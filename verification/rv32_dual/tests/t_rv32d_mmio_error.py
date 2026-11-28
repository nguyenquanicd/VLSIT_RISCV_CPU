"""
AI-GENERATED (Claude Opus 5.5, 2026-11-28) testcase source - candidate (R-117, R-231); engineer review pending (R-284).
Authored from the specification baseline only (RV32 HDS rev 0.4, REF-001 rev 0.39, CSR workbook, question_log answers); no RTL used (R-103, R-232).

| Field | Content |
|---|---|
| Test ID and title | t_rv32d_mmio_error - Proves AXI error responses reach the originating hart without ID change, with the Q-G0-06 architectural results |
| Priority and rationale | high; outside the ten R-283 waveform tests; priority from plan 6.1 |
| Purpose | Proves AXI error responses reach the originating hart without ID change, with the Q-G0-06 architectural results. |
| Requirements and features | PROTO-AXI4-A6, REQ-ERR-001; features: axi_protocol, mmio_access; functions: mmio_access+region_table+axi_protocol |
| DUT configuration and preconditions | CFG-RV32-2-P0; MMIO BFM rules: SLVERR on the R of 0x10000900, DECERR on the B of 0x10000910; trap action = skip. Plan configuration column: CFG-RV32-2-P0. Campaign region table bound through tb/generated/region_params.svh (REF-001 rev 0.40 14.4.20, Q-G3-01 answered) |
| Software flow | 1 boot; 2 hart 0: load from 0x10000900 (R error) with a sentinel in the destination register, store the register; store to 0x10000910 (B error); then a normal MMIO store/load at 0x10000920; 3 trap handler records cause/epc/tval and skips; 4 TOHOST |
| Stimulus | SLVERR on an MMIO read response, DECERR on an MMIO write response (Q-G0-06) |
| Functional checkpoints and assertions | See the check table below (5 planned checks; R-286 requires >= 5). Every check runs through scripts/evaluate_run.py with the oracle/scoreboard named; deadline = test cycle budget unless stated; failure condition as listed |
| Expected outcome | Load access fault cause 5 with mtval = 0x10000900; store/AMO access fault cause 7; destination register keeps the sentinel; next MMIO access succeeds |
| Defect/fault targeted | Error lost, bus data written to the register, error mapped to a wrong cause, response ID misassociated, MMIO path stuck after an error; failure modes FM-AXI-02, FM-MIO-03 |
| Checker/oracle | chk_axi_mmio_sb, chk_sig, chk_trap_oracle; qualification records under docs/01_qualification and docs/02_env |
| Reproducibility | SEED and every plusarg in tests/generated/t_rv32d_mmio_error/plusargs.txt (generated deterministically by scripts/generators/gen_prog.py); replay: build tb_top, run the simulator with +f-style plusargs from that file in a fresh runs/<run_id>/, then python scripts/evaluate_run.py runs/<run_id> |
| Waveform | N/A: outside the ten R-283 priority tests (plan 6.3); targeted capture only for diagnosis (R-278) |
| Evidence | Not run: no simulation in this phase (free disk below the approved 2 GiB threshold) |

Planned checks (from verification_plan.md Section 6.1, R-286):

| Check ID | Requirement / clause | Trigger | Expected observation | Checker / assertion | Deadline | Failure condition |
|---|---|---|---|---|---|---|
| CK-MER-01 | REQ-ERR-001 | R error | precise load access fault: mcause=5, mtval = load address (Q-G0-06) | chk_trap_oracle | trap | mismatch |
| CK-MER-02 | REQ-ERR-001 | B error | store/AMO access fault: mcause=7 (Q-G0-06) | chk_trap_oracle | trap | mismatch |
| CK-MER-03 | REQ-ERR-001 | R error | destination register not written with bus data | chk_sig | test end | written |
| CK-MER-04 | PROTO-AXI4-A6 | error response | ID echoed and matched to the request | chk_axi_mmio_sb | op | mismatch |
| CK-MER-05 | REQ-ERR-001 | after error | next MMIO access succeeds | chk_axi_mmio_sb | test end | failure |
"""
TEST = 't_rv32d_mmio_error'
SEED = 1
KIND = 'cpu'
REQS = {
    'CK-MER-01': 'REQ-ERR-001',
    'CK-MER-02': 'REQ-ERR-001',
    'CK-MER-03': 'REQ-ERR-001',
    'CK-MER-04': 'PROTO-AXI4-A6',
    'CK-MER-05': 'REQ-ERR-001',
}

from rv32d_lib import L, SLOT  # noqa: E402


def build(p):
    p.mmio_rules.append("ERR R 10000900 10000907 1 1 2")
    p.mmio_rules.append("ERR B 10000910 10000917 1 1 3")
    p.asm(0, "li t0, 0x10000900", "li t1, 0x5E5E5E5E", "ld_err_site:", "lw t1, 0(t0)")
    p.store_slot(0, "t1", "sentinel")
    p.asm(0, "li t0, 0x10000910", "li t2, 0x99", "st_err_site:", "sw t2, 0(t0)", "fence rw, rw")
    p.asm(0, "li t0, 0x10000920", "li t2, 0x4242", "sw t2, 0(t0)", "lw t3, 0(t0)")
    p.store_slot(0, "t3", "after")
    p.end(0); p.end(1)
    p.check("CK-MER-01", REQS["CK-MER-01"], "traps", hart=0, subset=True, expected=[{"kind": "exception", "code": 5, "epc": L("ld_err_site"), "tval": 0x10000900}])
    p.check("CK-MER-02", REQS["CK-MER-02"], "trap_cause", hart=0, cause=7, present=True)
    p.check("CK-MER-03", REQS["CK-MER-03"], "slot", addr=SLOT(p, 0, "sentinel"), expect=0x5E5E5E5E)
    p.check("CK-MER-04", REQS["CK-MER-04"], "axi_mmio", rules=[{"kind": "structural", "window": [None, None]}])
    p.check("CK-MER-05", REQS["CK-MER-05"], "slot", addr=SLOT(p, 0, "after"), expect=0x4242)
