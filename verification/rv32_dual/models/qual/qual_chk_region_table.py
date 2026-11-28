# AI-GENERATED (Claude Opus 5.5, 2026-11-28) - candidate; human review pending.
"""Qualification of chk_region_table (plan 5.6; Q-G0-09; REF-001 rev 0.40 14.4.20 rules 1-5)."""
import copy
import re
from qual_common import Suite
import chk_region_table as R

SOURCES = ["chk_region_table.py", "configs/region_table_campaign.json", "qual/qual_chk_region_table.py"]
KIND = "checker"

# Elaboration form copied from REF-001 rev 0.40 Section 14.4.20 (independent known answer for sv_params)
SPEC_FORM = {
    "PARA_ADDR_REGION_NUM": "32'd5",
    "PARA_ADDR_REGION_BASE_LO": "'{0:32'h8000_0000, 1:32'h1000_0000, 2:32'h0000_0000, 3:32'h4000_0000, 4:32'hC000_0000, default:32'd0}",
    "PARA_ADDR_REGION_BASE_HI": "'{4:32'h0000_0003, default:32'd0}",
    "PARA_ADDR_REGION_SIZE_LO": "'{0:32'h4000_0000, 1:32'h1000_0000, 2:32'h0000_1000, 3:32'h1000_0000, 4:32'h4000_0000, default:32'd0}",
    "PARA_ADDR_REGION_SIZE_HI": "'{default:32'd0}",
    "PARA_ADDR_REGION_TYPE": "'{0:32'd0, 1:32'd2, 2:32'd2, 3:32'd1, 4:32'd1, default:32'd0}",
}


def parse_sv(text):
    """Normalise an SV assignment-pattern string to {index: value} (+ default) for comparison."""
    out = {}
    for m in re.finditer(r"(\d+|default):32'([hd])([0-9A-Fa-f_]+)", text):
        out[m.group(1)] = int(m.group(3).replace("_", ""), 16 if m.group(2) == "h" else 10)
    if not out:
        m = re.match(r"32'd(\d+)", text.strip())
        out["value"] = int(m.group(1))
    return {k: v for k, v in out.items() if v != 0 or k == "default" or k == "value"}


def sv_from_model(cfg):
    got = {}
    for line in R.sv_params(cfg).splitlines():
        m = re.match(r"\s*,?\s*\.(\w+)\s*\((.*)\)\s*$", line)
        got[m.group(1)] = parse_sv(m.group(2))
    return got


def run():
    s = Suite()
    cfg = R.load()
    s.eq("known_answer", "campaign parameter set (14.4.20 example) satisfies rules 1-5 and 2^34", [], R.check_table(cfg))
    s.eq("known_answer", "SV parameter form equals the 14.4.20 elaboration form",
         {k: parse_sv(v) for k, v in SPEC_FORM.items()}, sv_from_model(cfg))
    for addr, n, atomic, exp in [(0x80000000, 4, False, ("cacheable", 0)), (0xBFFFFFFC, 4, False, ("cacheable", 0)),
                                 (0x10000000, 4, False, ("mmio", 1)), (0x800, 4, False, ("mmio", 2)),
                                 (0x40000000, 4, True, ("normal_uncached", 3)), (0x3FFFFFFFC, 4, False, ("normal_uncached", 4)),
                                 (0x3FFFFFFFC, 8, False, ("error", "boundary crossing")), (0x20000000, 4, False, ("error", "unmapped")),
                                 (0x10000000, 4, True, ("error", "atomic to MMIO")), (0xC0000000, 4, False, ("error", "unmapped"))]:
        s.eq("known_answer", "classify 0x%x/%d atomic=%s" % (addr, n, atomic), exp, R.classify(cfg, addr, n, atomic))
    s.eq("known_answer", "CLI on the campaign table returns 0", 0, R.main([]))
    edge = copy.deepcopy(cfg)
    s.eq("boundary", "entry ending exactly at 2^34 accepted", [], R.check_table(edge))
    one = {"num": 1, "entries": [cfg["entries"][0]]}
    s.eq("boundary", "REF-001 default table (NUM=1, cacheable 0x80000000/1 GiB) accepted", [], R.check_table(one))
    inact = copy.deepcopy(cfg)
    inact["entries"].append({"class": "reserved", "type_word": "0xFFFFFFFF", "base": "0x20000000", "size": "0x0"})  # invalid entry above NUM at an unmapped address
    s.eq("boundary", "entries above PARA_ADDR_REGION_NUM are ignored", [], R.check_table(inact))
    s.eq("boundary", "inactive entry is not used by classify", ("error", "unmapped"), R.classify(inact, 0x20000000, 1))
    s.eq("boundary", "NUM=16 accepted when 16 valid entries exist", [], R.check_table(
        {"num": 16, "entries": [cfg["entries"][0]] + [{"class": "mmio", "base": hex(0x1000 * i), "size": "0x1000"} for i in range(15)]}))
    s.not_applicable("reset", "static configuration check")
    s.not_applicable("negative", "covered by the fault_detection mutated tables")
    muts = []

    def mut(name, fn):
        c = copy.deepcopy(cfg)
        fn(c)
        muts.append((name, c))
    mut("rule 1: PARA_ADDR_REGION_NUM = 0", lambda c: c.__setitem__("num", 0))
    mut("rule 1: PARA_ADDR_REGION_NUM = 17", lambda c: c.__setitem__("num", 17))
    mut("rule 2: base not 16-byte aligned", lambda c: c["entries"][1].__setitem__("base", "0x10000008"))
    mut("rule 2: zero length", lambda c: c["entries"][2].__setitem__("size", "0x0"))
    mut("rule 2: length not a multiple of 16", lambda c: c["entries"][2].__setitem__("size", "0x1008"))
    mut("rule 2: base[63:56] nonzero", lambda c: c["entries"][3].__setitem__("base", "0x0100000040000000"))
    mut("rule 3: TYPE[31:2] nonzero", lambda c: c["entries"][1].__setitem__("type_word", "0x6"))
    mut("rule 3: class 2'b11 reserved", lambda c: c["entries"][3].update({"class": "reserved", "type_word": "0x3"}))
    mut("rule 4: entry 3 overlaps entry 0", lambda c: c["entries"][3].__setitem__("base", "0x80000000"))
    mut("rule 5: cacheable entry not at index 0", lambda c: (c["entries"][0].update({"class": "normal_uncached", "type_word": "0x1"}),
                                                           c["entries"][3].update({"class": "cacheable", "type_word": "0x0"})))
    mut("rule 5: second cacheable entry", lambda c: c["entries"][3].update({"class": "cacheable", "type_word": "0x0"}))
    mut("rule 5: no cacheable entry", lambda c: c["entries"][0].update({"class": "normal_uncached", "type_word": "0x1"}))
    mut("rule 5: cacheable length not a power of two", lambda c: c["entries"][0].__setitem__("size", "0x30000000"))
    mut("rule 5: cacheable base not aligned to its length", lambda c: c["entries"][0].update({"base": "0x90000000", "size": "0x20000000"}))
    mut("XL-011: entry 4 ends at 2^34 + 16 (Q-G0-09)", lambda c: c["entries"][4].__setitem__("size", "0x40000010"))
    mut("XL-011: static execute region beyond 2^34", lambda c: c["static_execute_regions"]["regions"].append({"base": "0x3FFFFF000", "size": "0x2000"}))
    for name, c in muts:
        s.detected(name, R.check_table(c))
    bad_sv = copy.deepcopy(cfg)
    bad_sv["entries"][4]["base"] = "0xC0000000"           # dropped BASE_HI word
    s.detected("SV form loses BASE_HI of entry 4", [] if sv_from_model(bad_sv) == {k: parse_sv(v) for k, v in SPEC_FORM.items()} else ["SV form differs from 14.4.20"])
    return s
