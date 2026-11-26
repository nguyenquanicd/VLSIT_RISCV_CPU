# RTL rule check

Files: m_vlsit_riscv_cache_line_locks.sv, m_vlsit_riscv_coh_fabric.sv, m_vlsit_riscv_coh_tile_array.sv, m_vlsit_riscv_sharer_directory.sv, m_vlsit_riscv_tile_coh_adapter.sv, m_vlsit_riscv_cpu_tile_array.sv, m_vlsit_riscv_axi_route.sv, m_vlsit_riscv_cmo_controller.sv, m_vlsit_riscv_pmu.sv, m_vlsit_riscv_cluster_axi_top.sv, m_vlsit_riscv_cluster_core.sv

| Level | Rule | File:line | Finding |
|---|---|---|---|
| ERROR | COM-09 | m_vlsit_riscv_cluster_core.sv:1065 | logical '&&' in a value expression: use the bitwise '&'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_cluster_core.sv:1066 | logical '&&' in a value expression: use the bitwise '&'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_coh_fabric.sv:162 | logical '&&' in a value expression: use the bitwise '&'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_coh_fabric.sv:163 | logical '&&' in a value expression: use the bitwise '&'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_coh_fabric.sv:163 | logical '!' in a value expression: use the bitwise '~'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_coh_fabric.sv:163 | logical '&&' in a value expression: use the bitwise '&'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_coh_fabric.sv:163 | logical '!' in a value expression: use the bitwise '~'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_coh_fabric.sv:164 | logical '&&' in a value expression: use the bitwise '&'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_coh_fabric.sv:165 | logical '&&' in a value expression: use the bitwise '&'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_coh_fabric.sv:167 | logical '&&' in a value expression: use the bitwise '&'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_coh_fabric.sv:167 | logical '!' in a value expression: use the bitwise '~'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_coh_fabric.sv:168 | logical '&&' in a value expression: use the bitwise '&'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_coh_fabric.sv:168 | logical '!' in a value expression: use the bitwise '~'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_coh_fabric.sv:168 | logical '&&' in a value expression: use the bitwise '&'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_coh_fabric.sv:169 | logical '&&' in a value expression: use the bitwise '&'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_coh_fabric.sv:170 | logical '&&' in a value expression: use the bitwise '&'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_coh_fabric.sv:172 | logical '&&' in a value expression: use the bitwise '&'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_coh_fabric.sv:178 | logical '&&' in a value expression: use the bitwise '&'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_coh_fabric.sv:180 | logical '&&' in a value expression: use the bitwise '&'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_coh_fabric.sv:182 | logical '&&' in a value expression: use the bitwise '&'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_coh_fabric.sv:184 | logical '&&' in a value expression: use the bitwise '&'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-11 | m_vlsit_riscv_sharer_directory.sv:295 | selection nesting depth 5: keep case / if nesting at four levels or less and restructure with a case, a helper function or a submodule (COM-11, P33) |
| ERROR | NAM-07 | m_vlsit_riscv_axi_route.sv:26 | localparam 'LPARA_TIMING_PROFILE_LOW_LATENCY' is 32 characters; the limit is 30 |
| ERROR | NAM-07 | m_vlsit_riscv_axi_route.sv:27 | localparam 'LPARA_TIMING_PROFILE_CLUSTER_TIMING' is 35 characters; the limit is 30 |
| ERROR | NAM-07 | m_vlsit_riscv_cluster_axi_top.sv:91 | localparam 'LPARA_TIMING_PROFILE_LOW_LATENCY' is 32 characters; the limit is 30 |
| ERROR | NAM-07 | m_vlsit_riscv_cluster_axi_top.sv:92 | localparam 'LPARA_TIMING_PROFILE_CLUSTER_TIMING' is 35 characters; the limit is 30 |
| ERROR | NAM-07 | m_vlsit_riscv_cluster_core.sv:90 | localparam 'LPARA_TIMING_PROFILE_LOW_LATENCY' is 32 characters; the limit is 30 |
| ERROR | NAM-07 | m_vlsit_riscv_cluster_core.sv:91 | localparam 'LPARA_TIMING_PROFILE_CLUSTER_TIMING' is 35 characters; the limit is 30 |
| ERROR | NAM-07 | m_vlsit_riscv_pmu.sv:31 | localparam 'LPARA_TIMING_PROFILE_LOW_LATENCY' is 32 characters; the limit is 30 |
| ERROR | NAM-07 | m_vlsit_riscv_pmu.sv:32 | localparam 'LPARA_TIMING_PROFILE_CLUSTER_TIMING' is 35 characters; the limit is 30 |
| ERROR | NAM-09 | m_vlsit_riscv_axi_route.sv:459 | instance 'u_mem_axi_cut' of cell 'axi_cut' must be named u_dont_touch_<function> |
| ERROR | NAM-09 | m_vlsit_riscv_axi_route.sv:477 | instance 'u_mmio_axi_cut' of cell 'axi_cut' must be named u_dont_touch_<function> |
| ERROR | R-072 | m_vlsit_riscv_axi_route.sv:26 | 'LPARA_TIMING_PROFILE_LOW_LATENCY' is declared but nothing uses it: remove the declaration (R-072) |
| ERROR | R-072 | m_vlsit_riscv_cluster_axi_top.sv:91 | 'LPARA_TIMING_PROFILE_LOW_LATENCY' is declared but nothing uses it: remove the declaration (R-072) |
| ERROR | R-072 | m_vlsit_riscv_cluster_axi_top.sv:92 | 'LPARA_TIMING_PROFILE_CLUSTER_TIMING' is declared but nothing uses it: remove the declaration (R-072) |
| ERROR | R-072 | m_vlsit_riscv_cluster_core.sv:90 | 'LPARA_TIMING_PROFILE_LOW_LATENCY' is declared but nothing uses it: remove the declaration (R-072) |
| ERROR | R-072 | m_vlsit_riscv_cluster_core.sv:91 | 'LPARA_TIMING_PROFILE_CLUSTER_TIMING' is declared but nothing uses it: remove the declaration (R-072) |
| ERROR | R-072 | m_vlsit_riscv_pmu.sv:31 | 'LPARA_TIMING_PROFILE_LOW_LATENCY' is declared but nothing uses it: remove the declaration (R-072) |
| ERROR | TYP-07 | m_vlsit_riscv_cluster_axi_top.sv:74 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_cluster_axi_top.sv:78 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_cluster_axi_top.sv:82 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_cluster_axi_top.sv:86 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_cluster_axi_top.sv:90 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_cluster_core.sv:73 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_cluster_core.sv:77 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_cluster_core.sv:81 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_cluster_core.sv:85 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_cluster_core.sv:89 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_cpu_tile_array.sv:37 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_cpu_tile_array.sv:41 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_cpu_tile_array.sv:45 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_cpu_tile_array.sv:49 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_cpu_tile_array.sv:53 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| WARN | CMT-01 | m_vlsit_riscv_axi_route.sv:495 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_axi_route.sv:564 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_axi_route.sv:604 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_pmu.sv:156 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_pmu.sv:160 | no functional comment before this assign group |
| WARN | HIE-02 | m_vlsit_riscv_axi_route.sv:16 | module has instances and also logic; a structural top should contain instances only (HIE-02) |
| WARN | HIE-02 | m_vlsit_riscv_cluster_core.sv:26 | module has instances and also logic; a structural top should contain instances only (HIE-02) |
| WARN | HIE-02 | m_vlsit_riscv_coh_fabric.sv:33 | module has instances and also logic; a structural top should contain instances only (HIE-02) |
| WARN | HIE-02 | m_vlsit_riscv_coh_tile_array.sv:11 | module has instances and also logic; a structural top should contain instances only (HIE-02) |
| WARN | HIE-02 | m_vlsit_riscv_cpu_tile_array.sv:16 | module has instances and also logic; a structural top should contain instances only (HIE-02) |
| WARN | HIE-02 | m_vlsit_riscv_pmu.sv:13 | module has instances and also logic; a structural top should contain instances only (HIE-02) |
| WARN | HIE-02 | m_vlsit_riscv_tile_coh_adapter.sv:24 | module has instances and also logic; a structural top should contain instances only (HIE-02) |
| WARN | NAM-08 | m_vlsit_riscv_cluster_axi_top.sv:62 | parameter 'PARA_PMU_COUNTER_NUM' spells out 'counter'; NAM-08 writes 'cnt' |
| WARN | NAM-08 | m_vlsit_riscv_cluster_axi_top.sv:66 | parameter 'PARA_PMU_COUNTER_W' spells out 'counter'; NAM-08 writes 'cnt' |
| WARN | NAM-08 | m_vlsit_riscv_cluster_core.sv:61 | parameter 'PARA_PMU_COUNTER_NUM' spells out 'counter'; NAM-08 writes 'cnt' |
| WARN | NAM-08 | m_vlsit_riscv_cluster_core.sv:65 | parameter 'PARA_PMU_COUNTER_W' spells out 'counter'; NAM-08 writes 'cnt' |
| WARN | NAM-08 | m_vlsit_riscv_cluster_core.sv:271 | signal 'w_cmo_error' spells out 'error'; NAM-08 writes 'err' |
| WARN | NAM-08 | m_vlsit_riscv_cluster_core.sv:275 | signal 'w_maint_error' spells out 'error'; NAM-08 writes 'err' |
| WARN | NAM-08 | m_vlsit_riscv_cluster_core.sv:278 | instance 'u_vlsit_riscv_cmo_arbiter' spells out 'arbiter'; NAM-08 writes 'arb' |
| WARN | NAM-08 | m_vlsit_riscv_cmo_controller.sv:50 | port 'o_cmo_error' spells out 'error'; NAM-08 writes 'err' |
| WARN | NAM-08 | m_vlsit_riscv_cmo_controller.sv:73 | port 'i_maint_error' spells out 'error'; NAM-08 writes 'err' |

Rules failed: COM-09, COM-11, NAM-07, NAM-09, R-072, TYP-07
Rules warned: CMT-01, HIE-02, NAM-08
Rules clean: ARI-04, CMT-05, COM-02, COM-03, COM-04, COM-06, COM-07, COM-10, ENM-01, ENM-03, ENM-04, ENM-05, ENM-06, FIL-01, FIL-02, FIL-03, FIL-04, FIL-05, FIL-06, HIE-01, HIE-03, HIE-05, NAM-TBL, P1, P11, P12, P13, P14, P17, P18, P19, P2, P20, P21, P22, P24, P25, P26, P27, P29, P3, P30, P31, P32, P33, P4, P6, P7, PAR-01, PAR-02, PAR-03, R-019, R-027, R-032, R-035, R-036, R-038, R-071, SCP-01, SEC-8.1, SEQ-01, TYP-02, TYP-06
