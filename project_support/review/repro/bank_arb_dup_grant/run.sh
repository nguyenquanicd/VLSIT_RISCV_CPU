#!/bin/sh
HERE=$(cd "$(dirname "$0")" && pwd)
R="$HERE/../../../../rtl/common/vlsit"
sh "$HERE/../run_tb.sh" "$HERE/tb.sv" "$R/coherence/m_vlsit_riscv_coh_bank_arb.sv"
