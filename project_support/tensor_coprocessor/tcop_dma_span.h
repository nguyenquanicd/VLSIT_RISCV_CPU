#ifndef TCOP_DMA_SPAN_H
#define TCOP_DMA_SPAN_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

struct tcop_dma_range {
    uint64_t start;
    uint64_t end; /* Exclusive, as in TCOP_DMA_LIMIT. */
};

/*
 * Calculate the required byte footprint of an already layout-checked reference.
 * For a TLAS rank-one reference, use the byte count of header plus payload
 * as item_bytes and the validated padded sample pitch as stride_bytes[0].
 */
static inline bool tcop_required_bytes(unsigned rank, uint64_t item_bytes,
                                       const uint32_t extent[4],
                                       const uint64_t stride_bytes[4],
                                       uint64_t *required)
{
    if (rank == 0 || rank > 4 || item_bytes == 0 ||
        !extent || !stride_bytes || !required)
        return false;

    uint64_t bytes = item_bytes;
    for (unsigned axis = 0; axis < rank; ++axis) {
        if (extent[axis] == 0 || stride_bytes[axis] == 0)
            return false;
        uint64_t steps = (uint64_t)extent[axis] - 1;
        if (steps > (UINT64_MAX - bytes) / stride_bytes[axis])
            return false;
        bytes += steps * stride_bytes[axis];
    }
    *required = bytes;
    return true;
}

/*
 * Check addressability of a present allocation before DMA. The firewall
 * aperture, reference layout and ownership are checked separately.
 */
static inline bool tcop_check_addressable_dma_range(uint64_t base, uint64_t span,
                                                    uint64_t required, uint64_t alignment,
                                                    unsigned address_bits,
                                                    struct tcop_dma_range *range)
{
    if (!range || required == 0 || span < required || alignment == 0 ||
        (alignment & (alignment - 1)) != 0 ||
        ((base | span) & (alignment - 1)) != 0 ||
        address_bits == 0 || address_bits > 64 ||
        span > UINT64_MAX - base)
        return false;

    /* The last addressed byte, rather than the exclusive end, fits the bus. */
    uint64_t end = base + span;
    if (address_bits < 64 && ((end - 1) >> address_bits) != 0)
        return false;

    range->start = base;
    range->end = end;
    return true;
}

/* Driver aperture preflight for an already validated allocation. */
static inline bool tcop_dma_range_in_aperture(struct tcop_dma_range range,
                                              struct tcop_dma_range aperture)
{
    return range.start < range.end && aperture.start < aperture.end &&
           range.start >= aperture.start && range.end <= aperture.end;
}

/* Driver convenience check. Failed validation leaves the output untouched. */
static inline bool tcop_check_dma_range(uint64_t base, uint64_t span,
                                        uint64_t required, uint64_t alignment,
                                        unsigned address_bits,
                                        struct tcop_dma_range aperture,
                                        struct tcop_dma_range *range)
{
    struct tcop_dma_range addressable;
    if (!range ||
        !tcop_check_addressable_dma_range(base, span, required, alignment,
                                          address_bits, &addressable) ||
        !tcop_dma_range_in_aperture(addressable, aperture))
        return false;
    *range = addressable;
    return true;
}

/*
 * Reference check for an aligned AXI4 INCR burst. axlen is the wire field
 * (beats minus one). The caller checks the configured burst-length cap and
 * ownership of the specific allocation in addition to the global aperture.
 */
static inline bool tcop_check_aligned_incr_burst(uint64_t base, uint8_t axlen,
                                                 unsigned axsize, unsigned bus_bytes,
                                                 unsigned address_bits,
                                                 struct tcop_dma_range aperture,
                                                 struct tcop_dma_range *range)
{
    if (axsize > 7 || bus_bytes == 0 || bus_bytes > 128 ||
        (bus_bytes & (bus_bytes - 1)) != 0)
        return false;

    uint64_t transfer_bytes = UINT64_C(1) << axsize;
    uint64_t span = ((uint64_t)axlen + 1) * transfer_bytes;
    if (transfer_bytes > bus_bytes || span > 4096 - (base & UINT64_C(4095)))
        return false;

    return tcop_check_dma_range(base, span, span, transfer_bytes, address_bits,
                                aperture, range);
}

/* Check alias policy only after both ranges have passed individual validation. */
static inline bool tcop_dma_ranges_overlap(struct tcop_dma_range a,
                                          struct tcop_dma_range b)
{
    return a.start < b.end && b.start < a.end;
}

struct tcop_dma_reference {
    struct tcop_dma_range range;
    bool writable;
};

/*
 * Check already validated, present references. Omit absent optional slots.
 * disjoint_reads is true for OP-006/OP-007, which require pairwise disjoint
 * references. Other operations permit overlap between read-only references.
 */
static inline bool tcop_check_dma_aliases(struct tcop_dma_range descriptor,
                                         const struct tcop_dma_reference *refs,
                                         size_t count, bool disjoint_reads)
{
    if (!refs && count != 0)
        return false;

    for (size_t i = 0; i < count; ++i) {
        if (tcop_dma_ranges_overlap(descriptor, refs[i].range))
            return false;
        for (size_t j = 0; j < i; ++j) {
            if ((disjoint_reads || refs[i].writable || refs[j].writable) &&
                tcop_dma_ranges_overlap(refs[i].range, refs[j].range))
                return false;
        }
    }
    return true;
}

#endif
