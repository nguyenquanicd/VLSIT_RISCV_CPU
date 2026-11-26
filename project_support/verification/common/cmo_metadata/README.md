# Store-buffer CMO metadata check

> **Documentation status / Trạng thái tài liệu:** This page records the named run or focused suite; earlier missing-core, timeout or unconnected-CMO statements are historical. Use the current HDS and dated audit for cluster status. / Trang này ghi lại lần chạy hoặc suite riêng; nhận định thiếu core, timeout hoặc CMO chưa nối của mốc cũ là lịch sử. Dùng HDS hiện tại và audit có ngày để xác định trạng thái cluster.

[Current cluster HDS / HDS cluster hiện tại](../../../../doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) · [Recorded audit / Báo cáo đã lưu](../../../reports/post_a06_cluster_audit/README.md) · [Tensor specification / Đặc tả tensor](../../../../doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md)

The pending-tag table regression is `run_regression.ps1 -LlcPending`. It checks a full four-entry table, a fifth waiting replacement, release after an ordered completion, and 15 allocations across pointer wraps using the native LLC tag store. It reproduces the former full-table circular wait. This test injects completion events and does not verify CPU-to-memory maintenance.

Regression bảng pending tag: `run_regression.ps1 -LlcPending`. Test kiểm tra bảng bốn entry đầy, replacement thứ năm chờ, giải phóng sau completion đúng thứ tự và 15 allocation qua nhiều vòng pointer bằng tag store LLC native. Đây chưa phải kiểm chứng maintenance từ CPU tới memory.

This directed test checks that the speculative store buffer retains a CBO's physical address, original virtual address, and operation at its head. It also checks ordering behind an older store, payload stability while blocked, and removal by a pipeline flush.

Run from PowerShell:

```powershell
.\run_regression.ps1
```

The test uses minimal package/type stubs to isolate `store_buffer.sv`; it does not validate CVA6 retirement, cache maintenance, CCU, LLC, or TOP integration. Code coverage is not measured.

The additional `run_regression.ps1 -StoreUnit` test uses the real CVA6 packages and selected configuration. It changes the incoming VA/op while the preceding CBO enters the store buffer, checking that the original VA remains paired with the translated PA and registered opcode. Its model-generation attempt currently does not complete; it is not a simulation pass.

Test bổ sung `run_regression.ps1 -StoreUnit` dùng package và cấu hình CVA6 thật. Test thay VA/op đầu vào khi CBO trước đi vào store buffer, kiểm tra VA gốc vẫn khớp PA đã dịch và opcode đã đăng ký. Lần sinh model hiện chưa hoàn tất; chưa ghi nhận simulation pass.
