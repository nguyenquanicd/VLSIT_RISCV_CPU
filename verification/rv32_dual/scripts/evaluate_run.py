#!/usr/bin/env python3
# -----------------------------------------------------------------------------
# AI-GENERATED (Claude Opus 5.5, 2026-11-28) - candidate artifact (R-117, R-231).
# Post-simulation evaluator: executes every planned check of a testcase
# (expected.json from gen_prog) against the run's NDJSON logs with the
# qualified oracles and scoreboards; writes results.json. A test passes only if
# every non-blocked check executed and passed (R-282, R-286); a missing log makes
# the check not_run (never pass). No simulation is launched by this script.
# -----------------------------------------------------------------------------
"""Usage: python scripts/evaluate_run.py <run_dir> [--expected <expected.json>]"""
import argparse
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
for p in ("models", "models/common", "env/scoreboards", "env/coverage"):
    sys.path.insert(0, os.path.join(ROOT, p))
import chk_trap_oracle as T          # noqa: E402
import chk_mem_oracle as M           # noqa: E402
import chk_litmus_oracle as LIT      # noqa: E402
import chk_pmu_model as PMU          # noqa: E402
import chk_fault_oracle as FO        # noqa: E402
import chk_csr_model as CSR          # noqa: E402
import chk_region_table as RT        # noqa: E402
import chk_sig as SIG                # noqa: E402
import chk_axi_mem_sb as MEMSB       # noqa: E402
import chk_axi_mmio_sb as MMIOSB     # noqa: E402
import chk_axil_sb as AXILSB         # noqa: E402
from axi_sb_core import read_ndjson  # noqa: E402

LOGS = {"mem": "mem_dump.ndjson", "axi_mem": "axi_mem.ndjson", "axi_mmio": "axi_mmio.ndjson", "axil": "axil.ndjson",
        "pins": "pins.ndjson", "sva": "sva.ndjson", "stale_mem": "stale_mem.ndjson", "stale_mmio": "stale_mmio.ndjson",
        "wd": "watchdog.ndjson", "bfm_mem": "bfm_mem.ndjson", "bfm_mmio": "bfm_mmio.ndjson"}


class Missing(Exception):
    pass


class Run:
    def __init__(self, d):
        self.d = d
        self.cache = {}

    def log(self, key):
        if key not in self.cache:
            p = os.path.join(self.d, LOGS[key])
            self.cache[key] = read_ndjson(p) if os.path.exists(p) else None
        if self.cache[key] is None:
            raise Missing("log %s not found" % LOGS[key])
        return self.cache[key]

    def mem(self):
        if "memb" not in self.cache:
            self.cache["memb"] = SIG.mem_bytes(self.log("mem"))
        return self.cache["memb"]


def axil_reads(recs):
    out = {}
    for r in recs:
        if r.get("type") == "axil" and r["op"] == "read":
            out[int(r["addr"], 0)] = int(r["rdata"], 0)
    return out


def run_check(run, exp, c):
    k, p = c["kind"], c["params"]
    if k == "slot":
        return SIG.check_slot(run.mem(), p["addr"], p.get("expect"), p.get("allowed"), p.get("mask", 0xFFFFFFFF))
    if k == "mem_word":
        return SIG.check_slot(run.mem(), p["addr"], p.get("expect"), p.get("allowed"))
    if k == "traps":
        obs = SIG.traps(run.mem(), int(exp["trap_base"], 0), p["hart"])
        if obs is None:
            return ["trap area of hart %d not published" % p["hart"]]
        exp_l = [T.expected_trap(p["hart"], e["kind"], e["code"], e["epc"], e.get("tval"), e.get("from", "M"),
                                 e.get("medeleg", 0), e.get("mideleg", 0)) for e in p["expected"]]
        if p.get("subset"):
            obs = [o for o in obs if (o.get("mcause") if o["level"] == "M" else o.get("scause")) in {x["cause"] for x in exp_l}]
        return T.compare(exp_l, obs)
    if k == "counter":
        v = SIG.word(run.mem(), p["addr"])
        return ["counter slot not published"] if v is None else M.check_counter(p["init"], p["contributions"], v)
    if k == "litmus":
        out = {}
        for reg, addr in p["regs"].items():
            v = SIG.word(run.mem(), addr)
            if v is None:
                return ["litmus register %s not published" % reg]
            out[reg] = v
        return LIT.check_result(p["pattern"], p["fenced"], out)
    if k in ("axi_mem", "axi_mmio"):
        sb = MEMSB if k == "axi_mem" else MMIOSB
        recs = run.log("axi_mem") + run.log("axi_mmio") if k == "axi_mem" else run.log("axi_mmio")
        return [e for _, es in sb.check(recs, p["rules"]) for e in es]
    if k == "axil":
        recs = run.log("axil")
        errs = AXILSB.check(recs)
        if p.get("csr_model", True):
            model = CSR.CsrModel()
            for (reg, fld, val) in p.get("hw", []):
                model.hw_set(reg, fld, val)
            sel = [r for r in recs if r.get("type") == "axil" and int(r["addr"], 0) not in set(p.get("skip_addrs", []))]
            for r in sel:
                if int(r["addr"], 0) in set(p.get("ignore_data", [])):
                    r = dict(r)
                    r.pop("rdata", None)
                    if r["op"] == "read":
                        resp, _ = model.read(int(r["addr"], 0))
                        if resp != r["resp"]:
                            errs.append("read 0x%s resp %s expected %s" % (r["addr"], r["resp"], resp))
                        continue
                errs += CSR.check_log(model, [r])
        return errs
    if k == "pmu":
        cfg = {int(kk): {"event_id": v[0], "scope": v[1], "en": bool(v[2])} for kk, v in p["config"].items()}
        vals, ierr = PMU.expected_counts(cfg, p["occurrences"], num_harts=2, width=p.get("width", 64))
        rd = axil_reads(run.log("axil"))
        reads = {k2: (rd.get(0x2000 + 4 * k2, -1), rd.get(0x3000 + 4 * k2, -1)) for k2 in cfg}
        return ierr + PMU.check_snapshot(vals, reads, p.get("width", 64))
    if k == "fault":
        rec = FO.FaultRecord()
        evs = [e for e in run.log("bfm_mem") if e.get("event") == "err_b"]
        rec.events([{"cycle": e["cycle"], "source": "LLC", "hart": None, "bresp": e["resp"], "pa": int(e["addr"], 0)} for e in evs])
        idx = {"first": 0, "second_block": 1}.get(p.get("which", "first"), 0)
        reads = [r for r in run.log("axil") if r.get("type") == "axil" and r["op"] == "read"]
        def nth(a):
            rr = [int(r["rdata"], 0) for r in reads if int(r["addr"], 0) == a]
            return rr[idx] if len(rr) > idx else None
        obs = {n: nth(a) for n, a in (("cpucl_fault_sts", 0x4000), ("cpucl_fault_info", 0x4004), ("cpucl_fault_lo", 0x4008), ("cpucl_fault_hi", 0x400C))}
        errs = FO.check(rec, obs, None)
        if p.get("min_events") and len(evs) < p["min_events"]:
            errs.append("only %d LLC writeback error(s) injected, expected >= %d" % (len(evs), p["min_events"]))
        return errs
    if k == "sva":
        recs = {r["id"]: r for r in run.log("sva")}
        r = recs.get(p["id"])
        if r is None:
            return ["assertion %s not reported" % p["id"]]
        if p.get("expect") == "fire":
            return [] if r["fails"] > 0 else ["assertion %s expected to fire (negative test) but did not" % p["id"]]
        e = [] if r["fails"] == 0 else ["assertion %s failed %d time(s)" % (p["id"], r["fails"])]
        if p.get("need_cover", True) and r["covers"] == 0:
            e.append("assertion %s vacuous in this test (0 covers)" % p["id"])
        return e
    if k == "pin":
        ev = [r for r in run.log("pins") if r["name"] == p["name"] and r.get("index", 0) == p.get("index", 0)]
        vals = [r["value"] for r in ev]
        if p["rule"] == "rises":
            return [] if 1 in vals else ["%s[%d] never rose" % (p["name"], p.get("index", 0))]
        if p["rule"] == "never_high":
            return [] if 1 not in vals else ["%s[%d] went high" % (p["name"], p.get("index", 0))]
        if p["rule"] == "final":
            return [] if vals and vals[-1] == p["value"] else ["%s[%d] final value %s expected %s" % (p["name"], p.get("index", 0), vals[-1] if vals else None, p["value"])]
        return ["unknown pin rule"]
    if k == "stale":
        s = [r for r in run.log("stale_" + p["port"]) if r.get("type") == "stale_summary"]
        if not s:
            return ["stale-response summary missing"]
        e = [] if s[-1]["violations"] == 0 else ["%d stale response(s) after reset" % s[-1]["violations"]]
        if p.get("need_reset") and s[-1]["resets"] < 1:
            e.append("no mid-test reset observed")
        return e
    if k == "tohost":
        codes = {r["hart"]: int(r["code"], 0) for r in run.log("wd") if r.get("event") == "tohost"}
        if any(r.get("event") == "expired" for r in run.log("wd")):
            return ["watchdog expired (cycle budget) before every hart finished"]
        return [] if all(codes.get(hh) == p.get("code", 1) for hh in p.get("harts", [0, 1])) else ["TOHOST codes %s, expected %s" % (codes, p.get("code", 1))]
    if k == "bfm_event":
        evs = [e for e in run.log("bfm_" + p["port"]) if e.get("event") == p["event"]]
        return [] if len(evs) >= p.get("min", 1) else ["BFM event %s seen %d time(s), expected >= %d" % (p["event"], len(evs), p.get("min", 1))]
    if k == "region_table":
        return RT.check_table(RT.load())
    if k in ("slots", "slots_any"):
        errs = []
        for a, v in p["values"].items():
            if v is None:
                errs += [] if SIG.word(run.mem(), int(a)) is not None else ["slot 0x%08x not published" % int(a)]
            elif isinstance(v, list):
                errs += SIG.check_slot(run.mem(), int(a), allowed=v)
            else:
                errs += SIG.check_slot(run.mem(), int(a), v)
        return errs
    if k == "slots_mask":
        return [e for a, m, v in p["items"] for e in SIG.check_slot(run.mem(), a, v, mask=m)]
    if k == "slot_sum":
        vals = [SIG.word(run.mem(), a) for a in p["addrs"]]
        tot = SIG.word(run.mem(), p["equals_addr"])
        if None in vals or tot is None:
            return ["slot_sum inputs not published"]
        return [] if (sum(vals) & 0xFFFFFFFF) == tot else ["sum of %s = %d, expected %d" % (vals, sum(vals), tot)]
    if k in ("trap_cause", "traps_level"):
        obs = SIG.traps(run.mem(), int(exp["trap_base"], 0), p["hart"])
        if obs is None:
            return ["trap area of hart %d not published" % p["hart"]]
        causes = [(o["level"], o.get("mcause") if o["level"] == "M" else o.get("scause")) for o in obs]
        if k == "traps_level":
            return [] if (p["level"], p["cause"]) in causes else ["no trap with cause 0x%x at level %s on hart %d (saw %s)" % (p["cause"], p["level"], p["hart"], causes)]
        present = any(c == p["cause"] for _, c in causes)
        return [] if present == p["present"] else ["cause 0x%x %s on hart %d (saw %s)" % (p["cause"], "missing" if p["present"] else "unexpected", p["hart"], causes)]
    if k in ("axil_reads_eq", "axil_resp", "axil_reads_stable"):
        recs = [r for r in run.log("axil") if r.get("type") == "axil"]
        if k == "axil_resp":
            n = sum(1 for r in recs if int(r["addr"], 0) == p["addr"] and r["resp"] == p["resp"])
            return [] if n == p["count"] else ["%d %s response(s) at 0x%x, expected %d" % (n, p["resp"], p["addr"], p["count"])]
        reads = [r for r in recs if r["op"] == "read"]
        if k == "axil_reads_eq":
            errs = []
            for a, v in p["values"].items():
                rr = [r for r in reads if int(r["addr"], 0) == int(a)]
                if not rr:
                    errs.append("no AXI4-Lite read of 0x%x" % int(a))
                    continue
                got = int((rr[-1] if p.get("which", "last") == "last" else rr[0])["rdata"], 0)
                if got != v:
                    errs.append("read 0x%x = 0x%08x expected 0x%08x" % (int(a), got, v))
            return errs
        cks = __import__("axi_sb_core").checkpoints(run.log("axi_mmio"))
        win = __import__("axi_sb_core").window(cks, p.get("between"))
        if win is None:
            return ["checkpoint window %s not found" % p.get("between")]
        errs = []
        for a in p["addrs"]:
            vals = {r["rdata"] for r in reads if int(r["addr"], 0) == a and win[0] <= r["cycle"] <= win[1]}
            if len(vals) != 1:
                errs.append("reads of 0x%x in window gave %s (expected one stable value, >= 1 read)" % (a, sorted(vals)))
        return errs
    if k == "no_retry_after_err":
        from axi_sb_core import rebuild
        writes, _, _ = rebuild(run.log("axi_mem"), "mem")
        errs = []
        for e in [e for e in run.log("bfm_" + p["port"]) if e.get("event") == "err_b"]:
            a = int(e["addr"], 0) & ~0xF
            later = [w for w in writes if w["cycle"] > e["cycle"] and (w["addr"] & ~0xF) == a]
            if later:
                errs.append("failed writeback line 0x%x written again at cycle %d (automatic retry)" % (a, later[0]["cycle"]))
        return errs
    if k == "ckpt_order":
        cks = __import__("axi_sb_core").checkpoints(run.log("axi_mmio"))
        c1 = [c for v, c in cks if v == p["first"]]
        c2 = [c for v, c in cks if v == p["second"]]
        if not c1 or not c2:
            return ["checkpoint 0x%x or 0x%x missing" % (p["first"], p["second"])]
        gap = c2[0] - c1[0]
        return [] if gap >= p.get("min_gap", 1) else ["checkpoint 0x%x only %d cycles before 0x%x (expected >= %d)" % (p["first"], gap, p["second"], p.get("min_gap", 1))]
    if k in ("pmu_relation", "pmu_bound"):
        rd = axil_reads(run.log("axil"))
        val = lambda c: rd.get(0x2000 + 4 * c, 0) | (rd.get(0x3000 + 4 * c, 0) << 32)
        if k == "pmu_bound":
            limit = max(r.get("cycle", 0) for r in run.log("wd")) if run.log("wd") else 0
            return [] if val(p["counter"]) <= limit else ["counter %d = %d exceeds elapsed cycles %d" % (p["counter"], val(p["counter"]), limit)]
        e = []
        if val(p["total"]) != sum(val(c) for c in p["sum_of"]):
            e.append("counter %d = %d, expected sum of %s = %d" % (p["total"], val(p["total"]), p["sum_of"], sum(val(c) for c in p["sum_of"])))
        for c in p["sum_of"]:
            if not p.get("min_each", 0) <= val(c) <= p.get("max_each", 1 << 64):
                e.append("counter %d = %d outside [%d, %d]" % (c, val(c), p.get("min_each", 0), p.get("max_each", 1 << 64)))
        return e
    return ["unknown check kind %r" % k]


def main(argv=None):
    ap = argparse.ArgumentParser()
    ap.add_argument("run_dir")
    ap.add_argument("--expected")
    a = ap.parse_args(argv)
    exp = json.load(open(a.expected or os.path.join(a.run_dir, "expected.json"), encoding="utf-8"))
    run = Run(a.run_dir)
    res = []
    for c in exp["checks"]:
        try:
            errs = run_check(run, exp, c)
            res.append({"id": c["id"], "req": c["req"], "kind": c["kind"], "status": "pass" if not errs else "fail", "errors": errs})
        except Missing as m:
            res.append({"id": c["id"], "req": c["req"], "kind": c["kind"], "status": "not_run", "errors": [str(m)]})
    for b in exp.get("blocked_checks", []):
        res.append({"id": b["id"], "req": b["req"], "kind": "blocked", "status": "blocked", "errors": [b["reason"]]})
    ids = {r["id"] for r in res if r["status"] != "blocked"}
    verdict = "PASS" if res and all(r["status"] == "pass" for r in res if r["status"] != "blocked") and len(ids) >= 5 else "FAIL"
    out = {"test": exp["test"], "seed": exp["seed"], "verdict": verdict, "distinct_checks": len(ids), "checks": res}
    with open(os.path.join(a.run_dir, "results.json"), "w", encoding="utf-8", newline="\n") as f:
        json.dump(out, f, indent=1)
    for r in res:
        print("%-10s %-8s %s %s" % (r["id"], r["status"], r["req"], ("; ".join(r["errors"])[:160]) if r["errors"] else ""))
    print("VERDICT: %s (%d distinct executed-or-planned checks)" % (verdict, len(ids)))
    return 0 if verdict == "PASS" else 1


if __name__ == "__main__":
    sys.exit(main())
