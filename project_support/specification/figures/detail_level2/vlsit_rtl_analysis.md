# RISC-V cluster detail-diagram analysis / Phân tích sơ đồ chi tiết cluster RISC-V

## Scope and evidence / Phạm vi và căn cứ

These pages expand the approved cluster specification by one architectural level. No RTL was inspected or claimed as implemented. Names and hierarchy are design proposals; upstream candidates require pinned commits and interface checks.
Các trang mở rộng đặc tả cluster thêm một cấp kiến trúc. Chưa phân tích hay khẳng định RTL đã được triển khai. Tên và hierarchy là đề xuất; nguồn upstream cần chốt commit và kiểm tra giao diện.

The diagrams show defined logical interfaces only. Internal pin names, widths, timing, and ACE subsets remain open where the HDS marks them TBD. Dashed blocks mean proposed, not integrated RTL.
Sơ đồ chỉ thể hiện giao diện logic đã xác định. Tên pin, độ rộng, timing nội bộ và subset ACE vẫn để mở ở nơi HDS đánh dấu TBD. Khối nét đứt là đề xuất, chưa phải RTL tích hợp.

## Status key / Chú giải trạng thái

| Status | Meaning / Nghĩa |
|---|---|
| REUSE | Unchanged upstream RTL after source, config, and license checks. / Dùng RTL upstream nguyên trạng sau khi kiểm tra nguồn, cấu hình và license. |
| REUSE* | Candidate pending compatibility checks. / Khối dự kiến tái sử dụng, chờ kiểm tra tương thích. |
| MODIFY | Adapt upstream logic, add a wrapper, or bind ASIC memory. / Điều chỉnh logic upstream, viết wrapper hoặc gắn SRAM ASIC. |
| NEW | New VLSIT-owned RTL. / RTL mới do VLSIT thiết kế. |
| GENERATED | CSR RTL from the reviewed workbook and pinned generator. / RTL CSR sinh từ workbook đã duyệt và generator đã chốt. |
| EXTERNAL | Logic supplied outside the cluster by the SoC. / Logic do SoC cung cấp bên ngoài cluster. |

## Page inventory / Danh sách sơ đồ

| Page | Parent block / Khối cha | Detail / Nội dung |
|---|---|---|
| 01_TILE | m_vlsit_riscv_cpu_tile | CPU tile internals |
| 02_COHERENCE | m_vlsit_riscv_coh_fabric | Coherence and MMIO routing |
| 03_LLC | axi_llc | Shared LLC internal datapath |
| 04_CONTROL | m_vlsit_riscv_axil_decode | Control and CSR routing |
| 05_PMU | m_vlsit_riscv_pmu | Cluster PMU internals |
| 06_DEBUG | m_vlsit_riscv_debug_router | Per-hart debug routing |
| 07_ACE | m_vlsit_riscv_ace_proxy | ACE external coherence boundary |

## Block inventory / Danh sách khối

| Page | Planned instance / Instance dự kiến | Source module / Module nguồn | Status/source / Trạng thái/nguồn | Function description / Mô tả chức năng |
|---|---|---|---|---|
| 01_TILE | u_cva6 | cva6 | MODIFY | OpenHW CVA6 integration copy | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |
| 01_TILE | u_cva6_hpdcache_subsystem | cva6_hpdcache_subsystem | MODIFY | OpenHW CVA6 | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |
| 01_TILE | u_cva6_icache | cva6_icache | REUSE | OpenHW CVA6 | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |
| 01_TILE | u_cva6_hpdcache_wrapper | cva6_hpdcache_wrapper | MODIFY | OpenHW CVA6 | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |
| 01_TILE | u_hpdcache | hpdcache | MODIFY | OpenHW HPDcache licensed copy | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |
| 01_TILE | u_vlsit_riscv_tile_coh_adapter | m_vlsit_riscv_tile_coh_adapter | NEW | VLSIT | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |
| 02_COHERENCE | u_vlsit_riscv_tile_coh_adapter | m_vlsit_riscv_tile_coh_adapter | NEW | VLSIT | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |
| 02_COHERENCE | u_vlsit_riscv_coh_fabric | m_vlsit_riscv_coh_fabric | NEW | VLSIT; Culsans is reference only | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |
| 02_COHERENCE | u_vlsit_riscv_coh_txn_table | m_vlsit_riscv_coh_txn_table | NEW | VLSIT | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |
| 02_COHERENCE | u_vlsit_riscv_sharer_directory | m_vlsit_riscv_sharer_directory | NEW | VLSIT | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |
| 02_COHERENCE | u_vlsit_riscv_probe_scheduler | m_vlsit_riscv_probe_scheduler | NEW | VLSIT | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |
| 02_COHERENCE | u_axi_mux | axi_mux | REUSE candidate | PULP AXI | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |
| 02_COHERENCE | u_vlsit_riscv_device_classifier | m_vlsit_riscv_device_classifier | NEW | VLSIT | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |
| 02_COHERENCE | u_axi_demux | axi_demux | REUSE candidate | PULP AXI | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |
| 02_COHERENCE | u_vlsit_riscv_axi_mmio | m_vlsit_riscv_axi_mmio | NEW | VLSIT wrapper | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |
| 03_LLC | u_axi_llc_chan_splitter | axi_llc_chan_splitter | REUSE | PULP axi_llc | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |
| 03_LLC | u_axi_llc_hit_miss | axi_llc_hit_miss | REUSE | PULP axi_llc | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |
| 03_LLC | u_axi_llc_tag_store | axi_llc_tag_store | REUSE candidate | PULP axi_llc | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |
| 03_LLC | u_axi_llc_rw_units | axi_llc_read_unit / axi_llc_write_unit | REUSE | PULP axi_llc | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |
| 03_LLC | u_axi_llc_miss_units | axi_llc_evict_unit / axi_llc_refill_unit | REUSE | PULP axi_llc | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |
| 03_LLC | u_axi_llc_data_ways | LLC data-way storage | MODIFY | SRAM macro integration | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |
| 03_LLC | u_axi_llc_config | axi_llc_config | MODIFY | PULP axi_llc wrapper policy | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |
| 04_CONTROL | u_axi_lite_demux | axi_lite_demux | REUSE candidate | PULP AXI | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |
| 04_CONTROL | u_vlsit_riscv_axil_decode | m_vlsit_riscv_axil_decode | NEW | VLSIT | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |
| 04_CONTROL | u_vlsit_cpucl_csr | m_vlsit_cpucl_csr | GENERATED | CSR_Generation.py v3.4 (commit c40f319) | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |
| 04_CONTROL | u_axi_llc_cfg | axi_llc_config wrapper | MODIFY | PULP axi_llc wrapper policy | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |
| 04_CONTROL | u_vlsit_riscv_pmu | m_vlsit_riscv_pmu | NEW | VLSIT | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |
| 05_PMU | u_vlsit_pmu_hart_evt | m_vlsit_pmu_hart_evt | NEW | VLSIT | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |
| 05_PMU | u_vlsit_pmu_cluster_evt | m_vlsit_pmu_cluster_evt | NEW | VLSIT | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |
| 05_PMU | u_vlsit_pmu_event_select | m_vlsit_pmu_event_select | NEW | VLSIT | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |
| 05_PMU | u_vlsit_pmu_aggregate | m_vlsit_pmu_aggregate | NEW | VLSIT | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |
| 05_PMU | u_vlsit_pmu_counter_bank | m_vlsit_pmu_counter_bank | NEW | VLSIT | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |
| 05_PMU | u_vlsit_pmu_snapshot | m_vlsit_pmu_snapshot | NEW | VLSIT | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |
| 05_PMU | u_vlsit_pmu_irq | m_vlsit_pmu_irq | NEW | VLSIT | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |
| 06_DEBUG | u_vlsit_riscv_debug_router | m_vlsit_riscv_debug_router | NEW | VLSIT | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |
| 06_DEBUG | u_vlsit_riscv_cpu_tile_0.._3 | m_vlsit_riscv_cpu_tile | NEW | VLSIT | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |
| 07_ACE | u_vlsit_axi_llc | m_vlsit_axi_llc | MODIFY | PULP axi_llc | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |
| 07_ACE | u_vlsit_riscv_ace_proxy | m_vlsit_riscv_ace_proxy | NEW | VLSIT | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |
| 07_ACE | u_vlsit_riscv_ace_probe_router | m_vlsit_riscv_ace_probe_router | NEW | VLSIT | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |
| 07_ACE | u_vlsit_riscv_coh_fabric | m_vlsit_riscv_coh_fabric | MODIFY | Culsans candidate | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |

## Interface evidence / Căn cứ giao diện

The draw.io interface tables group design-level paths. External AXI/ACE ports are defined in HDS Section 6; internal ports and timing are not yet tied to pinned RTL. ACE policy, LLC-to-ACE mapping, Culsans compatibility, and SRAM binding remain open.
Bảng giao diện draw.io nhóm các đường logic theo thiết kế. Port AXI/ACE bên ngoài nằm ở Mục 6 HDS; port và timing nội bộ chưa gắn với RTL đã chốt. Chính sách ACE, ánh xạ LLC–ACE, tương thích Culsans và gắn SRAM vẫn còn mở.

## Source and integration limits / Nguồn và giới hạn tích hợp

- OpenHW CVA6/HPDcache are reuse baselines; audit exact files and licenses at pinned revisions. / CVA6/HPDcache OpenHW là baseline tái sử dụng; kiểm tra file và license ở revision đã chốt.
- Culsans is an adaptation source, not proven compatible with this upstream CVA6 + HPDcache configuration. / Culsans là nguồn để điều chỉnh, chưa chứng minh tương thích với cấu hình CVA6 + HPDcache upstream này.
- PULP axi_llc functions are reuse candidates; VLSIT fixes policy/geometry and binds ASIC SRAM. / Chức năng `axi_llc` PULP là ứng viên tái sử dụng; VLSIT chốt chính sách/geometry và gắn SRAM ASIC.
- PULP AXI/ACE primitives require version, ID, topology, and feature checks before reuse. / Primitive AXI/ACE PULP cần kiểm tra version, ID, topology và tính năng trước khi dùng.
- Cluster tops, adapters, PMU, and debug routing are VLSIT-owned design work. / Top, adapter, PMU và định tuyến debug là phần VLSIT cần thiết kế.
- CSR RTL is generated; the reviewed workbook defines software-visible fields. / RTL CSR được sinh; workbook đã duyệt định nghĩa các trường software nhìn thấy.

## Diagram validation / Kiểm tra sơ đồ

The library check verifies template provenance; the geometry checker verifies placement and routing constraints. Neither proves RTL existence, protocol compliance, or functional correctness. / Kiểm tra thư viện xác nhận nguồn template; geometry checker kiểm tra bố trí và đường nối. Cả hai không chứng minh RTL tồn tại, tuân thủ protocol hay đúng chức năng.

## Automated validation results / Kết quả kiểm tra tự động

Tool output (English): / Kết quả tool (tiếng Anh):

```text
01_TILE: SCORE gapH=110 gapV=110 seed=2 failed=0 unplaced=0 issues=0 bend_gt5=0 bend5=0 bends=0 cross_total=0 cross_max_per_connector=0 frame=1050x610
02_COHERENCE: SCORE gapH=110 gapV=110 seed=2 failed=0 unplaced=0 issues=0 bend_gt5=0 bend5=0 bends=18 cross_total=4 cross_max_per_connector=2 frame=1390x800
03_LLC: SCORE gapH=110 gapV=110 seed=2 failed=0 unplaced=0 issues=0 bend_gt5=0 bend5=0 bends=4 cross_total=1 cross_max_per_connector=1 frame=1520x610
04_CONTROL: SCORE gapH=110 gapV=110 seed=2 failed=0 unplaced=0 issues=0 bend_gt5=0 bend5=0 bends=8 cross_total=0 cross_max_per_connector=0 frame=1020x420
05_PMU: SCORE gapH=110 gapV=110 seed=2 failed=0 unplaced=0 issues=0 bend_gt5=0 bend5=0 bends=0 cross_total=0 cross_max_per_connector=0 frame=790x800
06_DEBUG: SCORE gapH=110 gapV=110 seed=2 failed=0 unplaced=0 issues=0 bend_gt5=0 bend5=0 bends=0 cross_total=0 cross_max_per_connector=0 frame=410x420
07_ACE: SCORE gapH=110 gapV=110 seed=2 failed=0 unplaced=0 issues=0 bend_gt5=0 bend5=0 bends=8 cross_total=0 cross_max_per_connector=0 frame=870x420
PASS: 190 library-derived cells across 7 pages. RTL semantics and visual layout were not checked.

[01_TILE] frame i1__2 1050x610 ratio 1.72
[01_TILE] shapes: 6 blocks, 13 labels, 0 pads; connectors: 10; physical crossings: 0; bends: 0 bends=10; findings: 0
[02_COHERENCE] frame i1__2 1390x800 ratio 1.74
[02_COHERENCE] shapes: 9 blocks, 15 labels, 0 pads; connectors: 12; physical crossings: 4; bends: 0 bends=7, 2 bends=1, 4 bends=4; findings: 0
[03_LLC] frame i1__2 1520x610 ratio 2.49
[03_LLC] shapes: 7 blocks, 14 labels, 0 pads; connectors: 11; physical crossings: 1; bends: 0 bends=10, 4 bends=1; findings: 0
[04_CONTROL] frame i1__2 1020x420 ratio 2.43
[04_CONTROL] shapes: 5 blocks, 10 labels, 0 pads; connectors: 7; physical crossings: 0; bends: 0 bends=5, 4 bends=2; findings: 0
[05_PMU] frame i1__2 790x800 ratio 0.99
[05_PMU] shapes: 7 blocks, 13 labels, 0 pads; connectors: 10; physical crossings: 0; bends: 0 bends=10; findings: 0
[06_DEBUG] frame i1__2 410x420 ratio 0.98
[06_DEBUG] shapes: 2 blocks, 7 labels, 0 pads; connectors: 4; physical crossings: 0; bends: 0 bends=4; findings: 0
[07_ACE] frame i1__2 870x420 ratio 2.07
[07_ACE] shapes: 4 blocks, 10 labels, 0 pads; connectors: 7; physical crossings: 0; bends: 0 bends=5, 4 bends=2; findings: 0
total findings: 0

```
