# RTL lint cleanup / Sửa cảnh báo lint RTL

The production `m_vlsit_riscv_cluster_axi_top` now completes lint with **0 errors and 0 warnings** at both 2 and 4 harts. Baseline counts were 565 and 564 warnings. Tool/version and diagnostic flags are unchanged; no new warning-disable pragma, suppression option or waiver was added. The lint runner now fails when any warning appears.

TOP production hiện lint với **0 lỗi và 0 warning** ở cả 2/4 hart, giảm từ 565/564 warning. Không thêm pragma tắt warning, tùy chọn suppression hoặc waiver. Runner hiện trả lỗi nếu có warning.

| Configuration / Cấu hình | Before / Trước | After / Sau | Final log |
|---|---|---|---|
| 2 harts | 565 warnings | 0 errors, 0 warnings | [lint 2h](../../../lint/non_coherence_cluster/full_integration/top_lint_2h_20261115_153403.log) |
| 4 harts | 564 warnings | 0 errors, 0 warnings | [lint 4h](../../../lint/non_coherence_cluster/full_integration/top_lint_4h_20261115_153424.log) |

## Fixes / Các sửa đổi

- **UNOPTFLAT:** separated AXI channel payload/VALID from isolation state transitions and READY; separated selected B/R validity from packed response construction; moved LLC descriptor payload selection outside READY-dependent control. HPDcache refill response availability now has its own state-based expression. Decoder exception and CSR opcode/payload generation no longer depend on packed outputs or access-fault retirement feedback. No pipeline register or latency was added.
- **Width/range:** explicitly sized arithmetic, sign/zero extensions, AXI burst addresses, CSR words, masks and port connections. Constant-disabled second-issue/third-operand branches use legal indices. HPDcache word/pointer widths are at least one bit when the upsizer ratio or depth is one.
- **Packed-array direction:** changed FPU pipeline/format dimensions to descending ranges. Format encodings, feature masks, unit types and pipeline latencies use enum-indexed configuration bindings, preserving the selected logical format and stage. Tests compare against a separate original FPnew package and original modules.
- **Other diagnostics:** used Boolean parameter types, explicit constant-boundary cases, string SRAM initialization modes and complete existing ATOP fallback cases. The approved CVXIF-disabled tile uses scalar inactive CVXIF boundary types, so the unused standard field named `register` is not elaborated into this cluster.

Đã tách các đường payload/VALID khỏi READY và logic trạng thái; sửa sizing, select vượt phạm vi và width bằng 0; chuyển mảng packed FPU sang chiều giảm dần với cấu hình gắn rõ theo enum. Không thêm tầng pipeline. Các sửa đổi còn lại làm rõ kiểu parameter, trường hợp biên và nhánh mặc định hiện có.

Internal FPnew packed-mask representation has changed. All cluster bindings were updated; external cluster ports and parameters are unchanged. A standalone consumer of the modified FPnew package should use enum-indexed masks instead of assuming the original positional bit pattern.

Biểu diễn mask packed nội bộ FPnew đã đổi; mọi kết nối trong cluster đã cập nhật. Cổng và parameter ngoài cluster giữ nguyên. Nếu dùng riêng package FPnew đã sửa, nên cấu hình mask theo enum thay vì dùng vị trí bit cũ.

## Verification / Kiểm chứng

| Check / Kiểm tra | Result / Kết quả | Evidence |
|---|---|---|
| Real CVA6 CLEAN/FLUSH/INVAL, 2 and 4 harts | PASS; 3 retired CBOs per hart | [instruction logs and VCDs](../cmo_end_to_end/README.md) |
| Real CVA6 SLVERR → CCU ABORT → precise trap, 2 and 4 harts | PASS; cause 7, original PC/VA, no CBO retirement | [instruction logs and VCDs](../cmo_end_to_end/README.md) |
| CSR/retirement differential | PASS, 20,000 cycles | [log](../../../verification/common/reports/lint_cleanup/csr_payload/simulation.log) |
| AXI isolation differential | PASS, 10,000 cycles | [log](../../../verification/common/reports/lint_cleanup/isolate/simulation.log) |
| ALU differential, 32/64-bit | PASS, 200,000 cases; bitmanip/crypto/conditional logic enabled in the test | [log](../../../verification/common/reports/lint_cleanup/alu/simulation.log) |
| FMA differential, FP32/FP64 | PASS, 20,000 cycles | [log](../../../verification/common/reports/lint_cleanup/fpu_fma/simulation.log) |
| Non-computational FPU differential, FP32/FP64 | PASS, 20,000 cycles | [log](../../../verification/common/reports/lint_cleanup/fpu_noncomp/simulation.log) |
| Conversion differential | PASS, 20,000 cycles | [log](../../../verification/common/reports/lint_cleanup/fpu_cast_multi/simulation.log) |
| Full CVA6 FPU wrapper differential | PASS, 1,600 transactions: 16 operations in both FP32/FP64; result, status, tag and cycle timing | [log](../../../verification/common/reports/lint_cleanup/wrap/simulation.log) |
| Retirement hold/interrupt deferral/precise error | PASS | [log](../../../verification/common/reports/lint_cleanup/retirement.log) |
| LLC table-full escape and 15-entry allocation wraparound | PASS | [log](../../../verification/common/reports/lint_cleanup/llc_pending.log) |
| VLSIT rule checker | 0 errors; 22 existing style advisories, 2 information notices | [rule report](../../../lint/common/lint_cleanup/rule_check.txt) |

The differential checks are regression comparisons, **not specification golden models or formal equivalence proofs**. Independent architectural CBO expectations remain in the instruction bench. These results cover the selected RV64 cluster and FP32/FP64 paths; they do not establish complete ISA/AXI compliance, all optional FP formats, every bus width, synthesis timing or tapeout signoff. Code coverage was not requested.

So sánh vi sai là regression với bản trước sửa, không thay thế golden model từ specification hoặc formal equivalence. Test CBO vẫn kiểm tra kết quả kiến trúc độc lập. Kết quả chưa chứng minh toàn bộ ISA/AXI, mọi format FPU tùy chọn, bus width, timing hoặc signoff. Không đo code coverage theo lựa chọn directed checks đã duyệt.

An initial wrapper test incorrectly randomized the FCLASS funct3 field into the disabled FP16ALT selector. Both original and modified wrappers waited identically. The stimulus now uses legal FCLASS funct3 `001`; RTL was not changed for that test failure. The diagnostic is preserved in [invalid_fclass_rm_diagnostic.log](../../../verification/common/reports/lint_cleanup/wrap/invalid_fclass_rm_diagnostic.log).

Test wrapper ban đầu đưa mã FCLASS không hợp lệ sang format FP16ALT đã tắt; cả hai bản đều chờ như nhau. Đã sửa stimulus về funct3 `001`, không sửa RTL để né lỗi test. Log chẩn đoán được giữ tại liên kết trên.

## Reproduce / Chạy lại

Run from `verification/non_coherence_cluster/cmo_end_to_end` using its [Makefile](../../../verification/non_coherence_cluster/cmo_end_to_end/Makefile):

```text
make refactor
make alu-refactor
make fpu-refactor
make fpu-wrapper
make retirement pending
make all
```

Commands include native Verilator generation and g++ compilation. Fresh build directories under `C:/HQuan/.test_tmp` prevent obsolete generated C++ specializations from entering later builds. Logs and testbenches remain in the project.

Lệnh chạy dùng Verilator và g++ native. Mỗi build dùng thư mục mới trong `.test_tmp`, tránh biên dịch nhầm C++ cũ sau khi specialization thay đổi. Log và testbench vẫn lưu trong dự án.

## Sources and rules / Nguồn và rule

[source_changes.md](source_changes.md) lists all 67 changed RTL files and line counts; [source_changes.json](../../../verification/common/reports/lint_cleanup/source_changes.json) records baseline/final hashes. Pre-change snapshots are under `../full_integration/source_snapshots/lint_cleanup_20261115`. Original upstream files in `rtl/common/third_party` were retained. Modified copies retain their licenses and add history attributed to **Quan Nguyen and Codex - VLSI Technology page**.

Danh sách file và hash nằm trong hai liên kết trên. Nguồn upstream giữ nguyên; bản sửa giữ license và thêm history. Registry `rtl/lint_source_overrides.json` maps original sources to local copies; lint, simulation and filelist generation apply it automatically.

R-001/R-014: verified logs above; no new diagnostic suppression. R-008/R-009: user-authorized repair, snapshots and retained originals. R-012/R-016: VLSIT mechanical rule result is separate from native lint; HIE-02 functional-adapter and NAM-08 approved-name advisories remain documented in the rule report. R-023: differential regressions supplement the specification-derived CBO test. R-047: directed checks only. Native modified sources retain upstream coding conventions as requested.
