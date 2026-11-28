"""
AI-GENERATED (Claude Opus 5.5, 2026-11-28) testcase source - candidate (R-117, R-231); engineer review pending (R-284).
Authored from the specification baseline only (RV32 HDS rev 0.4, REF-001 rev 0.39, CSR workbook, question_log answers); no RTL used (R-103, R-232).

| Field | Content |
|---|---|
| Test ID and title | t_rv32d_atomics_uncached - Proves REQ-IF-009 uncached atomics at the memory boundary (region 3 of the Q-G0-03 table) |
| Priority and rationale | high; outside the ten R-283 waveform tests; priority from plan 6.1 |
| Purpose | Proves REQ-IF-009 uncached atomics at the memory boundary (region 3 of the Q-G0-03 table). |
| Requirements and features | PROTO-AXI4-A3.4, PROTO-AXI4-A7.2, PROTO-AXI5-E1.1, REQ-IF-003, REQ-IF-009; features: atomics, axi_protocol; functions: atomics+region_table+axi_protocol |
| DUT configuration and preconditions | CFG-RV32-2-P0; normal-uncached region 3 at 0x40000000; memory BFM implements the A7.2 exclusive monitor and E1.1 atomic service. Plan configuration column: CFG-RV32-2-P0. Campaign region table bound through tb/generated/region_params.svh (REF-001 rev 0.40 14.4.20, Q-G3-01 answered) |
| Software flow | 1 boot; 2 checkpoint 0xE0; hart 0: LR.W/SC.W increment of 0x40000200 (exclusive pair), AMOADD/AMOSWAP/AMOXOR/AMOAND/AMOOR/AMOMIN/AMOMAX/AMOMINU/AMOMAXU.W on 0x40000210..0x40000230 storing old values; hart 1 interleaves a plain store to 0x40000200 between an LR and SC of its own (SC must fail); checkpoint 0xE1; 3 TOHOST |
| Stimulus | Uncached LR/SC and every AMO*.W to a normal-uncached region |
| Functional checkpoints and assertions | See the check table below (5 planned checks; R-286 requires >= 5). Every check runs through scripts/evaluate_run.py with the oracle/scoreboard named; deadline = test cycle budget unless stated; failure condition as listed |
| Expected outcome | AxLOCK set for the LR/SC pair; AWATOP legal with size 4; old values and final memory equal the A-extension model; hart 1's SC returns failure |
| Defect/fault targeted | Exclusive signalling missing, SC succeeding after an intervening write, wrong old value or memory result, illegal AWATOP; failure modes FM-ATM-02, FM-ATM-04, FM-AXI-04 |
| Checker/oracle | a_awatop_legal, chk_axi_mem_sb, chk_mem_oracle; qualification records under docs/01_qualification and docs/02_env |
| Reproducibility | SEED and every plusarg in tests/generated/t_rv32d_atomics_uncached/plusargs.txt (generated deterministically by scripts/generators/gen_prog.py); replay: build tb_top, run the simulator with +f-style plusargs from that file in a fresh runs/<run_id>/, then python scripts/evaluate_run.py runs/<run_id> |
| Waveform | N/A: outside the ten R-283 priority tests (plan 6.3); targeted capture only for diagnosis (R-278) |
| Evidence | Not run: no simulation in this phase (free disk below the approved 2 GiB threshold) |

Planned checks (from verification_plan.md Section 6.1, R-286):

| Check ID | Requirement / clause | Trigger | Expected observation | Checker / assertion | Deadline | Failure condition |
|---|---|---|---|---|---|---|
| CK-UAT-01 | REQ-IF-009 | LR.W/SC.W | ARLOCK/AWLOCK=1; EXOKAY -> SC success rd=0; OKAY -> SC fails rd=1, no trap (Q-G0-06) | chk_axi_mem_sb | op | mismatch |
| CK-UAT-02 | PROTO-AXI5-E1.1 | AMO*.W | AWATOP is a legal E1.1 encoding with AWSIZE=2 (4 bytes) | a_awatop_legal | per AW | illegal |
| CK-UAT-03 | REQ-IF-009 | AMO*.W | old value returned to rd; memory equals op result | chk_mem_oracle | test end | mismatch |
| CK-UAT-04 | PROTO-AXI4-A7.2 | exclusive pair | exclusive read/write use same ID, address, size | chk_axi_mem_sb | op | mismatch |
| CK-UAT-05 | REQ-IF-003 | AMO responses | B and R for AWATOP routed to the issuing hart | chk_axi_mem_sb | op | misrouted |
"""
TEST = 't_rv32d_atomics_uncached'
SEED = 1
KIND = 'cpu'
REQS = {
    'CK-UAT-01': 'REQ-IF-009',
    'CK-UAT-02': 'PROTO-AXI5-E1.1',
    'CK-UAT-03': 'REQ-IF-009',
    'CK-UAT-04': 'PROTO-AXI4-A7.2',
    'CK-UAT-05': 'REQ-IF-003',
}

from rv32d_lib import L, SLOT  # noqa: E402


def build(p):
    import chk_mem_oracle as M
    init = {0x40000210 + 4 * i: v for i, v in enumerate([10, 20, 0xF0, 0xFF, 0x0F, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 1])}
    ops = ["amoadd.w", "amoswap.w", "amoxor.w", "amoand.w", "amoor.w", "amomin.w", "amomax.w", "amominu.w", "amomaxu.w"]
    rs2 = [5, 7, 0xFF, 0x0F, 0xF0, 1, 1, 1, 0xFFFFFFFF]
    p.ckpt(0, 0xE0)
    for a, v in init.items():
        p.asm(0, "li t0, 0x%x" % a, "li t1, 0x%x" % v, "sw t1, 0(t0)")
    p.asm(0, "li t0, 0x40000200", "sw zero, 0(t0)", "lr.w t1, (t0)", "addi t1, t1, 1", "sc.w t2, t1, (t0)")
    p.store_slot(0, "t2", "sc0")
    for i, (op, r) in enumerate(zip(ops, rs2)):
        p.asm(0, "li t0, 0x%x" % (0x40000210 + 4 * i), "li t1, 0x%x" % r, "%s t2, t1, (t0)" % op, "lw t3, 0(t0)")
        p.store_slot(0, "t2", "old%d" % i); p.store_slot(0, "t3", "new%d" % i)
    p.word("go", 0)
    p.flag_set(0, "go", 1); p.flag_wait(1, "go", 1)
    p.asm(1, "li t0, 0x40000204", "lr.w t1, (t0)", "li t2, 0x55", "sw t2, 0(t0)", "addi t1, t1, 1", "sc.w t3, t1, (t0)")
    p.store_slot(1, "t3", "sc1")
    p.flag_set(1, "go", 2); p.flag_wait(0, "go", 2)
    p.ckpt(0, 0xE1)
    p.end(0); p.end(1)
    vals = {}
    for i, (op, r) in enumerate(zip(ops, rs2)):
        a = 0x40000210 + 4 * i
        vals[str(SLOT(p, 0, "old%d" % i))] = init[a]
        vals[str(SLOT(p, 0, "new%d" % i))] = M.amo(op, init[a], r)
    p.check("CK-UAT-01", REQS["CK-UAT-01"], "axi_mem", rules=[{"kind": "lock", "dir": "r", "lo": 0x40000200, "hi": 0x40000203, "window": [0xE0, 0xE1]},
                                                             {"kind": "lock", "dir": "w", "lo": 0x40000200, "hi": 0x40000203, "window": [0xE0, 0xE1]}])
    p.check("CK-UAT-01b", REQS["CK-UAT-01"], "slots", values={str(SLOT(p, 0, "sc0")): 0, str(SLOT(p, 1, "sc1")): 1})
    p.check("CK-UAT-02", REQS["CK-UAT-02"], "sva", id="a_awatop_legal")
    p.check("CK-UAT-02b", REQS["CK-UAT-02"], "axi_mem", rules=[{"kind": "atop", "lo": 0x40000210, "hi": 0x40000233, "window": [0xE0, 0xE1], "min": 9}])
    p.check("CK-UAT-03", REQS["CK-UAT-03"], "slots", values=vals)
    p.check("CK-UAT-04", REQS["CK-UAT-04"], "axi_mem", rules=[{"kind": "structural", "window": [None, None]}])
    p.check("CK-UAT-05", REQS["CK-UAT-05"], "tohost", code=1)
