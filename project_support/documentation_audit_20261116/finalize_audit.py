"""Finish the documentation audit; preserve backups and validate protected files."""
from pathlib import Path
import ast
import gzip
import hashlib
import json
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / 'scripts'))
import audit_documentation as checker

changes = json.loads((OUT / 'changes.json').read_text(encoding='utf-8'))


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def save(name, text):
    path = ROOT / name
    raw = path.read_bytes() if path.exists() else None
    data = text.replace('\r\n', '\n').encode('utf-8')
    if data == raw:
        return
    backup = OUT / 'before' / name
    new_in_this_audit = name in changes and changes[name]['before_sha256'] is None
    if raw is not None and not backup.exists() and not new_in_this_audit:
        backup.parent.mkdir(parents=True, exist_ok=True)
        backup.write_bytes(raw)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(data)
    changes[name] = dict(before_sha256=digest(backup) if backup.exists() else None,
                         after_sha256=digest(path))


name = 'README.md'
text = (ROOT / name).read_text(encoding='utf-8-sig')
row = '| Documentation links / Liên kết tài liệu | [Link audit and changed files / Kiểm tra liên kết và danh sách file sửa](project_support/documentation_audit_20261116/README.md) |\n'
if row not in text:
    text = text.replace('| Cleanup history / Lịch sử dọn tài liệu |', row + '| Cleanup history / Lịch sử dọn tài liệu |')
save(name, text)

name = 'project_support/README.md'
text = (ROOT / name).read_text(encoding='utf-8-sig')
row = '| `documentation_audit_20261116` | [README/link audit and changed files / Kiểm tra README, liên kết và danh sách file sửa](documentation_audit_20261116/README.md) |\n'
if row not in text:
    text = text.replace('| `doc_cleanup_20261116` |', row + '| `doc_cleanup_20261116` |')
save(name, text)

name = 'project_support/third_party/README.md'
text = (ROOT / name).read_text(encoding='utf-8-sig')
table_start = text.index('| Repository |')
table_end = text.index('\n\n', table_start)
table = text[table_start:table_end].replace('| Repository | Revision | Repository license file |',
    '| Repository / Nguồn | Revision | License / Giấy phép |')
text = '''# Third-party sources / Nguồn third-party

Pinned upstream snapshots support reuse, local modification and interface comparison. The selected CVA6/HPDcache baseline and dependencies are recorded in [source provenance](../../doc/specification/references/THIRD_PARTY_SOURCES.md).

Các snapshot upstream được pin để tái sử dụng, sửa cục bộ hoặc đối chiếu giao tiếp. Revision được chọn cho CVA6/HPDcache và dependency nằm trong tài liệu nguồn gốc mã.

''' + table + '''

## Source layout and status / Cấu trúc source và trạng thái

- [Pristine RTL / RTL nguyên bản](../../rtl/common/third_party/) · [Licensed modifications / Bản sửa giữ license](../../rtl/common/modified/) · [New VLSIT RTL / RTL VLSIT mới](../../rtl/common/vlsit/).
- [LLC dependency lockfile / Lockfile dependency LLC](../../scripts/third_party/axi_llc/Bender.lock) · [Preserved license files / File license được giữ](../licenses/third_party/).
- [Current cluster HDS / HDS cluster hiện tại](../../doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) · [Recorded implementation audit / Audit triển khai đã lưu](../reports/post_a06_cluster_audit/README.md).

The production AXI hierarchy now connects the CPU tiles, CCU, LLC and per-line maintenance path. Earlier compile-only counts and statements that the LLC wrapper is unconnected describe prior checkpoints; they do not describe the current hierarchy. Recorded directed evidence does not establish full functional or ASIC signoff.

Hierarchy AXI production đã nối CPU tile, CCU, LLC và maintenance theo line. Số liệu compile riêng và nhận định wrapper LLC chưa nối thuộc mốc cũ. Bằng chứng directed đã lưu chưa xác nhận kiểm chứng đầy đủ hoặc signoff ASIC.

Retain original copyright, SPDX and license notices in reused RTL. Modified copies keep those notices and add change history; new VLSIT RTL follows the project coding rules. The PlanV CVA6 snapshot is for comparison and is not the selected upstream baseline.

Giữ copyright, SPDX và license gốc trong RTL tái sử dụng. Bản sửa giữ thông báo gốc và thêm history; RTL VLSIT mới theo coding rule dự án. Snapshot PlanV CVA6 dùng đối chiếu, không phải baseline upstream đã chọn.

Some upstream README references require assets absent from the retained snapshot or a documentation-site renderer. [Known reference gaps / Danh sách tham chiếu còn thiếu](../documentation_audit_20261116/preserved_references.json) records each source and target; no replacement from another revision is implied.

Một số tham chiếu README upstream cần asset không có trong snapshot lưu hoặc cần bộ dựng website tài liệu. Danh sách trên ghi file nguồn và đích; không thay bằng file của revision khác.
'''
save(name, text)

report_name = 'project_support/documentation_audit_20261116/README.md'
report = '''# Documentation audit / Kiểm tra tài liệu

2026-11-16. Scope: Markdown, RST, AsciiDoc and README navigation across the project, excluding build/cache directories. Local targets and Markdown anchors are checked; external URLs are inventoried without HTTP requests.

Phạm vi: liên kết trong Markdown, RST, AsciiDoc và README toàn dự án, bỏ qua thư mục build/cache. Kiểm tra đích nội bộ và anchor Markdown; URL ngoài chỉ được thống kê, chưa kiểm tra qua HTTP.

- [Cluster 2/4 CPU HDS](../../doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) · [Tensor HDS](../../doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md).
- [Main README / README tổng](../../README.md) · [Documentation index / Mục lục tài liệu](../../doc/README.md).

## Changes / Nội dung sửa

Updated navigation targets and anchors, linked the current design packages, and separated historical reports from current implementation status. The cluster has internal D-cache coherence and an external AXI profile; external ACE is deferred. Its selected configuration disables CVXIF, so the draft tensor coprocessor is not an integrated accelerator in this cluster.

Sửa đích liên kết và anchor, dẫn đến hai bộ đặc tả hiện tại, phân biệt báo cáo lịch sử với trạng thái triển khai. Cluster có coherence D-cache nội bộ và profile AXI bên ngoài; ACE ngoài chưa triển khai. Cấu hình được chọn tắt CVXIF, nên tensor còn là đặc tả nháp riêng, chưa được tích hợp vào cluster này.

The simulation workspace README now describes its retained plan, runner and incomplete replay manifest. Existing simulation/lint evidence remains dated evidence; no RTL test or lint run was performed for this documentation audit.

README workspace mô phỏng mô tả đúng kế hoạch, runner và manifest replay chưa hoàn thiện. Kết quả simulation/lint cũ giữ nguyên mốc chạy; lần kiểm tra tài liệu này không chạy lại test hoặc lint RTL.

## Validation / Kết quả kiểm tra

@COUNTS@

Preserved findings are not project-navigation passes. They include old relative paths in immutable before/source snapshots, upstream references to missing assets, and unrendered site templates. Those records retain their run/source identities. The vendor README subset is listed separately with source path, line, target and reason.

Các mục lỗi trong bản lưu không được tính là liên kết dự án đã pass. Chúng gồm đường dẫn cũ trong snapshot, asset upstream còn thiếu và template website chưa dựng. Bản lưu giữ nguyên danh tính source/lần chạy. Tập README vendor có danh sách riêng ghi file, dòng, đích và nguyên nhân.

| Record / Hồ sơ | File |
|---|---|
| Full link results / Kết quả liên kết đầy đủ | [link_audit.json](link_audit.json) |
| Modified files and SHA-256 / File sửa và SHA-256 | [changes.json](changes.json) |
| Original link inventory, losslessly compressed / Kiểm kê ban đầu, nén không mất dữ liệu | [before_links.json.gz](before_links.json.gz) |
| Vendor README reference gaps / Tham chiếu README vendor còn thiếu | [preserved_references.json](preserved_references.json) |
| Source/backup integrity / Tính toàn vẹn source và backup | [validation.json](validation.json) |

Replay from the repository root / Chạy lại từ thư mục gốc:

```powershell
python -B -X utf8 scripts/audit_documentation.py
```

The command returns nonzero for maintained project link failures; preserved findings remain visible in its JSON. Original edited documents are retained under `before/` with their pre-edit SHA-256 in the change manifest.

Lệnh trả mã khác 0 nếu tài liệu dự án đang dùng có lỗi liên kết; lỗi thuộc bản lưu vẫn hiện trong JSON. Văn bản trước khi sửa nằm trong `before/`, có SHA-256 trong manifest.
'''
save(report_name, report.replace('@COUNTS@', 'Finalizing local checks. / Đang hoàn tất kiểm tra nội bộ.'))
# The report links the output files, so create them before scanning.
for filename in ['preserved_references.json', 'validation.json']:
    path = OUT / filename
    if not path.exists():
        path.write_text('{}\n', encoding='utf-8')

audit = checker.audit()
(OUT / 'link_audit.json').write_text(json.dumps(audit, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
vendor = [x for x in audit['findings'] if x['path'].startswith('project_support/third_party/')
          and Path(x['path']).name.lower().startswith('readme')]
catalog = dict(scope='Retained vendor README references only; snapshots remain in link_audit.json.',
               findings=vendor, count=len(vendor))
(OUT / 'preserved_references.json').write_text(json.dumps(catalog, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')

count = audit['counts']
stats = f'''| Check / Kiểm tra | Result / Kết quả |
|---|---|
| Documents / Tài liệu | {count['documents']} ({count['project_documents']} maintained / đang dùng) |
| READMEs | {count['readmes']} ({count['project_readmes']} maintained / đang dùng) |
| Local links / Liên kết nội bộ | {count['local_links']} ({count['project_local_links']} maintained / đang dùng) |
| Maintained-project findings / Lỗi trong tài liệu đang dùng | {audit['project_findings']} |
| Preserved-source/snapshot findings / Mục lỗi thuộc bản lưu | {audit['preserved_findings']} |
| Vendor README subset / Tập README vendor | {len(vendor)} |
'''
prior_links = [x[2] for x in checker.links((ROOT / report_name).read_text(encoding='utf-8'))]
save(report_name, report.replace('@COUNTS@', stats))
assert prior_links == [x[2] for x in checker.links((ROOT / report_name).read_text(encoding='utf-8'))]

(OUT / 'changes.json').write_text(json.dumps(changes, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
integrity_errors = []
for name, record in changes.items():
    for phase, path in [('after', ROOT / name), ('before', OUT / 'before' / name)]:
        expected = record[phase + '_sha256']
        if expected and (not path.exists() or digest(path) != expected):
            integrity_errors.append(dict(path=name, phase=phase))
baseline = json.loads((ROOT / 'project_support/doc_cleanup_20261116/manifest.json').read_text(encoding='utf-8'))
rtl_errors = [n for n, h in baseline['protected_rtl_sha256'].items()
              if not (ROOT / n).exists() or digest(ROOT / n) != h]
workbooks = [x for x in baseline['files'] if Path(x['new_path']).suffix.lower() in {'.xlsx', '.xlsm', '.xls'}]
workbook_errors = [x['new_path'] for x in workbooks
                   if not (ROOT / x['new_path']).exists() or digest(ROOT / x['new_path']) != x['sha256']]
python_files = ['scripts/audit_documentation.py',
                'project_support/documentation_audit_20261116/fix_documentation.py',
                'project_support/documentation_audit_20261116/finalize_audit.py']
for name in python_files:
    ast.parse((ROOT / name).read_text(encoding='utf-8-sig'), filename=name)
diff = subprocess.run(['git', 'diff', '--check', '--', *changes, *python_files],
                      cwd=ROOT, capture_output=True, text=True, encoding='utf-8', errors='replace')
gzip_before = json.loads(gzip.decompress((OUT / 'before_links.json.gz').read_bytes()))
validation = dict(date='2026-11-16', maintained_links_pass=audit['project_findings'] == 0,
    counts=count, preserved_findings=audit['preserved_findings'], vendor_readme_findings=len(vendor),
    modified_documents=len(changes), document_hash_mismatches=integrity_errors,
    protected_rtl_files_checked=len(baseline['protected_rtl_sha256']), protected_rtl_mismatches=rtl_errors,
    original_workbooks_checked=len(workbooks), workbook_mismatches=workbook_errors,
    python_sources_parsed=len(python_files), git_diff_check_exit=diff.returncode,
    git_diff_check_output=diff.stdout, git_diff_check_diagnostics=diff.stderr,
    compressed_initial_inventory_readable=bool(gzip_before['documents']),
    external_http_checked=False, rtl_tests_or_lint_rerun=False,
    final_report_navigation_rechecked=True)
ok = not (audit['project_findings'] or integrity_errors or rtl_errors or workbook_errors or diff.returncode)
validation['status'] = 'PASS_WITH_PRESERVED_REFERENCE_GAPS' if ok else 'FAIL'
(OUT / 'validation.json').write_text(json.dumps(validation, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print(json.dumps(validation, ensure_ascii=False, indent=2))
raise SystemExit(0 if ok else 1)
