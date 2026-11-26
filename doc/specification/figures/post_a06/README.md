# Cluster block diagrams and FSMs / Sơ đồ khối và FSM cluster

65 component diagrams, two working flows and ten FSM views for six controllers. A component diagram exists only when it shows something: child instances with their wire connections (for example the cluster core), or the internal functional blocks of a module that has no child (six VLSIT coherence and maintenance modules, files `*_internal`). One-box diagrams were removed. CCU phase views belong to the same controller.

65 sơ đồ component, hai luồng hoạt động và mười hình FSM cho sáu controller. Sơ đồ component chỉ giữ khi có nội dung: instance con kèm kết nối dây (ví dụ cluster core) hoặc các khối chức năng bên trong module không có instance con (sáu module coherence và maintenance của VLSIT, file `*_internal`). Các sơ đồ một khối đã bị bỏ. Các view theo phase CCU thuộc cùng một controller.

- [TOP SVG](m_vlsit_riscv_cluster_axi_top.svg) · [TOP draw.io](m_vlsit_riscv_cluster_axi_top.drawio).
- [Memory data flow / Luồng bộ nhớ](CLUSTER_DATA_FLOW.svg) · [Maintenance flow / Luồng maintenance](CLUSTER_CMO_FLOW.svg).

| Controller / Bộ điều khiển | FSM view / Hình FSM | Editable source / Nguồn chỉnh sửa |
|---|---|---|
| CCU context | [SVG](CCU_CONTEXT.svg) | [draw.io](CCU_CONTEXT.drawio) |
| CMO controller | [SVG](CMO_CONTROLLER.svg) | [draw.io](CMO_CONTROLLER.drawio) |
| HPDcache probe | [SVG](HPD_PROBE.svg) | [draw.io](HPD_PROBE.drawio) |
| AXI4-Lite–RegBus bridge | [SVG](AXIL_REGBUS.svg) | [draw.io](AXIL_REGBUS.drawio) |
| HPDcache miss permission | [SVG](HPD_MISS_PERMISSION.svg) | [draw.io](HPD_MISS_PERMISSION.drawio) |
| HPDcache flush capture | [SVG](HPD_FLUSH_CAPTURE.svg) | [draw.io](HPD_FLUSH_CAPTURE.drawio) |

CCU phase views / View theo phase: [lookup/victim](CCU_LOOKUP_VICTIM.svg) · [prepare/CMO](CCU_PREPARE_CMO.svg) · [commit/release](CCU_COMMIT_RELEASE.svg) · [abort/release](CCU_ABORT_RELEASE.svg).

[Component inventory / Danh sách component](component_inventory.json) · [Figure validation / Kiểm tra hình](validation.json) · [Build reports / Báo cáo tạo hình](../../../../project_support/specification/figures/post_a06/).

The HDS defines guards and timing; figures do not establish simulation coverage. / HDS định nghĩa guard và timing; hình không chứng minh coverage mô phỏng.

[Specification / Đặc tả](../../VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) · [CSR](../../VLSIT_RISCV_CPU_Cluster_CSR.xlsx) · [Block diagram / Sơ đồ khối](m_vlsit_riscv_cluster_axi_top.svg) · [FSM](CCU_CONTEXT.svg) · [Waveforms / Dạng sóng](../waveforms/README.md)
