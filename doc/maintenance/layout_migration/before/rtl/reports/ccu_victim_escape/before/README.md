# VLSIT RISC-V CPU Cluster

## English

This project defines a synthesis-time configurable two- or four-hart RISC-V cluster based on OpenHW CVA6. The current implementation phase targets the AXI profile: private coherent D-caches, a shared LLC, a cluster PMU, per-hart debug routing, AXI4-Lite control, AXI4+ATOP memory traffic, and non-coherent AXI4 MMIO. The external ACE profile is deferred.

### Project files

| Path | Purpose |
|---|---|
| [`doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md`](doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) | Functional requirements, interfaces, modes, and verification plan. |
| [`doc/specification/VLSIT_RISCV_CPU_CLUSTER_RTL_PORT_PLAN.md`](doc/specification/VLSIT_RISCV_CPU_CLUSTER_RTL_PORT_PLAN.md) | Source audit and integration port contracts. |
| [`doc/specification/VLSIT_RISCV_CPU_Cluster_CSR.xlsx`](doc/specification/VLSIT_RISCV_CPU_Cluster_CSR.xlsx) | CSR map and PMU event catalog source. |
| [`rtl/third_party/README.md`](rtl/third_party/README.md) | Pinned source revisions and license handling. |
| [`rtl/modified/README.md`](rtl/modified/README.md) | License-preserving upstream changes. |
| [`rtl/vlsit/`](rtl/vlsit/) | Newly authored VLSIT RTL and generated CSR RTL. |
| [`rtl_change_review.md`](rtl_change_review.md) | Approved Plan V4 and implementation status. |

### Current implementation status

**Completeness audit:** A-01 (LOAD → STORE → CBO) is fixed and passes at 2/4 harts, including ABORT/error regression. [Fix and evidence](rtl/reports/e_to_m_fix/README.md). A-02 cached AMO/LR-SC livelock and precise faults also pass real CPU tests at 2/4 harts; [atomic report](rtl/reports/atomic_coherence/README.md). A-03 dirty-eviction retention passes six CPU cases; [report](rtl/reports/l1_eviction_retention/README.md). A-04 conservative-holder reconciliation passes eight CPU cases; [report](rtl/reports/directory_holder_lifecycle/README.md). A-05 and detailed fault-record A-06 [cluster audit gaps](rtl/reports/cluster_completeness_audit/README.md) remain open.

The AXI cluster TOP is integrated with CVA6, HPDcache, CCU, LLC and control logic. Production TOP lint passes at 2/4 harts with 0 errors and 0 warnings. Real CPU tests cover CBO maintenance and the DEC-030/031 FENCE.I path. [FENCE.I evidence](rtl/reports/fence_i/README.md) includes eight M/S-mode success/error/retry tests, I-cache completion checks, actual waveforms and the changed-file list. Licensed upstream sources remain pristine under `rtl/third_party`; local changes live in `rtl/modified`.

These directed checks do not establish complete CPU/SoC signoff. External ACE, full software/OS and random coherence verification, synthesis, STA and PPA remain outside the demonstrated scope. The [FPU warning cleanup](rtl/reports/fpu_warning_fix/README.md) also passes: native FENCE.I models and production TOP lint have zero warnings.

## Tiếng Việt

Dự án đặc tả cluster RISC-V cấu hình trước tổng hợp với hai hoặc bốn hart, dùng OpenHW CVA6. Giai đoạn hiện tại xây dựng profile AXI: D-cache riêng có coherence, LLC chia sẻ, PMU cluster, định tuyến debug từng hart, điều khiển AXI4-Lite, bộ nhớ AXI4+ATOP và MMIO AXI4 không coherence. Profile ACE bên ngoài được để cho giai đoạn sau.

### Tệp của dự án

| Đường dẫn | Chức năng |
|---|---|
| [`doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md`](doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) | Yêu cầu chức năng, giao diện, cấu hình và kế hoạch kiểm chứng. |
| [`doc/specification/VLSIT_RISCV_CPU_CLUSTER_RTL_PORT_PLAN.md`](doc/specification/VLSIT_RISCV_CPU_CLUSTER_RTL_PORT_PLAN.md) | Phân tích mã nguồn và hợp đồng port tích hợp. |
| [`doc/specification/VLSIT_RISCV_CPU_Cluster_CSR.xlsx`](doc/specification/VLSIT_RISCV_CPU_Cluster_CSR.xlsx) | Nguồn bản đồ CSR và danh mục event PMU. |
| [`rtl/third_party/README.md`](rtl/third_party/README.md) | Revision mã nguồn và yêu cầu license. |
| [`rtl/modified/README.md`](rtl/modified/README.md) | Các thay đổi trên bản sao upstream có giữ license. |
| [`rtl/vlsit/`](rtl/vlsit/) | RTL mới của VLSIT và CSR được sinh tự động. |
| [`rtl_change_review.md`](rtl_change_review.md) | Plan V4 đã duyệt và trạng thái triển khai. |

### Trạng thái hiện tại

**Audit độ hoàn thiện:** A-01 (LOAD → STORE → CBO) đã sửa và pass ở 2/4 hart, gồm nhánh lỗi/ABORT. [Bản sửa và bằng chứng](rtl/reports/e_to_m_fix/README.md). A-02 AMO/LR-SC cached đã sửa livelock và lỗi precise, test CPU thật 2/4 hart đều pass; [báo cáo atomic](rtl/reports/atomic_coherence/README.md). A-03 giữ dữ liệu eviction dirty đã pass sáu ca CPU thật; [báo cáo](rtl/reports/l1_eviction_retention/README.md). A-04 đối chiếu holder bảo thủ đã pass tám ca CPU; [báo cáo](rtl/reports/directory_holder_lifecycle/README.md). Các [gap A-05 và fault record A-06](rtl/reports/cluster_completeness_audit/README.md) vẫn còn.

TOP cluster AXI đã tích hợp CVA6, HPDcache, CCU, LLC và logic điều khiển. Lint TOP production 2/4 hart đạt 0 lỗi, 0 warning. Test CPU thật đã kiểm tra CBO và FENCE.I theo DEC-030/031. [Báo cáo FENCE.I](rtl/reports/fence_i/README.md) có tám ca M/S-mode thành công/lỗi/retry, kiểm tra completion I-cache, waveform thật và danh sách file sửa. Nguồn gốc trong `rtl/third_party` giữ nguyên; bản sửa nằm trong `rtl/modified`.

Các test có định hướng chưa phải signoff toàn CPU/SoC. ACE bên ngoài, phần mềm/OS đầy đủ, coherence ngẫu nhiên, synthesis, STA và PPA chưa được chứng minh bởi bộ test này. [Bản sửa warning FPU](rtl/reports/fpu_warning_fix/README.md) cũng đã pass: model FENCE.I và lint TOP production đều không còn warning.
