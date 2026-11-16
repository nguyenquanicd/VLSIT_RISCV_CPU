# Silent E→M fix / Sửa lỗi E→M cục bộ

2026-11-15. TOP: `m_vlsit_riscv_cluster_axi_top`.

EN: Closed audit A-01. The real CPU LOAD→STORE→CBO sequence now succeeds at both 2/4 harts; memory-error variants still ABORT and trap cause 7 correctly. One production RTL module changed: [CCU fabric](../../../rtl/common/vlsit/coherence/m_vlsit_riscv_coh_fabric.sv). No native upstream file, port, hierarchy or pipeline stage was changed. No warning suppression or waiver was added.

VI: Đã đóng lỗi A-01: LOAD→STORE→CBO chạy thành công bằng CPU thật ở cả 2/4 hart; nhánh lỗi memory vẫn ABORT rồi trap cause 7 chính xác. Chỉ sửa một module RTL production là CCU fabric. Không đổi port, hierarchy hoặc tầng pipeline; không tắt hay waive warning.

## Mechanism / Cách sửa

- Directory E identifies the unique exclusive owner, whose cache may have silently become M after a store. Only that owner with a singleton holder mask can refine E to M during PREPARE.
- The CCU tracks E as a potentially dirty owner before starting PREPARE. Clean E satisfies the no-writeback-needed condition; actual M must return successful transport writeback completion when required.
- Save the validated PREPARE state per transaction tag and holder, including when a B error is reported. ABORT must echo the saved actual state; COMMIT must echo the selected target state.
- Keep tag/line/phase/expected-hart/duplicate-response checks. Clear snapshots on tag allocation. No ACK timeout is added; raw writeback PMU signals are unchanged.

VI: Chỉ owner E duy nhất được trả M hợp lệ. E clean không cần writeback, nhưng M thực phải có completion ghi trả thành công. State PREPARE thực được giữ theo tag/holder để ABORT kiểm tra đúng M, kể cả khi B lỗi. COMMIT vẫn phải đúng target state. Mọi check định danh/phase/holder và chính sách không timeout vẫn giữ.

## Results / Kết quả

| Suite | Harts | Error | Privilege | Result | Cycles |
|---|---:|---:|---|---|---:|
| LOAD→STORE→CBO | 2 | 0 | M | [PASS](../../../verification/non_coherence_cluster/reports/cluster_completeness_audit/simulation_2h_error0.log) | 726 |
| LOAD→STORE→CBO | 2 | 1 | M | [PASS](../../../verification/non_coherence_cluster/reports/cluster_completeness_audit/simulation_2h_error1.log) | 605 |
| LOAD→STORE→CBO | 4 | 0 | M | [PASS](../../../verification/non_coherence_cluster/reports/cluster_completeness_audit/simulation_4h_error0.log) | 948 |
| LOAD→STORE→CBO | 4 | 1 | M | [PASS](../../../verification/non_coherence_cluster/reports/cluster_completeness_audit/simulation_4h_error1.log) | 705 |
| Baseline CBO | 2 | 0 | M | [PASS](../../../verification/non_coherence_cluster/reports/cmo_end_to_end/simulation_2h_error0.log) | 724 |
| Baseline CBO | 2 | 1 | M | [PASS](../../../verification/non_coherence_cluster/reports/cmo_end_to_end/simulation_2h_error1.log) | 603 |
| Baseline CBO | 4 | 0 | M | [PASS](../../../verification/non_coherence_cluster/reports/cmo_end_to_end/simulation_4h_error0.log) | 944 |
| Baseline CBO | 4 | 1 | M | [PASS](../../../verification/non_coherence_cluster/reports/cmo_end_to_end/simulation_4h_error1.log) | 701 |
| FENCE.I | 2 | 0 | M | [PASS](../../../verification/non_coherence_cluster/reports/fence_i_end_to_end/simulation_2h_error0.log) | 938 |
| FENCE.I | 2 | 0 | S delegated | [PASS](../../../verification/non_coherence_cluster/reports/fence_i_end_to_end/simulation_2h_error0_supervisor.log) | 1063 |
| FENCE.I | 2 | 1 | M | [PASS](../../../verification/non_coherence_cluster/reports/fence_i_end_to_end/simulation_2h_error1.log) | 1020 |
| FENCE.I | 2 | 1 | S delegated | [PASS](../../../verification/non_coherence_cluster/reports/fence_i_end_to_end/simulation_2h_error1_supervisor.log) | 1145 |
| FENCE.I | 4 | 0 | M | [PASS](../../../verification/non_coherence_cluster/reports/fence_i_end_to_end/simulation_4h_error0.log) | 1015 |
| FENCE.I | 4 | 0 | S delegated | [PASS](../../../verification/non_coherence_cluster/reports/fence_i_end_to_end/simulation_4h_error0_supervisor.log) | 1140 |
| FENCE.I | 4 | 1 | M | [PASS](../../../verification/non_coherence_cluster/reports/fence_i_end_to_end/simulation_4h_error1.log) | 1163 |
| FENCE.I | 4 | 1 | S delegated | [PASS](../../../verification/non_coherence_cluster/reports/fence_i_end_to_end/simulation_4h_error1_supervisor.log) | 1288 |

All six native CPU models generate without errors or warnings. Full production TOP lint: [2 harts](../../../lint/non_coherence_cluster/full_integration/top_lint_2h_20261115_172938.log), [4 harts](../../../lint/non_coherence_cluster/full_integration/top_lint_4h_20261115_172938.log): **0 errors, 0 warnings**, no latch or multiple-driver diagnostics.

Sáu model CPU đều không có lỗi/warning. Lint toàn hierarchy TOP 2/4 hart có 0 lỗi và 0 warning.

[Directed CCU unit log](../../../verification/non_coherence_cluster/reports/e_to_m_fix/unit/simulation_4h_error0.log) also passes original clean-E/MESI/bank/PMU scenarios, E→M sharing, missing-writeback rejection, explicit B-error ABORT retaining M, retry, and invalid E→S rejection. These negative cases prevent replacing the fix with unconditional state acceptance or fabricated dirty-writeback success. The unit uses modeled cache responses; CPU tests above use native CVA6/HPDcache/LLC.

Test unit còn kiểm tra clean E, E→M chia sẻ, từ chối thiếu writeback, B lỗi→ABORT giữ M, retry và từ chối E→S không hợp lệ. Nhờ đó không thể thay bản sửa bằng cách bỏ check state hoặc tự báo dirty-writeback thành công. Unit mô hình hóa cache response; các test CPU phía trên dùng CVA6/HPDcache/LLC thật.

[WF-019 VCD/JSON/SVG evidence](../../verification/non_coherence_cluster/fence_i_end_to_end/waveforms_sim/waveform_compare.md) was refreshed after the eight FENCE.I replays. CBO and LOAD/store corner service VCDs remain alongside their simulation logs. Cycle totals include program execution and are not IPC or isolated maintenance latency measurements.

## Replay / Chạy lại

```powershell
cd C:\HQuan\102_MyGithub\VLSIT_RISCV_CPU\rtl\verification\cmo_end_to_end
make e-to-m-regression
```

[Shared Makefile](../../../verification/non_coherence_cluster/cmo_end_to_end/Makefile), [unit test and rationale](../../verification/non_coherence_cluster/e_to_m_fix/README.md). Fresh generated C++ directories are used for every build. CBO and audit runners now reject any reported model warning; testbench-only scalar conditions were sized explicitly instead of suppressing their warnings. Expected values and maintenance-order assertions were not relaxed.

Makefile dùng chung chạy unit, bốn ca LOAD/store CBO, bốn ca CBO gốc, tám ca FENCE.I và lint TOP. Mỗi build dùng thư mục C++ mới. Runner CBO/audit trả lỗi nếu model còn warning; chỉ sửa biểu thức điều kiện scalar trong testbench, không nới oracle hoặc assertion.

## Files and rule evidence / File và bằng chứng rule

Production RTL: `rtl/common/vlsit/coherence/m_vlsit_riscv_coh_fabric.sv`; diff estimate 85/1194 lines = 7.12%. [Before snapshot](../../../verification/non_coherence_cluster/reports/e_to_m_fix/m_vlsit_riscv_coh_fabric_before.sv), [hash/results](../../../verification/non_coherence_cluster/reports/e_to_m_fix/results.json).

Other files: E→M unit test/runner/README; baseline and corner CBO testbench warning fixes/runners; shared Makefile; HDS clarification; audit/current-status documents. Existing FENCE.I test stimulus was unchanged.

Các file khác gồm unit test/runner, sửa warning testbench CBO, Makefile, mô tả HDS và trạng thái audit. Không đổi stimulus FENCE.I.

R-001/R-014: actual CPU runs and full TOP lint, not diagnostic-only evidence. R-008/R-018: approved fix scope with snapshots and source accounting. R-012/R-013: [rule check](rule_check.md) PASS, 0 errors; the existing HIE-02 style finding remains because this functional fabric contains instances and control, while the cluster TOP remains structural. This is not a waived lint warning. R-023/R-048: TEST-019/REQ-MEM-001 plus negative owner/writeback tests supplement the original CBO/FENCE contract checks. R-046: HDS records exclusive-permission versus actual cache-state refinement. R-047: directed checks only, no inferred code-coverage target. R-039/R-040: generated CSR untouched.

This closes A-01 only. The broader cluster audit's atomic/coherence, ordinary L1 eviction/error-retention, holder lifecycle, full-context victim escape and CSR/PMU integration items are not claimed resolved. Tests use the legal reduced simulation LLC; no synthesis, STA, PPA or complete ISA/coherence signoff is claimed.

Chỉ đóng A-01. Các mục atomic, eviction L1, vòng đời holder, escape khi hết context và kiểm chứng CSR/PMU trong audit rộng vẫn còn. Test dùng LLC mô phỏng giảm dung lượng; chưa tuyên bố signoff ISA/coherence, synthesis, STA hoặc PPA.
