"""
AI-GENERATED (Claude Opus 5.5, 2026-11-28) testcase source - candidate (R-117, R-231); engineer review pending (R-284).
Authored from the specification baseline only (RV32 HDS rev 0.4, REF-001 rev 0.39, CSR workbook, question_log answers); no RTL used (R-103, R-232).

| Field | Content |
|---|---|
| Test ID and title | t_rv32d_fatal_llc_eviction - Proves the reset-only first-fatal record and sticky o_int_fault for a non-maintenance LLC writeback error |
| Priority and rationale | high; rank 6 of the plan 6.3 risk-ranked list: Reset-only fatal record and sticky IRQ |
| Purpose | Proves the reset-only first-fatal record and sticky o_int_fault for a non-maintenance LLC writeback error. |
| Requirements and features | PROTO-AXI4-A6, REQ-ERR-003, REQ-IF-008, REQ-RST-001; features: axi_protocol, axil_csr, fatal_fault_record, reset_recovery; functions: fatal_fault_record+axil_csr+reset_recovery+axi_protocol |
| DUT configuration and preconditions | CFG-RV32-2-P0; default LLC 256 KiB (Q-G0-15); memory BFM rules: SLVERR on the 1st and DECERR on the 5th external write in the sweep range; +RESET_AT_CKPT=72. Plan configuration column: CFG-RV32-2-P0. Campaign region table bound through tb/generated/region_params.svh (REF-001 rev 0.40 14.4.20, Q-G3-01 answered) |
| Software flow | 1 boot; 2 hart 0 stores one word per 16-byte line over 300 KiB (0x80100000-0x8014AFFF) so that dirty LLC lines are evicted (non-maintenance writebacks); 3 checkpoint 0x70: AXI4-Lite reads cpucl_fault_sts/info/lo/hi, W1C cpucl_coh.fault, reads again; 4 checkpoint 0x72 triggers a coordinated reset; 5 after reboot (phase word) checkpoint 0x73: AXI4-Lite reads the fault record again; 6 TOHOST |
| Stimulus | External B errors (SLVERR then DECERR) on LLC dirty-eviction writebacks |
| Functional checkpoints and assertions | See the check table below (6 planned checks; R-286 requires >= 5). Every check runs through scripts/evaluate_run.py with the oracle/scoreboard named; deadline = test cycle budget unless stated; failure condition as listed |
| Expected outcome | o_int_fault rises and stays high until reset; record = first error (source LLC, hart_valid 0, SLVERR, victim line base) with multiple=1; W1C changes nothing; reset clears the record; no retry write |
| Defect/fault targeted | First fatal record overwritten, wrong source/hart attribution, o_int_fault clearable by W1C or not cleared by reset, automatic retry of the failed writeback; failure modes FM-AXI-02, FM-AXL-01, FM-FAT-01, FM-FAT-02, FM-FAT-03, FM-FAT-04 |
| Checker/oracle | a_fault_sticky, chk_axi_mem_sb, chk_fault_oracle; qualification records under docs/01_qualification and docs/02_env |
| Reproducibility | SEED and every plusarg in tests/generated/t_rv32d_fatal_llc_eviction/plusargs.txt (generated deterministically by scripts/generators/gen_prog.py); replay: build tb_top, run the simulator with +f-style plusargs from that file in a fresh runs/<run_id>/, then python scripts/evaluate_run.py runs/<run_id> |
| Waveform | wave.vcd of the run (TOP ports and checkpoint window, +WAVE=wave.vcd +WAVE_SCOPE=ports); R-283 rank 6 |
| Evidence | Not run: no simulation in this phase (free disk below the approved 2 GiB threshold) |

Planned checks (from verification_plan.md Section 6.1, R-286):

| Check ID | Requirement / clause | Trigger | Expected observation | Checker / assertion | Deadline | Failure condition |
|---|---|---|---|---|---|---|
| CK-FAT-01 | REQ-ERR-003 | first error B | o_int_fault rises and stays high | a_fault_sticky | 1000 cycles | low |
| CK-FAT-02 | REQ-ERR-003 | AXI4-Lite read cpucl_fault_* | valid=1, source=2 (LLC), hart_valid=0, raw BRESP=SLVERR; cpucl_fault_lo = PA[31:0] of the first failed victim line base (bits 3:0 = 0), cpucl_fault_hi[1:0] = PA[33:32] (Q-G0-12) | chk_fault_oracle | after error | field mismatch |
| CK-FAT-03 | REQ-ERR-003 | second error | multiple=1, first payload unchanged | chk_fault_oracle | after error | payload overwritten |
| CK-FAT-04 | REQ-ERR-003 | W1C cpucl_coh.fault | o_int_fault stays high; record unchanged | chk_fault_oracle | after write | cleared |
| CK-FAT-05 | REQ-RST-001 | reset | record and o_int_fault cleared | chk_fault_oracle | after reset | not cleared |
| CK-FAT-06 | REQ-ERR-003 | after error | no retry AW for the failed victim (no automatic retry) | chk_axi_mem_sb | test end | retry observed |
"""
TEST = 't_rv32d_fatal_llc_eviction'
SEED = 1
KIND = 'cpu'
REQS = {
    'CK-FAT-01': 'REQ-ERR-003',
    'CK-FAT-02': 'REQ-ERR-003',
    'CK-FAT-03': 'REQ-ERR-003',
    'CK-FAT-04': 'REQ-ERR-003',
    'CK-FAT-05': 'REQ-RST-001',
    'CK-FAT-06': 'REQ-ERR-003',
}

from rv32d_lib import L, SLOT  # noqa: E402


def build(p):
    p.waveform = True
    p.plusargs.update({"TIMEOUT_CYCLES": 30000000, "RESET_AT_CKPT": "72", "RESET_HOLD": 32})
    p.line("phase", [0, 0, 0, 0])
    p.mem_rules.append("ERR B 80100000 8014afff 1 1 2")
    p.mem_rules.append("ERR B 80100000 8014afff 5 1 3")
    for h in (0, 1):
        p.asm(h, "la t0, phase", "lw t1, 0(t0)", "bnez t1, phase1_h%d" % h)
    p.asm(0, "la t0, phase", "li t1, 1", "sw t1, 0(t0)", "cbo.flush (t0)", "fence rw, rw")
    p.asm(0, "li t0, 0x80100000", "li t1, 0x8014b000", "sweep:", "sw t0, 0(t0)", "addi t0, t0, 16", "bltu t0, t1, sweep")
    fault_regs = [0x4000, 0x4004, 0x4008, 0x400C]
    p.axil_block(0, 0x70, [p.axr(a) for a in fault_regs] + [p.axw(0x10, 0x1)] + [p.axr(a) for a in fault_regs])
    p.ckpt(0, 0x72)
    p.asm(0, "park72:", "j park72")
    p.asm(1, "park_h1:", "j park_h1")
    p.asm(0, "phase1_h0:")
    p.axil_block(0, 0x73, [p.axr(a) for a in fault_regs])
    p.end(0)
    p.asm(1, "phase1_h1:")
    p.end(1)
    p.check("CK-FAT-01", REQS["CK-FAT-01"], "pin", name="o_int_fault", rule="rises")
    p.check("CK-FAT-01b", REQS["CK-FAT-01"], "sva", id="a_fault_sticky")
    p.check("CK-FAT-02", REQS["CK-FAT-02"], "fault", which="first", min_events=2)
    p.check("CK-FAT-03", REQS["CK-FAT-03"], "fault", which="second_block", min_events=2)
    p.check("CK-FAT-04", REQS["CK-FAT-04"], "axil_reads_stable", addrs=fault_regs, between=[0x70, 0x72])
    p.check("CK-FAT-05", REQS["CK-FAT-05"], "axil_reads_eq", which="last", values={str(a): 0 for a in fault_regs})
    p.check("CK-FAT-05b", REQS["CK-FAT-05"], "pin", name="o_int_fault", rule="final", value=0)
    p.check("CK-FAT-06", REQS["CK-FAT-06"], "no_retry_after_err", port="mem")
