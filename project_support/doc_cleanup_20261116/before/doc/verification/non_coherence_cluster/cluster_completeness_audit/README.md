# Cluster corner audit / Kiểm tra ca biên cluster

EN: This audit reuses the existing specification-grounded CBO test with one stimulus change: initialize each private line to `49 + hart_id` and execute a real `LD a3,0(a1)` before the existing `SD a3,0(a1); CBO.CLEAN`. No AXI error is injected. The required result remains successful maintenance and retirement. Loading a private line permits E, and the subsequent local store makes it dirty; TEST-019 and REQ-MEM-001 require this legal transition to remain coherent. Existing CBO checks detect an unexpected early terminal/ABORT before LLC maintenance. The original audit did not edit RTL. Follow-up A-01 now corrects the CCU and this regression must PASS; see `doc/reports/e_to_m_fix/README.md`.

VI: Test giữ các kiểm tra CBO theo spec, chỉ đổi stimulus: khởi tạo line riêng bằng `49 + hart_id`, chạy instruction `LD a3,0(a1)` thật trước `SD a3,0(a1); CBO.CLEAN`. Không chèn lỗi AXI. Kết quả yêu cầu vẫn là maintenance và retire thành công. Đọc line riêng có thể nhận E; store cục bộ làm line dirty. TEST-019/REQ-MEM-001 yêu cầu chuyển trạng thái hợp lệ này được giữ coherent. Audit ban đầu giữ test FAIL và không sửa RTL; bản sửa A-01 nay làm test PASS. Xem báo cáo E→M.

Replay through the shared Makefile / Chạy qua Makefile dùng chung:

```powershell
cd C:\HQuan\102_MyGithub\VLSIT_RISCV_CPU\rtl\verification\cmo_end_to_end
make audit-e-to-m2
make audit-e-to-m4
```

Logs / Log: `verification/non_coherence_cluster/reports/cluster_completeness_audit`.
