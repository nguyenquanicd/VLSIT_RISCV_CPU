#!/bin/sh
HERE=$(cd "$(dirname "$0")" && pwd)
R="$HERE/../../../../rtl/common/vlsit"
sh "$HERE/../run_tb.sh" "$HERE/tb.sv" "$R/control/m_vlsit_axil_reg_bridge.sv"
