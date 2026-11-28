"""
AI-GENERATED (Claude Opus 5.5, 2026-11-28) testcase source - candidate (R-117, R-231); engineer review pending (R-284).
Authored from the specification baseline only (RV32 HDS rev 0.4, REF-001 rev 0.39, CSR workbook, question_log answers); no RTL used (R-103, R-232).

| Field | Content |
|---|---|
| Test ID and title | t_rv32d_fencei_smc - Proves local FENCE |
| Priority and rationale | high; rank 4 of the plan 6.3 risk-ranked list: Stale-instruction consequence; no-DRAM-write rule |
| Purpose | Proves local FENCE.I clean-to-LLC semantics and per-hart software notification for self-modifying code. |
| Requirements and features | PROTO-RISCV-ZIFENCEI, REQ-IRQ-001, REQ-MEM-007, REQ-MEM-018, REQ-XL-012; features: fence_i, hpdcache_word32, irq_routing; functions: fence_i+irq_routing+mesi_coherence+hpdcache_word32 |
| DUT configuration and preconditions | CFG-RV32-2-P0; subroutine patch_site in region 0 code, initially 'addi a1, zero, 1; ret'. Plan configuration column: CFG-RV32-2-P0. Campaign region table bound through tb/generated/region_params.svh (REF-001 rev 0.40 14.4.20, Q-G3-01 answered) |
| Software flow | 1 boot; 2 both harts call patch_site (prime I-cache), store a1; 3 hart 0 stores the encoding of 'addi a1, zero, 2' over patch_site (dirty D-cache line), checkpoint 0x51, FENCE.I, checkpoint 0x52 (minstret read around the FENCE.I), calls patch_site; 4 hart 0 raises MSIP of hart 1 through the MMIO IRQ register; 5 hart 1 (MIE/MSIE enabled) takes the machine software interrupt (handler drops the level), calls patch_site before its own FENCE.I (old or new allowed), executes FENCE.I, calls patch_site again; 6 TOHOST |
| Stimulus | Self-modifying code with a dirty code line; per-hart MSIP notification; FENCE.I on each hart |
| Functional checkpoints and assertions | See the check table below (6 planned checks; R-286 requires >= 5). Every check runs through scripts/evaluate_run.py with the oracle/scoreboard named; deadline = test cycle budget unless stated; failure condition as listed |
| Expected outcome | Hart 0 executes the new code after its FENCE.I without any external memory write in the FENCE.I window; hart 1 executes the new code after its own FENCE.I; only hart 1 takes interrupt cause 0x80000003 |
| Defect/fault targeted | Stale fetch after FENCE.I, LLC-to-DRAM writeback caused by FENCE.I, FENCE.I treated as broadcast, interrupt routed to the wrong hart; failure modes FM-FEI-01, FM-FEI-02, FM-FEI-03, FM-IRQ-01, FM-W32-02 |
| Checker/oracle | chk_axi_mem_sb, chk_sig, chk_trap_oracle; qualification records under docs/01_qualification and docs/02_env |
| Reproducibility | SEED and every plusarg in tests/generated/t_rv32d_fencei_smc/plusargs.txt (generated deterministically by scripts/generators/gen_prog.py); replay: build tb_top, run the simulator with +f-style plusargs from that file in a fresh runs/<run_id>/, then python scripts/evaluate_run.py runs/<run_id> |
| Waveform | wave.vcd of the run (TOP ports and checkpoint window, +WAVE=wave.vcd +WAVE_SCOPE=ports); R-283 rank 4 |
| Evidence | Not run: no simulation in this phase (free disk below the approved 2 GiB threshold) |

Planned checks (from verification_plan.md Section 6.1, R-286):

| Check ID | Requirement / clause | Trigger | Expected observation | Checker / assertion | Deadline | Failure condition |
|---|---|---|---|---|---|---|
| CK-SMC-01 | REQ-MEM-018 | first fetch of new code on hart 0 | new instruction result in signature | chk_sig | test end | old result |
| CK-SMC-02 | REQ-MEM-018 | FENCE.I window | no external memory AW caused by FENCE.I | chk_axi_mem_sb | FENCE.I retire | AW observed |
| CK-SMC-03 | REQ-MEM-007 | hart 1 after its FENCE.I | hart 1 executes the new code | chk_sig | test end | old code |
| CK-SMC-04 | REQ-IRQ-001 | MSIP[1] asserted | only hart 1 takes the machine software interrupt (mcause interrupt 3) | chk_trap_oracle | 1000 cycles | hart 0 traps or hart 1 does not |
| CK-SMC-05 | REQ-MEM-007 | before hart 1 FENCE.I | hart 1 result is old or new (both allowed); no hang | chk_sig | test end | illegal value |
| CK-SMC-06 | PROTO-RISCV-ZIFENCEI | hart 0 FENCE.I retire | minstret advances once per FENCE.I | chk_sig | test end | mismatch |
"""
TEST = 't_rv32d_fencei_smc'
SEED = 1
KIND = 'cpu'
REQS = {
    'CK-SMC-01': 'REQ-MEM-018',
    'CK-SMC-02': 'REQ-MEM-018',
    'CK-SMC-03': 'REQ-MEM-007',
    'CK-SMC-04': 'REQ-IRQ-001',
    'CK-SMC-05': 'REQ-MEM-007',
    'CK-SMC-06': 'PROTO-RISCV-ZIFENCEI',
}

from rv32d_lib import L, SLOT  # noqa: E402


def build(p):
    p.waveform = True
    new_insn = p.encode("addi a1, zero, 2")
    p.both("jal ra, patch_site")
    p.store_slot(0, "a1", "old0"); p.store_slot(1, "a1", "old1")
    p.asm(1, "li t0, 0x8", "csrs mie, t0", "li t0, 0x8", "csrs mstatus, t0")
    p.asm(0, "la t0, patch_site", "li t1, 0x%x" % new_insn, "sw t1, 0(t0)")
    p.ckpt(0, 0x51)
    p.asm(0, "csrr t3, minstret", "fence.i", "csrr t4, minstret", "sub t4, t4, t3")
    p.ckpt(0, 0x52)
    p.store_slot(0, "t4", "dinstret")
    p.asm(0, "jal ra, patch_site")
    p.store_slot(0, "a1", "new0")
    p.irq(0, 1, "msip", 1)
    l = "wait_irq"
    p.asm(1, "slli t5, s10, 10", "li t6, 0x80090000", "add t5, t5, t6", "%s:" % l, "lw t4, 0(t5)", "beqz t4, %s" % l)
    p.asm(1, "jal ra, patch_site")
    p.store_slot(1, "a1", "pre1")
    p.asm(1, "fence.i", "jal ra, patch_site")
    p.store_slot(1, "a1", "post1")
    p.end(0); p.end(1)
    p.asm(0, "patch_site:", "addi a1, zero, 1", "ret")
    p.check("CK-SMC-01", REQS["CK-SMC-01"], "slot", addr=SLOT(p, 0, "new0"), expect=2)
    p.check("CK-SMC-01b", REQS["CK-SMC-01"], "slot", addr=SLOT(p, 0, "old0"), expect=1)
    p.check("CK-SMC-02", REQS["CK-SMC-02"], "axi_mem", rules=[{"kind": "no_write", "lo": 0x80000000, "hi": 0xBFFFFFFF, "window": [0x51, 0x52]}])
    p.check("CK-SMC-03", REQS["CK-SMC-03"], "slot", addr=SLOT(p, 1, "post1"), expect=2)
    p.check("CK-SMC-04", REQS["CK-SMC-04"], "trap_cause", hart=1, cause=0x80000003, present=True)
    p.check("CK-SMC-04b", REQS["CK-SMC-04"], "trap_cause", hart=0, cause=0x80000003, present=False)
    p.check("CK-SMC-05", REQS["CK-SMC-05"], "slot", addr=SLOT(p, 1, "pre1"), allowed=[1, 2])
    p.check("CK-SMC-06", REQS["CK-SMC-06"], "slot", addr=SLOT(p, 0, "dinstret"), expect=2)
