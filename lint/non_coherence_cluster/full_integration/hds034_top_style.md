# RTL rule check

Files: m_vlsit_riscv_cluster_axi_top.sv

| Level | Rule | File:line | Finding |
|---|---|---|---|
| ERROR | P14 | m_vlsit_riscv_cluster_axi_top.sv:220 | system task $error is for verification sources only |
| ERROR | P14 | m_vlsit_riscv_cluster_axi_top.sv:223 | system task $error is for verification sources only |
| ERROR | P14 | m_vlsit_riscv_cluster_axi_top.sv:226 | system task $error is for verification sources only |
| ERROR | P14 | m_vlsit_riscv_cluster_axi_top.sv:230 | system task $error is for verification sources only |
| ERROR | P14 | m_vlsit_riscv_cluster_axi_top.sv:234 | system task $error is for verification sources only |
| ERROR | P14 | m_vlsit_riscv_cluster_axi_top.sv:237 | system task $error is for verification sources only |
| ERROR | P14 | m_vlsit_riscv_cluster_axi_top.sv:240 | system task $error is for verification sources only |
| ERROR | P14 | m_vlsit_riscv_cluster_axi_top.sv:245 | system task $error is for verification sources only |
| ERROR | TYP-07 | m_vlsit_riscv_cluster_axi_top.sv:77 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_cluster_axi_top.sv:81 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_cluster_axi_top.sv:85 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_cluster_axi_top.sv:89 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| ERROR | TYP-07 | m_vlsit_riscv_cluster_axi_top.sv:93 | ascending dimension [0:15]: write dimensions MSB:LSB (TYP-07, P31) |
| WARN | CMT-01 | m_vlsit_riscv_cluster_axi_top.sv:381 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_cluster_axi_top.sv:396 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_cluster_axi_top.sv:411 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_cluster_axi_top.sv:426 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_cluster_axi_top.sv:441 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_cluster_axi_top.sv:456 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_cluster_axi_top.sv:471 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_cluster_axi_top.sv:486 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_cluster_axi_top.sv:501 | no functional comment before this assign group |
| WARN | CMT-01 | m_vlsit_riscv_cluster_axi_top.sv:516 | no functional comment before this assign group |
| WARN | HIE-02 | m_vlsit_riscv_cluster_axi_top.sv:27 | module has instances and also logic; a structural top should contain instances only (HIE-02) |
| WARN | NAM-08 | m_vlsit_riscv_cluster_axi_top.sv:65 | parameter 'PARA_PMU_COUNTER_NUM' spells out 'counter'; NAM-08 writes 'cnt' |
| WARN | NAM-08 | m_vlsit_riscv_cluster_axi_top.sv:69 | parameter 'PARA_PMU_COUNTER_W' spells out 'counter'; NAM-08 writes 'cnt' |
| WARN | PAR-03 | m_vlsit_riscv_cluster_axi_top.sv:219 | literal 32'd2 may be a magic number (P10); name it with a parameter, localparam or enum member |
| WARN | PAR-03 | m_vlsit_riscv_cluster_axi_top.sv:225 | literal 32'd2 may be a magic number (P10); name it with a parameter, localparam or enum member |
| WARN | PAR-03 | m_vlsit_riscv_cluster_axi_top.sv:228 | literal 32'd32 may be a magic number (P10); name it with a parameter, localparam or enum member |
| WARN | PAR-03 | m_vlsit_riscv_cluster_axi_top.sv:229 | literal 32'd128 may be a magic number (P10); name it with a parameter, localparam or enum member |
| WARN | PAR-03 | m_vlsit_riscv_cluster_axi_top.sv:232 | literal 32'd32 may be a magic number (P10); name it with a parameter, localparam or enum member |
| WARN | PAR-03 | m_vlsit_riscv_cluster_axi_top.sv:233 | literal 32'd32 may be a magic number (P10); name it with a parameter, localparam or enum member |
| WARN | PAR-03 | m_vlsit_riscv_cluster_axi_top.sv:236 | literal 32'd16 may be a magic number (P10); name it with a parameter, localparam or enum member |
| WARN | PAR-03 | m_vlsit_riscv_cluster_axi_top.sv:242 | literal 32'd32 may be a magic number (P10); name it with a parameter, localparam or enum member |

Rules failed: P14, TYP-07
Rules warned: CMT-01, HIE-02, NAM-08, PAR-03
Rules clean: ARI-04, CMT-05, COM-02, COM-03, COM-04, COM-06, COM-07, COM-09, COM-10, COM-11, ENM-01, ENM-03, ENM-04, ENM-05, ENM-06, FIL-01, FIL-02, FIL-03, FIL-04, FIL-05, FIL-06, HIE-01, HIE-03, HIE-05, NAM-07, NAM-09, NAM-TBL, P1, P11, P12, P13, P17, P18, P19, P2, P20, P21, P22, P24, P25, P26, P27, P29, P3, P30, P31, P32, P33, P4, P6, P7, PAR-01, PAR-02, R-019, R-027, R-032, R-035, R-036, R-038, R-071, R-072, SCP-01, SEC-8.1, SEQ-01, TYP-02, TYP-06
