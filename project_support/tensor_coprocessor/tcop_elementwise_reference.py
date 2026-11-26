"""Per-element numerical reference for OP-002."""

from fractions import Fraction

from tcop_exp_candidate import centered_exp_bits
from tcop_fp_reference import FLOAT16_FORMATS, FP32, NaNResult, add_fp32, decode, encode, fma_fp32
from tcop_reciprocal_candidate import reciprocal_bits
from tcop_requant_reference import Requant8, lookup_int8_lut


_ADD_MODES = ("add", "bias_add", "residual_add")
_SIGN = 0x80000000
_ONE = 0x3F800000
_TWO = 0x40000000
_TEN = 0x41200000


def int8_elementwise(mode, x, *, rhs=None, activation="none",
                     scale_q16_16=None, lut=None, swiglu_coeff=None):
    """Return signed INT8 output after the selected elementwise operation.

    Use the corresponding RHS element or the last-axis bias value. Pass
    None for disabled scalar coefficients and unused LUTs. Byte-level
    descriptor validation, broadcast indexing and DMA faults are separate.
    """
    if mode not in (*_ADD_MODES, "scale", "act_only", "swiglu"):
        raise ValueError("invalid OP-002 mode")
    if activation not in ("none", "relu", "lut8"):
        raise ValueError("invalid INT8 activation")
    if type(x) is not int or not -128 <= x <= 127:
        raise ValueError("x must be signed INT8")
    if mode in (*_ADD_MODES, "swiglu"):
        if type(rhs) is not int or not -128 <= rhs <= 127:
            raise ValueError("selected mode requires a signed INT8 RHS")
    elif rhs is not None:
        raise ValueError("unary mode does not use an RHS")

    if (scale_q16_16 is not None) != (mode == "scale"):
        raise ValueError("scale_q16_16 is required only for SCALE")
    if (swiglu_coeff is not None) != (mode == "swiglu"):
        raise ValueError("a requantization coefficient is required only for SwiGLU")
    if lut is not None and activation != "lut8" and mode != "swiglu":
        raise ValueError("unused LUT")

    if mode == "swiglu":
        if activation != "none" or not isinstance(swiglu_coeff, Requant8):
            raise ValueError("SwiGLU needs its own LUT and coefficient and has no extra activation")
        return swiglu_coeff.requantize(lookup_int8_lut(x, lut) * rhs)

    if mode in _ADD_MODES:
        value = x + rhs
    elif mode == "scale":
        if type(scale_q16_16) is not int or not -(1 << 31) <= scale_q16_16 < 1 << 31:
            raise ValueError("scale_q16_16 must be a signed 32-bit value")
        value = round(Fraction(x * scale_q16_16, 1 << 16))
    else:
        if activation == "none":
            raise ValueError("ACT_ONLY requires an activation")
        value = x

    q = min(127, max(-128, value))
    if activation == "relu":
        return max(q, 0)
    if activation == "lut8":
        return lookup_int8_lut(q, lut)
    return q


def _mul_fp32(a, b):
    return fma_fp32(a, b, (a ^ b) & _SIGN)


def _activate_fp32(x, activation):
    """Candidate nonlinear lane using only nonpositive exp arguments."""
    negative = bool(x & _SIGN)
    magnitude = x & ~_SIGN
    if activation == "none":
        return x
    if activation == "relu":
        return 0 if negative and magnitude else x
    if magnitude > _TEN:
        return _SIGN if negative else x

    if activation == "gelu_tanh":
        # Evaluate 2*abs(t) for t = 0.7978845608*(x + 0.044715*x**3).
        square = _mul_fp32(magnitude, magnitude)
        cube = _mul_fp32(square, magnitude)
        t = _mul_fp32(0x3F4C422A, add_fp32(magnitude, _mul_fp32(0x3D372713, cube)))
        exp_argument = _mul_fp32(_TWO, t)
    else:
        exp_argument = magnitude

    e = centered_exp_bits(exp_argument | _SIGN)
    reciprocal = reciprocal_bits(add_fp32(_ONE, e))
    scaled = _mul_fp32(x, e) if negative else x
    return _mul_fp32(scaled, reciprocal)


def fp_elementwise(mode, x, precision, *, rhs=None, activation="none", scale=None):
    """Return one unsigned BF16/FP16 OP-002 storage encoding.

    Bias callers supply the corresponding last-axis element as rhs. SCALE
    takes a finite FP32 bit pattern. Descriptor and DMA checks are separate.
    GELU and SiLU use candidate exp and reciprocal arithmetic.
    """
    if precision not in FLOAT16_FORMATS or mode not in (*_ADD_MODES, "scale", "act_only", "swiglu"):
        raise ValueError("invalid floating-point OP-002 precision or mode")
    if activation not in ("none", "relu", "gelu_tanh", "silu"):
        raise ValueError("invalid floating-point OP-002 activation")
    if (mode == "act_only" and activation == "none") or (mode == "swiglu" and activation != "none"):
        raise ValueError("activation conflicts with selected mode")
    if (rhs is not None) != (mode in (*_ADD_MODES, "swiglu")):
        raise ValueError("selected mode does not match RHS presence")
    if (scale is not None) != (mode == "scale"):
        raise ValueError("scale is required only for SCALE")
    if scale is not None and (type(scale) is not int or not 0 <= scale <= 0xFFFFFFFF
                              or (scale & 0x7FFFFFFF) >= 0x7F800000):
        raise ValueError("scale must be a finite FP32 encoding")

    shape = FLOAT16_FORMATS[precision]

    def widen(bits):
        if type(bits) is not int or not 0 <= bits <= 0xFFFF:
            raise ValueError("operands must use unsigned 16-bit encodings")
        return encode(*decode(bits, shape), FP32)

    try:
        value = widen(x)
        if mode == "swiglu":
            value = _mul_fp32(_activate_fp32(value, "silu"), widen(rhs))
        else:
            if mode in _ADD_MODES:
                value = add_fp32(value, widen(rhs))
            elif mode == "scale":
                value = _mul_fp32(value, scale)
            value = _activate_fp32(value, activation)
        return encode(*decode(value, FP32), shape)
    except NaNResult:
        return 0x7FC0 if precision == "bf16" else 0x7E00
