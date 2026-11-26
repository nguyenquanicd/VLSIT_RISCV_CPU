# CBO metadata checkpoint / Mốc metadata CBO

> **Documentation status / Trạng thái tài liệu:** This page records the named run or focused suite; earlier missing-core, timeout or unconnected-CMO statements are historical. Use the current HDS and dated audit for cluster status. / Trang này ghi lại lần chạy hoặc suite riêng; nhận định thiếu core, timeout hoặc CMO chưa nối của mốc cũ là lịch sử. Dùng HDS hiện tại và audit có ngày để xác định trạng thái cluster.

[Current cluster HDS / HDS cluster hiện tại](../../../doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) · [Recorded audit / Báo cáo đã lưu](../post_a06_cluster_audit/README.md) · [Tensor specification / Đặc tả tensor](../../../doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md)

## CMO arbiter RTL / RTL phân xử CMO

`m_vlsit_riscv_cmo_arbiter` buffers one round-robin-selected hart command, preserves PC/VA/PA/op under controller backpressure, and routes success/error completion only to the accepted hart. Directed simulations pass for 2 and 4 harts; logs are `arbiter_2h_sim.log` and `arbiter_sim.log`. The rule-check report is `arbiter_rules.log`. The module has been added to the production filelist but is not yet instantiated in the cluster core. These simulations exercise arbitration only, not retirement or CCU/LLC endpoints.

Arbiter CMO lưu một request được chọn round-robin, giữ PC/VA/PA/op khi controller stall và trả completion/error đúng hart. Mô phỏng directed pass cấu hình 2/4 hart. Module có trong filelist nhưng chưa instantiate tại cluster core; test này chưa kiểm chứng retirement hoặc endpoint CCU/LLC.

## Resolved tool timeout — 2026-11-15 / Đã xử lý timeout công cụ

Using the existing Verilator `v5.052-119-g014c9820d` binary at `C:/Users/PC/Tools/oss-cad-suite/bin/verilator_bin.exe` resolves the parameter-elaboration timeout observed with `v5.052-352-gc265bd444` at `C:/Tools`. The real-package store-unit test now completes model generation, C++ compilation, and simulation with exit code zero: `PASS: store-unit back-to-back CBO VA/op/PA alignment`. See `store_unit_sim_fixed.log` and `alternate_verilator.log`. The exact internal cause in the later binary has not been proven.

Bản Verilator sẵn có `v5.052-119-g014c9820d` xử lý được ca elaborate bị timeout ở bản `v5.052-352-gc265bd444`. Test store unit dùng package thật hiện hoàn tất sinh model, compile C++ và mô phỏng, exit code 0. Đây là bằng chứng sửa lỗi căn chỉnh VA; không phải bằng chứng hoàn tất retirement hay maintenance đầu-cuối. Các ghi chú timeout bên dưới là lịch sử.

## Result / Kết quả

The directed store-buffer test passes capture, queue ordering, metadata stability, and flush removal. Simulation log: `metadata_sim.log`. The same isolated testbench passes Verilator lint. It uses minimal package/type stubs and does not compile or simulate the full CVA6 hierarchy.

Test directed store buffer pass các kiểm tra capture, thứ tự hàng đợi, ổn định metadata và xóa khi flush. Log mô phỏng: `metadata_sim.log`. Testbench cô lập cũng pass Verilator lint. Test dùng package/type stub tối thiểu; không compile hoặc mô phỏng toàn hierarchy CVA6.

## Current boundary / Ranh giới hiện tại

PA, effective VA, and CBO operation travel from the speculative store-buffer head through LSU/EX, CVA6, tile, tile array, and into `m_vlsit_riscv_cluster_core`. The cluster core currently observes these fields only. PC is still associated with the retirement-head instruction and is not joined to this metadata path.

PA, VA hiệu dụng và operation CBO đi từ đầu store buffer speculative qua LSU/EX, CVA6, tile, tile array tới `m_vlsit_riscv_cluster_core`. Cluster core hiện chỉ nhận các trường này để quan sát. PC vẫn nằm ở instruction tại retirement head và chưa được ghép vào đường metadata.

## Remaining integration / Phần tích hợp còn lại

- Join the retirement PC and hold the CBO at retirement until controller completion.
- Route one accepted CMO request through per-hart arbitration to the shared controller.
- Connect the controller to the CCU context/line lock and per-line LLC maintenance service.
- Implement precise fault delivery and remove the CBO from the store buffer only on successful retirement.
- Run full CVA6/cluster lint and end-to-end directed simulation; no normal-exit full TOP lint result exists yet.

- Ghép PC tại retirement và giữ CBO cho tới khi controller hoàn tất.
- Đưa request CMO qua phân xử từng hart tới controller dùng chung.
- Nối controller với context/line lock CCU và dịch vụ maintenance từng line của LLC.
- Báo fault chính xác; chỉ xóa CBO khỏi store buffer khi retirement thành công.
- Chạy lint CVA6/cluster và mô phỏng directed đầu-cuối; hiện chưa có kết quả lint TOP kết thúc bình thường.

Code coverage was not measured, per the selected directed-check-only verification plan. / Không đo code coverage theo kế hoạch chỉ chạy directed checks đã chọn.

## Store-unit alignment correction / Sửa căn chỉnh store unit

Source inspection found that `store_unit` forwarded a live input VA while data/op were registered for the preceding instruction. The licensed copy now registers VA alongside data/op before enqueue. A new directed test changes the incoming VA/op during enqueue using real CVA6 packages. Verilator model generation remains incomplete; this correction has not yet passed simulation. The earlier isolated store-buffer pass does not exercise this register boundary.

Rà soát source phát hiện `store_unit` chuyển VA đầu vào trực tiếp trong khi data/op đã đăng ký cho lệnh trước. Bản sao có license hiện đăng ký VA cùng data/op trước enqueue. Test directed mới thay VA/op đầu vào trong lúc enqueue và dùng package CVA6 thật. Verilator chưa hoàn tất sinh model; bản sửa chưa pass mô phỏng. Kết quả store-buffer cô lập trước đó không kiểm tra ranh giới thanh ghi này.

## Frontend timeout investigation

The debug binary stops during `V3Param` parameter elaboration, before emitting a model. Reproduction with a reduced filelist (real CVA6 packages, FIFO, AMO buffer, store buffer, and store unit) also times out. Disabling optimization with `-O0` does not resolve it. An explicit configuration function that avoids `build_config` also fails to complete, so the evidence does not establish `build_config` as the cause. Logs: `debug_lint.log`, `no_const_lint.log`, and `store_unit_native.log`. The debug run writes intermediate trees under the test directory; these are diagnostic output, not synthesis sources.

Binary debug dừng ở bước elaborate tham số `V3Param`, trước khi xuất model. Filelist thu gọn vẫn timeout; `-O0` và cấu hình tường minh bỏ qua `build_config` cũng chưa xử lý được. Vì vậy chưa đủ bằng chứng kết luận `build_config` là nguyên nhân. Retirement và endpoint CCU/LLC chưa hoàn tất; không có kết quả mô phỏng hoặc lint TOP pass mới.
