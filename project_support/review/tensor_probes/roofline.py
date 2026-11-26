#!/usr/bin/env python3
"""Roofline, decode and fill/drain arithmetic for the tensor coprocessor review (2026-11-17).

All inputs come from the HDS (VLSIT_TENSOR_COPROCESSOR_HDS.md): CFG-64TOPS = 16 arrays of 32x32 INT8 PEs
at 2 GHz, tensor DMA = one 256-bit AXI4 port at the core clock, 128x128 output tile with Kt=128 and
ping-pong operand buffers (HDS 6.1 "first tile-capacity point").
Model: output-stationary tile Mt x Nt, K streamed, INT8 inputs and requantized INT8 output.
INT32 accumulators stay on chip. The square-tile estimate ignores output traffic.
Run: python roofline.py
"""

from collections import Counter
from dataclasses import dataclass
from math import ceil

F_HZ = 2e9
ARRAYS = 16
ROWS = COLS = 32
AXI_BYTES_PER_BEAT = 256 // 8
KT = 128
AXI_BOUNDARY_BYTES = 4096


def peak_tops(arrays=ARRAYS, rows=ROWS, cols=COLS, f=F_HZ):
    return 2 * arrays * rows * cols * f / 1e12


def axi_gbps(f=F_HZ, beat=AXI_BYTES_PER_BEAT):
    return beat * f / 1e9


def attainable_tops(tile, bw_gbps, peak):
    """min(peak, BW * AI) for a square output tile of side `tile` (INT8 operands)."""
    return min(peak, bw_gbps * tile / 1e3)


def sram_kib(tile, kt=KT):
    """INT32 result tile plus ping-pong A and B tiles (INT8)."""
    return (4 * tile * tile + 2 * 2 * tile * kt) / 1024


@dataclass(frozen=True)
class GemmTraffic:
    a_bytes: int
    b_bytes: int
    output_bytes: int

    @property
    def total_bytes(self):
        return self.a_bytes + self.b_bytes + self.output_bytes


def gemm_traffic(m, n, k, mt, nt, b_reuse_m=1, *, whole_matrix_reuse=False):
    """Count useful INT8 payload under the chosen schedule, including tile tails.

    b_reuse_m is how many consecutive M blocks share each loaded B slice.
    Whole-matrix reuse is a separate lower-bound reference. Neither estimate
    includes coefficient fetch, physical burst overhead, or buffer stalls.
    """
    if min(m, n, k, mt, nt, b_reuse_m) < 1:
        raise ValueError("matrix dimensions, tile dimensions and reuse must be positive")
    if whole_matrix_reuse:
        return GemmTraffic(m * k, k * n, m * n)
    m_blocks = (m + mt - 1) // mt
    n_blocks = (n + nt - 1) // nt
    b_loads = (m_blocks + b_reuse_m - 1) // b_reuse_m
    return GemmTraffic(n_blocks * m * k, b_loads * k * n, m * n)


@dataclass(frozen=True)
class AxiReadTraffic:
    payload_bytes: int
    wire_bytes: int
    bursts: int


def descriptor_read_bursts(base, schema_bytes, beat_bytes, max_beats):
    """Return separate header/body bursts as (address, transfer bytes, beats).

    Transfer bytes may be narrower than the data port. No beat accesses
    bytes from a subsequent phase or outside the selected descriptor schema.
    """
    if (base < 0 or base % 64 or schema_bytes < 128 or schema_bytes % 64
            or not 1 <= beat_bytes <= 128 or beat_bytes & (beat_bytes - 1)
            or not 1 <= max_beats <= 256):
        raise ValueError("invalid descriptor fetch geometry")

    def plan(start, end):
        bursts = []
        cursor = start
        while cursor < end:
            page = cursor // AXI_BOUNDARY_BYTES
            size = beat_bytes
            while cursor % size or size > end - cursor:
                size //= 2
            if (bursts and bursts[-1][1] == size and bursts[-1][2] < max_beats
                    and bursts[-1][0] // AXI_BOUNDARY_BYTES == page):
                address, _, count = bursts[-1]
                bursts[-1] = (address, size, count + 1)
            else:
                bursts.append((cursor, size, 1))
            cursor += size
        return tuple(bursts)

    return plan(base, base + 64), plan(base + 64, base + schema_bytes)


def aligned_read_traffic(address, payload_bytes, allocation_base, span_bytes,
                         beat_bytes=AXI_BYTES_PER_BEAT, max_beats=64):
    """Model reading one interval using aligned beats and bounded INCR bursts.

    This planner expands reads only within the owning allocation. It has no
    narrow-transfer fallback. It does not apply to descriptor fetches.
    """
    if (beat_bytes < 1 or beat_bytes > AXI_BOUNDARY_BYTES or
            beat_bytes & (beat_bytes - 1) or not 1 <= max_beats <= 256):
        raise ValueError("invalid beat width or burst limit")
    if payload_bytes < 1 or allocation_base < 0 or span_bytes < 1:
        raise ValueError("empty payload or allocation")
    first = address // beat_bytes * beat_bytes
    after = (address + payload_bytes + beat_bytes - 1) // beat_bytes * beat_bytes
    if first < allocation_base or after > allocation_base + span_bytes:
        raise ValueError("full-width read extends beyond the allocation")

    burst_cap = beat_bytes * max_beats
    cursor = first
    bursts = 0
    while cursor < after:
        boundary_room = AXI_BOUNDARY_BYTES - cursor % AXI_BOUNDARY_BYTES
        cursor += min(after - cursor, boundary_room, burst_cap)
        bursts += 1
    return AxiReadTraffic(payload_bytes, after - first, bursts)


def matrix_tile_reads(base, span_bytes, row_pitch, row_start, col_start,
                      rows, cols, element_bytes, *, transposed=False):
    """Count one tile assuming each contiguous physical row issues separately."""
    if min(row_pitch, rows, cols, element_bytes) < 1 or min(row_start, col_start) < 0:
        raise ValueError("invalid tile or row pitch")
    if transposed:
        row_start, col_start, rows, cols = col_start, row_start, cols, rows
    if (col_start + cols) * element_bytes > row_pitch:
        raise ValueError("tile exceeds the physical row pitch")
    payload = cols * element_bytes
    wire_bytes = bursts = 0
    for row in range(row_start, row_start + rows):
        address = base + row * row_pitch + col_start * element_bytes
        traffic = aligned_read_traffic(address, payload, base, span_bytes)
        wire_bytes += traffic.wire_bytes
        bursts += traffic.bursts
    return AxiReadTraffic(rows * payload, wire_bytes, bursts)


def attention_k_tile_reads(rows, width, slice_width, base, row_pitch):
    """Count BF16/FP16 K reads with one AXI interval per row and feature slice."""
    element_bytes = 2
    span_bytes = rows * row_pitch
    slices = [
        matrix_tile_reads(base, span_bytes, row_pitch, 0, start, rows,
                          min(slice_width, width - start), element_bytes)
        for start in range(0, width, slice_width)
    ]
    return AxiReadTraffic(sum(traffic.payload_bytes for traffic in slices),
                          sum(traffic.wire_bytes for traffic in slices),
                          sum(traffic.bursts for traffic in slices))


def argmax_weight_traffic(vocab, features, element_bytes, dma_stripe, base, row_pitch,
                          alignment=64, beat_bytes=AXI_BYTES_PER_BEAT, max_beats=64):
    """Count one fused OP-004 weight pass for a fixed independent-stripe DMA schedule.

    Each physical row/stripe is a separate read interval. The last stripe clips
    to the vocabulary size. Full beats may cover unused bytes inside the padded
    allocation. Counts exclude descriptor, activation, bias, coefficient and
    repeat-read traffic. No row or stripe coalescing is assumed.
    """
    if not (1 <= vocab <= 65536 and 1 <= features <= 4096 and
            element_bytes in (1, 2) and dma_stripe > 0 and base >= 0):
        raise ValueError("invalid fused OP-004 weight shape, format or stripe")
    if (alignment < max(64, beat_bytes) or alignment & (alignment - 1) or
            base % alignment or row_pitch % alignment or row_pitch < vocab * element_bytes):
        raise ValueError("invalid weight allocation alignment or row pitch")

    # Aligned INCR fragmentation depends only on the start modulo 4 KiB
    # and the useful interval length. Group repeated row/stripe residues.
    row_starts = Counter((base + row * row_pitch) % AXI_BOUNDARY_BYTES
                         for row in range(features))
    stripes = Counter(
        ((col * element_bytes) % AXI_BOUNDARY_BYTES,
         min(dma_stripe, vocab - col) * element_bytes)
        for col in range(0, vocab, dma_stripe)
    )
    wire_bytes = bursts = 0
    for row_start, row_count in row_starts.items():
        for (offset, payload), stripe_count in stripes.items():
            start = (row_start + offset) % AXI_BOUNDARY_BYTES
            interval = aligned_read_traffic(
                start, payload, 0, AXI_BOUNDARY_BYTES + payload + beat_bytes,
                beat_bytes, max_beats
            )
            repetitions = row_count * stripe_count
            wire_bytes += repetitions * interval.wire_bytes
            bursts += repetitions * interval.bursts
    return AxiReadTraffic(vocab * features * element_bytes, wire_bytes, bursts)


def argmax_weight_traffic_bound(vocab, features, element_bytes, dma_stripe,
                                alignment=64, beat_bytes=AXI_BYTES_PER_BEAT,
                                max_beats=64):
    """Return the layout envelope and a base residue that attains it.

    Every row is bounded by the worst aligned start residue. A pitch that is
    a multiple of both the page and build alignment repeats that residue on
    every row. Payload and beat count per row are independent of that residue.
    The envelope ignores any platform aperture constraints on the witness.
    """
    if not 1 <= features <= 4096 or alignment < 64 or alignment & (alignment - 1):
        raise ValueError("invalid fused OP-004 feature count or alignment")
    pitch_alignment = max(alignment, AXI_BOUNDARY_BYTES)
    row_pitch = (vocab * element_bytes + pitch_alignment - 1) // pitch_alignment * pitch_alignment
    rows = (
        (base, argmax_weight_traffic(vocab, 1, element_bytes, dma_stripe, base,
                                    row_pitch, alignment, beat_bytes, max_beats))
        for base in range(0, AXI_BOUNDARY_BYTES, alignment)
    )
    base, worst = max(rows, key=lambda entry: entry[1].bursts)
    return AxiReadTraffic(features * worst.payload_bytes, features * worst.wire_bytes,
                          features * worst.bursts), base


def argmax_fused_read_envelope(vocab, features, element_bytes, compute_stripe, dma_stripe,
                              *, bias=False, reload_activation=False,
                              keep_coefficients=False, alignment=64,
                              beat_bytes=AXI_BYTES_PER_BEAT, max_beats=64):
    """Per-reference layout maxima for one fixed OP-004 candidate.

    One weight pass uses independent row/stripe reads. Activation is loaded
    whole once, or once per compute stripe. FP bias is loaded once as a vector.
    INT8 coefficients have one contiguous validation pass and may be read
    again in per-DMA-stripe intervals. Descriptor header/body are separate.
    """
    if compute_stripe < 1:
        raise ValueError("invalid compute stripe")
    if bias and element_bytes == 1:
        raise ValueError("fused INT8 OP-004 does not accept bias")
    weight, _ = argmax_weight_traffic_bound(
        vocab, features, element_bytes, dma_stripe, alignment, beat_bytes, max_beats
    )

    def vector_envelope(parts, base_alignment):
        parts = tuple(parts)
        payload = sum(length for _, length in parts)
        max_wire = max_bursts = 0
        for base in range(0, AXI_BOUNDARY_BYTES, base_alignment):
            wire = bursts = 0
            for offset, length in parts:
                start = (base + offset) % AXI_BOUNDARY_BYTES
                traffic = aligned_read_traffic(
                    start, length, 0, AXI_BOUNDARY_BYTES + length + beat_bytes,
                    beat_bytes, max_beats
                )
                wire += traffic.wire_bytes
                bursts += traffic.bursts
            max_wire = max(max_wire, wire)
            max_bursts = max(max_bursts, bursts)
        return AxiReadTraffic(payload, max_wire, max_bursts)

    activation_bytes = features * element_bytes
    activation_load = vector_envelope(((0, activation_bytes),), alignment)
    loads = (vocab + compute_stripe - 1) // compute_stripe if reload_activation else 1
    descriptor_bursts = descriptor_beats = 0
    for base in range(0, AXI_BOUNDARY_BYTES, 64):
        header, body = descriptor_read_bursts(base, 384, beat_bytes, max_beats)
        descriptor_bursts = max(descriptor_bursts, len(header) + len(body))
        descriptor_beats = max(descriptor_beats, sum(count for _, _, count in header + body))
    traffic = {
        "descriptor": AxiReadTraffic(384, descriptor_beats * beat_bytes, descriptor_bursts),
        "weights": weight,
        "activation": AxiReadTraffic(loads * activation_load.payload_bytes,
                                     loads * activation_load.wire_bytes,
                                     loads * activation_load.bursts),
    }
    if bias:
        traffic["bias"] = vector_envelope(((0, vocab * element_bytes),), alignment)
    if element_bytes == 1:
        intervals = [(0, 8 * vocab)]
        if not keep_coefficients:
            intervals.extend((8 * col, 8 * min(dma_stripe, vocab - col))
                             for col in range(0, vocab, dma_stripe))
        traffic["coefficients"] = vector_envelope(intervals, alignment)
    return traffic


def operand_feed_bytes(grid_rows, grid_cols, pe_rows, pe_cols, element_bytes=1):
    """Return endpoint and ideal distinct SRAM bytes/cycle for dense GEMM.

    Distinct feed assumes phase-aligned A broadcast across columns and B
    broadcast across rows. It excludes staging writes and other operations.
    """
    if min(grid_rows, grid_cols, pe_rows, pe_cols, element_bytes) < 1:
        raise ValueError("array grid, PE dimensions and element size must be positive")
    endpoints = grid_rows * grid_cols * (pe_rows + pe_cols) * element_bytes
    distinct = (grid_rows * pe_rows + grid_cols * pe_cols) * element_bytes
    return endpoints, distinct


def sparse_group_feed_bytes(grid_rows, grid_cols, pe_rows, pe_cols):
    """Return distinct activation, packed weight and selector bytes per 2:4 step."""
    if min(grid_rows, grid_cols, pe_rows, pe_cols) < 1 or pe_cols % 2:
        raise ValueError("sparse feed requires a positive grid and even channel tile width")
    activations = grid_rows * pe_rows * 4
    packed_weights = grid_cols * pe_cols * 2
    selectors = grid_cols * pe_cols // 2
    return activations, packed_weights, selectors


def main():
    peak = peak_tops()
    bw = axi_gbps()
    print(f"peak = {peak:.3f} TOPS, injection = {ARRAYS * (ROWS + COLS) * F_HZ / 1e12:.3f} TB/s, "
          f"one AXI port = {bw:.0f} GB/s per direction")

    print("\nA. Attainable TOPS versus output-tile side (one 256-bit AXI port, 2 GHz)")
    print(f"{'tile':>6} {'AI op/B':>8} {'SRAM KiB':>9} {'TOPS @64GB/s':>13} {'% of peak':>10} {'GB/s for peak':>14}")
    for tile in (64, 128, 256, 512, 1024, 2048):
        att = attainable_tops(tile, bw, peak)
        print(f"{tile:6d} {tile:8d} {sram_kib(tile):9.0f} {att:13.2f} {100 * att / peak:9.1f}% {peak * 1e3 / tile:14.0f}")

    print("\nB. HDS 13 prefill example M=1024, N=K=4096")
    m, n, k = 1024, 4096, 4096
    ops = 2 * m * n * k
    print(f"   INT8 output; minimum coefficient-validation payload = {8*n/1024:.0f} KiB (excluded below)")
    tile = 128
    for label, traffic in (
        ("independent blocks", gemm_traffic(m, n, k, tile, tile)),
        ("share B with two M blocks", gemm_traffic(m, n, k, tile, tile, 2)),
        ("retain B panel", gemm_traffic(m, n, k, tile, tile, (m + tile - 1) // tile)),
        ("whole-matrix reuse bound", gemm_traffic(m, n, k, tile, tile, whole_matrix_reuse=True)),
    ):
        memory_tops = bw * ops / traffic.total_bytes / 1e3
        print(f"   {label:25s}: {traffic.total_bytes / 2**20:6.1f} MiB payload, "
              f"{traffic.total_bytes / (bw * 1e6):5.2f} ms aggregate transfer floor, "
              f"{min(peak, memory_tops):5.2f} TOPS roof")
    print("   16 x 128 INT8 tile in a matrix with a 4096-byte physical row pitch")
    for transposed in (False, True):
        traffic = matrix_tile_reads(0, 4096 * 128, 4096, 0, 0, 16, 128, 1,
                                    transposed=transposed)
        label = "transpose" if transposed else "row-major"
        print(f"   {label:12s}: {traffic.payload_bytes:4d} useful bytes, "
              f"{traffic.wire_bytes:4d} wire bytes, {traffic.bursts:3d} bursts")

    print("\nC. Batch-one decode, weights streamed once per token (INT8 = 1 byte per parameter)")
    for name, params in (("Llama-3.2-1B", 1.24e9), ("Llama-3.2-3B", 3.21e9), ("8B-class", 8.03e9)):
        row = []
        for eff in (1.0, 0.7):
            t = params / (bw * 1e9 * eff)
            row.append(f"eff {eff:.0%}: {t * 1e3:6.1f} ms ({1 / t:5.1f} tok/s; INT4 {t * 1e3 / 2:5.1f} ms)")
        print(f"   {name:13s} " + " | ".join(row))
    print(f"   array time for 1.24e9 params at peak: {2 * 1.24e9 / (peak * 1e12) * 1e3:.3f} ms per token "
          f"(arrays idle > 99%)")

    print("\nD. Prefill time for a 1.24e9-parameter model, 2*params*S operations")
    for s in (128, 512, 2048):
        ops_s = 2 * 1.24e9 * s
        for label, tops in (("peak", peak), ("tile 128 roof", attainable_tops(128, bw, peak)),
                            ("tile 512 roof", attainable_tops(512, bw, peak))):
            print(f"   S={s:4d} {label:14s} {tops:6.2f} TOPS -> {ops_s / (tops * 1e12) * 1e3:8.1f} ms")

    print("\nE. Output-stationary fill/drain, cycles per tile = K + R + C - 2 when not overlapped")
    for kd in (32, 64, 128, 256, 512, 1024, 4096):
        print(f"   K={kd:5d}: array efficiency {kd / (kd + ROWS + COLS - 2):6.1%}")

    print("\nF. Exact-attention score rate (QK^T, head dim d): one score needs d MACs")
    for d in (64, 128):
        scores_per_cycle = ARRAYS * ROWS * COLS / d
        print(f"   d={d:3d}: {scores_per_cycle:6.0f} scores/cycle -> {scores_per_cycle:6.0f} exp/cycle needed "
              f"({scores_per_cycle * F_HZ / 1e9:7.0f} Gexp/s)")

    print("\nG. Register cost of the accumulators (32-bit, one set / double buffered / carry-save pair)")
    pes = ARRAYS * ROWS * COLS
    for label, bits in (("one set", 32), ("double buffered", 64), ("carry-save pair", 64), ("carry-save, double", 128)):
        print(f"   {label:20s}: {pes * bits / 8 / 1024:6.0f} KiB of flip-flops")

    endpoints, distinct = operand_feed_bytes(4, 4, ROWS, COLS)
    print(f"\nH. Dense operand feed: {endpoints} endpoint B/cycle, "
          f"{distinct} unique B/cycle with phase-aligned broadcast")
    for width_bits in (128, 256, 512):
        no_reuse = (endpoints * 8 + width_bits - 1) // width_bits
        reuse = (distinct * 8 + width_bits - 1) // width_bits
        print(f"   {width_bits:3d}-bit read port: {no_reuse:3d} without reuse, "
              f"{reuse:3d} ideal with broadcast (read service only)")
    activations, weights, selectors = sparse_group_feed_bytes(4, 4, ROWS, COLS)
    print(f"   2:4 candidate: {activations + weights + selectors} unique B/group step "
          f"({activations} A + {weights} packed B + {selectors} metadata)")

    print("\nI. Fused OP-004 single weight pass (BF16/FP16, V=65536, K=4096)")
    for stripe in (32, 512, 1024):
        for padding in (0, 64):
            traffic = argmax_weight_traffic(65536, 4096, 2, stripe, 0, 131072 + padding)
            print(f"   {stripe:4d} channels/stripe, {padding:2d} B row padding: "
                  f"{traffic.bursts:9,d} bursts, {traffic.wire_bytes / 2**20:6.1f} MiB on bus")
        bound, residue = argmax_weight_traffic_bound(65536, 4096, 2, stripe)
        print(f"   {'':4s} layout maximum: {bound.bursts:9,d} bursts, "
              f"witness base mod 4 KiB = {residue} B")

    print("\nJ. Fused OP-004 fixed-schedule read envelope (compute stripe 32, DMA stripe 1024)")
    schedules = (
        ("BF16/FP16 with bias, resident activation", 2, {"bias": True}),
        ("BF16/FP16 with bias, activation reload", 2, {"bias": True, "reload_activation": True}),
        ("INT8, coefficient reread, resident activation", 1, {}),
        ("INT8, retained coefficients, resident activation", 1, {"keep_coefficients": True}),
    )
    for label, element_bytes, options in schedules:
        operands = argmax_fused_read_envelope(65536, 4096, element_bytes, 32, 1024, **options)
        print(f"   {label}: {sum(x.bursts for x in operands.values()):,} bursts, "
              f"{sum(x.wire_bytes for x in operands.values()) / 2**20:.3f} MiB on bus")

    print("\nOP-005 high-width K tile: 128 rows, 4,096 BF16/FP16 features, 64-byte page residue")
    for slice_width in (128, 256, 512, 1024, 4096):
        traffic = attention_k_tile_reads(128, 4096, slice_width, 64, 8192)
        credit_ns = 16 * traffic.wire_bytes / traffic.bursts / axi_gbps()
        print(f"   F={slice_width:4d}: {traffic.bursts:5,d} bursts, "
              f"{traffic.wire_bytes / 2**20:.3f} MiB, "
              f"K-only credit lifetime at line rate <= {credit_ns:.1f} ns")

    print("\nOP-005 P*V operand reads: 32 rows, 128 keys, 128 value features")
    query_rows, keys, value_features = 32, 128, 128
    for stripe_rows, stripe_features in ((1, 64), (4, 16), (8, 8), (32, 2)):
        probability_bytes = 4 * query_rows * keys * ceil(value_features / stripe_features)
        value_bytes = 2 * keys * value_features * ceil(query_rows / stripe_rows)
        feed_bytes = 4 * stripe_rows + 2 * stripe_features
        print(f"   {stripe_rows:2d}x{stripe_features:<2d}: "
              f"{probability_bytes / 1024:5.0f} KiB P + {value_bytes / 1024:5.0f} KiB V, "
              f"{feed_bytes:3d} bytes per key step for 64 products")


if __name__ == "__main__":
    main()
