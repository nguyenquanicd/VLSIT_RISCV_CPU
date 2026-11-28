# Specification gaps and questions (R-104, R-105)

AI-generated (Claude Opus 5.5, 2026-11-27) from the specification baseline only. Each question names the section, gives at least two options with a concrete example, at most one recommendation and an open choice. No behaviour has been invented for these points. **All 16 questions were answered by the user on 2026-11-27** (`question_log.md`, section "Specification-gap answers"); the plan, vplan and scope record were updated the same day. Rows still blocked: Q-G0-04, Q-G0-05 and Q-G0-13 follow-ups.

| ID | Topic | Blocked (before answers) | Answer | Status after answers |
|---|---|---|---|---|
| Q-G0-01 | REF-001 revision cited by the RV32 HDS | none (assumption: 0.39) | A | closed |
| Q-G0-02 | `mstatus.SXL/UXL` in RV32 | sub-check CK-I32-06 | A | closed |
| Q-G0-03 | Campaign address-region table | MMIO, normal-uncached, >4 GiB, debug ROM rows | A | closed |
| Q-G0-04 | Native LLC service register map | REQ-MEM-003/004, REQ-IF-010 simulation rows | A | open follow-up |
| Q-G0-05 | Boundary stimulus for an L1-to-LLC writeback error | CBO owner fault, FENCE.I cause 24, L1 fatal record | B (modified by the user) | open dependency |
| Q-G0-06 | Hart-visible result of external R/B errors | MMIO error rows | A | closed |
| Q-G0-07 | Debug verification without a Debug Module | REQ-DBG-001, REQ-CLK-002 (halt) rows | A | closed |
| Q-G0-08 | Sv32 A/D-bit handling | sub-check CK-SV-05 | A | closed |
| Q-G0-09 | Observable of an above-2^34 region entry | REQ-XL-011 rows | C | closed |
| Q-G0-10 | PMU wrap/overflow verification method | REQ-PMU-002/004 rows | A | closed |
| Q-G0-11 | Exact or bounded PMU CCU event expectations | strength of CK-DOW-03, CK-STR-06 | A | open confirmation |
| Q-G0-12 | `cpucl_fault_lo/hi` address content | CK-FAT-02 address field | A | closed |
| Q-G0-13 | Binding of internal assertions SVA-101/104/105 | SVA rows of REQ-XL-007, REQ-MEM-019 | A | open follow-up |
| Q-G0-14 | IRQ/debug vector width conflict in REF-001 | CK-ELB-02 (assumption: PARA_CPU_NUM bits) | A | closed |
| Q-G0-15 | LLC geometry for the campaign | run time of eviction tests | A | closed |
| Q-G0-16 | `mhpmevent` encodings of the RV32 harts | sub-check CK-CNT-03 | B | closed |

---

### Q-G0-01 REF-001 revision

**Answered (2026-11-27): option A.** Answered: verify against REF-001 rev 0.39; DEC-046/DEC-047 expectations apply.

Context: RV32 HDS rev 0.4 Section 2.1 cites REF-001 "revision 0.36", while the campaign baseline (question log Q-02) is REF-001 rev 0.39, and RV32 HDS 14.2/20 already adopt DEC-046/DEC-047 introduced in REF-001 0.37-0.39. DEC-046 changes the expected AMO-on-S-grant behaviour.

- A. Verify against REF-001 rev 0.39 (**recommended**: matches Q-02 and the DEC-107/108 adoption text). Example: an AMO pending on an S grant must not refuse a competing PREPARE probe (DEC-046 rule 1).
- B. Verify against rev 0.36 and treat 0.37-0.39 as unadopted. Example: TEST-064-style AMO+CMO contention has no DEC-046 expectation.
- C. Other: state the revision and any excluded decisions.

### Q-G0-02 `mstatus.SXL/UXL` for RV32 (REQ-XL-003)

**Answered (2026-11-27): option A.** Answered: check only misa.MXL=1; mstatush not checked (CK-I32-06 replaced by an RV32C C.FLW/C.FSW check).

Context: REQ-XL-003 requires "mstatus.SXL/UXL equal to the 32-bit encoding". In the RISC-V Privileged ISA these fields exist only in RV64 `mstatus` (bits 35:32); RV32 has no SXL/UXL and `mstatush` does not define them.

- A. Interpret as "XLEN is fixed at 32": check only `misa.MXL=1` and that no XLEN-changing field exists (**recommended**). Example: `csrr misa` bits 31:30 = 01; `mstatush` bits that would hold SXL/UXL are not checked.
- B. Check that `mstatush` reads zero in its reserved bit positions as the "32-bit encoding". Example: `csrr mstatush` & 0x0000000F == 0.
- C. Other: give the exact CSR bits to check.

### Q-G0-03 Address-region table of the campaign

**Answered (2026-11-27): option A.** Answered: five-region table (0 cacheable 0x8000_0000/1 GiB; 1 MMIO 0x1000_0000/256 MiB; 2 MMIO 0x0000_0000/4 KiB debug ROM; 3 normal-uncached 0x4000_0000/256 MiB; 4 normal-uncached 0x3_C000_0000/1 GiB ending at 2^34); MMIO, uncached, high-PA and debug-ROM rows unblocked.

Context: REF-001 REQ-IF-011 and Section 8.2 say the default table holds only the cacheable entry 0x8000_0000/1 GiB and the SoC supplies uncached/MMIO entries; entry 0 is the only cacheable class. RV32 HDS REQ-XL-011 bounds every entry below 2^34. Without MMIO and normal-uncached entries the MMIO port, uncached atomics, high-PA aliasing and a debug-ROM window cannot be exercised; tests would end through a CBO.FLUSH signature instead of an MMIO write.

- A. One parameter set: entry 0 cacheable 0x8000_0000 size 1 GiB; entry 1 MMIO 0x1000_0000 size 256 MiB (test-end, IRQ control); entry 2 MMIO 0x0000_0000 size 4 KiB (debug ROM at HaltAddress 0x800, only if Q-G0-07 option A); entry 3 normal-uncached 0x4000_0000 size 256 MiB; entry 4 normal-uncached 0x3_C000_0000 size 1 GiB ending exactly at 2^34 (**recommended**). Example: `sw` to 0x1000_0000 appears only on the MMIO port; `lw` at 0x3_FFFF_FFFC via Sv32 is accepted. Limitation: cacheable lines keep PA[33:32]=0, so line-adapter bits 51:32 are checked only by SVA-101.
- B. As A plus a second parameter set where entry 0 is cacheable above 4 GiB (for example 0x2_0000_0000) and code runs from the 0x10000 executable window. Example: cacheable line 0x2_0000_0040 exercises line bits 29:28 set. Cost: a second build and boot flow.
- C. Default table only; MMIO, uncached and high-PA tests are removed from the campaign. Example: `t_rv32d_mmio_axi` waived.
- D. Other: supply the table.

### Q-G0-04 Native LLC service register map (REQ-MEM-003/004, REQ-IF-010)

**Answered (2026-11-27): option A.** Answered: the owner adds the native LLC service register table to REF-001 Section 11; rows stay blocked until the table exists.

Context: REF-001 Section 11.2 step S02 requires software to wait for the native LLC BIST-ready state, and REQ-MEM-003 requires SPM controls to be rejected, but the HDS and workbook (Address_Map) give only the 4 KiB window 0x5000-0x5FFF; the "native LLC RegBus map" offsets, fields, reset values and the response to unmapped offsets inside the window are not specified (REF-008 is cited without a pinned register table).

- A. The specification owner adds the LLC service register table (offset, field, access, reset, BIST/flush/SPM semantics, response code of unmapped window offsets) to REF-001 Section 11 (**recommended**). Example: "offset 0x20 BistOut, RO, bit 0 = BIST done".
- B. Approve the public PULP axi_llc register description at a stated revision as a specification input for this campaign. Example: "REF-008 at tag vX.Y, register file `axi_llc_reg`".
- C. Exclude REQ-MEM-003/004 from simulation and verify REQ-IF-010 by component formal only. Example: `t_rv32d_llc_service_bist` waived; `t_rv32d_fv_axil` kept.
- D. Other.

### Q-G0-05 Boundary stimulus for an L1-to-LLC writeback error

**Answered (2026-11-27): option B (modified by the user).** Answered: add a verification test hook connected to a cluster CSR error-injection bit, as a design change (specification DEC + CSR workbook + RTL change plan) outside this campaign; recorded as dependency DEP-DV-01, register and behaviour not yet specified; rows stay blocked.

Context: REQ-MEM-017 (owner writeback error during CBO), REQ-MEM-018 (FENCE.I cause 24 on a non-OKAY L1-to-LLC B) and REQ-ERR-003 (ordinary L1 eviction failure, source=L1) all require an error on the B response that the internal LLC returns to an L1 writeback. The HDS does not state which external TOP stimulus produces such an error (TEST-054 says only "memory fault injection"); a force on internal signals is not allowed (R-258).

- A. The owner specifies the external condition, for example "an external RRESP=SLVERR on the LLC write-allocate refill of the target line returns SLVERR to the L1 writeback", together with the affected line. Example: hart 0 owns line X dirty, LLC does not hold X, the memory BFM answers the LLC refill read of X with SLVERR, and FENCE.I then traps with cause 24 and mtval = X base (**recommended**, if the LLC behaves this way).
- B. Add an approved test hook or fault-injection input to the specification. Example: a verification-only input that makes the LLC return SLVERR for one write ID.
- C. Declare these three error paths not reachable at the TOP; verify them at REF-001 unit level and record residual risk. Example: `t_rv32d_fencei_fault`, `t_rv32d_cbo_fault_owner`, `t_rv32d_fatal_l1_eviction` waived with owner/expiry.
- D. Other.

### Q-G0-06 Hart-visible result of external R/B errors

**Answered (2026-11-27): option A.** Answered: load R error -> precise load access fault (cause 5, mtval = address); store/AMO B error -> store/AMO access fault (cause 7); SC with OKAY -> SC fails (rd=1), no trap.

Context: REQ-ERR-001 requires error responses to return to the originating path without fabricating data, and Section 12 says "source-specific AXI error response" and "native precise architectural error" for cached atomics, but no section states the exception (if any) a hart takes for: MMIO load R error, MMIO store B error, cacheable refill R error, uncached AMO (AWATOP) error, and SC with OKAY instead of EXOKAY.

- A. Load R error -> precise load access fault (cause 5, mtval = address); store/AMO B error -> store/AMO access fault (cause 7, precise); SC with OKAY -> SC fails (rd=1), no trap (**recommended** for testability). Example: `lw` from MMIO with RRESP=SLVERR traps with mcause=5.
- B. Load R error -> cause 5; store B error is not reported to the hart (posted store), only observable at the bus. Example: `sw` with BRESP=DECERR retires normally.
- C. Other: give the mapping per access kind.

### Q-G0-07 Debug verification without a Debug Module (REQ-DBG-001, REQ-CLK-002)

**Answered (2026-11-27): option A.** Answered: testbench MMIO debug ROM at 0x800/0x808 in region 2 (park loop, per-hart flag, dret on a resume flag).

Context: REF-001 REQ-DBG-001 and OP-008 place the Debug Module outside the cluster; RV32 HDS 8.2 keeps DmBaseAddress=0, HaltAddress=0x800, ExceptionAddress=0x808. A hart entering debug mode fetches from 0x800, which needs a region and code that the specification does not define.

- A. The testbench provides a minimal MMIO-served debug ROM at 0x800/0x808 per Debug Spec 0.13.2 (park loop that writes a per-hart flag, then `dret` on a testbench resume flag); needs Q-G0-03 entry 2 (**recommended**). Example: `i_hart_debug_req[0]=1` -> `o_hart_debug_mode[0]=1`, hart 1 keeps running, resume -> mode 0.
- B. Check only that `o_hart_debug_mode[n]` rises after `i_hart_debug_req[n]` and the other hart is unaffected; no resume or halt-time probe check. Example: test ends while hart 0 is halted.
- C. Exclude debug from this campaign.
- D. Other.

### Q-G0-08 Sv32 accessed/dirty bit handling (REQ-XL-005)

**Answered (2026-11-27): option A.** Answered: page fault when A=0 or when D=0 on a store; no hardware A/D update.

Context: RV32 HDS TEST-105 expects "correct translation and faults" but neither HDS states whether the harts update PTE A/D bits in hardware or raise a page fault (both are allowed by the Privileged ISA).

- A. Page fault when A=0, or when D=0 on a store (no hardware update) (**recommended**, to be confirmed by the owner for the pinned CVA6). Example: store through a PTE with D=0 -> store page fault, cause 15.
- B. Hardware sets A/D. Example: the same store succeeds and the PTE in memory has D=1.
- C. Other.

### Q-G0-09 Observable for a region entry above 2^34 (REQ-XL-011, TEST-111)

**Answered (2026-11-27): option C.** Answered: integration obligation; pre-build check script (chk_region_table) rejects base+size > 2^34; RTL behaviour unspecified.

Context: TEST-111 expects "at the bound accepted; above rejected or flagged". REF-001 TEST-051 states invalid tables lower `o_config_valid`, which is internal (not a TOP port), and that RTL does not guarantee an elaboration failure; the PLEN=56 check is specified, the 2^34 check is not assigned to any component.

- A. Elaboration must fail for an entry with base+size > 2^34. Example: building with entry 1 = 0x3_FFFF_F000 + 8 KiB stops with an error.
- B. Elaboration succeeds; every access that matches the illegal entry returns a local access error. Example: load at 0x4_0000_0000 traps with cause 5.
- C. It is an integration obligation: a parameter-set check script rejects the table before build; the RTL behaviour is unspecified (**recommended**: matches the "shall satisfy" wording and TEST-051). Example: `check_region_table.py` fails the configuration.
- D. Other.

### Q-G0-10 PMU wrap and overflow (REQ-PMU-002, REQ-PMU-004)

**Answered (2026-11-27): option A.** Answered: SymbiYosys proofs on m_vlsit_pmu_counter_bank, m_vlsit_pmu_irq, m_vlsit_pmu_snapshot plus TOP check that o_int_pmu is low with no cause (a_int_pmu_no_cause).

Context: PARA_PMU_COUNTER_W is 32 or 64 and the workbook gives no counter write/preload; wrap needs at least 2^32 events, which TOP simulation cannot reach, and `irq_raw.overflow` is W1C only, so `o_int_pmu` cannot be raised by software.

- A. Verify wrap, overflow event, sticky cause, mask and aggregate level by SymbiYosys proofs on `m_vlsit_pmu_counter_bank`, `m_vlsit_pmu_irq` and `m_vlsit_pmu_snapshot` using their REF-001 14.4 port contracts, plus a TOP simulation check that `o_int_pmu` is low with no cause (**recommended**). Example: k-induction proof "value' = (value + cnt) mod 2^W".
- B. Add a test-only preload mechanism to the specification. Example: a debug CSR that writes a live counter.
- C. Accept as not verified (residual risk).
- D. Other.

### Q-G0-11 Exactness of PMU CCU/LLC event expectations

**Answered (2026-11-27): option A.** Answered: exact counts in isolated windows with the prefetcher off; prefetcher off confirmed by the owner on 2026-11-27 (G0-CONF-01 closed).

Context: REQ-PMU-008 defines CCU occurrence counting; REF-001 10.2.1 describes the transactions of each scenario, but stale-positive holders (REQ-MEM-008), the HPDcache prefetcher (`hwpf_stride`, REF-001 14.5.78) and replays may add events; no section gives the expected count for an isolated scenario.

- A. Exact counts in an isolated window with the prefetcher stated off. Example: one dirty-owner read with no other traffic gives 0x0303 PREPARE=1, 0x0304 COMMIT=1, 0x0307 grant=1 (**recommended**, if the owner confirms the prefetcher state and the counts).
- B. Lower/upper bounds only. Example: PREPARE >= 1 and grant >= 1.
- C. Other.

### Q-G0-12 Content of `cpucl_fault_lo/hi` (REQ-ERR-003)

**Answered (2026-11-27): option A.** Answered: byte address of the line base, lo = PA[31:0] with bits 3:0 = 0, hi[1:0] = PA[33:32].

Context: workbook AXIL_QUEUED: `cpucl_fault_lo` = "physical line address bits 31:0", `cpucl_fault_hi` bits 23:0 = "bits 55:32". It does not say whether this is the byte address of the line base (bits 3:0 zero) or the line index (PA>>4). For RV32, PA[33:32] position depends on it.

- A. Byte address of the line base: lo = PA[31:0] with bits 3:0 = 0, hi[1:0] = PA[33:32] (**recommended**: "victim line address" in REQ-ERR-003 and Section 12). Example: victim 0x8000_1230 -> lo=0x8000_1230, hi=0.
- B. Line index: lo = PA[35:4]. Example: victim 0x8000_1230 -> lo=0x0800_0123.
- C. Other.

### Q-G0-13 Binding of the internal assertions SVA-101, SVA-104, SVA-105

**Answered (2026-11-27): option A.** Answered: the owner adds the SVA observation-point table to the RV32 HDS; SVA rows stay blocked until the table exists.

Context: RV32 HDS 15.3 defines SVA-101 (line-address inputs to the core), SVA-104/105 (fabric context leaves DIR_UPDATE/DIR_CANCEL only on its own-tag handshake). The HDS names patterns (`i_x_nline`, `w_update_hs[bank]`, `w_dir_update_tag[bank]`, `ENUM_ST_DIR_UPDATE`) but no complete list of hierarchical observation points; this plan may not take names from the RTL during authoring (R-103).

- A. The owner adds an observation-point table (hierarchical path, width, qualifier) for these assertions to the RV32 HDS (**recommended**). Example: "`u_core.u_tile[0].i_probe_req_nline` qualified by `i_probe_req_valid`".
- B. Allow an integration-phase engineer to map the specification names to RTL paths after authoring, with the property text frozen and a reviewer approving the mapping. Example: binding file reviewed at G1.
- C. Drop the internal assertions; rely on boundary data/hang checks. Example: REQ-XL-007 checked only by alias data.
- D. Other.

### Q-G0-14 IRQ/debug vector width (REQ-IF-006)

**Answered (2026-11-27): option A.** Answered: PARA_CPU_NUM bits ([1:0] for two harts).

Context: REF-001 Section 4 (text after the configuration table) says "interrupt/debug vectors stay four bits wide and bits 3:2 are ignored in a two-hart build", while REQ-IF-006, Section 6.1, Section 6.2 and revision note 0.35 make them PARA_CPU_NUM bits wide.

- A. PARA_CPU_NUM bits ([1:0] for two harts) (**recommended**: normative requirement and port table). Example: `i_int_meip[1:0]`.
- B. Four bits with bits 3:2 ignored. Example: `i_int_meip[3:0]`.
- C. Other.

### Q-G0-15 LLC geometry of the campaign

**Answered (2026-11-27): option A.** Answered: default LLC geometry only; eviction by footprint sweep.

Context: REF-001 8.1 says "CPU campaigns use reduced geometry" while Q-04 fixes CFG-RV32-2 at default parameters. LLC eviction tests (`t_rv32d_fatal_llc_eviction`) need a footprint above the 256 KiB LLC plus 32 KiB L1, i.e. about 19,000 line stores (estimated, not measured).

- A. Default geometry (4 ways x 4096 lines) only; eviction by footprint sweep (**recommended**: one configuration, no set-index assumption). Example: 300 KiB store sweep before injecting the B error.
- B. Add a reduced-geometry parameter set (e.g. PARA_LLC_NO_LINES=4) for eviction tests. Example: 5 lines force a dirty eviction.
- C. Other.

### Q-G0-16 `mhpmevent` encodings (REQ-XL-013)

**Answered (2026-11-27): option B.** Answered: write/read-back of both halves and carry with a written value.

Context: REQ-XL-013 requires `mhpmcounter`/`mhpmcounterh` readability and PerfCounterEn=1; event selection for `mhpmeventN` is implementation-defined (REF-001 REF-011 is cited but its encodings are not in the baseline), so a counting check of `mhpmcounterN` has no specified expected value.

- A. The owner supplies the `mhpmevent` encoding table of the pinned CVA6. Example: `mhpmevent3=1` counts L1 I-cache misses.
- B. Limit the check to write/read-back of both halves and carry on a written value with a known event (**recommended** until A exists). Example: write `mhpmcounter3=0xFFFF_FFFF`, read `mhpmcounter3h` after one event.
- C. Other.

---

## Questions raised during environment and testcase authoring (G3 phase)

| ID | Topic | Blocked (before answer) | Answer | Status |
|---|---|---|---|---|
| Q-G3-01 | TOP address-region parameter names, types and TYPE encoding | every CPU simulation (tb_top region binding) and `t_rv32d_fv_addr_decode` | A | closed |

### Q-G3-01 TOP address-region parameters (REQ-IF-011, REQ-XL-011, question_log Q-G0-03)

**Answered (2026-11-28): option A.** The owner added the parameter declarations, class encoding, validity rules 1-5, the 2^34 cluster-profile bound and the campaign parameter set to REF-001 rev 0.40 Section 14.4.20 (question_log "Q-G3-01 follow-up"). tb_top now binds them through `tb/generated/region_params.svh` (generated from `models/configs/region_table_campaign.json` after `chk_region_table` accepts it); `t_rv32d_fv_addr_decode` is unblocked. Remaining assumption, recorded in the test: the address decoder component takes the same parameter names (Section 14.4.13 lists its ports only); a mismatch fails elaboration.

Context: REF-001 Section 8.1 names `PARA_ADDR_REGION_NUM` and `PARA_ADDR_REGION_*`, and Section 8.2 says "BASE_LO/BASE_HI and SIZE_LO/SIZE_HI region parameters are sixteen-entry arrays of 32-bit words; TYPE is a sixteen-entry word array and NUM selects active entries; TYPE low bits encode the three defined classes" (REQ-IF-011: 00 cacheable, 01 normal-uncached, 10 MMIO). The exact identifiers, the SystemVerilog array form (packed `[15:0][31:0]` or unpacked `[16]`), the index order and the TYPE word layout are not given; the TOP port contract of Section 14.4.20 lists ports only. Without them the testbench cannot bind the five-region campaign table, so no CPU test can run (all of them need the MMIO region for TOHOST) and the address-decoder formal harness cannot be configured.

- A. The owner adds the TOP parameter declarations to REF-001 Section 14.4.20 (or 8.2) (**recommended**). Example: `parameter logic [15:0][31:0] PARA_ADDR_REGION_BASE_LO = ...` with entry 0 at index 0 and `PARA_ADDR_REGION_TYPE[i][1:0]` = class.
- B. The owner states the identifiers and encoding in the question log only, and the testbench uses them through `tb/region_params.svh`. Example: answer "PARA_ADDR_REGION_BASE_LO/BASE_HI/SIZE_LO/SIZE_HI/TYPE are `int unsigned [16]`, index = entry".
- C. Other.

**Answered (2026-11-28): option A.** The declarations are to be added to REF-001 Section 14.4.20 or 8.2; until then the dependent tests stay blocked.

## Other observations (no verification-behaviour change)

- RV32 HDS Section 4 still lists CFG-RV32-2 as "Specified, no RTL yet", contradicting the revision notes; editorial.
- RV32 HDS 15.5 and REF-001 14.7 cite evidence from `verification/rv32_profile`; per Q-03 it is not credited and was not read.
- AWATOP encoding subset "generated by the pinned HPDcache/PULP sources" (REQ-IF-009) cannot be checked from the specification; the plan checks E1.1 legality and the architectural result only (recorded as a limitation, not a question).
