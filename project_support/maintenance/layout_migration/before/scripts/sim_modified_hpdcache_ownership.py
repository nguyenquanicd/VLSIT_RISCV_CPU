#!/usr/bin/env python3
"""Run a directed Verilator simulation of the modified HPDcache ownership path."""

from __future__ import annotations

import json
import shutil
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
HPDCACHE = ROOT / "rtl/third_party/hpdcache_cva6_pinned"
OUT = ROOT / "rtl/reports/hpdcache_ownership_sim"
TB_SOURCE = ROOT / "rtl/verification/hpdcache_ownership/tb_m_vlsit_riscv_hpd_ownership.sv"
VERILATOR = Path("C:/Tools/oss-cad-suite/bin/verilator_bin.exe")
VERILATOR_ROOT = Path("C:/Tools/oss-cad-suite/share/verilator")
CXX = Path("C:/Users/PC/Tools/msys64/ucrt64/bin/g++.exe")


def run(command: list[str], cwd: Path | None = None, timeout: int = 1800) -> subprocess.CompletedProcess[str]:
    result = subprocess.run(command, cwd=cwd or ROOT, text=True, capture_output=True, timeout=timeout)
    if result.returncode != 0:
        raise RuntimeError(
            f"Command failed ({result.returncode}): {subprocess.list2cmdline(command)}\n"
            f"{result.stdout}\n{result.stderr}"
        )
    return result


def main() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    lint_runner = ROOT / "scripts/lint_modified_cva6_cache_path.py"
    run([sys.executable, str(lint_runner), "--top-module", "hpdcache_query_lint", "--timeout-seconds", "60"])
    lint_result = json.loads(
        (ROOT / "rtl/reports/cva6_flush_path/subtop_hpdcache_query_lint/hpdcache_query_lint_result.json")
        .read_text(encoding="utf-8")
    )
    if not lint_result.get("passed"):
        raise RuntimeError("Configured HPDcache query lint did not pass")
    run_dir = ROOT / "rtl/reports/cva6_flush_path/subtop_hpdcache_query_lint"
    tb_path = OUT / "hpdcache_ownership_tb.sv"
    shutil.copyfile(TB_SOURCE, tb_path)
    flist = run_dir / "hpdcache_modified.Flist"

    ecc_dir = HPDCACHE / "rtl/src/utils/ecc"
    macro_dir = HPDCACHE / "rtl/src/common/macros/behav"
    ecc_files = [ecc_dir / "prim_secded_pkg.sv"]
    ecc_files += sorted(ecc_dir.glob("prim_secded_*enc.sv"))
    ecc_files += sorted(ecc_dir.glob("prim_secded_*dec.sv"))
    macro_files = sorted(macro_dir.glob("*.sv"))
    common_args = [f"+incdir+{ecc_dir.as_posix()}", "-f", str(flist)]
    common_args += [str(path) for path in ecc_files + macro_files]
    common_args.append(str(tb_path))
    lint_command = [
        str(VERILATOR), "--lint-only", "--timing", "-Wall", "-Wno-fatal",
        "--top-module", "hpdcache_ownership_tb",
    ] + common_args
    lint_run = run(lint_command, timeout=1800)
    (OUT / "tb_lint.log").write_text(lint_run.stdout + lint_run.stderr, encoding="utf-8")
    obj = OUT / "obj_dir"
    if obj.exists():
        shutil.rmtree(obj)
    obj.mkdir(parents=True)
    command = [
        str(VERILATOR), "--cc", "--main", "--timing", "-Wall", "-Wno-fatal",
        "--top-module", "hpdcache_ownership_tb", "--Mdir", str(obj),
    ] + common_args
    generated = run(command, timeout=1800)
    (OUT / "verilator.log").write_text(generated.stdout + generated.stderr, encoding="utf-8")

    include = VERILATOR_ROOT / "include"
    cxx_sources = sorted(obj.glob("*.cpp")) + [
        include / "verilated.cpp",
        include / "verilated_threads.cpp",
        include / "verilated_timing.cpp",
    ]
    executable = obj / "hpdcache_ownership_tb.exe"
    cxx_command = [
        str(CXX), "-std=c++20", "-O0", "-DVL_TIME_CONTEXT",
        "-I", str(obj), "-I", str(include), "-I", str(include / "vltstd"),
    ] + [str(path) for path in cxx_sources] + [
        "-o", str(executable),
    ]
    compiled = run(cxx_command, timeout=1800)
    (OUT / "compile.log").write_text(compiled.stdout + compiled.stderr, encoding="utf-8")
    simulated = run([str(executable)], timeout=1800)
    (OUT / "simulation.log").write_text(simulated.stdout + simulated.stderr, encoding="utf-8")
    result = {
        "passed": "PASS: ownership-gated refill and Shared-store invalidate/replay" in simulated.stdout,
        "top": "hpdcache_ownership_tb",
        "scope": [
            "configured modified HPDcache",
            "ownership request held without refill until grant",
            "Shared store invalidates/replays and requests exclusive ownership",
        ],
        "simulator": str(VERILATOR),
        "testbench_lint_passed": True,
        "lint": {
            "passed": lint_result["passed"],
            "errors": lint_result["errors"],
            "warnings": lint_result["warnings"],
        },
        "result": simulated.stdout.strip(),
    }
    (OUT / "result.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    if result["passed"]:
        shutil.rmtree(obj)
    print(json.dumps(result))
    return 0 if result["passed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
