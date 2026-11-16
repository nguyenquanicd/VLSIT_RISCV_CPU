# A-04: conservative holder reconciliation / Đối chiếu holder bảo thủ

**A-05 follow-up / Cập nhật:** [Current victim-escape implementation and full 2/4-hart regression](../ccu_victim_escape/README.md) pass. This report retains its historical source-hash snapshot; replay logs may be newer. Detailed fault-record A-06 remains open. / A-05 và regression đã PASS; hash của báo cáo này giữ snapshot lịch sử, log có thể mới hơn. Fault record chi tiết A-06 vẫn còn.

## English

DEC-013 / REQ-MEM-008/012/023 / TEST-052. The directory remains a conservative set of possible holders. Successful clean/dirty L1 replacement or failed post-grant refill can leave an extra bit; a later locked probe proves absence and a successful COMMIT removes it. This implements reconciliation, not an eager DROP notification.

| Changed production file | Behavior |
|---|---|
| [CCU fabric](../../vlsit/m_vlsit_riscv_coh_fabric.sv) | Accept validated PREPARE-I, satisfy the no-data-needed obligation, retain the actual state for terminal checks, prune candidate holder bits and publish only after COMMIT. Empty committed masks become I/owner zero. |
| [Cache probe engine](../../vlsit/m_vlsit_riscv_hpd_probe_engine.sv) | A cache captured absent stays I at COMMIT for S/E/M targets and performs no allocation or RAM write. Tag/line/target errors and writeback failures remain errors. |

Actual M still requires successful writeback when requested. A-03 failed dirty victims remain M/busy until reset and cannot claim absent I. Error-I does not authorize pruning; ABORT keeps the old conservative directory. All tag, phase, expected-hart, duplicate and state checks remain active. A prepared-I cache returning synthetic S at COMMIT is diagnosed, does not grant the requester and retains its context/line lock until reset.

### Evidence and replay

**Completed:** 40 actual CPU cases (8 holder, 6 A-03, 10 atomic, 8 CBO, 8 FENCE.I) and both focused protocol units pass. TOP lint at 2/4 harts and every native model generation have zero RTL warnings/errors. The 60-entry validation index includes completed-driver and model-input identity checks, so old logs alone cannot claim a current pass.

[Validation](validation.md), [source hashes and machine-readable results](results.json), [changed-file inventory](changed_files.md), [manual review](manual_review.md), [bench details](../../verification/directory_holder_end_to_end/README.md).

Run `make holder-regression` from `rtl/verification/cmo_end_to_end`. This single Makefile contains the focused probe/fabric checks, real CPU programs, A-03 retention, atomic/CBO/FENCE.I regression, strict TOP lint and evidence generation. Native model warnings remain fatal; no warning was disabled or waived. The final input manifests bind each holder model to its production RTL, bench, includes and program images; `--run-only` rejects a changed identity.

The four programs at each hart count cover dirty eviction, clean eviction, failed AMO refill and failed LR refill. Real peer loads check all nine data lines; peer AMOs require unique old values and the exact final sum. A final CBO.CLEAN publishes that sum to the independent DRAM model. Monitors check actual native PREPARE-I responses and absence of those bits in committed directory masks. Both the native L1-to-LLC and external memory AXI interfaces have 20 active protocol assertions. No cache state, CPU completion or retirement is forced.

Focused units cover E/M absence, mixed live/absent sharers, error-I ABORT, empty-mask CMO, rejected synthetic COMMIT state, reset recovery, original M writeback negatives, same-bank concurrency and matched terminal targets. A fixture initially left its CMO-enable parameter at the bank-test default of zero; it was enabled to match production and a bounded unit watchdog was added. No production behavior was changed to bypass that fixture wait.

### Figures and limits

[Dirty eviction](waveforms/4h_dirty_eviction.svg), [clean eviction](waveforms/4h_clean_eviction.svg), [AMO refill fault](waveforms/4h_amo_refill_error.svg), [LR refill fault](waveforms/4h_lr_refill_error.svg). These are actual nonuniform timestamp samples of testbench monitor masks, not literal RTL ports or cycle-latency contracts. Full selected-signal VCDs remain beside logs.

A stale bit can remain until the next probe, including after ABORT. Pruning can leave a single real holder in S; automatic E promotion is not added. Extra lookup/PREPARE/COMMIT traffic can increase latency, while no per-eviction DROP channel is needed. No fixed IPC/Fmax/PPA improvement is claimed. A-05 CCU victim-child capacity and A-06 detailed fault records remain open; this is not complete cluster/ASIC signoff. Tests use AXI64, a 4-KiB LLC and bare M-mode; FENCE.I additionally uses bare S-mode. Uncached ATOP, full ISA/Linux, randomized coherence, full-size LLC and physical signoff are outside this run. Code coverage was not requested or measured.

Rule check: zero errors, the same existing HIE-02 warning on the functional fabric and two COM-04 informational notices as the [baseline](rule_baseline.md); [final](rule_check.md). The existing comments describe full legal case coverage and intentional unknown defaults. Third-party/modified native RTL and license headers are unchanged by A-04; only the two VLSIT files receive dated history naming Quan Nguyen and Codex - VLSI Technology page.

## Tiếng Việt

A-04 giữ kiến trúc directory bảo thủ đã duyệt: eviction thành công hoặc refill lỗi có thể để lại bit holder dư; probe I hợp lệ xác nhận cache đã vắng và COMMIT thành công mới loại bit đó. Không thêm thông báo DROP tức thời.

Đã PASS 40 ca CPU thật và hai unit; lint TOP/model native 2/4 hart đạt 0 lỗi/warning RTL.

Đã sửa hai file VLSIT: CCU kiểm tra proof I, giữ state theo tag, prune candidate rồi publish sau đủ ACK; cache vắng ACK COMMIT bằng I và không tạo line S/E/M giả. Owner M thật vẫn cần writeback; victim B lỗi theo A-03 vẫn giữ M/busy đến reset. ABORT giữ metadata cũ. ACK sai tag/phase/state và terminal S giả vẫn bị từ chối.

Test CPU thật ở 2/4 hart kiểm tra chín line dữ liệu, AMO giữa các peer, refill AMO/LR lỗi và truy cập lại từ peer; CBO.CLEAN cuối chương trình kiểm tra tổng mới nhất tới DRAM. Monitor đọc response/cache/directory thực, không force state hay completion. Các unit kiểm tra holder trộn thật/vắng, CMO mask rỗng, ABORT và lỗi terminal.

Makefile liên kết trên chứa toàn bộ lệnh chạy lại. Waveform là mask monitor được lấy mẫu với thời gian thực không đều, không quy định latency. Directory có thể giữ bit dư tới probe tiếp theo và có thể giữ S dù còn một holder; không tuyên bố cải thiện IPC/PPA. A-05/A-06 và signoff toàn cluster vẫn còn. Không đo code coverage.
