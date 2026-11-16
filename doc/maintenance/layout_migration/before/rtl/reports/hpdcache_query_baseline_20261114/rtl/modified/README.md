# Modified upstream source / Bản sao nguồn upstream đã sửa

HPDcache integration baseline (2026-11-14): `hpdcache/rtl/src/hpdcache_flush.sv` derives from commit `e8f072e117ed3282950d4d1e975f462b173f0de0`, matching the selected CVA6 gitlink. The separate checkout is `rtl/third_party/hpdcache_cva6_pinned`. The existing `rtl/third_party/hpdcache` clone at `40d2897` is not the integration baseline. The modified flush engine reports origin/error and validates live response IDs; it is currently checked only through its typed lint harness. / Baseline cache đã khớp gitlink CVA6. Bản sửa flush engine lưu nguồn yêu cầu, báo lỗi và kiểm tra response ID; hiện mới lint qua harness có kiểu native thực.

HPDcache write-response metadata integration (2026-11-14): license-preserving copies of `hpdcache.sv`, `cva6_hpdcache_wrapper.sv`, `cva6_hpdcache_subsystem.sv`, and `cva6.sv` now route matched flush B completion, line address, origin, B error, and invalid-response status to the VLSIT CPU-tile boundary. Origins `00` (native flush/eviction) and `01` (native CMO) are connected. Origin `10` remains unused because the external probe allocator and native cache-array probe path are not implemented. The new path reports transport completion; it does not repair the native CMO controller's early dirty-state update or implement MESI/line locking. / Các bản sao có license hiện truyền B-response flush, line, origin, lỗi và response ID sai đến tile VLSIT. Nguồn `00` và `01` được nối; `10` chưa dùng vì chưa có bộ cấp phát probe và đường probe vào array. Đường mới chỉ báo hoàn tất transport; chưa sửa CMO cập nhật dirty sớm, chưa triển khai MESI/khóa line.

HPDcache MESI metadata foundation (2026-11-14): licensed copies of `hpdcache.sv`, `hpdcache_memctrl.sv`, and `hpdcache_miss_handler.sv` add an `exclusive` tag-directory bit. Existing non-coherent refills and CMO/directory updates initialize it to zero, so the new bit currently represents Shared for clean lines and does not enable E/M ownership transitions. The pinned `rtl/third_party/hpdcache` files remain unchanged. / Nền metadata MESI HPDcache: các bản sao có license thêm bit `exclusive` vào tag directory. Refill và update hiện tại đặt bit này bằng 0; chưa có chuyển trạng thái E/M, probe hay arbitration array mới. Source đã pin trong `rtl/third_party` được giữ nguyên.

CVFPU source is available separately at `rtl/third_party/cvfpu`, revision `3eb6afeab2cb33f7d8689222955d0171aeb3a801`. Full CVA6 lint now requires a complete source/include map and resolution of tool warnings; the earlier missing-source limitation below records the original run. / Đã có source CVFPU riêng đúng revision; vẫn cần filelist/include đầy đủ và xử lý cảnh báo tool để lint CVA6 tích hợp. Giới hạn thiếu source phía dưới ghi lại lần chạy ban đầu.

## English

This directory contains CVA6 copies from revision `742dc82a0c706e0a3bfb98b709fd3ee06d50d12a`. The pristine originals remain under `rtl/third_party/cva6`; modified copies preserve the upstream notices/headers where present and add dated history naming Quan Nguyen and Codex - VLSI Technology page. The upstream `build_config_pkg.sv` has no file header, so its original content is retained and the modification history is added inside the package.

| Modified copy | Approved delta |
|---|---|
| `cva6/core/include/cv64a6_imafdc_sv39_hpdcache_wb_config_pkg.sv` | Disable CVXIF (`CVA6ConfigCvxifEn: 1 -> 0`) because no accelerator boundary is defined. |
| `cva6/core/include/build_config_pkg.sv` | Add `build_config_with_addr_regions`, deriving CVA6 cached-range fields from table class `00` and non-idempotent fields from class `10`; class `01` remains idempotent and uncached. The original package copy remains pristine under `rtl/third_party`. |
| `cva6/core/csr_regfile.sv` | Add supervisor software/timer interrupt inputs. OR external levels with software-writable MIP.SSIP/STIP for CSR readback and interrupt evaluation, while keeping external levels separate from stored software state. Gate SSIP with `RVS && SoftwareInterruptEn`; gate STIP with `RVS`. |
| `cva6/core/perf_counters.sv` | Export the 22 raw source event indicators used by the cluster PMU; leave native CSR counter selection and update behavior unchanged. |
| `cva6/core/cache_subsystem/cva6_hpdcache_wrapper.sv` | Export matched HPDcache flush B-response line/origin/error status. |
| `cva6/core/cache_subsystem/cva6_hpdcache_subsystem.sv` | Carry flush completion metadata from the HPDcache wrapper to CVA6. |
| `cva6/core/cva6.sv` | Route supervisor interrupts, PMU events, debug mode, and HPDcache flush completion metadata; drive unsupported-cache-profile metadata low. |
| `hpdcache/rtl/src/hpdcache.sv` | Connect modified flush completion metadata to CVA6; add the local `exclusive` directory bit. |
| `hpdcache/rtl/src/hpdcache_memctrl.sv` | Add the `exclusive` field to existing CMO and directory update records; initialize legacy updates to zero. |
| `hpdcache/rtl/src/hpdcache_miss_handler.sv` | Initialize existing refill entries with `exclusive=0` (Shared). |

Full CVA6 lint has not been completed. The CVFPU source is present, but an authoritative modified-source filelist and full tool run are still required. The PMA/tile syntax smoke uses a temporary CVA6 blackbox and is not a full core integration check.

## Tiếng Việt

Thư mục này chứa các bản sao CVA6 từ revision `742dc82a0c706e0a3bfb98b709fd3ee06d50d12a`. Source gốc nguyên vẹn nằm trong `rtl/third_party/cva6`; các bản sao sửa giữ thông báo/header upstream nếu có và thêm history ghi ngày cùng tên Quan Nguyen and Codex - VLSI Technology page. File upstream `build_config_pkg.sv` không có header riêng; nội dung gốc được giữ và history được thêm bên trong package.

| Bản sao đã sửa | Thay đổi được duyệt |
|---|---|
| `cva6/core/include/cv64a6_imafdc_sv39_hpdcache_wb_config_pkg.sv` | Tắt CVXIF (`CVA6ConfigCvxifEn: 1 -> 0`) vì cluster chưa có giao diện accelerator. |
| `cva6/core/include/build_config_pkg.sv` | Thêm `build_config_with_addr_regions`: class `00` tạo cached-region, class `10` tạo non-idempotent-region, class `01` giữ idempotent/uncached. Bản gốc vẫn nguyên vẹn trong `rtl/third_party`. |
| `cva6/core/csr_regfile.sv` | Thêm input ngắt software/timer supervisor. OR mức ngắt ngoài với MIP.SSIP/STIP software-writable khi đọc CSR và đánh giá ngắt; không trộn mức ngoài vào trạng thái software đã lưu. SSIP theo `RVS && SoftwareInterruptEn`; STIP theo `RVS`. |
| `cva6/core/perf_counters.sv` | Xuất 22 tín hiệu event nguồn cho PMU cluster; giữ nguyên lựa chọn và cập nhật counter CSR native. |
| `cva6/core/cache_subsystem/cva6_hpdcache_wrapper.sv` | Xuất line/origin/error của B-response flush đã khớp ID. |
| `cva6/core/cache_subsystem/cva6_hpdcache_subsystem.sv` | Truyền metadata hoàn tất flush từ wrapper HPDcache lên CVA6. |
| `cva6/core/cva6.sv` | Truyền interrupt supervisor, PMU, debug mode và metadata flush; profile cache không hỗ trợ trả metadata bằng 0. |
| `hpdcache/rtl/src/hpdcache.sv` | Nối metadata completion flush đã sửa tới CVA6; thêm bit directory `exclusive`. |
| `hpdcache/rtl/src/hpdcache_memctrl.sv` | Thêm field `exclusive` vào update CMO/directory; cập nhật cũ đặt 0. |
| `hpdcache/rtl/src/hpdcache_miss_handler.sv` | Khởi tạo entry refill hiện có với `exclusive=0` (Shared). |

Chưa hoàn tất lint toàn bộ CVA6. Source CVFPU đã có, nhưng vẫn cần filelist chính xác cho các bản sao đã sửa và chạy full tool. Smoke lint PMA/tile dùng CVA6 blackbox tạm, không phải kiểm tra tích hợp core đầy đủ.

The modified-source lint filelist now substitutes the three MESI-metadata copies above. This metadata foundation is not a coherent cache implementation: CCU permission-before-refill, probe scheduling, array arbitration, MESI state transitions, and dirty-owner writeback are still pending. / Filelist lint đã thay bằng ba bản sao metadata MESI ở trên. Đây chưa phải cache coherent: xin quyền CCU trước refill, probe, arbitration array, chuyển MESI và writeback từ owner vẫn chưa triển khai.
