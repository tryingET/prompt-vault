"""Exact-state backup assurance: bind and verify a receipt against AK recovery records and the live vault.

Contract: schema/backup-assurance-v1.json. A receipt names one workstation capture manifest, one Restic
snapshot and two AK evidence records (primary and offsite recovery). Verification re-reads all of them
and recomputes the vault's native identity and every table/schema digest; any difference refuses.
No backup, restore, import or AK write happens here.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys

SCRIPTS = Path(__file__).resolve().parent
CONTRACT = json.loads((SCRIPTS.parent / 'schema/backup-assurance-v1.json').read_text(encoding='utf-8'))
ALGORITHM = CONTRACT['digest_algorithm']
RECEIPT = CONTRACT['receipt_schema']
IDENTIFIER = re.compile(r'^[A-Za-z_][A-Za-z0-9_]*$')
HEX64 = re.compile(r'[a-f0-9]{64}')
IDENTITY_SQL = ("SELECT active_branch() AS branch,DOLT_HASHOF('HEAD') AS head,"
                "DOLT_HASHOF_DB('WORKING') AS working_root,DOLT_HASHOF_DB('STAGED') AS staged_root,"
                "(SELECT MAX(version) FROM schema_version) AS schema_version")


class Unverified(ValueError):
    """Assurance could not be verified; never a statement that backups are absent."""


def encoded(value):
    """Workstation capture serialization: ensure_ascii, sorted keys, no spaces."""
    return json.dumps(value, sort_keys=True, separators=(',', ':')).encode('utf-8')


def digest(value):
    return hashlib.sha256(encoded(value)).hexdigest()


def rows(vault, sql):
    result = subprocess.run([str(SCRIPTS / 'pv'), 'sql', '-r', 'json', '-q', sql],
                            env=dict(os.environ, VAULT_DIR=str(vault)), capture_output=True, text=True)
    if result.returncode:
        raise Unverified('native vault query failed')
    packet = json.loads(result.stdout) if result.stdout.strip() else {}
    if not isinstance(packet, dict) or not isinstance(packet.get('rows', []), list):
        raise Unverified('unexpected native query packet')
    return packet.get('rows', [])  # Dolt emits {} for an empty result.


def quoted(name):
    if not IDENTIFIER.fullmatch(name):
        raise Unverified('unsupported native table/column identifier')
    return f'`{name}`'


def live_identity(vault):
    identity = rows(vault, IDENTITY_SQL)
    if len(identity) != 1:
        raise Unverified('missing vault identity')
    return identity[0]


def live_tables(vault):
    """Same SQL and serialization as the workstation recovery helper."""
    tables = [next(iter(row.values())) for row in rows(vault, 'SHOW TABLES')]
    output = {}
    for table in tables:
        name = quoted(table)
        columns = rows(vault, f'SHOW COLUMNS FROM {name}')
        if not columns:
            raise Unverified('missing column schema')
        names = [column['Field'] for column in columns]
        keys = [column['Field'] for column in columns if column.get('Key') == 'PRI']
        values = ','.join(f'HEX(CAST({quoted(c)} AS BINARY))' for c in names)
        ordering = ','.join(quoted(c) for c in (keys or names))
        hashes = rows(vault, f'SELECT SHA2(CAST(JSON_ARRAY({values}) AS CHAR),256) AS row_sha256 '
                             f'FROM {name} ORDER BY {ordering}')
        count = rows(vault, f'SELECT COUNT(*) AS n FROM {name}')[0]['n']
        if count != len(hashes):
            raise Unverified('table changed during bounded native reads')
        output[table] = {'rows': count, 'ordered_row_sha256': digest(hashes),
                         'schema_sha256': digest(rows(vault, f'SHOW CREATE TABLE {name}'))}
    return output


def evidence(number):
    result = subprocess.run(['ak', 'evidence', 'show', str(int(number)), '-F', 'json'],
                            capture_output=True, text=True)
    if result.returncode:
        raise Unverified(f'AK evidence {number} could not be read')
    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError as exc:
        raise Unverified(f'AK evidence {number} is not JSON') from exc


def check_record(kind, row, receipt, manifest, manifest_sha):
    rule = CONTRACT['required_records'][kind]
    details = row.get('details') if isinstance(row, dict) else None
    checks = [
        (row.get('result') == 'pass', 'evidence result is not pass'),
        (row.get('check_type') == CONTRACT['evidence_check_type'], 'evidence is not a recovery record'),
        (row.get('repo') == rule['owner_repo'], 'evidence is not from the owning repo'),
        (isinstance(details, dict) and details.get('schema') == CONTRACT['record_schema'], 'unknown record schema'),
    ]
    if isinstance(details, dict):
        probe = details.get('native_probe') or {}
        checks += [
            (details.get('kind') == kind and details.get('origin') == rule['origin'], 'kind/origin mismatch'),
            (details.get('snapshot_id') == receipt['snapshot_id'], 'other snapshot'),
            (details.get('vault') == receipt['vault'], 'other vault'),
            (details.get('capture_manifest_sha256') == manifest_sha, 'other capture manifest'),
            (details.get('restored_manifest_sha256') == manifest_sha, 'restored manifest differs'),
            (details.get('restored_files_match_manifest') is True, 'restored files not matched'),
            (details.get('restore') == CONTRACT['restore'], 'restore not exit 0 with --verify and --overwrite never'),
            (probe.get('fsck_ok') is True, 'native fsck not clean'),
            (probe.get('digest_algorithm') == ALGORITHM, 'other digest algorithm'),
            (probe.get('identity') == manifest['source_identity'], 'recovered identity differs from capture'),
            (probe.get('tables_sha256') == digest(manifest['tables']), 'recovered tables differ from capture'),
            (bool(details.get('repository')), 'repository missing'),
        ]
    for ok, reason in checks:
        if not ok:
            raise Unverified(f'{kind} recovery record {receipt["evidence"][kind]}: {reason}')
    return details


def verify(receipt, vault_path):
    if not isinstance(receipt, dict) or receipt.get('schema') != RECEIPT:
        raise Unverified('not a backup assurance receipt')
    if not HEX64.fullmatch(str(receipt.get('snapshot_id'))):
        raise Unverified('receipt has no exact snapshot id')
    vault = Path(vault_path).resolve(strict=True)
    if not (vault / '.dolt').is_dir():
        raise Unverified('vault is not an initialized Dolt database')
    if str(vault) != receipt.get('vault'):
        raise Unverified('receipt is bound to another vault')
    raw = Path(receipt['capture_manifest']).read_bytes()
    manifest_sha = hashlib.sha256(raw).hexdigest()
    if manifest_sha != receipt.get('capture_manifest_sha256'):
        raise Unverified('capture manifest bytes changed since binding')
    manifest = json.loads(raw)
    if manifest.get('source') != receipt['vault']:
        raise Unverified('capture manifest describes another vault')
    evidence_ids = receipt.get('evidence') or {}
    if set(evidence_ids) != {'primary', 'offsite'} or evidence_ids['primary'] == evidence_ids['offsite']:
        raise Unverified('primary and offsite records must be two distinct AK evidence rows')
    records = {kind: check_record(kind, evidence(evidence_ids[kind]), receipt, manifest, manifest_sha)
               for kind in ('primary', 'offsite')}
    if records['primary']['repository'] == records['offsite']['repository']:
        raise Unverified('offsite record names the primary repository: not a distinct failure domain')
    before = live_identity(vault)
    tables = live_tables(vault)
    if live_identity(vault) != before:
        raise Unverified('vault changed during verification')
    if before != manifest['source_identity'] or tables != manifest['tables']:
        raise Unverified('live state drift from the captured state; capture and recover again')
    return {'verified': True, 'vault': str(vault), 'identity': before, 'snapshot_id': receipt['snapshot_id'],
            'capture_manifest_sha256': manifest_sha, 'evidence': evidence_ids,
            'repositories': {kind: records[kind]['repository'] for kind in records},
            'admits_stages': CONTRACT['admits_stages']}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest='command', required=True)
    bind = commands.add_parser('bind', help='verify, then write a new receipt')
    bind.add_argument('--vault', type=Path, required=True)
    bind.add_argument('--capture-manifest', type=Path, required=True)
    bind.add_argument('--snapshot-id', required=True)
    bind.add_argument('--primary-evidence', type=int, required=True)
    bind.add_argument('--offsite-evidence', type=int, required=True)
    bind.add_argument('--out', type=Path, required=True)
    check = commands.add_parser('verify', help='re-verify an existing receipt against the live vault')
    check.add_argument('--receipt', type=Path, required=True)
    check.add_argument('--vault', type=Path, required=True)
    args = parser.parse_args()
    try:
        if args.command == 'bind':
            manifest = args.capture_manifest.resolve(strict=True)
            receipt = {'schema': RECEIPT, 'vault': str(args.vault.resolve(strict=True)),
                       'capture_manifest': str(manifest),
                       'capture_manifest_sha256': hashlib.sha256(manifest.read_bytes()).hexdigest(),
                       'snapshot_id': args.snapshot_id,
                       'evidence': {'primary': args.primary_evidence, 'offsite': args.offsite_evidence}}
            result = verify(receipt, args.vault)
            with args.out.open('x', encoding='utf-8') as stream:
                json.dump(receipt, stream, indent=2, sort_keys=True)
                stream.write('\n')
        else:
            result = verify(json.loads(args.receipt.read_text(encoding='utf-8')), args.vault)
        print(json.dumps(result, sort_keys=True))
        return 0
    except (Unverified, ValueError, OSError, KeyError, TypeError, AttributeError) as exc:
        print(f'backup assurance unable_to_verify: {exc}', file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
