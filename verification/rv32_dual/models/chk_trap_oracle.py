#!/usr/bin/env python3
# -----------------------------------------------------------------------------
# AI-GENERATED (Claude Opus 5.5, 2026-11-27) - candidate artifact (R-117, R-231).
# Sources: RISC-V Privileged ISA (mcause/scause encoding for XLEN=32, exception
# and interrupt codes, medeleg/mideleg delegation rules); REF-001 rev 0.39
# REQ-MEM-017 (CBO fault cause 7), REQ-MEM-018 (FENCE.I cause 24, REF-014),
# Section 10.2.3 example; question_log Q-G0-06 (cause 5/7 for bus errors),
# Q-G0-08 (Sv32 A/D page faults). No RTL used. Human review: pending.
# -----------------------------------------------------------------------------
"""chk_trap_oracle - expected trap state per trap record (plan 5.2).

expected_trap(kind, code, epc, tval, from_priv, medeleg, mideleg) gives the
target level and CSR values; compare(expected, observed) matches lists of trap
records by (hart, sequence) and reports missing, extra and mismatching traps.
"""
EXC = {"inst_misaligned": 0, "inst_access": 1, "illegal": 2, "breakpoint": 3, "load_misaligned": 4,
       "load_access": 5, "store_misaligned": 6, "store_access": 7, "ecall_u": 8, "ecall_s": 9,
       "ecall_m": 11, "inst_page": 12, "load_page": 13, "store_page": 15,
       "maint_fencei": 24}                      # REF-001 REQ-MEM-018 / REF-014 custom code
IRQ = {"ssi": 1, "msi": 3, "sti": 5, "mti": 7, "sei": 9, "mei": 11}
PRIV = {"U": 0, "S": 1, "M": 3}


def mcause_value(kind, code):
    """RV32: interrupt bit is bit 31."""
    if kind == "interrupt":
        return (1 << 31) | code
    if kind != "exception":
        raise ValueError(kind)
    return code


def target_level(kind, code, from_priv, medeleg=0, mideleg=0):
    """Privileged ISA: a trap is never taken to a lower privilege than the current
    one; a delegated trap from S or U goes to S, otherwise to M."""
    deleg = (mideleg if kind == "interrupt" else medeleg) >> code & 1
    if deleg and PRIV[from_priv] <= PRIV["S"]:
        return "S"
    return "M"


def expected_trap(hart, kind, code, epc, tval, from_priv="M", medeleg=0, mideleg=0):
    lvl = target_level(kind, code, from_priv, medeleg, mideleg)
    return {"hart": hart, "level": lvl, "cause": mcause_value(kind, code), "epc": epc & 0xFFFFFFFF,
            "tval": None if tval is None else tval & 0xFFFFFFFF}


def observed_view(rec):
    """Normalise an NDJSON 'trap' record to the level-specific CSR view."""
    h = lambda k: None if rec.get(k) is None else (int(rec[k], 0) if isinstance(rec[k], str) else int(rec[k]))
    lvl = rec["level"]
    p = "m" if lvl == "M" else "s"
    return {"hart": int(rec["hart"]), "level": lvl, "cause": h(p + "cause"), "epc": h(p + "epc"), "tval": h(p + "tval")}


def compare(expected, observed):
    """expected: list of expected_trap dicts; observed: list of NDJSON trap records.
    Records are matched per hart in order. tval None in expected means 'not checked'."""
    errs = []
    harts = sorted({e["hart"] for e in expected} | {int(o["hart"]) for o in observed})
    for h in harts:
        ex = [e for e in expected if e["hart"] == h]
        ob = [observed_view(o) for o in observed if int(o["hart"]) == h]
        for i in range(max(len(ex), len(ob))):
            if i >= len(ob):
                errs.append("hart %d: missing trap #%d (cause 0x%x)" % (h, i, ex[i]["cause"]))
                continue
            if i >= len(ex):
                errs.append("hart %d: unexpected trap #%d (cause 0x%x)" % (h, i, ob[i]["cause"] or 0))
                continue
            e, o = ex[i], ob[i]
            for k in ("level", "cause", "epc", "tval"):
                if k == "tval" and e[k] is None:
                    continue
                if e[k] != o[k]:
                    errs.append("hart %d trap #%d: %s %r expected %r" % (h, i, k, o[k], e[k]))
    return errs
