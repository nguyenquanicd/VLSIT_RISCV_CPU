# AI-GENERATED (Claude Opus 5.5, 2026-11-27) - candidate; human review pending.
"""Qualification of chk_csr_model (plan 5.6)."""
from qual_common import Suite
import chk_csr_model as C

SOURCES = ["chk_csr_model.py", "common/xlsx_min.py", "qual/qual_chk_csr_model.py"]
KIND = "model"
WORKBOOK_INPUT = True


def run():
    s = Suite()
    m = C.CsrModel()
    s.eq("known_answer", "register count from workbook (5 control + 3x16 PMU + 4 fault)", 57, len(m.regs))
    s.eq("known_answer", "all mapped registers read reset value 0 with OKAY",
         [("OKAY", 0)] * 57, [m.read(a) for a in sorted(m.regs)])
    s.eq("known_answer", "irq_en full write/read-back", ("OKAY", ("OKAY", 0xDEADBEEF)), (m.write(0x4, 0xDEADBEEF), m.read(0x4)))
    m.reset()
    m.write(0x4, 0x000000FF, strb=0x1)
    m.write(0x4, 0xFFFFFFFF, strb=0x0)
    s.eq("known_answer", "WSTRB honoured; zero strobe changes nothing (REF-001 11.4)", ("OKAY", 0xFF), m.read(0x4))
    s.eq("known_answer", "pmu_evt[0] write all-ones: reserved bits [31:20] read 0", ("OKAY", 0x000FFFFF),
         (m.write(0x1000, 0xFFFFFFFF), m.read(0x1000))[1])
    m.hw_set("irq_raw", "overflow", 0b101)
    m.write(0x4, 0b110)
    s.eq("known_answer", "irq_sts = irq_raw AND irq_en", ("OKAY", 0b100), m.read(0xC))
    m.write(0x8, 0b001)
    s.eq("known_answer", "irq_raw W1C clears written-one bits only", ("OKAY", 0b100), m.read(0x8))
    m.write(0x0, 0x1)
    s.eq("known_answer", "snapshot_req (wo) records a command and reads 0", (("pmu_ctrl", "snapshot_req", 1), ("OKAY", 0)),
         (m.events[-1], m.read(0x0)))
    m.write(0x4000, 0xFFFFFFFF)
    s.eq("known_answer", "write to RO fault record ignored", ("OKAY", 0), m.read(0x4000))
    s.eq("known_answer", "reserved control offset 0x14 -> DECERR, read 0", ("DECERR", 0), m.read(0x14))
    s.eq("known_answer", "pmu_evt[16] reserved with 16 counters (REQ-IF-008)", ("DECERR", 0), m.read(0x1040))
    s.eq("known_answer", "misaligned read -> SLVERR", ("SLVERR", None), m.read(0x2))
    s.eq("known_answer", "misaligned write -> SLVERR, no side effect", ("SLVERR", ("OKAY", 0b110)), (m.write(0x5, 0xFFFFFFFF), m.read(0x4)))
    s.eq("boundary", "last mapped offset 0x400C OKAY; 0x4010 and 0x4FFC reserved", (("OKAY", 0), ("DECERR", 0), ("DECERR", 0)),
         (m.read(0x400C), m.read(0x4010), m.read(0x4FFC)))
    s.eq("boundary", "pmu_count_hi[15] mapped at 0x303C", "OKAY", m.read(0x303C)[0])
    s.eq("boundary", "reserved write returns DECERR without side effect", ("DECERR", ("DECERR", 0)), (m.write(0x14, 0xFFFFFFFF), m.read(0x14)))
    s.raises("negative", "LLC window not modelled (Q-G0-04)", lambda: m.read(0x5000), NotImplementedError)
    s.raises("negative", "outside the 24-KiB aperture is unspecified", lambda: m.read(0x6000), ValueError)
    m.reset()
    s.eq("reset", "reset restores workbook reset values and clears commands", ([("OKAY", 0)] * 57, []),
         ([m.read(a) for a in sorted(m.regs)], m.events))
    log_good = [{"op": "write", "addr": "0x4", "wdata": "0x12345678", "wstrb": 15, "resp": "OKAY"},
                {"op": "read", "addr": "0x4", "resp": "OKAY", "rdata": "0x12345678"},
                {"op": "read", "addr": "0x14", "resp": "DECERR", "rdata": "0x0"}]
    s.eq("known_answer", "control for fault injection: correct log has no error", [], C.check_log(C.CsrModel(), log_good))
    for name, log in [("reserved offset answered OKAY", [{"op": "read", "addr": "0x14", "resp": "OKAY", "rdata": "0x0"}]),
                      ("reserved bits of pmu_evt read nonzero", [{"op": "write", "addr": "0x1000", "wdata": "0xffffffff", "resp": "OKAY"},
                                                                {"op": "read", "addr": "0x1000", "resp": "OKAY", "rdata": "0xffffffff"}]),
                      ("WSTRB ignored", [{"op": "write", "addr": "0x4", "wdata": "0xffffffff", "wstrb": 1, "resp": "OKAY"},
                                         {"op": "read", "addr": "0x4", "resp": "OKAY", "rdata": "0xffffffff"}]),
                      ("misaligned access answered OKAY", [{"op": "write", "addr": "0x6", "wdata": "0x1", "resp": "OKAY"}]),
                      ("RO register modified by write", [{"op": "write", "addr": "0x4008", "wdata": "0x1", "resp": "OKAY"},
                                                         {"op": "read", "addr": "0x4008", "resp": "OKAY", "rdata": "0x1"}]),
                      ("reset value wrong", [{"op": "read", "addr": "0x1004", "resp": "OKAY", "rdata": "0x80000"}])]:
        s.detected(name, C.check_log(C.CsrModel(), log))
    return s
