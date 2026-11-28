# AI-GENERATED (Claude Opus 5.5, 2026-11-27) - candidate; human review pending.
"""Shared helpers for the model/checker qualification suites."""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
MODELS = os.path.dirname(HERE)
for p in (MODELS, os.path.join(MODELS, "common"), os.path.join(MODELS, "asm_rv32")):
    if p not in sys.path:
        sys.path.insert(0, p)


class Suite:
    KINDS = ("known_answer", "boundary", "negative", "reset", "fault_detection")

    def __init__(self):
        self.cases = {k: [] for k in self.KINDS}
        self.na = {}

    def eq(self, kind, name, expected, observed):
        self.cases[kind].append({"name": name, "expected": _fmt(expected), "observed": _fmt(observed),
                                 "pass": expected == observed})

    def raises(self, kind, name, fn, exc=Exception):
        try:
            fn()
            ok, obs = False, "no exception"
        except exc as e:
            ok, obs = True, "%s: %s" % (type(e).__name__, e)
        self.cases[kind].append({"name": name, "expected": "rejected", "observed": obs, "pass": ok})

    def detected(self, name, errors):
        """Fault injection: the checker must return at least one error."""
        self.cases["fault_detection"].append({"name": name, "expected": "detected",
                                              "observed": ("detected: " + errors[0]) if errors else "NOT detected",
                                              "pass": bool(errors)})

    def not_applicable(self, kind, reason):
        self.na[kind] = reason


def _fmt(v):
    if isinstance(v, int) and not isinstance(v, bool):
        return "0x%x" % v if v >= 0 else str(v)
    if isinstance(v, (list, tuple)):
        return [_fmt(x) for x in v]
    if isinstance(v, dict):
        return {str(k): _fmt(x) for k, x in v.items()}
    if isinstance(v, (set, frozenset)):
        return sorted(str(x) for x in v)
    return v
