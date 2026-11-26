# Coherence Fabric Directed Simulation

## CCU PMU event checks / Kiểm tra event PMU CCU

The fabric exports all workbook IDs `0x0300–0x030B`. This regression checks exact accumulated totals for accepted requests, directory hit/miss, PREPARE/COMMIT/ABORT acknowledgements, completed owner writebacks, and grants; it also checks that transaction-slot, same-line-lock, bank-conflict, and replacement events remain zero in the directed scenarios. Expected event totals are asserted in `tb_m_vlsit_riscv_coh_fabric.sv`. / Fabric xuất đủ các ID workbook `0x0300–0x030B`. Regression kiểm tra tổng tích lũy chính xác của request được nhận, directory hit/miss, ACK PREPARE/COMMIT/ABORT, writeback owner hoàn tất và grant; đồng thời xác nhận event thiếu transaction slot, khóa cùng line, xung đột bank và thay thế vẫn bằng 0 trong các kịch bản directed. Tổng mong đợi được assert trong `tb_m_vlsit_riscv_coh_fabric.sv`.

This testbench exercises the control plane of `m_vlsit_riscv_coh_fabric` with modeled probe responders. It covers seven directed cases:

1. A cold shared read receives `E` without probes.
2. A second hart requests shared ownership: the existing `E` holder is prepared and committed to `S`; the requester receives `S`.
3. An exclusive request probes two `S` holders, commits both to `I`, and receives `M`.
4. A dirty `M` owner completes PREPARE/writeback, commits to `I`, and transfers `M` to another hart.
5. A failed dirty-owner writeback runs PREPARE then ABORT, returns an error grant, and preserves the owner's `M` directory state.
6. Retrying the failed shared request with successful writeback commits the owner to `S` and grants `S` to the requester.
7. With hart 1's grant stalled for a line in bank 1, hart 2 completes a request to an unrelated line in bank 2; the first grant stays stable and retires when READY returns.

The failure case caught a fabric bug: PREPARE failure followed by successful ABORT was incorrectly returned as a successful CPU grant. The fabric now retains the error through ABORT and returns the error grant. The modeled `wback_done` response is a control-plane input; this test does not generate AXI W/B traffic.

This testbench does not instantiate CVA6, HPDcache, LLC, the cluster core or TOP. It verifies only the fabric's directory/probe/grant control behavior; it does not establish end-to-end cache coherence, AXI writeback behavior, performance or PPA closure.

Run `make lint` and `make sim` from this directory. Override `VERILATOR`, `VERILATOR_ROOT`, `MAKE`, and `BUILD_DIR` for another installation. The default GCC linker alias works around the local MinGW 16.2 C++ constructor-symbol mismatch; set `VERILATOR_LDFLAGS=` when using a compatible toolchain.

## Mô phỏng directed cho Coherence Fabric

Testbench kiểm tra control plane của `m_vlsit_riscv_coh_fabric`; phản hồi probe được mô hình hóa. Bảy ca kiểm tra gồm:

1. Read lạnh nhận quyền `E`, không cần probe.
2. Hart thứ hai xin shared: hart đang giữ `E` qua PREPARE và COMMIT sang `S`; hart yêu cầu nhận `S`.
3. Yêu cầu exclusive probe hai hart đang giữ `S`, commit cả hai sang `I`, rồi cấp `M`.
4. Owner `M` dirty hoàn tất PREPARE/writeback, commit sang `I`, sau đó chuyển `M` cho hart khác.
5. Writeback của owner `M` thất bại; fabric chạy PREPARE rồi ABORT, trả error grant và giữ nguyên trạng thái directory `M` của owner.
6. Thử lại yêu cầu shared với writeback thành công; owner chuyển sang `S` và requester nhận `S`.
7. Khi grant của hart 1 cho line ở bank 1 bị stall, hart 2 vẫn hoàn tất request tới line khác ở bank 2; grant đầu giữ ổn định và được tiêu thụ khi READY bật lại.

Ca lỗi phát hiện bug: sau PREPARE thất bại và ABORT thành công, fabric từng trả CPU grant thành công. RTL hiện giữ cờ lỗi qua ABORT và trả error grant. `wback_done` trong test là phản hồi điều khiển được mô hình hóa; test không tạo giao dịch AXI W/B.

Testbench không tạo CVA6, HPDcache, LLC, cluster core hoặc TOP. Kết quả chỉ xác nhận điều khiển directory/probe/grant của fabric; không chứng minh coherence đầu-cuối, writeback AXI, hiệu năng hay PPA.

Chạy `make lint` và `make sim` trong thư mục này. Có thể ghi đè `VERILATOR`, `VERILATOR_ROOT`, `MAKE` và `BUILD_DIR`. Linker alias GCC mặc định xử lý lỗi symbol constructor C++ của MinGW 16.2 tại máy này; đặt `VERILATOR_LDFLAGS=` với toolchain tương thích.
