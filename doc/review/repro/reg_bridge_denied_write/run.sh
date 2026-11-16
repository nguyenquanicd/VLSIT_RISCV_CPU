#!/bin/sh
HERE=$(cd "$(dirname "$0")" && pwd)
R="$HERE/../../../../rtl/vlsit"
sh "$HERE/../run_tb.sh" "$HERE/tb.sv" "$R/m_vlsit_axil_reg_bridge.sv"
