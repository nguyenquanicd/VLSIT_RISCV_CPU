"""
AI-GENERATED (Claude Opus 5.5, 2026-11-28) testcase source - candidate (R-117, R-231); engineer review pending (R-284).
Authored from the specification baseline only (RV32 HDS rev 0.4, REF-001 rev 0.39, CSR workbook, question_log answers); no RTL used (R-103, R-232).

| Field | Content |
|---|---|
| Test ID and title | t_rv32d_cbo_fault_llc - Proves the precise Store/AMO access fault (code 7) of a writeback-required CBO when the external memory write fails, and that dirty data stays recoverable for a retry |
| Priority and rationale | high; rank 2 of the plan 6.3 risk-ranked list: Precise trap ordering after ABORT; data-loss consequence |
| Purpose | Proves the precise Store/AMO access fault (code 7) of a writeback-required CBO when the external memory write fails, and that dirty data stays recoverable for a retry. |
| Requirements and features | PROTO-AXI4-A3.2, REQ-MEM-012, REQ-MEM-016, REQ-MEM-017, REQ-XL-005; features: axi_protocol, cbo_maintenance, cbo_precise_fault, mesi_coherence, sv32_mmu; functions: cbo_precise_fault+cbo_maintenance+mesi_coherence+sv32_mmu+axi_protocol |
| DUT configuration and preconditions | CFG-RV32-2-P0; memory BFM rule: SLVERR then DECERR on the B of the external write of line fa, OKAY afterwards; S-mode run uses an Sv32 identity mapping of region 0 with medeleg bit 7. Plan configuration column: CFG-RV32-2-P0. Campaign region table bound through tb/generated/region_params.svh (REF-001 rev 0.40 14.4.20, Q-G3-01 answered) |
| Software flow | 1 boot; 2 hart 0 dirties line fa (offset 7 effective address), trap action = resume at retry label; 3 CBO.CLEAN fa (M mode) -> expect store/AMO access fault cause 7, mepc = CBO PC, mtval = EA; the younger marker store must not execute; 4 retry CBO.CLEAN with OKAY; 5 same with CBO.FLUSH and DECERR; 6 hart 1: Sv32 root page table, enter S mode with medeleg[7]=1, CBO.CLEAN on a mapped VA of line fb with SLVERR -> scause 7, stval = VA; 7 publish and TOHOST |
| Stimulus | External memory B error (SLVERR/DECERR) on the LLC-to-memory writeback of CBO.CLEAN/FLUSH; retry with OKAY |
| Functional checkpoints and assertions | See the check table below (6 planned checks; R-286 requires >= 5). Every check runs through scripts/evaluate_run.py with the oracle/scoreboard named; deadline = test cycle budget unless stated; failure condition as listed |
| Expected outcome | Precise trap cause 7 with exact epc/tval (M and S), no younger retirement, retry writes the original data with 2 beats |
| Defect/fault targeted | CBO retired on request acceptance, wrong cause/epc/tval, dirty data lost after error, duplicate external write after the trap; failure modes FM-AXI-01, FM-CBF-01, FM-CBF-02, FM-CBF-03, FM-CBF-04, FM-COH-05 |
| Checker/oracle | chk_axi_mem_sb, chk_mem_oracle, chk_sig, chk_trap_oracle; qualification records under docs/01_qualification and docs/02_env |
| Reproducibility | SEED and every plusarg in tests/generated/t_rv32d_cbo_fault_llc/plusargs.txt (generated deterministically by scripts/generators/gen_prog.py); replay: build tb_top, run the simulator with +f-style plusargs from that file in a fresh runs/<run_id>/, then python scripts/evaluate_run.py runs/<run_id> |
| Waveform | wave.vcd of the run (TOP ports and checkpoint window, +WAVE=wave.vcd +WAVE_SCOPE=ports); R-283 rank 2 |
| Evidence | Not run: no simulation in this phase (free disk below the approved 2 GiB threshold) |

Planned checks (from verification_plan.md Section 6.1, R-286):

| Check ID | Requirement / clause | Trigger | Expected observation | Checker / assertion | Deadline | Failure condition |
|---|---|---|---|---|---|---|
| CK-CBF-01 | REQ-MEM-017 | trap entry | mcause (or scause when delegated) = 7 | chk_trap_oracle | trap handler | other cause or no trap |
| CK-CBF-02 | REQ-MEM-017 | trap entry | mepc/sepc = CBO PC; mtval/stval = original effective address incl. byte offset (e.g. ...0007) | chk_trap_oracle | trap handler | mismatch |
| CK-CBF-03 | REQ-MEM-017 | after trap | younger marker store after the CBO not visible; CBO not retired (minstret delta) | chk_sig; chk_mem_oracle | test end | marker present |
| CK-CBF-04 | REQ-MEM-016 | handler retry with OKAY | retry CLEAN writes the original dirty data (2 beats) | chk_axi_mem_sb | test end | data lost or changed |
| CK-CBF-05 | REQ-ERR-001 | error injection | exactly one external AW per CBO attempt; no duplicate issue after trap | chk_axi_mem_sb | test end | duplicate AW |
| CK-CBF-06 | REQ-XL-005 | S-mode variant | stval holds the Sv32 virtual effective address | chk_trap_oracle | trap handler | physical or truncated value |
"""
TEST = 't_rv32d_cbo_fault_llc'
SEED = 1
KIND = 'cpu'
REQS = {
    'CK-CBF-01': 'REQ-MEM-017',
    'CK-CBF-02': 'REQ-MEM-017',
    'CK-CBF-03': 'REQ-MEM-017',
    'CK-CBF-04': 'REQ-MEM-016',
    'CK-CBF-05': 'REQ-ERR-001',
    'CK-CBF-06': 'REQ-XL-005',
}

from rv32d_lib import L, SLOT  # noqa: E402


def build(p):
    p.waveform = True
    p.line("fa", [0xFA000000, 0xFA000001, 0xFA000002, 0xFA000003])
    p.line("fb", [0xFB000000, 0xFB000001, 0xFB000002, 0xFB000003])
    p.word("marker", 0)
    p.data.append(".align 12")
    p.data.append("pt_root:")
    p.data.append(".space 4096")
    # rules: nth-occurrence counting is per rule: 1st write of fa -> SLVERR, 3rd -> DECERR (2nd = retry of CLEAN OK)
    p.mem_rules.append("ERR B {fa} {fa+15} 1 1 2")
    p.mem_rules.append("ERR B {fa} {fa+15} 3 1 3")
    p.mem_rules.append("ERR B {fb} {fb+15} 1 1 2")
    # hart 0, M mode
    p.asm(0, "la t0, fa", "li t1, 0x12345678", "sw t1, 0(t0)")
    p.trap_action(0, 1, "retry_clean")
    p.ckpt(0, 0x31)
    p.asm(0, "la t0, fa", "addi t0, t0, 7", "cbo_clean_site:", "cbo.clean (t0)", "la t2, marker", "li t3, 1", "sw t3, 0(t2)")
    p.asm(0, "retry_clean:")
    p.ckpt(0, 0x32)
    p.asm(0, "la t0, fa", "cbo.clean (t0)")
    p.ckpt(0, 0x33)
    p.trap_action(0, 1, "retry_flush")
    p.asm(0, "la t0, fa", "li t1, 0x9abcdef0", "sw t1, 4(t0)", "cbo_flush_site:", "cbo.flush (t0)", "la t2, marker", "li t3, 2", "sw t3, 0(t2)")
    p.asm(0, "retry_flush:", "la t0, fa", "cbo.flush (t0)")
    p.ckpt(0, 0x34)
    p.asm(0, "la t2, marker", "lw t3, 0(t2)")
    p.store_slot(0, "t3", "marker")
    p.cbo(0, "flush", "marker")
    p.end(0)
    # hart 1: S mode through Sv32 (4 MiB megapage identity map of 0x80000000-0x803FFFFF and the MMIO window)
    p.asm(1, "la t0, pt_root", "li t1, 0x%x" % ((0x80000000 >> 22) * 4), "add t1, t0, t1",
          "li t2, 0x%x" % (((0x80000000 >> 12) << 10) | 0xCF), "sw t2, 0(t1)",
          "li t1, 0x%x" % ((0x10000000 >> 22) * 4), "add t1, t0, t1",
          "li t2, 0x%x" % (((0x10000000 >> 12) << 10) | 0xC7), "sw t2, 0(t1)",
          "srli t0, t0, 12", "li t1, 0x80000000", "or t0, t0, t1", "csrw satp, t0", "sfence.vma",
          "li t0, 0x80", "csrw medeleg, t0", "li t0, 0x40", "csrs menvcfg, t0", "li t0, -1", "csrw pmpaddr0, t0", "li t0, 0x1f", "csrw pmpcfg0, t0")
    p.trap_action(1, 1, "s_retry")
    p.asm(1, "la t0, s_entry", "csrw mepc, t0", "li t0, 0x1800", "csrc mstatus, t0", "li t0, 0x800", "csrs mstatus, t0", "mret")
    p.asm(1, "s_entry:", "la t0, fb", "li t1, 0x5a5a5a5a", "sw t1, 0(t0)", "addi t0, t0, 3", "cbo_clean_s:", "cbo.clean (t0)", "s_retry:", "ecall")
    p.asm(1, "s_exit:")
    p.end(1)
    p.check("CK-CBF-01", REQS["CK-CBF-01"], "traps", hart=0, subset=True, expected=[
        {"kind": "exception", "code": 7, "epc": L("cbo_clean_site"), "tval": L("fa", 7)},
        {"kind": "exception", "code": 7, "epc": L("cbo_flush_site"), "tval": L("fa")}])
    p.check("CK-CBF-02", REQS["CK-CBF-02"], "traps", hart=0, subset=True, expected=[
        {"kind": "exception", "code": 7, "epc": L("cbo_clean_site"), "tval": L("fa", 7)},
        {"kind": "exception", "code": 7, "epc": L("cbo_flush_site"), "tval": L("fa")}])
    p.check("CK-CBF-03", REQS["CK-CBF-03"], "slot", addr=SLOT(p, 0, "marker"), expect=0)
    p.check("CK-CBF-04", REQS["CK-CBF-04"], "axi_mem", rules=[
        {"kind": "write_line", "addr": L("fa"), "window": [0x32, 0x33], "beats": 2, "strobe_full": True, "resp": 0,
         "data": "78563412" + "010000fa" + "020000fa" + "030000fa"}])
    p.check("CK-CBF-05", REQS["CK-CBF-05"], "axi_mem", rules=[
        {"kind": "write_line", "addr": L("fa"), "window": [0x31, 0x32], "count": 1, "resp": 2}])
    p.check("CK-CBF-06", REQS["CK-CBF-06"], "traps", hart=1, subset=True, expected=[
        {"kind": "exception", "code": 7, "epc": L("cbo_clean_s"), "tval": L("fb", 3), "from": "S", "medeleg": 0x80}])
    p.check("CK-CBF-07", "REQ-MEM-016", "mem_word", addr=L("fa", 4), expect=0x9abcdef0)
