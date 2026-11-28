#!/usr/bin/env python3
# -----------------------------------------------------------------------------
# AI-GENERATED (Claude Opus 5.5, 2026-11-28) - candidate artifact (R-117, R-231, R-276).
# Testcase generator (plan 5.2 gen_prog): reads every testcase source tests/t_*.py
# (header + build(p)), builds the RV32 program with models/asm_rv32 and writes
# tests/generated/<test>/ {prog.S, prog.memh, symbols.json, expected.json,
# *_rules.txt, axil_script.txt, dump_ranges.txt, plusargs.txt} plus
# tests/generated/generation_manifest.json (input/output hashes, command).
# Deterministic for fixed inputs; refuses to overwrite changed outputs without
# --force; --check regenerates in memory and reports differences.
# -----------------------------------------------------------------------------
"""Usage: python scripts/generators/gen_prog.py [--only t_x,t_y] [--check] [--force]"""
import argparse
import glob
import hashlib
import importlib.util
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import rv32d_lib  # noqa: E402


def sha(b):
    return hashlib.sha256(b).hexdigest()


def load(path):
    spec = importlib.util.spec_from_file_location(os.path.basename(path)[:-3], path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def main(argv=None):
    ap = argparse.ArgumentParser()
    ap.add_argument("--only")
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--force", action="store_true")
    a = ap.parse_args(argv)
    srcs = sorted(glob.glob(os.path.join(ROOT, "tests", "t_*.py")))
    if a.only:
        keep = set(a.only.split(","))
        srcs = [s for s in srcs if os.path.basename(s)[:-3] in keep]
    gen_dir = os.path.join(ROOT, "tests", "generated")
    manifest = {"generator": "scripts/generators/gen_prog.py",
                "generator_sha256": sha(open(os.path.abspath(__file__), "rb").read()),
                "library_sha256": sha(open(os.path.join(HERE, "rv32d_lib.py"), "rb").read()),
                "assembler_sha256": sha(open(os.path.join(ROOT, "models", "asm_rv32", "asm_rv32.py"), "rb").read()),
                "command": "python scripts/generators/gen_prog.py --force", "tests": []}
    diffs, errors, n_written = [], [], 0
    for s in srcs:
        mod = load(s)
        tid = os.path.basename(s)[:-3]
        if getattr(mod, "TEST", tid) != tid:
            errors.append("%s: TEST constant does not match file name" % tid)
            continue
        if getattr(mod, "KIND", "cpu") != "cpu":            # static / formal / review testcase: no program
            st = getattr(mod, "STATIC", {})
            manifest["tests"].append({"test": tid, "kind": mod.KIND, "source": "tests/%s.py" % tid,
                                      "source_sha256": sha(open(s, "rb").read()), "runner": st.get("runner"),
                                      "checks": [c[0] for c in st.get("checks", [])], "blocked": st.get("blocked"), "outputs": []})
            continue
        p = rv32d_lib.Prog(tid, getattr(mod, "SEED", 1))
        try:
            mod.build(p)
            files = p.build(os.path.join(gen_dir, tid))
        except Exception as e:                       # report and continue with the other tests
            errors.append("%s: %s: %s" % (tid, type(e).__name__, e))
            continue
        entry = {"test": tid, "source": "tests/%s.py" % tid, "source_sha256": sha(open(s, "rb").read()),
                 "reqs": sorted({c["req"] for c in p.checks}), "checks": [c["id"] for c in p.checks],
                 "blocked_checks": [b["id"] for b in p.blocked], "outputs": []}
        for name, text in sorted(files.items()):
            path = os.path.join(gen_dir, tid, name)
            data = text.encode("utf-8")
            entry["outputs"].append({"path": "tests/generated/%s/%s" % (tid, name), "sha256": sha(data)})
            old = open(path, "rb").read() if os.path.exists(path) else None
            if old != data:
                diffs.append("%s/%s" % (tid, name))
                if not a.check:
                    if old is not None and not a.force:
                        raise SystemExit("refusing to overwrite changed %s (use --force)" % path)
                    os.makedirs(os.path.dirname(path), exist_ok=True)
                    open(path, "wb").write(data)
                    n_written += 1
        manifest["tests"].append(entry)
    for e in errors:
        print("ERROR: %s" % e)
    if a.check:
        print("CHECK: %d tests, %s" % (len(manifest["tests"]), "identical" if not diffs else "%d differing files" % len(diffs)))
        return 1 if (diffs or errors) else 0
    if not a.only:
        os.makedirs(gen_dir, exist_ok=True)
        with open(os.path.join(gen_dir, "generation_manifest.json"), "w", encoding="utf-8", newline="\n") as f:
            json.dump(manifest, f, indent=1)
            f.write("\n")
    print("GENERATED %d tests, %d files written, %d errors" % (len(manifest["tests"]), n_written, len(errors)))
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
