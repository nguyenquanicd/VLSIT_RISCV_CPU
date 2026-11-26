# Change plan v1 - HPDcache coherent-atomic deadlock (TC-07, OPEN-X32-CBO4)

Status: **v1 and v2 approved and implemented on 2026-11-26; all checks pass (section 11). Merging `rtl/coherence_fix/` into the original RTL folders is left to the designer.**
Trạng thái: **v1 và v2 đã duyệt và thực hiện; mọi kiểm tra đều PASS (mục 11). Việc merge `rtl/coherence_fix/` vào thư mục RTL gốc do designer quyết định.**

**Tóm tắt.** Có hai lỗi trong phần atomic coherent (DEC-038) của HPDcache dùng chung, làm cluster deadlock khi chạy 4 hart (TC-07).
- **F1 (2 file):** chỉ cấp quyền atomic khi grant là E hoặc M. Riêng LR vẫn được nhận S.
- **F2 (1 file):** giữ fence của RTAB bật suốt lúc còn một entry kiểu fence (AMO, uncached, CMO) trong RTAB.
- **Nơi ghi file:** bản sao trong thư mục output, bản gốc không đổi (R-009).
- **Kiểm tra:** chạy lại regression của cả bản 64-bit và RV32.
- Có 4 câu hỏi ở mục 7.

## 1. Trigger and evidence

| Item | Content |
|---|---|
| Failure | TC-07 hangs with 4 harts on the RV32 profile and on the original 64-bit cluster: hart 0 stops inside its CBO sequence while harts 1-3 run AMOADD.W then a load loop on one barrier line. Deadlock: no DUT activity after cycle 810 in a 3 000 000-cycle run |
| Root cause | Two defects, both in the coherent-atomic (DEC-038) additions to the HPDcache. Cycle-by-cycle wait-for chains: `verification/rv32_profile/REPORT.md` section 3d |
| Confirmation | Simulation-only experiments (`verification/rv32_profile/tb/tb_experiments_rv64.svh`, no RTL edit): experiment 1 removes defect 1, so the hang moves later; experiment 2 removes both and TC-07 passes with 4 harts (also with 2 and 3 harts in the barrier); TC-04, 05, 06, 09, 10 pass |
| Specification | REF-001 `doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md` line 1462 (S-to-M upgrade / AMO hit in S, DEC-038): "retains the clean S copy while awaiting unique permission ... **older probes may complete before that grant**". Upstream comment of `hpdcache_ctrl_pe.sv:278-282`: "all instructions following the fence need to wait the completion of this last before being executed" |

### Defect 1

`hpdcache.sv:648-649` drives `coh_atomic_grant_i` for every grant whose state is not I, so a Shared grant counts. `hpdcache_ctrl.sv:926-928` then sets `atomic_permission_q`, and `hpdcache_ctrl.sv:1171-1172` refuses every probe of that line until the AMO completes. An AMO cannot complete from S: it sends a unique request, which the fabric serializes behind the competing same-line context whose PREPARE probe is being refused. This contradicts REF-001 line 1462.

### Defect 2

`hpdcache_rtab.sv:250, 261, 452` (upstream logic): `fence_o` is high only while an entry still has its `pend_trans` dependency, and `pend_trans` clears only when every valid entry is fenced (`fence_only`). After the AMO's dependency clears, core requests are accepted although the AMO is still queued, and a younger same-line load links behind it. The DEC-038 AMO needs a second (unique) ownership request after a Shared refill and is rolled back with `pend_trans` again. From then on `fence_only` stays false: the linked load is valid and not fenced, and it cannot run before the AMO. Upstream never re-fences an AMO after a refill, so only the DEC-038 cached-AMO path reaches this state.

## 2. Baseline (read only, before any edit)

| Check | Result | Evidence |
|---|---|---|
| RV32 lint, TOP, 2 harts profiles 0/1/2 and 4 harts profile 0 | 0 errors, 0 warnings | `rtl/rv32_profile/lint/v3_rv32_*.log` |
| 64-bit lint of the TOP | Last recorded runs clean | `rtl/rv32_profile/lint/v2_rv64_2h.log`, `v2_rv64_4h.log` |
| RV32 testbench, 2 harts | TC-01 to TC-10 PASS | `verification/rv32_profile/REPORT.md` section 1 |
| RV32 testbench, 4 harts | TC-01 to 06, 08 to 10 PASS; TC-07 hang | section 3b |
| 64-bit mode of the same testbench | 2 harts TC-04 to 07 PASS; 4 harts TC-07 hang | section 3c |
| VLSIT rule checker on the three files | Not applicable: upstream-derived HPDcache code in upstream style (same treatment as the DEC-106 divider copy). Edits follow the surrounding style and carry dated change comments | - |

## 3. Files (rule R-009: originals untouched)

Output folder `rtl/coherence_fix/` (new). The originals in `rtl/common/modified/hpdcache/rtl/src/` and every original filelist stay unchanged. SHA-256 of each original is written to `rtl/coherence_fix/original_sha256.txt` before the copies are made.

| File | Action |
|---|---|
| `rtl/coherence_fix/hpdcache/hpdcache_ctrl.sv` | NEW copy of `rtl/common/modified/hpdcache/rtl/src/hpdcache_ctrl.sv`, F1 edit |
| `rtl/coherence_fix/hpdcache/hpdcache_rtab.sv` | NEW copy of `.../hpdcache_rtab.sv`, F2 edit |
| `rtl/coherence_fix/hpdcache/hpdcache.sv` | NEW copy of `.../hpdcache.sv` (64-bit build), F1 connection |
| `rtl/rv32_profile/hpdcache/hpdcache.sv` | MODIFY (RV32 copy created by plan v2): the same F1 connection |
| `rtl/coherence_fix/filelists/hpdcache_fix.Flist` | NEW copy of `rtl/common/filelists/cva6_flush_path/hpdcache_modified.Flist`, lines 40, 44 and 50 point to the three copies |
| `rtl/coherence_fix/filelists/cva6_fix.Flist` | NEW copy of `.../cva6_modified_cache.Flist`, line 201 points to `hpdcache_fix.Flist` |
| `rtl/coherence_fix/filelist_fix.f` | NEW 64-bit TOP filelist: `rtl/non_coherence_cluster/filelist.f` with its first line pointing to `cva6_fix.Flist` |
| `rtl/rv32_profile/filelists/hpdcache_rv32.Flist` | MODIFY: lines 44 and 50 point to the fixed `hpdcache_ctrl.sv` and `hpdcache_rtab.sv` |
| `verification/rv32_profile/run.py` | `--xlen 64` builds with `rtl/coherence_fix/filelist_fix.f`; a new option `--base-64` keeps the unfixed filelist so the hang can still be reproduced |

## 4. Exact edits

### F1 - atomic permission only on a unique grant (LR keeps S)

`hpdcache_ctrl.sv`, port list after line 110:

```systemverilog
    input  logic                  coh_atomic_grant_i,
    input  hpdcache_nline_t        coh_atomic_grant_nline_i,
    input  logic                  coh_atomic_grant_unique_i,   // NEW: grant state is E or M
```

`hpdcache_ctrl.sv:910-935` (before -> after, changed lines only):

```systemverilog
    logic atomic_pending_q, atomic_permission_q;
    logic atomic_lr_q;                                          // NEW
    ...
        if (!rst_ni) begin
            ...
            atomic_lr_q <= 1'b0;                                // NEW
        end else begin
            if (st1_req_valid_q && st1_req_is_amo && !st1_req_is_uncacheable &&
                !st1_req_abort && !atomic_pending_q) begin
                ...
                atomic_lr_q <= st1_req_is_amo_lr;               // NEW
            end
            // before: if (atomic_pending_q && coh_atomic_grant_i &&
            if (atomic_pending_q && coh_atomic_grant_i &&
                (coh_atomic_grant_unique_i || atomic_lr_q) &&   // NEW: S grant gives no permission (REF-001 DEC-038)
                (coh_atomic_grant_nline_i == atomic_nline_q)) begin
                atomic_permission_q <= 1'b1;
            end
```

`hpdcache.sv` (both copies), instance of `hpdcache_ctrl` after line 650:

```systemverilog
        .coh_atomic_grant_nline_i(coh_own_gnt_nline_i),
        .coh_atomic_grant_unique_i(coh_own_gnt_state_i[1]),     // NEW: E (2) or M (3)
```

The state encoding (I=0, S=1, E=2, M=3) is the one `hpdcache_miss_handler.sv:371-373, 418` already uses. The LR exception keeps the rule used at the first hit (`hpdcache_ctrl.sv:922-924`: permission on a hit when dirty, exclusive **or LR**), because an LR executes from S without another ownership request.

### F2 - RTAB fence held while a fence-type entry is queued

`hpdcache_rtab.sv`, declarations near line 205, the check generate loop (line 261) and line 250:

```systemverilog
    logic               [N-1:0]  fence_type_bv;                 // NEW
    ...
        assign fence_bv[gen_i] = deps_q[gen_i].pend_trans;
        // NEW: same classification as st1_fence in hpdcache_ctrl_pe.sv:283-287
        assign fence_type_bv[gen_i] = is_amo(req_q[gen_i].req.req.op)
                                    | req_q[gen_i].req.req.pma.uncacheable
                                    | is_cmo_fence(req_q[gen_i].req.req.op)
                                    | is_cmo_inval(req_q[gen_i].req.req.op)
                                    | is_cmo_flush(req_q[gen_i].req.req.op);
    ...
    // before: assign fence_o = |fence_bv;
    assign fence_o = (|fence_bv) | (|(valid_q & fence_type_bv));
```

The flag is computed from the stored request, so it needs no new storage and stays correct across rollbacks. `fence_only` and the `pend_trans` clear rule are unchanged. `fence_o` feeds only `core_req_ready_o` and `scrub_req_ready_o` (`hpdcache_ctrl_pe.sv:1403, 1414`); refill, probe, write-back and RTAB replay are not gated by it.

Each changed file gets a dated change comment in its header: date, author, OPEN-X32-CBO4 and the reason.

## 5. Behavior

| Changes | Stays the same |
|---|---|
| A pending AMO that receives a Shared grant no longer refuses probes; it answers them like any S holder and its unique request proceeds | Atomic permission after an E/M grant (the DEC-038 protection against two contenders stealing ownership between refill and replay), and permission on the first hit |
| LR keeps permission on an S grant, as on an S hit | AMO, LR/SC results and ordering |
| While an AMO, uncacheable or CMO entry is in the RTAB, the HPDcache accepts no new core request (as the upstream comment intends). Cost: the load/store port waits during an AMO miss; the core already waits for the AMO result | Refill, probe, write-back, CMO, MSHR, RTAB replay order; behavior when no fence-type entry is queued; every port of the cluster; CSR map |
| | Configurations without coherent AMOs: an uncacheable or CMO entry already held `pend_trans` while queued, so for them the fence now also covers the cycles after the dependency clears and before the entry leaves |

Performance risk: low. The extra fence time occurs only between a fence-type entry's dependency clearing and that entry's departure from the RTAB, a few cycles for an uncacheable or CMO entry and one ownership round trip for an AMO that needs an S-to-M upgrade.

## 6. Checks after the edit

| Check | Configurations | Pass criterion |
|---|---|---|
| Verilator lint of the TOP, fixed filelist | 64-bit 2 and 4 harts; RV32 2 harts profiles 0/1/2, 4 harts profile 0 | 0 errors, 0 warnings (same as baseline) |
| RV32 testbench | 2 and 4 harts | TC-01 to TC-10 PASS, **TC-07 PASS with 4 harts**; unchanged testcases keep bit-identical waveforms where no AMO is involved |
| Same testbench, 64-bit mode | 2 and 4 harts | TC-04 to 07, 09, 10 PASS; TC-07 also with `TC07_PART` 2 and 3; no `+EXPERIMENT` |
| Negative reproduction | `--base-64` (unfixed filelist), 4 harts | TC-07 still hangs (shows the testbench detects the defect) |
| Each fix needed on its own | experiment build on the fixed RTL is not needed; experiments 1 and 2 on the unfixed RTL already show it | Recorded |
| Existing 64-bit suites | `verification/non_coherence_cluster/atomic_end_to_end` (including `lrsc_contention`), `cmo_end_to_end`, `fence_i_end_to_end`, `directory_holder_end_to_end`, run with the fixed filelist | Same verdicts as their recorded baseline. Where a script cannot take another filelist, it is reported as not run |
| Timing profiles | RV32 4 harts profiles 1 and 2 build | TC-07 PASS (TC-12 scope) |

## 7. Questions for the designer

1. **Where the fix lives.**
   - A (recommended, R-009): copies in `rtl/coherence_fix/` and new filelists. The originals stay unchanged, and you merge them into `rtl/common/modified/` when you accept the result.
   - B: edit `rtl/common/modified/hpdcache/rtl/src/` in place after a snapshot. Every existing filelist and suite then picks up the fix, but this needs your explicit waiver of R-009.
2. **F2 variant.**
   - A (recommended): fence flag from the stored request (section 4).
   - B: do not set `pend_trans` again when an AMO replayed from the RTAB is rolled back (`hpdcache_ctrl_pe.sv`, `st1_rtab_pend_trans_o = st1_fence & ~st1_req_rtab_i`). B is smaller, but it lets younger requests to other lines run before a queued AMO completes, which weakens the fence the upstream comment describes. It is also not the form tested by experiment 2.
3. **LR exception in F1.**
   - A (recommended): keep permission on an S grant for LR, consistent with the first-hit rule.
   - B: E/M only for every atomic.
4. **Specification update.**
   - A (recommended): add DEC-046 to REF-001 (the 64-bit HDS) and rewrite the row at line 1462 to state "atomic permission is taken only on an E/M grant; the RTAB fence holds while a fence-type entry is queued". Add a 4-hart CBO/AMO contention test (the TC-07 scenario) to its test plan. Close OPEN-X32-CBO4 with DEC-107 in the RV32 HDS.
   - B: update the RV32 HDS only.

## 8. Risks and stop conditions

- If any 64-bit suite verdict changes from its baseline, stop and report it with analysis before any further edit.
- If TC-07 still hangs with the real F2, stop. The real F2 is narrower than experiment 2: it excludes write-miss stores and includes uncacheable and CMO entries. Report the new wait-for chain.
- Possible livelock (DEC-038's original concern): two AMOs on one line can still exchange S copies before either has unique ownership. Each unique grant is still protected until its AMO executes, so the fabric's FIFO serialization guarantees progress. The `lrsc_contention` suite and TC-06 with 4 harts check this.

## 9. Implementation results of v1 (2026-11-26)

| Item | Result |
|---|---|
| Files | `rtl/coherence_fix/hpdcache/{hpdcache.sv, hpdcache_ctrl.sv, hpdcache_rtab.sv}` (edits exactly as section 4, plus dated header comments); `rtl/rv32_profile/hpdcache/hpdcache.sv` (one connection line, header comment); filelists `rtl/coherence_fix/filelists/{hpdcache_fix.Flist, cva6_fix.Flist}`, `rtl/coherence_fix/filelist_fix.f`; `rtl/rv32_profile/filelists/hpdcache_rv32.Flist` lines 44 and 50; `verification/rv32_profile/run.py` (`--base-64`). Originals unchanged; hashes in `rtl/coherence_fix/original_sha256.txt` |
| Lint | 0 errors, 0 warnings: 64-bit 2/4 harts profile 0, 4 harts profile 2; RV32 2 harts profiles 0/1/2, 4 harts profile 0 (`rtl/coherence_fix/lint/`) |
| Simulation | See `verification/rv32_profile/REPORT.md` section 3e: 64-bit TC-07 PASS with 4 harts; 36/36 existing 64-bit suite runs PASS; RV32 2 harts unchanged; RV32 4 harts TC-07 still hangs |
| Specification | REF-001 rev 0.37: DEC-046, row of line 1462, TEST-064, OPEN-DIR-UPD-TAG. RV32 HDS: DEC-107, Section 15.5, OPEN-X32-CBO4 kept open |
| Stop condition | Hit: TC-07 hangs on RV32 at FENCE.I. Root cause is a third, separate defect (section 10); no further RTL edit made |

## 10. Plan version 2 - F3: directory update/cancel tag check (approved 2026-11-26)

| Item | Content |
|---|---|
| Defect | `m_vlsit_riscv_coh_fabric.sv:1062, 1066-1067`: `ENUM_ST_DIR_UPDATE` and `ENUM_ST_DIR_CANCEL` leave on the bank handshake without checking that it carries their own tag. Two contexts of one bank in DIR_UPDATE retire on one handshake; the second loses its directory update (holder not recorded) and its set reservation leaks, so the next lookup of that set waits forever (REPORT section 3e, cycle 945) |
| File | NEW copy `rtl/coherence_fix/coherence/m_vlsit_riscv_coh_fabric.sv` of `rtl/common/vlsit/coherence/m_vlsit_riscv_coh_fabric.sv`; the fixed filelists (`filelist_fix.f` chain and the RV32 cluster filelist) point to it |
| Edit 1 (line 1062) | `if (w_update_hs[bank])` to `if (w_update_hs[bank] & (w_dir_update_tag[bank] == LPARA_COH_TAG_W'(slot_idx)))`, with `bank = w_ctx_pa_line[slot_idx][1:0]` |
| Edit 2 (lines 1066-1067) | `if (~reg_ctx_dir_reserved[slot_idx] \| w_cancel_hs[bank])` to `if (~reg_ctx_dir_reserved[slot_idx] \| (w_cancel_hs[bank] & (w_dir_cancel_tag[bank] == LPARA_COH_TAG_W'(slot_idx))))` |
| Why | Same rule as `ENUM_ST_RETRY_CANCEL` (lines 1000-1002) in the same FSM; the arbiter already holds the unpicked context in DIR_UPDATE, so it is picked on a later cycle. No new state, port or register |
| Header | Dated change comment (OPEN-DIR-UPD-TAG, DEC-047) |
| Checks | VLSIT rule checker on the changed file (VLSIT-owned RTL) compared with the baseline findings; lint as in v1; RV32 TC-01 to 10 with 2 and 4 harts (TC-07 must PASS); 64-bit TC-04 to 07, 09, 10 with 2 and 4 harts; the 36 existing suite runs; an SVA in the testbench: when a context leaves DIR_UPDATE, the update handshake of its bank carries its tag |
| Specification | REF-001: DEC-047, close OPEN-DIR-UPD-TAG; RV32 HDS: close OPEN-X32-CBO4 |
| Stop condition | Any suite verdict change, or TC-07 still failing: stop and report |

## 11. Implementation results of v2 (2026-11-26)

| Item | Result |
|---|---|
| Files | NEW `rtl/coherence_fix/coherence/m_vlsit_riscv_coh_fabric.sv` (edits exactly as section 10, dated header comment); NEW `rtl/coherence_fix/filelists/filelist_vlsit_cluster_fix.f` and `filelist_fix.f` line 4; `rtl/rv32_profile/filelists/filelist_vlsit_cluster_rv32.f` line 18; suite copies in `verification/coherence_fix/` point to the fixed filelist. Original fabric unchanged (hash appended to `rtl/coherence_fix/original_sha256.txt`) |
| Rule check | Original and changed file: 19 ERROR, 2 WARN, identical findings (pre-existing COM-09 at lines 321-343); no new finding (`rtl/coherence_fix/rulecheck_base.txt`, `rulecheck_fix.txt`) |
| Lint | 0 errors, 0 warnings in 6 configurations (`rtl/coherence_fix/lint/fix3_*.log`) |
| Testbench | SVA-104/105 added (A46/A47). One correction during the run: SVA-104 was first marked required in every testcase; TC-01 and TC-03 have no inter-hart sharing and never exercise it, so it is now required through `meta[7]` bit 2 for TC-04 to TC-07 (same mechanism as the other scenario-dependent assertions) |
| Simulation | RV32 2/4 harts TC-01 to TC-10 PASS; TC-07 PASS with 2/3/4 harts in the barrier on both profiles; 64-bit TC-04 to 07, 09, 10 PASS; 36/36 existing suite runs PASS (`verification/coherence_fix/v2_summary.txt`) |
| Negative checks | Original 64-bit RTL: TC-07 hang. v1 configuration (F1+F2, original fabric) on RV32: TC-07 hang and SVA-104 fails at cycle 946 |
| Specification | REF-001 rev 0.38: DEC-047, OPEN-DIR-UPD-TAG closed, TEST-064 PASS. RV32 HDS rev 0.3: DEC-108, OPEN-X32-CBO4 closed |
| Not done | Merge into `rtl/common/`; rerun of the other existing suites not listed in section 6 (for example `ccu_victim_escape`, `e_to_m_fix`, `l1_eviction_end_to_end`); timing-profile 1/2 simulation (TC-12) |


## 12. Merge into the original RTL folders (approved 2026-11-27)

| Item | Result |
|---|---|
| Approval | Designer, 2026-11-27: "merge như bạn đề xuất" (explicit waiver of R-009 for these four files) |
| Snapshot | Pre-fix files copied to `rtl/coherence_fix/pre_merge/{hpdcache,coherence}/` (hashes `pre_merge_sha256.txt`, equal to `original_sha256.txt`). Reproduction chain `rtl/coherence_fix/filelists/pre_merge/filelist_pre.f`; `run.py --base-64` uses it |
| Merged | `rtl/common/modified/hpdcache/rtl/src/hpdcache.sv`, `hpdcache_ctrl.sv`, `hpdcache_rtab.sv`; `rtl/common/vlsit/coherence/m_vlsit_riscv_coh_fabric.sv`; each is byte-identical to the verified copy in `rtl/coherence_fix/` |
| Filelists | RV32 `hpdcache_rv32.Flist` (lines 44, 50) and `filelist_vlsit_cluster_rv32.f` (line 18) point back to `rtl/common/`; 64-bit filelists were never changed and now pick up the fix; `run.py --xlen 64` uses `rtl/non_coherence_cluster/filelist.f`; `negative_v1` uses the pre-merge fabric |
| Lint | 0 errors / 0 warnings: 64-bit original filelist 2/4 harts, RV32 4 harts profile 0 and 2 harts profile 2, pre-merge chain 4 harts (`rtl/coherence_fix/lint/merged_*`, `pre_merge_*`) |
| Simulation | RV32 2/4 harts TC-01 to TC-10 PASS; 64-bit 2/4 harts TC-04 to 07, 09, 10 PASS; pre-merge snapshot TC-07 still hangs (`verification/coherence_fix/merge_summary.txt`). The 36 suite runs of section 11 used byte-identical RTL |
| Documentation | REF-001 rev 0.39 Section 14.7 (each fix: where, symptom, root cause, change, reason) and its Vietnamese companion; RV32 HDS rev 0.4 Section 14.2; root `README.md`, `doc/specification/README.md`, `doc/specification_32/README.md` |
| Not done | Rerun of the other existing suites (`ccu_victim_escape`, `e_to_m_fix`, `l1_eviction_end_to_end`, ...) on the merged tree; nothing committed |
