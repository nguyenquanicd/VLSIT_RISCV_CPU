"""Exact binary floating-point arithmetic for tensor numerical references."""


FP16 = (5, 10)
BF16 = (8, 7)
FP32 = (8, 23)
FLOAT16_FORMATS = {"fp16": FP16, "bf16": BF16}


class NaNResult(Exception):
    """A NaN encoding or invalid floating-point arithmetic."""


def decode(bits, shape):
    """Return sign and unsigned magnitude in units of 2**-149, or infinity."""
    e_bits, fraction_bits = shape
    sign = bool(bits >> (e_bits + fraction_bits))
    exponent_mask = (1 << e_bits) - 1
    exponent = (bits >> fraction_bits) & exponent_mask
    fraction = bits & ((1 << fraction_bits) - 1)
    if exponent == exponent_mask:
        if fraction:
            raise NaNResult
        return sign, None
    bias = exponent_mask >> 1
    min_shift = 150 - bias - fraction_bits
    if exponent == 0:
        return sign, fraction << min_shift
    return sign, ((1 << fraction_bits) | fraction) << (min_shift + exponent - 1)


def encode(sign, magnitude, shape, *, unit_exponent=-149):
    """Round an exact magnitude to the requested format, preserving signed zero."""
    e_bits, fraction_bits = shape
    sign_bits = int(sign) << (e_bits + fraction_bits)
    exponent_mask = (1 << e_bits) - 1
    if magnitude is None:
        return sign_bits | (exponent_mask << fraction_bits)

    bias = exponent_mask >> 1
    min_shift = 1 - bias - fraction_bits - unit_exponent
    shift = max(min_shift, magnitude.bit_length() - fraction_bits - 1)
    spacing = 1 << shift
    retained, discarded = divmod(magnitude, spacing)
    if 2 * discarded > spacing or (2 * discarded == spacing and retained & 1):
        retained += 1
    rounded = retained << shift
    exponent = rounded.bit_length() - 1 + unit_exponent + bias
    if exponent <= 0:
        return sign_bits | (rounded >> min_shift)
    if exponent >= exponent_mask:
        return sign_bits | (exponent_mask << fraction_bits)
    fraction = (rounded >> (min_shift + exponent - 1)) & ((1 << fraction_bits) - 1)
    return sign_bits | (exponent << fraction_bits) | fraction


def add_fp32(left, right):
    left_sign, left_units = decode(left, FP32)
    right_sign, right_units = decode(right, FP32)
    if left_units is None or right_units is None:
        if left_units is None and right_units is None and left_sign != right_sign:
            raise NaNResult
        return left if left_units is None else right
    signed_sum = (-left_units if left_sign else left_units) + (
        -right_units if right_sign else right_units
    )
    negative = signed_sum < 0 or (signed_sum == 0 and left_sign and right_sign)
    return encode(negative, abs(signed_sum), FP32)


def balanced_sum_fp32(leaves):
    """Sum nonempty FP32 leaves in index order, padding the right with +0."""
    level = list(leaves)
    if not level:
        raise ValueError("balanced sum requires at least one leaf")
    level.extend([0] * ((1 << (len(level) - 1).bit_length()) - len(level)))
    while len(level) > 1:
        level = [add_fp32(level[i], level[i + 1]) for i in range(0, len(level), 2)]
    return level[0]


def fma_fp32(left, right, addend):
    """Round left*right+addend once in binary32, including gradual underflow."""
    left_sign, left_mag = decode(left, FP32)
    right_sign, right_mag = decode(right, FP32)
    add_sign, add_mag = decode(addend, FP32)
    product_sign = left_sign != right_sign
    if left_mag is None or right_mag is None:
        if left_mag == 0 or right_mag == 0 or (add_mag is None and product_sign != add_sign):
            raise NaNResult
        return encode(product_sign, None, FP32)
    if add_mag is None:
        return addend

    # The exact product is measured in units of 2**-298. Shift the
    # addend into that same unit before the single binary32 rounding.
    product = left_mag * right_mag
    addend_units = add_mag << 149
    signed_sum = (-product if product_sign else product) + (
        -addend_units if add_sign else addend_units
    )
    negative = signed_sum < 0 or (signed_sum == 0 and product_sign and add_sign)
    return encode(negative, abs(signed_sum), FP32, unit_exponent=-298)
