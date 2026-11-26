# Project tools / Công cụ dự án

Run tools from the repository root. Sources are in [scripts](../../scripts/); the [layout guide](../../doc/PROJECT_LAYOUT.md) explains production paths.

Chạy công cụ từ thư mục gốc repository. Source nằm trong `scripts`; hướng dẫn cấu trúc giải thích các đường dẫn production.

| Command / Lệnh | Purpose / Mục đích |
|---|---|
| `python scripts/run_cluster_top_lint.py --hart-count 2` | Lint 2-hart production TOP / Lint TOP production 2 hart |
| `python scripts/run_cluster_top_lint.py --hart-count 4` | Lint 4-hart production TOP / Lint TOP production 4 hart |
| `python scripts/audit_documentation.py` | Check local documentation targets and anchors / Kiểm tra đích và anchor liên kết nội bộ |

[Single behavioral replay Makefile / Makefile chạy lại chức năng](../../verification/non_coherence_cluster/cmo_end_to_end/Makefile) · [Diagram guide / Hướng dẫn hình](../../doc/specification/figures/post_a06/README.md).

The commands above are entrypoints, not results of this documentation review. / Các lệnh trên là điểm chạy; không phải kết quả mô phỏng/lint của lần rà soát tài liệu này.

[Current cluster HDS / HDS cluster hiện tại](../../doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) · [Recorded audit / Báo cáo đã lưu](../reports/post_a06_cluster_audit/README.md) · [Tensor specification / Đặc tả tensor](../../doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md)
