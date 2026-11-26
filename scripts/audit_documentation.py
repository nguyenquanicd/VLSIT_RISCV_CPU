"""Audit local documentation links without accessing the network or changing sources.

Run from the project root: python scripts/audit_documentation.py
Vendor documents and immutable snapshots are inspected but reported separately.
"""
from pathlib import Path
from collections import Counter
from urllib.parse import unquote, urlsplit
import argparse
import html
import json
import os
import re
import unicodedata

ROOT = Path(__file__).resolve().parents[1]
SKIP = {'.git', '__pycache__', 'node_modules', 'build', 'obj', 'obj_dir', '.test_tmp',
        '.chrome-preview', 'Crashpad', '.pytest_cache'}
TEXT_EXT = {'.md', '.rst', '.adoc'}


def immutable(name):
    # This is the maintained project index, not an upstream README snapshot.
    if name == 'project_support/third_party/README.md':
        return False
    parts = Path(name).parts
    return (any(x in parts for x in ('third_party', 'before', 'source_snapshots', 'snapshots',
                                    'simulation_sources', 'legacy_work', 'dut', 'source_docs'))
            or any(x.startswith('before_') for x in parts)
            or Path(name).name.startswith('HDS_before')
            or Path(name).name.endswith('_contract_sections.md')
            or name.startswith(('project_support/maintenance/', 'project_support/provenance/',
                                'project_support/licenses/', 'project_support/specification/revision_history/',
                                'project_support/reports/hpdcache_query_baseline_20261114/'))
            or name == 'doc/tensor_coprocessor/reference/md_doc/vlsit_cvxif_openhw_core_v_xif_v1_0_0.md')


def documents():
    for base, dirs, files in os.walk(ROOT):
        dirs[:] = [d for d in dirs if d not in SKIP]
        for name in files:
            path = Path(base) / name
            rel = path.relative_to(ROOT).as_posix()
            if rel.startswith('project_support/documentation_audit_20261116/before/'):
                continue
            if path.suffix.lower() in TEXT_EXT or name.lower().startswith('readme'):
                yield path


def masked(text):
    """Ignore fenced and inline code; source samples are not navigation links."""
    text = re.sub(r'^([ \t]*)(`{3,}|~{3,}).*?^\1\2[^\n]*$',
                  lambda m: ''.join('\n' if c == '\n' else ' ' for c in m.group(0)), text, flags=re.M | re.S)
    return re.sub(r'(`+)([^\n]*?)\1', lambda m: ' ' * len(m.group(0)), text)


def links(text):
    """Return (start, end, destination), including balanced URL parentheses."""
    code = masked(text)
    for match in re.finditer(r'!?\[[^\]\n]*\]\([ \t]*', code):
        start = match.end()
        if start >= len(code):
            continue
        if code[start] == '<':
            end = code.find('>', start + 1)
            if end >= 0:
                yield start + 1, end, text[start + 1:end]
            continue
        end, depth = start, 0
        while end < len(code):
            char = code[end]
            if char == '\\':
                end += 2
                continue
            if char == '(':
                depth += 1
            elif char == ')':
                if depth == 0:
                    break
                depth -= 1
            elif char.isspace() and depth == 0:
                break
            end += 1
        if end > start:
            yield start, end, text[start:end]
    # Reference definitions and explicit HTML navigation in Markdown.
    for match in re.finditer(r'^\s{0,3}\[(?!\^)[^\]\n]+\]:\s*(?:<([^>]+)>|(\S+))', code, re.M):
        group = 1 if match.group(1) is not None else 2
        yield match.start(group), match.end(group), text[match.start(group):match.end(group)]
    for match in re.finditer(r'\b(?:href|src)\s*=\s*([\'"])(.*?)\1', code, re.I):
        yield match.start(2), match.end(2), html.unescape(match.group(2))
    for match in re.finditer(r'`[^`\n]*?<([^>\n]+)>`_', text):
        yield match.start(1), match.end(1), match.group(1)
    for match in re.finditer(r'\b(?:link:|image::)([^\s\[]+)\[', code):
        yield match.start(1), match.end(1), match.group(1)


def target(owner, value):
    value = html.unescape(value)
    if value.startswith(('data:', 'mailto:', 'javascript:', 'plugin:', 'app:')):
        return 'other', None, ''
    if not re.match(r'^[A-Za-z]:[/\\]', value) and urlsplit(value).scheme:
        return 'web', None, ''
    value = value.replace('\\ ', ' ').replace('\\(', '(').replace('\\)', ')')
    name, _, fragment = value.partition('#')
    name = unquote(name.split('?', 1)[0]).replace('\\', '/')
    if not name:
        return 'local', owner, unquote(fragment)
    path = Path(name)
    if name.startswith('/') and not path.exists():
        path = ROOT / name.lstrip('/')
    elif not path.is_absolute():
        path = owner.parent / path
    path = path.resolve()
    return ('local' if path.is_relative_to(ROOT) else 'external_file'), path, unquote(fragment)


def anchors(path):
    text = path.read_text(encoding='utf-8-sig', errors='replace')
    found = set(re.findall(r'\b(?:id|name)=[\'"]([^\'"]+)[\'"]', text))
    counts = Counter()
    heads = re.findall(r'^\s{0,3}#{1,6}\s+(.+?)\s*#*\s*$', text, re.M)
    heads += re.findall(r'^([^\n]+)\n(?:={3,}|-{3,})\s*$', text, re.M)
    for heading in heads:
        heading = re.sub(r'<[^>]+>', '', html.unescape(heading))
        heading = re.sub(r'!?\[([^\]]+)\]\([^)]*\)', r'\1', heading)
        slug = ''.join(c for c in heading.lower() if c in ' -_' or unicodedata.category(c)[0] in 'LMN')
        slug = slug.replace(' ', '-')
        ordinal = counts[slug]
        counts[slug] += 1
        found.add(slug if not ordinal else slug + '-' + str(ordinal))
    return found


def audit():
    rows, issues = [], []
    anchor_cache = {}
    counts = Counter()
    for path in sorted(documents()):
        name = path.relative_to(ROOT).as_posix()
        scope = 'preserved' if immutable(name) else 'project'
        text = path.read_text(encoding='utf-8-sig', errors='replace')
        counts['documents'] += 1
        counts[scope + '_documents'] += 1
        is_readme = path.name.lower().startswith('readme')
        counts['readmes'] += int(is_readme)
        counts[scope + '_readmes'] += int(is_readme)
        rows.append(dict(path=name, scope=scope, readme=is_readme))
        for start, end, value in links(text):
            try:
                kind, dest, fragment = target(path, value)
            except (ValueError, OSError) as exc:
                issues.append(dict(path=name, scope=scope, link=value, reason='invalid_target', detail=str(exc)))
                continue
            counts[kind + '_links'] += 1
            counts[scope + '_' + kind + '_links'] += 1
            if kind != 'local':
                continue
            reason = None
            if not dest.exists():
                reason = 'missing_target'
            elif fragment and dest.suffix.lower() == '.md':
                if dest not in anchor_cache:
                    anchor_cache[dest] = anchors(dest)
                if fragment not in anchor_cache[dest]:
                    reason = 'missing_anchor'
            if reason:
                issues.append(dict(path=name, scope=scope, link=value,
                                   line=text.count('\n', 0, start) + 1, reason=reason,
                                   target=dest.relative_to(ROOT).as_posix()))
    return dict(scope='Local Markdown/README navigation; no HTTP requests or RTL tests.',
                counts=dict(counts), documents=rows, findings=issues,
                project_findings=sum(x['scope'] == 'project' for x in issues),
                preserved_findings=sum(x['scope'] == 'preserved' for x in issues))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', default='project_support/documentation_audit_20261116/link_audit.json')
    args = parser.parse_args()
    result = audit()
    out = ROOT / args.output
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(json.dumps({k: v for k, v in result.items() if k not in ('documents', 'findings')}, indent=2))
    raise SystemExit(1 if result['project_findings'] else 0)
