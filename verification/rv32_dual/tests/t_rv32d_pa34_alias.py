"""
AI-GENERATED (Claude Opus 5.5, 2026-11-28) testcase source - candidate (R-117, R-231); engineer review pending (R-284).
Authored from the specification baseline only (RV32 HDS rev 0.4, REF-001 rev 0.39, CSR workbook, question_log answers); no RTL used (R-103, R-232).

| Field | Content |
|---|---|
| Test ID and title | t_rv32d_pa34_alias - Proves 34-bit physical addresses reach AXI unaliased (region 4 of the Q-G0-03 table; SVA-101 part blocked by Q-G0-13) |
| Priority and rationale | medium; outside the ten R-283 waveform tests; priority from plan 6.1 |
| Purpose | Proves 34-bit physical addresses reach AXI unaliased (region 4 of the Q-G0-03 table; SVA-101 part blocked by Q-G0-13). |
| Requirements and features | REQ-XL-005, REQ-XL-006, REQ-XL-007, REQ-XL-011; features: axi_addr_width, line_addr_adapter, region_table, sv32_mmu; functions: line_addr_adapter+sv32_mmu+region_table+axi_addr_width |
| DUT configuration and preconditions | CFG-RV32-2-P0; region 4 (normal-uncached 0x3_C000_0000-0x3_FFFF_FFFF, Q-G0-03); Sv32 4 KiB pages mapping VAs to PAs that differ only in bits 33:30. Plan configuration column: CFG-RV32-2-P0. Campaign region table bound through tb/generated/region_params.svh (REF-001 rev 0.40 14.4.20, Q-G3-01 answered) |
| Software flow | 1 boot; 2 hart 0 maps VA 0x00401000 -> PA 0x3_C000_1000, VA 0x00402000 -> PA 0x3_D000_1000 (bit 32/28 differ), VA 0x00403000 -> PA 0x3_FFFF_F000 (last page); 3 S mode: distinct values stored through each alias, read back; checkpoints 0xF0/0xF1 around the accesses; 4 TOHOST |
| Stimulus | 34-bit physical addresses reached through Sv32 (RV32 HDS 6.2, REQ-XL-005/006/011) |
| Functional checkpoints and assertions | See the check table below (5 planned checks; R-286 requires >= 5). Every check runs through scripts/evaluate_run.py with the oracle/scoreboard named; deadline = test cycle budget unless stated; failure condition as listed |
| Expected outcome | Each alias keeps its own value; AXI addresses carry PA bits 33:30 and zero 63:34; the last line below 2^34 is accessible |
| Defect/fault targeted | Upper physical-address bits dropped or shifted (aliasing), region-4 top page rejected; failure modes FM-AXW-02, FM-LAD-01, FM-LAD-02, FM-REG-03, FM-SV-01 |
| Checker/oracle | a_line_addr_hi_zero, chk_axi_mem_sb, chk_mem_oracle; qualification records under docs/01_qualification and docs/02_env |
| Reproducibility | SEED and every plusarg in tests/generated/t_rv32d_pa34_alias/plusargs.txt (generated deterministically by scripts/generators/gen_prog.py); replay: build tb_top, run the simulator with +f-style plusargs from that file in a fresh runs/<run_id>/, then python scripts/evaluate_run.py runs/<run_id> |
| Waveform | N/A: outside the ten R-283 priority tests (plan 6.3); targeted capture only for diagnosis (R-278) |
| Evidence | Not run: no simulation in this phase (free disk below the approved 2 GiB threshold) |
| Blocked obligations | OB-085 (REQ-XL-007): Q-G0-13 answered A: waiting for the SVA observation-point table in the RV32 HDS; region 4 (Q-G0-03) available |

Planned checks (from verification_plan.md Section 6.1, R-286):

| Check ID | Requirement / clause | Trigger | Expected observation | Checker / assertion | Deadline | Failure condition |
|---|---|---|---|---|---|---|
| CK-PA-01 | REQ-XL-007 | alias pair writes | distinct values read back | chk_mem_oracle | test end | alias |
| CK-PA-02 | REQ-XL-006 | AXI address | bits 33:30 match the PA, 63:34 zero | chk_axi_mem_sb | per AW/AR | mismatch |
| CK-PA-03 | REQ-XL-005 | PPN mapping | PA = PPN[21:0] << 12 + offset | chk_mem_oracle | test end | mismatch |
| CK-PA-04 | REQ-XL-011 | region 4 ending at 2^34 | last line accessible | chk_mem_oracle | test end | fault |
| CK-PA-05 | REQ-XL-007 | internal line inputs | SVA-101 never fires | a_line_addr_hi_zero | per cycle | fires |
"""
TEST = 't_rv32d_pa34_alias'
SEED = 1
KIND = 'cpu'
REQS = {
    'CK-PA-01': 'REQ-XL-007',
    'CK-PA-02': 'REQ-XL-006',
    'CK-PA-03': 'REQ-XL-005',
    'CK-PA-04': 'REQ-XL-011',
    'CK-PA-05': 'REQ-XL-007',
}

from rv32d_lib import L, SLOT  # noqa: E402

def _pt(p, h, extra=()):
    """Sv32 root table: megapages for region 0 (0x80000000, supervisor RWX) and MMIO (0x10000000, RW)."""
    p.asm(h, "la t0, pt_root",
          "li t1, 0x%x" % ((0x80000000 >> 22) * 4), "add t1, t0, t1", "li t2, 0x%x" % (((0x80000000 >> 12) << 10) | 0xCF), "sw t2, 0(t1)",
          "li t1, 0x%x" % ((0x10000000 >> 22) * 4), "add t1, t0, t1", "li t2, 0x%x" % (((0x10000000 >> 12) << 10) | 0xC7), "sw t2, 0(t1)")
    for ln in extra:
        p.asm(h, ln)
    p.asm(h, "la t0, pt_root", "srli t0, t0, 12", "li t1, 0x80000000", "or t0, t0, t1", "csrw satp, t0", "sfence.vma")


def _to_s(p, h, label):
    """PMP entry 0 = NAPOT all, RWX (S/U accesses need a matching PMP entry when PMP is implemented);
    menvcfg.CBCFE=1 so CBO.CLEAN/FLUSH (test_end) are legal in S mode (Zicbom); then mret to S."""
    p.asm(h, "li t0, -1", "csrw pmpaddr0, t0", "li t0, 0x1f", "csrw pmpcfg0, t0", "li t0, 0x40", "csrs menvcfg, t0")
    p.asm(h, "la t0, %s" % label, "csrw mepc, t0", "li t0, 0x1800", "csrc mstatus, t0", "li t0, 0x800", "csrs mstatus, t0", "mret")


def build(p):
    p.data.append(".align 12"); p.data.append("pt_root:"); p.data.append(".space 4096")
    p.data.append("pt_l0:"); p.data.append(".space 4096")
    pas = [0x3C0001000, 0x3D0001000, 0x3FFFFF000]
    extra = ["la t3, pt_l0", "srli t3, t3, 12", "slli t3, t3, 10", "ori t3, t3, 1", "la t4, pt_root", "sw t3, 4(t4)"]
    for i, pa in enumerate(pas):
        extra += ["li t3, 0x%x" % (((pa >> 12) << 10) | 0xC7), "la t4, pt_l0", "sw t3, %d(t4)" % (4 * (i + 1))]
    _pt(p, 0, extra)
    _to_s(p, 0, "s_alias")
    p.asm(0, "s_alias:")
    p.ckpt(0, 0xF0)
    for i in range(3):
        p.asm(0, "li t0, 0x%x" % (0x00401000 + 0x1000 * i + (0xFF0 if i == 2 else 0)), "li t1, 0x%x" % (0xA1A50000 + i), "sw t1, 0(t0)")
    for i in range(3):
        p.asm(0, "li t0, 0x%x" % (0x00401000 + 0x1000 * i + (0xFF0 if i == 2 else 0)), "lw t1, 0(t0)")
        p.store_slot(0, "t1", "alias%d" % i)
    p.ckpt(0, 0xF1)
    p.asm(0, "ecall")
    p.end(0); p.end(1)
    p.check("CK-PA-01", REQS["CK-PA-01"], "slots", values={str(SLOT(p, 0, "alias%d" % i)): 0xA1A50000 + i for i in range(2)})
    p.check("CK-PA-02", REQS["CK-PA-02"], "axi_mem", rules=[{"kind": "write_present", "lo": pa, "hi": pa + 3, "window": [0xF0, 0xF1]} for pa in pas[:2]])
    p.check("CK-PA-03", REQS["CK-PA-03"], "axi_mem", rules=[{"kind": "read_present", "lo": pa, "hi": pa + 3, "window": [0xF0, 0xF1]} for pa in pas[:2]])
    p.check("CK-PA-04", REQS["CK-PA-04"], "slot", addr=SLOT(p, 0, "alias2"), expect=0xA1A50002)
    p.check("CK-PA-06", "REQ-XL-006", "sva", id="a_axi_addr_hi_zero")
    p.block("CK-PA-05", REQS["CK-PA-05"], "SVA-101 binding blocked by Q-G0-13 (observation-point table not in the RV32 HDS)")
