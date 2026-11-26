"""OP-005 single-query, single-head reference for a fixed K/V tile width."""

from tcop_exp_candidate import centered_exp_bits
from tcop_fp_reference import (
    FLOAT16_FORMATS, FP32, NaNResult, add_fp32, balanced_sum_fp32, decode, encode, fma_fp32,
)
from tcop_reciprocal_candidate import reciprocal_bits


SIGN = 0x80000000


class NonfiniteResult(Exception):
    """An infinite valid operand, intermediate, or stored output."""


def _finite(bits, shape=FP32):
    sign, magnitude = decode(bits, shape)
    if magnitude is None:
        raise NonfiniteResult
    return sign, magnitude


def _mul(a, b):
    # A zero addend with the product sign preserves signed-zero multiplication.
    result = fma_fp32(a, b, (a ^ b) & SIGN)
    _finite(result)
    return result


def _exp_difference(value, peak):
    difference = add_fp32(value, peak ^ SIGN)
    return 0 if difference == 0xFF800000 else centered_exp_bits(difference)


def _score(query, key, scale):
    accum = 0
    for q, k in zip(query, key):
        accum = fma_fp32(q, k, accum)
        _finite(accum)
    return _mul(accum, scale)


def attention_row(query, keys, values, precision, scale, tile_kv, *, mask=None, causal_position=None):
    """Return (output storage encodings or None, row status symbol).

    Inputs are unsigned BF16/FP16 encodings. Pass a BOOL byte mask, the
    resolved causal query position, or neither for NONE. Descriptor-level
    batch, head, shape and DMA checks are outside this row model.
    """
    if precision not in FLOAT16_FORMATS:
        raise ValueError("invalid attention precision")
    if type(scale) is not int or not 0 < scale < 0x7F800000:
        return None, "TC_ERR_DESCRIPTOR_FORMAT"
    if not 1 <= tile_kv <= 2048:
        raise ValueError("invalid build tile width")
    length = len(keys)
    if not 1 <= length <= 2048 or len(values) != length or not 1 <= len(query) <= 4096:
        return None, "TC_ERR_SHAPE"
    width = len(values[0])
    if not 1 <= width <= 128 or any(len(v) != width for v in values):
        return None, "TC_ERR_SHAPE"
    if any(len(k) != len(query) for k in keys):
        return None, "TC_ERR_SHAPE"
    if mask is not None and (
        causal_position is not None or len(mask) != length
        or any(type(byte) is not int or not 0 <= byte <= 255 for byte in mask)
    ):
        raise ValueError("invalid or conflicting mask")
    if causal_position is not None and not 0 <= causal_position <= 0xFFFFFFFF:
        return None, "TC_ERR_SHAPE"

    if mask is not None:
        valid = [bool(byte) for byte in mask]
    else:
        valid = [causal_position is None or i <= causal_position for i in range(length)]
    if not any(valid):
        return None, "TC_ERR_NO_VALID_ATTENTION_ROW"

    shape = FLOAT16_FORMATS[precision]
    has_nan = False

    def widen(vector):
        nonlocal has_nan
        result = []
        for bits in vector:
            if type(bits) is not int or not 0 <= bits <= 0xFFFF:
                raise ValueError("operands must use unsigned 16-bit storage encodings")
            try:
                result.append(encode(*_finite(bits, shape), FP32))
            except NaNResult:
                has_nan = True
                result.append(None)
        return result

    try:
        q = widen(query)
        kv = {i: (widen(keys[i]), widen(values[i])) for i in range(length) if valid[i]}
        query_is_numeric = None not in q
        peak = None
        denom = 0
        numerators = [0] * width
        for start in range(0, length, tile_kv):
            scored = []
            for i in range(start, min(start + tile_kv, length)):
                if query_is_numeric and i in kv and None not in kv[i][0]:
                    k, v = kv[i]
                    scored.append((i - start, _score(q, k, scale), v))
            if not scored:
                continue

            # Numeric max of finite FP32 encodings, including a +0 tie preference.
            scores = [score for _, score, _ in scored]
            if peak is not None:
                scores.append(peak)
            new_peak = max(scores, key=lambda bits: bits ^ (0xFFFFFFFF if bits & SIGN else SIGN))
            alpha = 0 if peak is None else _exp_difference(peak, new_peak)
            peak = new_peak
            probabilities = [0] * tile_kv
            for index, score, _ in scored:
                probabilities[index] = _exp_difference(score, peak)
            denom = add_fp32(_mul(alpha, denom), balanced_sum_fp32(probabilities))
            _finite(denom)

            for feature in range(width):
                if numerators[feature] is None:
                    continue
                products = [0] * tile_kv
                for index, _, v in scored:
                    if v[feature] is None:
                        numerators[feature] = None
                        break
                    products[index] = _mul(probabilities[index], v[feature])
                if numerators[feature] is None:
                    continue
                tile_sum = balanced_sum_fp32(products)
                _finite(tile_sum)
                numerators[feature] = add_fp32(_mul(alpha, numerators[feature]), tile_sum)
                _finite(numerators[feature])

        if has_nan:
            return None, "TC_ERR_NUMERIC_NAN"
        reciprocal = reciprocal_bits(denom)
        output = [encode(*_finite(_mul(o, reciprocal)), shape) for o in numerators]
        for bits in output:
            _finite(bits, shape)
    except NaNResult:
        return None, "TC_ERR_NUMERIC_NAN"
    except NonfiniteResult:
        return None, "TC_ERR_NUMERIC_NONFINITE"
    return output, "TC_STATUS_OK"
