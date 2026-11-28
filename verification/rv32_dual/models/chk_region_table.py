#!/usr/bin/env python3
# -----------------------------------------------------------------------------
# AI-GENERATED (Claude Opus 5.5, 2026-11-28) - candidate artifact (R-117, R-231).
# Sources: REF-001 rev 0.40 Section 14.4.20 "TOP address-region parameters"
# (six parameters, unpacked [0:15] arrays, index = entry, TYPE[1:0] class
# 00 cacheable / 01 normal uncached / 10 MMIO / 11 reserved, TYPE[31:2] = 0,
# validity rules 1-5, cluster-profile bound base + length <= 2^34, example
# parameter set); RV32 HDS rev 0.4 REQ-XL-011 and Section 8.2 (static execute
# regions); REF-001 Section 14.4.13 (full-window match, boundary crossing and
# MMIO atomic errors); question_log Q-G0-03, Q-G0-09 C, Q-G3-01 follow-up.
# No RTL used. Human review pending.
# -----------------------------------------------------------------------------
"""chk_region_table - pre-build region-table check, access classifier and the
SystemVerilog parameter form of REF-001 14.4.20.

Usage: python chk_region_table.py [CONFIG.json]   (exit 0 = accepted, 1 = rejected)
"""
import json
import os
import sys

BOUND_RV32 = 1 << 34   # REQ-XL-011 / 14.4.20 cluster-profile bound
BOUND_PLEN = 1 << 56   # 14.4.20 rule 2 (PLEN = 56)
CLASS_CODE = {"cacheable": 0, "normal_uncached": 1, "mmio": 2, "reserved": 3}
CODE_CLASS = {v: k for k, v in CLASS_CODE.items()}
DEFAULT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "configs", "region_table_campaign.json")


def _int(v):
    return int(v, 0) if isinstance(v, str) else int(v)


def type_word(e):
    """TYPE[i]: explicit 'type_word' if given, else the class code (bits 31:2 zero)."""
    return _int(e["type_word"]) if "type_word" in e else CLASS_CODE[e["class"]]


def check_table(cfg, profile_bound=BOUND_RV32):
    """Return a list of rule violations (empty = valid). Rule numbers follow REF-001 14.4.20."""
    errs = []
    ents = cfg.get("entries", [])
    num = _int(cfg.get("num", len(ents)))
    if not 1 <= num <= 16:                                           # rule 1 (elaboration error in RTL)
        errs.append("rule 1: PARA_ADDR_REGION_NUM %d outside 1..16" % num)
        return errs
    if num > len(ents):
        errs.append("rule 1: PARA_ADDR_REGION_NUM %d exceeds the %d entries given" % (num, len(ents)))
        return errs
    active = ents[:num]
    spans = []
    for i, e in enumerate(active):
        base, size, tw = _int(e["base"]), _int(e["size"]), type_word(e)
        cls = tw & 3
        if base % 16 or size == 0 or size % 16:                       # rule 2
            errs.append("rule 2: entry %d base/length not 16-byte aligned or length zero" % i)
        if base >> 56:
            errs.append("rule 2: entry %d base[63:56] not zero" % i)
        if base + size > BOUND_PLEN:
            errs.append("rule 2: entry %d base + length exceeds 2^56" % i)
        if tw >> 2:                                                  # rule 3
            errs.append("rule 3: entry %d TYPE[31:2] = 0x%x not zero" % (i, tw >> 2))
        if cls == 3:
            errs.append("rule 3: entry %d class 2'b11 is reserved" % i)
        if "class" in e and CLASS_CODE.get(e["class"]) != cls:
            errs.append("entry %d: class name %r disagrees with TYPE[1:0]=%d" % (i, e["class"], cls))
        if base + size > profile_bound:                              # XL-011 cluster-profile bound
            errs.append("XL-011: entry %d base + length 0x%x exceeds 2^34" % (i, base + size))
        spans.append((base, base + size, i, cls, size))
    srt = sorted(spans)
    for (b0, e0, i0, _, _), (b1, e1, i1, _, _) in zip(srt, srt[1:]):  # rule 4
        if b1 < e0:
            errs.append("rule 4: entries %d and %d overlap" % (i0, i1))
    cache = [s for s in spans if s[3] == 0]                          # rule 5
    if len(cache) != 1 or cache[0][2] != 0:
        errs.append("rule 5: exactly one cacheable (class 00) entry is required and it must be entry 0 (found %s)" % [s[2] for s in cache])
    if cache:
        b, _, i, _, size = cache[0]
        if size & (size - 1):
            errs.append("rule 5: cacheable entry %d length 0x%x is not a power of two" % (i, size))
        elif b % size:
            errs.append("rule 5: cacheable entry %d base 0x%x not aligned to its length 0x%x" % (i, b, size))
    for j, r in enumerate(cfg.get("static_execute_regions", {}).get("regions", [])):
        if _int(r["base"]) + _int(r["size"]) > profile_bound:
            errs.append("XL-011: static execute region %d exceeds 2^34" % j)
    return errs


def classify(cfg, addr, nbytes=1, atomic=False):
    """Return (class, index) or ('error', reason) for an access window (active entries only)."""
    end = addr + nbytes
    num = _int(cfg.get("num", len(cfg["entries"])))
    for i, e in enumerate(cfg["entries"][:num]):
        b, s = _int(e["base"]), _int(e["size"])
        if b <= addr < b + s:
            if end > b + s:
                return "error", "boundary crossing"
            cls = CODE_CLASS[type_word(e) & 3]
            if atomic and cls == "mmio":
                return "error", "atomic to MMIO"
            return cls, i
    return "error", "unmapped"


def sv_params(cfg, leading_comma=True):
    """The six TOP parameter overrides in the elaboration form of REF-001 14.4.20."""
    num = _int(cfg.get("num", len(cfg["entries"])))
    act = cfg["entries"][:num]

    def arr(vals):
        items = ["%d:32'h%08X" % (i, v) for i, v in enumerate(vals) if v]
        return "'{%s}" % ", ".join(items + ["default:32'd0"])
    base = [_int(e["base"]) for e in act]
    size = [_int(e["size"]) for e in act]
    lines = [".PARA_ADDR_REGION_NUM     (32'd%d)" % num,
             ".PARA_ADDR_REGION_BASE_LO (%s)" % arr([b & 0xFFFFFFFF for b in base]),
             ".PARA_ADDR_REGION_BASE_HI (%s)" % arr([b >> 32 for b in base]),
             ".PARA_ADDR_REGION_SIZE_LO (%s)" % arr([s & 0xFFFFFFFF for s in size]),
             ".PARA_ADDR_REGION_SIZE_HI (%s)" % arr([s >> 32 for s in size]),
             ".PARA_ADDR_REGION_TYPE    (%s)" % arr([type_word(e) for e in act])]
    return "".join(("    , " if leading_comma or k else "      ") + l + "\n" for k, l in enumerate(lines))


def load(path=DEFAULT):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def main(argv=None):
    argv = sys.argv[1:] if argv is None else argv
    cfg = load(argv[0] if argv else DEFAULT)
    errs = check_table(cfg)
    for e in errs:
        print("REJECT: %s" % e)
    print("RESULT: %s (%d active entries)" % ("ACCEPTED" if not errs else "REJECTED", _int(cfg.get("num", len(cfg.get("entries", []))))))
    return 0 if not errs else 1


if __name__ == "__main__":
    sys.exit(main())
