"""
AI-GENERATED (Claude Opus 5.5, 2026-11-28) testcase source - candidate (R-117, R-231); engineer review pending (R-284).
Authored from the specification baseline only (RV32 HDS rev 0.4, REF-001 rev 0.39, CSR workbook, question_log answers); no RTL used (R-103, R-232).

| Field | Content |
|---|---|
| Test ID and title | t_rv32d_axil_csr_windows - Proves AXI4-Lite subordinate compliance and the approved local address map |
| Priority and rationale | high; outside the ten R-283 waveform tests; priority from plan 6.1 |
| Purpose | Proves AXI4-Lite subordinate compliance and the approved local address map. |
| Requirements and features | PROTO-AXI4L-B1, REQ-ERR-002, REQ-IF-001, REQ-IF-005, REQ-IF-007, REQ-IF-008, REQ-IF-010; features: axi_protocol, axil_csr, llc_service; functions: axil_csr+llc_service+axi_protocol |
| DUT configuration and preconditions | CFG-RV32-2-P0; +AXIL_RDY=40 (random B/R READY); harts idle except for the checkpoint and wait. Plan configuration column: CFG-RV32-2-P0. Campaign region table bound through tb/generated/region_params.svh (REF-001 rev 0.40 14.4.20, Q-G3-01 answered) |
| Software flow | 1 boot; 2 hart 0 checkpoint 0x120; the AXI4-Lite BFM runs: full and partial-strobe writes/reads of irq_en with AW-before-W, W-before-AW and simultaneous timing; zero-strobe write; misaligned write/read; reserved offsets 0x0014, 0x1040, 0x2040, 0x3040, 0x4010, 0x4FFC (read and write); RO write to cpucl_fault_sts; write/read pmu_evt[15]; 3 hart 0 waits for completion; 4 TOHOST |
| Stimulus | AXI4-Lite access matrix over the local CSR windows with B/R backpressure (IHI 0022H B1; REQ-IF-007/008; REF-001 11.4) |
| Functional checkpoints and assertions | See the check table below (7 planned checks; R-286 requires >= 5). Every check runs through scripts/evaluate_run.py with the oracle/scoreboard named; deadline = test cycle budget unless stated; failure condition as listed |
| Expected outcome | CSR model (workbook) matches every response and read value; one response per request; stable B/R |
| Defect/fault targeted | Wrong response code, side effects on error or zero strobe, lost/duplicate B or R, unstable response under stall; failure modes FM-AXI-01, FM-AXL-01, FM-AXL-02, FM-AXL-03, FM-AXL-04, FM-LLC-03 |
| Checker/oracle | a_axil_stable, chk_axil_sb, chk_csr_model; qualification records under docs/01_qualification and docs/02_env |
| Reproducibility | SEED and every plusarg in tests/generated/t_rv32d_axil_csr_windows/plusargs.txt (generated deterministically by scripts/generators/gen_prog.py); replay: build tb_top, run the simulator with +f-style plusargs from that file in a fresh runs/<run_id>/, then python scripts/evaluate_run.py runs/<run_id> |
| Waveform | N/A: outside the ten R-283 priority tests (plan 6.3); targeted capture only for diagnosis (R-278) |
| Evidence | Not run: no simulation in this phase (free disk below the approved 2 GiB threshold) |
| Blocked obligations | OB-108 (REQ-IF-010): Q-G0-04 answered A: waiting for the native LLC service register table to be added to REF-001 Section 11 |

Planned checks (from verification_plan.md Section 6.1, R-286):

| Check ID | Requirement / clause | Trigger | Expected observation | Checker / assertion | Deadline | Failure condition |
|---|---|---|---|---|---|---|
| CK-AXL-01 | REQ-IF-008 | reserved aligned offsets | read zero + DECERR; write no side effect + DECERR | chk_csr_model | per access | mismatch |
| CK-AXL-02 | REQ-IF-007 | misaligned access | SLVERR, no field change | chk_csr_model | per access | mismatch |
| CK-AXL-03 | REQ-IF-007 | partial/zero WSTRB | only strobed bytes change; zero strobe no change | chk_csr_model | per access | mismatch |
| CK-AXL-04 | PROTO-AXI4L-B1 | AW before W, W before AW, same cycle | exactly one B per write | chk_axil_sb | per access | lost/duplicate B |
| CK-AXL-05 | REQ-IF-005 | B/R backpressure | BRESP/RDATA stable while not ready | a_axil_stable | per cycle | violation |
| CK-AXL-06 | REQ-ERR-002 | write to RO field / reserved offset | no state change visible on read-back | chk_csr_model | per access | changed |
| CK-AXL-07 | REQ-IF-010 | LLC window access | one RegBus operation per write with matching response (blocked: Q-G0-04) | chk_axil_sb | per access | lost/duplicate |
"""
TEST = 't_rv32d_axil_csr_windows'
SEED = 1
KIND = 'cpu'
REQS = {
    'CK-AXL-01': 'REQ-IF-008',
    'CK-AXL-02': 'REQ-IF-007',
    'CK-AXL-03': 'REQ-IF-007',
    'CK-AXL-04': 'PROTO-AXI4L-B1',
    'CK-AXL-05': 'REQ-IF-005',
    'CK-AXL-06': 'REQ-ERR-002',
    'CK-AXL-07': 'REQ-IF-010',
}

from rv32d_lib import L, SLOT  # noqa: E402


def build(p):
    p.plusargs.update({"AXIL_RDY": 40})
    ops = [p.axw(0x4, 0xDEADBEEF, 0xF, 0), p.axr(0x4), p.axw(0x4, 0x000000AA, 0x1, 2), p.axr(0x4), p.axw(0x4, 0x0000BB00, 0x2, -2), p.axr(0x4),
           p.axw(0x4, 0xFFFFFFFF, 0x0, 1), p.axr(0x4), p.axw(0x6, 0x1, 0xF, 0), p.axr(0x6), p.axr(0x4)]
    for a in (0x14, 0x1040, 0x2040, 0x3040, 0x4010, 0x4FFC):
        ops += [p.axw(a, 0xFFFFFFFF, 0xF, 0), p.axr(a)]
    ops += [p.axw(0x4000, 0xFFFFFFFF), p.axr(0x4000), p.axw(0x103C, 0x000D0303), p.axr(0x103C), p.axr(0x303C)]
    p.axil_block(0, 0x120, ops)
    p.end(0); p.end(1)
    p.check("CK-AXL-01", REQS["CK-AXL-01"], "axil", csr_model=True)
    p.check("CK-AXL-02", REQS["CK-AXL-02"], "axil_resp", addr=0x6, resp="SLVERR", count=2)
    p.check("CK-AXL-03", REQS["CK-AXL-03"], "axil_reads_eq", which="last", values={"4": 0xDEADBBAA})
    p.check("CK-AXL-04", REQS["CK-AXL-04"], "axil", csr_model=False)
    p.check("CK-AXL-05", REQS["CK-AXL-05"], "sva", id="a_axil_stable")
    p.check("CK-AXL-06", REQS["CK-AXL-06"], "axil_reads_eq", which="last", values={"16384": 0, "20": 0})
    p.block("CK-AXL-07", REQS["CK-AXL-07"], "LLC service window field semantics: Q-G0-04 (register table not yet in REF-001 Section 11)")
