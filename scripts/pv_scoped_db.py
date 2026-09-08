"""Guarded Dolt access for the local exact-template operator surface (no retries)."""
import base64
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile

SCRIPTS = Path(__file__).resolve().parent
JSON_COLUMNS = {'visibility_companies', 'variables', 'controlled_vocabulary'}


def digest(data):
    return hashlib.sha256(data).hexdigest()


def literal(value):
    """Use base64 instead of interpolating caller-controlled SQL text."""
    encoded = base64.b64encode(str(value).encode('utf-8')).decode('ascii')
    return f"FROM_BASE64('{encoded}')"


def query(sql, *, write=False):
    # pv-lib supplies vault identity/working-directory guard and JSON read helper.
    command = ('dolt sql -r json' if write else
               'sql=$(< /dev/stdin); dolt_json_query "$sql"')
    result = subprocess.run(
        ['bash', '-c', 'source "$1/pv-lib.sh"; ensure_vault; ' + command,
         '_', str(SCRIPTS)], input=sql, text=True, capture_output=True)
    if result.returncode:
        raise RuntimeError(('DB effect indeterminate; DO NOT retry update. Inspect row and '
                            'changelog, then use export-only recovery. ' if write else
                            'DB read failed: ') + result.stderr.strip())
    decoder, text, objects = json.JSONDecoder(), result.stdout.strip(), []
    try:
        while text:
            obj, end = decoder.raw_decode(text)
            objects.append(obj)
            text = text[end:].lstrip()
    except ValueError as exc:
        raise RuntimeError('DB result unreadable; DO NOT retry update' if write
                           else 'DB result unreadable') from exc
    return [row for obj in objects for row in obj.get('rows', [])]


def get_row(name):
    rows = query(f'SELECT * FROM prompt_templates WHERE name = {literal(name)}')
    if len(rows) != 1 or rows[0]['name'] != name:
        raise ValueError(f'missing/ambiguous exact template: {name}')
    # Dolt JSON omits SQL NULL fields; retain them in the complete CAS snapshot.
    for key in ('description', 'variables', 'controlled_vocabulary', 'parent_id',
                'version', 'status', 'created_at', 'updated_at'):
        rows[0].setdefault(key, None)
    return rows[0]


def preflight(vault):
    # The existing preflight is cwd-relative, not VAULT_DIR-aware. Present only
    # the explicitly selected, verified Dolt directory in an isolated context.
    if not (vault / '.dolt').is_dir():
        raise ValueError('selected vault is not initialized')
    with tempfile.TemporaryDirectory(prefix='pv-scoped-preflight-') as root:
        Path(root, 'prompt-vault-db').symlink_to(vault, target_is_directory=True)
        result = subprocess.run([str(SCRIPTS / 'db-change-preflight.sh'),
                                 '--stage', 'db-dev'], cwd=root,
                                capture_output=True, text=True)
        if result.returncode:
            raise ValueError('owner DB preflight failed: ' + result.stdout + result.stderr)


def snapshot_predicate(row):
    conditions = []
    # CAS every field, not just version: lifecycle/governance edits elsewhere
    # need not increment version. Preserve their concurrency boundary too.
    for key, value in row.items():
        if not key.replace('_', '').isalnum():
            raise ValueError('unexpected DB column')
        if value is None:
            condition = f'`{key}` IS NULL'
        elif key in JSON_COLUMNS:
            value = json.dumps(value) if not isinstance(value, str) else value
            condition = f'`{key}` <=> CAST({literal(value)} AS JSON)'
        else:
            value = int(value) if isinstance(value, bool) else value
            condition = f'HEX(CAST(`{key}` AS CHAR)) = HEX({literal(value)})'
        conditions.append(condition)
    # Name uniqueness is schema-enforced; count also fails closed on broken fixtures.
    conditions.append(f'(SELECT COUNT(*) FROM prompt_templates WHERE name = '
                      f'{literal(row["name"])}) = 1')
    return ' AND '.join(conditions)


def update(row, content):
    version = int(row['version'])
    author = os.environ.get('PV_CHANGELOG_AUTHOR', os.environ.get('USER', 'local-operator'))
    sql = f"""
START TRANSACTION;
UPDATE prompt_templates SET content = {literal(content)}, version = version + 1,
    updated_at = CURRENT_TIMESTAMP WHERE {snapshot_predicate(row)};
SET @pv_scoped_changed = ROW_COUNT();
INSERT INTO changelog
    (entity_type, entity_id, old_version, new_version, change_type, summary, author)
SELECT 'template', {int(row['id'])}, {version}, {version + 1}, 'update',
    {literal('Scoped content update: ' + row['name'])}, {literal(author)}
WHERE @pv_scoped_changed = 1;
COMMIT;
SELECT @pv_scoped_changed AS changed;
"""
    result = query(sql, write=True)
    if result != [{'changed': 1}]:
        if result == [{'changed': 0}]:
            raise ValueError('concurrent row change: CAS refused; no DB update/changelog')
        raise RuntimeError('DB result indeterminate; DO NOT retry update; inspect row/changelog')
