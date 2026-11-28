"""
AI-GENERATED (Claude Opus 5.5, 2026-11-28) testcase source - candidate (R-117, R-231); engineer review pending (R-284).
Authored from the specification baseline only (RV32 HDS rev 0.4, REF-001 rev 0.39, CSR workbook, question_log answers); no RTL used (R-103, R-232).

| Field | Content |
|---|---|
| Test ID and title | t_rv32d_process_audit - Audit that expected behaviour derives from the specification (authoring_inputs |
| Priority and rationale | medium; outside the ten R-283 waveform tests; priority from plan 6.1 |
| Purpose | Audit that expected behaviour derives from the specification (authoring_inputs.md) and that each configuration has a reproducible target with saved command/log manifest. |
| Requirements and features | REQ-VER-001, REQ-VER-002; features: verif_process; functions: verif_process (single) |
| DUT configuration and preconditions | Review of verification/rv32_dual: authoring_inputs.md, generation manifests, ai/provenance.json, replay manifests. Plan configuration column: CFG-RV32-2-P0. Campaign region table bound through tb/generated/region_params.svh (REF-001 rev 0.40 14.4.20, Q-G3-01 answered) |
| Software flow | N/A (process review): 1 confirm the authoring input records list no RTL or RTL-derived input; 2 confirm every oracle cites specification sections; 3 cold replay of a recorded run; 4 confirm a build target and manifest per configuration; 5 confirm tool versions and seeds in every manifest |
| Stimulus | Document and manifest review; cold replay with scripts/vlsit_sim_workspace.py |
| Functional checkpoints and assertions | See the check table below (5 planned checks; R-286 requires >= 5). Every check runs through scripts/evaluate_run.py with the oracle/scoreboard named; deadline = test cycle budget unless stated; failure condition as listed |
| Expected outcome | All five review items pass and are signed by the reviewer |
| Defect/fault targeted | Expected values derived from RTL, unreproducible run, missing configuration target; failure modes FM-PRC-01, FM-PRC-02 |
| Checker/oracle | chk_authoring_audit, chk_replay; qualification records under docs/01_qualification and docs/02_env |
| Reproducibility | SEED and every plusarg in tests/generated/t_rv32d_process_audit/plusargs.txt (generated deterministically by scripts/generators/gen_prog.py); replay: build tb_top, run the simulator with +f-style plusargs from that file in a fresh runs/<run_id>/, then python scripts/evaluate_run.py runs/<run_id> |
| Waveform | N/A: outside the ten R-283 priority tests (plan 6.3); targeted capture only for diagnosis (R-278) |
| Evidence | Not run: no simulation in this phase (free disk below the approved 2 GiB threshold) |

Planned checks (from verification_plan.md Section 6.1, R-286):

| Check ID | Requirement / clause | Trigger | Expected observation | Checker / assertion | Deadline | Failure condition |
|---|---|---|---|---|---|---|
| CK-PRC-01 | REQ-VER-001 | plan/testcase review | authoring inputs list no RTL-derived source | chk_authoring_audit | G0/G3 | RTL input found |
| CK-PRC-02 | REQ-VER-001 | oracle review | each oracle cites spec sections | chk_authoring_audit | G3 | uncited value |
| CK-PRC-03 | REQ-VER-002 | cold replay | replay of a recorded run reproduces result | chk_replay | per release | different |
| CK-PRC-04 | REQ-VER-002 | per configuration | independent build target + manifest exists for P0/P1/P2 | chk_replay | per release | missing |
| CK-PRC-05 | REQ-VER-002 | manifest | tool versions and seeds recorded | chk_replay | per release | missing |
"""
TEST = 't_rv32d_process_audit'
SEED = 1
KIND = 'static'
REQS = {
    'CK-PRC-01': 'REQ-VER-001',
    'CK-PRC-02': 'REQ-VER-001',
    'CK-PRC-03': 'REQ-VER-002',
    'CK-PRC-04': 'REQ-VER-002',
    'CK-PRC-05': 'REQ-VER-002',
}

STATIC = {
    "runner": "manual review + python scripts/vlsit_sim_workspace.py replay",
    "checks": [
        ("CK-PRC-01", "review", {"item": "authoring inputs list no RTL-derived source (docs/00_plan/authoring_inputs.md, ai/provenance.json)"}),
        ("CK-PRC-02", "review", {"item": "each oracle header cites specification sections (models/*.py)"}),
        ("CK-PRC-03", "replay", {"item": "cold replay reproduces a recorded run"}),
        ("CK-PRC-04", "review", {"item": "independent build target and manifest for P0/P1/P2"}),
        ("CK-PRC-05", "review", {"item": "tool versions and seeds recorded in every manifest"}),
    ],
}
