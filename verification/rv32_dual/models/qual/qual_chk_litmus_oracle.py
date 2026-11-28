# AI-GENERATED (Claude Opus 5.5, 2026-11-27) - candidate; human review pending.
"""Qualification of chk_litmus_oracle (plan 5.6)."""
import itertools
from qual_common import Suite
import chk_litmus_oracle as L

SOURCES = ["chk_litmus_oracle.py", "qual/qual_chk_litmus_oracle.py"]
KIND = "model"


def all_combos(pattern):
    if pattern == "2+2W":
        return [{"fx": a, "fy": b} for a, b in itertools.product((1, 2), (1, 2))]
    return [{"r0": a, "r1": b} for a, b in itertools.product((0, 1), (0, 1))]


def run():
    s = Suite()
    for (pat, fenced), t in sorted(L.TABLE.items()):
        enum = L.allowed_outcomes(pat, fenced)
        forb = {tuple(sorted(f.items())) for f in t["forbidden"]}
        expected_allowed = {tuple(sorted(c.items())) for c in all_combos(pat)} - forb
        s.eq("known_answer", "%s fenced=%s: enumeration equals published verdicts" % (pat, fenced),
             sorted(expected_allowed), sorted(enum))
    sc = L.allowed_outcomes("SB", True)
    s.eq("boundary", "fenced SB equals the sequentially consistent set (3 outcomes)", 3, len(sc))
    s.eq("boundary", "unfenced MP allows the reordered outcome r0=1,r1=0", [], L.check_result("MP", False, {"r0": 1, "r1": 0}))
    s.eq("boundary", "table and enumeration agree for every outcome of every case", 0,
         sum(int(bool(L.check_result(p, f, c)) != bool(L.check_result(p, f, c, use="table")))
             for (p, f) in L.TABLE for c in all_combos(p)))
    s.raises("negative", "unknown pattern", lambda: L.allowed_outcomes("IRIW", False), KeyError)
    s.eq("negative", "outcome with an impossible value is rejected", True, bool(L.check_result("MP", False, {"r0": 2, "r1": 0})))
    s.not_applicable("reset", "stateless enumeration")
    for name, rec in [("MP with fences observed r0=1,r1=0", {"pattern": "MP", "fenced": True, "outcome": {"r0": 1, "r1": 0}}),
                      ("SB with fences observed r0=0,r1=0", {"pattern": "SB", "fenced": True, "outcome": {"r0": 0, "r1": 0}}),
                      ("LB with fences observed r0=1,r1=1", {"pattern": "LB", "fenced": True, "outcome": {"r0": 1, "r1": 1}}),
                      ("2+2W with fences final x=1,y=1", {"pattern": "2+2W", "fenced": True, "outcome": {"fx": 1, "fy": 1}}),
                      ("value never written (r1=3)", {"pattern": "SB", "fenced": False, "outcome": {"r0": 0, "r1": 3}})]:
        s.detected(name, L.check_record(rec))
    return s
