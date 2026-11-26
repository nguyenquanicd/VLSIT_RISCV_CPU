"""Numerical reference and offline top-two diagnostics for OP-004."""

from fractions import Fraction
from heapq import nlargest
from typing import NamedTuple

from tcop_fp_reference import FLOAT16_FORMATS, FP32, NaNResult, add_fp32, decode, encode, fma_fp32


def _check_storage(values):
    if any(type(bits) is not int or not 0 <= bits < 1 << 16 for bits in values):
        raise ValueError("expected unsigned 16-bit storage encodings")


def _fp_score_keys(scores, shape):
    bits_per_score = 1 + sum(shape)
    for index, bits in enumerate(scores):
        if type(bits) is not int or not 0 <= bits < (1 << bits_per_score):
            raise ValueError(f"expected unsigned {bits_per_score}-bit score encodings")
        negative, magnitude = decode(bits, shape)
        if negative and magnitude is None:
            continue
        if magnitude is None:
            yield True, 0, -index  # +Inf wins against every finite score.
        else:
            yield False, -magnitude if negative else magnitude, -index


def _winner(scores, shape, xlen):
    best = max(_fp_score_keys(scores, shape), default=None)
    if best is None:
        return (1 << xlen) - 1, "TC_ERR_ARGMAX_NO_VALID_LOGIT"
    return -best[2], "TC_STATUS_OK"


class TopTwo(NamedTuple):
    winner: int | None
    runner_up: int | None
    margin: Fraction | None
    category: str


def _top_two(score_keys):
    best = nlargest(2, score_keys)
    if not best:
        return TopTwo(None, None, None, "no_valid")
    winner = -best[0][2]
    runner_up = -best[1][2] if len(best) == 2 else None
    if best[0][0]:
        category = "positive_infinity_tie" if len(best) == 2 and best[1][0] else "positive_infinity"
        return TopTwo(winner, runner_up, None, category)
    if runner_up is None:
        return TopTwo(winner, None, None, "single")
    return TopTwo(winner, runner_up, Fraction(best[0][1] - best[1][1]), "finite")


def fp_top_two(scores, precision):
    """Inspect BF16/FP16 stored scores or fused FP32 scores by raw bits."""
    shape = FP32 if precision == "fp32" else FLOAT16_FORMATS[precision]
    try:
        result = _top_two(_fp_score_keys(scores, shape))
    except NaNResult:
        return TopTwo(None, None, None, "nan")
    if result.margin is not None:
        # decode() expresses all finite floating magnitudes in units of 2**-149.
        return result._replace(margin=result.margin / (1 << 149))
    return result


def exact_top_two(scores):
    """Inspect raw signed INT8 logits or Fraction scores from Requant8.score."""
    return _top_two((False, score, -index) for index, score in enumerate(scores))


def project_fp32(activation, weights, precision, bias=None):
    """Return ordered FP32 scores. Weights are logical [feature][channel]."""
    shape = FLOAT16_FORMATS[precision]
    if not 1 <= len(activation) <= 4096 or len(weights) != len(activation):
        raise ValueError("invalid OP-004 feature extent")
    channels = len(weights[0])
    if not 1 <= channels <= 65536 or any(len(row) != channels for row in weights):
        raise ValueError("invalid OP-004 vocabulary extent")
    _check_storage(activation)
    for weights_row in weights:
        _check_storage(weights_row)
    if bias is not None:
        if len(bias) != channels:
            raise ValueError("bias extent differs from vocabulary")
        _check_storage(bias)

    accumulators = [0] * channels
    for activation_bits, weights_row in zip(activation, weights):
        x = encode(*decode(activation_bits, shape), FP32)
        for index, weight_bits in enumerate(weights_row):
            weight = encode(*decode(weight_bits, shape), FP32)
            accumulators[index] = fma_fp32(x, weight, accumulators[index])
    if bias is not None:
        for index, bias_bits in enumerate(bias):
            accumulators[index] = add_fp32(accumulators[index], encode(*decode(bias_bits, shape), FP32))
    return accumulators


def argmax_result(precision, xlen, *, logits=None, activation=None, weights=None, bias=None):
    """Return (unsigned rd bits, status symbol) for one build's FP variant."""
    if xlen not in (32, 64) or precision not in FLOAT16_FORMATS:
        raise ValueError("invalid XLEN or OP-004 precision")
    if logits is not None:
        if (activation is not None or weights is not None or bias is not None or
                not 1 <= len(logits) <= 65536):
            raise ValueError("invalid standalone OP-004 arguments")
        _check_storage(logits)
    elif activation is None or weights is None:
        raise ValueError("fused OP-004 requires activation and weights")

    try:
        if logits is not None:
            return _winner(logits, FLOAT16_FORMATS[precision], xlen)
        return _winner(project_fp32(activation, weights, precision, bias), FP32, xlen)
    except NaNResult:
        return (1 << xlen) - 1, "TC_ERR_NUMERIC_NAN"
