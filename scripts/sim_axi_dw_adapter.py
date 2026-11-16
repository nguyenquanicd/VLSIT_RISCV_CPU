#!/usr/bin/env python3
"""Lint and simulate the fixed-64-bit LLC memory-width adapter."""

from __future__ import annotations

import hashlib
import json
import shutil
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'verification/common/reports/axi_dw_adapter'
RTL = ROOT / 'rtl/non_coherence_cluster/m_vlsit_riscv_axi_dw_adapter.sv'
TB = ROOT / 'verification/common/axi_dw_adapter/tb_m_vlsit_riscv_axi_dw_adapter.sv'
VERILATOR = Path("C:/Tools/oss-cad-suite/bin/verilator_bin.exe")
VERILATOR_ROOT = Path("C:/Tools/oss-cad-suite/share/verilator")
CXX = Path("C:/Users/PC/Tools/msys64/ucrt64/bin/g++.exe")
COMMON_PIN = "db42769334b4589b4b3fc671b34513bdb98be565"
AXI_PIN = "d436bd4936ba1c49cd87521df54580c5159114d3"
SOURCES = [
    "rtl/common/third_party/common_cells/src/cc_pkg.sv",
    "rtl/common/third_party/common_cells/src/cc_lzc.sv",
    "rtl/common/third_party/common_cells/src/cc_onehot_to_bin.sv",
    "rtl/common/third_party/common_cells/src/cc_id_queue.sv",
    "rtl/common/third_party/common_cells/src/cc_rr_arb_tree.sv",
    "rtl/common/third_party/common_cells/src/cc_fifo.sv",
    "rtl/common/third_party/common_cells/src/cc_counter.sv",
    "rtl/common/third_party/common_cells/src/cc_delta_counter.sv",
    "rtl/common/third_party/common_cells/src/cc_spill_register.sv",
    "rtl/common/third_party/common_cells/src/cc_spill_register_flushable.sv",
    "rtl/common/third_party/common_cells/src/cc_stream_register.sv",
    "rtl/common/third_party/axi/src/axi_pkg.sv",
    "rtl/common/third_party/axi/src/axi_atop_filter.sv",
    "rtl/common/third_party/axi/src/axi_demux_id_counters.sv",
    "rtl/common/third_party/axi/src/axi_demux_simple.sv",
    "rtl/common/third_party/axi/src/axi_demux.sv",
    "rtl/common/third_party/axi/src/axi_err_slv.sv",
    "rtl/common/third_party/axi/src/axi_dw_upsizer.sv",
    "rtl/common/third_party/axi/src/axi_dw_downsizer.sv",
    "rtl/common/third_party/axi/src/axi_dw_converter.sv",
    "rtl/non_coherence_cluster/m_vlsit_riscv_axi_dw_adapter.sv",
]
WIDTHS = (32, 64, 128, 256)


def run(command: list[str], timeout: int = 900) -> subprocess.CompletedProcess[str]:
    result = subprocess.run(command, cwd=ROOT, text=True, capture_output=True, timeout=timeout)
    if result.returncode != 0:
        raise RuntimeError(
            f"Command failed ({result.returncode}): {subprocess.list2cmdline(command)}\n"
            f"{result.stdout}\n{result.stderr}"
        )
    return result


def main() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    common_rev = subprocess.check_output(
        ["git", "-C", str(ROOT / 'rtl/common/third_party/common_cells'), "rev-parse", "HEAD"], text=True
    ).strip()
    axi_rev = subprocess.check_output(
        ["git", "-C", str(ROOT / 'rtl/common/third_party/axi'), "rev-parse", "HEAD"], text=True
    ).strip()
    if common_rev != COMMON_PIN or axi_rev != AXI_PIN:
        raise SystemExit(f"Pinned source mismatch: common_cells={common_rev}; axi={axi_rev}")

    filelist = OUT / "filelist.f"
    filelist.write_text("\n".join([
        "+incdir+" + (ROOT / 'rtl/common/third_party/common_cells/include').as_posix(),
        "+incdir+" + (ROOT / 'rtl/common/third_party/axi/include').as_posix(),
        *[(ROOT / source).as_posix() for source in SOURCES],
    ]) + "\n", encoding="utf-8")
    (ROOT / 'rtl/common/filelists/legacy_vlsit/filelist_axi_dw_adapter.f').write_text(
        filelist.read_text(encoding="utf-8"), encoding="utf-8"
    )

    results = []
    for width in WIDTHS:
        profile = OUT / f"{width}_bit"
        profile.mkdir(parents=True, exist_ok=True)
        common = ["-Wall", "-Wno-fatal", "--top-module"]
        lint = run([
            str(VERILATOR), "--lint-only", *common, "m_vlsit_riscv_axi_dw_adapter",
            f"-GPARA_AXI_MEM_DATA_W={width}", "-f", str(filelist),
        ])
        (profile / "rtl_lint.log").write_text(lint.stdout + lint.stderr, encoding="utf-8")
        rtl_errors = sum(line.startswith("%Error") for line in (lint.stdout + lint.stderr).splitlines())

        tb_common = [
            "--timing", "-Wall", "-Wno-fatal", "--top-module",
            "tb_m_vlsit_riscv_axi_dw_adapter", f"-GPARA_AXI_MEM_DATA_W={width}",
        ]
        tb_lint = run([str(VERILATOR), "--lint-only", *tb_common, "-f", str(filelist), str(TB)])
        (profile / "tb_lint.log").write_text(tb_lint.stdout + tb_lint.stderr, encoding="utf-8")
        mdir = profile / "obj_dir"
        if mdir.exists():
            resolved = mdir.resolve()
            if resolved.parent != profile.resolve() or resolved.name != "obj_dir":
                raise SystemExit(f"Refusing to clean unexpected build path: {resolved}")
            shutil.rmtree(resolved)
        mdir.mkdir()
        generated = run([
            str(VERILATOR), "--cc", "--main", *tb_common, "--Mdir", str(mdir),
            "-f", str(filelist), str(TB),
        ])
        (profile / "verilator_build.log").write_text(generated.stdout + generated.stderr, encoding="utf-8")

        include = VERILATOR_ROOT / "include"
        cxx_sources = sorted(mdir.glob("*.cpp")) + [
            include / "verilated.cpp", include / "verilated_threads.cpp", include / "verilated_timing.cpp",
        ]
        exe = mdir / "axi_dw_adapter_tb.exe"
        compiled = run([
            str(CXX), "-std=c++20", "-O0", "-DVL_TIME_CONTEXT", "-I", str(mdir),
            "-I", str(include), "-I", str(include / "vltstd"),
            *[str(path) for path in cxx_sources], "-o", str(exe),
        ])
        (profile / "compile.log").write_text(compiled.stdout + compiled.stderr, encoding="utf-8")
        simulated = run([str(exe)])
        (profile / "simulation.log").write_text(simulated.stdout + simulated.stderr, encoding="utf-8")
        expected = f"PASS: AXI width conversion, channel payloads, and supported response checks; data_width={width}"
        simulation_pass = expected in simulated.stdout
        results.append({
            "width": width,
            "rtl_lint_errors": rtl_errors,
            "rtl_lint_pass": rtl_errors == 0,
            "simulation_pass": simulation_pass,
            "simulation_result": simulated.stdout.strip(),
            "rtl_lint_log": (profile / "rtl_lint.log").relative_to(ROOT).as_posix(),
            "simulation_log": (profile / "simulation.log").relative_to(ROOT).as_posix(),
        })
        shutil.rmtree(mdir)
        print(f"{width}-bit memory bus: {'PASS' if simulation_pass and rtl_errors == 0 else 'FAIL'}")

    manifest = {
        "passed": all(row["rtl_lint_pass"] and row["simulation_pass"] for row in results),
        "dut": "m_vlsit_riscv_axi_dw_adapter",
        "testbench": "tb_m_vlsit_riscv_axi_dw_adapter",
        "common_cells_revision": common_rev,
        "axi_revision": axi_rev,
        "rtl_sha256": hashlib.sha256(RTL.read_bytes()).hexdigest(),
        "testbench_sha256": hashlib.sha256(TB.read_bytes()).hexdigest(),
        "results": results,
    }
    (OUT / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(manifest, indent=2))
    return 0 if manifest["passed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
