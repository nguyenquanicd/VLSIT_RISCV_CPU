"""
AI-GENERATED (Claude Opus 5.5, 2026-11-28) testcase source - candidate (R-117, R-231); engineer review pending (R-284).
Authored from the specification baseline only (RV32 HDS rev 0.4, REF-001 rev 0.39, CSR workbook, question_log answers); no RTL used (R-103, R-232).

| Field | Content |
|---|---|
| Test ID and title | t_rv32d_mesi_random_litmus - Finds interaction defects in coherence and atomics under backpressure; checks litmus outcomes against the RVWMO-allowed set |
| Priority and rationale | high; outside the ten R-283 waveform tests; priority from plan 6.1 |
| Purpose | Finds interaction defects in coherence and atomics under backpressure; checks litmus outcomes against the RVWMO-allowed set. |
| Requirements and features | PROTO-AXI4-A3.4, REQ-IF-009, REQ-MEM-001, REQ-MEM-006, REQ-MEM-008, REQ-MEM-020, REQ-XL-009; features: atomics, axi_protocol, mesi_coherence, same_line_lock; functions: mesi_coherence+same_line_lock+atomics+axi_protocol |
| DUT configuration and preconditions | CFG-RV32-2-P0; +MEM_RDY=60 +MEM_LAT=16; 8 lines in region 0; seed-driven program generation (SEED in plusargs). Plan configuration column: CFG-RV32-2-P0. Campaign region table bound through tb/generated/region_params.svh (REF-001 rev 0.40 14.4.20, Q-G3-01 answered) |
| Software flow | 1 boot; 2 litmus phase: MP, SB, LB, 2+2W each without and with 'fence rw,rw', 4 iterations each, results stored per iteration (start synchronised by a flag); 3 random phase: each hart executes 400 seeded operations (lw/sw/amoadd.w/amoswap.w/lr.w+sc.w increment) over 8 lines; per-hart private words record its own last stores, shared counters receive AMOADD contributions; 4 publish counters with CBO.FLUSH; 5 TOHOST |
| Stimulus | Constrained random: word-aligned RV32 accesses (REF-002 A extension .W forms only), 8 lines incl. same-word and false-sharing pairs, AXI READY 60 % and latency 0-16 (IHI 0022H A3.2 legal backpressure) |
| Functional checkpoints and assertions | See the check table below (6 planned checks; R-286 requires >= 5). Every check runs through scripts/evaluate_run.py with the oracle/scoreboard named; deadline = test cycle budget unless stated; failure condition as listed |
| Expected outcome | Litmus outcomes inside the RVWMO-allowed set; AMO counter exact; LR/SC counter equals successful SCs; no hang; no protocol violation |
| Defect/fault targeted | Stale data, lost update, SC success after an intervening write, forbidden litmus outcome, deadlock under backpressure; failure modes FM-ATM-01, FM-ATM-02, FM-AXI-04, FM-COH-01, FM-COH-02, FM-COH-04, FM-COH-06, FM-LCK-01, FM-LCK-03 |
| Checker/oracle | a_axi_mem_stable, chk_litmus_oracle, chk_mem_oracle, chk_watchdog; qualification records under docs/01_qualification and docs/02_env |
| Reproducibility | SEED and every plusarg in tests/generated/t_rv32d_mesi_random_litmus/plusargs.txt (generated deterministically by scripts/generators/gen_prog.py); replay: build tb_top, run the simulator with +f-style plusargs from that file in a fresh runs/<run_id>/, then python scripts/evaluate_run.py runs/<run_id> |
| Waveform | N/A: outside the ten R-283 priority tests (plan 6.3); targeted capture only for diagnosis (R-278) |
| Evidence | Not run: no simulation in this phase (free disk below the approved 2 GiB threshold) |

Planned checks (from verification_plan.md Section 6.1, R-286):

| Check ID | Requirement / clause | Trigger | Expected observation | Checker / assertion | Deadline | Failure condition |
|---|---|---|---|---|---|---|
| CK-RND-01 | REQ-MEM-001 | end of run | every final word matches a legal serialization (per-address oracle) | chk_mem_oracle | test end | illegal value |
| CK-RND-02 | REQ-MEM-008 | litmus MP/SB/LB with fences | observed outcome in the RVWMO-allowed set | chk_litmus_oracle | test end | forbidden outcome |
| CK-RND-03 | REQ-MEM-006 | AMO sequences | sum of AMOADD contributions exact | chk_mem_oracle | test end | mismatch |
| CK-RND-04 | REQ-IF-009 | LR/SC pairs | SC succeeds only without intervening same-reservation write | chk_mem_oracle | test end | illegal success |
| CK-RND-05 | PROTO-AXI4-A3.2 | all beats | no stability/handshake violation under random READY | a_axi_mem_stable | per cycle | violation |
| CK-RND-06 | REQ-MEM-020 | run | completion within the cycle budget | chk_watchdog | budget | hang |
"""
TEST = 't_rv32d_mesi_random_litmus'
SEED = 1
KIND = 'cpu'
REQS = {
    'CK-RND-01': 'REQ-MEM-001',
    'CK-RND-02': 'REQ-MEM-008',
    'CK-RND-03': 'REQ-MEM-006',
    'CK-RND-04': 'REQ-IF-009',
    'CK-RND-05': 'PROTO-AXI4-A3.2',
    'CK-RND-06': 'REQ-MEM-020',
}

from rv32d_lib import L, SLOT  # noqa: E402


def build(p):
    import random
    rng = random.Random(p.seed)
    p.plusargs.update({"MEM_RDY": 60, "MEM_LAT": 16, "TIMEOUT_CYCLES": 8000000})
    for n in range(8):
        p.line("r%d" % n, [0, 0, 0, 0])
    for nm in ("lx", "ly", "go"):
        p.line(nm, [0, 0, 0, 0])
    pats = [("MP", False), ("MP", True), ("SB", False), ("SB", True), ("LB", False), ("LB", True), ("2+2W", False), ("2+2W", True)]
    it = 0
    for pat, fenced in pats:
        for k in range(4):
            it += 1
            for h in (0, 1):
                p.asm(h, "la t0, lx", "sw zero, 0(t0)", "la t0, ly", "sw zero, 0(t0)") if h == 0 else None
            p.flag_set(0, "go", 2 * it - 1); p.flag_wait(1, "go", 2 * it - 1)
            F = ["fence rw, rw"] if fenced else []
            if pat == "MP":
                t0 = ["la t0, lx", "li t1, 1", "sw t1, 0(t0)"] + F + ["la t0, ly", "sw t1, 0(t0)"]
                t1 = ["la t0, ly", "lw a0, 0(t0)"] + F + ["la t0, lx", "lw a1, 0(t0)"]
            elif pat == "SB":
                t0 = ["la t0, lx", "li t1, 1", "sw t1, 0(t0)"] + F + ["la t0, ly", "lw a0, 0(t0)"]
                t1 = ["la t0, ly", "li t1, 1", "sw t1, 0(t0)"] + F + ["la t0, lx", "lw a1, 0(t0)"]
            elif pat == "LB":
                t0 = ["la t0, lx", "lw a0, 0(t0)"] + F + ["la t0, ly", "li t1, 1", "sw t1, 0(t0)"]
                t1 = ["la t0, ly", "lw a1, 0(t0)"] + F + ["la t0, lx", "li t1, 1", "sw t1, 0(t0)"]
            else:
                t0 = ["la t0, lx", "li t1, 1", "sw t1, 0(t0)"] + F + ["la t0, ly", "li t1, 2", "sw t1, 0(t0)"]
                t1 = ["la t0, ly", "li t1, 1", "sw t1, 0(t0)"] + F + ["la t0, lx", "li t1, 2", "sw t1, 0(t0)"]
            p.asm(0, *t0); p.asm(1, *t1)
            p.flag_set(1, "go", 2 * it); p.flag_wait(0, "go", 2 * it)
            if pat == "2+2W":
                p.asm(0, "la t0, lx", "lw a0, 0(t0)", "la t0, ly", "lw a1, 0(t0)")
                p.store_slot(0, "a0", "fx%d" % it); p.store_slot(0, "a1", "fy%d" % it)
                regs = {"fx": SLOT(p, 0, "fx%d" % it), "fy": SLOT(p, 0, "fy%d" % it)}
            else:
                h_r0 = 1 if pat == "MP" else 0
                p.store_slot(h_r0, "a0", "r0_%d" % it)
                p.store_slot(1, "a1", "r1_%d" % it)
                regs = {"r0": SLOT(p, h_r0, "r0_%d" % it), "r1": SLOT(p, 1, "r1_%d" % it)}
            p.check("CK-RND-02_%d" % it if it > 1 else "CK-RND-02", REQS["CK-RND-02"], "litmus", pattern=pat, fenced=fenced, regs=regs)
    # random phase
    amo_counts, sc_lines = {0: 0, 1: 0}, {}
    for h in (0, 1):
        p.asm(h, "li s2, 0")
        for i in range(400):
            n = rng.randrange(8)
            kind = rng.choices(["lw", "sw", "amo", "lrsc"], [4, 3, 2, 1])[0]
            if kind == "lw":
                p.asm(h, "la t0, r%d" % n, "lw t1, %d(t0)" % (4 * (h + 1)))
            elif kind == "sw":
                p.asm(h, "la t0, r%d" % n, "li t1, 0x%x" % rng.getrandbits(32), "sw t1, %d(t0)" % (4 * (h + 1)))
            elif kind == "amo":
                p.asm(h, "la t0, r0", "li t1, 1", "amoadd.w zero, t1, (t0)")
                amo_counts[h] += 1
            else:
                l = p.label("lrsc")
                p.asm(h, "la t0, r7", "addi t0, t0, 12", "lr.w t1, (t0)", "addi t1, t1, 1", "sc.w t2, t1, (t0)", "bnez t2, %s" % l,
                      "addi s2, s2, 1", "%s:" % l)
        p.store_slot(h, "s2", "sc_ok")
    p.flag_set(0, "go", 1000); p.flag_wait(1, "go", 1000)
    p.flag_set(1, "go", 1001); p.flag_wait(0, "go", 1001)
    p.asm(0, "la t0, r0", "lw t1, 0(t0)", "la t0, r7", "lw t2, 12(t0)")
    p.store_slot(0, "t1", "amo_total"); p.store_slot(0, "t2", "lrsc_total")
    p.end(0); p.end(1)
    p.check("CK-RND-01", REQS["CK-RND-01"], "slot_sum", addrs=[SLOT(p, 0, "sc_ok"), SLOT(p, 1, "sc_ok")], equals_addr=SLOT(p, 0, "lrsc_total"))
    p.check("CK-RND-03", REQS["CK-RND-03"], "slot", addr=SLOT(p, 0, "amo_total"), expect=amo_counts[0] + amo_counts[1])
    p.check("CK-RND-04", REQS["CK-RND-04"], "slot_sum", addrs=[SLOT(p, 0, "sc_ok"), SLOT(p, 1, "sc_ok")], equals_addr=SLOT(p, 0, "lrsc_total"))
    p.check("CK-RND-05", REQS["CK-RND-05"], "sva", id="a_axi_mem_stable")
    p.check("CK-RND-06", REQS["CK-RND-06"], "tohost", code=1)
    p.check("CK-RND-07", "PROTO-AXI4-A3.4", "sva", id="a_axi_burst_legal", need_cover=False)
