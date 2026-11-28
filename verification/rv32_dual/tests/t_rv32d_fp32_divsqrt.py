"""
AI-GENERATED (Claude Opus 5.5, 2026-11-28) testcase source - candidate (R-117, R-231); engineer review pending (R-284).
Authored from the specification baseline only (RV32 HDS rev 0.4, REF-001 rev 0.39, CSR workbook, question_log answers); no RTL used (R-103, R-232).

| Field | Content |
|---|---|
| Test ID and title | t_rv32d_fp32_divsqrt - Proves bit-exact RV32F results with their own fflags (including the DEC-106 divider path) and FP event attribution |
| Priority and rationale | high; rank 10 of the plan 6.3 risk-ranked list: Past defect DEC-106 (RV32 HDS 14.5) |
| Purpose | Proves bit-exact RV32F results with their own fflags (including the DEC-106 divider path) and FP event attribution. |
| Requirements and features | REQ-PMU-008, REQ-XL-004; features: fp_single, pmu_counting; functions: fp_single+pmu_counting |
| DUT configuration and preconditions | CFG-RV32-2-P0; mstatus.FS enabled by crt; PMU counters 0-2 select 0x0015 with scopes 0, 1, 4. Plan configuration column: CFG-RV32-2-P0. Campaign region table bound through tb/generated/region_params.svh (REF-001 rev 0.40 14.4.20, Q-G3-01 answered) |
| Software flow | 1 boot; 2 checkpoint 0xB0: AXI4-Lite enables counters (0x0015 scope 0/1/4); 3 both harts run the same vector list: move operands with fmv.w.x, execute the op with a static rounding mode, move the result with fmv.x.w and read-and-clear fflags (csrrw rd, fflags, zero), store both; 4 checkpoint 0xB1: snapshot; 5 TOHOST |
| Stimulus | FDIV.S/FSQRT.S/FMADD.S/FADD.S corner vectors (exact, inexact, x/0, 0/0, sqrt(-1), rounding modes) from chk_fp_model |
| Functional checkpoints and assertions | See the check table below (5 planned checks; R-286 requires >= 5). Every check runs through scripts/evaluate_run.py with the oracle/scoreboard named; deadline = test cycle budget unless stated; failure condition as listed |
| Expected outcome | Every result and fflags equal the exact rational model; scope-4 count = scope 0 + scope 1; each hart count between 1 and the number of FP operations it executed |
| Defect/fault targeted | DEC-106 class NaN-boxing of divider operands, wrong flags or rounding, wrong per-hart FP event attribution; failure modes FM-FP-01, FM-FP-02, FM-PMU-01 |
| Checker/oracle | chk_fp_model, chk_pmu_model; qualification records under docs/01_qualification and docs/02_env |
| Reproducibility | SEED and every plusarg in tests/generated/t_rv32d_fp32_divsqrt/plusargs.txt (generated deterministically by scripts/generators/gen_prog.py); replay: build tb_top, run the simulator with +f-style plusargs from that file in a fresh runs/<run_id>/, then python scripts/evaluate_run.py runs/<run_id> |
| Waveform | wave.vcd of the run (TOP ports and checkpoint window, +WAVE=wave.vcd +WAVE_SCOPE=ports); R-283 rank 10 |
| Evidence | Not run: no simulation in this phase (free disk below the approved 2 GiB threshold) |

Planned checks (from verification_plan.md Section 6.1, R-286):

| Check ID | Requirement / clause | Trigger | Expected observation | Checker / assertion | Deadline | Failure condition |
|---|---|---|---|---|---|---|
| CK-FP-01 | REQ-XL-004 | each FDIV.S/FSQRT.S | result bit-exact vs exact rational rounding model | chk_fp_model | test end | mismatch |
| CK-FP-02 | REQ-XL-004 | each op | fflags read after each op equals model flags | chk_fp_model | test end | mismatch |
| CK-FP-03 | REQ-XL-004 | 0/0, sqrt(-1), x/0 | canonical NaN 0x7FC00000 + NV, signed infinity + DZ | chk_fp_model | test end | mismatch |
| CK-FP-04 | REQ-XL-004 | RNE/RTZ/RDN/RUP/RMM | per-mode rounding result | chk_fp_model | test end | mismatch |
| CK-FP-05 | REQ-PMU-008 | snapshot | scope 0/1 counts <= per-hart FP op count and scope 4 equals sum of scopes 0 and 1 | chk_pmu_model | after snapshot | violation |
"""
TEST = 't_rv32d_fp32_divsqrt'
SEED = 1
KIND = 'cpu'
REQS = {
    'CK-FP-01': 'REQ-XL-004',
    'CK-FP-02': 'REQ-XL-004',
    'CK-FP-03': 'REQ-XL-004',
    'CK-FP-04': 'REQ-XL-004',
    'CK-FP-05': 'REQ-PMU-008',
}

from rv32d_lib import L, SLOT  # noqa: E402


def build(p):
    import chk_fp_model as F
    f = lambda x: __import__("struct").unpack("<I", __import__("struct").pack("<f", x))[0]
    vec = [("fdiv.s", f(7.0), f(2.0), None, "rne"), ("fdiv.s", f(1.0), f(3.0), None, "rne"), ("fdiv.s", f(1.0), f(3.0), None, "rtz"),
           ("fdiv.s", f(1.0), f(3.0), None, "rup"), ("fdiv.s", f(-1.0), f(3.0), None, "rdn"), ("fdiv.s", f(-2.5), f(1.0), None, "rmm"),
           ("fdiv.s", 0, 0, None, "rne"), ("fdiv.s", f(1.0), 0, None, "rne"), ("fdiv.s", f(-1.0), 0, None, "rne"),
           ("fsqrt.s", f(2.0), None, None, "rne"), ("fsqrt.s", f(4.0), None, None, "rne"), ("fsqrt.s", f(-1.0), None, None, "rne"),
           ("fsqrt.s", 0x80000000, None, None, "rne"), ("fmadd.s", f(2.0), f(3.0), f(1.0), "rne"), ("fadd.s", 0x3DCCCCCD, 0x3E4CCCCD, None, "rne"),
           ("fmul.s", 0x00800001, f(0.5), None, "rne"), ("fmul.s", 0x7F7FFFFF, f(2.0), None, "rtz")]
    p.axil_block(0, 0xB0, [p.axw(0x1000 + 4 * k, p.pmu_evt_word(0x0015, s)) for k, s in enumerate((0, 1, 4))])
    p.word("go", 0)
    p.flag_set(0, "go", 1); p.flag_wait(1, "go", 1)
    for h in (0, 1):
        for i, (op, a, b, c, rm) in enumerate(vec):
            p.asm(h, "li t1, 0x%x" % a, "fmv.w.x fa1, t1")
            if b is not None:
                p.asm(h, "li t1, 0x%x" % b, "fmv.w.x fa2, t1")
            if c is not None:
                p.asm(h, "li t1, 0x%x" % c, "fmv.w.x fa3, t1")
            ops = {"fsqrt.s": "fsqrt.s fa0, fa1, %s", "fmadd.s": "fmadd.s fa0, fa1, fa2, fa3, %s"}.get(op, op + " fa0, fa1, fa2, %s")
            p.asm(h, "csrw fflags, zero", ops % rm, "fmv.x.w t2, fa0", "csrrw t3, fflags, zero")
            p.store_slot(h, "t2", "r%d" % i); p.store_slot(h, "t3", "f%d" % i)
    p.flag_set(1, "go", 2); p.flag_wait(0, "go", 2)
    p.axil_block(0, 0xB1, p.pmu_snapshot_ops([0, 1, 2]))
    p.end(0); p.end(1)
    exp = [F.fp_op(op, a, b, c, rm) for (op, a, b, c, rm) in vec]
    div_idx = [i for i, v in enumerate(vec) if v[0] in ("fdiv.s", "fsqrt.s")]
    for h in (0, 1):
        p.check("CK-FP-01" if h == 0 else "CK-FP-01h1", REQS["CK-FP-01"], "slots", values={str(SLOT(p, h, "r%d" % i)): exp[i][0] for i in div_idx})
        p.check("CK-FP-02" if h == 0 else "CK-FP-02h1", REQS["CK-FP-02"], "slots", values={str(SLOT(p, h, "f%d" % i)): exp[i][1] for i in range(len(vec))})
    p.check("CK-FP-03", REQS["CK-FP-03"], "slots", values={str(SLOT(p, 0, "r%d" % i)): exp[i][0] for i in (6, 7, 8, 11)})
    p.check("CK-FP-04", REQS["CK-FP-04"], "slots", values={str(SLOT(p, 0, "r%d" % i)): exp[i][0] for i in (1, 2, 3, 4, 5)})
    p.check("CK-FP-05", REQS["CK-FP-05"], "pmu_relation", sum_of=[0, 1], total=2, max_each=len(vec) * 2, min_each=1)
    p.check("CK-FP-06", "REQ-XL-004", "slots", values={str(SLOT(p, 0, "r%d" % i)): exp[i][0] for i in (13, 14, 15, 16)})
