#!/usr/bin/env python3
"""Run an integration-level classifier-to-AXI-route simulation."""

from __future__ import annotations

import json
import shutil
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'verification/common/reports/axi_region_route'
TB = ROOT / 'verification/common/axi_region_route/tb_m_vlsit_riscv_axi_route_region.sv'
ADDR_DECODER = ROOT / 'rtl/common/vlsit/address_map/m_vlsit_riscv_addr_decode.sv'
VERILATOR = Path("C:/Tools/oss-cad-suite/bin/verilator_bin.exe")
VERILATOR_ROOT = Path("C:/Tools/oss-cad-suite/share/verilator")
CXX = Path("C:/Users/PC/Tools/msys64/ucrt64/bin/g++.exe")


def run(command: list[str], timeout: int = 600) -> subprocess.CompletedProcess[str]:
    result = subprocess.run(command, cwd=ROOT, text=True, capture_output=True, timeout=timeout)
    if result.returncode != 0:
        raise RuntimeError(
            f"Command failed ({result.returncode}): {subprocess.list2cmdline(command)}\n"
            f"{result.stdout}\n{result.stderr}"
        )
    return result


def main() -> int:
    run([sys.executable, str(ROOT / 'scripts/lint_axi_region_route.py')])
    filelist = OUT / "filelist.f"
    obj = OUT / "region_route_obj"
    if obj.exists():
        shutil.rmtree(obj)
    obj.mkdir(parents=True)

    common = ["--timing", "-Wall", "-Wno-fatal", "--top-module", "tb_m_vlsit_riscv_axi_route_region"]
    linted = run([str(VERILATOR), "--lint-only", *common, "-f", str(filelist), str(ADDR_DECODER), str(TB)])
    (OUT / "region_route_tb_lint.log").write_text(linted.stdout + linted.stderr, encoding="utf-8")

    generated = run([
        str(VERILATOR), "--cc", "--main", *common,
        "--Mdir", str(obj), "-f", str(filelist), str(ADDR_DECODER), str(TB),
    ])
    (OUT / "region_route_verilator.log").write_text(generated.stdout + generated.stderr, encoding="utf-8")

    include = VERILATOR_ROOT / "include"
    cxx_sources = sorted(obj.glob("*.cpp")) + [
        include / "verilated.cpp",
        include / "verilated_threads.cpp",
        include / "verilated_timing.cpp",
    ]
    exe = obj / "axi_region_route_tb.exe"
    compiled = run([
        str(CXX), "-std=c++20", "-O0", "-DVL_TIME_CONTEXT",
        "-I", str(obj), "-I", str(include), "-I", str(include / "vltstd"),
        *[str(path) for path in cxx_sources], "-o", str(exe),
    ], timeout=900)
    (OUT / "region_route_compile.log").write_text(compiled.stdout + compiled.stderr, encoding="utf-8")

    simulated = run([str(exe)])
    (OUT / "region_route_simulation.log").write_text(simulated.stdout + simulated.stderr, encoding="utf-8")
    passed = "PASS: shared region classifier drives" in simulated.stdout
    result = {
        "passed": passed,
        "top": "tb_m_vlsit_riscv_axi_route_region",
        "dut": ["m_vlsit_riscv_addr_decode", "m_vlsit_riscv_axi_route"],
        "simulator": str(VERILATOR),
        "cases": [
            "AW cacheable routes to LLC memory path",
            "AW normal-uncached routes to memory with bypass class",
            "AW MMIO routes to external peripheral path",
            "AR cacheable, normal-uncached, and MMIO route selection",
        ],
        "result": simulated.stdout.strip(),
    }
    (OUT / "region_route_result.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    if passed:
        shutil.rmtree(obj)
    print(json.dumps(result))
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
