"""Given/When/Then: exact-state backup assurance against real Dolt fixtures.

AK evidence comes from a fixture `ak` on PATH; no live Vault, AK record or backup is touched.
"""
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

SCRIPTS = Path(__file__).resolve().parent.parent / 'scripts'
sys.path.insert(0, str(SCRIPTS))
import pv_backup_assurance as assurance
import pv_skill_store as store

WORKSTATION = '/home/tryinget/ai-society/softwareco/infra/workstation'
DS1621 = '/home/tryinget/ai-society/softwareco/infra/ds1621-admin'
SID = '7' * 64
COMPANIES = ['core', 'software', 'finance', 'house', 'health', 'teaching', 'holding']
FAKE_AK = '''#!/bin/sh
# Fixture AK: `ak evidence show ID -F json` reads $FIXTURE_AK_DIR/ID.json.
[ "$1 $2" = "evidence show" ] || exit 64
[ -f "$FIXTURE_AK_DIR/$3.json" ] || { echo "Evidence not found: $3" >&2; exit 1; }
cat "$FIXTURE_AK_DIR/$3.json"
'''


class Assurance(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.owned = tempfile.TemporaryDirectory(prefix='pv-assurance-tests-', dir=os.environ['TMPDIR'])
        cls.base_root = Path(cls.owned.name)
        cls.home, cls.base = cls.base_root / 'home', cls.base_root / 'base-vault'
        cls.home.mkdir()
        cls.common = dict(os.environ, HOME=str(cls.home), TMPDIR=str(cls.base_root),
                          VAULT_DIR=str(cls.base), PYTHONDONTWRITEBYTECODE='1')
        for key, value in (('user.name', 'Assurance fixture'), ('user.email', 'fixture@invalid.local')):
            subprocess.run(['dolt', 'config', '--global', '--add', key, value], env=cls.common,
                           check=True, capture_output=True)
        result = subprocess.run([str(SCRIPTS / 'init-vault.sh')], env=cls.common, capture_output=True)
        if result.returncode:
            raise RuntimeError(result.stderr.decode())

    @classmethod
    def tearDownClass(cls):
        cls.owned.cleanup()

    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix='case-', dir=self.base_root)
        self.root = Path(self.temporary.name)
        self.vault = self.root / 'vault'
        shutil.copytree(self.base, self.vault, ignore=shutil.ignore_patterns('LOCK', 'tmp', 'temptf', 'stats'))
        (self.vault / '.dolt/tmp').mkdir(exist_ok=True)
        (self.vault / '.dolt/temptf').mkdir(exist_ok=True)
        self.bin, self.evidence = self.root / 'bin', self.root / 'evidence'
        self.bin.mkdir()
        self.evidence.mkdir()
        (self.bin / 'ak').write_text(FAKE_AK)
        (self.bin / 'ak').chmod(0o755)
        self.env = dict(self.common, VAULT_DIR=str(self.vault), TMPDIR=str(self.root),
                        FIXTURE_AK_DIR=str(self.evidence), PATH=f'{self.bin}:{os.environ["PATH"]}')
        os.environ.update(FIXTURE_AK_DIR=str(self.evidence), VAULT_DIR=str(self.vault),
                          PATH=self.env['PATH'])
        self.capture = self.root / 'capture'
        self.capture.mkdir()
        self.manifest = self.capture / 'capture-manifest.json'
        self.write_capture()
        self.records = {'primary': self.record('primary'), 'offsite': self.record('offsite')}
        self.save_evidence(101, 'primary', self.records['primary'])
        self.save_evidence(202, 'offsite', self.records['offsite'])
        self.receipt = self.root / 'receipt.json'

    def tearDown(self):
        os.environ.update(PATH=self.common['PATH'])
        self.temporary.cleanup()

    # Given helpers -----------------------------------------------------------------
    def write_capture(self):
        vault = self.vault.resolve()
        manifest = {'schema': 'workstation/dolt-stable-capture/v1', 'source': str(vault),
                    'source_identity': assurance.live_identity(vault),
                    'tables': assurance.live_tables(vault), 'files': []}
        self.manifest.write_text(json.dumps(manifest, indent=2))
        self.manifest_sha = hashlib.sha256(self.manifest.read_bytes()).hexdigest()
        self.manifest_value = manifest

    def record(self, kind, **changes):
        value = {'schema': 'prompt-vault/recovery-record/v1', 'kind': kind,
                 'origin': {'primary': 'primary_repository', 'offsite': 'offsite_archive_export'}[kind],
                 'snapshot_id': SID, 'snapshot_tree': 'e' * 64,
                 'repository': {'primary': 'sftp:fixture-primary', 'offsite': 'sftp:fixture-offsite'}[kind],
                 'restic_version': '0.18.1', 'restore': {'exit': 0, 'verify': True, 'overwrite': 'never'},
                 'vault': self.manifest_value['source'], 'capture_manifest_sha256': self.manifest_sha,
                 'restored_manifest_sha256': self.manifest_sha, 'restored_files_match_manifest': True,
                 'total_bytes': 1,
                 'native_probe': {'fsck_ok': True, 'digest_algorithm': assurance.ALGORITHM,
                                  'identity': self.manifest_value['source_identity'],
                                  'tables_sha256': assurance.digest(self.manifest_value['tables'])}}
        value.update(changes)
        return value

    def save_evidence(self, number, kind, details, **changes):
        row = {'id': number, 'task_id': number, 'repo': {'primary': WORKSTATION, 'offsite': DS1621}[kind],
               'check_type': 'backup_recovery_record', 'result': 'pass', 'details': details}
        row.update(changes)
        (self.evidence / f'{number}.json').write_text(json.dumps(row))

    def bind(self, status=0, primary=101, offsite=202):
        return self.cli('bind', '--vault', self.vault, '--capture-manifest', self.manifest,
                        '--snapshot-id', SID, '--primary-evidence', primary,
                        '--offsite-evidence', offsite, '--out', self.receipt, status=status)

    def cli(self, *args, status=0):
        result = subprocess.run([str(SCRIPTS / 'pv'), 'backup-assurance', *map(str, args)],
                                env=self.env, cwd=self.root, text=True, capture_output=True)
        self.assertEqual(result.returncode, status, result.stdout + result.stderr)
        return result

    def preflight(self, stage, status, receipt=True):
        root = Path(tempfile.mkdtemp(prefix='preflight-' + stage + '-', dir=self.root))
        (root / 'prompt-vault-db').symlink_to(self.vault, target_is_directory=True)
        env = dict(self.env)
        if receipt:
            env['PV_BACKUP_ASSURANCE_RECEIPT'] = str(self.receipt)
        result = subprocess.run([str(SCRIPTS / 'db-change-preflight.sh'), '--stage', stage], cwd=root,
                                env=env, text=True, capture_output=True)
        self.assertEqual(result.returncode, status, result.stdout + result.stderr)
        return result.stdout + result.stderr

    def sql(self, value, write=False):
        return store.query(value, write=write)

    def refused(self, reason):
        result = self.cli('verify', '--receipt', self.receipt, '--vault', self.vault, status=1)
        self.assertIn('unable_to_verify', result.stderr)
        self.assertIn(reason, result.stderr)
        self.assertNotIn('"verified": true', result.stdout)

    # Scenarios ---------------------------------------------------------------------
    def test_digest_algorithm_is_pinned_to_the_workstation_serialization(self):
        value = [{'row_sha256': 'a' * 64}]
        self.assertEqual(assurance.digest(value), hashlib.sha256(
            b'[{"row_sha256":"' + b'a' * 64 + b'"}]').hexdigest())
        self.assertEqual(assurance.encoded({'é': 1}), b'{"\\u00e9":1}')

    def test_given_exact_state_and_both_records_when_db_test_preflight_runs_then_it_admits(self):
        self.bind()
        receipt = json.loads(self.receipt.read_text())
        self.assertEqual(receipt['schema'], 'prompt-vault/backup-assurance-receipt/v1')
        self.assertEqual(receipt['evidence'], {'primary': 101, 'offsite': 202})
        verified = json.loads(self.cli('verify', '--receipt', self.receipt, '--vault', self.vault).stdout)
        self.assertTrue(verified['verified'])
        self.assertEqual(verified['identity'], self.manifest_value['source_identity'])
        output = self.preflight('db-test', 0)
        self.assertIn('OK   backup assurance verified', output)
        self.assertIn('ASSURED_IDENTITY ' + json.dumps(verified['identity'], sort_keys=True), output)
        self.assertIn('result: PASS', output)

    def test_given_valid_receipt_when_db_stage_or_prod_runs_then_owner_gates_still_refuse(self):
        self.bind()
        for stage in ('db-stage', 'db-prod'):
            output = self.preflight(stage, 1)
            self.assertIn('OK   backup assurance verified', output)
            self.assertIn('Gate B', output)
            self.assertNotIn('result: PASS', output)

    def test_given_no_or_arbitrary_receipt_when_db_test_runs_then_unable_to_verify(self):
        output = self.preflight('db-test', 1, receipt=False)
        self.assertIn('backup assurance unable_to_verify', output)
        self.receipt.write_text(json.dumps({'protected': True}))
        output = self.preflight('db-test', 1)
        self.assertIn('backup assurance unable_to_verify', output)
        self.assertNotIn('result: PASS', output)

    def test_given_live_drift_after_capture_when_verified_then_refused(self):
        self.bind()
        self.sql("INSERT INTO collections (name, description) VALUES ('drift', 'post-capture change');", write=True)
        self.refused('drift')
        self.preflight('db-test', 1)

    def test_given_receipt_for_another_vault_when_verified_then_refused(self):
        self.bind()
        other = self.root / 'other-vault'
        shutil.copytree(self.vault, other)
        result = self.cli('verify', '--receipt', self.receipt, '--vault', other, status=1)
        self.assertIn('vault', result.stderr)

    def test_given_changed_capture_manifest_when_verified_then_refused(self):
        self.bind()
        self.manifest.write_text(self.manifest.read_text() + ' ')
        self.refused('capture manifest')

    def test_given_offsite_record_for_other_snapshot_or_capture_when_bound_then_refused(self):
        for changes in ({'snapshot_id': '8' * 64}, {'capture_manifest_sha256': 'f' * 64},
                        {'restored_manifest_sha256': 'f' * 64}):
            with self.subTest(changes=changes):
                self.save_evidence(202, 'offsite', self.record('offsite', **changes))
                self.assertIn('offsite', self.bind(status=1).stderr)

    def test_given_primary_assisted_or_same_domain_offsite_when_bound_then_refused(self):
        cases = [{'repository': 'sftp:fixture-primary'}, {'origin': 'primary_repository'},
                 {'kind': 'primary', 'origin': 'primary_repository'}]
        for changes in cases:
            with self.subTest(changes=changes):
                self.save_evidence(202, 'offsite', dict(self.record('offsite'), **changes))
                self.bind(status=1)
        self.save_evidence(202, 'offsite', self.record('offsite'))
        self.assertIn('distinct', self.bind(status=1, offsite=101).stderr)

    def test_given_unbound_or_failed_evidence_rows_when_bound_then_refused(self):
        variants = [({'check_type': 'validation'}, None), ({'result': 'fail'}, None),
                    ({'repo': WORKSTATION}, None), ({}, {'protected': True, 'result': 'pass'})]
        for row_changes, details in variants:
            with self.subTest(row=row_changes, details=details):
                self.save_evidence(202, 'offsite', details or self.record('offsite'), **row_changes)
                self.assertIn('offsite', self.bind(status=1).stderr)

    def test_given_unverified_restore_or_probe_mismatch_when_bound_then_refused(self):
        identity = dict(self.manifest_value['source_identity'], working_root='x' * 32)
        cases = [{'restore': {'exit': 0, 'verify': False, 'overwrite': 'never'}},
                 {'restore': {'exit': 1, 'verify': True, 'overwrite': 'never'}},
                 {'restored_files_match_manifest': False},
                 {'native_probe': dict(self.records['primary']['native_probe'], fsck_ok=False)},
                 {'native_probe': dict(self.records['primary']['native_probe'], identity=identity)},
                 {'native_probe': dict(self.records['primary']['native_probe'], tables_sha256='0' * 64)}]
        for changes in cases:
            with self.subTest(changes=changes):
                self.save_evidence(101, 'primary', self.record('primary', **changes))
                self.assertIn('primary', self.bind(status=1).stderr)

    def test_given_ak_cannot_read_evidence_when_verified_then_unable_to_verify(self):
        self.bind()
        (self.evidence / '202.json').unlink()
        self.refused('evidence')

    def test_given_two_skills_and_valid_receipt_when_bulk_import_applies_then_exact_state_is_consumed(self):
        agent = self.root / 'agent'
        entries = []
        for name in ('first-skill', 'second-skill'):
            source = agent / name
            source.mkdir(parents=True)
            (source / 'SKILL.md').write_text(f'---\nname: {name}\ndescription: Use when testing assurance.\n---\n\n# Skill\n')
            entries.append({'name': name, 'root': 'agent', 'path': name, 'source_owner': 'fixture owner',
                            'owner_company': 'core', 'visibility_companies': COMPANIES})
        catalogue, plan = self.root / 'catalogue.json', self.root / 'plan.json'
        catalogue.write_text(json.dumps({'schema': 'prompt-vault/skill-catalogue/v1',
                                         'authority': 'original_source_package', 'skills': entries}))
        self.bind()
        env = dict(self.env, PV_BACKUP_ASSURANCE_RECEIPT=str(self.receipt))
        def run(*args, status=0):
            result = subprocess.run([str(SCRIPTS / 'pv'), 'skill-bundle', *map(str, args)], env=env,
                                    cwd=self.root, capture_output=True, text=True)
            self.assertEqual(result.returncode, status, result.stdout + result.stderr)
        run('plan', '--catalogue', catalogue, '--agent-root', agent, '--out', plan)
        run('import', '--catalogue', catalogue, '--agent-root', agent, '--plan', plan, '--apply')
        self.assertEqual(self.sql('SELECT name FROM skills ORDER BY name'),
                         [{'name': 'first-skill'}, {'name': 'second-skill'}])
        # The mutation changed the working set: the same receipt can never admit again.
        self.refused('drift')

    def test_given_working_root_moved_after_preflight_when_transaction_runs_then_guard_admits_nothing(self):
        assured = assurance.live_identity(self.vault.resolve())
        moved = dict(assured, working_root='0' * 32)
        binding = {'branch': assured['branch'], 'head': assured['head']}
        manifest = {'name': 'guarded', 'source_frontmatter': {'description': 'x'}, 'owner_company': 'core',
                    'visibility_companies': ['core'], 'files': [{'path': 'SKILL.md'}]}
        items = [(manifest, {'SKILL.md': b'---\nname: guarded\n---\n'}, None, False)]
        rows = self.sql(store.import_sql(items, binding, moved), write=True)
        self.assertEqual(rows, [{'admitted': 0, 'planned_changes': 1}])
        self.assertEqual(self.sql('SELECT COUNT(*) AS n FROM skills'), [{'n': 0}])
        self.assertEqual(assurance.live_identity(self.vault.resolve()), assured)


if __name__ == '__main__':
    unittest.main()
