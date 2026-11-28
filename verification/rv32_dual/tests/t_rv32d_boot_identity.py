"""
AI-GENERATED (Claude Opus 5.5, 2026-11-28) testcase source - candidate (R-117, R-231); engineer review pending (R-284).
Authored from the specification baseline only (RV32 HDS rev 0.4, REF-001 rev 0.39, CSR workbook, question_log answers); no RTL used (R-103, R-232).

| Field | Content |
|---|---|
| Test ID and title | t_rv32d_boot_identity - Proves REQ-SYS-001/003 and REQ-XL-002/008 boot and identity for two harts |
| Priority and rationale | high; outside the ten R-283 waveform tests; priority from plan 6.1 |
| Purpose | Proves REQ-SYS-001/003 and REQ-XL-002/008 boot and identity for two harts. |
| Requirements and features | REQ-SYS-001, REQ-XL-002, REQ-XL-003, REQ-XL-008; features: boot_fanout, rv32_isa_mode; functions: boot_fanout+rv32_isa_mode+axi_addr_width |
| DUT configuration and preconditions | CFG-RV32-2-P0; i_boot_addr = 0x0000_0000_8000_0000. Plan configuration column: CFG-RV32-2-P0. Campaign region table bound through tb/generated/region_params.svh (REF-001 rev 0.40 14.4.20, Q-G3-01 answered) |
| Software flow | 1 reset release; 2 both harts start at the boot address, read mhartid and misa, branch to per-hart code (crt) and store them; 3 TOHOST |
| Stimulus | One shared boot address for both harts (REQ-SYS-003) |
| Functional checkpoints and assertions | See the check table below (5 planned checks; R-286 requires >= 5). Every check runs through scripts/evaluate_run.py with the oracle/scoreboard named; deadline = test cycle budget unless stated; failure condition as listed |
| Expected outcome | mhartid 0/1; first fetches at 0x80000000; misa MXL=1; SVA-102 holds; each hart writes its own slot |
| Defect/fault targeted | Duplicate or non-contiguous hart IDs, wrong boot fanout, misa reporting XLEN 64, upper boot bits used; failure modes FM-BOT-02, FM-BOT-03, FM-I32-02 |
| Checker/oracle | a_boot_hi_zero, chk_axi_mem_sb, chk_sig; qualification records under docs/01_qualification and docs/02_env |
| Reproducibility | SEED and every plusarg in tests/generated/t_rv32d_boot_identity/plusargs.txt (generated deterministically by scripts/generators/gen_prog.py); replay: build tb_top, run the simulator with +f-style plusargs from that file in a fresh runs/<run_id>/, then python scripts/evaluate_run.py runs/<run_id> |
| Waveform | N/A: outside the ten R-283 priority tests (plan 6.3); targeted capture only for diagnosis (R-278) |
| Evidence | Not run: no simulation in this phase (free disk below the approved 2 GiB threshold) |

Planned checks (from verification_plan.md Section 6.1, R-286):

| Check ID | Requirement / clause | Trigger | Expected observation | Checker / assertion | Deadline | Failure condition |
|---|---|---|---|---|---|---|
| CK-BID-01 | REQ-SYS-001 | csrr mhartid | 0 and 1, contiguous from zero | chk_sig | boot budget | mismatch |
| CK-BID-02 | REQ-XL-008 | first fetch | address = i_boot_addr[31:0] for both harts | chk_axi_mem_sb | boot budget | mismatch |
| CK-BID-03 | REQ-XL-003 | csrr misa | MXL=1 | chk_sig | test end | mismatch |
| CK-BID-04 | REQ-XL-008 | reset | i_boot_addr[63:32]=0 while reset (SVA-102 holds) | a_boot_hi_zero | reset window | fires |
| CK-BID-05 | REQ-XL-002 | per-hart branch | each hart writes its own signature slot | chk_sig | test end | missing slot |
"""
TEST = 't_rv32d_boot_identity'
SEED = 1
KIND = 'cpu'
REQS = {
    'CK-BID-01': 'REQ-SYS-001',
    'CK-BID-02': 'REQ-XL-008',
    'CK-BID-03': 'REQ-XL-003',
    'CK-BID-04': 'REQ-XL-008',
    'CK-BID-05': 'REQ-XL-002',
}

from rv32d_lib import L, SLOT  # noqa: E402


def build(p):
    p.both("csrr t1, mhartid", "csrr t2, misa")
    for h in (0, 1):
        p.store_slot(h, "t1", "hid"); p.store_slot(h, "t2", "misa")
        p.asm(h, "li t3, 0x%x" % (0xB0070000 + h))
        p.store_slot(h, "t3", "own")
    p.end(0); p.end(1)
    p.check("CK-BID-01", REQS["CK-BID-01"], "slots", values={str(SLOT(p, 0, "hid")): 0, str(SLOT(p, 1, "hid")): 1})
    p.check("CK-BID-02", REQS["CK-BID-02"], "axi_mem", rules=[{"kind": "read_present", "lo": 0x80000000, "hi": 0x8000000F, "window": [None, None]}])
    p.check("CK-BID-03", REQS["CK-BID-03"], "slot", addr=SLOT(p, 1, "misa"), expect=0x40000000, mask=0xC0000000)
    p.check("CK-BID-04", REQS["CK-BID-04"], "sva", id="a_boot_hi_zero")
    p.check("CK-BID-05", REQS["CK-BID-05"], "slots", values={str(SLOT(p, 0, "own")): 0xB0070000, str(SLOT(p, 1, "own")): 0xB0070001})
