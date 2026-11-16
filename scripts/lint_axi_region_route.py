"""Lint the shared-table AXI address router against pinned PULP AXI sources."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[1]
COMMON_CELLS_PIN = "db42769334b4589b4b3fc671b34513bdb98be565"
AXI_PIN = "d436bd4936ba1c49cd87521df54580c5159114d3"
SOURCES = [
    "rtl/common/third_party/common_cells/src/cc_pkg.sv",
    "rtl/common/third_party/axi/src/axi_pkg.sv",
    "rtl/common/third_party/common_cells/src/cc_lzc.sv",
    "rtl/common/third_party/common_cells/src/cc_delta_counter.sv",
    "rtl/common/third_party/common_cells/src/cc_counter.sv",
    "rtl/common/third_party/common_cells/src/cc_fifo.sv",
    "rtl/common/third_party/common_cells/src/cc_rr_arb_tree.sv",
    "rtl/common/third_party/common_cells/src/cc_spill_register.sv",
    "rtl/common/third_party/common_cells/src/cc_spill_register_flushable.sv",
    "rtl/common/third_party/common_cells/src/cc_stream_register.sv",
    "rtl/common/third_party/axi/src/axi_demux_id_counters.sv",
    "rtl/common/third_party/axi/src/axi_demux_simple.sv",
    "rtl/common/third_party/axi/src/axi_demux.sv",
    "rtl/common/third_party/axi/src/axi_atop_filter.sv",
    "rtl/common/third_party/axi/src/axi_err_slv.sv",
    "rtl/common/vlsit/interconnect/m_vlsit_riscv_axi_route.sv",
]


def git_revision(path):
    return subprocess.check_output(
        ["git", "-C", str(ROOT / path), "rev-parse", "HEAD"], text=True
    ).strip()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--verilator", default=None)
    args = parser.parse_args()
    tool = args.verilator or shutil.which("verilator") or shutil.which("verilator_bin.exe")
    fallback = Path("C:/Tools/oss-cad-suite/bin/verilator_bin.exe")
    if not tool and fallback.is_file():
        tool = str(fallback)
    if not tool:
        parser.error("Verilator is required; pass --verilator with its executable path")

    common_revision = git_revision("rtl/common/third_party/common_cells")
    axi_revision = git_revision("rtl/common/third_party/axi")
    if common_revision != COMMON_CELLS_PIN:
        parser.error("Common Cells revision differs from the pinned dependency: " + common_revision)
    if axi_revision != AXI_PIN:
        parser.error("PULP AXI revision differs from the pinned dependency: " + axi_revision)
    for source in SOURCES:
        if not (ROOT / source).is_file():
            parser.error("Missing dependency: " + source)

    out = ROOT / 'lint/common/axi_region_route'
    out.mkdir(parents=True, exist_ok=True)
    filelist = out / "filelist.f"
    filelist.write_text("\n".join([
        "+incdir+" + (ROOT / 'rtl/common/third_party/common_cells/include').as_posix(),
        "+incdir+" + (ROOT / 'rtl/common/third_party/axi/include').as_posix(),
    ] + [(ROOT / source).as_posix() for source in SOURCES]) + "\n", encoding="utf-8")
    (ROOT / 'rtl/common/filelists/legacy_vlsit/filelist_axi_route.f').write_text(
        filelist.read_text(encoding="utf-8"), encoding="utf-8"
    )

    results = []
    for capacity in (1, 8, 32):
        command = [
            tool, "--lint-only", "-Wall", "-Wno-fatal", "--top-module",
            "m_vlsit_riscv_axi_route", "-GPARA_AXI_MAX_TRANS=" + str(capacity),
            "-f", str(filelist),
        ]
        run = subprocess.run(command, cwd=ROOT, capture_output=True, text=True)
        output = run.stdout + run.stderr
        log = out / ("lint_max_trans_" + str(capacity) + ".log")
        log.write_text(subprocess.list2cmdline(command) + "\n" + output, encoding="utf-8")
        errors = sum(line.startswith("%Error") for line in output.splitlines())
        warnings = sum(line.startswith("%Warning") for line in output.splitlines())
        passed = run.returncode == 0 and errors == 0 and "%Warning-LATCH" not in output
        results.append({
            "max_transactions": capacity,
            "passed": passed,
            "errors": errors,
            "warnings": warnings,
            "log": log.relative_to(ROOT).as_posix(),
        })
        print(f"MaxTrans={capacity}: {'PASS' if passed else 'FAIL'}; "
              f"{errors} errors, {warnings} warnings")

    manifest = {
        "common_cells_revision": common_revision,
        "axi_revision": axi_revision,
        "verilator": subprocess.check_output([tool, "--version"], text=True).strip(),
        "results": results,
        "source_sha256": {
            source: hashlib.sha256((ROOT / source).read_bytes()).hexdigest()
            for source in SOURCES
        },
    }
    (out / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    return 0 if all(result["passed"] for result in results) else 1


if __name__ == "__main__":
    raise SystemExit(main())
