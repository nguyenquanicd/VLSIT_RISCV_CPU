#!/usr/bin/env python3
"""Lint the four-hart AXI4+ATOP memory mux for dual and quad profiles."""

from __future__ import annotations

import hashlib
import json
import shutil
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'lint/common/axi_mem_mux'
COMMON_PIN = "db42769334b4589b4b3fc671b34513bdb98be565"
AXI_PIN = "d436bd4936ba1c49cd87521df54580c5159114d3"
SOURCES = [
    "rtl/common/third_party/common_cells/src/cc_pkg.sv",
    "rtl/common/third_party/common_cells/src/cc_lzc.sv",
    "rtl/common/third_party/common_cells/src/cc_rr_arb_tree.sv",
    "rtl/common/third_party/common_cells/src/cc_fifo.sv",
    "rtl/common/third_party/common_cells/src/cc_spill_register_flushable.sv",
    "rtl/common/third_party/common_cells/src/cc_spill_register.sv",
    "rtl/common/third_party/common_cells/src/cc_stream_register.sv",
    "rtl/common/third_party/axi/src/axi_id_prepend.sv",
    "rtl/common/third_party/axi/src/axi_mux.sv",
    "rtl/common/vlsit/interconnect/m_vlsit_riscv_axi_mem_mux.sv",
]
VERILATOR = Path("C:/Tools/oss-cad-suite/bin/verilator_bin.exe")


def git_revision(path: str) -> str:
    return subprocess.check_output(["git", "-C", str(ROOT / path), "rev-parse", "HEAD"], text=True).strip()


def main() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    common_rev = git_revision("rtl/common/third_party/common_cells")
    axi_rev = git_revision("rtl/common/third_party/axi")
    if common_rev != COMMON_PIN or axi_rev != AXI_PIN:
        raise SystemExit(f"Pinned source mismatch: common_cells={common_rev}; axi={axi_rev}")
    missing = [source for source in SOURCES if not (ROOT / source).is_file()]
    if missing:
        raise SystemExit("Missing source(s): " + ", ".join(missing))

    filelist = OUT / "filelist.f"
    filelist.write_text("\n".join([
        "+incdir+" + (ROOT / 'rtl/common/third_party/common_cells/include').as_posix(),
        "+incdir+" + (ROOT / 'rtl/common/third_party/axi/include').as_posix(),
        *[(ROOT / source).as_posix() for source in SOURCES],
    ]) + "\n", encoding="utf-8")
    (ROOT / 'rtl/common/filelists/legacy_vlsit/filelist_axi_mem_mux.f').write_text(filelist.read_text(encoding="utf-8"), encoding="utf-8")

    results = []
    for cpu_num in (2, 4):
        command = [
            str(VERILATOR), "--lint-only", "-Wall", "-Wno-fatal", "--top-module",
            "m_vlsit_riscv_axi_mem_mux", f"-GPARA_CPU_NUM={cpu_num}", "-f", str(filelist),
        ]
        proc = subprocess.run(command, cwd=ROOT, text=True, capture_output=True)
        output = proc.stdout + proc.stderr
        log = OUT / f"lint_{cpu_num}_harts.log"
        log.write_text(subprocess.list2cmdline(command) + "\n" + output, encoding="utf-8")
        errors = sum(line.startswith("%Error") for line in output.splitlines())
        warnings = sum(line.startswith("%Warning") for line in output.splitlines())
        passed = proc.returncode == 0 and errors == 0 and "%Warning-LATCH" not in output
        results.append({"harts": cpu_num, "passed": passed, "errors": errors,
                        "warnings": warnings, "log": log.relative_to(ROOT).as_posix()})
        print(f"{cpu_num} harts: {'PASS' if passed else 'FAIL'}; {errors} errors, {warnings} warnings")

    manifest = {
        "common_cells_revision": common_rev,
        "axi_revision": axi_rev,
        "results": results,
        "source_sha256": {source: hashlib.sha256((ROOT / source).read_bytes()).hexdigest() for source in SOURCES},
    }
    (OUT / "lint_manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    return 0 if all(row["passed"] for row in results) else 1


if __name__ == "__main__":
    raise SystemExit(main())
