# Cluster verification plan / Kế hoạch kiểm chứng cluster

G0-approved plan for the 2/4-hart AXI cluster. Four initial FENCE.I cases passed in sealed execution and cold replay matched. This does not close the 97-row HDS plan or coverage targets.

Kế hoạch G0 đã được duyệt cho cluster AXI 2/4 hart. Bốn case FENCE.I ban đầu đã pass trong execution đã seal và cold replay khớp. Kết quả này chưa đóng plan HDS 97 dòng hay mục tiêu coverage.

- [Scope and methodology / Phạm vi và phương pháp](verification_plan.md).
- [Requirements inventory / Danh sách yêu cầu](requirements.txt).
- [Test/checker traceability / Truy vết test và checker](vplan.csv).
- [Configurations / Cấu hình](scope_matrix.json).
- [Source denominator / Phạm vi source](active_rtl_source_scope.json).
- [Coverage obligations / Yêu cầu coverage](coverage_contract.json).

[Current cluster HDS / HDS cluster hiện tại](../../doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) · [Recorded audit / Báo cáo đã lưu](../../project_support/reports/post_a06_cluster_audit/README.md) · [Tensor specification / Đặc tả tensor](../../doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md)

External ACE is deferred; the tensor design has a separate draft specification. / ACE ngoài chưa triển khai; tensor có đặc tả nháp riêng.
