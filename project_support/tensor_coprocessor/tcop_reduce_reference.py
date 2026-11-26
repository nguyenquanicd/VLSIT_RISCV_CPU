"""Bit-exact OP-003 numerical reference for accepted REDUCE commands."""


from tcop_fp_reference import FLOAT16_FORMATS, FP32, NaNResult, balanced_sum_fp32, decode, encode


def reduce_result(raw, precision, mode, xlen, max_elements=1_048_576):
    """Return (unsigned rd bit pattern, status symbol) for valid inputs.

    raw holds unsigned storage encodings in logical element order. Misformed
    inputs to this numerical model raise ValueError. Descriptor validation,
    DMA faults and the zero-result CSR fence are handled by the caller.
    """
    if xlen not in (32, 64) or mode not in ("sum", "max"):
        raise ValueError("invalid XLEN or REDUCE mode")
    if precision not in FLOAT16_FORMATS and precision != "int8":
        raise ValueError("invalid REDUCE precision")
    if not 1 <= max_elements <= 1 << 24 or not 1 <= len(raw) <= max_elements:
        raise ValueError("invalid REDUCE length or build cap")
    storage_limit = 1 << (8 if precision == "int8" else 16)
    if any(type(bits) is not int or not 0 <= bits < storage_limit for bits in raw):
        raise ValueError("input must use unsigned storage encodings")

    if precision == "int8":
        values = (bits - 256 if bits & 0x80 else bits for bits in raw)
        result = sum(values) if mode == "sum" else max(values)
        return result & ((1 << xlen) - 1), "TC_STATUS_OK"

    shape = FLOAT16_FORMATS[precision]
    try:
        if mode == "max":
            for bits in raw:
                decode(bits, shape)
            winner = max(raw, key=lambda bits: bits ^ (0xFFFF if bits & 0x8000 else 0x8000))
            return winner, "TC_STATUS_OK"

        total = balanced_sum_fp32(encode(*decode(bits, shape), FP32) for bits in raw)
        return encode(*decode(total, FP32), shape), "TC_STATUS_OK"
    except NaNResult:
        return 0, "TC_ERR_NUMERIC_NAN"
