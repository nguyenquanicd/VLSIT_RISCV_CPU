#!/bin/sh
# Generic Verilator runner for the review reproductions.
# Usage: sh run_tb.sh <testbench.sv> <rtl.sv> [<rtl.sv> ...]
# Needs Verilator (OSS CAD Suite) and MinGW g++. Override with OSS_CAD_POSIX, MSYS_UCRT_POSIX and
# VERILATOR_ROOT_WIN (same setup as APB-DEC-Generator/tests/run_cov.sh). Work files go to $WORK.
TB=${1:?testbench}; shift
RTL="$*"
OSS_P=${OSS_CAD_POSIX:-/c/Tools/oss-cad-suite}
GCC_P=${MSYS_UCRT_POSIX:-/c/Users/PC/Tools/msys64/ucrt64}
PATH="$GCC_P/bin:$OSS_P/bin:$PATH"; export PATH
VERILATOR_ROOT=${VERILATOR_ROOT_WIN:-'C:\Tools\oss-cad-suite\share\verilator'}; export VERILATOR_ROOT
INC=$OSS_P/share/verilator/include
WORK=${WORK:-$(mktemp -d)}
mkdir -p "$WORK"
cat > "$WORK/main.cpp" <<'CPP'
#include <cstdio>
#include <memory>
#include "verilated.h"
#include "Vcov.h"
double sc_time_stamp() { return 0.0; }
int main(int argc, char** argv) {
  setvbuf(stdout, NULL, _IONBF, 0);
  const std::unique_ptr<VerilatedContext> ctx{new VerilatedContext};
  ctx->commandArgs(argc, argv);
  const std::unique_ptr<Vcov> top{new Vcov{ctx.get(), "TOP"}};
  while (!ctx->gotFinish()) {
    top->eval();
    if (!top->eventsPending()) break;
    ctx->time(top->nextTimeSlot());
  }
  top->final();
  return 0;
}
CPP
verilator_bin.exe --cc --exe --timing --Mdir "$WORK/obj" -Wno-fatal -Wno-lint -Wno-style \
  --top-module tb "$TB" $RTL --prefix Vcov > "$WORK/verilator.log" 2>&1 || { tail -20 "$WORK/verilator.log"; exit 1; }
cd "$WORK/obj" || exit 1
CXXFLAGS="-O1 -w -I. -I$INC -I$INC/vltstd -DVERILATOR=1 -DVM_COVERAGE=0 -DVM_SC=0 -DVM_TIMING=1 -DVM_TRACE=0 -DVM_TRACE_FST=0 -DVM_TRACE_VCD=0 -DVM_TRACE_SAIF=0 -DVM_VPI=0 -faligned-new -fcf-protection=none -std=gnu++20"
for f in Vcov*.cpp "$WORK/main.cpp" "$INC/verilated.cpp" "$INC/verilated_threads.cpp" "$INC/verilated_timing.cpp"; do echo "$f"; done > srcs.txt
xargs -P 6 -I SRC sh -c "g++ $CXXFLAGS -c SRC -o \$(basename SRC .cpp).o" < srcs.txt || exit 1
g++ -Wl,--stack,536870912 -o Vcov_bin.exe ./*.o || exit 1
./Vcov_bin.exe
