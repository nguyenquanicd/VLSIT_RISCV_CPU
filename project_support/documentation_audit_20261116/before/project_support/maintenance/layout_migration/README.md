# Layout validation / Kiểm tra cấu trúc

Migration date / Ngày sắp xếp: 2026-11-16.

| Check / Kiểm tra | Result / Kết quả |
|---|---|
| RTL/include identity / Nội dung RTL/include | 1,832 original SHA-256 identities unchanged / Giữ nguyên 1.832 hash gốc |
| RTL tree contents / Nội dung cây RTL | Only RTL/include/filelists / Chỉ RTL, include và filelist |
| AXI TOP lint, 2 harts | Native exit 0; 0 errors, 0 warnings |
| AXI TOP lint, 4 harts | Native exit 0; 0 errors, 0 warnings |
| Fault-record smoke, 2 harts | PASS, 47 checks |
| Fault-record smoke, 4 harts | PASS, 86 checks |
| Historical A-06 package / Gói A-06 lịch sử | 98 entries, 58 CPU cases: identities and evidence links verified / Đã kiểm tra hash và liên kết |
| Canonical document links / Liên kết tài liệu chính | No missing target / Không thiếu đích |
| Active Python syntax / Cú pháp Python đang dùng | 62 files parsed / 62 file hợp lệ |
| Single Makefile / Makefile chung | `fault-regression` dry run passed; regression not rerun / Dry run pass, chưa chạy lại toàn bộ regression |

Fresh lint logs / Log lint mới:

- [2 harts](../../../lint/non_coherence_cluster/full_integration/top_lint_2h_20261116_073936.log)
- [4 harts](../../../lint/non_coherence_cluster/full_integration/top_lint_4h_20261116_074030.log)

Fresh simulation logs / Log mô phỏng mới:

- [2 harts](../../../verification/non_coherence_cluster/reports/layout_smoke/simulation_2h_error0.log)
- [4 harts](../../../verification/non_coherence_cluster/reports/layout_smoke/simulation_4h_error0.log)

Initial lint attempts exposed stale include-directory paths; those filelist paths were corrected and the clean runs above followed. Failed attempts remain in `lint` as history. No warning was suppressed and no RTL behavior was changed.

Các lần lint đầu phát hiện đường dẫn include cũ; đã sửa filelist và chạy lại sạch như trên. Log lỗi ban đầu được giữ trong `lint`. Không tắt warning và không sửa hành vi RTL.

The 58 CPU cases are historical evidence, not a new full regression after this migration. The new smoke tests exercise fault-record logic only. External ACE implementation remains paused. The root `figures/cluster_architecture` directory is empty but Windows currently prevents removal because another process holds it; its diagram and backup were preserved under `doc`.

58 ca CPU là bằng chứng lịch sử, không phải regression mới sau lần di chuyển. Smoke test mới chỉ kiểm tra fault-record. Chưa triển khai tiếp ACE. Thư mục gốc `figures/cluster_architecture` đã rỗng nhưng Windows chưa cho xóa vì tiến trình khác đang giữ; sơ đồ và bản sao lưu đã được giữ trong `doc`.

[Directory guide / Hướng dẫn thư mục](../../PROJECT_LAYOUT.md) · [Manifest](manifest.json) · [Source validation / Kiểm tra source](validation.json)
