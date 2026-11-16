# A-06 fault record — proposed contract and implementation plan

Date: 2026-11-16 (Asia/Saigon). Status: **Q1=A and Q2=A confirmed by the designer; implementation in progress. No uncompleted validation is claimed**.

## Verified baseline / Hiện trạng đã kiểm tra

- HDS REQ-ERR-003 / DEC-036 requires asynchronous ordinary dirty-eviction fault notification, retained data/context and reset-only recovery. It requires an associated CSR record but does not define record selection, replacement, clear semantics or shared-LLC hart attribution.
- `m_vlsit_riscv_cluster_core.sv` combines coherence/lock diagnostics, flush errors, invalid responses, LLC writeback fault and the reset-only L1 eviction latch into `cpucl_coh_fault`. Existing W1C does not recover fatal L1 eviction.
- The tile exports accepted flush ACK line/origin/error; the final error is one bit. The LLC write master also exports only a sticky writeback fault bit. These bits cannot distinguish the original two-bit AXI response. Capture/export the response with the matched transaction; do not sample an unrelated live bus when software reads CSR.
- Current generated CSR and decoder use the legacy 4-KiB layout: control 0x0000, PMU selectors 0x0100, count low 0x0200, count high 0x0300; LLC service at 0x1000. This differs from the designer's earlier instruction to space each group by 4 KiB. This mismatch is recorded explicitly rather than silently copying the old offsets.
- Original A-05 production hashes are preserved in `baseline_sha256.json` for comparison before implementation.

## Decision Q1 — lifetime and scope / Vòng đời và phạm vi record

**Recommended A:** one first-fatal record for ordinary L1/LLC dirty-eviction B failures. Once valid, address/source/hart/response stay stable until cluster reset. A later independent fatal event sets `multiple` without overwriting the record; simultaneous events choose L1 lowest hart index, then LLC, with `multiple=1` when more than one event arrives. Existing nonfatal protocol diagnostics retain their separate W1C status and cannot consume/overwrite the fatal record. This preserves REQ-ERR-003 reset-only recovery and gives consistent low/high reads without a new snapshot command.

**Alternative B:** capture all existing fault/diagnostic sources in a small FIFO, e.g. four records, with software pop/W1C and overflow status. This preserves more history but requires additional queue/CSR semantics, metadata-valid flags for diagnostics and explicit separation of queue clear from fatal IRQ/reset recovery. A pop must never release retained dirty data or recover a failed context.

VI: A giữ lỗi fatal đầu tiên đến reset, lỗi sau chỉ đặt cờ multiple; diagnostic không fatal vẫn W1C riêng. B dùng FIFO để lưu nhiều loại lỗi, cần thêm luật pop/overflow và không được coi xóa record là recovery cache.

## Decision Q2 — hart for LLC / Ý nghĩa hart của LLC

**Recommended A:** per-L1 faults carry the exact hart with `hart_valid=1`. A shared LLC victim has `hart_valid=0` because several harts may have written that line; neither the last writer nor an original requesting hart is reliably present at the current fault boundary. The hart bits read zero when invalid and must not be interpreted as hart 0. Address/source/actual AXI B response remain valid. No guessed attribution.

**Alternative B:** extend LLC descriptor/provenance tracking and define hart as the *requester that triggered this eviction*, not the dirty-data writer. It may remain invalid for non-hart maintenance/other shared operations. This adds ID/provenance transport through LLC queues and extra verification, and cannot identify all contributors to a shared dirty line.

VI: A báo hart chính xác cho L1; lỗi LLC dùng hart_valid=0 vì không có một hart duy nhất sở hữu dữ liệu bẩn chia sẻ. B theo dõi hart gây eviction, không được gọi đó là hart đã ghi dữ liệu bẩn.

## Proposed CSR payload / Dữ liệu CSR đề xuất

| Offset within fault group | Register | Contents |
|---|---|---|
| +0x00 | cpucl_fault_sts | valid, multiple, addr_valid, hart_valid, resp_valid; reset zero |
| +0x04 | cpucl_fault_info | source (0 none, 1 L1 ordinary eviction, 2 LLC ordinary eviction), hart index, exact two-bit AXI B response; reserved bits zero |
| +0x08 | cpucl_fault_addr_lo | aligned physical line address bits 31:0 |
| +0x0C | cpucl_fault_addr_hi | physical address bits 55:32; upper byte zero |

Under Q1-A these registers are read-only and hardware clears only on reset. L1 line address is reconstructed from the matched native line address plus four zero offset bits; 56-bit physical addresses are zero-extended for 64-bit software assembly. The metadata is published atomically with valid. Events must be real accepted error completions, not repeated samples of an already-sticky fault level.

## Address map reconciliation / Hòa giải address map

Apply the already-approved 4-KiB group spacing: control/IRQ at 0x0000, PMU event selectors at 0x1000, counter low at 0x2000, counter high at 0x3000, fault records at 0x4000, LLC service at 0x5000. Each range is 4 KiB; unused offsets remain reserved. The decoder and HDS must change together and pass the whole local CSR offset instead of truncating it to 12 bits. This changes the legacy PMU/LLC firmware offsets and increases the total aperture to 24 KiB; document this compatibility impact. This follows the earlier designer instruction, rather than asking again to authorize the already-approved spacing. If the designer revises that instruction, record the revised map before generation.

## Planned implementation / Phương án triển khai

1. After Q1/Q2, update HDS requirements, register semantics, concrete examples and TEST-050/added tests; preserve baseline copies. Freeze the plan against those answers before RTL.
2. Update the canonical CSR workbook and regenerate using the existing AXI4-Lite generator. Do not hand-edit generated RTL. Verify schema/port mapping and record generator/source hashes; investigate historical workbook provenance rather than assuming the missing old path is authoritative.
3. Add a VLSIT fault-record leaf and route matched metadata through L1 flush/CVA6/tile/array and LLC write-master/eviction/top/wrapper boundaries as necessary. Preserve all reused file headers/licenses; append exact change history to modified copies; new files follow VLSIT rule v2. Keep the external cluster TOP port list unchanged.
4. Connect record payload to generated RO CSR fields. Keep fatal recovery, data/lock retention, CBO/FENCE.I retirement/traps and response draining unchanged. Update AXI4-Lite decoder and integration aperture checks for the approved 4-KiB groups.
5. Directed primary tests: capture/hold/reset, simultaneous priorities, later-event multiple bit, first-fatal stability across low/high reads, no repeated-event inflation from sticky levels, invalid hart handling, exact SLVERR/DECERR, reserved offsets and WSTRB/RO behavior.
6. Real CPU 2/4-hart end-to-end faults and external AXI4-Lite reads of the record; real LLC failure/address checks, reset recovery and no false successful completion. Retain at least 20 activated assertions per tested AXI interface. Re-run AMO/LR-SC, CBO/FENCE.I, A-04/A-05 and TOP lint 2/4 harts with zero native warnings; do not add warning suppression. Directed-only coverage intent remains in force.
7. Save all images/testbenches/logs/hash evidence and replay commands in the existing single verification Makefile. Report only completed native runs; pending items remain explicit.

VI: Chỉ bắt đầu sửa sau khi chốt hai hợp đồng hành vi. CSR sinh lại từ workbook, không sửa tay output. Nối metadata đúng transaction qua các tầng; giữ license/history và giữ recovery cache đến reset. Test phải đọc CSR qua AXI4-Lite thật, phân biệt SLVERR/DECERR, kiểm tra lỗi đồng thời/reset/reserved, rồi chạy lại regression và lint TOP 2/4 hart.


Implementation refinement: no L1/CVA6 metadata port changes are needed. The current AXI write adapter is combinational from the tile B channel to the ID-checked flush ACK; core captures the raw response only on that matched ACK. Add read-only assertions proving ACK implies matching accepted B in the native CPU tests. LLC exports a matched error-event pulse, descriptor address and raw B response through its existing licensed wrapper chain. Production changes: new m_vlsit_riscv_fault_record, cluster core, AXI4-Lite decoder, LLC wrapper and four modified LLC source copies, generated CSR. Keep all pristine third_party files unchanged. Verification-only LLC shims must forward the added metadata ports for native regressions.
