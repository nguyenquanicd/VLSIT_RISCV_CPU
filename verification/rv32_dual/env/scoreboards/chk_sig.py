#!/usr/bin/env python3
# AI-GENERATED (Claude Opus 5.5, 2026-11-28) - candidate artifact (R-117, R-231). Review pending.
"""chk_sig - signature and trap-record decoder/comparator (plan 5.2).
Reads the memory-BFM dump ('mem' records), the slot map and trap area layout of
scripts/generators/rv32d_lib.py: per hart, trap area word 0 = count, records of
{cause, epc, tval, level(3=M,1=S)} from offset 16."""


def h(v):
    return int(v, 0) if isinstance(v, str) else int(v)


def mem_bytes(records):
    m = {}
    for r in records:
        if r.get("type") != "mem":
            continue
        a, d, n = h(r["addr"]), h(r["data"]), int(r.get("size", 8))
        for i in range(n):
            m[a + i] = (d >> (8 * i)) & 0xFF
    return m


def word(m, a):
    if not all((a + i) in m for i in range(4)):
        return None
    return sum(m[a + i] << (8 * i) for i in range(4))


def traps(m, trap_base, hart):
    base = trap_base + 0x400 * hart
    n = word(m, base)
    if n is None:
        return None
    out = []
    for k in range(min(n, 60)):
        a = base + 16 + 16 * k
        lvl = word(m, a + 12)
        p = "m" if lvl == 3 else "s"
        out.append({"hart": hart, "level": "M" if lvl == 3 else "S", p + "cause": word(m, a), p + "epc": word(m, a + 4), p + "tval": word(m, a + 8)})
    return out


def check_slot(m, addr, expect=None, allowed=None, mask=0xFFFFFFFF):
    v = word(m, addr)
    if v is None:
        return ["slot 0x%08x not present in the memory dump (signature not published)" % addr]
    if allowed is not None:
        return [] if (v & mask) in [a & mask for a in allowed] else ["slot 0x%08x = 0x%08x not in allowed %s" % (addr, v, [hex(a) for a in allowed])]
    return [] if (v & mask) == (expect & mask) else ["slot 0x%08x = 0x%08x expected 0x%08x (mask 0x%x)" % (addr, v, expect, mask)]
