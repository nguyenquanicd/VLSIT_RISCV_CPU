# RTL layout / Cấu trúc RTL

See [the project layout](../../doc/PROJECT_LAYOUT.md) for directory roles, commands and evidence provenance. / Xem cấu trúc dự án, lệnh chạy và nguồn gốc bằng chứng tại liên kết trên.

- [AXI TOP](../../rtl/non_coherence_cluster/m_vlsit_riscv_cluster_axi_top.sv): 2/4 harts, default 4; internal D-cache coherence remains enabled. / TOP AXI: 2/4 hart, mặc định 4; giữ coherence D-cache nội bộ.
- [AXI filelist](../../rtl/non_coherence_cluster/filelist.f): production hierarchy. / Hierarchy production.
- `rtl/coherence_cluster`: reserved for external ACE; no implemented TOP. / Dành cho ACE bên ngoài, chưa có TOP.
- `rtl/common/third_party`: unchanged licensed RTL. / RTL upstream nguyên bản, giữ license.
- `rtl/common/modified`: licensed modifications with history. / Bản sửa giữ license và history.
- `rtl/common/vlsit`: new/generated RTL grouped by function. / RTL mới hoặc sinh tự động, chia theo chức năng.

RTL directories contain only source/include files and filelists. Lint logs, simulation artifacts and documents are in sibling `lint`, `verification` and `doc`. / Các thư mục RTL chỉ chứa source, include và filelist; log lint, dữ liệu mô phỏng và tài liệu nằm trong các thư mục cùng cấp tương ứng.

[Functional status and remaining work / Hiện trạng chức năng và công việc còn lại](../reports/post_a06_cluster_audit/README.md). Historical validation is retained; this directory cleanup does not constitute a new full CPU regression. / Giữ kết quả kiểm chứng lịch sử; lần sắp xếp này không phải lần chạy lại toàn bộ regression CPU.
