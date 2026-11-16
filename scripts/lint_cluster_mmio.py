"""Lint the AXI MMIO wrapper against its real, pinned upstream dependencies."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[1]
PIN = "db42769334b4589b4b3fc671b34513bdb98be565"
SOURCES = [
    "rtl/common/third_party/common_cells/src/cc_pkg.sv",
    "rtl/common/third_party/common_cells/src/cc_lzc.sv",
    "rtl/common/third_party/common_cells/src/cc_rr_arb_tree.sv",
    "rtl/common/third_party/common_cells/src/cc_fifo.sv",
    "rtl/common/third_party/common_cells/src/cc_spill_register_flushable.sv",
    "rtl/common/third_party/common_cells/src/cc_spill_register.sv",
    "rtl/common/third_party/axi/src/axi_id_prepend.sv",
    "rtl/common/third_party/axi/src/axi_mux.sv",
    "rtl/common/vlsit/interconnect/m_vlsit_riscv_axi_mmio.sv",
]


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
    actual = subprocess.check_output(
        ["git", "-C", str(ROOT / 'rtl/common/third_party/common_cells'), "rev-parse", "HEAD"],
        text=True,
    ).strip()
    if actual != PIN:
        parser.error("Common Cells revision differs from AXI Bender.lock: " + actual)
    for source in SOURCES:
        if not (ROOT / source).is_file():
            parser.error("Missing dependency: " + source)
    out = ROOT / 'lint/common/mmio'
    out.mkdir(parents=True, exist_ok=True)
    # Include directories and package-first order are required by the upstream libraries.
    filelist = out / "filelist.f"
    filelist.write_text("\n".join([
        "+incdir+" + (ROOT / 'rtl/common/third_party/common_cells/include').as_posix(),
        "+incdir+" + (ROOT / 'rtl/common/third_party/axi/include').as_posix(),
    ] + [(ROOT / source).as_posix() for source in SOURCES]) + "\n", encoding="utf-8")
    (ROOT / 'rtl/common/filelists/legacy_vlsit/filelist_axi_mmio.f').write_text(
        filelist.read_text(encoding="utf-8"), encoding="utf-8")
    results = []
    for harts in (2, 4):
        command = [tool, "--lint-only", "-Wall", "-Wno-fatal", "--top-module",
                   "m_vlsit_riscv_axi_mmio", "-GPARA_CPU_NUM=" + str(harts),
                   "-f", str(filelist)]
        run = subprocess.run(command, cwd=ROOT, capture_output=True, text=True)
        output = run.stdout + run.stderr
        log = out / ("lint_" + str(harts) + "_harts.log")
        log.write_text(subprocess.list2cmdline(command) + "\n" + output,
                       encoding="utf-8")
        errors = sum(line.startswith("%Error") for line in output.splitlines())
        warnings = sum(line.startswith("%Warning") for line in output.splitlines())
        # A latch finding fails the run even when the tool classifies it as a warning.
        passed = run.returncode == 0 and errors == 0 and "%Warning-LATCH" not in output
        results.append(dict(harts=harts, passed=passed, errors=errors,
                            warnings=warnings, log=log.relative_to(ROOT).as_posix()))
        print(f"{harts} harts: {'PASS' if passed else 'FAIL'}; {errors} errors, {warnings} warnings")
    manifest = dict(common_cells_revision=actual, results=results, sources={
        source: hashlib.sha256((ROOT / source).read_bytes()).hexdigest()
        for source in SOURCES
    })
    (out / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    return 0 if all(result["passed"] for result in results) else 1


if __name__ == "__main__":
    raise SystemExit(main())
