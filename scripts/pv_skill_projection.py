"""Explicit new-target bundle projection, preserving bytes and executable intent."""
import json
import os
from pathlib import Path
import stat
import sys

import pv_skill_bundle as bundle

RECEIPT = '.prompt-vault-skill-snapshot.json'


def target_path(value, name):
    path = Path(value).absolute()
    if path.name != name or '..' in path.parts:
        raise ValueError('target must be the exact skill-name directory, without traversal')
    current = Path(path.anchor)
    for part in path.parts[1:-1]:
        current /= part
        s = current.lstat()
        if not stat.S_ISDIR(s.st_mode) or current.is_symlink():
            raise ValueError('target parent has unsafe/missing/symlink ancestry')
    return path


def identity(vault, row, manifest):
    return {'schema': 'prompt-vault/skill-projection-receipt/v1', 'vault': str(vault),
            'skill_id': row['id'], 'name': row['name'], 'version': row['version'],
            'bundle_sha256': manifest['bundle_sha256'], 'snapshot_only': True}


def check(path, expected, manifest, payloads):
    if path.is_symlink() or not path.is_dir():
        raise ValueError('missing/unsafe skill projection')
    receipt = path / RECEIPT
    if receipt.is_symlink() or not receipt.is_file() or receipt.stat().st_nlink != 1:
        raise ValueError('missing/unsafe snapshot receipt')
    value = json.loads(receipt.read_text())
    if value != dict(expected, state='complete'):
        raise ValueError('foreign/stale/pending skill projection receipt')
    files = set()
    for parent, directories, names in os.walk(path, followlinks=False):
        for name in directories:
            if Path(parent, name).is_symlink():
                raise ValueError('symlink projection resource directory')
        for name in names:
            p = Path(parent, name)
            s = p.lstat()
            if not stat.S_ISREG(s.st_mode) or s.st_nlink != 1:
                raise ValueError('unsafe projection resource')
            files.add(p.relative_to(path).as_posix())
    if files != set(payloads) | {RECEIPT}:
        raise ValueError('extra/missing projection files')
    # Empty extra directories are not silently adopted either.
    expected_dirs = {str(parent) for f in payloads for parent in Path(f).parents if str(parent) != '.'}
    actual_dirs = {p.relative_to(path).as_posix() for p in path.rglob('*') if p.is_dir()}
    if actual_dirs != expected_dirs:
        raise ValueError('extra/missing projection directories')
    for f in manifest['files']:
        p = path / f['path']
        if p.read_bytes() != payloads[f['path']] or stat.S_IMODE(p.stat().st_mode) != f['mode']:
            raise ValueError('skill projection bytes/mode drift')


def write_at(directory_fd, relative, raw, mode):
    parts = bundle.safe_path(relative).parts
    fd = os.dup(directory_fd)
    try:
        for part in parts[:-1]:
            try:
                os.mkdir(part, 0o755, dir_fd=fd)
            except FileExistsError:
                pass
            child = os.open(part, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW, dir_fd=fd)
            os.close(fd)
            fd = child
        out = os.open(parts[-1], os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW,
                      mode, dir_fd=fd)
        with os.fdopen(out, 'wb') as stream:
            stream.write(raw)
            stream.flush()
            os.fchmod(stream.fileno(), mode)
            os.fsync(stream.fileno())
    finally:
        os.close(fd)


def export(path, expected, manifest, payloads):
    if path.exists() or path.is_symlink():
        check(path, expected, manifest, payloads)
        return 'noop'
    parent = os.open(path.parent, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW)
    owned, root, receipt = False, None, None
    try:
        os.mkdir(path.name, 0o700, dir_fd=parent)  # exclusive ownership: no overwrite/adoption
        owned = True
        root = os.open(path.name, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW, dir_fd=parent)
        # Receipt has a separate trusted fixed filename, not a source-controlled asset path.
        receipt = os.open(RECEIPT, os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW,
                          0o600, dir_fd=root)
        # Keep the original FD: never reopen/truncate a concurrently replaced path.
        with os.fdopen(os.dup(receipt), 'w') as stream:
            json.dump(dict(expected, state='pending'), stream, sort_keys=True)
            stream.flush()
            os.fsync(stream.fileno())
        for f in manifest['files']:
            write_at(root, f['path'], payloads[f['path']], f['mode'])
        held, named = os.fstat(receipt), os.stat(RECEIPT, dir_fd=root, follow_symlinks=False)
        if held.st_nlink != 1 or (held.st_dev, held.st_ino) != (named.st_dev, named.st_ino):
            raise ValueError('receipt identity changed during export')
        os.lseek(receipt, 0, os.SEEK_SET)
        os.ftruncate(receipt, 0)
        with os.fdopen(os.dup(receipt), 'w') as stream:
            json.dump(dict(expected, state='complete'), stream, sort_keys=True)
            stream.flush()
            os.fsync(stream.fileno())
        os.fsync(root)
        os.fsync(parent)
        check(path, expected, manifest, payloads)
        return 'exported'
    except Exception as exc:
        if owned:
            raise RuntimeError(f'KNOWN-PARTIAL: owned export target {path}; inspect receipt/bytes; no automatic cleanup or overwrite') from exc
        raise
    finally:
        errors = []
        for fd in (receipt, root, parent):
            if fd is not None:
                try:
                    os.close(fd)
                except OSError as exc:
                    errors.append(str(exc))
        if errors:
            print('CLEANUP-INCOMPLETE: primary effect classification unchanged; ' + '; '.join(errors), file=sys.stderr)
