# Converted protocol text / Văn bản giao thức đã chuyển đổi

Searchable Markdown conversion of the local CV-X-IF reference.

Bản chuyển đổi Markdown của tham chiếu CV-X-IF, thuận tiện tìm kiếm và dẫn mục.

- [CV-X-IF Markdown](vlsit_cvxif_openhw_core_v_xif_v1_0_0.md).
- [Source PDF / PDF nguồn](../protocol/cvxif_v1.0.0.pdf).

For revision and applicable clauses, read HDS REF-001. The PDF cover identifies Release v1.0.1-dev.0. Sections 5.5.9 and 5.5.10 exclude the memory request/response and memory-result channels from this edition. / Xem REF-001 trong HDS để xác định revision và các mục áp dụng. Phiên bản này dùng IF-003 riêng để đọc và ghi dữ liệu tensor.

The [local Arm AXI4 conversion](vlsit_axi_amba_axi_ihi0022h.md) is excluded from version control under REF-013. The PDF checksum matches the conversion header. The converter's word-count check flags 53 of 500 pages. For the selected reset and framing policy, the cited statements on the final read beat, AXI4 write-response dependencies and completing the remaining transfers after a read error were checked directly against PDF pages 43, 45–46 and 48. Use the PDF as authority for those statements and for other passages that need review.

[Specification / Đặc tả](../../VLSIT_TENSOR_COPROCESSOR_HDS.md) · [CSR](../../TENSOR_COPROCESSOR_CSR.xlsx) · [Block diagram / Sơ đồ khối](../../figures/tensor_copro_block_diagram_runtime.svg) · [FSM](../../figures/ctrl_fsm.svg) · [Waveforms / Dạng sóng](../../figures/README.md)
