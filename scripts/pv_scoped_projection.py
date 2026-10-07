"""Selected files only; independent receipts never refresh shared provenance."""
import fcntl
import importlib.util
import json
import os
from pathlib import Path
import re
import stat
import uuid

from pv_scoped_db import digest, SCRIPTS

spec = importlib.util.spec_from_file_location('export_policy', SCRIPTS / 'pv-export-policy.py')
policy = importlib.util.module_from_spec(spec)
spec.loader.exec_module(policy)
DIMENSIONS, REQUIRED = policy.load_contract(str(SCRIPTS.parent / 'ontology/controlled-vocabulary-contract.json'))
SCHEMA = 'prompt-vault/pi-scoped-template-receipt/v1'
POLICY = 'prompt-vault/raw-pi-projection-policy/v1'
FULL = '.prompt-vault-export-state.json'
MANIFEST = '.prompt-vault-managed-files'
HASH = re.compile(r'[0-9a-f]{64}')


def selected_name(name):
    if not isinstance(name, str) or not re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9._-]{0,63}', name) or '..' in name:
        raise ValueError(f'unsafe selected name: {name!r}')
    return name


def projection(row):
    selected_name(row['name'])
    item = policy.classify(row, DIMENSIONS, REQUIRED)
    # Add only text-safe cognitive napkin/structured authoring. Procedures retain the bounded-only
    # restriction; shared raw-export classification still refuses gated/unknown content.
    supported_level = row['formalization_level'] == 'bounded' or (
        row['artifact_kind'] == 'cognitive' and row['formalization_level'] in ('napkin', 'structured'))
    if (row['status'] != 'active' or row['export_to_pi'] not in (True, 1) or
            item['disposition'] != 'exported' or row['control_mode'] != 'one_shot' or
            not supported_level):
        raise ValueError(f'projection policy refused {row["name"]}: '
                         f'{item.get("reason", "requires active published bounded one_shot")}')
    return item


def encoded(value):
    return (json.dumps(value, sort_keys=True, indent=2) + '\n').encode()


def open_directory(path):
    """Traverse with dirfds so neither leaf nor ancestor symlinks are followed."""
    path = Path(os.path.abspath(path))
    fd = os.open('/', os.O_RDONLY | os.O_DIRECTORY)
    try:
        for part in path.parts[1:]:
            nxt = os.open(part, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW, dir_fd=fd)
            os.close(fd)
            fd = nxt
        return fd
    except BaseException:
        os.close(fd)
        raise


class Directory:
    def __init__(self, path, apply):
        self.path = Path(os.path.abspath(path))
        self.fd = open_directory(self.path)
        fcntl.flock(self.fd, fcntl.LOCK_EX if apply else fcntl.LOCK_SH)
        self.staged = set()

    def close(self):
        """Best-effort cleanup; return diagnostics without replacing the outcome."""
        problems = []
        try:
            for name in sorted(self.staged):
                try:
                    os.unlink(name, dir_fd=self.fd)
                except FileNotFoundError:
                    pass
                except OSError as exc:
                    problems.append(f'staging residue {self.path / name}: {exc}')
                    continue
                self.staged.remove(name)
        finally:
            try:
                os.close(self.fd)
            except OSError as exc:
                problems.append(f'directory FD close failed for {self.path}: {exc}')
        return problems

    def read(self, name):
        try:
            fd = os.open(name, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK, dir_fd=self.fd)
        except FileNotFoundError:
            return None
        with os.fdopen(fd, 'rb') as stream:
            st = os.fstat(stream.fileno())
            if not stat.S_ISREG(st.st_mode) or st.st_nlink != 1 or st.st_uid != os.getuid():
                raise ValueError(f'unsafe projection file: {name}')
            data = stream.read()
            return ((st.st_dev, st.st_ino, st.st_mode, st.st_mtime_ns, st.st_ctime_ns), data)

    def check(self, name, expected):
        fd = open_directory(self.path)
        try:
            current, opened = os.fstat(fd), os.fstat(self.fd)
            if (current.st_dev, current.st_ino) != (opened.st_dev, opened.st_ino):
                raise ValueError('projection directory changed')
        finally:
            os.close(fd)
        if self.read(name) != expected:
            raise ValueError(f'concurrent/stale target file: {name}')

    def stage(self, data):
        name = '.pv-scoped-' + uuid.uuid4().hex + '.stage'
        fd = os.open(name, os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW,
                     0o600, dir_fd=self.fd)
        self.staged.add(name)
        with os.fdopen(fd, 'wb') as stream:
            stream.write(data)
            stream.flush()
            os.fsync(stream.fileno())
        snapshot = self.read(name)
        if snapshot[1] != data:
            raise ValueError('staging verification failed')
        return name, snapshot

    def replace(self, name, stage, expected):
        temporary, snapshot = stage
        self.check(temporary, snapshot)
        self.check(name, expected)
        os.replace(temporary, name, src_dir_fd=self.fd, dst_dir_fd=self.fd)
        self.staged.remove(temporary)
        os.fsync(self.fd)
        result = self.read(name)
        if result is None or result[1] != snapshot[1]:
            raise ValueError(f'post-write verification failed: {name}')
        return result


def json_snapshot(snapshot, label):
    try:
        result = json.loads(snapshot[1])
        if not isinstance(result, dict):
            raise ValueError('not an object')
        return result
    except (ValueError, TypeError) as exc:
        raise ValueError(f'invalid receipt: {label}') from exc


class Selected:
    def __init__(self, directory, vault, row):
        self.directory = directory
        self.item = projection(row)
        self.name = row['name']
        self.path = self.item['path']
        self.receipt_path = f'.prompt-vault-scoped-{self.name}.json'
        self.file = directory.read(self.path)
        self.receipt = directory.read(self.receipt_path)
        self.dependencies = {}
        self.final = {
            'schema': SCHEMA, 'state': 'complete', 'policy': POLICY,
            'source': {'vault_dir': str(vault), 'template_id': row['id']},
            'target': {'templates_dir': str(directory.path)},
            'template': {k: v for k, v in self.item.items() if k not in ('content', 'disposition')},
        }

    def admission(self):
        allowed = set()
        if self.receipt:
            receipt = json_snapshot(self.receipt, self.receipt_path)
            for key in ('schema', 'policy', 'source', 'target'):
                if receipt.get(key) != self.final[key]:
                    raise ValueError(f'scoped receipt {key} mismatch: {self.name}')
            item = receipt.get('template', {})
            if item.get('name') != self.name or item.get('path') != self.path:
                raise ValueError('scoped receipt identity mismatch')
            allowed.add(item.get('projected_sha256'))
            if receipt.get('state') == 'pending':
                # A pending receipt authorizes only the exact DB snapshot it
                # staged; don't overwrite recovery evidence with another edit.
                if item != self.final['template']:
                    raise ValueError('pending scope does not match DB; inspect before recovery')
                allowed.add(receipt.get('previous_sha256'))
            elif receipt.get('state') != 'complete':
                raise ValueError('invalid scoped receipt state')
        elif self.file:
            manifest, full = self.directory.read(MANIFEST), self.directory.read(FULL)
            self.dependencies = {MANIFEST: manifest, FULL: full}
            if manifest is None or full is None or manifest[1].decode().splitlines().count(self.path) != 1:
                raise ValueError(f'unmanaged collision: {self.path}')
            receipt = json_snapshot(full, FULL)
            items = [i for i in receipt.get('templates', []) if isinstance(i, dict) and i.get('name') == self.name]
            if (receipt.get('schema') != 'prompt-vault/pi-export-receipt/v2' or
                    receipt.get('policy') != POLICY or len(items) != 1 or items[0].get('path') != self.path or
                    any(i.get('name') == self.name for i in receipt.get('quarantined', []))):
                raise ValueError(f'no unique managed receipt: {self.name}')
            # Prior full provenance is NOT adopted as current DB truth. Only
            # its selected file ownership/hash is used to fence overwrite.
            allowed.add(items[0].get('sha256'))
        if any(value is not None and (not isinstance(value, str) or not HASH.fullmatch(value)) for value in allowed):
            raise ValueError('invalid receipt hash')
        if self.file and digest(self.file[1]) not in allowed:
            raise ValueError(f'stale target file: {self.path}')
        if self.file is None and self.receipt and not (receipt.get('state') == 'pending' and receipt.get('previous_sha256') is None):
            raise ValueError(f'missing managed target file: {self.path}; inspect before recovery')

    def fresh(self):
        return (self.file is not None and self.file[1] == policy.content_bytes(self.item['content']) and
                self.receipt is not None and json_snapshot(self.receipt, self.receipt_path) == self.final)

    def prepare(self):
        pending = dict(self.final, state='pending',
                       previous_sha256=digest(self.file[1]) if self.file else None)
        self.stages = [self.directory.stage(data) for data in
                       (encoded(pending), policy.content_bytes(self.item['content']), encoded(self.final))]

    def recheck(self):
        for path, snapshot in {self.path: self.file, self.receipt_path: self.receipt,
                               **self.dependencies}.items():
            self.directory.check(path, snapshot)

    def publish(self):
        self.recheck()
        pending, content, final = self.stages
        receipt = self.directory.replace(self.receipt_path, pending, self.receipt)
        self.directory.replace(self.path, content, self.file)
        self.directory.replace(self.receipt_path, final, receipt)
