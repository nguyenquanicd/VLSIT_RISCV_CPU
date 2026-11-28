#!/usr/bin/env python3
# -----------------------------------------------------------------------------
# AI-GENERATED (Claude Opus 5.5, 2026-11-27) - candidate artifact (R-117, R-231).
# Sources: RISC-V Unprivileged ISA chapter 'RVWMO Memory Consistency Model'
# (preserved program order rule 1 same-address ordering, FENCE rw,rw ordering,
# multi-copy atomicity) and its litmus-test appendix (MP, SB, LB, 2+2W
# allowed/forbidden outcomes). No RTL used. Human review: pending.
# -----------------------------------------------------------------------------
"""chk_litmus_oracle - RVWMO-allowed outcome sets for small litmus tests.

Two independent derivations are provided:
1. allowed_outcomes(): operational enumeration. Each hart's memory operations
   may execute in any order that keeps (a) same-address operations in program
   order and (b) every operation on its side of a 'fence rw,rw'. The reordered
   per-hart sequences are interleaved and executed sequentially (multi-copy
   atomic memory). Scope: tests without address/data/control dependencies,
   without same-hart store-to-load forwarding races and without AMOs.
2. TABLE: the published allowed/forbidden verdicts of the four patterns.
check_result(pattern, fenced, outcome) -> list of errors.
"""
import itertools

# op: ("W", var, value) | ("R", var, reg) | ("F",)
PATTERNS = {
    "MP": ([("W", "x", 1), ("W", "y", 1)], [("R", "y", "r0"), ("R", "x", "r1")]),
    "SB": ([("W", "x", 1), ("R", "y", "r0")], [("W", "y", 1), ("R", "x", "r1")]),
    "LB": ([("R", "x", "r0"), ("W", "y", 1)], [("R", "y", "r1"), ("W", "x", 1)]),
    "2+2W": ([("W", "x", 1), ("W", "y", 2)], [("W", "y", 1), ("W", "x", 2)]),
}
# outcome keys: registers r0/r1 or final values fx/fy
TABLE = {
    ("MP", False): {"forbidden": [], "allowed": [{"r0": 1, "r1": 0}, {"r0": 1, "r1": 1}, {"r0": 0, "r1": 0}, {"r0": 0, "r1": 1}]},
    ("MP", True): {"forbidden": [{"r0": 1, "r1": 0}], "allowed": [{"r0": 1, "r1": 1}, {"r0": 0, "r1": 0}, {"r0": 0, "r1": 1}]},
    ("SB", False): {"forbidden": [], "allowed": [{"r0": 0, "r1": 0}, {"r0": 1, "r1": 1}, {"r0": 0, "r1": 1}, {"r0": 1, "r1": 0}]},
    ("SB", True): {"forbidden": [{"r0": 0, "r1": 0}], "allowed": [{"r0": 1, "r1": 1}, {"r0": 0, "r1": 1}, {"r0": 1, "r1": 0}]},
    ("LB", False): {"forbidden": [], "allowed": [{"r0": 1, "r1": 1}, {"r0": 0, "r1": 0}, {"r0": 0, "r1": 1}, {"r0": 1, "r1": 0}]},
    ("LB", True): {"forbidden": [{"r0": 1, "r1": 1}], "allowed": [{"r0": 0, "r1": 0}, {"r0": 0, "r1": 1}, {"r0": 1, "r1": 0}]},
    ("2+2W", False): {"forbidden": [], "allowed": [{"fx": 1, "fy": 1}, {"fx": 2, "fy": 2}, {"fx": 2, "fy": 1}, {"fx": 1, "fy": 2}]},
    ("2+2W", True): {"forbidden": [{"fx": 1, "fy": 1}], "allowed": [{"fx": 2, "fy": 2}, {"fx": 2, "fy": 1}, {"fx": 1, "fy": 2}]},
}


def with_fence(ops):
    return [ops[0], ("F",)] + list(ops[1:])


def _orders(ops):
    """All execution orders of the memory ops of one hart allowed by the rules."""
    mem = [i for i, o in enumerate(ops) if o[0] != "F"]
    fences = [i for i, o in enumerate(ops) if o[0] == "F"]

    def must_precede(i, j):  # program order i < j
        if ops[i][1] == ops[j][1]:
            return True
        return any(i < f < j for f in fences)
    res = []
    for perm in itertools.permutations(mem):
        pos = {k: n for n, k in enumerate(perm)}
        if all(pos[i] < pos[j] for i in mem for j in mem if i < j and must_precede(i, j)):
            res.append([ops[k] for k in perm])
    return res


def _interleavings(a, b):
    if not a:
        yield list(b)
        return
    if not b:
        yield list(a)
        return
    for rest in _interleavings(a[1:], b):
        yield [a[0]] + rest
    for rest in _interleavings(a, b[1:]):
        yield [b[0]] + rest


def allowed_outcomes(pattern, fenced):
    t0, t1 = PATTERNS[pattern]
    if fenced:
        t0, t1 = with_fence(t0), with_fence(t1)
    outs = set()
    for o0 in _orders(t0):
        for o1 in _orders(t1):
            for seq in _interleavings(o0, o1):
                mem, regs = {"x": 0, "y": 0}, {}
                for op in seq:
                    if op[0] == "W":
                        mem[op[1]] = op[2]
                    else:
                        regs[op[2]] = mem[op[1]]
                if pattern == "2+2W":
                    outs.add((("fx", mem["x"]), ("fy", mem["y"])))
                else:
                    outs.add(tuple(sorted(regs.items())))
    return {tuple(sorted(dict(o).items())) for o in outs}


def check_result(pattern, fenced, outcome, use="enumeration"):
    """outcome: dict like {'r0':1,'r1':0} or {'fx':1,'fy':1}. Returns errors."""
    key = tuple(sorted(outcome.items()))
    if use == "table":
        forb = {tuple(sorted(f.items())) for f in TABLE[(pattern, fenced)]["forbidden"]}
        return ["%s fenced=%s outcome %s is forbidden" % (pattern, fenced, outcome)] if key in forb else []
    allowed = allowed_outcomes(pattern, fenced)
    return [] if key in allowed else ["%s fenced=%s outcome %s is not RVWMO-allowed" % (pattern, fenced, outcome)]


def check_record(rec):
    """NDJSON 'litmus' record: {pattern, fenced: bool, outcome: {...}}."""
    return check_result(rec["pattern"], bool(rec["fenced"]), {k: int(v) for k, v in rec["outcome"].items()})
