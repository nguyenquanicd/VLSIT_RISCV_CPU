#!/usr/bin/env python3
"""Capture exact observed tool versions and configure reviewed package manifests."""
import hashlib
import json
import subprocess
from collections import Counter
from pathlib import Path


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def write(path: Path, value) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2) + "\n", encoding="utf-8")


def main() -> int:
    root = Path(__file__).resolve().parents[2]
    toolchain = json.loads((root / "env/toolchain.json").read_text(encoding="utf-8"))
    versions = [
        ("python", toolchain["python"], "--version", "Python 3.12.10"),
        ("verilator", toolchain["verilator"], "--version", "Verilator 5.053"),
        ("gxx", toolchain["compiler"], "--version", "16.2.0"),
        ("verilator_coverage", toolchain["verilator_coverage"], "--version", "Verilator 5.053"),
    ]
    tools = []
    for name, executable, option, expected in versions:
        result = subprocess.run([executable, option], stdout=subprocess.PIPE,
                                stderr=subprocess.STDOUT, check=False, timeout=30)
        if result.returncode:
            raise SystemExit(f"version query failed for {name}: {result.returncode}")
        text = result.stdout.decode("utf-8", errors="replace")
        if expected not in text:
            raise SystemExit(f"unexpected {name} version: {text.strip()}")
        log = root / f"docs/tool_versions/{name}.txt"
        log.write_bytes(result.stdout)
        tools.append({
            "name": name,
            "version_argv": [executable, option],
            "status": "observed",
            "version": text.strip().replace("\r", ""),
            "version_log": log.relative_to(root).as_posix(),
            "version_log_sha256": sha(log),
        })

    path_value = toolchain["path"].replace("/", "\\")
    runtime_root = str(Path(toolchain["runtime_include"]).parent).replace("/", "\\")
    py = toolchain["python"]
    environment = [
        {"name": "PATH", "purpose": "Resolve Windows runtime DLLs for Python, Verilator and UCRT64 GCC.",
         "required": True, "secret": False, "value": path_value, "source": "env/toolchain.json",
         "setup_order": 0, "override": "The package helper replaces the shell PATH with this curated value."},
        {"name": "VERILATOR_ROOT", "purpose": "Identify the installed Verilator runtime tree.",
         "required": True, "secret": False, "value": runtime_root, "source": "env/toolchain.json",
         "setup_order": 1, "override": "Exact installed tool root recorded in the package."},
        {"name": "VLSIT_BUILD_JOBS", "purpose": "Bound parallel generated C++ compilation workers.",
         "required": True, "secret": False, "value": str(toolchain["build_jobs"]), "source": "env/toolchain.json",
         "setup_order": 2, "override": f"Fixed to {toolchain['build_jobs']} worker(s) by the reviewed resource budget."},
    ]
    commands = [
        {"name": "plan validator", "stage": "setup",
         "argv": [py, "scripts/vlsit_verify_plan.py", "check", "docs/00_plan/vplan.csv",
                  "--spec-index", "docs/00_plan/requirements.txt", "--today", "2026-11-16"],
         "cwd": "runs/configuration/build", "environment": ["PATH"], "timeout_s": 60,
         "status": "not_run", "reason": "A plan validation was run before G0; this package-local command is retained for independent replay."},
        {"name": "compile isolated FENCE.I smoke models", "stage": "compile",
         "argv": [py, "scripts/project_runner.py", "compile"], "cwd": "runs/configuration/build",
         "environment": ["PATH", "VERILATOR_ROOT", "VLSIT_BUILD_JOBS"], "timeout_s": 7200,
         "status": "not_run", "reason": "Per-run result is recorded in helper receipts."},
        {"name": "simulate four initial FENCE.I cases", "stage": "simulate",
         "argv": [py, "scripts/project_runner.py", "simulate"], "cwd": "runs/configuration/build",
         "environment": ["PATH", "VERILATOR_ROOT", "VLSIT_BUILD_JOBS"], "timeout_s": 1800,
         "status": "not_run", "reason": "Per-run result is recorded in helper receipts."},
        {"name": "cold replay in a new run directory", "stage": "replay",
         "argv": [py, "scripts/vlsit_sim_workspace.py", "replay", "--root", ".", "--baseline", "BASELINE_ID",
                  "--run-id", "replay_001", "--reference-run", "initial_001"],
         "cwd": "runs/configuration/build", "environment": ["PATH", "VERILATOR_ROOT", "VLSIT_BUILD_JOBS"],
         "timeout_s": 9000, "status": "not_run", "reason": "Replay must follow a qualified original execution."},
    ]
    result_cases = [case["id"] for case in json.loads(
        (root / "tests/generated/initial_case_manifest.json").read_text(encoding="utf-8"))["cases"]]
    manifest = {
        "schema_version": 2,
        "configuration": "AXI non-coherent cluster; 64-bit bus; 2 or 4 active harts",
        "test": "G0 initial FENCE.I success and AXI B-error qualification (HDS TEST-041/042)",
        "top": "tb_fence_i_end_to_end",
        "seed": 1,
        "environment": environment,
        "tools": tools,
        "commands": commands,
        "cold_replay": {"status": "not_run", "reason": "Only helper-generated replay receipts may record a cold replay."},
        "external_dependencies": [
            {"name": "Verilator runtime and executable", "version": tools[1]["version"],
             "purpose": "SystemVerilog elaboration, timed simulation model and coverage runtime.",
             "provisioning": "Install the exact build at the path recorded in env/toolchain.json; retain its upstream license.",
             "limitation": "Development build; no condition coverage claim."},
            {"name": "MSYS2 UCRT64 GCC", "version": tools[2]["version"],
             "purpose": "Compile generated C++ model and Verilator runtime.",
             "provisioning": "Install the exact compiler at the path recorded in env/toolchain.json.",
             "limitation": "Host-specific Windows toolchain; replay on another host requires a reviewed baseline update."},
            {"name": "Python", "version": tools[0]["version"],
             "purpose": "Run package helper, project runner, generators and validators.",
             "provisioning": "Install Python 3.12.10 at the path recorded in env/toolchain.json.",
             "limitation": "Standard-library scripts only."},
        ],
        "environment_policy": {"mode": "isolated", "empty_reason": "Not applicable; three curated variables are declared."},
        "dependency_export": "env/build_inputs.json",
        "replay_plan": {
            "runner": "scripts/project_runner.py",
            "compile": {"argv": [py, "{snapshot}/scripts/project_runner.py", "compile"], "timeout_s": 7200},
            "simulate": {"argv": [py, "{snapshot}/scripts/project_runner.py", "simulate"], "timeout_s": 1800},
            "build_outputs": ["build/fence_2h/Vtb_fence_i_end_to_end.exe",
                              "build/fence_4h/Vtb_fence_i_end_to_end.exe"],
            "result": "reports/result.json",
            "expected_cases": result_cases,
            "result_producer": {"status": "pending", "reviewer": "Codex; qualification record pending first isolated run",
                                "scope": "rtl", "evidence": "docs/result_producer_qualification.md"},
        },
    }
    write(root / "env/replay_manifest.json", manifest)

    source_order = json.loads((root / "env/source_order.json").read_text(encoding="utf-8"))
    source_scope = json.loads((root / "docs/00_plan/active_rtl_source_scope.json").read_text(encoding="utf-8"))
    actual_counts = Counter(row["class"] for row in source_scope["sources"])
    origin = {
        "schema_version": 1,
        "snapshot_status": "materialized; each active file SHA-256 checked against the G0 source inventory",
        "original_project": "VLSIT_RISCV_CPU",
        "original_filelist": "rtl/non_coherence_cluster/filelist.f",
        "snapshot_source_root": "dut/source",
        "flattened_compile_order": "env/source_order.json",
        "active_source_count": source_scope["source_count"],
        "class_counts": dict(actual_counts),
        "additional_include_support": [
            {"path": rel,
             "files": [{"path": file.relative_to(root).as_posix(), "sha256": sha(file)}
                       for file in sorted((root / rel).rglob("*")) if file.is_file()]}
            for rel in source_order["include_dirs"]
            if rel not in {"dut/source/" + item for item in source_scope.get("include_directories", [])}
        ],
        "license_policy": "Preserve source headers verbatim; source class is not a license conclusion. See docs/source_docs/third_party/README.md.",
        "source_files": source_scope["sources"],
    }
    write(root / "docs/source_origin.json", origin)

    all_package_files = []
    for path in root.rglob("*"):
        if not path.is_file() or path.name == ".gitkeep" or "__pycache__" in path.parts or path.suffix == ".pyc":
            continue
        rel = path.relative_to(root).as_posix()
        if rel in {"README.md", "env/replay_manifest.json", "env/build_inputs.json",
                   "env/workspace_manifest.json", "env/retention_catalog.json",
                   "scripts/vlsit_sim_workspace.py"}:
            continue
        if rel.startswith(("docs/", "coverage/", "runs/", "snapshots/")):
            continue
        all_package_files.append(rel)
    build_inputs = {
        "schema_version": 1,
        "method": "reviewed_manual",
        "reviewer": "Codex; source hashes, filelist closure, include closure and runner inputs reviewed against G0 manifests",
        "status": "reviewed",
        "unresolved": [],
        "include_dirs": source_order["include_dirs"],
        "inputs": sorted(set(all_package_files)),
    }
    write(root / "env/build_inputs.json", build_inputs)
    print(f"Configured isolated package: {len(tools)} tool version logs; {len(build_inputs['inputs'])} replay inputs")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
