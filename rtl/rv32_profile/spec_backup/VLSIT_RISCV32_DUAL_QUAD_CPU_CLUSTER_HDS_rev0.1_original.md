---
document_type: asic_ip_design_specification
document_id: "VLSIT-RISCV32-DUAL-QUAD-CPU-CLUSTER"
title: "VLSIT RISC-V 32-bit Dual/Quad CPU Cluster Design Specification"
ip_name: "VLSIT RISC-V 32-bit Dual/Quad CPU Cluster"
version: "0.1"
status: "Draft - RV32 profile of the 64-bit cluster; no RTL, lint or simulation exists for this profile yet"
language: "English"
rtl_rules: "VLSIT_RTL_Design_Rule.md v2"
csr_spec: "../specification/VLSIT_RISCV_CPU_Cluster_CSR.xlsx"
---

# VLSIT RISC-V 32-bit Dual/Quad CPU Cluster Design Specification

**Revision 0.1, 2026-11-25.** First draft. Defines a 32-bit (RV32) profile of the VLSIT dual/quad CPU cluster. The cluster architecture, coherence protocol, interfaces and CSR map are those of the 64-bit cluster; only the CVA6 core configuration and the CPU tile adapter change. The Vietnamese companion summary is [README.md](README.md).

## Document map

- Sections 1 to 4: purpose, references, requirements and configurations of the RV32 profile.
- Section 5: what changes in the architecture (only the CPU tile) and what is reused.
- Section 8: the complete CVA6 configuration, field by field, and every derived width.
- Sections 6, 9, 10: interface, width and ISA-level behavior differences.
- Sections 13 to 15: PPA expectations, the RTL change contract and the verification plan.
- Section 20: decisions, assumptions and open items.
- Base specification (64-bit, normative for everything not changed here): [VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md](../specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md).

## 1. Purpose, scope, and product context

### 1.1 Purpose and scope

This specification defines the RV32 profile of the VLSIT RISC-V dual/quad CPU cluster. It integrates two or four identical 32-bit application-class CVA6 harts into one internally cache-coherent cluster, with the same MESI D-cache coherence, CCU, sharer directory, shared LLC, AXI4 memory and MMIO boundaries, AXI4-Lite control, PMU and per-hart debug as the 64-bit cluster.

The profile is built on one design rule: **change the core, keep the cluster**. Every interface that the cluster sees stays as in the 64-bit design: AXI data 64-bit, AXI address 64-bit, native AXI ID 4-bit, 16-byte cache line, 52-bit cluster line address, HPDcache write-back. The CVA6 core is rebuilt from an RV32 configuration package, and the CPU tile gains two width adapters between the core and the unchanged cluster ports.

Included: two/four-hart elaboration; CVA6 RV32 configuration with Sv32 MMU and caches; RV32 tile adaptation; all cluster components of the base specification without functional change.

Excluded: a cache-less or M-mode-only core (this is not the FU3 MCU configuration); RV32 double-precision floating point; 64-bit software compatibility (RV64 binaries do not run); any change to the CCU, directory, LLC, router, PMU or CSR behavior; an external coherent (ACE) port.

### 1.2 Deployment assumptions

- Target software: an RV32 Linux kernel with Sv32 virtual memory, or an RV32 RTOS. The cluster stays Linux-capable (S-mode, U-mode, MMU, atomics).
- Physical address space: 34-bit (16 GiB) from the core. Every address region of the SoC that the cores use shall lie below 2^34.
- Memory size: Sv32 gives 4 GiB of virtual address space per process. A Linux kernel needs high memory above roughly 1 GiB of RAM (INFERENCE from the Sv32 kernel/user split); the product should size RAM accordingly.
- Library, corner, SRAM and workload are the same open dependencies as in the base specification (base DEP-007, OPEN-ASIC).

### 1.3 Feature summary

| Feature ID | Feature | Required / optional | Configuration condition | Requirements |
|---|---|---|---|---|
| FEAT-101 | Two- or four-hart CVA6 RV32 cluster | Required | PARA_CPU_NUM is 2 or 4 | REQ-XL-001, REQ-XL-002 |
| FEAT-102 | RV32IMAFC with B, Zcb, Zicond, Zicbom, Zicntr, Zihpm and Zkn | Required | RV32 configuration package | REQ-XL-003, REQ-XL-004 |
| FEAT-103 | Sv32 virtual memory, S-mode and U-mode | Required | MmuPresent=1, RVS=1, RVU=1 | REQ-XL-005 |
| FEAT-104 | Internal MESI coherence of the D-caches, unchanged | Required | Same CCU, directory and probe engine | REQ-XL-009 |
| FEAT-105 | Unchanged 64-bit AXI and 52-bit coherence interfaces at the tile boundary | Required | Tile width adapters | REQ-XL-006, REQ-XL-007, REQ-XL-008 |
| FEAT-106 | Same TOP port list and CSR map as the 64-bit cluster | Required | AXI TOP | REQ-XL-010 |

### 1.4 Real-world applications of the features

Values are proposal baselines of this specification, not measured workload limits.

| Feature ID | Real-world application | What the application needs | Proposed measurable values | Consequence if missing or wrong | Requirements | Source |
|---|---|---|---|---|---|---|
| FEAT-101 | SMP Linux or multi-core RTOS on an industrial controller or edge device with modest RAM | Two or four coherent harts without 64-bit software | 2 or 4 harts; XLEN=32 | Software cannot use the harts in parallel | REQ-XL-001, REQ-XL-002 | ASM-101 |
| FEAT-102 | Control, protocol and crypto code compiled for RV32 | Compact code and fast bit, crypto and single-float operations | RV32IMAFC + B + Zcb + Zkn; ABI ilp32f | Larger code or software emulation of these operations | REQ-XL-003, REQ-XL-004 | DEC-102 |
| FEAT-103 | Process isolation under Linux | Virtual memory and privilege levels | Sv32, S-mode, U-mode, PMP 8 | No Linux user space or isolation | REQ-XL-005 | REF-002 |
| FEAT-104 | Workers sharing queues and descriptors in normal memory | Coherent ownership of shared lines | MESI, 16-byte line, as base | Stale data between harts | REQ-XL-009 | REF-001 |
| FEAT-105 | Reuse of the verified 64-bit cluster | No change at the cluster interfaces | 64-bit AXI, 52-bit line ports at the tile | Cluster blocks must be redesigned | REQ-XL-006, REQ-XL-007, REQ-XL-008 | DEC-104 |
| FEAT-106 | Same SoC integration and driver as the 64-bit cluster | Identical ports and CSR map | 111 ports, same CSR workbook | SoC and driver need a second integration | REQ-XL-010 | DEC-105 |

The profile trades 64-bit data processing speed (about twice the instructions for 64-bit operations) for a smaller register file, narrower datapaths and narrower cache and TLB tags.

## 2. Normative references and precedence

### 2.1 Normative references

| ID | Document | Use |
|---|---|---|
| REF-001 | VLSIT RISC-V Dual/Quad CPU Cluster Design Specification, revision 0.36 ([base HDS](../specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md)) | Normative for every section, requirement, interface, FSM, register and test that this document does not change |
| REF-002 | RISC-V Unprivileged ISA (RV32I base, M, A, F, C, B, Zcb, Zicond, Zicbom, Zkn) and Privileged ISA (Sv32, PMP) | ISA behavior of the RV32 harts |
| REF-003 | OpenHW CVA6 source as pinned in `rtl/common/modified/cva6` and `rtl/common/third_party/cva6` | Core implementation; `build_config_pkg.sv` derives the RV32 widths |
| REF-004 | Upstream CVA6 RV32 packages `cv32a65x_config_pkg.sv` and `cv32a6_imac_sv32_config_pkg.sv` | Evidence that CVA6 RV32 is used with 64-bit AXI data and with Sv32 |
| REF-005 | AMBA AXI4 / AXI4-Lite IHI 0022H and PULP AWATOP extension | Unchanged boundary protocols (see REF-001 Section 2.3) |

### 2.2 Source-of-truth and conflict handling

This document overrides REF-001 only where it states a change. Everything else in REF-001 applies to the RV32 profile without restatement. When the two documents conflict on a point this document does not mention, REF-001 wins and the conflict is recorded as an open item. Requirement and test identifiers of REF-001 are written here as "base" identifiers (for example base SYS-002) to keep them apart from the RV32 identifiers.

**Naming rule:** VLSIT RTL Design Rule v2 (the default rule of vlsit-rtl-generator), the same rule as REF-001: m_ module prefix, i_/o_ port prefixes, lowercase snake_case. The new adapter signals follow it.

### 2.3 Compliance declaration

| Standard | Revision / profile | Role implemented | Options | Deviations |
|---|---|---|---|---|
| RISC-V ISA | RV32IMAFC + Zba/Zbb/Zbc/Zbs (RVB) + Zcb + Zicond + Zicbom + Zicntr + Zihpm + Zkn | Two/four application harts | XLEN=32, FLEN=32, Sv32, PMP 8 entries | No D extension; misa.MXL, mstatus.SXL/UXL fixed to 32-bit |
| AMBA AXI4 + AWATOP | As REF-001 | Manager on memory and MMIO | 64-bit address and data, native ID 4 bits | None: core physical addresses use bits 33:0, bits 63:34 are zero |
| AMBA AXI4-Lite | As REF-001 | Subordinate for control | 32-bit address and data | None |

## 3. Requirements and traceability

### 3.1 Normative requirements

| ID | Requirement using shall/should/may | Source | Applies to | Verification method |
|---|---|---|---|---|
| REQ-XL-001 | Every active tile shall instantiate CVA6 with the RV32 configuration package of Section 8.2 (proposed file `cv32a6_imafc_sv32_hpdcache_wb_config_pkg.sv`). This replaces base SYS-002 for this profile only. | This specification; DEC-101 | CFG-RV32-2/4 | TEST-101 |
| REQ-XL-002 | The cluster shall support PARA_CPU_NUM equal to 2 or 4, with the same hart indexing, boot address fanout and per-hart interrupt and debug vectors as REF-001. | REF-001 base SYS-001, SYS-003 | CFG-RV32-2/4 | TEST-102 |
| REQ-XL-003 | The harts shall implement XLEN=32 with misa.MXL=1 and mstatus.SXL/UXL equal to the 32-bit encoding. RV64-only instructions (for example ADDW, LD, SD, AMO*.D, LR.D, SC.D) shall raise an illegal-instruction exception. | REF-002; DEC-101 | All | TEST-103 |
| REQ-XL-004 | The harts shall implement F without D (FLEN=32). Software shall use an ABI with single-precision hardware floating point (ilp32f). | DEC-102 | All | TEST-104 |
| REQ-XL-005 | The harts shall implement S-mode, U-mode and an Sv32 MMU with a 2-level page-table walk and 34-bit physical addresses. | REF-002; REF-003 build_config_pkg.sv:31-43, 200-202 | All | TEST-105 |
| REQ-XL-006 | The CVA6 AXI configuration shall stay at 64-bit address, 64-bit data, 4-bit ID and 64-bit user width, so the AXI records and every AXI port of the tile and cluster are unchanged. Core physical addresses shall appear on bits 33:0 with bits 63:34 zero. | DEC-103 | All | TEST-106 |
| REQ-XL-007 | The tile shall zero-extend each 30-bit cache-line address leaving the core to the 52-bit cluster width, and shall pass only bits 29:0 of each 52-bit line address entering the core. Bits 51:30 of every entering line address shall be zero; an assertion shall check it. | DEC-104 | All | TEST-107, SVA-101 |
| REQ-XL-008 | The tile shall pass bits 31:0 of i_boot_addr and i_hart_id to the core and zero-extend the 32-bit CMO virtual address and PC outputs to the 64-bit tile ports. Bits 63:32 of i_boot_addr shall be zero; an assertion shall check it. | DEC-104 | All | TEST-108, SVA-102 |
| REQ-XL-009 | The CCU, sharer directory, probe scheduler, transaction table, line locks, CMO controller, LLC, router, PMU and CSR blocks shall be reused without functional change. Their behavior shall match REF-001 with line addresses whose bits 51:30 are zero. | DEC-105 | All | TEST-109 |
| REQ-XL-010 | The AXI TOP port list, port widths and CSR workbook shall be identical to REF-001 Section 6.2 and the cluster CSR workbook. | DEC-105 | AXI TOP | TEST-110 |
| REQ-XL-011 | Every active entry of the shared address-region table (PARA_ADDR_REGION_*) shall satisfy base + size <= 2^34. The static executable regions of the configuration package shall satisfy the same bound. | REQ-XL-005 consequence | All | TEST-111 |
| REQ-XL-012 | The HPDcache shall operate with a 32-bit word (wordWidth=XLEN) and unchanged 16-byte lines and 64-bit memory data. Probe, dirty-owner writeback, flush and CMO results shall be identical in content and AXI beat count (two 64-bit beats per line) to REF-001. | REF-003 cva6_hpdcache_subsystem.sv:284-293 | All | TEST-112 |
| REQ-XL-013 | The 64-bit counters (mcycle, minstret, mhpmcounter) shall be readable through the RV32 high/low CSR pairs, and the cluster PMU shall receive the same per-hart event vector as in REF-001 (PerfCounterEn=1). | REF-002; DEC-102 | All | TEST-113 |
| REQ-XL-014 | The three timing profiles (PARA_TIMING_PROFILE 0, 1, 2) of REF-001 shall elaborate and pass lint for 2 and 4 harts with the RV32 configuration. | REF-001 Section 8.3 | All profiles | TEST-114 |

**Disposition of base requirements.** All base requirements apply unchanged except: base SYS-002 is replaced by REQ-XL-001; base FEAT-001 "64-bit XLEN" reads "32-bit XLEN"; base requirements that name 64-bit or 56-bit address widths apply with the widths of Section 9. No base requirement is removed.

### 3.2 Requirement change control

Any change to the RV32 configuration package, the AXI widths, the line width or the tile adapters requires a new revision of this document and of the traceability in Section 19. A change to a reused cluster block is made in REF-001 first and then inherited.

## 4. Features and configurations

| Configuration | Contents | Selection mechanism | Status |
|---|---|---|---|
| CFG-RV32-2 | Two RV32 harts, AXI TOP | RV32 filelist + PARA_CPU_NUM=2 | Specified, no RTL yet |
| CFG-RV32-4 | Four RV32 harts, AXI TOP | RV32 filelist + PARA_CPU_NUM=4 | Specified, no RTL yet |
| CFG-AXI-2/4 (base) | 64-bit harts | Base filelist | Implemented (REF-001) |

The XLEN choice is a compile-time filelist choice, not a TOP parameter: CVA6 takes its configuration from the package `cva6_config_pkg`, and SystemVerilog cannot select a package by parameter. The RV32 filelist replaces only the configuration package file and adds the adapted tile source; every other file is shared with the 64-bit filelist.

## 5. Architecture

### 5.1 Overview and block responsibilities

| Block | RV32 status | Change |
|---|---|---|
| m_vlsit_riscv_cluster_axi_top, m_vlsit_riscv_cluster_core | Reused | None |
| m_vlsit_riscv_cpu_tile_array | Reused | None (instantiates the RV32 tile through the shared module name) |
| m_vlsit_riscv_cpu_tile | Modified | CVA6 built from the RV32 package; new line-address and virtual-address adapters (Section 14.3) |
| CVA6 core and HPDcache (modified sources) | Reused source, new configuration | No source change expected; widths follow XLEN/PLEN/VLEN |
| Coherence: coh_fabric, sharer_directory, coh_txn_table, probe_scheduler, coh_bank_arb, tile_coh_adapter, cache_line_locks, hpd_probe_engine | Reused | None; line addresses carry zero upper bits |
| Interconnect: axi_route, axi_mem_mux, axi_mmio, axi_dw_adapter | Reused | None; AXI stays 64-bit |
| LLC (m_vlsit_axi_llc), CMO arbiter/controller, PMU, fault record, CSR, AXI4-Lite bridge | Reused | None |

### 5.2 Block diagram

The cluster block diagram is that of REF-001 Section 5.2 ([cluster core connectivity](../specification/figures/post_a06/m_vlsit_riscv_cluster_core.svg)). The only internal change is inside each CPU tile:

![RV32 CPU tile with width adapters](figures/m_vlsit_riscv_cpu_tile_rv32.svg)

*Figure 5-1. RV32 CPU tile. The two adapters are new; the CVA6 instance takes the RV32 configuration package; the AXI record slicer and region decode are reused. Sources: [draw.io](figures/m_vlsit_riscv_cpu_tile_rv32.drawio), [JSON](figures/m_vlsit_riscv_cpu_tile_rv32.json).*

### 5.3 Transaction and dataflow

Every transaction flow of REF-001 Section 5.3 and 10.5 is unchanged: ownership request, directory lookup, two-phase probe, owner writeback of a 16-byte line as two 64-bit AXI beats, refill, CMO and MMIO. The only difference is the address content: a core physical address has 34 significant bits, so the line address has 30 significant bits and bits 51:30 are zero everywhere in the cluster.

### 5.4 Invariants

- I-X32-1: every line address in the cluster has bits 51:30 equal to zero.
- I-X32-2: every AXI address issued by a hart has bits 63:34 equal to zero.
- I-X32-3: AXI beat counts, IDs and ordering are identical to the 64-bit cluster for the same access.
- All invariants of REF-001 Section 5.4 hold.

### 5.5 Component provenance

Only `m_vlsit_riscv_cpu_tile` (MODIFY) and the RV32 configuration package (NEW, derived from the 64-bit package) are new for this profile. Provenance of every other component is as in REF-001 Section 5.5.

## 6. External interfaces and ports

### 6.1 Interface inventory

The interface inventory of REF-001 Section 6.1 applies without change: AXI4-Lite control, AXI4 MMIO, PULP AXI4 memory with AWATOP, boot address, per-hart interrupts, per-hart debug and the PMU/fatal interrupt outputs.

### 6.2 Complete AXI-profile port list

The port list is identical to REF-001 Section 6.2 (111 ports, same names, directions and widths). The meaning changes only as follows:

| Port | Direction | Width | Signal type | Clock domain | Meaning / function |
|---|---|---|---|---|---|
| i_boot_addr | Input | 64 | Data, static | CLK-CLUSTER | Bits 31:0 are the shared boot address; bits 63:32 shall be zero (REQ-XL-008). |
| o_axi_mem_awaddr | Output | 64 | Data, AXI address | CLK-CLUSTER | Bits 33:0 carry the physical address; bits 63:34 are zero. |
| o_axi_mem_araddr | Output | 64 | Data, AXI address | CLK-CLUSTER | Bits 33:0 carry the physical address; bits 63:34 are zero. |
| o_axi_mmio_awaddr | Output | 64 | Data, AXI address | CLK-CLUSTER | Bits 33:0 carry the physical address; bits 63:34 are zero. |
| o_axi_mmio_araddr | Output | 64 | Data, AXI address | CLK-CLUSTER | Bits 33:0 carry the physical address; bits 63:34 are zero. |

Every other port (AXI data, strobe, ID, AWATOP, responses, interrupts, debug, AXI4-Lite, PMU and fatal outputs) keeps the meaning of REF-001 Section 6.2. RV32 AMOs use only 4-byte AWATOP accesses.

### 6.3 Internal interface contracts

The tile-to-core interface changes width; the tile-to-cluster interface does not:

| Signal group | Core side (RV32) | Tile port (unchanged) | Adapter rule |
|---|---|---|---|
| Boot address, hart ID | 32 bits (VLEN, XLEN) | 64 bits | Pass bits 31:0; assert boot address bits 63:32 are zero |
| CMO request and entry virtual address, CMO PC | 32 bits (VLEN) | 64 bits | Zero-extend |
| CMO request and entry line address | 30 bits (PLEN-4) | 52 bits | Zero-extend |
| D-cache flush-ack line, coherence access/victim/own-request line, probe-response line | 30 bits | 52 bits | Zero-extend |
| Line locks (16 entries), probe-request line, probe-query line, grant line | 30 bits | 52 bits | Pass bits 29:0; assert bits 51:30 are zero |
| AXI request and response records | 470 / 210 bits | 470 / 210 bits | None (AxiUserWidth kept at 64) |

### 6.4 Interrupt and debug obligations

Unchanged from REF-001 Section 6.4. The irq_i mapping (bit 0 MEIP, bit 1 SEIP) is the same for RV32.

## 7. Clock, reset, and power

### 7.1 Clock domains

One synchronous cluster clock, as in REF-001 Section 7.1.

### 7.2 CDC and RDC

No new crossing. The adapters are combinational wiring inside the tile clock domain.

### 7.3 Reset domains and sequencing

Unchanged from REF-001 Section 7.3. i_boot_addr shall be stable and its bits 63:32 zero while reset is asserted and through reset release.

### 7.4 Power intent

Unchanged from REF-001 Section 7.4.

## 8. Parameters and elaboration configurations

### 8.1 TOP parameters

All TOP parameters, ranges and defaults are those of REF-001 Section 8.1, with one added bound:

| Parameter | RV32 rule |
|---|---|
| PARA_CPU_NUM | 2 or 4, default 4 (unchanged) |
| PARA_ADDR_REGION_BASE_*/SIZE_* | Every active region below 2^34 (REQ-XL-011). The default cacheable region 0x8000_0000, 1 GiB, satisfies it. |
| PARA_TIMING_PROFILE, PARA_COH_TXN_NUM, PARA_LLC_*, PARA_AXI_MEM_DATA_W, PARA_PMU_*, PARA_AXIL_BASE_ADDR | Unchanged |

### 8.2 CVA6 configuration package (complete)

The RV32 package is a copy of `rtl/common/modified/cva6/core/include/cv64a6_imafdc_sv39_hpdcache_wb_config_pkg.sv` with three localparam changes:

| Localparam | 64-bit package | RV32 package |
|---|---|---|
| CVA6ConfigXlen | 64 | 32 |
| CVA6ConfigRVD | 1 | 0 |
| CVA6ConfigDataUserWidth | CVA6ConfigXlen | 64 (fixed, no longer CVA6ConfigXlen) |

The table below lists every field of `cva6_cfg` as it resolves in each package. "Changed" marks a different value; "Pinned" marks a field whose value is kept but whose definition no longer follows XLEN. The cached and non-idempotent region fields are overridden at elaboration by `build_config_with_addr_regions` from the shared region table (REF-001 DEC-037); the executable region fields are not.

| Field | 64-bit value | RV32 value | Status | Reason |
|---|---|---|---|---|
| XLEN | 64 | 32 | Changed | Selects the 32-bit integer ISA (RV32). CVA6 derives PLEN=34, VLEN-based Sv32 and 2-level page walk from it. |
| VLEN | 64 | 32 | Changed | Virtual address width equals XLEN for Sv32. |
| FpgaEn | 0 | 0 | Same |  |
| FpgaAlteraEn | 0 | 0 | Same |  |
| TechnoCut | 0 | 0 | Same |  |
| SuperscalarEn | 0 | 0 | Same |  |
| ALUBypass | 0 | 0 | Same |  |
| NrCommitPorts | 2 | 2 | Same |  |
| AxiAddrWidth | 64 | 64 | Same |  |
| AxiDataWidth | 64 | 64 | Same |  |
| AxiIdWidth | 4 | 4 | Same |  |
| AxiUserWidth | 64 | 64 | Pinned | Kept at 64 instead of following XLEN so that the packed AXI request (470 bits) and response (210 bits) records sliced at fixed offsets in the tile do not move. AXI user is disabled (DataUserEn=0). |
| MemTidWidth | 4 | 4 | Same |  |
| NrLoadBufEntries | 8 | 8 | Same |  |
| RVF | 1 | 1 | Same |  |
| RVD | 1 | 0 | Changed | No CVA6 RV32 package in the repository (cv32a60x, cv32a65x, cv32a6_imac_sv32, cv32a6_imafc_sv32) enables D; FLEN becomes 32. Keeps the FPU in its upstream-proven RV32 form (ABI ilp32f). |
| XF16 | 0 | 0 | Same |  |
| XF16ALT | 0 | 0 | Same |  |
| XF8 | 0 | 0 | Same |  |
| RVA | 1 | 1 | Same |  |
| RVB | 1 | 1 | Same |  |
| ZKN | 1 | 1 | Same |  |
| RVV | 0 | 0 | Same |  |
| RVC | 1 | 1 | Same |  |
| RVH | 0 | 0 | Same |  |
| RVZCB | 1 | 1 | Same |  |
| RVZCMP | 0 | 0 | Same |  |
| RVZCMT | 0 | 0 | Same |  |
| XFVec | 0 | 0 | Same |  |
| CvxifEn | 0 | 0 | Same |  |
| CoproType | config_pkg::COPRO_NONE | config_pkg::COPRO_NONE | Same |  |
| RVZiCond | 1 | 1 | Same |  |
| RVZiCbom | 1 | 1 | Same |  |
| RVZicntr | 1 | 1 | Same |  |
| RVZihpm | 1 | 1 | Same |  |
| NrScoreboardEntries | 8 | 8 | Same |  |
| PerfCounterEn | 1 | 1 | Same |  |
| MmuPresent | 1 | 1 | Same |  |
| RVS | 1 | 1 | Same |  |
| RVU | 1 | 1 | Same |  |
| SoftwareInterruptEn | 1 | 1 | Same |  |
| HaltAddress | 64'h800 | 64'h800 | Same |  |
| ExceptionAddress | 64'h808 | 64'h808 | Same |  |
| RASDepth | 2 | 2 | Same |  |
| BTBEntries | 32 | 32 | Same |  |
| BPType | config_pkg::BHT | config_pkg::BHT | Same |  |
| BHTEntries | 128 | 128 | Same |  |
| BHTHist | 3 | 3 | Same |  |
| DmBaseAddress | 64'h0 | 64'h0 | Same |  |
| TvalEn | 1 | 1 | Same |  |
| DirectVecOnly | 0 | 0 | Same |  |
| NrPMPEntries | 8 | 8 | Same |  |
| PMPCfgRstVal | {64{64'h0}} | {64{64'h0}} | Same |  |
| PMPAddrRstVal | {64{64'h0}} | {64{64'h0}} | Same |  |
| PMPEntryReadOnly | 64'd0 | 64'd0 | Same |  |
| PMPNapotEn | 1 | 1 | Same |  |
| NOCType | config_pkg::NOC_TYPE_AXI4_ATOP | config_pkg::NOC_TYPE_AXI4_ATOP | Same |  |
| NrNonIdempotentRules | 2 | 2 | Same |  |
| NonIdempotentAddrBase | 1024'({64'b0, 64'b0}) | 1024'({64'b0, 64'b0}) | Same |  |
| NonIdempotentLength | 1024'({64'b0, 64'b0}) | 1024'({64'b0, 64'b0}) | Same |  |
| NrExecuteRegionRules | 3 | 3 | Same |  |
| ExecuteRegionAddrBase | 1024'({64'h8000_0000, 64'h1_0000, 64'h0}) | 1024'({64'h8000_0000, 64'h1_0000, 64'h0}) | Same |  |
| ExecuteRegionLength | 1024'({64'h40000000, 64'h10000, 64'h1000}) | 1024'({64'h40000000, 64'h10000, 64'h1000}) | Same |  |
| NrCachedRegionRules | 1 | 1 | Same |  |
| CachedRegionAddrBase | 1024'({64'h8000_0000}) | 1024'({64'h8000_0000}) | Same |  |
| CachedRegionLength | 1024'({64'h40000000}) | 1024'({64'h40000000}) | Same |  |
| MaxOutstandingStores | 7 | 7 | Same |  |
| DebugEn | 1 | 1 | Same |  |
| Sdtrig | 0 | 0 | Same |  |
| SdtrigMcontrol6 | 0 | 0 | Same |  |
| SdtrigMcontrol6ExecAddr | 0 | 0 | Same |  |
| SdtrigMcontrol6ExecData | 0 | 0 | Same |  |
| SdtrigMcontrol6Store | 0 | 0 | Same |  |
| SdtrigMcontrol6LoadAddr | 0 | 0 | Same |  |
| SdtrigMcontrol6LoadData | 0 | 0 | Same |  |
| SdtrigIcount | 0 | 0 | Same |  |
| SdtrigEtrigger | 0 | 0 | Same |  |
| SdtrigItrigger | 0 | 0 | Same |  |
| SdtrigNrTriggers | 4 | 4 | Same |  |
| SdtrigTriggerChaining | 0 | 0 | Same |  |
| SdtrigSupportedActions | 2'b01 | 2'b01 | Same |  |
| SdtrigSupportedMatch | 10'b00_0000_0001 | 10'b00_0000_0001 | Same |  |
| SdtrigSupportTextra | 0 | 0 | Same |  |
| AxiBurstWriteEn | 0 | 0 | Same |  |
| IcacheByteSize | 16384 | 16384 | Same |  |
| IcacheSetAssoc | 4 | 4 | Same |  |
| IcacheLineWidth | 128 | 128 | Same |  |
| DCacheType | config_pkg::HPDCACHE_WB | config_pkg::HPDCACHE_WB | Same |  |
| DcacheByteSize | 32768 | 32768 | Same |  |
| DcacheSetAssoc | 8 | 8 | Same |  |
| DcacheLineWidth | 128 | 128 | Same |  |
| DcacheFlushOnFence | 1'b0 | 1'b0 | Same |  |
| DcacheFlushOnFenceI | 1'b1 | 1'b1 | Same |  |
| DcacheInvalidateOnFlush | 1'b0 | 1'b0 | Same |  |
| DcacheEccEnable | 0 | 0 | Same |  |
| DcacheEccScrubberEnable | 0 | 0 | Same |  |
| DataUserEn | 0 | 0 | Same |  |
| WtDcacheWbufDepth | 7 | 7 | Same |  |
| FetchUserWidth | 64 | 32 | Changed | Follows XLEN as in the source package; fetch user is disabled (FetchUserEn=0) and is not part of the AXI record. |
| FetchUserEn | 0 | 0 | Same |  |
| InstrTlbEntries | 16 | 16 | Same |  |
| DataTlbEntries | 16 | 16 | Same |  |
| UseSharedTlb | 0 | 0 | Same |  |
| SvnapotEn | 0 | 0 | Same |  |
| SharedTlbDepth | 64 | 64 | Same |  |
| NrLoadPipeRegs | 1 | 1 | Same |  |
| NrStorePipeRegs | 0 | 0 | Same |  |
| DcacheIdWidth | 3 | 3 | Same |  |

### 8.3 Derived widths

CVA6 derives the following values from XLEN in `build_config_pkg.sv`; they are listed so that every width in the profile is explicit.

| Derived value | 64-bit | RV32 | Source |
|---|---|---|---|
| PLEN (physical address) | 56 | 34 | build_config_pkg.sv:38 |
| GPLEN | 41 | 34 | build_config_pkg.sv:39 |
| Virtual-memory mode | Sv39 | Sv32 | build_config_pkg.sv:200-202 |
| VPN length / page-table levels | 27 / 3 | 20 / 2 | build_config_pkg.sv:31-32 |
| ASID_WIDTH (as implemented by CVA6) | 16 | 1 | build_config_pkg.sv:43 |
| FLEN | 64 | 32 | build_config_pkg.sv:10 (RVD=0) |
| I-cache index / tag width | 12 / 44 | 12 / 22 | ICACHE_TAG_WIDTH = PLEN - 12 (16 KiB, 4-way) |
| D-cache index / tag width | 12 / 44 | 12 / 22 | DCACHE_TAG_WIDTH = PLEN - 12 (32 KiB, 8-way) |
| HPDcache word width | 64 | 32 | cva6_hpdcache_subsystem.sv:285 |
| HPDcache data ways per RAM word | 2 | 4 | min(8, 128/XLEN), cva6_hpdcache_subsystem.sv:293 |
| Core cache-line address (PLEN-4) | 52 | 30 | cva6.sv ports |
| Cluster cache-line address | 52 | 52 (bits 51:30 zero) | REQ-XL-007 |
| AXI address / data / ID / user | 64 / 64 / 4 / 64 | 64 / 64 / 4 / 64 | REQ-XL-006 |

## 9. Data representation and arithmetic

| Quantity | Width | Encoding / range | Extension / truncation | Overflow / invalid behavior |
|---|---|---|---|---|
| Integer register | 32 | Two's complement | None | RV32 ISA rules |
| FP register | 32 | IEEE 754 binary32 | None | RV32F rules |
| Virtual address | 32 | Unsigned | Zero-extended to 64 at CMO tile ports | Sv32 page fault |
| Physical address (core) | 34 | Unsigned | Zero-extended to 64 on AXI | PMP/PMA access fault |
| Cache-line address (core) | 30 | PA[33:4] | Zero-extended to 52 in the cluster | Bits 51:30 nonzero on entry is an assertion failure |
| AXI data | 64 | As REF-001 | None | As REF-001 |
| Hart index | 2-bit vector index | 0 to PARA_CPU_NUM-1 | None | As REF-001 |

## 10. Detailed functional behavior

### 10.1 Modes and state transitions

All FSMs of REF-001 Section 10.1 (CCU context, CMO controller, HPDcache probe, AXI4-Lite bridge, miss permission, flush capture) are reused without change. The privilege modes M, S and U are as in REF-001; there is no 32-bit compatibility mode switching because XLEN is fixed.

### 10.2 Operations

| Operation | RV32 behavior | Difference from REF-001 |
|---|---|---|
| Integer and FP instructions | RV32IMFC + B + Zcb + Zicond + Zkn | No 64-bit forms (W-suffixed, LD/SD); no D |
| Atomics | LR.W, SC.W, AMO*.W; uncached AMO via AWATOP with 4-byte size | No .D forms; AXI exclusive and AWATOP paths unchanged |
| Counters | cycle/cycleh, instret/instreth, mhpmcounterN/mhpmcounterNh | 64-bit counters read as two 32-bit halves |
| Virtual memory | Sv32, 4 KiB and 4 MiB pages, 2-level walk, 32-bit PTE | Shorter walk than Sv39 |
| PMP | 8 entries, pmpaddr holds PA[33:2], NAPOT enabled | Address range 34-bit |
| CBO.CLEAN/FLUSH/INVAL, FENCE.I | Same CMO path; line address 30 bits zero-extended | None in protocol |
| MESI coherence, probes, owner writeback | As REF-001 Section 10.2.1 | None |

### 10.3 Waveform plan

The waveforms of REF-001 Section 10.3 apply. One RV32 waveform is added to the plan. Until it is drawn, its figure cell points to the base waveform WF-002, whose cycle behavior is identical.

| Waveform ID | Function / operation | Scenario | Signals shown | Figure | Confirmed by user |
|---|---|---|---|---|---|
| WF-101 | Dirty-owner transfer, RV32 | Hart 1 reads a line above 0x8000_0000 held dirty by hart 0 | Core 30-bit line address, cluster 52-bit line address, PREPARE/COMMIT, two 64-bit AXI W beats, grant | ![WF-002 base dirty-owner transfer](../specification/figures/waveforms/WF-002_mesi_dirty_owner.svg) (base waveform; RV32 differs only in the line-address width) | No |


### 10.4 Timing boundaries

The adapters add no register and no latency. Cycle behavior at every cluster interface is identical to REF-001.

### 10.5 End-to-end working flows and storage ownership

Unchanged from REF-001 Section 10.5.

## 11. Register and programming model

### 11.1 Canonical workbook and generator

The cluster CSR workbook and generated RTL are unchanged ([workbook](../specification/VLSIT_RISCV_CPU_Cluster_CSR.xlsx)). The AXI4-Lite port is 32-bit in both profiles.

### 11.2 Software programming and use flow

- Toolchain: `-march=rv32imafc_zba_zbb_zbc_zbs_zcb_zicond_zicbom_zkn` (adjust to the toolchain's spelling), `-mabi=ilp32f`.
- Boot: all harts start at i_boot_addr[31:0]; software branches on mhartid (REQ-XL-002).
- Fault records and PMU snapshots that hold line or physical addresses report the same fields as REF-001; the upper bits are zero.
- A 64-bit PMU counter read over AXI4-Lite uses the snapshot sequence of REF-001 Section 11.2, unchanged.

### 11.3 Field connections and storage ownership

Unchanged from REF-001 Section 11.3.

### 11.4 Access and update behavior

Unchanged from REF-001 Section 11.4.

### 11.5 ABI preservation

The register ABI is identical to the 64-bit cluster. Software can detect the profile from misa.MXL.

## 12. Error handling and recovery

Unchanged from REF-001 Section 12. A nonzero upper line-address bit at the tile input (I-X32-1) is a design error caught by SVA-101 in simulation and formal; it has no run-time recovery path.

## 13. Performance, power, and area

No measured number exists for this profile. The table states the expected direction of each change and its basis.

| Item | Expected effect | Basis |
|---|---|---|
| Integer register file | Half the flops: 31 x 32 instead of 31 x 64 bits per hart | Arithmetic |
| FP register file | Half the flops: 32 x 32 instead of 32 x 64 bits per hart | Arithmetic (RVD=0) |
| Cache tag SRAM | Tag width 22 instead of 44 bits in I-cache and D-cache | Section 8.3 |
| TLB tags, page walk | Narrower VPN (20 bits); 2-level walk | Section 8.3 |
| Sharer directory | No change by default. Bits 51:30 of every stored tag are constant zero; synthesis may remove them, otherwise an optional tag-width parameter saves 22 bits per entry (about 90,000 bits for 4,096 entries, INFERENCE) | Section 14.4 |
| Core critical path | Likely shorter (32-bit adders, multiplier, divider, TLB compare); size unknown | INFERENCE; to be measured with the REF-001 sweep |
| Software performance | About twice the instructions for 64-bit data operations; same IPC structure otherwise | ISA |
| Cluster bandwidth, coherence latency | Unchanged (same line, AXI width, CCU) | REQ-XL-009 |

## 14. RTL implementation contract

### 14.1 Required coding baseline

As REF-001 Section 14.1 (VLSIT_RTL_Design_Rule.md v2).

### 14.2 Source changes

| File | Change | Notes |
|---|---|---|
| rtl/common/modified/cva6/core/include/cv32a6_imafc_sv32_hpdcache_wb_config_pkg.sv | NEW (copy of the 64-bit package, Section 8.2) | Declares package cva6_config_pkg like the 64-bit file; only one of the two may be in a filelist |
| rtl/common/vlsit/cpu/m_vlsit_riscv_cpu_tile.sv | MODIFY: adapters of Section 6.3 and assertions SVA-101/02 | About 15 64-bit and 12 52-bit connection points; AXI slicing unchanged |
| RV32 filelist (new) next to rtl/non_coherence_cluster/filelist.f | NEW | Same as the 64-bit filelist except the configuration package |
| Every other source | No change | Compiled with the RV32 package |

### 14.3 Tile adapter rules

- Outputs toward the cluster: `o_x_nline = 52'(w_core_x_nline)` (zero-extension), `o_cmo_req_vaddr = 64'(w_core_cmo_vaddr)`.
- Inputs toward the core: `w_core_x_nline = i_x_nline[29:0]`, with an immediate assertion `i_x_nline[51:30] == 0` when the matching valid is high.
- Boot and identity: `boot_addr_i = i_boot_addr[31:0]`, `hart_id_i = i_hart_id[31:0]`, with an assertion `i_boot_addr[63:32] == 0` while reset is asserted.
- Use widths derived from the configuration (`CVA6Cfg.PLEN-4`, `CVA6Cfg.VLEN`, `CVA6Cfg.XLEN`) so the same tile source compiles for both profiles; the 64-bit profile then degenerates to direct connections.

### 14.4 Optional area optimization (not required)

Parameterize the stored tag width of `m_vlsit_riscv_sharer_directory` (currently `52 - 2 - SET_W`) from the line width actually used, after confirming in synthesis that the constant-zero bits are not already removed. This is a separate change that affects both profiles and is made in REF-001 first.

## 15. Verification specification

### 15.1 Scope and strategy

Verification reuses the REF-001 environment and its independent reference models with an RV32 toolchain. The highest-risk area is the VLSIT-modified HPDcache path (probe engine, flush, CMO) running with a 32-bit word for the first time (REQ-XL-012). Lint, elaboration and the CPU regression shall be run for CFG-RV32-2 and CFG-RV32-4 before any other qualification claim.

### 15.2 Requirement-based test plan

| Test ID | Requirements | Stimulus | Expected result | Method | Configuration |
|---|---|---|---|---|---|
| TEST-101 | REQ-XL-001 | Elaborate the TOP with the RV32 filelist | Elaboration and lint clean; misa reads RV32 | Lint + directed | CFG-RV32-2/4 |
| TEST-102 | REQ-XL-002 | Boot all harts from one address; per-hart interrupt and debug requests | Each hart identifies itself and services its own vectors | Directed CPU | CFG-RV32-2/4 |
| TEST-103 | REQ-XL-003 | Execute RV64-only encodings | Illegal-instruction trap for each | Directed CPU | CFG-RV32-2 |
| TEST-104 | REQ-XL-004 | F arithmetic, fflags, D encodings | F results correct; D encodings trap | Directed CPU + reference model | CFG-RV32-2 |
| TEST-105 | REQ-XL-005 | Sv32 page walks for 4 KiB and 4 MiB pages, faults, S/U transitions; Linux RV32 boot | Correct translation and faults; kernel reaches user space | Directed CPU + OS boot | CFG-RV32-2/4 |
| TEST-106 | REQ-XL-006 | Cached, uncached and MMIO accesses near 2^34 | AXI address bits 63:34 zero; same beat counts as 64-bit | Protocol checker | CFG-RV32-2 |
| TEST-107 | REQ-XL-007 | Probes, locks and grants on lines above 0x8000_0000 | Correct zero-extension and truncation; no assertion fires | Directed + SVA | CFG-RV32-2/4 |
| TEST-108 | REQ-XL-008 | Boot address with bits 63:32 zero and nonzero | Boot from bits 31:0; assertion fires for nonzero upper bits | Directed + SVA | CFG-RV32-2 |
| TEST-109 | REQ-XL-009 | Rerun the REF-001 coherence regression (base tests 002, 020 to 025, 044 to 049, 056, 058, 060) | Same pass criteria as REF-001 | Regression with RV32 programs | CFG-RV32-2/4 |
| TEST-110 | REQ-XL-010 | Compare the TOP port list and CSR map with REF-001 | Identical | Script comparison | AXI TOP |
| TEST-111 | REQ-XL-011 | Region tables with entries ending at and above 2^34 | At the bound accepted; above rejected or flagged | Elaboration check | CFG-RV32-2 |
| TEST-112 | REQ-XL-012 | Dirty-owner transfer, flush, CBO and FENCE.I with 32-bit HPDcache words | Line data identical to the reference model; two 64-bit W beats per line | Directed + scoreboard | CFG-RV32-2/4 |
| TEST-113 | REQ-XL-013 | Read 64-bit counters across a low-word carry; PMU event counting | Consistent high/low values; PMU counts match events | Directed + PMU scoreboard | CFG-RV32-2 |
| TEST-114 | REQ-XL-014 | Elaborate profiles 0, 1 and 2 for 2 and 4 harts | Lint clean for all six combinations | Lint | CFG-RV32-2/4 |

### 15.3 Assertions and coverage

| ID | Property | Kind | Requirement |
|---|---|---|---|
| SVA-101 | Bits 51:30 of every valid line address entering the core are zero | assert | REQ-XL-007 |
| SVA-102 | Bits 63:32 of i_boot_addr are zero while reset is asserted | assert | REQ-XL-008 |
| SVA-103 | AXI address bits 63:34 issued by each hart are zero | assert | REQ-XL-006 |

All properties and coverage thresholds of REF-001 Section 15.3 apply.

### 15.4 Formal, CDC, and RDC

As REF-001 Section 15.4, run on CFG-RV32-2. No new CDC or RDC crossing exists.

## 16. DFT and testability

Unchanged from REF-001 Section 16, including the DFT hand-off and PD-05.

## 17. Physical design and timing integration

### 17.1 Timing constraints and budgets

Same constraints and interface contract as REF-001 Section 17.1. The accepted period is found with the same sweep (REF-001 Section 8.3, PD-01). The planning period of PD-01 (3.5 ns) applies until the RV32 sweep exists.

### 17.2 Physical assumptions

Unchanged from REF-001 Section 17.2. SRAM tag macros of the L1 caches are narrower (Section 8.3).

## 18. Security, safety, and reliability

Unchanged from REF-001 Section 18. PMP covers a 34-bit physical space; regions above it are unreachable.

## 19. Requirement-to-verification traceability

| Requirement ID | RTL module/location | Test/property | Verification method / analysis | Configuration |
|---|---|---|---|---|
| REQ-XL-001 | RV32 configuration package, RV32 filelist | TEST-101 | Elaboration, lint, misa read | CFG-RV32-2/4 |
| REQ-XL-002 | m_vlsit_riscv_cpu_tile_array | TEST-102 | Directed CPU | CFG-RV32-2/4 |
| REQ-XL-003 | CVA6 decoder and CSR file | TEST-103 | Directed CPU | CFG-RV32-2 |
| REQ-XL-004 | CVA6 FPU | TEST-104 | Directed CPU + model | CFG-RV32-2 |
| REQ-XL-005 | CVA6 MMU | TEST-105 | Directed CPU + OS boot | CFG-RV32-2/4 |
| REQ-XL-006 | Tile AXI slicer | TEST-106, SVA-103 | Protocol checker | CFG-RV32-2 |
| REQ-XL-007 | Tile line-address adapter | TEST-107, SVA-101 | Directed + SVA | CFG-RV32-2/4 |
| REQ-XL-008 | Tile virtual-address adapter | TEST-108, SVA-102 | Directed + SVA | CFG-RV32-2 |
| REQ-XL-009 | All reused cluster blocks | TEST-109 | Regression | CFG-RV32-2/4 |
| REQ-XL-010 | AXI TOP, CSR | TEST-110 | Script comparison | AXI TOP |
| REQ-XL-011 | Region table, configuration package | TEST-111 | Elaboration check | CFG-RV32-2 |
| REQ-XL-012 | HPDcache and probe engine | TEST-112 | Directed + scoreboard | CFG-RV32-2/4 |
| REQ-XL-013 | CVA6 CSR file, perf_counters, PMU | TEST-113 | Directed + scoreboard | CFG-RV32-2 |
| REQ-XL-014 | TOP with timing profiles | TEST-114 | Lint | CFG-RV32-2/4 |

## 20. Assumptions, dependencies, and decisions

| ID | Type | Content | Impact | Status |
|---|---|---|---|---|
| DEC-101 | Decision | Change only XLEN (and VLEN) of the CVA6 configuration; keep every other field unless a row of Section 8.2 says otherwise | Minimal core change | Proposed in this draft |
| DEC-102 | Decision | RVD=0 (F only, ABI ilp32f); keep ZKN=1 (aes.sv has an RV32 path, aes.sv:76, 195); keep PerfCounterEn=1 | Avoids an unproven RV32D FPU form; keeps crypto and PMU | Proposed in this draft |
| DEC-103 | Decision | Keep AXI 64-bit address and data, 4-bit ID, and pin AxiUserWidth at 64 | AXI records and every cluster AXI port unchanged | Proposed in this draft |
| DEC-104 | Decision | Adapt widths only inside the tile (zero-extend out, truncate in, assert) | No change to CCU, directory, LLC, router | Proposed in this draft |
| DEC-105 | Decision | Reuse every cluster block, port list and CSR map without change | One shared source base for both profiles | Proposed in this draft |
| ASM-101 | Assumption | Target software is RV32 Linux (Sv32) or an RV32 RTOS; RAM sized for Sv32 | Defines feature set | Proposed |
| DEP-101 | Dependency | Same PDK, SRAM, SDC, corner and workload inputs as REF-001 | PPA and timing | Open |

### 20.1 Open items

| ID | Issue | Next action |
|---|---|---|
| OPEN-X32-HPD | The VLSIT-modified HPDcache, probe engine and CMO path have never run with a 32-bit word | Lint first, then TEST-112 |
| OPEN-X32-USER | AxiUserWidth=64 with XLEN=32 is a configuration no upstream package uses; CVA6 may assume user width equals XLEN somewhere | Confirm in lint and TEST-106; fall back to recomputing the AXI slice offsets |
| OPEN-X32-OS | No RV32 Linux image or RTOS port is selected | Product owner selects the software stack |
| OPEN-X32-PPA | No area, power or timing number for the RV32 profile | Run the REF-001 sweep on CFG-RV32-2 |
| OPEN-X32-DIR | Directory tag bits 51:30 are constant zero | Check synthesis; decide on Section 14.4 |

## 21. Glossary

| Term | Meaning |
|---|---|
| RV32 / RV64 | RISC-V base integer ISA with 32-bit / 64-bit registers (XLEN) |
| PLEN, VLEN | Physical and virtual address widths of the core |
| Sv32, Sv39 | RISC-V page-table formats for 32-bit and 39-bit virtual addresses |
| ilp32f | RV32 ABI: 32-bit int, long and pointer; single-precision float in FP registers |
| Line address (nline) | Physical address without the 4 byte-offset bits of a 16-byte line |
| Base / REF-001 | The 64-bit cluster specification that this document extends |

## 22. References used to shape this template

- REF-001 to REF-005 in Section 2.1.
- RTL evidence read for this draft: `build_config_pkg.sv` (derived widths), `cva6.sv` (port widths), `cva6_hpdcache_subsystem.sv` (word width), `aes.sv` (RV32 path), `m_vlsit_riscv_cpu_tile.sv` (tile ports and AXI record slicing).
