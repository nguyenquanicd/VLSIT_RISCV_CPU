"""FP32 reciprocal square-root candidate for OP-007 LayerNorm."""

from decimal import Decimal, localcontext
from struct import pack, unpack

from tcop_fp_reference import fma_fp32


_ONE_BITS = 0x3F800000
_FRACTION_MASK = 0x007FFFFF
_EXPONENT_STEP = 1 << 23


def seed_rom():
    """Return two parity banks of 16 binary32 midpoint seeds."""
    banks = []
    with localcontext() as context:
        context.prec = 80
        for parity in (0, 1):
            seeds = []
            for index in range(16):
                center = Decimal((33 + 2 * index) << parity) / 32
                guess = 1 / center.sqrt()
                seeds.append(unpack("<I", pack("<f", float(guess)))[0])
            banks.append(tuple(seeds))
    return tuple(banks)


_SEEDS = seed_rom()


def rsqrt_bits(bits):
    """Evaluate two normalized Newton steps and exact exponent rescaling."""
    if type(bits) is not int or not 0x33800000 <= bits <= 0x7F7FFFFF:
        raise ValueError("rsqrt requires finite FP32 in the LayerNorm domain")

    exponent = (bits >> 23) - 127
    parity = exponent & 1
    fraction = bits & _FRACTION_MASK
    if parity == 0 and fraction == 0:
        estimate = _ONE_BITS
    else:
        normalized = (_ONE_BITS + parity * _EXPONENT_STEP) | fraction
        estimate = _SEEDS[parity][fraction >> 19]
        for _ in range(2):
            square = fma_fp32(estimate, estimate, 0)
            residual = fma_fp32(normalized | 0x80000000, square, _ONE_BITS)
            estimate = fma_fp32(estimate - _EXPONENT_STEP, residual, estimate)

    # Estimates and outputs remain positive normal. The final exponent
    # change and the halvings in the Newton steps are exact.
    return estimate - (exponent // 2) * _EXPONENT_STEP
