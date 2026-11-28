#!/usr/bin/env python3
# AI-GENERATED (Claude Opus 5.5, 2026-11-28) - candidate artifact (R-117, R-231). Review pending.
"""chk_axil_sb - AXI4-Lite response accounting (IHI 0022H B1, REQ-IF-001/010):
exactly one B per accepted AW+W pair, one R per accepted AR, no orphan response,
legal response codes only (OKAY/SLVERR/DECERR; EXOKAY is illegal on AXI4-Lite)."""


def check(records):
    ch = {}
    errs = []
    for r in records:
        if r.get("type") == "axilch":
            ch[r["ch"]] = ch.get(r["ch"], 0) + 1
    nb = sum(1 for r in records if r.get("type") == "axil" and r["op"] == "write")
    nr = sum(1 for r in records if r.get("type") == "axil" and r["op"] == "read")
    for k in ("B_ORPHAN", "R_ORPHAN"):
        if ch.get(k):
            errs.append("%d %s response(s) without a request" % (ch[k], k[0]))
    if ch.get("AW", 0) != ch.get("W", 0):
        errs.append("AW count %d != W count %d at end of run" % (ch.get("AW", 0), ch.get("W", 0)))
    if nb != min(ch.get("AW", 0), ch.get("W", 0)):
        errs.append("%d B responses for %d write requests" % (nb, min(ch.get("AW", 0), ch.get("W", 0))))
    if nr != ch.get("AR", 0):
        errs.append("%d R responses for %d read requests" % (nr, ch.get("AR", 0)))
    for r in records:
        if r.get("type") == "axil" and r["resp"] not in ("OKAY", "SLVERR", "DECERR"):
            errs.append("illegal AXI4-Lite response %s at cycle %s" % (r["resp"], r.get("cycle")))
    return errs
