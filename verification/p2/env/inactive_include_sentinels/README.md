# Inactive conditional include sentinels

This package does not define `UVM` or `PITON_ARIANE`. The retained sources reference `uvm_macros.svh` only inside `ifdef UVM`, and `l15.tmp.h` only inside `ifdef PITON_ARIANE`. The placeholder files satisfy package static include closure; neither header is consumed by the configured Verilator compile. Do not enable either macro without replacing the corresponding sentinel with its real dependency.
