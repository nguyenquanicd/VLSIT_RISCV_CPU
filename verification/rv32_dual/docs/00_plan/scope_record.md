# Scope record: rv32_dual (CFG-RV32-2) - R-260, R-261, R-269

AI-generated (Claude Opus 5.5, 2026-11-27) in a specification-only authoring context; candidate artifact until the G0 human review (R-117, R-231). Status: **pending G0**.

## 1. Specification baseline

| Document | Revision | SHA-256 |
|---|---|---|
| `doc/specification_32/VLSIT_RISCV32_DUAL_QUAD_CPU_CLUSTER_HDS.md` (RV32 HDS) | 0.4, 2026-11-27 | `81923890dc7b70b415fbb8947e48c82e666860c2c5e23243fa2dbe72253a115c` |
| `doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md` (REF-001, base HDS) | 0.39, 2026-11-27 | `12615b0bbcf64571b5e202876207eb89825cc5375c518d680528204f6565e1a9` |
| `doc/specification/VLSIT_RISCV_CPU_Cluster_CSR.xlsx` (register facts only) | workbook as committed | `59872e8809ee51a0a380b4642ec94230ba6ed097c4a62d38f2366e01e60ccec1` |
| AMBA AXI4/AXI4-Lite IHI 0022H; AMBA 5 E1.1 atomics; RISC-V Unprivileged (Zicbom, Zifencei, RV32IMAFC, B, Zcb, Zicond, Zkn) and Privileged (Sv32, PMP, traps) | as cited by the HDS | from the author's knowledge; clause numbers need controlled-document confirmation (RISK-08) |

Both HDS documents are Draft; question log Q-02 approved them as the campaign baseline. The RV32 HDS cites REF-001 revision 0.36; the campaign uses 0.39 (spec_gaps Q-G0-01, answered A on 2026-11-27). All 16 spec_gaps questions were answered on 2026-11-27 (question_log.md).

## 2. DUT boundary and level (R-261)

| Item | Decision |
|---|---|
| DUT | `m_vlsit_riscv_cluster_axi_top` in the 32-bit profile (RV32 filelist), PARA_CPU_NUM=2 |
| Level | **block**, processor profile (`vlsit_large_ip_verification.md` section 4, CPU row). Chosen from the DUT boundary (one cluster TOP with real cores), not from the CPU keyword |
| Observation points | The 111 TOP ports of REF-001 Section 6.2: AXI4 memory (PULP AWATOP), AXI4 MMIO, AXI4-Lite control, boot address, 6 per-hart IRQ vectors, debug request/status, `o_int_pmu`, `o_int_fault`; plus software-visible state reported by the RV32 programs (signature lines, trap records) and the AXI4-Lite CSR/PMU views |
| Internal observation | Only for the specification-named assertions SVA-101, SVA-104, SVA-105; their binding stays blocked until the observation-point table promised by the Q-G0-13 answer is in the RV32 HDS. No other white-box probe is planned |
| Supplementary component formal | Small control components whose exact port contracts are specification text in REF-001 Section 14.4 (`m_vlsit_pmu_counter_bank`, `m_vlsit_pmu_irq`, `m_vlsit_pmu_snapshot`, `m_vlsit_riscv_axil_decode`, `m_vlsit_axil_reg_bridge`, `m_vlsit_riscv_addr_decode`). This is a recorded boundary extension for obligations that TOP simulation cannot reach (PMU wrap/overflow, approved by Q-G0-10 A) or cannot exhaust; it is not a separate campaign |
| Stimulus | RV32 programs executed by the real CVA6 harts; project-local AXI memory BFM, AXI MMIO BFM, AXI4-Lite manager BFM, IRQ/debug/boot drivers. No force on internal signals (R-258) |
| VIP inventory (R-254, R-262) | No qualified AXI/AXI4-Lite/RISC-V VIP is available in the approved tool set; no UVM. Project-local BFMs and passive monitors are defined with the no-VIP contract of verification_plan.md section 5.2. They are not labelled qualified full-protocol VIPs |
| Legacy collateral | `verification/rv32_profile` receives no credit and was not read (question log Q-03) |

## 3. Configurations

| Config ID | Parameters | Campaign scope |
|---|---|---|
| CFG-RV32-2-P0 | RV32 filelist; PARA_CPU_NUM=2; PARA_TIMING_PROFILE=0; other TOP parameters at REF-001 8.1 defaults, except the address-region table: five regions per Q-G0-03 A (0 cacheable 0x8000_0000/1 GiB; 1 MMIO 0x1000_0000/256 MiB; 2 MMIO 0x0000_0000/4 KiB debug ROM; 3 normal-uncached 0x4000_0000/256 MiB; 4 normal-uncached 0x3_C000_0000/1 GiB ending at 2^34), checked before build by the region-table script (Q-G0-09 C) | Full campaign |
| CFG-RV32-2-P1 | as P0 with PARA_TIMING_PROFILE=1 | Elaboration, lint, `t_rv32d_smoke` |
| CFG-RV32-2-P2 | as P0 with PARA_TIMING_PROFILE=2 | Elaboration, lint, `t_rv32d_smoke` |
| CFG-RV32-4-P0/P1/P2 | PARA_CPU_NUM=4 | Elaboration and lint only, because REQ-XL-014 names 2 and 4 harts; no simulation credit for 4 harts |

Fixed for the whole campaign: PARA_AXI_MEM_DATA_W=64, PARA_COH_TXN_NUM=8, PARA_PMU_COUNTER_NUM=16, PARA_PMU_COUNTER_W=64, default LLC geometry 4 ways x 4096 lines (Q-G0-15 A), PARA_AXIL_BASE_ADDR=0.

## 4. Abstraction layers

| Layer | In scope | Not in scope |
|---|---|---|
| ISA / architectural | RV32 harts executing RV32IMAFC+B+Zcb+Zicond+Zicbom+Zkn programs; traps; CSRs; Sv32 | RV32 Linux/RTOS boot (OPEN-X32-OS: no image selected) |
| Cluster transaction | Coherent data, CMO, FENCE.I, atomics, MMIO, region routing, PMU, fatal record, reset | Internal CCU tag/slot/bank mechanics (see out-of-scope list) |
| Interface protocol | AXI4 memory and MMIO manager subset, AXI4-Lite subordinate, AWATOP subset, level IRQ/debug | Full AXI4/AXI5 compliance; ACE |
| Physical | none | STA, power, area, DFT, CDC/RDC tool runs |

## 5. Applicable rule sections (R-261)

| Rule range | Applicability |
|---|---|
| Core R-100-R-119 | Applies |
| Component R-120-R-129 | Applies to each project-local BFM, monitor, oracle and checker; R-120/R-122 UVM clauses N/A (no UVM); R-128 self-test and checker mutation apply |
| VIP R-140-R-149 | **Not applicable**: no reusable VIP package is released. Inherited obligations for local BFMs are limited to the no-VIP contract (R-262) |
| Block R-160-R-169 | Applies |
| SoC R-180-R-189 | Not applicable (block DUT) |
| Test design R-250-R-259, testcase quality R-281-R-286 | Applies |
| Strategy R-240-R-247, scalable R-260-R-280, coverage R-200-R-207, regression R-215-R-222, AI R-230-R-239 | Applies |

## 6. Requirement classification (R-260)

In scope: 14 REQ-XL + 48 REF-001 requirements + 8 protocol clauses = **70 inventory IDs** (`requirements.txt`). Out of scope: **19 REF-001 requirements**. Every REF-001 requirement (67) appears below.

### 6.1 RV32 requirements

All 14 REQ-XL requirements (REQ-XL-001 to REQ-XL-014) are in scope. REQ-XL-014 also covers 4-hart elaboration/lint.

### 6.2 REF-001 requirements

| Requirement | Decision | Reason |
|---|---|---|
| REQ-SYS-001 | In | Two-hart elaboration and contiguous mhartid at the boundary |
| REQ-SYS-002 | **Out** | Replaced for this profile by REQ-XL-001 (RV32 HDS 3.1) |
| REQ-SYS-003 | In | Boot fanout re-checked with RV32 (REQ-XL-008) |
| REQ-SYS-004 | In | Port audit: no CVXIF port at TOP |
| REQ-PERF-006 | In (smoke only) | Profile 1 smoke (Q-04); full TEST-057-061 matrix, PMU latency matrix and source-diff audit not in this campaign |
| REQ-PERF-007 | In (smoke only) | Profile 2 smoke (Q-04); STA and TEST-063 not in this campaign |
| REQ-MEM-001 | In | MESI data coherence for two RV32 harts |
| REQ-MEM-005 | In | Directory targeting observed through data and PMU CCU events |
| REQ-MEM-006 | In | Same-line serialization visible through atomic/data outcomes |
| REQ-MEM-007 | In | FENCE.I locality (RV32 HDS 10.2 lists FENCE.I) |
| REQ-MEM-008 | In | Missing-holder safety observed by litmus/data oracle |
| REQ-MEM-009 | **Out** | Internal tag/slot allocation is not observable at the TOP with two harts and the default N=8; unchanged by XLEN (REQ-XL-009); REF-001 TEST-025/053 unit level |
| REQ-MEM-010 | **Out** | LLC-eviction independence cannot be separated at the TOP from legal directory-replacement invalidation without the directory set-index function, which REF-001 does not specify; REF-001 TEST-024 unit level |
| REQ-MEM-011 | **Out** | Bank selection and per-cache probe queue are internal; bank index uses line bits [1:0], unchanged by XLEN |
| REQ-MEM-012 | In | Two-phase probe outcome (data, ABORT preservation, PMU events) |
| REQ-MEM-013 | In (boundary form) | No-timeout retention checked with held external responses; internal missing PREPARE/COMMIT/ABORT ACK injection is not reachable from the TOP with real caches (REQ-CLK-002 requires responsive probes) and stays at REF-001 TEST-029-031 level |
| REQ-MEM-014 | **Out** | Round-robin and PLRU internals are not observable at the TOP |
| REQ-MEM-015 | In | CBO operations, boundary-visible on memory |
| REQ-MEM-016 | In | LLC per-line service and error preservation |
| REQ-MEM-017 | In | Precise CBO fault (owner-writeback variant blocked by dependency DEP-DV-01, Q-G0-05) |
| REQ-MEM-018 | In | FENCE.I success; error variant blocked by dependency DEP-DV-01, Q-G0-05 |
| REQ-MEM-019 | In | Reservation escape: no-hang under CMO + AMO stress; SVA-104/105 binding blocked until the Q-G0-13 observation-point table exists |
| REQ-MEM-020 | In | Deadlock freedom observed as bounded completion under stress |
| REQ-MEM-021 | **Out** | Stale/duplicate internal ACK injection needs an internal probe agent; REF-001 TEST-045 unit level |
| REQ-MEM-022 | **Out** | Bank-arbiter token rearm is internal; REF-001 TEST-048 |
| REQ-MEM-023 | **Out** | Context-retention fields are internal; covered indirectly by REQ-MEM-012 data/abort checks |
| REQ-MEM-024 | **Out** | Atomic multi-hart probe-slot claim needs three or more targets; with two harts every mask is a single hart (disjoint) |
| REQ-MEM-025 | **Out** | Profile 2 RAM wrapper is a structural/synthesis obligation |
| REQ-MEM-002 | **Out** | LLC default geometry is an elaboration parameter unchanged by XLEN (REQ-XL-009); REF-001 TEST-003 |
| REQ-MEM-003 | In | SPM disable through the AXI4-Lite LLC window (blocked until the Q-G0-04 LLC register table is in REF-001 Section 11) |
| REQ-MEM-004 | In | BIST-ready before use is part of the boot software flow (blocked until the Q-G0-04 LLC register table is in REF-001 Section 11) |
| REQ-IF-001 | In | AXI4-Lite boundary |
| REQ-IF-002 | In | MMIO boundary (region 1, Q-G0-03 A) |
| REQ-IF-003 | In | Memory port AWATOP and no snoop channels; RV32 uses 4-byte AMOs |
| REQ-IF-004 | **Out** | Future ACE profile, not in the current RTL phase |
| REQ-IF-005 | In | VALID/payload stability on all boundary channels |
| REQ-IF-006 | In | Two-hart IRQ/debug vector widths |
| REQ-IF-007 | In | AXI4-Lite WSTRB and error responses |
| REQ-IF-008 | In | AXI4-Lite local windows |
| REQ-IF-009 | In | Cached atomics and uncached LR/SC/AMO (region 3, Q-G0-03 A; error results per Q-G0-06 A) |
| REQ-IF-010 | In | AXI4-Lite-to-RegBus bridge (formal planned; simulation blocked until the Q-G0-04 LLC register table exists) |
| REQ-IF-011 | In | Region table and 2^34 bound (REQ-XL-011) |
| REQ-IF-012 | **Out** | Only PARA_AXI_MEM_DATA_W=64 in this campaign (Q-04); the adapter is XLEN-independent; REF-001 TEST-047 |
| REQ-PMU-001 | **Out** | Counter-number parameter boundary is an elaboration check; default 16 only |
| REQ-PMU-002 | In | Wrap semantics by component formal (Q-G0-10 A) |
| REQ-PMU-003 | In | Snapshot over AXI4-Lite (REQ-XL-013, RV32 HDS 11.2) |
| REQ-PMU-004 | In | Overflow/IRQ by component formal plus TOP o_int_pmu-low check (Q-G0-10 A) |
| REQ-PMU-005 | In | Scope behaviour with two active harts (absent-hart scopes) |
| REQ-PMU-006 | In | Aggregate over two harts |
| REQ-PMU-007 | In | Same per-hart event vector as REF-001 (REQ-XL-013) |
| REQ-PMU-008 | In | Event count semantics |
| REQ-DBG-001 | In | Per-hart debug at the boundary with the testbench debug ROM in region 2 (Q-G0-07 A) |
| REQ-IRQ-001 | In | Per-hart level routing |
| REQ-IRQ-002 | In | SSIP/STIP effective pending view in RV32 CSRs |
| REQ-IRQ-003 | In | MEIP/SEIP mapping (RV32 HDS 6.4) |
| REQ-CLK-001 | **Out** | Clock-domain lint/CDC review; RV32 HDS 7.2 adds no crossing; not a simulation obligation |
| REQ-CLK-002 | In | Probe service in WFI and in debug halt (Q-G0-07 A) |
| REQ-RST-001 | In | Coordinated reset with in-flight traffic |
| REQ-RST-002 | **Out** | SoC watchdog obligation; the cluster has no timeout. The testbench watchdog is a test-harness feature, not DUT behaviour |
| REQ-ERR-001 | In | Error/response association at the boundary |
| REQ-ERR-002 | In (boundary form) | Unmapped CPU access and reserved AXI4-Lite access have no side effect; internal malformed requests are not injectable |
| REQ-ERR-003 | In | LLC-source fatal record (planned); L1-source blocked by dependency DEP-DV-01 (Q-G0-05: CSR error-injection test hook, design change not yet specified) |
| REQ-PD-001 | **Out** | Physical-design claim review, no library/PVT input |
| REQ-PD-002 | **Out** | STA/structural interface timing |
| REQ-PD-003 | **Out** | Structural reset-in-handshake check; not a functional simulation obligation |
| REQ-VER-001 | In (review) | Specification-derived expected behaviour (this record + authoring_inputs.md) |
| REQ-VER-002 | In (review) | Reproducible per-configuration targets |

Out-of-scope count: REQ-SYS-002, REQ-MEM-002, -009, -010, -011, -014, -021, -022, -023, -024, -025, REQ-IF-004, REQ-IF-012, REQ-PMU-001, REQ-CLK-001, REQ-RST-002, REQ-PD-001, -002, -003 = **19**. No requirement is removed from the specification; each exclusion needs the G0 approver's signature.

### 6.3 Protocol clauses in the inventory

| ID | Content |
|---|---|
| PROTO-AXI4-A3.2 | AXI4 VALID/READY handshake and channel dependencies |
| PROTO-AXI4-A3.4 | AXI4 transaction structure: burst length/size/type, 4 KiB boundary, strobes |
| PROTO-AXI4-A6 | AXI4 transaction identifiers and ordering |
| PROTO-AXI4-A7.2 | AXI4 exclusive access |
| PROTO-AXI4L-B1 | AXI4-Lite interface |
| PROTO-AXI5-E1.1 | Atomic transactions (AWATOP) for the PULP subset |
| PROTO-RISCV-ZICBOM | RISC-V CMO clean/flush/inval semantics (REF-001 REF-012) |
| PROTO-RISCV-ZIFENCEI | Zifencei 2.0 Section 4.1 |

## 7. Profile decisions (R-269)

Processor profile: architectural state model per test (Python oracles), enabled ISA = RV32 HDS 2.3, retirement/trap state reported by programs, CSRs, interrupts, memory ordering (RVWMO litmus), reset, coherence. Exclusions: physical layer (none exists), OS boot, external DMA agents (no ACE), 4-hart simulation.
