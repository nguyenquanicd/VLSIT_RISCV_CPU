"""One-time, reversible documentation cleanup. Plan first; never delete file content."""
from pathlib import Path
from collections import Counter
from urllib.parse import unquote, urlsplit
import hashlib
import json
import os
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
DOC = ROOT / 'doc'
SUPPORT = ROOT / 'project_support'
OUT = Path(__file__).resolve().parent
LINK = re.compile(r'(!?\[[^\]\n]*\]\()(<[^>]+>|[^\s)]+)([^)]*\))')
FIGURE_EXT = {'.drawio', '.svg', '.json', '.png', '.html'}


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def save(name, value):
    (OUT / name).write_text(json.dumps(value, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')


def local_target(owner, value):
    value = value.strip('<>')
    if value.startswith(('#', 'data:', 'mailto:', 'plugin:', 'app:')):
        return None
    # Windows absolute paths are not URL schemes for this purpose.
    if not re.match(r'^[A-Za-z]:[/\\]', value) and urlsplit(value).scheme:
        return None
    target = unquote(value.split('#', 1)[0].split('?', 1)[0]).replace('\\', '/')
    if not target:
        return None
    path = Path(target)
    if not path.is_absolute():
        path = owner.parent / path
    return path.resolve()


def plan():
    if (OUT / 'manifest.json').exists():
        raise RuntimeError('Cleanup already applied; preserve the original plan and manifest.')
    files = sorted(p for p in DOC.rglob('*') if p.is_file())
    keep = {'doc/PROJECT_LAYOUT.md'}
    relocated = {}
    # Current specification sources and programming models.
    for p in (DOC / 'specification').iterdir():
        if p.is_file() and p.suffix in {'.md', '.json', '.xlsx'}:
            keep.add(p.relative_to(ROOT).as_posix())
    for p in (DOC / 'tensor_coprocessor').rglob('*'):
        if p.is_file() and p.suffix not in {'.log', '.txt'}:
            keep.add(p.relative_to(ROOT).as_posix())
    for category, destination in [('architecture', 'architecture'), ('research', 'references/research')]:
        for p in (DOC / category).glob('*.md'):
            relocated[p.relative_to(ROOT).as_posix()] = 'doc/specification/' + destination + '/' + p.name
    for name in ['VLSIT_RISCV_CPU_Cluster_Design_Review.md', 'VLSIT_RISCV_CPU_Review_2026-11-16.md']:
        p = DOC / 'review' / name
        if p.is_file():
            relocated[p.relative_to(ROOT).as_posix()] = 'doc/specification/review/' + name
    relocated['doc/provenance/THIRD_PARTY_SOURCES.md'] = 'doc/specification/references/THIRD_PARTY_SOURCES.md'
    for p in (DOC / 'maintenance/legacy_work/_spec_work').rglob('*'):
        if p.is_file():
            tail = p.relative_to(DOC / 'maintenance/legacy_work/_spec_work').as_posix()
            relocated[p.relative_to(ROOT).as_posix()] = 'doc/tensor_coprocessor/reference/' + tail
    keep.update(relocated)
    # Keep only figures actually used by the retained documents, plus editable
    # sources and render companions sharing their stem.
    pending = [ROOT / name for name in keep if name.endswith('.md')]
    pending.append(DOC / 'specification/figures/post_a06/README.md')
    seen = set()
    while pending:
        owner = pending.pop()
        if owner in seen or not owner.is_file():
            continue
        seen.add(owner)
        keep.add(owner.relative_to(ROOT).as_posix())
        for match in LINK.finditer(owner.read_text(encoding='utf-8-sig')):
            target = local_target(owner, match.group(2))
            if not target or not target.is_file() or not target.is_relative_to(DOC):
                continue
            rel = target.relative_to(ROOT).as_posix()
            if not rel.startswith(('doc/specification/figures/', 'doc/tensor_coprocessor/figures/')):
                continue
            keep.add(rel)
            if target.suffix == '.md':
                pending.append(target)
            for sibling in target.parent.glob(target.stem + '.*'):
                if sibling.suffix in FIGURE_EXT:
                    keep.add(sibling.relative_to(ROOT).as_posix())
    moves = {}
    rows = []
    for p in files:
        old = p.relative_to(ROOT).as_posix()
        new = relocated.get(old, old if old in keep else 'project_support/' + p.relative_to(DOC).as_posix())
        if old != new:
            moves[old] = new
        rows.append(dict(old_path=old, new_path=new, sha256=sha(p), size=p.stat().st_size))
    if len({r['new_path'] for r in rows}) != len(rows):
        raise RuntimeError('Destination collision')
    for old, new in moves.items():
        if (ROOT / new).exists():
            raise RuntimeError('Destination exists: ' + new)
    protected = {p.relative_to(ROOT).as_posix(): sha(p) for p in (ROOT / 'rtl').rglob('*') if p.is_file()}
    result = dict(date='2026-11-16', root=str(ROOT), files=rows, moves=moves,
                  protected_rtl_sha256=protected, initial_git_status=subprocess.check_output(
                      ['git', 'status', '--short'], cwd=ROOT, text=True))
    save('plan.json', result)
    print(json.dumps(dict(original_files=len(rows), retained_in_doc=sum(r['new_path'].startswith('doc/') for r in rows),
                          moved_to_support=sum(r['new_path'].startswith('project_support/') for r in rows),
                          doc_MiB=round(sum(r['size'] for r in rows if r['new_path'].startswith('doc/')) / 2**20, 2)), indent=2))


def apply():
    if (OUT / 'manifest.json').exists():
        raise RuntimeError('Already applied; use the manifest for recovery.')
    data = json.loads((OUT / 'plan.json').read_text(encoding='utf-8'))
    moves = data['moves']
    # Complete the read-only audit before moving a single file.
    for row in data['files']:
        source = (ROOT / row['old_path']).resolve()
        dest = (ROOT / row['new_path']).resolve()
        if not source.is_relative_to(DOC.resolve()) or not dest.is_relative_to(ROOT):
            raise RuntimeError('Path outside intended workspace')
        if sha(source) != row['sha256']:
            raise RuntimeError('File changed since plan: ' + row['old_path'])
        if source != dest and dest.exists():
            raise RuntimeError('Destination exists: ' + str(dest))
    for row in data['files']:
        if row['old_path'] == row['new_path']:
            continue
        source = ROOT / row['old_path']
        dest = ROOT / row['new_path']
        dest.parent.mkdir(parents=True, exist_ok=True)
        source.rename(dest)
        if sha(dest) != row['sha256']:
            raise RuntimeError('Move hash mismatch: ' + str(dest))
    # Only empty directories are removed; no file is permanently deleted.
    for directory in sorted((p for p in DOC.rglob('*') if p.is_dir()), key=lambda p: len(p.parts), reverse=True):
        if directory.resolve().is_relative_to(DOC.resolve()) and not any(directory.iterdir()):
            directory.rmdir()
    data['text_changes'] = {}
    save('manifest.json', data)
    print('Moved files; all moved-file hashes match the plan.')


def rebase():
    data = json.loads((OUT / 'manifest.json').read_text(encoding='utf-8'))
    if data.get('text_changes'):
        raise RuntimeError('References already rebased; do not overwrite pre-cleanup backups.')
    moves = data['moves']
    # Directory aliases cover live script destinations, including future outputs.
    aliases = {'doc/' + name: 'project_support/' + name for name in
               ['architecture_figures', 'csr', 'licenses', 'maintenance', 'provenance', 'reports',
                'rtl_layout', 'third_party', 'tools', 'verification']}
    aliases.update({'doc/architecture': 'doc/specification/architecture',
                    'doc/research': 'doc/specification/references/research',
                    'doc/review': 'project_support/review',
                    'doc/specification/revision_history': 'project_support/specification/revision_history'})
    all_aliases = dict(aliases, **moves)

    def map_name(name):
        if name in moves:
            return moves[name]
        for old in sorted(aliases, key=len, reverse=True):
            if name == old or name.startswith(old + '/'):
                return aliases[old] + name[len(old):]
        return name

    candidates = [(r['old_path'], r['new_path']) for r in data['files']
                  if r['old_path'].endswith('.md') and not r['old_path'].startswith(
                      ('doc/maintenance/', 'doc/third_party/', 'doc/licenses/', 'doc/specification/revision_history/'))
                  and '/before/' not in r['old_path']]
    candidates.append(('README.md', 'README.md'))
    candidates += [(p.relative_to(ROOT).as_posix(), p.relative_to(ROOT).as_posix())
                   for p in (ROOT / 'scripts').iterdir() if p.suffix in {'.py', '.ps1', '.sh', '.md'}]
    candidates.append(('.gitignore', '.gitignore'))
    for old_name, new_name in candidates:
        p = ROOT / new_name
        raw = p.read_bytes()
        try:
            text = raw.decode('utf-8-sig')
        except UnicodeDecodeError:
            continue
        original = text
        if p.suffix == '.md':
            def link_replace(match):
                value = match.group(2)
                target = local_target(ROOT / old_name, value)
                if target is None or not target.is_relative_to(ROOT):
                    return match.group(0)
                rel = target.relative_to(ROOT).as_posix()
                mapped = map_name(rel)
                if mapped == rel and old_name == new_name:
                    return match.group(0)
                suffix = ('#' + value.strip('<>').split('#', 1)[1]) if '#' in value else ''
                replacement = os.path.relpath(ROOT / mapped, p.parent).replace('\\', '/') + suffix
                if ' ' in replacement:
                    replacement = '<' + replacement + '>'
                return match.group(1) + replacement + match.group(3)
            text = LINK.sub(link_replace, text)
        # Plain project-root paths in prose, source strings, and ignore rules.
        pattern = re.compile('|'.join(re.escape(x) for x in sorted(all_aliases, key=len, reverse=True)))
        text = pattern.sub(lambda m: all_aliases[m.group()], text)
        if text == original:
            continue
        backup = OUT / 'before' / old_name
        backup.parent.mkdir(parents=True, exist_ok=True)
        backup.write_bytes(raw)
        newline = '\r\n' if b'\r\n' in raw else '\n'
        p.write_bytes(text.replace('\r\n', '\n').replace('\n', newline).encode('utf-8'))
        data['text_changes'][new_name] = dict(old_path=old_name, before_sha256=hashlib.sha256(raw).hexdigest(),
                                             after_sha256=sha(p))
    save('manifest.json', data)
    print('Rebased', len(data['text_changes']), 'navigation/tool files; RTL and historical snapshots untouched.')


if __name__ == '__main__':
    {'plan': plan, 'apply': apply, 'rebase': rebase}[sys.argv[1]]()
