"""Lint CVA6 or its configured HPDcache subsystem with licensed integration copies."""

from pathlib import Path
import argparse
import json
import subprocess
import shutil


ROOT = Path(__file__).resolve().parents[1]
CVA6 = ROOT / "rtl/third_party/cva6"
HPDCACHE = ROOT / "rtl/third_party/hpdcache_cva6_pinned"
CVFPU = ROOT / "rtl/third_party/cvfpu"
FPU_DIV_SQRT_MVP = ROOT / "rtl/third_party/culsans_cva6_pinned/vendor/openhwgroup/cvfpu/src/fpu_div_sqrt_mvp"
OUT = ROOT / "rtl/reports/cva6_flush_path"
VERILATOR_FALLBACK = Path("C:/Tools/oss-cad-suite/bin/verilator_bin.exe")


def _posix(path: Path) -> str:
    return path.resolve().as_posix()


def _expand(text: str) -> str:
    return (text.replace("${CVA6_REPO_DIR}", _posix(CVA6))
                .replace("${HPDCACHE_DIR}", _posix(HPDCACHE)))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--top-module", default="cva6")
    parser.add_argument("--timeout-seconds", type=int, default=180)
    args = parser.parse_args()
    run_out = OUT if args.top_module == "cva6" else OUT / f"subtop_{args.top_module}"
    run_out.mkdir(parents=True, exist_ok=True)
    tool = shutil.which("verilator") or (str(VERILATOR_FALLBACK) if VERILATOR_FALLBACK.is_file() else None)
    if not tool:
        raise SystemExit("Verilator not found")

    hpdcache_flist = _expand((HPDCACHE / "rtl/hpdcache.Flist").read_text(encoding="utf-8"))
    hpdcache_flist = hpdcache_flist.replace(
        _posix(HPDCACHE / "rtl/src/hpdcache.sv"),
        _posix(ROOT / "rtl/modified/hpdcache/rtl/src/hpdcache.sv"),
    ).replace(
        _posix(HPDCACHE / "rtl/src/hpdcache_ctrl.sv"),
        _posix(ROOT / "rtl/modified/hpdcache/rtl/src/hpdcache_ctrl.sv"),
    ).replace(
        _posix(HPDCACHE / "rtl/src/hpdcache_ctrl_pe.sv"),
        _posix(ROOT / "rtl/modified/hpdcache/rtl/src/hpdcache_ctrl_pe.sv"),
    ).replace(
        _posix(HPDCACHE / "rtl/src/hpdcache_rtab.sv"),
        _posix(ROOT / "rtl/modified/hpdcache/rtl/src/hpdcache_rtab.sv"),
    ).replace(
        _posix(HPDCACHE / "rtl/src/hpdcache_flush.sv"),
        _posix(ROOT / "rtl/modified/hpdcache/rtl/src/hpdcache_flush.sv"),
    ).replace(
        _posix(HPDCACHE / "rtl/src/hpdcache_memctrl.sv"),
        _posix(ROOT / "rtl/modified/hpdcache/rtl/src/hpdcache_memctrl.sv"),
    ).replace(
        _posix(HPDCACHE / "rtl/src/hpdcache_miss_handler.sv"),
        _posix(ROOT / "rtl/modified/hpdcache/rtl/src/hpdcache_miss_handler.sv"),
    )
    hpdcache_flist_path = run_out / "hpdcache_modified.Flist"
    hpdcache_flist_path.write_text(hpdcache_flist, encoding="utf-8")

    cva6_flist = (CVA6 / "core/Flist.cva6").read_text(encoding="utf-8")
    replacements = {
        # CVFPU is checked out as a sibling source repository in this tree;
        # the CVA6 nested submodule directory is intentionally empty.
        "${CVA6_REPO_DIR}/core/cvfpu": _posix(CVFPU),
        "${CVA6_REPO_DIR}/core/cva6.sv": _posix(ROOT / "rtl/modified/cva6/core/cva6.sv"),
        "${CVA6_REPO_DIR}/core/csr_regfile.sv": _posix(ROOT / "rtl/modified/cva6/core/csr_regfile.sv"),
        "${CVA6_REPO_DIR}/core/perf_counters.sv": _posix(ROOT / "rtl/modified/cva6/core/perf_counters.sv"),
        "${CVA6_REPO_DIR}/core/include/build_config_pkg.sv": _posix(ROOT / "rtl/modified/cva6/core/include/build_config_pkg.sv"),
        "${CVA6_REPO_DIR}/core/include/cv64a6_imafdc_sv39_hpdcache_wb_config_pkg.sv": _posix(ROOT / "rtl/modified/cva6/core/include/cv64a6_imafdc_sv39_hpdcache_wb_config_pkg.sv"),
        "${CVA6_REPO_DIR}/core/include/${TARGET_CFG}_config_pkg.sv": _posix(ROOT / "rtl/modified/cva6/core/include/cv64a6_imafdc_sv39_hpdcache_wb_config_pkg.sv"),
        "${CVA6_REPO_DIR}/core/cache_subsystem/cva6_hpdcache_subsystem.sv": _posix(ROOT / "rtl/modified/cva6/core/cache_subsystem/cva6_hpdcache_subsystem.sv"),
        "${CVA6_REPO_DIR}/core/cache_subsystem/cva6_hpdcache_wrapper.sv": _posix(ROOT / "rtl/modified/cva6/core/cache_subsystem/cva6_hpdcache_wrapper.sv"),
        # `-F` resolves paths relative to the including file. The generated
        # list contains absolute paths, so include it with `-f` from the cwd.
        "-F ${HPDCACHE_DIR}/rtl/hpdcache.Flist": f"-f {_posix(hpdcache_flist_path)}",
    }
    for source, modified in replacements.items():
        cva6_flist = cva6_flist.replace(source, modified)
    cva6_flist = cva6_flist.replace(
        "${TARGET_CFG}_config_pkg.sv",
        "cv64a6_imafdc_sv39_hpdcache_wb_config_pkg.sv",
    )
    cva6_flist = _expand(cva6_flist)
    # This checkout's standalone CVFPU repository leaves the MVP div/sqrt
    # submodule empty. The pinned Culsans CVFPU vendor tree contains that
    # source at the revision used by the local integration baseline.
    cva6_flist = cva6_flist.replace(
        _posix(CVFPU / "src/fpu_div_sqrt_mvp"),
        _posix(FPU_DIV_SQRT_MVP),
    )
    if args.top_module == "hpdcache_mesi_lint":
        harness_path = run_out / "hpdcache_mesi_lint_top.sv"
        harness_path.write_text(
            """module m_vlsit_hpdcache_mesi_lint;
  localparam config_pkg::cva6_cfg_t LPARA_CVA6_CFG =
      build_config_pkg::build_config(cva6_config_pkg::cva6_cfg);
  cva6_hpdcache_subsystem #(
    .CVA6Cfg(LPARA_CVA6_CFG)
  ) u_vlsit_hpdcache_subsystem ();
endmodule
""",
            encoding="utf-8",
        )
        cva6_flist += "\n" + _posix(harness_path) + "\n"
        args.top_module = "m_vlsit_hpdcache_mesi_lint"
    cva6_flist_path = run_out / "cva6_modified_cache.Flist"
    cva6_flist_path.write_text(cva6_flist, encoding="utf-8")

    command = [tool, "--lint-only", "-Wall", "-Wno-fatal", "--top-module", args.top_module, "-f", str(cva6_flist_path)]
    try:
        run = subprocess.run(command, cwd=ROOT, capture_output=True, text=True,
                             timeout=args.timeout_seconds)
        return_code = run.returncode
        output = run.stdout + run.stderr
        timed_out = False
    except subprocess.TimeoutExpired as exc:
        return_code = -1
        output = (exc.stdout or "") + (exc.stderr or "") + f"\nTimed out after {args.timeout_seconds} seconds.\n"
        timed_out = True
    (run_out / "lint.log").write_text(subprocess.list2cmdline(command) + "\n" + output, encoding="utf-8")
    errors = sum(line.startswith("%Error") for line in output.splitlines())
    warnings = sum(line.startswith("%Warning") for line in output.splitlines())
    result = {"passed": return_code == 0 and errors == 0, "return_code": return_code,
              "errors": errors, "warnings": warnings, "top": args.top_module, "timed_out": timed_out,
              "uses_modified_hpd_top": True, "uses_modified_flush_engine": True,
              "uses_modified_hpdcache_memctrl": True,
              "uses_modified_hpdcache_miss_handler": True,
              "uses_modified_hpdcache_ctrl": True,
              "uses_modified_hpdcache_ctrl_pe": True,
              "uses_modified_hpdcache_rtab": True,
              "uses_modified_cva6_cache_wrapper": True}
    (run_out / "lint_result.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(result))
    return 0 if result["passed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
