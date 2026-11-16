# FPU warning cleanup / Sửa warning FPU

**Current status / Hiện tại (2026-11-15):** The production AXI TOP is integrated and strict lint passes at 2/4 harts. Actual CPU atomic, CBO and FENCE.I tests pass. [Latest source changes and limits](../reports/atomic_coherence/README.md). Sections below retain earlier implementation notes and pre-integration validation history; their missing-core/timeout statements are historical. / TOP AXI đã tích hợp, lint nghiêm ngặt 2/4 hart và test CPU atomic/CBO/FENCE.I pass. Nội dung bên dưới giữ lịch sử triển khai; nhận định thiếu core hoặc timeout là kết quả cũ.

[Latest report](../reports/fpu_warning_fix/README.md): licensed `fpu_wrap.sv` and `fpnew_opgroup_block.sv` copies remove the READY dependency cycles without added pipeline stages or warning suppression. Native simulation models and TOP lint are warning-free at 2/4 harts; FPU preservation and real FENCE.I regressions pass.

[Báo cáo mới nhất](../reports/fpu_warning_fix/README.md): hai bản sao có license sửa dependency READY, không thêm tầng pipeline hoặc suppression. Model mô phỏng và lint TOP 2/4 hart không còn warning; regression FPU và FENCE.I thật đều pass.

# Latest FENCE.I checkpoint / Mốc FENCE.I mới nhất

[DEC-030/031 report](../reports/fence_i/README.md) lists every changed licensed copy, source hashes, eight real-instruction M/S tests and TOP lint. This checkpoint supersedes earlier incomplete-integration notes below.

Báo cáo trên liệt kê mọi bản sao RTL sửa có license, hash nguồn, tám test instruction thật M/S và lint TOP. Mốc này thay thế các ghi chú tích hợp chưa hoàn tất của lần chạy cũ phía dưới.

# Modified upstream source / Bản sao nguồn upstream đã sửa

HPDcache ownership checkpoint (2026-11-14): cacheable MSHR allocations issue an ownership request before the miss handler asserts refill AR. Read/prefetch misses request shared permission; write-allocate misses request exclusive permission. Matching E/M grants are carried with the memory response ID into the refill directory update. A clean Shared write-back store hit is invalidated locally and replayed as a write miss; the replay must obtain M permission before refill and before the store can modify data. This conservative path adds an LLC read/refill to an S-to-M transition. Denied or mismatched grants use a synthetic full-line error response to retire the MSHR/FETCHING entry. Configured HPDcache query lint passes with 0 errors and 131 warnings. The directed Verilator simulation now passes cold-load grant gating and Shared-store invalidate/replay against the configured HPDcache arrays; see `rtl/verification/hpdcache_ownership/`. The path is not integrated to the CCU because `m_vlsit_riscv_cluster_core` is still missing. / Mốc ownership HPDcache (2026-11-14): MSHR cacheable phát ownership request trước khi miss handler phát refill AR. Miss đọc/prefetch xin shared; write-allocate xin exclusive. Grant E/M khớp được truyền cùng memory response ID tới cập nhật directory refill. Store write-back hit trên line Shared sạch sẽ invalidate copy cục bộ rồi replay như write miss; request replay phải lấy quyền M trước refill và trước khi store sửa dữ liệu. Cách an toàn này thêm một lượt đọc/refill LLC khi chuyển S→M. Grant sai/bị từ chối dùng full-line error response tổng hợp để giải phóng MSHR/FETCHING. Lint query HPDcache cấu hình pass với 0 lỗi, 131 cảnh báo. Mô phỏng Verilator directed hiện pass với miss đọc lạnh có grant và store Shared invalidate/replay trên mảng HPDcache cấu hình; xem `rtl/verification/hpdcache_ownership/`. Đường này chưa nối CCU do thiếu `m_vlsit_riscv_cluster_core`.

HPDcache integration baseline (2026-11-14): `hpdcache/rtl/src/hpdcache_flush.sv` derives from commit `e8f072e117ed3282950d4d1e975f462b173f0de0`, matching the selected CVA6 gitlink. The separate checkout is `rtl/third_party/hpdcache_cva6_pinned`. The existing `rtl/third_party/hpdcache` clone at `40d2897` is not the integration baseline. The modified flush engine reports origin/error and validates live response IDs; it is currently checked only through its typed lint harness. / Baseline cache đã khớp gitlink CVA6. Bản sửa flush engine lưu nguồn yêu cầu, báo lỗi và kiểm tra response ID; hiện mới lint qua harness có kiểu native thực.

HPDcache write-response metadata integration (2026-11-14): license-preserving copies of `hpdcache.sv`, `cva6_hpdcache_wrapper.sv`, `cva6_hpdcache_subsystem.sv`, and `cva6.sv` now route matched flush B completion, line address, origin, B error, and invalid-response status to the VLSIT CPU-tile boundary. Origins `00` (native flush/eviction) and `01` (native CMO) are connected. Origin `10` remains unused because the external probe allocator and native cache-array probe path are not implemented. The new path reports transport completion; it does not repair the native CMO controller's early dirty-state update or implement MESI/line locking. / Các bản sao có license hiện truyền B-response flush, line, origin, lỗi và response ID sai đến tile VLSIT. Nguồn `00` và `01` được nối; `10` chưa dùng vì chưa có bộ cấp phát probe và đường probe vào array. Đường mới chỉ báo hoàn tất transport; chưa sửa CMO cập nhật dirty sớm, chưa triển khai MESI/khóa line.

HPDcache MESI metadata foundation (2026-11-14, initial checkpoint): licensed copies added the `exclusive` tag-directory bit. The later ownership checkpoint above supersedes the initial always-Shared refill behavior. The Shared write-hit path now invalidates and replays through exclusive permission acquisition; direct in-place S-to-M upgrade is not implemented. The pinned `rtl/third_party/hpdcache` files remain unchanged. / Mốc metadata MESI HPDcache ban đầu: các bản sao có license thêm bit `exclusive` vào tag directory. Mốc ownership mới hơn đã thay hành vi refill ban đầu luôn Shared. Đường store-hit Shared hiện invalidate và replay để lấy quyền exclusive; chưa có nâng cấp S-to-M trực tiếp tại chỗ. Clone `rtl/third_party/hpdcache` được giữ nguyên.

CVFPU source is available separately at `rtl/third_party/cvfpu`, revision `3eb6afeab2cb33f7d8689222955d0171aeb3a801`. Production TOP lint now passes at 2/4 harts with 0 errors and 0 warnings; see `../reports/fence_i/README.md`. Earlier missing-source statements below describe historical runs. / Đã có source CVFPU riêng đúng revision; vẫn cần filelist/include đầy đủ và xử lý cảnh báo tool để lint CVA6 tích hợp. Giới hạn thiếu source phía dưới ghi lại lần chạy ban đầu.

## English

This directory contains CVA6 copies from revision `742dc82a0c706e0a3bfb98b709fd3ee06d50d12a`. The pristine originals remain under `rtl/third_party/cva6`; modified copies preserve the upstream notices/headers where present and add dated history naming Quan Nguyen and Codex - VLSI Technology page. The upstream `build_config_pkg.sv` has no file header, so its original content is retained and the modification history is added inside the package.

| Modified copy | Approved delta |
|---|---|
| `cva6/core/include/cv64a6_imafdc_sv39_hpdcache_wb_config_pkg.sv` | Disable CVXIF (`CVA6ConfigCvxifEn: 1 -> 0`) because no accelerator boundary is defined. |
| `cva6/core/include/build_config_pkg.sv` | Add `build_config_with_addr_regions`, deriving CVA6 cached-range fields from table class `00` and non-idempotent fields from class `10`; class `01` remains idempotent and uncached. The original package copy remains pristine under `rtl/third_party`. |
| `cva6/core/csr_regfile.sv` | Add supervisor software/timer interrupt inputs. OR external levels with software-writable MIP.SSIP/STIP for CSR readback and interrupt evaluation, while keeping external levels separate from stored software state. Gate SSIP with `RVS && SoftwareInterruptEn`; gate STIP with `RVS`. |
| `cva6/core/perf_counters.sv` | Export the 22 raw source event indicators used by the cluster PMU; leave native CSR counter selection and update behavior unchanged. |
| `cva6/core/cache_subsystem/cva6_hpdcache_wrapper.sv` | Export matched HPDcache flush B-response line/origin/error status and the 16 existing native HPDcache event indicators in Event_Map order, without changing their source logic. |
| `cva6/core/cache_subsystem/cva6_hpdcache_subsystem.sv` | Carry flush completion metadata and the native HPDcache PMU event vector from the wrapper to CVA6. |
| `cva6/core/cva6.sv` | Route supervisor interrupts, CVA6 and HPDcache PMU events, debug mode, and HPDcache flush completion metadata; drive unsupported-cache-profile event outputs low. |
| `hpdcache/rtl/src/hpdcache.sv` | Connect flush completion metadata, ownership request/grant, exact-line busy query, 16 lock slots, and directory E metadata to the controller/miss handler. |
| `hpdcache/rtl/src/hpdcache_ctrl.sv` | Detect locked request/victim lines, hold them in replay dependency, and report matching accepted Stage-0/active Stage-1 work to probe admission. |
| `hpdcache/rtl/src/hpdcache_ctrl_pe.sv` | Replay locked accesses and invalidate/replay clean Shared write-back hits before a write miss obtains M permission. |
| `hpdcache/rtl/src/hpdcache_rtab.sv` | Track each lock-dependent replay's physical line and release it after the lock clears. |
| `hpdcache/rtl/src/hpdcache_memctrl.sv` | Add the `exclusive` field to existing CMO and directory update records; expose the hit E bit to the controller. |
| `hpdcache/rtl/src/hpdcache_miss_handler.sv` | Request shared/exclusive permission before refill AR, validate grant ID/line/state, retain E/M metadata by memory ID, and convert denied grants into normal refill errors. |

Full CVA6 lint has not been completed. The CVFPU source is present, but an authoritative modified-source filelist and full tool run are still required. The PMA/tile syntax smoke uses a temporary CVA6 blackbox and is not a full core integration check.

## Tiếng Việt

Thư mục này chứa các bản sao CVA6 từ revision `742dc82a0c706e0a3bfb98b709fd3ee06d50d12a`. Source gốc nguyên vẹn nằm trong `rtl/third_party/cva6`; các bản sao sửa giữ thông báo/header upstream nếu có và thêm history ghi ngày cùng tên Quan Nguyen and Codex - VLSI Technology page. File upstream `build_config_pkg.sv` không có header riêng; nội dung gốc được giữ và history được thêm bên trong package.

| Bản sao đã sửa | Thay đổi được duyệt |
|---|---|
| `cva6/core/include/cv64a6_imafdc_sv39_hpdcache_wb_config_pkg.sv` | Tắt CVXIF (`CVA6ConfigCvxifEn: 1 -> 0`) vì cluster chưa có giao diện accelerator. |
| `cva6/core/include/build_config_pkg.sv` | Thêm `build_config_with_addr_regions`: class `00` tạo cached-region, class `10` tạo non-idempotent-region, class `01` giữ idempotent/uncached. Bản gốc vẫn nguyên vẹn trong `rtl/third_party`. |
| `cva6/core/csr_regfile.sv` | Thêm input ngắt software/timer supervisor. OR mức ngắt ngoài với MIP.SSIP/STIP software-writable khi đọc CSR và đánh giá ngắt; không trộn mức ngoài vào trạng thái software đã lưu. SSIP theo `RVS && SoftwareInterruptEn`; STIP theo `RVS`. |
| `cva6/core/perf_counters.sv` | Xuất 22 tín hiệu event nguồn cho PMU cluster; giữ nguyên lựa chọn và cập nhật counter CSR native. |
| `cva6/core/cache_subsystem/cva6_hpdcache_wrapper.sv` | Xuất line/origin/error của B-response flush đã khớp ID và 16 event HPDcache native theo Event_Map, không đổi logic phát event. |
| `cva6/core/cache_subsystem/cva6_hpdcache_subsystem.sv` | Truyền metadata hoàn tất flush và vector event PMU HPDcache native từ wrapper lên CVA6. |
| `cva6/core/cva6.sv` | Nối interrupt supervisor, event PMU CVA6/HPDcache, debug mode và metadata flush; profile cache không hỗ trợ trả event bằng 0. |
| `hpdcache/rtl/src/hpdcache.sv` | Nối metadata completion flush, ownership request/grant, query busy đúng line, 16 slot khóa và metadata E tới controller/miss handler. |
| `hpdcache/rtl/src/hpdcache_ctrl.sv` | Phát hiện request/victim bị khóa, giữ trong replay dependency và báo request Stage 0/Stage 1 cùng line cho probe admission. |
| `hpdcache/rtl/src/hpdcache_ctrl_pe.sv` | Replay truy cập bị khóa; invalidate/replay store-hit Shared sạch trước khi write miss xin quyền M. |
| `hpdcache/rtl/src/hpdcache_rtab.sv` | Theo dõi line vật lý của từng replay chờ lock và cho replay chạy lại sau khi nhả lock. |
| `hpdcache/rtl/src/hpdcache_memctrl.sv` | Thêm field `exclusive` vào update CMO/directory; xuất bit E của line hit cho controller. |
| `hpdcache/rtl/src/hpdcache_miss_handler.sv` | Xin shared/exclusive trước refill AR, kiểm tra grant ID/line/state, giữ metadata E/M theo memory ID và biến grant lỗi thành refill error thông thường. |

Chưa hoàn tất lint toàn bộ CVA6. Source CVFPU đã có, nhưng vẫn cần filelist chính xác cho các bản sao đã sửa và chạy full tool. Smoke lint PMA/tile dùng CVA6 blackbox tạm, không phải kiểm tra tích hợp core đầy đủ.

The modified-source lint filelists select licensed copies of `hpdcache_ctrl.sv`, `hpdcache_ctrl_pe.sv`, and `hpdcache_rtab.sv`. The controller checks PREPARE against accepted/active pipeline requests and parks accesses to locked lines or victims in RTAB. HPDcache also has tagged directory lookup, COMMIT-only state update, probe writeback through its flush path, ownership-before-refill, and Shared store-hit invalidate/replay. These paths are not functionally simulated together or connected to the CCU through a cluster core. / Filelist lint dùng các bản sao có license của `hpdcache_ctrl.sv`, `hpdcache_ctrl_pe.sv` và `hpdcache_rtab.sv`. Controller kiểm tra PREPARE với request pipeline đã nhận/đang hoạt động và đưa truy cập line/victim bị khóa vào RTAB. HPDcache còn có tra directory theo tag, chỉ ghi state ở COMMIT, writeback probe qua flush path, xin quyền trước refill và invalidate/replay store-hit Shared. Các đường này chưa được mô phỏng chức năng cùng nhau hoặc nối CCU qua cluster core.

## Latest cache query update / Cập nhật query cache

A license-preserving modified copy of `hpdcache_mshr.sv` keeps active MSHR line addresses in shadow registers and performs an exact-line comparison. The query also includes active refills and accepted Stage-0/valid Stage-1 lines. The tile adapter holds PREPARE until the query clears, then exports per-slot locks through the CPU tile and modified CVA6/HPDcache path. HPDcache parks same-line requests and misses selecting a locked victim in RTAB. Tagged directory lookup, probe transitions, ownership-before-refill, and Shared store-hit replay are present, but these paths have no combined end-to-end regression and are not connected through the missing cluster core. This is not a complete cluster MESI implementation.

Bản sao có license đã sửa của `hpdcache_mshr.sv` lưu địa chỉ line MSHR đang hoạt động trong shadow register và so sánh song song. Query còn xét refill đang chạy cùng line Stage 0 đã nhận/Stage 1 hợp lệ. Tile adapter chờ query rỗng trước khi nhận PREPARE, sau đó truyền lock theo slot qua CPU tile và CVA6/HPDcache đã sửa. HPDcache giữ request cùng line và miss chọn victim đang khóa trong dependency replay RTAB. Phần này chặn race ở admission và thay victim, nhưng chưa tra tag resident cho probe, phân xử array để phục vụ probe, trả dữ liệu owner dirty hay thực hiện chuyển trạng thái PREPARE/COMMIT/ABORT có tag. Chưa xem đây là MESI hoàn chỉnh.

## Validation / Kiểm tra

`python scripts/lint_modified_cva6_cache_path.py --top-module hpdcache_query_lint --timeout-seconds 180` passes the configured standalone HPDcache query lint with 0 errors and 131 warnings. The harness disables ECC and the scrubber, so ECC-product configuration is not checked. The configured `hpdcache_mesi_lint` harness timed out at 240 seconds with 0 reported errors and 586 warnings; this is not a pass. Full cluster TOP lint stops at missing `m_vlsit_riscv_cluster_core`. / Lệnh lint query HPDcache cấu hình độc lập pass với 0 lỗi và 131 cảnh báo. Harness tắt ECC/scrubber nên chưa kiểm tra cấu hình ECC của sản phẩm. Harness `hpdcache_mesi_lint` cấu hình timeout sau 240 giây với 0 lỗi được báo và 586 cảnh báo; đây chưa phải pass. Lint TOP cluster dừng do thiếu `m_vlsit_riscv_cluster_core`.
