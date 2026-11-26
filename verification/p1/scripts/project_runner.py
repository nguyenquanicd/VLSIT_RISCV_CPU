#!/usr/bin/env python3
"""Build and execute the retained isolated CVA6 cluster qualification smoke suite."""
from __future__ import annotations

import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import time
from pathlib import Path

from resource_guard import run_logged

HARTS = (2, 4)
TIMING_PROFILE = 1
CASE_MAP = {
    "H2_FENCEI_SUCCESS": (2, 0, 0),
    "H2_FENCEI_AXI_ERROR": (2, 1, 1),
    "H4_FENCEI_SUCCESS": (4, 0, 0),
    "H4_FENCEI_AXI_ERROR": (4, 1, 0),
}


def sha(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def read_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8-sig"))


def must(condition: bool, message: str) -> None:
    if not condition:
        raise RuntimeError(message)


def paths():
    snapshot = Path(os.environ["VLSIT_SNAPSHOT"]).resolve()
    run = Path(os.environ["VLSIT_RUN_ROOT"]).resolve()
    toolchain = read_json(snapshot / "env/toolchain.json")
    runtime = Path(toolchain["runtime_include"])
    return snapshot, run, toolchain, runtime


def sources(snapshot: Path) -> tuple[list[str], list[str]]:
    data = read_json(snapshot / "env/source_order.json")
    all_sources = [snapshot / rel for rel in data["source_order"]]
    production_llc = "/rtl/common/vlsit/cache/m_vlsit_axi_llc.sv".lower()
    filtered = [p for p in all_sources if not p.as_posix().lower().endswith(production_llc)]
    need_native = snapshot / "tests/t/n/fence_i_end_to_end/m_vlsit_axi_llc_native.sv"
    need_shim = snapshot / "tests/t/n/fence_i_end_to_end/m_vlsit_axi_llc.sv"
    bench = snapshot / "tb/fence_i_end_to_end/tb_fence_i_end_to_end.sv"
    must(len(filtered) + 1 == len(all_sources), "fault shim must replace exactly one production LLC wrapper")
    for path in (need_native, need_shim, bench):
        must(path.is_file(), f"retained verification source missing: {path.relative_to(snapshot)}")
    filtered.extend((need_native, need_shim, bench))
    includes = [snapshot / rel for rel in read_json(snapshot / "env/source_order.json")["include_dirs"]]
    return [p.as_posix() for p in filtered], [p.as_posix() for p in includes]


def compile_one(snapshot: Path, run: Path, toolchain: dict, runtime: Path,
                hart_count: int, coverage: bool) -> Path:
    suffix = "_cov" if coverage else ""
    build = run / "build" / f"fence_{hart_count}h_tp{TIMING_PROFILE}{suffix}"
    objdir = build / "obj"
    objdir.mkdir(parents=True, exist_ok=True)
    model_top = "tb_fence_i_end_to_end"
    verilator = toolchain["verilator"]
    compiler = toolchain["compiler"]
    model_sources, include_dirs = sources(snapshot)
    filelist = build / "ordered_sources.f"
    filelist.write_text("\n".join(model_sources) + "\n", encoding="utf-8")
    for inc in include_dirs:
        must(Path(inc).is_dir(), f"missing retained include directory {inc}")
    verilator_cmd = [verilator, "--cc", "--timing", "--assert", "-O0", "-fno-inline", "-fno-inline-cfuncs", "--timescale", "1ns/1ps",
                     "--top-module", model_top, f"-GHARTS={hart_count}", "-GTRACE=0",
                     f"-GTIMING_PROFILE={TIMING_PROFILE}",
                     "--Wno-fatal", "--output-split", "500", "--output-split-cfuncs", "100",
                     "--Mdir", str(objdir)]
    control = None
    if coverage:
        verilator_cmd[1:1] = ["--coverage-line", "--coverage-expr", "--coverage-toggle"]
        scope = read_json(snapshot / "docs/00_plan/active_rtl_source_scope.json")
        scoped_paths = {entry["path"] for entry in scope["sources"]
                        if entry["coverage_threshold_scope"] is True}
        control = build / "coverage_scope.vlt"
        control_lines = ["`verilator_config"]
        for entry in scope["sources"]:
            if entry["path"] not in scoped_paths:
                source_path = (snapshot / "dut/source" / entry["path"]).as_posix()
                control_lines.append(f'coverage_off -file "{source_path}"')
        control_lines.append('coverage_off -file "*tb_fence_i_end_to_end.sv"')
        control.write_text("\n".join(control_lines) + "\n", encoding="utf-8")
        verilator_cmd.extend((str(control),))
    verilator_cmd.extend(f"+incdir+{path}" for path in include_dirs)
    verilator_cmd.extend(("-f", str(filelist)))
    run_logged(verilator_cmd, build, os.environ.copy(), build / "verilator.log", 7200)
    diagnostics = (build / "verilator.log").read_text(encoding="utf-8", errors="replace")
    warnings = re.findall(r"(?m)^%Warning-[^:\r\n]+", diagnostics)
    errors = re.findall(r"(?m)^%Error[^\r\n]*", diagnostics)
    must(not errors, f"Verilator diagnostics: {len(warnings)} warnings, {len(errors)} errors")
    warning_kinds = sorted(set(warnings))
    (build / "compile_summary.json").write_text(json.dumps({
        "hart_count": hart_count,
        "timing_profile": TIMING_PROFILE,
        "verilator_warnings_are_visible_nonfatal": True,
        "warning_count": len(warnings),
        "warning_kinds": warning_kinds,
        "warning_policy": "--Wno-fatal preserves every warning in verilator.log; no warning class is disabled or waived.",
        "error_count": len(errors),
        "coverage_enabled": coverage,
        "coverage_target_source_count": (sum(entry["coverage_threshold_scope"] is True
                                              for entry in read_json(snapshot / "docs/00_plan/active_rtl_source_scope.json")["sources"])
                                          if coverage else 0),
    }, indent=2) + "\n", encoding="utf-8")

    generated = sorted(objdir.glob("*.cpp"))
    must(generated, f"Verilator emitted no C++ sources for {hart_count} harts")
    sim_main = build / "sim_main.cpp"
    template = snapshot / "scripts/generators/templates/sim_main.cpp.tpl"
    generator = snapshot / "scripts/generators/generate_sim_main.py"
    run_logged([sys.executable, str(generator), "--template", str(template), "--out", str(sim_main)],
               build, os.environ.copy(), build / "generate_sim_main.log", 60)
    cpp_sources = generated + [sim_main]
    runtime_names = ["verilated.cpp", "verilated_timing.cpp", "verilated_threads.cpp",
                     "verilated_dpi.cpp"]
    if coverage:
        runtime_names.append("verilated_cov.cpp")
    runtime_sources = [runtime / name for name in runtime_names]
    for source in runtime_sources:
        must(source.is_file(), f"Verilator runtime source missing: {source}")
    cpp_sources.extend(runtime_sources)
    compiler_path = Path(compiler)
    compiler_env = os.environ.copy()
    compiler_env["PATH"] = str(compiler_path.parent) + os.pathsep + compiler_env.get("PATH", "")
    compiler_tmp = build / "tmp"
    compiler_tmp.mkdir(parents=True, exist_ok=True)
    compiler_env["TMP"] = str(compiler_tmp)
    compiler_env["TEMP"] = str(compiler_tmp)
    compiler_env["TMPDIR"] = str(compiler_tmp)
    obj_paths: list[Path] = []
    log_dir = build / "object_logs"
    log_dir.mkdir(exist_ok=True)

    def compile_cpp(source: Path) -> Path:
        obj = build / "objects" / (source.stem + "_" + hashlib.sha1(str(source).encode()).hexdigest()[:8] + ".o")
        obj.parent.mkdir(parents=True, exist_ok=True)
        log = log_dir / (obj.stem + ".log")
        cmd = [compiler, "-std=gnu++20", "-fcoroutines", "-O0", "-DVL_TIME_CONTEXT",
               "-DVM_TIMING=1", "-DVM_TRACE=0", "-DVM_SC=0",
               f"-DVM_COVERAGE={1 if coverage else 0}", "-DVM_VPI=0",
               "-Wno-attributes", f"-I{objdir}", f"-I{runtime}", f"-I{runtime / 'vltstd'}",
               "-c", str(source), "-o", str(obj)]
        run_logged(cmd, build, compiler_env, log, 1200)
        return obj

    started = time.monotonic()
    jobs = int(os.environ.get("VLSIT_BUILD_JOBS", "1"))
    must(jobs == 1, "the reviewed RAM budget requires exactly one C++ build worker")
    for index, source in enumerate(cpp_sources, start=1):
        obj_paths.append(compile_cpp(source))
        # The generated translation unit is reproducible from the sealed RTL
        # and Verilator command. Remove it only after its object compiled so
        # the guarded run stores one source/object working set, not both.
        source.unlink()
        if index == 1 or index % 25 == 0 or index == len(cpp_sources):
            print(f"C++ objects {hart_count}h: {index}/{len(cpp_sources)} ({time.monotonic()-started:.0f}s)", flush=True)
    exe = build / f"V{model_top}.exe"
    response = build / "link.rsp"
    response.write_text("\n".join([*(f'"{p}"' for p in obj_paths),
                                     "-pthread", "-latomic", "-o", f'"{exe}"']) + "\n",
                         encoding="utf-8")
    link_cmd = [compiler, "@" + str(response)]
    run_logged(link_cmd, build, compiler_env, build / "link.log", 1800)
    must(exe.is_file() and exe.stat().st_size > 100_000, f"model executable missing/implausible: {exe}")
    # The executable is the only generated build product required by the
    # following simulation phase. Keep commands/logs/summary for audit, while
    # dropping reproducible C++ headers and object files to reduce disk use.
    shutil.rmtree(objdir)
    shutil.rmtree(build / "objects")
    for transient in (build / "tmp", build / "sim_main.cpp", build / "link.rsp"):
        if transient.is_dir():
            shutil.rmtree(transient)
        else:
            transient.unlink(missing_ok=True)
    return exe


def compile_action(coverage: bool) -> int:
    snapshot, run, toolchain, runtime = paths()
    for hart_count in HARTS:
        suffix = "_cov" if coverage else ""
        completed = run / "build" / f"fence_{hart_count}h_tp{TIMING_PROFILE}{suffix}" / "Vtb_fence_i_end_to_end.exe"
        summary = run / "build" / f"fence_{hart_count}h_tp{TIMING_PROFILE}{suffix}" / "compile_summary.json"
        if completed.is_file() and summary.is_file():
            print(f"Using retained completed model for {hart_count} harts", flush=True)
            continue
        print(f"Building isolated FENCE.I model for {hart_count} harts", flush=True)
        compile_one(snapshot, run, toolchain, runtime, hart_count, coverage)
    return 0


def simulate_action(coverage: bool) -> int:
    snapshot, run, toolchain, _ = paths()
    cases = read_json(snapshot / "tests/generated/initial_case_manifest.json")["cases"]
    expected = set(read_json(snapshot / "env/replay_manifest.json")["replay_plan"]["expected_cases"])
    must({case["id"] for case in cases} == expected, "generated case manifest differs from approved result scope")
    reports = run / "reports"
    reports.mkdir(exist_ok=True)
    attempts = [int(path.name.split("_", 1)[1]) for path in reports.glob("attempt_*")
                if path.is_dir() and path.name.split("_", 1)[1].isdigit()]
    attempt_id = max(attempts, default=0) + 1
    attempt_name = f"attempt_{attempt_id:03d}"
    attempt_reports = reports / attempt_name
    attempt_waveforms = run / "waveforms" / attempt_name
    directories = [attempt_reports]
    if coverage:
        (run / "coverage").mkdir(exist_ok=True)
        directories.extend((run / "coverage" / attempt_name, attempt_waveforms))
    for directory in directories:
        directory.mkdir(parents=True, exist_ok=False)
    results = []
    case_coverage_paths = []
    compile_summaries = {}
    for harts in HARTS:
        suffix = "_cov" if coverage else ""
        summary_path = run / "build" / f"fence_{harts}h_tp{TIMING_PROFILE}{suffix}" / "compile_summary.json"
        must(summary_path.is_file(), f"compile diagnostic summary missing for {harts} harts")
        compile_summaries[str(harts)] = read_json(summary_path)
    for case in cases:
        case_id = case["id"]
        harts, inject_error, supervisor = CASE_MAP[case_id]
        suffix = "_cov" if coverage else ""
        exe = run / "build" / f"fence_{harts}h_tp{TIMING_PROFILE}{suffix}" / "Vtb_fence_i_end_to_end.exe"
        must(exe.is_file(), f"fresh model executable missing: {exe}")
        log = attempt_reports / f"{case_id}.log"
        cmd = [str(exe), f"+INJECT_ERROR={inject_error}", f"+SUPERVISOR={supervisor}"]
        if coverage:
            vcd = attempt_waveforms / f"{case_id}.vcd"
            cov = run / "coverage" / attempt_name / f"{case_id}.dat"
            cmd.extend((f"+WAVE={vcd}", f"+verilator+coverage+file+{cov}"))
        run_logged(cmd, run / "build" / f"fence_{harts}h_tp{TIMING_PROFILE}{suffix}", os.environ.copy(), log, 300)
        text = log.read_text(encoding="utf-8", errors="replace")
        expected_marker = f"PASS: real CVA6 FENCE.I through arbiter/CCU/LLC; harts={harts} error={inject_error}"
        must(expected_marker in text, f"functional pass marker missing: {case_id}")
        must(f"CHECK profile={TIMING_PROFILE} PMU CCU request snapshot=" in text,
             f"profile {TIMING_PROFILE} PMU event/snapshot check missing: {case_id}")
        hits = re.findall(r"AXI-IHI0022 ASSERT (\d+) hits=(\d+)", text)
        must(len(hits) == 20 and all(int(value) > 0 for _, value in hits), f"AXI assertions incomplete: {case_id}")
        if coverage:
            must(vcd.is_file() and vcd.stat().st_size > 100, f"event VCD missing: {case_id}")
            must(cov.is_file() and cov.stat().st_size > 0, f"Verilator coverage missing: {case_id}")
            case_coverage_paths.append(cov)
        cycles_match = re.search(r"cycles=(\d+)", text)
        must(cycles_match, f"cycle count missing: {case_id}")
        cycles = int(cycles_match.group(1))
        hit_total = sum(int(value) for _, value in hits)
        results.append({"id": case_id, "status": "pass", "checks": hit_total + 2, "errors": 0,
                        "observables": {"harts": harts, "injected_axi_error": inject_error,
                                        "supervisor_mode": supervisor,
                                        "cycles": cycles, "protocol_assertion_count": 20,
                                        "protocol_assertion_hits": hit_total,
                                        "waveform_sha256": sha(vcd) if coverage else None,
                                        "coverage_sha256": sha(cov) if coverage else None}})
        print(f"PASS {case_id}: cycles={cycles}, AXI assertion hits={hit_total}", flush=True)
    coverage_summary = {"status": "not_collected",
                        "reason": "Full-hierarchy functional lane omits coverage; use the separate scoped-coverage lane."}
    if coverage:
        coverage_tool = toolchain["verilator_coverage"]
        merged_coverage = run / "coverage" / attempt_name / "merged.dat"
        run_logged([coverage_tool, "--write", str(merged_coverage), *map(str, case_coverage_paths)],
                   run / "build", os.environ.copy(), attempt_reports / "coverage_merge.log", 1800)
        coverage_summary_log = attempt_reports / "coverage_summary.log"
        run_logged([coverage_tool, "--report", "summary", str(merged_coverage)],
                   run / "build", os.environ.copy(), coverage_summary_log, 600)
        summary_text = coverage_summary_log.read_text(encoding="utf-8", errors="replace")
        coverage_summary = {"status": "collected", "native_verilator_report": summary_text.strip()}
        for metric in ("line", "toggle", "expr"):
            match = re.search(rf"{metric}\s*:\s*([\d.]+)%\s*\(\s*(\d+)\s*/\s*(\d+)\)", summary_text)
            must(match, f"Verilator coverage summary does not contain {metric} metric")
            coverage_summary[metric] = {"percent": float(match.group(1)),
                                        "covered": int(match.group(2)), "points": int(match.group(3))}
        source_union_json = attempt_reports / "coverage_source_union.json"
        source_union_markdown = attempt_reports / "coverage_source_union.md"
        scope_path = snapshot / "docs/00_plan/active_rtl_source_scope.json"
        source_summary_script = snapshot / "scripts/coverage_source_summary.py"
        run_logged([sys.executable, str(source_summary_script), "--scope", str(scope_path),
                    "--merged", str(merged_coverage), "--json", str(source_union_json),
                    "--markdown", str(source_union_markdown)],
                   run / "build", os.environ.copy(), attempt_reports / "coverage_source_union.log", 1800)
        source_union = read_json(source_union_json)
        coverage_summary["threshold_source_union"] = source_union["metrics"]
        coverage_summary["threshold_source_count"] = source_union["scoped_source_count"]
        coverage_summary["threshold_source_instrumented"] = source_union["instrumented_source_count"]
        coverage_summary["threshold_source_uninstrumented"] = source_union["never_instrumented_source_count"]
        coverage_summary["merged_coverage_sha256"] = sha(merged_coverage)
    result = {
        "schema_version": 1,
        "complete": True,
        "configuration": read_json(snapshot / "env/replay_manifest.json")["configuration"],
        "test": read_json(snapshot / "env/replay_manifest.json")["test"],
        "top": read_json(snapshot / "env/replay_manifest.json")["top"],
        "seed": read_json(snapshot / "env/replay_manifest.json")["seed"],
        "timing_profile": TIMING_PROFILE,
        "baseline_id": os.environ["VLSIT_BASELINE_ID"],
        "cases": [{key: value for key, value in row.items() if key != "observables"} for row in results],
        "observables": {"compile_diagnostics": compile_summaries,
                        "coverage": coverage_summary,
                        "cases": {row["id"]: row["observables"] for row in results}},
    }
    (reports / "result.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    return 0


def main() -> int:
    actions = {"compile": (compile_action, False), "simulate": (None, False),
               "compile-coverage": (compile_action, True), "simulate-coverage": (None, True)}
    if len(sys.argv) != 2 or sys.argv[1] not in actions:
        print("usage: project_runner.py compile|simulate|compile-coverage|simulate-coverage", file=sys.stderr)
        return 2
    action, coverage = actions[sys.argv[1]]
    try:
        return action(coverage) if action else simulate_action(coverage)
    except (OSError, KeyError, ValueError, RuntimeError, subprocess.SubprocessError) as exc:
        print(f"RUNNER FAILURE: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
