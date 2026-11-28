"""
AI-GENERATED (Claude Opus 5.5, 2026-11-28) testcase source - candidate (R-117, R-231); engineer review pending (R-284).
Authored from the specification baseline only (RV32 HDS rev 0.4, REF-001 rev 0.39, CSR workbook, question_log answers); no RTL used (R-103, R-232).

| Field | Content |
|---|---|
| Test ID and title | t_rv32d_irq_wfi_coherence - Proves probe service during WFI and per-hart external interrupt wake-up |
| Priority and rationale | high; outside the ten R-283 waveform tests; priority from plan 6.1 |
| Purpose | Proves probe service during WFI and per-hart external interrupt wake-up. |
| Requirements and features | REQ-CLK-002, REQ-IRQ-001, REQ-IRQ-003, REQ-MEM-012; features: irq_routing, mesi_coherence, wfi_probe; functions: irq_routing+wfi_probe+mesi_coherence |
| DUT configuration and preconditions | CFG-RV32-2-P0; hart 0 enables MEIE and mstatus.MIE. Plan configuration column: CFG-RV32-2-P0. Campaign region table bound through tb/generated/region_params.svh (REF-001 rev 0.40 14.4.20, Q-G3-01 answered) |
| Software flow | 1 boot; 2 hart 0 dirties line wl, sets flag, executes WFI; 3 hart 1 waits ~2000 cycles, reads wl (probe while hart 0 sleeps), stores the value, then raises MEIP[0] through the MMIO IRQ register; 4 hart 0 wakes, takes interrupt 0x8000000B (handler drops the level), reads wl again; 5 hart 1 records its own trap count (must be 0); 6 TOHOST |
| Stimulus | Probe service for a line owned by a hart in WFI; per-hart external interrupt wake-up |
| Functional checkpoints and assertions | See the check table below (5 planned checks; R-286 requires >= 5). Every check runs through scripts/evaluate_run.py with the oracle/scoreboard named; deadline = test cycle budget unless stated; failure condition as listed |
| Expected outcome | Hart 1 reads hart 0's value without hang; only hart 0 takes cause 0x8000000B; MEIP level drops after service |
| Defect/fault targeted | Hang on a sleeping owner, misrouted or sticky interrupt; failure modes FM-IRQ-01, FM-IRQ-02, FM-WFI-01 |
| Checker/oracle | chk_mem_oracle, chk_sig, chk_trap_oracle, chk_watchdog; qualification records under docs/01_qualification and docs/02_env |
| Reproducibility | SEED and every plusarg in tests/generated/t_rv32d_irq_wfi_coherence/plusargs.txt (generated deterministically by scripts/generators/gen_prog.py); replay: build tb_top, run the simulator with +f-style plusargs from that file in a fresh runs/<run_id>/, then python scripts/evaluate_run.py runs/<run_id> |
| Waveform | N/A: outside the ten R-283 priority tests (plan 6.3); targeted capture only for diagnosis (R-278) |
| Evidence | Not run: no simulation in this phase (free disk below the approved 2 GiB threshold) |

Planned checks (from verification_plan.md Section 6.1, R-286):

| Check ID | Requirement / clause | Trigger | Expected observation | Checker / assertion | Deadline | Failure condition |
|---|---|---|---|---|---|---|
| CK-WFI-01 | REQ-CLK-002 | hart 1 load while hart 0 in WFI | latest value read, no hang | chk_mem_oracle; chk_watchdog | budget | hang/stale |
| CK-WFI-02 | REQ-IRQ-003 | MEIP[0] asserted | hart 0 wakes and traps with mcause interrupt 11 | chk_trap_oracle | 1000 cycles | no trap |
| CK-WFI-03 | REQ-IRQ-001 | MEIP[0] asserted | hart 1 not interrupted | chk_trap_oracle | test end | trap on hart 1 |
| CK-WFI-04 | REQ-CLK-002 | after wake | hart 0 resumes and re-reads the line (now S or I) correctly | chk_mem_oracle | test end | mismatch |
| CK-WFI-05 | REQ-IRQ-001 | MEIP deassert | mip.MEIP clears (level) | chk_sig | test end | sticky |
"""
TEST = 't_rv32d_irq_wfi_coherence'
SEED = 1
KIND = 'cpu'
REQS = {
    'CK-WFI-01': 'REQ-CLK-002',
    'CK-WFI-02': 'REQ-IRQ-003',
    'CK-WFI-03': 'REQ-IRQ-001',
    'CK-WFI-04': 'REQ-CLK-002',
    'CK-WFI-05': 'REQ-IRQ-001',
}

from rv32d_lib import L, SLOT  # noqa: E402


def build(p):
    p.line("wl", [0, 0, 0, 0])
    p.word("go", 0)
    p.asm(0, "li t0, 0x800", "csrs mie, t0", "li t0, 0x8", "csrs mstatus, t0", "la t0, wl", "li t1, 0x0EE0F00D", "sw t1, 0(t0)")
    p.flag_set(0, "go", 1)
    p.asm(0, "wfi")
    p.asm(0, "la t0, wl", "lw t2, 0(t0)")
    p.store_slot(0, "t2", "after_wake")
    p.flag_wait(1, "go", 1)
    p.delay(1, 2000)
    p.asm(1, "la t0, wl", "lw t1, 0(t0)")
    p.store_slot(1, "t1", "peer")
    p.irq(1, 0, "meip", 1)
    p.end(0); p.end(1)
    p.check("CK-WFI-01", REQS["CK-WFI-01"], "slot", addr=SLOT(p, 1, "peer"), expect=0x0EE0F00D)
    p.check("CK-WFI-02", REQS["CK-WFI-02"], "trap_cause", hart=0, cause=0x8000000B, present=True)
    p.check("CK-WFI-03", REQS["CK-WFI-03"], "trap_cause", hart=1, cause=0x8000000B, present=False)
    p.check("CK-WFI-04", REQS["CK-WFI-04"], "slot", addr=SLOT(p, 0, "after_wake"), expect=0x0EE0F00D)
    p.check("CK-WFI-05", REQS["CK-WFI-05"], "pin", name="i_int_meip", index=0, rule="final", value=0)
    p.check("CK-WFI-06", "REQ-CLK-002", "tohost", code=1)
