# A-02: coherent cached atomics / Atomic cached có coherence

**Follow-up / Cập nhật:** A-03 now verifies ordinary L1 eviction retention, fatal IRQ and reset recovery. [Latest source/regression record](../l1_eviction_retention/README.md). This A-02 report keeps its original source-hash snapshot; linked replay logs may be newer. A-04/A-05 and detailed fault-record A-06 remain open. / A-03 đã có test giữ dữ liệu eviction/IRQ/reset; hash trong báo cáo A-02 giữ snapshot cũ, log replay có thể mới hơn. A-04/A-05 và fault record chi tiết A-06 vẫn còn.

## English

DEC-038 keeps cached AMO/LR-SC in L1 under CCU ownership; normal-uncached atomics retain AXI4+ATOP. The targeted A-02 fixes pass actual CVA6 instruction tests on the production AXI TOP at 2 and 4 harts. This closes the reproduced livelock and precise-error failures, not every cluster audit item.

- LR reads S/E/M; SC/AMO require exclusive write permission. A clean S copy remains probeable while its upgrade waits for CCU. Failed-reservation SC returns failure without allocating a coherence transaction. The local completion guard ends at each atomic response; it never spans LR to SC.
- PREPARE owns the cache probe service through matching COMMIT/ABORT. Lock acquisition follows the admitted handshake. Directory lookup responses advance only their selected transaction tag. Pending probe writeback drains existing pipeline operations before taking the shared data array.
- Refill/permission errors reach retirement: LR traps cause 5; SC/AMO trap cause 7, with original instruction PC and virtual address. Faulting atomics do not retire or update the destination GPR. Interrupt/debug entry waits for terminal completion.
- LLC propagates RRESP errors across all refill beats. New tags become valid only after successful refill and, for a dirty victim, successful writeback B. A failed refill remains invalid; a failed dirty-victim writeback preserves the victim and blocks destructive replacement.

[Validation table](validation.md) and [machine-readable results/source hashes](results.json) record 10 atomic CPU cases, 8 CBO cases, 8 FENCE.I cases, 7 focused units, 6 native model generations and 2 TOP lint runs. Native model generation and TOP lint have zero RTL warnings/errors; no warning-disable flag was added. Directed checks only: code coverage was not measured. Host C++ runtime diagnostics remain visible in focused build logs.

[RTL rule check](rule_check.md): zero errors, two existing HIE-02 structural-heuristic warnings on functional adapter/fabric modules. These are reported, not suppressed; the actual cluster TOP remains structural. Native lint has no UNOPTFLAT, width/range or other warning.

### Replay

From `rtl/verification/cmo_end_to_end`, run `make atomic-regression`. This single Makefile includes test generation, native builds, all scenarios, focused units, TOP lint and evidence generation. See [bench details](../../verification/atomic_end_to_end/README.md).

### Actual waveform samples

[AMO](waveforms/4h_success.svg), [LR/SC retry](waveforms/4h_lrsc_contention.svg), [dirty-owner error](waveforms/4h_owner_fault.svg). Columns show actual nonuniform event times, not clock-cycle spacing. Full sampled VCDs remain in this report directory. Detailed success/error FENCE.I evidence is regenerated [here](../../verification/fence_i_end_to_end/waveforms_sim/waveform_compare.md).

### Limits and ownership

Tests use bare M-mode, AXI64 and a 4-KiB LLC; FENCE.I additionally runs bare S-mode. The uncached ATOP path is preserved but not exercised by the new atomic memory model. Tests do not establish universal LR/SC progress under arbitrary traffic, full ISA/OS correctness, default-size LLC coverage or ASIC signoff. A-03 through A-06 remain open: ordinary L1 eviction error retention, directory holder lifecycle, CCU full-table victim escape, and detailed asynchronous fault records. LLC pending-table wrap tests do not close the CCU victim-allocation issue.

Original sources under `rtl/third_party` were not restyled. Modified upstream copies retain license/copyright headers and dated history naming Quan Nguyen and Codex - VLSI Technology page. [Changed-file inventory](changed_files.md) lists 19 production RTL files. `results.json` records them with before/after SHA-256 and hashes the final VLSIT/modified source set; snapshots are in `before`.

## Tiếng Việt

Theo DEC-038, AMO/LR-SC cached thực thi tại L1 dưới quyền CCU; atomic normal-uncached vẫn dùng AXI4+ATOP. Test instruction CVA6 thật từ TOP AXI đã kiểm tra bản sửa ở 2/4 hart. Phạm vi hoàn tất là livelock và lỗi precise của A-02 đã tái hiện; chưa phải đóng toàn bộ audit cluster.

LR đọc line S/E/M; SC/AMO cần quyền ghi độc quyền. Khi chờ upgrade, bản S sạch vẫn phục vụ probe để tránh vòng chờ. SC mất reservation trả thất bại ngay. Guard kết thúc khi từng atomic hoàn tất, không giữ lock từ LR đến SC. Probe giữ đúng transaction qua PREPARE–COMMIT/ABORT; phân xử directory kiểm tra tag; writeback probe đợi pipeline cũ drain trước khi dùng data array.

Lỗi permission/refill được đưa tới retirement: LR cause 5, SC/AMO cause 7, giữ PC và địa chỉ ảo gốc; không retire hoặc ghi GPR sai. LLC truyền RRESP lỗi, chỉ cài tag mới sau refill thành công và B thành công nếu thay dirty victim. Lỗi refill không để lại line valid; lỗi writeback giữ victim.

Bảng kiểm chứng ghi 10 ca atomic, 8 CBO, 8 FENCE.I, 7 unit, 6 lần sinh model và 2 lint TOP. Model/lint native không có warning hoặc lỗi RTL. Không đo code coverage. Rule checker riêng còn hai cảnh báo HIE-02 đã có ở adapter/fabric chức năng; không giấu cảnh báo này.

Chạy lại toàn bộ bằng `make atomic-regression` tại `rtl/verification/cmo_end_to_end`. Waveform có nhãn thời gian thực, không suy diễn latency. Nguồn reuse giữ nguyên; bản sửa giữ license và history. Các gap A-03–A-06, ISA/OS, LLC mặc định, stress ngẫu nhiên và signoff ASIC vẫn cần công việc riêng.
