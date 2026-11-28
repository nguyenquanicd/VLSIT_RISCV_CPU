#!/usr/bin/env python3
# -----------------------------------------------------------------------------
# AI-GENERATED (Claude Opus 5.5, 2026-11-27) - candidate artifact (R-117, R-231).
# Sources: REF-001 rev 0.39 REQ-PMU-002..008, Sections 10.5.7, 11.2-11.3;
# CSR workbook sheets AXIL_QUEUED (pmu_evt fields, pmu_count_lo/hi) and
# Event_Map (IDs, allowed scope, SPM-disabled selectors, count semantics);
# question_log Q-G0-11 (exact counts, prefetcher off - G0-CONF-01). No RTL used.
# Human review: pending.
# -----------------------------------------------------------------------------
"""chk_pmu_model - expected PMU counter values (plan 5.2).

Inputs: counter configuration {k: (event_id, scope, en)}, per-cycle event
occurrence records, number of active harts (2 in CFG-RV32-2) and counter width.
expected_counts() returns {k: value}; check_snapshot() compares AXI4-Lite
snapshot reads (pmu_count_lo/hi) with the expectation.
"""
import os
import re
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "common"))
import xlsx_min  # noqa: E402

WORKBOOK = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                         "..", "..", "..", "doc", "specification", "VLSIT_RISCV_CPU_Cluster_CSR.xlsx"))


class EventCatalog:
    """Event_Map rows: id -> {group, name, scope_class ('hart' or 'cluster'), disabled, kind}."""

    def __init__(self, path=WORKBOOK):
        self.events = {}
        for row in xlsx_min.read_sheet(path, "Event_Map"):
            if not row or not row[0] or not str(row[0]).startswith("EVT "):
                continue
            row = list(row) + [None] * 8
            eid = int(row[0].split()[1], 16)
            scope_txt = row[3] or ""
            limits = (row[7] or "") + " " + (row[5] or "")
            scope_class = "cluster" if "scope 5" in scope_txt else "hart"
            if "occurrence-count tap" in limits:
                kind, cap = "occurrence", 4          # REQ-PMU-008: CCU taps count up to four per cycle
            elif "cycle indicator" in limits:
                kind, cap = "cycle", 1               # REQ-PMU-008: stall IDs one per asserted cycle
            else:
                kind, cap = "indicator", 1           # one sampled indicator per hart / per LLC event
            self.events[eid] = {"group": row[1], "name": row[2], "scope_class": scope_class,
                                "disabled": "count zero because SPM is disabled" in limits,
                                "kind": kind, "cap": cap}

    def get(self, eid):
        return self.events.get(eid)


def expected_counts(config, occurrences, num_harts=2, width=64, catalog=None, initial=None):
    """config: {k: {'event_id':int,'scope':int,'en':bool}}
    occurrences: iterable of {'cycle':int,'event_id':int,'hart':int|None,'count':int}
    Returns ({k: value}, input_errors)."""
    cat = catalog or EventCatalog()
    mask = (1 << width) - 1
    vals = dict(initial or {k: 0 for k in config})
    errs = []
    seen = {}
    for o in occurrences:
        ev = cat.get(o["event_id"])
        if ev is not None:
            key = (o["cycle"], o["event_id"], o.get("hart"))
            seen[key] = seen.get(key, 0) + o["count"]
            if seen[key] > ev["cap"]:
                errs.append("event 0x%04x cycle %d hart %s count %d exceeds cap %d" % (o["event_id"], o["cycle"], o.get("hart"), seen[key], ev["cap"]))
        for k, c in config.items():
            if not c["en"] or c["event_id"] != o["event_id"] or ev is None or ev["disabled"]:
                continue
            s = c["scope"]
            if ev["scope_class"] == "hart":
                h = o.get("hart")
                if h is None or h >= num_harts:
                    continue
                if (s < 4 and s == h) or s == 4:
                    vals[k] = (vals[k] + o["count"]) & mask
            elif s == 5:
                vals[k] = (vals[k] + o["count"]) & mask
    return vals, errs


def check_snapshot(expected, reads, width=64):
    """reads: {k: (lo, hi)} from pmu_count_lo/hi. Returns mismatch list."""
    errs = []
    for k in sorted(expected):
        if k not in reads:
            errs.append("counter %d not read" % k)
            continue
        lo, hi = reads[k]
        exp = expected[k]
        exp_hi = 0 if width == 32 else (exp >> 32) & 0xFFFFFFFF
        if lo != exp & 0xFFFFFFFF or hi != exp_hi:
            errs.append("counter %d snapshot hi:lo 0x%08x_%08x expected 0x%08x_%08x" % (k, hi, lo, exp_hi, exp & 0xFFFFFFFF))
    return errs


def decode_pmu_evt(word):
    """pmu_evt register: event_id [15:0], scope [18:16], en [19] (workbook AXIL_QUEUED)."""
    return {"event_id": word & 0xFFFF, "scope": (word >> 16) & 7, "en": bool((word >> 19) & 1)}
