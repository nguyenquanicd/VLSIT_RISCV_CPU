"""
AI-GENERATED (Claude Opus 5.5, 2026-11-28) testcase source - candidate (R-117, R-231); engineer review pending (R-284).
Authored from the specification baseline only (RV32 HDS rev 0.4, REF-001 rev 0.39, CSR workbook, question_log answers); no RTL used (R-103, R-232).

| Field | Content |
|---|---|
| Test ID and title | t_rv32d_fv_pmu - Component formal on m_vlsit_pmu_counter_bank, m_vlsit_pmu_irq and m_vlsit_pmu_snapshot (HDS 14 |
| Priority and rationale | medium; outside the ten R-283 waveform tests; priority from plan 6.1 |
| Purpose | Component formal on m_vlsit_pmu_counter_bank, m_vlsit_pmu_irq and m_vlsit_pmu_snapshot (HDS 14.4 port contracts): modulo wrap, overflow event, sticky cause, aggregate level, atomic snapshot (Q-G0-10 A). |
| Requirements and features | REQ-PMU-002, REQ-PMU-003, REQ-PMU-004; features: pmu_overflow, pmu_snapshot; functions: pmu_overflow (single) |
| DUT configuration and preconditions | SymbiYosys tasks prove_w64, prove_w32, cover_w64 of tests/formal/fv_pmu.sby; components m_vlsit_pmu_counter_bank, m_vlsit_pmu_irq, m_vlsit_pmu_snapshot with N=2 counters. Plan configuration column: CFG-RV32-2-P0. Campaign region table bound through tb/generated/region_params.svh (REF-001 rev 0.40 14.4.20, Q-G3-01 answered) |
| Software flow | N/A (formal, no software): unconstrained component inputs under the property modules of env/assertions/fv_pmu_props.sv; k-induction proof of every assertion, cover run for non-vacuity |
| Stimulus | All input sequences allowed by the port contracts (formal) |
| Functional checkpoints and assertions | See the check table below (5 planned checks; R-286 requires >= 5). Every check runs through scripts/evaluate_run.py with the oracle/scoreboard named; deadline = test cycle budget unless stated; failure condition as listed |
| Expected outcome | All a_pmu_* properties proven (unbounded); every c_pmu_* cover reached |
| Defect/fault targeted | Counter saturating or wrapping at the wrong width, overflow not on carry, pending/level wrong, hardware set lost against software clear, torn snapshot; failure modes FM-PMO-01, FM-PMO-02, FM-PMO-03, FM-PMS-01 |
| Checker/oracle | a_pmu_hw_wins, a_pmu_irq_level, a_pmu_ovf_on_carry, a_pmu_snap_atomic, a_pmu_wrap; qualification records under docs/01_qualification and docs/02_env |
| Reproducibility | SEED and every plusarg in tests/generated/t_rv32d_fv_pmu/plusargs.txt (generated deterministically by scripts/generators/gen_prog.py); replay: build tb_top, run the simulator with +f-style plusargs from that file in a fresh runs/<run_id>/, then python scripts/evaluate_run.py runs/<run_id> |
| Waveform | N/A: outside the ten R-283 priority tests (plan 6.3); targeted capture only for diagnosis (R-278) |
| Evidence | Not run: no simulation in this phase (free disk below the approved 2 GiB threshold) |

Planned checks (from verification_plan.md Section 6.1, R-286):

| Check ID | Requirement / clause | Trigger | Expected observation | Checker / assertion | Deadline | Failure condition |
|---|---|---|---|---|---|---|
| CK-FPM-01 | REQ-PMU-002 | counter at 2^W-1 + n | wraps modulo 2^W | a_pmu_wrap | proof | cex |
| CK-FPM-02 | REQ-PMU-004 | wrap | overflow event asserted exactly on carry | a_pmu_ovf_on_carry | proof | cex |
| CK-FPM-03 | REQ-PMU-004 | enabled pending cause | level IRQ stays high while any enabled cause pending | a_pmu_irq_level | proof | cex |
| CK-FPM-04 | REQ-PMU-004 | W1C same edge as HW set | hardware set wins | a_pmu_hw_wins | proof | cex |
| CK-FPM-05 | REQ-PMU-003 | snapshot request | all counters captured on one edge | a_pmu_snap_atomic | proof | cex |
"""
TEST = 't_rv32d_fv_pmu'
SEED = 1
KIND = 'formal'
REQS = {
    'CK-FPM-01': 'REQ-PMU-002',
    'CK-FPM-02': 'REQ-PMU-004',
    'CK-FPM-03': 'REQ-PMU-004',
    'CK-FPM-04': 'REQ-PMU-004',
    'CK-FPM-05': 'REQ-PMU-003',
}

STATIC = {
    "runner": "sby -f tests/formal/fv_pmu.sby",
    "interpretation": "14.4.12 does not fix whether snapshot clear/done are combinational or registered: a_pmu_snap_done accepts the observing cycle or the next one",
    "checks": [
        ("CK-FPM-01", "proven", {"property": "a_pmu_wrap", "tasks": ["prove_w64", "prove_w32"]}),
        ("CK-FPM-02", "proven", {"property": "a_pmu_ovf_on_carry", "tasks": ["prove_w64", "prove_w32"]}),
        ("CK-FPM-03", "proven", {"property": "a_pmu_irq_level", "tasks": ["prove_w64"]}),
        ("CK-FPM-04", "proven", {"property": "a_pmu_hw_wins", "tasks": ["prove_w64"]}),
        ("CK-FPM-05", "proven", {"property": "a_pmu_snap_atomic", "tasks": ["prove_w64", "prove_w32"]}),
        ("CK-FPM-06", "covered", {"covers": ["c_pmu_ovf", "c_pmu_irq_rise_fall", "c_pmu_collision", "c_pmu_snap_twice"], "task": "cover_w64"}),
    ],
}
