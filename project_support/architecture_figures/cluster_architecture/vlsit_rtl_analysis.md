# Cluster architecture diagram analysis

## 1. Scope and evidence
User approved document-source substitution and level N=1. Top: proposed cluster. Source: ../../VLSIT_RISCV_CPU_Cluster_Architecture.md. RTL files inspected: none. All blocks and links are proposed architectural subsystems, not implemented module instances. At level 1 the CPU bank is one architectural array containing N independent tiles; it is not a claim that one CPU replaces N instances. No standard protocol compliance or pulse timing is inferred. Library and layout rules still apply.

## 2. Proposed hierarchy and functions
| Depth | Block | Function | Document evidence |
|---|---|---|---|
| 1 | Coherent fabric | Proposed local ownership and request-routing subsystem. It resolves cache probes, serializes conflicting lines and routes non-cacheable accesses to the peripheral fabric. Not expanded. | Architecture section 7, line 140 |
| 1 | Coherent memory | Proposed memory subsystem combining optional shared L2 and external coherent proxy. It handles system-facing requests and returns snoop results from local ownership tracking. External full-coherent support remains integration work. Not expanded. | Architecture section 7, line 140 |
| 1 | Peripheral fabric | Proposed non-cacheable peripheral routing and response-ordering subsystem. It isolates MMIO from allocating cache paths and handles decode errors. Not expanded. | Architecture section 8, line 165 |
| 1 | Debug subsystem | Proposed multi-hart debug subsystem with transport, run control and coherent normal-memory system-bus access. Native feature compatibility must be confirmed. Not expanded. | Architecture section 12, line 234 |
| 1 | Performance monitor | Proposed per-hart and shared performance accumulators, latency tracking and snapshot engine. Passive observation must not backpressure execution. Not expanded. | Architecture section 10, line 189 |
| 1 | Cluster management | Proposed management register bank and coordinated boot, quiesce, reset and wake controller. Cross-domain operations use acknowledged commands. Not expanded. | Architecture section 9, line 177 |
| 1 | Flight recorder | Proposed bounded timestamped event recorder with pre/post-trigger capture and observable loss handling. Not a standard instruction-trace encoder. Not expanded. | Architecture section 13, line 257 |
| 1 | CPU tile bank: hart 0/1; hart 2/3 only for N=4 | Architectural array of two or four identical CPU tiles, each with its own core and private L1 instruction/data caches. Hart 0 and 1 are always present; hart 2 and 3 exist only in the four-core build. Replicated interfaces are indexed per tile, not a single physical shared bus. Not expanded at level 1. | Architecture section 4, line 66 |

No RTL own-logic partition exists. These are architectural groupings; no further level is drawn.

## 3. Interface and signal analysis
The document defines logical interfaces, not an exhaustive netlist. Names, widths and level/pulse types absent from the source remain TBD. Symbolic payload descriptions below are not invented RTL pins.
| ID | Proposed interface | Active side -> passive side | Payload and return direction | Evidence |
|---|---|---|---|---|
| CMEM | Coherent memory service | CF -> MEM (proposed) | Fabric -> memory: normal-memory request; memory -> fabric: request completion/read data/error. External-initiated local snoop work is separately represented by LPROB. | Architecture section 7, line 140 |
| MMIO | Uncached peripheral requests | CF -> IO (proposed) | Fabric -> router: uncached address/control and write payload; router -> fabric: read payload, completion and errors. | Architecture section 8, line 165 |
| DSBA | Coherent debug memory access | DBG -> CF (proposed) | Debug -> fabric: cacheless coherent memory requests; fabric -> debug: completion/read data/error. Not a raw DRAM bypass. | Architecture section 12, line 234 |
| FEVT | Fabric event observation | CF -> PMU (proposed) | Fabric -> PMU: ownership, probe, queue and atomic events; names and widths TBD. | Architecture section 10, line 189 |
| MEVT | Memory event observation | MEM -> PMU (proposed) | Memory -> PMU: shared-cache and external request/response events; names and widths TBD. | Architecture section 10, line 189 |
| IEVT | MMIO event observation | IO -> PMU (proposed) | Router -> PMU: MMIO handshakes, errors, backpressure and pending-request observations. | Architecture section 10, line 189 |
| TRIG | Recorder trigger and event feed | PMU -> REC (proposed) | PMU -> recorder: selected timestamped records and trigger requests. Recorder full drops records and reports loss; no execution backpressure. | Architecture section 13, line 257 |
| PCFG | PMU configuration and readback | MGT -> PMU (proposed) | Management -> PMU: selectors, masks and snapshot commands; PMU -> management: snapshot/status/acknowledgments. | Architecture section 11, line 222 |
| RCFG | Recorder configuration and readback | MGT -> REC (proposed) | Management -> recorder: trigger and read commands; recorder -> management: records, status and loss counters. | Architecture section 13, line 257 |
| DCFG | Debug policy and wake coordination | MGT -> DBG (proposed) | Management -> debug: policy and coordinated wake/configuration; debug -> management: availability/status and wake requirements. | Architecture section 12, line 234 |
| FCFG | Fabric management | MGT -> CF (proposed) | Management -> fabric: supported quiesce/route-policy commit; fabric -> management: command and drained-state acknowledgments. | Architecture section 16, line 300 |
| ACER | Proposed ACE request service | MEM -> coherent SoC fabric | Outward: normal/coherent memory requests and write payload; inward: read/write completion. Full protocol channel fields and widths not finalized. | Architecture section 6, line 122 |
| ACSN | Proposed ACE snoop service | SoC fabric -> MEM | Inward: snoop requests; outward: snoop responses/data with required protocol acknowledgment behavior. Not RTL-proven ACE compliance. | Architecture section 6, line 122 |
| AXIP | Proposed AXI4 peripheral interface | IO -> peripheral subsystem | Outward: AW/W/AR request channels; inward: B/R response channels; VALID/READY both directions. Actual RTL port names and widths TBD. | Architecture section 6, line 122 |
| APBC | Proposed APB4 management interface | SoC configuration manager -> MGT | Inward: PSEL, PENABLE, PADDR[15:0], PWRITE, PWDATA[31:0], PSTRB[3:0], PPROT[2:0]; outward: PRDATA[31:0], PREADY, PSLVERR. Proposed boundary fields, not RTL names. | Architecture section 9, line 177 |
| TCK | Proposed JTAG TCK pin | Debug host -> DBG | TCK: single dedicated JTAG pad line; proposed semantics, implementation not selected. | Architecture section 12, line 234 |
| TMS | Proposed JTAG TMS pin | Debug host -> DBG | TMS: single dedicated JTAG pad line; proposed semantics, implementation not selected. | Architecture section 12, line 234 |
| TDI | Proposed JTAG TDI pin | Debug host -> DBG | TDI: single dedicated JTAG pad line; proposed semantics, implementation not selected. | Architecture section 12, line 234 |
| TDO | Proposed JTAG TDO pin | DBG -> debug host | TDO: single dedicated JTAG pad line; proposed semantics, implementation not selected. | Architecture section 12, line 234 |
| IRQS | Per-hart platform interrupts | Platform -> CPU bank | Per-hart timer, inter-processor and platform interrupt inputs; proposed routing directly into tile bank. Exact vector width and core interrupt interface TBD. | Architecture section 6, line 122 |
| EVIRQ | Cluster event interrupts | Cluster management -> platform | Cluster PMU, recorder and fault interrupt status, proposed level semantics from architecture section 6; exact pins TBD. | Architecture section 6, line 122 |
| CLKR | Cluster domain integration | Platform -> management and internal domains | Cluster clock, management clock, reset and wake infrastructure; logical domain boundary only. Internal clock-tree wiring is not defined by the source architecture. | Architecture section 16, line 300 |
| LPROB | Local snoop service | MEM -> CF (proposed) | Memory proxy -> fabric: external probe work; fabric -> memory proxy: aggregated snoop response and dirty data. Exact RTL names, widths and timing TBD. | Architecture section 7 |
| TILE | Replicated tile transactions | CPU -> CF (proposed) | For each present hart independently: tile-to-fabric memory requests and fabric-to-tile completion/read data. Address/attributes choose coherent normal memory or uncached MMIO. Separate per-tile interfaces; not one shared physical link. | Architecture sections 4, 7, 10, 12, 15 |
| TEVT | Replicated tile event observation | CPU -> PMU (proposed) | Per-tile retirement multiplicity, pipeline/cache/TLB event observations to PMU; source/hart association retained. Exact names, widths and timing TBD. | Architecture sections 4, 7, 10, 12, 15 |
| HDBG | Replicated native hart debug | DBG -> CPU (proposed) | Debug-to-hart supported halt/resume/step transactions; per-hart state/completion returned. Not a claim of native halt-group support. | Architecture sections 4, 7, 10, 12, 15 |
| TCTL | Replicated tile management | MGT -> CPU (proposed) | Management-to-tile boot/quiesce/wake/reset requests with per-hart acknowledgment and actual state returned. Exact native interfaces TBD. | Architecture sections 4, 7, 10, 12, 15 |

## 4. Classification and proposed groups
All interfaces are classified custom/proposed at this evidence level. APB/AXI/ACE names express design intent only; actual mandatory pin coverage and behavior cannot be checked without RTL.
Candidate catalog entries: native hart debug; tile event observation; coherent cluster request/snoop service; timestamped trigger/recorder feed. Approval to add catalog entries is pending; installed skill files are unchanged.

## 5. Conditional and unresolved details
- CPU tiles 2 and 3: four-core build only; tiles 0 and 1 always present.
- MEM combines optional L2 and ACE proxy at this level; CFG and response paths inside MEM are not expanded.
- Incoming snoops and outbound requests are separate transaction classes. The MEM-to-CF local snoop service will be included as its own interface in the drawing.
- Core architectural-counter access is not silently replaced by APB snapshot.
- CLKR is a domain-integration boundary, not a resolved clock-tree implementation.
- IRQS logical ingress is not an assertion that cache logic generates platform interrupts.

## 6. Diagram mapping
One page: 01_LEVEL_1. Each proposed block is listed above; every connector ID maps to one interface row. All blocks are dashed because they are proposals. Native tables contain block functions and interfaces.

## 7. Validation and self-improvement
Library source: assets/VLSIT_DRAWIO_LIB_V1.drawio.xml; SHA-256: D1631ACF98A920526B235E8970FEDDC9305EA2F0D6A35C6529CD220D62AFABB6.
Template indices: 0 text, 1 arrows, 5 JTAG pads, 32 blocks/frames. Native description tables are the authorized exception.
Reproducible source: ../../scripts/build_cluster_diagram.py; manifest: cluster_diagram_spec.json.
No installed skill/reference/library changes. A document-input evidence mode is proposed as a future skill enhancement; it must retain explicit source labeling and approval rather than pretending to analyze RTL.

## 8. Actual final validation

Library provenance validator: PASS. Geometry checker: zero findings. Independent generator metric: at most two crossings per connector.

```text
SCORE gapH=120 gapV=140 seed=2 failed=0 unplaced=0 issues=0 bend_gt5=0 bend5=0 bends=18 cross_total=8 cross_max_per_connector=2 frame=1380x660
```

One page: 01_LEVEL_1; eight architectural subsystem blocks. 27 functional/boundary connectors plus one legend arrow. Functional bends: 20 with zero, 3 with two, 4 with three; none with four or more in the selected layout. Physical crossings: 8, each with arc jumps. Block height: 80 px; horizontal gap: 120 px; vertical gap: 140 px; frame margin: 40 px. Vertical gaps 100/110/120 failed the per-connector crossing criterion; 130 added bends. At 140, seeds 1/2/3/4 were tried and seed 2 minimized bends among those candidates. The search is a bounded layout exploration, not a proof of a global optimum.

2026-11-06 tooling observations: stock --svg option is described but not implemented; fixed right outer margin can omit full labels; non-grid widths can put snapped endpoints inside their blocks; geometry findings do not enforce the per-connector crossing cap. Project-local wrappers address rendering, outer margin, grid widths and separate score checks. Installed skills, rule.md, catalog and immutable library were not edited.
