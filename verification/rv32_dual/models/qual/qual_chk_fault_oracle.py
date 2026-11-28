# AI-GENERATED (Claude Opus 5.5, 2026-11-27) - candidate; human review pending.
"""Qualification of chk_fault_oracle (plan 5.6)."""
from qual_common import Suite
import chk_fault_oracle as FO

SOURCES = ["chk_fault_oracle.py", "qual/qual_chk_fault_oracle.py"]
KIND = "model"


def run():
    s = Suite()
    r = FO.FaultRecord()
    r.events([{"cycle": 10, "source": "LLC", "hart": None, "bresp": 2, "pa": 0x80001234}])
    s.eq("known_answer", "first LLC SLVERR: sts/info/lo/hi",
         {"cpucl_fault_sts": 0x15, "cpucl_fault_info": 0x22, "cpucl_fault_lo": 0x80001230, "cpucl_fault_hi": 0}, r.regs())
    s.eq("known_answer", "o_int_fault level after first event", True, r.fault_level)
    r.events([{"cycle": 20, "source": "LLC", "hart": None, "bresp": 3, "pa": 0x80005670}])
    s.eq("known_answer", "second event sets multiple, payload unchanged",
         {"cpucl_fault_sts": 0x17, "cpucl_fault_info": 0x22, "cpucl_fault_lo": 0x80001230, "cpucl_fault_hi": 0}, r.regs())
    l1 = FO.FaultRecord()
    l1.events([{"cycle": 5, "source": "L1", "hart": 1, "bresp": 3, "pa": 0x80002000}])
    s.eq("known_answer", "L1 hart 1 DECERR: hart_valid and hart field (DEC-040)",
         {"cpucl_fault_sts": 0x1D, "cpucl_fault_info": 0x131, "cpucl_fault_lo": 0x80002000, "cpucl_fault_hi": 0}, l1.regs())
    sim = FO.FaultRecord()
    sim.events([{"cycle": 7, "source": "LLC", "hart": None, "bresp": 2, "pa": 0x80003000},
                {"cycle": 7, "source": "L1", "hart": 1, "bresp": 2, "pa": 0x80004000},
                {"cycle": 7, "source": "L1", "hart": 0, "bresp": 3, "pa": 0x80005000}])
    s.eq("known_answer", "simultaneous: lowest L1 hart wins, multiple set (DEC-039)",
         (0x1F, 0x031, 0x80005000), (sim.regs()["cpucl_fault_sts"], sim.regs()["cpucl_fault_info"], sim.regs()["cpucl_fault_lo"]))
    hi = FO.FaultRecord()
    hi.events([{"cycle": 1, "source": "LLC", "hart": None, "bresp": 2, "pa": 0x3C000001C}])
    s.eq("boundary", "PA above 4 GiB: lo = PA[31:0] line base, hi[1:0] = PA[33:32] (Q-G0-12)",
         (0xC0000010, 0x3), (hi.regs()["cpucl_fault_lo"], hi.regs()["cpucl_fault_hi"]))
    hi.w1c_coh()
    s.eq("boundary", "cpucl_coh W1C does not clear the record or the level", (True, 0x15), (hi.fault_level, hi.regs()["cpucl_fault_sts"]))
    s.raises("negative", "OKAY response is not a fatal event", lambda: FO.FaultRecord().event({"cycle": 0, "source": "LLC", "hart": None, "bresp": 0, "pa": 0}), ValueError)
    s.eq("negative", "no event: all registers zero, level low",
         ({"cpucl_fault_sts": 0, "cpucl_fault_info": 0, "cpucl_fault_lo": 0, "cpucl_fault_hi": 0}, False), (FO.FaultRecord().regs(), FO.FaultRecord().fault_level))
    rr = FO.FaultRecord()
    rr.events([{"cycle": 1, "source": "LLC", "hart": None, "bresp": 2, "pa": 0x80001000}])
    rr.reset()
    s.eq("reset", "reset clears record and o_int_fault (REQ-RST-001)",
         ({"cpucl_fault_sts": 0, "cpucl_fault_info": 0, "cpucl_fault_lo": 0, "cpucl_fault_hi": 0}, False), (rr.regs(), rr.fault_level))
    exp = r.regs()
    s.eq("known_answer", "control for fault injection: correct readout has no error", [], FO.check(r, exp, 1))
    for name, patch, lvl in [("payload overwritten by second error", {"cpucl_fault_lo": 0x80005670}, 1),
                             ("multiple flag missing", {"cpucl_fault_sts": 0x15}, 1),
                             ("hart_valid set for LLC source", {"cpucl_fault_sts": 0x1F}, 1),
                             ("raw BRESP of second error recorded", {"cpucl_fault_info": 0x32}, 1),
                             ("o_int_fault dropped", {}, 0),
                             ("byte address not line-aligned", {"cpucl_fault_lo": 0x80001234}, 1)]:
        obs = dict(exp)
        obs.update(patch)
        s.detected(name, FO.check(r, obs, lvl))
    return s
