# VLSIT RISC-V CPU Cluster & Tensor Coprocessor

This repository contains a configurable 2/4-CPU RISC-V cluster and the design specification for a tensor coprocessor. Start with the specifications and register workbooks below; diagrams, FSMs and waveforms are linked beside them.

Repository gồm cluster RISC-V cấu hình 2/4 CPU và đặc tả tensor coprocessor. Bắt đầu từ specification và workbook thanh ghi bên dưới; các liên kết sơ đồ, FSM và waveform nằm cạnh từng thiết kế.

[Documentation index / Mục lục tài liệu](doc/README.md) · [Project layout / Cấu trúc dự án](doc/PROJECT_LAYOUT.md) · [Supporting records / Hồ sơ hỗ trợ](project_support/README.md)

## 1. Cluster 2/4 CPU

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

## 2. Tensor coprocessor / Bộ đồng xử lý tensor

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
  specification/                 Cluster 2/4 CPU: HDS, CSR, architecture, figures, references
  tensor_coprocessor/             Tensor HDS, CSR, figures, CV-X-IF reference
rtl/
  non_coherence_cluster/         Current AXI TOP and private RTL / TOP AXI hiện tại
  coherence_cluster/             Reserved external ACE profile / Profile ACE dự phòng
  common/
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
| Cluster TOP, 2/4 harts / TOP cluster 2/4 hart | [m_vlsit_riscv_cluster_axi_top.sv](rtl/non_coherence_cluster/m_vlsit_riscv_cluster_axi_top.sv) · [Production filelist / Filelist production](rtl/non_coherence_cluster/filelist.f) |
| Current cluster audit / Audit cluster hiện tại | [Post-A-06 report](project_support/reports/post_a06_cluster_audit/README.md) |
| Behavioral replay / Chạy lại kiểm chứng chức năng | [Regression Makefile](verification/non_coherence_cluster/cmo_end_to_end/Makefile) · [A-06 evidence / Bằng chứng A-06](project_support/reports/fault_record_a06/README.md) |
| Design gaps / Điểm thiết kế còn mở | [Cluster HDS Section 20](doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md#20-assumptions-dependencies-and-decisions) · [Tensor HDS Section 20](doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md#20-assumptions-dependencies-and-decisions) |
| Reused IP revisions / Revision IP tái sử dụng | [Source provenance / Nguồn gốc mã](doc/specification/references/THIRD_PARTY_SOURCES.md) · [Vendor source guide / Hướng dẫn source vendor](project_support/third_party/README.md) |
| Licenses / Giấy phép | [Preserved license files / Các file license được giữ](project_support/licenses/third_party/) |
| Cleanup history / Lịch sử dọn tài liệu | [Supporting records / Hồ sơ hỗ trợ](project_support/README.md) |

Implementation status and qualification limits belong to the linked specifications and audit reports. Existing directed results do not establish complete SoC, software/OS, synthesis, STA or PPA signoff. Apply the license notices of each reused source file and its repository.

Trạng thái triển khai và giới hạn đã kiểm chứng được ghi trong đặc tả và báo cáo liên kết. Các kết quả directed hiện có chưa xác nhận signoff toàn SoC, phần mềm/OS, synthesis, STA hoặc PPA. Cần tuân thủ thông báo license của từng file nguồn và repository tái sử dụng.
