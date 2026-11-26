# RTL rule check

Files: hpdcache_miss_handler.sv, m_vlsit_riscv_cpu_tile.sv

| Level | Rule | File:line | Finding |
|---|---|---|---|
| ERROR | COM-03 | hpdcache_miss_handler.sv:301 | case without a default branch |
| ERROR | COM-07 | hpdcache_miss_handler.sv:432 | 'core_rsp_word' is assigned only inside if / case of an always_comb: assign a default at the top of the process or a latch is inferred (COM-07, COM-02, P7) |
| ERROR | COM-07 | hpdcache_miss_handler.sv:432 | 'is_prefetch' is assigned only inside if / case of an always_comb: assign a default at the top of the process or a latch is inferred (COM-07, COM-02, P7) |
| ERROR | COM-07 | hpdcache_miss_handler.sv:432 | 'refill_cnt' is assigned only inside if / case of an always_comb: assign a default at the top of the process or a latch is inferred (COM-07, COM-02, P7) |
| ERROR | ENM-01 | hpdcache_miss_handler.sv:187 | enum 'refill_fsm_e' must be logic-based (typedef enum logic [N:0]) |
| ERROR | ENM-01 | hpdcache_miss_handler.sv:187 | enum member 'REFILL_IDLE' needs an explicit value |
| ERROR | ENM-01 | hpdcache_miss_handler.sv:187 | enum member 'REFILL_WRITE' needs an explicit value |
| ERROR | ENM-01 | hpdcache_miss_handler.sv:187 | enum member 'REFILL_WRITE_DIR' needs an explicit value |
| ERROR | ENM-01 | hpdcache_miss_handler.sv:187 | enum member 'REFILL_INVAL' needs an explicit value |
| ERROR | FIL-01 | hpdcache_miss_handler.sv:1 | header field 'Project:' is missing or empty |
| ERROR | FIL-01 | hpdcache_miss_handler.sv:1 | header field 'Author:' is missing or empty |
| ERROR | FIL-01 | hpdcache_miss_handler.sv:1 | header field 'AI Flow:' is missing or empty |
| ERROR | FIL-01 | hpdcache_miss_handler.sv:1 | header field 'AI Flow Page:' is missing or empty |
| ERROR | FIL-01 | hpdcache_miss_handler.sv:1 | header field 'Date:' is missing or empty |
| ERROR | FIL-01 | hpdcache_miss_handler.sv:1 | header field 'Description:' is missing or empty |
| ERROR | NAM-07 | hpdcache_miss_handler.sv:368 | label 'gen_mem_id_mshr_sets_and_ways_gt_1' is 34 characters; the limit is 30 |
| ERROR | NAM-07 | hpdcache_miss_handler.sv:376 | label 'gen_mem_id_mshr_sets_and_ways_eq_1' is 34 characters; the limit is 30 |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:42 | parameter 'HPDcacheCfg' must be PARA_<UPPERCASE> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:44 | parameter 'hpdcache_nline_t' must be PARA_<UPPERCASE> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:45 | parameter 'hpdcache_set_t' must be PARA_<UPPERCASE> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:46 | parameter 'hpdcache_tag_t' must be PARA_<UPPERCASE> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:47 | parameter 'hpdcache_word_t' must be PARA_<UPPERCASE> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:49 | parameter 'hpdcache_way_vector_t' must be PARA_<UPPERCASE> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:50 | parameter 'hpdcache_way_t' must be PARA_<UPPERCASE> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:52 | parameter 'hpdcache_dir_entry_t' must be PARA_<UPPERCASE> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:54 | parameter 'hpdcache_refill_data_t' must be PARA_<UPPERCASE> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:56 | parameter 'hpdcache_req_data_t' must be PARA_<UPPERCASE> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:57 | parameter 'hpdcache_req_be_t' must be PARA_<UPPERCASE> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:58 | parameter 'hpdcache_req_offset_t' must be PARA_<UPPERCASE> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:59 | parameter 'hpdcache_req_sid_t' must be PARA_<UPPERCASE> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:60 | parameter 'hpdcache_req_tid_t' must be PARA_<UPPERCASE> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:62 | parameter 'hpdcache_req_t' must be PARA_<UPPERCASE> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:63 | parameter 'hpdcache_rsp_t' must be PARA_<UPPERCASE> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:65 | parameter 'hpdcache_mem_id_t' must be PARA_<UPPERCASE> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:66 | parameter 'hpdcache_mem_req_t' must be PARA_<UPPERCASE> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:67 | parameter 'hpdcache_mem_resp_r_t' must be PARA_<UPPERCASE> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:74 | input port 'clk_i' must start with i_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:75 | input port 'rst_ni' must start with i_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:79 | output port 'mshr_empty_o' must start with o_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:80 | output port 'mshr_full_o' must start with o_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:85 | input port 'cfg_prefetch_updt_sel_victim_i' must start with i_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:90 | input port 'mshr_check_i' must start with i_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:91 | input port 'mshr_check_offset_i' must start with i_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:92 | input port 'mshr_check_nline_i' must start with i_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:93 | output port 'mshr_check_hit_o' must start with o_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:94 | input port 'probe_check_valid_i' must start with i_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:95 | input port 'probe_check_nline_i' must start with i_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:96 | output port 'probe_line_busy_o' must start with o_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:102 | output port 'mshr_alloc_ready_o' must start with o_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:103 | input port 'mshr_alloc_i' must start with i_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:104 | input port 'mshr_alloc_cs_i' must start with i_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:105 | input port 'mshr_alloc_nline_i' must start with i_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:106 | output port 'mshr_alloc_full_o' must start with o_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:107 | output port 'mshr_alloc_cbuf_full_o' must start with o_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:108 | input port 'mshr_alloc_tid_i' must start with i_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:109 | input port 'mshr_alloc_sid_i' must start with i_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:110 | input port 'mshr_alloc_word_i' must start with i_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:111 | input port 'mshr_alloc_victim_way_i' must start with i_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:112 | input port 'mshr_alloc_need_rsp_i' must start with i_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:113 | input port 'mshr_alloc_is_prefetch_i' must start with i_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:114 | input port 'mshr_alloc_wback_i' must start with i_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:115 | input port 'mshr_alloc_dirty_i' must start with i_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:116 | input port 'mshr_alloc_wdata_i' must start with i_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:117 | input port 'mshr_alloc_be_i' must start with i_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:120 | input port 'refill_req_ready_i' must start with i_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:121 | output port 'refill_req_valid_o' must start with o_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:122 | output port 'refill_is_error_o' must start with o_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:123 | output port 'refill_busy_o' must start with o_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:124 | output port 'refill_updt_sel_victim_o' must start with o_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:125 | output port 'refill_set_o' must start with o_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:126 | output port 'refill_way_o' must start with o_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:127 | output port 'refill_dir_entry_o' must start with o_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:128 | output port 'refill_write_dir_o' must start with o_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:129 | output port 'refill_write_data_o' must start with o_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:130 | output port 'refill_data_o' must start with o_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:131 | output port 'refill_word_o' must start with o_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:132 | output port 'refill_nline_o' must start with o_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:133 | output port 'refill_updt_rtab_o' must start with o_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:135 | output port 'inval_check_dir_o' must start with o_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:136 | output port 'inval_write_dir_o' must start with o_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:137 | output port 'inval_nline_o' must start with o_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:138 | input port 'inval_hit_i' must start with i_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:141 | output port 'refill_core_rsp_valid_o' must start with o_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:142 | output port 'refill_core_rsp_o' must start with o_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:147 | input port 'mem_req_ready_i' must start with i_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:148 | output port 'mem_req_valid_o' must start with o_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:149 | output port 'mem_req_o' must start with o_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:151 | output port 'mem_resp_ready_o' must start with o_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:152 | input port 'mem_resp_valid_i' must start with i_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:153 | input port 'mem_resp_i' must start with i_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:154 | input port 'mem_resp_inval_i' must start with i_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:155 | input port 'mem_resp_inval_nline_i' must start with i_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:158 | output port 'coh_own_req_valid_o' must start with o_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:159 | input port 'coh_own_req_ready_i' must start with i_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:160 | output port 'coh_own_req_id_o' must start with o_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:161 | output port 'coh_own_req_nline_o' must start with o_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:162 | output port 'coh_own_req_kind_o' must start with o_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:163 | input port 'coh_own_gnt_valid_i' must start with i_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:164 | output port 'coh_own_gnt_ready_o' must start with o_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:165 | input port 'coh_own_gnt_id_i' must start with i_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:166 | input port 'coh_own_gnt_nline_i' must start with i_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:167 | input port 'coh_own_gnt_state_i' must start with i_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:168 | input port 'coh_own_gnt_err_i' must start with i_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:175 | localparam 'REFILL_REQ_RATIO' must be LPARA_<UPPERCASE> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:177 | localparam 'REFILL_LAST_CHUNK_WORD' must be LPARA_<UPPERCASE> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:179 | type 'miss_req_fsm_e' must be named <name>_type_def |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:179 | enum member 'MISS_REQ_IDLE' must be ENUM_<FUNCTION>_<VALUE> in uppercase |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:179 | enum member 'MISS_REQ_OWN_REQ' must be ENUM_<FUNCTION>_<VALUE> in uppercase |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:179 | enum member 'MISS_REQ_OWN_WAIT' must be ENUM_<FUNCTION>_<VALUE> in uppercase |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:179 | enum member 'MISS_REQ_SEND' must be ENUM_<FUNCTION>_<VALUE> in uppercase |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:179 | enum member 'MISS_REQ_OWN_ERROR' must be ENUM_<FUNCTION>_<VALUE> in uppercase |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:187 | type 'refill_fsm_e' must be named <name>_type_def |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:187 | enum member 'REFILL_IDLE' must be ENUM_<FUNCTION>_<VALUE> in uppercase |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:187 | enum member 'REFILL_WRITE' must be ENUM_<FUNCTION>_<VALUE> in uppercase |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:187 | enum member 'REFILL_WRITE_DIR' must be ENUM_<FUNCTION>_<VALUE> in uppercase |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:187 | enum member 'REFILL_INVAL' must be ENUM_<FUNCTION>_<VALUE> in uppercase |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:291 | combinational signal 'mshr_alloc_ready_o' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:347 | assigned signal 'coh_own_req_id_o' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:348 | assigned signal 'coh_own_req_nline_o' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:349 | assigned signal 'coh_own_req_kind_o' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:350 | assigned signal 'coh_gnt_match' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:352 | assigned signal 'coh_gnt_state_valid' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:357 | localparam 'REFILL_REQ_SIZE' must be LPARA_<UPPERCASE> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:358 | localparam 'REFILL_REQ_LEN' must be LPARA_<UPPERCASE> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:360 | assigned signal 'mem_req_o' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:361 | assigned signal 'mem_req_o' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:362 | assigned signal 'mem_req_o' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:363 | assigned signal 'mem_req_o' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:364 | assigned signal 'mem_req_o' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:365 | assigned signal 'mem_req_o' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:369 | assigned signal 'mem_req_o' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:372 | assigned signal 'mem_req_o' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:375 | assigned signal 'mem_req_o' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:377 | assigned signal 'mem_req_o' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:380 | process label 'miss_req_fsm_internal_ff' must start with p_ff_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:383 | sequential state 'mshr_alloc_way_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:384 | sequential state 'mshr_alloc_nline_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:385 | sequential state 'mshr_alloc_exclusive_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:386 | sequential state 'coh_refill_exclusive_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:387 | sequential state 'coh_error_beat_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:390 | sequential state 'mshr_alloc_way_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:391 | sequential state 'mshr_alloc_nline_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:392 | sequential state 'mshr_alloc_exclusive_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:396 | sequential state 'coh_refill_exclusive_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:400 | sequential state 'coh_refill_exclusive_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:404 | sequential state 'coh_error_beat_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:408 | sequential state 'coh_error_beat_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:410 | sequential state 'coh_error_beat_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:416 | process label 'miss_req_fsm_ff' must start with p_ff_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:419 | sequential state 'miss_req_fsm_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:421 | sequential state 'miss_req_fsm_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:430 | assigned signal 'refill_req_valid_o' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:432 | process label 'miss_resp_fsm_comb' must start with p_com_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:433 | combinational signal 'refill_updt_sel_victim_o' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:636 | assigned signal 'refill_is_error_o' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:638 | assigned signal 'refill_busy_o' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:639 | assigned signal 'refill_nline_o' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:640 | assigned signal 'refill_word_o' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:644 | assigned signal 'probe_line_busy_o' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:648 | assigned signal 'inval_nline_o' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:650 | assigned signal 'mshr_check_tag' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:651 | assigned signal 'mshr_check_set' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:655 | assigned signal 'mshr_ack_set' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:657 | assigned signal 'mshr_ack_way' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:660 | assigned signal 'mshr_ack_way' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:664 | assigned signal 'mshr_ack_set' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:666 | assigned signal 'mshr_ack_way' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:668 | assigned signal 'mshr_ack_way' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:674 | assigned signal 'refill_dir_entry_o' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:685 | assigned signal 'refill_core_rsp' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:686 | assigned signal 'refill_core_rsp' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:687 | assigned signal 'refill_core_rsp' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:688 | assigned signal 'refill_core_rsp' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:689 | assigned signal 'refill_core_rsp' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:720 | assigned signal 'refill_core_rsp_rdata' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:725 | assigned signal 'refill_fifo_resp_meta_wdata' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:774 | assigned signal 'clean_data' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:781 | assigned signal 'dirty_be' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:782 | assigned signal 'dirty_data' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:795 | combinational signal 'v_current_rsp' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:801 | assigned signal 'dirty_sel' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:803 | assigned signal 'refill_data' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:805 | assigned signal 'refill_data_o' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:809 | assigned signal 'refill_data_o' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:813 | assigned signal 'refill_fifo_resp_data_w' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:818 | assigned signal 'refill_fifo_resp_meta_w' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:824 | combinational signal 'mem_resp_src' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:842 | combinational signal 'mem_resp_src_ready' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:855 | process label 'miss_resp_fsm_ff' must start with p_ff_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:858 | sequential state 'refill_fsm_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:860 | sequential state 'refill_fsm_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:864 | process label 'miss_resp_fsm_internal_ff' must start with p_ff_ |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:867 | sequential state 'refill_set_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:868 | sequential state 'refill_way_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:869 | sequential state 'refill_tag_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:870 | sequential state 'refill_sid_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:871 | sequential state 'refill_tid_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:872 | sequential state 'refill_need_rsp_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:873 | sequential state 'refill_is_prefetch_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:874 | sequential state 'refill_wback_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:875 | sequential state 'refill_dirty_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:876 | sequential state 'refill_dirty_wdata_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:877 | sequential state 'refill_dirty_be_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:878 | sequential state 'refill_core_rsp_word_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:879 | sequential state 'refill_cnt_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:882 | sequential state 'refill_set_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:883 | sequential state 'refill_way_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:884 | sequential state 'refill_tag_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:885 | sequential state 'refill_sid_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:886 | sequential state 'refill_tid_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:887 | sequential state 'refill_need_rsp_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:888 | sequential state 'refill_is_prefetch_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:889 | sequential state 'refill_wback_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:890 | sequential state 'refill_dirty_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:891 | sequential state 'refill_dirty_wdata_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:892 | sequential state 'refill_dirty_be_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:893 | sequential state 'refill_core_rsp_word_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:895 | sequential state 'refill_cnt_q' must be named reg_<name> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:979 | assigned signal 'mshr_empty_o' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:987 | assigned signal 'cbuf_alloc' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:988 | assigned signal 'cbuf_ack' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:1011 | assigned signal 'mshr_alloc_cbuf_id' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:1012 | assigned signal 'mshr_alloc_cbuf_full_o' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:1013 | assigned signal 'mshr_ack_wdata' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:1014 | assigned signal 'mshr_ack_be' must be named w_<name> (or be an o_ port) |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:1021 | localparam 'REFILL_MEM_WORDS' must be LPARA_<UPPERCASE> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:1023 | localparam 'REFILL_FIFO_WORDS_PER_ENTRY' must be LPARA_<UPPERCASE> |
| ERROR | NAM-TBL | hpdcache_miss_handler.sv:1025 | localparam 'REFILL_FIFO_WORDS' must be LPARA_<UPPERCASE> |
| ERROR | P11 | hpdcache_miss_handler.sv:37 | package / import / interface in design RTL |
| ERROR | P14 | hpdcache_miss_handler.sv:630 | system task $error is for verification sources only |
| ERROR | P14 | hpdcache_miss_handler.sv:1029 | system task $fatal is for verification sources only |
| ERROR | P19 | hpdcache_miss_handler.sv:630 | SVA construct in the RTL source set |
| ERROR | P26 | hpdcache_miss_handler.sv:175 | hierarchical reference 'HPDcacheCfg.u' |
| ERROR | P26 | hpdcache_miss_handler.sv:176 | hierarchical reference 'HPDcacheCfg.u' |
| ERROR | P26 | hpdcache_miss_handler.sv:177 | hierarchical reference 'HPDcacheCfg.u' |
| ERROR | P26 | hpdcache_miss_handler.sv:178 | hierarchical reference 'HPDcacheCfg.u' |
| ERROR | P26 | hpdcache_miss_handler.sv:202 | hierarchical reference 'HPDcacheCfg.mshrWayWidth' |
| ERROR | P26 | hpdcache_miss_handler.sv:203 | hierarchical reference 'HPDcacheCfg.mshrSetWidth' |
| ERROR | P26 | hpdcache_miss_handler.sv:205 | hierarchical reference 'HPDcacheCfg.cbufEntryWidth' |
| ERROR | P26 | hpdcache_miss_handler.sv:214 | hierarchical reference 'HPDcacheCfg.u' |
| ERROR | P26 | hpdcache_miss_handler.sv:223 | hierarchical reference 'HPDcacheCfg.clWordIdxWidth' |
| ERROR | P26 | hpdcache_miss_handler.sv:337 | hierarchical reference 'mem_resp_src.mem_resp_r_last' |
| ERROR | P26 | hpdcache_miss_handler.sv:347 | hierarchical reference 'mem_req_o.mem_req_id' |
| ERROR | P26 | hpdcache_miss_handler.sv:357 | hierarchical reference 'HPDcacheCfg.u' |
| ERROR | P26 | hpdcache_miss_handler.sv:358 | hierarchical reference 'HPDcacheCfg.clWidth' |
| ERROR | P26 | hpdcache_miss_handler.sv:358 | hierarchical reference 'HPDcacheCfg.u' |
| ERROR | P26 | hpdcache_miss_handler.sv:360 | hierarchical reference 'mem_req_o.mem_req_addr' |
| ERROR | P26 | hpdcache_miss_handler.sv:360 | hierarchical reference 'HPDcacheCfg.clOffsetWidth' |
| ERROR | P26 | hpdcache_miss_handler.sv:361 | hierarchical reference 'mem_req_o.mem_req_len' |
| ERROR | P26 | hpdcache_miss_handler.sv:362 | hierarchical reference 'mem_req_o.mem_req_size' |
| ERROR | P26 | hpdcache_miss_handler.sv:363 | hierarchical reference 'mem_req_o.mem_req_command' |
| ERROR | P26 | hpdcache_miss_handler.sv:364 | hierarchical reference 'mem_req_o.mem_req_atomic' |
| ERROR | P26 | hpdcache_miss_handler.sv:365 | hierarchical reference 'mem_req_o.mem_req_cacheable' |
| ERROR | P26 | hpdcache_miss_handler.sv:367 | hierarchical reference 'HPDcacheCfg.u' |
| ERROR | P26 | hpdcache_miss_handler.sv:367 | hierarchical reference 'HPDcacheCfg.u' |
| ERROR | P26 | hpdcache_miss_handler.sv:369 | hierarchical reference 'mem_req_o.mem_req_id' |
| ERROR | P26 | hpdcache_miss_handler.sv:370 | hierarchical reference 'HPDcacheCfg.mshrSetWidth' |
| ERROR | P26 | hpdcache_miss_handler.sv:371 | hierarchical reference 'HPDcacheCfg.u' |
| ERROR | P26 | hpdcache_miss_handler.sv:372 | hierarchical reference 'mem_req_o.mem_req_id' |
| ERROR | P26 | hpdcache_miss_handler.sv:373 | hierarchical reference 'HPDcacheCfg.mshrSetWidth' |
| ERROR | P26 | hpdcache_miss_handler.sv:374 | hierarchical reference 'HPDcacheCfg.u' |
| ERROR | P26 | hpdcache_miss_handler.sv:375 | hierarchical reference 'mem_req_o.mem_req_id' |
| ERROR | P26 | hpdcache_miss_handler.sv:377 | hierarchical reference 'mem_req_o.mem_req_id' |
| ERROR | P26 | hpdcache_miss_handler.sv:396 | hierarchical reference 'mem_req_o.mem_req_id' |
| ERROR | P26 | hpdcache_miss_handler.sv:400 | hierarchical reference 'mem_resp_src.mem_resp_r_id' |
| ERROR | P26 | hpdcache_miss_handler.sv:407 | hierarchical reference 'mem_resp_src.mem_resp_r_last' |
| ERROR | P26 | hpdcache_miss_handler.sv:472 | hierarchical reference 'refill_fifo_resp_meta_rdata.is_inval' |
| ERROR | P26 | hpdcache_miss_handler.sv:478 | hierarchical reference 'refill_fifo_resp_meta_rdata.is_inval' |
| ERROR | P26 | hpdcache_miss_handler.sv:485 | hierarchical reference 'refill_fifo_resp_meta_rdata.is_inval' |
| ERROR | P26 | hpdcache_miss_handler.sv:504 | hierarchical reference 'HPDcacheCfg.u' |
| ERROR | P26 | hpdcache_miss_handler.sv:515 | hierarchical reference 'HPDcacheCfg.u' |
| ERROR | P26 | hpdcache_miss_handler.sv:520 | hierarchical reference 'HPDcacheCfg.u' |
| ERROR | P26 | hpdcache_miss_handler.sv:521 | hierarchical reference 'HPDcacheCfg.u' |
| ERROR | P26 | hpdcache_miss_handler.sv:532 | hierarchical reference 'HPDcacheCfg.u' |
| ERROR | P26 | hpdcache_miss_handler.sv:557 | hierarchical reference 'HPDcacheCfg.u' |
| ERROR | P26 | hpdcache_miss_handler.sv:636 | hierarchical reference 'refill_fifo_resp_meta_rdata.r_error' |
| ERROR | P26 | hpdcache_miss_handler.sv:648 | hierarchical reference 'refill_fifo_resp_meta_rdata.inval_nline' |
| ERROR | P26 | hpdcache_miss_handler.sv:650 | hierarchical reference 'HPDcacheCfg.setWidth' |
| ERROR | P26 | hpdcache_miss_handler.sv:650 | hierarchical reference 'HPDcacheCfg.tagWidth' |
| ERROR | P26 | hpdcache_miss_handler.sv:651 | hierarchical reference 'HPDcacheCfg.clOffsetWidth' |
| ERROR | P26 | hpdcache_miss_handler.sv:651 | hierarchical reference 'HPDcacheCfg.setWidth' |
| ERROR | P26 | hpdcache_miss_handler.sv:653 | hierarchical reference 'HPDcacheCfg.u' |
| ERROR | P26 | hpdcache_miss_handler.sv:655 | hierarchical reference 'refill_fifo_resp_meta_rdata.r_id' |
| ERROR | P26 | hpdcache_miss_handler.sv:655 | hierarchical reference 'HPDcacheCfg.mshrSetWidth' |
| ERROR | P26 | hpdcache_miss_handler.sv:656 | hierarchical reference 'HPDcacheCfg.u' |
| ERROR | P26 | hpdcache_miss_handler.sv:657 | hierarchical reference 'refill_fifo_resp_meta_rdata.r_id' |
| ERROR | P26 | hpdcache_miss_handler.sv:657 | hierarchical reference 'HPDcacheCfg.mshrSetWidth' |
| ERROR | P26 | hpdcache_miss_handler.sv:658 | hierarchical reference 'HPDcacheCfg.mshrWayWidth' |
| ERROR | P26 | hpdcache_miss_handler.sv:665 | hierarchical reference 'HPDcacheCfg.u' |
| ERROR | P26 | hpdcache_miss_handler.sv:666 | hierarchical reference 'refill_fifo_resp_meta_rdata.r_id' |
| ERROR | P26 | hpdcache_miss_handler.sv:666 | hierarchical reference 'HPDcacheCfg.mshrWayWidth' |
| ERROR | P26 | hpdcache_miss_handler.sv:678 | hierarchical reference 'refill_fifo_resp_meta_rdata.exclusive' |
| ERROR | P26 | hpdcache_miss_handler.sv:685 | hierarchical reference 'refill_core_rsp.rdata' |
| ERROR | P26 | hpdcache_miss_handler.sv:686 | hierarchical reference 'refill_core_rsp.sid' |
| ERROR | P26 | hpdcache_miss_handler.sv:687 | hierarchical reference 'refill_core_rsp.tid' |
| ERROR | P26 | hpdcache_miss_handler.sv:688 | hierarchical reference 'refill_core_rsp.error' |
| ERROR | P26 | hpdcache_miss_handler.sv:689 | hierarchical reference 'refill_core_rsp.aborted' |
| ERROR | P26 | hpdcache_miss_handler.sv:693 | hierarchical reference 'HPDcacheCfg.u' |
| ERROR | P26 | hpdcache_miss_handler.sv:710 | hierarchical reference 'HPDcacheCfg.reqDataWidth' |
| ERROR | P26 | hpdcache_miss_handler.sv:726 | hierarchical reference 'mem_resp_src.mem_resp_r_error' |
| ERROR | P26 | hpdcache_miss_handler.sv:727 | hierarchical reference 'mem_resp_src.mem_resp_r_id' |
| ERROR | P26 | hpdcache_miss_handler.sv:730 | hierarchical reference 'mem_resp_src.mem_resp_r_id' |
| ERROR | P26 | hpdcache_miss_handler.sv:734 | hierarchical reference 'HPDcacheCfg.u' |
| ERROR | P26 | hpdcache_miss_handler.sv:750 | hierarchical reference 'HPDcacheCfg.u' |
| ERROR | P26 | hpdcache_miss_handler.sv:751 | hierarchical reference 'HPDcacheCfg.accessWidth' |
| ERROR | P26 | hpdcache_miss_handler.sv:752 | hierarchical reference 'HPDcacheCfg.u' |
| ERROR | P26 | hpdcache_miss_handler.sv:759 | hierarchical reference 'mem_resp_src.mem_resp_r_data' |
| ERROR | P26 | hpdcache_miss_handler.sv:760 | hierarchical reference 'mem_resp_src.mem_resp_r_last' |
| ERROR | P26 | hpdcache_miss_handler.sv:772 | hierarchical reference 'HPDcacheCfg.accessBytes' |
| ERROR | P26 | hpdcache_miss_handler.sv:776 | hierarchical reference 'HPDcacheCfg.u' |
| ERROR | P26 | hpdcache_miss_handler.sv:777 | hierarchical reference 'HPDcacheCfg.accessBytes' |
| ERROR | P26 | hpdcache_miss_handler.sv:778 | hierarchical reference 'HPDcacheCfg.accessBytes' |
| ERROR | P26 | hpdcache_miss_handler.sv:779 | hierarchical reference 'HPDcacheCfg.accessBytes' |
| ERROR | P26 | hpdcache_miss_handler.sv:785 | hierarchical reference 'HPDcacheCfg.accessBytes' |
| ERROR | P26 | hpdcache_miss_handler.sv:795 | hierarchical reference 'HPDcacheCfg.reqDataBytes' |
| ERROR | P26 | hpdcache_miss_handler.sv:814 | hierarchical reference 'mem_resp_src.mem_resp_r_last' |
| ERROR | P26 | hpdcache_miss_handler.sv:819 | hierarchical reference 'mem_resp_src.mem_resp_r_last' |
| ERROR | P26 | hpdcache_miss_handler.sv:831 | hierarchical reference 'mem_resp_src.mem_resp_r_error' |
| ERROR | P26 | hpdcache_miss_handler.sv:832 | hierarchical reference 'mem_resp_src.mem_resp_r_id' |
| ERROR | P26 | hpdcache_miss_handler.sv:832 | hierarchical reference 'mem_req_o.mem_req_id' |
| ERROR | P26 | hpdcache_miss_handler.sv:833 | hierarchical reference 'mem_resp_src.mem_resp_r_last' |
| ERROR | P26 | hpdcache_miss_handler.sv:848 | hierarchical reference 'mem_resp_src.mem_resp_r_last' |
| ERROR | P26 | hpdcache_miss_handler.sv:965 | hierarchical reference 'HPDcacheCfg.u' |
| ERROR | P26 | hpdcache_miss_handler.sv:970 | hierarchical reference 'HPDcacheCfg.wayIndexWidth' |
| ERROR | P26 | hpdcache_miss_handler.sv:984 | hierarchical reference 'HPDcacheCfg.u' |
| ERROR | P26 | hpdcache_miss_handler.sv:1022 | hierarchical reference 'HPDcacheCfg.u' |
| ERROR | P26 | hpdcache_miss_handler.sv:1022 | hierarchical reference 'HPDcacheCfg.u' |
| ERROR | P26 | hpdcache_miss_handler.sv:1024 | hierarchical reference 'HPDcacheCfg.u' |
| ERROR | P26 | hpdcache_miss_handler.sv:1026 | hierarchical reference 'HPDcacheCfg.u' |
| ERROR | P26 | hpdcache_miss_handler.sv:1028 | hierarchical reference 'HPDcacheCfg.u' |
| ERROR | PAR-01 | hpdcache_miss_handler.sv:42 | parameter 'HPDcacheCfg' must be declared 'parameter logic [31:0] PARA_<NAME>' |
| ERROR | PAR-01 | hpdcache_miss_handler.sv:44 | parameter 'hpdcache_nline_t' must be declared 'parameter logic [31:0] PARA_<NAME>' |
| ERROR | PAR-01 | hpdcache_miss_handler.sv:45 | parameter 'hpdcache_set_t' must be declared 'parameter logic [31:0] PARA_<NAME>' |
| ERROR | PAR-01 | hpdcache_miss_handler.sv:46 | parameter 'hpdcache_tag_t' must be declared 'parameter logic [31:0] PARA_<NAME>' |
| ERROR | PAR-01 | hpdcache_miss_handler.sv:47 | parameter 'hpdcache_word_t' must be declared 'parameter logic [31:0] PARA_<NAME>' |
| ERROR | PAR-01 | hpdcache_miss_handler.sv:49 | parameter 'hpdcache_way_vector_t' must be declared 'parameter logic [31:0] PARA_<NAME>' |
| ERROR | PAR-01 | hpdcache_miss_handler.sv:50 | parameter 'hpdcache_way_t' must be declared 'parameter logic [31:0] PARA_<NAME>' |
| ERROR | PAR-01 | hpdcache_miss_handler.sv:52 | parameter 'hpdcache_dir_entry_t' must be declared 'parameter logic [31:0] PARA_<NAME>' |
| ERROR | PAR-01 | hpdcache_miss_handler.sv:54 | parameter 'hpdcache_refill_data_t' must be declared 'parameter logic [31:0] PARA_<NAME>' |
| ERROR | PAR-01 | hpdcache_miss_handler.sv:56 | parameter 'hpdcache_req_data_t' must be declared 'parameter logic [31:0] PARA_<NAME>' |
| ERROR | PAR-01 | hpdcache_miss_handler.sv:57 | parameter 'hpdcache_req_be_t' must be declared 'parameter logic [31:0] PARA_<NAME>' |
| ERROR | PAR-01 | hpdcache_miss_handler.sv:58 | parameter 'hpdcache_req_offset_t' must be declared 'parameter logic [31:0] PARA_<NAME>' |
| ERROR | PAR-01 | hpdcache_miss_handler.sv:59 | parameter 'hpdcache_req_sid_t' must be declared 'parameter logic [31:0] PARA_<NAME>' |
| ERROR | PAR-01 | hpdcache_miss_handler.sv:60 | parameter 'hpdcache_req_tid_t' must be declared 'parameter logic [31:0] PARA_<NAME>' |
| ERROR | PAR-01 | hpdcache_miss_handler.sv:62 | parameter 'hpdcache_req_t' must be declared 'parameter logic [31:0] PARA_<NAME>' |
| ERROR | PAR-01 | hpdcache_miss_handler.sv:63 | parameter 'hpdcache_rsp_t' must be declared 'parameter logic [31:0] PARA_<NAME>' |
| ERROR | PAR-01 | hpdcache_miss_handler.sv:65 | parameter 'hpdcache_mem_id_t' must be declared 'parameter logic [31:0] PARA_<NAME>' |
| ERROR | PAR-01 | hpdcache_miss_handler.sv:66 | parameter 'hpdcache_mem_req_t' must be declared 'parameter logic [31:0] PARA_<NAME>' |
| ERROR | PAR-01 | hpdcache_miss_handler.sv:67 | parameter 'hpdcache_mem_resp_r_t' must be declared 'parameter logic [31:0] PARA_<NAME>' |
| ERROR | PAR-01 | hpdcache_miss_handler.sv:175 | localparam 'REFILL_REQ_RATIO' must be declared 'localparam logic [31:0] LPARA_<NAME>' |
| ERROR | PAR-01 | hpdcache_miss_handler.sv:175 | localparam 'REFILL_REQ_RATIO' must be in the parameter port list, directly after the parameters |
| ERROR | PAR-01 | hpdcache_miss_handler.sv:177 | localparam 'REFILL_LAST_CHUNK_WORD' must be declared 'localparam logic [31:0] LPARA_<NAME>' |
| ERROR | PAR-01 | hpdcache_miss_handler.sv:177 | localparam 'REFILL_LAST_CHUNK_WORD' must be in the parameter port list, directly after the parameters |
| ERROR | PAR-01 | hpdcache_miss_handler.sv:357 | localparam 'REFILL_REQ_SIZE' must be declared 'localparam logic [31:0] LPARA_<NAME>' |
| ERROR | PAR-01 | hpdcache_miss_handler.sv:357 | localparam 'REFILL_REQ_SIZE' must be in the parameter port list, directly after the parameters |
| ERROR | PAR-01 | hpdcache_miss_handler.sv:358 | localparam 'REFILL_REQ_LEN' must be declared 'localparam logic [31:0] LPARA_<NAME>' |
| ERROR | PAR-01 | hpdcache_miss_handler.sv:358 | localparam 'REFILL_REQ_LEN' must be in the parameter port list, directly after the parameters |
| ERROR | PAR-01 | hpdcache_miss_handler.sv:1021 | localparam 'REFILL_MEM_WORDS' must be declared 'localparam logic [31:0] LPARA_<NAME>' |
| ERROR | PAR-01 | hpdcache_miss_handler.sv:1021 | localparam 'REFILL_MEM_WORDS' must be in the parameter port list, directly after the parameters |
| ERROR | PAR-01 | hpdcache_miss_handler.sv:1023 | localparam 'REFILL_FIFO_WORDS_PER_ENTRY' must be declared 'localparam logic [31:0] LPARA_<NAME>' |
| ERROR | PAR-01 | hpdcache_miss_handler.sv:1023 | localparam 'REFILL_FIFO_WORDS_PER_ENTRY' must be in the parameter port list, directly after the parameters |
| ERROR | PAR-01 | hpdcache_miss_handler.sv:1025 | localparam 'REFILL_FIFO_WORDS' must be declared 'localparam logic [31:0] LPARA_<NAME>' |
| ERROR | PAR-01 | hpdcache_miss_handler.sv:1025 | localparam 'REFILL_FIFO_WORDS' must be in the parameter port list, directly after the parameters |
| ERROR | PAR-02 | hpdcache_miss_handler.sv:42 | 'HPDcacheCfg' needs the three comment lines 'Parameter Description:', 'Parameter values:', 'Parameter unit:' immediately above it, in that order |
| ERROR | PAR-02 | hpdcache_miss_handler.sv:44 | 'hpdcache_nline_t' needs the three comment lines 'Parameter Description:', 'Parameter values:', 'Parameter unit:' immediately above it, in that order |
| ERROR | PAR-02 | hpdcache_miss_handler.sv:45 | 'hpdcache_set_t' needs the three comment lines 'Parameter Description:', 'Parameter values:', 'Parameter unit:' immediately above it, in that order |
| ERROR | PAR-02 | hpdcache_miss_handler.sv:46 | 'hpdcache_tag_t' needs the three comment lines 'Parameter Description:', 'Parameter values:', 'Parameter unit:' immediately above it, in that order |
| ERROR | PAR-02 | hpdcache_miss_handler.sv:47 | 'hpdcache_word_t' needs the three comment lines 'Parameter Description:', 'Parameter values:', 'Parameter unit:' immediately above it, in that order |
| ERROR | PAR-02 | hpdcache_miss_handler.sv:49 | 'hpdcache_way_vector_t' needs the three comment lines 'Parameter Description:', 'Parameter values:', 'Parameter unit:' immediately above it, in that order |
| ERROR | PAR-02 | hpdcache_miss_handler.sv:50 | 'hpdcache_way_t' needs the three comment lines 'Parameter Description:', 'Parameter values:', 'Parameter unit:' immediately above it, in that order |
| ERROR | PAR-02 | hpdcache_miss_handler.sv:52 | 'hpdcache_dir_entry_t' needs the three comment lines 'Parameter Description:', 'Parameter values:', 'Parameter unit:' immediately above it, in that order |
| ERROR | PAR-02 | hpdcache_miss_handler.sv:54 | 'hpdcache_refill_data_t' needs the three comment lines 'Parameter Description:', 'Parameter values:', 'Parameter unit:' immediately above it, in that order |
| ERROR | PAR-02 | hpdcache_miss_handler.sv:56 | 'hpdcache_req_data_t' needs the three comment lines 'Parameter Description:', 'Parameter values:', 'Parameter unit:' immediately above it, in that order |
| ERROR | PAR-02 | hpdcache_miss_handler.sv:57 | 'hpdcache_req_be_t' needs the three comment lines 'Parameter Description:', 'Parameter values:', 'Parameter unit:' immediately above it, in that order |
| ERROR | PAR-02 | hpdcache_miss_handler.sv:58 | 'hpdcache_req_offset_t' needs the three comment lines 'Parameter Description:', 'Parameter values:', 'Parameter unit:' immediately above it, in that order |
| ERROR | PAR-02 | hpdcache_miss_handler.sv:59 | 'hpdcache_req_sid_t' needs the three comment lines 'Parameter Description:', 'Parameter values:', 'Parameter unit:' immediately above it, in that order |
| ERROR | PAR-02 | hpdcache_miss_handler.sv:60 | 'hpdcache_req_tid_t' needs the three comment lines 'Parameter Description:', 'Parameter values:', 'Parameter unit:' immediately above it, in that order |
| ERROR | PAR-02 | hpdcache_miss_handler.sv:62 | 'hpdcache_req_t' needs the three comment lines 'Parameter Description:', 'Parameter values:', 'Parameter unit:' immediately above it, in that order |
| ERROR | PAR-02 | hpdcache_miss_handler.sv:63 | 'hpdcache_rsp_t' needs the three comment lines 'Parameter Description:', 'Parameter values:', 'Parameter unit:' immediately above it, in that order |
| ERROR | PAR-02 | hpdcache_miss_handler.sv:65 | 'hpdcache_mem_id_t' needs the three comment lines 'Parameter Description:', 'Parameter values:', 'Parameter unit:' immediately above it, in that order |
| ERROR | PAR-02 | hpdcache_miss_handler.sv:66 | 'hpdcache_mem_req_t' needs the three comment lines 'Parameter Description:', 'Parameter values:', 'Parameter unit:' immediately above it, in that order |
| ERROR | PAR-02 | hpdcache_miss_handler.sv:67 | 'hpdcache_mem_resp_r_t' needs the three comment lines 'Parameter Description:', 'Parameter values:', 'Parameter unit:' immediately above it, in that order |
| ERROR | SEC-8.1 | hpdcache_miss_handler.sv:1 | `timescale 1ns/1ps is missing (section 8.1) |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:74 | input port 'clk_i' must be declared 'input wire' (found 'logic') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:75 | input port 'rst_ni' must be declared 'input wire' (found 'logic') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:85 | input port 'cfg_prefetch_updt_sel_victim_i' must be declared 'input wire' (found 'logic') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:90 | input port 'mshr_check_i' must be declared 'input wire' (found 'logic') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:91 | input port 'mshr_check_offset_i' must be declared 'input wire' (found 'hpdcache_req_offset_t') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:92 | input port 'mshr_check_nline_i' must be declared 'input wire' (found 'hpdcache_nline_t') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:94 | input port 'probe_check_valid_i' must be declared 'input wire' (found 'logic') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:95 | input port 'probe_check_nline_i' must be declared 'input wire' (found 'hpdcache_nline_t') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:103 | input port 'mshr_alloc_i' must be declared 'input wire' (found 'logic') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:104 | input port 'mshr_alloc_cs_i' must be declared 'input wire' (found 'logic') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:105 | input port 'mshr_alloc_nline_i' must be declared 'input wire' (found 'hpdcache_nline_t') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:108 | input port 'mshr_alloc_tid_i' must be declared 'input wire' (found 'hpdcache_req_tid_t') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:109 | input port 'mshr_alloc_sid_i' must be declared 'input wire' (found 'hpdcache_req_sid_t') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:110 | input port 'mshr_alloc_word_i' must be declared 'input wire' (found 'hpdcache_word_t') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:111 | input port 'mshr_alloc_victim_way_i' must be declared 'input wire' (found 'hpdcache_way_vector_t') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:112 | input port 'mshr_alloc_need_rsp_i' must be declared 'input wire' (found 'logic') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:113 | input port 'mshr_alloc_is_prefetch_i' must be declared 'input wire' (found 'logic') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:114 | input port 'mshr_alloc_wback_i' must be declared 'input wire' (found 'logic') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:115 | input port 'mshr_alloc_dirty_i' must be declared 'input wire' (found 'logic') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:116 | input port 'mshr_alloc_wdata_i' must be declared 'input wire' (found 'hpdcache_req_data_t') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:117 | input port 'mshr_alloc_be_i' must be declared 'input wire' (found 'hpdcache_req_be_t') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:120 | input port 'refill_req_ready_i' must be declared 'input wire' (found 'logic') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:125 | output port 'refill_set_o' must be declared 'output logic' (found 'hpdcache_set_t') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:126 | output port 'refill_way_o' must be declared 'output logic' (found 'hpdcache_way_vector_t') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:127 | output port 'refill_dir_entry_o' must be declared 'output logic' (found 'hpdcache_dir_entry_t') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:130 | output port 'refill_data_o' must be declared 'output logic' (found 'hpdcache_refill_data_t') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:131 | output port 'refill_word_o' must be declared 'output logic' (found 'hpdcache_word_t') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:132 | output port 'refill_nline_o' must be declared 'output logic' (found 'hpdcache_nline_t') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:137 | output port 'inval_nline_o' must be declared 'output logic' (found 'hpdcache_nline_t') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:138 | input port 'inval_hit_i' must be declared 'input wire' (found 'logic') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:142 | output port 'refill_core_rsp_o' must be declared 'output logic' (found 'hpdcache_rsp_t') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:147 | input port 'mem_req_ready_i' must be declared 'input wire' (found 'logic') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:149 | output port 'mem_req_o' must be declared 'output logic' (found 'hpdcache_mem_req_t') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:152 | input port 'mem_resp_valid_i' must be declared 'input wire' (found 'logic') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:153 | input port 'mem_resp_i' must be declared 'input wire' (found 'hpdcache_mem_resp_r_t') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:154 | input port 'mem_resp_inval_i' must be declared 'input wire' (found 'logic') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:155 | input port 'mem_resp_inval_nline_i' must be declared 'input wire' (found 'hpdcache_nline_t') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:159 | input port 'coh_own_req_ready_i' must be declared 'input wire' (found 'logic') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:161 | output port 'coh_own_req_nline_o' must be declared 'output logic' (found 'hpdcache_nline_t') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:163 | input port 'coh_own_gnt_valid_i' must be declared 'input wire' (found 'logic') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:165 | input port 'coh_own_gnt_id_i' must be declared 'input wire' (found 'logic') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:166 | input port 'coh_own_gnt_nline_i' must be declared 'input wire' (found 'hpdcache_nline_t') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:167 | input port 'coh_own_gnt_state_i' must be declared 'input wire' (found 'logic') |
| ERROR | TYP-02 | hpdcache_miss_handler.sv:168 | input port 'coh_own_gnt_err_i' must be declared 'input wire' (found 'logic') |
| WARN | CMT-01 | hpdcache_miss_handler.sv:352 | no functional comment before this assign group |
| WARN | CMT-01 | hpdcache_miss_handler.sv:360 | no functional comment before this assign group |
| WARN | CMT-01 | hpdcache_miss_handler.sv:369 | no functional comment before this assign group |
| WARN | CMT-01 | hpdcache_miss_handler.sv:372 | no functional comment before this assign group |
| WARN | CMT-01 | hpdcache_miss_handler.sv:375 | no functional comment before this assign group |
| WARN | CMT-01 | hpdcache_miss_handler.sv:377 | no functional comment before this assign group |
| WARN | CMT-01 | hpdcache_miss_handler.sv:380 | no functional comment before this process |
| WARN | CMT-01 | hpdcache_miss_handler.sv:416 | no functional comment before this process |
| WARN | CMT-01 | hpdcache_miss_handler.sv:432 | no functional comment before this process |
| WARN | CMT-01 | hpdcache_miss_handler.sv:636 | no functional comment before this assign group |
| WARN | CMT-01 | hpdcache_miss_handler.sv:638 | no functional comment before this assign group |
| WARN | CMT-01 | hpdcache_miss_handler.sv:648 | no functional comment before this assign group |
| WARN | CMT-01 | hpdcache_miss_handler.sv:650 | no functional comment before this assign group |
| WARN | CMT-01 | hpdcache_miss_handler.sv:657 | no functional comment before this assign group |
| WARN | CMT-01 | hpdcache_miss_handler.sv:660 | no functional comment before this assign group |
| WARN | CMT-01 | hpdcache_miss_handler.sv:666 | no functional comment before this assign group |
| WARN | CMT-01 | hpdcache_miss_handler.sv:668 | no functional comment before this assign group |
| WARN | CMT-01 | hpdcache_miss_handler.sv:685 | no functional comment before this assign group |
| WARN | CMT-01 | hpdcache_miss_handler.sv:720 | no functional comment before this assign group |
| WARN | CMT-01 | hpdcache_miss_handler.sv:774 | no functional comment before this assign group |
| WARN | CMT-01 | hpdcache_miss_handler.sv:781 | no functional comment before this assign group |
| WARN | CMT-01 | hpdcache_miss_handler.sv:793 | no functional comment before this process |
| WARN | CMT-01 | hpdcache_miss_handler.sv:801 | no functional comment before this assign group |
| WARN | CMT-01 | hpdcache_miss_handler.sv:803 | no functional comment before this assign group |
| WARN | CMT-01 | hpdcache_miss_handler.sv:805 | no functional comment before this assign group |
| WARN | CMT-01 | hpdcache_miss_handler.sv:841 | no functional comment before this process |
| WARN | CMT-01 | hpdcache_miss_handler.sv:855 | no functional comment before this process |
| WARN | CMT-01 | hpdcache_miss_handler.sv:864 | no functional comment before this process |
| WARN | CMT-01 | hpdcache_miss_handler.sv:987 | no functional comment before this assign group |
| WARN | CMT-01 | hpdcache_miss_handler.sv:1011 | no functional comment before this assign group |
| WARN | HIE-02 | m_vlsit_riscv_cpu_tile.sv:25 | module has instances and also logic; a structural top should contain instances only (HIE-02) |
| WARN | NAM-08 | hpdcache_miss_handler.sv:122 | port 'refill_is_error_o' spells out 'error'; NAM-08 writes 'err' |
| WARN | NAM-08 | hpdcache_miss_handler.sv:128 | port 'refill_write_dir_o' spells out 'write'; NAM-08 writes 'wr' |
| WARN | NAM-08 | hpdcache_miss_handler.sv:129 | port 'refill_write_data_o' spells out 'write'; NAM-08 writes 'wr' |
| WARN | NAM-08 | hpdcache_miss_handler.sv:136 | port 'inval_write_dir_o' spells out 'write'; NAM-08 writes 'wr' |
| WARN | NAM-08 | hpdcache_miss_handler.sv:179 | enum member 'MISS_REQ_OWN_ERROR' spells out 'error'; NAM-08 writes 'err' |
| WARN | NAM-08 | hpdcache_miss_handler.sv:187 | enum member 'REFILL_WRITE' spells out 'write'; NAM-08 writes 'wr' |
| WARN | NAM-08 | hpdcache_miss_handler.sv:187 | enum member 'REFILL_WRITE_DIR' spells out 'write'; NAM-08 writes 'wr' |
| WARN | NAM-08 | hpdcache_miss_handler.sv:223 | signal 'coh_error_beat_q' spells out 'error'; NAM-08 writes 'err' |
| WARN | NAM-08 | hpdcache_miss_handler.sv:257 | signal 'refill_core_rsp_error' spells out 'error'; NAM-08 writes 'err' |
| WARN | NAM-08 | hpdcache_miss_handler.sv:824 | process label 'p_com_mem_resp_source' spells out 'source'; NAM-08 writes 'src' |
| WARN | NAM-08 | m_vlsit_riscv_cpu_tile.sv:82 | port 'o_dcache_flush_ack_error' spells out 'error'; NAM-08 writes 'err' |
| WARN | NAM-TBL | hpdcache_miss_handler.sv:793 | always_comb without a 'begin : p_com_<function>' label |
| WARN | PAR-03 | hpdcache_miss_handler.sv:182 | literal 3'd2 may be a magic number (P10); name it with a parameter, localparam or enum member |
| WARN | PAR-03 | hpdcache_miss_handler.sv:183 | literal 3'd3 may be a magic number (P10); name it with a parameter, localparam or enum member |
| WARN | PAR-03 | hpdcache_miss_handler.sv:184 | literal 3'd4 may be a magic number (P10); name it with a parameter, localparam or enum member |
| WARN | PAR-03 | hpdcache_miss_handler.sv:353 | literal 2'd3 may be a magic number (P10); name it with a parameter, localparam or enum member |
| WARN | PAR-03 | hpdcache_miss_handler.sv:355 | literal 2'd2 may be a magic number (P10); name it with a parameter, localparam or enum member |
| WARN | PAR-03 | hpdcache_miss_handler.sv:397 | literal 2'd2 may be a magic number (P10); name it with a parameter, localparam or enum member |
| WARN | SEQ-01 | hpdcache_miss_handler.sv:380 | always_ff clock 'clk_i' is not named i_clk_<domain> |
| WARN | SEQ-01 | hpdcache_miss_handler.sv:416 | always_ff clock 'clk_i' is not named i_clk_<domain> |
| WARN | SEQ-01 | hpdcache_miss_handler.sv:855 | always_ff clock 'clk_i' is not named i_clk_<domain> |
| WARN | SEQ-01 | hpdcache_miss_handler.sv:864 | always_ff clock 'clk_i' is not named i_clk_<domain> |

Rules failed: COM-03, COM-07, ENM-01, FIL-01, NAM-07, NAM-TBL, P11, P14, P19, P26, PAR-01, PAR-02, SEC-8.1, TYP-02
Rules warned: CMT-01, HIE-02, NAM-08, PAR-03, SEQ-01
Rules clean: ARI-04, CMT-05, COM-02, COM-04, COM-06, ENM-03, ENM-04, ENM-05, ENM-06, FIL-02, FIL-03, FIL-04, FIL-05, FIL-06, HIE-01, HIE-03, HIE-05, NAM-09, P1, P12, P13, P17, P18, P2, P20, P21, P22, P24, P25, P27, P29, P3, P30, P4, P6, P7, R-019, R-027, R-032, R-035, R-036, R-038, R-071, R-072, SCP-01, TYP-06
