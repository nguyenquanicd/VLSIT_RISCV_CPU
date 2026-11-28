# AI-GENERATED (Claude Opus 5.5, 2026-11-27) - candidate; human review pending.
"""Qualification of chk_pmu_model (plan 5.6)."""
from qual_common import Suite
import chk_pmu_model as P

SOURCES = ["chk_pmu_model.py", "common/xlsx_min.py", "qual/qual_chk_pmu_model.py"]
KIND = "model"
WORKBOOK_INPUT = True


def cfg(*items):
    return {k: {"event_id": e, "scope": sc, "en": en} for k, (e, sc, en) in enumerate(items)}


def run():
    s = Suite()
    cat = P.EventCatalog()
    s.eq("known_answer", "Event_Map catalog size (22 CVA6 + 16 HPDcache + 28 LLC + 12 CCU)", 78, len(cat.events))
    s.eq("known_answer", "0x0007 is a per-hart event", "hart", cat.get(0x0007)["scope_class"])
    s.eq("known_answer", "0x0303 is a cluster occurrence tap with cap 4", ("cluster", "occurrence", 4),
         (cat.get(0x0303)["scope_class"], cat.get(0x0303)["kind"], cat.get(0x0303)["cap"]))
    s.eq("known_answer", "0x0308 is a cycle indicator", "cycle", cat.get(0x0308)["kind"])
    s.eq("known_answer", "SPM selectors disabled", [True] * 6, [cat.get(x)["disabled"] for x in (0x206, 0x207, 0x20B, 0x20C, 0x20D, 0x20E)])
    occ = [{"cycle": c, "event_id": 0x0007, "hart": 0, "count": 1} for c in range(3)] + \
          [{"cycle": c, "event_id": 0x0007, "hart": 1, "count": 1} for c in range(1, 6)] + \
          [{"cycle": 10, "event_id": 0x0303, "hart": None, "count": 2}, {"cycle": 11, "event_id": 0x0303, "hart": None, "count": 4},
           {"cycle": 12, "event_id": 0x0206, "hart": None, "count": 1}]
    c = cfg((0x0007, 0, True), (0x0007, 1, True), (0x0007, 4, True), (0x0007, 2, True), (0x0007, 3, True), (0x0007, 5, True),
            (0x0007, 6, True), (0x0007, 7, True), (0x0303, 5, True), (0x0303, 0, True), (0x0206, 5, True), (0x0500, 0, True),
            (0x0007, 0, False))
    vals, errs = P.expected_counts(c, occ, num_harts=2, catalog=cat)
    s.eq("known_answer", "scopes 0,1,4,2,3,5,6,7 for 0x0007; CCU 0x0303 scope 5/0; SPM; unknown; disabled",
         [3, 5, 8, 0, 0, 0, 0, 0, 6, 0, 0, 0, 0], [vals[k] for k in range(13)])
    s.eq("known_answer", "no input-cap violation in the scenario", [], errs)
    s.eq("known_answer", "pmu_evt decode [15:0]/[18:16]/[19]", {"event_id": 0x303, "scope": 5, "en": True}, P.decode_pmu_evt(0x000D0303))
    v32, _ = P.expected_counts(cfg((0x0007, 0, True)), [{"cycle": 0, "event_id": 7, "hart": 0, "count": 1}], width=32,
                               catalog=cat, initial={0: 0xFFFFFFFF})
    s.eq("boundary", "32-bit counter wraps modulo 2^32 (REQ-PMU-002)", 0, v32[0])
    v64, _ = P.expected_counts(cfg((0x0007, 0, True)), [{"cycle": 0, "event_id": 7, "hart": 0, "count": 1}], width=64,
                               catalog=cat, initial={0: 0xFFFFFFFF})
    s.eq("boundary", "64-bit counter carries into the high word", 0x100000000, v64[0])
    s.eq("boundary", "W=32 snapshot: high word must read zero", [], P.check_snapshot({0: 5}, {0: (5, 0)}, width=32))
    _, e1 = P.expected_counts(cfg((0x0303, 5, True)), [{"cycle": 0, "event_id": 0x303, "hart": None, "count": 5}], catalog=cat)
    s.eq("negative", "CCU tap above 4 per cycle flagged as an input error", True, bool(e1))
    _, e2 = P.expected_counts(cfg((0x0007, 0, True)), [{"cycle": 0, "event_id": 7, "hart": 0, "count": 1}] * 2, catalog=cat)
    s.eq("negative", "per-hart indicator above 1 per cycle flagged", True, bool(e2))
    vr, _ = P.expected_counts(c, [], catalog=cat)
    s.eq("reset", "after reset (no events) every counter expects 0 (REQ-RST-001)", [0] * 13, [vr[k] for k in range(13)])
    exp = {k: vals[k] for k in range(13)}
    good = {k: (v & 0xFFFFFFFF, v >> 32) for k, v in exp.items()}
    s.eq("known_answer", "control for fault injection: correct snapshot has no error", [], P.check_snapshot(exp, good))
    for name, k, val in [("count off by one", 0, (4, 0)), ("aggregate misses hart 1", 2, (3, 0)),
                         ("absent hart 2 counted", 3, (3, 0)), ("SPM selector counted", 10, (1, 0)),
                         ("high word nonzero", 1, (5, 1)), ("CCU tap counted once per cycle", 8, (2, 0))]:
        bad = dict(good)
        bad[k] = val
        s.detected(name, P.check_snapshot(exp, bad))
    return s
