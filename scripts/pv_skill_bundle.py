"""Exact source-owned skill snapshots. No discovery, execution, or owner relocation."""
import base64
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import re
import stat

SCHEMA = 'prompt-vault/skill-snapshot/v1'
NAME = re.compile(r'^[a-z0-9]+(?:-[a-z0-9]+)*$')
CACHE = {'.git', '__pycache__', '.pytest_cache', '.mypy_cache', '.DS_Store'}
PRIVATE = {'evals', 'evaluations', 'private-evals', 'evidence'}
SECRET = re.compile(r'-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----|(?:ghp_|github_pat_)[A-Za-z0-9_]{25,}')
MAX_FILES, MAX_BYTES = 256, 8 * 1024 * 1024


def canonical(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'), ensure_ascii=False)


def digest(data):
    return hashlib.sha256(data).hexdigest()


def safe_path(value):
    p = PurePosixPath(value)
    if (not value or p.is_absolute() or str(p) != value or '\\' in value or
            any(part in ('.', '..') for part in p.parts) or len(value.encode()) > 255 or
            any(ord(c) < 32 for c in value) or any(part.startswith('.') for part in p.parts)):
        raise ValueError(f'unsafe asset path: {value!r}')
    return p


def governance(entry):
    contract = json.loads((Path(__file__).resolve().parent.parent /
                           'ontology/company-visibility-contract.json').read_text())
    companies = contract['companies']
    owner, visibility = entry['owner_company'], entry['visibility_companies']
    if (owner not in companies or not isinstance(visibility, list) or not visibility or
            len(visibility) != len(set(visibility)) or owner not in visibility or
            any(c not in companies for c in visibility)):
        raise ValueError('invalid skill ownership/visibility')
    if owner == 'core' and set(visibility) != set(companies):
        raise ValueError('core-owned snapshots must remain visible to all governed companies')
    if not isinstance(entry['name'], str) or len(entry['name']) > 64 or not NAME.fullmatch(entry['name']):
        raise ValueError('unsafe exact skill name')
    if not isinstance(entry['source_owner'], str) or not entry['source_owner'].strip():
        raise ValueError('original authoring owner must be explicit')


def frontmatter(raw):
    try:
        import yaml
    except ImportError as exc:
        raise ValueError('skill snapshot metadata requires installed PyYAML; no auto-install') from exc
    text = raw.decode('utf-8-sig')
    lines = text.splitlines()
    if not lines or lines[0] != '---':
        raise ValueError('SKILL.md requires YAML frontmatter')
    try:
        end = lines.index('---', 1)
    except ValueError as exc:
        raise ValueError('unterminated skill frontmatter') from exc
    class UniqueLoader(yaml.SafeLoader):
        pass

    def mapping(loader, node):
        result = {}
        for key_node, value_node in node.value:
            key = loader.construct_object(key_node)
            if not isinstance(key, str) or key in result:
                raise ValueError('duplicate/non-string frontmatter key')
            result[key] = loader.construct_object(value_node)
        return result

    UniqueLoader.add_constructor(yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG, mapping)
    try:
        header = '\n'.join(lines[1:end])
        if any(isinstance(event, yaml.events.AliasEvent) for event in yaml.parse(header)):
            raise ValueError('YAML aliases are not accepted in snapshot metadata')
        data = yaml.load(header, Loader=UniqueLoader)
    except yaml.YAMLError as exc:
        raise ValueError('invalid skill YAML frontmatter') from exc
    if not isinstance(data, dict):
        raise ValueError('skill frontmatter must be a mapping')
    # YAML timestamp objects get a string projection; raw author bytes remain unchanged.
    return json.loads(json.dumps(data, default=str))


def descriptor(path, raw, mode):
    safe_path(path)
    if mode not in (0o644, 0o755):
        raise ValueError('unsupported projection mode')
    try:
        text = raw.decode('utf-8')
        binary = '\x00' in text
    except UnicodeDecodeError:
        text, binary = '', True
    if binary and len(raw) > 65535:
        raise ValueError('binary asset exceeds current BLOB byte limit (65535)')
    if not binary and SECRET.search(text):
        raise ValueError(f'private-key/token signature in {path}; no snapshot')
    if path.endswith('.json') and not binary:
        private_keys = {'expected_output', 'expected_skill', 'answer_key', 'grader_notes'}

        def evaluator(value):
            if isinstance(value, dict):
                return bool(private_keys.intersection(value)) or any(evaluator(v) for v in value.values())
            return isinstance(value, list) and any(evaluator(v) for v in value)

        try:
            private = evaluator(json.loads(text))
        except (json.JSONDecodeError, RecursionError) as exc:
            raise ValueError(f'malformed public JSON resource {path}; source-owner adjudication required') from exc
        if private:
            raise ValueError(f'evaluator-only material in {path}; no snapshot')
    return {'path': path, 'sha256': digest(raw), 'bytes': len(raw), 'mode': mode,
            'is_binary': binary}


def snapshot(source, entry):
    governance(entry)
    root = Path(source).resolve(strict=True)
    if not root.is_dir():
        raise ValueError('source must be an explicit skill directory')
    files, payloads, omitted = [], {}, []
    for parent, directories, names in os.walk(root, followlinks=False):
        parent = Path(parent)
        for name in list(directories):
            p = parent / name
            if name in PRIVATE:
                raise ValueError(f'evaluator/private directory {name}; curate the source first')
            if name in CACHE:
                omitted.append(str(p.relative_to(root)))
                directories.remove(name)
            elif p.is_symlink():
                raise ValueError('symlink resource directory refused')
        for name in names:
            p = parent / name
            rel = p.relative_to(root).as_posix()
            if name in CACHE or name.endswith(('.pyc', '.pyo')):
                omitted.append(rel)
                continue
            before = p.lstat()
            if not stat.S_ISREG(before.st_mode) or before.st_nlink != 1:
                raise ValueError('symlink/hardlink/nonregular resource refused')
            if before.st_mode & 0o7000:
                raise ValueError('special executable mode refused')
            fd = os.open(p, os.O_RDONLY | os.O_NOFOLLOW)
            try:
                with os.fdopen(fd, 'rb') as stream:
                    opened = os.fstat(stream.fileno())
                    raw = stream.read(MAX_BYTES + 1)
                    after = os.fstat(stream.fileno())
                if ((before.st_dev, before.st_ino, before.st_size, before.st_mtime_ns) !=
                        (opened.st_dev, opened.st_ino, opened.st_size, opened.st_mtime_ns) or
                        (opened.st_size, opened.st_mtime_ns) != (after.st_size, after.st_mtime_ns)):
                    raise ValueError('source changed during snapshot')
            except Exception:
                raise
            mode = 0o755 if before.st_mode & 0o111 else 0o644
            files.append(descriptor(rel, raw, mode))
            payloads[rel] = raw
            if len(files) > MAX_FILES or sum(f['bytes'] for f in files) > MAX_BYTES:
                raise ValueError('skill bundle exceeds file/byte budget')
    if 'SKILL.md' not in payloads or len(payloads['SKILL.md']) > 65535 or b'\x00' in payloads['SKILL.md']:
        raise ValueError('missing or oversized/non-text SKILL.md')
    meta = frontmatter(payloads['SKILL.md'])
    if meta.get('name') != entry['name'] or not isinstance(meta.get('description'), str) or not meta['description'].strip():
        raise ValueError('source name/description mismatch')
    if len(meta['description']) > 1024:
        raise ValueError('description exceeds schema limit')
    for field, limit in (('license', 100), ('compatibility', 500)):
        if meta.get(field) is not None and (not isinstance(meta[field], str) or len(meta[field]) > limit):
            raise ValueError(f'{field} exceeds schema/type limit')
    identity = {'schema': SCHEMA, 'name': entry['name'], 'source_owner': entry['source_owner'],
                'owner_company': entry['owner_company'], 'visibility_companies': entry['visibility_companies'],
                'source_frontmatter': meta, 'files': sorted(files, key=lambda f: f['path'])}
    manifest = dict(identity, bundle_sha256=digest(canonical(identity).encode()),
                    source_root=str(root), omitted_cache_paths=sorted(omitted),
                    authoring_authority='original_source_package', snapshot_only=True)
    return manifest, payloads


def validate_manifest(manifest):
    if manifest.get('schema') != SCHEMA or manifest.get('snapshot_only') is not True:
        raise ValueError('not an owned snapshot row')
    governance(manifest)
    files = manifest['files']
    if not isinstance(files, list) or not files or len(files) > MAX_FILES:
        raise ValueError('invalid snapshot file inventory')
    paths = [f['path'] for f in files]
    if paths != sorted(set(paths)) or 'SKILL.md' not in paths:
        raise ValueError('duplicate/unordered/missing bundle paths')
    for f in files:
        safe_path(f['path'])
        if f['mode'] not in (0o644, 0o755) or not re.fullmatch('[a-f0-9]{64}', f['sha256']):
            raise ValueError('invalid mode/hash')
    identity = {k: manifest[k] for k in ('schema', 'name', 'source_owner', 'owner_company',
                                       'visibility_companies', 'source_frontmatter', 'files')}
    if digest(canonical(identity).encode()) != manifest['bundle_sha256']:
        raise ValueError('snapshot manifest identity mismatch')


def b64(raw):
    return base64.b64encode(raw).decode('ascii')
