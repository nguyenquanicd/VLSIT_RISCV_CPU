# RTL Verification

**Current checkpoint / Hiện trạng 2026-11-16:** TOP integrates CVA6/core/tile, CCU, HPDcache and LLC; fresh 2/4-hart lint is clean. The latest source-consistent campaign has 58 real CPU cases and 98 evidence entries. [Current feature matrix and remaining work](../reports/post_a06_cluster_audit/README.md), [CPU evidence](../reports/fault_record_a06/README.md), [single replay Makefile](cmo_end_to_end/Makefile). Run `make fault-regression` from that Makefile's directory. / TOP đã tích hợp các khối chính, lint 2/4 hart không lỗi/warning; có 58 ca CPU thật và 98 mục bằng chứng. Không suy ra phần trăm coverage từ số ca.

The tables below describe the original focused leaf tests, not the current completeness of TOP. New CPU suites are in `atomic_end_to_end`, `cmo_end_to_end`, `fence_i_end_to_end`, `l1_eviction_end_to_end`, `directory_holder_end_to_end`, `ccu_victim_escape` and `fault_record_a06`. / Bảng dưới mô tả test leaf ban đầu; không dùng để kết luận TOP hiện chưa tích hợp. Các thư mục trên chứa test CPU và regression mới hơn.

`tile_coh_adapter/` contains a directed simulation for the CPU-tile ownership request/grant bridge, PREPARE busy gating, line locks, and terminal response release. It complements the standalone coherence-fabric and HPDcache probe-engine tests; it does not instantiate a complete CVA6 tile.

`tile_coh_adapter/` có mô phỏng directed cho cầu request/grant quyền sở hữu của CPU tile, chặn PREPARE khi cache còn bận, khóa dòng và nhả khóa sau phản hồi kết thúc. Test này bổ sung cho test riêng của coherence fabric và HPDcache probe engine; nó không instantiate CVA6 tile hoàn chỉnh.

`coh_tile_array/` verifies the composed tile-adapter array and shared MESI fabric at 2 and 4 harts. It checks a cold E grant, same-line E-to-S sharing, busy-query PREPARE gating, per-tag access/victim locks, and terminal lock release. This remains a control-path test; it does not instantiate CVA6, HPDcache arrays, LLC, or AXI data channels.

The focused testbenches cover the coherence fabric, composed coherence tile array, HPDcache probe engine, tile adapter, configured HPDcache ownership/refill, shared address-table routing, AXI memory mux, and LLC-to-memory data-width adapter. Each README records the checked behavior and its limits.

| Folder | Main checks | Integration limit |
|---|---|---|
| `coherence` | Seven transaction, probe, abort/retry, bank-progress, and grant-backpressure cases | Probe responses are modeled; not end-to-end CVA6/HPDcache/AXI |
| `hpd_probe_engine` | Lookup, E-to-S, mismatched-COMMIT rejection/recovery, dirty-M writeback, ABORT, invalidation, and backpressure | Directory and writeback services are modeled; no HPDcache arrays or CVA6 |
| `hpdcache_ownership` | Grant-gated cold refill and clean-Shared store invalidate/replay to exclusive ownership | Configured HPDcache arrays are instantiated; no CVA6, CCU, LLC, denial/error, or end-to-end cluster regression |
| `tile_coh_adapter` | Request/grant backpressure, PREPARE busy gating, line-lock lifetime, failed-COMMIT retention, and ABORT release | Adapter only; no CVA6 or HPDcache arrays |
| `coh_tile_array` | Composed adapters/fabric; cold E grant, shared E-to-S transition, busy-gated PREPARE, lock coverage/release; 2/4 harts | Control path only; no CVA6, HPDcache arrays, LLC, AXI or CMO endpoint |
| `addr_region_table` | Cacheable/uncached/MMIO classes, access boundaries, atomic-MMIO rejection, overlap rejection | Classifier leaf only; no CVA6 PMA or AXI route |
| `axi_region_route` | Shared classifier drives AW/AR memory or MMIO selection and uncached class metadata | Route leaf; no cluster-core integration or local DECERR response check |
| `axi_mem_mux` | Hart-ID extension, AWATOP, W payload, B/R demultiplexing, inactive-hart mask; 2/4 hart | Mux only; not connected to LLC or cluster core |
| `axi_dw_adapter` | 64-bit LLC to 32/64/128/256-bit memory conversion; W/R payload, B/R IDs and SLVERR propagation; ATOP metadata | Leaf simulation; TOP instantiates it structurally, but no LLC/core integration; wide-bus R-data test covers one aligned 64-bit transfer |

The TOP now elaborates at 2/4 harts, and its 64-bit memory path is exercised by real CPU tests. The 32/128/256-bit external memory configurations remain leaf-tested rather than functionally qualified end-to-end. PMU software operation, native LLC BIST/whole flush, external debug/interrupts, CPU MMIO/uncached ATOP and broad coherence/configuration stress remain open. A-06 actively tests external fault CSR accesses; it does not prove all CSR side effects. Passing focused tests does not establish full cluster correctness.

## Kiểm chứng RTL

Các testbench kiểm tra coherence fabric, probe engine HPDcache, tile adapter và đường ownership/refill trên HPDcache đã cấu hình. README từng thư mục mô tả nội dung test và giới hạn.

| Thư mục | Nội dung chính | Giới hạn tích hợp |
|---|---|---|
| `coherence` | Bảy ca transaction, probe, abort/retry, tiến triển giữa bank và backpressure grant | Mô hình hóa phản hồi probe; chưa kiểm tra CVA6/HPDcache/AXI end-to-end |
| `hpd_probe_engine` | Lookup, E-to-S, từ chối/khôi phục COMMIT sai target, writeback M dirty, ABORT, invalidate và backpressure | Mô hình hóa dịch vụ directory/writeback; không có mảng HPDcache hoặc CVA6 |
| `hpdcache_ownership` | Refill lạnh chờ grant và store Shared sạch invalidate/replay để lấy quyền exclusive | Instantiate mảng HPDcache cấu hình; chưa có CVA6, CCU, LLC, grant lỗi hay regression cluster đầu-cuối |
| `tile_coh_adapter` | Backpressure request/grant, chặn PREPARE khi cùng dòng bận, thời gian giữ line-lock, giữ khóa sau COMMIT lỗi và nhả sau ABORT | Chỉ test adapter; không có CVA6 hay mảng HPDcache |
| `coh_tile_array` | Ghép adapter và fabric; grant E lạnh, chuyển E-to-S khi share cùng dòng, chặn PREPARE khi cache bận, kiểm tra/nhả khóa; cấu hình 2/4 hart | Chỉ đường điều khiển; chưa có CVA6, mảng HPDcache, LLC, AXI hay endpoint CMO |
| `addr_region_table` | Phân loại cacheable/uncached/MMIO, biên truy cập, từ chối atomic vào MMIO và bảng chồng lấn | Chỉ classifier; chưa nối PMA CVA6 hoặc AXI route |
| `axi_region_route` | Bảng phân loại chung điều khiển AW/AR sang memory/MMIO và giữ metadata uncached | Chỉ route leaf; chưa tích hợp core hoặc kiểm tra response DECERR cục bộ |
| `axi_mem_mux` | Mở rộng hart ID, AWATOP, payload W, định tuyến B/R, mask hart không hoạt động ở cấu hình 2/4 hart | Chỉ mux; chưa nối LLC hoặc core |
| `axi_dw_adapter` | Đổi độ rộng LLC 64-bit sang memory 32/64/128/256-bit; kiểm tra payload W/R, ID B/R, SLVERR và metadata ATOP | Test leaf; TOP instantiate cấu trúc nhưng chưa nối LLC/core; test R-data bus rộng chỉ có một transfer 64-bit căn hàng |

TOP đã elaborate được ở 2/4 hart; test CPU thật đã kích hoạt đường memory 64-bit. Các cấu hình memory ngoài 32/128/256-bit mới kiểm tra ở leaf, chưa verify đầu-cuối. PMU qua phần mềm, BIST/whole flush LLC thật, debug/interrupt ngoài, MMIO/ATOP uncached từ CPU và stress coherence/matrix vẫn còn thiếu. A-06 đã test fault CSR ngoài nhưng chưa chứng minh mọi side effect của CSR. Test riêng lẻ không chứng minh toàn cluster đúng.
