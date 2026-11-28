"""
AI-GENERATED (Claude Opus 5.5, 2026-11-28) testcase source - candidate (R-117, R-231); engineer review pending (R-284).
Authored from the specification baseline only (RV32 HDS rev 0.4, REF-001 rev 0.39, CSR workbook, question_log answers); no RTL used (R-103, R-232).

| Field | Content |
|---|---|
| Test ID and title | t_rv32d_coh_cmo_amo_stress - Proves that maintenance, FENCE |
| Priority and rationale | high; rank 1 of the plan 6.3 risk-ranked list: 7 functions; reproduces the DEC-046/047 deadlock class (REF-001 14.7) |
| Purpose | Proves that maintenance, FENCE.I and contended cached atomics complete together without hang, with exact atomic count and memory-visible CLEAN/FLUSH data (REF-001 TEST-064 analogue for 2 harts). |
| Requirements and features | PROTO-RISCV-ZICBOM, REQ-MEM-006, REQ-MEM-015, REQ-MEM-018, REQ-MEM-019, REQ-MEM-020, REQ-PMU-008, REQ-XL-009, REQ-XL-012; features: atomics, cbo_maintenance, fence_i, hpdcache_word32, mesi_coherence, pmu_counting, same_line_lock; functions: mesi_coherence+cbo_maintenance+fence_i+atomics+same_line_lock+pmu_counting+hpdcache_word32 |
| DUT configuration and preconditions | CFG-RV32-2-P0; memory BFM READY 70 %, latency 0-8 (+MEM_RDY=70 +MEM_LAT=8); private lines p0-p3 of hart 0 and shared line sh in region 0; PMU counters 0-2 programmed over AXI4-Lite only for the isolated window. Plan configuration column: CFG-RV32-2-P0. Campaign region table bound through tb/generated/region_params.svh (REF-001 rev 0.40 14.4.20, Q-G3-01 answered) |
| Software flow | 1 reset release, both harts boot at 0x80000000 (crt); 2 hart 0: 8 iterations of {store p0-p2, CBO.CLEAN p0, CBO.FLUSH p1, CBO.INVAL p2} bracketed by checkpoints 0x11-0x14, then patch one instruction and FENCE.I (checkpoints 0x15/0x16) and execute it; 3 hart 1 concurrently: 64 x AMOADD.W on sh and 16 loads of sh; 4 isolated window: hart 0 dirties line X, checkpoint 0x20 makes the AXI4-Lite BFM enable PMU counters 0x0303/0x0304/0x0307 (scope 5), hart 1 reads X, checkpoint 0x21 runs the REF-001 11.2 snapshot sequence; 5 both harts flush sh/signature and write TOHOST |
| Stimulus | Cached AMOADD.W contention on one line overlapped with CBO.CLEAN/FLUSH/INVAL and FENCE.I on other lines; random memory backpressure; one isolated dirty-owner read for exact PMU counts |
| Functional checkpoints and assertions | See the check table below (7 planned checks; R-286 requires >= 5). Every check runs through scripts/evaluate_run.py with the oracle/scoreboard named; deadline = test cycle budget unless stated; failure condition as listed |
| Expected outcome | Shared counter = 64; CLEAN/FLUSH lines written to memory with 2 full-strobe beats and the stored data; no AW for the invalidated line or during FENCE.I; patched instruction executes; exact CCU counts 1/1/1; both harts pass |
| Defect/fault targeted | DEC-046/047 class: AMO refusing probes after an S grant, RTAB fence dropping, one directory handshake retiring two contexts (lost update, leaked reservation, hang); CMO writing wrong data or missing writeback; failure modes FM-ATM-01, FM-CBO-01, FM-CBO-03, FM-COH-04, FM-COH-07, FM-FEI-02, FM-LCK-02, FM-LCK-03, FM-PMU-03, FM-W32-01 |
| Checker/oracle | a_axi_mem_stable, chk_axi_mem_sb, chk_mem_oracle, chk_pmu_model, chk_sig, chk_watchdog; qualification records under docs/01_qualification and docs/02_env |
| Reproducibility | SEED and every plusarg in tests/generated/t_rv32d_coh_cmo_amo_stress/plusargs.txt (generated deterministically by scripts/generators/gen_prog.py); replay: build tb_top, run the simulator with +f-style plusargs from that file in a fresh runs/<run_id>/, then python scripts/evaluate_run.py runs/<run_id> |
| Waveform | wave.vcd of the run (TOP ports and checkpoint window, +WAVE=wave.vcd +WAVE_SCOPE=ports); R-283 rank 1 |
| Evidence | Not run: no simulation in this phase (free disk below the approved 2 GiB threshold) |
| Blocked obligations | OB-002 (REQ-MEM-019): Q-G0-13 answered A: waiting for the SVA observation-point table in the RV32 HDS; boundary no-hang check (CK-STR-05) runs meanwhile |

Planned checks (from verification_plan.md Section 6.1, R-286):

| Check ID | Requirement / clause | Trigger | Expected observation | Checker / assertion | Deadline | Failure condition |
|---|---|---|---|---|---|---|
| CK-STR-01 | REQ-MEM-006; REQ-IF-009 | hart 1 end of AMO loop | shared word equals initial + N (exact AMOADD.W count) | chk_mem_oracle | test timeout | value differs from N |
| CK-STR-02 | REQ-MEM-015; PROTO-RISCV-ZICBOM | each CBO.CLEAN/FLUSH retire | external AW to the line with 2 W beats and data equal to the model line | chk_axi_mem_sb | before test end | missing/extra write or data mismatch |
| CK-STR-03 | REQ-MEM-015 | each CBO.INVAL retire | no external AW for the invalidated line | chk_axi_mem_sb | before test end | AW observed |
| CK-STR-04 | REQ-MEM-018 | FENCE.I retire | no external AW caused by FENCE.I; next fetch executes new code marker | chk_axi_mem_sb; chk_sig | before test end | AW to clean lines or stale code executed |
| CK-STR-05 | REQ-MEM-020; REQ-XL-009 | whole test | both harts reach the end signature before the cycle budget (no deadlock) | chk_watchdog | cycle budget | budget expires |
| CK-STR-06 | REQ-PMU-008 | snapshot after the loop | in the isolated window after the loop (one dirty-owner transfer, no other traffic) 0x0303 PREPARE=1, 0x0304 COMMIT=1, 0x0307 grant=1 exactly (Q-G0-11; prefetcher off, G0-CONF-01) | chk_pmu_model | after snapshot | counter zero |
| CK-STR-07 | PROTO-AXI4-A3.2 | every AXI beat | no handshake/stability violation on memory port | a_axi_mem_stable | per cycle | assertion fails |
"""
TEST = 't_rv32d_coh_cmo_amo_stress'
SEED = 1
KIND = 'cpu'
REQS = {
    'CK-STR-01': 'REQ-MEM-006',
    'CK-STR-02': 'REQ-MEM-015',
    'CK-STR-03': 'REQ-MEM-015',
    'CK-STR-04': 'REQ-MEM-018',
    'CK-STR-05': 'REQ-MEM-020',
    'CK-STR-06': 'REQ-PMU-008',
    'CK-STR-07': 'PROTO-AXI4-A3.2',
}

from rv32d_lib import L, SLOT  # noqa: E402


def build(p):
    p.plusargs.update({"MEM_RDY": 70, "MEM_LAT": 8, "TIMEOUT_CYCLES": 4000000})
    p.waveform = True
    for i in range(4):
        p.line("p%d" % i, [0x11110000 + 0x100 * i + j for j in range(4)])
    p.line("sh", [0, 0, 0, 0])
    p.line("xline", [0, 0, 0, 0])
    p.word("go_x", 0)
    new_insn = p.encode("addi a1, zero, 0x55")
    # hart 0: CMO + FENCE.I
    p.asm(0, "li s1, 8")
    p.asm(0, "cmo_loop:")
    for i in range(3):
        p.asm(0, "la t0, p%d" % i, "addi t1, s1, %d" % (0x100 * i), "sw t1, 0(t0)", "sw t1, 4(t0)")
    p.ckpt(0, 0x11); p.cbo(0, "clean", "p0"); p.cbo(0, "flush", "p1"); p.ckpt(0, 0x12)
    p.ckpt(0, 0x13); p.cbo(0, "inval", "p2"); p.ckpt(0, 0x14)
    p.asm(0, "addi s1, s1, -1", "bnez s1, cmo_loop")
    p.asm(0, "la t0, patch_site", "li t1, 0x%x" % new_insn, "sw t1, 0(t0)")
    p.ckpt(0, 0x15); p.asm(0, "fence.i"); p.ckpt(0, 0x16)
    p.asm(0, "patch_site:", "addi a1, zero, 0", "nop")
    p.store_slot(0, "a1", "patch")
    # hart 1: AMO contention
    p.asm(1, "la t0, sh", "li t1, 1", "li s1, 64", "amo_loop:", "amoadd.w zero, t1, (t0)", "addi s1, s1, -1", "bnez s1, amo_loop")
    p.asm(1, "li s1, 16", "ld_loop:", "lw t2, 0(t0)", "addi s1, s1, -1", "bnez s1, ld_loop")
    p.store_slot(1, "t2", "sh_seen")
    # isolated dirty-owner window (Q-G0-11: exact counts, prefetcher assumed off - G0-CONF-01)
    p.asm(0, "la t0, xline", "li t1, 0xA5A5", "sw t1, 0(t0)")
    p.flag_set(0, "go_x")
    p.flag_wait(1, "go_x")
    p.axil_block(1, 0x20, [p.axw(0x1000 + 4 * k, p.pmu_evt_word(e, 5)) for k, e in enumerate((0x0303, 0x0304, 0x0307))])
    p.asm(1, "la t0, xline", "lw t3, 0(t0)")
    p.store_slot(1, "t3", "x_seen")
    p.axil_block(1, 0x21, p.pmu_snapshot_ops([0, 1, 2]))
    p.cbo(1, "flush", "sh")
    p.flag_set(1, "go_x", 2)
    p.flag_wait(0, "go_x", 2)
    p.end(0); p.end(1)
    p.dump.append((0x80040000, 0x80040fff))
    p.check("CK-STR-01", REQS["CK-STR-01"], "mem_word", addr=L("sh"), expect=64)
    p.check("CK-STR-02", REQS["CK-STR-02"], "axi_mem", rules=[
        {"kind": "write_line", "addr": L("p0"), "window": [0x11, 0x12], "beats": 2, "strobe_full": True},
        {"kind": "write_line", "addr": L("p1"), "window": [0x11, 0x12], "beats": 2, "strobe_full": True}])
    p.check("CK-STR-03", REQS["CK-STR-03"], "axi_mem", rules=[{"kind": "no_write", "lo": L("p2"), "hi": L("p2", 15), "window": [0x13, 0x14]}])
    p.check("CK-STR-04", REQS["CK-STR-04"], "slot", addr=SLOT(p, 0, "patch"), expect=0x55)
    p.check("CK-STR-04b", REQS["CK-STR-04"], "axi_mem", rules=[{"kind": "no_write", "lo": 0x80000000, "hi": 0xBFFFFFFF, "window": [0x15, 0x16]}])
    p.check("CK-STR-05", REQS["CK-STR-05"], "tohost", code=1)
    p.check("CK-STR-06", REQS["CK-STR-06"], "pmu", config={"0": [0x0303, 5, 1], "1": [0x0304, 5, 1], "2": [0x0307, 5, 1]},
            occurrences=[{"cycle": 1, "event_id": 0x0303, "hart": None, "count": 1},
                         {"cycle": 2, "event_id": 0x0304, "hart": None, "count": 1},
                         {"cycle": 3, "event_id": 0x0307, "hart": None, "count": 1}])
    p.check("CK-STR-07", REQS["CK-STR-07"], "sva", id="a_axi_mem_stable")
    p.check("CK-STR-08", "REQ-MEM-001", "slot", addr=SLOT(p, 1, "x_seen"), expect=0xA5A5)
    p.block("SVA-104/105", "REQ-MEM-019", "sva_internal_bind blocked by Q-G0-13 (observation-point table not in the RV32 HDS)")
