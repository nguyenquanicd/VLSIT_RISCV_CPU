# Review-fix status — 2026-11-20

## English

Applied the source-grounded, low-risk RTL fixes from the consolidated review:

- **R-01:** A mapped but write-protected LLC register no longer enters the RegBus write state. The existing local response path returns one `SLVERR`; no LLC write request is issued.
- **R-02:** The CVA6 interrupt vector now maps `MEIP` to `irq_i[0]` and `SEIP` to `irq_i[1]`, matching the inspected CVA6 CSR logic.
- **R-03:** The cited cluster-core and coherence-fabric declarations now precede their first use. No logic equations or state behavior were intentionally changed for this finding.
- **R-13:** Illegal probe-FSM encodings deassert request/response `valid` outputs and recover the next state to `IDLE` instead of propagating X or holding the illegal state.
- **R-18 (partial):** Corrected the stale CMO integration comment and the TOP comment for the 24-KiB AXI4-Lite aperture.

Original copies of all changed RTL files are preserved in `original/`. The exact edits and rationale are in `CHANGE_PLAN.md`.

**Validation:** `git -c core.whitespace=cr-at-eol diff --check -- <six changed RTL files>` passed; snapshot SHA-256 checks passed. Simulation, lint, RTL-rule check, synthesis and timing were not run. Therefore these fixes are not marked functionally verified.

## Tiếng Việt

Đã áp dụng các sửa RTL có bằng chứng trực tiếp và rủi ro thấp trong review hợp nhất:

- **R-01:** Địa chỉ LLC được map nhưng cấm ghi không còn đi vào trạng thái ghi RegBus. Đường phản hồi lỗi cục bộ hiện có trả đúng một `SLVERR`; không phát lệnh ghi tới LLC.
- **R-02:** Vector ngắt vào CVA6 được nối để `MEIP` vào `irq_i[0]` và `SEIP` vào `irq_i[1]`, khớp logic CSR CVA6 đã kiểm tra.
- **R-03:** Các khai báo được review nêu trong cluster core và coherence fabric đã được chuyển lên trước lần sử dụng đầu tiên. Không chủ ý đổi phương trình logic hay hành vi trạng thái.
- **R-13:** Mã trạng thái probe FSM không hợp lệ làm các ngõ `valid` xuống 0 và đưa trạng thái kế tiếp về `IDLE`, thay vì phát X hoặc giữ trạng thái sai.
- **R-18 (một phần):** Sửa comment cũ về đường CMO và comment TOP mô tả aperture AXI4-Lite 24 KiB.

Bản RTL trước khi sửa được lưu trong `original/`. Chi tiết và lý do sửa nằm trong `CHANGE_PLAN.md`.

**Xác minh:** Lệnh `git -c core.whitespace=cr-at-eol diff --check -- <sáu file RTL đã sửa>` và kiểm tra SHA-256 của snapshot đều PASS. Chưa chạy simulation, lint, RTL-rule check, synthesis hoặc timing; do đó chưa đánh dấu các sửa này là đã xác minh chức năng.

## Still open

R-04 (possible CCU circular wait; needs reproduction/formal analysis), R-05 (file-level licensing), R-06 through R-12 (architecture, verification, CSR-generator and access-policy work), R-14 (invalid-CMO error contract), R-15 through R-17 (system/performance scope), and R-20 through R-26 (timing/ASIC/FPGA implementation and flow). R-18 also has documentation and traceability work beyond the two comment corrections above. See the consolidated review for the detailed evidence and actions.

