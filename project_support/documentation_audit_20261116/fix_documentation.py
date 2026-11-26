"""Rebase project documentation; retain pre-edit bytes in the audit directory."""
from pathlib import Path
import hashlib
import json
import os
import re
import sys

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / 'scripts'))
from audit_documentation import documents, immutable, links, target, anchors
from project_layout import map_path

changed = {}
cleanup = json.loads((ROOT / 'project_support/doc_cleanup_20261116/manifest.json').read_text(encoding='utf-8'))
legacy = json.loads((ROOT / 'project_support/maintenance/layout_migration/manifest.json').read_text(encoding='utf-8'))
old_owners = {}
for old, new in cleanup['moves'].items():
    old_owners.setdefault(new, []).append(old)
for old, new in legacy['moves'].items():
    old_owners.setdefault(cleanup['moves'].get(new, new), []).append(old)


def write(name, text):
    path = ROOT / name
    raw = path.read_bytes() if path.exists() else None
    data = text.replace('\r\n', '\n').encode('utf-8')
    if raw == data:
        return
    backup = OUT / 'before' / name
    if raw is not None and not backup.exists():
        backup.parent.mkdir(parents=True, exist_ok=True)
        backup.write_bytes(raw)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(data)
    changed[name] = dict(before_sha256=hashlib.sha256(backup.read_bytes()).hexdigest()
                         if backup.exists() else None, after_sha256=hashlib.sha256(data).hexdigest())


def relative(owner, dest, fragment=''):
    return os.path.relpath(dest, owner.parent).replace('\\', '/') + ('#' + fragment if fragment else '')


def resolve_relocation(owner, value):
    kind, original, fragment = target(owner, value)
    if kind != 'local' or original.exists():
        return None
    candidates = [original]
    token = value.split('#', 1)[0]
    if token.startswith(('doc/', 'rtl/', 'verification/', 'project_support/', 'lint/', 'scripts/')):
        candidates.append(ROOT / token)
    name = owner.relative_to(ROOT).as_posix()
    for old in old_owners.get(name, []):
        _, candidate, _ = target(ROOT / old, value)
        if candidate:
            candidates.append(candidate)
    for candidate in candidates:
        if not candidate.is_relative_to(ROOT):
            continue
        rel = candidate.relative_to(ROOT).as_posix()
        mapped = ROOT / map_path(rel)
        if mapped.exists():
            return relative(owner, mapped, fragment)
        # The earlier migration already rebased some vendor links into the new
        # source-only RTL tree; documentation there moved to project_support.
        if rel.startswith('rtl/common/third_party/'):
            prior = 'rtl/third_party/' + rel[len('rtl/common/third_party/'):]
            mapped = ROOT / map_path(prior)
            if mapped.exists():
                return relative(owner, mapped, fragment)
    return None


def rebase_links():
    repaired = []
    for p in documents():
        name = p.relative_to(ROOT).as_posix()
        # Vendor README copies can receive navigation fixes; their originals,
        # notices and all source/snapshot bytes are preserved separately.
        vendor_readme = name.startswith('project_support/third_party/') and p.name.lower().startswith('readme')
        if immutable(name) and not vendor_readme:
            continue
        text = p.read_text(encoding='utf-8-sig')
        replacements = []
        for start, end, value in links(text):
            new = resolve_relocation(p, value)
            if new:
                replacements.append((start, end, new))
                repaired.append(dict(path=name, before=value, after=new))
        for start, end, new in sorted(set(replacements), reverse=True):
            text = text[:start] + new + text[end:]
        if replacements:
            write(name, text)
    return repaired


def common_links(folder):
    p = ROOT / folder / 'README.md'
    return ('[Current cluster HDS / HDS cluster hiện tại](' + relative(p, ROOT / 'doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md')
            + ') · [Recorded audit / Báo cáo đã lưu](' + relative(p, ROOT / 'project_support/reports/post_a06_cluster_audit/README.md')
            + ') · [Tensor specification / Đặc tả tensor](' + relative(p, ROOT / 'doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md') + ')')


repaired = rebase_links()

# One stale anchor in the current HDS, with no design-contract edit.
name = 'doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md'
s = (ROOT / name).read_text(encoding='utf-8-sig')
write(name, s.replace('#22-references-used-to-shape-this-specification', '#22-references-used-to-shape-this-template'))

# Root navigation must distinguish a proposed tensor attachment from the selected core configuration.
name = 'README.md'
s = (ROOT / name).read_text(encoding='utf-8-sig')
needle = '## 2. Tensor coprocessor / Bộ đồng xử lý tensor\n'
note = ('\nThe current cluster configuration disables CVXIF and exposes no CV-X-IF ports (HDS DEC-022). '
        'The tensor specification describes a future accelerator attachment; that integration remains to be defined.\n\n'
        'Cấu hình cluster hiện tại tắt CVXIF và không đưa cổng CV-X-IF ra ngoài (DEC-022). '
        'Đặc tả tensor mô tả phần kết nối accelerator cần thiết kế thêm; chưa phải cấu hình cluster đã tích hợp tensor.\n')
if note.strip() not in s:
    s = s.replace(needle, needle + note)
write(name, s)

index_text = {
 'project_support/rtl_layout/modified/README.md': '''# Modified upstream RTL / RTL upstream đã sửa

Licensed source copies live in [rtl/common/modified](../../../rtl/common/modified/). Pristine source snapshots live in [rtl/common/third_party](../../../rtl/common/third_party/). Local modifications retain original notices and dated change history.

Các bản source sửa có giữ license nằm trong `rtl/common/modified`; source nguyên bản nằm trong `rtl/common/third_party`. Bản sửa giữ thông báo gốc và history theo ngày.

- [Selected modified-source contracts / Hợp đồng source MODIFY](../../../doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md#14-rtl-implementation-contract).
- [Source revisions / Revision nguồn](../../../doc/specification/references/THIRD_PARTY_SOURCES.md) · [License files / File license](../../licenses/third_party/).
- [Recorded atomic evidence / Bằng chứng atomic đã lưu](../../reports/atomic_coherence/README.md) · [FENCE.I](../../reports/fence_i/README.md) · [Fatal retention / Giữ dữ liệu khi lỗi fatal](../../reports/l1_eviction_retention/README.md).

The production hierarchy includes the CBO retirement/CCU/LLC path. Qualification limits remain in the HDS and audit; earlier missing-core notes are historical.

Hierarchy production đã có đường retirement/CCU/LLC của CBO. Giới hạn kiểm chứng nằm trong HDS và audit; ghi chú thiếu core của mốc cũ là lịch sử.
''',
 'project_support/rtl_layout/vlsit/README.md': '''# VLSIT RTL / RTL VLSIT

New and generated blocks are grouped by function under [rtl/common/vlsit](../../../rtl/common/vlsit/). The AXI TOP, core and external memory-width adapter are under [rtl/non_coherence_cluster](../../../rtl/non_coherence_cluster/).

Khối RTL mới và sinh tự động nằm trong `rtl/common/vlsit`, chia theo chức năng. TOP AXI, core và adapter độ rộng memory ngoài nằm trong `rtl/non_coherence_cluster`.

- [Cluster HDS](../../../doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) · [CSR workbook](../../../doc/specification/VLSIT_RISCV_CPU_Cluster_CSR.xlsx).
- [TOP diagram / Sơ đồ TOP](../../../doc/specification/figures/post_a06/m_vlsit_riscv_cluster_axi_top.svg) · [FSM index / Mục lục FSM](../../../doc/specification/figures/post_a06/README.md).
- [Maintenance flow / Luồng maintenance](../../../doc/specification/figures/post_a06/CLUSTER_CMO_FLOW.svg) · [Waveforms](../../../doc/specification/figures/waveforms/README.md).

The AXI profile has internal D-cache coherence and supports 2 or 4 harts. External ACE is deferred; the tensor coprocessor remains a separate draft specification.

Profile AXI có coherence D-cache nội bộ và hỗ trợ 2 hoặc 4 hart. ACE bên ngoài chưa triển khai; tensor coprocessor hiện là đặc tả nháp riêng.
''',
 'project_support/tools/README.md': '''# Project tools / Công cụ dự án

Run tools from the repository root. Sources are in [scripts](../../scripts/); the [layout guide](../../doc/PROJECT_LAYOUT.md) explains production paths.

Chạy công cụ từ thư mục gốc repository. Source nằm trong `scripts`; hướng dẫn cấu trúc giải thích các đường dẫn production.

| Command / Lệnh | Purpose / Mục đích |
|---|---|
| `python scripts/run_cluster_top_lint.py --hart-count 2` | Lint 2-hart production TOP / Lint TOP production 2 hart |
| `python scripts/run_cluster_top_lint.py --hart-count 4` | Lint 4-hart production TOP / Lint TOP production 4 hart |
| `python scripts/audit_documentation.py` | Check local documentation targets and anchors / Kiểm tra đích và anchor liên kết nội bộ |

[Single behavioral replay Makefile / Makefile chạy lại chức năng](../../verification/non_coherence_cluster/cmo_end_to_end/Makefile) · [Diagram guide / Hướng dẫn hình](../../doc/specification/figures/post_a06/README.md).

The commands above are entrypoints, not results of this documentation review. / Các lệnh trên là điểm chạy; không phải kết quả mô phỏng/lint của lần rà soát tài liệu này.
'''
}
for name, text in index_text.items():
    write(name, text + '\n' + common_links(str(Path(name).parent)) + '\n')

# Preserve the report body as dated evidence; clearly separate it from current design authority.
for p in list((ROOT / 'project_support/reports').glob('*/README.md')) + list((ROOT / 'project_support/verification').glob('**/README.md')):
    name = p.relative_to(ROOT).as_posix()
    if immutable(name) or '/before/' in name:
        continue
    text = p.read_text(encoding='utf-8-sig')
    if 'Documentation status / Trạng thái tài liệu' in text:
        continue
    first, sep, rest = text.partition('\n')
    banner = ('\n\n> **Documentation status / Trạng thái tài liệu:** This page records the named run or focused suite; '
              'earlier missing-core, timeout or unconnected-CMO statements are historical. Use the current HDS and dated audit for cluster status. '
              '/ Trang này ghi lại lần chạy hoặc suite riêng; nhận định thiếu core, timeout hoặc CMO chưa nối của mốc cũ là lịch sử. '
              'Dùng HDS hiện tại và audit có ngày để xác định trạng thái cluster.\n\n'
              + common_links(str(Path(name).parent)) + '\n')
    write(name, first + banner + rest)

# Correct remaining old project-root path literals in maintained README prose/commands.
for p in documents():
    name = p.relative_to(ROOT).as_posix()
    if immutable(name) or not p.name.lower().startswith('readme'):
        continue
    s = p.read_text(encoding='utf-8-sig')
    pattern = re.compile(r'(?<![\w/])(?:rtl/(?:vlsit|third_party|modified|reports|verification)|doc/(?:reports|licenses|third_party|rtl_layout|maintenance|provenance))[^\s`<>()\[\],;]*')
    def replace(match):
        value = match.group(0).rstrip('.')
        mapped = map_path(value)
        if mapped == value:
            return match.group(0)
        return mapped + match.group(0)[len(value):]
    write(name, pattern.sub(replace, s))

# The live verification plan is planning material; link its real files and both HDS documents.
for folder in ['verification/plan', 'verification/sim/docs/00_plan']:
    p = ROOT / folder
    rows = [('verification_plan.md', 'Scope and methodology / Phạm vi và phương pháp'),
            ('requirements.txt', 'Requirements inventory / Danh sách yêu cầu'),
            ('vplan.csv', 'Test/checker traceability / Truy vết test và checker'),
            ('scope_matrix.json', 'Configurations / Cấu hình'),
            ('active_rtl_source_scope.json', 'Source denominator / Phạm vi source'),
            ('coverage_contract.json', 'Coverage obligations / Yêu cầu coverage')]
    text = ('# Cluster verification plan / Kế hoạch kiểm chứng cluster\n\n'
            'G0 planning package for the 2/4-hart AXI cluster. Plan acceptance is separate from simulation and coverage results.\n\n'
            'Gói kế hoạch G0 cho cluster AXI 2/4 hart. Duyệt kế hoạch không đồng nghĩa đã có kết quả mô phỏng hoặc coverage.\n\n')
    for filename, label in rows:
        if (p / filename).exists():
            text += '- [' + label + '](' + filename + ').\n'
    text += '\n' + common_links(folder) + '\n\nExternal ACE is deferred; the tensor design has a separate draft specification. / ACE ngoài chưa triển khai; tensor có đặc tả nháp riêng.\n'
    write(folder + '/README.md', text)

folder = 'verification/sim'
p = ROOT / folder / 'README.md'
text = '''# Cluster simulation package / Gói mô phỏng cluster

This workspace contains a retained DUT copy, qualification plan, focused tests and replay tooling. The current replay manifest still has placeholder configuration/command fields; a complete qualified campaign is not established by the presence of these files.

Workspace chứa bản sao DUT, kế hoạch kiểm chứng, test riêng và công cụ replay. Manifest replay hiện còn trường cấu hình/lệnh chưa điền; việc có file không chứng minh đã hoàn tất một campaign kiểm chứng.

- [Plan / Kế hoạch](docs/00_plan/README.md).
- [Recorded tool settings / Cấu hình công cụ đã ghi](env/toolchain.json) · [Replay manifest](env/replay_manifest.json).
- [Workspace manager / Công cụ quản lý workspace](scripts/vlsit_sim_workspace.py) · [Retained runner / Runner đã lưu](scripts/project_runner.py).
- [Existing production regression Makefile / Makefile regression production](../non_coherence_cluster/cmo_end_to_end/Makefile).

The retained runner names 2/4-hart FENCE.I success/error smoke cases. It is narrower than the complete HDS verification scope. Use each runner's own arguments and recorded environment; this documentation audit does not execute it.

Runner đã lưu định nghĩa smoke test FENCE.I thành công/lỗi ở 2/4 hart, có phạm vi hẹp hơn kế hoạch HDS đầy đủ. Dùng tham số và environment của runner; lần kiểm tra tài liệu này không chạy simulation.
'''
write(folder + '/README.md', text + '\n' + common_links(folder) + '\n')

# These two vendor navigation defects predate the migration. Fix anchors only.
for name, replacements in {
 'project_support/third_party/cva6/config/gen_from_riscv_config/README.md': {'(##Annexes)': '(#annexes)'},
 'project_support/third_party/culsans_cva6_pinned/README.md': {'(#table-of-contents)': '(#cva6-risc-v-cpu)', '(#fpga-emulation)': '(#corev-apu-fpga-emulation)'},
}.items():
    p = ROOT / name
    s = p.read_text(encoding='utf-8-sig')
    for old, new in replacements.items():
        s = s.replace(old, new)
    write(name, s)

# Repair unambiguous vendor navigation issues while retaining upstream prose.
for name, replacements in {
 'project_support/maintenance/layout_migration/README.md': {'(../../PROJECT_LAYOUT.md)': '(../../../doc/PROJECT_LAYOUT.md)'},
 'project_support/third_party/cva6/README.md': {
     '#Prerequisites': '#prerequisites', '#Getting-started': '#getting-started',
     '(#running-regression-tests-simulations)': '(#quick-setup)',
     '(#cva6-risc-v-cpu)': '(#directory-structure)',
     '(#corev-apu-fpga-emulation)': '(#directory-structure)'},
 'project_support/third_party/cva6/verif/README.md': {
     '- [Prerequisites](#prerequisites)\n': '',
     '- [Test execution](#test-execution)\n': '',
     '- [32-bit configuration](#32-bit-configuration)\n': ''},
 'project_support/third_party/hpdcache/README.md': {'hpdcache/docs/lint/hpdcache_lint.sv': 'hpdcache/rtl/lint/hpdcache_lint.sv'},
 'project_support/third_party/hpdcache_cva6_pinned/README.md': {'hpdcache_cva6_pinned/docs/lint/hpdcache_lint.sv': 'hpdcache_cva6_pinned/rtl/lint/hpdcache_lint.sv'},
}.items():
    p = ROOT / name
    s = p.read_text(encoding='utf-8-sig')
    for old, new in replacements.items():
        s = s.replace(old, new)
    write(name, s)
for folder in ['hpdcache', 'hpdcache_cva6_pinned']:
    name = 'project_support/third_party/' + folder + '/rtl/tb/qemu_plugin/README.md'
    p = ROOT / name
    s = p.read_text(encoding='utf-8-sig')
    s = re.sub(r'\]\([^\n)]*?/mailto:', '](mailto:', s)
    write(name, s)
name = 'project_support/third_party/cva6/corev_apu/instr_tracing/README.md'
p = ROOT / name
s = p.read_text(encoding='utf-8-sig')
s = re.sub(r'\]\([^\n)]*?/digilent\.com/', '](https://digilent.com/', s)
write(name, s)

manifest_path = OUT / 'changes.json'
previous = json.loads(manifest_path.read_text(encoding='utf-8')) if manifest_path.exists() else {}
previous.update(changed)
manifest_path.write_text(json.dumps(previous, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
(OUT / 'link_repairs.json').write_text(json.dumps(repaired, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print('Updated documentation files:', len(changed))
print('Deterministic relocation repairs:', len(repaired))
