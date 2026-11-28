"""
AI-GENERATED (Claude Opus 5.5, 2026-11-28) testcase source - candidate (R-117, R-231); engineer review pending (R-284).
Authored from the specification baseline only (RV32 HDS rev 0.4, REF-001 rev 0.39, CSR workbook, question_log answers); no RTL used (R-103, R-232).

| Field | Content |
|---|---|
| Test ID and title | t_rv32d_isa_rv32_traps - Proves XLEN=32 and F-without-D decoding: every RV64-only and D encoding traps |
| Priority and rationale | high; outside the ten R-283 waveform tests; priority from plan 6.1 |
| Purpose | Proves XLEN=32 and F-without-D decoding: every RV64-only and D encoding traps. |
| Requirements and features | REQ-XL-003, REQ-XL-004; features: fp_single, rv32_isa_mode; functions: rv32_isa_mode+fp_single |
| DUT configuration and preconditions | CFG-RV32-2-P0; trap action = skip; misa and RV32C quadrant checks in M mode. Plan configuration column: CFG-RV32-2-P0. Campaign region table bound through tb/generated/region_params.svh (REF-001 rev 0.40 14.4.20, Q-G3-01 answered) |
| Software flow | 1 boot; 2 hart 0 executes .word encodings of ADDW, SUBW, SLLIW, LD, SD, LWU, AMOADD.D, LR.D, SC.D, FADD.D, FLD, FSD, FCVT.D.S, each at its own label; the handler records mcause/mepc/mtval and skips; 3 reads misa; executes C.FLW/C.FSW (RV32C funct3=011 quadrants 0/2) on a known word; 4 TOHOST |
| Stimulus | RV64-only and D-extension encodings written as raw words (the assembler rejects them as mnemonics) |
| Functional checkpoints and assertions | See the check table below (6 planned checks; R-286 requires >= 5). Every check runs through scripts/evaluate_run.py with the oracle/scoreboard named; deadline = test cycle budget unless stated; failure condition as listed |
| Expected outcome | Illegal-instruction trap (cause 2) at each label with mtval = the instruction word; misa MXL=1, I/M/A/F/C/S/U set, D clear; C.FLW/C.FSW execute as FP word accesses |
| Defect/fault targeted | RV64 or D instruction accepted in the RV32F profile; wrong mtval; misa reporting XLEN 64 or D; failure modes FM-FP-04, FM-I32-01, FM-I32-02 |
| Checker/oracle | chk_mem_oracle, chk_sig, chk_trap_oracle; qualification records under docs/01_qualification and docs/02_env |
| Reproducibility | SEED and every plusarg in tests/generated/t_rv32d_isa_rv32_traps/plusargs.txt (generated deterministically by scripts/generators/gen_prog.py); replay: build tb_top, run the simulator with +f-style plusargs from that file in a fresh runs/<run_id>/, then python scripts/evaluate_run.py runs/<run_id> |
| Waveform | N/A: outside the ten R-283 priority tests (plan 6.3); targeted capture only for diagnosis (R-278) |
| Evidence | Not run: no simulation in this phase (free disk below the approved 2 GiB threshold) |

Planned checks (from verification_plan.md Section 6.1, R-286):

| Check ID | Requirement / clause | Trigger | Expected observation | Checker / assertion | Deadline | Failure condition |
|---|---|---|---|---|---|---|
| CK-I32-01 | REQ-XL-003 | ADDW/SUBW/SLLIW/LD/SD/LWU | illegal instruction (cause 2) each | chk_trap_oracle | trap | no trap |
| CK-I32-02 | REQ-XL-003 | AMOADD.D/LR.D/SC.D | cause 2 each | chk_trap_oracle | trap | no trap |
| CK-I32-03 | REQ-XL-004 | FADD.D/FLD/FSD/FCVT.D.S | cause 2 each | chk_trap_oracle | trap | no trap |
| CK-I32-04 | REQ-XL-003 | trap | mtval = faulting instruction bits (TvalEn=1) | chk_trap_oracle | trap | mismatch |
| CK-I32-05 | REQ-XL-003 | csrr misa | MXL (bits 31:30) = 1; I/M/A/F/C/S/U set, D clear | chk_sig | test end | mismatch |
| CK-I32-06 | REQ-XL-004 | C.FLW/C.FSW encodings (RV32C quadrants 0/2, funct3=011) | execute as FP word load/store, no trap (mstatush not checked per Q-G0-02) | chk_sig; chk_mem_oracle | test end | trap or wrong data |
"""
TEST = 't_rv32d_isa_rv32_traps'
SEED = 1
KIND = 'cpu'
REQS = {
    'CK-I32-01': 'REQ-XL-003',
    'CK-I32-02': 'REQ-XL-003',
    'CK-I32-03': 'REQ-XL-004',
    'CK-I32-04': 'REQ-XL-003',
    'CK-I32-05': 'REQ-XL-003',
    'CK-I32-06': 'REQ-XL-004',
}

from rv32d_lib import L, SLOT  # noqa: E402


def build(p):
    enc = {"addw": 0x00C5853B, "subw": 0x40C5853B, "slliw": 0x0015951B, "ld": 0x0005B503, "sd": 0x00A5B023, "lwu": 0x0005E503,
           "amoadd_d": 0x00C5B52F, "lr_d": 0x1005B52F, "sc_d": 0x18C5B52F,
           "fadd_d": 0x02C5F553, "fld": 0x0005B507, "fsd": 0x00A5B027, "fcvt_d_s": 0x42058553}
    p.line("fpw", [0x40490FDB, 0, 0, 0])
    p.asm(0, "la a1, fpw", "mv a2, a1")
    for nm, w in enc.items():
        p.asm(0, "ill_%s:" % nm, ".word 0x%08x" % w)
    p.asm(0, "csrr t1, misa")
    p.store_slot(0, "t1", "misa")
    p.asm(0, "la s0, fpw", "c.flw fa0, 0(s0)", "fmv.x.w t2, fa0", "c.fsw fa0, 4(s0)", "lw t3, 4(s0)")
    p.store_slot(0, "t2", "cflw"); p.store_slot(0, "t3", "cfsw")
    p.end(0); p.end(1)
    rv64 = ["addw", "subw", "slliw", "ld", "sd", "lwu"]
    amo64 = ["amoadd_d", "lr_d", "sc_d"]
    dd = ["fadd_d", "fld", "fsd", "fcvt_d_s"]
    tr = lambda names: [{"kind": "exception", "code": 2, "epc": L("ill_%s" % n), "tval": None} for n in names]
    p.check("CK-I32-01", REQS["CK-I32-01"], "traps", hart=0, subset=True, expected=tr(rv64))
    p.check("CK-I32-02", REQS["CK-I32-02"], "traps", hart=0, subset=True, expected=tr(amo64))
    p.check("CK-I32-03", REQS["CK-I32-03"], "traps", hart=0, subset=True, expected=tr(dd))
    p.check("CK-I32-04", REQS["CK-I32-04"], "traps", hart=0, subset=True, expected=[{"kind": "exception", "code": 2, "epc": L("ill_%s" % n), "tval": w} for n, w in enc.items()])
    # misa: MXL (31:30)=01; extension bits I(8) M(12) A(0) F(5) C(2) S(18) U(20) set, D(3) clear
    want = (1 << 30) | (1 << 8) | (1 << 12) | (1 << 0) | (1 << 5) | (1 << 2) | (1 << 18) | (1 << 20)
    p.check("CK-I32-05", REQS["CK-I32-05"], "slot", addr=SLOT(p, 0, "misa"), expect=want, mask=want | (3 << 30) | (1 << 3))
    p.check("CK-I32-06", REQS["CK-I32-06"], "slots", values={str(SLOT(p, 0, "cflw")): 0x40490FDB, str(SLOT(p, 0, "cfsw")): 0x40490FDB})
