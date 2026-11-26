"""Inventory production TOP sources and validate existing post-A-06 evidence.

This is an audit, not an RTL parser, functional test, or license determination.
Native TOP lint supplies elaboration evidence. Source-reference edges below only
describe the VLSIT integration boundaries; generate multiplicity is not expanded.
"""
from pathlib import Path
from datetime import datetime, timezone
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'rtl/reports/post_a06_cluster_audit'
BASE = ROOT / 'rtl/reports/full_integration'
TOP = 'm_vlsit_riscv_cluster_axi_top'

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def clean(text):
    return re.sub(r'/\*.*?\*/|//[^\r\n]*', '', text, flags=re.S)

def main():
    OUT.mkdir(parents=True, exist_ok=True)
    manifests = [ROOT / 'rtl/reports/cva6_flush_path/cva6_modified_cache.Flist',
                 BASE / 'filelist_llc_unique.f', BASE / 'filelist_vlsit_cluster.f']
    sources = {}
    seen_manifests = set()
    def read_manifest(manifest):
        manifest = manifest.resolve()
        if manifest in seen_manifests:
            return
        seen_manifests.add(manifest)
        for raw in manifest.read_text(encoding='utf-8').splitlines():
            line = raw.split('//')[0].strip()
            if not line or line.startswith('+'):
                continue
            if line.startswith(('-f ', '-F ')):
                child = Path(line.split(maxsplit=1)[1].strip('"'))
                if not child.is_absolute():
                    child = (manifest.parent if line.startswith('-F ') else BASE) / child
                read_manifest(child)
                continue
            if not line.endswith(('.sv', '.v', '.svh', '.vhd')):
                continue
            path = Path(line)
            if not path.is_absolute():
                path = BASE / path
            path = path.resolve()
            if not path.exists():
                raise RuntimeError(f'Missing source {path}')
            sources[path.relative_to(ROOT).as_posix()] = sha(path)
    for manifest in manifests:
        read_manifest(manifest)
    modules = {}
    for name in sources:
        text = clean((ROOT / name).read_text(encoding='utf-8', errors='replace'))
        for module in re.findall(r'\bmodule\s+(\w+)', text):
            if module in modules:
                raise RuntimeError(f'Duplicate module declaration: {module}')
            modules[module] = (name, text)
    def edges(module):
        text = modules[module][1]
        return sorted(other for other in modules if other != module and re.search(
            r'\b' + re.escape(other) + r'\s*(?:#\s*\(|[A-Za-z_]\w*\s*\()', text))
    visited = set()
    graph = {}
    def visit(module):
        if module in visited:
            return
        visited.add(module)
        graph[module] = dict(path=modules[module][0], source_references=edges(module))
        for child in graph[module]['source_references']:
            if child.startswith(('m_vlsit_', 'm_csr_')):
                visit(child)
    visit(TOP)
    a06 = json.loads((ROOT / 'rtl/reports/fault_record_a06/results.json').read_text())
    assert len(a06['results']) == 98 and all(row['passed'] for row in a06['results'])
    for group in ('source_sha256', 'verification_sha256'):
        for name, expected in a06[group].items():
            assert sha(ROOT / name) == expected, name
    cpu = [r for r in a06['results'] if ' CPU ' in r['test']]
    assert len(cpu) == 58
    lints = {}
    for h in (2, 4):
        log = sorted(BASE.glob(f'top_lint_{h}h_????????_??????.log'))[-1]
        text = log.read_text(encoding='utf-8', errors='replace')
        assert 'Verilator: Built' in text and not re.search(r'%Error|%Warning|%Fatal', text)
        lints[str(h)] = dict(log=log.relative_to(ROOT).as_posix(), sha256=sha(log), errors=0, warnings=0)
    lzc = 'rtl/third_party/cva6/vendor/pulp-platform/common_cells/src/lzc.sv'
    assert lzc in sources
    lzc_text = (ROOT / lzc).read_text()
    assert 'reuse/redistribution is strictly forbidden' in lzc_text
    counts = {}
    for r in cpu:
        key = r['test'].split(' CPU ')[0]
        counts[key] = counts.get(key, 0) + 1
    result = dict(date=datetime.now(timezone.utc).isoformat(), top=TOP,
                  source_inventory=sources,
                  manifests={p.relative_to(ROOT).as_posix():sha(p) for p in sorted(seen_manifests)},
                  vlsit_boundary_reference_graph=graph, native_top_lint=lints,
                  existing_validation=dict(entries=98, cpu_cases=58, suites=counts,
                                           cpu_simulation_rerun_in_this_audit=False,
                                           source_and_verification_hashes_match=True),
                  source_notice=dict(path=lzc, sha256=sources[lzc],
                                     restrictive_header_present=True,
                                     disposition='provenance/permission or licensed replacement needed before release'),
                  limitations='Reference graph is lexical, not a complete preprocessed elaboration or coverage model. No RTL edited.')
    (OUT / 'audit.json').write_text(json.dumps(result, indent=2)+'\n', encoding='utf-8')
    lines = ['# Production source inventory / Danh sách source production', '',
             f'{len(sources)} unique source files; all paths exist. / Tất cả đường dẫn tồn tại.', '',
             '| Source | SHA-256 |', '|---|---|']
    for name, digest in sources.items():
        lines.append(f'| [{name}](../../../{name}) | `{digest}` |')
    (OUT / 'source_inventory.md').write_text('\n'.join(lines)+'\n', encoding='utf-8')
    print(f'PASS: {len(sources)} production sources, {len(graph)} VLSIT/CSR boundaries; fresh TOP lint 2/4h clean; 98 existing entries/58 CPU cases source-consistent')
    print('NOTICE: restrictive lzc header is in the actual TOP filelist; see audit.json')

if __name__ == '__main__':
    main()
