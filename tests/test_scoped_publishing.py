"""Real Dolt tests. Run through pv-scoped-publishing.bats for fixture isolation."""
import contextlib
import errno
import io
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest
from unittest import mock

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'scripts'))
import pv_scoped as cli
import pv_scoped_db as db
import pv_scoped_projection as fs


class Publishing(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        # Fail rather than silently using a real HOME, vault or projection.
        cls.root = Path(os.environ['PV_SCOPED_TEST_ROOT']).resolve(strict=True)
        cls.source = Path(os.environ['VAULT_DIR']).resolve(strict=True)
        for key in ('HOME', 'TMPDIR', 'VAULT_DIR', 'TEMPLATES_DIR', 'SKILLS_DIR'):
            if not Path(os.environ[key]).resolve().is_relative_to(cls.root):
                raise RuntimeError(f'unisolated fixture environment: {key}')

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(dir=self.root)
        self.addCleanup(self.temp.cleanup)
        self.work = Path(self.temp.name)
        self.vault = self.work / 'prompt-vault-db'
        shutil.copytree(self.source, self.vault, ignore=shutil.ignore_patterns('LOCK', 'tmp', 'temptf', 'stats'))
        self.prompts, self.skills = self.work / 'prompts', self.work / 'skills'
        self.prompts.mkdir()
        self.skills.mkdir()
        self.env = mock.patch.dict(os.environ, VAULT_DIR=str(self.vault),
                                   TEMPLATES_DIR=str(self.prompts), SKILLS_DIR=str(self.skills),
                                   PI_COMPANY='software', PV_CHANGELOG_AUTHOR='fixture-operator')
        self.env.start()
        self.addCleanup(self.env.stop)
        db.preflight(self.vault)
        db.query("DELETE FROM prompt_templates WHERE name IN ('commit','commit-terse','inversion');", write=True)
        for name, owner in [('commit', 'core'), ('commit-terse', 'holding'), ('inversion', 'core')]:
            db.query(f"""INSERT INTO prompt_templates
                (name, content, description, owner_company, visibility_companies, variables,
                 artifact_kind, control_mode, formalization_level, controlled_vocabulary,
                 status, export_to_pi, version)
                VALUES ({db.literal(name)}, {db.literal('---\ndescription: preserve\n---\nOld ' + name + '\n')},
                'preserve description', {db.literal(owner)}, {db.literal(json.dumps([owner, 'software']))},
                '["$1"]', 'procedure', 'one_shot', 'bounded', NULL, 'active', true, 4);""", write=True)
        self.rows = {name: db.get_row(name) for name in ('commit', 'commit-terse', 'inversion')}
        full = {'schema': 'prompt-vault/pi-export-receipt/v2', 'policy': fs.POLICY,
                'source': {'vault_dir': '/fixture-owned/not-canonical'},
                'templates': [], 'quarantined': [], 'candidate_count': 3,
                'exported_count': 3, 'quarantined_count': 0}
        for name, row in self.rows.items():
            item = fs.projection(row)
            (self.prompts / item['path']).write_bytes(fs.policy.content_bytes(row['content']))
            full['templates'].append({'name': name, 'path': item['path'], 'version': 4,
                                      'sha256': item['projected_sha256']})
        (self.prompts / fs.FULL).write_bytes(fs.encoded(full))
        (self.prompts / fs.MANIFEST).write_bytes(b'commit.md\ncommit-terse.md\ninversion.md\n.prompt-vault-export-state.json\n')
        (self.prompts / 'inversion.md').write_text('unrelated installed inversion drift\n')
        (self.prompts / 'unmanaged.md').write_bytes(b'operator file\n')
        (self.prompts / 'unrelated-link.md').symlink_to('unmanaged.md')
        (self.skills / 'external').mkdir()
        (self.skills / 'external/SKILL.md').write_bytes(b'unrelated skill\n')
        (self.skills / fs.MANIFEST).write_bytes(b'external\n')
        (self.skills / 'skill-link').symlink_to('external', target_is_directory=True)
        self.content = self.work / 'content.txt'
        self.content.write_bytes(b'---\ndescription: preserve\n---\nNew \'quoted\' \\ $1 \xe2\x9c\x93\n\n')

    def command(self, *args, status=0):
        proc = subprocess.run([str(db.SCRIPTS / 'pv'), 'scoped', *args], text=True, capture_output=True)
        self.assertEqual(proc.returncode, status, proc.stdout + proc.stderr)
        return proc

    def update_args(self, name='commit', **overrides):
        row = self.rows[name]
        opts = {'name': name, 'expected-owner': row['owner_company'], 'expected-version': row['version'],
                'expected-content-sha256': db.digest(row['content'].encode()), 'content-file': self.content}
        opts.update(overrides)
        return ['update', *[str(x) for pair in opts.items() for x in ('--' + pair[0], pair[1])]]

    def snapshot(self):
        return {str(p.relative_to(self.work)): ('symlink', os.readlink(p)) if p.is_symlink() else
                ('bytes', p.read_bytes()) for root in (self.prompts, self.skills)
                for p in root.rglob('*') if p.is_symlink() or p.is_file()}

    def unrelated(self):
        return {key: value for key, value in self.snapshot().items()
                if key not in ('prompts/commit.md', 'prompts/commit-terse.md')
                and not key.startswith('prompts/.prompt-vault-scoped-commit')}

    def logs(self):
        return db.query('SELECT * FROM changelog ORDER BY id')

    def test_exact_two_updates_preserve_metadata_unrelated_and_provenance(self):
        before, logs = self.unrelated(), self.logs()
        for name in ('commit', 'commit-terse'):
            self.command(*self.update_args(name), '--apply')
            row = db.get_row(name)
            self.assertEqual(row['version'], 5)
            self.assertEqual(row['content'].encode(), self.content.read_bytes())
            for field in row.keys() - {'version', 'content', 'updated_at'}:
                self.assertEqual(row[field], self.rows[name][field], field)
            receipt = json.loads((self.prompts / f'.prompt-vault-scoped-{name}.json').read_bytes())
            self.assertEqual(receipt['source'], {'vault_dir': str(self.vault), 'template_id': row['id']})
        self.command('check', '--name', 'commit', '--name', 'commit-terse')
        self.assertEqual(self.unrelated(), before)
        self.assertEqual(len(self.logs()), len(logs) + 2)
        self.assertEqual([(r['old_version'], r['new_version']) for r in self.logs()[-2:]], [(4, 5), (4, 5)])
        proc = subprocess.run([str(db.SCRIPTS / 'pv-export-freshness')], capture_output=True, text=True)
        self.assertEqual(proc.returncode, 1)
        self.assertIn('stale', proc.stderr)
        self.assertEqual(os.environ['PI_COMPANY'], 'software')

    def test_exact_two_export_changes_only_selected_and_scoped_receipts(self):
        before, logs = self.unrelated(), self.logs()
        for name in ('commit', 'commit-terse'):
            db.query(f"UPDATE prompt_templates SET content='changed fixture', version=5 WHERE name={db.literal(name)};", write=True)
        self.command('export', '--name', 'commit', '--name', 'commit-terse', '--dry-run')
        self.assertFalse(list(self.prompts.glob('.prompt-vault-scoped-*')))
        self.command('export', '--name', 'commit', '--name', 'commit-terse', '--apply')
        self.command('check', '--name', 'commit', '--name', 'commit-terse')
        self.assertEqual(self.unrelated(), before)
        self.assertEqual(self.logs(), logs)

    def test_owner_version_content_mismatch_before_any_write(self):
        before, logs = self.snapshot(), self.logs()
        for wrong in ({'expected-owner': 'holding'}, {'expected-version': 99},
                      {'expected-content-sha256': '0' * 64}):
            self.command(*self.update_args(**wrong), '--apply', status=1)
            self.assertEqual(db.get_row('commit'), self.rows['commit'])
            self.assertEqual(self.snapshot(), before)
            self.assertEqual(self.logs(), logs)

    def test_plan_and_unchanged_are_noops(self):
        before, logs = self.snapshot(), self.logs()
        self.command(*self.update_args(), '--dry-run')
        self.command(*self.update_args())
        self.content.write_bytes(self.rows['commit']['content'].encode())
        proc = self.command(*self.update_args(), '--apply')
        self.assertIn('noop', proc.stdout)
        self.assertEqual(self.snapshot(), before)
        self.assertEqual(db.get_row('commit'), self.rows['commit'])
        self.assertEqual(self.logs(), logs)
        self.command('check', '--name', 'commit', status=1)  # no fabricated freshness

    def test_stale_selected_refuses_before_db_write(self):
        (self.prompts / 'commit.md').write_bytes(b'operator drift')
        before = self.snapshot()
        proc = self.command(*self.update_args(), '--apply', status=1)
        self.assertIn('stale target', proc.stderr)
        self.command('export', '--name', 'commit', '--apply', status=1)
        self.assertEqual(db.get_row('commit'), self.rows['commit'])
        self.assertEqual(self.snapshot(), before)

    def test_invalid_missing_duplicate_and_case_alias_names(self):
        before = self.snapshot()
        for name in ('../commit', '/commit', '.', 'a..b', 'commit/other', 'commit\n', 'x' * 65, 'missing', 'Commit'):
            self.command('export', '--name', name, '--apply', status=1)
        self.command('export', '--name', 'commit', '--name', 'commit', '--apply', status=1)
        self.assertEqual(self.snapshot(), before)
        with mock.patch.object(db, 'query', return_value=[self.rows['commit']] * 2):
            with self.assertRaisesRegex(ValueError, 'ambiguous'):
                db.get_row('commit')

    def test_symlink_unmanaged_and_hardlink_collisions(self):
        file = self.prompts / 'commit.md'
        original = file.read_bytes()
        file.unlink()
        file.symlink_to('unmanaged.md')
        self.command(*self.update_args(), '--apply', status=1)
        self.assertEqual((self.prompts / 'unmanaged.md').read_bytes(), b'operator file\n')
        file.unlink()
        os.link(self.prompts / 'unmanaged.md', file)
        self.command('export', '--name', 'commit', '--apply', status=1)
        file.unlink()
        file.write_bytes(original)
        (self.prompts / fs.MANIFEST).write_bytes(b'inversion.md\n')
        proc = self.command(*self.update_args(), '--apply', status=1)
        self.assertIn('unmanaged collision', proc.stderr)
        self.assertEqual(db.get_row('commit'), self.rows['commit'])

    def test_symlink_ancestors_and_receipts_refused(self):
        link = self.work / 'alias'
        link.symlink_to(self.prompts, target_is_directory=True)
        with mock.patch.dict(os.environ, TEMPLATES_DIR=str(link)):
            self.command('export', '--name', 'commit', '--apply', status=1)
        (self.prompts / '.prompt-vault-scoped-commit.json').symlink_to('unmanaged.md')
        self.command(*self.update_args(), '--apply', status=1)
        self.assertEqual(db.get_row('commit'), self.rows['commit'])

    def test_cognitive_napkin_and_structured_exact_update(self):
        for level in ('napkin', 'structured'):
            with self.subTest(level=level):
                self.content.write_text('---\ndescription: preserve\n---\nCognitive repair ' + level + '\n')
                db.query(f"UPDATE prompt_templates SET artifact_kind='cognitive', formalization_level={db.literal(level)} WHERE name='commit';", write=True)
                self.rows['commit'] = db.get_row('commit')
                before = self.unrelated()
                self.command(*self.update_args(), '--dry-run')
                self.command(*self.update_args(), '--apply')
                after = db.get_row('commit')
                self.assertEqual(after['version'], self.rows['commit']['version'] + 1)
                self.assertEqual(after['content'], self.content.read_text())
                self.assertEqual(after['owner_company'], 'core')
                self.assertEqual(after['formalization_level'], level)
                self.assertEqual(self.unrelated(), before)
                self.command('check', '--name', 'commit')

    def test_gate_and_unpublished_refusal(self):
        before = self.snapshot()
        for field, value in [('formalization_level', 'workflow'), ('control_mode', 'loop'),
                             ('formalization_level', 'structured'), ('status', 'draft'), ('export_to_pi', 0)]:
            db.query(f'UPDATE prompt_templates SET {field}={db.literal(value)} WHERE name="commit";', write=True)
            self.command('export', '--name', 'commit', '--apply', status=1)
            self.command(*self.update_args(), '--apply', status=1)
            db.query(f'UPDATE prompt_templates SET {field}={db.literal(self.rows["commit"][field])} WHERE name="commit";', write=True)
        self.assertEqual(self.snapshot(), before)

    def test_cas_refuses_concurrent_content_and_governance_without_changelog(self):
        logs = self.logs()
        for field, value in [('content', 'concurrent same-version body'), ('status', 'draft'),
                             ('description', 'concurrent metadata'), ('controlled_vocabulary', '{}'),
                             ('owner_company', 'holding')]:
            old = db.get_row('commit')
            db.query(f'UPDATE prompt_templates SET {field}={db.literal(value)} WHERE name="commit";', write=True)
            actual = db.get_row('commit')
            with self.assertRaisesRegex(ValueError, 'CAS refused'):
                db.update(old, 'must not be written')
            self.assertEqual(db.get_row('commit'), actual)
            self.assertEqual(self.logs(), logs)

    def test_transaction_rolls_back_update_when_changelog_fails(self):
        logs = self.logs()
        with mock.patch.dict(os.environ, PV_CHANGELOG_AUTHOR='x' * 101):
            with self.assertRaisesRegex(RuntimeError, 'DO NOT retry'):
                db.update(self.rows['commit'], 'not committed')
        self.assertEqual(db.get_row('commit'), self.rows['commit'])
        self.assertEqual(self.logs(), logs)

    def test_known_partial_after_db_and_export_only_recovery(self):
        for fail_at in (1, 2, 3):
            with self.subTest(fail_at=fail_at):
                if fail_at != 1:
                    self.rows['commit'] = db.get_row('commit')
                    self.content.write_text(f'next fixture content {fail_at}\n')
                expected_version = self.rows['commit']['version'] + 1
                logs = self.logs()
                original, calls = fs.Directory.replace, []
                def failing(directory, *args):
                    calls.append(args[0])
                    if len(calls) == fail_at:
                        raise OSError('injected atomic write failure')
                    return original(directory, *args)
                output = io.StringIO()
                with mock.patch.object(fs.Directory, 'replace', failing), contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(output):
                    status = cli.run(cli.parser().parse_args([*self.update_args(), '--apply']))
                self.assertEqual(status, 3)
                self.assertIn('KNOWN-PARTIAL: DB content update committed', output.getvalue())
                self.assertIn('scoped export --name commit', output.getvalue())
                self.assertEqual(db.get_row('commit')['version'], expected_version)
                self.command('check', '--name', 'commit', status=1)
                self.command('export', '--name', 'commit', '--dry-run')
                self.command('export', '--name', 'commit', '--apply')
                self.command('check', '--name', 'commit')
                self.assertEqual(db.get_row('commit')['version'], expected_version)
                self.assertEqual(len(self.logs()), len(logs) + 1)

    def test_publication_and_cleanup_erofs_preserve_known_partial_and_close_fd(self):
        logs = self.logs()
        original_unlink, original_close = os.unlink, fs.Directory.close
        attempted, closed = [], []
        def fail_cleanup(path, *args, **kwargs):
            if str(path).startswith('.pv-scoped-'):
                attempted.append(path)
                raise OSError(errno.EROFS, 'injected cleanup EROFS')
            return original_unlink(path, *args, **kwargs)
        def track_close(directory):
            problems = original_close(directory)
            with self.assertRaises(OSError) as caught:
                os.fstat(directory.fd)
            self.assertEqual(caught.exception.errno, errno.EBADF)
            closed.append(directory.fd)
            return problems
        output = io.StringIO()
        with mock.patch.object(fs.Directory, 'replace', side_effect=OSError(errno.EROFS, 'publication EROFS')), \
                mock.patch.object(os, 'unlink', fail_cleanup), \
                mock.patch.object(fs.Directory, 'close', track_close), \
                mock.patch.object(sys, 'argv', ['pv', *self.update_args(), '--apply']), \
                contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(output):
            status = cli.main()
        self.assertEqual(status, 3)
        self.assertEqual(len(closed), 1)
        self.assertEqual(len(attempted), 3)  # continue after every failed unlink
        self.assertIn('KNOWN-PARTIAL: DB content update committed', output.getvalue())
        self.assertIn('CLEANUP-INCOMPLETE', output.getvalue())
        for path in attempted:
            self.assertIn(str(self.prompts / path), output.getvalue())
            self.assertTrue((self.prompts / path).is_file())
        self.assertEqual(db.get_row('commit')['version'], 5)
        self.assertEqual(len(self.logs()), len(logs) + 1)
        self.command('export', '--name', 'commit', '--apply')
        self.command('check', '--name', 'commit')
        self.assertEqual(db.get_row('commit')['version'], 5)
        self.assertEqual(len(self.logs()), len(logs) + 1)

    def test_success_with_cleanup_residue_keeps_success_and_warns(self):
        original_prepare, original_unlink = fs.Selected.prepare, os.unlink
        residue = []
        def prepare_with_residue(selected):
            original_prepare(selected)
            residue.append(selected.directory.stage(b'injected extra staging residue')[0])
        def fail_cleanup(path, *args, **kwargs):
            if path in residue:
                raise OSError(errno.EROFS, 'injected cleanup EROFS')
            return original_unlink(path, *args, **kwargs)
        output, errors = io.StringIO(), io.StringIO()
        with mock.patch.object(fs.Selected, 'prepare', prepare_with_residue), \
                mock.patch.object(os, 'unlink', fail_cleanup), \
                mock.patch.object(sys, 'argv', ['pv', *self.update_args(), '--apply']), \
                contextlib.redirect_stdout(output), contextlib.redirect_stderr(errors):
            status = cli.main()
        self.assertEqual(status, 0)
        self.assertIn('OK: selected scopes fresh', output.getvalue())
        self.assertIn('CLEANUP-INCOMPLETE', errors.getvalue())
        self.assertIn('do not retry DB work', errors.getvalue())
        self.assertIn(str(self.prompts / residue[0]), errors.getvalue())
        self.assertTrue((self.prompts / residue[0]).is_file())
        self.command('check', '--name', 'commit')
        self.assertEqual(db.get_row('commit')['version'], 5)

    def test_indeterminate_db_error_survives_cleanup_failure(self):
        original_unlink = os.unlink
        def fail_cleanup(path, *args, **kwargs):
            if str(path).startswith('.pv-scoped-'):
                raise OSError(errno.EROFS, 'injected cleanup EROFS')
            return original_unlink(path, *args, **kwargs)
        errors = io.StringIO()
        with mock.patch.object(db, 'update', side_effect=RuntimeError('DB effect indeterminate; DO NOT retry')) as update, \
                mock.patch.object(os, 'unlink', fail_cleanup), \
                mock.patch.object(sys, 'argv', ['pv', *self.update_args(), '--apply']), \
                contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(errors):
            status = cli.main()
        self.assertEqual(status, 1)
        self.assertEqual(update.call_count, 1)
        self.assertIn('DB effect indeterminate; DO NOT retry', errors.getvalue())
        self.assertIn('CLEANUP-INCOMPLETE', errors.getvalue())
        self.assertEqual(db.get_row('commit'), self.rows['commit'])

    def test_recheck_refuses_target_race_before_db(self):
        original = fs.Selected.prepare
        def race(selected):
            original(selected)
            (self.prompts / 'commit.md').write_bytes(b'concurrent operator')
        with mock.patch.object(fs.Selected, 'prepare', race), contextlib.redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, 'concurrent/stale'):
                cli.run(cli.parser().parse_args([*self.update_args(), '--apply']))
        self.assertEqual(db.get_row('commit'), self.rows['commit'])


    def test_real_ambiguous_row_and_ambiguous_receipt_refuse(self):
        path = self.prompts / fs.FULL
        full = json.loads(path.read_bytes())
        full['templates'].append(full['templates'][0])
        path.write_bytes(fs.encoded(full))
        before, logs = self.snapshot(), self.logs()
        self.command(*self.update_args(), '--apply', status=1)
        self.assertEqual(self.snapshot(), before)
        db.query('ALTER TABLE prompt_templates DROP INDEX name;', write=True)
        db.query("INSERT INTO prompt_templates (name,content,visibility_companies) VALUES ('commit','duplicate','[\"core\"]');", write=True)
        self.command(*self.update_args(), '--apply', status=1)
        self.assertEqual(self.logs(), logs)
        self.assertEqual(self.snapshot(), before)

    def test_all_selected_admitted_before_any_selected_write(self):
        (self.prompts / 'commit-terse.md').write_bytes(b'drift')
        before = self.snapshot()
        self.command('export', '--name', 'commit', '--name', 'commit-terse', '--apply', status=1)
        self.assertEqual(self.snapshot(), before)

    def test_export_first_install_and_pending_recovery(self):
        (self.prompts / 'commit.md').unlink()
        original = fs.Directory.replace
        def fail_content(directory, name, *args):
            if name == 'commit.md':
                raise OSError('first-install write failure')
            return original(directory, name, *args)
        with mock.patch.object(fs.Directory, 'replace', fail_content), contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
            result = cli.run(cli.parser().parse_args(['export', '--name', 'commit', '--apply']))
        self.assertEqual(result, 3)
        self.command('export', '--name', 'commit', '--apply')
        self.command('check', '--name', 'commit')
        self.assertEqual(db.get_row('commit'), self.rows['commit'])

    def test_large_utf8_content_roundtrip_and_nul_refusal(self):
        self.content.write_bytes(b'bad\x00body')
        self.command(*self.update_args(), '--apply', status=1)
        self.content.write_text('Quoted \" apostrophe \' backslash \\ \u2713\n' * 1600)
        self.command(*self.update_args(), '--apply')
        self.assertEqual(db.get_row('commit')['content'].encode(), self.content.read_bytes())

    def test_indeterminate_db_operation_is_not_retried_or_published(self):
        before = self.snapshot()
        with mock.patch.object(db, 'update', side_effect=RuntimeError('DB effect indeterminate; DO NOT retry')) as update, contextlib.redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(RuntimeError, 'DO NOT retry'):
                cli.run(cli.parser().parse_args([*self.update_args(), '--apply']))
        self.assertEqual(update.call_count, 1)
        self.assertEqual(self.snapshot(), before)


    def test_unknown_policy_and_blank_proposed_content_refuse(self):
        before, logs = self.snapshot(), self.logs()
        self.content.write_text(' \n')
        self.command(*self.update_args(), '--apply', status=1)
        self.assertEqual(db.get_row('commit'), self.rows['commit'])
        db.query("UPDATE prompt_templates SET controlled_vocabulary='{\"unknown\":\"value\"}' WHERE name='commit';", write=True)
        self.command('export', '--name', 'commit', '--apply', status=1)
        self.assertEqual(self.snapshot(), before)
        self.assertEqual(self.logs(), logs)

    def test_reread_after_admission_does_not_adopt_racing_file(self):
        original = fs.Selected.admission
        def race(selected):
            original(selected)
            (self.prompts / 'commit.md').write_bytes(b'concurrent after admission')
        with mock.patch.object(fs.Selected, 'admission', race), contextlib.redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, 'concurrent/stale'):
                cli.run(cli.parser().parse_args([*self.update_args(), '--apply']))
        self.assertEqual(db.get_row('commit'), self.rows['commit'])

    def test_wrong_scoped_provenance_and_tampered_receipt_fail(self):
        self.command('export', '--name', 'commit', '--apply')
        path = self.prompts / '.prompt-vault-scoped-commit.json'
        receipt = json.loads(path.read_bytes())
        receipt['source']['vault_dir'] = '/other/vault'
        path.write_bytes(fs.encoded(receipt))
        before = self.snapshot()
        self.command('check', '--name', 'commit', status=1)
        self.command(*self.update_args(), '--apply', status=1)
        self.assertEqual(self.snapshot(), before)


if __name__ == '__main__':
    unittest.main()
