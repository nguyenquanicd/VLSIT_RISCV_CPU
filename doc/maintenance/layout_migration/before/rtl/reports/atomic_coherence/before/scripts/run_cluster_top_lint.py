#!/usr/bin/env python3
"""Run Verilator lint on the integrated AXI cluster top with reliable exit capture."""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
import time
from datetime import datetime
from pathlib import Path
from lint_source_overrides import apply_overrides


PROJECT_ROOT = Path(__file__).resolve().parents[1]
REPORT_DIR = PROJECT_ROOT / "rtl" / "reports" / "full_integration"
TOP = "m_vlsit_riscv_cluster_axi_top"
INCLUDE_DIRS = [
    PROJECT_ROOT / "rtl" / "third_party" / "axi_llc_locked" / "common_cells" / "include",
    PROJECT_ROOT / "rtl" / "third_party" / "axi_llc_locked" / "axi" / "include",
    PROJECT_ROOT / "rtl" / "third_party" / "apb" / "include",
    PROJECT_ROOT / "rtl" / "third_party" / "register_interface" / "include",
    PROJECT_ROOT / "rtl" / "third_party" / "tech_cells_generic" / "include",
    PROJECT_ROOT / "rtl" / "third_party" / "axi_llc" / "include",
]


def make_arguments(verilator: str, hart_count: int) -> list[str]:
    apply_overrides()
    args = [
        verilator,
        "--lint-only",
        "--timing",
        "--timescale",
        "1ns/1ps",
        "-Wno-fatal",
        "-Wno-TIMESCALEMOD",
        "--top-module",
        TOP,
        f"-GPARA_CPU_NUM={hart_count}",
    ]
    args.extend(f"+incdir+{path.as_posix()}" for path in INCLUDE_DIRS)
    args.extend(
        [
            "-f",
            "../cva6_flush_path/cva6_modified_cache.Flist",
            "-f",
            "filelist_llc_unique.f",
            "-f",
            "filelist_vlsit_cluster.f",
        ]
    )
    return args


def run_one(verilator: str, hart_count: int, timeout_seconds: int) -> int:
    REPORT_DIR.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    log_path = REPORT_DIR / f"top_lint_{hart_count}h_{stamp}.log"
    args = make_arguments(verilator, hart_count)
    started = time.monotonic()

    print(f"Starting {hart_count}-hart TOP lint; log: {log_path}", flush=True)
    with log_path.open("w", encoding="utf-8", newline="\n") as log_file:
        try:
            process = subprocess.Popen(
                args,
                cwd=REPORT_DIR,
                stdout=log_file,
                stderr=subprocess.STDOUT,
                text=True,
            )
        except OSError as exc:
            print(f"ERROR: could not start Verilator: {exc}", file=sys.stderr)
            return 127

        print(f"Verilator PID: {process.pid}", flush=True)
        while process.poll() is None:
            if time.monotonic() - started >= timeout_seconds:
                process.terminate()
                try:
                    process.wait(timeout=10)
                except subprocess.TimeoutExpired:
                    process.kill()
                    process.wait()
                print(f"Verilator timed out after {timeout_seconds}s", flush=True)
                break
            time.sleep(10)
            elapsed = int(time.monotonic() - started)
            print(f"{hart_count}-hart lint still running ({elapsed}s)", flush=True)
        exit_code = process.returncode

    text = log_path.read_text(encoding="utf-8", errors="replace")
    error_count = len(re.findall(r"%Error", text))
    warning_count = len(re.findall(r"%Warning", text))
    latch_count = len(re.findall(r"%Warning-LATCH\b", text))
    multiple_driver_count = len(re.findall(r"%Warning-MULTIDRIVEN\b", text))
    elapsed = time.monotonic() - started
    print(f"Hart count: {hart_count}")
    print(f"Native Verilator exit code: {exit_code}")
    print(f"Error diagnostics: {error_count}")
    print(f"Warning diagnostics: {warning_count}")
    print(f"Latch diagnostics: {latch_count}")
    print(f"Multiple-driver diagnostics: {multiple_driver_count}")
    print(f"Elapsed: {elapsed:.1f}s")
    print(f"Log: {log_path}")
    # A completed invocation is not a clean lint result while diagnostics remain.
    if exit_code == 0 and error_count == 0 and warning_count == 0 and latch_count == 0 and multiple_driver_count == 0:
        return 0
    return exit_code if exit_code else 1


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--hart-count", type=int, choices=(2, 4), default=4)
    parser.add_argument(
        "--verilator",
        default=r"C:\Users\PC\Tools\oss-cad-suite\bin\verilator_bin.exe",
    )
    parser.add_argument("--timeout", type=int, default=420,
                        help="maximum runtime in seconds (default: 420)")
    args = parser.parse_args()
    return run_one(args.verilator, args.hart_count, args.timeout)


if __name__ == "__main__":
    raise SystemExit(main())
