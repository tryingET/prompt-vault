"""Explicit local operator content update + bounded, selective Pi publishing."""
import argparse
import json
import os
from pathlib import Path
import shlex
import sys

import pv_scoped_db as db
from pv_scoped_projection import Directory, Selected, selected_name, projection, HASH, json_snapshot


def parser():
    p = argparse.ArgumentParser(description=__doc__)
    commands = p.add_subparsers(dest='command', required=True)
    for command in ('update', 'export', 'check'):
        sub = commands.add_parser(command)
        sub.add_argument('--name', required=True, action='append' if command != 'update' else 'store')
        if command != 'check':
            mode = sub.add_mutually_exclusive_group()
            mode.add_argument('--apply', action='store_true', help='explicitly authorize local effects')
            mode.add_argument('--dry-run', action='store_true', help='plan only (default)')
        if command == 'update':
            sub.add_argument('--expected-owner', required=True)
            sub.add_argument('--expected-version', required=True, type=int)
            sub.add_argument('--expected-content-sha256', required=True)
            sub.add_argument('--content-file', required=True, type=Path)
    return p


def recovery(names, vault, target):
    command = ['env', f'VAULT_DIR={vault}', f'TEMPLATES_DIR={target}',
               str(db.SCRIPTS / 'pv'), 'scoped', 'export']
    for name in names:
        command += ['--name', name]
    return shlex.join(command)


def run(args):
    names = [args.name] if args.command == 'update' else args.name
    for name in names:
        selected_name(name)
    if len(names) != len(set(names)):
        raise ValueError('duplicate selected names')
    apply = getattr(args, 'apply', False)
    vault = Path(os.environ['VAULT_DIR']).resolve(strict=True)
    target = os.environ.get('TEMPLATES_DIR', str(Path.home() / '.pi/agent/prompts'))
    rows = [db.get_row(name) for name in names]
    updated, noop = None, False
    if args.command == 'update':
        row = rows[0]
        if row['owner_company'] != args.expected_owner:
            raise ValueError('expected owner mismatch; no mutation')
        if row['version'] != args.expected_version:
            raise ValueError('expected version mismatch; no mutation')
        if not HASH.fullmatch(args.expected_content_sha256) or db.digest(row['content'].encode()) != args.expected_content_sha256:
            raise ValueError('expected content SHA-256 mismatch; no mutation')
        raw = args.content_file.read_bytes()
        content = raw.decode('utf-8')
        if b'\x00' in raw or len(raw) > 65535:
            raise ValueError('content must be NUL-free UTF-8 within TEXT byte limit')
        projection(row)
        noop = content == row['content']
        updated = dict(row, content=content, version=row['version'] + (not noop))
        projection(updated)
    directory = Directory(target, apply)
    db_succeeded, publishing = False, False
    try:
        # Fence installed OLD bytes before deriving proposed new projection.
        old = [Selected(directory, vault, row) for row in rows]
        if args.command == 'check':
            for selected in old:
                if not selected.fresh():
                    raise ValueError(f'scoped freshness stale: {selected.name}')
            print(json.dumps({'scope': names, 'scoped_fresh': True, 'global_freshness': 'not_checked'}))
            return 0
        for selected in old:
            selected.admission()
        if updated and not noop and old[0].receipt and json_snapshot(old[0].receipt, old[0].receipt_path).get('state') == 'pending':
            raise ValueError('pending projection: recover with scoped export before another update')
        plans = [Selected(directory, vault, updated)] if updated else old
        if updated:
            # Keep admission's exact snapshots: a later read must not silently
            # adopt a concurrent operator edit as the expected overwrite target.
            plans[0].file, plans[0].receipt = old[0].file, old[0].receipt
            plans[0].dependencies = old[0].dependencies
        print(json.dumps({'mode': 'apply' if apply else 'plan', 'scope': names,
                          'db': 'noop' if noop else ('content_update' if updated else 'unchanged'),
                          'templates': [item.final['template'] for item in plans],
                          'global_freshness': 'not_checked'}, sort_keys=True))
        if not apply or noop:
            return 0  # unchanged update never republishes or increments a version
        db.preflight(vault) if updated else None
        for selected in plans:
            selected.prepare()  # stage and hash-check ALL selected bytes before any DB write
        for selected in plans:
            selected.recheck()
        if updated:
            db.update(rows[0], updated['content'])
            db_succeeded = True
            actual = db.get_row(names[0])
            # updated_at is DB-maintained; every other field must remain as planned.
            if {k: v for k, v in actual.items() if k != 'updated_at'} != {k: v for k, v in updated.items() if k != 'updated_at'}:
                raise ValueError('DB changed after update; inspect before export-only recovery')
            rows = [actual]
        # Revalidate DB snapshots for export as well; never emit a newly gated row.
        for row in rows:
            if db.get_row(row['name']) != row:
                raise ValueError('concurrent DB change before projection')
        publishing = True
        for selected in plans:
            selected.publish()
        for name in names:
            if not Selected(directory, vault, db.get_row(name)).fresh():
                raise ValueError(f'scoped post-write freshness failed: {name}')
        print('OK: selected scopes fresh; global freshness NOT checked/refreshed')
        return 0
    except Exception as exc:
        if db_succeeded or publishing:
            command = recovery(names, vault, directory.path)
            print(f'KNOWN-PARTIAL: {"DB content update committed; " if db_succeeded else "DB unchanged; "}'
                  f'projection may be incomplete: {exc}\n'
                  f'Inspect selected files/receipts. Export-only recovery (no version increment):\n'
                  f'{command} --dry-run\n{command} --apply', file=sys.stderr)
            return 3
        raise
    finally:
        problems = directory.close()
        if problems:
            print('CLEANUP-INCOMPLETE: primary operation outcome/exit status unchanged; '
                  'do not retry DB work for cleanup.\n' + '\n'.join(problems), file=sys.stderr)


def main():
    try:
        return run(parser().parse_args())
    except (ValueError, OSError, RuntimeError) as exc:
        print(str(exc), file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
