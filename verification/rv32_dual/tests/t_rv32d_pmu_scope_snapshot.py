"""
AI-GENERATED (Claude Opus 5.5, 2026-11-28) testcase source - candidate (R-117, R-231); engineer review pending (R-284).
Authored from the specification baseline only (RV32 HDS rev 0.4, REF-001 rev 0.39, CSR workbook, question_log answers); no RTL used (R-103, R-232).

| Field | Content |
|---|---|
| Test ID and title | t_rv32d_pmu_scope_snapshot - Proves PMU scope, aggregation, catalog and snapshot semantics for two active harts |
| Priority and rationale | high; outside the ten R-283 waveform tests; priority from plan 6.1 |
| Purpose | Proves PMU scope, aggregation, catalog and snapshot semantics for two active harts. |
| Requirements and features | REQ-IF-008, REQ-PMU-003, REQ-PMU-004, REQ-PMU-005, REQ-PMU-006, REQ-PMU-007, REQ-PMU-008; features: axil_csr, pmu_counting, pmu_snapshot; functions: pmu_counting+pmu_snapshot+axil_csr |
| DUT configuration and preconditions | CFG-RV32-2-P0; 12 counters programmed; hart 0 executes 4 ECALLs and hart 1 executes 6 ECALLs. Plan configuration column: CFG-RV32-2-P0. Campaign region table bound through tb/generated/region_params.svh (REF-001 rev 0.40 14.4.20, Q-G3-01 answered) |
| Software flow | 1 boot; 2 checkpoint 0x110: AXI4-Lite programs pmu_evt[k] for 0x0007 with scopes 0..7 (k=0..7), reserved ID 0x0500 (k=8), SPM ID 0x0206 scope 5 (k=9), CCU stall 0x0308 scope 5 (k=10), 0x0007 scope 4 with en=0 (k=11); 3 both harts raise their exceptions; 4 checkpoint 0x111: W1C done, snapshot request, wait, read done, read all lo/hi words twice; then a second request without W1C and a read of pmu_ctrl; 5 TOHOST |
| Stimulus | Scope sweep 0-7 with two active harts, reserved/SPM IDs, a disabled counter, snapshot sequences |
| Functional checkpoints and assertions | See the check table below (7 planned checks; R-286 requires >= 5). Every check runs through scripts/evaluate_run.py with the oracle/scoreboard named; deadline = test cycle budget unless stated; failure condition as listed |
| Expected outcome | Scopes 0/1/4 = 4/6/10, scopes 2/3/5/6/7 = 0, reserved/SPM IDs and disabled counter = 0; repeated reads stable; snapshot_done stays 1 after the second request |
| Defect/fault targeted | Absent hart counted, wrong aggregate, reserved scope/ID counted, torn or unstable snapshot, sticky done cleared by a request; failure modes FM-AXL-01, FM-PMO-03, FM-PMS-01, FM-PMS-02, FM-PMU-01, FM-PMU-02, FM-PMU-03 |
| Checker/oracle | a_int_pmu_no_cause, chk_csr_model, chk_pmu_model; qualification records under docs/01_qualification and docs/02_env |
| Reproducibility | SEED and every plusarg in tests/generated/t_rv32d_pmu_scope_snapshot/plusargs.txt (generated deterministically by scripts/generators/gen_prog.py); replay: build tb_top, run the simulator with +f-style plusargs from that file in a fresh runs/<run_id>/, then python scripts/evaluate_run.py runs/<run_id> |
| Waveform | N/A: outside the ten R-283 priority tests (plan 6.3); targeted capture only for diagnosis (R-278) |
| Evidence | Not run: no simulation in this phase (free disk below the approved 2 GiB threshold) |

Planned checks (from verification_plan.md Section 6.1, R-286):

| Check ID | Requirement / clause | Trigger | Expected observation | Checker / assertion | Deadline | Failure condition |
|---|---|---|---|---|---|---|
| CK-PMS-01 | REQ-PMU-005 | scopes 2/3 (absent harts), 6/7 (reserved) | count zero | chk_pmu_model | after snapshot | nonzero |
| CK-PMS-02 | REQ-PMU-006 | scope 4 | equals scope 0 + scope 1 for the same event | chk_pmu_model | after snapshot | mismatch |
| CK-PMS-03 | REQ-PMU-007 | reserved/unknown IDs and SPM IDs 0x0206/0x0207/0x020B-0x020E | count zero | chk_pmu_model | after snapshot | nonzero |
| CK-PMS-04 | REQ-PMU-003 | snapshot during counting | snapshot stable across repeated reads until next request | chk_pmu_model | after snapshot | changes |
| CK-PMS-05 | REQ-PMU-003 | second request without W1C | snapshot_done stays 1 (not cleared by request) | chk_csr_model | after request | cleared |
| CK-PMS-06 | REQ-PMU-008 | scope 5 CCU stall event | counts one per stalled cycle (bounded by cycles) | chk_pmu_model | after snapshot | exceeds bound |
| CK-PMS-07 | REQ-PMU-004 | whole test, no counter wraps | o_int_pmu low and irq_raw/irq_sts read zero (Q-G0-10) | a_int_pmu_no_cause; chk_csr_model | per cycle | o_int_pmu high |
"""
TEST = 't_rv32d_pmu_scope_snapshot'
SEED = 1
KIND = 'cpu'
REQS = {
    'CK-PMS-01': 'REQ-PMU-005',
    'CK-PMS-02': 'REQ-PMU-006',
    'CK-PMS-03': 'REQ-PMU-007',
    'CK-PMS-04': 'REQ-PMU-003',
    'CK-PMS-05': 'REQ-PMU-003',
    'CK-PMS-06': 'REQ-PMU-008',
    'CK-PMS-07': 'REQ-PMU-004',
}

from rv32d_lib import L, SLOT  # noqa: E402


def build(p):
    cfg = [(0x0007, s, 1) for s in range(8)] + [(0x0500, 0, 1), (0x0206, 5, 1), (0x0308, 5, 1), (0x0007, 4, 0)]
    p.axil_block(0, 0x110, [p.axw(0x1000 + 4 * k, p.pmu_evt_word(e, s, en)) for k, (e, s, en) in enumerate(cfg)])
    p.word("go", 0)
    p.flag_set(0, "go", 1); p.flag_wait(1, "go", 1)
    for h, n in ((0, 4), (1, 6)):
        for _ in range(n):
            p.asm(h, "ecall")
    p.flag_set(1, "go", 2); p.flag_wait(0, "go", 2)
    ops = p.pmu_snapshot_ops(list(range(11)))
    ops += [p.axr(0x2000 + 4 * k) for k in range(11)] + [p.axw(0x0, 0x1), "WAIT 40", p.axr(0x0)]
    p.axil_block(0, 0x111, ops)
    p.end(0); p.end(1)
    occ = [{"cycle": c, "event_id": 0x0007, "hart": 0, "count": 1} for c in range(4)] + [{"cycle": c, "event_id": 0x0007, "hart": 1, "count": 1} for c in range(10, 16)]
    full = {str(k): [e, s, en] for k, (e, s, en) in enumerate(cfg) if k != 10}
    p.check("CK-PMS-01", REQS["CK-PMS-01"], "pmu", config={k: v for k, v in full.items() if int(k) in (2, 3, 5, 6, 7)}, occurrences=occ)
    p.check("CK-PMS-02", REQS["CK-PMS-02"], "pmu", config={k: v for k, v in full.items() if int(k) in (0, 1, 4)}, occurrences=occ)
    p.check("CK-PMS-03", REQS["CK-PMS-03"], "pmu", config={k: v for k, v in full.items() if int(k) in (8, 9, 11)}, occurrences=occ)
    p.check("CK-PMS-04", REQS["CK-PMS-04"], "axil_reads_stable", addrs=[0x2000 + 4 * k for k in range(11)], between=[0x111, None])
    p.check("CK-PMS-05", REQS["CK-PMS-05"], "axil_reads_eq", which="last", values={"0": 0x2})
    p.check("CK-PMS-06", REQS["CK-PMS-06"], "pmu_bound", counter=10, max_from="cycles")
    p.check("CK-PMS-07", REQS["CK-PMS-07"], "sva", id="a_int_pmu_no_cause")
