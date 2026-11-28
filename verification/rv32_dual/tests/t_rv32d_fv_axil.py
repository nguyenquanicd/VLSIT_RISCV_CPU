"""
AI-GENERATED (Claude Opus 5.5, 2026-11-28) testcase source - candidate (R-117, R-231); engineer review pending (R-284).
Authored from the specification baseline only (RV32 HDS rev 0.4, REF-001 rev 0.39, CSR workbook, question_log answers); no RTL used (R-103, R-232).

| Field | Content |
|---|---|
| Test ID and title | t_rv32d_fv_axil - Component formal on m_vlsit_riscv_axil_decode and m_vlsit_axil_reg_bridge (HDS 14 |
| Priority and rationale | medium; outside the ten R-283 waveform tests; priority from plan 6.1 |
| Purpose | Component formal on m_vlsit_riscv_axil_decode and m_vlsit_axil_reg_bridge (HDS 14.4.4, 14.4.18): window decode, DECERR, AW/W independence, one RegBus op per write, response stability. |
| Requirements and features | PROTO-AXI4L-B1, REQ-IF-001, REQ-IF-007, REQ-IF-008, REQ-IF-010; features: axil_csr, llc_service; functions: axil_csr (single) |
| DUT configuration and preconditions | SymbiYosys tasks prove and cover of tests/formal/fv_axil.sby; components m_vlsit_riscv_axil_decode and m_vlsit_axil_reg_bridge. Plan configuration column: CFG-RV32-2-P0. Campaign region table bound through tb/generated/region_params.svh (REF-001 rev 0.40 14.4.20, Q-G3-01 answered) |
| Software flow | N/A (formal): AXI4-Lite manager assumptions (stable request while stalled, one outstanding read and write), unconstrained targets and RegBus responder |
| Stimulus | All AXI4-Lite sequences allowed by the assumptions (formal) |
| Functional checkpoints and assertions | See the check table below (5 planned checks; R-286 requires >= 5). Every check runs through scripts/evaluate_run.py with the oracle/scoreboard named; deadline = test cycle budget unless stated; failure condition as listed |
| Expected outcome | All properties proven; covers reached for each window, out-of-aperture read, stall, both AW/W orders and RegBus error |
| Defect/fault targeted | Request routed to two targets or outside a window, out-of-aperture read reaching a target or answered without DECERR/zero data, unstable B/R, duplicate RegBus write, mismatched response; failure modes FM-AXL-01, FM-AXL-03, FM-AXL-04, FM-LLC-03 |
| Checker/oracle | a_axil_decerr, a_axil_decode_onehot, a_axil_stable, a_bridge_one_write, a_bridge_resp_match; qualification records under docs/01_qualification and docs/02_env |
| Reproducibility | SEED and every plusarg in tests/generated/t_rv32d_fv_axil/plusargs.txt (generated deterministically by scripts/generators/gen_prog.py); replay: build tb_top, run the simulator with +f-style plusargs from that file in a fresh runs/<run_id>/, then python scripts/evaluate_run.py runs/<run_id> |
| Waveform | N/A: outside the ten R-283 priority tests (plan 6.3); targeted capture only for diagnosis (R-278) |
| Evidence | Not run: no simulation in this phase (free disk below the approved 2 GiB threshold) |

Planned checks (from verification_plan.md Section 6.1, R-286):

| Check ID | Requirement / clause | Trigger | Expected observation | Checker / assertion | Deadline | Failure condition |
|---|---|---|---|---|---|---|
| CK-FAX-01 | REQ-IF-008 | any aligned address | decoded to exactly one of 5 CSR groups, LLC window or reserved | a_axil_decode_onehot | proof | cex |
| CK-FAX-02 | REQ-IF-007 | reserved offset | DECERR, read data zero | a_axil_decerr | proof | cex |
| CK-FAX-03 | REQ-IF-010 | AW/W any order | exactly one RegBus write after both captured | a_bridge_one_write | proof | cex |
| CK-FAX-04 | REQ-IF-010 | RegBus response | AXI response matches the request | a_bridge_resp_match | proof | cex |
| CK-FAX-05 | REQ-IF-001 | B/R stall | payload stable | a_axil_stable | proof | cex |
"""
TEST = 't_rv32d_fv_axil'
SEED = 1
KIND = 'formal'
REQS = {
    'CK-FAX-01': 'REQ-IF-008',
    'CK-FAX-02': 'REQ-IF-007',
    'CK-FAX-03': 'REQ-IF-010',
    'CK-FAX-04': 'REQ-IF-010',
    'CK-FAX-05': 'REQ-IF-001',
}

STATIC = {
    "runner": "sby -f tests/formal/fv_axil.sby",
    "assumptions": ["AXI4-Lite compliant manager", "one outstanding read and one outstanding write", "aperture base 0"],
    "checks": [
        ("CK-FAX-01", "proven", {"property": ["a_axil_decode_onehot", "a_axil_csr_window_w", "a_axil_csr_window_r", "a_axil_llc_window_w", "a_axil_llc_window_r"]}),
        ("CK-FAX-02", "proven", {"property": ["a_axil_decerr", "a_axil_out_no_target"]}),
        ("CK-FAX-03", "proven", {"property": ["a_bridge_after_aw_w", "a_bridge_one_write", "a_bridge_b_after_pair"]}),
        ("CK-FAX-04", "proven", {"property": ["a_bridge_resp_match", "a_bridge_req_stable"]}),
        ("CK-FAX-05", "proven", {"property": ["a_axil_stable_b", "a_axil_stable_r"]}),
        ("CK-FAX-06", "covered", {"covers": ["c_axil_each_window", "c_axil_reserved", "c_axil_stall", "c_bridge_w_first", "c_bridge_aw_first", "c_bridge_err"]}),
    ],
}
