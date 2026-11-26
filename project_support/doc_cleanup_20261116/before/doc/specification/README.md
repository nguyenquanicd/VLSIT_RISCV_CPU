# Cluster specification / Đặc tả cluster

The authoritative [HDS revision 0.29](VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) describes the current AXI-only 2/4-hart cluster. It preserves approved behavior and separates design requirements, present RTL realization and actual verification evidence.

[HDS 0.29](VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) là bản đặc tả chính của cluster AXI 2/4 hart. Bản này giữ các quyết định đã duyệt, tách yêu cầu thiết kế, cách RTL hiện thực và bằng chứng verify.

| Section / Mục | Content / Nội dung |
|---|---|
| 5 | Structural TOP and working/data-flow diagrams / Sơ đồ TOP và luồng làm việc/dữ liệu |
| 6 | Exact TOP ports and internal bundle contracts / Port TOP và hợp đồng interface nội bộ |
| 8 | Current parameters and qualification limits / Parameter và giới hạn đã verify |
| 10 | Six implemented controllers, four additional readable CCU views, transition guards and end-to-end operations / FSM, điều kiện chuyển state và hoạt động đầu-cuối |
| 11–13 | Workbook-based software sequence, errors, retention and worst-case performance / Trình tự phần mềm, lỗi, giữ dữ liệu và worst case |
| 14 | 35 NEW/GENERATED component contracts and all 84 selected modified source contracts; adjacent composition figures and exact ports / Component mới/sinh tự động và mọi source MODIFY được chọn |
| 15, 19, 20 | Tests, traceability and unresolved review items / Kiểm chứng, truy vết và điểm còn mở |

The [canonical CSR workbook](VLSIT_RISCV_CPU_Cluster_CSR.xlsx) remains the register source. No RTL or register ABI was changed. Native licensing headers are preserved. [Prior specification snapshot](revision_history/pre_detail_rewrite_20261116/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md).

Workbook là nguồn định nghĩa register; không sửa RTL, ABI hoặc header/license native trong lần viết lại này. Snapshot giữ nguyên bản spec trước khi viết lại.

Editable figures and checks: [post-A-06 figure package](figures/post_a06/README.md). Older V1–V4 proposal figures remain historical; the current HDS embeds the new source-grounded figures.

Các hình mới có draw.io và JSON đi kèm. Hình đề xuất V1–V4 cũ được giữ làm lịch sử, không thay trạng thái source hiện tại.
