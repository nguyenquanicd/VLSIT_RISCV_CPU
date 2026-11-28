#!/usr/bin/env python3
# -----------------------------------------------------------------------------
# AI-GENERATED (Claude Opus 5.5, 2026-11-27) - candidate artifact (R-117, R-231).
# Sources: CSR workbook VLSIT_RISCV_CPU_Cluster_CSR.xlsx sheets AXIL_QUEUED
# (register/field/type/reset/repeat) and Address_Map (local windows); REF-001
# rev 0.39 REQ-IF-007, REQ-IF-008, Section 11.3-11.4 (OKAY/SLVERR/DECERR,
# WSTRB, RO writes ignored, zero strobe, hardware priority), REQ-RST-001.
# Read with the Python standard library (zipfile + xml). No RTL used.
# Human review: pending.
# -----------------------------------------------------------------------------
"""chk_csr_model - AXI4-Lite register model of the generated cluster CSR block.

Responses: 'OKAY', 'SLVERR', 'DECERR'. Hardware-owned values (snapshot_done,
irq_raw.overflow, cpucl_coh.fault, pmu_count_*, cpucl_fault_*) are injected by
the PMU/fault oracles with hw_set(); irq_sts is computed as irq_raw & irq_en.
The LLC service window 0x5000-0x5FFF is not modelled (blocked by Q-G0-04).
"""
import os
import re
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "common"))
import xlsx_min  # noqa: E402

WORKBOOK = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                         "..", "..", "..", "doc", "specification", "VLSIT_RISCV_CPU_Cluster_CSR.xlsx"))
CSR_WINDOW = (0x0000, 0x5000)
LLC_WINDOW = (0x5000, 0x6000)


class Field:
    def __init__(self, name, lsb, width, ftype, reset):
        self.name, self.lsb, self.width, self.ftype, self.reset = name, lsb, width, ftype, reset
        self.mask = ((1 << width) - 1) << lsb


class Register:
    def __init__(self, name, offset, fields):
        self.name, self.offset, self.fields = name, offset, fields


def parse_workbook(path=WORKBOOK, counter_num=16):
    rows = xlsx_min.read_sheet(path, "AXIL_QUEUED")
    regs, cur, start = [], None, False
    for row in rows:
        row = list(row) + [None] * 11
        if row[0] == "REGISTER":
            start = True
            continue
        if not start:
            continue
        if row[0]:
            cur = {"name": row[0], "offset": int(row[1], 16), "repeat": row[7], "count": row[8], "stride": row[9],
                   "max": row[10], "fields": []}
            regs.append(cur)
        elif row[2] and cur is not None:
            m = re.match(r"\[(\d+)(?::(\d+))?\]", row[3])
            hi, lo = int(m.group(1)), int(m.group(2) if m.group(2) else m.group(1))
            cur["fields"].append(Field(row[2], lo, hi - lo + 1, row[4], int(row[5], 16)))
    out = []
    for r in regs:
        if r["repeat"] == "PARAMETERIZED":
            stride = int(r["stride"])
            for k in range(counter_num):     # entries counter_num..max-1 are reserved (REQ-IF-008)
                out.append(Register("%s[%d]" % (r["name"], k), r["offset"] + k * stride, r["fields"]))
        else:
            out.append(Register(r["name"], r["offset"], r["fields"]))
    return out


class CsrModel:
    HW_OWNED = {"pmu_ctrl.snapshot_done", "irq_raw.overflow", "cpucl_coh.fault"}

    def __init__(self, path=WORKBOOK, counter_num=16):
        self.regs = {r.offset: r for r in parse_workbook(path, counter_num)}
        self.by_name = {r.name: r for r in self.regs.values()}
        self.reset()

    def reset(self):
        self.val = {}
        for r in self.regs.values():
            for f in r.fields:
                self.val[(r.name, f.name)] = f.reset
        self.events = []        # software-visible commands, e.g. snapshot requests

    def hw_set(self, reg, field, value):
        self.val[(reg, field)] = value

    def _field_read(self, r, f):
        if f.ftype == "wo":
            return 0
        if r.name == "irq_sts":
            return self.val[("irq_raw", "overflow")] & self.val[("irq_en", "overflow_en")]
        if f.name == "reserved":
            return 0
        return self.val[(r.name, f.name)]

    def read(self, addr):
        """Return (resp, data). data None means 'not checked'."""
        if not (CSR_WINDOW[0] <= addr < LLC_WINDOW[1]):
            raise ValueError("address 0x%x outside the 24-KiB aperture: behaviour unspecified" % addr)
        if LLC_WINDOW[0] <= addr < LLC_WINDOW[1]:
            raise NotImplementedError("LLC service window not modelled (Q-G0-04)")
        if addr & 3:
            return "SLVERR", None
        r = self.regs.get(addr)
        if r is None:
            return "DECERR", 0
        v = 0
        for f in r.fields:
            v |= (self._field_read(r, f) << f.lsb) & f.mask
        return "OKAY", v

    def write(self, addr, data, strb=0xF):
        if not (CSR_WINDOW[0] <= addr < LLC_WINDOW[1]):
            raise ValueError("address 0x%x outside the 24-KiB aperture: behaviour unspecified" % addr)
        if LLC_WINDOW[0] <= addr < LLC_WINDOW[1]:
            raise NotImplementedError("LLC service window not modelled (Q-G0-04)")
        if addr & 3:
            return "SLVERR"
        r = self.regs.get(addr)
        if r is None:
            return "DECERR"
        bmask = sum(0xFF << (8 * i) for i in range(4) if (strb >> i) & 1)
        for f in r.fields:
            m = f.mask & bmask
            if not m:
                continue
            wv = (data & m) >> f.lsb
            fm = m >> f.lsb
            key = (r.name, f.name)
            if f.ftype == "rw":
                self.val[key] = (self.val[key] & ~fm) | wv
            elif f.ftype == "w1c":
                self.val[key] &= ~wv
            elif f.ftype == "wo" and wv:
                self.events.append((r.name, f.name, wv))
        return "OKAY"


def check_log(model, records):
    """records: NDJSON 'axil' records {op, addr, wdata?, wstrb?, resp, rdata?}."""
    errs = []
    for i, rec in enumerate(records):
        a = int(rec["addr"], 0) if isinstance(rec["addr"], str) else int(rec["addr"])
        if rec["op"] == "write":
            d = int(rec["wdata"], 0) if isinstance(rec["wdata"], str) else int(rec["wdata"])
            s = int(rec.get("wstrb", 15))
            exp = model.write(a, d, s)
            if rec["resp"] != exp:
                errs.append("#%d write 0x%04x resp %s expected %s" % (i, a, rec["resp"], exp))
        else:
            resp, data = model.read(a)
            if rec["resp"] != resp:
                errs.append("#%d read 0x%04x resp %s expected %s" % (i, a, rec["resp"], resp))
            got = rec.get("rdata")
            got = int(got, 0) if isinstance(got, str) else got
            if data is not None and got != data:
                errs.append("#%d read 0x%04x data 0x%08x expected 0x%08x" % (i, a, got if got is not None else -1, data))
    return errs
