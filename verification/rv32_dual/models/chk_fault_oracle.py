#!/usr/bin/env python3
# -----------------------------------------------------------------------------
# AI-GENERATED (Claude Opus 5.5, 2026-11-27) - candidate artifact (R-117, R-231).
# Sources: REF-001 rev 0.39 REQ-ERR-003, Section 12, DEC-039/DEC-040, REQ-RST-001;
# CSR workbook AXIL_QUEUED cpucl_fault_sts/info/lo/hi and cpucl_coh;
# question_log Q-G0-12 (lo = PA[31:0] of the line base, hi[23:0] = PA[55:32]).
# No RTL used. Human review: pending.
# -----------------------------------------------------------------------------
"""chk_fault_oracle - first-fatal record and o_int_fault model (plan 5.2).

Event: {'cycle', 'source': 'L1'|'LLC', 'hart': int|None, 'bresp': 2|3, 'pa': int}
Simultaneous events (same cycle): lowest active L1 hart first, then LLC (DEC-039).
addr_valid/resp_valid: REQ-ERR-003 requires every record to expose the actual
victim address and the exact B response, so both are 1 whenever valid=1.
"""


class FaultRecord:
    def __init__(self):
        self.reset()

    def reset(self):
        self.valid = self.multiple = False
        self.source = self.bresp = self.hart = None
        self.pa = 0
        self.fault_level = False

    def events(self, evs):
        """Apply a list of events; groups by cycle with DEC-039 priority."""
        for cyc in sorted({e["cycle"] for e in evs}):
            same = [e for e in evs if e["cycle"] == cyc]
            same.sort(key=lambda e: (0, e["hart"]) if e["source"] == "L1" else (1, 0))
            for e in same:
                self.event(e)

    def event(self, e):
        if e["bresp"] not in (2, 3):
            raise ValueError("fatal record needs a non-OKAY BRESP (SLVERR=2/DECERR=3)")
        if not self.valid:
            self.valid = True
            self.source = e["source"]
            self.bresp = e["bresp"]
            self.hart = e["hart"] if e["source"] == "L1" else None   # DEC-040
            self.pa = e["pa"] & ~0xF                                    # line base (16-byte line)
        else:
            self.multiple = True
        self.fault_level = True

    def w1c_coh(self):
        """cpucl_coh.fault W1C: diagnostic only; does not clear the record or o_int_fault."""
        return None

    def regs(self):
        hv = self.valid and self.hart is not None
        sts = (int(self.valid) | (int(self.multiple) << 1) | (int(self.valid) << 2) |
               (int(hv) << 3) | (int(self.valid) << 4))
        info = 0
        if self.valid:
            info = (1 if self.source == "L1" else 2) | (self.bresp << 4) | ((self.hart << 8) if hv else 0)
        lo = self.pa & 0xFFFFFFFF if self.valid else 0
        hi = (self.pa >> 32) & 0xFFFFFF if self.valid else 0
        return {"cpucl_fault_sts": sts, "cpucl_fault_info": info, "cpucl_fault_lo": lo, "cpucl_fault_hi": hi}


def check(record, observed_regs, observed_fault_level=None):
    exp = record.regs()
    errs = ["%s 0x%08x expected 0x%08x" % (k, observed_regs.get(k, -1) & 0xFFFFFFFF, v)
            for k, v in exp.items() if observed_regs.get(k) != v]
    if observed_fault_level is not None and bool(observed_fault_level) != record.fault_level:
        errs.append("o_int_fault %d expected %d" % (observed_fault_level, record.fault_level))
    return errs
