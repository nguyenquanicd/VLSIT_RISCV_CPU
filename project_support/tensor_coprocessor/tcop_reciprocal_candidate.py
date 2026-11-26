"""FP32 reciprocal candidate for positive normal denominators."""

from tcop_fp_reference import FP32, decode, encode, fma_fp32


_ONE_BITS = 0x3F800000
_FRACTION_MASK = 0x007FFFFF


def seed_rom():
    """Return 32 nearest-even FP32 reciprocals of normalized bin midpoints."""
    seeds = []
    for index in range(32):
        # Center is (65 + 2*index)/64. Its reciprocal lies in (0.5, 1)
        # with FP32 spacing 2**-24 throughout.
        denominator = 65 + 2 * index
        units, remainder = divmod(64 << 24, denominator)
        if 2 * remainder > denominator or (2 * remainder == denominator and units & 1):
            units += 1
        seeds.append(0x3F000000 | (units & _FRACTION_MASK))
    return tuple(seeds)


_SEEDS = seed_rom()


def reciprocal_bits(bits):
    """Evaluate two Newton steps and one exponent rescale in FP32."""
    if type(bits) is not int or not 0x00800000 <= bits <= 0x7F7FFFFF:
        raise ValueError("reciprocal requires positive normal FP32")

    exponent = (bits >> 23) - 127
    mantissa = bits & _FRACTION_MASK
    if mantissa == 0:
        estimate = _ONE_BITS
    else:
        negative_mantissa = 0xBF800000 | mantissa
        estimate = _SEEDS[mantissa >> 18]
        for _ in range(2):
            residual = fma_fp32(negative_mantissa, estimate, _ONE_BITS)
            estimate = fma_fp32(estimate, residual, estimate)

    sign, magnitude = decode(estimate, FP32)
    return encode(sign, magnitude, FP32, unit_exponent=-149 - exponent)
