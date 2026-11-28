"""
AI-GENERATED (Claude Opus 5.5, 2026-11-28) testcase source - candidate (R-117, R-231); engineer review pending (R-284).
Authored from the specification baseline only (RV32 HDS rev 0.4, REF-001 rev 0.39, CSR workbook, question_log answers); no RTL used (R-103, R-232).

| Field | Content |
|---|---|
| Test ID and title | t_rv32d_mesi_dirty_owner - Proves dirty-owner sharing and ownership ping-pong deliver the latest data on RV32 (WF-101 scenario) and that CCU events reflect the transfers |
| Priority and rationale | high; rank 3 of the plan 6.3 risk-ranked list: WF-101, the one RV32-specific waveform of RV32 HDS 10.3 |
| Purpose | Proves dirty-owner sharing and ownership ping-pong deliver the latest data on RV32 (WF-101 scenario) and that CCU events reflect the transfers. |
| Requirements and features | REQ-MEM-001, REQ-MEM-005, REQ-MEM-012, REQ-PMU-007, REQ-XL-006, REQ-XL-007, REQ-XL-009, REQ-XL-012; features: axi_addr_width, hpdcache_word32, line_addr_adapter, mesi_coherence, pmu_counting; functions: mesi_coherence+hpdcache_word32+line_addr_adapter+pmu_counting+axi_addr_width |
| DUT configuration and preconditions | CFG-RV32-2-P0; line L at 0x80041000 (PA bit 31 set, WF-101 scenario); PMU counters 0-2 enabled only around the isolated read. Plan configuration column: CFG-RV32-2-P0. Campaign region table bound through tb/generated/region_params.svh (REF-001 rev 0.40 14.4.20, Q-G3-01 answered) |
| Software flow | 1 boot; 2 hart 0 writes 4 words (byte, half and word stores) into L (becomes M); 3 checkpoint 0x40: AXI4-Lite enables CCU counters 0x0303/0x0304/0x0307; 4 hart 1 reads all 4 words (dirty-owner sharing); 5 checkpoint 0x41: snapshot and read counters; 6 ping-pong: 8 alternating increments of word 0 synchronised by a flag line; 7 hart 0 CBO.CLEAN L inside checkpoints 0x42/0x43; 8 TOHOST |
| Stimulus | Dirty-owner read sharing then store ping-pong on one line above 0x8000_0000 |
| Functional checkpoints and assertions | See the check table below (6 planned checks; R-286 requires >= 5). Every check runs through scripts/evaluate_run.py with the oracle/scoreboard named; deadline = test cycle budget unless stated; failure condition as listed |
| Expected outcome | Hart 1 reads hart 0's values; final word 0 = 8; exact CCU counts 1/1/1; CLEAN writes 2 full beats with the final line |
| Defect/fault targeted | Stale read from a dirty owner, lost word in partial-line merge with the 32-bit HPDcache word, line-address truncation, wrong probe targeting; failure modes FM-AXW-01, FM-COH-01, FM-COH-02, FM-COH-03, FM-COH-05, FM-LAD-01, FM-PMU-02, FM-W32-02 |
| Checker/oracle | a_axi_addr_hi_zero, a_line_addr_hi_zero, chk_axi_mem_sb, chk_mem_oracle, chk_pmu_model; qualification records under docs/01_qualification and docs/02_env |
| Reproducibility | SEED and every plusarg in tests/generated/t_rv32d_mesi_dirty_owner/plusargs.txt (generated deterministically by scripts/generators/gen_prog.py); replay: build tb_top, run the simulator with +f-style plusargs from that file in a fresh runs/<run_id>/, then python scripts/evaluate_run.py runs/<run_id> |
| Waveform | wave.vcd of the run (TOP ports and checkpoint window, +WAVE=wave.vcd +WAVE_SCOPE=ports); R-283 rank 3 |
| Evidence | Not run: no simulation in this phase (free disk below the approved 2 GiB threshold) |
| Blocked obligations | OB-020 (REQ-XL-007): Q-G0-13 answered A: waiting for the SVA observation-point table in the RV32 HDS; data-level check (CK-DOW-01/02) runs meanwhile |

Planned checks (from verification_plan.md Section 6.1, R-286):

| Check ID | Requirement / clause | Trigger | Expected observation | Checker / assertion | Deadline | Failure condition |
|---|---|---|---|---|---|---|
| CK-DOW-01 | REQ-MEM-001; REQ-MEM-012 | hart 1 load after hart 0 store | hart 1 reads hart 0's value | chk_mem_oracle | test end | stale value |
| CK-DOW-02 | REQ-MEM-001 | ping-pong end | final line equals the sequential-order model for all 4 words | chk_mem_oracle | test end | lost update |
| CK-DOW-03 | REQ-PMU-008; REQ-MEM-005 | snapshot | isolated dirty-owner read: 0x0303 PREPARE=1, 0x0304 COMMIT=1, 0x0307 grant=1 exactly (Q-G0-11; prefetcher off, G0-CONF-01) | chk_pmu_model | after snapshot | mismatch |
| CK-DOW-04 | REQ-XL-006 | every external AR/AW | address bits 63:34 zero | a_axi_addr_hi_zero | per cycle | nonzero |
| CK-DOW-05 | REQ-XL-012 | final CBO.CLEAN of the line | 2 W beats of 64 bits, full strobes, data equal to model | chk_axi_mem_sb | test end | beat count or data mismatch |
| CK-DOW-06 | REQ-XL-007 | internal line-address inputs | bits 51:30 zero whenever valid (SVA-101) | a_line_addr_hi_zero | per cycle | nonzero (binding blocked: Q-G0-13) |
"""
TEST = 't_rv32d_mesi_dirty_owner'
SEED = 1
KIND = 'cpu'
REQS = {
    'CK-DOW-01': 'REQ-MEM-001',
    'CK-DOW-02': 'REQ-MEM-001',
    'CK-DOW-03': 'REQ-PMU-008',
    'CK-DOW-04': 'REQ-XL-006',
    'CK-DOW-05': 'REQ-XL-012',
    'CK-DOW-06': 'REQ-XL-007',
}

from rv32d_lib import L, SLOT  # noqa: E402


def build(p):
    p.waveform = True
    p.data.append(".org 0x80041000")
    p.data.append("lineL:")
    p.data.append(".word 0, 0, 0, 0")
    p.line("turn", [0, 0, 0, 0])
    p.asm(0, "la t0, lineL", "li t1, 0x11", "sb t1, 4(t0)", "li t1, 0x2233", "sh t1, 6(t0)", "li t1, 0x44556677", "sw t1, 8(t0)", "li t1, 0x8899aabb", "sw t1, 12(t0)")
    p.flag_set(0, "turn", 1)
    p.flag_wait(1, "turn", 1)
    p.axil_block(1, 0x40, [p.axw(0x1000 + 4 * k, p.pmu_evt_word(e, 5)) for k, e in enumerate((0x0303, 0x0304, 0x0307))])
    p.asm(1, "la t0, lineL", "lw t1, 4(t0)", "lw t2, 8(t0)", "lw t3, 12(t0)")
    p.store_slot(1, "t1", "w1"); p.store_slot(1, "t2", "w2"); p.store_slot(1, "t3", "w3")
    p.axil_block(1, 0x41, p.pmu_snapshot_ops([0, 1, 2]))
    # ping-pong on word 0: hart 0 increments on turn==2, hart 1 on turn==3; 4 rounds each
    p.flag_set(1, "turn", 2)
    for h in (0, 1):
        lp = "pp_loop_%d" % h
        p.asm(h, "li s1, 4", "%s:" % lp)
        p.flag_wait(h, "turn", 2 + h)
        p.asm(h, "la t0, lineL", "lw t1, 0(t0)", "addi t1, t1, 1", "sw t1, 0(t0)")
        p.flag_set(h, "turn", 3 - h)
        p.asm(h, "addi s1, s1, -1", "bnez s1, %s" % lp)
    p.flag_wait(0, "turn", 2)
    p.ckpt(0, 0x42); p.cbo(0, "clean", "lineL"); p.ckpt(0, 0x43)
    p.end(0); p.end(1)
    p.check("CK-DOW-01", REQS["CK-DOW-01"], "slot", addr=SLOT(p, 1, "w2"), expect=0x44556677)
    p.check("CK-DOW-01b", REQS["CK-DOW-01"], "slot", addr=SLOT(p, 1, "w1"), expect=0x22330011)
    p.check("CK-DOW-02", REQS["CK-DOW-02"], "axi_mem", rules=[{"kind": "write_line", "addr": 0x80041000, "window": [0x42, 0x43],
            "data": "08000000" + "11003322" + "77665544" + "bbaa9988"}])
    p.check("CK-DOW-03", REQS["CK-DOW-03"], "pmu", config={"0": [0x0303, 5, 1], "1": [0x0304, 5, 1], "2": [0x0307, 5, 1]},
            occurrences=[{"cycle": 1, "event_id": e, "hart": None, "count": 1} for e in (0x0303, 0x0304, 0x0307)])
    p.check("CK-DOW-04", REQS["CK-DOW-04"], "sva", id="a_axi_addr_hi_zero")
    p.check("CK-DOW-05", REQS["CK-DOW-05"], "axi_mem", rules=[{"kind": "write_line", "addr": 0x80041000, "window": [0x42, 0x43], "beats": 2, "strobe_full": True}])
    p.check("CK-DOW-07", "REQ-MEM-001", "tohost", code=1)
    p.block("CK-DOW-06", REQS["CK-DOW-06"], "SVA-101 binding blocked by Q-G0-13 (observation-point table not in the RV32 HDS)")
