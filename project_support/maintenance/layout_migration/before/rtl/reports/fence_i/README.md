# FENCE.I DEC-030/031 — RTL and verification / RTL và kiểm chứng

2026-11-15. TOP: `m_vlsit_riscv_cluster_axi_top`.

**EN:** Completed the selected FENCE.I path: CVA6 retirement → HPDcache dirty-line walker → shared arbiter → CCU PREPARE → owner AXI write to native LLC → COMMIT/ABORT ACK → retirement/trap. Success cleans M→E, waits for local I-cache invalidation ACK and flushes the fetch pipeline at retirement. No FENCE.I-triggered external-memory write is permitted. Error retains M and directory ownership, completes ABORT first, then raises precise cause 24 with the FENCE.I PC and aligned physical line base. Software MRET/SRET retry succeeds after the modeled write-path recovery.

**VI:** Đã hoàn tất đường FENCE.I được chọn: retirement CVA6 → walker dirty line HPDcache → arbiter → CCU PREPARE → owner ghi AXI vào LLC thật → ACK COMMIT/ABORT → retire/trap. Khi thành công, clean M→E, chờ ACK invalidate I-cache rồi flush fetch khi retire; không ghi xuống DRAM do FENCE.I. Khi lỗi, giữ M và directory owner, chờ ABORT hoàn tất rồi mới trap cause 24 với PC FENCE.I và physical line base. Retry bằng MRET/SRET thành công sau khi mô hình đường ghi phục hồi.

## Fault fixed / Lỗi đã sửa

**EN:** CVA6's internal `DEBUG_REQUEST` has numeric value 24. A plain cause-24 exception entered debug rather than updating architectural trap CSRs; this reproduced as a real-instruction watchdog failure. The CSR unit now receives explicit maintenance-fault provenance. Cause 24 follows normal M/S trap routing; ordinary debug requests retain the original behavior. `medeleg[24]` is writable. A focused retirement test checks older-store drain, held payload, interrupt deferral, retained completion during halt, precise cause/PA, and waiting for I-cache ACK.

**VI:** Pseudo-exception `DEBUG_REQUEST` của CVA6 có mã 24. Nếu chỉ phát cause 24, core vào debug thay vì cập nhật CSR trap; test instruction thật đã tái hiện lỗi bằng watchdog. CSR unit nay có tín hiệu phân biệt maintenance fault; cause 24 đi theo đường trap M/S, debug thông thường giữ đường gốc. Cho phép ghi `medeleg[24]`. Test retirement riêng kiểm tra drain store cũ, giữ payload, hoãn interrupt, giữ completion khi halt, cause/PA chính xác và chờ ACK I-cache.

## Measured results / Kết quả đo

| Harts | Trap privilege | Inject L1→LLC B error | Result | Total test cycles |
|---:|---|---|---|---:|
| 2 | M | 0 | PASS | 938 |
| 2 | M | 1 | PASS | 1020 |
| 2 | S (delegated) | 0 | PASS | 1063 |
| 2 | S (delegated) | 1 | PASS | 1145 |
| 4 | M | 0 | PASS | 1015 |
| 4 | M | 1 | PASS | 1163 |
| 4 | S (delegated) | 0 | PASS | 1140 |
| 4 | S (delegated) | 1 | PASS | 1288 |

Cycles include boot, priming, program execution and handler/retry; they are not FENCE.I latency or IPC measurements. / Số chu kỳ gồm boot, prime code, chương trình và handler/retry; không phải latency FENCE.I hoặc IPC.

- Each active hart executes old instruction value 1, patches it through D-cache, then executes new value 2 after FENCE.I.
- Fault cases check one ABORT preserving M, precise M/S trap CSRs and one successful COMMIT E on retry.
- All eight logs report 20 exercised L1→LLC AXI checks, zero assertion failures and zero unexercised assertions.
- [Native retirement test](retirement.log): PASS, including explicit I-cache completion retention.
- Production TOP lint: [2 harts](../full_integration/top_lint_2h_20261115_165846.log), [4 harts](../full_integration/top_lint_4h_20261115_165846.log): **0 errors, 0 warnings**, no latch or multiple-driver diagnostics.
- [Actual WF-019 VCD / WaveJSON / SVG comparison](../../verification/fence_i_end_to_end/waveforms_sim/waveform_compare.md): eight MATCH cases. SVG columns show actual event times with nonuniform spacing.

VI: Mỗi hart thực thi mã cũ, sửa instruction qua D-cache rồi thực thi mã mới sau fence. Các ca lỗi kiểm tra ABORT giữ M, CSR trap M/S chính xác và COMMIT E khi retry. Tất cả tám ca pass, 20 kiểm tra AXI đều được kích hoạt; lint TOP 2/4 hart có 0 lỗi và 0 warning. Waveform ghi thời gian thực, không giả định latency cố định.

## Modified RTL / RTL đã sửa

Pristine `rtl/third_party` files were not edited. Licensed copies keep the original notices and add dated history naming Quan Nguyen and Codex - VLSI Technology page. / Không sửa nguồn gốc trong `rtl/third_party`; bản sao sửa giữ thông báo license và bổ sung history.

| File | Changed lines / before lines |
|---|---:|
| [`rtl/modified/cva6/core/cache_subsystem/cva6_hpdcache_subsystem.sv`](../../../rtl/modified/cva6/core/cache_subsystem/cva6_hpdcache_subsystem.sv) | 22 / 686 |
| [`rtl/modified/cva6/core/cache_subsystem/cva6_hpdcache_wrapper.sv`](../../../rtl/modified/cva6/core/cache_subsystem/cva6_hpdcache_wrapper.sv) | 20 / 532 |
| [`rtl/modified/cva6/core/cache_subsystem/cva6_icache.sv`](../../../rtl/modified/cva6/core/cache_subsystem/cva6_icache.sv) | 4 / 604 |
| [`rtl/modified/cva6/core/cache_subsystem/cva6_icache_axi_wrapper.sv`](../../../rtl/modified/cva6/core/cache_subsystem/cva6_icache_axi_wrapper.sv) | 4 / 214 |
| [`rtl/modified/cva6/core/cache_subsystem/wt_cache_subsystem.sv`](../../../rtl/modified/cva6/core/cache_subsystem/wt_cache_subsystem.sv) | 4 / 291 |
| [`rtl/modified/cva6/core/commit_stage.sv`](../../../rtl/modified/cva6/core/commit_stage.sv) | 39 / 618 |
| [`rtl/modified/cva6/core/controller.sv`](../../../rtl/modified/cva6/core/controller.sv) | 6 / 277 |
| [`rtl/modified/cva6/core/csr_regfile.sv`](../../../rtl/modified/cva6/core/csr_regfile.sv) | 9 / 3244 |
| [`rtl/modified/cva6/core/cva6.sv`](../../../rtl/modified/cva6/core/cva6.sv) | 55 / 2196 |
| [`rtl/modified/hpdcache/rtl/src/hpdcache.sv`](../../../rtl/modified/hpdcache/rtl/src/hpdcache.sv) | 33 / 1588 |
| [`rtl/modified/hpdcache_cva6_pinned/rtl/src/hpdcache_cmo.sv`](../../../rtl/modified/hpdcache_cva6_pinned/rtl/src/hpdcache_cmo.sv) | 80 / 494 |
| [`rtl/vlsit/m_vlsit_riscv_cmo_controller.sv`](../../../rtl/vlsit/m_vlsit_riscv_cmo_controller.sv) | 8 / 255 |
| [`rtl/vlsit/m_vlsit_riscv_coh_fabric.sv`](../../../rtl/vlsit/m_vlsit_riscv_coh_fabric.sv) | 18 / 1181 |

Change estimate: 302/12180 = 2.48% (sum of max(old-span,new-span) per changed diff block). [Exact source hashes](changed_files.json), [before snapshots](before/).

Other updates / Cập nhật khác: source override registry and regenerated production filelists; the FENCE.I testbench, AXI fault BFM, runner, evidence collector; the existing single replay Makefile; retirement testbench; HDS/port plan and READMEs. Generated CSR RTL was not changed.

## Replay / Chạy lại

```powershell
cd C:\HQuan\102_MyGithub\VLSIT_RISCV_CPU\rtl\verification\cmo_end_to_end
make fence
```

[Single replay Makefile](../../verification/cmo_end_to_end/Makefile), [testbench guide](../../verification/fence_i_end_to_end/README.md). Fresh build directories prevent stale generated C++ from entering a model. Verilator 5.053 (working OSS CAD Suite build) and native MSYS g++ are used.

## Rules and limits / Rule và giới hạn

| Rule / check | Evidence and scope |
|---|---|
| R-001, R-014 | Actual native CPU simulations and full production TOP lint; no suppressed new diagnostics. |
| R-003, R-008, R-009, R-018 | Existing approved DEC-030/031 scope; incremental edits, snapshots, licensed history; VLSIT style for VLSIT modules only, per user instruction. |
| R-012, R-013 | [CMO rules](cmo_rules.md): 0 errors; NAM-08 keeps the approved existing `o_cmo_error`/`i_maint_error` API. [CCU rules](ccu_rules.md): 0 errors; HIE-02 is a functional fabric containing both instances and control, not the structural cluster TOP. |
| R-017 | Production filelists resolve licensed copies through `rtl/lint_source_overrides.json`; TOP lint elaborates the full hierarchy. |
| R-023–025, R-033 | TEST-041/042, actual ISA code, 20 exercised AXI checks, maintenance ordering and architectural checks; saved WF-019 evidence. AXI4-Lite/MMIO are idle and are outside this focused protocol test. |
| R-027, R-034 | No new CDC or simulation-only logic was added to production RTL. This run uses one cluster clock; no metastability or CDC signoff claim. |
| R-039/R-040 | CSR generator output untouched. |
| R-046, R-047 | HDS implementation clarification updated; directed functional checks only, no code coverage measurement. |

**EN:** The simulation model uses a legal reduced 4 KiB LLC; production lint uses the default 256 KiB. Each hart dirties one code line; sparse/full-cache walks and reset during maintenance are not exercised. S-mode tests use bare address translation with PMP access; Sv39 page-table walks, Linux, sustained random concurrency, formal coherence, synthesis, STA and PPA are not signoff-tested here. The two FPnew `UNOPTFLAT` diagnostics were subsequently fixed in RTL; both native simulation models and production TOP lint now report zero warnings. See the [FPU follow-up report](../fpu_warning_fix/README.md) for the two additional licensed source changes and independent preservation tests. AXI checks are targeted to the exercised transfers, not full protocol compliance; Verilator does not provide four-state X propagation. Native debug request behavior is preserved by source inspection; an external debugger session was not tested. ACKs have no timeout by the selected contract. Earlier watchdog diagnostics are retained as investigation evidence, not passing tests.

**VI:** Mô phỏng dùng LLC hợp lệ 4 KiB; lint production dùng 256 KiB mặc định. Test S-mode dùng bare translation và PMP; chưa signoff Sv39 page walk, Linux, concurrency ngẫu nhiên dài, formal coherence, synthesis, STA hay PPA. Hai chẩn đoán FPnew `UNOPTFLAT` đã được sửa ở RTL trong bước tiếp theo; model mô phỏng và lint TOP production đều có 0 warning. [Báo cáo FPU](../fpu_warning_fix/README.md) liệt kê hai bản sao RTL sửa thêm và test bảo toàn hành vi. Kiểm tra AXI tập trung vào giao dịch đã chạy, chưa phải chứng nhận toàn giao thức; Verilator không kiểm tra X bốn trạng thái. Chưa test debugger ngoài. ACK không timeout theo quyết định đã chọn. Log watchdog cũ là bằng chứng điều tra, không được tính pass.
