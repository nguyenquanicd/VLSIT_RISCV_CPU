# RTL Change Review — HDS v0.19 Coherence Delta — plan version 4

Status: APPROVED PLAN V4 — implemented in isolated output copies; source RTL unchanged

## 1. Design and input summary

- RTL root: `rtl/` in `VLSIT_RISCV_CPU`.
- New specification: `doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md`, revision 0.19.
- Existing approved baseline plan: `rtl_change_review.md`, Plan V3. This document covers only the additional v0.19 coherence contracts and does not replace or silently expand Plan V3.
- Deliverable folder: `rtl_v019_delta/`. Original RTL and the existing CSR workbook remain unchanged; the deliverable contains copies of changed RTL, a copy of the updated workbook, generated CSR RTL, the FSM V5 draw.io copy with FSM-012, filelists, reports, and logs.
- Project / RTL header: `VLSIT RISC-V CPU Cluster`; `Quan Nguyen (user)`. Modified VLSIT RTL copies add a dated history entry naming `Quan Nguyen and Codex - VLSI Technology page` and the applicable REQ IDs.
- No RTL top module is present in the current source tree. The HDS names `m_vlsit_riscv_cluster_axi_top` as the intended structural top, but no matching module definition exists under `rtl/`. The existing `project_support/rtl_layout/vlsit/README.md` also says the blocks are not assembled into a cluster top.
- Scope is the existing VLSIT coherence blocks and the generated CSR artifact. It does not create the missing cluster top, CPU tile, coherence fabric, or the other unimplemented HDS modules. It does not modify `rtl/common/third_party`, alter the native 64-bit AXI path, implement candidate 32/128/256-bit buses, or add a testbench/simulation/synthesis deliverable.
- The repository has no `.git` directory. A task-start snapshot of 1,104 RTL files was captured after approval and before the first source-copy edit.

## 2. Requirement comparison

| ID | New requirement | Previous behavior | Current RTL evidence | Intended behavior |
|---|---|---|---|---|
| REQ-MEM-019 / DEC-032 | Filter eligibility before arbitration; reservation-owner UPDATE/CANCEL must escape an ineligible request; owner issuing both terminal operations is a protocol fault | UPDATE has fixed channel priority over CANCEL, including when UPDATE is ineligible | `rtl/common/vlsit/coherence/m_vlsit_riscv_sharer_directory.sv:211-235`; reservation release at `:339-346` | A blocked non-owner operation cannot occupy the bank. Matching owner terminal operation has an escape path. Simultaneous owner UPDATE+CANCEL is accepted as neither, leaves directory/reservation unchanged, and raises the diagnostic. Otherwise arbitrate eligible operations round-robin and advance only on acceptance. |
| REQ-MEM-021 / DEC-033 | Consume every valid ACK that the response receiver can accept; discard invalid ACKs without state mutation; set sticky diagnostic | Scheduler READY requires active tag/line/phase match; transaction-table READY is asserted only for an expected ACK | `rtl/common/vlsit/coherence/m_vlsit_riscv_probe_scheduler.sv:127-139`; `rtl/common/vlsit/coherence/m_vlsit_riscv_coh_txn_table.sv:137-160` | Scheduler drains a response whenever its per-hart ACK buffer is free, emits an ACK only for the active matching response, and reports mismatches. The transaction table consumes all ACKs on its unbuffered lane, updates state only for the unique expected match, and reports/discards all others. |
| REQ-MEM-022 / DEC-035 | Consume a bank request token once; disarm its slot until VALID has been sampled low; retain a stalled grant | Arbiter excludes a just-accepted slot during that selection, but can select it again while its VALID remains high | `rtl/common/vlsit/coherence/m_vlsit_riscv_coh_bank_arb.sv:48-112` | Add per-slot armed/consumed state. Accepted slot is disarmed until a sampled low VALID rearms it. Grant VALID and slot remain stable during backpressure. |
| REQ-MEM-023 / DEC-035 | Retain tag, line, requester/owner, kind, target MESI, phase masks and completion/error status through phase completion | Context has no target-state or owner field; phase start clears owner-writeback-done and phase error | `rtl/common/vlsit/coherence/m_vlsit_riscv_coh_txn_table.sv:11-87, 103-118, 137-228`; scheduler currently samples a separate target-state vector at `:34, 167-169` | Capture target MESI at context allocation and export it by tag. Capture owner metadata from the matching directory response before PREPARE. Preserve owner-writeback completion/error and transaction error until context release. Do not permit COMMIT after a retained writeback error. |
| DEP-023 / DEC-033 | Software-visible sticky W1C coherence-protocol diagnostic | Workbook/CSR has no coherence diagnostic field | `doc/specification/VLSIT_RISCV_CPU_Cluster_CSR.xlsx`; generated module `rtl/common/vlsit/csr/RTL/m_vlsit_cpucl_csr.sv` | Add `cpucl_coh` at local CSR offset `0x0010`, bit 0 `fault`, sticky W1C; hardware set has priority over software clear. The shorter names preserve the intended coherence protocol fault while meeting the VLSIT 30-character identifier limit. Generate CSR from the copied workbook with APB-CSR-Generator v3.5 `AXIL_QUEUED`; do not hand-edit generated RTL. |

## 3. Affected modules and files

All modified RTL and generated outputs are copies under `rtl_v019_delta/`; source files remain unchanged.

| Module / artifact | Source file | Output copy | Implemented change | Reason |
|---|---|---|---|---|
| `m_vlsit_riscv_sharer_directory` | `rtl/common/vlsit/coherence/m_vlsit_riscv_sharer_directory.sv` | `rtl_v019_delta/rtl/vlsit/m_vlsit_riscv_sharer_directory.sv` | Eligibility-first arbitration; reservation-owner escape; round-robin selection among eligible operation channels; detect simultaneous owner UPDATE+CANCEL, preserve state, emit diagnostic event. | REQ-MEM-019/020 |
| `m_vlsit_riscv_coh_bank_arb` | `rtl/common/vlsit/coherence/m_vlsit_riscv_coh_bank_arb.sv` | `rtl_v019_delta/rtl/vlsit/m_vlsit_riscv_coh_bank_arb.sv` | Add per-slot token-consumed/rearm state. | REQ-MEM-022 |
| `m_vlsit_riscv_coh_txn_table` | `rtl/common/vlsit/coherence/m_vlsit_riscv_coh_txn_table.sv` | `rtl_v019_delta/rtl/vlsit/m_vlsit_riscv_coh_txn_table.sv` | Store target MESI on allocation; add tagged owner-capture handshake and owner fields; drain unexpected ACKs; preserve transaction-critical status until release; add diagnostic event output and COMMIT guard after writeback error. | REQ-MEM-021/023 |
| `m_vlsit_riscv_probe_scheduler` | `rtl/common/vlsit/coherence/m_vlsit_riscv_probe_scheduler.sv` | `rtl_v019_delta/rtl/vlsit/m_vlsit_riscv_probe_scheduler.sv` | Source probe target state from the matching transaction context; drain and discard stale/mismatched responses when the response buffer has room; emit diagnostic event. | REQ-MEM-021/023 |
| CSR workbook | `doc/specification/VLSIT_RISCV_CPU_Cluster_CSR.xlsx` | `rtl_v019_delta/doc/VLSIT_RISCV_CPU_Cluster_CSR_v019.xlsx` | Add `cpucl_coh` offset `0x0010`, bit 0 sticky W1C `fault`; document reset, hardware-set priority, software clear, and reserved bits. | DEP-023 |
| Generated CSR | `rtl/common/vlsit/csr/RTL/m_vlsit_cpucl_csr.sv` | `rtl_v019_delta/rtl/vlsit/csr_generated/RTL/m_vlsit_cpucl_csr.sv` plus generator outputs | Regenerate from the copied workbook with `CSR_Generation.py` v3.5, `AXIL_QUEUED`, `--vlsit-style`. No manual edits to generated output. | DEP-023 / R-040 |

Diagnostic event outputs from the directory, scheduler, and transaction table are exposed for later cluster-core wiring. Because the cluster top/core/fabric are not present, this delta cannot connect those events end-to-end to the CSR or claim software-visible operation in a complete cluster. That integration remains outside this plan.

## 4. Design choices

| Strategy | Functional coverage | Change size | Compatibility | Complexity | Risk |
|---|---|---|---|---|---|
| **Recommended: implement the v0.19 delta in output copies; round-robin eligible directory operation channels, with owner-terminal escape; capture owner after directory lookup** | Covers REQ-MEM-019/021/022/023 and creates the approved W1C CSR field | Moderate; five RTL artifacts plus workbook copy and generated outputs | Preserves existing module names and SoC-facing widths; internal leaf ports change | Adds small arbitration state, context metadata, and diagnostic outputs | Full integration is not possible until missing cluster core/fabric/top are implemented; exact source-to-CSR event wiring remains pending |
| Keep fixed channel priority and only add special-case CANCEL escape | Partial; continuous eligible channels may still starve | Small | Highest local compatibility | Low | Does not fully implement fair service of eligible operations |
| Implement the full cluster top and all missing integration modules in this change | Could cover more HDS scope | Very large and outside the v0.19 leaf-block delta | Requires additional upstream source-port mapping and architecture closure | High | Current source tree lacks required parents, and several integration dependencies remain open |

## 5. Minimal-change rationale

- The four VLSIT leaf modules are the only present RTL blocks that directly own the new liveness, token, ACK-drain, and transaction-context behavior.
- CSR generated RTL must be regenerated from its workbook; direct editing would violate the generator contract.
- The separate `rtl_v019_delta/` tree preserves the current project baseline and lets the designer compare the proposed changes before replacing integration sources.
- Third-party source, unrelated PMU/debug/AXI modules, HDS text, and the previous review plan are excluded. No width converter is added; 64-bit remains the supported external/native datapath in the current HDS.
- No testbench, simulation, synthesis, timing, or PPA work is included because this request asks for RTL updates, not those deliverables. Rule checking and lint are included below.

## 6. Open questions, assumptions, conflicts, risks

1. **Owner capture point:** The directory lookup returns the owner after the transaction context is allocated. The plan therefore adds a tagged owner-capture handshake (`valid/ready`, tag, owner-present, owner-hart) and requires it before PREPARE. This is the recommended mapping for REQ-MEM-023; approval of this plan approves that mapping.
2. **Directory operation fairness:** The specification says to arbitrate eligible transaction slots, while the existing directory exposes one lookup, update, and cancel channel per bank. The plan uses a rotating round-robin pointer across these eligible operation channels, except that a matching reservation-owner terminal operation takes the required escape path. This keeps one accepted operation per bank per cycle and prevents fixed-priority starvation.
3. **Writeback status mapping:** The existing tagged ACK has `i_ack_err` and `i_ack_wback_done`, but not a raw AXI BRESP field. The plan treats matching owner ACK `i_ack_err` as writeback failure and `i_ack_wback_done` as successful matching B completion; those status bits persist until release. No additional AXI response code is invented.
4. **CSR event connection:** The new generated CSR field is ready for a hardware-set input, but no cluster top/core exists to aggregate and connect the three diagnostic sources. The delta exposes the events and documents the required connection; it does not claim a complete integrated top.
5. **Top-module mismatch:** HDS Section 1.1/14.2 names `m_vlsit_riscv_cluster_axi_top`, but there is no definition in `rtl/`, and `project_support/rtl_layout/vlsit/README.md` says integration is not assembled. A future top-level build needs the missing HDS parent modules and filelist.
6. **FSM document dependency:** HDS DEP-024 requires the editable FSM source to show eligibility filtering, owner-terminal escape, and reservation release. Completed in `rtl_v019_delta/doc/specification/figures/fsm/VLSIT_RISCV_CLUSTER_FSM_V5.drawio`; the original FSM V4 source was preserved. The library-symbol check passed and the geometry checker reported zero findings for FSM-012.
7. All PREPARE/COMMIT/ABORT ACK waits remain unbounded as previously selected. No timeout or recovery policy is added.

## 7. Validation results

The following checks were run after Plan V4 approval. The task-start RTL snapshot was captured before the first source-copy edit. Python used: `C:\Users\PC\AppData\Local\Programs\Python\Python312\python.exe`.

| Check | Command / action | Expected evidence | Status |
|---|---|---|---|
| Task-start baseline | Snapshot script saved the original `rtl/` tree before source-copy edits | 1,104 RTL files captured under `rtl_v019_delta/metrics/baseline` | PASS |
| Specification gaps | `vlsit_spec_gaps.py gaps doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md` | No unresolved blocking gap | PASS — 0 BLOCK, 0 INFO |
| Workbook review | `vlsit_analyze_excel.py` on the copied workbook; inspected `AXIL_QUEUED` and address map | `0x0010` free in baseline; W1C `cpucl_coh.fault` added; 4 KiB map updated | PASS |
| CSR generation | `CSR_Generation.py` v3.5, `AXIL_QUEUED`, `--vlsit-style` | CSR generated from copied workbook; no manual RTL edits | PASS |
| Mechanical RTL rules | `vlsit_rtl_check.py check rtl_v019_delta/rtl/vlsit` | 0 errors; one generated-module HIE-02 warning | PASS |
| Block-level lint | Verilator via `vlsit_lint_rtl.py` for all four changed leaf modules and generated CSR plus two FIFO models | Four leaf modules: 0 errors/0 warnings each; CSR: 0 errors/2 unused AXI PROT warnings; no full-cluster lint because top is absent | PASS |
| Draw.io checks | VLSIT library validation and geometry check on copied FSM V5 source | 12 pages; 290 library-derived cells; FSM-012 geometry findings: 0 | PASS |
| Change metric | Compare task-start snapshot with candidate RTL tree | Baseline 232,420 lines; 234 added, 23 deleted; change percentage 0.11% | PASS |

No simulation, testbench, synthesis, formal, STA, or PPA command is approved in this plan.

## 8. Approval

Approval received: **APPROVE PLAN V4**. The plan was implemented only in the isolated output tree; original source RTL and original workbook are unchanged.

## 9. Final implementation report

Implemented. The change modifies four standalone VLSIT coherence blocks, adds the workbook-defined sticky W1C diagnostic register at local offset `0x0010`, and regenerates CSR RTL. Diagnostic event outputs are present on the leaf modules, but they are not wired to the CSR because no cluster core/fabric/top exists in this RTL tree. No simulation, testbench, synthesis, STA, or PPA was run under Plan V4.

The HDS names `m_vlsit_riscv_cluster_axi_top` as the intended structural top. No RTL file defines that module yet; `rtl_v019_delta` intentionally does not create it. Therefore there is currently no runnable cluster TOP file. The expected future filename is `rtl/non_coherence_cluster/m_vlsit_riscv_cluster_axi_top.sv` when the approved structural top is implemented.
