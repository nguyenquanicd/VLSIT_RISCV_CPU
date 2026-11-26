#!/usr/bin/env python3
"""Build and run retained component-directed tests from an isolated snapshot."""
from __future__ import annotations

import hashlib
import json
import os
import re
import subprocess
import sys
import time
from dataclasses import dataclass
from pathlib import Path

from resource_guard import run_logged


@dataclass(frozen=True)
class Case:
    case_id: str
    top: str
    sources: tuple[str, ...]
    parameters: tuple[tuple[str, str], ...] = ()


COH_BASE = (
    "rtl/common/vlsit/coherence/m_vlsit_riscv_coh_txn_table.sv",
    "rtl/common/vlsit/coherence/m_vlsit_riscv_coh_bank_arb.sv",
    "rtl/common/vlsit/coherence/m_vlsit_riscv_sharer_directory.sv",
    "rtl/common/vlsit/coherence/m_vlsit_riscv_probe_scheduler.sv",
    "rtl/common/vlsit/coherence/m_vlsit_riscv_coh_fabric.sv",
)


def cases() -> list[Case]:
    rows = [Case("addr_region_table", "tb_m_vlsit_riscv_addr_decode", (
        "rtl/common/vlsit/address_map/m_vlsit_riscv_addr_decode.sv",
        "tests/t/c/addr_region_table/tb_m_vlsit_riscv_addr_decode.sv"))]
    for hart_count in (2, 4):
        rows.extend((
            Case(f"cmo_controller_{hart_count}h", "tb_m_vlsit_riscv_cmo_controller", (
                "rtl/common/vlsit/maintenance/m_vlsit_riscv_cmo_controller.sv",
                "tests/t/c/cmo_controller/tb_m_vlsit_riscv_cmo_controller.sv"),
                (("PARA_CPU_NUM", str(hart_count)),)),
            Case(f"cmo_arbiter_{hart_count}h", "tb_cmo_arbiter", (
                "rtl/common/vlsit/maintenance/m_vlsit_riscv_cmo_arbiter.sv",
                "tests/t/c/cmo_metadata/tb_cmo_arbiter.sv"), (("HARTS", str(hart_count)),)),
            Case(f"cmo_ccu_{hart_count}h", "tb_cmo_ccu", COH_BASE + (
                "tests/t/c/cmo_metadata/tb_cmo_ccu.sv",), (("HARTS", str(hart_count)),)),
            Case(f"coh_tile_array_{hart_count}h", "tb_m_vlsit_riscv_coh_tile_array", COH_BASE + (
                "rtl/common/vlsit/coherence/m_vlsit_riscv_cache_line_locks.sv",
                "rtl/common/vlsit/coherence/m_vlsit_riscv_tile_coh_adapter.sv",
                "rtl/common/vlsit/coherence/m_vlsit_riscv_coh_tile_array.sv",
                "tests/t/c/coh_tile_array/tb_m_vlsit_riscv_coh_tile_array.sv"),
                (("PARA_CPU_NUM", str(hart_count)),)),
            Case(f"tile_coh_adapter_{hart_count}h", "tb_m_vlsit_riscv_tile_coh_adapter", (
                "rtl/common/vlsit/coherence/m_vlsit_riscv_cache_line_locks.sv",
                "rtl/common/vlsit/coherence/m_vlsit_riscv_tile_coh_adapter.sv",
                "tests/t/c/tile_coh_adapter/tb_m_vlsit_riscv_tile_coh_adapter.sv")),
        ))
    rows.extend((
        Case("coherence_fabric", "tb_m_vlsit_riscv_coh_fabric", COH_BASE + (
            "tests/t/c/coherence/tb_m_vlsit_riscv_coh_fabric.sv",)),
        Case("hpd_probe_engine", "tb_m_vlsit_riscv_hpd_probe_engine", (
            "rtl/common/vlsit/coherence/m_vlsit_riscv_hpd_probe_engine.sv",
            "tests/t/c/hpd_probe_engine/tb_m_vlsit_riscv_hpd_probe_engine.sv")),
    ))
    return rows


def sha(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def read_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8-sig"))


def load_context(root: Path, baseline: str, run_id: str):
    root = root.resolve()
    snapshot = (root / "snapshots" / baseline).resolve()
    run = (root / "runs" / run_id).resolve()
    if root not in snapshot.parents or root not in run.parents:
        raise RuntimeError("snapshot or run path escaped package root")
    if not (snapshot / "env/workspace_manifest.json").is_file():
        raise RuntimeError(f"unknown sealed baseline: {baseline}")
    tools = read_json(snapshot / "env/toolchain.json")
    order = read_json(snapshot / "env/source_order.json")
    replay = read_json(snapshot / "env/replay_manifest.json")
    env = os.environ.copy()
    env["PATH"] = tools["path"]
    for variable in replay["environment"]:
        if variable["name"] in ("VERILATOR_ROOT", "VLSIT_BUILD_JOBS", "VLSIT_MIN_FREE_RAM_BYTES",
                                 "VLSIT_MIN_FREE_DISK_BYTES", "VLSIT_MAX_RAM_DROP_BYTES",
                                 "VLSIT_RAM_GUARD_MARGIN_BYTES", "VLSIT_RAM_POLL_INTERVAL_MS"):
            env[variable["name"]] = variable["value"]
    env["VLSIT_BASELINE_ID"] = baseline
    env["VLSIT_RUN_ID"] = run_id
    env["VLSIT_SNAPSHOT"] = str(snapshot)
    env["VLSIT_RUN_ROOT"] = str(run)
    return snapshot, run, tools, order, env


def compile_case(case: Case, snapshot: Path, run: Path, tools: dict, include_dirs: list[str], env: dict) -> Path:
    build = run / "build" / case.case_id
    objdir = build / "obj"
    objdir.mkdir(parents=True, exist_ok=True)
    sources = [snapshot / "dut/source" / item for item in case.sources if item.startswith("rtl/")]
    sources += [snapshot / item for item in case.sources if item.startswith("tests/")]
    if len(sources) != len(case.sources):
        raise RuntimeError(f"unsupported source path in {case.case_id}")
    for source in sources:
        if not source.is_file():
            raise RuntimeError(f"missing isolated source: {source}")
    source_list = build / "sources.f"
    source_list.write_text("\n".join(path.as_posix() for path in sources) + "\n", encoding="utf-8")
    args = [tools["verilator"], "--cc", "--timing", "--assert", "--coverage-line",
            "--coverage-expr", "--coverage-toggle", "--timescale", "1ns/1ps",
            "--top-module", case.top, "--Wno-fatal", "--output-split", "1000",
            "--output-split-cfuncs", "250",
            "--Mdir", str(objdir)]
    for name, value in case.parameters:
        args.append(f"-G{name}={value}")
    args.extend(f"+incdir+{snapshot / item}" for item in include_dirs)
    args.extend(("-f", str(source_list)))
    run_logged(args, build, env, build / "verilator.log", 900)
    diagnostic = (build / "verilator.log").read_text(encoding="utf-8", errors="replace")
    errors = re.findall(r"(?m)^%Error[^\r\n]*", diagnostic)
    warnings = re.findall(r"(?m)^%Warning-[^:\r\n]+", diagnostic)
    if errors:
        raise RuntimeError(f"{case.case_id}: Verilator errors={len(errors)}; see {build / 'verilator.log'}")
    (build / "compile_summary.json").write_text(json.dumps({
        "case": case.case_id, "top": case.top, "parameters": dict(case.parameters),
        "warning_count": len(warnings), "warning_kinds": sorted(set(warnings)),
        "warning_policy": "Warnings remain visible; --Wno-fatal only permits simulation.",
        "error_count": 0,
    }, indent=2) + "\n", encoding="utf-8")

    runtime = Path(tools["runtime_include"])
    compiler = tools["compiler"]
    main_cpp = build / "sim_main.cpp"
    main_cpp.write_text(
        "#include <memory>\n#include <verilated.h>\n#include <verilated_cov.h>\n"
        f'#include "V{case.top}.h"\n'
        "int main(int argc, char** argv) {\n"
        "  const std::unique_ptr<VerilatedContext> context{new VerilatedContext};\n"
        "  context->commandArgs(argc, argv);\n"
        f"  const std::unique_ptr<V{case.top}> model{{new V{case.top}{{context.get(), \"TOP\"}}}};\n"
        "  while (!context->gotFinish()) { model->eval(); if (context->gotFinish()) break; "
        "if (model->eventsPending()) context->time(model->nextTimeSlot()); else context->timeInc(1); }\n"
        "  model->final();\n#if VM_COVERAGE\n  context->coveragep()->write();\n#endif\n"
        "  return context->gotError() ? 1 : 0;\n}\n", encoding="utf-8")
    cpp = sorted(objdir.glob("*.cpp")) + [main_cpp]
    cpp += [runtime / name for name in ("verilated.cpp", "verilated_timing.cpp",
            "verilated_threads.cpp", "verilated_dpi.cpp", "verilated_cov.cpp")]
    for source in cpp:
        if not source.is_file():
            raise RuntimeError(f"missing generated/runtime C++ source: {source}")
    compiler_env = env.copy()
    compiler_env["PATH"] = str(Path(compiler).parent) + os.pathsep + compiler_env.get("PATH", "")
    tmp = build / "tmp"
    tmp.mkdir(exist_ok=True)
    for variable in ("TMP", "TEMP", "TMPDIR"):
        compiler_env[variable] = str(tmp)
    objects = []
    object_dir = build / "objects"
    object_dir.mkdir(exist_ok=True)
    def compile_cpp(source: Path) -> Path:
        obj = object_dir / (source.stem + "_" + hashlib.sha1(str(source).encode()).hexdigest()[:8] + ".o")
        run_logged([compiler, "-std=gnu++20", "-fcoroutines", "-O0", "-DVL_TIME_CONTEXT",
                    "-DVM_TIMING=1", "-DVM_TRACE=0", "-DVM_SC=0", "-DVM_COVERAGE=1",
                    "-DVM_VPI=0", "-Wno-attributes", f"-I{objdir}", f"-I{runtime}",
                    f"-I{runtime / 'vltstd'}", "-c", str(source), "-o", str(obj)],
                   build, compiler_env, build / "objects_logs" / (obj.stem + ".log"), 600)
        return obj
    jobs = int(compiler_env.get("VLSIT_BUILD_JOBS", "1"))
    if jobs != 1:
        raise RuntimeError("the reviewed RAM budget requires exactly one C++ build worker")
    for source in cpp:
        objects.append(compile_cpp(source))
    exe = build / f"V{case.top}.exe"
    rsp = build / "link.rsp"
    rsp.write_text("\n".join([*(f'"{obj}"' for obj in objects), "-pthread", "-latomic",
                               f' -o "{exe}"']) + "\n", encoding="utf-8")
    run_logged([compiler, "@" + str(rsp)], build, compiler_env, build / "link.log", 600)
    if not exe.is_file():
        raise RuntimeError(f"executable missing for {case.case_id}")
    return exe


def main() -> int:
    if len(sys.argv) == 2 and sys.argv[1] == "list":
        for case in cases():
            print(case.case_id)
        return 0
    if len(sys.argv) < 5 or sys.argv[1] != "run":
        print("usage: component_runner.py list | run PACKAGE_ROOT BASELINE_ID RUN_ID [CASE_ID ...]", file=sys.stderr)
        return 2
    try:
        root = Path(sys.argv[2])
        baseline = sys.argv[3]
        run_id = sys.argv[4]
        selected_ids = set(sys.argv[5:])
        if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9_.-]*", run_id):
            raise RuntimeError("invalid run ID")
        all_cases = cases()
        known_ids = {case.case_id for case in all_cases}
        if selected_ids - known_ids:
            raise RuntimeError("unknown component case(s): " + ", ".join(sorted(selected_ids - known_ids)))
        selected_cases = [case for case in all_cases if not selected_ids or case.case_id in selected_ids]
        snapshot, run, tools, order, env = load_context(root, baseline, run_id)
        if run.exists():
            raise RuntimeError(f"run directory already exists; refusing overwrite: {run}")
        run.mkdir(parents=True, exist_ok=False)
        (run / "reports").mkdir()
        (run / "coverage").mkdir()
        case_results = []
        for case in selected_cases:
            print(f"BUILD {case.case_id}", flush=True)
            try:
                exe = compile_case(case, snapshot, run, tools, order["include_dirs"], env)
                cov = run / "coverage" / f"{case.case_id}.dat"
                log = run / "reports" / f"{case.case_id}.log"
                run_logged([str(exe), f"+verilator+coverage+file+{cov}"], exe.parent,
                           env, log, 300)
                text = log.read_text(encoding="utf-8", errors="replace")
                if "PASS:" not in text.upper():
                    raise RuntimeError(f"PASS marker missing; see {log}")
                if not cov.is_file() or not cov.stat().st_size:
                    raise RuntimeError(f"coverage output missing: {cov}")
                sources = [snapshot / "dut/source" / item if item.startswith("rtl/") else snapshot / item
                           for item in case.sources]
                case_results.append({"case": case.case_id, "status": "pass", "top": case.top,
                    "parameters": dict(case.parameters), "pass_marker": next(
                        line.strip() for line in text.splitlines() if "PASS:" in line.upper()),
                    "source_hashes": {str(source.relative_to(snapshot)): sha(source) for source in sources},
                    "coverage_sha256": sha(cov), "compile_summary": read_json(exe.parent / "compile_summary.json")})
                print(f"PASS {case.case_id}", flush=True)
            except (OSError, RuntimeError, subprocess.SubprocessError) as exc:
                case_results.append({"case": case.case_id, "status": "fail", "top": case.top,
                    "parameters": dict(case.parameters), "reason": str(exc)})
                print(f"FAIL {case.case_id}: {exc}", flush=True)
                if "approved floor" in str(exc):
                    break
        failed = sum(row["status"] != "pass" for row in case_results)
        report = {"schema_version": 1, "baseline_id": baseline,
                  "suite": "component-directed", "selected_case_ids": [case.case_id for case in selected_cases],
                  "completed_case_ids": [row["case"] for row in case_results], "cases": case_results,
                  "pass_count": len(case_results) - failed, "fail_count": failed,
                  "limitation": "Component benches exercise isolated DUT blocks; they do not close the HDS or replace end-to-end independent-scoreboard tests."}
        reports = run / "reports"
        reports.mkdir(exist_ok=True)
        (reports / "component_results.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
        print(f"COMPONENT_SUITE_{'FAIL' if failed else 'PASS'}: {len(case_results)-failed}/{len(case_results)} cases passed", flush=True)
        return 1 if failed else 0
    except (OSError, KeyError, ValueError, RuntimeError, subprocess.SubprocessError) as exc:
        print(f"COMPONENT_SUITE_FAIL: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
