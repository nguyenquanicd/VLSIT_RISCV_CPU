# RTL rule check

Files: m_vlsit_riscv_cluster_axi_top.sv, m_vlsit_riscv_axi_soc_wrap.sv

| Level | Rule | File:line | Finding |
|---|---|---|---|
| ERROR | P14 | m_vlsit_riscv_cluster_axi_top.sv:222 | system task $error is for verification sources only |
| ERROR | P14 | m_vlsit_riscv_cluster_axi_top.sv:225 | system task $error is for verification sources only |
| ERROR | P14 | m_vlsit_riscv_cluster_axi_top.sv:228 | system task $error is for verification sources only |
| ERROR | P14 | m_vlsit_riscv_cluster_axi_top.sv:232 | system task $error is for verification sources only |
| ERROR | P14 | m_vlsit_riscv_cluster_axi_top.sv:236 | system task $error is for verification sources only |
| ERROR | P14 | m_vlsit_riscv_cluster_axi_top.sv:239 | system task $error is for verification sources only |
| ERROR | P14 | m_vlsit_riscv_cluster_axi_top.sv:242 | system task $error is for verification sources only |
| ERROR | P14 | m_vlsit_riscv_cluster_axi_top.sv:247 | system task $error is for verification sources only |
| ERROR | TYP-07 | m_vlsit_riscv_axi_soc_wrap.sv:60 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_axi_soc_wrap.sv:64 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_axi_soc_wrap.sv:68 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_axi_soc_wrap.sv:72 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_axi_soc_wrap.sv:76 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_cluster_axi_top.sv:79 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_cluster_axi_top.sv:83 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_cluster_axi_top.sv:87 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_cluster_axi_top.sv:91 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_cluster_axi_top.sv:95 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| WARN | CMT-01 | m_vlsit_riscv_cluster_axi_top.sv:383 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_cluster_axi_top.sv:398 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_cluster_axi_top.sv:413 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_cluster_axi_top.sv:428 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_cluster_axi_top.sv:443 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_cluster_axi_top.sv:458 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_cluster_axi_top.sv:473 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_cluster_axi_top.sv:488 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_cluster_axi_top.sv:503 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_cluster_axi_top.sv:518 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_cluster_axi_top.sv:525 | no functional comment before this assign group |
| WARN | HIE-02 | m_vlsit_riscv_axi_soc_wrap.sv:10 | module has instances and also logic; a structural top should contain instances only (HIE-02) |
| WARN | HIE-02 | m_vlsit_riscv_cluster_axi_top.sv:29 | module has instances and also logic; a structural top should contain instances only (HIE-02) |
| WARN | NAM-08 | m_vlsit_riscv_axi_soc_wrap.sv:48 | parameter 'PARA_PMU_COUNTER_NUM' spells out 'counter'; NAM-08 writes 'cnt' |
| WARN | NAM-08 | m_vlsit_riscv_axi_soc_wrap.sv:52 | parameter 'PARA_PMU_COUNTER_W' spells out 'counter'; NAM-08 writes 'cnt' |
| WARN | NAM-08 | m_vlsit_riscv_cluster_axi_top.sv:67 | parameter 'PARA_PMU_COUNTER_NUM' spells out 'counter'; NAM-08 writes 'cnt' |
| WARN | NAM-08 | m_vlsit_riscv_cluster_axi_top.sv:71 | parameter 'PARA_PMU_COUNTER_W' spells out 'counter'; NAM-08 writes 'cnt' |
| WARN | PAR-03 | m_vlsit_riscv_cluster_axi_top.sv:221 | literal 32'd2 may be a magic number (P10); name it with a parameter, localparam or enum member |
| WARN | PAR-03 | m_vlsit_riscv_cluster_axi_top.sv:227 | literal 32'd2 may be a magic number (P10); name it with a parameter, localparam or enum member |
| WARN | PAR-03 | m_vlsit_riscv_cluster_axi_top.sv:230 | literal 32'd32 may be a magic number (P10); name it with a parameter, localparam or enum member |
| WARN | PAR-03 | m_vlsit_riscv_cluster_axi_top.sv:231 | literal 32'd128 may be a magic number (P10); name it with a parameter, localparam or enum member |
| WARN | PAR-03 | m_vlsit_riscv_cluster_axi_top.sv:234 | literal 32'd32 may be a magic number (P10); name it with a parameter, localparam or enum member |
| WARN | PAR-03 | m_vlsit_riscv_cluster_axi_top.sv:235 | literal 32'd32 may be a magic number (P10); name it with a parameter, localparam or enum member |
| WARN | PAR-03 | m_vlsit_riscv_cluster_axi_top.sv:238 | literal 32'd16 may be a magic number (P10); name it with a parameter, localparam or enum member |
| WARN | PAR-03 | m_vlsit_riscv_cluster_axi_top.sv:244 | literal 32'd32 may be a magic number (P10); name it with a parameter, localparam or enum member |

Rules failed: P14, TYP-07
Rules warned: CMT-01, HIE-02, NAM-08, PAR-03
Rules clean: ARI-04, CMT-05, COM-02, COM-03, COM-04, COM-06, COM-07, COM-09, COM-10, COM-11, ENM-01, ENM-03, ENM-04, ENM-05, ENM-06, FIL-01, FIL-02, FIL-03, FIL-04, FIL-05, FIL-06, HIE-01, HIE-03, HIE-05, NAM-07, NAM-09, NAM-TBL, P1, P11, P12, P13, P17, P18, P19, P2, P20, P21, P22, P24, P25, P26, P27, P29, P3, P30, P31, P32, P33, P4, P6, P7, PAR-01, PAR-02, R-019, R-027, R-032, R-035, R-036, R-038, R-071, R-072, SCP-01, SEC-8.1, SEQ-01, TYP-02, TYP-06
