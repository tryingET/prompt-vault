"""Real Dolt/CLI regressions; all data, HOME and projections are owned fixtures."""
import contextlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

SCRIPTS = Path(__file__).resolve().parent.parent / 'scripts'
sys.path.insert(0, str(SCRIPTS))
import pv_skill_bundle as bundle
import pv_skill_store as store
import pv_skill_projection as projection

COMPANIES = ['core', 'software', 'finance', 'house', 'health', 'teaching', 'holding']


class Bundles(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.owned = tempfile.TemporaryDirectory(prefix='pv-skill-tests-', dir=os.environ['TMPDIR'])
        cls.base_root = Path(cls.owned.name)
        cls.home, cls.base = cls.base_root / 'home', cls.base_root / 'base-vault'
        cls.home.mkdir()
        cls.common = dict(os.environ, HOME=str(cls.home), TMPDIR=str(cls.base_root),
                          VAULT_DIR=str(cls.base), PYTHONDONTWRITEBYTECODE='1')
        for key, value in (('user.name', 'Skill bundle fixture'), ('user.email', 'fixture@invalid.local')):
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
        self.vault, self.agent = self.root / 'vault', self.root / 'agent'
        shutil.copytree(self.base, self.vault,
                        ignore=shutil.ignore_patterns('LOCK', 'tmp', 'temptf', 'stats'))
        (self.vault / '.dolt/tmp').mkdir(exist_ok=True)
        (self.vault / '.dolt/temptf').mkdir(exist_ok=True)
        self.agent.mkdir()
        self.env = dict(self.common, VAULT_DIR=str(self.vault), TMPDIR=str(self.root))
        self.entry = {'name': 'test-skill', 'root': 'agent', 'path': 'test-skill',
                      'source_owner': 'fixture owner, not Vault', 'owner_company': 'core',
                      'visibility_companies': COMPANIES}
        self.source = self.make_source('test-skill')
        self.catalogue = self.root / 'catalogue.json'
        self.write_catalogue([self.entry])
        self.plan = self.root / 'plan.json'
        self.exports = self.root / 'exports'
        self.exports.mkdir()
        self.target = self.exports / 'test-skill'

    def tearDown(self):
        self.temporary.cleanup()

    def make_source(self, name):
        source = self.agent / name
        (source / 'scripts').mkdir(parents=True)
        (source / 'assets').mkdir()
        (source / 'SKILL.md').write_text(f'---\nname: {name}\ndescription: >-\n  Use when testing quoted, multiline skills.\nlicense: MIT\ncompatibility: Linux\nmetadata:\n  owner: Original fixture author\n---\n\n# Skill\nNever execute on import.\n')
        script = source / 'scripts/run.sh'
        script.write_bytes(b'#!/bin/sh\n# Unicode: \xc3\xa9; quoted: "x,y"\r\nexit 0\n')
        script.chmod(0o755)
        (source / 'assets/payload.bin').write_bytes(b'\x00\xff\x01raw\r\n')
        return source

    def write_catalogue(self, entries):
        self.catalogue.write_text(json.dumps({'schema': 'prompt-vault/skill-catalogue/v1',
                                              'authority': 'original_source_package', 'skills': entries}))

    def command(self, *args, status=0, env=None):
        result = subprocess.run([str(SCRIPTS / 'pv'), 'skill-bundle', *map(str, args)],
                                env=env or self.env, cwd=self.root, text=True, capture_output=True)
        self.assertEqual(result.returncode, status, result.stdout + result.stderr)
        return result

    def sql(self, value):
        result = subprocess.run([str(SCRIPTS / 'pv'), 'sql', '-r', 'json', '-q', value],
                                env=self.env, text=True, capture_output=True, check=True)
        return json.loads(result.stdout)['rows'] if result.stdout.strip() else []

    def plan_args(self):
        return ['--catalogue', self.catalogue, '--agent-root', self.agent]

    def generate_plan(self, path=None):
        path = path or self.plan
        self.command('plan', *self.plan_args(), '--out', path)
        return json.loads(path.read_text())

    def apply(self, plan=None):
        return self.command('import', *self.plan_args(), '--plan', plan or self.plan, '--apply')

    def install_snapshot(self):
        self.generate_plan()
        self.apply()

    def test_plan_and_default_import_are_read_only(self):
        before = self.sql('SELECT COUNT(*) AS n FROM prompt_templates')
        self.generate_plan()
        result = self.command('import', *self.plan_args(), '--plan', self.plan)
        self.assertEqual(json.loads(result.stdout)['effect'], 'plan_only')
        self.assertEqual(self.sql('SELECT COUNT(*) AS n FROM skills'), [{'n': 0}])
        self.assertEqual(self.sql('SELECT COUNT(*) AS n FROM prompt_templates'), before)
        self.command('plan', *self.plan_args(), '--out', self.plan, status=1)

    def test_import_and_complete_binary_executable_roundtrip(self):
        self.install_snapshot()
        row = json.loads(self.command('inspect', '--name', 'test-skill', '--content').stdout)
        self.assertEqual(row['version'], 1)
        self.assertEqual(row['readme'].encode(), (self.source / 'SKILL.md').read_bytes())
        self.assertEqual(row['metadata']['authoring_authority'], 'original_source_package')
        self.assertEqual(self.sql('SELECT COUNT(*) AS n FROM skill_assets'), [{'n': 2}])
        self.command('export', '--name', 'test-skill', '--target', self.target)
        self.assertFalse(self.target.exists())
        self.command('export', '--name', 'test-skill', '--target', self.target, '--apply')
        for relative in ('SKILL.md', 'scripts/run.sh', 'assets/payload.bin'):
            self.assertEqual((self.target / relative).read_bytes(), (self.source / relative).read_bytes())
        self.assertEqual((self.target / 'scripts/run.sh').stat().st_mode & 0o777, 0o755)
        self.command('check', '--name', 'test-skill', '--target', self.target)

    def test_repeat_import_and_export_are_true_noops(self):
        self.install_snapshot()
        old = self.sql('SELECT id,version,updated_at FROM skills')
        assets = self.sql('SELECT id,path,updated_at FROM skill_assets ORDER BY path')
        repeat = self.root / 'repeat.json'
        self.generate_plan(repeat)
        self.assertEqual(json.loads(self.apply(repeat).stdout)['effect'], 'noop')
        self.assertEqual(self.sql('SELECT id,version,updated_at FROM skills'), old)
        self.assertEqual(self.sql('SELECT id,path,updated_at FROM skill_assets ORDER BY path'), assets)
        self.command('export', '--name', 'test-skill', '--target', self.target, '--apply')
        self.assertEqual(json.loads(self.command('export', '--name', 'test-skill', '--target', self.target, '--apply').stdout)['effect'], 'noop')

    def test_source_drift_refuses_stale_plan(self):
        self.generate_plan()
        (self.source / 'SKILL.md').write_text((self.source / 'SKILL.md').read_text() + 'changed\n')
        result = self.command('import', *self.plan_args(), '--plan', self.plan, '--apply', status=1)
        self.assertIn('differs', result.stderr)
        self.assertEqual(self.sql('SELECT COUNT(*) AS n FROM skills'), [{'n': 0}])

    def test_row_governance_lifecycle_drift_refuses_stale_plan(self):
        self.install_snapshot()
        later = self.root / 'later.json'
        self.generate_plan(later)
        self.sql("UPDATE skills SET status='draft' WHERE name='test-skill'")
        self.command('import', *self.plan_args(), '--plan', later, '--apply', status=1)
        self.assertEqual(self.sql('SELECT status,version FROM skills'), [{'status': 'draft', 'version': 1}])
        self.command('export', '--name', 'test-skill', '--target', self.target, '--apply', status=1)

    def test_asset_drift_is_detected_even_without_row_version_change(self):
        self.install_snapshot()
        later = self.root / 'later.json'
        self.generate_plan(later)
        self.sql("UPDATE skill_assets SET content='foreign edit' WHERE path='scripts/run.sh'")
        self.command('import', *self.plan_args(), '--plan', later, '--apply', status=1)
        self.command('inspect', '--name', 'test-skill', status=1)
        self.assertEqual(self.sql('SELECT version FROM skills'), [{'version': 1}])

    def test_update_replaces_only_selected_assets_and_versions(self):
        self.install_snapshot()
        self.sql("INSERT INTO skills(name,description,readme,owner_company,visibility_companies,status) VALUES ('unrelated','d','body','core','[\"core\"]','draft')")
        (self.source / 'assets/payload.bin').unlink()
        (self.source / 'SKILL.md').write_text((self.source / 'SKILL.md').read_text() + 'new content\n')
        later = self.root / 'updated.json'
        self.generate_plan(later)
        self.apply(later)
        self.assertEqual(self.sql("SELECT version FROM skills WHERE name='test-skill'"), [{'version': 2}])
        self.assertEqual(self.sql('SELECT COUNT(*) AS n FROM skill_assets'), [{'n': 1}])
        self.assertEqual(self.sql("SELECT readme FROM skills WHERE name='unrelated'"), [{'readme': 'body'}])

    def test_given_unbound_copies_when_bulk_import_then_no_dolt_effects(self):
        # Given two selected skills and a real private Dolt fixture.
        self.make_source('second-skill')
        second = dict(self.entry, name='second-skill', path='second-skill')
        self.write_catalogue([self.entry, second])
        self.generate_plan()
        # All configured paths are explicitly absent; cannot inherit machine backups.
        env = dict(self.env, PV_BACKUP_LOCAL_PATH=str(self.root / 'absent-local'),
                   PV_BACKUP_DS1621_PATH=str(self.root / 'absent-primary'),
                   PV_BACKUP_OFFSITE_PATH=str(self.root / 'absent-offsite'))
        identity = "SELECT active_branch() AS branch, DOLT_HASHOF('HEAD') AS head, DOLT_HASHOF_DB('WORKING') AS working, DOLT_HASHOF_DB('STAGED') AS staged"
        before = self.sql(identity)
        result = self.command('import', *self.plan_args(), '--plan', self.plan, '--apply', status=1, env=env)
        self.assertIn('backup assurance unable_to_verify', result.stderr)
        self.assertEqual(self.sql(identity), before)
        self.assertEqual(self.sql('SELECT COUNT(*) AS n FROM skills'), [{'n': 0}])
        self.assertEqual(self.sql('SELECT COUNT(*) AS n FROM skill_assets'), [{'n': 0}])
        # Given three local copies: real bytes, but no independent offsite recovery
        # or accepted owner contract. They must not stand in for assurance.
        for label in ('local', 'primary', 'offsite'):
            dest = self.root / label
            shutil.copytree(self.vault, dest)
            env['PV_BACKUP_' + {'local': 'LOCAL', 'primary': 'DS1621', 'offsite': 'OFFSITE'}[label] + '_PATH'] = str(dest)
        # When the actual operator CLI submits the bulk plan, Then refuse before SQL.
        result = self.command('import', *self.plan_args(), '--plan', self.plan, '--apply', status=1, env=env)
        self.assertIn('backup assurance unable_to_verify', result.stderr)
        self.assertIn('no writes', result.stderr)
        self.assertEqual(self.sql('SELECT COUNT(*) AS n FROM skills'), [{'n': 0}])
        self.assertEqual(self.sql('SELECT COUNT(*) AS n FROM skill_assets'), [{'n': 0}])
        self.assertEqual(self.sql(identity), before)

    def test_given_one_noop_one_new_when_bulk_import_then_whole_scope_refuses(self):
        # Given one stored skill and one new skill, not two new rows.
        self.install_snapshot()
        self.make_source('second-skill')
        second = dict(self.entry, name='second-skill', path='second-skill')
        self.write_catalogue([self.entry, second])
        later = self.root / 'mixed.json'
        self.generate_plan(later)
        before = self.sql("SELECT DOLT_HASHOF_DB('WORKING') AS working, DOLT_HASHOF_DB('STAGED') AS staged")
        # When one of two selected skills would change, Then do not downgrade to db-dev.
        result = self.command('import', *self.plan_args(), '--plan', later, '--apply', status=1)
        self.assertIn('backup assurance unable_to_verify', result.stderr)
        self.assertEqual(self.sql("SELECT DOLT_HASHOF_DB('WORKING') AS working, DOLT_HASHOF_DB('STAGED') AS staged"), before)
        self.assertEqual(self.sql('SELECT name,version FROM skills'), [{'name': 'test-skill', 'version': 1}])

    def test_given_all_noops_when_bulk_plan_repeats_then_no_mutation_or_new_admission(self):
        # Given both fixtures installed by separately scoped single-skill operations.
        self.install_snapshot()
        self.make_source('second-skill')
        second = dict(self.entry, name='second-skill', path='second-skill')
        self.write_catalogue([second])
        single = self.root / 'second.json'
        self.generate_plan(single)
        self.apply(single)
        self.write_catalogue([self.entry, second])
        later = self.root / 'noops.json'
        self.generate_plan(later)
        before = self.sql("SELECT DOLT_HASHOF_DB('WORKING') AS working, DOLT_HASHOF_DB('STAGED') AS staged")
        # When all selected snapshots are already identical, Then no-op stays effect-free.
        result = self.apply(later)
        self.assertEqual(json.loads(result.stdout)['effect'], 'noop')
        self.assertEqual(self.sql("SELECT DOLT_HASHOF_DB('WORKING') AS working, DOLT_HASHOF_DB('STAGED') AS staged"), before)

    def test_transaction_rechecks_current_row_and_assets(self):
        self.install_snapshot()
        (self.source / 'SKILL.md').write_text((self.source / 'SKILL.md').read_text() + 'new\n')
        later = self.root / 'later.json'
        approved = self.generate_plan(later)
        real_query = store.query
        def racing_query(sql, *, write=False):
            if write:
                real_query("UPDATE skills SET status='draft' WHERE name='test-skill'", write=True)
            return real_query(sql, write=write)
        with patch.dict(os.environ, self.env), patch.object(store, 'query', racing_query):
            with self.assertRaisesRegex(ValueError, 'CAS refused'):
                store.apply_import(approved, {'test-skill': dict(self.entry, source=str(self.source))})
        self.assertEqual(self.sql('SELECT version,status FROM skills'), [{'version': 1, 'status': 'draft'}])

    def test_rejects_symlinks_hardlinks_and_traversal(self):
        (self.source / 'link.md').symlink_to(self.source / 'SKILL.md')
        self.command('plan', *self.plan_args(), status=1)
        (self.source / 'link.md').unlink()
        os.link(self.source / 'SKILL.md', self.source / 'hard.md')
        self.command('plan', *self.plan_args(), status=1)
        (self.source / 'hard.md').unlink()
        self.write_catalogue([dict(self.entry, path='../test-skill')])
        self.command('plan', *self.plan_args(), status=1)

    def test_private_evaluators_and_credentials_are_refused(self):
        (self.source / 'evals').mkdir()
        self.command('plan', *self.plan_args(), status=1)
        (self.source / 'evals').rmdir()
        (self.source / 'answers.json').write_text('{"expected_output":"private evaluator answer"}')
        self.command('plan', *self.plan_args(), status=1)
        (self.source / 'answers.json').unlink()
        (self.source / 'secret.txt').write_text('ghp_' + 'a' * 30)
        self.command('plan', *self.plan_args(), status=1)

    def test_invalid_metadata_binary_budget_and_unknown_names(self):
        self.write_catalogue([dict(self.entry, visibility_companies=['core'])])
        self.command('plan', *self.plan_args(), status=1)
        self.write_catalogue([self.entry])
        (self.source / 'assets/payload.bin').write_bytes(b'\x00' * 65536)
        self.command('plan', *self.plan_args(), status=1)
        self.command('inspect', '--name', 'unknown', status=1)
        self.command('inspect', '--name', "x' OR 1=1", status=1)

    def test_export_refuses_collisions_extra_files_and_symlink_parents(self):
        self.install_snapshot()
        self.target.mkdir()
        (self.target / 'SKILL.md').write_text('foreign')
        self.command('export', '--name', 'test-skill', '--target', self.target, '--apply', status=1)
        self.assertEqual((self.target / 'SKILL.md').read_text(), 'foreign')
        foreign = self.root / 'foreign'
        foreign.mkdir()
        (self.root / 'alias').symlink_to(foreign, target_is_directory=True)
        self.command('export', '--name', 'test-skill', '--target', self.root / 'alias/test-skill', '--apply', status=1)
        self.assertEqual(list(foreign.iterdir()), [])

    def test_projection_drift_is_never_overwritten(self):
        self.install_snapshot()
        self.command('export', '--name', 'test-skill', '--target', self.target, '--apply')
        script = self.target / 'scripts/run.sh'
        script.chmod(0o644)
        self.command('check', '--name', 'test-skill', '--target', self.target, status=1)
        self.command('export', '--name', 'test-skill', '--target', self.target, '--apply', status=1)
        self.assertEqual(script.stat().st_mode & 0o777, 0o644)

    def test_export_failure_reports_owned_partial_state(self):
        manifest, payloads = bundle.snapshot(self.source, self.entry)
        expected = {'schema': 'test', 'name': 'test-skill'}
        with patch.object(projection, 'write_at', side_effect=OSError('fixture disk fault')):
            with self.assertRaisesRegex(RuntimeError, 'KNOWN-PARTIAL'):
                projection.export(self.target, expected, manifest, payloads)
        self.assertEqual(json.loads((self.target / projection.RECEIPT).read_text())['state'], 'pending')

    def test_relative_vault_selector_is_normalized(self):
        """Explicit relative selector must bind once, not double-cd into another vault."""
        env = dict(self.env, VAULT_DIR='vault')
        self.command('plan', *self.plan_args(), env=env)

    def test_duplicate_yaml_keys_and_hidden_assets_are_refused(self):
        path = self.source / 'SKILL.md'
        path.write_text(path.read_text().replace('name: test-skill', 'name: test-skill\nname: overwritten'))
        self.command('plan', *self.plan_args(), status=1)
        path.write_text(path.read_text().replace('\nname: overwritten', ''))
        (self.source / 'assets/.private').write_text('hidden')
        self.command('plan', *self.plan_args(), status=1)

    def test_import_asset_failure_rolls_back_and_is_not_retried(self):
        approved = self.generate_plan()
        real_query, writes = store.query, []
        def failing_query(sql, *, write=False):
            if write:
                writes.append(sql)
                sql = sql.replace('COMMIT;', "INSERT INTO skill_assets(skill_id,path) VALUES(999999,'fault');\nCOMMIT;")
            return real_query(sql, write=write)
        with patch.dict(os.environ, self.env), patch.object(store, 'query', failing_query):
            with self.assertRaisesRegex(RuntimeError, 'indeterminate'):
                store.apply_import(approved, {'test-skill': dict(self.entry, source=str(self.source))})
        self.assertEqual(len(writes), 1)
        self.assertEqual(self.sql('SELECT COUNT(*) AS n FROM skills'), [{'n': 0}])
        self.assertEqual(self.sql('SELECT COUNT(*) AS n FROM skill_assets'), [{'n': 0}])

    def test_receipt_replacement_does_not_truncate_foreign_bytes(self):
        manifest, payloads = bundle.snapshot(self.source, self.entry)
        foreign = self.root / 'foreign-receipt'
        foreign.write_text('untouched')
        original = projection.write_at
        switched = []
        def replacing(directory_fd, relative, raw, mode):
            original(directory_fd, relative, raw, mode)
            if not switched:
                os.unlink(projection.RECEIPT, dir_fd=directory_fd)
                os.link(foreign, self.target / projection.RECEIPT)
                switched.append(True)
        with patch.object(projection, 'write_at', replacing):
            with self.assertRaisesRegex(RuntimeError, 'KNOWN-PARTIAL'):
                projection.export(self.target, {'schema': 'test'}, manifest, payloads)
        self.assertEqual(foreign.read_text(), 'untouched')

    def test_cleanup_failures_preserve_partial_effect_classification(self):
        manifest, payloads = bundle.snapshot(self.source, self.entry)
        original, count = os.close, []
        def close_then_fail(fd):
            original(fd)
            count.append(fd)
            raise OSError('fixture close reporting fault')
        with patch.object(projection, 'write_at', side_effect=OSError('write fault')), \
                patch.object(projection.os, 'close', close_then_fail), \
                contextlib.redirect_stderr(__import__('io').StringIO()) as messages:
            with self.assertRaisesRegex(RuntimeError, 'KNOWN-PARTIAL'):
                projection.export(self.target, {'schema': 'test'}, manifest, payloads)
        self.assertEqual(len(count), 3)
        self.assertIn('CLEANUP-INCOMPLETE', messages.getvalue())

    def test_branch_switch_invalidates_approved_plan(self):
        self.generate_plan()
        subprocess.run([str(SCRIPTS / 'pv'), 'branch', 'other'], env=self.env,
                       capture_output=True, check=True)
        self.command('import', *self.plan_args(), '--plan', self.plan, '--apply', status=1)
        self.assertEqual(self.sql('SELECT COUNT(*) AS n FROM skills'), [{'n': 0}])

    def test_bom_roundtrip_and_yaml_alias_refusal(self):
        skill = self.source / 'SKILL.md'
        skill.write_bytes(b'\xef\xbb\xbf' + skill.read_bytes())
        self.install_snapshot()
        self.command('export', '--name', 'test-skill', '--target', self.target, '--apply')
        self.assertEqual((self.target / 'SKILL.md').read_bytes(), skill.read_bytes())
        skill.write_text(skill.read_text().replace('owner: Original fixture author', 'owner: &a Original fixture author\n  copy: *a'))
        self.command('plan', *self.plan_args(), status=1)

    def test_out_of_line_longtext_and_large_binary_roundtrip_and_cas(self):
        script = self.source / 'scripts/run.sh'
        script.write_bytes(('quoted \"x,y\" Unicode é\r\n' * 5000).encode())
        binary = self.source / 'assets/payload.bin'
        binary.write_bytes(bytes(range(256)) * 200)
        self.install_snapshot()
        self.command('export', '--name', 'test-skill', '--target', self.target, '--apply')
        self.assertEqual((self.target / 'scripts/run.sh').read_bytes(), script.read_bytes())
        self.assertEqual((self.target / 'assets/payload.bin').read_bytes(), binary.read_bytes())
        script.write_bytes(script.read_bytes() + b'changed\n')
        later = self.root / 'large-update.json'
        self.generate_plan(later)
        self.apply(later)
        self.assertEqual(self.sql('SELECT version FROM skills'), [{'version': 2}])
        self.command('inspect', '--name', 'test-skill')

    def test_acknowledged_import_readback_failure_is_known_partial(self):
        approved = self.generate_plan()
        real_query, real_capture, acknowledged = store.query, store.capture, []
        def tracking_query(sql, *, write=False):
            rows = real_query(sql, write=write)
            if write:
                acknowledged.append(True)
            return rows
        def failing_capture(name):
            if acknowledged:
                raise RuntimeError('fixture post-commit read failure')
            return real_capture(name)
        with patch.dict(os.environ, self.env), patch.object(store, 'query', tracking_query), \
                patch.object(store, 'capture', failing_capture):
            with self.assertRaisesRegex(RuntimeError, 'KNOWN-PARTIAL'):
                store.apply_import(approved, {'test-skill': dict(self.entry, source=str(self.source))})
        self.assertEqual(len(acknowledged), 1)
        self.assertEqual(self.sql('SELECT COUNT(*) AS n FROM skills'), [{'n': 1}])


if __name__ == '__main__':
    unittest.main()
