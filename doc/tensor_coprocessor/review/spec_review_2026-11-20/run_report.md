# Báo cáo lần chạy / Run report: review đặc tả tensor coprocessor (2026-11-20)

## Đã review
- Đặc tả: `doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md` (trường version 0.1, file sửa 2026-11-20, 4.356 dòng). Người dùng xác nhận đúng file này.
- Danh sách 15 hạng mục được người dùng chốt: ứng dụng, tính năng và cấu hình, chức năng, giao diện và chuẩn, clock/reset/CDC, tham số và số học, ASIC và SDC và timing, area/power/performance, mô hình lập trình, DFT, security/RAS, verification, tài liệu, tích hợp, so sánh thương mại.
- Inventory: 69 section, 98 bảng, 62 requirement, 50 test, 35 property, 76 decision, 7 open item, 0 requirement thiếu test (`inventory.json`).
- Đối chiếu: các review ngày 2026-11-17 (re-review đọc 120 dòng đầu; hai file còn lại chỉ liệt kê), README, driver commit CVA6, báo cáo synthesis cluster đã tóm tắt trong review hợp nhất.

## Kết quả
- Verdict: **Conditional**, điểm trọng số 2,95 trên 5, 1 Blocker (F-001), 22 phát hiện (1 Critical, 12 High, 7 Medium, 2 Low theo thang gate; 19 fix, 1 waive, 2 none).
- Gate: lần chạy đầu `RESULT: FAIL` vì F-001 (Critical) chưa waive. Ngày 2026-11-21 chủ dự án cấp waiver W-2 cho F-001 (owner Architect, hết hiệu lực khi có RTL host đã sửa và bằng chứng TEST-029/030, hoặc khi HFC bị bác); chạy lại gate cho `RESULT: PASS`, waiver dùng 2/10 (F-012, F-001). Waiver không phải bằng chứng host frontier hoạt động: F-001 vẫn mở (RV-017).
- Audit mẫu 3 phát hiện (F-009, F-003, F-010): hai phát hiện được chỉnh sau khi đối chiếu spec (F-009 hạ từ Major xuống Minor vì đã có profile small-M; F-003 sửa trích dẫn 2,048 TB/s sang FEAT-006). False-positive 0 trên 3 sau chỉnh sửa, false-negative 0 trên 3.
- Script: `vlsit_report_check.py` PASS cho `REVIEW_*.md`; `vlsit_review_report.py check` PASS cho `vlsit_spec_2026-11-20.md`.

## Việc không làm được và cách xử lý
- So sánh thương mại chỉ có trang vendor, một paper và một repository, không có datasheet; các dòng thương mại ghi nguồn, ngày truy cập và nhãn INFERENCE.
- Không có RTL tensor, nên không có CDC/RDC, timing, area, power hay simulation; diện tích chỉ là proxy cấu trúc (dùng diện tích flop trung bình từ lần synthesis cluster 55LPx).
- Hợp đồng số học (DEC-053 đến DEC-070), byte map descriptor và tài liệu instruction-set chỉ đọc mẫu, không tính lại.
- Không mở workbook CSR, hình và waveform.
