"""Per-output numerical reference for BF16/FP16 OP-001 GEMM."""

from tcop_fp_reference import FLOAT16_FORMATS, FP32, NaNResult, add_fp32, decode, encode, fma_fp32


class _NonFiniteResult(Exception):
    """A GEMM input or intermediate is infinite."""


def _widen_finite(inputs, shape):
    result = []
    seen_nan = False
    for bits in inputs:
        if type(bits) is not int or not 0 <= bits < 1 << 16:
            raise ValueError("expected a 16-bit storage encoding")
        try:
            sign, magnitude = decode(bits, shape)
        except NaNResult:
            seen_nan = True
            continue
        if magnitude is None:
            raise _NonFiniteResult
        result.append(encode(sign, magnitude, FP32))
    if seen_nan:
        raise NaNResult
    return result


def _decode_finite(bits, shape):
    sign, magnitude = decode(bits, shape)
    if magnitude is None:
        raise _NonFiniteResult
    return sign, magnitude


def fp_gemm_dot(a, b, precision, *, initial_c=None, bias=None, residual=None):
    """Return (output bits or None, status symbol) for one logical output.

    a and b provide unsigned input encodings in increasing logical K order.
    Optional addends hold unsigned encodings in command precision. This model
    stops at a bad numerical stage. The command monitor resolves faults from
    all in-flight lanes and DMA under DEC-012.
    """
    if precision not in FLOAT16_FORMATS or not len(a) or len(a) != len(b):
        raise ValueError("invalid GEMM precision or K extent")
    shape = FLOAT16_FORMATS[precision]
    accumulator = 0
    try:
        for left, right in zip(a, b):
            x, y = _widen_finite((left, right), shape)
            accumulator = fma_fp32(x, y, accumulator)
            _decode_finite(accumulator, FP32)
        for addend in (initial_c, bias, residual):
            if addend is not None:
                widened, = _widen_finite((addend,), shape)
                accumulator = add_fp32(accumulator, widened)
                _decode_finite(accumulator, FP32)
        output = encode(*decode(accumulator, FP32), shape)
        _decode_finite(output, shape)
        return output, "TC_STATUS_OK"
    except NaNResult:
        return None, "TC_ERR_NUMERIC_NAN"
    except _NonFiniteResult:
        return None, "TC_ERR_NUMERIC_NONFINITE"
