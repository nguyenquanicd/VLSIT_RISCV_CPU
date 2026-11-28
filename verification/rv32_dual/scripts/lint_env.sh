#!/usr/bin/env bash
# AI-GENERATED (Claude Opus 5.5, 2026-11-28). Verilator lint-only of the verification sources against
# lint-only stubs generated from the REF-001 port tables (no build output is written; no RTL is read).
# Usage (from verification/rv32_dual): bash scripts/lint_env.sh [log]
# Part 1: simulation environment (tb_top + BFMs + monitors + SVA + checkers), -Wall, waivers in source.
# Part 2: formal harnesses, -Wall with three documented waivers: DECLFILENAME (several checker modules per
#         file), PROCASSINIT (past_valid formal idiom), UNUSEDSIGNAL (formal tops leave unobserved outputs).
set -u
export VERILATOR_ROOT="${VERILATOR_ROOT:-/c/Users/PC/Tools/oss-cad-suite/share/verilator}"
V="${VERILATOR_BIN:-/c/Users/PC/Tools/oss-cad-suite/bin/verilator_bin.exe}"
LOG="${1:-docs/02_env/lint_env.log}"
mkdir -p "$(dirname "$LOG")"
SIM=("$V" --lint-only --timing --timescale 1ns/1ps -Wall +define+RV32D_LINT_ONLY +incdir+tb +incdir+tb/generated
     --top-module tb_top tb/generated/m_vlsit_riscv_cluster_axi_top_stub.sv
     env/bfm/bfm_axi_sub.sv env/bfm/bfm_axil_mgr.sv env/bfm/drv_sideband.sv
     env/monitors/mon_axi.sv env/monitors/mon_axil.sv env/monitors/mon_sideband.sv
     env/assertions/sva_top_bind.sv env/scoreboards/chk_stale_resp.sv env/scoreboards/chk_watchdog.sv tb/tb_top.sv)
FV=(tb/generated/fv_component_stubs.sv env/assertions/fv_pmu_props.sv env/assertions/fv_axil_props.sv
    env/assertions/fv_addr_decode_props.sv env/assertions/fv_tops.sv)
rc=0
{
  echo "# $(date -Iseconds)"; "$V" --version
  echo "# part 1 command:"; printf '%q ' "${SIM[@]}"; echo
  "${SIM[@]}" 2>&1; r=$?; echo "# part 1 exit=$r"; [ $r -ne 0 ] && rc=1
  for top in fv_top_pmu fv_top_axil fv_top_addr_decode; do
    CMD=("$V" --lint-only -Wall -Wno-DECLFILENAME -Wno-PROCASSINIT -Wno-UNUSEDSIGNAL --top-module "$top" "${FV[@]}")
    echo "# part 2 command:"; printf '%q ' "${CMD[@]}"; echo
    "${CMD[@]}" 2>&1; r=$?; echo "# part 2 $top exit=$r"; [ $r -ne 0 ] && rc=1
  done
  echo "# overall exit=$rc"
} > "$LOG"
echo "warnings: $(grep -c '^%Warning' "$LOG")  errors: $(grep -c '^%Error' "$LOG")"
grep '# part\|# overall' "$LOG" | grep exit
