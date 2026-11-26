# VLSIT RTL / RTL VLSIT

New and generated blocks are grouped by function under [rtl/common/vlsit](../../../rtl/common/vlsit/). The AXI TOP, core and external memory-width adapter are under [rtl/non_coherence_cluster](../../../rtl/non_coherence_cluster/).

Khối RTL mới và sinh tự động nằm trong `rtl/common/vlsit`, chia theo chức năng. TOP AXI, core và adapter độ rộng memory ngoài nằm trong `rtl/non_coherence_cluster`.

- [Cluster HDS](../../../doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) · [CSR workbook](../../../doc/specification/VLSIT_RISCV_CPU_Cluster_CSR.xlsx).
- [TOP diagram / Sơ đồ TOP](../../../doc/specification/figures/post_a06/m_vlsit_riscv_cluster_axi_top.svg) · [FSM index / Mục lục FSM](../../../doc/specification/figures/post_a06/README.md).
- [Maintenance flow / Luồng maintenance](../../../doc/specification/figures/post_a06/CLUSTER_CMO_FLOW.svg) · [Waveforms](../../../doc/specification/figures/waveforms/README.md).

The AXI profile has internal D-cache coherence and supports 2 or 4 harts. External ACE is deferred; the tensor coprocessor remains a separate draft specification.

Profile AXI có coherence D-cache nội bộ và hỗ trợ 2 hoặc 4 hart. ACE bên ngoài chưa triển khai; tensor coprocessor hiện là đặc tả nháp riêng.

[Current cluster HDS / HDS cluster hiện tại](../../../doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) · [Recorded audit / Báo cáo đã lưu](../../reports/post_a06_cluster_audit/README.md) · [Tensor specification / Đặc tả tensor](../../../doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md)
