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
from project_layout import loads_legacy
import re
import subprocess
import sys
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'doc/specification/figures/detail_level2'
SKILL = Path(r"C:\Users\PC\.codex\skills\vlsit-rtl-hierarchy-diagram")
LIBRARY = SKILL / "assets" / "VLSIT_DRAWIO_LIB_V1.drawio.xml"
GENERATOR = SKILL / "scripts" / "vlsit_drawio_frame_diagram.py"
VALIDATOR = SKILL / "scripts" / "vlsit_library_symbols.py"
GEOMETRY = SKILL / "scripts" / "vlsit_drawio_geometry_check.py"
HDS = ROOT / 'doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md'


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


def post_a06_main():
    """Build current, source-grounded component documentation without editing RTL.

    The legacy proposal diagrams remain unchanged. This mode uses the installed
    micro-specification builders and new output names for the current contracts.
    """
    parser = argparse.ArgumentParser()
    parser.add_argument('--post-a06', choices=('prepare', 'draw', 'render-fsm', 'assemble', 'check'), required=True)
    parser.add_argument('--only', default='')
    args = parser.parse_args()
    import math
    import html
    micro = Path(r'C:\Users\PC\.codex\skills\vlsit-asic-ip-microspec')
    base = ROOT / 'doc/specification'
    target = base / 'doc/architecture_figures/post_a06'
    target.mkdir(parents=True, exist_ok=True)
    catalog = json.loads((base / 'post_a06_components.json').read_text())
    audit = loads_legacy((ROOT / 'verification/non_coherence_cluster/reports/post_a06_cluster_audit/audit.json').read_text())
    contracts = json.loads((base / 'post_a06_fsm_contracts.json').read_text())
    full_ccu=next(c for c in contracts if c['id']=='CCU_CONTEXT')
    ccu_views=[('CCU_LOOKUP_VICTIM','ENUM_ST_IDLE',[0,1,2,3,4,5,6,7,8,9,10,11,29,30,32]),
               ('CCU_PREPARE_CMO','ENUM_ST_PREP_START',[12,13,14,15,16,17,18]),
               ('CCU_COMMIT_RELEASE','ENUM_ST_COMMIT_START',[19,20,21,22,23,29,30,31,32,33]),
               ('CCU_ABORT_RELEASE','ENUM_ST_ABORT_START',[24,25,26,27,28,30,31,32,33])]
    for view,entry,indices in ccu_views:
        transitions=[full_ccu['transitions'][i] for i in indices]
        states=sorted({n for s,d,_ in transitions for n in (s,d)})
        contracts.append(dict(id=view,module=full_ccu['module'],initial=entry,states=states,transitions=transitions,
                              view_of='CCU_CONTEXT',transition_ids=indices,
                              description='Readable phase view of the same per-context CCU FSM, not an additional controller. Entry is '+entry+'. The underlying reset is ENUM_ST_IDLE; omitted transitions continue in the other views/full graph. Original T numbers preserve full-graph identity.'))
    paths = sorted(set(audit['source_inventory']) | {
        p.relative_to(ROOT).as_posix() for p in (ROOT / 'rtl/common/modified').rglob('*.sv')})
    inventory = {}
    module_bodies = {}
    sources = {}

    def strip_comments(text):
        return re.sub(r'("(?:\\.|[^"\\])*")|(/\*.*?\*/|//[^\r\n]*)',
                      lambda m: m[1] or '', text, flags=re.S)

    def balanced(text, start):
        depth = 0
        for pos in range(start, len(text)):
            if text[pos] == '(':
                depth += 1
            elif text[pos] == ')':
                depth -= 1
                if depth == 0:
                    return text[start+1:pos], pos+1
        raise ValueError('Unbalanced module header')

    def ports(text, match):
        pos = match.end()
        # Native CVA6 modules may import packages between name and #(...).
        while pos < len(text) and text[pos].isspace():
            pos += 1
        while text[pos:pos+6] == 'import':
            pos = text.index(';', pos)+1
            while text[pos].isspace(): pos += 1
        if text[pos:pos+1] == '#':
            pos = text.index('(', pos)
            _, pos = balanced(text, pos)
            while text[pos].isspace(): pos += 1
        if text[pos:pos+1] != '(':
            return []
        body, _ = balanced(text, pos)
        chunks=[]
        start=0
        depth=0
        for idx,char in enumerate(body):
            if char in '([{': depth+=1
            elif char in ')]}': depth-=1
            elif char==',' and depth==0:
                chunks.append(body[start:idx]);start=idx+1
        chunks.append(body[start:])
        result = []
        inherited_direction=None
        for chunk in chunks:
            chunk = ' '.join(chunk.split()).rstrip(',')
            m = re.match(r'(input|output|inout)\s+(.+)', chunk)
            if not m:
                interface=re.match(r'(\w+\.\w+)\s+(\w+)$',chunk)
                if interface:
                    result.append(dict(direction='interface modport',declaration=chunk,names=[interface[2]]))
                    inherited_direction=None
                elif inherited_direction and re.fullmatch(r'\w+(?:\s*\[[^]]+\])*',chunk):
                    result.append(dict(direction=inherited_direction,declaration=chunk,names=[chunk.split('[')[0].strip()]))
                continue
            # The native source has occasional multi-name declarations; retain
            # their exact declaration instead of inventing a flattened width.
            names = re.findall(r'\b([A-Za-z_]\w*)\s*(?:\[[^]]+\])?\s*(?:,|$)', m[2])
            result.append(dict(direction=m[1], declaration=m[2], names=names))
            inherited_direction=m[1]
        return result

    for name in paths:
        raw = (ROOT / name).read_text(encoding='utf-8', errors='replace')
        text = strip_comments(raw)
        sources[name] = dict(raw=raw, text=text, selected=name in audit['source_inventory'])
        for match in re.finditer(r'(?m)^\s*module\s+(\w+)\b', text):
            module = match[1]
            # An unselected alternate copy never overrides an active source.
            if module in inventory and not sources[name]['selected']:
                continue
            inventory[module] = dict(path=name, ports=ports(text, match),
                                     selected=sources[name]['selected'])
            end=re.search(r'(?m)^\s*endmodule\b',text[match.end():])
            module_bodies[module]=text[match.start():match.end()+end.end()] if end else text[match.start():]

    # Every VLSIT block in the active source set receives an authored contract.
    active_vlsit = {m for m, item in inventory.items() if item['selected'] and item['path'].startswith('rtl/common/vlsit')}
    missing = active_vlsit - catalog.keys()
    if missing:
        raise ValueError('Missing authored component contract: '+str(sorted(missing)))

    native_roles = {
        'commit_stage': ('Precise retirement and completion', 'Hold accepted CBO/FENCE.I until terminal completion. Retain PC/address/error provenance, defer interrupt/debug admission while maintenance is active, retire only on success and trap after ABORT on failure.'),
        'controller': ('Pipeline flush and fence coordination', 'Coordinate fetch/pipeline invalidation with retained maintenance completion so an accepted CBO/FENCE.I cannot be lost by ordinary flush/interrupt/debug control.'),
        'csr_regfile': ('Privilege, delegation and trap state', 'Route precise maintenance and atomic errors to the correct M/S trap state. Preserve the custom FENCE.I cause-24 and aligned physical fault-value contract; software support is a SoC dependency.'),
        'store_buffer': ('Retained committed store/CBO queue', 'Retain effective VA, physical line, operation and completion association. An externally completed CBO dequeues once without issuing a duplicate local maintenance operation.'),
        'store_unit': ('Store translation and CBO metadata', 'Carry decoded maintenance kind and effective address through the native store path to its retained queue/retirement interface; preserve precise errors.'),
        'load_unit': ('Load/atomic completion and fault path', 'Preserve cached atomic/load response error provenance and destination association while the CCU-owned request is stalled or completed.'),
        'load_store_unit': ('LSU maintenance and atomic integration', 'Connect the selected external-maintenance mode and native store/load/translation state to the retained retirement service and cache hierarchy.'),
        'cva6': ('Native CPU integration boundary', 'Connect boot/IRQ/debug, retained maintenance command/completion, trap state, source event taps and cache-coherence query/probe/flush status without replacing the CPU architecture.'),
        'cva6_hpdcache_wrapper': ('Native HPDcache and probe integration', 'Integrate the new tagged HPDcache probe endpoint with native metadata lookup/update, flush ACK, cache busy query and ownership request/grant channels.'),
        'cva6_hpdcache_subsystem': ('Cache subsystem integration', 'Carry native instruction/data traffic, events, cache flush origins and the retained external maintenance path through the selected HPDcache write-back configuration.'),
        'cva6_hpdcache_if_adapter': ('CPU-to-cache request adaptation', 'Preserve request identity, ownership needs and atomic/CMO error response association across the native CPU/cache adapter.'),
        'cva6_hpdcache_subsystem_axi_arbiter': ('Cache AXI source arbitration', 'Arbitrate instruction/data/cache sources and retain source ID association for B/R; report native writeback status to the proper flush origin.'),
        'hpdcache': ('Native D-cache composition', 'Route shared-line busy/lock queries, tagged metadata probe operations, permission-before-refill, origin-tagged writeback completion and source events through the cache hierarchy.'),
        'hpdcache_ctrl': ('Cache array resource arbitration', 'Arbitrate CPU/replay/refill/probe/flush/ECC resources; block only admissions that conflict with required resources, drain admitted work and protect the first probe writeback SRAM capture.'),
        'hpdcache_ctrl_pe': ('Hit/eviction pipeline execution', 'Maintain exclusive/dirty metadata and silent E-to-M consistency. Do not allocate a replacement or overwrite a dirty victim until its writeback B succeeds; retain failed context/data until reset.'),
        'hpdcache_memctrl': ('Tag/data array ownership', 'Expose read-only tagged lookup and COMMIT-only metadata update, retain dirty/exclusive state and arbitrate native tag/data access without collision.'),
        'hpdcache_miss_handler': ('Ownership-gated miss and refill', 'Obtain CCU permission before issuing the refill. Retain request/grant state, return denied ownership as a precise error, and avoid installing valid/exclusive data after a failed refill.'),
        'hpdcache_mshr': ('Outstanding miss identity and busy queries', 'Track active physical miss lines and preserve request identity through refill/error completion so a probe of the same line waits safely.'),
        'hpdcache_rtab': ('Replay and blocked-request lifetime', 'Retain replay association and avoid reissuing a dependent request while ownership/line locks or failed ordinary eviction hold the cache controller.'),
        'hpdcache_flush': ('Origin-tagged dirty writeback completion', 'Keep flush descriptors through accepted B, preserve native origin/line/ID/status and report success only for matching B=OKAY. Invalid responses are diagnostic; fatal ordinary errors retain recoverable state.'),
        'axi_llc_top': ('Shared LLC orchestration and maintenance ingress', 'Capture one per-line maintenance descriptor, coordinate native queue service, defer destructive tag actions until writeback success and forward matched fatal metadata.'),
        'axi_llc_reg_wrap': ('Native LLC software wrapper', 'Connect RegBus configuration and native AXI/maintenance/status/error/fatal-record fields without changing the external cluster to APB.'),
        'axi_llc_tag_store': ('LLC tag/dirty publication', 'Keep dirty victim/tag association through pending writeback. Publish replacement/clean/invalidate only after successful completion; preserve the victim on error and guard pending full/wrap conditions.'),
        'axi_llc_hit_miss': ('LLC lookup and descriptor association', 'Carry the right victim tag/way/set/maintenance attributes from hit/miss detection into retained eviction/refill processing.'),
        'axi_llc_evict_unit': ('Eviction/refill transport completion', 'Retain descriptor and dirty-data obligations across native AXI responses; expose fatal ordinary-writeback and maintenance-specific completion/error separately.'),
        'axi_llc_w_master': ('LLC AXI writeback master', 'Retain the victim descriptor until accepted B. On failed non-maintenance B emit a pulse with actual victim tag plus set address and raw BRESP; do not report the replacement/refill address.'),
        'axi_llc_r_master': ('LLC refill read master', 'Preserve ID/data/last/error association across refill buffering and explicit width/selection fixes; a failed refill must not silently create a valid cache line.'),
        'axi_llc_config': ('Native BIST/whole-way flush control', 'Coordinate software configuration and native flush/BIST descriptors. The VLSIT service bridge blocks runtime SPM; full software-driven service verification remains open.'),
        'perf_counters': ('Native CPU event taps', 'Expose the existing native HPM source expressions for cluster observation. Preserve each indicator unit; OR-reduced per-hart categories are not arbitrary retirement popcounts.'),
        'fpu_wrap': ('FPU pipeline and issue/response wrapper', 'Separate state-derived valid/payload selection from ready-dependent control to remove a combinational feedback path without adding latency or changing arithmetic.'),
        'fpnew_opgroup_block': ('Native FPU operation-group routing', 'Drive merged-format readiness from the scalar slice result rather than reading a packed ready vector while driving it; preserve format selection, payload and configured latency.')
    }

    def history(name):
        raw = sources[name]['raw']
        lines = raw.splitlines()
        result = []
        for idx, line in enumerate(lines[:210]):
            if re.search(r'2026-\d\d-\d\d', line) and ('Quan' in line or 'Codex' in line):
                block = []
                for following in lines[idx+1:idx+7]:
                    if re.search(r'2026-\d\d-\d\d|\bmodule\b|\bpackage\b', following): break
                    value = re.sub(r'^\s*(?://|/\*|\*)?\s*', '', following).strip(' */')
                    if value: block.append(value)
                if block: result.append(' '.join(block))
        return result

    module_reference = re.compile(r'\b('+'|'.join(re.escape(m) for m in sorted(inventory,key=len,reverse=True))+r')\b\s*(?:#\s*\(|([A-Za-z_]\w*)\s*\()')
    member_cache = {}
    def members(module):
        if module in member_cache:
            return member_cache[module]
        text = module_bodies[module]
        result = []
        for match in module_reference.finditer(text):
            child = match[1]
            if child == module: continue
            # Source references are only used for composition, not connectivity.
            instance = match[2]
            if not instance:
                opening = text.index('(', match.start())
                _, end = balanced(text, opening)
                tail = re.match(r'\s*(\w+)\s*\(', text[end:])
                if not tail: continue
                instance = tail[1]
            result.append((child, instance))
        member_cache[module] = sorted(set(result))
        return member_cache[module]

    def classification(module):
        name = inventory[module]['path']
        if '/csr_generated/' in name: return 'GENERATED'
        if name.startswith('rtl/common/modified'): return 'MODIFY'
        if name.startswith('rtl/common/vlsit'): return 'NEW'
        return 'REUSE'

    def signal_list(module, direction):
        return ', '.join(n for p in inventory[module]['ports'] if p['direction']==direction for n in p['names']) or 'No ports in this group'

    def diagram(module):
        if module in ('CLUSTER_DATA_FLOW','CLUSTER_CMO_FLOW'):
            parent='m_vlsit_riscv_cluster_core'
            spec=diagram(parent)
            names=(['m_vlsit_riscv_cpu_tile_array','m_vlsit_riscv_axi_route','m_vlsit_axi_llc','m_vlsit_riscv_axi_mem_mux']
                   if module=='CLUSTER_DATA_FLOW' else ['m_vlsit_riscv_cpu_tile_array','m_vlsit_riscv_cmo_arbiter','m_vlsit_axi_llc','m_vlsit_riscv_cmo_controller'])
            chosen=[]
            for idx,name in enumerate(names):
                block=copy.deepcopy(next(b for b in spec['blocks'] if b['label'][1]=='('+name+')'))
                block.update(key='B'+str(idx),row=idx//2,col=idx%2)
                chosen.append(block)
            spec.update(out_name=module+'.drawio',blocks=chosen,connectors=[],interfaces=[],externals=[],frame_interfaces=[])
            spec['top']['frame_label']=[module.replace('_',' '),'('+parent+')']
            connections=([('CPU','B0','R','B1','L','w_tile_'),('ROUTE','B1','B','B3','T','w_route_mem_'),('LLC','B3','L','B2','R','w_llc_axi_')]
                         if module=='CLUSTER_DATA_FLOW' else [('CMD','B0','R','B1','L','w_cmo_'),('TAKE','B1','B','B3','T','w_cmo_'),('MAINT','B3','L','B2','R','w_maint_'),('CCU','B3','T','B0','B','w_ccu_')])
            text=sources[inventory[parent]['path']]['text']
            for key,src,side,dst,dside,prefix in connections:
                spec['connectors'].append(dict(id=key,src=src,src_side=side,dst=dst,dst_side=dside))
                signals=sorted(set(re.findall(r'\b'+re.escape(prefix)+r'\w+',text)))
                spec['interfaces'].append(dict(id=key,name=key+' request and response bundle',category='handshake',active=src+' -> '+dst,signals=', '.join(signals)))
            spec['legend_note']='Focused working-flow view of actual core child instances. Arrows indicate request initiation; completion/data responses return in the same bundle. Only the named path is shown: other core children remain in the full composition diagram. The route block represents the source generate replication across active harts. Complete qualifiers and ordering are in Sections 6.3 and 10.5.'
            return spec
        children = members(module)
        # A leaf has no child instances: display its single boundary symbol.
        leaf = not children
        shown = children if children else [(module, 'component_boundary')]
        if module == 'm_vlsit_riscv_cluster_axi_top':
            shown = sorted(shown, key=lambda item: item[0] != 'm_vlsit_riscv_cluster_core')
        blocks = []
        columns = 1 if len(shown) <= 2 else max(2,math.ceil(math.sqrt(len(shown)/2)))
        for idx, (child, instance) in enumerate(shown):
            label = [instance, '('+child+')']
            width = int(math.ceil(max(map(len,label))*9/.78/20)*20)
            blocks.append(dict(key=f'B{idx}', label=label, width=max(60,width), row=idx//columns, col=idx%columns,
                               row_name=instance+' ('+child+')',
                               function=(catalog.get(child,{}).get('function') or native_roles.get(child,('Native component','Source-defined native behavior'))[0]),
                               source=classification(child)+'; '+inventory[child]['path']))
        spec = dict(page_name='BLOCK_DIAGRAM',out_name=module+'.drawio',
                    layout=dict(gap_h=120,gap_v=110,margin=80,block_h=60),
                    top=dict(frame_label=['Component composition','('+module+')']),
                    frame_row=[module, catalog.get(module,{}).get('function','Native modified component; function and change contract are specified in Section 14.'), inventory[module]['path']],
                    frame_interfaces=[],blocks=blocks,connectors=[],externals=[],interfaces=[],nets=[],
                    legend_note=('Exact source-referenced children; generate multiplicity and active branches are specified in the component text. Containment denotes hierarchy, not invented signal connectivity. ' if not leaf else 'A single boundary symbol denotes a leaf: internal equations/registers are described in its function/dataflow contract, not invented child modules. ')+
                    'NEW/MODIFY/REUSE/GENERATED provenance is listed in the block table. Clock/reset follow the common synchronous contract. Complete parent port declarations are in the component section.')
        if leaf:
            for group,side,direction in [('IN','L','in'),('OUT','R','out')]:
                ports_in_group = signal_list(module,'input' if group=='IN' else 'output')
                if ports_in_group == 'No ports in this group': continue
                spec['frame_interfaces'].append(group)
                spec['externals'].append(dict(id=group,block='B0',side=side,dir=direction,pos=0,text=[group,'ports']))
                spec['interfaces'].append(dict(id=group,name='Parent '+group.lower()+' ports',category='custom',active=direction,signals=ports_in_group))
        # The real structural TOP has a known, source-checked data connection.
        if module == 'm_vlsit_riscv_cluster_axi_top':
            ids={child:f'B{idx}' for idx,(child,_) in enumerate(shown)}
            core=ids['m_vlsit_riscv_cluster_core']; adapter=ids['m_vlsit_riscv_axi_dw_adapter']
            spec['connectors']=[dict(id='AXI64',src=core,src_side='B',dst=adapter,dst_side='T')]
            spec['interfaces']=[dict(id='AXI64',name='Fixed 64-bit LLC memory interface',category='handshake',active='core -> adapter',signals=', '.join(re.findall(r'\b(w_axi_llc_\w+)\b',sources[inventory[module]['path']]['text'])[:45]))]
            for key,block,side,direction,pattern in [('AXIL',core,'L','in','axil'),('MMIO',core,'R','out','axi_mmio'),('MEM',adapter,'R','out','axi_mem')]:
                names=[n for p in inventory[module]['ports'] for n in p['names'] if pattern in n]
                spec['frame_interfaces'].append(key)
                spec['externals'].append(dict(id=key,block=block,side=side,dir=direction,pos=0,text=[key,'AXI']))
                spec['interfaces'].append(dict(id=key,name=key+' boundary',category='handshake',active=direction,signals=', '.join(names)))
            spec['legend_note']='Source-grounded structural TOP. AXI64 request/response bundle joins the core and width adapter; arrow denotes request initiator, responses return on the same bundle. Boot, IRQ/debug and common clock/reset are fully listed in Section 6 rather than duplicated as unconnected pads.'
        return spec

    selected_modified = sorted(n for n in sources if n.startswith('rtl/common/modified') and sources[n]['selected'])
    # All new/generated modules plus every selected modified module get a figure.
    figure_modules = sorted(set(catalog) | {m for m,item in inventory.items() if item['path'] in selected_modified})
    extra_figures=['CLUSTER_DATA_FLOW','CLUSTER_CMO_FLOW']
    def render_fsm_svg(name):
        """Preserve library ellipses and labels missing from the installed SVG renderer."""
        tree=ET.parse(target/(name+'.drawio'))
        machine=json.loads((target/(name+'.json')).read_text())
        state_ids={html.unescape(c.get('value','')):c.get('id') for c in tree.getroot().iter('mxCell') if c.get('vlsit_library_entry')=='13'}
        edge_cells=[c for c in tree.getroot().iter('mxCell') if c.get('edge')=='1']
        for cell,transition in zip(edge_cells,machine['transitions']):
            cell.set('source',state_ids[transition['src']]);cell.set('target',state_ids[transition['dst']])
        tree.write(target/(name+'.drawio'),encoding='utf-8',xml_declaration=True)
        states=[];edges=[]
        for cell in tree.getroot().iter('mxCell'):
            geo=cell.find('mxGeometry')
            if geo is None: continue
            value=html.unescape(cell.get('value',''))
            if cell.get('vertex')=='1' and cell.get('vlsit_library_entry')=='13':
                states.append((float(geo.get('x')),float(geo.get('y')),float(geo.get('width')),float(geo.get('height')),value))
            if cell.get('edge')=='1':
                src=geo.find("mxPoint[@as='sourcePoint']");dst=geo.find("mxPoint[@as='targetPoint']")
                if src is None or dst is None: continue
                pts=[(float(src.get('x')),float(src.get('y')))]
                pts += [(float(p.get('x')),float(p.get('y'))) for p in geo.findall("Array[@as='points']/mxPoint")]
                pts.append((float(dst.get('x')),float(dst.get('y'))))
                total=sum(math.dist(a,b) for a,b in zip(pts,pts[1:]));distance=total/2
                px,py=pts[0]
                for a,b in zip(pts,pts[1:]):
                    length=math.dist(a,b)
                    if distance<=length:
                        ratio=distance/length if length else 0
                        px=a[0]+ratio*(b[0]-a[0]);py=a[1]+ratio*(b[1]-a[1]);break
                    distance-=length
                offset=geo.find("mxPoint[@as='offset']")
                if offset is not None: px+=float(offset.get('x',0));py+=float(offset.get('y',0))
                edges.append((pts,px,py,value))
        if not states: raise ValueError('No library FSM ellipses: '+name)
        xs=[x for x,y,w,h,_ in states]+[x+w for x,y,w,h,_ in states]
        ys=[y for x,y,w,h,_ in states]+[y+h for x,y,w,h,_ in states]
        for pts,x,y,label in edges:
            xs += [p[0] for p in pts]+[x-len(label)*5-8,x+len(label)*5+8]
            ys += [p[1] for p in pts]+[y-16,y+16]
        left,top=min(xs)-30,min(ys)-30;width=max(xs)-left+30;height=max(ys)-top+30
        ns='http://www.w3.org/2000/svg';ET.register_namespace('',ns)
        def add(parent,tag,**attrib): return ET.SubElement(parent,'{'+ns+'}'+tag,{k.replace('_','-'):str(v) for k,v in attrib.items()})
        svg=ET.Element('{'+ns+'}svg',dict(viewBox=f'{left:g} {top:g} {width:g} {height:g}',width=f'{width:g}',height=f'{height:g}'))
        add(svg,'metadata').text=json.dumps(dict(source=name+'.drawio',library=EXPECTED_LIBRARY_SHA256 if 'EXPECTED_LIBRARY_SHA256' in globals() else 'VLSIT_DRAWIO_LIB_V1',state_entry=13,edge_entry=1,renderer='project compatibility: exact draw.io ellipses, routes and edge labels'))
        add(svg,'rect',x=left,y=top,width=width,height=height,fill='white')
        defs=add(svg,'defs');marker=add(defs,'marker',id='arrow',viewBox='0 0 10 10',refX=9,refY=5,markerWidth=8,markerHeight=8,orient='auto-start-reverse')
        add(marker,'path',d='M 0 0 L 10 5 L 0 10 z',fill='black')
        for pts,_,_,_ in edges:
            add(svg,'polyline',points=' '.join(f'{x:g},{y:g}' for x,y in pts),fill='none',stroke='black',stroke_width=2)
            end=pts[-1]
            previous=next(p for p in reversed(pts[:-1]) if math.dist(p,end)>0)
            length=math.dist(previous,end);ux=(end[0]-previous[0])/length;uy=(end[1]-previous[1])/length
            base=(end[0]-12*ux,end[1]-12*uy)
            triangle=[end,(base[0]-5*uy,base[1]+5*ux),(base[0]+5*uy,base[1]-5*ux)]
            add(svg,'polygon',points=' '.join(f'{x:g},{y:g}' for x,y in triangle),fill='black')
        for x,y,w,h,label in states:
            add(svg,'ellipse',cx=x+w/2,cy=y+h/2,rx=w/2,ry=h/2,fill='white',stroke='black',stroke_width=2)
            add(svg,'text',x=x+w/2,y=y+h/2+6,text_anchor='middle',font_family='Arial, Helvetica, sans-serif',font_size=18,fill='black').text=label
        for _,x,y,label in edges:
            w=len(label)*10+12
            add(svg,'rect',x=x-w/2,y=y-13,width=w,height=26,fill='white')
            add(svg,'text',x=x,y=y+6,text_anchor='middle',font_family='Arial, Helvetica, sans-serif',font_size=18,fill='black').text=label
        ET.ElementTree(svg).write(target/(name+'.svg'),encoding='utf-8',xml_declaration=True)
        print(f'PASS: {name} SVG retains {len(states)} ellipses and {len(edges)} transition labels',flush=True)
    if args.post_a06=='render-fsm':
        for contract in contracts: render_fsm_svg(contract['id'])
        return 0
    if args.post_a06 == 'prepare':
        (target/'component_inventory.json').write_text(json.dumps(dict(
            modules={m:dict(**item,classification=classification(m),children=members(m)) for m,item in inventory.items() if m in figure_modules},
            modified_sources={n:dict(selected=sources[n]['selected'],history=history(n)) for n in sorted(sources) if n.startswith('rtl/common/modified')},
            rtl_sha256={n:hashlib.sha256((ROOT/n).read_bytes()).hexdigest() for n in audit['source_inventory']}),indent=2)+'\n',encoding='utf-8')
        changed=[]
        for module in figure_modules+extra_figures:
            spec=diagram(module);path=target/(module+'.json')
            if not path.exists() or json.loads(path.read_text())!=spec: changed.append(module)
            path.write_text(json.dumps(spec,indent=2)+'\n',encoding='utf-8')
        (target/'changed_component_figures.json').write_text(json.dumps(changed,indent=2)+'\n')
        for contract in contracts:
            transition_rows=[dict(src=s,dst=d,label=l) for s,d,l in contract['transitions']]
            if contract['id'].startswith('CCU_'):
                short=['alloc root','alloc victim','reject','lookup','held victim','lookup result','victim busy','cancel retry','alloc child','child commit','child abort','owner capture','prepare start','CMO prepared','prepare error','prepare OK','CMO report','finish commit','finish abort','commit start','victim release','victim hold','CMO cancel','publish','abort start','victim release','victim hold','cancel owner','error grant','update','cancel','grant load','CMO release','release']
                for idx,row in enumerate(transition_rows):
                    row['guard']=row['label']
                    original_idx=contract.get('transition_ids',list(range(len(transition_rows))))[idx]
                    row['label']=f'T{original_idx+1:02d}: '+short[original_idx]
            fsm=dict(page_name=contract['id'],out_name=contract['id']+'.drawio',function=contract['id'],
                     initial=contract['initial'],state_pattern='^[A-Z][A-Z0-9_]+$',
                     states=[dict(name=n) for n in contract['states']],
                     transitions=transition_rows,layout=dict(margin=50))
            if contract['id']=='CCU_CONTEXT':
                fsm['layout'].update(node_gap=220,rank_gap=220,max_columns=4)
            elif contract.get('view_of'):
                fsm['layout'].update(node_gap=220,rank_gap=220,max_columns=3)
            (target/(contract['id']+'.json')).write_text(json.dumps(fsm,indent=2)+'\n',encoding='utf-8')
        print(f'Prepared {len(figure_modules)} component and {len(contracts)} FSM sources; production RTL untouched')
        return 0
    if args.post_a06 == 'draw':
        names=[m for m in figure_modules]+extra_figures+[c['id'] for c in contracts]
        for name in names:
            if args.only=='changed' and name not in json.loads((target/'changed_component_figures.json').read_text()): continue
            if args.only=='components' and name in {c['id'] for c in contracts}: continue
            if args.only and args.only not in ('components','changed') and name not in args.only.split(','): continue
            command='vlsit_fsm_diagram.py' if name in {c['id'] for c in contracts} else 'vlsit_spec_diagram.py'
            run=[sys.executable,str(micro/'scripts'/command),'build',str(target/(name+'.json')),'--out-dir',str(target)]
            proc=subprocess.run(run,capture_output=True,text=True)
            output=proc.stdout+proc.stderr
            if proc.returncode and command=='vlsit_fsm_diagram.py' and 'Library operation failed' in output:
                # The installed FSM renderer appends three styles forbidden by
                # its own current symbol validator. Restore the exact library
                # edge style; do not change the skill or disable validation.
                module_spec=importlib.util.spec_from_file_location('post_a06_fsm',micro/'scripts'/command)
                fmod=importlib.util.module_from_spec(module_spec)
                sys.path.insert(0,str(micro/'scripts'))
                sys.modules[module_spec.name]=fmod
                module_spec.loader.exec_module(fmod)
                spec=json.loads((target/(name+'.json')).read_text())
                names,succ,pred,rank=fmod.build_graph(spec)
                sizes={n:fmod.state_size(n) for n in names}
                layout,positions,stats,gap,_,margin=fmod.choose_layout(spec,names,sizes,pred,succ,rank)
                positions=fmod.normalise_positions(positions,sizes,margin)
                geometry=fmod.geometry_report(positions,sizes,spec['transitions'],gap,spec)
                drawio=target/(name+'.drawio')
                tree=ET.parse(drawio)
                for cell in tree.getroot().iter('mxCell'):
                    if cell.get('edge')=='1':
                        cell.set('style',re.sub(r'(?:jumpStyle=arc;|jumpSize=12;|labelBackgroundColor=#FFFFFF;)','',cell.get('style','')))
                tree.write(drawio,encoding='utf-8',xml_declaration=True)
                check=subprocess.run([sys.executable,str(micro/'scripts/vlsit_library_symbols.py'),'validate','--diagram',str(drawio)],capture_output=True,text=True)
                output+='\nPROJECT COMPATIBILITY: restored protected edge style to the exact library prototype; no validator disabled.\n'+check.stdout+check.stderr
                report=dict(layout=layout,geometry=geometry,stats=stats)
                (target/(name+'_layout_report.json')).write_text(json.dumps(report,indent=2,default=str)+'\n')
                if check.returncode==0 and not geometry['findings']:
                    render=subprocess.run([sys.executable,str(micro/'scripts/vlsit_drawio_to_svg.py'),str(drawio),'--out',str(target/(name+'.svg')),'--force'],capture_output=True,text=True)
                    output+=render.stdout+render.stderr
                    proc.returncode=render.returncode
                    output+='\nPASS: FSM library, geometry and SVG checks\n' if proc.returncode==0 else '\nFAIL: FSM render\n'
                else:
                    output+='\n'+json.dumps(geometry['findings'])
            (target/(name+'_build.log')).write_text(output,encoding='utf-8')
            if proc.returncode==0 and command=='vlsit_fsm_diagram.py':
                render_fsm_svg(name)
            print(('PASS' if proc.returncode==0 else 'FAIL')+': '+name,flush=True)
            if proc.returncode: return proc.returncode
        return 0
    if args.post_a06 == 'check':
        failures=[]
        for name in figure_modules+extra_figures+[c['id'] for c in contracts]:
            for suffix in ('.json','.drawio','.svg'):
                p=target/(name+suffix)
                if not p.exists() or not p.stat().st_size: failures.append(str(p))
            log=target/(name+'_build.log')
            if not log.exists() or not log.read_text().strip().splitlines()[-1].startswith('PASS'):
                failures.append(str(log))
            if (target/(name+'.drawio')).exists():
                tabs=[d.get('name') for d in ET.parse(target/(name+'.drawio')).getroot().findall('diagram')]
                if name not in {c['id'] for c in contracts} and tabs!=['BLOCK_DIAGRAM','BLOCK_INFORMATION']:
                    failures.append('Wrong tabs: '+name)
            if (target/(name+'.svg')).exists():
                ET.parse(target/(name+'.svg'))
        frozen=json.loads((target/'component_inventory.json').read_text())['rtl_sha256']
        for name,digest in frozen.items():
            if hashlib.sha256((ROOT/name).read_bytes()).hexdigest()!=digest: failures.append('RTL changed: '+name)
        if failures: raise RuntimeError('\n'.join(failures))
        library_checks=[]
        for c in contracts:
            name=c['id']
            svg=ET.parse(target/(name+'.svg')).getroot()
            if len(svg.findall('{http://www.w3.org/2000/svg}ellipse'))!=len(c['states']):
                raise RuntimeError('FSM oval count: '+name)
            if len(svg.findall('{http://www.w3.org/2000/svg}polyline'))!=len(c['transitions']):
                raise RuntimeError('FSM edge count: '+name)
            texts=[x.text for x in svg.findall('{http://www.w3.org/2000/svg}text')]
            if not set(c['states']).issubset(texts): raise RuntimeError('Missing state label: '+name)
            spec=json.loads((target/(name+'.json')).read_text())
            if not all(t['label'] in texts for t in spec['transitions']): raise RuntimeError('Missing transition label: '+name)
            proc=subprocess.run([sys.executable,str(micro/'scripts/vlsit_library_symbols.py'),'validate','--diagram',str(target/(name+'.drawio'))],capture_output=True,text=True)
            library_checks.append(name+': '+proc.stdout+proc.stderr)
            if proc.returncode: raise RuntimeError('Post-render FSM library validation: '+name)
        (target/'library_check_post_render.log').write_text('\n'.join(library_checks),encoding='utf-8')
        text=HDS.read_text(encoding='utf-8')
        missing_links=[]
        for link in re.findall(r'\]\(([^)]+)\)',text):
            if '://' in link or link.startswith('#'): continue
            if not (base/link.split('#')[0]).exists(): missing_links.append(link)
        if missing_links: raise RuntimeError('Missing HDS links: '+str(sorted(set(missing_links))))
        native_spec=subprocess.run([sys.executable,str(micro/'scripts/vlsit_spec_tool.py'),'check',str(HDS)],capture_output=True,text=True)
        spec_output=native_spec.stdout+native_spec.stderr
        (target/'spec_check.log').write_text(spec_output,encoding='utf-8')
        errors=[line for line in spec_output.splitlines() if line.startswith('ERROR:')]
        unexpected=[line for line in errors if not ('Vietnamese letters' in line and 'R-005' in line)]
        if unexpected: raise RuntimeError('Specification structural errors: '+str(unexpected))
        summary=dict(components=len(figure_modules),working_flow_figures=len(extra_figures),
                     implemented_fsms=6,fsm_figures=len(contracts),rtl_files_unchanged=len(frozen),
                     block_tabs=['BLOCK_DIAGRAM','BLOCK_INFORMATION'],
                     bilingual_specification='User preference overrides skill R-005 English-only check.',
                     spec_checker_native_exit=native_spec.returncode,
                     spec_checker_technical_errors=len(unexpected),
                     spec_checker_language_findings=len(errors)-len(unexpected),
                     compatibility='Project adapter restores protected FSM library edge style and emits exact oval/transition-label SVG; post-render library checks pass; installed skill unchanged.',
                     component_functions=len(catalog),modified_sources=len(selected_modified))
        (target/'validation.json').write_text(json.dumps(summary,indent=2)+'\n',encoding='utf-8')
        print(f'PASS: {len(figure_modules)} component diagrams + {len(extra_figures)} working-flow diagrams + {len(contracts)} FSMs; RTL identities unchanged')
        return 0
    # Assembly uses the existing authoritative file and its archived prior revision.
    def figure(name, title):
        src=target/(name+'.json')
        return ('\n!['+title+'](figures/post_a06/'+name+'.svg)\n\n```json\n'+
                json.dumps(json.loads(src.read_text()),separators=(',',':'))+'\n```\n\n'+
                '[Editable draw.io](figures/post_a06/'+name+'.drawio) · [Figure source](figures/post_a06/'+name+'.json).\n')
    component_sections=[]
    for idx,module in enumerate(sorted(catalog),1):
        item=inventory[module]; c=catalog[module]
        part=[f'#### 14.4.{idx} `{module}` — {classification(module)}','',
              f'Source: [{item["path"]}](../../{item["path"]}). Selected production source: **{item["selected"]}**.',
              '', '**Function.** '+c['function'],'', '**Working/data flow.** '+c['flow'],'',
              '**State and storage ownership.** '+c['storage'],'', '**Safety, timing and error constraints.** '+c['critical'],'',
              '**Verification boundary.** '+c['verification'],'',
              'The figure shows actual child composition; a leaf shows its own boundary. It does not invent intermediate RTL modules. / Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.',
              figure(module,module+' composition'),
              '**Interface contract.** All synchronous ports use the common cluster clock; the probe engine cache clock is the same domain in this cluster. A valid/ready payload is accepted only on the corresponding handshake and held through backpressure. Pulsed completion/ACK interfaces are described by the operation/FSM contract; they must not be treated as independent ready/valid channels.',
              '', '| Direction | Exact source declaration |', '|---|---|']
        for p in item['ports']:
            part.append('| '+p['direction']+' | `'+p['declaration'].replace('|','\\|')+'` |')
        fsm=[c['id'] for c in contracts if c['module']==module]
        if fsm: part+=['','**FSM:** '+', '.join('['+f+'](#'+f.lower().replace('_','-')+')' for f in fsm)+'. See Section 10.1 for every transition and retained obligation.']
        else: part+=['','**FSM:** No new enum controller is declared by this module. Its combinational mapping, queue/valid-bit lifecycle, or instantiated child FSMs implement the behavior above. This is not a claim that the entire subtree is stateless.']
        component_sections.append('\n'.join(part))
    native_sections=['### 14.5 Modified native source contracts / Hợp đồng source native đã sửa','',
                     'Every selected modified source is listed below. Native ports/types/state names retain upstream naming and licenses; VLSIT wrappers adapt boundaries. A package is a type/constant dependency, not an instantiable RTL component. Header history is implementation provenance and can contain superseded staging comments; current behavior follows this specification and the actual source. / Liệt kê mọi source MODIFY được chọn; package không phải module. Không restyle RTL reuse theo rule VLSIT.']
    for idx,name in enumerate(selected_modified,1):
        modules=[m for m,item in inventory.items() if item['path']==name]
        hist=history(name)
        native_sections+=['',f'#### 14.5.{idx} `{Path(name).name}` — MODIFY','',f'Source: [{name}](../../{name}).', '']
        for module in modules:
            description=re.search(r'Description\s*:\s*([^\n]+)',sources[name]['raw'],re.I)
            inherited=(description[1].strip(' */') if description else 'Native '+module.replace('_',' ')+' component')
            role,flow=native_roles.get(module,(inherited,
                      'Preserve the native request/result or storage behavior while applying the explicit local changes recorded below. Its parent consumes the exact typed interfaces in this section; queue, arithmetic, memory and protocol helpers do not create new architectural ownership rules. Native latency/ordering remains source-defined and is not independently qualified by TOP lint.'))
            native_sections+=['**Function and local effect.** '+role+'. '+flow,
                              figure(module,module+' selected modified component'),
                              '**Interface and flow.** Keep native typed request/response records and source ordering. The parent wrapper owns translation to VLSIT flat ports. Exact port declarations:',
                              '', '| Direction | Exact source declaration |','|---|---|']
            native_sections += ['| '+p['direction']+' | `'+p['declaration'].replace('|','\\|')+'` |' for p in inventory[module]['ports']]
        if not modules:
            native_sections+=['**Function.** Type/configuration/package support; not an instantiable block, so no fictitious block/FSM diagram is supplied. Its definitions are consumed by the selected native component interfaces.']
        native_sections+=['','**Recorded local changes (source history, not a substitute for the current contract):**']
        native_sections += ['- '+h for h in hist] if hist else ['- Selected local copy; detailed delta provenance is linked from the source and the lint/implementation review reports.']
        native_sections+=['','**State/verification.** Native state encodings and helper logic remain source-owned. Coherence/maintenance-relevant state machines are discussed in Section 10; native arithmetic/MMU/helper integration is linted, with only the specific activated CPU/FPU cases described in Section 15. No blanket ISA/FP/MMU or helper-equivalence qualification is claimed.']
    unselected=[n for n in sources if n.startswith('rtl/common/modified') and not sources[n]['selected']]
    native_sections+=['','**Unselected local copies.** '+(', '.join('`'+n+'`' for n in unselected) if unselected else 'None in the captured source inventory.')+' They do not establish a current active implementation or test result.']
    (target/'component_contract_sections.md').write_text('\n\n'.join(component_sections)+'\n\n'+'\n'.join(native_sections)+'\n',encoding='utf-8')
    fsm_sections=['### 10.1 Modes and state transitions','',
                  'These are the exact explicit enum controllers introduced by the cluster. Waiting states hold until the stated handshake/completion. Diagrams show event order, not numeric latency. Native queue/flag lifecycles and retained retirement are specified separately; do not invent enum states for them. / Đây là các FSM enum thực; chờ đúng handshake/completion, không đặt latency giả.']
    for c in contracts:
        fsm_sections+=['',f'#### {c["id"].replace("_","-")}', '',c['description'],figure(c['id'],c['module']+' FSM'),
                       '| Transition | Current state | Guard / event | Next state |','|---|---|---|---|']
        fsm_sections += ['| T'+f'{c.get("transition_ids",list(range(len(c["transitions"]))))[idx]+1:02d}'+' | `'+s+'` | '+l+' | `'+d+'` |' for idx,(s,d,l) in enumerate(c['transitions'])]
        reset='ENUM_ST_IDLE' if c.get('view_of') else c['initial']
        fsm_sections+=['','All unspecified guards hold the current legal state in the full FSM. Reset enters `'+reset+'`; a phase-view entry is not a new hardware reset state. Invalid-encoding behavior follows the source and is not a normal software recovery path. / Điều kiện chưa thỏa giữ state theo FSM đầy đủ; điểm vào phase không phải reset state mới.']
    (target/'fsm_contract_sections.md').write_text('\n'.join(fsm_sections)+'\n',encoding='utf-8')
    baseline=base/'revision_history/pre_detail_rewrite_20261116'/HDS.name
    original=baseline.read_text(encoding='utf-8')
    # Keep all 22 template sections and their approved requirement/decision IDs;
    # consolidate historical appendices into the current implementation contract.
    headings=list(re.finditer(r'(?m)^## (\d+)\. ([^\n]+)\n',original))
    sections={}
    for idx,h in enumerate(headings):
        end=headings[idx+1].start() if idx+1<len(headings) else len(original)
        sections[int(h[1])]=original[h.start():end]
    sections[22]=sections[22].split('\n## DEC-030/031 implementation clarification')[0]
    architecture=(base/'post_a06_architecture_contract.md').read_text(encoding='utf-8')
    fragments={}
    markers=list(re.finditer(r'<!-- (ARCHITECTURE|INTERFACES|INTERNAL_INTERFACES|WORKING_FLOWS|ERRORS|PERFORMANCE) -->\n',architecture))
    for idx,m in enumerate(markers):
        fragments[m[1]]=architecture[m.end():markers[idx+1].start() if idx+1<len(markers) else len(architecture)].strip()
    body5=fragments['ARCHITECTURE'].replace('<!-- TOP_FIGURE -->',figure('m_vlsit_riscv_cluster_axi_top','Current structural AXI cluster TOP'))
    body5=body5.replace('### 5.3 Transaction and dataflow','### 5.3 Transaction and dataflow\n'+figure('CLUSTER_DATA_FLOW','Cached memory working/data flow')+figure('CLUSTER_CMO_FLOW','Retirement to CCU and LLC maintenance working flow'))
    sections[5]='## 5. Architecture\n\n'+body5+'\n\n'
    # A complete source-derived TOP port list supersedes the old proposed ACE
    # ports. Do not change native names or create optional absent ports.
    port_lines=['## 6. External interfaces and ports','',fragments['INTERFACES'],'',
                '### 6.2 Complete AXI-profile port list','',
                '| Port | Direction | Width | Signal type | Clock domain | Meaning / function |',
                '|---|---|---|---|---|---|']
    descriptions={'i_boot_addr':'Shared boot entry, held through reset release; hart identity selects software startup.',
                  'i_rst_n_cluster':'Active-low reset: asynchronous assertion, SoC-synchronized deassertion.',
                  'i_clk_cluster':'Common rising-edge clock for CPU, cache, buses and control.',
                  'o_int_fault':'Retained fatal cache-writeback level; diagnostic W1C does not clear it.',
                  'o_int_pmu':'Aggregate enabled PMU overflow level.',
                  'i_hart_debug_req':'Per-hart external Debug Module request; active maintenance defers admission.',
                  'o_hart_debug_mode':'Per-hart native debug-mode status.'}
    axi_meaning={'addr':'Byte address','id':'Transaction/source identity','len':'Burst length encoding',
                 'size':'Bytes-per-transfer encoding','burst':'Burst type','lock':'Exclusive-access attribute',
                 'cache':'Memory attribute','prot':'Protection attribute','qos':'Quality-of-service attribute',
                 'region':'Region attribute','atop':'Native atomic operation encoding','data':'Data payload',
                 'strb':'Byte write strobes','last':'Last transfer marker','resp':'Response status',
                 'valid':'Producer has valid payload','ready':'Consumer can accept payload'}
    for p in inventory['m_vlsit_riscv_cluster_axi_top']['ports']:
        width=' '.join(re.findall(r'\[[^]]+\]',p['declaration'])) or '1'
        for name in p['names']:
            if name.startswith('i_clk_'): kind='clock'
            elif name.startswith('i_rst_'): kind='reset'
            elif any(t in name for t in ('valid','ready','i_int_','o_int_','debug')): kind='level'
            elif name=='i_boot_addr': kind='static: stable through reset release'
            else: kind='data: qualified by the corresponding channel VALID/READY'
            function=descriptions.get(name)
            if not function and '_int_' in name: function='Per-hart '+name.split('_int_')[-1].upper()+' interrupt input; inactive slots ignored.'
            if not function:
                field=name.split('_')[-1]
                channel=next((c.upper() for c in ('aw','ar','w','b','r') if field.startswith(c)), '')
                stem=field[len(channel):] if channel else field
                function=(channel+' channel: '+axi_meaning.get(stem,field.replace('_',' ')))+'. Preserve the matching channel identity through stalls.'
            port_lines.append('| `'+name+'` | '+p['direction']+' | `'+width+'` | '+kind+' | CLK-CLUSTER | '+function+' |')
    sections[6]='\n'.join(port_lines)+'\n\n'+fragments['INTERNAL_INTERFACES']+'\n\n'
    current10=sections[10]
    start=current10.index('### 10.1 ');end=current10.index('### 10.2 Operations')
    current10=current10[:start]+'\n'.join(fsm_sections)+'\n\n'+current10[end:]
    # Preserve approved waveform sources and timings; no new waveform is drawn.
    current10=current10.replace('One snapshot command; no cycle bound until RTL design','One capture edge when the stored request is observed; software bus latency is variable')
    sections[10]=current10+'\n'+fragments['WORKING_FLOWS']+'\n\n'
    sections[12]=fragments['ERRORS']+'\n\n'
    sections[13]=fragments['PERFORMANCE']+'\n\n'
    hierarchy=['## 14. RTL implementation contract','',
               '### 14.1 Required coding baseline','',
               'New VLSIT modules use the approved VLSIT_RTL_Design_Rule.md v2. Pristine reuse retains original source, ports, headers and license notices. Modified native copies retain notices and dated history by Quan Nguyen and Codex - VLSI Technology page. Generated CSR is regenerated from the canonical workbook, never hand-edited. Native package/signed/type names are deliberate licensed-source exceptions, not instructions to restyle third-party RTL.',
               '', 'Logic module, component, source-file and source-reference are different units. A selected file can declare optional/inactive modules; selection is not activation or coverage. / Module, component và file source không đồng nghĩa; compile không chứng minh nhánh chức năng đã hoạt động.',
               '', '### 14.2 Current source hierarchy and component inventory','',
               '| Component | Class | Source | Direct source-referenced children |','|---|---|---|---|']
    for module in sorted(catalog):
        hierarchy.append('| `'+module+'` | '+classification(module)+' | `'+inventory[module]['path']+'` | '+(', '.join('`'+m+'`' for m,_ in members(module)) or 'Leaf / no child instance')+' |')
    hierarchy+=['','### 14.3 Shared implementation rules and figure interpretation','',
                'Each component section records function, working/data flow, storage owner, interface, error/backpressure constraints and verification scope. A no-enum wrapper can contain stateful child controllers; a combinational selector does not require an invented FSM. Block figures show actual containment; exact port declarations and the flow contracts carry the connectivity detail. Native replicated/conditional instances retain their source conditions.',
                '', '### 14.4 New and generated component contracts / Component mới và sinh tự động','']
    sections[14]='\n'.join(hierarchy)+'\n\n'+'\n\n'.join(component_sections)+'\n\n'+'\n'.join(native_sections)+'\n\n'
    sections[14]+=('### 14.6 Synthesis and qualification boundary\n\nThe logical baseline is one clock, 16-byte coherence lines, 64-bit native LLC data and default 256-KiB LLC. Memory bus width is selected at synthesis. Larger LLC block counts are declared by RTL but are not yet an approved/qualified multi-line maintenance contract. PDK/SRAM/SDC/corner/scan inputs are integration dependencies. No synthesis, timing, power, formal or code-coverage result is inferred from lint.\n\n')
    sections[8]+=('\n### 8.1 Current RTL defaults and qualification limits\n\n'
       '| Parameter | Current RTL default / legal declaration | Qualification boundary |\n|---|---|---|\n'
       '| `PARA_CPU_NUM` | 4; 2 or 4 | Both real CPU campaigns and native TOP lint |\n'
       '| `PARA_COH_TXN_NUM` | 8; 2 through 16 | Root admission reserves one victim credit; focused 2/8/16 units; not a whole-system matrix |\n'
       '| `PARA_LLC_WAY_NUM`, `PARA_LLC_NO_LINES` | 4 and 4096 | Default 256-KiB TOP lint; CPU campaigns use reduced geometry |\n'
       '| `PARA_LLC_BLOCK_NUM` | 2; RTL declares larger powers of two | Keep 16-byte baseline for qualified maintenance; larger-line behavior remains review work |\n'
       '| `PARA_AXI_MEM_DATA_W` | 64; 32/64/128/256 | Four leaf widths, only 64-bit real CPU end-to-end |\n'
       '| `PARA_PMU_COUNTER_NUM`, `PARA_PMU_COUNTER_W` | 16 and 64; 1–32 counters, 32/64 bits | Functional PMU/software matrix pending |\n'
       '| `PARA_AXIL_BASE_ADDR` | 0; aligned base up to 0xFFFFA000 | Twenty-four KiB aperture with six 4-KiB regions; group/base units pass |\n'
       '| `PARA_ADDR_REGION_*` | One cacheable 0x80000000–0xBFFFFFFF region | Shared PMA/router table; normal-uncached/MMIO are configurable but need CPU integration tests |\n\n'
       'The table describes the present declaration and evidence; it does not silently approve extra configurations. Native width/type parameters belong to the pinned dependency configuration.\n\n')
    sections[8]='## 8. Parameters and elaboration configurations\n\n'+sections[8][sections[8].index('### 8.1 Current RTL defaults'):]
    sections[8]+=('### 8.2 Address arrays, identity and line representation\n\n'
       'The BASE_LO/BASE_HI and SIZE_LO/SIZE_HI region parameters are sixteen-entry arrays of 32-bit words; TYPE is a sixteen-entry word array and NUM selects active entries. Active entries are aligned, nonzero in size, non-overlapping and within PLEN=56. Entry zero is the sole cacheable region in this native LLC integration; other active entries classify normal-uncached or MMIO. TYPE low bits encode the three defined classes; reserved upper/type bits invalidate the table. Exact defaults and checks are visible at the TOP/decoder contracts.\n\n'
       'Native CPU AXI IDs are four bits, MMIO egress IDs six bits and memory egress IDs seven bits after source extension. CCU context/scheduler tag width is max(1, clog2(PARA_COH_TXN_NUM)): three bits by default and one through four over the legal range. The native HPDcache probe endpoint uses a fixed four-bit tag field; its wrapper adapts the width while retaining the valid slot value. Physical line indices are 52 bits with four byte-offset bits omitted. LLC native data stays 64-bit; external memory width alone is parameterized. / Phải phân biệt native ID, ID sau mux, tag CCU và tag endpoint; không dùng một độ rộng cho mọi boundary.\n\n')
    # Remove stale implementation suggestions from the programming sequence.
    use='''### 11.2 Software programming and use flow

M means mandatory for the shown operating path; O means optional/conditional. The canonical AXIL_QUEUED workbook defines field layout, reset and access; the sequence below uses its exact cluster field names. Native LLC status is a separate upstream service map, not generated cluster CSR.

```mermaid
flowchart TD
 S01["S01 [M] Stable clock and SoC-controlled reset release"] --> S02["S02 [M] Wait for native LLC initialization"]
 S02 --> S03{"S03 [O] Enable PMU measurement?"}
 S03 -->|yes| S04["S04 [O] Program event_id, scope, en and overflow mask"]
 S03 -->|no| S05["S05 [M] Run active harts with configured PMA regions"]
 S04 --> S05
 S05 --> S06{"S06 [O] Need counter readout?"}
 S06 -->|yes| S07["S07 [O] Request snapshot and poll done"]
 S07 --> S08["S08 [O] Read stable low/high words"]
 S06 -->|no| S09{"S09 [O] PMU overflow pending?"}
 S08 --> S09
 S09 -->|yes| S10["S10 [O] Read causes and W1C handled causes"]
 S09 -->|no| S11{"S11 [O] Fatal cache IRQ?"}
 S10 --> S11
 S11 -->|yes| S12["S12 [O] Read retained fault record; platform reset recovery"]
 S11 -->|no| S13["S13 [M] Continue or stop the workload"]
 S12 --> S13
```

| No. | Step | Option (M/O) | Interface | CSR | Description |
|---|---|---|---|---|---|
| S01 | Stable clock and reset release | M | SoC clock/reset pins | N/A: reset is not a CSR | Release the one-domain cluster only under the reset contract |
| S02 | Wait for native LLC initialization | M | AXI4-Lite native LLC service status | N/A: native LLC RegBus map; BIST/status source is the pinned LLC register wrapper | Do not assume cache service before its native initialization completes; software service tests remain open |
| S03 | Select PMU use | O | Software branch, if measurement required | N/A: software decision | Skip PMU programming when no observation is requested |
| S04 | Configure observation | O | AXI4-Lite writes before measurement | `cpucl_pmu_evt[k].event_id`, `.scope`, `.en`; `cpucl_irq_en.overflow_en` | Select implemented source/scope and enable intended counters/overflow masks |
| S05 | Run software | M | Boot input and native instruction execution | N/A: not a CSR-controlled hart-start mechanism | Execute the workload on zero-based active harts with shared PMA/router regions |
| S06 | Select snapshot | O | Software branch if readout needed | N/A: decision | Choose a coherent snapshot rather than assuming low-read capture |
| S07 | Snapshot | O | AXI4-Lite command and polling | Write `cpucl_pmu_ctrl.snapshot_req`; poll `.snapshot_done`; W1C done as required before a new command | Capture one consistent bank; never accept an old sticky done as new completion |
| S08 | Read snapshot | O | AXI4-Lite reads | `cpucl_pmu_count_lo[k].value`, `cpucl_pmu_count_hi[k].value` | Reconstruct the captured value; high reads are zero for 32-bit counter profile |
| S09 | Test overflow | O | `o_int_pmu` and software status | Read `cpucl_irq_sts.overflow_pending` | Determine whether an enabled overflow cause needs handling |
| S10 | Clear handled overflow | O | AXI4-Lite read/write | Read `cpucl_irq_raw.overflow`; W1C handled bits | Respect hardware-first collision priority; do not clear unhandled causes blindly |
| S11 | Test fatal IRQ | O | `o_int_fault` level | Read `cpucl_fault_sts.value` if IRQ asserted | Distinguish reset-only fatal state from diagnostic W1C |
| S12 | Preserve diagnostics and recover | O | AXI4-Lite read plus SoC reset policy, only if fatal | Read `cpucl_fault_sts.value`, `cpucl_fault_info.value`, `cpucl_fault_lo.value`, `cpucl_fault_hi.value`; no record clear command | Record first source/address/response and hart-valid; coordinate platform recovery instead of retrying retained cache state |
| S13 | Continue or stop | M | Software execution/platform control | N/A: processor operation | Continue only when the selected path permits; fatal recovery is not transparent workload continuation |

VI: Dùng đúng field workbook; snapshot là lệnh riêng, done sticky cần phân biệt lệnh cũ/mới. Fault fatal chỉ phục hồi theo reset của SoC, không phải W1C. Trình tự phần mềm là hợp đồng mong muốn; PMU và native LLC service còn cần verify đầu-cuối.

'''
    old=sections[11];start=old.index('### 11.2 ');end=old.index('### 11.3 ')
    # Match real workbook names: the legacy PMU registers do not carry cpucl_.
    for register in ('pmu_ctrl','pmu_evt','pmu_count_lo','pmu_count_hi','irq_en','irq_raw','irq_sts'):
        use=use.replace('cpucl_'+register,register)
    sections[11]=('## 11. Register and programming model\n\n'
       '### 11.1 Canonical workbook and generator\n\n'
       'The sole register-layout source is VLSIT_RISCV_CPU_Cluster_CSR.xlsx, sheet AXIL_QUEUED. The current output is CSR_Generation.py v3.5, module m_vlsit_cpucl_csr, synchronous 32-bit AXI4-Lite with one queued read and one queued write and WSTRB=HONOR. Exact workbook/generator/output hashes are recorded in [A-06 generation provenance](../../verification/non_coherence_cluster/reports/fault_record_a06/csr_generation.json); the old v3.4 commit is not the current generated baseline. No APB port is used.\n\n'
       'Control/IRQ, selector, count-low, count-high and fatal-record groups are separated by 4 KiB; native LLC service follows the five CSR groups in the 24-KiB aperture. CSR relative offsets retain the full group index. Native LLC service is translated to its own pinned RegBus register map. The native LLC wrapper is a locally modified licensed copy, not a claim of unchanged reuse.\n\n'
       'The actual workbook names are pmu_ctrl, pmu_evt, pmu_count_lo, pmu_count_hi, irq_en, irq_raw, irq_sts, cpucl_coh and the four cpucl_fault words. Do not add a nonexistent cpucl_ prefix to the legacy PMU names in software documentation. This naming deviation from the earlier prefix intent is recorded in Section 20; the rewrite changes no register or generated port.\n\n'
       'Catalog ranges are CVA6 0x0001–0x0016, HPDcache 0x0100–0x010F, LLC 0x0200–0x0217 and 0x0240–0x0243, CCU 0x0300–0x030B. Native event expressions/units remain subject to the event-by-event qualification in Section 15. An event indicator is not automatically an instruction-retirement count.\n\n'+use+
       '### 11.3 Field connections and storage ownership\n\n'
       '| Workbook register.field | Design consumer/producer | Connection contract |\n|---|---|---|\n'
       '| `pmu_evt[k].event_id`, `.scope`, `.en` | Event selector and counter bank | Program the catalog/scope before measurement; invalid source/scope counts zero |\n'
       '| `pmu_ctrl.snapshot_req` | Snapshot capture and hardware clear | Stored command is cleared by hardware at capture; no read-triggered snapshot |\n'
       '| `pmu_ctrl.snapshot_done` | Snapshot hardware set and software W1C | Current RTL leaves done sticky until W1C; clear old done before issuing another command; workbook auto-clear wording is OPEN-PMU-DONE |\n'
       '| `pmu_count_lo[k].value`, `pmu_count_hi[k].value` | Snapshot bank RO data | Both words observe one captured bank; high word is zero in 32-bit profile |\n'
       '| `irq_en.overflow_en` | IRQ masking | Mask raw causes to derive pending/aggregate level |\n'
       '| `irq_raw.overflow` | Counter overflow hardware update and software W1C | Hardware update wins according to the generated full-field priority |\n'
       '| `irq_sts.overflow_pending` | PMU combinational status | RO raw AND enable |\n'
       '| `cpucl_coh.fault` | Coherence diagnostic events | Separate sticky W1C diagnostic; not a fatal-record or cache-recovery clear |\n'
       '| `cpucl_fault_sts.value`, `cpucl_fault_info.value`, `cpucl_fault_lo.value`, `cpucl_fault_hi.value` | First-fatal record | RO payload retained to reset; multiple may rise later |\n\n'
       'There is no generated irq_inj register in this workbook. Do not describe one as implemented. All active connections use CLK-CLUSTER; optional asynchronous generator collateral is not a second cluster clock domain.\n\n'
       '### 11.4 Access and update behavior\n\n'
       'Mapped aligned generated-CSR accesses return OKAY; writes to RO data are ignored under the generator policy. Misaligned accesses return SLVERR without field side effects. Reserved/unmapped accesses return DECERR; reads return zero, writes have no side effects. Zero strobes do not modify fields. AW/W and reads are queued separately, and B/R remain stable until accepted. Hardware clear wins for the snapshot request; hardware update wins for generated W1C status. Native LLC service has its own decoded legal offsets and rejects prohibited writes, including runtime SPM controls. No fixed software-visible wait count is promised.\n\n'
       'VI: Dùng tên field thực trong workbook, không tự thêm prefix hoặc irq_inj. RO write không làm thay đổi dữ liệu; reserved/misaligned có response riêng. Snapshot done đang sticky đến W1C; mô tả auto-clear trong workbook chưa khớp RTL và được ghi rõ để review, không tự sửa hành vi.\n\n')
    sections[11]+=('\n### 11.5 ABI preservation in this documentation revision\n\nThe approved CSR workbook and generated RTL are unchanged. Cluster controls occupy the first group, PMU selector/count groups follow at 4-KiB spacing, fatal records use the next group and native LLC service follows. The present ABI lacks a cluster version register at offset zero; newer skill rule R-067 would require one. Record this as an open ABI/versioning decision rather than silently relocating the approved control register. The native LLC version service is not a substitute for a cluster identification register.\n\n')
    dep_status={
      'DEP-008':'PMU wiring and generated CSR are present; event/scope/counter/snapshot/IRQ software qualification remains open.',
      'DEP-011':'Catalog ranges and source taps are implemented; event-by-event units/multiplicity and native source semantics still require functional validation.',
      'DEP-012':'Current source-mapped FSM figures and transition tables replace proposal V4 for implemented controllers; user design review remains required before claiming architecture freeze.',
      'DEP-014':'Focused context 2/8/16 units and A-05 CPU tests pass; all-traffic/source-capacity configuration qualification remains open.',
      'DEP-015':'Directed source-specific CBO/FENCE/atomic/ordinary B-error paths pass; arbitrary reorder/reset interruption remains unqualified.',
      'DEP-016':'Shared boot input and zero-based hart fanout implemented and exercised by 2/4-hart boot programs.',
      'DEP-017':'Selected local configuration disables CVXIF; no accelerator interface is exposed. Broader configuration equivalence is separate.',
      'DEP-019':'AXI4-Lite-to-RegBus bridge implemented and linted; native BIST/flush/software service behavior remains unqualified.',
      'DEP-020':'Tagged probe, origin-aware native flush ACK, retained dirty data and terminal locks implemented; targeted CPU/unit evidence exists.',
      'DEP-022':'Adapter connected at TOP. Leaf 32/64/128/256 pass; CPU memory profile is 64-bit. Remaining width/ATOP/burst matrix is open.',
      'DEP-023':'Diagnostic W1C workbook/generated CSR wiring is implemented; A-06 adds separate reset-only fatal record. Broader malformed-protocol software observation remains to test.',
      'DEP-024':'Current CCU source-mapped FSM includes retry-cancel and victim parent/child transitions; proposal figures remain archived.',
      'DEP-025':'Context target/phase retention and request eligibility/token handling implemented; directed A-05/metadata tests exist; random progress proof remains open.'}
    lines=sections[20].splitlines()
    for idx,line in enumerate(lines):
        for key,status in dep_status.items():
            if line.startswith('| '+key+' '):
                fields=line.split('|');fields[-2]=' '+status+' ';lines[idx]='|'.join(fields)
    sections[20]='\n'.join(lines)+'\n\n### 20.1 Current unresolved contracts and release blockers\n\n'
    sections[20]+=('| ID | Evidence / issue | Impact and next decision |\n|---|---|---|\n'
      '| OPEN-LIC | Restrictive vendored lzc header remains in actual TOP filelist | Establish permission/provenance or replace with a licensed compatible implementation before release/tapeout readiness |\n'
      '| OPEN-LINE | Fixed 16-byte CCU/maintenance line and configurable larger LLC block count | Keep the qualified 16-byte profile; decide/review any larger-line support before advertising it |\n'
      '| OPEN-ABI | Newer skill version-at-zero requirement versus existing approved CSR ABI | Designer/firmware must choose any future version-register ABI change; this rewrite changes no register |\n'
      '| OPEN-ACE-MAP | Earlier ACE-subset architectural intent versus implemented custom tagged channels | Review semantic mapping; do not claim native ACE pin compliance or external snoop service |\n'
      '| OPEN-DV | PMU/native LLC service, MMIO/uncached ATOP, IRQ/debug/WFI, random coherence, width/default LLC matrix | Complete prioritized tests from the post-A-06 audit; existing lint is not functional closure |\n'
      '| OPEN-ASIC | PDK/SRAM/clock/SDC/PVT/scan/DFT and workload targets absent | SoC inputs required for implementation and PPA/STA/signoff |\n\n')
    sections[15]=sections[15].replace('### 15.1 Scope and strategy','### 15.1 Scope and strategy\n\nCurrent evidence: 58 actual CPU cases and 98 checked entries with source identities, plus fresh default TOP 2/4-hart lint. No CPU simulations are rerun by this document rewrite. See [post-A-06 matrix](../reports/post_a06_cluster_audit/README.md). A-06 activates external fault CSR; PMU/native LLC service/debug/uncached ATOP are not thereby verified. Directed cases are not code-coverage percentages.\n')
    sections[15]+=('\n### 15.5 Current ordinary-eviction test definition\n\n'
        '| Test ID | Requirement | Scenario | Expected result | Evidence |\n|---|---|---|---|---|\n'
        '| TEST-050 | REQ-ERR-003 | Ordinary dirty L1 eviction with OKAY/SLVERR/DECERR at 2/4 harts | B success permits replacement; failure retains actual victim/data/context and fatal IRQ until reset; reset recovery succeeds | A-03 six real CPU cases; current A-06 baseline replay |\n\n')
    sections[19]+=('\n### 19.1 Fatal ordinary writeback traceability\n\n'
        '| Requirement ID | Implementation | Verification | Status |\n|---|---|---|---|\n'
        '| REQ-ERR-003 | Native L1/LLC B-qualified retention; first-fatal record; sticky IRQ; RO CSR | TEST-050 and TEST-054; A-03/A-06 real CPU and units | Directed checks pass; broad reset/traffic stress remains open |\n\n')
    sections[20]+=('### 20.2 Confirmed first-fatal decisions\n\n'
        '| Decision | Confirmed behavior | Source |\n|---|---|---|\n'
        '| DEC-039 | First ordinary L1/LLC fatal record retained to reset; later events set multiple; simultaneous priority lowest active L1 hart then LLC; nonfatal diagnostics remain separate W1C | Designer Q1=A |\n'
        '| DEC-040 | L1 hart is exact; shared LLC uses hart_valid=0 and never implicates hart 0 merely because the hart field reads zero | Designer Q2=A |\n\n')
    sections[20]=sections[20].replace('## 20. Assumptions, dependencies, and decisions','## 20. Assumptions, dependencies, and decisions\n\nDated decision prose records the approval checkpoint, not current implementation completeness. Current source/status is in Sections 14–15 and the open-item table below. / Các quyết định cũ không phải bằng chứng trạng thái RTL hiện tại.\n',1)
    sections[20]+=('### 20.3 Register-model inconsistencies found during this rewrite\n\n'
       '| ID | Evidence | Required review; no silent change |\n|---|---|---|\n'
       '| OPEN-PMU-DONE | Workbook snapshot_done description says a new request clears old done; current snapshot/CSR RTL only sets it on capture and otherwise requires W1C | Agree intended rearm behavior and synchronize workbook/RTL/tests. Documented safe software sequence clears old done before requesting a new snapshot |\n'
       '| OPEN-REGNAME | Earlier cpucl prefix intent differs from actual legacy pmu/irq workbook names | Preserve actual names in this spec; decide any future naming/API migration explicitly. No offset, port or generated RTL changed here |\n\n')
    # Render already approved existing WaveJSON sources; no new timing is invented.
    for wf,stem in [('WF-020','WF-020_directory_cancel_escape'),('WF-021','WF-021_address_region_routing'),('WF-022','WF-022_directory_cancel_escape_detail')]:
        lines=sections[10].splitlines()
        for idx,line in enumerate(lines):
            if line.startswith('| '+wf+' |'):
                source='doc/architecture_figures/waveforms'+stem+'.svg'
                lines[idx]=line.replace('[WaveJSON source]',f'![{wf}]({source}); [WaveJSON source]',1)
        sections[10]='\n'.join(lines)+'\n\n'
    sections[22]+=('\nCurrent source baseline and review evidence: [recursive production inventory](../reports/post_a06_cluster_audit/source_inventory.md), [audit](../reports/post_a06_cluster_audit/README.md), [A-06 source identities](../../verification/non_coherence_cluster/reports/fault_record_a06/results.json). The corrected recursive inventory includes the nested HPDcache filelist: 464 source files, not the earlier 419-file top-level-only count.\n\n')
    front=original[:original.index('# VLSIT RISC-V')]
    front=front.replace('version: "0.28"','version: "0.29"')
    front=re.sub(r'(?m)^status:.*$', 'status: "Draft - detailed post-A-06 component/FSM/interface contract; qualification and explicit open items remain"',front)
    intro=('# VLSIT RISC-V Dual/Quad CPU Cluster Design Specification\n\n'
           '# Đặc tả chi tiết cluster CPU RISC-V 2/4 hart VLSIT\n\n'
           '**Revision 0.29, 2026-11-16.** Consolidated specification with current TOP/component diagrams, source-selected NEW/MODIFY/REUSE/GENERATED contracts, exact component ports, actual controller states and working/data flows. The prior revision and historical appendices are preserved in [the pre-rewrite snapshot](revision_history/pre_detail_rewrite_20261116/'+HDS.name+').\n\n'
           'This document states the approved design contract, explains its current RTL realization and separately identifies validation status. Source inspection is not a golden verification model. Conflicts and unqualified declarations remain explicit review items in Section 20; no RTL, register ABI, licensing notice or new waveform timing is changed by this rewrite.\n\n'
           'Bản này hợp nhất hợp đồng thiết kế, cách RTL hiện thực và trạng thái verify; không biến source đang có thành bằng chứng thiết kế đúng. Có sơ đồ TOP/từng component, chức năng, interface, FSM và data flow. Các mâu thuẫn/phần chưa verify ghi ở Section 20; không sửa RTL hoặc map CSR.\n\n'
           '## Document map\n\n| Sections | Use |\n|---|---|\n| 1–4 | Scope, precedence, approved requirements and configurations |\n| 5–9 | Architecture, TOP, interfaces, reset and data/configuration representation |\n| 10–13 | Actual FSMs, operations, working flows, software use, errors and worst-case performance |\n| 14 | Every new/generated component and selected modified source; adjacent diagram/interface/function/change contract |\n| 15–22 | Verification, ASIC/security constraints, traceability, decisions and references |\n\n')
    HDS.write_text(front+intro+''.join(sections[n] for n in range(1,23)),encoding='utf-8')
    print('Canonical revision 0.29 rewritten with all 22 template sections; baseline archived; production RTL untouched.')
    return 0


if __name__ == "__main__":
    raise SystemExit(post_a06_main() if '--post-a06' in sys.argv else main())
