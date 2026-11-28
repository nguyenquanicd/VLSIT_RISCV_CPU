"""
AI-GENERATED (Claude Opus 5.5, 2026-11-28) testcase source - candidate (R-117, R-231); engineer review pending (R-284).
Authored from the specification baseline only (RV32 HDS rev 0.4, REF-001 rev 0.39, CSR workbook, question_log answers); no RTL used (R-103, R-232).

| Field | Content |
|---|---|
| Test ID and title | t_rv32d_reset_inflight - Proves coordinated reset recovery: no pre-reset response reaches the released cluster, all generated CSRs return to workbook reset values and both harts reboot |
| Priority and rationale | high; rank 5 of the plan 6.3 risk-ranked list: Stale-response delivery after reset (DEC-041) |
| Purpose | Proves coordinated reset recovery: no pre-reset response reaches the released cluster, all generated CSRs return to workbook reset values and both harts reboot. |
| Requirements and features | REQ-IF-001, REQ-IF-005, REQ-MEM-013, REQ-RST-001, REQ-SYS-003; features: axi_protocol, axil_csr, boot_fanout, no_ack_timeout, reset_recovery; functions: reset_recovery+no_ack_timeout+axil_csr+boot_fanout+axi_protocol |
| DUT configuration and preconditions | CFG-RV32-2-P0; +RESET_AT_CKPT=61 +RESET_HOLD=32; memory BFM HOLD rule keeps the R of line hz for 100000 cycles; word keep preloaded with 0xC0FFEE11; phase word in region 0. Plan configuration column: CFG-RV32-2-P0. Campaign region table bound through tb/generated/region_params.svh (REF-001 rev 0.40 14.4.20, Q-G3-01 answered) |
| Software flow | 1 boot (phase 0): hart 0 sets phase=1 and publishes it with CBO.FLUSH, then loads line hz (R held by the BFM); 2 hart 1 raises checkpoint 0x60 (AXI4-Lite BFM issues CSR reads) and then 0x61; 3 the testbench asserts a coordinated reset (DEC-041): DUT and BFMs reset together, held responses dropped; 4 reboot (phase 1): both harts record mhartid, hart 0 reads keep, hart 1 raises checkpoint 0x62 and the AXI4-Lite BFM reads every mapped CSR; 5 TOHOST |
| Stimulus | Reset asserted with an outstanding held memory R and AXI4-Lite traffic |
| Functional checkpoints and assertions | See the check table below (6 planned checks; R-286 requires >= 5). Every check runs through scripts/evaluate_run.py with the oracle/scoreboard named; deadline = test cycle budget unless stated; failure condition as listed |
| Expected outcome | No stale response; every CSR at its workbook reset value; both harts reboot with mhartid 0/1; keep unchanged; outputs quiet after reset |
| Defect/fault targeted | Pre-reset response delivered after release, CSR/PMU/fault state not at workbook reset values, harts not rebooting, backing memory cleared; failure modes FM-AXI-03, FM-AXL-04, FM-BOT-01, FM-NAT-01, FM-RST-01, FM-RST-02 |
| Checker/oracle | a_rst_outputs, chk_axi_mem_sb, chk_csr_model, chk_mem_oracle, chk_sig, chk_stale_resp; qualification records under docs/01_qualification and docs/02_env |
| Reproducibility | SEED and every plusarg in tests/generated/t_rv32d_reset_inflight/plusargs.txt (generated deterministically by scripts/generators/gen_prog.py); replay: build tb_top, run the simulator with +f-style plusargs from that file in a fresh runs/<run_id>/, then python scripts/evaluate_run.py runs/<run_id> |
| Waveform | wave.vcd of the run (TOP ports and checkpoint window, +WAVE=wave.vcd +WAVE_SCOPE=ports); R-283 rank 5 |
| Evidence | Not run: no simulation in this phase (free disk below the approved 2 GiB threshold) |

Planned checks (from verification_plan.md Section 6.1, R-286):

| Check ID | Requirement / clause | Trigger | Expected observation | Checker / assertion | Deadline | Failure condition |
|---|---|---|---|---|---|---|
| CK-RST-01 | REQ-RST-001 | after reset release | no R/B carrying a pre-reset ID/transaction is delivered (BFM drops) and DUT issues no response-dependent action | chk_stale_resp | post-reset window | stale response accepted |
| CK-RST-02 | REQ-RST-001 | AXI4-Lite read of every mapped CSR | workbook reset value | chk_csr_model | after reboot | mismatch |
| CK-RST-03 | REQ-SYS-003 | reboot | both harts fetch from i_boot_addr[31:0] again and report distinct mhartid | chk_sig | reboot budget | no fetch / same id |
| CK-RST-04 | REQ-RST-001 | after reboot | testbench-preloaded backing memory value is unchanged | chk_mem_oracle | test end | changed |
| CK-RST-05 | REQ-MEM-013 | held response before reset | no fabricated response or timeout error from the DUT while held | chk_axi_mem_sb | hold window | response fabricated |
| CK-RST-06 | REQ-RST-001 | after reset | o_int_fault=0, o_int_pmu=0, o_hart_debug_mode=0 | a_rst_outputs | first post-reset cycle | nonzero |
"""
TEST = 't_rv32d_reset_inflight'
SEED = 1
KIND = 'cpu'
REQS = {
    'CK-RST-01': 'REQ-RST-001',
    'CK-RST-02': 'REQ-RST-001',
    'CK-RST-03': 'REQ-SYS-003',
    'CK-RST-04': 'REQ-RST-001',
    'CK-RST-05': 'REQ-MEM-013',
    'CK-RST-06': 'REQ-RST-001',
}

from rv32d_lib import L, SLOT  # noqa: E402


def build(p):
    p.waveform = True
    p.plusargs.update({"RESET_AT_CKPT": "61", "RESET_HOLD": 32})
    p.line("phase", [0, 0, 0, 0])
    p.line("keep", [0xC0FFEE11, 0, 0, 0])
    p.line("hz", [0x77, 0, 0, 0])
    p.mem_rules.append("HOLD R {hz} {hz+15} 100000")
    for h in (0, 1):
        p.asm(h, "la t0, phase", "lw t1, 0(t0)", "bnez t1, phase1_h%d" % h)
    p.asm(0, "la t0, phase", "li t1, 1", "sw t1, 0(t0)", "cbo.flush (t0)", "fence rw, rw", "la t0, hz", "lw t2, 0(t0)", "hold_park:", "j hold_park")
    p.delay(1, 2000)
    p.axil_block(1, 0x60, [p.axr(a) for a in (0x0, 0x4, 0x8, 0xC, 0x10)])
    p.ckpt(1, 0x61)
    p.asm(1, "reset_park:", "j reset_park")
    for h in (0, 1):
        p.asm(h, "phase1_h%d:" % h, "csrr t1, mhartid")
        p.store_slot(h, "t1", "hartid")
    p.asm(0, "la t0, keep", "lw t2, 0(t0)")
    p.store_slot(0, "t2", "keep")
    regs = [0x0, 0x4, 0x8, 0xC, 0x10] + [0x1000 + 4 * k for k in range(16)] + [0x2000 + 4 * k for k in range(16)] + \
           [0x3000 + 4 * k for k in range(16)] + [0x4000, 0x4004, 0x4008, 0x400C]
    p.axil_block(1, 0x62, [p.axr(a) for a in regs])
    p.end(0); p.end(1)
    p.check("CK-RST-01", REQS["CK-RST-01"], "stale", port="mem", need_reset=True)
    p.check("CK-RST-01b", REQS["CK-RST-01"], "stale", port="mmio", need_reset=True)
    p.check("CK-RST-02", REQS["CK-RST-02"], "axil_reads_eq", which="last", values={str(a): 0 for a in regs})
    p.check("CK-RST-03", REQS["CK-RST-03"], "slot", addr=SLOT(p, 1, "hartid"), expect=1)
    p.check("CK-RST-03b", REQS["CK-RST-03"], "slot", addr=SLOT(p, 0, "hartid"), expect=0)
    p.check("CK-RST-04", REQS["CK-RST-04"], "slot", addr=SLOT(p, 0, "keep"), expect=0xC0FFEE11)
    p.check("CK-RST-05", REQS["CK-RST-05"], "bfm_event", port="mem", event="reset_drop", min=1)
    p.check("CK-RST-06", REQS["CK-RST-06"], "sva", id="a_rst_outputs")
    p.check("CK-RST-07", "REQ-IF-005", "sva", id="a_axi_reset_valid_low")
    p.check("CK-RST-08", "REQ-SYS-003", "tohost", code=1)
