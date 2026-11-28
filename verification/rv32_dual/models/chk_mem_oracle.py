#!/usr/bin/env python3
# -----------------------------------------------------------------------------
# AI-GENERATED (Claude Opus 5.5, 2026-11-27) - candidate artifact (R-117, R-231).
# Sources: RISC-V Unprivileged ISA (little-endian byte order, store widths,
# 'A' extension AMO*.W semantics, LR/SC reservation rules, RVWMO coherence:
# per-location total order of writes), REF-001 rev 0.39 Sections 5.4/10.2.1
# (MESI data coherence), REF-001 REQ-RST-001 (backing memory not cleared by
# reset). No RTL used. Human review: pending.
# -----------------------------------------------------------------------------
"""chk_mem_oracle - per-address value model and allowed final values (plan 5.2).

* Memory: sparse little-endian byte memory with store/AMO application.
* amo(op, old, rs2): 32-bit AMO result (value written) per the A extension.
* legal_finals(init, per_hart_store_seqs): set of final values allowed by
  coherence when harts store to one word without synchronisation.
* check_counter(init, contributions, final): exact AMOADD accounting.
* compare_image(expected, observed_records): word-level image comparison.
"""
M32 = 0xFFFFFFFF


def s32(x):
    x &= M32
    return x - (1 << 32) if x & 0x80000000 else x


def amo(op, old, rs2):
    old, rs2 = old & M32, rs2 & M32
    return {
        "amoswap.w": rs2, "amoadd.w": (old + rs2) & M32, "amoxor.w": old ^ rs2, "amoand.w": old & rs2,
        "amoor.w": old | rs2, "amomin.w": old if s32(old) < s32(rs2) else rs2,
        "amomax.w": old if s32(old) > s32(rs2) else rs2, "amominu.w": min(old, rs2), "amomaxu.w": max(old, rs2),
    }[op]


class Memory:
    """Sparse byte memory; unwritten bytes read as the init value (default 0)."""

    def __init__(self, init=None):
        self.bytes = dict(init or {})

    def reset_view(self):
        """REQ-RST-001: backing memory is not cleared by cluster reset."""
        return Memory(self.bytes)

    def load(self, addr, size):
        if addr % size:
            raise ValueError("misaligned load 0x%x size %d" % (addr, size))
        return sum(self.bytes.get(addr + i, 0) << (8 * i) for i in range(size))

    def store(self, addr, size, value, strobe=None):
        if addr % size:
            raise ValueError("misaligned store 0x%x size %d" % (addr, size))
        for i in range(size):
            if strobe is None or (strobe >> i) & 1:
                self.bytes[addr + i] = (value >> (8 * i)) & 0xFF

    def amo(self, op, addr, rs2):
        old = self.load(addr, 4)
        self.store(addr, 4, amo(op, old, rs2))
        return old

    def apply(self, rec):
        """Apply an NDJSON 'memop' record {op: store|amo, addr, size, data|rs2, amo_op?}."""
        a = int(rec["addr"], 0) if isinstance(rec["addr"], str) else int(rec["addr"])
        if rec["op"] == "store":
            d = int(rec["data"], 0) if isinstance(rec["data"], str) else int(rec["data"])
            self.store(a, int(rec["size"]), d)
            return None
        if rec["op"] == "amo":
            v = int(rec["rs2"], 0) if isinstance(rec["rs2"], str) else int(rec["rs2"])
            return self.amo(rec["amo_op"], a, v)
        raise ValueError(rec["op"])


def legal_finals(init, per_hart_store_seqs):
    """Coherence: the final value of a location is the last write in its total
    write order; per-hart program order is preserved in that order, so the final
    value is the last store of some hart that stored, or init if none stored."""
    finals = {seq[-1] & M32 for seq in per_hart_store_seqs if seq}
    return finals or {init & M32}


def legal_read_values(init, per_hart_store_seqs):
    """Any value written to the location, or init, may be read without sync."""
    vals = {init & M32}
    for seq in per_hart_store_seqs:
        vals |= {v & M32 for v in seq}
    return vals


def check_counter(init, contributions, final):
    exp = (init + sum(contributions)) & M32
    return [] if (final & M32) == exp else ["counter final 0x%08x expected 0x%08x" % (final & M32, exp)]


def check_lrsc(init, sc_success_count, increment, final):
    """LR/SC increment loops: every successful SC adds 'increment' exactly once."""
    return check_counter(init, [increment] * sc_success_count, final)


def compare_image(expected, observed):
    """expected: {word_addr: value}; observed: iterable of NDJSON 'mem' records {addr, size, data}."""
    obs = {}
    for r in observed:
        a = int(r["addr"], 0) if isinstance(r["addr"], str) else int(r["addr"])
        d = int(r["data"], 0) if isinstance(r["data"], str) else int(r["data"])
        size = int(r.get("size", 4))
        for i in range(0, size, 4):
            obs[a + i] = (d >> (8 * i)) & M32
    errs = []
    for a in sorted(expected):
        if a not in obs:
            errs.append("word 0x%08x missing from observed image" % a)
        elif obs[a] != expected[a] & M32:
            errs.append("word 0x%08x = 0x%08x expected 0x%08x" % (a, obs[a], expected[a] & M32))
    return errs
