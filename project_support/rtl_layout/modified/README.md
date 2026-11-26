# Modified upstream RTL / RTL upstream đã sửa

Licensed source copies live in [rtl/common/modified](../../../rtl/common/modified/). Pristine source snapshots live in [rtl/common/third_party](../../../rtl/common/third_party/). Local modifications retain original notices and dated change history.

Các bản source sửa có giữ license nằm trong `rtl/common/modified`; source nguyên bản nằm trong `rtl/common/third_party`. Bản sửa giữ thông báo gốc và history theo ngày.

- [Selected modified-source contracts / Hợp đồng source MODIFY](../../../doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md#14-rtl-implementation-contract).
- [Source revisions / Revision nguồn](../../../doc/specification/references/THIRD_PARTY_SOURCES.md) · [License files / File license](../../licenses/third_party/).
- [Recorded atomic evidence / Bằng chứng atomic đã lưu](../../reports/atomic_coherence/README.md) · [FENCE.I](../../reports/fence_i/README.md) · [Fatal retention / Giữ dữ liệu khi lỗi fatal](../../reports/l1_eviction_retention/README.md).

The production hierarchy includes the CBO retirement/CCU/LLC path. Qualification limits remain in the HDS and audit; earlier missing-core notes are historical.

Hierarchy production đã có đường retirement/CCU/LLC của CBO. Giới hạn kiểm chứng nằm trong HDS và audit; ghi chú thiếu core của mốc cũ là lịch sử.

[Current cluster HDS / HDS cluster hiện tại](../../../doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) · [Recorded audit / Báo cáo đã lưu](../../reports/post_a06_cluster_audit/README.md) · [Tensor specification / Đặc tả tensor](../../../doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md)
