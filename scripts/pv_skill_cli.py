"""Plan/import exact skill snapshots; inspect/export/check only named bundles."""
import argparse
import json
import os
from pathlib import Path
import sys

import pv_skill_bundle as bundle
import pv_skill_store as store
import pv_skill_projection as projection

PLAN = 'prompt-vault/skill-import-plan/v1'


def parser():
    p = argparse.ArgumentParser(description=__doc__)
    commands = p.add_subparsers(dest='command', required=True)
    for command in ('plan', 'import'):
        sub = commands.add_parser(command)
        sub.add_argument('--catalogue', required=True, type=Path)
        sub.add_argument('--agent-root', type=Path, default=Path.home() / '.pi/agent/skills')
        if command == 'plan':
            sub.add_argument('--out', type=Path)
        else:
            sub.add_argument('--plan', required=True, type=Path)
            mode = sub.add_mutually_exclusive_group()
            mode.add_argument('--apply', action='store_true')
            mode.add_argument('--dry-run', action='store_true')
    for command in ('inspect', 'export', 'check'):
        sub = commands.add_parser(command)
        sub.add_argument('--name', required=True)
        if command == 'inspect':
            sub.add_argument('--content', action='store_true', help='include exact SKILL.md; no asset body dump')
        else:
            sub.add_argument('--target', required=True, type=Path)
            if command == 'export':
                mode = sub.add_mutually_exclusive_group()
                mode.add_argument('--apply', action='store_true')
                mode.add_argument('--dry-run', action='store_true')
    return p


def catalogue(path, agent_root):
    raw = path.read_bytes()
    value = json.loads(raw)
    if value.get('schema') != 'prompt-vault/skill-catalogue/v1' or value.get('authority') != 'original_source_package':
        raise ValueError('unsupported source-owner catalogue')
    entries = value['skills']
    if not entries or len(entries) > 32 or len({e['name'] for e in entries}) != len(entries):
        raise ValueError('empty/duplicate/oversized catalogue')
    roots = {'repo': store.SCRIPTS.parent, 'agent': agent_root.resolve(strict=True)}
    selected = {}
    for entry in entries:
        bundle.governance(entry)
        rel = Path(entry['path'])
        if rel.is_absolute() or '..' in rel.parts or '\\' in entry['path'] or entry['root'] not in roots:
            raise ValueError('unsafe catalogue source path/root')
        source = roots[entry['root']] / rel
        selected[entry['name']] = dict(entry, source=str(source.resolve(strict=True)))
    return selected, bundle.digest(raw)


def make_plan(entries, catalogue_hash):
    result = {'schema': PLAN, 'vault': str(store.vault()), 'dolt_binding': store.binding(),
              'catalogue_sha256': catalogue_hash, 'skills': []}
    for entry in entries.values():
        manifest, _ = bundle.snapshot(entry['source'], entry)
        old = store.capture(entry['name'])
        if old:
            previous, _ = store.read_bundle(old)
            if previous['source_owner'] != manifest['source_owner']:
                raise ValueError('original source owner mismatch')
        result['skills'].append({'name': entry['name'], 'manifest': manifest,
                                'expected_version': old['row']['version'] if old else 0,
                                'expected_state_sha256': store.state_hash(old)})
    return result


def run(args):
    if args.command in ('plan', 'import'):
        entries, chash = catalogue(args.catalogue, args.agent_root)
        current = make_plan(entries, chash)
        if args.command == 'plan':
            if args.out:
                with args.out.open('x', encoding='utf-8') as stream:
                    json.dump(current, stream, indent=2, ensure_ascii=False)
                    stream.write('\n')
            print(bundle.canonical(current))
            return 0
        approved = json.loads(args.plan.read_text())
        if approved != current:
            raise ValueError('approved plan differs from current source/row/governance state; rediscover, do not replay')
        if not args.apply:
            print(bundle.canonical({'effect': 'plan_only', 'names': list(entries),
                                    'stage_required': 'db-test' if len(entries) > 1 else 'db-dev'}))
            return 0
        print(bundle.canonical(store.apply_import(approved, entries)))
        return 0
    state = store.capture(args.name)
    manifest, payloads = store.read_bundle(state)
    row = state['row']
    if args.command == 'inspect':
        result = {'name': row['name'], 'id': row['id'], 'version': row['version'],
                  'status': row['status'], 'metadata': manifest}
        if args.content:
            result['readme'] = row['readme']
        print(bundle.canonical(result))
        return 0
    if row['status'] != 'active':
        raise ValueError('only active snapshots may be projected')
    path = projection.target_path(args.target, args.name)
    expected = projection.identity(store.vault(), row, manifest)
    if args.command == 'check':
        projection.check(path, expected, manifest, payloads)
        effect = 'checked'
    elif not args.apply:
        if path.exists() or path.is_symlink():
            projection.check(path, expected, manifest, payloads)
        effect = 'plan_only'
    else:
        effect = projection.export(path, expected, manifest, payloads)
    if store.state_hash(store.capture(args.name)) != store.state_hash(state):
        raise RuntimeError('KNOWN-PARTIAL: selected DB changed during projection; inspect target/receipt')
    print(bundle.canonical({'effect': effect, 'name': args.name, 'target': str(path),
                            'version': row['version'], 'bundle_sha256': manifest['bundle_sha256'],
                            'runtime_adoption': 'not_checked', 'global_projection': 'not_touched'}))
    return 0


def main():
    args = parser().parse_args()
    try:
        return run(args)
    except RuntimeError as exc:
        print(str(exc), file=sys.stderr)
        return 3 if str(exc).startswith('KNOWN-PARTIAL') else 1
    except (ValueError, OSError, KeyError, TypeError) as exc:
        print('REFUSED: ' + str(exc), file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
