#!/usr/bin/env python3
# AI-GENERATED (Claude Opus 5.5, 2026-11-27) - candidate; human review pending.
"""Write ai/provenance.json (template vlsit_ai_provenance.json.tpl, R-117/R-234)
for the Python environment phase. Hashes are computed from the actual files."""
import hashlib
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.normpath(os.path.join(ROOT, "..", ".."))
SKILL = os.path.expanduser(os.path.join("~", ".claude", "skills", "vlsit-verification-generator"))


def sha(p):
    return hashlib.sha256(open(p, "rb").read()).hexdigest()


def _extra_runs():
    out = []
    for cmd, log in (("bash scripts/lint_env.sh", "docs/02_env/lint_env.log"),
                     ("python scripts/run_env_qualification.py --force", "docs/02_env/run_output.txt"),
                     ("python scripts/generators/gen_prog.py --check; python scripts/generators/gen_env.py --check", "docs/02_env/generators_check.txt")):
        p = os.path.join(ROOT, log)
        if os.path.exists(p):
            txt = open(p, encoding="utf-8", errors="replace").read()
            res = "pass" if ("exit=0" in txt or "OVERALL: PASS" in txt or "identical" in txt) and "FAIL" not in txt else "see log"
            out.append({"command": cmd, "version": "Verilator 5.053 / Python %d.%d.%d" % sys.version_info[:3], "result": res,
                        "log": "verification/rv32_dual/" + log, "log_sha256": sha(p)})
    return out


def main():
    outputs = []
    for base in ("models", "scripts", "env", "tb", "tests"):
        for dp, dn, fn in os.walk(os.path.join(ROOT, base)):
            dn[:] = [d for d in dn if d != "__pycache__"]
            for f in sorted(fn):
                if f in ("vlsit_sim_workspace.py", ".gitkeep", "build_inputs.json", "replay_manifest.json", "resource_budget.json"):
                    continue
                p = os.path.join(dp, f)
                outputs.append({"path": os.path.relpath(p, REPO).replace("\\", "/"), "sha256": sha(p)})
    outputs.append({"path": "verification/rv32_dual/README.md", "sha256": sha(os.path.join(ROOT, "README.md"))})
    ctx = [os.path.join(REPO, "doc", "specification_32", "VLSIT_RISCV32_DUAL_QUAD_CPU_CLUSTER_HDS.md"),
           os.path.join(REPO, "doc", "specification", "VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md"),
           os.path.join(REPO, "doc", "specification", "VLSIT_RISCV_CPU_Cluster_CSR.xlsx"),
           os.path.join(ROOT, "docs", "00_plan", "verification_plan.md"),
           os.path.join(ROOT, "docs", "00_plan", "question_log.md"),
           os.path.join(ROOT, "docs", "00_plan", "signoff.md")]
    ctx_files = [{"path": os.path.relpath(p, REPO).replace("\\", "/"), "sha256": sha(p)} for p in ctx]
    for t in ("vlsit_model_qualification.json.tpl", "vlsit_checker_qualification.json.tpl", "vlsit_ai_provenance.json.tpl"):
        p = os.path.join(SKILL, "reference", "templates", t)
        if os.path.exists(p):
            ctx_files.append({"path": "skill:reference/templates/" + t, "sha256": sha(p)})
    run_out = os.path.join(ROOT, "docs", "01_qualification", "run_output.txt")
    summ = os.path.join(ROOT, "docs", "01_qualification", "summary.json")
    prov = {
        "label": "AI-GENERATED provenance record; reviewer pending (R-117, R-230, R-231)",
        "artifact_id": "rv32_dual_environment_and_testcases_phase2",
        "artifact_path": "verification/rv32_dual/{models,scripts,env,tb,tests}",
        "artifact_sha256": None,
        "artifacts": outputs,
        "model": {"provider": "Anthropic", "id": "claude-opus-5-5", "version": "Claude Opus 5.5", "temperature": None, "seed": None,
                  "note": "temperature/seed not exposed by the agent harness"},
        "prompt": {"template_id": "coordinator task 'write and qualify the Python-only parts of plan 5.2/5.6'",
                   "sha256": None, "sha256_note": "prompt text is held by the coordinating agent; not available to hash here",
                   "context_files": ctx_files,
                   "spec_ids": ["REQ-XL-003", "REQ-XL-004", "REQ-XL-011", "REQ-XL-013", "REQ-IF-007", "REQ-IF-008", "REQ-IF-011",
                                "REQ-MEM-017", "REQ-MEM-018", "REQ-PMU-002", "REQ-PMU-003", "REQ-PMU-004", "REQ-PMU-005",
                                "REQ-PMU-006", "REQ-PMU-007", "REQ-PMU-008", "REQ-ERR-003", "REQ-RST-001"],
                   "protocol_clauses": ["RISC-V Unprivileged ISA encoding tables", "RISC-V Privileged ISA trap causes", "RVWMO",
                                        "IEEE 754 binary32", "FIPS 197", "FIPS 180-4"]},
        "tool_runs": [{"command": "python scripts/run_model_qualification.py --force", "version": "Python %d.%d.%d" % sys.version_info[:3],
                       "result": json.load(open(summ))["overall"], "log": "verification/rv32_dual/docs/01_qualification/run_output.txt",
                       "log_sha256": sha(run_out)}] + _extra_runs(),
        "validation": {"compile": "not_applicable (Python)", "simulation": "not_run (no HDL build: disk below threshold)",
                       "qualification": json.load(open(summ))["overall"], "mutation": "see fault_detection in docs/01_qualification",
                       "coverage": "not_run"},
        "review": {"reviewer": "pending (named hardware verification engineer)", "date": None, "decision": "pending", "notes": ""},
    }
    os.makedirs(os.path.join(ROOT, "ai"), exist_ok=True)
    out = os.path.join(ROOT, "ai", "provenance.json")
    with open(out, "w", encoding="utf-8", newline="\n") as f:
        json.dump(prov, f, indent=2)
        f.write("\n")
    print("WROTE %s (%d artifacts)" % (os.path.relpath(out, ROOT), len(outputs)))


if __name__ == "__main__":
    main()
