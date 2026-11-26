#!/bin/sh
HERE=$(cd "$(dirname "$0")" && pwd)
R="$HERE/../../../../rtl/common/vlsit"
sh "$HERE/../run_tb.sh" "$HERE/tb.sv" "$R/coherence/m_vlsit_riscv_coh_txn_table.sv" "$R/coherence/m_vlsit_riscv_probe_scheduler.sv"
