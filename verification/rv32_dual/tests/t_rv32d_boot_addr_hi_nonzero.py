"""
AI-GENERATED (Claude Opus 5.5, 2026-11-28) testcase source - candidate (R-117, R-231); engineer review pending (R-284).
Authored from the specification baseline only (RV32 HDS rev 0.4, REF-001 rev 0.39, CSR workbook, question_log answers); no RTL used (R-103, R-232).

| Field | Content |
|---|---|
| Test ID and title | t_rv32d_boot_addr_hi_nonzero - Negative input test: i_boot_addr[63:32] nonzero; SVA-102 must fire and harts boot from bits 31:0 (REQ-XL-008, TEST-108) |
| Priority and rationale | medium; outside the ten R-283 waveform tests; priority from plan 6.1 |
| Purpose | Negative input test: i_boot_addr[63:32] nonzero; SVA-102 must fire and harts boot from bits 31:0 (REQ-XL-008, TEST-108). |
| Requirements and features | REQ-XL-008; features: boot_fanout; functions: boot_fanout (single) |
| DUT configuration and preconditions | CFG-RV32-2-P0; +BOOT_ADDR=0000000180000000 (bits 63:32 nonzero, illegal input of RV32 HDS 6.2/7.3). Plan configuration column: CFG-RV32-2-P0. Campaign region table bound through tb/generated/region_params.svh (REF-001 rev 0.40 14.4.20, Q-G3-01 answered) |
| Software flow | 1 reset with i_boot_addr upper half nonzero (SVA-102 must fire); 2 both harts start at i_boot_addr[31:0] = 0x80000000, record mhartid; 3 TOHOST |
| Stimulus | Negative input: nonzero i_boot_addr[63:32] (REQ-XL-008, TEST-108) |
| Functional checkpoints and assertions | See the check table below (5 planned checks; R-286 requires >= 5). Every check runs through scripts/evaluate_run.py with the oracle/scoreboard named; deadline = test cycle budget unless stated; failure condition as listed |
| Expected outcome | a_boot_hi_zero fires (checker qualification); first fetch at 0x80000000; both harts pass |
| Defect/fault targeted | Upper boot-address bits used for the first fetch or SVA-102 silent; failure modes FM-BOT-03 |
| Checker/oracle | a_axi_addr_hi_zero, a_boot_hi_zero, chk_axi_mem_sb, chk_sig; qualification records under docs/01_qualification and docs/02_env |
| Reproducibility | SEED and every plusarg in tests/generated/t_rv32d_boot_addr_hi_nonzero/plusargs.txt (generated deterministically by scripts/generators/gen_prog.py); replay: build tb_top, run the simulator with +f-style plusargs from that file in a fresh runs/<run_id>/, then python scripts/evaluate_run.py runs/<run_id> |
| Waveform | N/A: outside the ten R-283 priority tests (plan 6.3); targeted capture only for diagnosis (R-278) |
| Evidence | Not run: no simulation in this phase (free disk below the approved 2 GiB threshold) |

Planned checks (from verification_plan.md Section 6.1, R-286):

| Check ID | Requirement / clause | Trigger | Expected observation | Checker / assertion | Deadline | Failure condition |
|---|---|---|---|---|---|---|
| CK-BHN-01 | REQ-XL-008 | reset with upper bits nonzero | a_boot_hi_zero fires (checker qualification) | a_boot_hi_zero | reset window | silent |
| CK-BHN-02 | REQ-XL-008 | first fetch | address uses bits 31:0 only | chk_axi_mem_sb | boot budget | upper bits used |
| CK-BHN-03 | REQ-XL-006 | external AR | bits 63:34 zero | a_axi_addr_hi_zero | per cycle | nonzero |
| CK-BHN-04 | REQ-SYS-003 | both harts | both reach signature | chk_sig | test end | missing |
| CK-BHN-05 | REQ-XL-002 | mhartid | 0/1 | chk_sig | test end | mismatch |
"""
TEST = 't_rv32d_boot_addr_hi_nonzero'
SEED = 1
KIND = 'cpu'
REQS = {
    'CK-BHN-01': 'REQ-XL-008',
    'CK-BHN-02': 'REQ-XL-008',
    'CK-BHN-03': 'REQ-XL-006',
    'CK-BHN-04': 'REQ-SYS-003',
    'CK-BHN-05': 'REQ-XL-002',
}

from rv32d_lib import L, SLOT  # noqa: E402


def build(p):
    p.plusargs.update({"BOOT_ADDR": "0000000180000000"})
    p.both("csrr t1, mhartid")
    p.store_slot(0, "t1", "hid"); p.store_slot(1, "t1", "hid")
    p.end(0); p.end(1)
    p.check("CK-BHN-01", REQS["CK-BHN-01"], "sva", id="a_boot_hi_zero", expect="fire")
    p.check("CK-BHN-02", REQS["CK-BHN-02"], "axi_mem", rules=[{"kind": "read_present", "lo": 0x80000000, "hi": 0x8000000F, "window": [None, None]}])
    p.check("CK-BHN-03", REQS["CK-BHN-03"], "sva", id="a_axi_addr_hi_zero")
    p.check("CK-BHN-04", REQS["CK-BHN-04"], "tohost", code=1)
    p.check("CK-BHN-05", REQS["CK-BHN-05"], "slots", values={str(SLOT(p, 0, "hid")): 0, str(SLOT(p, 1, "hid")): 1})
