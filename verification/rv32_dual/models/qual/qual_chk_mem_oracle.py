# AI-GENERATED (Claude Opus 5.5, 2026-11-27) - candidate; human review pending.
"""Qualification of chk_mem_oracle (plan 5.6)."""
from qual_common import Suite
import chk_mem_oracle as M

SOURCES = ["chk_mem_oracle.py", "qual/qual_chk_mem_oracle.py"]
KIND = "model"


def run():
    s = Suite()
    m = M.Memory()
    m.store(0x100, 4, 0x11223344)
    s.eq("known_answer", "little-endian: byte 0 of 0x11223344", 0x44, m.load(0x100, 1))
    s.eq("known_answer", "little-endian: half at +2", 0x1122, m.load(0x102, 2))
    m.store(0x100, 4, 0xAABBCCDD, strobe=0b0101)
    s.eq("known_answer", "strobed store keeps unstrobed bytes", 0x11BB33DD, m.load(0x100, 4))
    for op, old, rs2, exp in [("amoswap.w", 1, 2, 2), ("amoadd.w", 0xFFFFFFFF, 2, 1), ("amoxor.w", 0xF0, 0xFF, 0x0F),
                              ("amoand.w", 0xF0, 0x3C, 0x30), ("amoor.w", 0xF0, 0x0F, 0xFF),
                              ("amomin.w", 0xFFFFFFFF, 1, 0xFFFFFFFF), ("amomax.w", 0xFFFFFFFF, 1, 1),
                              ("amominu.w", 0xFFFFFFFF, 1, 1), ("amomaxu.w", 0xFFFFFFFF, 1, 0xFFFFFFFF)]:
        s.eq("known_answer", "%s(old=0x%x, rs2=0x%x)" % (op, old, rs2), exp, M.amo(op, old, rs2))
    m2 = M.Memory()
    s.eq("known_answer", "Memory.amo returns old value", 0, m2.amo("amoadd.w", 0x200, 5))
    s.eq("known_answer", "Memory.amo writes result", 5, m2.load(0x200, 4))
    s.eq("known_answer", "legal finals: last store of each hart", {3, 7}, M.legal_finals(0, [[1, 2, 3], [5, 7]]))
    s.eq("known_answer", "legal finals: no store -> init", {9}, M.legal_finals(9, [[], []]))
    s.eq("known_answer", "AMOADD counter exact (64 + 64 increments)", [], M.check_counter(0, [1] * 128, 128))
    s.eq("known_answer", "image compare match", [], M.compare_image({0x80: 0x1234}, [{"addr": "0x80", "size": 4, "data": "0x1234"}]))
    s.eq("boundary", "AMOADD 32-bit wrap", 0, M.amo("amoadd.w", 0xFFFFFFFF, 1))
    s.eq("boundary", "counter wraps modulo 2^32", [], M.check_counter(0xFFFFFFFF, [1], 0))
    s.eq("boundary", "8-byte image record splits into two words", [],
         M.compare_image({0x0: 0x44332211, 0x4: 0x88776655}, [{"addr": 0, "size": 8, "data": "0x8877665544332211"}]))
    s.raises("negative", "misaligned word load rejected", lambda: M.Memory().load(0x102, 4), ValueError)
    s.raises("negative", "misaligned half store rejected", lambda: M.Memory().store(0x101, 2, 0), ValueError)
    s.raises("negative", "unknown memop", lambda: M.Memory().apply({"op": "fence", "addr": 0}), ValueError)
    r = M.Memory()
    r.store(0x300, 4, 0xCAFEF00D)
    s.eq("reset", "REQ-RST-001: backing memory unchanged across cluster reset", 0xCAFEF00D, r.reset_view().load(0x300, 4))
    s.eq("reset", "unwritten memory reads 0 in a fresh model", 0, M.Memory().load(0x400, 4))
    s.detected("lost AMO increment (127 of 128)", M.check_counter(0, [1] * 128, 127))
    s.detected("stale final value not in legal set",
               [] if 2 in M.legal_finals(0, [[1, 2, 3], [5, 7]]) else ["final 2 not legal"])
    s.detected("byte order swapped in image", M.compare_image({0x80: 0x11223344}, [{"addr": "0x80", "data": "0x44332211"}]))
    s.detected("word missing from image", M.compare_image({0x80: 1, 0x84: 2}, [{"addr": "0x80", "data": "0x1"}]))
    s.detected("LR/SC: success counted without store", M.check_lrsc(0, 10, 1, 9))
    s.detected("wrong AMO old value used (amomin unsigned)",
               [] if M.amo("amomin.w", 0xFFFFFFFF, 1) == 1 else ["signed min returned 0xFFFFFFFF, unsigned would be 1"])
    return s
