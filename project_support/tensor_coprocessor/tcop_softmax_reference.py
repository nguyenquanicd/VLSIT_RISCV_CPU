"""OP-006 row model using the candidate FP32 exp and reciprocal functions."""

from tcop_exp_candidate import centered_exp_bits
from tcop_fp_reference import (
    FLOAT16_FORMATS,
    FP32,
    NaNResult,
    add_fp32,
    balanced_sum_fp32,
    decode,
    encode,
    fma_fp32,
)
from tcop_reciprocal_candidate import reciprocal_bits


def softmax_row(logits, precision, mask=None):
    """Return (output storage encodings or None, row status symbol).

    Inputs are unsigned BF16 or FP16 encodings in logical order. A supplied
    mask contains one byte per element. Descriptor and command faults are
    handled by the caller.
    """
    if precision not in FLOAT16_FORMATS or not 1 <= len(logits) <= 65_536:
        raise ValueError("invalid softmax precision or row length")
    if any(type(bits) is not int or not 0 <= bits <= 0xFFFF for bits in logits):
        raise ValueError("logits must use unsigned 16-bit storage encodings")
    if mask is not None and (
        len(mask) != len(logits)
        or any(type(byte) is not int or not 0 <= byte <= 255 for byte in mask)
    ):
        raise ValueError("mask must contain one byte per logit")

    shape = FLOAT16_FORMATS[precision]
    widened = [None] * len(logits)
    has_nan = False
    for i, bits in enumerate(logits):
        if mask is not None and not mask[i]:
            continue
        try:
            sign, magnitude = decode(bits, shape)
        except NaNResult:
            has_nan = True
            continue
        if magnitude is None:
            return None, "TC_ERR_NUMERIC_NONFINITE"
        widened[i] = encode(sign, magnitude, FP32)
    if has_nan:
        return None, "TC_ERR_NUMERIC_NAN"

    # Finite max is associative with this ordering, which selects +0 over -0.
    # The result equals the fixed tree max with masked leaves set to -Inf.
    peak = max(
        (bits for bits in widened if bits is not None),
        key=lambda bits: bits ^ (0xFFFFFFFF if bits & 0x80000000 else 0x80000000),
        default=None,
    )
    if peak is None:
        return None, "TC_ERR_NO_VALID_SOFTMAX_ROW"

    exp_values = [0] * len(logits)
    for i, bits in enumerate(widened):
        if bits is not None:
            centered = add_fp32(bits, peak ^ 0x80000000)
            # DEC-070 treats negative overflow from finite subtraction as below cutoff.
            if centered != 0xFF800000:
                exp_values[i] = centered_exp_bits(centered)

    reciprocal = reciprocal_bits(balanced_sum_fp32(exp_values))
    result = [encode(*decode(fma_fp32(value, reciprocal, 0), FP32), shape) for value in exp_values]
    return result, "TC_STATUS_OK"
