# CMO controller verification / Kiểm chứng CMO controller

> **Documentation status / Trạng thái tài liệu:** This page records the named run or focused suite; earlier missing-core, timeout or unconnected-CMO statements are historical. Use the current HDS and dated audit for cluster status. / Trang này ghi lại lần chạy hoặc suite riêng; nhận định thiếu core, timeout hoặc CMO chưa nối của mốc cũ là lịch sử. Dùng HDS hiện tại và audit có ngày để xác định trạng thái cluster.

[Current cluster HDS / HDS cluster hiện tại](../../../../doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) · [Recorded audit / Báo cáo đã lưu](../../../reports/post_a06_cluster_audit/README.md) · [Tensor specification / Đặc tả tensor](../../../../doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md)

This standalone directed testbench checks the VLSIT CMO command sequencer against HDS requirements REQ-MEM-015–017 at both 2-hart and 4-hart configurations. It covers CLEAN success, PREPARE-error abort without an LLC request, LLC maintenance error and abort, true INVAL without owner writeback, payload stability under backpressure, retained PC/address/hart metadata, and rejection of reserved opcodes and inactive harts (the latter in the 2-hart profile). It does not verify CVA6 retirement/trap behavior, the CCU implementation, the LLC array, AXI writeback, or CPU-to-memory integration.

Run from this directory:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\run_regression.ps1
```

The same regression is available with `make regression`. Run `make mutation` to verify testbench sensitivity using a temporary mutated RTL copy; the delivered controller source is not edited.

Lint, model-generation, C++ build, and simulation logs are written to `verification/common/reports/cmo_controller/`, separately for each hart count. Each run creates a fresh generated build directory under `C:\HQuan\.test_tmp\riscv_cmo_controller_<harts>h_<timestamp>`. The mutation test forces owner-writeback enable high even for INVAL and must be caught by the INVAL check. Code coverage is not measured; the HDS does not specify a target.

Testbench standalone này kiểm tra directed sequencer CMO theo REQ-MEM-015–017 trong HDS ở cấu hình 2 và 4 hart. Các ca gồm CLEAN thành công, PREPARE lỗi và bỏ qua LLC, LLC maintenance lỗi rồi abort, INVAL thật không yêu cầu owner writeback, giữ payload khi backpressure, giữ metadata PC/địa chỉ/hart, từ chối opcode dành trước và hart không hoạt động (ca hart không hoạt động chạy ở profile 2 hart). Test không kiểm chứng retirement/trap của CVA6, CCU, mảng LLC, AXI writeback hay tích hợp CPU tới memory.

Chạy trong thư mục này bằng lệnh PowerShell ở trên hoặc `make regression`; dùng `make mutation` để kiểm tra testbench bắt được lỗi bằng một bản RTL bị mutate trong thư mục tạm, không sửa controller được giao. Log lint, sinh model, biên dịch C++ và mô phỏng riêng từng cấu hình nằm tại `verification/common/reports/cmo_controller/`; mỗi build mới nằm dưới `C:\HQuan\.test_tmp\riscv_cmo_controller_<harts>h_<timestamp>`. Mutation test buộc writeback enable bằng 1 kể cả với INVAL và phải bị check INVAL bắt. Không đo code coverage vì HDS chưa đặt target.
