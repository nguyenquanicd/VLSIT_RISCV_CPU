# AI-GENERATED (Claude Opus 5.5, 2026-11-27) - candidate; human review pending.
"""Qualification of chk_trap_oracle (plan 5.6)."""
from qual_common import Suite
import chk_trap_oracle as T

SOURCES = ["chk_trap_oracle.py", "qual/qual_chk_trap_oracle.py"]
KIND = "model"


def rec(hart, level, cause, epc, tval):
    p = "m" if level == "M" else "s"
    return {"type": "trap", "hart": hart, "level": level, p + "cause": hex(cause), p + "epc": hex(epc), p + "tval": hex(tval)}


def run():
    s = Suite()
    e = T.expected_trap(1, "exception", T.EXC["store_access"], 0x80201040, 0x90000007)
    s.eq("known_answer", "REF-001 10.2.3 CBO.CLEAN example: cause 7, epc 0x80201040, tval 0x90000007",
         {"hart": 1, "level": "M", "cause": 7, "epc": 0x80201040, "tval": 0x90000007}, e)
    s.eq("known_answer", "illegal instruction cause 2", 2, T.mcause_value("exception", T.EXC["illegal"]))
    s.eq("known_answer", "FENCE.I maintenance cause 24 (REQ-MEM-018)", 24, T.mcause_value("exception", T.EXC["maint_fencei"]))
    s.eq("known_answer", "RV32 machine external interrupt mcause", 0x8000000B, T.mcause_value("interrupt", T.IRQ["mei"]))
    s.eq("known_answer", "RV32 machine software interrupt mcause", 0x80000003, T.mcause_value("interrupt", T.IRQ["msi"]))
    s.eq("known_answer", "store page fault cause 15 (Q-G0-08)", 15, T.EXC["store_page"])
    s.eq("known_answer", "load access fault cause 5 (Q-G0-06)", 5, T.EXC["load_access"])
    s.eq("known_answer", "U ecall delegated by medeleg bit 8 -> S", "S", T.target_level("exception", 8, "U", medeleg=1 << 8))
    s.eq("known_answer", "SEI delegated by mideleg bit 9 from S -> S", "S", T.target_level("interrupt", 9, "S", mideleg=1 << 9))
    s.eq("boundary", "trap from M is never delegated even with medeleg set", "M", T.target_level("exception", 7, "M", medeleg=0xFFFF))
    s.eq("boundary", "undelegated trap from U goes to M", "M", T.target_level("exception", 13, "U", medeleg=0))
    s.eq("boundary", "tval None is not compared", [], T.compare([T.expected_trap(0, "exception", 2, 0x80000000, None)],
                                                                [rec(0, "M", 2, 0x80000000, 0x12345678)]))
    exp = [T.expected_trap(0, "exception", 7, 0x80000100, 0x90000007), T.expected_trap(1, "exception", 24, 0x80000200, 0x80001230)]
    obs = [rec(0, "M", 7, 0x80000100, 0x90000007), rec(1, "M", 24, 0x80000200, 0x80001230)]
    s.eq("known_answer", "two-hart compare, matching records", [], T.compare(exp, obs))
    s.raises("negative", "unknown trap kind", lambda: T.mcause_value("fault", 1), ValueError)
    s.eq("negative", "no traps expected, none observed", [], T.compare([], []))
    s.not_applicable("reset", "stateless comparison; trap records of a run after reset form a new list")
    for name, o in [("wrong cause (5 instead of 7)", [rec(0, "M", 5, 0x80000100, 0x90000007), obs[1]]),
                    ("epc points to next instruction", [rec(0, "M", 7, 0x80000104, 0x90000007), obs[1]]),
                    ("tval aligned instead of original EA", [rec(0, "M", 7, 0x80000100, 0x90000000), obs[1]]),
                    ("trap taken in S instead of M", [dict(rec(0, "S", 7, 0x80000100, 0x90000007)), obs[1]]),
                    ("missing trap on hart 1", [obs[0]]),
                    ("extra trap (younger instruction faulted too)", obs + [rec(0, "M", 7, 0x80000104, 0x90000007)]),
                    ("FENCE.I tval not the aligned line base", [obs[0], rec(1, "M", 24, 0x80000200, 0x80001234)])]:
        s.detected(name, T.compare(exp, o))
    return s
