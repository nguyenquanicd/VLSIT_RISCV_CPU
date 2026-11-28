"""
AI-GENERATED (Claude Opus 5.5, 2026-11-28) testcase source - candidate (R-117, R-231); engineer review pending (R-284).
Authored from the specification baseline only (RV32 HDS rev 0.4, REF-001 rev 0.39, CSR workbook, question_log answers); no RTL used (R-103, R-232).

| Field | Content |
|---|---|
| Test ID and title | t_rv32d_elab_lint_matrix - Elaborate and lint profiles 0/1/2 for 2 and 4 harts with the RV32 filelist (REQ-XL-014, TEST-114) |
| Priority and rationale | high; outside the ten R-283 waveform tests; priority from plan 6.1 |
| Purpose | Elaborate and lint profiles 0/1/2 for 2 and 4 harts with the RV32 filelist (REQ-XL-014, TEST-114). |
| Requirements and features | REQ-XL-014; features: elab_config; functions: elab_config (single) |
| DUT configuration and preconditions | CFG-RV32-2-P0/P1/P2 and CFG-RV32-4-P0/P1/P2; Verilator 5.053 --lint-only on the RV32 RTL filelist (execution phase). Plan configuration column: CFG-RV32-2-P0;CFG-RV32-2-P1;CFG-RV32-2-P2;CFG-RV32-4-P0;CFG-RV32-4-P1;CFG-RV32-4-P2. Campaign region table bound through tb/generated/region_params.svh (REF-001 rev 0.40 14.4.20, Q-G3-01 answered) |
| Software flow | N/A (static lint): for each of the six configurations run verilator --lint-only -Wall with the approved waiver file and record the log |
| Stimulus | Six elaborations (REQ-XL-014, TEST-114) |
| Functional checkpoints and assertions | See the check table below (5 planned checks; R-286 requires >= 5). Every check runs through scripts/evaluate_run.py with the oracle/scoreboard named; deadline = test cycle budget unless stated; failure condition as listed |
| Expected outcome | Six clean lint runs; every waiver reviewed with an owner |
| Defect/fault targeted | A timing profile or hart count that does not elaborate or lints with unwaived warnings; failure modes FM-PRF-02 |
| Checker/oracle | chk_lint; qualification records under docs/01_qualification and docs/02_env |
| Reproducibility | SEED and every plusarg in tests/generated/t_rv32d_elab_lint_matrix/plusargs.txt (generated deterministically by scripts/generators/gen_prog.py); replay: build tb_top, run the simulator with +f-style plusargs from that file in a fresh runs/<run_id>/, then python scripts/evaluate_run.py runs/<run_id> |
| Waveform | N/A: outside the ten R-283 priority tests (plan 6.3); targeted capture only for diagnosis (R-278) |
| Evidence | Not run: no simulation in this phase (free disk below the approved 2 GiB threshold) |

Planned checks (from verification_plan.md Section 6.1, R-286):

| Check ID | Requirement / clause | Trigger | Expected observation | Checker / assertion | Deadline | Failure condition |
|---|---|---|---|---|---|---|
| CK-LNT-01 | REQ-XL-014 | P0 2 harts | elaboration + lint clean (approved waivers only) | chk_lint | build | error |
| CK-LNT-02 | REQ-XL-014 | P1 2 harts | clean | chk_lint | build | error |
| CK-LNT-03 | REQ-XL-014 | P2 2 harts | clean | chk_lint | build | error |
| CK-LNT-04 | REQ-XL-014 | P0/P1/P2 4 harts | clean | chk_lint | build | error |
| CK-LNT-05 | REQ-XL-014 | waiver file | every waiver reviewed with owner | chk_lint | build | unreviewed |
"""
TEST = 't_rv32d_elab_lint_matrix'
SEED = 1
KIND = 'static'
REQS = {
    'CK-LNT-01': 'REQ-XL-014',
    'CK-LNT-02': 'REQ-XL-014',
    'CK-LNT-03': 'REQ-XL-014',
    'CK-LNT-04': 'REQ-XL-014',
    'CK-LNT-05': 'REQ-XL-014',
}

STATIC = {
    "runner": "scripts/static/lint_matrix.py",
    "needs": ["RV32 RTL filelist path recorded at G1 build manifest", "approved waiver file"],
    "checks": [
        ("CK-LNT-01", "lint_clean", {"config": "CFG-RV32-2-P0"}),
        ("CK-LNT-02", "lint_clean", {"config": "CFG-RV32-2-P1"}),
        ("CK-LNT-03", "lint_clean", {"config": "CFG-RV32-2-P2"}),
        ("CK-LNT-04", "lint_clean", {"config": ["CFG-RV32-4-P0", "CFG-RV32-4-P1", "CFG-RV32-4-P2"]}),
        ("CK-LNT-05", "waivers_reviewed", {"file": "approved waiver file of the RTL owner"}),
    ],
}
