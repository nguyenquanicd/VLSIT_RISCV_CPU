#!/usr/bin/env python3
# -----------------------------------------------------------------------------
# AI-GENERATED (Claude Opus 5.5, 2026-11-27) - candidate artifact (R-117, R-231).
# Runner for the Python model/checker qualification of plan Section 5.6.
# Human review: pending. No simulation, no HDL build.
# -----------------------------------------------------------------------------
"""Run every qualification suite under models/qual and write the records.

Usage (from verification/rv32_dual):
    python scripts/run_model_qualification.py [--out docs/01_qualification] [--force]

Writes per model: <out>/<id>/build_manifest.json, qualification_<kind>.json,
<id>.qualification.json (templates vlsit_model_qualification.json.tpl /
vlsit_checker_qualification.json.tpl) and <out>/summary.json, summary.md.
Exit 0 when every executed case passes, 1 otherwise. Review fields stay 'pending'.
"""
import argparse
import datetime
import hashlib
import importlib
import json
import os
import platform
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MODELS = os.path.join(ROOT, "models")
QUAL = os.path.join(MODELS, "qual")
WORKBOOK = os.path.normpath(os.path.join(ROOT, "..", "..", "doc", "specification", "VLSIT_RISCV_CPU_Cluster_CSR.xlsx"))
SUITES = ["asm_rv32", "chk_fp_model", "chk_isa_kat", "chk_trap_oracle", "chk_mem_oracle", "chk_litmus_oracle",
          "chk_pmu_model", "chk_fault_oracle", "chk_region_table", "chk_csr_model"]
CORRELATED = {
    "asm_rv32": "The assembler tables and the KAT bit strings were written by the same author from the same ISA encoding tables; "
                "a shared misremembered field value would pass both. Mitigations: 25 anchor vectors cross-checked against widely published "
                "constants, independent field-by-field bit strings, model-mutation detection. Residual risk until the human review compares "
                "the KAT with the ISA manual.",
    "chk_fp_model": "Expected values in the KAT were derived by the same author; RNE add/mul are cross-checked against the host IEEE binary32 "
                    "conversion (independent implementation); directed rounding modes and flags rely on the KAT only.",
    "chk_isa_kat": "sha512 RV32 halves are checked against FIPS 180-4 64-bit functions and the AES S-box against FIPS 197 published values "
                   "(independent); other KATs share the author with the model.",
    "chk_trap_oracle": "Cause codes and delegation rules come from the same author's reading of the Privileged ISA; the REF-001 10.2.3 "
                       "example is an independent anchor.",
    "chk_mem_oracle": "Shares no code with gen_prog (not yet written); when the generator is written, the parts shared with this oracle "
                      "must be listed and a hand-computed KAT added (plan 5.6).",
    "chk_litmus_oracle": "Two derivations (operational enumeration and published verdict table) by the same author; they agree on all 32 outcomes.",
    "chk_pmu_model": "Shares common/xlsx_min.py with chk_csr_model (workbook reader). A reader defect would affect both; the catalog size "
                     "and spot IDs are checked against the workbook rows read independently during plan authoring.",
    "chk_fault_oracle": "Same author as the plan; DEC-039/040 and workbook field layout are the only inputs.",
    "chk_region_table": "Uses the campaign table transcribed from REF-001 rev 0.40 14.4.20; the SV-form KAT compares against the elaboration text copied from the same section (independent of the transcription).",
    "chk_csr_model": "Shares common/xlsx_min.py with chk_pmu_model; register count and reset values are re-derived from the workbook rows.",
}
SEMANTICS = {
    "asm_rv32": "RV32 subset of plan 5.2 (RV32IMAFC, Zba/Zbb/Zbc/Zbs, Zbkb/Zbkc/Zbkx, Zkne/Zknd/Zknh RV32 forms, Zicond, Zcb, Zicbom, "
                "Zicsr, Zifencei, mret/sret/wfi/sfence.vma, dret); little-endian; no automatic compression; numeric branch/jump operand is a "
                "PC-relative offset; strict range checks; RV64/D mnemonics rejected (use .word).",
    "chk_fp_model": "IEEE 754 binary32 with exact rational arithmetic; RNE/RTZ/RDN/RUP/RMM; tininess after rounding; canonical NaN "
                    "0x7fc00000; RISC-V FMIN/FMAX, FCVT saturation and NV rules; fflags NV DZ OF UF NX.",
    "chk_isa_kat": "32-bit two's complement; RV32 M division edge cases; B/Zbc/Zbs; Zbkb/Zbkx; Zkne/Zknd aes32*; Zknh sha256*/sha512*32; Zicond.",
    "chk_trap_oracle": "XLEN=32 mcause encoding (interrupt bit 31); exception codes incl. custom 24 (REQ-MEM-018); delegation only from S/U.",
    "chk_mem_oracle": "Sparse little-endian byte memory; A-extension AMO*.W results; coherence final-value sets; reset keeps backing memory.",
    "chk_litmus_oracle": "RVWMO for MP/SB/LB/2+2W with and without fence rw,rw; no dependencies, no AMOs, no store forwarding races.",
    "chk_pmu_model": "Event_Map catalog; scopes 0-3/4/5/6-7; per-cycle caps (indicator 1, CCU occurrence 4, stall 1); SPM selectors zero; "
                     "modulo 2^W; W=32 high word zero; exact counts with prefetcher-off assumption (G0-CONF-01).",
    "chk_fault_oracle": "First-fatal record per DEC-039/040; addr_valid/resp_valid = valid (REQ-ERR-003); lo/hi per Q-G0-12; reset-only clear.",
    "chk_region_table": "REF-001 rev 0.40 14.4.20 validity rules 1-5 (NUM 1..16; 16-byte aligned nonzero length, base[63:56]=0, end <= 2^56; "
                        "TYPE[31:2]=0, class 11 reserved; no overlap; exactly one cacheable entry at index 0 with power-of-two length and "
                        "length-aligned base) plus the RV32 bound base+length <= 2^34 (Q-G0-09 C); classify() full-window, MMIO atomic error; "
                        "sv_params() emits the 14.4.20 elaboration form.",
    "chk_csr_model": "Workbook AXIL_QUEUED/Address_Map; OKAY/SLVERR/DECERR per REF-001 11.4; WSTRB; RO ignored; W1C; wo reads 0; "
                     "16 counters; LLC window not modelled (Q-G0-04); outside the aperture unspecified.",
}


def sha(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        h.update(f.read())
    return h.hexdigest()


def write_json(path, obj, force):
    if os.path.exists(path) and not force:
        raise SystemExit("refusing to overwrite %s (use --force)" % path)
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        json.dump(obj, f, indent=2, sort_keys=False)
        f.write("\n")
    return sha(path)


def main(argv=None):
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default=os.path.join("docs", "01_qualification"))
    ap.add_argument("--force", action="store_true")
    args = ap.parse_args(argv)
    out = os.path.join(ROOT, args.out)
    os.makedirs(out, exist_ok=True)
    sys.path.insert(0, QUAL)
    cmd = "python scripts/run_model_qualification.py --out %s%s" % (args.out.replace("\\", "/"), " --force" if args.force else "")
    summary, all_ok = [], True
    for sid in SUITES:
        mod = importlib.import_module("qual_" + sid)
        suite = mod.run()
        d = os.path.join(out, sid)
        os.makedirs(d, exist_ok=True)
        srcs = [{"path": "models/" + p, "sha256": sha(os.path.join(MODELS, p))} for p in mod.SOURCES]
        if getattr(mod, "WORKBOOK_INPUT", False):
            srcs.append({"path": "doc/specification/VLSIT_RISCV_CPU_Cluster_CSR.xlsx", "sha256": sha(WORKBOOK)})
        manifest = {"label": "AI-generated qualification manifest; review pending", "model_id": sid, "sources": srcs,
                    "python": platform.python_version(), "semantics": SEMANTICS[sid], "correlated_error_note": CORRELATED[sid]}
        man_sha = write_json(os.path.join(d, "build_manifest.json"), manifest, args.force)
        kinds = ("known_answer", "boundary", "negative", "reset", "fault_detection") if mod.KIND == "model" \
            else ("known_answer", "fault_detection", "boundary", "negative", "reset")
        tests, counts = [], {}
        for k in kinds:
            cases = suite.cases[k]
            if not cases:
                tests.append({"kind": k, "status": "not_applicable", "command": cmd, "exit_code": None,
                              "expected": "n/a", "observed": suite.na.get(k, "no cases"), "evidence": None})
                counts[k] = (0, 0)
                continue
            npass = sum(1 for c in cases if c["pass"])
            counts[k] = (npass, len(cases))
            ev = os.path.join(d, "qualification_%s.json" % k)
            ev_sha = write_json(ev, {"model_id": sid, "kind": k, "cases": cases}, args.force)
            ok = npass == len(cases)
            all_ok &= ok
            tests.append({"kind": k, "status": "pass" if ok else "fail", "command": cmd, "exit_code": 0 if ok else 1,
                          "expected": "detected" if k == "fault_detection" else ("handled" if k == "negative" else "match"),
                          "observed": "%d/%d cases %s" % (npass, len(cases), "detected" if k == "fault_detection" else "passed"),
                          "evidence": {"path": os.path.relpath(ev, ROOT).replace("\\", "/"), "sha256": ev_sha}})
        idkey = "model_id" if mod.KIND == "model" else "checker_id"
        record = {idkey: sid, "label": "AI-generated qualification record; not human-reviewed",
                  "build_manifest_sha256": man_sha, "review": {"decision": "pending", "approver": "pending", "date": None},
                  "tests": tests}
        write_json(os.path.join(d, "%s.qualification.json" % sid), record, args.force)
        line = "%-18s %-7s KAT %s  boundary %s  negative %s  reset %s  faults detected %s" % (
            sid, mod.KIND, "%d/%d" % counts["known_answer"], "%d/%d" % counts["boundary"], "%d/%d" % counts["negative"],
            ("%d/%d" % counts["reset"]) if counts["reset"][1] else "n/a", "%d/%d" % counts["fault_detection"])
        print(line)
        summary.append({"id": sid, "kind": mod.KIND, "counts": {k: list(v) for k, v in counts.items()},
                        "result": "pass" if all(v[0] == v[1] for v in counts.values()) else "fail"})
    stamp = datetime.date.today().isoformat()
    write_json(os.path.join(out, "summary.json"), {"date": stamp, "command": cmd, "suites": summary,
                                                    "overall": "pass" if all_ok else "fail",
                                                    "review": "pending (no human review recorded)"}, args.force)
    md = ["# Model and checker qualification summary", "",
          "AI-generated by `%s` on %s. Machine qualification only; human review pending (R-231, R-284)." % (cmd, stamp), "",
          "| Model / checker | Kind | KAT | Boundary | Negative | Reset | Injected faults detected | Result |", "|---|---|---|---|---|---|---|---|"]
    for s in summary:
        c = s["counts"]
        f = lambda k: "%d/%d" % tuple(c[k]) if c[k][1] else "n/a"
        md.append("| %s | %s | %s | %s | %s | %s | %s | %s |" % (s["id"], s["kind"], f("known_answer"), f("boundary"), f("negative"),
                                                                   f("reset"), f("fault_detection"), s["result"]))
    p = os.path.join(out, "summary.md")
    if os.path.exists(p) and not args.force:
        raise SystemExit("refusing to overwrite %s" % p)
    with open(p, "w", encoding="utf-8", newline="\n") as fh:
        fh.write("\n".join(md) + "\n")
    print("OVERALL: %s (%d suites)" % ("PASS" if all_ok else "FAIL", len(SUITES)))
    return 0 if all_ok else 1


if __name__ == "__main__":
    sys.exit(main())
