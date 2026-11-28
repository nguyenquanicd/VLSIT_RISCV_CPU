# Question log / Nhật ký câu hỏi (R-104, R-105)

Campaign: CFG-RV32-2 (32-bit cluster, two harts). Level: block. Recorded 2026-11-27.

| ID | Question | Options offered | Answer (user, 2026-11-27) | Effect on the plan |
|---|---|---|---|---|
| Q-01 | Requirement scope for CFG-RV32-2 | A: REQ-XL-001..014 plus the REF-001 requirements whose behavior changes with XLEN=32 or must be re-checked at the cluster boundary (recommended); B: REQ-XL only; C: all 81 requirements | A | Inventory = 14 REQ-XL + selected REF-001 requirements (REQ-MEM coherence/CMO/FENCE.I, REQ-IF AXI, REQ-ERR, REQ-PMU, REQ-RST and others with a boundary-visible effect). Every other REF-001 requirement is listed out of scope with a reason in the scope record |
| Q-02 | Specification baseline (both documents are marked Draft) | A: treat RV32 HDS rev 0.4 and REF-001 rev 0.39 as the approved verification baseline, OPEN-* items as assumptions/out of scope (recommended); B: wait for the specification to be finalized | A | Baseline: `doc/specification_32/VLSIT_RISCV32_DUAL_QUAD_CPU_CLUSTER_HDS.md` rev 0.4 and `doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md` rev 0.39 |
| Q-03 | Workspace and the legacy testbench `verification/rv32_profile` (written in a context that contained RTL) | A: new standalone workspace, legacy testbench kept as reference only, not credited (recommended); B: extend rv32_profile with a compatibility map | A, inside this repository | Workspace `verification/rv32_dual/`. Plan and testcases are authored in a clean, specification-only context (R-103, R-232). `verification/rv32_profile` receives no closure credit |
| Q-04 | Timing profiles to simulate | A: simulate profile 0; profiles 0/1/2 elaborate + lint, plus one smoke test (recommended); B: full regression on all three profiles | A | Configuration set: CFG-RV32-2 profile 0 (full campaign); profiles 1 and 2: elaboration, lint and one smoke test |

## Specification-gap answers (spec_gaps.md), user, 2026-11-27

| ID | Answer | Effect on the plan |
|---|---|---|
| Q-G0-01 | A: verify against REF-001 rev 0.39 | DEC-046/DEC-047 expectations apply |
| Q-G0-02 | A: check only `misa.MXL=1` (XLEN fixed at 32); `mstatush` not checked | CK-I32-06 reduced to the misa check |
| Q-G0-03 | A: one parameter set of five regions: 0 cacheable 0x8000_0000/1 GiB; 1 MMIO 0x1000_0000/256 MiB; 2 MMIO 0x0000_0000/4 KiB (debug ROM); 3 normal-uncached 0x4000_0000/256 MiB; 4 normal-uncached 0x3_C000_0000/1 GiB (ends at 2^34) | MMIO, uncached, high-PA and debug-ROM rows unblocked |
| Q-G0-04 | A: the specification owner adds the native LLC service register table to REF-001 Section 11 | REQ-MEM-003/004, REQ-IF-010 simulation rows stay blocked until the table exists |
| Q-G0-05 | B, modified by the user: add a verification test hook to the specification, connected to a cluster CSR error-injection bit. Feasible as a design change (spec DEC + CSR workbook + RTL change plan); outside this verification campaign | CBO owner-writeback fault, FENCE.I cause-24 and L1 fatal-record rows stay blocked until the design change is specified and implemented |
| Q-G0-06 | A: load R error -> precise load access fault (cause 5, mtval = address); store/AMO B error -> store/AMO access fault (cause 7); SC with OKAY -> SC fails (rd=1), no trap | MMIO/uncached error rows unblocked |
| Q-G0-07 | A: testbench provides a minimal MMIO debug ROM at 0x800/0x808 (Debug Spec 0.13.2 park loop, per-hart flag, `dret` on a resume flag), using region 2 | REQ-DBG-001 and REQ-CLK-002 halt rows unblocked |
| Q-G0-08 | A: page fault when A=0 or when D=0 on a store; no hardware A/D update | CK-SV-05 expectation fixed (store with D=0 -> cause 15) |
| Q-G0-09 | C: integration obligation; a parameter-set check script rejects a table with base+size > 2^34 before build; RTL behaviour unspecified | REQ-XL-011 rows become a script check |
| Q-G0-10 | A: SymbiYosys proofs on `m_vlsit_pmu_counter_bank`, `m_vlsit_pmu_irq`, `m_vlsit_pmu_snapshot` using their REF-001 14.4 port contracts, plus a TOP check that `o_int_pmu` is low with no cause | REQ-PMU-002/004 rows become formal + simulation |
| Q-G0-11 | A: exact counts in an isolated window, prefetcher stated off. The prefetcher state remains to be confirmed by the specification owner at G0 | CK-DOW-03, CK-STR-06 use exact counts, with the prefetcher-off assumption recorded |
| Q-G0-12 | A: byte address of the line base: lo = PA[31:0] with bits 3:0 = 0, hi[1:0] = PA[33:32] | CK-FAT-02 address field fixed |
| Q-G0-13 | A: the specification owner adds an observation-point table (hierarchical path, width, qualifier) for SVA-101/104/105 to the RV32 HDS | SVA rows of REQ-XL-007 and REQ-MEM-019 stay blocked until the table exists |
| Q-G0-14 | A: PARA_CPU_NUM bits ([1:0] for two harts) | CK-ELB-02 uses [1:0] |
| Q-G0-15 | A: default LLC geometry only (4 ways x 4096 lines); eviction by footprint sweep | One build configuration |
| Q-G0-16 | B: write/read-back of both halves and carry check with a written value | CK-CNT-03 limited to read-back and carry |

## G0 confirmations, user, 2026-11-27

| Item | Decision |
|---|---|
| Q-G0-11 prefetcher assumption | Confirmed: the HPDcache prefetcher (`hwpf_stride`) is off in the campaign configuration, so exact PMU CCU/LLC counts apply |
| Resource budget disk stop threshold | Approved at 2 GiB free (`env/resource_budget.json` limits.disk_stop_free_bytes); runs remain blocked while free space is below it |
| RISK-04 assembler/toolchain | Decided 2026-11-27: project-local Python assembler, newly written for this campaign and qualified by encoding KAT from the RISC-V ISA encoding tables (no external toolchain) |

## Environment-phase answers, user, 2026-11-28

| ID | Answer | Effect |
|---|---|---|
| Q-G3-01 | A: the TOP address-region parameter declarations (identifiers, SystemVerilog array form, index order, TYPE word layout) are added to the specification (REF-001 Section 14.4.20 or 8.2) | `tb/region_params.svh` stays a placeholder and every CPU simulation plus `t_rv32d_fv_addr_decode` stay blocked until the specification text exists; the testbench is then bound from that text only (R-103) |
| Q-G3-01 follow-up | 2026-11-28: the owner approved the draft `doc/specification/DRAFT_REGION_TABLE_PARAMETERS.md` (all three confirmation points accepted as drafted). The text is now in REF-001 rev 0.40 Section 14.4.20. The specification baseline of Q-02 becomes REF-001 rev 0.40 (additive change that documents existing behaviour; the verification baseline otherwise unchanged) | `tb/region_params.svh` is to be bound from Section 14.4.20 only; CPU simulations and `t_rv32d_fv_addr_decode` are unblocked on this point |
