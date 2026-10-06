"""Selected skill/asset SQL transactions through the repo-owned pv interface."""
import json
import os
from pathlib import Path
import subprocess
import tempfile

import pv_skill_bundle as bundle

SCRIPTS = Path(__file__).resolve().parent
ROW_FIELDS = ('id', 'name', 'description', 'readme', 'compatibility', 'license', 'metadata',
              'owner_company', 'visibility_companies', 'version', 'parent_id', 'status',
              'created_at', 'updated_at')
ASSET_FIELDS = ('id', 'skill_id', 'path', 'content_hex', 'binary_hex', 'is_binary',
                'created_at', 'updated_at')


def literal(value):
    return "FROM_BASE64('" + bundle.b64(str(value).encode()) + "')"


def query(sql, *, write=False):
    result = subprocess.run([str(SCRIPTS / 'pv'), 'sql', '-r', 'json'],
                            input=sql, text=True, capture_output=True)
    if result.returncode:
        raise RuntimeError('DB effect indeterminate; inspect exact skills/assets; DO NOT retry import'
                           if write else 'skill DB read failed')
    decoder, text, rows = json.JSONDecoder(), result.stdout.strip(), []
    try:
        while text:
            obj, end = decoder.raw_decode(text)
            rows.extend(obj.get('rows', []))
            text = text[end:].lstrip()
    except (ValueError, AttributeError) as exc:
        raise RuntimeError('DB result unreadable; DO NOT retry import' if write else
                           'skill DB result unreadable') from exc
    return rows


def vault():
    path = Path(os.environ['VAULT_DIR']).resolve(strict=True)
    if not (path / '.dolt').is_dir():
        raise ValueError('selected vault not initialized')
    return path


def binding():
    rows = query("SELECT active_branch() AS branch, DOLT_HASHOF('HEAD') AS head")
    if len(rows) != 1 or not rows[0].get('branch') or not rows[0].get('head'):
        raise ValueError('missing exact Dolt branch/HEAD identity')
    return rows[0]


def capture(name):
    if not bundle.NAME.fullmatch(name):
        raise ValueError('unsafe exact skill name')
    rows = query(f'SELECT * FROM skills WHERE name = {literal(name)}')
    if len(rows) > 1:
        raise ValueError('ambiguous skill identity')
    if not rows:
        return None
    row = rows[0]
    for key in ROW_FIELDS:
        row.setdefault(key, None)
    for key in ('metadata', 'visibility_companies'):
        if isinstance(row[key], str):
            row[key] = json.loads(row[key])
    sid = int(row['id'])
    size_sql = f'(SELECT COALESCE(SUM(COALESCE(OCTET_LENGTH(content),0)+COALESCE(OCTET_LENGTH(binary_content),0)),0) FROM skill_assets WHERE skill_id={sid})'
    count_sql = f'(SELECT COUNT(*) FROM skill_assets WHERE skill_id={sid})'
    metrics = query(f'SELECT {size_sql} AS bytes, {count_sql} AS files')[0]
    available = bundle.MAX_BYTES - len(row['readme'].encode())
    if metrics['bytes'] > available or metrics['files'] >= bundle.MAX_FILES:
        raise ValueError('stored bundle exceeds file/byte budget')
    # Installed Dolt TO_BASE64 panics on out-of-line LONGTEXT (*val.TextStorage).
    # Native HEX handles large text/binary bytes and preserves exact content.
    assets = query(f'SELECT id,skill_id,path,HEX(content) AS content_hex,'
                   f'HEX(binary_content) AS binary_hex,is_binary,created_at,updated_at '
                   f'FROM skill_assets WHERE skill_id={sid} AND {size_sql}<={available} '
                   f'AND {count_sql}<{bundle.MAX_FILES} ORDER BY path')
    if len(assets) != metrics['files']:
        raise ValueError('stored bundle changed during bounded read')
    for asset in assets:
        for key in ASSET_FIELDS:
            asset.setdefault(key, None)
    return {'row': row, 'assets': assets}


def state_hash(state):
    return bundle.digest(bundle.canonical(state).encode())


def read_bundle(state):
    if not state:
        raise ValueError('exact skill not found')
    row, assets = state['row'], state['assets']
    manifest = row['metadata']
    if not isinstance(manifest, dict):
        raise ValueError('skill has no source-owned snapshot manifest')
    bundle.validate_manifest(manifest)
    for key in ('name', 'owner_company', 'visibility_companies'):
        if row[key] != manifest[key]:
            raise ValueError('row/manifest governance drift')
    if row['description'] != manifest['source_frontmatter']['description']:
        raise ValueError('row/manifest description drift')
    for field in ('license', 'compatibility'):
        if row[field] != manifest['source_frontmatter'].get(field):
            raise ValueError('row/manifest metadata drift')
    payloads = {'SKILL.md': row['readme'].encode('utf-8')}
    for asset in assets:
        key = 'binary_hex' if asset['is_binary'] else 'content_hex'
        other = 'content_hex' if asset['is_binary'] else 'binary_hex'
        if asset[key] is None or asset[other] is not None or asset['path'] in payloads:
            raise ValueError('malformed/duplicate stored skill asset')
        payloads[asset['path']] = bytes.fromhex(asset[key])
    if set(payloads) != {f['path'] for f in manifest['files']}:
        raise ValueError('stored asset inventory drift')
    for f in manifest['files']:
        if bundle.descriptor(f['path'], payloads[f['path']], f['mode']) != f:
            raise ValueError('stored skill bundle bytes drift')
    if bundle.frontmatter(payloads['SKILL.md']) != manifest['source_frontmatter']:
        raise ValueError('stored skill frontmatter drift')
    return manifest, payloads


def preflight(count):
    """Run the shared preflight; return the assured identity for db-test, else None."""
    selected = vault()
    env = os.environ.copy()
    env.setdefault('PV_BACKUP_LOCAL_PATH', str(selected.parent / 'backups/local'))
    with tempfile.TemporaryDirectory(prefix='pv-skill-preflight-', dir=os.environ['TMPDIR']) as root:
        Path(root, 'prompt-vault-db').symlink_to(selected, target_is_directory=True)
        stage = 'db-test' if count > 1 else 'db-dev'
        result = subprocess.run([str(SCRIPTS / 'db-change-preflight.sh'), '--stage', stage],
                                cwd=root, env=env, text=True, capture_output=True)
        if result.returncode:
            raise ValueError('owner backup preflight failed; no writes:\n' + result.stdout + result.stderr)
    if stage == 'db-dev':
        return None
    lines = [line for line in result.stdout.splitlines() if line.startswith('ASSURED_IDENTITY ')]
    if len(lines) != 1:
        raise ValueError('db-test preflight passed without an assured identity; no writes')
    return json.loads(lines[0].split(' ', 1)[1])


def equality(expression, value, json_value=False):
    if value is None:
        return expression + ' IS NULL'
    if json_value:
        return expression + ' <=> CAST(' + literal(bundle.canonical(value)) + ' AS JSON)'
    if isinstance(value, bool):
        value = int(value)
    return f'HEX(CAST({expression} AS CHAR)) = HEX({literal(value)})'


def predicate(name, state):
    count = f'(SELECT COUNT(*) FROM skills WHERE name={literal(name)})'
    if state is None:
        return count + '=0'
    row, assets = state['row'], state['assets']
    row_tests = [equality(f'`{k}`', row[k], k in ('metadata', 'visibility_companies'))
                 for k in ROW_FIELDS]
    parts = [count + '=1', '(SELECT COUNT(*) FROM skills WHERE ' + ' AND '.join(row_tests) + ')=1',
             f'(SELECT COUNT(*) FROM skill_assets WHERE skill_id={int(row["id"])})={len(assets)}']
    for asset in assets:
        tests = []
        for key in ASSET_FIELDS:
            expression = {'content_hex': 'HEX(content)', 'binary_hex': 'HEX(binary_content)'}.get(key, f'`{key}`')
            tests.append(equality(expression, asset[key]))
        parts.append('(SELECT COUNT(*) FROM skill_assets WHERE ' + ' AND '.join(tests) + ')=1')
    return ' AND '.join(parts)


def import_sql(items, binding_ref, assured=None):
    guards = [f'({predicate(m["name"], old)})' for m, _, old, _ in items]
    guards += [equality('active_branch()', binding_ref['branch']),
               equality("DOLT_HASHOF('HEAD')", binding_ref['head'])]
    if assured is not None:
        # Exact-state binding: write only onto the staged/working roots whose recovery was verified.
        guards += [equality("DOLT_HASHOF_DB('STAGED')", assured['staged_root']),
                   equality("DOLT_HASHOF_DB('WORKING')", assured['working_root'])]
    statements = ['START TRANSACTION;', 'SET @pv_skill_ready=(' + ' AND '.join(guards) + ');']
    changed = 0
    for manifest, payloads, old, noop in items:
        if noop:
            continue
        changed += 1
        meta = manifest['source_frontmatter']
        data = {'name': manifest['name'], 'description': meta['description'],
                'readme': payloads['SKILL.md'].decode(), 'license': meta.get('license'),
                'compatibility': meta.get('compatibility'), 'metadata': bundle.canonical(manifest),
                'owner_company': manifest['owner_company'],
                'visibility_companies': bundle.canonical(manifest['visibility_companies'])}
        encoded = {k: 'NULL' if v is None else literal(v) for k, v in data.items()}
        for k in ('metadata', 'visibility_companies'):
            encoded[k] = 'CAST(' + encoded[k] + ' AS JSON)'
        if old is None:
            statements.append('INSERT INTO skills (' + ','.join(encoded) + ',version,status) SELECT ' +
                              ','.join(encoded.values()) + ",1,'active' WHERE @pv_skill_ready=1;")
        else:
            setters = ','.join(k + '=' + v for k, v in encoded.items())
            statements.append(f'UPDATE skills SET {setters},version=version+1,updated_at=CURRENT_TIMESTAMP '
                              f'WHERE id={int(old["row"]["id"])} AND @pv_skill_ready=1;')
        name = literal(manifest['name'])
        sid = f'(SELECT id FROM skills WHERE name={name})'
        statements.append(f'DELETE FROM skill_assets WHERE skill_id={sid} AND @pv_skill_ready=1;')
        for f in manifest['files']:
            if f['path'] == 'SKILL.md':
                continue
            raw = "FROM_BASE64('" + bundle.b64(payloads[f['path']]) + "')"
            text, binary = ('NULL', raw) if f['is_binary'] else (raw, 'NULL')
            statements.append('INSERT INTO skill_assets (skill_id,path,content,binary_content,is_binary) '
                              f'SELECT {sid},{literal(f["path"])},{text},{binary},{int(f["is_binary"])} '
                              'WHERE @pv_skill_ready=1;')
    statements += ['COMMIT;', f'SELECT @pv_skill_ready AS admitted, {changed} AS planned_changes;']
    return '\n'.join(statements)


def apply_import(plan, source_entries):
    if (plan.get('schema') != 'prompt-vault/skill-import-plan/v1' or
            plan.get('vault') != str(vault()) or plan.get('dolt_binding') != binding()):
        raise ValueError('plan schema/vault/branch/HEAD mismatch')
    entries = plan['skills']
    if not entries or len(entries) > 32 or len({s['name'] for s in entries}) != len(entries):
        raise ValueError('empty/duplicate/oversized selected scope')
    items = []
    for entry in entries:
        # All source/governance bytes are re-derived, never trusted from the plan.
        source = source_entries[entry['name']]
        manifest, payloads = bundle.snapshot(source['source'], source)
        if manifest != entry['manifest']:
            raise ValueError('source/governance drift from approved plan')
        old = capture(entry['name'])
        if state_hash(old) != entry['expected_state_sha256']:
            raise ValueError('skill/version/asset drift from approved plan')
        if old:
            existing, _ = read_bundle(old)
            if existing['source_owner'] != manifest['source_owner']:
                raise ValueError('original authoring owner cannot be relocated by import')
        noop = old is not None and old['row']['metadata'] == manifest and old['row']['status'] == 'active'
        items.append((manifest, payloads, old, noop))
    if all(i[3] for i in items):
        return {'effect': 'noop', 'names': [i[0]['name'] for i in items]}
    assured = preflight(len(items))
    if assured is not None and (assured['branch'], assured['head']) != (
            plan['dolt_binding']['branch'], plan['dolt_binding']['head']):
        raise ValueError('assured identity and approved plan name different branch/HEAD; no writes')
    rows = query(import_sql(items, plan['dolt_binding'], assured), write=True)
    expected = {'admitted': 1, 'planned_changes': sum(not i[3] for i in items)}
    if rows == [dict(expected, admitted=0)]:
        raise ValueError('transaction CAS refused all selected skills; no changes')
    if rows != [expected]:
        raise RuntimeError('DB result indeterminate; DO NOT retry import; inspect exact skills/assets')
    try:
        for manifest, payloads, old, noop in items:
            actual = capture(manifest['name'])
            actual_manifest, actual_payloads = read_bundle(actual)
            version = old['row']['version'] + (not noop) if old else 1
            if actual_manifest != manifest or actual_payloads != payloads or actual['row']['version'] != version:
                raise ValueError('post-readback drift')
    except Exception as exc:
        raise RuntimeError('KNOWN-PARTIAL: DB acknowledged but selected verification failed; inspect exact skills/assets; DO NOT retry import') from exc
    return {'effect': 'imported', 'names': [i[0]['name'] for i in items]}
