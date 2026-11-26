#!/usr/bin/env python3
"""Run real CVA6 CBO instructions through the isolated production cluster TOP."""
from __future__ import annotations

import hashlib
import json
import os
import re
import subprocess
import sys
from pathlib import Path

from resource_guard import run_logged


TOP = "tb_cmo_end_to_end"
TEST_SOURCE = "tests/t/n/cmo_end_to_end/tb_cmo_end_to_end.sv"
TIMING_PROFILE = 1


def sha(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def context(root: Path, baseline: str, run_id: str):
    root = root.resolve()
    snapshot = (root / "snapshots" / baseline).resolve()
    run = (root / "runs" / run_id).resolve()
    if root not in snapshot.parents or root not in run.parents:
        raise RuntimeError("snapshot/run path escaped package root")
    if not (snapshot / "env/workspace_manifest.json").is_file():
        raise RuntimeError(f"unknown sealed baseline: {baseline}")
    tools = json.loads((snapshot / "env/toolchain.json").read_text(encoding="utf-8-sig"))
    order = json.loads((snapshot / "env/source_order.json").read_text(encoding="utf-8-sig"))
    replay = json.loads((snapshot / "env/replay_manifest.json").read_text(encoding="utf-8-sig"))
    env = os.environ.copy()
    env["PATH"] = tools["path"]
    for item in replay["environment"]:
        if item["name"] in ("VERILATOR_ROOT", "VLSIT_BUILD_JOBS", "VLSIT_MIN_FREE_RAM_BYTES",
                             "VLSIT_MIN_FREE_DISK_BYTES", "VLSIT_MAX_RAM_DROP_BYTES",
                             "VLSIT_RAM_GUARD_MARGIN_BYTES", "VLSIT_RAM_POLL_INTERVAL_MS"):
            env[item["name"]] = item["value"]
    for name, value in (("VLSIT_BASELINE_ID", baseline), ("VLSIT_RUN_ID", run_id),
                        ("VLSIT_SNAPSHOT", str(snapshot)), ("VLSIT_RUN_ROOT", str(run))):
        env[name] = value
    return root, snapshot, run, tools, order, env


def compile_harts(snapshot: Path, run: Path, tools: dict, order: dict, env: dict,
                  harts: int, coverage: bool) -> Path:
    suffix = "_cov" if coverage else ""
    build = run / "build" / f"cluster_{harts}h_tp{TIMING_PROFILE}{suffix}"
    objdir = build / "obj"
    objdir.mkdir(parents=True, exist_ok=True)
    test_source = snapshot / TEST_SOURCE
    production_sources = [snapshot / rel for rel in order["source_order"]]
    if not test_source.is_file() or any(not source.is_file() for source in production_sources):
        raise RuntimeError("isolated production source or CBO testbench is missing")
    source_list = build / "ordered_sources.f"
    source_list.write_text("\n".join(p.as_posix() for p in production_sources + [test_source]) + "\n",
                           encoding="utf-8")
    args = [tools["verilator"], "--cc", "--timing", "--assert", "--timescale", "1ns/1ps",
            "--top-module", TOP, f"-GHARTS={harts}", "-GTRACE=0",
            f"-GTIMING_PROFILE={TIMING_PROFILE}", "--Wno-fatal",
            "--output-split", "1000", "--output-split-cfuncs", "250",
            "--Mdir", str(objdir)]
    if coverage:
        args[1:1] = ["--coverage-line", "--coverage-expr", "--coverage-toggle"]
        scope = json.loads((snapshot / "docs/00_plan/active_rtl_source_scope.json").read_text(encoding="utf-8-sig"))
        target_paths = {item["path"] for item in scope["sources"]
                        if item["coverage_threshold_scope"] is True}
        control = build / "coverage_scope.vlt"
        lines = ["`verilator_config"]
        for item in scope["sources"]:
            if item["path"] not in target_paths:
                lines.append(f'coverage_off -file "{(snapshot / "dut/source" / item["path"]).as_posix()}"')
        lines.append('coverage_off -file "*tb_cmo_end_to_end.sv"')
        control.write_text("\n".join(lines) + "\n", encoding="utf-8")
        args.append(str(control))
    args.extend(f"+incdir+{snapshot / item}" for item in order["include_dirs"])
    args.extend(("-f", str(source_list)))
    run_logged(args, build, env, build / "verilator.log", 7200)
    compile_text = (build / "verilator.log").read_text(encoding="utf-8", errors="replace")
    warnings = re.findall(r"(?m)^%Warning-[^:\r\n]+", compile_text)
    errors = re.findall(r"(?m)^%Error[^\r\n]*", compile_text)
    if errors:
        raise RuntimeError(f"Verilator errors={len(errors)}; see {build / 'verilator.log'}")
    (build / "compile_summary.json").write_text(json.dumps({
        "hart_count": harts, "warning_count": len(warnings),
        "warning_kinds": sorted(set(warnings)), "error_count": 0,
        "warnings_kept_visible": True,
        "policy": "--Wno-fatal allows functional execution; no warning class is disabled or waived.",
        "coverage_enabled": coverage
    }, indent=2) + "\n", encoding="utf-8")

    runtime = Path(tools["runtime_include"])
    compiler = tools["compiler"]
    main_cpp = build / "sim_main.cpp"
    main_cpp.write_text(
        "#include <memory>\n#include <verilated.h>\n#include <verilated_cov.h>\n"
        f'#include "V{TOP}.h"\n'
        "int main(int argc, char** argv) {\n"
        "  const std::unique_ptr<VerilatedContext> context{new VerilatedContext};\n"
        "  context->commandArgs(argc, argv);\n"
        f"  const std::unique_ptr<V{TOP}> model{{new V{TOP}{{context.get(), \"TOP\"}}}};\n"
        "  while (!context->gotFinish()) { model->eval(); if (context->gotFinish()) break; "
        "if (model->eventsPending()) context->time(model->nextTimeSlot()); else context->timeInc(1); }\n"
        "  model->final();\n#if VM_COVERAGE\n  context->coveragep()->write();\n#endif\n"
        "  return context->gotError() ? 1 : 0;\n}\n", encoding="utf-8")
    cpp = sorted(objdir.glob("*.cpp")) + [main_cpp]
    runtime_names = ["verilated.cpp", "verilated_timing.cpp", "verilated_threads.cpp", "verilated_dpi.cpp"]
    if coverage:
        runtime_names.append("verilated_cov.cpp")
    cpp += [runtime / name for name in runtime_names]
    compiler_env = env.copy()
    compiler_env["PATH"] = str(Path(compiler).parent) + os.pathsep + compiler_env.get("PATH", "")
    tmp = build / "tmp"
    tmp.mkdir(exist_ok=True)
    for variable in ("TMP", "TEMP", "TMPDIR"):
        compiler_env[variable] = str(tmp)
    object_dir = build / "objects"
    object_dir.mkdir(exist_ok=True)
    def compile_cpp(source: Path) -> Path:
        obj = object_dir / (source.stem + "_" + hashlib.sha1(str(source).encode()).hexdigest()[:8] + ".o")
        run_logged([compiler, "-std=gnu++20", "-fcoroutines", "-O0", "-DVL_TIME_CONTEXT",
                    "-DVM_TIMING=1", "-DVM_TRACE=0", "-DVM_SC=0", f"-DVM_COVERAGE={1 if coverage else 0}",
                    "-DVM_VPI=0", "-Wno-attributes", f"-I{objdir}", f"-I{runtime}",
                    f"-I{runtime / 'vltstd'}", "-c", str(source), "-o", str(obj)],
                   build, compiler_env, build / "objects_logs" / (obj.stem + ".log"), 1200)
        return obj
    jobs = int(compiler_env.get("VLSIT_BUILD_JOBS", "1"))
    if jobs != 1:
        raise RuntimeError("the reviewed RAM budget requires exactly one C++ build worker")
    objects = []
    for index, source in enumerate(cpp, start=1):
        objects.append(compile_cpp(source))
        if index == 1 or index % 50 == 0 or index == len(cpp):
            print(f"C++ objects {harts}h: {index}/{len(cpp)}", flush=True)
    exe = build / f"V{TOP}.exe"
    response = build / "link.rsp"
    response.write_text("\n".join([*(f'"{path}"' for path in objects), "-pthread", "-latomic",
                                   f'-o "{exe}"']) + "\n", encoding="utf-8")
    run_logged([compiler, "@" + str(response)], build, compiler_env, build / "link.log", 1800)
    if not exe.is_file():
        raise RuntimeError(f"linked model missing for {harts} harts")
    return exe


def main() -> int:
    if len(sys.argv) not in (5, 6) or sys.argv[1] != "run" or (len(sys.argv) == 6 and sys.argv[5] != "--coverage"):
        print("usage: cluster_cmo_runner.py run PACKAGE_ROOT BASELINE_ID RUN_ID [--coverage]", file=sys.stderr)
        return 2
    try:
        coverage = len(sys.argv) == 6
        root, snapshot, run, tools, order, env = context(Path(sys.argv[2]), sys.argv[3], sys.argv[4])
        if run.exists():
            raise RuntimeError(f"run ID already exists; refusing overwrite: {run}")
        check = subprocess.run([sys.executable, str(snapshot / "scripts/vlsit_sim_workspace.py"),
                                "check", "--root", str(root), "--baseline", sys.argv[3]],
                               cwd=root, env=env, capture_output=True, text=True, check=False)
        if check.returncode:
            raise RuntimeError("package integrity check failed before CBO run: " + check.stdout + check.stderr)
        run.mkdir(parents=True)
        (run / "reports").mkdir()
        if coverage:
            (run / "coverage").mkdir()
        models = {harts: compile_harts(snapshot, run, tools, order, env, harts, coverage) for harts in (2, 4)}
        results = []
        for harts in (2, 4):
            for inject_error in (0, 1):
                case_id = f"CBO_H{harts}_AXI_ERROR{inject_error}"
                log = run / "reports" / f"{case_id}.log"
                cmd = [str(models[harts]), f"+INJECT_ERROR={inject_error}", "+SUPERVISOR=0"]
                wave = cov = None
                if coverage:
                    wave = run / "waveforms" / f"{case_id}.vcd"
                    wave.parent.mkdir(exist_ok=True)
                    cov = run / "coverage" / f"{case_id}.dat"
                    cmd.extend((f"+WAVE={wave.as_posix()}", f"+verilator+coverage+file+{cov}"))
                run_logged(cmd,
                           models[harts].parent, env, log, 600)
                text = log.read_text(encoding="utf-8", errors="replace")
                marker = f"PASS: real CVA6 CBO through arbiter/CCU/LLC; harts={harts} error={inject_error}"
                if marker not in text:
                    raise RuntimeError(f"expected pass marker missing for {case_id}; see {log}")
                if coverage and (not wave.is_file() or not cov.is_file() or not cov.stat().st_size):
                    raise RuntimeError(f"waveform/coverage missing for {case_id}")
                cycle_match = re.search(r"cycles=(\d+)", text)
                if not cycle_match:
                    raise RuntimeError(f"cycle count missing for {case_id}")
                results.append({"case": case_id, "status": "pass", "harts": harts,
                    "injected_axi_error": inject_error, "cycles": int(cycle_match.group(1)),
                    "waveform_sha256": sha(wave) if coverage else None,
                    "coverage_sha256": sha(cov) if coverage else None})
                print(f"PASS {case_id}: cycles={cycle_match.group(1)}", flush=True)
        report = {"schema_version": 1, "baseline_id": sys.argv[3], "top": TOP,
                  "timing_profile": TIMING_PROFILE,
                  "cases": results, "pass_count": len(results), "fail_count": 0,
                  "coverage": "collected" if coverage else "not_collected",
                  "limitation": "Directed CPU-instruction test for CBO success and AXI writeback fault; not full HDS closure."}
        (run / "reports" / "cluster_cmo_results.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
        print("CLUSTER_CBO_SUITE_PASS: 4/4 cases", flush=True)
        return 0
    except (OSError, KeyError, ValueError, RuntimeError, subprocess.SubprocessError) as exc:
        print(f"CLUSTER_CBO_SUITE_FAIL: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
