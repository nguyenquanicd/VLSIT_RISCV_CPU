# VLSIT RISC-V CPU Cluster & Tensor Coprocessor

This repository contains a configurable 2/4-CPU RISC-V cluster in a 64-bit and a 32-bit version, and the design specification for a tensor coprocessor. Start with the status table below, then the specifications and register workbooks; diagrams, FSMs and waveforms are linked beside them.

Repository gồm cluster RISC-V cấu hình 2/4 CPU với hai phiên bản 64-bit và 32-bit, cùng đặc tả tensor coprocessor. Bắt đầu từ bảng trạng thái bên dưới, sau đó là specification và workbook thanh ghi; các liên kết sơ đồ, FSM và waveform nằm cạnh từng thiết kế.

[Documentation index / Mục lục tài liệu](doc/README.md) · [Project layout / Cấu trúc dự án](doc/PROJECT_LAYOUT.md) · [Supporting records / Hồ sơ hỗ trợ](project_support/README.md)

## Project status / Trạng thái dự án

Last updated: **2026-11-27**. Every design is a **draft**; none is signed off for tapeout.

Cập nhật lần cuối: **2026-11-27**. Mọi thiết kế đều là **bản nháp**, chưa có thiết kế nào được signoff để tapeout.

### Cluster versions / Các phiên bản cluster

| Version / Phiên bản | Core / Lõi | Harts | Specification / Đặc tả | RTL and filelist / RTL và filelist |
|---|---|---|---|---|
| **64-bit cluster** — main design / **Cluster 64-bit** — thiết kế chính | CVA6 `cv64a6_imafdc_sv39_hpdcache_wb`: RV64IMAFDC, Sv39, write-back HPDcache with MESI coherence / HPDcache write-back có coherence MESI | 2 or 4 (`PARA_CPU_NUM`, default 4) / 2 hoặc 4 (mặc định 4) | [Cluster HDS](doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) **rev 0.39** · [Bản tiếng Việt](doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS_vi.md) | [`rtl/non_coherence_cluster/`](rtl/non_coherence_cluster/) + [`rtl/common/`](rtl/common/) · [`filelist.f`](rtl/non_coherence_cluster/filelist.f) |
| **32-bit cluster** — RV32 profile / **Cluster 32-bit** — profile RV32 | CVA6 `cv32a6_imafc_sv32_hpdcache_wb`: RV32IMAFC (F without D / F không có D), Sv32, PLEN 34. Same cluster, ports and CSR map as the 64-bit version / Cùng cluster, cổng và bản đồ CSR với bản 64-bit | 2 or 4 (default 4) / 2 hoặc 4 (mặc định 4) | [RV32 HDS](doc/specification_32/VLSIT_RISCV32_DUAL_QUAD_CPU_CLUSTER_HDS.md) **rev 0.4** · [Tóm tắt tiếng Việt](doc/specification_32/README.md) | [`rtl/rv32_profile/`](rtl/rv32_profile/) (core package, tile adapter, FPU divider copy / package core, tile chuyển độ rộng, bản sao bộ chia FPU) + [`rtl/common/`](rtl/common/) · [`filelist_rv32.f`](rtl/rv32_profile/filelist_rv32.f) |
| External ACE coherence profile / Profile coherence ACE bên ngoài | — | — | Reserved / Dự phòng | [`rtl/coherence_cluster/`](rtl/coherence_cluster/): **not implemented / chưa triển khai** |

Both versions share one AXI TOP (`m_vlsit_riscv_cluster_axi_top`): AXI4-Lite control, AXI4 memory with the PULP AWATOP extension, non-coherent AXI4 MMIO, and timing profiles 0/1/2 (`PARA_TIMING_PROFILE`).

Hai phiên bản dùng chung một TOP AXI (`m_vlsit_riscv_cluster_axi_top`): điều khiển AXI4-Lite, bộ nhớ AXI4 mở rộng PULP AWATOP, MMIO AXI4 không coherence, và timing profile 0/1/2 (`PARA_TIMING_PROFILE`).

### Status by design / Trạng thái từng thiết kế

| Check / Hạng mục | 64-bit cluster / Cluster 64-bit | 32-bit cluster / Cluster 32-bit | Tensor coprocessor |
|---|---|---|---|
| Specification / Đặc tả | Draft rev 0.39 / Nháp rev 0.39 | Draft rev 0.4 / Nháp rev 0.4 | [Draft rev 0.1 / Nháp rev 0.1](doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md) |
| RTL | Complete for the AXI profile / Đủ cho profile AXI | Complete: 64-bit RTL plus RV32 adaptations / Đủ: RTL 64-bit cộng phần chuyển đổi RV32 | **None / Chưa có** |
| Lint (Verilator 5.053) | 0 errors, 0 warnings; 2/4 harts, profiles 0 and 2 / 0 lỗi, 0 cảnh báo; 2/4 hart, profile 0 và 2 | 0 errors, 0 warnings; 2/4 harts, profiles 0/1/2, with 68 documented upstream waivers / 0 lỗi, 0 cảnh báo; 2/4 hart, profile 0/1/2, có 68 waiver upstream đã ghi lý do | — |
| Directed simulation / Mô phỏng directed | **PASS**: atomic, CMO, FENCE.I and directory-holder suites (36 runs, 2/4 harts); RV32 testbench in 64-bit mode TC-04 to 07, 09, 10 / suite atomic, CMO, FENCE.I, directory holder (36 lần chạy, 2/4 hart); testbench RV32 ở chế độ 64-bit TC-04 đến 07, 09, 10 | **PASS**: [TC-01 to TC-10](verification/rv32_profile/REPORT.md), 2 and 4 harts, profile 0, with fault qualification / TC-01 đến TC-10, 2 và 4 hart, profile 0, có kiểm tra lỗi cố ý | — |
| Not yet verified / Chưa kiểm chứng | Random coherence, PMU, IRQ/debug/WFI, MMIO/uncached ATOP (OPEN-DV) / Coherence ngẫu nhiên, PMU, IRQ/debug/WFI, MMIO/ATOP uncached | PMU (TC-11), profiles 1/2 in simulation (TC-12), constrained-random test / PMU, mô phỏng profile 1/2, test ngẫu nhiên có ràng buộc | Everything / Toàn bộ |
| Timing | One DC run only (GF55, T = 1.04 ns): longest path 3.40 ns, WNS -2.47 ns, optimistic setup. No accepted clock period; planning value 3.5 ns (PD-01) / Mới có một lần chạy DC: đường dài nhất 3,40 ns, WNS -2,47 ns, điều kiện lạc quan. Chưa có chu kỳ clock được chấp nhận; giá trị lập kế hoạch 3,5 ns | Not run (OPEN-X32-PPA) / Chưa chạy | — |
| Software / Phần mềm | No Linux or RTOS image selected / Chưa chọn image Linux hay RTOS | No RV32 OS selected (OPEN-X32-OS) / Chưa chọn OS RV32 | — |
| Signoff (synthesis, STA, PPA, DFT, SoC) | **Not done / Chưa** | **Not done / Chưa** | **Not done / Chưa** |

Open items and release blockers / Mục còn mở và điểm chặn phát hành: [64-bit HDS Section 20.1](doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md#201-current-unresolved-contracts-and-release-blockers) · [RV32 HDS Section 20.1](doc/specification_32/VLSIT_RISCV32_DUAL_QUAD_CPU_CLUSTER_HDS.md) · [Tensor HDS Section 20](doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md#20-assumptions-dependencies-and-decisions).

### Recent changes / Thay đổi gần đây

| Date / Ngày | Change / Thay đổi | Details / Chi tiết |
|---|---|---|
| 2026-11-27 | Three coherence deadlock fixes merged into `rtl/common/`, used by both versions / Merge ba bản sửa deadlock coherence vào `rtl/common/`, dùng cho cả hai phiên bản | [Section below / Mục bên dưới](#coherence-deadlock-fixes-2026-11-27--sửa-lỗi-deadlock-coherence) · HDS 14.7, DEC-046, DEC-047 |
| 2026-11-26 | 32-bit version: RTL and testbench TC-01 to TC-10; FPU divider operands NaN-boxed for FLEN=32 (DEC-106) / Phiên bản 32-bit: RTL và testbench TC-01 đến TC-10; toán hạng bộ chia FPU được NaN-box khi FLEN=32 | [RV32 HDS 14.5](doc/specification_32/VLSIT_RISCV32_DUAL_QUAD_CPU_CLUSTER_HDS.md) · [Report / Báo cáo](verification/rv32_profile/REPORT.md) |

## 1. Cluster 2/4 CPU (64-bit and 32-bit versions / phiên bản 64-bit và 32-bit)

The cluster uses CVA6 harts, private L1 caches with coherent D-caches, a shared LLC, PMU and per-hart debug connections. The current AXI profile provides AXI4-Lite control, an AXI4 memory interface with the PULP AWATOP extension, and non-coherent AXI4 MMIO. The external ACE profile is deferred. CPU count is selected before synthesis: `PARA_CPU_NUM=2` or `4`, default `4`.

Cluster dùng các hart CVA6, L1 riêng với D-cache có coherence, LLC dùng chung, PMU và kết nối debug từng hart. Profile AXI hiện tại có điều khiển AXI4-Lite, bộ nhớ AXI4 mở rộng PULP AWATOP và MMIO AXI4 không coherence. Profile ACE bên ngoài chưa triển khai. Số CPU chọn trước synthesis: `PARA_CPU_NUM=2` hoặc `4`, mặc định `4`.

| Item / Nội dung | Read or view / Đọc hoặc xem | Editable source / Nguồn chỉnh sửa |
|---|---|---|
| Specification / Đặc tả | [Cluster HDS](doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) · [Reading guide / Hướng dẫn đọc](doc/specification/README.md) | [Architecture / Kiến trúc](doc/specification/architecture/VLSIT_RISCV_CPU_Cluster_Architecture.md) · [Port plan / Kế hoạch port](doc/specification/VLSIT_RISCV_CPU_CLUSTER_RTL_PORT_PLAN.md) |
| CSR / Thanh ghi | [Cluster CSR workbook](doc/specification/VLSIT_RISCV_CPU_Cluster_CSR.xlsx) | Workbook defines the register map and PMU events. / Workbook định nghĩa map thanh ghi và event PMU. |
| TOP block diagram / Sơ đồ khối TOP | [TOP SVG](doc/specification/figures/post_a06/m_vlsit_riscv_cluster_axi_top.svg) · [Core SVG](doc/specification/figures/post_a06/m_vlsit_riscv_cluster_core.svg) | [TOP draw.io](doc/specification/figures/post_a06/m_vlsit_riscv_cluster_axi_top.drawio) · [Core draw.io](doc/specification/figures/post_a06/m_vlsit_riscv_cluster_core.drawio) |
| Memory data flow / Luồng dữ liệu bộ nhớ | [Data-flow SVG](doc/specification/figures/post_a06/CLUSTER_DATA_FLOW.svg) | [draw.io](doc/specification/figures/post_a06/CLUSTER_DATA_FLOW.drawio) |
| Maintenance flow / Luồng cache maintenance | [Retirement–CCU–LLC SVG](doc/specification/figures/post_a06/CLUSTER_CMO_FLOW.svg) | [draw.io](doc/specification/figures/post_a06/CLUSTER_CMO_FLOW.drawio) |
| FSM / Máy trạng thái | [CCU FSM](doc/specification/figures/post_a06/CCU_CONTEXT.svg) · [CMO controller FSM](doc/specification/figures/post_a06/CMO_CONTROLLER.svg) | [CCU draw.io](doc/specification/figures/post_a06/CCU_CONTEXT.drawio) · [CMO draw.io](doc/specification/figures/post_a06/CMO_CONTROLLER.drawio) |
| Other components and FSMs / Các khối và FSM khác | [Figure guide / Hướng dẫn bộ hình](doc/specification/figures/post_a06/README.md) | [Figure sources / Nguồn hình](doc/specification/figures/post_a06/) |
| Waveforms / Dạng sóng | [Waveform files / Bộ waveform](doc/specification/figures/waveforms/) · Examples below / Ví dụ bên dưới | WaveJSON `.json`, rendered `.svg` and standalone `.html`. / Có nguồn JSON, ảnh SVG và HTML độc lập. |

### Waveform examples / Ví dụ waveform

| Scenario / Kịch bản | View / Xem | Source / Nguồn |
|---|---|---|
| Dirty MESI owner / Owner MESI giữ dữ liệu dirty | [WF-002 SVG](doc/specification/figures/waveforms/WF-002_mesi_dirty_owner.svg) | [JSON](doc/specification/figures/waveforms/WF-002_mesi_dirty_owner.json) |
| CBO writeback fault / Lỗi writeback khi thực hiện CBO | [WF-018 SVG](doc/specification/figures/waveforms/WF-018_cbo_writeback_fault.svg) | [JSON](doc/specification/figures/waveforms/WF-018_cbo_writeback_fault.json) |
| FENCE.I synchronization / Đồng bộ FENCE.I | [WF-019 SVG](doc/specification/figures/waveforms/WF-019_fence_i_sync.svg) | [JSON](doc/specification/figures/waveforms/WF-019_fence_i_sync.json) |
| Directory CANCEL progress / Tiến triển qua CANCEL của directory | [WF-020 SVG](doc/specification/figures/waveforms/WF-020_directory_cancel_escape.svg) | [JSON](doc/specification/figures/waveforms/WF-020_directory_cancel_escape.json) |
| Address-region routing / Định tuyến theo vùng địa chỉ | [WF-021 SVG](doc/specification/figures/waveforms/WF-021_address_region_routing.svg) | [JSON](doc/specification/figures/waveforms/WF-021_address_region_routing.json) |

Use the HDS for the timing contract. Entries marked `pending` are documented gaps. Simulation evidence and captured waveforms are linked from the [implementation audit](project_support/reports/post_a06_cluster_audit/README.md) and [FENCE.I report](project_support/reports/fence_i/README.md).

Dùng HDS để xác định hợp đồng timing. Mục ghi `pending` là phần còn thiếu. Bằng chứng mô phỏng và waveform thu từ simulation được dẫn trong báo cáo audit và FENCE.I; hình minh họa trong spec không tự chứng minh RTL đã pass.

### Coherence deadlock fixes, 2026-11-27 / Sửa lỗi deadlock coherence

With four harts, the cluster could deadlock when several harts run atomics on one shared line while another hart runs CBO and FENCE.I. Three defects were found with the RV32 testbench (TC-07), reproduced on the 64-bit cluster, fixed, and merged into `rtl/common/`. Details / Chi tiết: [HDS Section 14.7 / Mục 14.7](doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) (DEC-046, DEC-047) · [Test report / Báo cáo test](verification/rv32_profile/REPORT.md) · [Change plan](doc/specification/HPDCACHE_ATOMIC_DEADLOCK_CHANGE_PLAN.md).

Khi chạy 4 hart, cluster có thể deadlock nếu nhiều hart chạy lệnh atomic trên cùng một dòng dùng chung trong lúc một hart khác chạy CBO và FENCE.I. Ba lỗi được phát hiện bằng testbench RV32 (TC-07), tái hiện được trên cluster 64-bit, đã sửa và merge vào `rtl/common/`.

| Fix / Bản sửa | File | What changed / Thay đổi | Why / Vì sao |
|---|---|---|---|
| 1 | `hpdcache.sv`, `hpdcache_ctrl.sv` | An AMO takes atomic permission (and refuses probes of its line) only after an E/M grant, not after a Shared grant; LR keeps S. / AMO chỉ nhận quyền atomic (và chặn probe) sau grant E/M, không phải sau grant S; LR vẫn được nhận S. | From S the AMO still needs unique ownership, which waits behind the very probe it refuses: deadlock. The HDS already requires probes to complete before the unique grant. / Khi chỉ có S, AMO vẫn phải xin quyền unique, mà yêu cầu đó lại chờ sau chính probe nó đang chặn, nên deadlock. Spec vốn đã yêu cầu probe phải được hoàn tất trước grant unique. |
| 2 | `hpdcache_rtab.sv` | The replay-table fence stays on while an AMO, uncacheable or CMO entry is queued. / Fence của RTAB giữ mức 1 khi còn entry AMO, uncached hoặc CMO. | A younger same-line load slipped in behind a queued AMO; when the AMO was re-fenced it could never leave: deadlock. / Một lệnh load cùng dòng chen vào sau AMO đang chờ; khi AMO bị fence lại thì không bao giờ rời hàng đợi được, nên deadlock. |
| 3 | `m_vlsit_riscv_coh_fabric.sv` | A context leaves DIR_UPDATE/DIR_CANCEL only on the directory handshake that carries its own tag. / Context chỉ rời DIR_UPDATE/DIR_CANCEL khi handshake directory mang đúng tag của nó. | One handshake retired two contexts: the second lost its directory update and left its set reserved, blocking later lookups (and losing holder information). / Một handshake hoàn tất cả hai context: context thứ hai mất update directory và để lại reservation của set, làm lookup về sau bị chặn (đồng thời mất thông tin holder). |

Verified on the merged RTL: lint clean; RV32 TC-01 to TC-10 PASS with 2 and 4 harts; 64-bit TC-04 to 07, 09, 10 PASS; existing atomic, CMO, FENCE.I and directory-holder suites 36/36 PASS; the pre-fix snapshot (`rtl/coherence_fix/pre_merge/`) still reproduces the hang. / Đã kiểm chứng trên RTL đã merge: lint sạch; RV32 TC-01 đến TC-10 PASS với 2 và 4 hart; 64-bit TC-04 đến 07, 09, 10 PASS; 36/36 lần chạy suite sẵn có PASS; bản trước khi sửa vẫn tái hiện được lỗi treo.

## 2. Tensor coprocessor / Bộ đồng xử lý tensor

The current cluster configuration disables CVXIF and exposes no CV-X-IF ports (HDS DEC-022). The tensor specification describes a future accelerator attachment; that integration remains to be defined.

Cấu hình cluster hiện tại tắt CVXIF và không đưa cổng CV-X-IF ra ngoài (DEC-022). Đặc tả tensor mô tả phần kết nối accelerator cần thiết kế thêm; chưa phải cấu hình cluster đã tích hợp tensor.

The draft specifies a CV-X-IF coprocessor for tensor operations, including GEMM, attention, softmax, layer normalization and vector/decode workloads. It selects non-coherent AXI4 burst DMA with banked local SRAM for tensor data and describes optional APB4 CSR control. Interface sizing and other open decisions are listed in the HDS.

Bản nháp đặc tả bộ đồng xử lý CV-X-IF cho GEMM, attention, softmax, layer normalization và workload vector/decode. Đường dữ liệu đã chọn là DMA burst AXI4 không coherence kết hợp SRAM nội bộ chia bank; CSR APB4 là tùy chọn. Kích thước giao tiếp và các quyết định còn mở được ghi trong HDS.

| Item / Nội dung | Read or view / Đọc hoặc xem | Editable source / Nguồn chỉnh sửa |
|---|---|---|
| Specification / Đặc tả | [Tensor coprocessor HDS](doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md) · [Reading guide / Hướng dẫn đọc](doc/tensor_coprocessor/README.md) | Requirements, interfaces, algorithms and open decisions. / Yêu cầu, giao tiếp, thuật toán và quyết định còn mở. |
| CSR / Thanh ghi | [Tensor CSR workbook](doc/tensor_coprocessor/TENSOR_COPROCESSOR_CSR.xlsx) | [Register model JSON / Mô hình thanh ghi](doc/tensor_coprocessor/tcop_regs.json) |
| Block diagram / Sơ đồ khối | [Current block-diagram SVG / Sơ đồ hiện tại](doc/tensor_coprocessor/figures/tensor_copro_block_diagram_runtime.svg) | [draw.io](doc/tensor_coprocessor/figures/tensor_copro_block_diagram_runtime.drawio) · [Diagram JSON / Nguồn sơ đồ](doc/tensor_coprocessor/figures/tensor_copro_block_diagram_runtime.json) |
| Control FSM / FSM điều khiển | [FSM SVG](doc/tensor_coprocessor/figures/ctrl_fsm.svg) | [draw.io](doc/tensor_coprocessor/figures/ctrl_fsm.drawio) · [FSM JSON](doc/tensor_coprocessor/figures/ctrl_fsm.json) |
| Waveforms / Dạng sóng | [Waveform files / Bộ waveform](doc/tensor_coprocessor/figures/) · Examples below / Ví dụ bên dưới | WaveJSON sources with SVG or standalone HTML views. / Nguồn WaveJSON kèm SVG hoặc HTML độc lập. |
| CV-X-IF reference / Tham chiếu giao thức | [Converted reference / Bản Markdown](doc/tensor_coprocessor/reference/md_doc/vlsit_cvxif_openhw_core_v_xif_v1_0_0.md) | [Local PDF / PDF lưu trong dự án](doc/tensor_coprocessor/reference/protocol/cvxif_v1.0.0.pdf) |

### Waveform examples / Ví dụ waveform

| Scenario / Kịch bản | View / Xem | Source / Nguồn |
|---|---|---|
| GEMM issue/result / Nhận lệnh và trả kết quả GEMM | [WF-001 SVG](doc/tensor_coprocessor/figures/wf001_gemm_success.svg) | [JSON](doc/tensor_coprocessor/figures/wf001_gemm_success.json) |
| Result backpressure / Giữ kết quả khi phía nhận chưa sẵn sàng | [WF-008 SVG](doc/tensor_coprocessor/figures/wf008_backpressure.svg) | [JSON](doc/tensor_coprocessor/figures/wf008_backpressure.json) |
| AXI read error / Lỗi đọc AXI | [WF-010 SVG](doc/tensor_coprocessor/figures/wf010_argmax_read_error.svg) | [JSON](doc/tensor_coprocessor/figures/wf010_argmax_read_error.json) |
| Exact attention / Attention chính xác | [WF-011 HTML](doc/tensor_coprocessor/figures/wf011_exact_attention.html) | [JSON](doc/tensor_coprocessor/figures/wf011_exact_attention.json) |
| Layer normalization / Chuẩn hóa theo lớp | [WF-013 HTML](doc/tensor_coprocessor/figures/wf013_layer_norm.html) | [JSON](doc/tensor_coprocessor/figures/wf013_layer_norm.json) |

Open standalone waveform HTML files locally in a browser. These tensor figures describe the specification; they do not establish a completed RTL implementation or verification result.

Mở file HTML waveform bằng trình duyệt trên máy. Các hình tensor mô tả đặc tả; chưa phải bằng chứng đã hoàn tất RTL hoặc kiểm chứng.

## 3. Directory layout / Cấu trúc thư mục

```text
doc/
  README.md                      Documentation entry / Mục lục tài liệu
  PROJECT_LAYOUT.md              Project map and commands / Cấu trúc và lệnh chạy
  specification/                 64-bit cluster: HDS, CSR, architecture, figures / Cluster 64-bit: HDS, CSR, kiến trúc, hình
  specification_32/              32-bit cluster: HDS, change plan, figures / Cluster 32-bit: HDS, change plan, hình
  tensor_coprocessor/            Tensor HDS, CSR, figures, CV-X-IF reference / Đặc tả tensor, CSR, hình, tham chiếu CV-X-IF
rtl/
  non_coherence_cluster/         Current AXI TOP and private RTL / TOP AXI hiện tại
  rv32_profile/                  32-bit version: core package, tile adapter / Phiên bản 32-bit: package core, tile
  coherence_fix/                 Pre-fix snapshot, fix records / Bản trước khi sửa, hồ sơ bản sửa
  coherence_cluster/             Reserved external ACE profile / Profile ACE dự phòng
  common/                        Shared RTL / RTL dùng chung
    third_party/                 Original upstream RTL / RTL upstream nguyên bản
    modified/                    Local changes with license/history / Bản sửa giữ license/history
    vlsit/                       New and generated RTL / RTL mới và sinh tự động
    filelists/                   Shared source lists / Filelist dùng chung
verification/                    Testbenches, programs and simulation results / Mô phỏng
lint/                            Lint/rule configuration and results / Cấu hình và kết quả lint
scripts/                         Generation and checking tools / Công cụ sinh và kiểm tra
project_support/                 Reports, snapshots, vendor docs and licenses / Hồ sơ hỗ trợ
```

## 4. RTL, validation and licenses / RTL, kiểm chứng và license

| Resource / Tài nguyên | Link / Liên kết |
|---|---|
| Cluster TOP, 2/4 harts / TOP cluster 2/4 hart | [m_vlsit_riscv_cluster_axi_top.sv](rtl/non_coherence_cluster/m_vlsit_riscv_cluster_axi_top.sv) · [64-bit filelist / Filelist 64-bit](rtl/non_coherence_cluster/filelist.f) · [32-bit filelist / Filelist 32-bit](rtl/rv32_profile/filelist_rv32.f) |
| 32-bit testbench / Testbench 32-bit | [verification/rv32_profile](verification/rv32_profile/) · [Test plan / Kế hoạch test](verification/rv32_profile/TEST_PLAN.md) · [Report / Báo cáo](verification/rv32_profile/REPORT.md) · Run / Chạy: `python run.py build --harts 4`, then / rồi `python run.py run TC-01 ... TC-10 --harts 4`; add / thêm `--xlen 64` for the 64-bit cluster / cho cluster 64-bit |
| Current cluster audit / Audit cluster hiện tại | [Post-A-06 report / Báo cáo sau A-06](project_support/reports/post_a06_cluster_audit/README.md) |
| Behavioral replay / Chạy lại kiểm chứng chức năng | [Regression Makefile / Makefile regression](verification/non_coherence_cluster/cmo_end_to_end/Makefile) · [A-06 evidence / Bằng chứng A-06](project_support/reports/fault_record_a06/README.md) |
| Design gaps / Điểm thiết kế còn mở | [Cluster HDS Section 20 / Mục 20](doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md#20-assumptions-dependencies-and-decisions) · [Tensor HDS Section 20 / Mục 20](doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md#20-assumptions-dependencies-and-decisions) |
| Reused IP revisions / Revision IP tái sử dụng | [Source provenance / Nguồn gốc mã](doc/specification/references/THIRD_PARTY_SOURCES.md) · [Vendor source guide / Hướng dẫn source vendor](project_support/third_party/README.md) |
| Licenses / Giấy phép | [Preserved license files / Các file license được giữ](project_support/licenses/third_party/) |
| Documentation links / Liên kết tài liệu | [Link audit and changed files / Kiểm tra liên kết và danh sách file sửa](project_support/documentation_audit_20261116/README.md) |
| Cleanup history / Lịch sử dọn tài liệu | [Supporting records / Hồ sơ hỗ trợ](project_support/README.md) |

Implementation status and qualification limits belong to the linked specifications and audit reports. Existing directed results do not establish complete SoC, software/OS, synthesis, STA or PPA signoff. Apply the license notices of each reused source file and its repository.

Trạng thái triển khai và giới hạn đã kiểm chứng được ghi trong đặc tả và báo cáo liên kết. Các kết quả directed hiện có chưa xác nhận signoff toàn SoC, phần mềm/OS, synthesis, STA hoặc PPA. Cần tuân thủ thông báo license của từng file nguồn và repository tái sử dụng.
