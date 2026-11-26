#!/usr/bin/env python3
"""Lint and simulate the parameterized cluster address-region table."""

from __future__ import annotations

import json
import shutil
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
RTL = ROOT / "rtl/vlsit/m_vlsit_riscv_addr_decode.sv"
TB = ROOT / "rtl/verification/addr_region_table/tb_m_vlsit_riscv_addr_decode.sv"
OUT = ROOT / "rtl/reports/addr_region_table"
VERILATOR = Path("C:/Tools/oss-cad-suite/bin/verilator_bin.exe")
VERILATOR_ROOT = Path("C:/Tools/oss-cad-suite/share/verilator")
CXX = Path("C:/Users/PC/Tools/msys64/ucrt64/bin/g++.exe")


def run(command: list[str], timeout: int = 120) -> subprocess.CompletedProcess[str]:
    result = subprocess.run(command, cwd=ROOT, text=True, capture_output=True, timeout=timeout)
    if result.returncode != 0:
        raise RuntimeError(
            f"Command failed ({result.returncode}): {subprocess.list2cmdline(command)}\n"
            f"{result.stdout}\n{result.stderr}"
        )
    return result


def main() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    obj = OUT / "obj_dir"
    if obj.exists():
        shutil.rmtree(obj)
    obj.mkdir()

    args = ["--timing", "-Wall", "-Wno-fatal", "--top-module", "tb_m_vlsit_riscv_addr_decode"]
    linted = run([str(VERILATOR), "--lint-only", *args, str(RTL), str(TB)])
    (OUT / "lint.log").write_text(linted.stdout + linted.stderr, encoding="utf-8")

    generated = run([
        str(VERILATOR), "--cc", "--main", *args,
        "--Mdir", str(obj), str(RTL), str(TB),
    ])
    (OUT / "verilator.log").write_text(generated.stdout + generated.stderr, encoding="utf-8")

    include = VERILATOR_ROOT / "include"
    cxx_sources = sorted(obj.glob("*.cpp")) + [
        include / "verilated.cpp",
        include / "verilated_threads.cpp",
        include / "verilated_timing.cpp",
    ]
    exe = obj / "addr_region_table_tb.exe"
    compiled = run([
        str(CXX), "-std=c++20", "-O0", "-DVL_TIME_CONTEXT",
        "-I", str(obj), "-I", str(include), "-I", str(include / "vltstd"),
        *[str(path) for path in cxx_sources], "-o", str(exe),
    ], timeout=300)
    (OUT / "compile.log").write_text(compiled.stdout + compiled.stderr, encoding="utf-8")

    simulated = run([str(exe)])
    (OUT / "simulation.log").write_text(simulated.stdout + simulated.stderr, encoding="utf-8")
    passed = "PASS: region table classes" in simulated.stdout
    result = {
        "passed": passed,
        "top": "tb_m_vlsit_riscv_addr_decode",
        "dut": "m_vlsit_riscv_addr_decode",
        "simulator": str(VERILATOR),
        "checks": [
            "cacheable range base and final aligned beat",
            "access crossing a region boundary",
            "normal uncached region classification",
            "MMIO classification and atomic rejection",
            "unmapped address and zero-byte access",
            "overlapping static-region table rejection",
        ],
        "result": simulated.stdout.strip(),
    }
    (OUT / "result.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    if passed:
        shutil.rmtree(obj)
    print(json.dumps(result))
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
