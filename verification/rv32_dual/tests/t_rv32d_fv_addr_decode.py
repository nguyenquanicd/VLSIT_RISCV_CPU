"""
AI-GENERATED (Claude Opus 5.5, 2026-11-28) testcase source - candidate (R-117, R-231); engineer review pending (R-284).
Authored from the specification baseline only (RV32 HDS rev 0.4, REF-001 rev 0.39, CSR workbook, question_log answers); no RTL used (R-103, R-232).

| Field | Content |
|---|---|
| Test ID and title | t_rv32d_fv_addr_decode - Component formal on m_vlsit_riscv_addr_decode (HDS 14 |
| Priority and rationale | medium; outside the ten R-283 waveform tests; priority from plan 6.1 |
| Purpose | Component formal on m_vlsit_riscv_addr_decode (HDS 14.4.13) with the five-region campaign table: full-window match, boundary-crossing error, MMIO atomic error, top line below 2^34. |
| Requirements and features | REQ-IF-011, REQ-XL-011; features: region_table; functions: region_table (single) |
| DUT configuration and preconditions | SymbiYosys prove of tests/formal/fv_addr_decode.sby; component m_vlsit_riscv_addr_decode with the five-region campaign table of REF-001 rev 0.40 14.4.20 (Q-G3-01 answered). Plan configuration column: CFG-RV32-2-P0. Campaign region table bound through tb/generated/region_params.svh (REF-001 rev 0.40 14.4.20, Q-G3-01 answered) |
| Software flow | N/A (formal): unconstrained physical address, access size 1-64 bytes and atomic flag against the campaign table constants |
| Stimulus | All accesses (formal) |
| Functional checkpoints and assertions | See the check table below (5 planned checks; R-286 requires >= 5). Every check runs through scripts/evaluate_run.py with the oracle/scoreboard named; deadline = test cycle budget unless stated; failure condition as listed |
| Expected outcome | All properties proven once the table can be bound |
| Defect/fault targeted | Start-byte-only match, missing boundary-crossing or MMIO-atomic error, unmapped access accepted, wrong class, region 4 top line rejected; failure modes FM-REG-01, FM-REG-02, FM-REG-03 |
| Checker/oracle | a_dec_class, a_dec_cross_err, a_dec_mmio_atomic, a_dec_top_line, a_dec_unmapped; qualification records under docs/01_qualification and docs/02_env |
| Reproducibility | SEED and every plusarg in tests/generated/t_rv32d_fv_addr_decode/plusargs.txt (generated deterministically by scripts/generators/gen_prog.py); replay: build tb_top, run the simulator with +f-style plusargs from that file in a fresh runs/<run_id>/, then python scripts/evaluate_run.py runs/<run_id> |
| Waveform | N/A: outside the ten R-283 priority tests (plan 6.3); targeted capture only for diagnosis (R-278) |
| Evidence | Not run: no simulation in this phase (free disk below the approved 2 GiB threshold) |

Planned checks (from verification_plan.md Section 6.1, R-286):

| Check ID | Requirement / clause | Trigger | Expected observation | Checker / assertion | Deadline | Failure condition |
|---|---|---|---|---|---|---|
| CK-FAD-01 | REQ-IF-011 | access crossing a region end | o_access_err=1 | a_dec_cross_err | proof | cex |
| CK-FAD-02 | REQ-IF-011 | MMIO atomic | o_access_err=1 | a_dec_mmio_atomic | proof | cex |
| CK-FAD-03 | REQ-IF-011 | unmapped address | o_region_match=0, o_access_err=1 | a_dec_unmapped | proof | cex |
| CK-FAD-04 | REQ-IF-011 | mapped address | type equals table class | a_dec_class | proof | cex |
| CK-FAD-05 | REQ-XL-011 | addresses in region 4 up to 2^34-1 | matched as normal-uncached with no error for every full-window access ending at or below 2^34 | a_dec_top_line | proof | cex |
"""
TEST = 't_rv32d_fv_addr_decode'
SEED = 1
KIND = 'formal'
REQS = {
    'CK-FAD-01': 'REQ-IF-011',
    'CK-FAD-02': 'REQ-IF-011',
    'CK-FAD-03': 'REQ-IF-011',
    'CK-FAD-04': 'REQ-IF-011',
    'CK-FAD-05': 'REQ-XL-011',
}

STATIC = {
    "runner": "sby -f tests/formal/fv_addr_decode.sby",
    "assumption": "decoder takes the REF-001 rev 0.40 14.4.20 region parameters under the same names (14.4.13 lists ports only)",
    "checks": [
        ("CK-FAD-01", "proven", {"property": "a_dec_cross_err"}),
        ("CK-FAD-02", "proven", {"property": "a_dec_mmio_atomic"}),
        ("CK-FAD-03", "proven", {"property": "a_dec_unmapped"}),
        ("CK-FAD-04", "proven", {"property": "a_dec_class"}),
        ("CK-FAD-05", "proven", {"property": "a_dec_top_line"}),
        ("CK-FAD-06", "proven", {"property": "a_dec_config_valid"}),
    ],
}
