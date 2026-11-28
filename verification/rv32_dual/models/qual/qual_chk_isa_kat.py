# AI-GENERATED (Claude Opus 5.5, 2026-11-27) - candidate; human review pending.
"""Qualification of chk_isa_kat (plan 5.6)."""
import random
from qual_common import Suite
import chk_isa_kat as K

SOURCES = ["chk_isa_kat.py", "qual/qual_chk_isa_kat.py"]
KIND = "model"


def run():
    s = Suite()
    # FIPS 197 S-box known answers
    for x, y in [(0x00, 0x63), (0x01, 0x7C), (0x53, 0xED), (0xFF, 0x16), (0x10, 0xCA)]:
        s.eq("known_answer", "FIPS-197 S-box[0x%02x]" % x, y, K.SBOX[x])
    s.eq("known_answer", "FIPS-197 inverse S-box[0x63]", 0x00, K.INV_SBOX[0x63])
    s.eq("known_answer", "FIPS-197 xtime: {57}*{83} = {c1}", 0xC1, K.gmul(0x57, 0x83))
    kat = [
        ("aes32esi", 0, 0x00000053, 0, 0x000000ED), ("aes32esi", 0x11111111, 0x53000000, 3, 0xFC111111),
        ("aes32esmi", 0, 0, 0, 0xA56363C6), ("aes32dsi", 0, 0x00000063, 0, 0), ("aes32dsmi", 0, 0x00000063, 0, 0), ("aes32dsi", 0, 0x00000000, 0, 0x52),
        ("clz", 0, 0, 0, 32), ("clz", 1, 0, 0, 31), ("ctz", 0x80000000, 0, 0, 31), ("ctz", 0, 0, 0, 32),
        ("cpop", 0xFFFFFFFF, 0, 0, 32), ("rev8", 0x11223344, 0, 0, 0x44332211), ("orc.b", 0x00100001, 0, 0, 0x00FF00FF),
        ("sext.b", 0x80, 0, 0, 0xFFFFFF80), ("sext.h", 0x7FFF, 0, 0, 0x7FFF), ("zext.h", 0xFFFF8000, 0, 0, 0x8000),
        ("rol", 0x80000001, 1, 0, 0x00000003), ("ror", 0x00000003, 1, 0, 0x80000001), ("rori", 0x12345678, 0, 8, 0x78123456),
        ("max", 0xFFFFFFFF, 1, 0, 1), ("maxu", 0xFFFFFFFF, 1, 0, 0xFFFFFFFF), ("min", 0xFFFFFFFF, 1, 0, 0xFFFFFFFF),
        ("minu", 0xFFFFFFFF, 1, 0, 1), ("andn", 0xFF, 0x0F, 0, 0xF0), ("orn", 0, 0xFFFFFFF0, 0, 0xF), ("xnor", 0xF0F0F0F0, 0xFFFF0000, 0, 0xF0F00F0F),
        ("sh1add", 3, 1, 0, 7), ("sh2add", 3, 1, 0, 13), ("sh3add", 3, 1, 0, 25),
        ("clmul", 3, 3, 0, 5), ("clmulh", 0x80000000, 2, 0, 1), ("clmul", 0x80000000, 2, 0, 0), ("clmulr", 0x80000000, 1, 0, 1),
        ("bset", 0, 31, 0, 0x80000000), ("bclr", 0xFFFFFFFF, 0, 0, 0xFFFFFFFE), ("binv", 1, 0, 0, 0), ("bext", 0x10, 4, 0, 1),
        ("bseti", 0, 0, 5, 0x20), ("bclri", 0x20, 0, 5, 0), ("binvi", 0, 0, 31, 0x80000000), ("bexti", 0x80000000, 0, 31, 1),
        ("pack", 0x1234ABCD, 0x5678EF01, 0, 0xEF01ABCD), ("packh", 0x1234ABCD, 0x5678EF01, 0, 0x01CD),
        ("brev8", 0x01020380, 0, 0, 0x8040C001), ("zip", 0x0000FFFF, 0, 0, 0x55555555), ("unzip", 0x55555555, 0, 0, 0x0000FFFF),
        ("xperm8", 0x44332211, 0x00010203, 0, 0x11223344), ("xperm8", 0x44332211, 0x04040404, 0, 0),
        ("xperm4", 0x76543210, 0x01234567, 0, 0x01234567),
        ("czero.eqz", 5, 0, 0, 0), ("czero.eqz", 5, 1, 0, 5), ("czero.nez", 5, 1, 0, 0), ("czero.nez", 5, 0, 0, 5),
        ("div", 7, 0, 0, 0xFFFFFFFF), ("div", 0x80000000, 0xFFFFFFFF, 0, 0x80000000), ("div", 0xFFFFFFF9, 2, 0, 0xFFFFFFFD),
        ("rem", 0x80000000, 0xFFFFFFFF, 0, 0), ("rem", 0xFFFFFFF9, 2, 0, 0xFFFFFFFF), ("rem", 7, 0, 0, 7),
        ("divu", 7, 0, 0, 0xFFFFFFFF), ("remu", 7, 0, 0, 7), ("mulh", 0xFFFFFFFF, 0xFFFFFFFF, 0, 0),
        ("mulhu", 0xFFFFFFFF, 0xFFFFFFFF, 0, 0xFFFFFFFE), ("mulhsu", 0xFFFFFFFF, 0xFFFFFFFF, 0, 0xFFFFFFFF),
        ("sha256sig0", 0x80000000, 0, 0, K.ror(0x80000000, 7) ^ K.ror(0x80000000, 18) ^ 0x10000000),
    ]
    for op, a, b, imm, exp in kat:
        s.eq("known_answer", "%s(0x%x,0x%x,%d)" % (op, a, b, imm), exp, K.isa_op(op, a, b, imm))
    # boundary: RV32 sha512 half-instructions against the FIPS 180-4 64-bit functions (independent derivation)
    rng = random.Random(7)
    bad = 0
    xs = [0, (1 << 64) - 1, 1, 1 << 63, 0x0123456789ABCDEF] + [rng.getrandbits(64) for _ in range(500)]
    for x in xs:
        lo, hi = x & 0xFFFFFFFF, x >> 32
        for fn, lo_op, hi_op in [("sum0", "sha512sum0r", "sha512sum0r"), ("sum1", "sha512sum1r", "sha512sum1r"),
                                 ("sig0", "sha512sig0l", "sha512sig0h"), ("sig1", "sha512sig1l", "sha512sig1h")]:
            ref = K.sha512_ref(fn, x)
            got = K.isa_op(lo_op, lo, hi) | (K.isa_op(hi_op, hi, lo) << 32)
            bad += int(got != ref)
    s.eq("boundary", "sha512 RV32 halves vs FIPS 180-4 64-bit Sigma/sigma, %d values x 4 functions" % len(xs), 0, bad)
    bad = sum(int(K.unzip32(K.zip32(v)) != v) for v in [rng.getrandbits(32) for _ in range(200)] + [0, 0xFFFFFFFF])
    s.eq("boundary", "unzip(zip(x)) == x over 202 values", 0, bad)
    bad = sum(int(K.INV_SBOX[K.SBOX[v]] != v) for v in range(256))
    s.eq("boundary", "inverse S-box inverts S-box for all 256 bytes", 0, bad)
    bad = sum(int(K.aes32("aes32dsi", 0, K.aes32("aes32esi", 0, v, 0), 0) != v) for v in range(256))
    s.eq("boundary", "aes32dsi(aes32esi(x)) == x for all bytes, bs=0", 0, bad)
    s.eq("boundary", "rori by 0 is identity", 0xDEADBEEF, K.isa_op("rori", 0xDEADBEEF, 0, 0))
    s.eq("boundary", "sll uses rs2[4:0] only", 2, K.isa_op("sll", 1, 33))
    s.raises("negative", "unsupported op 'addw' (RV64-only)", lambda: K.isa_op("addw", 1, 2), ValueError)
    s.raises("negative", "aes32 bs=4", lambda: K.isa_op("aes32esi", 0, 0, 4), ValueError)
    s.raises("negative", "rori shamt 32", lambda: K.isa_op("rori", 0, 0, 32), ValueError)
    s.not_applicable("reset", "stateless functional model")
    good = {"op": "clmul", "rs1": "0x3", "rs2": "0x3", "rd": "0x5"}
    s.eq("known_answer", "control for fault injection: correct record has no error", [], K.check_record(good))
    for name, rec in [("clmul result bit flip", dict(good, rd="0x4")),
                      ("rev8 byte order not reversed", {"op": "rev8", "rs1": "0x11223344", "rd": "0x11223344"}),
                      ("aes32esmi without MixColumn", {"op": "aes32esmi", "rs1": "0", "rs2": "0", "imm": 0, "rd": "0x63"}),
                      ("div by zero returns 0", {"op": "div", "rs1": "7", "rs2": "0", "rd": "0"}),
                      ("sha512sig0h computed as sig0l", {"op": "sha512sig0h", "rs1": "0x1", "rs2": "0x1",
                                                         "rd": hex(K.isa_op("sha512sig0l", 1, 1))}),
                      ("czero.eqz inverted", {"op": "czero.eqz", "rs1": "5", "rs2": "0", "rd": "5"})]:
        s.detected(name, K.check_record(rec))
    return s
