`timescale 1ns/1ps
/*
 *  Copyright 2023,2024 Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA)
 *  Copyright 2025 Univ. Grenoble Alpes, Inria, TIMA Laboratory
 *
 *  SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
 */
/*
 *  Authors       : Cesar Fuguet
 *  Creation Date : April, 2024
 *  Description   : HPDcache Wrapper for Code Linting Check
 *  History       :
 */
/*
 * Directed verification harness for the modified HPDcache ownership/refill path.
 * Derived from the upstream HPDcache lint wrapper; original license notices are preserved.
 * History: 2026-11-14, Quan Nguyen and Codex - VLSI Technology page: add grant-gated refill and Shared-store replay scenarios.
 */
`include "hpdcache_typedef.svh"

module hpdcache_ownership_tb
  import hpdcache_pkg::*;
#(
  localparam int unsigned HPDCACHE_NREQUESTERS = 1,

  localparam hpdcache_pkg::hpdcache_user_cfg_t HPDcacheUserCfg = '{
      nRequesters: HPDCACHE_NREQUESTERS,
      paWidth: 56,
      wordWidth: 64,
      sets: 64,
      ways: 8,
      clWords: 8,
      reqWords: 1,
      reqTransIdWidth: 6,
      reqSrcIdWidth: 3,
      victimSel: hpdcache_pkg::HPDCACHE_VICTIM_RANDOM,
      dataWaysPerRamWord: 2,
      dataSetsPerRam: 64,
      dataRamByteEnable: 1'b1,
      accessWords: 8,
      mshrSets: 32,
      mshrWays: 2,
      mshrWaysPerRamWord: 2,
      mshrSetsPerRam: 32,
      mshrRamByteEnable: 1'b1,
      mshrUseRegbank: 1,
      cbufEntries: 4,
      refillCoreRspFeedthrough: 1'b1,
      refillFifoDepth: 2,
      wbufDirEntries: 16,
      wbufDataEntries: 8,
      wbufWords: 4,
      wbufTimecntWidth: 3,
      rtabEntries: 4,
      flushEntries: 4,
      flushFifoDepth: 2,
      memAddrWidth: 56,
      memIdWidth: 7,
      memDataWidth: 512,
      wtEn: 1'b1,
      wbEn: 1'b1,
      lowLatency: 1'b1,
      eccEn: 1'b0,
      eccScrubberEn: 1'b0
  },

  localparam hpdcache_pkg::hpdcache_cfg_t HPDcacheCfg = hpdcache_pkg::hpdcacheBuildConfig(
      HPDcacheUserCfg
  ),

  localparam type hpdcache_mem_addr_t = logic [HPDcacheCfg.u.memAddrWidth-1:0],
  localparam type hpdcache_mem_id_t = logic [HPDcacheCfg.u.memIdWidth-1:0],
  localparam type hpdcache_mem_data_t = logic [HPDcacheCfg.u.memDataWidth-1:0],
  localparam type hpdcache_mem_be_t = logic [HPDcacheCfg.u.memDataWidth/8-1:0],
  localparam type hpdcache_mem_req_t =
      `HPDCACHE_DECL_MEM_REQ_T(hpdcache_mem_addr_t, hpdcache_mem_id_t),
  localparam type hpdcache_mem_resp_r_t =
      `HPDCACHE_DECL_MEM_RESP_R_T(hpdcache_mem_id_t, hpdcache_mem_data_t),
  localparam type hpdcache_mem_req_w_t =
      `HPDCACHE_DECL_MEM_REQ_W_T(hpdcache_mem_data_t, hpdcache_mem_be_t),
  localparam type hpdcache_mem_resp_w_t =
      `HPDCACHE_DECL_MEM_RESP_W_T(hpdcache_mem_id_t),

  localparam type hpdcache_tag_t = logic [HPDcacheCfg.tagWidth-1:0],
  localparam type hpdcache_data_word_t = logic [HPDcacheCfg.u.wordWidth-1:0],
  localparam type hpdcache_data_be_t = logic [HPDcacheCfg.u.wordWidth/8-1:0],
  localparam type hpdcache_req_offset_t = logic [HPDcacheCfg.reqOffsetWidth-1:0],
  localparam type hpdcache_req_data_t =
      logic [HPDcacheCfg.u.reqWords-1:0][HPDcacheCfg.u.wordWidth-1:0],
  localparam type hpdcache_req_be_t =
      logic [HPDcacheCfg.u.reqWords-1:0][HPDcacheCfg.u.wordWidth/8-1:0],
  localparam type hpdcache_req_sid_t = logic [HPDcacheCfg.u.reqSrcIdWidth-1:0],
  localparam type hpdcache_req_tid_t = logic [HPDcacheCfg.u.reqTransIdWidth-1:0],
  localparam type hpdcache_req_t =
      `HPDCACHE_DECL_REQ_T(hpdcache_req_offset_t,
                           hpdcache_req_data_t,
                           hpdcache_req_be_t,
                           hpdcache_req_sid_t,
                           hpdcache_req_tid_t,
                           hpdcache_tag_t),
  localparam type hpdcache_rsp_t =
      `HPDCACHE_DECL_RSP_T(hpdcache_req_data_t,
                           hpdcache_req_sid_t,
                           hpdcache_req_tid_t),

  localparam type hpdcache_wbuf_timecnt_t = logic [HPDcacheCfg.u.wbufTimecntWidth-1:0],
  localparam type hpdcache_nline_t    = logic [HPDcacheCfg.nlineWidth-1:0]
)

;

   logic                        clk_i;
   logic                        rst_ni;
   logic                        wbuf_flush_i;
  logic                        wbuf_empty_o;
   logic                        core_req_valid_i         [HPDCACHE_NREQUESTERS];
  logic                        core_req_ready_o         [HPDCACHE_NREQUESTERS];
   hpdcache_req_t               core_req_i               [HPDCACHE_NREQUESTERS];
   logic                        core_req_abort_i         [HPDCACHE_NREQUESTERS];
   hpdcache_tag_t               core_req_tag_i           [HPDCACHE_NREQUESTERS];
   hpdcache_pkg::hpdcache_pma_t core_req_pma_i           [HPDCACHE_NREQUESTERS];
  logic                        core_rsp_valid_o         [HPDCACHE_NREQUESTERS];
  hpdcache_rsp_t               core_rsp_o               [HPDCACHE_NREQUESTERS];
   logic                        mem_req_read_ready_i;
  logic                        mem_req_read_valid_o;
  hpdcache_mem_req_t           mem_req_read_o;
  logic                        mem_resp_read_ready_o;
   logic                        mem_resp_read_valid_i;
   hpdcache_mem_resp_r_t        mem_resp_read_i;
   logic                        mem_resp_read_inval_i;
   hpdcache_nline_t             mem_resp_read_inval_nline_i;
   logic                        mem_req_write_ready_i;
  logic                        mem_req_write_valid_o;
  hpdcache_mem_req_t           mem_req_write_o;
   logic                        mem_req_write_data_ready_i;
  logic                        mem_req_write_data_valid_o;
  hpdcache_mem_req_w_t         mem_req_write_data_o;
  logic                        mem_resp_write_ready_o;
   logic                        mem_resp_write_valid_i;
   hpdcache_mem_resp_w_t        mem_resp_write_i;


  hpdcache #(
      .HPDcacheCfg          (HPDcacheCfg),
      .wbuf_timecnt_t       (hpdcache_wbuf_timecnt_t),
      .hpdcache_tag_t       (hpdcache_tag_t),
      .hpdcache_data_word_t (hpdcache_data_word_t),
      .hpdcache_data_be_t   (hpdcache_data_be_t),
      .hpdcache_req_offset_t(hpdcache_req_offset_t),
      .hpdcache_req_data_t  (hpdcache_req_data_t),
      .hpdcache_req_be_t    (hpdcache_req_be_t),
      .hpdcache_req_sid_t   (hpdcache_req_sid_t),
      .hpdcache_req_tid_t   (hpdcache_req_tid_t),
      .hpdcache_req_t       (hpdcache_req_t),
      .hpdcache_rsp_t       (hpdcache_rsp_t),
      .hpdcache_mem_addr_t  (hpdcache_mem_addr_t),
      .hpdcache_mem_id_t    (hpdcache_mem_id_t),
      .hpdcache_mem_data_t  (hpdcache_mem_data_t),
      .hpdcache_mem_be_t    (hpdcache_mem_be_t),
      .hpdcache_mem_req_t   (hpdcache_mem_req_t),
      .hpdcache_mem_req_w_t (hpdcache_mem_req_w_t),
      .hpdcache_mem_resp_r_t(hpdcache_mem_resp_r_t),
      .hpdcache_mem_resp_w_t(hpdcache_mem_resp_w_t)
  ) i_hpdcache (
      .clk_i,
      .rst_ni,

      .wbuf_flush_i,

      .core_req_valid_i,
      .core_req_ready_o,
      .core_req_i,
      .core_req_abort_i,
      .core_req_tag_i,
      .core_req_pma_i,

      .core_rsp_valid_o,
      .core_rsp_o,

      .mem_req_read_ready_i,
      .mem_req_read_valid_o,
      .mem_req_read_o,

      .mem_resp_read_ready_o,
      .mem_resp_read_valid_i,
      .mem_resp_read_i,

      .mem_resp_read_inval_i,
      .mem_resp_read_inval_nline_i,

      .mem_req_write_ready_i,
      .mem_req_write_valid_o,
      .mem_req_write_o,

      .mem_req_write_data_ready_i,
      .mem_req_write_data_valid_o,
      .mem_req_write_data_o,

      .mem_resp_write_ready_o,
      .mem_resp_write_valid_i,
      .mem_resp_write_i,

      .evt_cache_write_miss_o     (/* unused */),
      .evt_cache_read_miss_o      (/* unused */),
      .evt_cache_dir_unc_err_o    (/* unused */),
      .evt_cache_dir_cor_err_o    (/* unused */),
      .evt_cache_dat_unc_err_o    (/* unused */),
      .evt_cache_dat_cor_err_o    (/* unused */),
      .evt_scrub_complete_o       (/* unused */),
      .evt_uncached_req_o         (/* unused */),
      .evt_cmo_req_o              (/* unused */),
      .evt_write_req_o            (/* unused */),
      .evt_read_req_o             (/* unused */),
      .evt_prefetch_req_o         (/* unused */),
      .evt_req_on_hold_o          (/* unused */),
      .evt_rtab_rollback_o        (/* unused */),
      .evt_stall_refill_o         (/* unused */),
      .evt_stall_o                (/* unused */),

      .wbuf_empty_o,

      .cfg_enable_i                       (1'b1),
      .cfg_wbuf_threshold_i               (3'd2),
      .cfg_wbuf_reset_timecnt_on_write_i  (1'b1),
      .cfg_wbuf_sequential_waw_i          (1'b0),
      .cfg_wbuf_inhibit_write_coalescing_i(1'b0),
      .cfg_prefetch_updt_plru_i           (1'b1),
      .cfg_error_on_cacheable_amo_i       (1'b0),
      .cfg_rtab_single_entry_i            (1'b0),
      .cfg_default_wb_i                   (1'b0),
      .cfg_scrub_enable_i                 (1'b0),
      .cfg_scrub_period_i                 (6'd10),
      .cfg_scrub_restart_i                (1'b1),
      .flush_ack_valid_o                (/* unused */),
      .flush_ack_nline_o                (/* unused */),
      .flush_ack_origin_o               (/* unused */),
      .flush_ack_error_o                (/* unused */),
      .flush_rsp_invalid_o              (/* unused */),
      .coh_line_lock_valid_i             ('0),
      .coh_line_lock_nline_i             ('0),
      .coh_probe_req_valid_i             (1'b0),
      .coh_probe_req_tag_i               ('0),
      .coh_probe_req_nline_i             ('0),
      .coh_probe_req_phase_i             ('0),
      .coh_probe_req_target_state_i      ('0),
      .coh_probe_req_wback_en_i          (1'b0),
      .coh_probe_rsp_ready_i             (1'b1),
      .coh_probe_req_ready_o             (/* unused */),
      .coh_probe_rsp_valid_o             (/* unused */),
      .coh_probe_rsp_tag_o               (/* unused */),
      .coh_probe_rsp_nline_o             (/* unused */),
      .coh_probe_rsp_phase_o             (/* unused */),
      .coh_probe_rsp_state_o             (/* unused */),
      .coh_probe_rsp_err_o               (/* unused */),
      .coh_probe_rsp_wback_done_o        (/* unused */),
      .coh_own_req_valid_o               (coh_own_req_valid_tb),
      .coh_own_req_ready_i               (coh_own_req_ready_tb),
      .coh_own_req_id_o                 (coh_own_req_id_tb),
      .coh_own_req_nline_o              (coh_own_req_nline_tb),
      .coh_own_req_kind_o               (coh_own_req_kind_tb),
      .coh_own_gnt_valid_i              (coh_own_gnt_valid_tb),
      .coh_own_gnt_ready_o              (coh_own_gnt_ready_tb),
      .coh_own_gnt_id_i                (coh_own_gnt_id_tb),
      .coh_own_gnt_nline_i             (coh_own_gnt_nline_tb),
      .coh_own_gnt_state_i             (coh_own_gnt_state_tb),
      .coh_own_gnt_err_i               (coh_own_gnt_err_tb),
      .coh_probe_query_valid_i           (1'b0),
      .coh_probe_query_nline_i           ('0),
      .coh_probe_line_busy_o             (/* unused */)
  );


  localparam logic [63:0] TEST_ADDR = 64'h0000_0000_0000_8000;

  logic coh_own_req_ready_tb;
  logic coh_own_req_valid_tb;
  logic [2:0] coh_own_req_id_tb;
  hpdcache_nline_t coh_own_req_nline_tb;
  logic [1:0] coh_own_req_kind_tb;
  logic coh_own_gnt_valid_tb;
  logic coh_own_gnt_ready_tb;
  logic [2:0] coh_own_gnt_id_tb;
  hpdcache_nline_t coh_own_gnt_nline_tb;
  logic [1:0] coh_own_gnt_state_tb;
  logic coh_own_gnt_err_tb;

  always #5 clk_i = ~clk_i;

  task automatic fail(input string message);
    $display("FAIL: %s at time %0t", message, $time);
    $fatal(1);
  endtask

  task automatic wait_own_request(output logic [2:0] request_id,
                                  output hpdcache_nline_t request_nline,
                                  output logic [1:0] request_kind);
    int unsigned cycles;
    cycles = 0;
    while (!coh_own_req_valid_tb && cycles < 300) begin
      @(posedge clk_i);
      #1;
      cycles++;
    end
    if (!coh_own_req_valid_tb) fail("timed out waiting for ownership request");
    request_id = coh_own_req_id_tb;
    request_nline = coh_own_req_nline_tb;
    request_kind = coh_own_req_kind_tb;
  endtask

  task automatic give_grant(input logic [2:0] grant_id,
                            input hpdcache_nline_t grant_nline,
                            input logic [1:0] grant_state);
    int unsigned cycles;
    cycles = 0;
    @(negedge clk_i);
    coh_own_gnt_valid_tb = 1'b1;
    coh_own_gnt_id_tb = grant_id;
    coh_own_gnt_nline_tb = grant_nline;
    coh_own_gnt_state_tb = grant_state;
    coh_own_gnt_err_tb = 1'b0;
    while (!coh_own_gnt_ready_tb && cycles < 100) begin
      @(posedge clk_i);
      cycles++;
    end
    if (!coh_own_gnt_ready_tb) fail("ownership grant was not accepted");
    @(posedge clk_i);
    @(negedge clk_i);
    coh_own_gnt_valid_tb = 1'b0;
  endtask

  task automatic send_core_request(input hpdcache_pkg::hpdcache_req_op_t op,
                                   input logic [63:0] address,
                                   input logic [63:0] write_data);
    int unsigned cycles;
    cycles = 0;
    @(negedge clk_i);
    core_req_i[0] = '0;
    core_req_i[0].addr_offset = hpdcache_req_offset_t'(address);
    core_req_i[0].addr_tag = hpdcache_tag_t'(address >> HPDcacheCfg.reqOffsetWidth);
    core_req_i[0].op = op;
    core_req_i[0].be = '1;
    core_req_i[0].size = 3'd3;
    core_req_i[0].wdata[0] = write_data;
    core_req_i[0].sid = '0;
    core_req_i[0].tid = 6'd1;
    core_req_i[0].need_rsp = 1'b1;
    core_req_i[0].phys_indexed = 1'b1;
    core_req_i[0].pma.uncacheable = 1'b0;
    core_req_i[0].pma.io = 1'b0;
    core_req_i[0].pma.wr_policy_hint = hpdcache_pkg::HPDCACHE_WR_POLICY_WB;
    core_req_tag_i[0] = core_req_i[0].addr_tag;
    core_req_pma_i[0] = core_req_i[0].pma;
    core_req_valid_i[0] = 1'b1;
    while (!core_req_ready_o[0] && cycles < 100) begin
      @(posedge clk_i);
      cycles++;
    end
    if (!core_req_ready_o[0]) fail("core request was not accepted");
    @(posedge clk_i);
    @(negedge clk_i);
    core_req_valid_i[0] = 1'b0;
  endtask

  task automatic accept_refill(input logic [2:0] expected_id);
    int unsigned cycles;
    int unsigned response_wait;
    logic [HPDcacheCfg.u.memIdWidth-1:0] mem_id;
    cycles = 0;
    while (!mem_req_read_valid_o && cycles < 300) begin
      @(posedge clk_i);
      #1;
      cycles++;
    end
    if (!mem_req_read_valid_o) begin
      $display("REFILL_TIMEOUT expected_id=%0d ownership_id=%0d line=%h grant_ready=%b time=%0t",
               expected_id, coh_own_req_id_tb, coh_own_req_nline_tb,
               coh_own_gnt_ready_tb, $time);
      fail("ownership grant did not release refill AR");
    end
    mem_id = mem_req_read_o.mem_req_id;
    if (3'(mem_id) != expected_id) fail("refill memory ID did not match grant ID");
    if (mem_req_read_o.mem_req_command != hpdcache_pkg::HPDCACHE_MEM_READ)
      fail("refill request is not a memory read");
    if (mem_req_read_o.mem_req_addr[HPDcacheCfg.clOffsetWidth-1:0] != '0)
      fail("refill address is not cache-line aligned");
    @(negedge clk_i);
    mem_req_read_ready_i = 1'b1;
    @(posedge clk_i);
    @(negedge clk_i);
    mem_req_read_ready_i = 1'b0;
    mem_resp_read_i = '0;
    mem_resp_read_i.mem_resp_r_id = mem_id;
    mem_resp_read_i.mem_resp_r_error = hpdcache_pkg::HPDCACHE_MEM_RESP_OK;
    mem_resp_read_i.mem_resp_r_data = {16{32'hA5C3_19E7}};
    mem_resp_read_valid_i = 1'b1;
    mem_resp_read_i.mem_resp_r_last = 1'b1;
    response_wait = 0;
    while (!mem_resp_read_ready_o && response_wait < 100) begin
      @(posedge clk_i);
      response_wait++;
    end
    if (!mem_resp_read_ready_o) fail("refill first beat was not accepted");
    @(posedge clk_i);
    @(negedge clk_i);
    mem_resp_read_valid_i = 1'b0;
    mem_resp_read_i = '0;
  endtask

  task automatic wait_core_response;
    int unsigned cycles;
    cycles = 0;
    while (!core_rsp_valid_o[0] && cycles < 500) begin
      @(posedge clk_i);
      #1;
      cycles++;
    end
    if (!core_rsp_valid_o[0]) fail("timed out waiting for core response");
    if (core_rsp_o[0].error) fail("cache request returned an unexpected error");
    @(posedge clk_i);
  endtask

  initial begin : p_test
    logic [2:0] own_id;
    hpdcache_nline_t own_nline;
    logic [1:0] own_kind;
    int unsigned cycle_idx;

    clk_i = 1'b0;
    rst_ni = 1'b0;
    wbuf_flush_i = 1'b0;
    for (int i = 0; i < HPDCACHE_NREQUESTERS; i++) begin
      core_req_valid_i[i] = 1'b0;
      core_req_i[i] = '0;
      core_req_abort_i[i] = 1'b0;
      core_req_tag_i[i] = '0;
      core_req_pma_i[i] = '0;
    end
    mem_req_read_ready_i = 1'b0;
    mem_resp_read_valid_i = 1'b0;
    mem_resp_read_i = '0;
    mem_resp_read_inval_i = 1'b0;
    mem_resp_read_inval_nline_i = '0;
    mem_req_write_ready_i = 1'b1;
    mem_req_write_data_ready_i = 1'b1;
    mem_resp_write_valid_i = 1'b0;
    mem_resp_write_i = '0;
    coh_own_req_ready_tb = 1'b1;
    coh_own_gnt_valid_tb = 1'b0;
    coh_own_gnt_id_tb = '0;
    coh_own_gnt_nline_tb = '0;
    coh_own_gnt_state_tb = '0;
    coh_own_gnt_err_tb = 1'b0;

    repeat (5) @(posedge clk_i);
    @(negedge clk_i);
    rst_ni = 1'b1;
    repeat (5) @(posedge clk_i);

    // Cold cacheable load: ownership must be granted before refill AR.
    send_core_request(hpdcache_pkg::HPDCACHE_REQ_LOAD, TEST_ADDR, '0);
    wait_own_request(own_id, own_nline, own_kind);
    $display("OWN_REQ load id=%0d line=%h kind=%0d time=%0t", own_id, own_nline, own_kind, $time);
    if (own_kind != 2'd0) fail("load miss did not request shared/read ownership");
    for (cycle_idx = 0; cycle_idx < 4; cycle_idx++) begin
      if (mem_req_read_valid_o) fail("refill AR escaped before an ownership grant");
      @(posedge clk_i);
      #1;
    end
    give_grant(own_id, own_nline, 2'd1); // MESI S
    $display("GRANT load state=S ready=%b time=%0t", coh_own_gnt_ready_tb, $time);
    accept_refill(own_id);
    wait_core_response();

    // A write to the clean Shared line must invalidate/replay and request M.
    send_core_request(hpdcache_pkg::HPDCACHE_REQ_STORE, TEST_ADDR,
                      64'h0123_4567_89AB_CDEF);
    wait_own_request(own_id, own_nline, own_kind);
    $display("OWN_REQ shared-store id=%0d line=%h kind=%0d time=%0t", own_id, own_nline, own_kind, $time);
    if (own_kind != 2'd1) fail("Shared store replay did not request exclusive ownership");
    if (mem_req_read_valid_o) fail("Shared store refill escaped before M grant");
    give_grant(own_id, own_nline, 2'd3); // MESI M
    $display("GRANT store state=M ready=%b time=%0t", coh_own_gnt_ready_tb, $time);
    accept_refill(own_id);
    wait_core_response();

    $display("PASS: ownership-gated refill and Shared-store invalidate/replay");
    $finish;
  end

  initial begin : p_global_timeout
    #100000;
    fail("global test timeout");
  end

endmodule
// vim: ts=4 : sts=4 : sw=4 : et : tw=100 : spell : spelllang=en : fdm=marker
