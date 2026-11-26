# Báo cáo lần chạy / Run report: review đặc tả cluster dual/quad (2026-11-20)

## Đã review
- Đặc tả: `doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md`, revision 0.33 (sửa 2026-11-20 21:33). Người dùng xác nhận đúng file này.
- Danh sách 13 hạng mục được người dùng chốt: ứng dụng, coherence và tiến triển, giao diện và chuẩn, clock/reset/CDC/RDC, tham số và cấu hình, mô hình lập trình, ASIC và SDC và timing, area/power/performance, DFT/security/RAS, verification, tài liệu, tích hợp, so sánh thương mại.
- Inventory: 83 section, 178 bảng, 61 requirement, 61 test, 44 decision, 31 open item (`inventory.json`).
- Đối chiếu RTL hiện tại (đã đổi trong ngày): timing profile 0/1/2, `PARA_DIR_SYNC_READ`, probe scheduler claim nguyên tử, sửa ánh xạ MEIP/SEIP, bridge LLC.
- Dữ liệu timing: `dual_gf55_800.zip`, `vp1902.zip` (đã phân tích ở review hợp nhất cùng ngày).

## Kết quả
- Verdict: **Conditional**, điểm trọng số 2,71 trên 5, 1 Blocker (F-001), 27 phát hiện (1 Critical, 19 High, 6 Medium, 1 Low theo thang gate).
- Gate: lần chạy đầu `RESULT: FAIL` vì F-001 (Critical) chưa waive. Ngày 2026-11-21 chủ dự án cấp waiver W-2 cho F-001 (owner Architect, hết hiệu lực khi có sweep chu kỳ theo HDS §8.3 hoặc khi ký mục tiêu tần số sản phẩm); chạy lại gate cho `RESULT: PASS`, waiver dùng 2/10 (F-016, F-001). Waiver không phải bằng chứng timing đóng được: F-001 vẫn mở dưới OPEN-TIMING-TARGET.
- Audit mẫu 3 phát hiện (F-009, F-003, F-010): 3 tp, false-positive 0 trên 3, false-negative 0 trên 3.
- Script: `vlsit_report_check.py` PASS cho `REVIEW_*.md`; `vlsit_review_report.py check` PASS cho `vlsit_spec_2026-11-20.md`.

## Việc không làm được và cách xử lý
- Web search cho so sánh thương mại chỉ trả về bài báo và trang tổng hợp, không có datasheet; các dòng thương mại ghi nguồn, ngày truy cập và nhãn INFERENCE.
- Không đánh giá CDC/RDC cấu trúc, timing sau P&R, timing macro SRAM và công suất (không có đầu vào).
- Không chạy simulation hoặc lint; mọi phát biểu về RTL dựa trên đọc source.
- Không mở hình, waveform và nội dung workbook CSR; đã đọc phần HDS mô tả chúng.
- Số dòng RTL có thể lệch nếu RTL tiếp tục thay đổi (RTL đang được sửa trong ngày review).
