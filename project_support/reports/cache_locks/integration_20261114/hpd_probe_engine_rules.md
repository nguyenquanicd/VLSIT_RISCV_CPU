# RTL rule check

Files: m_vlsit_riscv_hpd_probe_engine.sv

| Level | Rule | File:line | Finding |
|---|---|---|---|
| ERROR | ENM-04 | m_vlsit_riscv_hpd_probe_engine.sv:1 | an FSM needs reg_fsm_<function>_current_state and w_fsm_<function>_nxt_state |
| ERROR | FIL-05 | m_vlsit_riscv_hpd_probe_engine.sv:27 | port 'i_clk_cache' is not aligned: keyword, type, width and name start in the same columns for every port, each column as narrow as its longest entry (FIL-05) |
| ERROR | PAR-01 | m_vlsit_riscv_hpd_probe_engine.sv:117 | localparam 'LPARA_ST_IDLE' must be declared 'localparam logic [31:0] LPARA_<NAME>' |
| ERROR | PAR-01 | m_vlsit_riscv_hpd_probe_engine.sv:117 | localparam 'LPARA_ST_IDLE' must be in the parameter port list, directly after the parameters |
| ERROR | PAR-01 | m_vlsit_riscv_hpd_probe_engine.sv:129 | localparam 'LPARA_STATE_I' must be declared 'localparam logic [31:0] LPARA_<NAME>' |
| ERROR | PAR-01 | m_vlsit_riscv_hpd_probe_engine.sv:129 | localparam 'LPARA_STATE_I' must be in the parameter port list, directly after the parameters |
| ERROR | R-019 | m_vlsit_riscv_hpd_probe_engine.sv:309 | if / else-if chain with 3 conditions: write it as case or casez (R-019) |
| ERROR | R-072 | m_vlsit_riscv_hpd_probe_engine.sv:16 | 'LPARA_TAG_W' is declared but nothing uses it: remove the declaration (R-072) |
| ERROR | R-072 | m_vlsit_riscv_hpd_probe_engine.sv:17 | 'LPARA_NLINE_W' is declared but nothing uses it: remove the declaration (R-072) |
| ERROR | R-072 | m_vlsit_riscv_hpd_probe_engine.sv:22 | 'LPARA_MESI_S' is declared but nothing uses it: remove the declaration (R-072) |
| ERROR | R-072 | m_vlsit_riscv_hpd_probe_engine.sv:23 | 'LPARA_MESI_E' is declared but nothing uses it: remove the declaration (R-072) |
| WARN | CMT-01 | m_vlsit_riscv_hpd_probe_engine.sv:198 | no functional comment before this process |
| WARN | NAM-08 | m_vlsit_riscv_hpd_probe_engine.sv:80 | enum member 'ENUM_ST_ERROR_RSP' spells out 'error'; NAM-08 writes 'err' |
| WARN | PAR-03 | m_vlsit_riscv_hpd_probe_engine.sv:119 | literal 4'd2 may be a magic number (P10); name it with a parameter, localparam or enum member |
| WARN | PAR-03 | m_vlsit_riscv_hpd_probe_engine.sv:120 | literal 4'd3 may be a magic number (P10); name it with a parameter, localparam or enum member |
| WARN | PAR-03 | m_vlsit_riscv_hpd_probe_engine.sv:121 | literal 4'd4 may be a magic number (P10); name it with a parameter, localparam or enum member |
| WARN | PAR-03 | m_vlsit_riscv_hpd_probe_engine.sv:122 | literal 4'd5 may be a magic number (P10); name it with a parameter, localparam or enum member |
| WARN | PAR-03 | m_vlsit_riscv_hpd_probe_engine.sv:123 | literal 4'd6 may be a magic number (P10); name it with a parameter, localparam or enum member |
| WARN | PAR-03 | m_vlsit_riscv_hpd_probe_engine.sv:124 | literal 4'd7 may be a magic number (P10); name it with a parameter, localparam or enum member |
| WARN | PAR-03 | m_vlsit_riscv_hpd_probe_engine.sv:125 | literal 4'd8 may be a magic number (P10); name it with a parameter, localparam or enum member |
| WARN | PAR-03 | m_vlsit_riscv_hpd_probe_engine.sv:126 | literal 4'd9 may be a magic number (P10); name it with a parameter, localparam or enum member |
| INFO | COM-04 | m_vlsit_riscv_hpd_probe_engine.sv:154 | casez default assigns 'x: confirm the comment above the process states that every legal encoding is covered and the spec allows don't-care |
| INFO | COM-04 | m_vlsit_riscv_hpd_probe_engine.sv:217 | casez default assigns 'x: confirm the comment above the process states that every legal encoding is covered and the spec allows don't-care |

Rules failed: ENM-04, FIL-05, PAR-01, R-019, R-072
Rules warned: CMT-01, NAM-08, PAR-03
Rules clean: ARI-04, CMT-05, COM-02, COM-03, COM-04, COM-06, COM-07, ENM-01, ENM-03, ENM-05, ENM-06, FIL-01, FIL-02, FIL-03, FIL-04, FIL-06, HIE-01, HIE-02, HIE-03, HIE-05, NAM-07, NAM-09, NAM-TBL, P1, P11, P12, P13, P14, P17, P18, P19, P2, P20, P21, P22, P24, P25, P26, P27, P29, P3, P30, P4, P6, P7, PAR-02, R-027, R-032, R-035, R-036, R-038, R-071, SCP-01, SEC-8.1, SEQ-01, TYP-02, TYP-06
