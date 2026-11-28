#!/usr/bin/env python3
# -----------------------------------------------------------------------------
# AI-GENERATED (Claude Opus 5.5, 2026-11-28) - candidate artifact (R-117, R-231).
# Shared AXI4 transaction reconstruction for chk_axi_mem_sb / chk_axi_mmio_sb.
# Sources: IHI 0022H A3.2 (handshake), A3.4 (beats = AxLEN+1, WLAST/RLAST),
# A5/A6 (IDs: responses matched to the oldest outstanding request with the same
# ID; AXI4 write data follows write-address order, no write interleaving);
# RV32 HDS 6.2 (address bits 63:34 zero); REF-001 Section 9 (16-byte line,
# two 64-bit beats). Consumes NDJSON 'axi' records (models/README.md).
# -----------------------------------------------------------------------------
"""Rebuild write and read transactions; structural and rule checks."""
import json

CKPT_ADDR = 0x10000200


def h(v):
    return int(v, 0) if isinstance(v, str) else int(v)


def read_ndjson(path):
    out = []
    with open(path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line:
                out.append(json.loads(line))
    return out


def rebuild(records, port):
    """Return (writes, reads, errors). Each transaction: dict with id, addr, len, size,
    burst, lock, atop, cycle, beats [(data, strb)], resp, rsp_cycle."""
    errs = []
    aw_wait_w, writes, b_wait = [], [], {}
    reads, r_wait = [], {}
    w_beats = []
    for r in records:
        if r.get("type") != "axi" or r.get("port") != port:
            continue
        ch = r["ch"]
        if ch == "RST":
            aw_wait_w, w_beats, b_wait, r_wait = [], [], {}, {}
            continue
        if ch == "AW":
            t = {"id": r["id"], "addr": h(r["addr"]), "len": r["len"], "size": r["size"], "burst": r["burst"],
                 "lock": r.get("lock", 0), "atop": r.get("atop", 0), "cycle": r["cycle"], "beats": [], "resp": None}
            aw_wait_w.append(t)
            writes.append(t)
        elif ch == "W":
            w_beats.append((h(r["data"]), r["strb"], r["last"], r["cycle"]))
        elif ch == "B":
            q = b_wait.get(r["id"], [])
            if not q:
                errs.append("%s B id %d cycle %d has no outstanding write (ID association, A5)" % (port, r["id"], r["cycle"]))
                continue
            t = q.pop(0)
            t["resp"], t["rsp_cycle"] = r["resp"], r["cycle"]
        elif ch == "AR":
            t = {"id": r["id"], "addr": h(r["addr"]), "len": r["len"], "size": r["size"], "burst": r["burst"],
                 "lock": r.get("lock", 0), "cycle": r["cycle"], "beats": [], "resp": None}
            reads.append(t)
            r_wait.setdefault(r["id"], []).append(t)
        elif ch == "R":
            q = r_wait.get(r["id"], [])
            if not q:
                errs.append("%s R id %d cycle %d has no outstanding read (ID association, A5)" % (port, r["id"], r["cycle"]))
                continue
            t = q[0]
            t["beats"].append((h(r["data"]), 0xFF))
            t["resp"] = r["resp"] if t["resp"] in (None, 0, 1) else t["resp"]
            if r["last"]:
                q.pop(0)
                t["rsp_cycle"] = r["cycle"]
                if len(t["beats"]) != t["len"] + 1:
                    errs.append("%s read id %d addr 0x%x: %d beats, expected %d (A3.4)" % (port, t["id"], t["addr"], len(t["beats"]), t["len"] + 1))
        # attach W beats to the oldest write address (no interleaving in AXI4)
        while aw_wait_w and w_beats:
            t = aw_wait_w[0]
            d, s, last, cyc = w_beats.pop(0)
            t["beats"].append((d, s))
            if last or len(t["beats"]) == t["len"] + 1:
                if bool(last) != (len(t["beats"]) == t["len"] + 1):
                    errs.append("%s write addr 0x%x: WLAST on beat %d, expected beat %d (A3.4)" % (port, t["addr"], len(t["beats"]), t["len"] + 1))
                aw_wait_w.pop(0)
                b_wait.setdefault(t["id"], []).append(t)
    for t in writes + reads:
        if t["addr"] >> 34:
            errs.append("%s addr 0x%x has bits 63:34 set (REQ-XL-006)" % (port, t["addr"]))
    return writes, reads, errs


def checkpoints(records):
    """MMIO writes to the checkpoint register: list of (value, cycle)."""
    w, _, _ = rebuild(records, "mmio")
    out = []
    for t in w:
        if t["addr"] == CKPT_ADDR and t["beats"]:
            d, s = t["beats"][0]
            out.append((d & 0xFFFFFFFF, t["cycle"]))
    return out


def window(cks, win):
    """win = [start_value|None, end_value|None] -> (lo_cycle, hi_cycle)."""
    lo, hi = 0, float("inf")
    if win and win[0] is not None:
        c = [cy for v, cy in cks if v == win[0]]
        if not c:
            return None
        lo = c[0]
    if win and len(win) > 1 and win[1] is not None:
        c = [cy for v, cy in cks if v == win[1] and cy >= lo]
        if not c:
            return None
        hi = c[0]
    return lo, hi


def line_bytes(t):
    """Byte map of a write transaction: {byte_addr: value}."""
    out = {}
    nb = 1 << t["size"]
    base = (t["addr"] // nb) * nb
    for i, (d, s) in enumerate(t["beats"]):
        a = t["addr"] if i == 0 else base + nb * i
        for b in range(8):
            if (s >> b) & 1:
                out[(a & ~7) + b] = (d >> (8 * b)) & 0xFF
    return out


def overlaps(t, lo, hi):
    nb = 1 << t["size"]
    end = t["addr"] + nb * (t["len"] + 1) - 1
    return t["addr"] <= hi and end >= lo


def check_rules(records, port, rules):
    """rules: list of dicts; returns list of (rule_index, errors)."""
    writes, reads, errs = rebuild(records, port)
    cks = checkpoints(records)
    results = []
    for i, r in enumerate(rules):
        e = []
        win = window(cks, r.get("window"))
        if win is None:
            results.append((i, ["checkpoint window %s not found in the MMIO log" % r.get("window")]))
            continue
        lo_c, hi_c = win
        in_w = lambda t: lo_c <= t["cycle"] <= hi_c
        k = r["kind"]
        if k == "write_line":
            a = r["addr"] & ~0xF
            cands = [t for t in writes if in_w(t) and overlaps(t, a, a + 15)]
            if not cands:
                e.append("no write to line 0x%x in window %s" % (a, r.get("window")))
            else:
                t = cands[-1]
                if "beats" in r and len(t["beats"]) != r["beats"]:
                    e.append("line 0x%x written with %d beats, expected %d (REQ-XL-012)" % (a, len(t["beats"]), r["beats"]))
                if r.get("strobe_full") and any(s != 0xFF for _, s in t["beats"]):
                    e.append("line 0x%x written with partial strobes" % a)
                if "data" in r:
                    bm = line_bytes(t)
                    exp = bytes.fromhex(r["data"])
                    got = bytes(bm.get(a + j, 0) for j in range(16))
                    if got != exp:
                        e.append("line 0x%x data %s expected %s" % (a, got.hex(), exp.hex()))
                if "resp" in r and t["resp"] != r["resp"]:
                    e.append("line 0x%x B resp %s expected %s" % (a, t["resp"], r["resp"]))
                if "count" in r and len(cands) != r["count"]:
                    e.append("line 0x%x written %d times in window, expected %d" % (a, len(cands), r["count"]))
        elif k in ("no_write", "no_read"):
            pool = writes if k == "no_write" else reads
            hits = [t for t in pool if in_w(t) and overlaps(t, r["lo"], r["hi"])]
            if hits:
                e.append("%s: %d transaction(s) to 0x%x-0x%x in window %s (first addr 0x%x)" % (k, len(hits), r["lo"], r["hi"], r.get("window"), hits[0]["addr"]))
        elif k == "read_present":
            if not [t for t in reads if in_w(t) and overlaps(t, r["lo"], r["hi"])]:
                e.append("no read of 0x%x-0x%x in window %s" % (r["lo"], r["hi"], r.get("window")))
        elif k == "write_present":
            hits = [t for t in writes if in_w(t) and overlaps(t, r["lo"], r["hi"])]
            if not hits:
                e.append("no write to 0x%x-0x%x in window %s" % (r["lo"], r["hi"], r.get("window")))
            elif "data32" in r:
                bm = line_bytes(hits[-1])
                got = sum(bm.get(r["lo"] + j, 0) << (8 * j) for j in range(4))
                if got != r["data32"]:
                    e.append("write data 0x%08x expected 0x%08x" % (got, r["data32"]))
        elif k == "lock":
            pool = writes if r.get("dir") == "w" else reads
            hits = [t for t in pool if in_w(t) and overlaps(t, r["lo"], r["hi"])]
            if not hits or any(not t["lock"] for t in hits):
                e.append("exclusive access not signalled (AxLOCK) for 0x%x" % r["lo"])
        elif k == "atop":
            hits = [t for t in writes if in_w(t) and overlaps(t, r["lo"], r["hi"]) and t["atop"]]
            if len(hits) < r.get("min", 1):
                e.append("expected >= %d AWATOP transaction(s) to 0x%x, saw %d" % (r.get("min", 1), r["lo"], len(hits)))
        elif k == "structural":
            e.extend(errs)
            incomplete = [t for t in writes if t["resp"] is None and len(t["beats"]) == t["len"] + 1] if r.get("complete") else []
            if incomplete:
                e.append("%d write(s) without B response at end of run" % len(incomplete))
        else:
            e.append("unknown rule kind %r" % k)
        results.append((i, e))
    return results
