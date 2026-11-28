#!/usr/bin/env python3
# -----------------------------------------------------------------------------
# AI-GENERATED (Claude Opus 5.5, 2026-11-27) - candidate artifact (R-117, R-231).
# Sources: IEEE 754-2008 binary32 arithmetic; RISC-V Unprivileged ISA chapter
# 'F Standard Extension' (fflags NV/DZ/OF/UF/NX, rounding modes, canonical NaN
# 0x7fc00000, tininess after rounding, FMIN/FMAX, FCVT saturation, FCLASS);
# RV32 HDS rev 0.4 Section 14.5 (FDIV.S/FSQRT.S known answers). No RTL used.
# Human review: pending.
# -----------------------------------------------------------------------------
"""chk_fp_model - exact rational IEEE 754 binary32 model for RV32F (plan 5.2).

Every result is computed with fractions.Fraction (exact), then rounded once.
API: fp_op(op, a, b=None, c=None, rm='rne') -> (result_bits, fflags)
     check_record(rec) -> list of mismatch strings (NDJSON record type 'fp').
fflags bit order: NV=4 DZ=3 OF=2 UF=1 NX=0.
"""
from fractions import Fraction
import math

NV, DZ, OF, UF, NX = 16, 8, 4, 2, 1
CANON_NAN = 0x7FC00000
RMS = ("rne", "rtz", "rdn", "rup", "rmm")
EMIN, BIAS, MANT = -126, 127, 23


def fields(b):
    return (b >> 31) & 1, (b >> 23) & 0xFF, b & 0x7FFFFF


def is_nan(b):
    s, e, m = fields(b)
    return e == 0xFF and m != 0


def is_snan(b):
    return is_nan(b) and not (b >> 22) & 1


def is_inf(b):
    return (b & 0x7FFFFFFF) == 0x7F800000


def is_zero(b):
    return (b & 0x7FFFFFFF) == 0


def to_frac(b):
    """Finite binary32 -> Fraction (signed zero returns 0; use sign separately)."""
    s, e, m = fields(b)
    if e == 0:
        v = Fraction(m, 1 << (MANT - EMIN))          # m * 2^(-149)
    else:
        v = Fraction((1 << MANT) | m) * (Fraction(2) ** (e - BIAS - MANT))
    return -v if s else v


def _round_int(q, rem_half, sticky, sign, rm):
    """Round integer significand q given the remainder classification.
    rem_half: -1 below half, 0 exactly half, +1 above half (when inexact)."""
    inexact = rem_half is not None
    if not inexact:
        return q, False
    if rm == "rne":
        up = rem_half > 0 or (rem_half == 0 and (q & 1))
    elif rm == "rmm":
        up = rem_half >= 0
    elif rm == "rtz":
        up = False
    elif rm == "rdn":
        up = sign == 1
    else:  # rup
        up = sign == 0
    return q + (1 if up else 0), True


def _classify(frac_part, sticky):
    """frac_part: Fraction in [0,1); sticky: extra positive amount beyond frac_part."""
    if frac_part == 0 and not sticky:
        return None
    if frac_part < Fraction(1, 2):
        return -1
    if frac_part == Fraction(1, 2):
        return 1 if sticky else 0
    return 1


def round_value(sign, mag, rm, sticky=False):
    """Round |x| = mag (+ an infinitesimal positive amount when sticky) to binary32.
    Returns (bits, flags). mag must be > 0 or (mag == 0 and sticky False -> zero)."""
    if mag == 0 and not sticky:
        return sign << 31, 0
    # exponent of the leading bit (unbounded)
    e = math.floor(math.log2(mag)) if mag > 0 else EMIN - 200
    while Fraction(2) ** e > mag:
        e -= 1
    while Fraction(2) ** (e + 1) <= mag:
        e += 1
    # unbounded-exponent rounding (for tininess after rounding and overflow)
    scale = Fraction(2) ** (MANT - e)
    s = mag * scale
    q = s.numerator // s.denominator
    q_u, inexact_u = _round_int(q, _classify(s - q, sticky), sticky, sign, rm)
    e_u = e
    if q_u == 1 << (MANT + 1):
        q_u >>= 1
        e_u += 1
    if e_u > 127:
        flags = OF | NX
        to_inf = rm in ("rne", "rmm") or (rm == "rup" and sign == 0) or (rm == "rdn" and sign == 1)
        return ((sign << 31) | (0x7F800000 if to_inf else 0x7F7FFFFF)), flags
    tiny = e_u < EMIN
    if e >= EMIN:
        bits = (sign << 31) | ((e_u + BIAS) << MANT) | (q_u & 0x7FFFFF)
        return bits, (NX if inexact_u else 0)
    # subnormal/zero: quantum 2^-149
    s2 = mag * (Fraction(2) ** (MANT - EMIN))
    q2 = s2.numerator // s2.denominator
    q2r, inexact = _round_int(q2, _classify(s2 - q2, sticky), sticky, sign, rm)
    flags = NX if inexact else 0
    if tiny and inexact:
        flags |= UF
    if q2r == 1 << MANT:             # rounded up into the smallest normal
        return (sign << 31) | (1 << MANT), flags
    return (sign << 31) | q2r, flags


def _nan_result(*ops):
    fl = NV if any(is_snan(x) for x in ops if x is not None) else 0
    return CANON_NAN, fl


def _isqrt_frac(x):
    """Return (lower, exact) with lower <= sqrt(x) at 2^-(K) resolution, x Fraction >= 0."""
    K = 160
    n = x.numerator * (1 << (2 * K))
    d = x.denominator
    # sqrt(n/d) = sqrt(n*d)/d
    t = n * d
    r = math.isqrt(t)
    exact = r * r == t
    return Fraction(r, d * (1 << K)), exact


def fp_op(op, a, b=None, c=None, rm="rne"):
    if rm not in RMS:
        raise ValueError("bad rounding mode %r" % rm)
    a = None if a is None else a & 0xFFFFFFFF
    b = None if b is None else b & 0xFFFFFFFF
    c = None if c is None else c & 0xFFFFFFFF
    if op in ("fadd.s", "fsub.s"):
        if op == "fsub.s":
            b2 = b ^ 0x80000000 if not is_nan(b) else b
        else:
            b2 = b
        if is_nan(a) or is_nan(b):
            return _nan_result(a, b)
        if is_inf(a) or is_inf(b2):
            if is_inf(a) and is_inf(b2) and (a >> 31) != (b2 >> 31):
                return CANON_NAN, NV
            return (a if is_inf(a) else b2), 0
        return _add(a, b2, rm)
    if op == "fmul.s":
        if is_nan(a) or is_nan(b):
            return _nan_result(a, b)
        sign = ((a ^ b) >> 31) & 1
        if (is_inf(a) and is_zero(b)) or (is_zero(a) and is_inf(b)):
            return CANON_NAN, NV
        if is_inf(a) or is_inf(b):
            return (sign << 31) | 0x7F800000, 0
        return round_value(sign, abs(to_frac(a) * to_frac(b)), rm)
    if op == "fdiv.s":
        if is_nan(a) or is_nan(b):
            return _nan_result(a, b)
        sign = ((a ^ b) >> 31) & 1
        if (is_inf(a) and is_inf(b)) or (is_zero(a) and is_zero(b)):
            return CANON_NAN, NV
        if is_inf(a):
            return (sign << 31) | 0x7F800000, 0
        if is_inf(b):
            return sign << 31, 0
        if is_zero(b):
            return (sign << 31) | 0x7F800000, DZ
        return round_value(sign, abs(to_frac(a) / to_frac(b)), rm)
    if op == "fsqrt.s":
        if is_nan(a):
            return _nan_result(a)
        if is_zero(a):
            return a, 0
        if a >> 31:
            return CANON_NAN, NV
        if is_inf(a):
            return a, 0
        low, exact = _isqrt_frac(to_frac(a))
        return round_value(0, low, rm, sticky=not exact)
    if op in ("fmadd.s", "fmsub.s", "fnmsub.s", "fnmadd.s"):
        return _fma(op, a, b, c, rm)
    if op in ("fmin.s", "fmax.s"):
        fl = NV if (is_snan(a) or is_snan(b)) else 0
        if is_nan(a) and is_nan(b):
            return CANON_NAN, fl
        if is_nan(a):
            return b, fl
        if is_nan(b):
            return a, fl
        if is_zero(a) and is_zero(b):
            neg = (a >> 31) | (b >> 31) if op == "fmin.s" else (a >> 31) & (b >> 31)
            return (neg << 31), fl
        va, vb = _val(a), _val(b)
        pick_a = (va < vb) if op == "fmin.s" else (va > vb)
        return (a if pick_a else b), fl
    if op in ("feq.s", "flt.s", "fle.s"):
        if is_nan(a) or is_nan(b):
            if op == "feq.s":
                return 0, (NV if (is_snan(a) or is_snan(b)) else 0)
            return 0, NV
        va, vb = _val(a), _val(b)
        return int({"feq.s": va == vb, "flt.s": va < vb, "fle.s": va <= vb}[op]), 0
    if op in ("fcvt.w.s", "fcvt.wu.s"):
        return _cvt_to_int(a, op == "fcvt.wu.s", rm)
    if op in ("fcvt.s.w", "fcvt.s.wu"):
        v = a if op == "fcvt.s.wu" else (a - (1 << 32) if a & 0x80000000 else a)
        if v == 0:
            return 0, 0
        return round_value(1 if v < 0 else 0, Fraction(abs(v)), rm)
    if op in ("fsgnj.s", "fsgnjn.s", "fsgnjx.s"):
        sb = (b >> 31) & 1
        s = {"fsgnj.s": sb, "fsgnjn.s": sb ^ 1, "fsgnjx.s": sb ^ ((a >> 31) & 1)}[op]
        return (a & 0x7FFFFFFF) | (s << 31), 0
    if op == "fclass.s":
        return fclass(a), 0
    raise ValueError("unsupported op %r" % op)


def _val(b):
    """Comparable value (inf as +-inf float-free via large Fraction)."""
    if is_inf(b):
        return Fraction(-(1 << 200)) if b >> 31 else Fraction(1 << 200)
    return to_frac(b)


def _add(a, b, rm):
    va, vb = to_frac(a), to_frac(b)
    s = va + vb
    if s == 0:
        if is_zero(a) and is_zero(b) and (a >> 31) and (b >> 31):
            return 0x80000000, 0
        # exact zero sum of nonzero opposites or mixed zeros: +0 except RDN gives -0
        return (0x80000000 if rm == "rdn" else 0), 0
    return round_value(1 if s < 0 else 0, abs(s), rm)


def _fma(op, a, b, c, rm):
    if is_nan(a) or is_nan(b) or is_nan(c):
        r, fl = _nan_result(a, b, c)
        if (is_inf(a) and is_zero(b)) or (is_zero(a) and is_inf(b)):
            fl |= NV
        return r, fl
    neg_prod = op in ("fnmsub.s", "fnmadd.s")
    neg_c = op in ("fmsub.s", "fnmadd.s")
    ps = (((a ^ b) >> 31) & 1) ^ int(neg_prod)
    cc = c ^ 0x80000000 if neg_c else c
    if (is_inf(a) and is_zero(b)) or (is_zero(a) and is_inf(b)):
        return CANON_NAN, NV
    if is_inf(a) or is_inf(b):
        if is_inf(cc) and (cc >> 31) != ps:
            return CANON_NAN, NV
        return (ps << 31) | 0x7F800000, 0
    if is_inf(cc):
        return cc, 0
    prod = to_frac(a) * to_frac(b)
    if neg_prod:
        prod = -prod
    vc = to_frac(cc)
    s = prod + vc
    if s == 0:
        if prod == 0 and is_zero(cc) and ps == ((cc >> 31) & 1):
            return ps << 31, 0      # (+-0) + (+-0) of equal sign keeps the sign
        return (0x80000000 if rm == "rdn" else 0), 0
    return round_value(1 if s < 0 else 0, abs(s), rm)


def _cvt_to_int(a, unsigned, rm):
    lo, hi = (0, (1 << 32) - 1) if unsigned else (-(1 << 31), (1 << 31) - 1)
    if is_nan(a):
        return (hi & 0xFFFFFFFF), NV
    if is_inf(a):
        return ((lo if a >> 31 else hi) & 0xFFFFFFFF), NV
    v = to_frac(a)
    sign = 1 if v < 0 else 0
    mag = abs(v)
    q = mag.numerator // mag.denominator
    r, inexact = _round_int(q, _classify(mag - q, False), False, sign, rm)
    res = -r if sign else r
    if res < lo or res > hi:
        return ((lo if sign else hi) & 0xFFFFFFFF), NV
    return res & 0xFFFFFFFF, (NX if inexact else 0)


def fclass(b):
    s, e, m = fields(b)
    if e == 0xFF:
        if m == 0:
            return 1 << (0 if s else 7)
        return 1 << (9 if (m >> 22) & 1 else 8)
    if e == 0:
        if m == 0:
            return 1 << (3 if s else 4)
        return 1 << (2 if s else 5)
    return 1 << (1 if s else 6)


def check_record(rec):
    """NDJSON 'fp' record: {op, rm, a, b?, c?, result, fflags}; values hex strings or ints."""
    h = lambda k: None if rec.get(k) is None else (int(rec[k], 0) if isinstance(rec[k], str) else int(rec[k]))
    exp_r, exp_f = fp_op(rec["op"], h("a"), h("b"), h("c"), rec.get("rm", "rne"))
    errs = []
    if h("result") != exp_r:
        errs.append("%s result 0x%08x expected 0x%08x" % (rec["op"], h("result"), exp_r))
    if h("fflags") is not None and h("fflags") != exp_f:
        errs.append("%s fflags 0x%02x expected 0x%02x" % (rec["op"], h("fflags"), exp_f))
    return errs
