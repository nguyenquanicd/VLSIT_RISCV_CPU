# FPU warning regression / Regression warning FPU

**EN:** Removes the two `UNOPTFLAT` dependencies without suppressing warnings or adding pipeline cycles. `fpu_wrap` separates state-selected VALID/payload routing from READY-dependent control. `fpnew_opgroup_block` distributes the merged slice READY directly, avoiding an alias that reads its own packed vector.

**VI:** Sửa hai dependency gây `UNOPTFLAT`, không tắt warning và không thêm chu kỳ pipeline. Wrapper tách chọn VALID/payload theo state khỏi logic phản hồi READY. Khối format lấy READY trực tiếp từ merged slice thay vì đọc lại vector đang được gán.

The independent legacy FPU reference checks results, flags, tags, READY, output VALID and latency for 1,600 scalar FP32/FP64 transactions. Another 256 mixed-format/group issue attempts exercise STALL and flush while held. This is a differential preservation check, not an independent IEEE-754 certification.

Reference FPU gốc độc lập kiểm tra kết quả, flags, tag, READY, output VALID và latency trên 1.600 giao dịch FP32/FP64. Thêm 256 lượt phát hỗn hợp để kiểm tra STALL và flush khi giữ request. Đây là kiểm tra bảo toàn hành vi, chưa phải chứng nhận IEEE-754 độc lập.

Run the single replay Makefile / Chạy Makefile dùng chung:

```powershell
cd C:\HQuan\102_MyGithub\VLSIT_RISCV_CPU\rtl\verification\cmo_end_to_end
make fpu-warning-regression
```

`fpu-warning-check` runs the differential test; `fence` rebuilds both CPU configurations, runs eight real FENCE.I cases, lints both TOPs and refreshes WF-019 artifacts. Native FENCE.I model generation fails if any reported warning remains. The unchanged legacy reference can still produce its original warnings in its comparison build; production-model logs are checked separately.

`fpu-warning-check` chạy test tương đương; `fence` build lại 2/4 hart, chạy tám ca FENCE.I thật, lint hai TOP và cập nhật WF-019. Nếu model FENCE.I còn warning được báo, runner trả lỗi. Reference gốc vẫn có thể báo warning trong build so sánh; log model production được kiểm tra riêng.

See [results and changed files](../../reports/fpu_warning_fix/README.md). / Xem kết quả và file sửa tại báo cáo trên.
