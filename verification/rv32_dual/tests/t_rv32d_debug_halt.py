"""
AI-GENERATED (Claude Opus 5.5, 2026-11-28) testcase source - candidate (R-117, R-231); engineer review pending (R-284).
Authored from the specification baseline only (RV32 HDS rev 0.4, REF-001 rev 0.39, CSR workbook, question_log answers); no RTL used (R-103, R-232).

| Field | Content |
|---|---|
| Test ID and title | t_rv32d_debug_halt - Proves per-hart debug request/status and probe service in debug halt, using the testbench debug ROM at 0x800/0x808 in region 2 (Q-G0-07) |
| Priority and rationale | medium; outside the ten R-283 waveform tests; priority from plan 6.1 |
| Purpose | Proves per-hart debug request/status and probe service in debug halt, using the testbench debug ROM at 0x800/0x808 in region 2 (Q-G0-07). |
| Requirements and features | REQ-CLK-002, REQ-DBG-001, REQ-XL-002; features: debug, wfi_probe; functions: debug+wfi_probe+mesi_coherence |
| DUT configuration and preconditions | CFG-RV32-2-P0; testbench debug ROM at 0x800/0x808 in MMIO region 2 (Q-G0-07 A); RESUME/HALTED flags in the MMIO control window. Plan configuration column: CFG-RV32-2-P0. Campaign region table bound through tb/generated/region_params.svh (REF-001 rev 0.40 14.4.20, Q-G3-01 answered) |
| Software flow | 1 boot; 2 hart 0 dirties line dl and spins on a flag; 3 hart 1 requests debug of hart 0 through MMIO DBG_REQ (bit 0), polls HALTED[0], drops the request, reads dl (probe while hart 0 is halted), counts its own progress, writes RESUME[0]=1, polls HALTED[0]=0; 4 hart 0 resumes (dret), continues and records; 5 TOHOST |
| Stimulus | Per-hart debug request with the testbench park-loop ROM; peer read of a line owned by the halted hart |
| Functional checkpoints and assertions | See the check table below (5 planned checks; R-286 requires >= 5). Every check runs through scripts/evaluate_run.py with the oracle/scoreboard named; deadline = test cycle budget unless stated; failure condition as listed |
| Expected outcome | o_hart_debug_mode[0] rises and falls, [1] stays 0; peer reads the latest value during the halt; hart 0 continues after resume |
| Defect/fault targeted | Debug entry on the wrong hart, hang on a halted owner, no resume, stalled peer; failure modes FM-DBG-01, FM-WFI-02 |
| Checker/oracle | a_dbg_mode, chk_mem_oracle, chk_sig; qualification records under docs/01_qualification and docs/02_env |
| Reproducibility | SEED and every plusarg in tests/generated/t_rv32d_debug_halt/plusargs.txt (generated deterministically by scripts/generators/gen_prog.py); replay: build tb_top, run the simulator with +f-style plusargs from that file in a fresh runs/<run_id>/, then python scripts/evaluate_run.py runs/<run_id> |
| Waveform | N/A: outside the ten R-283 priority tests (plan 6.3); targeted capture only for diagnosis (R-278) |
| Evidence | Not run: no simulation in this phase (free disk below the approved 2 GiB threshold) |

Planned checks (from verification_plan.md Section 6.1, R-286):

| Check ID | Requirement / clause | Trigger | Expected observation | Checker / assertion | Deadline | Failure condition |
|---|---|---|---|---|---|---|
| CK-DBG-01 | REQ-DBG-001 | debug_req[0] | o_hart_debug_mode[0]=1 and [1]=0 | a_dbg_mode | 1000 cycles | mismatch |
| CK-DBG-02 | REQ-DBG-001 | resume | o_hart_debug_mode[0]=0; hart 0 continues | chk_sig | test end | stuck |
| CK-DBG-03 | REQ-CLK-002 | peer read in halt | latest value, no hang | chk_mem_oracle | budget | hang |
| CK-DBG-04 | REQ-XL-002 | debug vectors | bit n controls hart n only | a_dbg_mode | test end | cross effect |
| CK-DBG-05 | REQ-DBG-001 | hart 1 progress during halt | hart 1 completes its work | chk_sig | test end | stalled |
"""
TEST = 't_rv32d_debug_halt'
SEED = 1
KIND = 'cpu'
REQS = {
    'CK-DBG-01': 'REQ-DBG-001',
    'CK-DBG-02': 'REQ-DBG-001',
    'CK-DBG-03': 'REQ-CLK-002',
    'CK-DBG-04': 'REQ-XL-002',
    'CK-DBG-05': 'REQ-DBG-001',
}

from rv32d_lib import L, SLOT  # noqa: E402


def build(p):
    p.line("dl", [0, 0, 0, 0])
    p.word("go", 0)
    p.asm(0, "la t0, dl", "li t1, 0xDB6DB6DB", "sw t1, 0(t0)")
    p.flag_set(0, "go", 1)
    l = p.label("spin")
    p.asm(0, "%s:" % l)
    p.flag_wait(0, "go", 2)
    p.asm(0, "li t1, 1")
    p.store_slot(0, "t1", "resumed")
    p.flag_wait(1, "go", 1)
    p.asm(1, "lui t5, 0x10000", "li t6, 1", "sw t6, 0x104(t5)")
    lw = p.label("wh")
    p.asm(1, "%s:" % lw, "lw t4, 0x400(t5)", "beqz t4, %s" % lw, "sw zero, 0x104(t5)")
    p.asm(1, "la t0, dl", "lw t1, 0(t0)")
    p.store_slot(1, "t1", "peer")
    p.asm(1, "li s1, 100", "prog:", "addi s1, s1, -1", "bnez s1, prog")
    p.store_slot(1, "s1", "progress")
    p.asm(1, "lui t5, 0x10000", "li t6, 1", "sw t6, 0x300(t5)")
    lr = p.label("wr")
    p.asm(1, "%s:" % lr, "lw t4, 0x400(t5)", "bnez t4, %s" % lr)
    p.flag_set(1, "go", 2)
    p.end(0); p.end(1)
    p.check("CK-DBG-01", REQS["CK-DBG-01"], "pin", name="o_hart_debug_mode", index=0, rule="rises")
    p.check("CK-DBG-01b", REQS["CK-DBG-01"], "pin", name="o_hart_debug_mode", index=1, rule="never_high")
    p.check("CK-DBG-02", REQS["CK-DBG-02"], "slot", addr=SLOT(p, 0, "resumed"), expect=1)
    p.check("CK-DBG-03", REQS["CK-DBG-03"], "slot", addr=SLOT(p, 1, "peer"), expect=0xDB6DB6DB)
    p.check("CK-DBG-04", REQS["CK-DBG-04"], "sva", id="a_dbg_mode")
    p.check("CK-DBG-05", REQS["CK-DBG-05"], "slot", addr=SLOT(p, 1, "progress"), expect=0)
