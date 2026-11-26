# Documentation audit / Kiểm tra tài liệu

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

| Check / Kiểm tra | Result / Kết quả |
|---|---|
| Documents / Tài liệu | 799 (149 maintained / đang dùng) |
| READMEs | 295 (67 maintained / đang dùng) |
| Local links / Liên kết nội bộ | 11324 (2413 maintained / đang dùng) |
| Maintained-project findings / Lỗi trong tài liệu đang dùng | 0 |
| Preserved-source/snapshot findings / Mục lỗi thuộc bản lưu | 7406 |
| Vendor README subset / Tập README vendor | 31 |


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
