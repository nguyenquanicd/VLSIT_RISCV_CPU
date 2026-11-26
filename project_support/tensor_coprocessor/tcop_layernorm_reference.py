"""OP-007 fixed-tree row model using the candidate FP32 rsqrt function."""

from tcop_fp_reference import FLOAT16_FORMATS, FP32, NaNResult, add_fp32, decode, encode
from tcop_rsqrt_candidate import rsqrt_bits


SIGN = 0x80000000


class NonfiniteResult(Exception):
    """An infinity at an OP-007 arithmetic boundary."""


def _finite_decode(bits, shape):
    sign, magnitude = decode(bits, shape)
    if magnitude is None:
        raise NonfiniteResult
    return sign, magnitude


def _add(left, right):
    result = add_fp32(left, right)
    _finite_decode(result, FP32)
    return result


def _mul(left, right):
    left_sign, left_mag = _finite_decode(left, FP32)
    right_sign, right_mag = _finite_decode(right, FP32)
    result = encode(left_sign != right_sign, left_mag * right_mag, FP32, unit_exponent=-298)
    _finite_decode(result, FP32)
    return result


def _divide_by_count(bits, count):
    """Round a finite FP32 value divided by a positive integer directly to FP32."""
    sign, magnitude = _finite_decode(bits, FP32)
    return _round_ratio(sign, magnitude, count)


def _round_ratio(sign, magnitude, count):
    """Round magnitude/count in units of the smallest FP32 subnormal."""
    shift = max(0, (magnitude // count).bit_length() - 24)
    spacing = count << shift
    retained, remainder = divmod(magnitude, spacing)
    if 2 * remainder > spacing or (2 * remainder == spacing and retained & 1):
        retained += 1
    return encode(sign, retained << shift, FP32)


def _merge(left, right):
    na, ma, m2a = left
    nb, mb, m2b = right
    if not na or not nb:
        return left if na else right
    count = na + nb
    delta = _add(mb, ma ^ SIGN)
    mean = _add(ma, _mul(delta, _round_ratio(False, nb << 149, count)))
    cross = _mul(_mul(delta, delta), _round_ratio(False, (na * nb) << 149, count))
    return count, mean, _add(m2a, _add(m2b, cross))


def _row_statistics(row):
    """Return (mean, M2, population variance) as FP32 encodings."""
    level = [(1, bits, 0) for bits in row]
    level.extend([(0, 0, 0)] * ((1 << (len(level) - 1).bit_length()) - len(level)))
    while len(level) > 1:
        level = [_merge(level[i], level[i + 1]) for i in range(0, len(level), 2)]
    count, mean, m2 = level[0]
    return mean, m2, _divide_by_count(m2, count)


def layernorm_row(row, precision, epsilon, gamma=None, beta=None):
    """Return (output storage encodings or None, row status symbol).

    Epsilon is a binary32 encoding. Input and optional affine vectors hold
    unsigned BF16 or FP16 encodings. DMA and command faults are separate.
    """
    if precision not in FLOAT16_FORMATS:
        raise ValueError("invalid LayerNorm precision")
    if type(epsilon) is not int or not 0x33800000 <= epsilon <= 0x3F800000:
        return None, "TC_ERR_DESCRIPTOR_FORMAT"
    width = len(row)
    if not 1 <= width <= 65_536:
        return None, "TC_ERR_SHAPE"
    affine = gamma is not None
    if affine != (beta is not None) or (affine and (len(gamma) != width or len(beta) != width)):
        raise ValueError("affine mode requires gamma and beta of row width")

    shape = FLOAT16_FORMATS[precision]
    widened = []
    has_nan = False
    for vector in ((row, gamma, beta) if affine else (row,)):
        if any(type(bits) is not int or not 0 <= bits <= 0xFFFF for bits in vector):
            raise ValueError("operands must use unsigned 16-bit storage encodings")
        values = []
        for bits in vector:
            try:
                values.append(encode(*_finite_decode(bits, shape), FP32))
            except NaNResult:
                has_nan = True
                values.append(None)
            except NonfiniteResult:
                return None, "TC_ERR_NUMERIC_NONFINITE"
        widened.append(values)
    if None in widened[0]:
        return None, "TC_ERR_NUMERIC_NAN"

    try:
        mean, _, variance = _row_statistics(widened[0])
        invstd = rsqrt_bits(_add(variance, epsilon))
        output = []
        for i, bits in enumerate(widened[0]):
            y = _mul(_add(bits, mean ^ SIGN), invstd)
            if affine:
                gamma_bits = widened[1][i]
                beta_bits = widened[2][i]
                if gamma_bits is None:
                    continue
                y = _mul(y, gamma_bits)
                if beta_bits is None:
                    continue
                y = _add(y, beta_bits)
            stored = encode(*_finite_decode(y, FP32), shape)
            _finite_decode(stored, shape)
            output.append(stored)
    except NaNResult:
        return None, "TC_ERR_NUMERIC_NAN"
    except NonfiniteResult:
        return None, "TC_ERR_NUMERIC_NONFINITE"
    if has_nan:
        return None, "TC_ERR_NUMERIC_NAN"
    return output, "TC_STATUS_OK"
