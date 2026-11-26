"""OP-009 numerical and TLAS checkpoint reference for one sample."""

from struct import Struct, iter_unpack, pack

from tcop_exp_candidate import centered_exp_bits
from tcop_fp_reference import (
    FLOAT16_FORMATS, FP32, NaNResult, add_fp32, balanced_sum_fp32, decode, encode, fma_fp32,
)
from tcop_reciprocal_candidate import reciprocal_bits


TLAS_HEADER = Struct("<4sHHBBBBIIIQI28x")
PRECISION_ID = {"bf16": 1, "fp16": 2}
SIGN = 0x80000000
ONE = 0x3F800000


class LinearFault(Exception):
    """A symbolic OP-009 status from validated inputs or arithmetic."""


def _finite(bits, shape=FP32):
    sign, magnitude = decode(bits, shape)
    if magnitude is None:
        raise LinearFault("TC_ERR_NUMERIC_NONFINITE")
    return sign, magnitude


def _product(left, right):
    return fma_fp32(left, right, (left ^ right) & SIGN)


def _widen(bits, shape):
    if type(bits) is not int or not 0 <= bits <= 0xFFFF:
        raise ValueError("Q/K/V must use unsigned 16-bit encodings")
    return encode(*_finite(bits, shape), FP32)


def _phi(bits, shape):
    x = _widen(bits, shape)
    return centered_exp_bits(x) if x & SIGN or x == 0 else add_fp32(x, ONE)


def _header(precision, heads, features, values, count):
    payload_bytes = 4 * heads * features * (values + 1)
    return TLAS_HEADER.pack(b"TLAS", 1, 64, 0, PRECISION_ID[precision], 1, 0,
                            heads, features, values, count, payload_bytes)


def _load_head(payload, features, values):
    state = [[next(payload)[0] for _ in range(values + 1)] for _ in range(features)]
    has_nan = False
    negative_z = False
    for feature in state:
        for i, word in enumerate(feature):
            try:
                sign, magnitude = _finite(word)
            except NaNResult:
                has_nan = True
                continue
            negative_z |= i == values and sign and magnitude != 0
    if has_nan:
        raise NaNResult
    if negative_z:
        raise LinearFault("TC_ERR_LINEAR_STATE")
    return state


def _step(q, k, v, state, shape, values):
    phi_q = [_phi(word, shape) for word in q]
    phi_k = [_phi(word, shape) for word in k]
    v32 = [_widen(word, shape) for word in v]
    for feature, key in zip(state, phi_k):
        for d, value in enumerate(v32):
            feature[d] = add_fp32(feature[d], _product(key, value))
            _finite(feature[d])
        feature[values] = add_fp32(feature[values], key)
        _finite(feature[values])

    def dot(d):
        terms = []
        for query, feature in zip(phi_q, state):
            term = _product(query, feature[d])
            _finite(term)
            terms.append(term)
        result = balanced_sum_fp32(terms)
        _finite(result)
        return result

    den = dot(values)
    numerators = [dot(d) for d in range(values)]
    if den & SIGN or den < 0x00800000:
        raise LinearFault("TC_ERR_LINEAR_ZERO_DENOM")
    reciprocal = reciprocal_bits(den)
    output = [encode(*_finite(_product(num, reciprocal)), shape) for num in numerators]
    for word in output:
        _finite(word, shape)
    return output


def linear_attention_sample(q, k, v, precision, checkpoint=None):
    """Return `(context, new_checkpoint, status)` for [head][token][feature].

    None selects RESET. CONTINUE reads a TLAS record, ignoring any bytes
    after the payload. The returned record excludes stride padding. This
    model processes heads in order and stops on fault, with no DMA or stalls.
    """
    if precision not in FLOAT16_FORMATS:
        raise ValueError("invalid linear attention precision")

    heads = len(q)
    if not 1 <= heads <= 64 or len(k) != heads or len(v) != heads:
        return None, None, "TC_ERR_SHAPE"
    tokens = len(q[0])
    if not 1 <= tokens <= 65_536 or any(len(head) != tokens for tensor in (q, k, v) for head in tensor):
        return None, None, "TC_ERR_SHAPE"
    features = len(q[0][0])
    values = len(v[0][0])
    entries = heads * features * (values + 1)
    if (not 1 <= features <= 128 or not 1 <= values <= 128
            or heads * max(features, values) > 4096
            or entries > 16_777_216 or 2 * tokens * entries > 17_179_869_184):
        return None, None, "TC_ERR_SHAPE"
    for tensor, width in ((q, features), (k, features), (v, values)):
        if any(len(row) != width for head in tensor for row in head):
            return None, None, "TC_ERR_SHAPE"

    old_count = 0
    if checkpoint is not None:
        total_bytes = TLAS_HEADER.size + 4 * entries
        if len(checkpoint) < total_bytes:
            return None, None, "TC_ERR_LINEAR_STATE"
        old_count = TLAS_HEADER.unpack_from(checkpoint)[10]
        if (not 1 <= old_count <= (1 << 64) - 1 - tokens
                or checkpoint[:64] != _header(precision, heads, features, values, old_count)):
            return None, None, "TC_ERR_LINEAR_STATE"
        payload = iter_unpack("<I", memoryview(checkpoint)[64:total_bytes])

    shape = FLOAT16_FORMATS[precision]
    new_record = bytearray(_header(precision, heads, features, values, old_count + tokens))
    context = []
    try:
        for q_head, k_head, v_head in zip(q, k, v):
            if checkpoint is None:
                state = [[0] * (values + 1) for _ in range(features)]
            else:
                state = _load_head(payload, features, values)
            context.append([_step(qt, kt, vt, state, shape, values)
                            for qt, kt, vt in zip(q_head, k_head, v_head)])
            for row in state:
                new_record.extend(pack(f"<{values + 1}I", *row))
    except LinearFault as fault:
        return None, None, fault.args[0]
    except NaNResult:
        return None, None, "TC_ERR_NUMERIC_NAN"
    return context, bytes(new_record), "TC_STATUS_OK"
