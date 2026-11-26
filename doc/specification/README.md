# Cluster 2/4 CPU specification / Đặc tả cluster 2/4 CPU

Design contract for the CVA6 cluster with 2 or 4 harts. The HDS defines requirements; the workbook defines registers and PMU events.

Hợp đồng thiết kế cluster CVA6 có 2 hoặc 4 hart. HDS định nghĩa yêu cầu; workbook định nghĩa thanh ghi và event PMU.

| Material / Tài liệu | Link / Liên kết |
|---|---|
| Specification / Đặc tả | [Cluster HDS (English)](VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) · [Bản dịch tiếng Việt](VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS_vi.md) · [Port plan / Kế hoạch port](VLSIT_RISCV_CPU_CLUSTER_RTL_PORT_PLAN.md) |
| CSR / Thanh ghi | [CSR workbook](VLSIT_RISCV_CPU_Cluster_CSR.xlsx) |
| Block diagram / Sơ đồ khối | [TOP SVG](figures/post_a06/m_vlsit_riscv_cluster_axi_top.svg) · [draw.io](figures/post_a06/m_vlsit_riscv_cluster_axi_top.drawio) |
| FSM / Máy trạng thái | [CCU SVG](figures/post_a06/CCU_CONTEXT.svg) · [CMO SVG](figures/post_a06/CMO_CONTROLLER.svg) · [All FSMs / Các FSM](figures/post_a06/README.md) |
| Waveforms / Dạng sóng | [WF index / Mục lục WF](figures/waveforms/README.md) |
| Coherence deadlock fixes / Sửa deadlock coherence (2026-11-27) | [HDS Section 14.7](VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) (DEC-046, DEC-047): what each of the three fixes changes and why / ba bản sửa thay đổi gì và vì sao · [Change plan](HPDCACHE_ATOMIC_DEADLOCK_CHANGE_PLAN.md) |
| Supporting design documents / Tài liệu thiết kế liên quan | [Architecture / Kiến trúc](architecture/README.md) · [References / Tham chiếu](references/README.md) · [Reviews / Review](review/README.md) |

[Specification / Đặc tả](VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) · [CSR](VLSIT_RISCV_CPU_Cluster_CSR.xlsx) · [Block diagram / Sơ đồ khối](figures/post_a06/m_vlsit_riscv_cluster_axi_top.svg) · [FSM](figures/post_a06/CCU_CONTEXT.svg) · [Waveforms / Dạng sóng](figures/waveforms/README.md)
