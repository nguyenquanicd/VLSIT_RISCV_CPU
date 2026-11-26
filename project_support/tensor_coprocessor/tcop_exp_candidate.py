"""Piecewise FP32 exp candidate for the centered interval [-16, 0]."""

from decimal import Decimal, localcontext
from functools import lru_cache
from math import factorial
from struct import pack, unpack

from tcop_fp_reference import FP32, add_fp32, decode, encode, fma_fp32


_ONE_BITS = 0x3F800000
_SIXTEEN_UNITS = 16 << 149


@lru_cache(maxsize=1)
def coefficient_rom():
    """Return 64 rows of five FP32 coefficients in increasing degree order."""
    rows = []
    with localcontext() as context:
        context.prec = 80
        for segment in range(64):
            center = -Decimal(2 * segment + 1) / 8
            amplitude = center.exp()
            scaled = (amplitude / factorial(degree) for degree in range(5))
            rows.append(tuple(unpack("<I", pack("<f", float(value)))[0] for value in scaled))
    return tuple(rows)


def centered_exp_bits(bits):
    """Evaluate four FP32 FMAs for one finite, nonpositive input encoding."""
    if type(bits) is not int or not 0 <= bits < 1 << 32:
        raise ValueError("expected a binary32 encoding")
    negative, magnitude = decode(bits, FP32)
    if magnitude is None or (not negative and magnitude):
        raise ValueError("the candidate accepts only finite nonpositive input")
    if magnitude == 0:
        return _ONE_BITS
    if magnitude > _SIXTEEN_UNITS:
        return 0

    # Segment centers are exact multiples of one eighth. The expression
    # below converts from integer units of 2**-149 without initial rounding.
    segment = min(63, magnitude >> 147)
    center_offset = encode(False, (2 * segment + 1) << 146, FP32)
    residual = add_fp32(bits, center_offset)
    row = coefficient_rom()[segment]
    result = row[-1]
    for coefficient in reversed(row[:-1]):
        result = fma_fp32(result, residual, coefficient)
    return 0 if result & 0x80000000 else min(_ONE_BITS, result)
