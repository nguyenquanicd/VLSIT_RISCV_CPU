#!/usr/bin/env python3
# -----------------------------------------------------------------------------
# AI-GENERATED (Claude Opus 5.5, 2026-11-28) - candidate artifact (R-117, R-231).
# cov_collect: functional coverage of plan Section 8 (vplan coverage_bin column).
# A bin of vplan row R is HIT in a run when the run's test is R.test, the run's
# configuration is in R.configuration, and at least one check of that test with
# requirement R.req_id executed and passed (results.json). Bins of blocked rows
# are reported as 'blocked', never hit. Runs are merged by set union on
# (bin, configuration) identity; percentages are never averaged (R-202, R-206).
# This is requirement-scenario coverage, not microarchitectural event coverage.
# -----------------------------------------------------------------------------
"""Usage: python env/coverage/cov_collect.py <vplan.csv> <run_dir> [<run_dir> ...] [--out cov.json]"""
import argparse
import csv
import json
import os
import sys


def bins_from_vplan(path):
    out = []
    for r in csv.DictReader(open(path, encoding="utf-8")):
        for b in r["coverage_bin"].split(";"):
            if b.strip():
                out.append({"bin": b.strip(), "req": r["req_id"], "test": r["test"], "status": r["status"],
                            "configs": [c.strip() for c in r["configuration"].split(";") if c.strip()]})
    return out


def collect(vplan_bins, runs):
    """runs: list of (results_dict, configuration). Returns merged coverage dict."""
    hit = set()
    contrib = {}
    for res, cfg in runs:
        passed_reqs = {c["req"] for c in res["checks"] if c["status"] == "pass"}
        for b in vplan_bins:
            if b["test"] == res["test"] and cfg in b["configs"] and b["req"] in passed_reqs and b["status"] != "blocked":
                key = (b["bin"], cfg)
                hit.add(key)
                contrib.setdefault("%s@%s" % key, []).append("%s/seed%s" % (res["test"], res["seed"]))
    catalog = {(b["bin"], c) for b in vplan_bins if b["status"] != "blocked" for c in b["configs"]}
    blocked = {(b["bin"], c) for b in vplan_bins if b["status"] == "blocked" for c in b["configs"]} - catalog
    return {"catalog_size": len(catalog), "hit": len(hit & catalog), "blocked": len(blocked),
            "missing": sorted("%s@%s" % k for k in catalog - hit), "contributors": contrib}


def main(argv=None):
    ap = argparse.ArgumentParser()
    ap.add_argument("vplan")
    ap.add_argument("runs", nargs="+")
    ap.add_argument("--out")
    a = ap.parse_args(argv)
    vb = bins_from_vplan(a.vplan)
    runs = []
    for d in a.runs:
        res = json.load(open(os.path.join(d, "results.json"), encoding="utf-8"))
        exp = json.load(open(os.path.join(d, "expected.json"), encoding="utf-8"))
        runs.append((res, exp.get("configuration", "CFG-RV32-2-P0")))
    cov = collect(vb, runs)
    print("FUNCTIONAL COVERAGE: %d/%d bins hit (%d blocked bins excluded from the denominator)" % (cov["hit"], cov["catalog_size"], cov["blocked"]))
    if a.out:
        json.dump(cov, open(a.out, "w", encoding="utf-8"), indent=1)
    return 0


if __name__ == "__main__":
    sys.exit(main())
