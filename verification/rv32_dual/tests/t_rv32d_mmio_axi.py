"""
AI-GENERATED (Claude Opus 5.5, 2026-11-28) testcase source - candidate (R-117, R-231); engineer review pending (R-284).
Authored from the specification baseline only (RV32 HDS rev 0.4, REF-001 rev 0.39, CSR workbook, question_log answers); no RTL used (R-103, R-232).

| Field | Content |
|---|---|
| Test ID and title | t_rv32d_mmio_axi - Proves non-coherent MMIO access, 64-bit address zero-extension and AXI4 compliance on the MMIO port (region 1 of the Q-G0-03 table) |
| Priority and rationale | high; outside the ten R-283 waveform tests; priority from plan 6.1 |
| Purpose | Proves non-coherent MMIO access, 64-bit address zero-extension and AXI4 compliance on the MMIO port (region 1 of the Q-G0-03 table). |
| Requirements and features | REQ-IF-002, REQ-IF-005, REQ-IF-011, REQ-XL-006; features: axi_addr_width, axi_protocol, mmio_access, region_table; functions: mmio_access+axi_protocol+axi_addr_width+region_table |
| DUT configuration and preconditions | CFG-RV32-2-P0; MMIO BFM READY 50 %, latency 0-12 (+MMIO_RDY=50 +MMIO_LAT=12); scratch words in MMIO region 1 at 0x10000800 + 0x100*hart (testbench RAM). Plan configuration column: CFG-RV32-2-P0. Campaign region table bound through tb/generated/region_params.svh (REF-001 rev 0.40 14.4.20, Q-G3-01 answered) |
| Software flow | 1 boot; 2 each hart writes bytes, halves, words and an FSW to its MMIO scratch window inside checkpoints 0xC0+h/0xC2+h, then reads them back (lbu/lhu/lw/flw); 3 results stored to the signature; 4 TOHOST |
| Stimulus | 1/2/4-byte MMIO stores/loads and FP word access from both harts with MMIO backpressure |
| Functional checkpoints and assertions | See the check table below (6 planned checks; R-286 requires >= 5). Every check runs through scripts/evaluate_run.py with the oracle/scoreboard named; deadline = test cycle budget unless stated; failure condition as listed |
| Expected outcome | MMIO port carries every access with the right address/strobe/data; reads return the written values to the issuing hart; no memory-port traffic for MMIO addresses; addresses bits 63:34 zero |
| Defect/fault targeted | MMIO access routed to the memory port or cached, wrong strobes/data, response returned to the other hart, payload change under stall; failure modes FM-AXI-01, FM-AXW-01, FM-MIO-01, FM-MIO-02, FM-REG-01 |
| Checker/oracle | a_axi_addr_hi_zero, a_axi_mmio_stable, chk_axi_mem_sb, chk_axi_mmio_sb, chk_sig; qualification records under docs/01_qualification and docs/02_env |
| Reproducibility | SEED and every plusarg in tests/generated/t_rv32d_mmio_axi/plusargs.txt (generated deterministically by scripts/generators/gen_prog.py); replay: build tb_top, run the simulator with +f-style plusargs from that file in a fresh runs/<run_id>/, then python scripts/evaluate_run.py runs/<run_id> |
| Waveform | N/A: outside the ten R-283 priority tests (plan 6.3); targeted capture only for diagnosis (R-278) |
| Evidence | Not run: no simulation in this phase (free disk below the approved 2 GiB threshold) |

Planned checks (from verification_plan.md Section 6.1, R-286):

| Check ID | Requirement / clause | Trigger | Expected observation | Checker / assertion | Deadline | Failure condition |
|---|---|---|---|---|---|---|
| CK-MIO-01 | REQ-IF-002 | MMIO store | AW/W on MMIO port only, correct address/strobe/data | chk_axi_mmio_sb | op | wrong port/data |
| CK-MIO-02 | REQ-IF-002 | MMIO load | R data returned to issuing hart register | chk_sig | test end | mismatch |
| CK-MIO-03 | REQ-XL-006 | every MMIO AR/AW | bits 63:34 zero | a_axi_addr_hi_zero | per cycle | nonzero |
| CK-MIO-04 | REQ-IF-005 | stalls | payload stable while VALID and not READY | a_axi_mmio_stable | per cycle | violation |
| CK-MIO-05 | PROTO-AXI4-A6 | responses by ID | per-ID order preserved | chk_axi_mmio_sb | test end | reorder within ID |
| CK-MIO-06 | REQ-IF-002 | MMIO traffic | no memory-port transaction for MMIO addresses | chk_axi_mem_sb | test end | leak |
"""
TEST = 't_rv32d_mmio_axi'
SEED = 1
KIND = 'cpu'
REQS = {
    'CK-MIO-01': 'REQ-IF-002',
    'CK-MIO-02': 'REQ-IF-002',
    'CK-MIO-03': 'REQ-XL-006',
    'CK-MIO-04': 'REQ-IF-005',
    'CK-MIO-05': 'PROTO-AXI4-A6',
    'CK-MIO-06': 'REQ-IF-002',
}

from rv32d_lib import L, SLOT  # noqa: E402


def build(p):
    p.plusargs.update({"MMIO_RDY": 50, "MMIO_LAT": 12})
    for h in (0, 1):
        base = 0x10000800 + 0x100 * h
        p.ckpt(h, 0xC0 + h)
        p.asm(h, "li t0, 0x%x" % base, "li t1, 0x%x" % (0xA5 + h), "sb t1, 1(t0)", "li t1, 0x%x" % (0xBEEF + h), "sh t1, 2(t0)",
              "li t1, 0x%x" % (0x12345678 + h), "sw t1, 4(t0)", "li t1, 0x3f800000", "fmv.w.x ft0, t1", "fsw ft0, 8(t0)")
        p.ckpt(h, 0xC2 + h)
        p.asm(h, "li t0, 0x%x" % base, "lbu t1, 1(t0)", "lhu t2, 2(t0)", "lw t3, 4(t0)", "flw ft1, 8(t0)", "fmv.x.w t4, ft1")
        p.store_slot(h, "t1", "b"); p.store_slot(h, "t2", "hw"); p.store_slot(h, "t3", "w"); p.store_slot(h, "t4", "fw")
        p.end(h)
    p.check("CK-MIO-01", REQS["CK-MIO-01"], "axi_mmio", rules=[{"kind": "write_present", "lo": 0x10000804, "hi": 0x10000807, "window": [0xC0, 0xC2], "data32": 0x12345678}])
    p.check("CK-MIO-02", REQS["CK-MIO-02"], "slots", values={str(SLOT(p, 0, "w")): 0x12345678, str(SLOT(p, 1, "w")): 0x12345679,
                                                             str(SLOT(p, 0, "b")): 0xA5, str(SLOT(p, 1, "hw")): 0xBEF0, str(SLOT(p, 0, "fw")): 0x3F800000})
    p.check("CK-MIO-03", REQS["CK-MIO-03"], "sva", id="a_axi_addr_hi_zero")
    p.check("CK-MIO-04", REQS["CK-MIO-04"], "sva", id="a_axi_mmio_stable")
    p.check("CK-MIO-05", REQS["CK-MIO-05"], "axi_mmio", rules=[{"kind": "structural", "window": [None, None]}])
    p.check("CK-MIO-06", REQS["CK-MIO-06"], "axi_mem", rules=[{"kind": "no_write", "lo": 0x10000000, "hi": 0x1FFFFFFF, "window": [None, None]},
                                                             {"kind": "no_read", "lo": 0x10000000, "hi": 0x1FFFFFFF, "window": [None, None]}])
