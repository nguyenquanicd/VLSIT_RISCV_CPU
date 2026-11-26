# RTL rule check

Files: m_vlsit_riscv_cache_line_locks.sv, m_vlsit_riscv_coh_fabric.sv, m_vlsit_riscv_coh_tile_array.sv, m_vlsit_riscv_sharer_directory.sv, m_vlsit_riscv_tile_coh_adapter.sv, m_vlsit_riscv_cpu_tile_array.sv, m_vlsit_riscv_axi_route.sv, m_vlsit_riscv_cmo_controller.sv, m_vlsit_riscv_pmu.sv, m_vlsit_riscv_cluster_axi_top.sv, m_vlsit_riscv_cluster_core.sv

| Level | Rule | File:line | Finding |
|---|---|---|---|
| ERROR | COM-09 | m_vlsit_riscv_cluster_core.sv:1072 | logical '&&' in a value expression: use the bitwise '&'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_cluster_core.sv:1073 | logical '&&' in a value expression: use the bitwise '&'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_coh_fabric.sv:321 | logical '&&' in a value expression: use the bitwise '&'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_coh_fabric.sv:322 | logical '&&' in a value expression: use the bitwise '&'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_coh_fabric.sv:322 | logical '!' in a value expression: use the bitwise '~'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_coh_fabric.sv:322 | logical '&&' in a value expression: use the bitwise '&'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_coh_fabric.sv:322 | logical '!' in a value expression: use the bitwise '~'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_coh_fabric.sv:323 | logical '&&' in a value expression: use the bitwise '&'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_coh_fabric.sv:324 | logical '&&' in a value expression: use the bitwise '&'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_coh_fabric.sv:326 | logical '&&' in a value expression: use the bitwise '&'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_coh_fabric.sv:326 | logical '!' in a value expression: use the bitwise '~'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_coh_fabric.sv:327 | logical '&&' in a value expression: use the bitwise '&'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_coh_fabric.sv:327 | logical '!' in a value expression: use the bitwise '~'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_coh_fabric.sv:327 | logical '&&' in a value expression: use the bitwise '&'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_coh_fabric.sv:328 | logical '&&' in a value expression: use the bitwise '&'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_coh_fabric.sv:329 | logical '&&' in a value expression: use the bitwise '&'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_coh_fabric.sv:331 | logical '&&' in a value expression: use the bitwise '&'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_coh_fabric.sv:337 | logical '&&' in a value expression: use the bitwise '&'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_coh_fabric.sv:339 | logical '&&' in a value expression: use the bitwise '&'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_coh_fabric.sv:341 | logical '&&' in a value expression: use the bitwise '&'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-09 | m_vlsit_riscv_coh_fabric.sv:343 | logical '&&' in a value expression: use the bitwise '&'; &&, // and ! belong in if / for / while / ternary conditions only (COM-09, COM-10, P32) |
| ERROR | COM-11 | m_vlsit_riscv_sharer_directory.sv:390 | selection nesting depth 5: keep case / if nesting at four levels or less and restructure with a case, a helper function or a submodule (COM-11, P33) |
| ERROR | NAM-09 | m_vlsit_riscv_axi_route.sv:477 | instance 'u_mem_axi_cut' of cell 'axi_cut' must be named u_dont_touch_<function> |
| ERROR | NAM-09 | m_vlsit_riscv_axi_route.sv:495 | instance 'u_mmio_axi_cut' of cell 'axi_cut' must be named u_dont_touch_<function> |
| ERROR | TYP-07 | m_vlsit_riscv_cluster_axi_top.sv:76 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_cluster_axi_top.sv:80 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_cluster_axi_top.sv:84 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_cluster_axi_top.sv:88 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_cluster_axi_top.sv:92 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_cluster_core.sv:75 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_cluster_core.sv:79 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_cluster_core.sv:83 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_cluster_core.sv:87 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_cluster_core.sv:91 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_cpu_tile_array.sv:47 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_cpu_tile_array.sv:51 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_cpu_tile_array.sv:55 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_cpu_tile_array.sv:59 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_cpu_tile_array.sv:63 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| WARN | CMT-01 | m_vlsit_riscv_axi_route.sv:417 | no functional comment before this process |
| WARN | CMT-01 | m_vlsit_riscv_axi_route.sv:423 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_axi_route.sv:425 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_axi_route.sv:428 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_axi_route.sv:513 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_axi_route.sv:582 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_axi_route.sv:622 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_cache_line_locks.sv:62 | no functional comment before this process |
| WARN | CMT-01 | m_vlsit_riscv_cache_line_locks.sv:68 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_cache_line_locks.sv:70 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_cluster_axi_top.sv:350 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_cluster_axi_top.sv:365 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_cluster_axi_top.sv:380 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_cluster_axi_top.sv:395 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_cluster_axi_top.sv:410 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_cluster_axi_top.sv:425 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_cluster_axi_top.sv:440 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_cluster_axi_top.sv:455 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_cluster_axi_top.sv:470 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_cluster_axi_top.sv:485 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_cmo_controller.sv:94 | no functional comment before this process |
| WARN | CMT-01 | m_vlsit_riscv_cmo_controller.sv:100 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_cmo_controller.sv:102 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_pmu.sv:113 | no functional comment before this process |
| WARN | CMT-01 | m_vlsit_riscv_pmu.sv:137 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_pmu.sv:147 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_pmu.sv:226 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_pmu.sv:230 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_sharer_directory.sv:185 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_sharer_directory.sv:193 | no functional comment before this process |
| WARN | CMT-01 | m_vlsit_riscv_sharer_directory.sv:215 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_sharer_directory.sv:222 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_sharer_directory.sv:234 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_sharer_directory.sv:239 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_sharer_directory.sv:243 | no functional comment before this process |
| WARN | CMT-01 | m_vlsit_riscv_sharer_directory.sv:249 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_sharer_directory.sv:251 | no functional comment before this process |
| WARN | CMT-01 | m_vlsit_riscv_sharer_directory.sv:255 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_tile_coh_adapter.sv:128 | no functional comment before this process |
| WARN | CMT-01 | m_vlsit_riscv_tile_coh_adapter.sv:134 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_tile_coh_adapter.sv:136 | no functional comment before this assign group |
| WARN | HIE-02 | m_vlsit_riscv_axi_route.sv:18 | module has instances and also logic; a structural top should contain instances only (HIE-02) |
| WARN | HIE-02 | m_vlsit_riscv_cluster_axi_top.sv:26 | module has instances and also logic; a structural top should contain instances only (HIE-02) |
| WARN | HIE-02 | m_vlsit_riscv_cluster_core.sv:28 | module has instances and also logic; a structural top should contain instances only (HIE-02) |
| WARN | HIE-02 | m_vlsit_riscv_coh_fabric.sv:38 | module has instances and also logic; a structural top should contain instances only (HIE-02) |
| WARN | HIE-02 | m_vlsit_riscv_coh_tile_array.sv:13 | module has instances and also logic; a structural top should contain instances only (HIE-02) |
| WARN | HIE-02 | m_vlsit_riscv_cpu_tile_array.sv:18 | module has instances and also logic; a structural top should contain instances only (HIE-02) |
| WARN | HIE-02 | m_vlsit_riscv_pmu.sv:15 | module has instances and also logic; a structural top should contain instances only (HIE-02) |
| WARN | HIE-02 | m_vlsit_riscv_tile_coh_adapter.sv:26 | module has instances and also logic; a structural top should contain instances only (HIE-02) |
| WARN | NAM-08 | m_vlsit_riscv_axi_route.sv:424 | label 'gen_route_reset_direct' spells out 'reset'; NAM-08 writes 'rst' |
| WARN | NAM-08 | m_vlsit_riscv_cache_line_locks.sv:26 | parameter 'PARA_REGISTER_RESET_RELEASE' spells out 'reset'; NAM-08 writes 'rst' |
| WARN | NAM-08 | m_vlsit_riscv_cache_line_locks.sv:60 | label 'gen_reset_release' spells out 'reset'; NAM-08 writes 'rst' |
| WARN | NAM-08 | m_vlsit_riscv_cache_line_locks.sv:62 | process label 'p_ff_reset_release' spells out 'reset'; NAM-08 writes 'rst' |
| WARN | NAM-08 | m_vlsit_riscv_cache_line_locks.sv:69 | label 'gen_reset_direct' spells out 'reset'; NAM-08 writes 'rst' |
| WARN | NAM-08 | m_vlsit_riscv_cluster_axi_top.sv:64 | parameter 'PARA_PMU_COUNTER_NUM' spells out 'counter'; NAM-08 writes 'cnt' |
| WARN | NAM-08 | m_vlsit_riscv_cluster_axi_top.sv:68 | parameter 'PARA_PMU_COUNTER_W' spells out 'counter'; NAM-08 writes 'cnt' |
| WARN | NAM-08 | m_vlsit_riscv_cluster_core.sv:63 | parameter 'PARA_PMU_COUNTER_NUM' spells out 'counter'; NAM-08 writes 'cnt' |
| WARN | NAM-08 | m_vlsit_riscv_cluster_core.sv:67 | parameter 'PARA_PMU_COUNTER_W' spells out 'counter'; NAM-08 writes 'cnt' |
| WARN | NAM-08 | m_vlsit_riscv_cluster_core.sv:272 | signal 'w_cmo_error' spells out 'error'; NAM-08 writes 'err' |
| WARN | NAM-08 | m_vlsit_riscv_cluster_core.sv:276 | signal 'w_maint_error' spells out 'error'; NAM-08 writes 'err' |
| WARN | NAM-08 | m_vlsit_riscv_cluster_core.sv:279 | instance 'u_vlsit_riscv_cmo_arbiter' spells out 'arbiter'; NAM-08 writes 'arb' |
| WARN | NAM-08 | m_vlsit_riscv_cmo_controller.sv:35 | parameter 'PARA_REGISTER_RESET_RELEASE' spells out 'reset'; NAM-08 writes 'rst' |
| WARN | NAM-08 | m_vlsit_riscv_cmo_controller.sv:56 | port 'o_cmo_error' spells out 'error'; NAM-08 writes 'err' |
| WARN | NAM-08 | m_vlsit_riscv_cmo_controller.sv:79 | port 'i_maint_error' spells out 'error'; NAM-08 writes 'err' |
| WARN | NAM-08 | m_vlsit_riscv_cmo_controller.sv:92 | label 'gen_reset_release' spells out 'reset'; NAM-08 writes 'rst' |
| WARN | NAM-08 | m_vlsit_riscv_cmo_controller.sv:94 | process label 'p_ff_reset_release' spells out 'reset'; NAM-08 writes 'rst' |
| WARN | NAM-08 | m_vlsit_riscv_cmo_controller.sv:101 | label 'gen_reset_direct' spells out 'reset'; NAM-08 writes 'rst' |
| WARN | NAM-08 | m_vlsit_riscv_coh_fabric.sv:60 | parameter 'PARA_DIR_SYNC_READ' spells out 'read'; NAM-08 writes 'rd' |
| WARN | NAM-08 | m_vlsit_riscv_coh_tile_array.sv:30 | parameter 'PARA_REGISTER_RESET_RELEASE' spells out 'reset'; NAM-08 writes 'rst' |
| WARN | NAM-08 | m_vlsit_riscv_coh_tile_array.sv:34 | parameter 'PARA_DIR_SYNC_READ' spells out 'read'; NAM-08 writes 'rd' |
| WARN | NAM-08 | m_vlsit_riscv_cpu_tile_array.sv:35 | parameter 'PARA_REGISTER_RESET_RELEASE' spells out 'reset'; NAM-08 writes 'rst' |
| WARN | NAM-08 | m_vlsit_riscv_cpu_tile_array.sv:39 | parameter 'PARA_DIR_SYNC_READ' spells out 'read'; NAM-08 writes 'rd' |
| WARN | NAM-08 | m_vlsit_riscv_pmu.sv:102 | label 'gen_pmu_source_pipe' spells out 'source'; NAM-08 writes 'src' |
| WARN | NAM-08 | m_vlsit_riscv_pmu.sv:113 | process label 'p_ff_pmu_source' spells out 'source'; NAM-08 writes 'src' |
| WARN | NAM-08 | m_vlsit_riscv_pmu.sv:146 | label 'gen_pmu_source_direct' spells out 'source'; NAM-08 writes 'src' |
| WARN | NAM-08 | m_vlsit_riscv_sharer_directory.sv:34 | parameter 'PARA_DIR_SYNC_READ' spells out 'read'; NAM-08 writes 'rd' |
| WARN | NAM-08 | m_vlsit_riscv_sharer_directory.sv:105 | signal 'w_read_slot_ready' spells out 'read'; NAM-08 writes 'rd' |
| WARN | NAM-08 | m_vlsit_riscv_sharer_directory.sv:177 | label 'gen_read_pipe' spells out 'read'; NAM-08 writes 'rd' |
| WARN | NAM-08 | m_vlsit_riscv_sharer_directory.sv:178 | signal 'reg_read_valid' spells out 'read'; NAM-08 writes 'rd' |
| WARN | NAM-08 | m_vlsit_riscv_sharer_directory.sv:179 | signal 'reg_read_set' spells out 'read'; NAM-08 writes 'rd' |
| WARN | NAM-08 | m_vlsit_riscv_sharer_directory.sv:180 | signal 'reg_read_tag' spells out 'read'; NAM-08 writes 'rd' |
| WARN | NAM-08 | m_vlsit_riscv_sharer_directory.sv:181 | signal 'reg_read_rsp_tag' spells out 'read'; NAM-08 writes 'rd' |
| WARN | NAM-08 | m_vlsit_riscv_sharer_directory.sv:182 | signal 'reg_read_valid_ways' spells out 'read'; NAM-08 writes 'rd' |
| WARN | NAM-08 | m_vlsit_riscv_sharer_directory.sv:183 | signal 'reg_read_plru' spells out 'read'; NAM-08 writes 'rd' |
| WARN | NAM-08 | m_vlsit_riscv_sharer_directory.sv:193 | process label 'p_ff_dir_read_pipe' spells out 'read'; NAM-08 writes 'rd' |
| WARN | NAM-08 | m_vlsit_riscv_sharer_directory.sv:214 | label 'gen_read_direct' spells out 'read'; NAM-08 writes 'rd' |
| WARN | NAM-08 | m_vlsit_riscv_sharer_directory.sv:230 | signal 'w_write_way' spells out 'write'; NAM-08 writes 'wr' |
| WARN | NAM-08 | m_vlsit_riscv_sharer_directory.sv:231 | signal 'w_write_entry' spells out 'write'; NAM-08 writes 'wr' |
| WARN | NAM-08 | m_vlsit_riscv_sharer_directory.sv:242 | signal 'reg_read_entry' spells out 'read'; NAM-08 writes 'rd' |
| WARN | NAM-08 | m_vlsit_riscv_sharer_directory.sv:250 | label 'gen_async_read' spells out 'read'; NAM-08 writes 'rd' |
| WARN | NAM-08 | m_vlsit_riscv_sharer_directory.sv:251 | process label 'p_ff_dir_write' spells out 'write'; NAM-08 writes 'wr' |
| WARN | NAM-08 | m_vlsit_riscv_tile_coh_adapter.sv:35 | parameter 'PARA_REGISTER_RESET_RELEASE' spells out 'reset'; NAM-08 writes 'rst' |
| WARN | NAM-08 | m_vlsit_riscv_tile_coh_adapter.sv:126 | label 'gen_reset_release' spells out 'reset'; NAM-08 writes 'rst' |
| WARN | NAM-08 | m_vlsit_riscv_tile_coh_adapter.sv:128 | process label 'p_ff_reset_release' spells out 'reset'; NAM-08 writes 'rst' |
| WARN | NAM-08 | m_vlsit_riscv_tile_coh_adapter.sv:135 | label 'gen_reset_direct' spells out 'reset'; NAM-08 writes 'rst' |
| WARN | PAR-03 | m_vlsit_riscv_cluster_axi_top.sv:273 | literal 8 may be a magic number (P10); name it with a parameter, localparam or enum member |

Rules failed: COM-09, COM-11, NAM-09, TYP-07
Rules warned: CMT-01, HIE-02, NAM-08, PAR-03
Rules clean: ARI-04, CMT-05, COM-02, COM-03, COM-04, COM-06, COM-07, COM-10, ENM-01, ENM-03, ENM-04, ENM-05, ENM-06, FIL-01, FIL-02, FIL-03, FIL-04, FIL-05, FIL-06, HIE-01, HIE-03, HIE-05, NAM-07, NAM-TBL, P1, P11, P12, P13, P14, P17, P18, P19, P2, P20, P21, P22, P24, P25, P26, P27, P29, P3, P30, P31, P32, P33, P4, P6, P7, PAR-01, PAR-02, R-019, R-027, R-032, R-035, R-036, R-038, R-071, R-072, SCP-01, SEC-8.1, SEQ-01, TYP-02, TYP-06
