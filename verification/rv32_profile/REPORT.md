# RV32 profile testbench - status report, 2026-11-26 (rev 2, after DEC-046/047)

Source of every check: `doc/specification_32/VLSIT_RISCV32_DUAL_QUAD_CPU_CLUSTER_HDS.md` rev 0.1, the RISC-V ISA and AMBA AXI4 (IHI 0022H). Expected values come from `tests.py` (independent Python oracle). Simulator: Verilator 5.053 (`--timing --assert`), DUT `rtl/rv32_profile/filelist_rv32.f`, SVA bind `verification/rv32_profile/sva/`.

## 1. Results, 2 harts, timing profile 0

| Testcase | Spec tests | Result | Checks passed / failed | Waveform (`runs/<tc>_rv32_2h_p0/wave.vcd`, SHA-256 prefix) |
|---|---|---|---|---|
| TC-01 boot, identity, misa, RV64-only traps | 101, 102, 103 | **PASS** | 34 / 0 | f397354c426d1ffc |
| TC-02 RV32 integer, M, B, Zcb, Zicond, counters | 101, 113 | **PASS** | 78 / 0 | 111daae32555885c |
| TC-03 F single precision, fflags, D rejected | 104 | **PASS** after DEC-106 (section 3) | 76 / 0 | 2997c045e9a76c8c |
| TC-04 cached sharing, AXI address width | 106, 107, 109 | **PASS** | 12 / 0 | 5b9f044a34fec875 |
| TC-05 dirty-owner transfer (WF-101) | 107, 109, 112 | **PASS** | 9 / 0 | 494931516246205b |
| TC-06 LR.W/SC.W and AMO*.W across harts | 103, 112 | **PASS** | 17 / 0 | 3d124d10d57d742e |
| TC-07 CBO and FENCE.I | 112 | **PASS** | 15 / 0 | 02f63ec29d91a59e |
| TC-08 Sv32, S/U modes, page faults | 105 | **PASS** | 18 / 0 | d1d24238439dde19 |
| TC-09 MMIO order and protocol | 106, 110 | **PASS** | 7 / 0 | 55f17ec8b819c2e4 |
| TC-10 boot address upper half | 108 | **PASS** | 6 / 0 | 13589b9b5321ae6c |

Waveforms of TC-01, 02, 04, 05, 06, 08, 09 and 10 rerun on 2026-11-26 with the DEC-106 divider are bit-identical to the 2026-11-25 runs (same SHA-256), so the change did not alter those paths. TC-07 has three more marker checks than on 2026-11-25.

Test defects found and fixed during bring-up (the RTL was not changed): TC-02 wrote `minstret` before `minstreth`, so the carry happened during the high write; TC-08 lacked a PMP entry for S/U accesses (Privileged ISA 3.7) and stored one page-table entry with an out-of-range offset; the TC-08 oracle used physical instead of virtual `mepc` for U-mode traps. The encoder now rejects out-of-range load/store offsets.

## 2. Assertions

46 counted AXI4 assertions (23 on the memory port, 23 on the MMIO port) plus SVA-101 to SVA-103. Over the nine passing runs: 0 failures. Never hit: the 8 WRAP-burst rules (MEM-10..13, MMIO-10..13), because the DUT issued only INCR bursts; they are scenario-inapplicable and not required. Write-side memory rules are required only in TC-07 (CBO writes to DRAM) and MMIO read rules only in TC-09; both runs hit them.

## 3. TC-03 failure, root cause and fix (DEC-106, approved 2026-11-26)

Resolved. Rerun on 2026-11-26 after the fix: TC-01 to TC-10 PASS on 2 harts, TC-03 PASS on 4 harts (152 / 0). The original analysis follows; the confirmed root cause and the fix are in the specification Section 14.5.

| Item | Content |
|---|---|
| Failure | TC-03, hart 0 and 1: FDIV.S 7.0/2.0 returns `7fc00000` (canonical NaN), expected `40600000`; FSQRT.S 16.0 returns NaN, expected `40800000`; FDIV.S 1.0/3.0 returns NaN, expected `3eaaaaab`; fflags after the exact operations reads `01`, expected `00`. FADD.S, FMUL.S, FCVT.W.S and FLT.S on the same operand registers are correct, and FADD.D traps as required |
| Specification | REQ-XL-004: F without D, FLEN=32; IEEE 754 binary32 results (RISC-V F extension) |
| RTL | `fpu_wrap` instantiates `fpnew_top` with the default `DivSqrtSel = THMULTI` (C910 64-bit divider). In `fpnew_divsqrt_th_64_multi.sv:357-358` (same as upstream `third_party/cvfpu`, lines 353-354) the FP32 operands are zero-extended to 64 bits: `{{(64-WIDTH){1'b0}}, srcf0_q}`. With FLEN=32 (WIDTH=32) the C910 unit receives single-precision values without NaN boxing, which is the likely reason it returns canonical NaN. The 64-bit profile is not affected because WIDTH=64 there |
| Test | Operands are loaded with FMV.W.X; expected values are exact binary32 results from Python `struct` |
| Candidates | A. RTL/config defect for FLEN=32 with the THMULTI divider (evidence: div/sqrt fail, add/mul pass on the same registers; zero extension at the C910 input). B. Test defect (unlikely: same operands give correct add/mul). C. Specification: DEC-102 chose RVD=0, a combination the repository never ran before |
| Root cause (confirmed 2026-11-26) | `ct_vfdsu_prepare.v:330-331, 370-377`: for single format the C910 unit marks an operand as canonical NaN when bits 63:32 are not all ones (RISC-V NaN boxing). Zero extension fails this check for every operand |
| Fix | Option 1, in `rtl/rv32_profile/cvfpu/fpnew_divsqrt_th_64_multi.sv:360-361`, RV32 filelist line 70 repointed; lint clean for 2/4 harts and profiles 0/1/2 (`rtl/rv32_profile/lint/v3_*.log`) |
| Test defect found in the rerun | `fflags.exact` was read after FCVT.W.S 3.75 (RTZ), which is inexact and sets NX; the check now runs before the conversion and a new `fcvt.w.s.flags` check expects NX |
| Test strengthened | 13 divide/square-root cases, each result checked with its own fflags (DZ, NV, NX; RNE/RTZ/RDN/RUP); oracle `f32_round` uses exact rational arithmetic |
| Options (as proposed) | 1 (recommended, chosen): in a copy under `rtl/rv32_profile/`, NaN-box the operands for WIDTH<64 (`{{(64-WIDTH){1'b1}}, srcf}`, 2 lines), then rerun TC-03. 2: select `DivSqrtSel = TH32` (E906 32-bit divider, already in the filelist) when FLEN=32, by changing the `fpnew_top` instance in a copy of `fpu_wrap.sv`. 3: set RVD=1 (FLEN=64) in the RV32 package, reversing DEC-102 |

## 3b. Results, 4 harts, timing profile 0

| Testcase | Result | Checks passed / failed |
|---|---|---|
| TC-01 | PASS | 68 / 0 |
| TC-02 | PASS | 156 / 0 |
| TC-04 | PASS | 36 / 0 |
| TC-05 | PASS | 9 / 0 |
| TC-06 | PASS | 33 / 0 |
| TC-03 | PASS (after DEC-106, 2026-11-26) | 152 / 0 |
| TC-07 | **FAIL (hang)** | see below |
| TC-08 | PASS | 36 / 0 |
| TC-09 | PASS | 7 / 0 |
| TC-10 | PASS | 12 / 0 |

TC-07 with 4 harts, analysis for the designer (rule R-026, no RTL change):

| Item | Content |
|---|---|
| Failure | Watchdog: hart 0 stops inside its CBO sequence (lines A, B, C at 0x8001_5000..0x8001_5080) and never reports again; the stop point moves between runs (after CBO.CLEAN in one run, after CBO.FLUSH in another), so it depends on timing. Harts 1-3 spin in a barrier (AMOADD.W then LW loop on line 0x8001_5100) |
| Diagnostic | Same program with only harts 0 and 1 in the barrier (harts 2 and 3 idle): **PASS** (`runs/TC-07_diag_part2_4h`). With 2 harts total: PASS |
| Specification | REQ-MEM-017/018 (CBO completes), REQ-MEM-024 and base OPEN-PROBE-FAIR / PD-08: the atomic all-slot probe claim has no aging rule, so a context can wait while other claims keep taking slots |
| Candidates | A. Starvation or deadlock in the CMO/CCU path when three or more harts contend on a line during a CBO (matches the open aging item; not proven). B. RV32-specific: no evidence; the same scenario has not been run on the 64-bit cluster. C. Test: the program is legal; a CBO must complete regardless of other harts' traffic |
| Next step (2026-11-25) | Run the same scenario on the 64-bit 4-hart cluster to see whether it is profile-independent, then trace the CCU context and probe-slot claims in the waveform |

### 3c. Step 2a result: the TC-07 hang is in the base 64-bit cluster (2026-11-26)

Same testbench and same program built for the original 64-bit cluster (`python run.py build --xlen 64`, filelist `rtl/non_coherence_cluster/filelist.f`, `cv64a6_imafdc_sv39_hpdcache_wb`; the RV32 SVA bind and the faults are left out because they use RV32 tile signals). In 64-bit mode the encoder zero-extends addresses in the DRAM window after LUI (`asm_rv32.py`, `li`), because LUI sign-extends on RV64; no compressed or XLEN-dependent instruction is used by TC-04 to TC-07.

| Run | Harts in the barrier (`TC07_PART`) | Result | Folder |
|---|---|---|---|
| 64-bit, 2 harts, TC-04/05/06/07 (baseline of the 64-bit mode) | 2 | PASS 12/9/17/15 | `runs/TC-0x_rv64_2h_p0` |
| 64-bit, 4 harts | 4 | **FAIL, hang** (hart 0 stops after CBO.CLEAN of line A; line B never written back) | `runs/TC-07_rv64_4h_p0` (VCD `16296a4f7cbd955b`) |
| 64-bit, 4 harts, 3 000 000-cycle limit | 4 | **FAIL, same stop point** | `runs/TC-07_rv64_4h_long` |
| 64-bit, 4 harts | 2 | PASS 15/0 | `runs/TC-07_rv64_4h_part2` |
| 64-bit, 4 harts | 3 | PASS 15/0 | `runs/TC-07_rv64_4h_part3` |
| RV32, 4 harts | 3 | PASS 15/0 | `runs/TC-07_rv32_4h_part3` |

Findings:
- The hang is **not RV32-specific**: the original 64-bit cluster stops at the same point. It needs hart 0 running the CBO sequence while **three** other harts spin on the barrier line (AMOADD.W then LW loop); two spinning harts pass.
- It is a **deadlock, not slow progress or starvation**: in the 3 000 000-cycle run every DUT output and every tapped probe/grant signal is constant after cycle 810 (only testbench ready signals toggle). The last coherence activity is the CBO.CLEAN of line A: probe of tile 0 at cycle 637, write-back of line A at cycles 660-667 (data in DRAM is correct), phase-1 probe at cycle 673. Hart 0 then stores to line B and issues CBO.FLUSH, which never produce a probe or a write. A starvation (missing aging rule, OPEN-PROBE-FAIR / PD-08) would show continuous probe traffic, so that hypothesis is weakened, not excluded.
- Severity: affects the 64-bit product with 4 harts (PARA_CPU_NUM=4 is the default).

Next (step 2b): rebuild with taps on tiles 2 and 3, the CCU contexts (txn_table), the probe scheduler slot claims, the line locks and the CMO controller, and read the state at cycle 810 to find which agent waits for which.

### 3d. Step 2b result: root cause of the TC-07 hang (2026-11-26)

Method: debug build with full waveform (`VLSIT_TB_TRACE_DEPTH=99 python run.py build --harts 4 --xlen 64`), final state of every signal at the hang, wait-for chain traced through the fabric, the tile adapters and the HPDcache of each tile. Two defects were found, both in the coherent-atomic additions (DEC-038) to the HPDcache of the base cluster. Each was confirmed by a simulation-only experiment that forces one HPDcache net (`tb/tb_experiments_rv64.svh`, `+EXPERIMENT=<n>`); no RTL file was changed.

**Defect 1 - an AMO takes "atomic permission" on a Shared grant.** `rtl/common/modified/hpdcache/rtl/src/hpdcache.sv:648-649` drives `coh_atomic_grant_i` for every ownership grant whose state is not I, so a Shared grant counts. `hpdcache_ctrl.sv:926-928` then sets `atomic_permission_q`, and `hpdcache_ctrl.sv:1171-1172` reports the line busy to every probe until the AMO completes. The AMO cannot complete from S: it requests unique ownership, which the fabric serializes behind the competing context on the same line, whose PREPARE probe is the one being refused. The 64-bit HDS (S-to-M upgrade / AMO hit in S row, DEC-038) requires the opposite: "older probes may complete before that grant".

| Cycle | Wait-for chain at the hang (first deadlock, no experiment) |
|---|---|
| 630 | Context 0: hart 3 requests unique ownership of the barrier line 0x8001_5100 (sharers: tiles 1 and 2) |
| 637 | Tile 2, whose AMOADD missed at cycle 572, receives a **Shared** grant for the same line; `atomic_permission_q` = 1 at 638 |
| 645 | PREPARE probe of context 0 reaches tile 2; `coh_probe_pipeline_busy` = 1 (atomic permission term), the adapter refuses it |
| 656 | Tile 2 requests unique ownership for its AMO; the fabric does not allocate it (same-line context 0 active), and the single allocation port also blocks hart 0's request for line B (cycle 696), so hart 0 stops after CBO.CLEAN |

**Defect 2 - the RTAB fence drops while the fenced AMO is still in the RTAB.** `hpdcache_rtab.sv:250, 261, 452` (upstream logic): `fence_o` is high only while some entry has its `pend_trans` dependency, and `pend_trans` clears only when every valid entry is fenced (`fence_only`). When the AMO's dependency clears, the controller accepts core requests again although the AMO is still in the RTAB; a younger load to the same line is linked behind it. The coherent AMO then needs a second (unique) ownership request and is rolled back with `pend_trans` again. From then on `fence_only` is false forever (the linked load is valid and not fenced) and the load cannot run before the AMO. Upstream never re-fences an AMO after a refill, so the gap is reachable only with the DEC-038 cached-AMO path.

| Cycle | Tile 2 with experiment 1 (defect 1 removed) |
|---|---|
| 572 | AMOADD misses, RTAB entry 0 with `pend_trans`; core requests blocked |
| 637 | Shared grant; 655: `pend_trans` cleared, `rtab_fence` = 0, a load is accepted |
| 656-657 | The load (same line) is allocated as RTAB entry 1, linked after entry 0 |
| 664 | Entry 0 (AMO) replays, needs unique ownership, rolled back with `pend_trans` again |
| 743-756 | Grant M, MSHR empty, but `pend_trans` never clears (`valid_q`=0b11, `fence_bv`=0b01); atomic permission keeps refusing the probe of hart 3's request on the same line |

| Run (64-bit, 4 harts) | Result |
|---|---|
| No experiment | TC-07 hang after CBO.CLEAN (defect 1) |
| `+EXPERIMENT=1` (permission only on E/M grant) | Hang moves later, after CBO.FLUSH (defect 2) |
| `+EXPERIMENT=2` (1 + fence held while an AMO entry is in the RTAB) | **TC-07 PASS 15/0**; also with 2 and 3 harts in the barrier; TC-04, 05, 06, 09, 10 PASS |

Why 4 harts: the hang needs a hart whose AMO received a Shared grant while another hart's unique request on the same line is in PREPARE; with three spinning harts this overlap happens in TC-07, with two it does not. The defects are timing races and are not limited to 4 harts.

Proposed fix (step 2c, needs the designer's approval of a change plan): F1, `hpdcache.sv`/`hpdcache_ctrl.sv`: grant atomic permission only for an E or M grant (keep S for LR, as the initial-hit rule does). F2, `hpdcache_rtab.sv`: keep `fence_o` high while any fence-type entry (AMO, uncacheable, CMO) is valid in the RTAB, with a per-entry fence flag recorded at allocation, which is the behavior the upstream comment describes ("all instructions following the fence need to wait the completion of this last"). Both files are shared by the 64-bit and RV32 builds (`hpdcache.sv` also has the RV32 copy).

### 3e. Step 2c result: F1 and F2 implemented; a third defect found (2026-11-26)

Change plan `doc/specification/HPDCACHE_ATOMIC_DEADLOCK_CHANGE_PLAN.md` v1 approved (options A) and implemented in `rtl/coherence_fix/` (originals unchanged, hashes in `rtl/coherence_fix/original_sha256.txt`). Lint: 0 errors, 0 warnings for 64-bit 2/4 harts and RV32 2 harts profiles 0/1/2 and 4 harts profile 0 (`rtl/coherence_fix/lint/`).

| Run with the fix | Result |
|---|---|
| RV32, 2 harts, TC-01 to TC-10 | PASS; all ten waveforms bit-identical to the runs before the fix |
| RV32, 4 harts | TC-01 to 06, 08 to 10 PASS; **TC-07 FAIL**: hart 0 now completes CBO.CLEAN, FLUSH and INVAL, then stops at FENCE.I |
| 64-bit, 2 harts, TC-04 to 07, 09, 10 | PASS |
| 64-bit, 4 harts, TC-04 to 07, 09, 10; TC-07 with 2 and 3 harts in the barrier | **PASS** |
| 64-bit, 4 harts, original filelist (`--base-64`) | TC-07 hang as before (negative check) |
| Existing 64-bit suites rerun with the fix (copies in `verification/coherence_fix/`, outputs `suite_*.out`): atomic (success, lrsc_contention, amo/lr/owner fault), CMO (error 0/1, load-first), FENCE.I (error 0/1, supervisor), directory holder (4 cases), each with 2 and 4 harts | 36 / 36 PASS, same verdicts as the recorded baseline |

Plan stop condition hit (TC-07 still hangs on RV32), so no further RTL edit was made. Analysis of the RV32 hang (debug build, 4 000 cycles, `runs/TC-07_rv32_4h_fix_deep`):

| Cycle | Event |
|---|---|
| 937 | Context 1 (tag 1) allocated for hart 0's store to the code line 0x8000380 (directory bank 0, set 0xE0) |
| 939 | Its directory lookup is accepted: set 0xE0 of bank 0 is reserved for tag 1, `reg_ctx_dir_reserved[1]` = 1 |
| 945 | Contexts 0 (barrier line 0x8001510, also bank 0) and 1 are both in `ENUM_ST_DIR_UPDATE`. The bank arbiter sends the update of context 0 only; its handshake `w_update_hs[0]` moves **both** contexts to `ENUM_ST_GNT` |
| 947-948 | Hart 0 is granted and context 1 retires without a directory update or cancel: the directory never records hart 0 as holder, and set 0xE0 stays reserved (`reg_ctx_dir_reserved` still 0b10 after retirement) |
| 3027-3028 | FENCE.I sends a CMO FENCE for the same code line; it gets tag 1 and its lookup is refused forever (`w_lookup_set_busy` = 1). The CMO controller waits in PREPARE and hart 0 stops |

Defect 3 (base cluster, `rtl/common/vlsit/coherence/m_vlsit_riscv_coh_fabric.sv:1062, 1066-1067`): `ENUM_ST_DIR_UPDATE` and `ENUM_ST_DIR_CANCEL` advance on the bank handshake without checking `w_dir_update_tag` / `w_dir_cancel_tag`, unlike `ENUM_ST_RETRY_CANCEL` (lines 1000-1002), which does. Besides the hang, the lost update leaves the directory without the new holder, a coherence risk. It is timing-dependent and reachable in the 64-bit cluster. Recorded as REF-001 OPEN-DIR-UPD-TAG; proposed fix F3 in change plan v2.

### 3f. Plan v2 result: F3 implemented, TC-07 passes on both profiles (2026-11-26)

F3 (DEC-047) in `rtl/coherence_fix/coherence/m_vlsit_riscv_coh_fabric.sv`: `ENUM_ST_DIR_UPDATE` and `ENUM_ST_DIR_CANCEL` now leave only on the bank handshake that carries their own tag. VLSIT rule checker: same 19 ERROR / 2 WARN as the original file (pre-existing COM-09 findings at lines 321-343, not touched), no new finding. Lint 0/0 for 64-bit 2/4 harts profiles 0/2 and RV32 2 harts profiles 0/2, 4 harts profile 0 (`rtl/coherence_fix/lint/fix3_*.log`). New testbench checks SVA-104/105 (assertions A46/A47; SVA-104 required when `meta[7]` bit 2 is set, i.e. TC-04 to TC-07).

| Run (all with F1+F2+F3) | Result |
|---|---|
| RV32 2 harts, TC-01 to TC-10 | PASS |
| RV32 4 harts, TC-01 to TC-10 | **PASS**, including TC-07 (15/0) |
| RV32 4 harts, TC-07 with 2 and 3 harts in the barrier | PASS |
| 64-bit 2 and 4 harts, TC-04 to 07, 09, 10; TC-07 with 2 and 3 harts in the barrier | PASS |
| Existing 64-bit suites, 36 runs (`verification/coherence_fix/v2_*.out`) | 36 / 36 PASS, same verdicts as baseline |
| SVA-104 hits, RV32 4 harts | TC-02 4, TC-04 28, TC-05 17, TC-06 115, TC-07 87, TC-08 24, TC-09 3, TC-10 4; 0 failures |
| Negative: original 64-bit RTL (`--base-64`) | TC-07 hang (defect 1) |
| Negative: v1 configuration on RV32 (F1+F2, original fabric; `VLSIT_TB_FILELIST=.../negative_v1/filelist_rv32_v1.f`) | TC-07 hang and **SVA-104 fails at cycle 946**, the cycle of defect 3: the new assertion detects the defect |

Summary file: `verification/coherence_fix/v2_summary.txt`. OPEN-X32-CBO4 is closed.

Merged into `rtl/common/` on 2026-11-27 (change plan section 12); the RV32 and 64-bit regressions rerun on the merged tree all PASS, and the pre-fix snapshot (`run.py --base-64`) still hangs (`verification/coherence_fix/merge_summary.txt`).

## 4. Fault qualification (rule R-096)

Expected detecting checks were recorded in `FAULTS.md` before the runs. Every fault is detected. Faults 6 to 10 were recorded in `FAULTS.md` after their runs (see the note there).

| Fault | Testcase | First detecting check | Verdict |
|---|---|---|---|
| 1 hart-1 id forced 0 | TC-01 | signature sequence mismatch (`CHECK h0 #1`) and count | detected |
| 2 boot address +4 | TC-10 | `CHECK h0 #0` boot.pc | detected |
| 3 tile-1 probe line bit 0 | TC-05 | watchdog (coherence hang) | detected |
| 4 tile-0 probe line bit 0 | TC-04 | watchdog (coherence hang) | detected |
| 5 CMO line + 1 | TC-07 | FENCE.I result and memory checks | detected |
| 6 multiplier result 0 | TC-02 | `CHECK h0 #8` mul | detected |
| 7 FPU flags 0 | TC-03 | `CHECK h0 #7` fdiv.1_7.flags (12 flag checks fail, `runs/TC-03_rv32_2h_p0_f7`) | detected |
| 8 tile-1 grant line bit 0 | TC-06 | `CHECK h1 #0` amoswap old value | detected |
| 9 satp forced 0 | TC-08 | `CHECK h0 #0` S-mode load | detected |
| 10 MMIO strobes wrong lane | TC-09 | assertion MMIO-15 | detected |
| BOOT_HI=1 | TC-10 | SVA-102 assertion failure | detected |

## 5. Not done yet

- TC-07 4-hart hang: fixed by REF-001 DEC-046/047 (sections 3e, 3f); merging `rtl/coherence_fix/` into the original RTL folders is the designer's decision.
- TC-11 (cluster PMU through AXI4-Lite) and TC-12 (timing profiles 1 and 2): not implemented / not built.
- WF-101 waveform rendering and `waveforms_sim/waveform_compare.md`: the VCD of TC-05 exists, the WaveJSON/SVG comparison is not made.
- Constrained-random test with seed: not written.
- Engineer review of every testcase and waveform: pending (`REVIEW_LEDGER.md`).

## 6. Reproduce

```
python run.py build --harts 2 --profile 0
python run.py run TC-01 TC-02 TC-03 TC-04 TC-05 TC-06 TC-07 TC-08 TC-09 TC-10 --harts 2
python run.py run TC-01 --harts 2 --fault 1      # fault qualification, see FAULTS.md
python run.py run TC-10 --harts 2 --boot-hi 1    # SVA-102 negative run
python run.py build --harts 4 --xlen 64          # original 64-bit cluster (step 2a)
python run.py run TC-07 --harts 4 --xlen 64      # TC-07 hang on the 64-bit cluster
```
