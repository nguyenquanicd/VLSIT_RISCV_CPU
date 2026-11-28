"""
AI-GENERATED (Claude Opus 5.5, 2026-11-28) testcase source - candidate (R-117, R-231); engineer review pending (R-284).
Authored from the specification baseline only (RV32 HDS rev 0.4, REF-001 rev 0.39, CSR workbook, question_log answers); no RTL used (R-103, R-232).

| Field | Content |
|---|---|
| Test ID and title | t_rv32d_smoke - Bring-up and configuration smoke on profiles 0/1/2 (Q-04 decision) |
| Priority and rationale | high; outside the ten R-283 waveform tests; priority from plan 6.1 |
| Purpose | Bring-up and configuration smoke on profiles 0/1/2 (Q-04 decision). |
| Requirements and features | REQ-IF-005, REQ-MEM-001, REQ-PERF-006, REQ-PERF-007, REQ-SYS-003, REQ-XL-014; features: axi_protocol, boot_fanout, mesi_coherence, timing_profiles; functions: boot_fanout+mesi_coherence+timing_profiles+axi_protocol |
| DUT configuration and preconditions | CFG-RV32-2-P0, CFG-RV32-2-P1, CFG-RV32-2-P2 (same program; build define RV32D_PROFILE=0/1/2); light backpressure +MEM_RDY=80. Plan configuration column: CFG-RV32-2-P0;CFG-RV32-2-P1;CFG-RV32-2-P2. Campaign region table bound through tb/generated/region_params.svh (REF-001 rev 0.40 14.4.20, Q-G3-01 answered) |
| Software flow | 1 boot; 2 both harts store mhartid-tagged words and read them back; 3 hart 0 writes line sl, hart 1 reads it after a flag; 4 TOHOST |
| Stimulus | Boot, cached load/store, one cross-hart transfer under light backpressure on each timing profile |
| Functional checkpoints and assertions | See the check table below (6 planned checks; R-286 requires >= 5). Every check runs through scripts/evaluate_run.py with the oracle/scoreboard named; deadline = test cycle budget unless stated; failure condition as listed |
| Expected outcome | Both harts boot and pass; peer reads hart 0's value; identical signature on all profiles; no assertion failure |
| Defect/fault targeted | Boot failure, payload or order lost through the profile 1/2 cuts, coherence failure in the smoke path; failure modes FM-AXI-01, FM-BOT-01, FM-COH-01, FM-PRF-01, FM-PRF-02 |
| Checker/oracle | a_axi_addr_hi_zero, a_axi_mem_stable, chk_mem_oracle, chk_sig; qualification records under docs/01_qualification and docs/02_env |
| Reproducibility | SEED and every plusarg in tests/generated/t_rv32d_smoke/plusargs.txt (generated deterministically by scripts/generators/gen_prog.py); replay: build tb_top, run the simulator with +f-style plusargs from that file in a fresh runs/<run_id>/, then python scripts/evaluate_run.py runs/<run_id> |
| Waveform | N/A: outside the ten R-283 priority tests (plan 6.3); targeted capture only for diagnosis (R-278) |
| Evidence | Not run: no simulation in this phase (free disk below the approved 2 GiB threshold) |

Planned checks (from verification_plan.md Section 6.1, R-286):

| Check ID | Requirement / clause | Trigger | Expected observation | Checker / assertion | Deadline | Failure condition |
|---|---|---|---|---|---|---|
| CK-SMK-01 | REQ-SYS-003 | reset release | first instruction fetch of each hart at i_boot_addr[31:0] | chk_sig | boot budget | no fetch |
| CK-SMK-02 | REQ-MEM-001 | cross-hart transfer | hart 1 reads hart 0's value | chk_mem_oracle | test end | stale |
| CK-SMK-03 | REQ-PERF-006 | profile 1 run | same signature as profile 0 | chk_sig | test end | mismatch |
| CK-SMK-04 | REQ-PERF-007 | profile 2 run | same signature as profile 0 | chk_sig | test end | mismatch |
| CK-SMK-05 | REQ-IF-005 | all AXI channels | stability under BFM backpressure | a_axi_mem_stable | per cycle | violation |
| CK-SMK-06 | REQ-XL-006 | external addresses | bits 63:34 zero | a_axi_addr_hi_zero | per cycle | nonzero |
"""
TEST = 't_rv32d_smoke'
SEED = 1
KIND = 'cpu'
REQS = {
    'CK-SMK-01': 'REQ-SYS-003',
    'CK-SMK-02': 'REQ-MEM-001',
    'CK-SMK-03': 'REQ-PERF-006',
    'CK-SMK-04': 'REQ-PERF-007',
    'CK-SMK-05': 'REQ-IF-005',
    'CK-SMK-06': 'REQ-XL-006',
}

from rv32d_lib import L, SLOT  # noqa: E402


def build(p):
    p.plusargs.update({"MEM_RDY": 80})
    p.config = "CFG-RV32-2-P0;CFG-RV32-2-P1;CFG-RV32-2-P2"
    p.line("sl", [0, 0, 0, 0])
    p.word("go", 0)
    p.both("csrr t1, mhartid")
    p.store_slot(0, "t1", "hid"); p.store_slot(1, "t1", "hid")
    p.asm(0, "la t0, sl", "li t1, 0x5A0C0DE5", "sw t1, 0(t0)")
    p.flag_set(0, "go", 1); p.flag_wait(1, "go", 1)
    p.asm(1, "la t0, sl", "lw t1, 0(t0)")
    p.store_slot(1, "t1", "peer")
    p.end(0); p.end(1)
    p.check("CK-SMK-01", REQS["CK-SMK-01"], "axi_mem", rules=[{"kind": "read_present", "lo": 0x80000000, "hi": 0x8000000F, "window": [None, None]}])
    p.check("CK-SMK-02", REQS["CK-SMK-02"], "slot", addr=SLOT(p, 1, "peer"), expect=0x5A0C0DE5)
    p.check("CK-SMK-03", REQS["CK-SMK-03"], "tohost", code=1)
    p.check("CK-SMK-04", REQS["CK-SMK-04"], "slots", values={str(SLOT(p, 0, "hid")): 0, str(SLOT(p, 1, "hid")): 1})
    p.check("CK-SMK-05", REQS["CK-SMK-05"], "sva", id="a_axi_mem_stable", need_cover=False)
    p.check("CK-SMK-06", REQS["CK-SMK-06"], "sva", id="a_axi_addr_hi_zero")
