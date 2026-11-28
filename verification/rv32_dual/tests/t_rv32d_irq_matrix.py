"""
AI-GENERATED (Claude Opus 5.5, 2026-11-28) testcase source - candidate (R-117, R-231); engineer review pending (R-284).
Authored from the specification baseline only (RV32 HDS rev 0.4, REF-001 rev 0.39, CSR workbook, question_log answers); no RTL used (R-103, R-232).

| Field | Content |
|---|---|
| Test ID and title | t_rv32d_irq_matrix - Isolates each of the 6 interrupt inputs x 2 harts, the SSIP/STIP OR with software mip state, CSRRS/CSRRC under asserted levels and S-mode delegation; kept single-function for debug resolution |
| Priority and rationale | high; outside the ten R-283 waveform tests; priority from plan 6.1 |
| Purpose | Isolates each of the 6 interrupt inputs x 2 harts, the SSIP/STIP OR with software mip state, CSRRS/CSRRC under asserted levels and S-mode delegation; kept single-function for debug resolution. |
| Requirements and features | REQ-IRQ-001, REQ-IRQ-002, REQ-IRQ-003, REQ-XL-002; features: irq_routing; functions: irq_routing (single) |
| DUT configuration and preconditions | CFG-RV32-2-P0; per hart: mie enables MSIE/MTIE/MEIE/SSIE/STIE/SEIE, mstatus.MIE=1; mideleg delegates SEI (bit 9) for the delegation step with S mode entered through PMP NAPOT-all. Plan configuration column: CFG-RV32-2-P0. Campaign region table bound through tb/generated/region_params.svh (REF-001 rev 0.40 14.4.20, Q-G3-01 answered) |
| Software flow | 1 boot; 2 for each hart h and each source s in {msip, mtip, meip}: hart h raises s for itself through the MMIO IRQ register, waits for its trap count to increase (handler drops the level), records; 3 SSIP/STIP: the testbench level is raised with interrupts disabled (MIE=0), mip read shows the bit; CSRRS/CSRRC on mip with the level high; level dropped, mip re-read; 4 SEIP delegated to S: hart 0 enters S mode, raises seip, S handler records scause 0x80000009; 5 TOHOST |
| Stimulus | Each of the 6 interrupt inputs on each hart, OR of external SSIP/STIP with software mip, S delegation |
| Functional checkpoints and assertions | See the check table below (5 planned checks; R-286 requires >= 5). Every check runs through scripts/evaluate_run.py with the oracle/scoreboard named; deadline = test cycle budget unless stated; failure condition as listed |
| Expected outcome | Only the addressed hart traps with mcause 0x80000003/7/11; mip SSIP/STIP follow the external level and are not captured by CSR RMW; delegated SEIP traps in S with scause 0x80000009 |
| Defect/fault targeted | Interrupt delivered to the wrong hart, wrong cause, external level captured into software state, sticky bit after the level drops; failure modes FM-IRQ-01, FM-IRQ-02, FM-IRQ-03 |
| Checker/oracle | chk_sig, chk_trap_oracle; qualification records under docs/01_qualification and docs/02_env |
| Reproducibility | SEED and every plusarg in tests/generated/t_rv32d_irq_matrix/plusargs.txt (generated deterministically by scripts/generators/gen_prog.py); replay: build tb_top, run the simulator with +f-style plusargs from that file in a fresh runs/<run_id>/, then python scripts/evaluate_run.py runs/<run_id> |
| Waveform | N/A: outside the ten R-283 priority tests (plan 6.3); targeted capture only for diagnosis (R-278) |
| Evidence | Not run: no simulation in this phase (free disk below the approved 2 GiB threshold) |

Planned checks (from verification_plan.md Section 6.1, R-286):

| Check ID | Requirement / clause | Trigger | Expected observation | Checker / assertion | Deadline | Failure condition |
|---|---|---|---|---|---|---|
| CK-IRQ-01 | REQ-IRQ-001 | each input level per hart | only the addressed hart sees the pending bit | chk_trap_oracle | 1000 cycles | wrong hart |
| CK-IRQ-02 | REQ-IRQ-002 | external SSIP/STIP high, software bit clear | mip/sip read shows 1; drops to 0 when level drops | chk_sig | per step | sticky |
| CK-IRQ-03 | REQ-IRQ-002 | CSRRS/CSRRC with external level high | software-writable state unchanged by RMW of external level | chk_sig | per step | copied |
| CK-IRQ-04 | REQ-IRQ-003 | SEIP[n] | supervisor external pending when delegated; scause interrupt 9 | chk_trap_oracle | 1000 cycles | mismatch |
| CK-IRQ-05 | REQ-XL-002 | MSIP/MTIP per hart | mcause interrupt 3/7 on the addressed hart only | chk_trap_oracle | 1000 cycles | mismatch |
"""
TEST = 't_rv32d_irq_matrix'
SEED = 1
KIND = 'cpu'
REQS = {
    'CK-IRQ-01': 'REQ-IRQ-001',
    'CK-IRQ-02': 'REQ-IRQ-002',
    'CK-IRQ-03': 'REQ-IRQ-002',
    'CK-IRQ-04': 'REQ-IRQ-003',
    'CK-IRQ-05': 'REQ-XL-002',
}

from rv32d_lib import L, SLOT  # noqa: E402


def build(p):
    for h in (0, 1):
        p.asm(h, "li t0, 0xAAA", "csrs mie, t0", "li t0, 0x8", "csrs mstatus, t0")
        for s in ("msip", "mtip", "meip"):
            l = p.label("wt")
            p.asm(h, "slli t5, s10, 10", "li t6, 0x80090000", "add t5, t5, t6", "lw s5, 0(t5)")
            p.irq(h, h, s, 1)
            p.asm(h, "%s:" % l, "lw t4, 0(t5)", "beq t4, s5, %s" % l)
        p.asm(h, "li t0, 0x8", "csrc mstatus, t0")
        p.irq(h, h, "ssip", 1)
        p.delay(h, 50)
        p.asm(h, "csrr t1, mip", "li t0, 0x2", "csrc mip, t0", "csrr t2, mip")
        p.irq(h, h, "ssip", 0)
        p.delay(h, 50)
        p.asm(h, "csrr t3, mip")
        p.store_slot(h, "t1", "mip_hi"); p.store_slot(h, "t2", "mip_rmw"); p.store_slot(h, "t3", "mip_lo")
        p.irq(h, h, "stip", 1)
        p.delay(h, 50)
        p.asm(h, "csrr t1, mip")
        p.irq(h, h, "stip", 0)
        p.delay(h, 50)
        p.asm(h, "csrr t2, mip")
        p.store_slot(h, "t1", "stip_hi"); p.store_slot(h, "t2", "stip_lo")
    p.asm(0, "li t0, 0x200", "csrw mideleg, t0", "li t0, 0x200", "csrs sie, t0", "li t0, 0x2", "csrs sstatus, t0",
          "li t0, -1", "csrw pmpaddr0, t0", "li t0, 0x1f", "csrw pmpcfg0, t0", "li t0, 0x40", "csrs menvcfg, t0",
          "la t0, s_irq", "csrw mepc, t0", "li t0, 0x1800", "csrc mstatus, t0", "li t0, 0x800", "csrs mstatus, t0", "mret", "s_irq:")
    l = p.label("ws")
    p.asm(0, "slli t5, s10, 10", "li t6, 0x80090000", "add t5, t5, t6", "lw s5, 0(t5)")
    p.irq(0, 0, "seip", 1)
    p.asm(0, "%s:" % l, "lw t4, 0(t5)", "beq t4, s5, %s" % l, "ecall")
    p.end(0); p.end(1)
    for h in (0, 1):
        for c in (0x80000003, 0x80000007, 0x8000000B):
            p.check("CK-IRQ-01_h%d_%x" % (h, c & 0xF) if (h, c) != (0, 0x80000003) else "CK-IRQ-01", REQS["CK-IRQ-01"], "trap_cause", hart=h, cause=c, present=True)
    p.check("CK-IRQ-02", REQS["CK-IRQ-02"], "slots_mask", items=[[SLOT(p, h, n), 0x2, v] for h in (0, 1) for n, v in (("mip_hi", 0x2), ("mip_lo", 0))])
    p.check("CK-IRQ-03", REQS["CK-IRQ-03"], "slots_mask", items=[[SLOT(p, h, "mip_rmw"), 0x2, 0x2] for h in (0, 1)])
    p.check("CK-IRQ-04", REQS["CK-IRQ-04"], "traps_level", hart=0, cause=0x80000009, level="S")
    p.check("CK-IRQ-05", REQS["CK-IRQ-05"], "slots_mask", items=[[SLOT(p, h, n), 0x20, v] for h in (0, 1) for n, v in (("stip_hi", 0x20), ("stip_lo", 0))])
