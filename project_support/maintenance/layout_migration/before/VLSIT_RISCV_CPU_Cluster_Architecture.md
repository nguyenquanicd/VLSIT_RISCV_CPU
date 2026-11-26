# VLSIT configurable 2/4-core RISC-V cluster architecture
# Kiến trúc cluster RISC-V cấu hình 2/4 core

Version: **0.2 — architecture proposal with editable VLSIT draw.io diagram**. Research date: **2026-11-06, Asia/Saigon**.

This single document consolidates the requested architecture, comparisons, interface roles, performance monitoring, debug and integration decisions. The English part defines the proposed technical contracts; the Vietnamese part explains the same major choices. It is an architecture proposal, not an approved RTL-generation specification. No RTL implementation, protocol compliance test or PPA measurement was performed for this document.

## English

### 1. User requirements and proposed baseline

| ID | User requirement | Proposed response |
|---|---|---|
| U-01 | Cluster supports two or four CPUs | Synthesis-time CPU count restricted to 2 or 4; runtime participation managed separately |
| U-02 | Efficient performance and power | Private L1s, compact coherent fabric, optional banked shared L2, per-core sleep; selection by energy/task and latency |
| U-03 | Performance supervision | Per-hart architectural counters plus a cluster PMU observing core/cache/fabric/coherence activity |
| U-04 | Effective debug | Multi-hart run control, JTAG/DMI, coherent memory debug path, correlated flight recorder and fault snapshots |
| U-05 | AXI interfaces | AXI4 non-coherent peripheral manager; AXI-derived full ACE interface for external coherent communication |
| U-06 | Coherent memory/main data path | One coherent domain for active CPU caches and supported external agents; explicit system home/interconnect responsibilities |
| U-07 | APB for configuration if needed | APB4 subordinate for cluster management, PMU, debug policy, trace and power control |
| U-08 | One description file | Diagrams, preliminary register map, sequences, references and open decisions embedded here |

Recommended starting architecture: **one homogeneous coherent cluster**, with N identical RV64 application cores, N private L1I/L1D cache subsystems, a coherent fabric/home function, a configurable shared L2, and a debug/observability island. Use CVA6-family coherent integration as the first SystemVerilog candidate; compare against Rocket/Chipyard as a reproducible generator baseline. Exact CVA6S+/HPDCache/coherent-CCU commits remain to be selected and demonstrated compatible. [R1–R4]

The proposed high-performance profile has an external **full ACE manager** representing the entire cluster toward a coherent SoC fabric. It requires a cluster proxy that translates external snoops into internal cache probes. This proxy is required integration work; the cited Culsans AXI memory output must not be assumed to provide it already.

### 2. Terminology and boundaries

| Term | Meaning in this document |
|---|---|
| CPU / hart | Physical core / architectural execution context; baseline has one hart per core |
| Cluster | CPU tiles, coherent fabric, optional L2, management, PMU and debug infrastructure |
| CPU tile | Core, private caches, translation/protection state and local event adapter |
| Coherence | Mechanism maintaining correct cached copies and ownership of a location |
| Memory consistency | Rules governing allowed observation/order of memory accesses; RISC-V RVWMO remains a separate obligation |
| Home function / PoC | Function serializing relevant transactions and managing ownership / defined point of coherency |
| CCU | Cache coherency unit servicing probes, data forwarding and ownership transitions |
| ACE / ACE-Lite | Full AXI coherency extensions for cached agents / I/O coherency interface with reduced capabilities |
| PMU | Performance monitoring unit; distinct from the power management controller |
| SBA / DMI / DTM | Debug system bus access / debug-module interface / debug transport module |
| Flight recorder | Bounded custom event buffer recording selected timestamped events before/after a trigger |
| MSHR / outstanding | Miss status tracking entry / accepted request not yet completed |
| Quiescent | Defined state in which required transactions and state transfers have finished, allowing a specific management action |

Inside cluster: CPU tiles, coherent fabric/proxy, L2 if enabled, route/protection logic, management APB bank, PMU, debug module integration, trace buffer and wake logic.

Outside baseline: DRAM controller/PHY, SoC coherent fabric/home functions beyond the cluster boundary, peripheral subsystem, voltage regulators/PLL, OS scheduler, full interrupt-controller implementation and external trace receiver. Platform interrupt/timer/IPI signals enter the cluster per hart; their controller may be integrated later with a separate contract.

Architectural memory ordering and the supported physical memory attributes must agree with the selected RISC-V core and system implementation. Coherence and atomicity are integration obligations, not capabilities inferred from the RISC-V ISA name. [R14]

### 3. Architecture alternatives and references

| Structure | Reference evidence | Useful properties | Limit for this project |
|---|---|---|---|
| One 2/4-core snoop-based cluster | Culsans explicitly targets 2–4 CVA6 CPUs [R1] | Compact ACE/MOESI coherent design and familiar SystemVerilog source | Match cache revisions; external full-ACE cluster-proxy support is not established by its ordinary AXI output |
| Coherent generator cluster | Chipyard has explicit two/four-Rocket configurations [R2] | Configurable tile count and coherent TileLink infrastructure | TileLink-to-AXI alone cannot preserve full external coherence; full coherent bridge/proxy needs a design |
| Directory-based cluster | BlackParrot/BedRock [R3] | Directory-based ownership tracking and reported quad-core silicon history | Protocol adaptation to required AXI/ACE boundary, core debug support and exact revision need review |
| Tiled/distributed hierarchy | OpenPiton/CVA6 [R4] | Coherent multicore integration with L1.5/memory hierarchy | Extra levels/routers may be unnecessary at 2/4 cores; no generic power advantage established |
| Two clusters of two cores | Architectural alternative | Local communication and per-pair power domains | Extra global coherence boundary; independent dual-core clusters joined by plain AXI do not form coherent SMP |
| Shared scratchpad and DMA | PULP cluster [R5] | Predictable banked SRAM, DMA overlap and events for regular kernels | Different software model; does not directly provide the requested general coherent-memory interface |

Choose a single cluster first. At four cores, compare a pipelined snoop CCU with a small directory/snoop-filter implementation using measured traffic. Neither topology is universally fastest or lowest-power. Keep transactions to different lines progressing concurrently where supported; serialize conflicting ownership changes at the defined coherence point.

Cheshire provides useful AXI, multi-hart debug and management integration references. Its documentation assumes its LLC is the only manager accessing its backing memory. That assumption must be revisited when external coherent agents are introduced; copying its memory topology unchanged would not establish system coherence. [R6]

### 4. Configuration model

The following are **proposed design parameters**, not user-approved numerical implementation targets:

| Setting | Proposal | Explanation |
|---|---|---|
| CPU count | `PARA_CPU_NUM`: 2 or 4; initial evaluation default 4 | Changes synthesized instance count, not a runtime hot-add feature |
| Hart IDs | 0 through N−1 | Stable IDs independent of parking/sleep masks |
| ISA/core profile | Homogeneous RV64 with required atomics and translation support; exact extensions TBD | All active peers need the platform's common software contract |
| Coherent interface | Full ACE, exact supported issue/revision and transaction subset TBD | Preferred AXI-family coherent interface for this scope |
| Peripheral interface | AXI4, no atomics/coherence extensions at this boundary | Non-cacheable MMIO path |
| Management interface | APB4, proposed 32-bit data and 16-bit byte-addressed aperture | Supports configuration and telemetry, not data streaming |
| Cache line | Proposed common 64-byte line, subject to chosen IP compatibility | Do not adapt incompatible coherent-cache lines by a simple width converter |
| Private caches | Proposed 16/32 KiB exploration points | Legal sizes/ways depend on selected core/cache IP |
| Shared L2 | Optional; proposed 256/512 KiB and 2/4-bank study | Capacity and bank count selected by workload and physical results |
| PMU | Proposed 8 programmable counters per hart and 16 shared counters, all 64-bit | Event capability reporting prevents assumptions about unimplemented events |
| Recorder | Proposed 256/1024-entry study; record format versioned | Disabled by default for normal execution; final storage cost TBD |
| Clocks | One cluster domain plus management/debug/wake domain; JTAG TCK asynchronous | Independent CPU clock enables; separate DVFS domains deferred |

Two-core builds instantiate only two tiles and expose a two-bit physical-present mask. Four-core builds can park CPUs but remain four-core hardware. Software-visible fixed-stride windows may reserve space for four harts; absent windows return zero for identification/status and reject mutating accesses with an APB error. No directory sharer bit or response can depend on a nonexistent tile.

Core count, XLEN, cache size and supported ISA are elaboration choices. APB does not change them after manufacture. Runtime enable, boot control and tuning only affect explicitly supported wrapper/core features. Architectural CSRs such as `satp`, `mstatus` and PMP configuration remain under hart execution/debug semantics; no unrestricted APB backdoor is proposed.

### 5. VLSIT draw.io architecture diagram

![VLSIT configurable 2/4-core cluster architecture](figures/cluster_architecture/cluster_architecture.svg)

[Editable draw.io](figures/cluster_architecture/vlsit_rtl_hierarchy.drawio) · [Diagram evidence and interface analysis](figures/cluster_architecture/vlsit_rtl_analysis.md) · [Validation results](figures/cluster_architecture/validation_report.txt) · [Rebuild instructions](scripts/README.md).

The user approved document-source drawing and architectural level 1 on 2026-11-06. The source is this architecture proposal, not RTL. Dashed outlines identify proposed subsystems; actual module instances, exact port names/widths and cycle timing remain unresolved. The source-specific exception does not assert protocol compliance.

At this level, **CPU tile bank** denotes N independent tiles, each containing a core and its private L1I/L1D. Hart 0 and 1 are always present; hart 2 and 3 exist only for N=4. TILE, TEVT, HDBG and TCTL denote replicated per-hart interface families, not one physical bus or one replacement CPU. The bank is an architectural abstraction without invented RTL module/instance names.

The memory subsystem combines optional shared L2 and the external ACE proxy; their internal structure is not expanded at level 1. Management combines APB, power and wake coordination. Debug combines DTM, DM and coherent-SBA injection. The recorder is a custom event recorder, not a standard instruction-trace encoder. Full block descriptions and interface payloads are included in the two native tables beneath the topology in draw.io and in the linked analysis.

| Connector | Meaning and initiating side |
|---|---|
| TILE / TEVT | CPU bank initiates memory requests / emits per-hart performance events |
| HDBG / TCTL | Debug initiates supported hart debug transactions / management initiates tile commands |
| CMEM / LPROB | Fabric initiates memory service / external-memory proxy initiates local snoop work; returns are part of each interface |
| MMIO / AXIP | Fabric routes uncached transactions to peripheral router / router initiates external AXI4 peripheral transactions |
| ACER / ACSN | Proxy initiates external ACE requests / SoC coherent fabric initiates inbound snoops |
| APBC | SoC configuration manager initiates APB accesses to management |
| DSBA | Debug initiates coherent normal-memory access through the local fabric |
| FEVT / MEVT / IEVT | Fabric, memory and peripheral-router observations enter PMU |
| PCFG / RCFG / DCFG / FCFG | Management initiates PMU, recorder, debug-policy and fabric-control transactions |
| TRIG | PMU initiates selected event/trigger delivery to the recorder |
| IRQS / EVIRQ / CLKR | Per-hart interrupt ingress / cluster event interrupt egress / logical clock-reset-wake integration boundary |
| TCK / TMS / TDI / TDO | Four separate proposed JTAG pad connections |

Arrowheads identify the transaction initiator; response data and acknowledgment travel within the corresponding interface. Clock/reset domain integration is declared through CLKR, but no physical clock-tree netlist is inferred. Native hart debug and management commands remain subject to selected-core capabilities.

Diagram validation: **85 library-derived cells**, library-provenance PASS; geometry checker **zero findings**. One page, `01_LEVEL_1`, contains eight architectural subsystem blocks, 27 interface connectors and one legend arrow. Selected layout: 80 px blocks, 120 px horizontal gap, 140 px vertical gap, 40 px frame margin; frame 1380×660 px. Interface bends: 20 straight, 3 with two bends, 4 with three bends. Eight physical crossings use arc jumps, maximum two crossings per connector. These checks validate diagram construction, not RTL or coherence correctness.

Library: `VLSIT_DRAWIO_LIB_V1.drawio.xml`; SHA-256 `D1631ACF98A920526B235E8970FEDDC9305EA2F0D6A35C6529CD220D62AFABB6`. Templates: 0 text, 1 connectors, 5 JTAG pads, 32 blocks/frames; the two native description tables are the skill-authorized exception. SVG is a topology crop rendered from the draw.io cells; the editable file retains its full tables.

### 6. External interface contract

| Interface | Cluster role and direction | Purpose | Proposed domain |
|---|---|---|---|
| Coherent memory/data path | Full ACE manager: AR/AW/W requests outward, R/B responses inward; AC snoops inward, CR/CD responses/data outward; required protocol acknowledgments/control included | Share cacheable normal memory with external coherent CPUs/accelerators through the SoC coherent fabric | Cluster clock, or protocol-complete boundary CDC |
| Non-coherent peripheral path | AXI4 manager outward | UART, timer, control peripheral or external AXI-to-APB bridge | Cluster clock; SoC bridge may adapt clocks |
| Management configuration | APB4 subordinate inward | Cluster control, PMU, recorder and status | Management/wake clock |
| Debug transport | JTAG TAP input/output through DTM; DMI to DM | Hart selection, run control, register/memory debug | TCK plus managed crossings |
| Interrupt/timer/IPI | Per-hart inputs and platform routing | Interrupt delivery and inter-processor coordination | Synchronized per specified input source |
| Cluster event interrupts | Level outputs for PMU, trace and fault status | Platform notification | Management/wake domain |
| Reset and wake controls | Requests plus status/acknowledgments | Controlled boot, idle and recovery | Always-on controller with explicit crossings |

**Full ACE is required for transparent external snooping of cached cluster data.** AXI4 alone carries ordinary memory/MMIO traffic. ACE-Lite supports I/O coherence but is not a drop-in replacement for the full cached-cluster endpoint. CHI is a coherent protocol alternative, but choosing it requires another coherent bridge/integration design rather than renaming AXI signals. [R7, R8]

Protocol revision and transaction subset must be pinned to both the cluster proxy and the SoC fabric. Standard revision claims are not inferred from a signal-name resemblance. AXI5-style atomic operations and cache coherence are separate capabilities; AXI4+ATOPs is not ordinary AXI4. [R9]

Baseline proposes one coherent memory egress and one MMIO egress. It does not promise a second independent non-coherent DRAM path: a data region visible through inconsistent cached/noncached aliases can bypass ownership tracking and expose stale data.

### 7. Coherent integration and cache organization

Each tile keeps private register/CSR/TLB state and cache state. Internal and external coherent observers must converge on the newest permitted data, including data dirty in a tile or shared L2. The external proxy represents all cluster caches, not only the tile that issued the most recent request.

Recommended responsibilities:

- Internal fabric tracks ownership/sharers and arbitrates conflicting lines. Optional filters may over-probe conservatively but must not omit a real owner.
- Shared L2 integration defines whether data/tags are inclusive, non-inclusive or exclusive and where directory state persists. An L2 eviction cannot silently discard information needed to locate dirty private data.
- External proxy resolves inbound snoops by probing relevant local caches/L2, combining responses, supplying dirty data when needed and sequencing acknowledgment completion.
- SoC coherent fabric/home functions manage external participants and backing-memory access according to the selected protocol. A plain DRAM controller beyond the system home can remain non-coherent.
- Atomics and reservations are serialized at a defined system-supported point. External writes/ownership changes invalidate reservations as required; no per-port emulation may bypass other agents.

At four cores, use line-conflict tracking and independent request/response progress rather than a global lock for every miss. Queue resources must reserve progress for snoop completions, writebacks and responses to avoid cyclic dependency on new requests. Arbitration fairness and forward progress require verification; an AXI QoS field alone does not guarantee either.

Instruction visibility is a separate platform contract. Data coherence does not automatically perform remote instruction synchronization. Software/firmware must arrange the required instruction-cache and TLB synchronization; generic DVM, FENCE.I and SFENCE.VMA behaviors must not be conflated.

**External attach modes:**

| Mode | Integration meaning | Suitability |
|---|---|---|
| System-coherent, proposed target | Full ACE cluster proxy connected to coherent SoC fabric | Meets external coherent-memory/main-path requirement |
| Isolated coherent cluster, alternative | CPUs coherent internally, ordinary AXI egress to memory; all data-sharing external agents must join a supported coherent injection point or use explicit software maintenance | Useful simplified subsystem, but does not meet transparent external cached-agent coherence by itself |

These are alternative product contracts, not a runtime protocol switch while transactions are active. The user requirement makes system-coherent attachment the proposed target; availability of a ready implementation is still an open integration dependency.

### 8. Peripheral routing and AXI behavior

Use a physical-address/PMA route table that distinguishes coherent normal memory, non-cacheable MMIO, local management aperture and debug memory. Prohibit incompatible attribute aliases of the same shared storage. Core-side cacheability attributes and wrapper routing must agree; changing only outbound AXI attributes cannot undo a prior private-cache allocation.

Peripheral requests bypass allocating private/shared data-cache behavior according to the core PMA support. Limit speculative or merged MMIO accesses where the device contract requires it. Route unmapped addresses to a protocol-correct decode-error endpoint.

Track AXI source identity for each hart, debug SBA and any internal initiator. Identifier expansion/remapping must retain return routing and ordering. With source prefixing, size the source field for actual CPU plus auxiliary initiators, not CPU count alone. Read response interleaving and repeated-ID ordering require explicit queues. AXI4 write data has no WID; preserve the association between accepted AW descriptors and W bursts.

Configure queue capacities by traffic class. Give snoop completions and dirty writebacks sufficient independent resources. Limit debug traffic so a debugger cannot unintentionally occupy all normal-request slots. Weighted fair arbitration is a proposed starting policy; tune weights using PMU results and verify no starvation under stated assumptions.

Do not send unsupported atomics to peripheral devices. Reject them through an endpoint that returns the required response channels for the originating protocol, rather than stripping attributes and performing an ordinary write. Reserve MMIO atomics only for explicitly supported target/region combinations. [R9]

### 9. APB management versus architectural core configuration

APB is a **subordinate management interface**. A SoC configuration manager supplies it; an on-chip CPU can reach it through an external AXI-to-APB bridge mapped to the non-coherent peripheral path. This keeps the management endpoint accessible to an external host even when all CPUs are halted or sleeping. That bridge is outside the baseline cluster boundary.

Recommended APB-visible groups: identity/capabilities, boot mailbox/address support, request/ack status for CPU release or quiesce, clock/power policy, route-table shadow/commit if runtime changes are supported, PMU, recorder and fault status. Do not replicate standard RISC-V architectural CSRs as independently writable APB registers.

Proposed APB4 contract: 32-bit data, byte-addressed aligned 32-bit accesses, per-byte strobes for suitable stored fields, error on unsupported/unmapped accesses and forbidden writes. Read-only/reserved behavior is documented per register. Pin the exact APB revision before implementation. Side-effect command fields either require a full-word write or have explicit strobe semantics.

Long operations return a command acknowledgment through APB and complete asynchronously with BUSY/DONE/ERROR status. Do not hold PREADY low for a whole cache drain or power transition. A second conflicting command is rejected with an observable status; concurrent hardware event versus software W1C clear is set-dominant.

Values crossing from management clock are committed through request/acknowledgment or asynchronous command queues, not sampled as unrelated synchronized bits. Boot addresses are staged then committed while the target CPU is held in an appropriate reset/park state. A core with a fixed reset vector uses boot ROM/mailboxes instead of an invented writable boot-address pin.

### 10. Performance monitoring architecture

Use three complementary layers:

| Layer | Events/data | Purpose and access |
|---|---|---|
| Per-hart standard counters | Implemented cycle, retired-instruction and HPM events | Software profiling through native RISC-V CSR/SBI paths |
| Cluster PMU | Cache, coherence, AXI, arbitration, sleep and fault event taps | APB-readable measurements across all harts and shared resources |
| Flight recorder | Timestamped selected events and fault context | Explain order of events around performance regressions and failures |

Do not assume that a selected CPU implements every HPM event or standard overflow/filter extension. Publish capability/event tables. Smcntrpmf and Sscofpmf behavior is advertised only when supported by the core and validated; a custom cluster interrupt is not automatically a standard architectural counter interrupt. [R10]

Recommended PMU event groups:

| Group | Events to expose | Precise interpretation |
|---|---|---|
| Core execution | Retired instructions, issue count, branch/mispredict, pipeline-active and stall cycles | Retirement/issue events come from core adapters; an AXI monitor cannot infer them |
| Private cache/TLB | Hits, misses, refill, eviction, page-walk events | Define counting unit: request, line, beat or cycle |
| Shared cache | Lookup/miss, bank conflicts, MSHR full, writebacks | Attribute per source where available |
| Coherence | Probe issued/completed, dirty intervention, owner transfers, line-conflict wait | Separate transactions from probe fanout and data beats |
| AXI flow | Accepted AR/AW, R/W bytes, response errors, VALID-not-READY cycles, outstanding high-water | Count handshakes, not VALID level alone |
| Arbitration | Request wait, grants, blocked-resource cycles | Distinguish no request, fabric contention and downstream backpressure |
| Power residency | Running, clock-gated, quiescing, retention/off, wake latency | Real state feedback; do not infer solely from a sleep request |
| Debug/trace impact | Halt duration, SBA traffic, trace drops, trigger count | Separate source tags prevent debug traffic being mistaken for application traffic |

A cycle can contain multiple stall causes. Preserve raw overlapping cause counters; if presenting a partitioned top-down view, define one explicit priority/classification scheme. Do not sum overlapping stalls and report the result as elapsed time.

**AXI latency definitions:** read first-beat latency starts on AR handshake and ends on first R handshake; read completion latency ends on RLAST handshake. Write address-to-completion latency starts at AW handshake and ends at B handshake. Also optionally measure completion from the later of AW acceptance and last-W acceptance; label it separately. Track IDs and same-ID request order. AW and W can arrive independently, so matching one same-cycle AW/W pair is incorrect.

Use count/sum/min/max and programmable histogram bins, with all bin boundaries documented. Average latency is SUM/COUNT only for completed requests; separately expose pending count and age for unfinished transactions. Exact p95/p99 requires suitable retained samples or adequate histograms; a coarse histogram only provides an interval estimate.

Counters increment by actual event multiplicity. Dual-issue retirement may add two, and several taps may fire concurrently; boolean increments would undercount. Counter freeze/clear, saturation/wrap policy and overflow recording must be defined. Proposed custom counters wrap modulo 2^64 with sticky overflow, and preserve a newly arriving hardware overflow against same-cycle software status clear.

### 11. Snapshot, timing and observability overhead

Provide a cluster timestamp from an always-on stable reference domain. Cycle counters in a DVFS-controlled domain cannot be directly interpreted as wall-clock time without frequency history. Each event records source and timestamp-domain identity.

A PMU snapshot request carries a generation number; each event domain latches a coherent local snapshot and acknowledges. APB reads the stable snapshot bank, leaving live counting active. Report snapshot completion mask and capture timestamps. Across asynchronous domains this is a coordinated observation with bounded skew, not an atomic same-cycle global snapshot. A truly simultaneous clock-domain-local capture requires the corresponding synchronous implementation.

Expose timestamp skew/error bounds only after the CDC design is known. Debug halt does not freeze the always-on timestamp; PMU count-on-halt and per-origin filtering are configurable, observable policies. Reset creates a new measurement epoch rather than silently concatenating incompatible counter intervals.

Keep custom per-hart event accumulators in a domain able to acknowledge snapshots while that hart's pipeline is gated. Native architectural HPM counters remain accessible only through supported hart/debug mechanisms; they are not silently included in an APB snapshot. For an unavailable or stopped event domain, return explicit unavailable/stale status and its last capture epoch instead of waiting forever or inventing a fresh zero reading.

Monitor taps must be observational: a full trace FIFO or PMU read must not backpressure normal CPU/AXI/coherence traffic. Use a deterministic drop policy, lost-record counter and sticky overflow. Recorders can be disabled and event inputs gated when unused; compare timing, area and power with observability disabled/enabled.

### 12. Debug architecture and capability honesty

Use one multi-hart Debug Module, JTAG DTM and DMI transport with present/available/halted/running state per hart. Support the exact native debug revision of the chosen core/DM combination. A debug wrapper alone does not upgrade a 0.13.2 core implementation to Debug 1.0.

PULP `riscv-dbg` is an integration candidate with execution-based debug and SBA. Its documentation lists unsupported optional features including halt groups/authentication and other trigger/access capabilities. Therefore coordinated halt groups, cross-triggering and authentication are **additional proposed integration work**, not inherited features. [R11]

Proposed capability levels:

| Level | Required behavior | Dependency |
|---|---|---|
| Base run control | Select each real hart, halt/resume/single-step, inspect supported GPR/CSR state, report unavailable harts | Compatible DM/core debug interfaces and ROM/program-buffer integration |
| Memory visibility | SBA can inspect/modify shared normal memory with explicit coherence policy | Coherent cacheless injection adapter or verified maintenance sequence |
| Coordinated debug | Trigger halt requests to a selected hart mask, capture each acknowledgment and timestamp | New cross-trigger controller if selected IP lacks it |
| Trace correlation | Connect breakpoints, PMU thresholds, bus faults and recorder triggers | Core trigger support is separately checked |

Coordinated requests do not guarantee that all harts halt on the same instruction boundary or cycle. Report per-hart halt acknowledgment and skew; timeouts identify a non-responsive hart without pretending that it halted. A hart may need instructions/data/debug memory while entering its park loop, so halt sequencing must preserve those paths.

**SBA normal memory must be coherent in the proposed cluster.** An SBA AXI read that bypasses dirty private/L2 caches can return stale data. Preferred path is a cacheless coherent initiator injected into the cluster home/fabric; a properly integrated ACE-Lite path may serve this purpose. The standard debug specification itself does not guarantee SBA coherence. [R12]

MMIO debug is a separate uncached path with explicit region authorization and side-effect awareness. Debug memory/ROM access is protected according to core debug-state support. APB exposes debug policy/status; it is not a competing replacement for DMI abstract commands. Independent APB and DMI accesses to shared control require arbitration and one authoritative state machine.

Debug must be able to request wake through the always-on controller. Clock-gated/coherence-active tiles remain snoop-responsive. Power-off harts report unavailable until the power/restore sequence completes; accesses must return defined status rather than stall DMI forever.

### 13. Flight recorder and trigger design

Proposed fixed-format event records contain format version, epoch, timestamp, source/hart ID, event ID, request ID or recorder correlation token, and limited event-specific context such as address/status. Data payload capture is off by default and requires explicit authorization/configuration because it increases bandwidth and may expose workload data.

Triggers include PMU threshold/overflow, response error, age of an outstanding transaction exceeding a configured observation threshold, repeated ownership transfers, trace overflow and supported hart debug triggers. Provide pre-trigger circular history and programmable post-trigger record count, then freeze the recorder. Trigger capture must not imply that the underlying fabric was halted.

Record address acceptance, response completion, probe issue/response, ownership transfer, low-power transitions and faults. Trace is a **custom cluster event recorder**, not a standards-compliant RISC-V instruction-trace encoder unless such an encoder is separately selected. A new stream interface is not required in the baseline: the frozen recorder is read through an APB aperture. Sustained instruction trace would require a separate bandwidth/interface decision.

### 14. Preliminary APB address organization

Offsets below organize one proposed 64 KiB aperture. They are not a completed register-by-register programming specification. All ordinary registers are 32-bit aligned; 64-bit quantities use documented low/high words or snapshot windows.

| Offset range | Group | Proposed content |
|---|---|---|
| 0x0000–0x00FF | Identification/capabilities | Version, CPU-present mask, hart IDs, cache/ISA-interface capability descriptors, PMU/trace format |
| 0x0100–0x01FF | Cluster management | Command/status, masks, shadow/commit controls, ownership of configuration |
| 0x0200–0x02FF | Power/wake policy | Requested versus actual states, wake reasons, transition faults |
| 0x0400–0x07FF | Per-hart wrapper control | Four reserved 0x100-byte windows; boot mailbox, release/quiesce request/status, supported tuning |
| 0x1000–0x13FF | Shared PMU control | Event selectors, masks, overflow, histogram configuration, snapshot generation/status |
| 0x1400–0x17FF | Per-hart PMU windows | Four reserved 0x100-byte snapshot/control windows |
| 0x1800–0x1FFF | Shared PMU snapshots | Coherence/AXI/L2 counters, latency sums and histograms within supported capacity |
| 0x2000–0x23FF | Debug supervision | Present/available/halted masks, cross-trigger policy, coherent-SBA policy/status |
| 0x2400–0x27FF | Fault recorder | First-error source/address/ID, sticky status, recovery observations |
| 0x3000–0x30FF | Recorder control | Trigger configuration, capture state, drop count, epoch |
| 0x4000–0x7FFF | Recorder data aperture | Frozen-record indexed reads; capacity may use explicit index/bank registers |
| Remaining | Reserved | Defined read/error policy; no accidental alias |

APB counter reads use a latched snapshot or documented stable low/high read procedure; torn 64-bit reads are unacceptable. Commands have sequence IDs and accept/busy/done/error states. Security/privilege checks protect control and trace separately from harmless capability reads. Existing core native debug/program-buffer behavior must be preserved.

### 15. Boot, measurement and debug sequences

| Sequence | Steps | Observable completion |
|---|---|---|
| Cold boot | Reset fabric and state consistently; initialize management; release hart 0; hold others reset or in boot-ROM park until firmware configures release | Present mask, fabric-ready and per-hart boot/release status |
| Release another hart | Prepare entry/context in shared memory; perform required ordering; stage wrapper mailbox/address; commit release through APB | Per-hart accepted/done status plus firmware acknowledgment |
| Performance measurement | Program supported selectors; clear/start epoch; run workload; request snapshot; wait for acknowledgment mask; read stable snapshots | Snapshot generation and per-domain capture times |
| Investigate latency | Arm recorder; set latency-age observation trigger; run workload; freeze after post-trigger window; read correlated PMU and records | Trigger cause, timestamp, pending-request context and dropped-record count |
| Debug shared data | Request wake if needed; select hart(s); halt or run according to task; issue coherent SBA; inspect actual halt mask and memory results | DMI completion and SBA error/busy state; no assumption of all-hart simultaneity |
| Park/power down core | Stop scheduling new work; request quiesce; drain permitted operations; retain snoop service or clean/evict/remove membership; enter requested sleep | Separate quiesce, coherence and power-controller acknowledgments |
| Reconfigure route/cache policy | Quiesce affected initiators and relevant cache state; validate shadow map/attributes; commit atomically; resume | Commit sequence/status; reject unsafe live changes |

Where a native CPU lacks a wrapper configuration feature, firmware performs the operation through supported CSRs/boot ROM. A generic APB field must not claim unsupported changes to the core microarchitecture.

### 16. Clock, reset, power and fault handling

Begin with one CPU/cache/coherence clock domain and a management/wake/debug domain. Per-core pipeline gating must not unintentionally gate required snoop service. Crossing full ACE interfaces needs a coherent protocol-aware solution including snoop/control channels; applying an ordinary five-channel AXI CDC alone is insufficient.

APB remains functional in the management domain while CPU execution is gated. JTAG/debug crossings follow selected DTM restrictions. Reset deassertion is synchronized in each destination domain, with reset/isolation order defined for retained versus non-retained state.

Single-core reset is a coordinated management operation. Resetting a core with dirty private data or active protocol transactions can corrupt shared state or strand directory ownership. Define drain/clean/evict, retained-cache operation or an explicit destructive-cluster recovery mode before allowing it. Hard reset recovery is not equivalent to a clean shutdown.

Fault supervision records protocol response errors, invalid routing, available ECC/parity events and observed no-progress conditions. A watchdog detects age, reports context and may request a controlled recovery; it must not silently drop accepted transactions, reuse their IDs or fabricate a completion while a late response can still arrive. Any timeout-based completion requires a formally specified containment/abort boundary.

Proposed recovery escalation: report interrupt and freeze diagnostics; attempt software-led diagnosis if responsive; request controlled tile/cluster quiesce; invoke platform recovery/reset if necessary. Exact escalation privileges and deadlines are integration inputs, not fabricated guarantees.

### 17. Performance and power reasoning

The architecture is selected by useful completed work under actual memory/coherence load. Measure CPU retirement, core-local stalls, shared queues, snoop traffic, peripheral pressure and debug overhead together.

```text
IPC(hart) = retired instructions / selected hart cycle denominator
Read BW = accepted R payload bytes / observation time
Write BW = sum(popcount(WSTRB)) on W handshakes / observation time
Average completed-read latency = completion-latency sum / completed requests
Task energy = integral of defined system power over completion time
Ideal S(N) = 1 / ((1-p) + p/N)
```

Define whether cycle denominator includes sleep/halt; report both active-cycle IPC and wall-time throughput where useful. Read bytes exclude unused/masked portions only if the metric explicitly says so; write strobe bytes and bus occupancy bytes are separate measurements. Response latency includes receiver backpressure when measured to response handshake, so expose R/B backpressure counters alongside it.

At p=0.90, ideal two/four-core speedups are 1.82×/3.08× before overhead. The cited 2026 CVA6S+ dual-core study is motivation, not proof of four-core speed or cluster power. No frequency, latency guarantee or low-power percentage is claimed without selected libraries, operating points and workloads. [R13]

Clock-gate unused PMU/trace arithmetic and SRAM ports where safe. Freeze capture does not force live counters to stop unless requested. Evaluate one/two/four-core workload policies, shared-fabric energy while cores park, and coherence-aware deep sleep. Four independent voltage domains are deferred until a measured duty-cycle benefit justifies added crossing and recovery complexity.

### 18. Validation plan and traceability

These are future implementation checks, not executed verification results.

| Requirement | Evidence needed before RTL acceptance |
|---|---|
| U-01 | Elaborate N=2 and N=4, enumerate correct harts, reject invalid N, prove absent tiles cannot block coherence/debug/snapshot |
| U-02 | Compare queue/cache/topology variants at common PVT/SDC/SRAM assumptions; quantify energy/task and sustained throughput |
| U-03 | Reference-model PMU counts for simultaneous events, ID reuse, interleaving, wrap, snapshot skew, reset epochs and DVFS residency |
| U-04 | Multi-hart halt/resume/step, unavailable-hart behavior, coherent SBA dirty-owner reads/writes, trigger and trace-loss tests |
| U-05 | AXI/ACE protocol checking with independent stalls, outstanding IDs, AW/W separation, errors and mapped/unmapped routes |
| U-06 | Coherence invariants, dirty data intervention, external snoops, atomic/LR-SC contention, DMA visibility, RVWMO and progress |
| U-07 | APB access, protection, strobe/error policy, command acknowledgment, CDC, torn-read prevention and unsupported-feature rejection |

Four-party race examples: hart 0 owns dirty data, hart 1 reads, hart 2 requests ownership, hart 3 evicts or sleeps while an external snoop arrives. Include shared-L2 eviction, recorder-full, debug SBA and reset requests. Assert ownership/data preservation and progress under legal environmental assumptions.

Performance tests include private compute, shared producer-consumer, false sharing, independent memory streams, MMIO pressure and bursty load with one/two/four active cores. Observe PMU/recorder correctness without enabling backpressure from monitoring. Record PPA with monitoring off, counters on and recorder armed.

### 19. Decisions proposed and inputs still needed

| Decision | Recommended option and reason | Example/tradeoff |
|---|---|---|
| Topology | One coherent cluster for 2/4 CPUs | Simpler cross-core path than 2+2; compare directory if snoop traffic dominates |
| CPU baseline | Compatible CVA6-family coherent tile first; exact variant pinned before RTL work | CVA6S+ may raise IPC, but matching coherent HPDCache/proxy must be demonstrated |
| External coherent protocol | Full ACE target | Cached external sharing is supported by contract; requires a real cluster proxy and compatible SoC fabric |
| Coherence/memory boundary | SoC provides system fabric/home; cluster manages its local caches | A plain DRAM-only SoC would instead need an integrated system home and coherent external-agent ingress |
| Shared L2 | Configurable option, measured before fixing size | Can reduce DRAM traffic but adds SRAM/leakage and snoop integration |
| APB usage | Cluster management/telemetry; native architectural CSRs stay on hart paths | A cache/ISA size change cannot be achieved by writing a runtime APB register |
| Debug revision | Match selected core/DM; do not claim unsupported newer revision | PULP DM is a 0.13.2 candidate, while newer standard features require compatibility work |
| Debug memory | Coherent cacheless injection preferred | SBA must see a line dirty in any CPU or L2 without relying on an unverified raw AXI read |
| Power | Shared CPU domain with independent supported gates | Separate per-core/per-pair DVFS needs PDK/SoC inputs |

Critical integration inputs: selected CPU/ISA and debug revision, external fabric ACE support and ownership model, memory map and physical address width, AXI widths/IDs/outstanding limits, cache IP compatibility, IRQ/timer/IPI platform, clock/reset sources, workload/deadlines, SRAM/PDK/PVT/SDC, permitted debug lifecycle access and trace budget.

Before implementing RTL, resolve the external coherent attachment and native core/cache compatibility first: these decide whether the proposed block can fulfill U-06, and are more fundamental than the preliminary APB offsets or PMU counter count.

## Tiếng Việt

### 20. Kiến trúc đề xuất và lý do

[Sơ đồ draw.io chỉnh sửa được](figures/cluster_architecture/vlsit_rtl_hierarchy.drawio) được nhúng ở mục 5. Đây là sơ đồ từ document theo phương án đã duyệt, chưa phải hierarchy xác nhận bằng RTL. CPU tile bank biểu diễn 2/4 tile độc lập có core và L1 riêng; mỗi giao tiếp theo hart vẫn độc lập. Bản draw.io có bảng chức năng và bảng interface, còn SVG trong document tập trung vào topology.

Đề xuất **một coherent cluster cấu hình tổng hợp 2 hoặc 4 CPU**, mỗi CPU có private L1I/L1D. Bên trong gồm coherent fabric/CCU, shared L2 tùy chọn, PMU, debug, recorder và quản lý nguồn/reset. Với hướng SystemVerilog, ưu tiên nghiên cứu CVA6-family + Culsans; dùng Rocket/Chipyard làm baseline đối chiếu. Chưa chốt phiên bản core/cache vì cần chứng minh các commit tương thích.

Số CPU là cấu hình trước synthesis. Bản hai core chỉ có hai CPU vật lý; bản bốn core có thể park core để tiết kiệm điện nhưng vẫn là phần cứng bốn core. Hart ID giữ ổn định 0..N−1. APB đọc được present mask và capability để phần mềm không truy cập nhầm core vắng mặt.

Mục 3 so sánh Culsans, Rocket/Chipyard, BlackParrot, OpenPiton, 2+2 cluster và scratchpad. Với phạm vi 2/4 core, một cluster là điểm bắt đầu hợp lý. Snoop không mặc định tốt hơn directory; cần đo độ trễ, contention và điện năng tại topology thực tế. Shared L2 cũng cần so sánh với cấu hình bypass/không L2.

### 21. Ba loại interface cần phân biệt

| Giao tiếp | Vai trò đề xuất | Ví dụ |
|---|---|---|
| **AXI4 non-coherent** | Cluster phát transaction ra peripheral | UART hoặc AXI-to-APB bridge; không để MMIO bị cache/speculate sai |
| **Full ACE coherent** | Cluster tham gia coherent SoC fabric như một cached agent tổng hợp | External agent đọc được dữ liệu mới nhất dù dữ liệu đang dirty trong cache của một CPU |
| **APB4 subordinate** | SoC/host truy cập cấu hình và trạng thái cluster | Release core, snapshot PMU, đọc fault, arm recorder và điều khiển power policy |

AXI thông thường không tự cung cấp coherence. ACE-Lite phù hợp cho một số initiator I/O coherent như DMA/cacheless debug; không thay thế full ACE khi cả cluster giữ cache và phải trả lời snoop ngoài. CHI là phương án khác nhưng cần thiết kế bridge/proxy coherent đầy đủ. [R7, R8]

Full ACE outward gồm cả đường request/response và đường snoop từ SoC vào cluster. **Cluster proxy** phải tìm dirty owner trong toàn bộ CPU/L2, tổng hợp response và đưa dữ liệu đúng ra ngoài. Đây là công việc tích hợp cần thực hiện; không giả định cổng AXI memory hiện có của Culsans đã làm được.

Memory controller phía sau system home có thể dùng AXI không coherent. Điều cần bảo đảm là mọi agent chia sẻ dữ liệu đều đi qua cơ chế ownership đúng. Nếu SoC chỉ có DRAM controller thường và không có coherent fabric, cần đổi boundary: tích hợp system home và một coherent ingress cho agent ngoài. Mục 7 ghi rõ hai hợp đồng này.

### 22. Cấu hình qua APB

APB dành cho wrapper/cluster management: version/capability, boot mailbox, release/quiesce request, power policy, PMU, debug policy và recorder. Không tạo một bản sao APB ghi tùy ý vào `satp`, `mstatus`, PMP hay các CSR kiến trúc đang được hart quản lý.

Core count, XLEN, ISA, cache size là cấu hình phần cứng. Nếu core có boot vector cố định thì dùng boot ROM/mailbox, không giả định có pin boot address tùy ý. Tính năng wrapper nào core không hỗ trợ phải báo rõ capability và từ chối lệnh tương ứng.

Lệnh dài như drain cache hoặc power-down dùng command + BUSY/DONE/ERROR, không giữ APB chờ suốt quá trình. Cấu hình nhiều bit crossing clock phải đi qua commit/acknowledgment nhất quán. Mục 14 đề xuất một aperture APB 64 KiB với các nhóm thanh ghi; đây chưa phải register specification đầy đủ để sinh RTL.

### 23. Giám sát performance có thể dùng để chẩn đoán

Giữ native counter của từng hart cho profiling phần mềm, đồng thời thêm **cluster PMU** để quan sát cache, coherence, AXI, arbitration và trạng thái ngủ. Không thể suy ra retired instruction hay pipeline stall chính xác chỉ bằng monitor ngoài AXI.

PMU đề xuất có 8 counter lập trình mỗi hart và 16 counter shared, rộng 64 bit; đây là điểm bắt đầu để đánh giá diện tích, chưa phải yêu cầu số lượng đã duyệt. Capability/event table chỉ rõ event nào thật sự có. Counter phải đếm được nhiều event trong một chu kỳ, ví dụ dual-issue retire hai lệnh.

Latency AXI cần theo dõi ID và thứ tự request cùng ID: read từ AR handshake tới first-R hoặc RLAST handshake; write từ AW tới B, hoặc một metric riêng bắt đầu khi đã nhận cả AW và W cuối. AW/W có thể độc lập, không ghép theo cùng chu kỳ. Pending request và tuổi request phải được lưu riêng với latency của request đã hoàn tất.

Snapshot dùng generation number và acknowledgment từ các event domain, rồi APB đọc bản đã chốt. Nếu các clock bất đồng bộ, snapshot có skew và phải báo timestamp từng domain; không gọi đó là ảnh chụp toàn cục cùng chu kỳ. Timestamp tham chiếu vẫn chạy khi CPU DVFS/halt để phân biệt thời gian thực với số chu kỳ CPU.

Phân biệt raw stall counters có thể chồng lấp với top-down view đã phân nhóm ưu tiên. Không cộng các counter chồng lấp rồi kết luận bằng tổng elapsed cycles. Histogram thô chỉ ước lượng khoảng percentile; không tuyên bố p99 chính xác khi dữ liệu không đủ.

### 24. Debug hiệu quả và nhất quán bộ nhớ

Một DM quản lý 2/4 harts qua JTAG/DTM/DMI; từng hart có present/available/halted/running status. Debug version phải khớp core và DM. Nguồn `riscv-dbg` là ứng viên 0.13.2, có các giới hạn tùy chọn được nêu trong tài liệu; không mặc định có halt groups, authentication hay mọi trigger. Các chức năng mở rộng này phải được thiết kế riêng nếu chọn. [R11]

**SBA phải coherent đối với normal memory theo đề xuất này.** Nếu debugger đọc AXI thẳng xuống DRAM trong khi một CPU giữ dirty line, debugger có thể thấy dữ liệu cũ. Đường ưu tiên là cacheless coherent initiator đi vào home/fabric. MMIO debug vẫn đi đường uncached, có kiểm soát vùng và nhận biết side effect. Debug standard không tự bảo đảm SBA coherence. [R12]

Cross-trigger có thể phát halt request cho một hart mask, nhưng không bảo đảm tất cả dừng cùng chu kỳ hay cùng instruction boundary. Cần lưu acknowledgment/timestamp của từng core và báo core không phản hồi. Hart đang power-off báo unavailable; debug có đường yêu cầu wake qua controller luôn bật.

Thêm **flight recorder** dạng ring buffer lưu timestamp, source, event, transaction correlation và context cần thiết. PMU threshold, bus fault hoặc request quá tuổi có thể trigger lưu lịch sử trước/sau sự kiện. Recorder đầy không được kéo backpressure vào data path: phải có drop policy/count và overflow status. Baseline đọc recorder đã freeze qua APB; đây là event trace tùy biến, chưa phải instruction trace encoder chuẩn.

### 25. Nguồn, reset và lỗi

Bắt đầu với một miền clock CPU/cache/coherence và một miền management/wake/debug. Clock gating CPU không được vô tình tắt snoop service cho dirty cache đang được hệ thống sử dụng. CDC full ACE phải bao phủ cả snoop/control channels; một AXI CDC năm kênh thông thường chưa đủ.

Reset riêng một core cần drain/clean/evict hoặc một hợp đồng retained-cache/recovery được định nghĩa. Không reset tùy tiện core đang sở hữu dirty line hoặc transaction outstanding. Power-down cũng cần acknowledgment từ coherence và nguồn, không chỉ thấy pipeline idle.

Watchdog ghi tuổi transaction, nguồn, địa chỉ, ID và trạng thái để chẩn đoán. Nó không được tự bỏ request đã nhận rồi tái dùng ID hoặc bịa completion khi response cũ vẫn có thể quay lại. Recovery cần boundary hủy/cô lập được định nghĩa hoặc reset có phối hợp. Đây là điểm quan trọng để tránh phần debug/fault-monitor tạo ra lỗi chức năng mới.

### 26. Những điểm cần chốt trước RTL

Ưu tiên chốt **external coherent fabric hỗ trợ gì** và **bộ core/cache/CCU nào tương thích**. Hai điểm này quyết định block có thật sự đáp ứng coherent main data path hay không. Sau đó mới cố định width/ID/outstanding, shared L2, clock/reset, interrupt platform và APB register details.

Các lựa chọn đề xuất hiện tại: homogeneous RV64, hai hoặc bốn core theo synthesis, một cluster, full ACE outward, AXI4 peripheral, APB4 management, coherent SBA, PMU có snapshot và recorder không gây backpressure. Đây là đề xuất review; chưa tự đặt frequency/Fmax, power target hoặc diện tích khi thiếu PDK/SRAM/workload.

Mục 18 đưa ra verification/traceability plan cho cả hai cấu hình, gồm race bốn bên, external snoop, atomics/LR-SC, DMA, PMU simultaneous events, snapshot CDC, debug dirty-owner access và sleep/reset. Các kiểm tra này chưa được chạy; tài liệu hiện tại là mô tả kiến trúc thống nhất để bạn review trước khi chuyển thành đặc tả triển khai.

## Primary references / Nguồn gốc

Consulted on 2026-11-06. Source-specific behavior is attributed below; project policies and parameter values above are proposals. Standards and compatible IP commits must be frozen before implementation.

- **R1:** [Culsans public 2–4-core integration](https://github.com/pulp-platform/culsans), [Culsans paper](https://arxiv.org/abs/2407.19895).
- **R2:** [Chipyard explicit dual/quad Rocket configurations](https://github.com/ucb-bar/chipyard/blob/main/generators/chipyard/src/main/scala/config/RocketConfigs.scala), [Rocket Chip architecture](https://chipyard.readthedocs.io/en/stable/generators/rocket-chip/).
- **R3:** [BlackParrot implementation/status](https://github.com/black-parrot/black-parrot), [BedRock coherent memory guide](https://github.com/black-parrot/black-parrot/blob/master/docs/bedrock_guide.md).
- **R4:** [OpenPiton and Ariane/CVA6 integration](https://github.com/PrincetonUniversity/openpiton/blob/openpiton/README.md).
- **R5:** [PULP cluster](https://github.com/pulp-platform/pulp_cluster), [PULP top-level architecture](https://github.com/pulp-platform/pulp).
- **R6:** [Cheshire architecture, LLC assumption and debug integration](https://github.com/pulp-platform/cheshire/blob/main/docs/um/arch.md).
- **R7:** [Arm AXI/ACE/ACE-Lite role distinctions](https://developer.arm.com/community/arm-community-blogs/b/architectures-and-processors-blog/posts/introducing-the-next-generation-of-axi-and-ace-protocols), [Arm coherent-system explanation](https://developer.arm.com/community/arm-community-blogs/b/architectures-and-processors-blog/posts/exploring-how-cache-coherency-accelerates-heterogeneous-compute).
- **R8:** [Arm AMBA AXI and ACE Protocol Specification IHI0022H](https://developer.arm.com/-/media/Arm%20Developer%20Community/PDF/IHI0022H_amba_axi_protocol_spec.pdf), [Arm ACE cache-coherence whitepaper](https://developer.arm.com/-/media/Arm%20Developer%20Community/PDF/CacheCoherencyWhitepaper_6June2011.pdf).
- **R9:** [PULP AXI library and AXI4+ATOP capability rules](https://github.com/pulp-platform/axi/blob/master/README.md).
- **R10:** [RISC-V Smcntrpmf](https://docs.riscv.org/reference/isa/priv/smcntrpmf.html), [RISC-V Sscofpmf](https://docs.riscv.org/reference/isa/v20260120/priv/sscofpmf.html).
- **R11:** [PULP RISC-V debug implementation](https://github.com/pulp-platform/riscv-dbg), [debug-system capabilities and limitations](https://github.com/pulp-platform/riscv-dbg/blob/master/doc/debug-system.md).
- **R12:** [RISC-V Debug Specification, including SBA coherence limitation](https://docs.riscv.org/reference/debug-trace-ras/debug/_attachments/riscv-debug-specification.pdf).
- **R13:** [CVA6S+/HPDCache cluster conference report](https://cfp.riscv-europe.org/eu-summit-2026/talk/R7MK7D/), [CVA6S+ paper](https://arxiv.org/abs/2505.03762).
- **R14:** [RISC-V ISA memory/privilege architecture](https://riscv.github.io/riscv-isa-manual/snapshot/spec/), [CVA6 PMA integration limits](https://cva6.readthedocs.io/en/stable/01_cva6_user/PMA.html).
- **R15 — Standard to freeze before implementation:** [Arm APB protocol specification landing page, IHI0024](https://developer.arm.com/documentation/ihi0024/latest/). The landing page was reachable but did not expose readable clauses in this review; exact edition and clause-level APB compliance review remain open.

Related local background: [dual-core research](RISC_V_Dual_Core_High_Performance_Low_Power_Analysis.md), [quad-core research](RISC_V_Quad_Core_High_Performance_Low_Power_Analysis.md).
