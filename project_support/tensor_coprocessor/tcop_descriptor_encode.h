#ifndef TCOP_DESCRIPTOR_ENCODE_H
#define TCOP_DESCRIPTOR_ENCODE_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>

#include "tcop_descriptor_layout.h"

/* Serialize wire bytes explicitly. Do not overlay native C structs on DMA buffers. */
static inline void tcop_put_le(uint8_t *dst, uint64_t value, unsigned bytes)
{
    for (unsigned i = 0; i < bytes; ++i) {
        dst[i] = (uint8_t)value;
        value >>= 8;
    }
}

/* Construct the R-type word. RV64 canonically encodes rs2 as x0. */
static inline bool tcop_encode_instruction_word(unsigned xlen, unsigned operation,
                                                unsigned precision, unsigned rd,
                                                unsigned rs1, unsigned rs2,
                                                uint32_t *word)
{
    if (!word || (xlen != 32 && xlen != 64) ||
        tcop_descriptor_schema_bytes(operation, 0) == 0 ||
        precision > TCOP_PRECISION_FP16 || rd > 31 || rs1 > 31 || rs2 > 31)
        return false;

    uint32_t high_source = xlen == 32 ? rs2 : 0;
    *word = ((uint32_t)operation << 25) | (high_source << 20) |
            ((uint32_t)rs1 << 15) | ((uint32_t)precision << 12) |
            ((uint32_t)rd << 7) | TCOP_MAJOR_OPCODE;
    return true;
}

/* Initialize the selected fixed schema with reserved and optional bytes zero. */
static inline bool tcop_init_descriptor(uint8_t *buffer, size_t capacity,
                                        unsigned operation, unsigned precision,
                                        unsigned variant)
{
    unsigned size = tcop_descriptor_schema_bytes(operation, variant);

    if (!buffer || size == 0 || capacity < size || precision > TCOP_PRECISION_FP16)
        return false;

    memset(buffer, 0, size);
    memcpy(buffer + TCOP_HEADER_MAGIC_OFFSET, "TCOP", TCOP_HEADER_MAGIC_BYTES);
    tcop_put_le(buffer + TCOP_HEADER_SCHEMA_MAJOR_OFFSET, TCOP_SCHEMA_MAJOR,
                TCOP_HEADER_SCHEMA_MAJOR_BYTES);
    tcop_put_le(buffer + TCOP_HEADER_SCHEMA_MINOR_OFFSET, TCOP_SCHEMA_MINOR,
                TCOP_HEADER_SCHEMA_MINOR_BYTES);
    tcop_put_le(buffer + TCOP_HEADER_HEADER_BYTES_OFFSET, TCOP_HEADER_BYTES,
                TCOP_HEADER_HEADER_BYTES_BYTES);
    tcop_put_le(buffer + TCOP_HEADER_OPERATION_ID_ECHO_OFFSET, operation,
                TCOP_HEADER_OPERATION_ID_ECHO_BYTES);
    tcop_put_le(buffer + TCOP_HEADER_PRECISION_ID_ECHO_OFFSET, precision,
                TCOP_HEADER_PRECISION_ID_ECHO_BYTES);
    tcop_put_le(buffer + TCOP_HEADER_SCHEMA_BYTES_OFFSET, size,
                TCOP_HEADER_SCHEMA_BYTES_BYTES);
    tcop_put_le(buffer + TCOP_HEADER_IMPLEMENTATION_VARIANT_OFFSET, variant,
                TCOP_HEADER_IMPLEMENTATION_VARIANT_BYTES);
    return true;
}

/*
 * Validate a complete, successfully fetched common header. Expected selectors
 * come from the accepted instruction and the build. The declared schema size
 * never determines how many bytes to read.
 */
static inline uint32_t tcop_validate_descriptor_header(const uint8_t *header,
                                                        size_t available,
                                                        unsigned operation,
                                                        unsigned precision,
                                                        unsigned variant)
{
    unsigned size = tcop_descriptor_schema_bytes(operation, variant);
    uint8_t expected_schema_bytes[TCOP_HEADER_SCHEMA_BYTES_BYTES];

    if (!header || available < TCOP_HEADER_BYTES || size == 0 ||
        precision > TCOP_PRECISION_FP16)
        return TCOP_ERR_DESCRIPTOR_FORMAT;

    tcop_put_le(expected_schema_bytes, size, sizeof expected_schema_bytes);
    if (memcmp(header + TCOP_HEADER_MAGIC_OFFSET, "TCOP", TCOP_HEADER_MAGIC_BYTES) ||
        header[TCOP_HEADER_SCHEMA_MAJOR_OFFSET] != TCOP_SCHEMA_MAJOR ||
        header[TCOP_HEADER_SCHEMA_MAJOR_OFFSET + 1] != 0 ||
        header[TCOP_HEADER_SCHEMA_MINOR_OFFSET] != TCOP_SCHEMA_MINOR ||
        header[TCOP_HEADER_SCHEMA_MINOR_OFFSET + 1] != 0 ||
        header[TCOP_HEADER_HEADER_BYTES_OFFSET] != TCOP_HEADER_BYTES ||
        header[TCOP_HEADER_HEADER_BYTES_OFFSET + 1] != 0 ||
        header[TCOP_HEADER_OPERATION_ID_ECHO_OFFSET] != operation ||
        header[TCOP_HEADER_PRECISION_ID_ECHO_OFFSET] != precision ||
        memcmp(header + TCOP_HEADER_SCHEMA_BYTES_OFFSET, expected_schema_bytes,
               sizeof expected_schema_bytes))
        return TCOP_ERR_DESCRIPTOR_FORMAT;

    for (size_t i = TCOP_HEADER_IMPLEMENTATION_VARIANT_OFFSET + 1;
         i < TCOP_HEADER_BYTES; ++i) {
        if (header[i] != 0)
            return TCOP_ERR_DESCRIPTOR_FORMAT;
    }

    if (header[TCOP_HEADER_IMPLEMENTATION_VARIANT_OFFSET] != variant)
        return TCOP_ERR_DESCRIPTOR_MODE;
    return TCOP_STATUS_OK;
}

/*
 * slot_offset is the generated reference offset for this operation.
 * Use only on a buffer initialized by tcop_init_descriptor.
 * schema_size is the exact initialized descriptor size, not allocation capacity.
 * The caller validates reference presence, rank and addresses per the ISA/HDS.
 */
static inline bool tcop_encode_tref(uint8_t *buffer, size_t schema_size,
                                    size_t slot_offset, uint64_t base,
                                    uint64_t span, const uint32_t extent[4],
                                    const uint64_t stride_bytes[4])
{
    const size_t ref_start = TCOP_CONFIG_OFFSET + TCOP_CONFIG_BYTES;

    if (!buffer || !extent || !stride_bytes || schema_size < TCOP_HEADER_BYTES)
        return false;

    unsigned operation = buffer[TCOP_HEADER_OPERATION_ID_ECHO_OFFSET];
    unsigned variant = buffer[TCOP_HEADER_IMPLEMENTATION_VARIANT_OFFSET];
    size_t ref_end = tcop_descriptor_ref_end(operation, variant);
    if (schema_size != tcop_descriptor_schema_bytes(operation, variant) ||
        slot_offset < ref_start || (slot_offset - ref_start) % TCOP_TREF_BYTES != 0 ||
        slot_offset > ref_end || ref_end - slot_offset < TCOP_TREF_BYTES)
        return false;

    uint8_t *ref = buffer + slot_offset;
    tcop_put_le(ref + TCOP_TREF_BASE_ADDR_OFFSET, base, TCOP_TREF_BASE_ADDR_BYTES);
    tcop_put_le(ref + TCOP_TREF_SPAN_BYTES_OFFSET, span, TCOP_TREF_SPAN_BYTES_BYTES);
    for (unsigned axis = 0; axis < 4; ++axis) {
        tcop_put_le(ref + TCOP_TREF_EXTENT_OFFSET + axis * sizeof(uint32_t),
                    extent[axis], sizeof(uint32_t));
        tcop_put_le(ref + TCOP_TREF_STRIDE_BYTES_OFFSET + axis * sizeof(uint64_t),
                    stride_bytes[axis], sizeof(uint64_t));
    }
    return true;
}

#endif
