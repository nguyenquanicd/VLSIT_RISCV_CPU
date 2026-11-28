# DRAFT for owner review — TOP address-region parameters (Q-G3-01)

Status: **approved by the owner and merged into REF-001 rev 0.40, Section 14.4.20 on 2026-11-28; this file is kept as the review record.** (Original status: draft, not yet in the specification.) Prepared 2026-11-28 by the design-side author (the assistant, with RTL access) because the owner chose "add to the specification" and asked for a draft to approve. It documents the behaviour of the existing RTL (`rtl/non_coherence_cluster/m_vlsit_riscv_cluster_axi_top.sv` parameter list and `rtl/common/vlsit/address_map/m_vlsit_riscv_addr_decode.sv` table check); it does not change the design. On approval the text below is pasted into REF-001 Section 14.4.20 (TOP parameter contract) and Section 8.2, and the verification side authors the testbench binding from that text only (R-103).

Bản nháp, chưa nằm trong spec. Mô tả hành vi RTL hiện có, không đổi thiết kế. Sau khi duyệt sẽ đưa vào REF-001 mục 14.4.20 và 8.2; phía kiểm chứng chỉ dùng đoạn spec đó để nối testbench.

## Proposed text

### TOP address-region parameters

The AXI TOP `m_vlsit_riscv_cluster_axi_top` exposes the shared PMA/router table (REQ-IF-011) through six elaboration parameters. Entry *i* of the table is the *i*-th element of each array; only entries `0 .. PARA_ADDR_REGION_NUM-1` are active, entries above are ignored.

| Parameter | SystemVerilog declaration | Meaning | Default |
|---|---|---|---|
| `PARA_ADDR_REGION_NUM` | `parameter logic [31:0]` | Number of active entries, 1 to 16; any other value is an elaboration error | `32'd1` |
| `PARA_ADDR_REGION_BASE_LO` | `parameter logic [31:0] PARA_ADDR_REGION_BASE_LO [0:15]` (unpacked array of sixteen 32-bit words, index = entry) | Bits 31:0 of the entry base byte address | entry 0 = `32'h8000_0000`, others 0 |
| `PARA_ADDR_REGION_BASE_HI` | `parameter logic [31:0] <name> [0:15]` | Bits 63:32 of the entry base byte address | all 0 |
| `PARA_ADDR_REGION_SIZE_LO` | `parameter logic [31:0] <name> [0:15]` | Bits 31:0 of the entry length in bytes | entry 0 = `32'h4000_0000`, others 0 |
| `PARA_ADDR_REGION_SIZE_HI` | `parameter logic [31:0] <name> [0:15]` | Bits 63:32 of the entry length in bytes | all 0 |
| `PARA_ADDR_REGION_TYPE` | `parameter logic [31:0] <name> [0:15]` | Bits 1:0 = class; bits 31:2 must be 0 | all 0 |

The entry base is `{BASE_HI[i], BASE_LO[i]}` and its length is `{SIZE_HI[i], SIZE_LO[i]}`. The entry covers the half-open byte range `[base, base + length)`.

**Class encoding (`TYPE[1:0]`):** `2'b00` cacheable, `2'b01` normal uncached, `2'b10` MMIO, `2'b11` reserved and invalid (REQ-IF-011).

### Table validity rules

A table is valid only if all of the following hold for the active entries. An invalid table drives the decoder output `o_config_valid` low and the cluster does not accept accesses; the rules are checked inside the decoder, they are not an elaboration failure, except the range of `PARA_ADDR_REGION_NUM`.

1. `PARA_ADDR_REGION_NUM` is in 1..16.
2. Every base is 16-byte aligned, every length is a non-zero multiple of 16 bytes, `base[63:56]` is 0 and `base + length` does not exceed 2^56 (PLEN = 56, REQ-IF-011).
3. `TYPE[31:2]` is 0 and `TYPE[1:0]` is not `2'b11`.
4. Entries do not overlap.
5. **Exactly one entry has class `00`, and it is entry 0.** Its length is a power of two and its base is aligned to its length.

Rules 5 and the power-of-two/alignment condition are stricter than the wording of REQ-IF-011 ("one cacheable normal-memory entry") and are recorded here so that the specification matches the design.

### Cluster-profile bound (RV32 HDS REQ-XL-011)

For the 32-bit cluster every active entry also satisfies `base + length <= 2^34`. This is an integration obligation checked by a parameter-set script before build (question log Q-G0-09 C); the RTL does not enforce it.

### Campaign parameter set (CFG-RV32-2, question log Q-G0-03 A)

| Entry | Class | Base | Length | Purpose |
|---|---|---|---|---|
| 0 | `00` cacheable | `0x0_8000_0000` | 1 GiB (`0x4000_0000`) | program and data |
| 1 | `10` MMIO | `0x0_1000_0000` | 256 MiB (`0x1000_0000`) | test control, IRQ control |
| 2 | `10` MMIO | `0x0_0000_0000` | 4 KiB (`0x1000`) | debug ROM at 0x800/0x808 |
| 3 | `01` normal uncached | `0x0_4000_0000` | 256 MiB (`0x1000_0000`) | uncached RAM |
| 4 | `01` normal uncached | `0x3_C000_0000` | 1 GiB (`0x4000_0000`), ends at 2^34 | high-address uncached RAM |

Elaboration form (`PARA_ADDR_REGION_NUM = 5`):

```systemverilog
.PARA_ADDR_REGION_NUM     (32'd5),
.PARA_ADDR_REGION_BASE_LO ('{0:32'h8000_0000, 1:32'h1000_0000, 2:32'h0000_0000, 3:32'h4000_0000, 4:32'hC000_0000, default:32'd0}),
.PARA_ADDR_REGION_BASE_HI ('{4:32'h0000_0003, default:32'd0}),
.PARA_ADDR_REGION_SIZE_LO ('{0:32'h4000_0000, 1:32'h1000_0000, 2:32'h0000_1000, 3:32'h1000_0000, 4:32'h4000_0000, default:32'd0}),
.PARA_ADDR_REGION_SIZE_HI ('{default:32'd0}),
.PARA_ADDR_REGION_TYPE    ('{0:32'd0, 1:32'd2, 2:32'd2, 3:32'd1, 4:32'd1, default:32'd0})
```

The table satisfies rules 1-5: no overlap, exactly one cacheable entry at index 0 (1 GiB, aligned to 1 GiB), highest end `0x4_0000_0000 = 2^34`.

## Points for the owner to confirm

1. Rule 5 (cacheable entry must be entry 0, power-of-two length, base aligned to length) is documented as design behaviour. Confirm this is intended and not an RTL limitation to be relaxed later.
2. An invalid table is signalled only by an internal decoder output, not by an elaboration error. Confirm this should stay as stated (it matches question log Q-G0-09 C).
3. The campaign table, including entry 4 ending exactly at 2^34, is as approved in Q-G0-03 A.

## Source of this draft (for traceability)

`m_vlsit_riscv_cluster_axi_top.sv` parameter list (declarations, defaults, value comments) and `m_vlsit_riscv_addr_decode.sv` function `f_region_table_valid`. REF-001 REQ-IF-011 and Section 8.1/8.2 for the class encoding.
