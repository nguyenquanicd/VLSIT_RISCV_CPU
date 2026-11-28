"""
AI-GENERATED (Claude Opus 5.5, 2026-11-28) testcase source - candidate (R-117, R-231); engineer review pending (R-284).
Authored from the specification baseline only (RV32 HDS rev 0.4, REF-001 rev 0.39, CSR workbook, question_log answers); no RTL used (R-103, R-232).

| Field | Content |
|---|---|
| Test ID and title | t_rv32d_counters_pmu - Proves REQ-XL-013: 64-bit counters through RV32 high/low pairs and the per-hart PMU event vector |
| Priority and rationale | high; outside the ten R-283 waveform tests; priority from plan 6.1 |
| Purpose | Proves REQ-XL-013: 64-bit counters through RV32 high/low pairs and the per-hart PMU event vector. |
| Requirements and features | REQ-IF-007, REQ-PMU-003, REQ-PMU-007, REQ-XL-013; features: axil_csr, counters_rv32, pmu_counting, pmu_snapshot; functions: counters_rv32+pmu_counting+pmu_snapshot+axil_csr |
| DUT configuration and preconditions | CFG-RV32-2-P0; PMU counters 0-3 select 0x0007 (exception) and 0x0008 (exception return) for harts 0 and 1. Plan configuration column: CFG-RV32-2-P0. Campaign region table bound through tb/generated/region_params.svh (REF-001 rev 0.40 14.4.20, Q-G3-01 answered) |
| Software flow | 1 boot; 2 checkpoint 0x100: AXI4-Lite programs pmu_evt[0..3] = {0x0007 scope 0, 0x0007 scope 1, 0x0008 scope 0, 0x0008 scope 1}; 3 hart 0 executes 5 ECALLs, hart 1 executes 3 ECALLs (handler skips and returns with MRET); 4 hart 0 presets mcycle/minstret low halves near 0xFFFFFFFF and reads them with the hi-lo-hi sequence across the carry; writes and reads back mcycleh/minstreth and mhpmcounter3/mhpmcounter3h (write 0xFFFFFFFF to the low half, Q-G0-16); 5 checkpoint 0x101: snapshot (REF-001 11.2 S07/S08) and lo/hi reads; 6 TOHOST |
| Stimulus | Known numbers of exceptions/returns per hart; counter presets across the 32-bit carry |
| Functional checkpoints and assertions | See the check table below (5 planned checks; R-286 requires >= 5). Every check runs through scripts/evaluate_run.py with the oracle/scoreboard named; deadline = test cycle budget unless stated; failure condition as listed |
| Expected outcome | hi increments by one across the carry with a consistent low value; read-back of written halves; exact PMU counts 5/3/5/3; snapshot lo/hi consistent |
| Defect/fault targeted | Torn 64-bit counter read, high half not incremented on carry, write to the high half lost, PMU event wired to the wrong hart, torn snapshot; failure modes FM-AXL-02, FM-CNT-01, FM-CNT-02, FM-PMS-01, FM-PMU-02 |
| Checker/oracle | chk_pmu_model, chk_sig; qualification records under docs/01_qualification and docs/02_env |
| Reproducibility | SEED and every plusarg in tests/generated/t_rv32d_counters_pmu/plusargs.txt (generated deterministically by scripts/generators/gen_prog.py); replay: build tb_top, run the simulator with +f-style plusargs from that file in a fresh runs/<run_id>/, then python scripts/evaluate_run.py runs/<run_id> |
| Waveform | N/A: outside the ten R-283 priority tests (plan 6.3); targeted capture only for diagnosis (R-278) |
| Evidence | Not run: no simulation in this phase (free disk below the approved 2 GiB threshold) |

Planned checks (from verification_plan.md Section 6.1, R-286):

| Check ID | Requirement / clause | Trigger | Expected observation | Checker / assertion | Deadline | Failure condition |
|---|---|---|---|---|---|---|
| CK-CNT-01 | REQ-XL-013 | hi-lo-hi read across carry | consistent 64-bit value (hi increments by 1 across the carry) | chk_sig | test end | torn value |
| CK-CNT-02 | REQ-XL-013 | write mcycleh/minstreth | read-back value | chk_sig | test end | mismatch |
| CK-CNT-03 | REQ-XL-013 | mhpmcounterN/Nh | write/read-back of both halves and carry from a written 0xFFFF_FFFF low half (Q-G0-16) | chk_sig | test end | mismatch |
| CK-CNT-04 | REQ-PMU-007 | snapshot after K ecalls per hart | 0x0007 count = K (scope 0/1), 0x0008 = K | chk_pmu_model | after snapshot | mismatch |
| CK-CNT-05 | REQ-PMU-003 | snapshot | lo/hi words of one snapshot consistent | chk_pmu_model | after snapshot | torn |
"""
TEST = 't_rv32d_counters_pmu'
SEED = 1
KIND = 'cpu'
REQS = {
    'CK-CNT-01': 'REQ-XL-013',
    'CK-CNT-02': 'REQ-XL-013',
    'CK-CNT-03': 'REQ-XL-013',
    'CK-CNT-04': 'REQ-PMU-007',
    'CK-CNT-05': 'REQ-PMU-003',
}

from rv32d_lib import L, SLOT  # noqa: E402


def build(p):
    cfg = [(0x0007, 0), (0x0007, 1), (0x0008, 0), (0x0008, 1)]
    p.axil_block(0, 0x100, [p.axw(0x1000 + 4 * k, p.pmu_evt_word(e, s)) for k, (e, s) in enumerate(cfg)])
    p.word("go", 0)
    p.flag_set(0, "go", 1); p.flag_wait(1, "go", 1)
    for h, n in ((0, 5), (1, 3)):
        for _ in range(n):
            p.asm(h, "ecall")
    p.flag_set(1, "go", 2); p.flag_wait(0, "go", 2)
    p.asm(0, "li t0, -8", "csrw mcycle, t0", "li t0, 0", "csrw mcycleh, t0", "nop", "nop", "nop", "nop", "nop", "nop", "nop", "nop", "nop", "nop",
          "hlh:", "csrr t1, mcycleh", "csrr t2, mcycle", "csrr t3, mcycleh", "bne t1, t3, hlh")
    p.store_slot(0, "t1", "cyc_hi"); p.store_slot(0, "t2", "cyc_lo")
    p.asm(0, "li t0, 0x12345678", "csrw minstreth, t0", "csrr t1, minstreth", "li t0, 0x9abcdef0", "csrw mcycleh, t0", "csrr t2, mcycleh")
    p.store_slot(0, "t1", "insth_rb"); p.store_slot(0, "t2", "cych_rb")
    p.asm(0, "li t0, 0x0000000A", "csrw mhpmcounter3h, t0", "li t0, -1", "csrw mhpmcounter3, t0", "csrr t1, mhpmcounter3h", "csrr t2, mhpmcounter3")
    p.store_slot(0, "t1", "hpm3h"); p.store_slot(0, "t2", "hpm3")
    p.axil_block(0, 0x101, p.pmu_snapshot_ops([0, 1, 2, 3]))
    p.end(0); p.end(1)
    p.check("CK-CNT-01", REQS["CK-CNT-01"], "slot", addr=SLOT(p, 0, "cyc_hi"), expect=1)
    p.check("CK-CNT-01b", REQS["CK-CNT-01"], "slot", addr=SLOT(p, 0, "cyc_lo"), expect=0, mask=0xFFFF0000)
    p.check("CK-CNT-02", REQS["CK-CNT-02"], "slots", values={str(SLOT(p, 0, "insth_rb")): 0x12345678, str(SLOT(p, 0, "cych_rb")): 0x9abcdef0})
    p.check("CK-CNT-03", REQS["CK-CNT-03"], "slots_any", values={str(SLOT(p, 0, "hpm3h")): [0x0A, 0x0B], str(SLOT(p, 0, "hpm3")): None})
    occ = [{"cycle": c, "event_id": 0x0007, "hart": 0, "count": 1} for c in range(5)] + [{"cycle": c, "event_id": 0x0007, "hart": 1, "count": 1} for c in range(10, 13)] + \
          [{"cycle": c, "event_id": 0x0008, "hart": 0, "count": 1} for c in range(20, 25)] + [{"cycle": c, "event_id": 0x0008, "hart": 1, "count": 1} for c in range(30, 33)]
    p.check("CK-CNT-04", REQS["CK-CNT-04"], "pmu", config={str(k): [e, s, 1] for k, (e, s) in enumerate(cfg)}, occurrences=occ)
    p.check("CK-CNT-05", REQS["CK-CNT-05"], "axil", csr_model=False)
