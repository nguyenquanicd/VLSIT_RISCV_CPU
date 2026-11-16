# RTL Change Review — VLSIT RISC-V Cluster — approved Plan V4

Status: Plan V4 approved by the designer; RTL implementation is in progress. The implementation checkpoint is current through 2026-11-14; see Section 11.1 and the current checkpoint at the end of Section 11.5.

> Current source of truth: HDS v0.26 and `doc/specification/VLSIT_RISCV_CPU_CLUSTER_RTL_PORT_PLAN.md` v0.18. Sections 1–10 below preserve earlier analysis and are historical wherever they conflict with the approved Plan V4 and current HDS. RTL implementation status is tracked in Section 11.5; “approved” does not mean the full cluster implementation or verification is complete.

## 1. Design and input summary

- Project: VLSIT RISC-V Dual/Quad CPU Cluster.
- RTL source root: `rtl/common/third_party`; pristine source trees are present for CVA6,
  HPDcache, PULP AXI, PULP AXI LLC, PULP ACE, and Culsans.
- Output root previously selected by the designer: `rtl`; planned VLSIT-owned RTL
  goes in `rtl/common/vlsit`, and modified upstream copies go in `rtl/common/modified`.
- Specification: `doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md`
  (version 0.18, draft, current RTL scope is the AXI profile).
- Rule file: `C:/HQuan/102_MyGithub/VLSIT_RTL_Generator_AI_Model/spec_template/VLSIT_RTL_Design_Rule.md` (v2).
- New-file header: Project `VLSIT RISC-V Dual/Quad CPU Cluster`; Author
  `Quan Nguyen (user)`; use the VLSIT RTL Generator AI Flow and its GitHub page.
- Reused upstream RTL headers and license notices remain untouched. A modified
  copy retains its complete source header and license, then adds a dated history
  entry stating the change and `Modified by: Quan Nguyen and Codex - VLSI
  Technology page.` New VLSIT files follow the selected rule file.
- Python 3.12.10 is available. This project directory has no detected Git working
  tree, so a task-start file snapshot is required before the first RTL edit.
- Analysis was read-only. No RTL baseline lint, rule check, simulation, or synthesis
  was run. The required specification-gap scan reports 10 BLOCK entries, all
  associated with draft FSM text or unresolved FSM details.

## 2. Requirement comparison

| Requirement | Current source evidence | Required change |
|---|---|---|
| Two- or four-hart CVA6 cluster | `rtl/common/third_party/cva6/core/cva6.sv:18` is the upstream core; no VLSIT cluster wrapper exists. | Add VLSIT cluster top, tile, and integration modules for fixed two- and four-hart elaborations. |
| Internally coherent MESI D-caches | The CVA6 top boundary at `cva6.sv:322-349` exposes the memory request/response but no peer-probe interface. `cva6_hpdcache_subsystem.sv:526-528` ties read-invalidation inputs low for the AXI path. | Add a probe path through a separately modified CVA6/cache integration copy and the HPDcache directory/data control. The exact HPDcache internal file set and probe contract remain unapproved. |
| HPDcache invalidation behavior | `hpdcache.sv:87-88` accepts an inbound memory-response invalidation and line address; it does not expose a dirty-line probe response at the module boundary. | Extend the cache for line-locked probe arbitration, MESI transitions, dirty-data response, and backpressure after the FSM contract is approved. |
| AXI memory, non-coherent MMIO, and AXI4-Lite CSR access | PULP AXI and `axi_llc` source trees are present, but no cluster filelist or integrated VLSIT wrapper exists. | Reuse compatible pinned upstream blocks unchanged; add VLSIT routing and integration modules. Exact source-port and address-map binding remains open. |
| Cluster PMU, CSR, and debug routing | HDS defines PMU behavior but leaves the event dictionary and exact workbook mapping open. The expected workbook `doc/specification/VLSIT_RISCV_CPU_Cluster_CSR.xlsx` is absent. | Generate CSR only from a reviewed workbook; implement PMU/debug logic only after source/event mapping is fixed. |
| FSM documentation | The editable draw.io contains FSM-001 through FSM-009 as V1 review drafts. The gap scanner flags unresolved guards, fields, buffer/order/error behavior, and the unreviewed draft status. | Obtain review of the diagrams and close behavior-changing TBDs before writing the corresponding FSM RTL. |

## 3. Affected modules and files

### New VLSIT modules proposed under `rtl/common/vlsit`

| Module | Responsibility |
|---|---|
| `m_vlsit_riscv_cluster_axi_top` | Fixed-port AXI cluster structural top. |
| `m_vlsit_riscv_cluster_core` | Shared integration, CSR decode, PMU, and debug connections. |
| `m_vlsit_riscv_cpu_tile` | Per-hart CVA6/cache wrapper; derives PMA and exports AW/AR burst region-class/error metadata from the shared table. |
| `m_vlsit_riscv_tile_coh_adapter` | Translates source cache requests to the internal coherence contract. |
| `m_vlsit_riscv_coh_fabric` | MESI ownership, line locks, peer probes, and LLC routing. |
| `m_vlsit_riscv_addr_decode` | Validates and classifies the shared synthesis-time region table for router use; the CPU-tile adapter derives CVA6 PMA cached/non-idempotent lists from that same table. |
| `m_vlsit_riscv_axi_mmio` | Non-cacheable AXI4 peripheral route. |
| `m_vlsit_riscv_axil_decode` | AXI4-Lite CSR and LLC-service decode. |
| `m_vlsit_axi_llc` | Fixed-geometry LLC integration wrapper. |
| `m_vlsit_riscv_pmu` and its event, selector, aggregate, counter, snapshot, and IRQ blocks | Cluster PMU implementation. |
| `m_vlsit_riscv_debug_router` | Per-hart debug request/status routing. |

The exact module port tables, generated CSR fields, and FSM state/transition contracts
must be approved before these files are written. The external ACE top/proxy is excluded
from this AXI phase.

### Upstream copies proposed for modification under `rtl/common/modified`

| Source path copied from `rtl/common/third_party` | Intended change |
|---|---|
| `cva6/core/cva6.sv` | Provisional: expose a probe path to the internal cache subsystem if source-port tracing confirms no existing route. This changes the HDS `REUSE` classification and needs confirmation. |
| `cva6/core/cache_subsystem/cva6_hpdcache_subsystem.sv` | Route the cluster probe path to/from HPDcache instead of tying AXI invalidation inputs low. |
| `cva6/core/cache_subsystem/cva6_hpdcache_wrapper.sv` | Carry probe and dirty-line response signals across the CVA6/HPDcache wrapper. |
| `hpdcache/rtl/src/hpdcache.sv` | Add the probe-facing cache boundary and coordinate probe versus CPU/refill work. |
| `hpdcache/rtl/src/hpdcache_ctrl.sv`, `hpdcache_ctrl_pe.sv`, `hpdcache_memctrl.sv`, `hpdcache_miss_handler.sv`, and possibly `hpdcache_pkg.sv` | Candidate internal changes for same-line exclusion, tag/state lookup/update, dirty data extraction, and refill/probe arbitration. Final inclusion depends on the approved FSM and source-port trace. |

No source under `rtl/common/third_party` is to be edited. Any source file added to the
modified-copy list requires a new review-plan version before it is changed.

### Reused and generated sources

- Preserve source headers for CVA6 I-cache and compatible PULP AXI/AXI-LLC units;
  list only the selected dependency closure in the final filelist.
- Do not treat the Culsans PlanV submodule as a drop-in compatible OpenHW cache
  controller. The approved source baseline is OpenHW CVA6 plus OpenHW HPDcache.
- Generate `m_vlsit_cpucl_csr` only after a workbook with fixed fields, access types,
  offsets, and reset values is reviewed. No register RTL is hand-written.
- The common RTL reuse scan found synchronizer/reset candidates, but no functional
  equivalent for the cluster modules. The specification uses one cluster clock and
  says reset deassertion is synchronized by the SoC, so those candidates are not
  selected for this design.

## 4. Design choice

| Strategy | Functional coverage | Change size | Compatibility | Complexity | Risk |
|---|---|---:|---|---|---|
| Recommended: preserve pristine upstream trees, reuse compatible source files unchanged, place modified copies under `rtl/common/modified`, and author VLSIT glue/control modules under `rtl/common/vlsit`. | Covers the approved AXI cluster architecture when the FSM, CSR, and port gaps are closed. | Large: cluster glue plus deep HPDcache probe/MESI changes. | SoC-facing AXI profile remains as specified; internal CVA6/cache interfaces change only in copies. | High. | High until probe behavior, source ports, CSR workbook, and synthesis storage binding are reviewed. |

## 5. Minimal-change rationale and exclusions

- Keep all original source snapshots under `rtl/common/third_party` byte-for-byte unchanged.
- Reuse CVA6 and PULP functions where their actual ports/parameters/behavior match;
  do not create new versions of those functions.
- Limit source modifications to the cache probe/MESI path and required integration
  boundaries. Do not reformat or rename unrelated upstream RTL.
- Keep all new VLSIT logic in one-module-per-file form under the v2 coding rules.
- Do not generate the future external ACE top/proxy, DTM/Debug Module, verification
  testbench, or target-specific SRAM macro wrapper in this plan. No PPA/signoff claim
  is possible until the SoC library, macro views, and constraints are supplied.

## 6. Open questions and conflicts

1. FSM-001 through FSM-009 are review drafts, not an accepted RTL contract. In
   particular, FSM-002 through FSM-009 contain open request fields, source-port
   mapping, queue/buffer policy, address map, response/error behavior, or ordering.
2. The HDS currently marks `cva6` as `REUSE` unchanged, but the checked top-level
   ports do not expose a peer cache probe path. The proposed `cva6.sv` copy must be
   classified as `MODIFY` if the source trace confirms it is required.
3. The CSR workbook is missing. Its register offsets, reset values, PMU event
   encodings, queue depths, and exact field access types are not ready for CSR RTL.
4. The exact modified HPDcache internal file list depends on the approved MESI/probe
   FSM and a detailed trace through its directory, data, miss, and refill controls.
5. No target SRAM macro, port model, memory timing, PDK, or SDC is supplied. RTL
   integration can be prepared, but macro binding and synthesis/timing signoff remain
   integration work.

## 7. Proposed validation (not run)

| Check | Command | Expected evidence |
|---|---|---|
| Capture task-start baseline after approval and before RTL edits | `python <skill>/scripts/vlsit_rtl_change_metrics.py snapshot rtl .rtl_baseline_cluster_v1` | Snapshot of the supplied RTL tree outside `rtl`. |
| Generate the approved source filelist | `python <skill>/scripts/vlsit_lint_rtl.py filelist rtl --out rtl/filelist.f --top m_vlsit_riscv_cluster_axi_top` | Compile-order list containing each selected reused, modified, and new source file. |
| Check new VLSIT RTL | `python <skill>/scripts/vlsit_rtl_check.py check rtl/common/vlsit` | `RESULT: PASS`; manual rule coverage recorded. |
| Lint integrated source set | `python <skill>/scripts/vlsit_lint_rtl.py lint rtl/filelist.f --top m_vlsit_riscv_cluster_axi_top` | No new lint errors; inherited source findings compared with the task baseline. |
| Generate and verify CSR | `python <skill>/scripts/vlsit_csr_generate.py generate <reviewed_workbook.xlsx> --sheet CSR --out lint/common/legacy_vlsit/csr --project "VLSIT RISC-V Dual/Quad CPU Cluster" --author "Quan Nguyen (user)"` and `verify lint/common/legacy_vlsit/csr` | Workbook hash, pinned generator, generated-port check, and manifest. Blocked until workbook exists and is approved. |
| Compare code-change percentage after implementation | `python <skill>/scripts/vlsit_rtl_change_metrics.py compare .rtl_baseline_cluster_v1 rtl` | Baseline, added/deleted RTL code lines, changed files, and calculated percentage. |

Simulation is not included because no cluster testbench was requested. Synthesis,
STA, CDC/RDC, and formal checks are not claimed by this plan.

## 8. Approval status

Awaiting review of the FSM V1 contract and the missing CSR workbook. The designer has
already approved deep CVA6/HPDcache probe and MESI modification in principle; source
inspection shows that a copied CVA6 top may also need a probe-port change. That file
must be explicitly listed in the final plan. No RTL file has been changed. Once the
FSM behavior and CSR source are closed, this review will be updated with the exact
module/file list and a named approval gate.

## 9. Plan version 2 addendum — source-header and modification-history policy

This addendum records the designer's latest RTL-source handling requirements and
supersedes any conflicting interpretation above:

- **REUSE unchanged:** copy the selected RTL source without changing its header,
  license text, or source contents. Record provenance in the dependency manifest,
  not in the RTL header.
- **MODIFY copy:** leave `rtl/common/third_party` untouched. In the copied file, preserve
  the upstream header and license verbatim, then append a clearly separated
  `Modification History` entry dated `2026-11-07`. It must enumerate the exact
  functional/structural edits and identify `Quan Nguyen and Codex - VLSI Technology
  page` as the modification authors. Do not claim changes that are not in the diff.
- **NEW VLSIT RTL:** one module per file; use the selected
  `VLSIT_RTL_Design_Rule.md` v2 and its required header/format. Header Project is
  `VLSIT RISC-V Dual/Quad CPU Cluster`; Author is `Quan Nguyen (user)`; include the
  VLSIT RTL Generator AI Flow attribution and project-page link; give each module a
  specific description. New code must not contain an upstream license header.
- A file is classified as `MODIFY` only when its source behavior/interface is
  changed. A merely instantiated source remains `REUSE` and its header stays exact.

No RTL source was changed while recording this addendum. The current FSM V1 remains
a review draft. The following unresolved design items still prevent an approval-ready
RTL plan:

1. **FSM-002:** exact coherence request fields and whether AMO uses the same exclusive
   request/response path as stores.
2. **FSM-003/004:** mapping of CVA6/HPDcache miss, upgrade, probe, dirty-data, refill,
   response, source-ID and backpressure signals; the upstream CVA6 top currently has
   no peer-probe port, so a copied `cva6.sv` is likely a required `MODIFY` file.
3. **FSM-005/006/007:** AXI4-Lite target map/queue behavior, CSR partial-write and
   response semantics, and PMU snapshot command/clear behavior. The approved CSR
   workbook draft does not exist at the expected path yet.
4. **FSM-008/009:** MMIO address windows, legal burst size/length/alignment, ordering,
   buffering, timeout policy, malformed `LAST` handling, and DECERR/SLVERR mapping.
5. **FSM freeze:** V1 pages were requested for later review; they are not an approved
   transition contract. The gap checker currently reports 10 BLOCK items (including
   this draft status and the TBDs above).

The file-level modification list remains provisional until the probe route is traced
through the pinned cache source and FSM behavior is frozen. Any added upstream file
or changed behavior will be shown in a new plan revision before RTL edits. The next
gate is designer review of FSM V1 and closure of the listed behavior decisions; only
then will this document contain the exact file list and a direct `APPROVE / REVISE /
STOP` sign-off request.

## 10. FSM V1 technical review — proposed dispositions

Review basis: HDS v0.4 Sections 3, 5, 6, 10, 11, and 14.6; the nine editable
pages in `doc/specification/figures/fsm/VLSIT_RISCV_CLUSTER_FSM_V1.drawio`; the
pinned OpenHW CVA6/HPDcache source copies; local CSR generator v3.3 documentation;
and Arm IHI 0022H. This is a design review, not a frozen contract. The recommended
changes below must be accepted or revised before the diagrams receive stable
transition IDs and before RTL is written.

### 10.1 Page-by-page findings

| FSM | V1 finding | Recommended disposition |
|---|---|---|
| FSM-001 — read miss | The diagram always ends at `ST_GRANT_SHARED`. HDS REQ-MEM-001 and Section 10.2.1 require E when no peer has a copy, and S when a peer has a copy. The dirty-owner path does not show a completion/error from the LLC writeback. | **Revise.** After collecting all peer responses, branch on any peer copy and dirty owner. No peer copy: fetch from LLC/AXI and grant E. Clean peer copy: use current LLC data and grant S. M owner: capture the complete 16-byte line, update LLC successfully, then allow owner M→S and grant requester S. On refill/writeback error, return an error to the requester, do not install/grant a valid line, and release the lock only after the error response is accepted. |
| FSM-002 — write/AMO ownership | `Requester already has S?` omits E; its NO path says requester is I, although an E line must transition locally to M under Section 10.2.1. The AMO path has no execution/commit completion. | **Revise.** Treat E and M hits locally; for S, invalidate peers and reuse the requester’s line without refill; for I, obtain data from a dirty peer or LLC. Grant M only after invalidations and line data are complete. For AMO, keep same-line serialization until the atomic update has committed and its architectural response is accepted. Do not classify an E requester as an I miss. |
| FSM-003 — modified D-cache probe | V1 covers ReadShared and Invalidate but not the clean-invalidate behavior named in Section 10.2.1. It updates M→S as soon as two data beats are accepted, earlier than the HDS requirement that the LLC be current before the owner becomes clean. It similarly invalidates M without showing the dirty-data commit point. | **Revise.** Add an explicit completion from the CCU. On ReadShared, M remains authoritative until the CCU confirms successful LLC update; then change M→S. On Invalidate, M remains valid until the CCU has safely captured/transferred the full line; then change M→I. S/E answer ReadShared without data and remain/become S; S/E answer Invalidate without data and become I; I answers no-hit. Add the specified clean-invalidate/writeback path or assign it a separate FSM ID. A probe must wait behind an older same-line refill; it must not deadlock by blocking the refill it is waiting for. |
| FSM-004 — tile coherent-request adapter | The request and response records, IDs, retry/error path, and source-to-local command mapping are open. The upstream memory-side interface is not the proposed local coherence interface. | **Keep the high-level sequence; do not freeze fields yet.** Trace the selected revision’s request acceptance, tag/PMA phase, miss/refill ID, write/AMO indication, response/error, and memory-side data path. The adapter must hold accepted fields stable, preserve requester/MSHR association, and return exactly one completion. Add error recovery and ensure local cache hit paths do not traverse this FSM. |
| FSM-005 — AXI4-Lite read | Decode and response hold are sound at a high level, but target windows and queue policy are absent. | **Keep with explicit contract.** Use aligned 32-bit accesses. Route the reviewed CSR and LLC-service windows; return target RRESP/RDATA unchanged. Misaligned mapped accesses return SLVERR; aligned unmapped accesses return DECERR with zero data and no side effect. Hold RVALID/RDATA/RRESP until handshake. The workbook must define non-overlapping windows and the selected generator mode/depth. |
| FSM-006 — AXI4-Lite write | V1 collects AW and W independently, which is correct, but `ST_ISSUE_TARGET_AW_W` does not show that the target AW and W channels can handshake on different cycles. Partial-write policy is deferred despite HDS 11.4 proposing HONOR. | **Revise.** Keep one AW entry and one W entry independently; pair only after both handshakes. Forward target AWVALID and WVALID independently and remember each acceptance separately. Return B only after both target handshakes and the target B response. Honor WSTRB (including WSTRB=0000 as a no-op) as the intended HDS/generator policy; remove the contradictory “rejected partial strobe” branch. For a locally rejected write, do not update any CSR field. Hold BVALID/BRESP until accepted. |
| FSM-007 — PMU snapshot | Capture-and-hold is appropriate, but the request auto-clear and done clear are still delegated to an absent workbook. | **Revise and bind to the workbook.** A software snapshot command atomically captures every counter on its accepted command edge, including that edge’s selected event increments; the snapshot bank remains stable until the next accepted command or reset. Hardware clears the command field after capture. Recommend sticky `snapshot_done`, cleared by a new command or W1C, with hardware set taking priority over simultaneous software clear. This is consistent with the generator’s supported `w1c`/hardware-load semantics; the workbook must encode it. There is no multi-cycle busy state unless the chosen implementation requires one. |
| FSM-008 — AXI4 MMIO read | V1 adds an internal MMIO decode, but HDS defines an external AXI4 Manager boundary and leaves the SoC address/attribute map as an integration input. It also shows one error response state even though AXI4 reads are bursts. | **Recommend replacing local decode with transparent route/arbitration.** Classify device traffic from the CVA6/HPDcache memory attributes and send it to the external AXI4 fabric; let that fabric decode addresses and return DECERR. The cluster preserves ID, attributes, RRESP, RLAST, and all accepted beats, with READY backpressure and no timeout. If a cluster-local address decoder is required instead, the SoC must supply a non-overlapping window table and the FSM must generate one R beat per accepted ARLEN entry, with RLAST on the final beat. |
| FSM-009 — AXI4 MMIO write | V1 correctly recognizes independent AW/W arrival, but the local decode-error branch lacks W-burst drain through WLAST. A B response cannot complete a legal write before all write-data beats are accepted. | **Recommend matching FSM-008 transparent route/arbitration.** Preserve AW and W independently, maintain AXI4 write ordering, route W beats to the selected target through accepted WLAST, then return the target BID/BRESP unchanged. If local decode is retained, first retain AW, accept/discard the full associated W burst through WLAST for an unmapped address, then return DECERR; do not issue a target write or side effect. No timeout is implied by AXI; a system watchdog is an integration feature. |

### 10.2 Cross-FSM architecture issues

1. **Coherence transaction capacity is not frozen.** The HDS requires line-level locks and says unrelated lines remain eligible subject to CCU capacity, but V1 has a single linear sequence and no transaction-table/queue rule. With broadcast probes and at most one active probe per D-cache, a single CCU transaction slot serializes all ownership misses/upgrades. Local D-cache hits may continue, but independent misses cannot progress through the CCU while that slot is occupied. This can reduce IPC for miss-heavy or sharing workloads. The RTL must not claim concurrent miss progress without specifying multiple contexts and compatible per-cache probe capacity.
2. **Dirty-line ownership needs a commit handshake.** V1 must distinguish “CCU has accepted both beats” from “LLC writeback succeeded.” ReadShared cannot demote the M owner before the latter. Invalidate may invalidate after the CCU has durably captured the line, but only if the CCU retains the full line through requester completion. The line-lock release point and error behavior must be identical across FSM-001..004.
3. **Probe versus refill ordering needs one linearization rule.** The recommended rule is: an already accepted same-line refill completes before a later probe; the probe is then serviced against the stable installed line. A later same-line CPU request waits behind the active line lock. A probe must never block an older refill while waiting for that refill to complete.
4. **Internal local-probe records are absent from the port contract.** HDS describes AC/CR/CD-style outcomes but does not define the VLSIT request command, response status, data-beat ordering, requester ID, or commit acknowledgement. These are internal design records, not signals from the external ACE profile. Freeze them only after source mapping.
5. **CSR workbook is a real dependency.** The expected workbook is absent. The generator documentation states AXI4-Lite `QUEUED` depths are independently configurable from 1 to 8 and that its read/write requests share a round-robin CSR engine. HDS 11.4 proposes HONOR strobes. Recommend `QUEUED`, depth 1 read + 1 write as the low-area baseline unless the designer chooses more buffering. Register offsets, LLC window, fields, and hardware-clear/W1C types still require workbook review.
6. **Do not add AXI timeout behavior by assumption.** Arm AXI uses per-channel VALID/READY handshakes; a compliant source holds payload until accepted. No timeout is specified by the protocol. A timeout must be a separate product/system requirement, including the response, cancellation, and late-response policy. The current FSMs should wait with stable payload and apply backpressure.

The AXI channel/handshake conclusions above are grounded in Arm’s official
[AMBA AXI and ACE Protocol Specification, IHI 0022H](https://developer.arm.com/-/media/Arm%20Developer%20Community/PDF/IHI0022H_amba_axi_protocol_spec.pdf?hash=6325311012DDADF238C35A6C0FD734E520754F82&la=en&revision=71bd7c57-2ed7-487b-bc3e-68c4ab56fa5f).

### 10.3 Source-based limitation

The current OpenHW `cva6_hpdcache_subsystem.sv` AXI branch ties
`dcache_resp_read_inval` and its line address to zero. The `hpdcache.sv` boundary
has an invalidation input associated with a memory read response, but no CCU probe
request, dirty-line response stream, or response-ready/commit interface. Therefore
FSM-003 is not implementable by merely connecting the existing invalidation input.
The modified copy needs a source-level design for tag/state lookup, access to both
64-bit words of a dirty 16-byte line, arbitration against cache requests/refills,
and completion/error handling. The pristine upstream files and their headers/licenses
remain unchanged under the source policy in Section 9.

### 10.4 Decisions still required before FSM freeze

| Decision | Recommended default | Reason and tradeoff |
|---|---|---|
| CCU request concurrency | One active broadcast ownership transaction in the first RTL version; local cache hits continue. | Fits one active probe per cache and limits modified cache state/control. Misses/upgrades across the cluster serialize, so IPC for miss-heavy workloads is lower. If the target requires parallel misses, approve multi-context CCU and multi-probe cache support before RTL; this is a materially larger change. |
| AXI4-Lite CSR queues | `QUEUED`, depth 1 read and 1 write, independent queues; HONOR WSTRB. | Matches the chosen generator mode with minimal storage; only one pending request per direction. Higher depths can improve control-plane burst acceptance but do not affect CPU data-path throughput. |
| AXI4 MMIO decode ownership | DEC-037 adds a shared region-class table for PMA/router classification; it identifies MMIO ranges but does not select individual peripheral targets. The external fabric still decodes targets. | Avoids duplicating the SoC peripheral map while allowing the cluster to separate cacheable, normal-uncached, MMIO, and unmapped traffic. SoC supplies the actual MMIO ranges. |
| Unsupported or malformed AXI MMIO traffic | Treat protocol violations as integration/checker failures; pass compliant transactions and downstream errors unchanged. | Avoids fabricating a private timeout/recovery contract. A local decoder, if retained, must separately define legal bursts and error-drain behavior. |
| AXI4-Lite protection | Map ARPROT/AWPROT to the generator’s protection setting only after the SoC security policy is provided; otherwise leave access policy as an explicit integration dependency. | HDS assigns secure/non-secure address policy to the SoC; silently enabling or disabling protection would change software access behavior. |

Status after review: FSM-001..003, FSM-006, and FSM-008/009 require diagram revisions;
FSM-004 requires pinned-port mapping; FSM-005/007 require the CSR workbook. No FSM
is frozen, no transition IDs have been assigned, and no RTL has been edited. The
designer must accept/revise the recommendations in Section 10.4 and the required
FSM corrections before the plan can be made approval-ready.

## 11. Plan v3 — current approval package (2026-11-08)

This section supersedes the outdated status statements in Sections 1–10. It is the
approved plan for the AXI-profile RTL. It records confirmed design choices, module
boundary contracts, license handling, completed implementation work, and remaining
integration dependencies.

### 11.1 Current baseline and checks

| Item | Current result |
|---|---|
| Specification | `doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md`, v0.21; DEC-037 is the current address-attribute contract. |
| RTL port plan | `doc/specification/VLSIT_RISCV_CPU_CLUSTER_RTL_PORT_PLAN.md`, v0.18; source audit and proposed integration boundary. |
| Specification-gap scan | `vlsit_spec_gaps.py gaps ...`: `RESULT: NO BLOCK GAP`, 0 BLOCK and 0 INFO. This does not prove that RTL ports elaborate or that the selected source copies are compatible. |
| CSR workbook | `doc/specification/VLSIT_RISCV_CPU_Cluster_CSR.xlsx` exists. Generator sheet: `AXIL_QUEUED`; additional sheets: `Address_Map`, `Review_Notes`, `Event_Map`. It was generated with the approved local CSR generator v3.5 `--vlsit-style`; detailed PMU source mapping and proposed CCU event taps remain an integration dependency. |
| FENCE.I error contract | Non-OKAY owner B response preserves the failed M line and directory holder, completes ABORT before a precise synchronous cause-24 exception at the FENCE.I PC, and reports the aligned physical line base in `mtval`/`stval`. The exact CVA6 trap-path implementation remains unverified. |
| WF-019 | Strict WaveJSON lint PASS (0 errors/warnings, 29 signals); offline HTML and SVG generated and parsed. The waveform shows separate success and error FENCE.I transactions. |
| FSM V4 | Generated from the VLSIT draw.io library; 265 library-derived cells across 11 pages; geometry checker reports 0 findings. The refreshed FSM V4 is still awaiting explicit designer review as a complete diagram set. |
| Reuse scan | 213 `common_rtl` modules scanned. The leading matches are reset/synchronizer helpers; none replaces the cluster functions. The SoC supplies synchronously deasserted reset and the design has one clock domain, so no reset/CDC helper is selected. PULP `axi_mux` remains an unchanged upstream reuse candidate. |
| RTL implementation | New VLSIT RTL exists for PMU event selection/counting/snapshot/IRQ, debug routing, AXI4-Lite window decode and RegBus bridge, shared address-region decoding, and a CVA6 tile wrapper. The tile calls a licensed local `build_config_with_addr_regions` function so CVA6 cached/non-idempotent PMA lists derive from the same table as the router. Coherence transaction tracking, sharer directory, bank arbitration, probe scheduler, and generated CSR also exist. These blocks remain standalone: the cluster core/router, native HPDcache coherence path, CCU transaction orchestration, and LLC maintenance integration are incomplete. |
| Rule check and lint | The whole `rtl/common/vlsit` rule check passes with no rule errors; the one HIE-02 warning is in generated CSR because the peripheral combines bus logic with FIFO instances. Verilator lint passes for the PMU, debug router, AXI4-Lite decoder, transaction table, sharer directory, probe scheduler, and bank arbiter. The bank arbiter elaborates with 5, 8, and 16 transaction slots. CSR and AXI4-Lite/RegBus bridge each have two intentional unused PROT input warnings because PULP RegBus has no PROT fields. |
| CVA6 local modifications | `csr_regfile.sv` accepts supervisor software/timer interrupt inputs and ORs them with stored software-writable MIP.SSIP/STIP state for the effective read/interrupt view; `cva6.sv` exports the PMU vector and architectural debug-mode state; `perf_counters.sv` exports the 22 raw source events. The copied `build_config_pkg.sv` maps DEC-037 table classes into CVA6 PMA lists. A temporary port-compatible CVA6 blackbox was used only to syntax-check the tile/package wrapper; it is not a CVA6 hierarchy lint. Full CVA6/cluster lint is not claimed. |
| Verification scope | CSR generator test regression passes 27/27; Golden quick regression passes. Standalone rule checks and lint cover the listed VLSIT RTL blocks. No cluster-level simulation, synthesis, STA, PPA, or source-level CVA6/HPDcache integration has been completed. |

### 11.2 Designer-approved architectural contracts

- Generate only the AXI profile now; defer the external ACE top and proxy.
- Support `PARA_CPU_NUM=2` or `4`, default `4`; use the selected upstream OpenHW CVA6 application configuration with a local license-preserving CVXIF-disabled configuration copy.
- Build MESI D-cache coherence with an independent sharer directory, 4 banks, 8 ways, tree-PLRU victim selection, per-bank round-robin arbitration, and `PARA_COH_TXN_NUM=8` by default (legal 2–16). Use tagged PREPARE/COMMIT with pre-COMMIT ABORT; no timeout applies to PREPARE, COMMIT, or ABORT ACKs.
- Keep line data on the owner's existing HPDcache AXI path. The owner remains M and locked until COMMIT or ABORT; a dirty 16-byte line uses two 64-bit transfers. Do not add a CCU AXI data source or widen the already selected external ID boundary.
- Use the DEC-037 shared synthesis-time region table to classify addresses for both CVA6 PMA generation and the router. Cacheable requests use CCU/LLC; normal-uncached requests use the LLC bypass path; configured MMIO ranges bypass CCU/LLC to the external MMIO AXI port; unmapped and boundary-crossing accesses fail locally. The SoC supplies actual uncached/MMIO entries, not a separate per-peripheral decode table. Preserve AXI4+ATOP at the memory port; the SoC must provide atomic service or a real ATOP-to-atomic bridge.
- Use one 32-bit AXI4-Lite configuration port. Keep the pinned LLC unchanged and add the VLSIT AXI4-Lite-to-RegBus service bridge. Generate `m_vlsit_cpucl_csr` from the workbook; no hand-written CSR RTL.
- Implement per-line CBO maintenance with precise Store/AMO access fault code 7 after ABORT on writeback failure. Implement local FENCE.I dirty-line clean-to-LLC, no LLC-to-DRAM writeback, and cause-24 precise maintenance exception on L1-to-LLC B error.
- Keep the Debug Module external; expose per-hart debug request/status. Provide the PMU event selectors/counters/snapshot/aggregated IRQ described by the workbook; exact Event_Map event wires and proposed CCU tap conditions require review.
- Preserve the user's source policy: pristine upstream clones remain unchanged; modified copies retain the complete upstream header/license and append a dated history of the actual changes by `Quan Nguyen and Codex - VLSI Technology page`; new VLSIT modules use the selected RTL rule v2 and the approved project/author header.

### 11.3 Proposed RTL modules and interface matrix

The AXI top's complete external signal table remains HDS Section 6.2; this plan does
not create a second, drifting port list. Internal ports are proposed as flattened
ready/valid channels, not SystemVerilog packages. Final signal spellings and any
source-specific adapters must follow the approved RTL rule and the pinned source
interfaces.

#### Proposed flattened port schemas

All listed modules use `i_clk_cluster` and active-low `i_rst_n_cluster`. The following
are the reviewable port groups and field widths; signal names follow the selected
VLSIT direction-prefix rule. Internal operation/state encodings are localparams in
the owning module, not a shared package.

| Channel | Source → destination | Inputs to destination | Outputs from destination |
|---|---|---|---|
| Ownership request/grant | Tile adapter ↔ coherence fabric | `i_req_valid`, `i_req_id[2:0]`, `i_req_pa_line[51:0]`, `i_req_kind[1:0]`; fabric backpressure is `o_req_ready` | `o_grant_valid`, `o_grant_req_id[2:0]`, `o_grant_pa_line[51:0]`, `o_grant_state[1:0]`, `o_grant_error`; tile accepts with `i_grant_ready` |
| Tagged probe | Probe scheduler ↔ each tile adapter | `i_probe_valid`, `i_probe_tag[max(1,$clog2(PARA_COH_TXN_NUM))-1:0]`, `i_probe_pa_line[51:0]`, `i_probe_phase[1:0]`, `i_probe_target_state[1:0]`; target tile returns `o_probe_ready` | `o_probe_rsp_valid`, matching tag/address, `o_probe_rsp_state[1:0]`, `o_probe_rsp_error`, `o_probe_rsp_wback_done`; CCU accepts with `i_probe_rsp_ready` |
| Directory lookup/update | Coherence fabric ↔ sharer directory | Four indexed lanes: `i_lookup_valid[3:0]`, `i_lookup_pa_line[3:0][51:0]`, `i_lookup_tag`, `i_update_*`, and `i_cancel_*`; lane index must equal `line[1:0]` | Registered lookup response with hit/victim way, holder bitmap, owner and MESI state; per-lane ready; miss set remains reserved until matching update/cancel. `m_vlsit_riscv_coh_bank_arb` selects per-bank transaction slots. |
| Bank arbitration | Active transaction contexts → directory lanes | `i_req_valid[PARA_COH_TXN_NUM-1:0]`, `i_req_bank[PARA_COH_TXN_NUM-1:0][1:0]`; downstream supplies `i_gnt_ready[3:0]` | `o_gnt_valid[3:0]`, `o_gnt_slot[3:0][LPARA_COH_SLOT_W-1:0]`; each grant is registered and held until accepted. |
| Transaction context | Coherence fabric ↔ transaction table | Allocate source/request ID/line/kind; start PREPARE/COMMIT/ABORT with expected-hart mask; accept tagged phase ACKs; explicit release | Lowest-free allocated tag; per-slot metadata, expected/received masks, active/done/error and owner-writeback status. The caller owns LLC/requester completion and safe release timing. |
| Tagged probe scheduler | Transaction contexts ↔ per-hart cache probes | Context valid/line/phase/target state and expected/received masks; per-hart request ready and tagged response valid | One held request and one held ACK per hart; per-hart round-robin context selection; accepts only matching tag/line/phase responses |
| CBO command/completion | Modified CVA6 retirement/cache path ↔ CMO controller | `i_cmo_valid`, `i_cmo_op[1:0]`, `i_cmo_pa_line[51:0]`, original `i_cmo_vaddr[63:0]`, `i_cmo_pc[63:0]`, `i_cmo_hart[1:0]`; controller returns `o_cmo_ready` | `o_cmo_done`, `o_cmo_error`; writeback error is returned only after all required ABORT ACKs |
| LLC per-line maintenance | CMO controller ↔ modified LLC service | `i_maint_valid`, `i_maint_op[1:0]`, `i_maint_pa_line[51:0]`; LLC returns `o_maint_ready` | `o_maint_done`, `o_maint_error`; on failure preserve LLC tag/dirty/data and return the matching transaction status |
| AXI4-Lite control | External SoC ↔ AXI-Lite decode ↔ generated CSR/LLC bridge | Fixed 32-bit data, 32-bit byte address and four WSTRB lanes; full channel ports remain those listed in HDS §6.2 | Route CSR-window traffic to `m_vlsit_cpucl_csr`; route LLC-service-window traffic through `m_vlsit_axil_reg_bridge`; reserved offsets return the documented response |
| Per-hart PMU events | CVA6/HPDcache/CCU/LLC taps → PMU | Per-hart one-bit event indicators; cluster transaction occurrence counts are 3 bits for 0–4; stall/full events are one-bit cycle indicators | Per-counter selected event and scope, accumulated count, overflow cause, snapshot image and aggregate interrupt |
| Debug | External Debug Module ↔ cluster debug router ↔ tiles | Four `i_hart_debug_req` lanes; top ports remain HDS §6.2 | Four `o_hart_debug_mode` status lanes; unused hart lanes are ignored for `PARA_CPU_NUM=2` |

Proposed encodings for review: request kind `00=GET_SHARED`, `01=GET_EXCLUSIVE`,
`10=WRITEBACK`; MESI state `00=I`, `01=S`, `10=E`, `11=M`; probe phase
`00=PREPARE`, `01=COMMIT`, `10=ABORT`; CMO op `00=CLEAN`, `01=FLUSH`, `10=INVAL`.
Unused encodings are reserved and rejected. The channel schemas are internal
implementation contracts; the external AXI/AXI4-Lite port names and widths are fixed
by HDS §6.2. User review is still required before code because the upstream source
mapping and the event map must match these proposals.

| Module | Classification | Proposed ports / boundary contract |
|---|---|---|
| `m_vlsit_riscv_cluster_axi_top` | NEW | External ports exactly from HDS §6.2; structural top instantiates the shared core, 2/4 tiles, AXI memory mux, MMIO route, CSR, and LLC. |
| `m_vlsit_riscv_cluster_core` | NEW | Cluster clock/reset, boot/interrupt/debug vectors, AXI4-Lite control, AXI memory/MMIO request paths; fans out hart identity and collects PMU IRQ/status. |
| `m_vlsit_riscv_cpu_tile` | NEW × `PARA_CPU_NUM` | CVA6 native boot, hart ID, interrupt, debug, performance-event and AXI request/response boundaries; derives PMA and exports shared-table AW/AR burst region match/index/class/error metadata. One instance per zero-based hart index. |
| `m_vlsit_riscv_tile_coh_adapter` | NEW × `PARA_CPU_NUM` | Native 3-bit HPDcache request ID and 52-bit physical line address to ownership request/grant; local cache also receives tagged probes and returns tagged status/writeback completion. |
| `m_vlsit_riscv_coh_fabric` | NEW | Per-hart ownership request/grant arrays, tagged probe request/response arrays, shared line locks, directory transactions, LLC data path and maintenance completion. |
| `m_vlsit_riscv_coh_txn_table` | NEW | Allocate lowest-free tag; store source, request ID, line, kind, phase, expected/received ACK masks, phase status/error and owner writeback status. LLC/requester completion is tracked by the fabric. |
| `m_vlsit_riscv_coh_bank_arb` | NEW | Four independent registered round-robin arbiters; one active transaction slot per directory bank, stable grants under backpressure, pointer update on accepted grant. |
| `m_vlsit_riscv_sharer_directory` | NEW | Four fixed bank lanes, 8-way sets, invalid-first/tree-PLRU replacement, registered backpressured lookup responses, and tag-matched miss reservation until update/cancel. |
| `m_vlsit_riscv_probe_scheduler` | NEW | Per-hart round-robin arbitration over transaction slots; holds one tagged probe and one response ACK per hart; requires matching tag, line, and phase; no line-data payload. |
| `m_vlsit_riscv_cmo_controller` | NEW | CVA6 maintenance command with resolved operation, physical line, original effective address and instruction PC; returns completion/error only after the line transaction and rollback resolve. |
| `m_vlsit_axi_llc` | NEW wrapper + MODIFY upstream copy | 64-bit AXI4+ATOP cache data path, 32-bit AXI4-Lite service, per-line CMO request/response and B-error status; reads LLC BIST/counter status, permits flush control, and blocks software SPM writes. |
| `m_vlsit_riscv_axil_decode` | NEW | One external AXI4-Lite subordinate request stream; target selection between the 4-KiB CSR and 4-KiB LLC-service windows; response routing and DECERR for reserved addresses. |
| `m_vlsit_axil_reg_bridge` | NEW | AXI4-Lite 32-bit to pinned PULP RegBus; maps the full register list, allows flush configuration/commit writes, blocks SPM/read-only writes with SLVERR, and returns DECERR for reserved offsets. |
| `m_vlsit_riscv_axi_mmio` | NEW | Non-cacheable AXI4 manager paths from active tiles through an unchanged four-input PULP `axi_mux`; external fabric performs address decode. |
| `m_vlsit_riscv_debug_router` | NEW | Four-lane debug request into active CVA6 harts and per-hart debug-mode return; JTAG/DMI remains outside. |
| `m_vlsit_riscv_pmu` | NEW | CSR configuration, event selector, counter bank, snapshot control, overflow causes and aggregated level IRQ. |
| `m_vlsit_pmu_hart_evt` | NEW | Per-hart CVA6/HPDcache event taps with hart identity and event occurrence indicators. |
| `m_vlsit_pmu_cluster_evt` | NEW | LLC/CCU/fabric events; transaction events use occurrence counts, stall/full events use active-cycle indicators. |
| `m_vlsit_pmu_event_select` | NEW | Per-counter event ID and scope (`hart 0–3`, aggregate, or cluster) selection. |
| `m_vlsit_pmu_aggregate` | NEW | Sum same-cycle per-hart event occurrences for aggregate scope. |
| `m_vlsit_pmu_counter_bank` | NEW | Parameterized 1–32 32/64-bit counters, per-counter enable/event/scope and sticky overflow. |
| `m_vlsit_pmu_snapshot` | NEW | Atomic snapshot command/status; 64-bit counts held for low/high reads; 32-bit mode returns zero in the high word. |
| `m_vlsit_pmu_irq` | NEW | Sticky raw overflow causes, interrupt masking and one aggregate level IRQ. |
| `m_vlsit_cpucl_csr` | GENERATED | Generated only from workbook sheet `AXIL_QUEUED`; 32-bit AXI4-Lite, `cpucl` prefix, `PARA_PMU_COUNTER_NUM` repeated banks. |

The channel fields, widths, and encodings above are the approved Plan V3 contracts.
Implementation must map the pinned CVA6/HPDcache source pins to these boundaries.
If a pinned interface prevents that mapping, record the specific source-level delta
before changing an approved channel or behavior; do not silently alter the HDS
contract.

### 11.4 Upstream source disposition

| Source family | Proposed action |
|---|---|
| OpenHW CVA6 | MODIFY license-preserving copies of `core/cva6.sv`, the selected local config package, `csr_regfile.sv`, `perf_counters.sv`, `commit_stage.sv`, `store_unit.sv`, `store_buffer.sv`, `controller.sv`, `cache_subsystem/cva6_hpdcache_if_adapter.sv`, `cva6_hpdcache_subsystem.sv`, and `cva6_hpdcache_wrapper.sv` for the approved interrupt, event, CBO, FENCE.I, and coherence boundaries. |
| OpenHW HPDcache | MODIFY license-preserving copies of `hpdcache.sv`, `hpdcache_ctrl.sv`, `hpdcache_ctrl_pe.sv`, `hpdcache_memctrl.sv`, `hpdcache_miss_handler.sv`, `hpdcache_mshr.sv`, and `hpdcache_flush.sv`; the transitive source closure must be checked before copying. |
| PULP `axi_llc` | MODIFY a license-preserving copy of the LLC top/package/hit-miss/tag-store/write-master path, plus required arbitration/descriptor dependencies, for same-line serialized per-line CMO with B-error preservation. The pinned `rtl/common/third_party` tree is never edited. |
| PULP AXI and remaining CVA6/HPDcache/LLC blocks | REUSE unchanged only when pinned revision, license, parameters, and ports match; notably the fixed four-input `axi_mux` instances. No common_rtl synchronizer is needed for the one-clock, SoC-synchronized-reset design. |
| ACE profile | DEFERRED; no ACE top/proxy or ACE-only RTL is generated in this phase. |

### 11.5 Approval gate and remaining implementation dependencies

The designer approved the module/interface matrix and AXI-only RTL scope in Plan V3,
then approved Plan V4 refinements to the specification and implementation plan. The source baseline hash manifest was
captured before edits. Implementation now proceeds under `rtl/common/modified` and
`rtl/common/vlsit`; never edit `rtl/common/third_party`. Before integrating each modified upstream
module, verify its exact source mapping, preserve its complete upstream license/header,
and record the actual dated delta by `Quan Nguyen and Codex - VLSI Technology page`.

Items that remain after approval are implementation and verification dependencies:
freeze the transitive source closure; review Event_Map source expressions and proposed
CCU taps; implement cause-24 trap delegation and `mtval`/`stval` delivery; bind the
directory/LLC to available SRAM macros; then run RTL rule check and lint. The CSR
workbook's detailed Event_Map and full FSM V4 drawings still need final review.

### 11.6 Current RTL and verification checkpoint — 2026-11-14

The standalone CCU fabric regression passes seven modeled control-plane scenarios:
cold `E`, `E→S`, `S→M`, dirty `M` ownership transfer, failed writeback followed by
PREPARE→ABORT/error grant, successful retry, and progress on bank 2 while a bank 1
grant is stalled. The failure case found a real bug:
the fabric lost the CPU error when ABORT completed successfully. The fabric now keeps
the error in its transaction context and returns an error grant. Verilator lint passes
for the fabric and testbench; the fabric rule report has zero errors and one intentional
HIE-02 warning. Probe/writeback responses are modeled; the test does not exercise AXI
W/B data, CVA6, HPDcache, LLC, or cluster TOP.

Current TOP lint still fails because `m_vlsit_riscv_cluster_core` is undefined. The
approved Plan V4 remains the implementation target, but full RTL is not complete.
Permission-before-refill/upgrade is not connected through HPDcache and the tile path;
per-line LLC maintenance, precise retirement handling, PMU/CSR integration, and
cluster-level verification also remain open. Preserve upstream licenses and keep
`rtl/common/third_party` unchanged while implementation continues under `rtl/common/modified` and
`rtl/common/vlsit`.

### 11.7 Current RTL and verification checkpoint — 2026-11-15

The CMO controller directed regression passes at 2 and 4 harts with five scenarios
and 134 checks per profile. Code coverage was not measured, as selected by the
designer. The 2-hart full TOP lint runner reached its 420-second timeout with 263
warnings and no `%Error`; this is not a lint pass, and no native Verilator exit was
obtained. The log is
`lint/non_coherence_cluster/full_integration/top_lint_2h_20261115_070540.log`.

The licensed CVA6 copies now retain CBO physical address, effective virtual address,
and operation in the speculative store-buffer entry, then route them through LSU/EX,
CVA6, tile, and tile array to the cluster-core boundary. A Verilator-directed
store-buffer regression passes capture, ordering, payload stability, and flush checks
using package/type stubs. The instruction PC remains available only at retirement
and is not yet joined to a CMO request. Retirement hold/error handling, controller
consumption, CCU/LLC maintenance, end-to-end CBO/FENCE.I verification, system atomic
checks, and normal-exit full-TOP lint remain open. Upstream `rtl/common/third_party` sources
remain unchanged.


## DEC-030/031 implementation checkpoint — 2026-11-15

EN: The FENCE.I retirement/walker/arbiter/CCU/LLC path is implemented. Error traps cause 24 only after ABORT ACK; success waits for I-cache invalidation ACK. Eight real-instruction 2/4-hart M/S-mode cases pass. See [changed files, source snapshots, waveforms, lint and limits](../../../../verification/non_coherence_cluster/reports/l1_eviction_retention/before/rtl/reports/fence_i/README.md). This supersedes earlier incomplete FENCE.I notes, not unrelated signoff dependencies.

VI: Đã triển khai đường FENCE.I retirement/walker/arbiter/CCU/LLC. Lỗi chỉ trap cause 24 sau ACK ABORT; thành công chờ ACK invalidate I-cache. Tám ca instruction thật 2/4 hart ở M/S-mode đều pass. Báo cáo trên có file sửa, snapshot, waveform, lint và giới hạn; thay thế ghi chú FENCE.I chưa hoàn tất cũ.


## Silent E→M correction — 2026-11-15

EN: The CCU now treats directory E as exclusive-owner permission, accepts a valid E/M PREPARE only from that unique owner, enforces actual dirty writeback completion, and retains the prepared cache state for ABORT. Only `m_vlsit_riscv_coh_fabric.sv` changed in production RTL. Native upstream and generated CSR are untouched. Real CPU LOAD/store/CBO success/error, baseline CBO, eight FENCE.I cases and full TOP lint pass at 2/4 harts. [Evidence and scope](../../../../verification/non_coherence_cluster/reports/l1_eviction_retention/before/rtl/reports/e_to_m_fix/README.md).

VI: CCU đã xử lý refinement E→M đúng owner, chờ dirty writeback và giữ state PREPARE cho ABORT. Chỉ một module RTL production được sửa; nguồn upstream và CSR generated giữ nguyên. Các regression và lint TOP 2/4 hart đều pass; phạm vi chi tiết ở báo cáo trên.


## A-02 / DEC-038 follow-up, 2026-11-15

EN: Implemented the approved cached-L1/uncached-ATOP split. Fixed shared-LR/SC upgrade progress, atomic grant-to-response exclusion, probe phase ownership, bank-tag handshakes, native array arbitration, precise atomic fault retirement and LLC refill-error/tag handling. [Final changed-source hashes, tests and scope](doc/reports/atomic_coherence/README.md). A-03–A-06 remain separate open items.

VI: Đã triển khai lựa chọn atomic cached tại L1, uncached qua ATOP; sửa tiến triển LR/SC, guard, probe, bank tag, arbitration array, retirement lỗi precise và lỗi refill/tag LLC. Báo cáo liên kết ghi file sửa, test và giới hạn. A-03–A-06 vẫn là các mục riêng chưa đóng.
