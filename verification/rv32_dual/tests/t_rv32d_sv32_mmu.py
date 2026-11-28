"""
AI-GENERATED (Claude Opus 5.5, 2026-11-28) testcase source - candidate (R-117, R-231); engineer review pending (R-284).
Authored from the specification baseline only (RV32 HDS rev 0.4, REF-001 rev 0.39, CSR workbook, question_log answers); no RTL used (R-103, R-232).

| Field | Content |
|---|---|
| Test ID and title | t_rv32d_sv32_mmu - Proves Sv32 translation, faults and S/U transitions with a coherent page-table walk |
| Priority and rationale | high; outside the ten R-283 waveform tests; priority from plan 6.1 |
| Purpose | Proves Sv32 translation, faults and S/U transitions with a coherent page-table walk. |
| Requirements and features | REQ-MEM-001, REQ-XL-005, REQ-XL-006; features: axi_addr_width, mesi_coherence, sv32_mmu; functions: sv32_mmu+mesi_coherence+axi_addr_width |
| DUT configuration and preconditions | CFG-RV32-2-P0; page tables in region 0 (pt_root, pt_l0 per hart area); trap action = skip; medeleg = 0 (faults taken in M). Plan configuration column: CFG-RV32-2-P0. Campaign region table bound through tb/generated/region_params.svh (REF-001 rev 0.40 14.4.20, Q-G3-01 answered) |
| Software flow | 1 boot; 2 hart 0 builds an Sv32 root with megapages for code/data and MMIO, a 4 MiB megapage VA 0x00800000 -> PA 0x80400000 and a level-0 table with 4 KiB pages: VA 0x00401000 -> data page A (RW, A=D=1), VA 0x00402000 -> page B (R only), VA 0x00403000 -> page C (A=0), VA 0x00404000 -> page D (RW, D=0); 3 enters S mode: accesses through each mapping (store to B, load from C, store to D expected to fault: 15, 13, 15), reads satp; 4 hart 1 rewrites the PTE of VA 0x00401000 to page A2; hart 0 executes SFENCE.VMA and reads the new mapping; 5 TOHOST |
| Stimulus | Sv32 4 KiB and 4 MiB translations, permission and A/D faults (Q-G0-08), PTE update by the peer hart with SFENCE.VMA |
| Functional checkpoints and assertions | See the check table below (6 planned checks; R-286 requires >= 5). Every check runs through scripts/evaluate_run.py with the oracle/scoreboard named; deadline = test cycle budget unless stated; failure condition as listed |
| Expected outcome | Loads/stores reach the translated PAs; faults with causes 15/13/15 and stval = VA; PTEs unchanged in memory; new mapping visible after SFENCE.VMA; satp MODE bit 31 set |
| Defect/fault targeted | Wrong translation, wrong fault cause/tval, hardware A/D update, stale PTE after SFENCE.VMA, PA truncation; failure modes FM-AXW-01, FM-SV-01, FM-SV-02, FM-SV-03 |
| Checker/oracle | a_axi_addr_hi_zero, chk_mem_oracle, chk_sig, chk_trap_oracle; qualification records under docs/01_qualification and docs/02_env |
| Reproducibility | SEED and every plusarg in tests/generated/t_rv32d_sv32_mmu/plusargs.txt (generated deterministically by scripts/generators/gen_prog.py); replay: build tb_top, run the simulator with +f-style plusargs from that file in a fresh runs/<run_id>/, then python scripts/evaluate_run.py runs/<run_id> |
| Waveform | N/A: outside the ten R-283 priority tests (plan 6.3); targeted capture only for diagnosis (R-278) |
| Evidence | Not run: no simulation in this phase (free disk below the approved 2 GiB threshold) |

Planned checks (from verification_plan.md Section 6.1, R-286):

| Check ID | Requirement / clause | Trigger | Expected observation | Checker / assertion | Deadline | Failure condition |
|---|---|---|---|---|---|---|
| CK-SV-01 | REQ-XL-005 | loads/stores via 4 KiB and 4 MiB pages | data from the translated PA | chk_mem_oracle | test end | mismatch |
| CK-SV-02 | REQ-XL-005 | invalid/permission PTE | page fault cause 12/13/15 with stval = VA | chk_trap_oracle | trap | mismatch |
| CK-SV-03 | REQ-XL-005 | PTE rewrite by hart 1 + SFENCE.VMA on hart 0 | new mapping used | chk_mem_oracle | test end | stale |
| CK-SV-04 | REQ-XL-005 | satp.MODE write | MODE bit 31 = 1 selects Sv32 | chk_sig | test end | mismatch |
| CK-SV-05 | REQ-XL-005 | PTE with A=0, or D=0 on a store | page fault (load 13 / store 15), PTE unchanged in memory, no hardware A/D update (Q-G0-08) | chk_trap_oracle; chk_mem_oracle | trap | no fault or PTE modified |
| CK-SV-06 | REQ-XL-006 | external AR/AW | bits 63:34 zero | a_axi_addr_hi_zero | per cycle | nonzero |
"""
TEST = 't_rv32d_sv32_mmu'
SEED = 1
KIND = 'cpu'
REQS = {
    'CK-SV-01': 'REQ-XL-005',
    'CK-SV-02': 'REQ-XL-005',
    'CK-SV-03': 'REQ-XL-005',
    'CK-SV-04': 'REQ-XL-005',
    'CK-SV-05': 'REQ-XL-005',
    'CK-SV-06': 'REQ-XL-006',
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
    for nm, v in (("pgA", 0xAAAA0001), ("pgB", 0xBBBB0002), ("pgC", 0xCCCC0003), ("pgD", 0xDDDD0004), ("pgA2", 0xA2A20005)):
        p.data.append(".align 12"); p.data.append("%s:" % nm); p.data.append(".word 0x%x" % v); p.data.append(".space 4092")
    p.data.append(".org 0x80400000"); p.data.append("mega:"); p.data.append(".word 0x4D454741")
    p.word("go", 0)
    def pte4k(slot, label, flags):
        return ["la t3, %s" % label, "srli t3, t3, 12", "slli t3, t3, 10", "ori t3, t3, 0x%x" % flags, "la t4, pt_l0", "sw t3, %d(t4)" % (4 * slot)]
    extra = ["la t3, pt_l0", "srli t3, t3, 12", "slli t3, t3, 10", "ori t3, t3, 1", "la t4, pt_root", "sw t3, 4(t4)",
             "li t3, 0x%x" % (((0x80400000 >> 12) << 10) | 0xC7), "la t4, pt_root", "sw t3, 8(t4)"]
    extra += pte4k(1, "pgA", 0xC7) + pte4k(2, "pgB", 0xC3) + pte4k(3, "pgC", 0x87) + pte4k(4, "pgD", 0x47)
    _pt(p, 0, extra)
    _to_s(p, 0, "s0_main")
    p.asm(0, "s0_main:", "li t0, 0x00401000", "lw t1, 0(t0)", "li t0, 0x00800000", "lw t2, 0(t0)")
    p.asm(0, "li t0, 0x00402000", "st_ro:", "sw t1, 0(t0)", "li t0, 0x00403000", "ld_na:", "lw t3, 0(t0)", "li t0, 0x00404000", "st_nd:", "sw t1, 0(t0)")
    p.asm(0, "csrr t5, satp")
    p.store_slot(0, "t1", "va_a"); p.store_slot(0, "t2", "mega"); p.store_slot(0, "t5", "satp")
    p.flag_set(0, "go", 1); p.flag_wait(1, "go", 1)
    p.asm(1, "la t3, pgA2", "srli t3, t3, 12", "slli t3, t3, 10", "ori t3, t3, 0xC7", "la t4, pt_l0", "sw t3, 4(t4)")
    p.flag_set(1, "go", 2); p.flag_wait(0, "go", 2)
    p.asm(0, "sfence.vma", "li t0, 0x00401000", "lw t1, 0(t0)", "la t4, pt_l0", "lw t2, 12(t4)", "lw t3, 16(t4)")
    p.store_slot(0, "t1", "va_a2"); p.store_slot(0, "t2", "pte_c"); p.store_slot(0, "t3", "pte_d")
    p.asm(0, "ecall")
    p.end(0); p.end(1)
    p.check("CK-SV-01", REQS["CK-SV-01"], "slots", values={str(SLOT(p, 0, "va_a")): 0xAAAA0001, str(SLOT(p, 0, "mega")): 0x4D454741})
    p.check("CK-SV-02", REQS["CK-SV-02"], "traps", hart=0, subset=True, expected=[
        {"kind": "exception", "code": 15, "epc": L("st_ro"), "tval": 0x00402000},
        {"kind": "exception", "code": 13, "epc": L("ld_na"), "tval": 0x00403000},
        {"kind": "exception", "code": 15, "epc": L("st_nd"), "tval": 0x00404000}])
    p.check("CK-SV-03", REQS["CK-SV-03"], "slot", addr=SLOT(p, 0, "va_a2"), expect=0xA2A20005)
    p.check("CK-SV-04", REQS["CK-SV-04"], "slot", addr=SLOT(p, 0, "satp"), expect=0x80000000, mask=0x80000000)
    p.check("CK-SV-05", REQS["CK-SV-05"], "slot", addr=SLOT(p, 0, "pte_c"), expect=0, mask=0x40)
    p.check("CK-SV-05b", REQS["CK-SV-05"], "slot", addr=SLOT(p, 0, "pte_d"), expect=0, mask=0x80)
    p.check("CK-SV-06", REQS["CK-SV-06"], "sva", id="a_axi_addr_hi_zero")
