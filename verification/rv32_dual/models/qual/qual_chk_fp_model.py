# AI-GENERATED (Claude Opus 5.5, 2026-11-27) - candidate; human review pending.
"""Qualification of chk_fp_model (plan 5.6)."""
import random
import struct
from qual_common import Suite
import chk_fp_model as F

SOURCES = ["chk_fp_model.py", "qual/qual_chk_fp_model.py"]
KIND = "model"
NV, DZ, OF, UF, NX = F.NV, F.DZ, F.OF, F.UF, F.NX


def f2b(x):
    return struct.unpack("<I", struct.pack("<f", x))[0]


def b2f(b):
    return struct.unpack("<f", struct.pack("<I", b))[0]


def run():
    s = Suite()
    kat = [  # (op, a, b, c, rm, result, flags, source)
        ("fdiv.s", f2b(7.0), f2b(2.0), None, "rne", 0x40600000, 0, "RV32 HDS 14.5 FDIV.S 7.0/2.0"),
        ("fadd.s", f2b(1.0), f2b(2.0), None, "rne", 0x40400000, 0, "IEEE exact sum"),
        ("fadd.s", 0x3DCCCCCD, 0x3E4CCCCD, None, "rne", 0x3E99999A, NX, "0.1f+0.2f"),
        ("fsqrt.s", f2b(4.0), None, None, "rne", 0x40000000, 0, "exact sqrt"),
        ("fsqrt.s", f2b(2.0), None, None, "rne", 0x3FB504F3, NX, "sqrt(2) RNE"),
        ("fdiv.s", f2b(1.0), f2b(3.0), None, "rne", 0x3EAAAAAB, NX, "1/3 RNE"),
        ("fdiv.s", f2b(1.0), f2b(3.0), None, "rtz", 0x3EAAAAAA, NX, "1/3 RTZ"),
        ("fdiv.s", f2b(1.0), f2b(3.0), None, "rup", 0x3EAAAAAB, NX, "1/3 RUP"),
        ("fdiv.s", f2b(-1.0), f2b(3.0), None, "rdn", 0xBEAAAAAB, NX, "-1/3 RDN"),
        ("fdiv.s", 0, 0, None, "rne", F.CANON_NAN, NV, "0/0 -> canonical NaN, NV (RV32 HDS 14.5)"),
        ("fdiv.s", f2b(1.0), 0, None, "rne", 0x7F800000, DZ, "1/0 -> +inf, DZ"),
        ("fdiv.s", f2b(1.0), 0x80000000, None, "rne", 0xFF800000, DZ, "1/-0 -> -inf, DZ"),
        ("fsqrt.s", f2b(-1.0), None, None, "rne", F.CANON_NAN, NV, "sqrt(-1) -> canonical NaN, NV"),
        ("fsqrt.s", 0x80000000, None, None, "rne", 0x80000000, 0, "sqrt(-0) = -0"),
        ("fmul.s", 0x7F7FFFFF, f2b(2.0), None, "rne", 0x7F800000, OF | NX, "overflow RNE -> inf"),
        ("fmul.s", 0x7F7FFFFF, f2b(2.0), None, "rtz", 0x7F7FFFFF, OF | NX, "overflow RTZ -> max finite"),
        ("fmul.s", 0x00800000, f2b(0.5), None, "rne", 0x00400000, 0, "exact subnormal: no UF"),
        ("fmul.s", 0x00800001, f2b(0.5), None, "rne", 0x00400000, UF | NX, "inexact tiny: UF|NX (tie to even)"),
        ("fmul.s", 0x00000001, f2b(0.5), None, "rne", 0x00000000, UF | NX, "min subnormal/2 -> +0 (tie to even)"),
        ("fmul.s", 0x00000001, f2b(0.5), None, "rup", 0x00000001, UF | NX, "min subnormal/2 RUP -> min subnormal"),
        ("fadd.s", f2b(1.0), f2b(-1.0), None, "rne", 0x00000000, 0, "x + -x = +0"),
        ("fadd.s", f2b(1.0), f2b(-1.0), None, "rdn", 0x80000000, 0, "x + -x = -0 in RDN"),
        ("fadd.s", 0x7F800000, 0xFF800000, None, "rne", F.CANON_NAN, NV, "inf - inf"),
        ("fmadd.s", f2b(2.0), f2b(3.0), f2b(1.0), "rne", f2b(7.0), 0, "fmadd exact"),
        ("fmsub.s", f2b(2.0), f2b(3.0), f2b(1.0), "rne", f2b(5.0), 0, "fmsub"),
        ("fnmadd.s", f2b(2.0), f2b(3.0), f2b(1.0), "rne", f2b(-7.0), 0, "fnmadd = -(a*b)-c"),
        ("fnmsub.s", f2b(2.0), f2b(3.0), f2b(1.0), "rne", f2b(-5.0), 0, "fnmsub = -(a*b)+c"),
        ("fmadd.s", 0x7F800000, 0, F.CANON_NAN, "rne", F.CANON_NAN, NV, "inf*0 + qNaN raises NV"),
        ("fcvt.w.s", f2b(3.75), None, None, "rtz", 3, NX, "FCVT.W.S 3.75 RTZ (RV32 HDS 15.5 note)"),
        ("fcvt.w.s", f2b(3.75), None, None, "rne", 4, NX, "FCVT.W.S 3.75 RNE"),
        ("fcvt.w.s", f2b(-2.5), None, None, "rne", 0xFFFFFFFE, NX, "-2.5 RNE -> -2"),
        ("fcvt.w.s", f2b(-2.5), None, None, "rmm", 0xFFFFFFFD, NX, "-2.5 RMM -> -3"),
        ("fcvt.w.s", F.CANON_NAN, None, None, "rne", 0x7FFFFFFF, NV, "NaN -> 2^31-1"),
        ("fcvt.w.s", 0x4F000000, None, None, "rne", 0x7FFFFFFF, NV, "2^31 saturates"),
        ("fcvt.w.s", 0xCF000000, None, None, "rne", 0x80000000, 0, "-2^31 exact"),
        ("fcvt.wu.s", f2b(-1.0), None, None, "rne", 0, NV, "-1.0 to unsigned -> 0, NV"),
        ("fcvt.wu.s", f2b(-0.25), None, None, "rtz", 0, NX, "-0.25 RTZ unsigned -> 0, NX only"),
        ("fcvt.s.w", 0xFFFFFFFF, None, None, "rne", f2b(-1.0), 0, "int -1 -> -1.0"),
        ("fcvt.s.wu", 0xFFFFFFFF, None, None, "rne", 0x4F800000, NX, "2^32-1 -> 2^32 RNE"),
        ("fcvt.s.wu", 0xFFFFFFFF, None, None, "rtz", 0x4F7FFFFF, NX, "2^32-1 RTZ"),
        ("fmin.s", 0x80000000, 0x00000000, None, "rne", 0x80000000, 0, "fmin(-0,+0) = -0"),
        ("fmax.s", 0x80000000, 0x00000000, None, "rne", 0x00000000, 0, "fmax(-0,+0) = +0"),
        ("fmax.s", F.CANON_NAN, f2b(1.0), None, "rne", f2b(1.0), 0, "fmax(qNaN,1) = 1, no flag"),
        ("fmin.s", 0x7F800001, f2b(1.0), None, "rne", f2b(1.0), NV, "fmin(sNaN,1) = 1, NV"),
        ("fmin.s", F.CANON_NAN, 0x7FC12345, None, "rne", F.CANON_NAN, 0, "both NaN -> canonical"),
        ("feq.s", F.CANON_NAN, f2b(1.0), None, "rne", 0, 0, "feq qNaN no flag"),
        ("feq.s", 0x7F800001, f2b(1.0), None, "rne", 0, NV, "feq sNaN NV"),
        ("flt.s", F.CANON_NAN, f2b(1.0), None, "rne", 0, NV, "flt qNaN NV"),
        ("fle.s", 0x80000000, 0x00000000, None, "rne", 1, 0, "-0 <= +0"),
        ("flt.s", 0x80000000, 0x00000000, None, "rne", 0, 0, "-0 < +0 is false"),
        ("fsgnjn.s", f2b(1.0), f2b(1.0), None, "rne", f2b(-1.0), 0, "fneg"),
        ("fsgnjx.s", f2b(-2.0), f2b(-1.0), None, "rne", f2b(2.0), 0, "fsgnjx"),
    ]
    for op, a, b, c, rm, res, fl, src in kat:
        s.eq("known_answer", "%s %s %s" % (op, rm, src), (res, fl), F.fp_op(op, a, b, c, rm))
    for v, bit in [(0xFF800000, 0), (0xBF800000, 1), (0x80000001, 2), (0x80000000, 3), (0x00000000, 4),
                   (0x00000001, 5), (0x3F800000, 6), (0x7F800000, 7), (0x7F800001, 8), (0x7FC00000, 9)]:
        s.eq("known_answer", "fclass 0x%08x" % v, 1 << bit, F.fclass(v))
    # boundary: cross-check RNE add/mul against host IEEE binary32 (product/sum exact in double)
    rng = random.Random(20261127)
    special = [0x00000001, 0x007FFFFF, 0x00800000, 0x00800001, 0x3F800000, 0x3F7FFFFF, 0x7F7FFFFF, 0x33800000, 0x4B000000]
    mism, n = 0, 0
    for i in range(3000):
        a = rng.choice(special) if i % 4 == 0 else rng.getrandbits(32)
        b = rng.choice(special) if i % 5 == 0 else rng.getrandbits(32)
        a ^= rng.getrandbits(1) << 31
        b ^= rng.getrandbits(1) << 31
        if F.is_nan(a) or F.is_nan(b) or F.is_inf(a) or F.is_inf(b):
            continue
        for op in ("fmul.s", "fadd.s"):
            x = b2f(a) * b2f(b) if op == "fmul.s" else b2f(a) + b2f(b)
            if op == "fadd.s" and abs(((a >> 23) & 0xFF) - ((b >> 23) & 0xFF)) > 28:
                continue        # double sum may be inexact: skip to keep a single rounding
            try:
                host = f2b(x)
            except OverflowError:
                host = (0x7F800000 | (0x80000000 if x < 0 else 0))
            mine = F.fp_op(op, a, b, None, "rne")[0]
            if F.is_zero(host) and F.is_zero(mine):
                host = mine if (host ^ mine) == 0x80000000 and op == "fadd.s" and x == 0 else host
            n += 1
            mism += int(mine != host)
    s.eq("boundary", "host binary32 cross-check, RNE fmul/fadd, %d vectors incl. subnormal/overflow edges" % n, 0, mism)
    for (op, a, b, rm, res, fl) in [("fadd.s", 0x7F7FFFFF, 0x73800000, "rne", 0x7F800000, OF | NX),
                                    ("fadd.s", 0x7F7FFFFF, 0x73000000, "rne", 0x7F800000, OF | NX),
                                    ("fadd.s", 0x7F7FFFFF, 0x72800000, "rne", 0x7F7FFFFF, NX),
                                    ("fmul.s", 0x00800000, 0x3F7FFFFF, "rne", 0x00800000, UF | NX)]:
        s.eq("boundary", "%s 0x%08x,0x%08x %s" % (op, a, b, rm), (res, fl), F.fp_op(op, a, b, None, rm))
    s.raises("negative", "bad rounding mode", lambda: F.fp_op("fadd.s", 0, 0, rm="dyn"), ValueError)
    s.raises("negative", "unsupported op fadd.d", lambda: F.fp_op("fadd.d", 0, 0), ValueError)
    s.eq("negative", "sNaN operand to fadd -> canonical NaN, NV", (F.CANON_NAN, NV), F.fp_op("fadd.s", 0x7F800001, 0x3F800000))
    s.not_applicable("reset", "stateless functional model; fcsr state is held by the program and checked per record")
    good = {"op": "fdiv.s", "rm": "rne", "a": "0x40e00000", "b": "0x40000000", "result": "0x40600000", "fflags": "0x0"}
    s.eq("known_answer", "control for fault injection: correct record has no error", [], F.check_record(good))
    for name, patch in [("result LSB flipped", {"result": "0x40600001"}),
                        ("NX dropped on inexact 1/3", {"a": "0x3f800000", "b": "0x40400000", "result": "0x3eaaaaab", "fflags": "0x0"}),
                        ("NaN not canonical", {"a": "0x0", "b": "0x0", "result": "0x7fc00001", "fflags": "0x10"}),
                        ("DEC-106 class: divide returns canonical NaN", {"result": "0x7fc00000"}),
                        ("RTZ result reported for RNE", {"a": "0x3f800000", "b": "0x40400000", "result": "0x3eaaaaaa", "fflags": "0x1"}),
                        ("zero sign wrong", {"op": "fadd.s", "a": "0x3f800000", "b": "0xbf800000", "result": "0x80000000", "fflags": "0x0"}),
                        ("DZ missing on x/0", {"a": "0x3f800000", "b": "0x0", "result": "0x7f800000", "fflags": "0x0"})]:
        rec = dict(good)
        rec.update(patch)
        s.detected(name, F.check_record(rec))
    return s
