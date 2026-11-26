# Changed production RTL / RTL production đã sửa

| File | Change / Thay đổi |
|---|---|
| [rtl/modified/axi_llc/src/axi_llc_hit_miss.sv](../../../rtl/modified/axi_llc/src/axi_llc_hit_miss.sv) | Forward refill completion/error to tag store / Truyền completion/lỗi refill tới tag store. |
| [rtl/modified/axi_llc/src/axi_llc_top.sv](../../../rtl/modified/axi_llc/src/axi_llc_top.sv) | Expose native refill completion metadata / Nối metadata completion refill native. |
| [rtl/modified/axi_llc/src/eviction_refill/axi_llc_r_master.sv](../../../rtl/modified/axi_llc/src/eviction_refill/axi_llc_r_master.sv) | Aggregate all-beat RRESP errors and hold descriptor / Gộp lỗi RRESP các beat và giữ descriptor. |
| [rtl/modified/axi_llc/src/hit_miss_detect/axi_llc_tag_store.sv](../../../rtl/modified/axi_llc/src/hit_miss_detect/axi_llc_tag_store.sv) | Reserve all misses; commit tags after refill and victim B success / Giữ miss, chỉ cập nhật tag sau refill và B thành công. |
| [rtl/modified/cva6/core/cache_subsystem/cva6_hpdcache_if_adapter.sv](../../../rtl/modified/cva6/core/cache_subsystem/cva6_hpdcache_if_adapter.sv) | Register atomic error with native response / Chốt lỗi cùng response atomic. |
| [rtl/modified/cva6/core/cache_subsystem/cva6_hpdcache_subsystem.sv](../../../rtl/modified/cva6/core/cache_subsystem/cva6_hpdcache_subsystem.sv) | Route atomic error / Nối lỗi atomic. |
| [rtl/modified/cva6/core/cache_subsystem/cva6_hpdcache_wrapper.sv](../../../rtl/modified/cva6/core/cache_subsystem/cva6_hpdcache_wrapper.sv) | Connect store-adapter atomic error / Nối lỗi từ adapter store. |
| [rtl/modified/cva6/core/commit_stage.sv](../../../rtl/modified/cva6/core/commit_stage.sv) | Precise cause 5/7; block faulty retire/GPR and defer IRQ/debug / Trap precise, chặn retire/GPR lỗi và hoãn IRQ/debug. |
| [rtl/modified/cva6/core/cva6.sv](../../../rtl/modified/cva6/core/cva6.sv) | Track active atomic and connect error to commit / Theo dõi atomic đang chạy, nối lỗi tới commit. |
| [rtl/modified/cva6/core/store_unit.sv](../../../rtl/modified/cva6/core/store_unit.sv) | Preserve original atomic VA for trap tval / Giữ địa chỉ ảo gốc cho trap tval. |
| [rtl/modified/hpdcache/rtl/src/hpdcache.sv](../../../rtl/modified/hpdcache/rtl/src/hpdcache.sv) | Atomic response guard and native probe array admission / Guard atomic và phân xử admission array probe. |
| [rtl/modified/hpdcache/rtl/src/hpdcache_ctrl.sv](../../../rtl/modified/hpdcache/rtl/src/hpdcache_ctrl.sv) | Connect shared-upgrade and reservation metadata / Nối metadata upgrade Shared và reservation. |
| [rtl/modified/hpdcache/rtl/src/hpdcache_ctrl_pe.sv](../../../rtl/modified/hpdcache/rtl/src/hpdcache_ctrl_pe.sv) | L1 atomics, shared LR, retained-S upgrades and failed-SC replay / Atomic L1, LR shared, upgrade giữ S và replay SC. |
| [rtl/modified/hpdcache/rtl/src/hpdcache_miss_handler.sv](../../../rtl/modified/hpdcache/rtl/src/hpdcache_miss_handler.sv) | Preparatory refill; allow old-S probes before grant / Refill chuẩn bị, cho probe bản S cũ trước grant. |
| [rtl/modified/hpdcache_cva6_pinned/rtl/src/hpdcache_uncached.sv](../../../rtl/modified/hpdcache_cva6_pinned/rtl/src/hpdcache_uncached.sv) | Local atomic arithmetic/LR-SC; reservation/error lifecycle / Atomic cục bộ và vòng đời reservation/lỗi. |
| [rtl/vlsit/m_vlsit_riscv_cache_line_locks.sv](../../../rtl/vlsit/m_vlsit_riscv_cache_line_locks.sv) | Registered lock vectors remove combinational admission loop / Vector lock đăng ký loại vòng tổ hợp admission. |
| [rtl/vlsit/m_vlsit_riscv_coh_fabric.sv](../../../rtl/vlsit/m_vlsit_riscv_coh_fabric.sv) | Qualify directory handshake with selected tag / Kiểm tra tag được chọn tại handshake directory. |
| [rtl/vlsit/m_vlsit_riscv_probe_scheduler.sv](../../../rtl/vlsit/m_vlsit_riscv_probe_scheduler.sv) | Pin service to phase owner until terminal response / Giữ service đúng owner đến response cuối. |
| [rtl/vlsit/m_vlsit_riscv_tile_coh_adapter.sv](../../../rtl/vlsit/m_vlsit_riscv_tile_coh_adapter.sv) | Acquire lock only on admitted cache PREPARE / Chỉ lấy lock khi cache nhận PREPARE. |

Diff size: +400/−79 lines across 19 production RTL files; baseline 16188 lines. Churn `(added+removed)/baseline` = 2.96%. Includes comments/formatting; not a hardware-area estimate. / Kích thước diff gồm comment/định dạng, không phải diện tích phần cứng.
