"""Build deeper document-grounded diagrams for the proposed RISC-V cluster.

Purpose: expand approved cluster subsystems by one architectural level and make
reuse/adaptation/new-design provenance visible in editable draw.io diagrams.
Usage: python scripts/build_cluster_detail_diagrams.py [--analyze-only]
Inputs: the approved dual/quad cluster specification and the installed VLSIT
        draw.io library/generator.
Outputs: doc/specification/figures/detail_level2/*.json, per-page draw.io files,
         a combined multi-page draw.io file, and vlsit_rtl_analysis.md.
Exit codes: 0 success; nonzero on missing inputs, incomplete routes, or errors.
Python standard library only. This script does not read or modify RTL sources.
"""
from pathlib import Path
import argparse
import copy
import hashlib
import importlib.util
import json
import re
import subprocess
import sys
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "doc" / "specification" / "figures" / "detail_level2"
SKILL = Path(r"C:\Users\PC\.codex\skills\vlsit-rtl-hierarchy-diagram")
LIBRARY = SKILL / "assets" / "VLSIT_DRAWIO_LIB_V1.drawio.xml"
GENERATOR = SKILL / "scripts" / "vlsit_drawio_frame_diagram.py"
VALIDATOR = SKILL / "scripts" / "vlsit_library_symbols.py"
GEOMETRY = SKILL / "scripts" / "vlsit_drawio_geometry_check.py"
HDS = ROOT / "doc" / "specification" / "VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md"


def blk(key, inst, module, status, role, row, col, width=260):
    prefix = status.split("|")[0].strip().upper()
    if prefix.startswith("MODIFY") or prefix.startswith("REUSE +"):
        classification = "MODIFY"
    elif prefix.startswith("NEW WRAPPER"):
        classification = "NEW + REUSE"
    elif prefix.startswith("REUSE CANDIDATE"):
        classification = "REUSE*"
    elif prefix.startswith("REUSE"):
        classification = "REUSE"
    elif prefix.startswith("GENERATED"):
        classification = "GENERATED"
    else:
        classification = "NEW"
    label = [inst, f"({module})", classification]
    # Size each block to its text so the diagram does not contain oversized
    # empty blocks or clipped labels. The geometry checker targets ~78% fill.
    width = max(80, int(round(9 * max(map(len, label)) / 0.78 / 10) * 10))
    return {"key": key, "label": label, "width": width,
            "row": row, "col": col, "row_name": f"{inst} / {module}",
            "function": role, "source": status}


def edge(name, src, src_side, dst, dst_side):
    return {"id": name, "src": src, "src_side": src_side,
            "dst": dst, "dst_side": dst_side}


def ext(name, block, side, direction, pos, text):
    return {"id": name, "block": block, "side": side, "dir": direction,
            "pos": pos, "text": text}


def iface(name, title, category, active, signals):
    return {"id": name, "name": title, "category": category,
            "active": active, "signals": signals}


def page(page_id, title, parent, blocks, edges, externals, interfaces, note):
    external_ids = [x["id"] for x in externals]
    return {
        "page_name": page_id,
        "library_sha256": hashlib.sha256(LIBRARY.read_bytes()).hexdigest().upper(),
        "layout": {"gap_h": 110, "gap_v": 110, "margin": 45, "block_h": 80},
        "top": {"frame_label": [title, f"({parent})"]},
        "frame_row": [title, "Document-grounded proposal; no RTL hierarchy is asserted.", HDS.name],
        "frame_interfaces": external_ids,
        "blocks": blocks,
        "connectors": edges,
        "externals": externals,
        "nets": [],
        "interfaces": interfaces,
        "legend_note": note + " Status codes: REUSE = upstream RTL reused; REUSE* = reuse candidate pending compatibility checks; MODIFY = source adaptation, wrapper, or macro binding; NEW = VLSIT RTL to design; GENERATED = CSR RTL from the selected generator. All proposed blocks are dashed because this cluster has no pinned integrated RTL yet."
    }


def specifications():
    pages = []
    pages.append(page(
        "01_TILE", "CPU tile internals", "m_vlsit_riscv_cpu_tile",
        [
            blk("core", "u_cva6", "cva6", "MODIFY | OpenHW CVA6 integration copy",
                "Uses a license-preserving local config with CVXIF disabled; the licensed shell routes boot address, D-cache ownership and tagged probes. Pipeline, MMU and I-cache submodules remain unchanged.", 0, 0, 320),
            blk("subsys", "u_cva6_hpdcache_subsystem", "cva6_hpdcache_subsystem", "MODIFY | OpenHW CVA6",
                "Splits the cacheable D-cache path from I-cache/device traffic and connects ownership grant plus tagged probe/data response paths to the coherence fabric.", 0, 1, 340),
            blk("icache", "u_cva6_icache", "cva6_icache", "REUSE | OpenHW CVA6",
                "Stores instruction lines and services instruction fetches for the hart.", 1, 0, 260),
            blk("hpdwrap", "u_cva6_hpdcache_wrapper", "cva6_hpdcache_wrapper", "MODIFY | OpenHW CVA6",
                "Carries CPU request IDs and hart identity across the new permission request/grant and tagged probe interfaces.", 1, 1, 340),
            blk("hpd", "u_hpdcache", "hpdcache", "MODIFY | OpenHW HPDcache licensed copy",
                "Adds per-line I/S/E/M state, permission-before-fill/upgrade sequencing, same-line exclusion and full-line tagged probe service.", 1, 2, 340),
            blk("tile_adapt", "u_vlsit_riscv_tile_coh_adapter", "m_vlsit_riscv_tile_coh_adapter", "NEW | VLSIT",
                "Adapts source request IDs and line operations to the CCU; gates D-cache completion on ownership grants and associates tagged probe responses.", 1, 3, 380),
        ],
        [edge("CORE", "core", "R", "subsys", "L"),
         edge("IFETCH", "subsys", "B", "icache", "T"),
         edge("DCACHE", "subsys", "R", "hpdwrap", "L"),
         edge("HPD", "hpdwrap", "B", "hpd", "T"),
         edge("COH", "hpd", "B", "tile_adapt", "T")],
        [ext("BOOT", "core", "T", "in", -20, ["BOOT", "Shared i_boot_addr[63:0]"]),
         ext("IRQ", "core", "L", "in", -30, ["IRQ", "Per-hart interrupt inputs"]),
         ext("TREQ", "tile_adapt", "B", "out", 0, ["TREQ", "Coherence boundary"]),
         ext("EVT", "core", "T", "out", 0, ["EVT", "Per-hart event taps"])],
        [iface("CORE", "CVA6/cache subsystem", "handshake", "cva6 -> cache subsystem",
               "Request, response, fetch/data payload and completion; exact record fields depend on the pinned CVA6 source."),
         iface("IFETCH", "Instruction cache path", "handshake", "cache subsystem -> cva6_icache",
               "Instruction fetch request/return data; exact RTL fields are source-version dependent."),
         iface("DCACHE", "HPDcache wrapper path", "handshake", "cache subsystem -> wrapper",
               "Data-cache requester traffic and responses; types and outstanding limits must match the selected config."),
         iface("HPD", "HPDcache internal path", "handshake", "wrapper -> hpdcache",
               "Requester commands, response data, write data and cache-maintenance status."),
         iface("COH", "Tile ownership request/grant", "custom", "D-cache -> CCU -> D-cache",
               "Read-shared or write-unique permission request, physical line address, original requester ID, grant state and line data; exact widths are frozen in the port plan."),
         iface("PROBE", "Tagged two-phase probe", "custom", "CCU <-> D-cache",
               "PREPARE returns stable MESI state and any dirty data without changing state; COMMIT changes target state; ABORT restores the old state. Missing COMMIT ACK holds line lock/slot until reset."),
         iface("IRQ", "Per-hart platform interrupts", "custom", "SoC -> CVA6", "Per-hart interrupt classes defined in Section 6."),
         iface("BOOT", "Shared boot address", "custom", "SoC -> every active CVA6 hart", "One runtime 64-bit input is held through reset release and fanned out to boot_addr_i of each active hart; software may branch on mhartid."),
         iface("TREQ", "Tile coherence boundary", "custom", "tile -> cluster fabric", "Logical cacheable request/response interface; names, widths and cycle timing await source integration."),
         iface("EVT", "Hart performance event taps", "custom", "CVA6/cache -> PMU", "Candidate CVA6 performance events and cache events; event map is an open dependency.")],
        "Planned wrapper/instance names are VLSIT proposals, not names observed in a pinned RTL tree. CVXIF is disabled in the licensed local CVA6 config copy; no CVXIF port is exposed at the cluster boundary."
    ))
    pages.append(page(
        "02_COHERENCE", "Coherence and MMIO routing", "m_vlsit_riscv_coh_fabric",
        [
            blk("tile", "u_vlsit_riscv_tile_coh_adapter", "m_vlsit_riscv_tile_coh_adapter", "NEW | VLSIT",
                "Terminates one tile's coherent request/response interface; instantiated once for each active hart.", 1, 0, 340),
            blk("ccu", "u_vlsit_riscv_coh_fabric", "m_vlsit_riscv_coh_fabric", "NEW | VLSIT; Culsans is reference only",
                "New MESI CCU coordinates tagged transactions and two-phase probes; all PREPARE/COMMIT/ABORT ACK waits have no timeout. Culsans supplies architecture reference, not copied RTL.", 1, 1, 360),
            blk("txn", "u_vlsit_riscv_coh_txn_table", "m_vlsit_riscv_coh_txn_table", "NEW | VLSIT",
                "Tracks 2–16 tagged contexts (default 8), line locks and PREPARE/COMMIT/ABORT ACK masks. A missing phase ACK retains its lock and slot until ACK or reset.", 0, 3, 340),
            blk("directory", "u_vlsit_riscv_sharer_directory", "m_vlsit_riscv_sharer_directory", "NEW | VLSIT",
                "Independent non-inclusive directory: four banks, eight ways, 4,096/8,192 entries for two/four harts; per-bank round-robin and seven-bit tree-PLRU per set, choosing the lowest-index invalid way first.", 0, 4, 360),
            blk("probe", "u_vlsit_riscv_probe_scheduler", "m_vlsit_riscv_probe_scheduler", "NEW | VLSIT",
                "Sends tagged PREPARE/COMMIT/ABORT only to recorded holders and collects one matching response from each target.", 1, 4, 330),
            blk("mux", "u_axi_mux", "axi_mux", "REUSE candidate | PULP AXI",
                "Arbitrates compatible AXI request sources into one output while preserving response association.", 0, 2, 260),
            blk("dev_class", "u_vlsit_riscv_device_classifier", "m_vlsit_riscv_device_classifier", "NEW | VLSIT",
                "Classifies normal cacheable memory versus non-cacheable device transactions using the SoC address/attribute contract.", 2, 2, 340),
            blk("demux", "u_axi_demux", "axi_demux", "REUSE candidate | PULP AXI",
                "Routes AXI transactions to selected targets with response and ID tracking; configuration must be checked against the chosen topology.", 2, 3, 300),
            blk("mmio", "u_vlsit_riscv_axi_mmio", "m_vlsit_riscv_axi_mmio", "NEW | VLSIT wrapper",
                "Carries non-cacheable peripheral traffic to the external AXI4 device fabric and returns responses without allocating cache lines.", 2, 4, 340),
        ],
        [edge("COH_REQ", "tile", "R", "ccu", "L"),
         edge("CTX", "ccu", "T", "txn", "B"),
         edge("DIR", "ccu", "R", "directory", "L"),
         edge("PROBE", "ccu", "B", "probe", "T"),
         edge("MEM", "ccu", "B", "mux", "T"),
         edge("DEVICE", "ccu", "R", "dev_class", "L"),
         edge("DECODE", "dev_class", "B", "demux", "T"),
         edge("MMIO", "demux", "B", "mmio", "T")],
        [ext("LLC", "mux", "B", "out", 0, ["LLC", "Shared LLC request"]),
         ext("DEV", "mmio", "B", "out", 0, ["DEV", "AXI4 device path"]),
         ext("EVT", "ccu", "T", "out", 0, ["EVT", "Coherence event taps"])],
        [iface("COH_REQ", "Tile coherent request service", "custom", "tile adapter -> CCU", "One logical request/response service per active tile; local probe semantics and fields require the pinned Culsans/cache interfaces."),
         iface("CTX", "Tagged transaction context", "custom", "CCU <-> transaction table", "Line address, requester, slot-derived tag, holder/phase masks, dirty-data and LLC status; context is released only after protocol completion."),
         iface("DIR", "Independent sharer directory", "custom", "CCU <-> directory", "Four independently arbitrated banks; round-robin grant per bank; 8-way tree-PLRU (0=left, 1=right), lowest-index invalid-way preference, holder bitmap and two-phase victim resolution."),
         iface("PROBE", "Tagged two-phase probes", "custom", "CCU <-> probe scheduler <-> D-caches", "PREPARE keeps stable MESI unchanged; COMMIT applies target state; pre-COMMIT ABORT restores the prior state. No ACK timeout in any phase."),
         iface("MEM", "Coherent normal-memory path", "custom", "CCU -> shared LLC path", "Cacheable requests, ownership resolution and response data; exact VLSIT record is to be defined from source ports."),
         iface("DEVICE", "Uncached device path", "custom", "CCU -> device classifier", "Non-cacheable address/control/data and returned response."),
         iface("DECODE", "AXI target routing", "standard protocol", "classifier -> AXI demux", "AXI4 transaction channels; route policy is VLSIT-owned."),
         iface("MMIO", "Non-coherent AXI4 peripheral", "standard protocol", "cluster -> peripheral fabric", "AXI4 AW/W/B/AR/R; exact port widths are specified in Section 6."),
         iface("TREQ", "Per-tile coherence boundary", "custom", "tiles -> fabric", "Replicated logical cache request/response paths; exact RTL pins TBD."),
         iface("LLC", "Shared LLC request boundary", "custom", "fabric -> LLC", "AXI4 cache request path; profile-specific external memory service is described separately."),
         iface("DEV", "AXI4 peripheral boundary", "standard protocol", "cluster -> SoC peripheral fabric", "AXI4 MMIO channels as specified in Section 6."),
         iface("EVT", "Coherence performance taps", "custom", "CCU -> cluster PMU", "Candidate hit/miss, probe, conflict and queue events; exact source map is open.")],
        "The PULP axi_mux/axi_demux blocks are reuse candidates only until the pinned dependency versions and transaction topology are checked."
    ))
    pages.append(page(
        "03_LLC", "Shared LLC internal datapath", "axi_llc",
        [
            blk("split", "u_axi_llc_chan_splitter", "axi_llc_chan_splitter", "REUSE | PULP axi_llc",
                "Splits AXI bursts into cache-line descriptors and merges read, write and flush descriptors.", 1, 0, 300),
            blk("hm", "u_axi_llc_hit_miss", "axi_llc_hit_miss", "REUSE | PULP axi_llc",
                "Performs tag lookup, hit bypass, miss ordering and line-lock checks before the read/write datapaths.", 1, 1, 300),
            blk("tags", "u_axi_llc_tag_store", "axi_llc_tag_store", "REUSE candidate | PULP axi_llc",
                "Stores and looks up tags/dirty state and performs tag-store initialization BIST.", 0, 2, 280),
            blk("rw", "u_axi_llc_rw_units", "axi_llc_read_unit / axi_llc_write_unit", "REUSE | PULP axi_llc",
                "Serves cache hits and transfers data between AXI slave transactions and configured LLC data ways.", 2, 2, 340),
            blk("miss", "u_axi_llc_miss_units", "axi_llc_evict_unit / axi_llc_refill_unit", "REUSE | PULP axi_llc",
                "Writes back dirty victims and refills cache lines from the LLC master memory interface.", 1, 3, 340),
            blk("ways", "u_axi_llc_data_ways", "LLC data-way storage", "MODIFY | SRAM macro integration",
                "Holds cache-line data; map the source storage wrappers to selected ASIC SRAM macros and timing models.", 0, 4, 320),
            blk("cfg", "u_axi_llc_config", "axi_llc_config", "MODIFY | PULP axi_llc wrapper policy",
                "Reports BIST/status and controls flush/counters; the VLSIT wrapper shall lock SPM disabled and expose the approved service window.", 2, 4, 360),
        ],
        [edge("DESC", "split", "R", "hm", "L"),
         edge("TAG", "hm", "T", "tags", "B"),
         edge("HIT", "hm", "B", "rw", "T"),
         edge("MISS", "hm", "R", "miss", "L"),
         edge("DATA", "rw", "R", "ways", "L"),
         edge("EVICT", "miss", "B", "ways", "T"),
         edge("FLUSH", "cfg", "L", "hm", "R")],
        [ext("SLV", "split", "L", "in", 0, ["SLV", "AXI4 cache request interface"]),
         ext("MEM", "miss", "R", "out", 0, ["MEM"]),
         ext("SVC", "cfg", "B", "in", 0, ["SVC", "AXI4-Lite service"])],
        [iface("DESC", "LLC descriptor pipeline", "handshake", "channel splitter -> hit/miss pipeline", "Address, burst fragment, ID, way, hit/miss, eviction/refill/flush control; internal types vary by pinned source."),
         iface("TAG", "Tag lookup and BIST", "handshake", "hit/miss -> tag store", "Lookup/store/flush/BIST commands and tag/dirty/way status."),
         iface("HIT", "Hit data access", "handshake", "hit/miss -> read/write units", "Hit descriptor and data-way request/response routing."),
         iface("MISS", "Miss pipeline", "handshake", "hit/miss -> eviction/refill", "Ordered miss descriptors, victim selection, dirty writeback and line refill."),
         iface("DATA", "LLC data-way service", "handshake", "read/write units -> data ways", "Way, line index, block offset, write enable, data, strobe and response."),
         iface("EVICT", "Memory refill/writeback", "standard protocol", "LLC -> memory profile", "AXI4 master traffic for dirty eviction and line refill."),
         iface("FLUSH", "LLC flush service", "handshake", "AXI4-Lite service -> LLC control", "Status/configuration and flush requests; exact service fields follow pinned axi_llc wrapper."),
         iface("SLV", "LLC AXI4 slave path", "standard protocol", "coherence fabric -> LLC", "AXI4 AW/W/B/AR/R; request boundary is defined in Section 6."),
         iface("MEM", "LLC memory egress", "standard protocol", "LLC -> memory profile", "AXI4 master data path; CFG-ACE conversion/ordering remains an integration dependency."),
         iface("SVC", "LLC AXI4-Lite service", "standard protocol", "SoC -> LLC service target", "AXI4-Lite service port routed by the shared control decoder.")],
        "PULP documentation describes the listed functional units. Exact module hierarchy, storage macro binding and top wrapper must be pinned; total capacity remains the user-approved static 256-KiB baseline."
    ))
    pages.append(page(
        "04_CONTROL", "Control and CSR routing", "m_vlsit_riscv_axil_decode",
        [
            blk("mux", "u_axi_lite_demux", "axi_lite_demux", "REUSE candidate | PULP AXI",
                "Routes the one external AXI4-Lite subordinate port to the cluster CSR and LLC service targets.", 1, 0, 300),
            blk("decode", "u_vlsit_riscv_axil_decode", "m_vlsit_riscv_axil_decode", "NEW | VLSIT",
                "Implements the approved local address windows, transaction response association and unmapped/misaligned error policy.", 1, 1, 340),
            blk("csr", "u_vlsit_cpucl_csr", "m_vlsit_cpucl_csr", "GENERATED | CSR_Generation.py v3.4 (commit c40f319)",
                "Provides software-visible cluster CSR fields generated from the project AXI4-Lite workbook.", 0, 2, 320),
            blk("llc_cfg", "u_axi_llc_cfg", "axi_llc_config wrapper", "MODIFY | PULP axi_llc wrapper policy",
                "Provides LLC BIST, flush and status service; runtime SPM writes must be blocked or tied off by the VLSIT integration.", 2, 2, 340),
            blk("pmu", "u_vlsit_riscv_pmu", "m_vlsit_riscv_pmu", "NEW | VLSIT",
                "Consumes CSR selectors/control and exports snapshot, status, overflow causes and the aggregate PMU interrupt.", 1, 3, 320),
        ],
        [edge("AXIL", "mux", "R", "decode", "L"),
         edge("CSR", "decode", "T", "csr", "B"),
         edge("LLCSVC", "decode", "B", "llc_cfg", "T"),
         edge("PMCFG", "csr", "R", "pmu", "L")],
        [ext("AXIL", "mux", "L", "in", 0, ["AXIL", "32-bit AXI4-Lite control port"]),
         ext("IRQ", "pmu", "B", "out", 0, ["IRQ", "Aggregate PMU interrupt"])],
        [iface("AXIL", "AXI4-Lite control subordinate", "standard protocol", "SoC manager -> control router", "32-bit address/data, four byte strobes and AW/W/B/AR/R channels."),
         iface("CSR", "Cluster CSR access", "custom", "decoder -> generated CSR", "AXI-Lite register write/read operations and generated register fields."),
         iface("LLCSVC", "LLC service window", "standard protocol", "decoder -> LLC service", "AXI4-Lite service transactions; address map remains workbook/integration controlled."),
         iface("PMCFG", "PMU configuration/status", "custom", "CSR -> PMU", "Event ID, scope, counter enable, snapshot command and cause/status fields; exact offsets are workbook-owned."),
         iface("IRQ", "Aggregate PMU interrupt", "custom", "PMU -> SoC interrupt controller", "One level interrupt asserted while an enabled sticky cause remains pending.")],
        "The selected CSR generator version and AXI4-Lite protocol are requirements. The workbook, offsets, reset values and LLC window base remain open until the workbook is reviewed."
    ))
    pages.append(page(
        "05_PMU", "Cluster PMU internals", "m_vlsit_riscv_pmu",
        [
            blk("hart_evt", "u_vlsit_pmu_hart_evt", "m_vlsit_pmu_hart_evt", "NEW | VLSIT",
                "Collects the implemented per-hart event vectors and retains source-hart identity.", 1, 0, 320),
            blk("cluster_evt", "u_vlsit_pmu_cluster_evt", "m_vlsit_pmu_cluster_evt", "NEW | VLSIT",
                "Collects cluster-global event sources such as LLC and fabric events without inventing per-hart attribution.", 0, 1, 340),
            blk("select", "u_vlsit_pmu_event_select", "m_vlsit_pmu_event_select", "NEW | VLSIT",
                "Selects a programmed event and applies scope 0–3 hart, 4 aggregate, or 5 cluster-global.", 1, 2, 340),
            blk("sum", "u_vlsit_pmu_aggregate", "m_vlsit_pmu_aggregate", "NEW | VLSIT",
                "Adds simultaneous per-hart occurrences; four matching hart events in one cycle increment by four.", 0, 3, 340),
            blk("count", "u_vlsit_pmu_counter_bank", "m_vlsit_pmu_counter_bank", "NEW | VLSIT",
                "Implements PARA_PMU_COUNTER_NUM counters, modulo-2^W wrap, event selection and enable state.", 1, 4, 340),
            blk("snap", "u_vlsit_pmu_snapshot", "m_vlsit_pmu_snapshot", "NEW | VLSIT",
                "Captures a coherent read image on the software snapshot command and holds it for low/high reads.", 0, 5, 340),
            blk("irq", "u_vlsit_pmu_irq", "m_vlsit_pmu_irq", "NEW | VLSIT",
                "Latches enabled overflow causes and drives one aggregate level interrupt until software clears causes.", 1, 6, 340),
        ],
        [edge("HEVT", "hart_evt", "R", "select", "L"),
         edge("GEVT", "cluster_evt", "R", "sum", "L"),
         edge("SEL", "select", "B", "sum", "T"),
         edge("INC", "sum", "B", "count", "T"),
         edge("SNAP", "count", "B", "snap", "T"),
         edge("OVF", "count", "L", "irq", "R")],
        [ext("CFG", "select", "R", "in", 0, ["CFG", "CSR control"]),
         ext("READ", "snap", "B", "out", 0, ["READ", "Stable counter snapshot image"]),
         ext("IRQ", "irq", "B", "out", 0, ["IRQ", "Aggregate PMU interrupt"])],
        [iface("HEVT", "Per-hart event vectors", "custom", "CVA6/cache -> hart event collector", "Candidate CVA6 performance counters and per-hart cache events; exact source availability and selector IDs are pending."),
         iface("GEVT", "Cluster-global event vectors", "custom", "CCU/LLC/fabric -> cluster event collector", "LLC/fabric/error events with cluster-global scope."),
         iface("SEL", "PMU selector output", "custom", "event selector -> occurrence aggregator", "One selected source and scope; no increment for reserved or unavailable sources."),
         iface("INC", "Event multiplicity", "custom", "aggregator -> counter bank", "Unsigned occurrence count per cycle; scope 4 sums active-hart events."),
         iface("SNAP", "Counter snapshot capture", "custom", "counter bank -> snapshot bank", "Atomic capture of configured counter values on accepted command."),
         iface("OVF", "Counter overflow status", "custom", "counter bank -> IRQ logic", "Overflow pulses are converted to sticky per-counter cause bits."),
         iface("CFG", "CSR PMU configuration", "custom", "generated CSR -> PMU", "Selector, scope, enable, snapshot and clear controls; workbook controls offsets."),
         iface("READ", "Stable PMU read image", "custom", "snapshot bank -> CSR read data", "Snapshot values remain stable until the next accepted snapshot or reset."),
         iface("IRQ", "Aggregate PMU interrupt", "custom", "PMU -> SoC interrupt controller", "Single level output follows enabled pending sticky causes.")],
        "The source event dictionary and exact CVA6 performance-event wire mapping remain open. The diagram does not claim that all listed candidate events exist in the selected CVA6 revision."
    ))
    pages.append(page(
        "06_DEBUG", "Per-hart debug routing", "m_vlsit_riscv_debug_router",
        [
            blk("dm", "u_vlsit_riscv_debug_router", "m_vlsit_riscv_debug_router", "NEW | VLSIT",
                "Routes external Debug Module requests to the selected active hart and returns per-hart debug state without embedding DTM/DM.", 1, 1, 360),
            blk("tiles", "u_vlsit_riscv_cpu_tile_0.._3", "m_vlsit_riscv_cpu_tile", "NEW | VLSIT",
                "Elaborates only indices 0 through PARA_CPU_NUM-1; each tile contains the licensed modified CVA6 integration shell and HPDcache coherence copy.", 0, 2, 400),
        ],
        [edge("HDBG", "dm", "B", "tiles", "T")],
        [ext("DBG", "dm", "L", "in", 0, ["DBG", "Debug Module"]),
         ext("CLKR", "dm", "R", "in", 0, ["CLKR", "Clock/reset"])],
        [iface("DBG", "External Debug Module connection", "custom", "External Debug Module -> router -> active harts", "Per-hart request and mode/status semantics are specified at the cluster boundary; exact CVA6 native debug handshake must be pinned."),
         iface("HDBG", "Native per-hart debug connections", "custom", "debug router -> CVA6 tiles", "Each bit/lane maps to a zero-based hart; absent hart lanes are ignored in a two-hart build."),
         iface("CLKR", "Cluster clock/reset", "custom", "SoC -> router and tiles", "All shown blocks use the selected cluster clock/reset; reset release is synchronized by the SoC.")],
        "DTM and Debug Module remain outside the cluster. CVA6's debug interface is reused; the per-hart array routing wrapper is new VLSIT logic."
    ))
    pages.append(page(
        "07_ACE", "ACE external coherence boundary", "m_vlsit_riscv_ace_proxy",
        [
            blk("llc", "u_vlsit_axi_llc", "m_vlsit_axi_llc", "MODIFY | PULP axi_llc",
                "Supplies shared-cache requests and memory traffic; the ACE profile must define how LLC AXI traffic participates in external coherence.", 1, 0, 340),
            blk("proxy", "u_vlsit_riscv_ace_proxy", "m_vlsit_riscv_ace_proxy", "NEW | VLSIT",
                "Bridges external ACE transactions and inward snoops to the local coherence domain; response, data and ordering policy must be fixed before RTL.", 1, 1, 360),
            blk("probe", "u_vlsit_riscv_ace_probe_router", "m_vlsit_riscv_ace_probe_router", "NEW | VLSIT",
                "Fans out snoop work to active local caches and collects clean/dirty responses and data for the proxy.", 0, 2, 360),
            blk("coh", "u_vlsit_riscv_coh_fabric", "m_vlsit_riscv_coh_fabric", "MODIFY | Culsans candidate",
                "Owns local multi-hart coherence and must expose a complete local-probe transaction contract to the ACE adapter.", 1, 3, 360),
        ],
        [edge("MEM", "llc", "R", "proxy", "L"),
         edge("PROBE", "proxy", "R", "probe", "L"),
         edge("LOCAL", "probe", "R", "coh", "L")],
        [ext("ACE", "proxy", "R", "out", 0, ["ACE"]),
         ext("LLC", "llc", "L", "in", 0, ["LLC", "Shared LLC request boundary"]),
         ext("CLKR", "llc", "T", "in", 0, ["CLKR", "Clock/reset"])],
        [iface("MEM", "LLC to ACE profile adapter", "custom", "LLC <-> ACE proxy", "Mapping between LLC AXI master traffic and external coherent ACE transactions is an open design decision; no pass-through equivalence is assumed."),
         iface("PROBE", "External snoop service", "standard protocol", "ACE proxy -> local probe router", "ACE AC requests are translated to local probes; CR/CD responses and acknowledge semantics follow the chosen supported ACE subset."),
         iface("LOCAL", "Local cache probe service", "custom", "probe router -> coherence fabric", "Probe request, per-hart response and dirty-line data; fields and timing must be defined from the pinned cache/CCU ports."),
         iface("ACE", "External full ACE boundary", "standard protocol", "cluster -> ACE-capable SoC fabric", "Fixed ACE port set is listed in Section 6; supported transaction subset and outstanding limits remain DEP-002."),
         iface("LLC", "Shared LLC boundary", "custom", "coherence fabric -> LLC", "AXI4 cache request and response service."),
         iface("CLKR", "Cluster clock/reset", "custom", "SoC -> cluster", "Synchronized reset deassertion is owned by the SoC.")],
        "PULP ace_ccu_top is a reuse candidate documented as an ACE interconnector, not a proven drop-in for the selected Culsans/HPDcache configuration. Keep the VLSIT proxy classified NEW until interface and behavior compatibility is demonstrated."
    ))
    # Arrange each detail page as a compact grid instead of a long RTL chain.
    # This keeps the frame readable at normal zoom and within the VLSIT 3:1 limit.
    grids = {
        "01_TILE": {"core": (0, 0), "subsys": (0, 1), "hpdwrap": (0, 2),
                    "icache": (1, 1), "hpd": (1, 2), "tile_adapt": (2, 2)},
        "02_COHERENCE": {"tile": (0, 0), "ccu": (0, 1), "directory": (0, 2),
                         "txn": (1, 1), "probe": (1, 2), "dev_class": (2, 0),
                         "mux": (2, 1), "demux": (2, 2), "mmio": (3, 2)},
        "03_LLC": {"tags": (0, 1), "split": (1, 0), "hm": (1, 1), "miss": (1, 2),
                   "cfg": (2, 0), "rw": (2, 1), "ways": (2, 2)},
        "04_CONTROL": {"mux": (0, 0), "decode": (0, 1), "csr": (0, 2),
                       "llc_cfg": (1, 1), "pmu": (1, 2)},
        "05_PMU": {"hart_evt": (0, 0), "select": (0, 1), "cluster_evt": (1, 0),
                   "sum": (1, 1), "count": (2, 1), "snap": (3, 1), "irq": (2, 0)},
        "06_DEBUG": {"dm": (0, 0), "tiles": (1, 0)},
        "07_ACE": {"llc": (0, 0), "proxy": (0, 1), "probe": (1, 1), "coh": (1, 0)},
    }
    for spec in pages:
        coords = grids[spec["page_name"]]
        for block in spec["blocks"]:
            block["row"], block["col"] = coords[block["key"]]
    return pages


def write_analysis(pages):
    lines = [
        "# RISC-V cluster detail-diagram analysis / Phân tích sơ đồ chi tiết cluster RISC-V", "",
        "## Scope and evidence / Phạm vi và căn cứ", "",
        "These pages expand the approved cluster specification by one architectural level. No RTL was inspected or claimed as implemented. Names and hierarchy are design proposals; upstream candidates require pinned commits and interface checks.",
        "Các trang mở rộng đặc tả cluster thêm một cấp kiến trúc. Chưa phân tích hay khẳng định RTL đã được triển khai. Tên và hierarchy là đề xuất; nguồn upstream cần chốt commit và kiểm tra giao diện.", "",
        "The diagrams show defined logical interfaces only. Internal pin names, widths, timing, and ACE subsets remain open where the HDS marks them TBD. Dashed blocks mean proposed, not integrated RTL.",
        "Sơ đồ chỉ thể hiện giao diện logic đã xác định. Tên pin, độ rộng, timing nội bộ và subset ACE vẫn để mở ở nơi HDS đánh dấu TBD. Khối nét đứt là đề xuất, chưa phải RTL tích hợp.", "",
        "## Status key / Chú giải trạng thái", "",
        "| Status | Meaning / Nghĩa |", "|---|---|",
        "| REUSE | Unchanged upstream RTL after source, config, and license checks. / Dùng RTL upstream nguyên trạng sau khi kiểm tra nguồn, cấu hình và license. |",
        "| REUSE* | Candidate pending compatibility checks. / Khối dự kiến tái sử dụng, chờ kiểm tra tương thích. |",
        "| MODIFY | Adapt upstream logic, add a wrapper, or bind ASIC memory. / Điều chỉnh logic upstream, viết wrapper hoặc gắn SRAM ASIC. |",
        "| NEW | New VLSIT-owned RTL. / RTL mới do VLSIT thiết kế. |",
        "| GENERATED | CSR RTL from the reviewed workbook and pinned generator. / RTL CSR sinh từ workbook đã duyệt và generator đã chốt. |",
        "| EXTERNAL | Logic supplied outside the cluster by the SoC. / Logic do SoC cung cấp bên ngoài cluster. |", "",
        "## Page inventory / Danh sách sơ đồ", "",
        "| Page | Parent block / Khối cha | Detail / Nội dung |", "|---|---|---|"]
    for spec in pages:
        lines.append(f"| {spec['page_name']} | {spec['top']['frame_label'][1].strip('()')} | {spec['top']['frame_label'][0]} |")
    lines += ["", "## Block inventory / Danh sách khối", "", "| Page | Planned instance / Instance dự kiến | Source module / Module nguồn | Status/source / Trạng thái/nguồn | Function description / Mô tả chức năng |", "|---|---|---|---|---|"]
    for spec in pages:
        for b in spec["blocks"]:
            lines.append(f"| {spec['page_name']} | {b['label'][0]} | {b['label'][1].strip('()')} | {b['source']} | See HDS Section 14.4 (English/Vietnamese). / Xem Mục 14.4 HDS (Anh/Việt). |")
    lines += ["", "## Interface evidence / Căn cứ giao diện", "",
              "The draw.io interface tables group design-level paths. External AXI/ACE ports are defined in HDS Section 6; internal ports and timing are not yet tied to pinned RTL. ACE policy, LLC-to-ACE mapping, Culsans compatibility, and SRAM binding remain open.",
              "Bảng giao diện draw.io nhóm các đường logic theo thiết kế. Port AXI/ACE bên ngoài nằm ở Mục 6 HDS; port và timing nội bộ chưa gắn với RTL đã chốt. Chính sách ACE, ánh xạ LLC–ACE, tương thích Culsans và gắn SRAM vẫn còn mở.", "",
              "## Source and integration limits / Nguồn và giới hạn tích hợp", "",
              "- OpenHW CVA6/HPDcache are reuse baselines; audit exact files and licenses at pinned revisions. / CVA6/HPDcache OpenHW là baseline tái sử dụng; kiểm tra file và license ở revision đã chốt.",
              "- Culsans is an adaptation source, not proven compatible with this upstream CVA6 + HPDcache configuration. / Culsans là nguồn để điều chỉnh, chưa chứng minh tương thích với cấu hình CVA6 + HPDcache upstream này.",
              "- PULP axi_llc functions are reuse candidates; VLSIT fixes policy/geometry and binds ASIC SRAM. / Chức năng `axi_llc` PULP là ứng viên tái sử dụng; VLSIT chốt chính sách/geometry và gắn SRAM ASIC.",
              "- PULP AXI/ACE primitives require version, ID, topology, and feature checks before reuse. / Primitive AXI/ACE PULP cần kiểm tra version, ID, topology và tính năng trước khi dùng.",
              "- Cluster tops, adapters, PMU, and debug routing are VLSIT-owned design work. / Top, adapter, PMU và định tuyến debug là phần VLSIT cần thiết kế.",
              "- CSR RTL is generated; the reviewed workbook defines software-visible fields. / RTL CSR được sinh; workbook đã duyệt định nghĩa các trường software nhìn thấy.", "",
              "## Diagram validation / Kiểm tra sơ đồ", "",
              "The library check verifies template provenance; the geometry checker verifies placement and routing constraints. Neither proves RTL existence, protocol compliance, or functional correctness. / Kiểm tra thư viện xác nhận nguồn template; geometry checker kiểm tra bố trí và đường nối. Cả hai không chứng minh RTL tồn tại, tuân thủ protocol hay đúng chức năng.", ""]
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / "vlsit_rtl_analysis.md").write_text("\n".join(lines), encoding="utf-8")
    for spec in pages:
        name = spec["page_name"].lower() + "_spec.json"
        (OUT / name).write_text(json.dumps(spec, indent=2), encoding="utf-8")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--analyze-only", action="store_true")
    args = parser.parse_args()
    for path in (LIBRARY, GENERATOR, VALIDATOR, GEOMETRY, HDS):
        if not path.is_file():
            raise FileNotFoundError(path)
    pages = specifications()
    write_analysis(pages)
    if args.analyze_only:
        print("Analysis and diagram specs written before drawing.")
        return 0
    module_spec = importlib.util.spec_from_file_location("vlsit_frame", GENERATOR)
    module = importlib.util.module_from_spec(module_spec)
    module_spec.loader.exec_module(module)
    combined = ET.Element("mxfile", {"host": "app.diagrams.net", "agent": "VLSIT cluster detail architecture", "version": "24.7.17", "compressed": "false"})
    reports = []
    for spec in pages:
        page_out = OUT / spec["page_name"].lower()
        page_out.mkdir(parents=True, exist_ok=True)
        gen = module.Generator(spec, spec["layout"]["gap_h"], spec["layout"]["gap_v"], seed=2)
        gen.run(str(page_out), False)
        report_text = "\n".join(gen.report)
        score = gen.score(gen.p, 0, [])
        if "FAILED" in report_text or "NOT PLACED" in report_text:
            raise RuntimeError(f"Unresolved route/label in {spec['page_name']}: {report_text}")
        source_drawio = page_out / "vlsit_rtl_hierarchy.drawio"
        tree = ET.parse(source_drawio)
        root = tree.getroot()
        # The upstream layout engine places some orthogonal connector endpoints
        # a few pixels inside the source symbol. Move only those endpoints just
        # outside their owning cell so the diagram remains visually connected
        # without the geometry checker counting the endpoint as a shape crossing.
        cell_by_id = {c.get("id"): c for c in root.iter("mxCell")}
        boxes = {}
        for cell in cell_by_id.values():
            geo = cell.find("mxGeometry")
            if geo is None or geo.get("width") is None:
                continue
            boxes[cell.get("id")] = tuple(float(geo.get(k, 0)) for k in ("x", "y", "width", "height"))
        for cell in cell_by_id.values():
            if cell.get("edge") != "1":
                continue
            geo = cell.find("mxGeometry")
            for point_name, ref_name in (("sourcePoint", "source"), ("targetPoint", "target")):
                point = geo.find(f"mxPoint[@as='{point_name}']") if geo is not None else None
                box = boxes.get(cell.get(ref_name))
                if point is None or box is None:
                    continue
                px, py = float(point.get("x")), float(point.get("y"))
                x, y, w, h = box
                if x < px < x + w and y < py < y + h:
                    distances = [(px - x, "L"), (x + w - px, "R"),
                                 (py - y, "T"), (y + h - py, "B")]
                    side = min(distances)[1]
                    if side == "L":
                        px = x - 4
                    elif side == "R":
                        px = x + w + 4
                    elif side == "T":
                        py = y - 4
                    else:
                        py = y + h + 4
                    point.set("x", str(px))
                    point.set("y", str(py))
        # Keep long note labels within the generated page bounds on narrow pages.
        model_root = root.find(".//mxGraphModel")
        page_width = float(model_root.get("pageWidth", "0")) if model_root is not None else 0
        for cell in cell_by_id.values():
            if cell.get("vlsit_library_entry") != "0":
                continue
            geo = cell.find("mxGeometry")
            if geo is None or geo.get("width") is None:
                continue
            x, width = float(geo.get("x", 0)), float(geo.get("width", 0))
            if x + width > page_width - 10:
                geo.set("width", str(max(80, page_width - x - 15)))
        for cell in root.iter("mxCell"):
            if cell.get("vlsit_library_entry") == "32":
                cell.set("style", cell.get("style", "") + "dashed=1;")
        page_node = root.find("diagram")
        page_node.set("id", spec["page_name"])
        page_node.set("name", spec["page_name"])
        individual = OUT / f"VLSIT_RISCV_CLUSTER_DETAIL_{spec['page_name']}.drawio"
        tree.write(individual, encoding="utf-8", xml_declaration=True)
        combined.append(copy.deepcopy(page_node))
        reports.append(f"{spec['page_name']}: {score}")
    combined_path = OUT / "VLSIT_RISCV_CLUSTER_DETAIL_LEVEL2.drawio"
    ET.ElementTree(combined).write(combined_path, encoding="utf-8", xml_declaration=True)
    checks = []
    for command in ([sys.executable, str(VALIDATOR), "validate", "--diagram", str(combined_path)],
                    [sys.executable, str(GEOMETRY), str(combined_path), "--allow-shared-start"]):
        result = subprocess.run(command, capture_output=True, text=True)
        checks.append(result.stdout + result.stderr)
        if result.returncode:
            (OUT / "validation_report.txt").write_text("\n".join(checks), encoding="utf-8")
            raise RuntimeError("Combined diagram validation failed; inspect validation_report.txt")
    (OUT / "validation_report.txt").write_text("\n".join(reports + checks), encoding="utf-8")
    with (OUT / "vlsit_rtl_analysis.md").open("a", encoding="utf-8") as handle:
        handle.write("\n## Automated validation results / Kết quả kiểm tra tự động\n\nTool output (English): / Kết quả tool (tiếng Anh):\n\n```text\n" + "\n".join(reports + checks) + "\n```\n")
    print(f"Built {len(pages)} detail pages in {combined_path}")
    print("Validation results:", OUT / "validation_report.txt")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
