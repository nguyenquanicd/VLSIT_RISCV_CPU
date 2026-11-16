# External CMO integration / Tích hợp external CMO

Production TOP: `m_vlsit_riscv_cluster_axi_top`, source [m_vlsit_riscv_cluster_axi_top.sv](../../../rtl/non_coherence_cluster/m_vlsit_riscv_cluster_axi_top.sv).

External CMO is enabled in the production core. Real CVA6 instructions traverse retirement → shared arbiter/controller → shared CCU context/line lock → native LLC maintenance → CCU COMMIT/ABORT ACK → CPU retire/trap. The test does not force DUT signals or inject internal completion pulses.

Core production đã bật external CMO. Instruction CVA6 thật đi qua retirement → arbiter/controller → context/lock CCU → LLC native → ACK COMMIT/ABORT → retire/trap. Test không force tín hiệu DUT hoặc giả lập completion nội bộ.

## Results / Kết quả

| Harts | Case / Trường hợp | Result | Cycles from reset release | Evidence |
|---|---|---|---|---|
| 2 | CLEAN / FLUSH / INVAL → retire | PASS | 724 | [log](../../../verification/non_coherence_cluster/reports/cmo_end_to_end/simulation_2h_error0.log), [VCD](../../../verification/non_coherence_cluster/reports/cmo_end_to_end/service_2h_error0.vcd) |
| 2 | SLVERR → ABORT → cause 7 | PASS | 603 | [log](../../../verification/non_coherence_cluster/reports/cmo_end_to_end/simulation_2h_error1.log), [VCD](../../../verification/non_coherence_cluster/reports/cmo_end_to_end/service_2h_error1.vcd) |
| 4 | CLEAN / FLUSH / INVAL → retire | PASS | 944 | [log](../../../verification/non_coherence_cluster/reports/cmo_end_to_end/simulation_4h_error0.log), [VCD](../../../verification/non_coherence_cluster/reports/cmo_end_to_end/service_4h_error0.vcd) |
| 4 | SLVERR → ABORT → cause 7 | PASS | 701 | [log](../../../verification/non_coherence_cluster/reports/cmo_end_to_end/simulation_4h_error1.log), [VCD](../../../verification/non_coherence_cluster/reports/cmo_end_to_end/service_4h_error1.vcd) |

Each hart stores `49 + hart_id` at `0x80001000 + 64 × hart_id`, then executes CLEAN, FLUSH and INVAL. The observer checks external-memory data at every CBO retirement. With injected memory writeback SLVERR, CLEAN never retires; each hart traps with `mcause=7`, `mepc=0x8000002c`, and `mtval` equal to its original effective address. Service monitors require PREPARE → LLC completion → terminal COMMIT/ABORT ACK before CPU completion, and count every hart's service/abort.

Mỗi hart ghi dữ liệu riêng rồi chạy ba CBO. Observer kiểm tra bộ nhớ ngoài ngay tại mỗi lần retire. Khi writeback trả SLVERR, CLEAN không retire; từng hart trap đúng cause, PC và VA gốc. Monitor kiểm tra thứ tự service và đếm completion/ABORT của từng hart.

| TOP harts | Error diagnostics | Warning diagnostics | LATCH | MULTIDRIVEN | Log |
|---|---|---|---|---|---|
| 2 | 0 | 0 | 0 | 0 | [top_lint_2h_20261115_153403.log](../../../lint/non_coherence_cluster/full_integration/top_lint_2h_20261115_153403.log) |
| 4 | 0 | 0 | 0 | 0 | [top_lint_4h_20261115_153424.log](../../../lint/non_coherence_cluster/full_integration/top_lint_4h_20261115_153424.log) |

Native lint invocations returned exit 0 with **zero warnings**, including `UNOPTFLAT`, width/range, latch and multiple-driver diagnostics. Existing tool arguments were retained; no new warning suppression or waiver was added. The runner now fails if any warning returns. See [lint status](../../../lint/non_coherence_cluster/cmo_end_to_end/lint_warning_disposition.txt) and [cleanup details](../lint_cleanup/README.md). This is RTL lint evidence, not timing, formal or tapeout signoff.

Lint hoàn tất với exit 0 và không còn warning; runner hiện trả lỗi nếu warning xuất hiện lại. Không thêm suppression hoặc waiver. Kết quả chưa thay thế STA, formal hoặc signoff tapeout.

## RTL changes / Thay đổi RTL

- CVA6/EX/LSU/store buffer: retain original VA/PA/op/PC; consume an externally completed CBO once; block younger retirement; hold completion during halt; defer interrupt/debug entry while owned; generate the precise terminal fault.
- HPDcache wrapper: retirement's store-empty condition also requires empty replay/MSHR and idle CPU pipeline. This fixes CLEAN racing a retired store whose refill/replay had not yet updated the cache. Native cache-internal write-buffer-empty remains separate to avoid a drain dependency cycle.
- Core, tile arrays and CMO arbiter: enable external CMO, retain ownership, and connect real CCU/LLC endpoints.
- CCU fabric: use native tagged contexts and locks, retain PREPARE until accepted, preserve status and directory ownership through ABORT, and release only after required terminal ACKs.
- LLC: per-line native tag/data/writeback service; commit clean/invalidate metadata only on success; preserve dirty data on error. Normal eviction retains its four-entry pending table and unrelated-set concurrency.
- Lint cleanup: license-preserving CVA6 MMU/TLB/FIFO copies default temporary combinational values; LLC `id_queue` declares its existing empty net; inactive tile tie-offs no longer index beyond active-hart vectors.

Các thay đổi giữ metadata và quyền sở hữu transaction đến completion; chờ store thật sự drain khỏi cache; nối service native; lỗi writeback đi qua ABORT trước trap. Bản reuse trong `rtl/common/third_party` được giữ nguyên; bản sửa nằm trong `rtl/common/modified` với license và history.

## Reproduce / Chạy lại

Run from `verification/non_coherence_cluster/cmo_end_to_end`:

```text
make focused
make all
```

The [single Makefile](../../../verification/non_coherence_cluster/cmo_end_to_end/Makefile) contains focused checks, success/error runs for 2/4 harts and TOP lint commands. `run.py` uses native Verilator code generation and direct g++ compilation, avoiding the local MSYS make runtime failure. Model objects stay under `C:/HQuan/.test_tmp/cmo_cpu_2h` and `cmo_cpu_4h`; committed evidence stays here.

Makefile chứa lệnh test khối, test đầu-cuối và lint. Build tạm ở `.test_tmp`; log và VCD lưu riêng khỏi source RTL.

Tools: Verilator 5.053 devel `v5.052-119-g014c9820d (mod)`, installed in `C:/Users/PC/Tools/oss-cad-suite`; g++ from `C:/Users/PC/Tools/msys64/ucrt64/bin`. The newer installed Verilator stalls during parameter elaboration; runners select the working version. [source_hashes.json](../../../verification/non_coherence_cluster/reports/cmo_end_to_end/source_hashes.json) records the delivered modified/VLSIT source hashes.

## Scope and rule evidence / Phạm vi và bằng chứng rule

The instruction tests instantiate the real production hierarchy with a reduced legal LLC geometry (4 ways × 64 lines × 16 bytes = 4 KiB), 64-bit memory AXI and a 64-KiB behavioral memory. Production TOP lint uses default 256-KiB LLC. Tests run in M-mode without address translation; per-hart data lines are distinct. These directed checks do not prove all sharing races, every bus width, virtual-memory faults, all backpressure patterns or full AXI4/ATOP compliance. Full protocol assertion coverage, the entire HDS waveform matrix, synthesis/PPA, formal proof and signoff remain outside these results. Code coverage was not requested.

Test instruction dùng LLC 4 KiB để giảm thời gian mô phỏng; lint dùng LLC mặc định 256 KiB. Test chạy M-mode, địa chỉ riêng từng hart. Chưa chứng minh toàn bộ race coherence, mọi bus width, MMU, backpressure hoặc AXI4/ATOP. Không đo code coverage theo lựa chọn directed checks đã duyệt.

R-012: [rule_check.txt](../../../lint/non_coherence_cluster/cmo_end_to_end/rule_check.txt), 36 VLSIT modules, 0 errors, 22 warnings, 2 informational notices. HIE-02 warnings identify functional adapters, not the structural cluster TOP; NAM-08 warnings retain approved public names and matching instance names. COM-04 information marks existing full-case don't-care defaults. Licensed modified upstream sources retain their native coding conventions per the user's instruction; they are linted in the complete hierarchy.

R-001/R-014/R-016: results and limits are explicit above. R-008: approved plan V4 and later approved CBO policy A. R-009: pristine third-party sources retained. R-010/R-022: verification sources remain separate. R-023: architectural CBO behavior and HDS maintenance contracts form expected results; hierarchy references only observe service/retirement and architectural CSRs. R-024/R-025: this focused instruction bench is not a complete per-protocol assertion suite. R-033: sampled service VCDs are saved; a complete HDS waveform comparison is not claimed. R-047: directed checks only. [manual_rules.txt](../../../lint/non_coherence_cluster/cmo_end_to_end/manual_rules.txt) lists the checker/manual boundary; a full tapeout checklist is not claimed.
