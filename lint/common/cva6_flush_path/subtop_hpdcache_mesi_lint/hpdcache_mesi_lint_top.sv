module m_vlsit_hpdcache_mesi_lint;
  localparam config_pkg::cva6_cfg_t LPARA_CVA6_CFG =
      build_config_pkg::build_config(cva6_config_pkg::cva6_cfg);
  cva6_hpdcache_subsystem #(
    .CVA6Cfg(LPARA_CVA6_CFG)
  ) u_vlsit_hpdcache_subsystem (
    .coh_probe_query_valid_i(1'b0),
    .coh_probe_query_nline_i('0),
    .coh_probe_line_busy_o(),
    .coh_probe_req_valid_i(1'b0),
    .coh_probe_req_tag_i('0),
    .coh_probe_req_nline_i('0),
    .coh_probe_req_phase_i('0),
    .coh_probe_req_target_state_i('0),
    .coh_probe_req_wback_en_i(1'b0),
    .coh_probe_rsp_ready_i(1'b1),
    .coh_probe_req_ready_o(),
    .coh_probe_rsp_valid_o(),
    .coh_probe_rsp_tag_o(),
    .coh_probe_rsp_nline_o(),
    .coh_probe_rsp_phase_o(),
    .coh_probe_rsp_state_o(),
    .coh_probe_rsp_err_o(),
    .coh_probe_rsp_wback_done_o(),
    .coh_own_req_ready_i(1'b1),
    .coh_own_req_valid_o(),
    .coh_own_req_id_o(),
    .coh_own_req_nline_o(),
    .coh_own_req_kind_o(),
    .coh_own_gnt_valid_i(1'b0),
    .coh_own_gnt_ready_o(),
    .coh_own_gnt_id_i('0),
    .coh_own_gnt_nline_i('0),
    .coh_own_gnt_state_i('0),
    .coh_own_gnt_err_i(1'b0)
  );
endmodule
