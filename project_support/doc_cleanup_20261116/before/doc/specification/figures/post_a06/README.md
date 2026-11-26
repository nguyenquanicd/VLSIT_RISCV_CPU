# Current component and FSM figures / Sơ đồ component và FSM hiện tại

This package contains **117 component compositions**, **two focused working-flow diagrams**, and **ten FSM figures for six controllers**. The CCU has one complete graph and four phase views; those phase views are not additional hardware controllers. Selected source files may declare optional/unused modules; filelist membership is not proof of elaboration or functional activation.

Bộ hình có **117 sơ đồ component**, **hai sơ đồ working flow** và **mười hình cho sáu FSM**. CCU có một hình tổng và bốn view theo phase; không phải năm controller độc lập. Source được chọn trong filelist có thể chứa module/nhánh tùy chọn chưa hoạt động.

- [TOP SVG](m_vlsit_riscv_cluster_axi_top.svg) · [editable TOP draw.io](m_vlsit_riscv_cluster_axi_top.drawio)
- [Memory data flow](CLUSTER_DATA_FLOW.svg) · [draw.io](CLUSTER_DATA_FLOW.drawio)
- [Retirement–CCU–LLC maintenance flow](CLUSTER_CMO_FLOW.svg) · [draw.io](CLUSTER_CMO_FLOW.drawio)
- [CCU lookup/victim](CCU_LOOKUP_VICTIM.svg), [prepare/CMO](CCU_PREPARE_CMO.svg), [commit/release](CCU_COMMIT_RELEASE.svg), [abort/release](CCU_ABORT_RELEASE.svg)
- [Component/source inventory](component_inventory.json) · [validation summary](validation.json)

Every component has a same-stem JSON, two-tab `.drawio` (`BLOCK_DIAGRAM`, `BLOCK_INFORMATION`), SVG and build log. The HDS Section 14 embeds its diagram with function, flow, state/storage owner, interface, error/stall constraints and validation boundary. Package/configuration source files have a change contract rather than a fictitious instantiable block diagram. A leaf diagram depicts its boundary; it does not invent internal RTL submodules.

Mỗi component có JSON, draw.io hai tab, SVG và log. Section 14 mô tả chức năng, flow, chủ thể giữ state/data, interface và giới hạn verify. File package/config không có diagram module giả. Leaf chỉ thể hiện boundary; không thêm module RTL không tồn tại.

FSM sources preserve actual state names and transition guards. T-numbers in the CCU views map to the full graph and the transition tables. An entry state in a phase view is not a new reset state. Full-word guards remain in the HDS even where labels are shortened on the figure.

FSM dùng đúng tên state của source; T-number liên kết view với graph tổng và bảng guard. Điểm vào phase không phải reset state mới. Nhãn rút gọn không thay điều kiện chuyển state đầy đủ.

Replay from project root:

```sh
python scripts/build_cluster_detail_diagrams.py --post-a06 prepare
python scripts/build_cluster_detail_diagrams.py --post-a06 draw
python scripts/build_cluster_detail_diagrams.py --post-a06 render-fsm
python scripts/build_cluster_detail_diagrams.py --post-a06 assemble
python scripts/build_cluster_detail_diagrams.py --post-a06 check
```

The project adapter restores the FSM edge prototype after the installed skill adds styles rejected by its own symbol validator. It revalidates the original library symbols, preserves oval states, attached arrow endpoints and transition labels in SVG, and changes no installed skill file. Component builds use the installed micro-specification builder. No warning/geometry validator is disabled.

Script dự án xử lý hai điểm không tương thích của tool cài đặt: style edge bị validator từ chối và SVG làm mất oval/nhãn FSM. Symbol vẫn lấy từ thư viện VLSIT và được validate lại; không sửa skill cài đặt hoặc tắt kiểm tra. TOP, data flow và view CCU đã được kiểm tra ảnh preview.

The generic spec checker reports one language finding because the project requires bilingual English–Vietnamese documents while skill R-005 requests English-only. All other checked structural/port/traceability/figure findings were corrected; this language exception is explicit, not a claimed clean native checker exit. No CPU simulation, synthesis or new RTL validation is implied by document rendering.

Checker spec còn một finding ngôn ngữ do yêu cầu song ngữ của dự án; không báo giả checker exit 0. Các kiểm tra cấu trúc, port, truy vết và hình khác đã được sửa. Vẽ tài liệu không tạo thêm bằng chứng mô phỏng hoặc signoff.
