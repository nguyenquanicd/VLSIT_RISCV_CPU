#!/usr/bin/env python3
"""Lint and simulate the AXI4+ATOP memory mux in dual and quad profiles."""

from __future__ import annotations

import json
import shutil
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "rtl/reports/axi_mem_mux"
TB = ROOT / "rtl/verification/axi_mem_mux/tb_m_vlsit_riscv_axi_mem_mux.sv"
VERILATOR = Path("C:/Tools/oss-cad-suite/bin/verilator_bin.exe")
VERILATOR_ROOT = Path("C:/Tools/oss-cad-suite/share/verilator")
CXX = Path("C:/Users/PC/Tools/msys64/ucrt64/bin/g++.exe")


def run(command: list[str], timeout: int = 900) -> subprocess.CompletedProcess[str]:
    result = subprocess.run(command, cwd=ROOT, text=True, capture_output=True, timeout=timeout)
    if result.returncode != 0:
        raise RuntimeError(
            f"Command failed ({result.returncode}): {subprocess.list2cmdline(command)}\n"
            f"{result.stdout}\n{result.stderr}"
        )
    return result


def main() -> int:
    run([sys.executable, str(ROOT / "scripts/lint_axi_mem_mux.py")])
    filelist = OUT / "filelist.f"
    results = []
    for hart_num in (2, 4):
        obj = OUT / f"sim_{hart_num}_obj"
        if obj.exists():
            shutil.rmtree(obj)
        obj.mkdir(parents=True)
        common = [
            "--timing", "-Wall", "-Wno-fatal", "--top-module", "tb_m_vlsit_riscv_axi_mem_mux",
            f"-GPARA_CPU_NUM={hart_num}",
        ]
        linted = run([str(VERILATOR), "--lint-only", *common, "-f", str(filelist), str(TB)])
        (OUT / f"tb_lint_{hart_num}_harts.log").write_text(linted.stdout + linted.stderr, encoding="utf-8")
        generated = run([
            str(VERILATOR), "--cc", "--main", *common,
            "--Mdir", str(obj), "-f", str(filelist), str(TB),
        ])
        (OUT / f"verilator_{hart_num}_harts.log").write_text(generated.stdout + generated.stderr, encoding="utf-8")

        include = VERILATOR_ROOT / "include"
        cxx_sources = sorted(obj.glob("*.cpp")) + [
            include / "verilated.cpp",
            include / "verilated_threads.cpp",
            include / "verilated_timing.cpp",
        ]
        exe = obj / "axi_mem_mux_tb.exe"
        compiled = run([
            str(CXX), "-std=c++20", "-O0", "-DVL_TIME_CONTEXT",
            "-I", str(obj), "-I", str(include), "-I", str(include / "vltstd"),
            *[str(path) for path in cxx_sources], "-o", str(exe),
        ])
        (OUT / f"compile_{hart_num}_harts.log").write_text(compiled.stdout + compiled.stderr, encoding="utf-8")
        simulated = run([str(exe)])
        (OUT / f"simulation_{hart_num}_harts.log").write_text(simulated.stdout + simulated.stderr, encoding="utf-8")
        passed = f"PASS: AXI IDs, ATOP, W/R payloads, response routing, and inactive-hart mask; harts={hart_num}" in simulated.stdout
        results.append({"harts": hart_num, "passed": passed, "result": simulated.stdout.strip()})
        if passed:
            shutil.rmtree(obj)

    manifest = {
        "passed": all(row["passed"] for row in results),
        "dut": "m_vlsit_riscv_axi_mem_mux",
        "testbench": "tb_m_vlsit_riscv_axi_mem_mux",
        "simulator": str(VERILATOR),
        "results": results,
    }
    (OUT / "simulation_manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(manifest))
    return 0 if manifest["passed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
