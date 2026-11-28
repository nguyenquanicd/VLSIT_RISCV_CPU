"""
AI-GENERATED (Claude Opus 5.5, 2026-11-28) testcase source - candidate (R-117, R-231); engineer review pending (R-284).
Authored from the specification baseline only (RV32 HDS rev 0.4, REF-001 rev 0.39, CSR workbook, question_log answers); no RTL used (R-103, R-232).

| Field | Content |
|---|---|
| Test ID and title | t_rv32d_no_timeout_hold - Proves the no-timeout retention contract at the TOP boundary and response association by ID |
| Priority and rationale | high; rank 9 of the plan 6.3 risk-ranked list: No-timeout contract and ID association |
| Purpose | Proves the no-timeout retention contract at the TOP boundary and response association by ID. |
| Requirements and features | PROTO-AXI4-A3.2, PROTO-AXI4-A6, REQ-ERR-001, REQ-MEM-001, REQ-MEM-013; features: axi_protocol, mesi_coherence, no_ack_timeout; functions: no_ack_timeout+mesi_coherence+axi_protocol |
| DUT configuration and preconditions | CFG-RV32-2-P0; +MEM_REORDER=1; memory BFM HOLD rule: the R of line hz is released 200000 cycles after its request; lines hz, hy preloaded. Plan configuration column: CFG-RV32-2-P0. Campaign region table bound through tb/generated/region_params.svh (REF-001 rev 0.40 14.4.20, Q-G3-01 answered) |
| Software flow | 1 boot; 2 hart 0 checkpoint 0x80, loads hz (held), stores the value, checkpoint 0x82; 3 hart 1 performs 1000 increments on its own line and loads hy (another line, answered out of order), stores both, checkpoint 0x81; 4 TOHOST |
| Stimulus | One external read response withheld for 200000 cycles while the other hart works |
| Functional checkpoints and assertions | See the check table below (5 planned checks; R-286 requires >= 5). Every check runs through scripts/evaluate_run.py with the oracle/scoreboard named; deadline = test cycle budget unless stated; failure condition as listed |
| Expected outcome | Hart 1 finishes (0x81) long before hart 0 (0x82); hart 0 receives the BFM data unchanged; hart 1 reads hy correctly; no fabricated response |
| Defect/fault targeted | DUT-generated timeout or error, independent hart blocked behind the held line, response misrouted after reordering; failure modes FM-AXI-01, FM-AXI-02, FM-COH-01, FM-NAT-01, FM-NAT-02 |
| Checker/oracle | a_axi_mem_stable, chk_axi_mem_sb, chk_mem_oracle, chk_sig; qualification records under docs/01_qualification and docs/02_env |
| Reproducibility | SEED and every plusarg in tests/generated/t_rv32d_no_timeout_hold/plusargs.txt (generated deterministically by scripts/generators/gen_prog.py); replay: build tb_top, run the simulator with +f-style plusargs from that file in a fresh runs/<run_id>/, then python scripts/evaluate_run.py runs/<run_id> |
| Waveform | wave.vcd of the run (TOP ports and checkpoint window, +WAVE=wave.vcd +WAVE_SCOPE=ports); R-283 rank 9 |
| Evidence | Not run: no simulation in this phase (free disk below the approved 2 GiB threshold) |

Planned checks (from verification_plan.md Section 6.1, R-286):

| Check ID | Requirement / clause | Trigger | Expected observation | Checker / assertion | Deadline | Failure condition |
|---|---|---|---|---|---|---|
| CK-HLD-01 | REQ-MEM-013 | hold window | no DUT-generated error/response and hart 0 does not complete the load | chk_sig; chk_axi_mem_sb | hold window | load completes or error |
| CK-HLD-02 | REQ-MEM-013 | hold window | hart 1 independent work completes | chk_sig | hold window | hart 1 stalls |
| CK-HLD-03 | PROTO-AXI4-A6 | out-of-order R by ID | data returned to the requesting hart only | chk_mem_oracle | test end | misrouted data |
| CK-HLD-04 | REQ-ERR-001 | release | hart 0 load returns the BFM data unchanged | chk_mem_oracle | release + budget | wrong data |
| CK-HLD-05 | PROTO-AXI4-A3.2 | R stalled with RREADY | DUT keeps RREADY legal and no AR re-issue for the same line | a_axi_mem_stable; chk_axi_mem_sb | per cycle | violation |
"""
TEST = 't_rv32d_no_timeout_hold'
SEED = 1
KIND = 'cpu'
REQS = {
    'CK-HLD-01': 'REQ-MEM-013',
    'CK-HLD-02': 'REQ-MEM-013',
    'CK-HLD-03': 'PROTO-AXI4-A6',
    'CK-HLD-04': 'REQ-ERR-001',
    'CK-HLD-05': 'PROTO-AXI4-A3.2',
}

from rv32d_lib import L, SLOT  # noqa: E402


def build(p):
    p.waveform = True
    p.plusargs.update({"MEM_REORDER": 1, "TIMEOUT_CYCLES": 3000000})
    p.line("hz", [0x5A5A0001, 0, 0, 0])
    p.line("hy", [0x5A5A0002, 0, 0, 0])
    p.line("own1", [0, 0, 0, 0])
    p.mem_rules.append("HOLD R {hz} {hz+15} 200000")
    p.ckpt(0, 0x80)
    p.asm(0, "la t0, hz", "lw t1, 0(t0)")
    p.store_slot(0, "t1", "hz")
    p.ckpt(0, 0x82)
    p.delay(1, 200)
    p.asm(1, "la t0, own1", "li s1, 1000", "inc_loop:", "lw t1, 0(t0)", "addi t1, t1, 1", "sw t1, 0(t0)", "addi s1, s1, -1", "bnez s1, inc_loop")
    p.store_slot(1, "t1", "work")
    p.asm(1, "la t0, hy", "lw t2, 0(t0)")
    p.store_slot(1, "t2", "hy")
    p.ckpt(1, 0x81)
    p.end(0); p.end(1)
    p.check("CK-HLD-01", REQS["CK-HLD-01"], "ckpt_order", first=0x81, second=0x82, min_gap=100000)
    p.check("CK-HLD-01b", REQS["CK-HLD-01"], "bfm_event", port="mem", event="hold_r", min=1)
    p.check("CK-HLD-02", REQS["CK-HLD-02"], "slot", addr=SLOT(p, 1, "work"), expect=1000)
    p.check("CK-HLD-03", REQS["CK-HLD-03"], "slot", addr=SLOT(p, 1, "hy"), expect=0x5A5A0002)
    p.check("CK-HLD-04", REQS["CK-HLD-04"], "slot", addr=SLOT(p, 0, "hz"), expect=0x5A5A0001)
    p.check("CK-HLD-05", REQS["CK-HLD-05"], "sva", id="a_axi_mem_stable", need_cover=False)
    p.check("CK-HLD-06", "PROTO-AXI4-A6", "axi_mem", rules=[{"kind": "structural", "window": [None, None]}])
