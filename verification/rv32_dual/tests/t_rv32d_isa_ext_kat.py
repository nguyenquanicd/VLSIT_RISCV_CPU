"""
AI-GENERATED (Claude Opus 5.5, 2026-11-28) testcase source - candidate (R-117, R-231); engineer review pending (R-284).
Authored from the specification baseline only (RV32 HDS rev 0.4, REF-001 rev 0.39, CSR workbook, question_log answers); no RTL used (R-103, R-232).

| Field | Content |
|---|---|
| Test ID and title | t_rv32d_isa_ext_kat - Proves the RV32 extension set of REQ-XL-003 by known answers from the ISA definitions |
| Priority and rationale | medium; outside the ten R-283 waveform tests; priority from plan 6.1 |
| Purpose | Proves the RV32 extension set of REQ-XL-003 by known answers from the ISA definitions. |
| Requirements and features | REQ-XL-003, REQ-XL-013; features: counters_rv32, rv32_isa_mode; functions: rv32_isa_mode+counters_rv32 |
| DUT configuration and preconditions | CFG-RV32-2-P0; known answers computed by models/chk_isa_kat.py at generation time. Plan configuration column: CFG-RV32-2-P0. Campaign region table bound through tb/generated/region_params.svh (REF-001 rev 0.40 14.4.20, Q-G3-01 answered) |
| Software flow | 1 boot; 2 hart 0 executes, per extension block (Zba/Zbb/Zbs, Zbc, Zicond, Zkn, Zcb), each instruction on seeded operands loaded with li and stores rd; minstret/minstreth read before and after each block; 3 TOHOST |
| Stimulus | Seeded operands incl. 0, all-ones, sign boundaries, for every RV32 B/Zbc/Zicond/Zkn/Zcb instruction of the plan |
| Functional checkpoints and assertions | See the check table below (6 planned checks; R-286 requires >= 5). Every check runs through scripts/evaluate_run.py with the oracle/scoreboard named; deadline = test cycle budget unless stated; failure condition as listed |
| Expected outcome | Every rd equals the reference; each minstret delta equals the executed instruction count of the block (constant from the generator) |
| Defect/fault targeted | Wrong RV32 form of an extension instruction, miscounted retirement; failure modes FM-CNT-02, FM-I32-03 |
| Checker/oracle | chk_isa_kat, chk_sig; qualification records under docs/01_qualification and docs/02_env |
| Reproducibility | SEED and every plusarg in tests/generated/t_rv32d_isa_ext_kat/plusargs.txt (generated deterministically by scripts/generators/gen_prog.py); replay: build tb_top, run the simulator with +f-style plusargs from that file in a fresh runs/<run_id>/, then python scripts/evaluate_run.py runs/<run_id> |
| Waveform | N/A: outside the ten R-283 priority tests (plan 6.3); targeted capture only for diagnosis (R-278) |
| Evidence | Not run: no simulation in this phase (free disk below the approved 2 GiB threshold) |

Planned checks (from verification_plan.md Section 6.1, R-286):

| Check ID | Requirement / clause | Trigger | Expected observation | Checker / assertion | Deadline | Failure condition |
|---|---|---|---|---|---|---|
| CK-EXT-01 | REQ-XL-003 | Zba/Zbb/Zbs vectors | results equal ISA model | chk_isa_kat | test end | mismatch |
| CK-EXT-02 | REQ-XL-003 | Zbc clmul/clmulh/clmulr | results equal ISA model | chk_isa_kat | test end | mismatch |
| CK-EXT-03 | REQ-XL-003 | Zicond czero.eqz/nez | results equal ISA model | chk_isa_kat | test end | mismatch |
| CK-EXT-04 | REQ-XL-003 | Zkn RV32 forms | results equal ISA model | chk_isa_kat | test end | mismatch |
| CK-EXT-05 | REQ-XL-003 | Zcb compressed forms | results equal ISA model | chk_isa_kat | test end | mismatch |
| CK-EXT-06 | REQ-XL-013 | minstret/minstreth around each block | delta equals executed instruction count | chk_sig | test end | mismatch |
"""
TEST = 't_rv32d_isa_ext_kat'
SEED = 1
KIND = 'cpu'
REQS = {
    'CK-EXT-01': 'REQ-XL-003',
    'CK-EXT-02': 'REQ-XL-003',
    'CK-EXT-03': 'REQ-XL-003',
    'CK-EXT-04': 'REQ-XL-003',
    'CK-EXT-05': 'REQ-XL-003',
    'CK-EXT-06': 'REQ-XL-013',
}

from rv32d_lib import L, SLOT  # noqa: E402


def build(p):
    import random
    import chk_isa_kat as K
    rng = random.Random(p.seed)
    edge = [0, 0xFFFFFFFF, 0x80000000, 0x7FFFFFFF, 1]
    blocks = {
        "EXT-01": ["sh1add", "sh2add", "sh3add", "andn", "orn", "xnor", "clz", "ctz", "cpop", "max", "maxu", "min", "minu",
                   "sext.b", "sext.h", "zext.h", "rol", "ror", "rori", "orc.b", "rev8", "bclr", "bclri", "bext", "bexti", "binv", "binvi", "bset", "bseti"],
        "EXT-02": ["clmul", "clmulh", "clmulr"],
        "EXT-03": ["czero.eqz", "czero.nez"],
        "EXT-04": ["aes32esi", "aes32esmi", "aes32dsi", "aes32dsmi", "sha256sum0", "sha256sum1", "sha256sig0", "sha256sig1",
                   "sha512sum0r", "sha512sum1r", "sha512sig0l", "sha512sig0h", "sha512sig1l", "sha512sig1h", "pack", "packh",
                   "brev8", "zip", "unzip", "xperm4", "xperm8"],
        "EXT-05": ["c.zext.b", "c.sext.b", "c.zext.h", "c.sext.h", "c.not", "c.mul"],
    }
    unary = {"clz", "ctz", "cpop", "sext.b", "sext.h", "zext.h", "orc.b", "rev8", "sha256sum0", "sha256sum1", "sha256sig0", "sha256sig1", "brev8", "zip", "unzip"}
    immop = {"rori", "bclri", "bexti", "binvi", "bseti"}
    expect = {}
    ninsn = {}
    for blk, ops in blocks.items():
        p.asm(0, "csrr s3, minstret")
        n = 0
        for i, op in enumerate(ops):
            a = edge[i % 5] if i % 2 == 0 else rng.getrandbits(32)
            b = rng.getrandbits(32) if i % 3 else edge[(i + 2) % 5]
            imm = rng.randrange(4) if op.startswith("aes32") else rng.randrange(32)
            p.asm(0, "li s0, 0x%x" % a, "li s1, 0x%x" % b)
            n += (1 if -2048 <= a <= 2047 else (1 if a & 0xFFF == 0 else 2)) + (1 if -2048 <= b <= 2047 else (1 if b & 0xFFF == 0 else 2))
            if op.startswith("c."):
                ref = {"c.zext.b": "zext.b", "c.sext.b": "sext.b", "c.zext.h": "zext.h", "c.sext.h": "sext.h", "c.not": "not", "c.mul": "mul"}[op]
                p.asm(0, "%s s0, s1" % op if op == "c.mul" else "%s s0" % op, "mv a0, s0")
                val = K.isa_op(ref, a, b)
                n += 2
            elif op.startswith("aes32"):
                p.asm(0, "%s a0, s0, s1, %d" % (op, imm)); val = K.isa_op(op, a, b, imm); n += 1
            elif op in unary:
                p.asm(0, "%s a0, s0" % op); val = K.isa_op(op, a); n += 1
            elif op in immop:
                p.asm(0, "%s a0, s0, %d" % (op, imm)); val = K.isa_op(op, a, 0, imm); n += 1
            else:
                p.asm(0, "%s a0, s0, s1" % op); val = K.isa_op(op, a, b); n += 1
            p.store_slot(0, "a0", "%s_%d" % (blk, i)); n += 1
            expect.setdefault(blk, {})[str(SLOT(p, 0, "%s_%d" % (blk, i)))] = val
        p.asm(0, "csrr s4, minstret", "sub s4, s4, s3")
        p.store_slot(0, "s4", "dret_%s" % blk)
        ninsn[blk] = n + 1
    p.end(0); p.end(1)
    for blk in ("EXT-01", "EXT-02", "EXT-03", "EXT-04", "EXT-05"):
        p.check("CK-%s" % blk, REQS["CK-%s" % blk], "slots", values=expect[blk])
    p.check("CK-EXT-06", REQS["CK-EXT-06"], "slots", values={str(SLOT(p, 0, "dret_%s" % b)): ninsn[b] for b in ("EXT-02", "EXT-03")})
