"""Release-1 OP-008 INT8 packing, tile selector, and dot-product reference."""


def pack_2of4(weights, selectors) -> tuple[bytes, bytes]:
    """Pack dense [K][N] weights and explicit [K/4][N] selector pairs.

    Returns (selector_metadata, packed_weight_values). This function checks the
    selected sparsity pattern. It never prunes or silently changes a weight.
    """
    k = len(weights)
    if not k or k % 4 or not weights[0]:
        raise ValueError("weights must have K>0 divisible by four and N>0")
    n = len(weights[0])
    if any(len(row) != n for row in weights):
        raise ValueError("all weights rows must have the same channel count")
    groups = k // 4
    if len(selectors) != groups or any(len(row) != n for row in selectors):
        raise ValueError("selectors must have shape [K/4][N]")

    metadata = bytearray((groups * n + 1) // 2)
    values = bytearray()
    for group, selector_row in enumerate(selectors):
        for channel, (p0, p1) in enumerate(selector_row):
            if not 0 <= p0 < p1 < 4:
                raise ValueError(f"invalid positions for group {group}, channel {channel}")
            group_values = [weights[4 * group + p][channel] for p in range(4)]
            if any(not isinstance(w, int) or not -128 <= w <= 127 for w in group_values):
                raise ValueError("weights must be signed INT8 integers")
            if any(w != 0 for p, w in enumerate(group_values) if p not in (p0, p1)):
                raise ValueError(f"unselected nonzero weight at group {group}, channel {channel}")
            q = group * n + channel
            nibble = p0 | (p1 << 2)
            metadata[q // 2] |= nibble << (4 * (q % 2))
            values.extend((group_values[p0] & 0xFF, group_values[p1] & 0xFF))
    return bytes(metadata), bytes(values)


def decode_selector_tile(metadata: bytes, group_count: int, channel_count: int,
                         groups: range, channels: range) -> list[list[tuple[int, int]]]:
    """Decode a contiguous tile and validate only its owned selector nibbles."""
    slots = group_count * channel_count
    if group_count <= 0 or channel_count <= 0 or len(metadata) != (slots + 1) // 2:
        raise ValueError("selector metadata size does not match [groups][channels]")
    if not (groups.step == channels.step == 1 and
            0 <= groups.start < groups.stop <= group_count and
            0 <= channels.start < channels.stop <= channel_count):
        raise ValueError("tile must be nonempty, contiguous and within the descriptor bounds")

    decoded = []
    for group in groups:
        row = []
        for channel in channels:
            q = group * channel_count + channel
            byte = metadata[q // 2]
            if slots % 2 and q == slots - 1 and byte & 0xF0:
                raise ValueError("unused high nibble at the end of the stream is not zero")
            nibble = (byte >> (4 * (q % 2))) & 0xF
            p0, p1 = nibble & 3, nibble >> 2
            if p0 >= p1:
                raise ValueError(f"malformed selector at group {group}, channel {channel}")
            row.append((p0, p1))
        decoded.append(row)
    return decoded


def sparse_dot(activation, metadata: bytes, values: bytes,
               channel_count: int, channel: int) -> int:
    """Return the exact dot for one output channel before INT8 addends.

    activation holds signed INT8 values in logical K order. Metadata and
    weights are the compact DEC-062 byte streams. Validate the selectors
    owned by this column. Command-wide validation and DMA order are separate.
    """
    if not activation or len(activation) % 4:
        raise ValueError("activation length must be positive and divisible by four")
    if any(type(x) is not int or not -128 <= x <= 127 for x in activation):
        raise ValueError("activations must be signed INT8 integers")
    groups = len(activation) // 4
    if len(values) != 2 * groups * channel_count:
        raise ValueError("packed weight size does not match [groups][channels][2]")
    selectors = decode_selector_tile(
        metadata, groups, channel_count, range(groups), range(channel, channel + 1)
    )

    accumulator = 0
    for group, row in enumerate(selectors):
        p0, p1 = row[0]
        offset = 2 * (group * channel_count + channel)
        first, second = values[offset:offset + 2]
        w0 = first - 256 if first & 0x80 else first
        w1 = second - 256 if second & 0x80 else second
        accumulator += activation[4 * group + p0] * w0 + activation[4 * group + p1] * w1
    return accumulator
