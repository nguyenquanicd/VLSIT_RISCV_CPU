#!/bin/sh
# Relative logic-depth probe for one tensor-array PE (findings TC-T1 and TC-T2 of the 2026-11-17 tensor review).
# Synthesises each module with Yosys + ABC into 2-input gates and prints the longest topological path in
# gate levels (flip-flops cut the path). Unit-gate depth, not picoseconds: use it only to compare variants.
# Needs yosys (OSS CAD Suite). Override the location with OSS_CAD_POSIX.
HERE=$(cd "$(dirname "$0")" && pwd)
cd "$HERE" || exit 1
OSS_P=${OSS_CAD_POSIX:-/c/Tools/oss-cad-suite}
PATH="$OSS_P/bin:$OSS_P/lib:$PATH"; export PATH
WORK=${WORK:-$(mktemp -d)}
run() { # file module description
  yosys -p "read_verilog -sv $1; hierarchy -top $2; proc; flatten; opt; synth -top $2 -flatten; abc -g AND,NAND,OR,NOR,XOR,XNOR,ANDNOT,ORNOT,MUX; opt_clean; ltp -noff; stat" > "$WORK/$2.log" 2>&1
  depth=$(grep -i 'Longest topological path' "$WORK/$2.log" | tail -1 | sed 's/.*length=\([0-9]*\).*/\1/')
  cells=$(grep -E 'cells$' "$WORK/$2.log" | tail -1 | awk '{print $1}')
  printf '%-14s depth=%-4s cells=%-6s %s\n' "$2" "$depth" "$cells" "$3"
}
run pe_variants.sv pe_v1 "mul+acc32 in one stage (no MUL cut)"
run pe_variants.sv pe_v2 "product registered, 32-bit carry-propagate accumulate (MUL cut)"
run pe_variants.sv pe_v3 "product registered, carry-save accumulate (loop = 3:2 compressor)"
run pe_variants.sv pe_v4 "2:4 sparse paired lane, one stage"
run pe_variants.sv pe_v5 "2:4 sparse paired lane, gather cut + product-adder cut"
run pe_variants.sv fp32_add_loop "FP32 add in the accumulator loop, one stage (unoptimised RTL)"
run pe_parts.sv mul8 "INT8 multiplier alone"
run pe_parts.sv acc32 "32-bit accumulator loop alone (carry-propagate)"
run pe_parts.sv acc64 "64-bit accumulator loop alone (PARA_ACCUM_W=64)"
run pe_parts.sv csa32 "carry-save accumulator loop alone"
run pe_parts.sv gather "4:1 activation gather alone"
