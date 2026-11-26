# Cluster waveforms / Waveform cluster

WaveJSON sources and SVG/HTML views for the cluster HDS. Open standalone HTML locally in a browser.

Nguồn WaveJSON và bản xem SVG/HTML của HDS cluster. Mở HTML độc lập bằng trình duyệt trên máy.

| ID | Scenario / Kịch bản | View / Xem | Source / Nguồn |
|---|---|---|---|
| WF-001 | Pending spec detail / Chưa chốt chi tiết spec | [SVG](WF-001_pending_status.svg) · [HTML](WF-001_pending_status.html) | [JSON](WF-001_pending_status.json) |
| WF-002 | Dirty MESI owner / Owner MESI dirty | [SVG](WF-002_mesi_dirty_owner.svg) · [HTML](WF-002_mesi_dirty_owner.html) | [JSON](WF-002_mesi_dirty_owner.json) |
| WF-003 | MMIO read/write / Đọc, ghi MMIO | [SVG](WF-003_axi_mmio_read_write.svg) · [HTML](WF-003_axi_mmio_read_write.html) | [JSON](WF-003_axi_mmio_read_write.json) |
| WF-004 | MMIO backpressure / MMIO chờ phía nhận | [SVG](WF-004_axi_mmio_backpressure.svg) · [HTML](WF-004_axi_mmio_backpressure.html) | [JSON](WF-004_axi_mmio_backpressure.json) |
| WF-005 | Pending spec detail / Chưa chốt chi tiết spec | [SVG](WF-005_pending_status.svg) · [HTML](WF-005_pending_status.html) | [JSON](WF-005_pending_status.json) |
| WF-006 | Pending spec detail / Chưa chốt chi tiết spec | [SVG](WF-006_pending_status.svg) · [HTML](WF-006_pending_status.html) | [JSON](WF-006_pending_status.json) |
| WF-007 | Pending spec detail / Chưa chốt chi tiết spec | [SVG](WF-007_pending_status.svg) · [HTML](WF-007_pending_status.html) | [JSON](WF-007_pending_status.json) |
| WF-008 | Pending spec detail / Chưa chốt chi tiết spec | [SVG](WF-008_pending_status.svg) · [HTML](WF-008_pending_status.html) | [JSON](WF-008_pending_status.json) |
| WF-009 | Pending spec detail / Chưa chốt chi tiết spec | [SVG](WF-009_pending_status.svg) · [HTML](WF-009_pending_status.html) | [JSON](WF-009_pending_status.json) |
| WF-010 | Pending spec detail / Chưa chốt chi tiết spec | [SVG](WF-010_pending_status.svg) · [HTML](WF-010_pending_status.html) | [JSON](WF-010_pending_status.json) |
| WF-011 | Pending spec detail / Chưa chốt chi tiết spec | [SVG](WF-011_pending_status.svg) · [HTML](WF-011_pending_status.html) | [JSON](WF-011_pending_status.json) |
| WF-012 | Pending spec detail / Chưa chốt chi tiết spec | [SVG](WF-012_pending_status.svg) · [HTML](WF-012_pending_status.html) | [JSON](WF-012_pending_status.json) |
| WF-013 | AXI4-Lite errors / Lỗi AXI4-Lite | [SVG](WF-013_axil_error_responses.svg) · [HTML](WF-013_axil_error_responses.html) | [JSON](WF-013_axil_error_responses.json) |
| WF-014 | Pending spec detail / Chưa chốt chi tiết spec | [SVG](WF-014_pending_status.svg) · [HTML](WF-014_pending_status.html) | [JSON](WF-014_pending_status.json) |
| WF-015 | Wait for COMMIT ACK / Chờ ACK COMMIT | [SVG](WF-015_commit_ack_wait.svg) · [HTML](WF-015_commit_ack_wait.html) | [JSON](WF-015_commit_ack_wait.json) |
| WF-016 | Wait for PREPARE ACK / Chờ ACK PREPARE | [SVG](WF-016_prepare_ack_wait.svg) · [HTML](WF-016_prepare_ack_wait.html) | [JSON](WF-016_prepare_ack_wait.json) |
| WF-017 | Wait for ABORT ACK / Chờ ACK ABORT | [SVG](WF-017_abort_ack_wait.svg) · [HTML](WF-017_abort_ack_wait.html) | [JSON](WF-017_abort_ack_wait.json) |
| WF-018 | CBO writeback fault / Lỗi writeback CBO | [SVG](WF-018_cbo_writeback_fault.svg) · [HTML](WF-018_cbo_writeback_fault.html) | [JSON](WF-018_cbo_writeback_fault.json) |
| WF-019 | FENCE.I synchronization / Đồng bộ FENCE.I | [SVG](WF-019_fence_i_sync.svg) · [HTML](WF-019_fence_i_sync.html) | [JSON](WF-019_fence_i_sync.json) |
| WF-020 | Directory CANCEL progress / Tiến triển qua CANCEL directory | [SVG](WF-020_directory_cancel_escape.svg) · [HTML](WF-020_directory_cancel_escape.html) | [JSON](WF-020_directory_cancel_escape.json) |
| WF-021 | Address-region routing / Định tuyến vùng địa chỉ | [SVG](WF-021_address_region_routing.svg) · [HTML](WF-021_address_region_routing.html) | [JSON](WF-021_address_region_routing.json) |
| WF-022 | Directory CANCEL detail / Chi tiết CANCEL directory | [SVG](WF-022_directory_cancel_escape_detail.svg) · [HTML](WF-022_directory_cancel_escape_detail.html) | [JSON](WF-022_directory_cancel_escape_detail.json) |

Files named `pending_status` mark missing specification detail, not completed timing contracts. / File `pending_status` đánh dấu chi tiết còn thiếu, chưa phải hợp đồng timing hoàn chỉnh.

[Specification / Đặc tả](../../VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) · [CSR](../../VLSIT_RISCV_CPU_Cluster_CSR.xlsx) · [Block diagram / Sơ đồ khối](../post_a06/m_vlsit_riscv_cluster_axi_top.svg) · [FSM](../post_a06/CCU_CONTEXT.svg) · [Waveforms / Dạng sóng](README.md)
