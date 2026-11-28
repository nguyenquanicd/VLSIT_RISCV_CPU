"""
AI-GENERATED (Claude Opus 5.5, 2026-11-28) testcase source - candidate (R-117, R-231); engineer review pending (R-284).
Authored from the specification baseline only (RV32 HDS rev 0.4, REF-001 rev 0.39, CSR workbook, question_log answers); no RTL used (R-103, R-232).

| Field | Content |
|---|---|
| Test ID and title | t_rv32d_region_routing - Proves region classification and local errors with the five-region campaign table (Q-G0-03) |
| Priority and rationale | high; outside the ten R-283 waveform tests; priority from plan 6.1 |
| Purpose | Proves region classification and local errors with the five-region campaign table (Q-G0-03). |
| Requirements and features | REQ-ERR-002, REQ-IF-009, REQ-IF-011, REQ-XL-006, REQ-XL-011; features: atomics, axi_addr_width, region_table; functions: region_table+atomics+mmio_access+axi_addr_width |
| DUT configuration and preconditions | CFG-RV32-2-P0 with the five-region table (Q-G0-03); trap action = skip. Plan configuration column: CFG-RV32-2-P0. Campaign region table bound through tb/generated/region_params.svh (REF-001 rev 0.40 14.4.20, Q-G3-01 answered) |
| Software flow | 1 boot; 2 hart 0 checkpoint 0xD0; load and store to unmapped 0x20000000; AMOADD.W to MMIO 0x10000A00; two loads from normal-uncached 0x40000100; checkpoint 0xD1; 3 hart 1 maps a 4 KiB Sv32 page to the last page below 2^34 (region 4) and accesses its last word from S mode; 4 TOHOST |
| Stimulus | Accesses to unmapped, MMIO (atomic), normal-uncached and top-of-range addresses |
| Functional checkpoints and assertions | See the check table below (6 planned checks; R-286 requires >= 5). Every check runs through scripts/evaluate_run.py with the oracle/scoreboard named; deadline = test cycle budget unless stated; failure condition as listed |
| Expected outcome | Load/store access faults (5/7) with tval for unmapped and MMIO-atomic accesses, no external transaction for them; both uncached loads reach the memory port; top word accessible |
| Defect/fault targeted | PMA/router mismatch, external traffic for rejected accesses, atomic forwarded to MMIO, uncached data allocated in the LLC, 2^34 bound wrong; failure modes FM-ATM-03, FM-AXW-01, FM-REG-02, FM-REG-03 |
| Checker/oracle | chk_axi_mem_sb, chk_axi_mmio_sb, chk_mem_oracle, chk_trap_oracle; qualification records under docs/01_qualification and docs/02_env |
| Reproducibility | SEED and every plusarg in tests/generated/t_rv32d_region_routing/plusargs.txt (generated deterministically by scripts/generators/gen_prog.py); replay: build tb_top, run the simulator with +f-style plusargs from that file in a fresh runs/<run_id>/, then python scripts/evaluate_run.py runs/<run_id> |
| Waveform | N/A: outside the ten R-283 priority tests (plan 6.3); targeted capture only for diagnosis (R-278) |
| Evidence | Not run: no simulation in this phase (free disk below the approved 2 GiB threshold) |

Planned checks (from verification_plan.md Section 6.1, R-286):

| Check ID | Requirement / clause | Trigger | Expected observation | Checker / assertion | Deadline | Failure condition |
|---|---|---|---|---|---|---|
| CK-REG-01 | REQ-IF-011 | load to unmapped address | access fault (cause 5) with mtval = address | chk_trap_oracle | trap | no fault |
| CK-REG-02 | REQ-ERR-002 | unmapped access | no transaction on any external port | chk_axi_mem_sb; chk_axi_mmio_sb | test end | traffic |
| CK-REG-03 | REQ-IF-011 | store to unmapped address | store access fault (cause 7) | chk_trap_oracle | trap | no fault |
| CK-REG-04 | REQ-IF-011 | AMO to MMIO | local access error, no MMIO AW | chk_trap_oracle; chk_axi_mmio_sb | trap | forwarded |
| CK-REG-05 | REQ-IF-011 | normal-uncached access | memory port with no LLC allocation (second access also external) | chk_axi_mem_sb | test end | cached |
| CK-REG-06 | REQ-XL-011 | Sv32 access to the last word below 2^34 (region 4) | accepted with correct data at AXI address 0x3_FFFF_FFFC | chk_mem_oracle; chk_axi_mem_sb | test end | fault or wrong address |
"""
TEST = 't_rv32d_region_routing'
SEED = 1
KIND = 'cpu'
REQS = {
    'CK-REG-01': 'REQ-IF-011',
    'CK-REG-02': 'REQ-ERR-002',
    'CK-REG-03': 'REQ-IF-011',
    'CK-REG-04': 'REQ-IF-011',
    'CK-REG-05': 'REQ-IF-011',
    'CK-REG-06': 'REQ-XL-011',
}

from rv32d_lib import L, SLOT  # noqa: E402


def build(p):
    p.data.append(".align 12")
    p.data.append("pt_root:")
    p.data.append(".space 4096")
    p.data.append("pt_l0:")
    p.data.append(".space 4096")
    p.ckpt(0, 0xD0)
    p.asm(0, "li t0, 0x20000000", "unm_ld:", "lw t1, 0(t0)", "unm_st:", "sw t1, 0(t0)")
    p.asm(0, "li t0, 0x10000A00", "li t1, 1", "mmio_amo:", "amoadd.w t2, t1, (t0)")
    p.asm(0, "li t0, 0x40000100", "li t1, 0x77", "sw t1, 0(t0)", "lw t2, 0(t0)", "lw t3, 0(t0)")
    p.store_slot(0, "t3", "unc")
    p.ckpt(0, 0xD1)
    p.end(0)
    # hart 1: Sv32 map VA 0x00400000 -> PA 0x3_FFFF_F000 (PPN 0x3FFFFF), plus megapages for code/sig and MMIO
    p.asm(1, "la t0, pt_root",
          "li t1, 0x%x" % ((0x80000000 >> 22) * 4), "add t1, t0, t1", "li t2, 0x%x" % (((0x80000000 >> 12) << 10) | 0xCF), "sw t2, 0(t1)",
          "li t1, 0x%x" % ((0x10000000 >> 22) * 4), "add t1, t0, t1", "li t2, 0x%x" % (((0x10000000 >> 12) << 10) | 0xC7), "sw t2, 0(t1)",
          "la t3, pt_l0", "srli t3, t3, 12", "slli t3, t3, 10", "ori t3, t3, 1", "sw t3, 4(t0)",
          "la t3, pt_l0", "li t2, 0x%x" % ((0x3FFFFF << 10) | 0xC7), "sw t2, 0(t3)",
          "srli t0, t0, 12", "li t1, 0x80000000", "or t0, t0, t1", "csrw satp, t0", "sfence.vma")
    p.asm(1, "li t0, -1", "csrw pmpaddr0, t0", "li t0, 0x1f", "csrw pmpcfg0, t0", "li t0, 0x40", "csrs menvcfg, t0")
    p.asm(1, "la t0, s_main", "csrw mepc, t0", "li t0, 0x1800", "csrc mstatus, t0", "li t0, 0x800", "csrs mstatus, t0", "mret")
    p.asm(1, "s_main:", "li t0, 0x00400ffc", "li t1, 0x3c3c3c3c", "sw t1, 0(t0)", "lw t2, 0(t0)", "ecall")
    p.store_slot(1, "t2", "top")
    p.end(1)
    p.check("CK-REG-01", REQS["CK-REG-01"], "traps", hart=0, subset=True, expected=[{"kind": "exception", "code": 5, "epc": L("unm_ld"), "tval": 0x20000000}])
    p.check("CK-REG-02", REQS["CK-REG-02"], "axi_mem", rules=[{"kind": "no_read", "lo": 0x20000000, "hi": 0x20000003, "window": [0xD0, 0xD1]},
                                                             {"kind": "no_write", "lo": 0x20000000, "hi": 0x20000003, "window": [0xD0, 0xD1]}])
    p.check("CK-REG-02b", REQS["CK-REG-02"], "axi_mmio", rules=[{"kind": "no_write", "lo": 0x10000A00, "hi": 0x10000A03, "window": [0xD0, 0xD1]},
                                                               {"kind": "no_read", "lo": 0x20000000, "hi": 0x20000003, "window": [0xD0, 0xD1]}])
    p.check("CK-REG-03", REQS["CK-REG-03"], "traps", hart=0, subset=True, expected=[{"kind": "exception", "code": 7, "epc": L("unm_st"), "tval": 0x20000000}])
    p.check("CK-REG-04", REQS["CK-REG-04"], "traps", hart=0, subset=True, expected=[{"kind": "exception", "code": 7, "epc": L("mmio_amo"), "tval": 0x10000A00}])
    p.check("CK-REG-05", REQS["CK-REG-05"], "axi_mem", rules=[{"kind": "read_present", "lo": 0x40000100, "hi": 0x40000103, "window": [0xD0, 0xD1]}])
    p.check("CK-REG-05b", REQS["CK-REG-05"], "slot", addr=SLOT(p, 0, "unc"), expect=0x77)
    p.check("CK-REG-06", REQS["CK-REG-06"], "slot", addr=SLOT(p, 1, "top"), expect=0x3c3c3c3c)
