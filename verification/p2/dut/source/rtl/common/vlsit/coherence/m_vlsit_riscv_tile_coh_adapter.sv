/*
 * Project      : VLSIT RISC-V CPU Cluster
 * Author       : Quan Nguyen (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-14
 * Description  : Elastic ownership/gnt boundary and transparent tagged probes.
 * Specification: REQ-MEM-006/009/012/015; approved Plan V4 tile boundary.
 * Contract     : Native HPDcache must apply access/victim exclusion queries.
 *                Already admitted refills must drain independently of locks.
 * Change History:
 * 2026-11-14 - Quan Nguyen and Codex - VLSI Technology page:
 *              Acquire tagged line locks on PREPARE admission; release only
 *              on accepted successful COMMIT/ABORT responses.
 * 2026-11-14 - Quan Nguyen and Codex - VLSI Technology page:
 *              Export per-tag line-lock vectors to the native HPDcache path.
 * 2026-11-14 - Quan Nguyen and Codex - VLSI Technology page:
 *              Gate PREPARE forwarding until the matching MSHR/refill query clears.
 * Rule note    : HIE-02: functional adapter combines transport RTL and lock instance.
 * History      : Quan Nguyen and Codex - VLSI Technology page.
 *                DEC-045: Add optional cluster boundary timing profile support.
 */
// 2026-11-15 - Quan Nguyen and Codex - VLSI Technology page:
// DEC-038/A-02: acquire a line lock only when gated cache PREPARE is admitted.
`timescale 1ns/1ps

module m_vlsit_riscv_tile_coh_adapter #(
  // Parameter Description: number of CCU contexts sizing the internal probe tag.
  // Parameter values: 2 through 16; default is 8.
  // Parameter unit: contexts.
  parameter logic [31:0] PARA_COH_TXN_NUM = 32'd8,
  // Parameter Description: register the release of handshake gates.
  // Parameter values: 0 = legacy, 1 = registered; default is 0.
  // Parameter unit: mode
  parameter logic [31:0] PARA_REGISTER_RESET_RELEASE = 32'd0,
  localparam logic [31:0] LPARA_COH_TAG_W = (PARA_COH_TXN_NUM > 32'd1)
                                           ? 32'($clog2(PARA_COH_TXN_NUM)) : 32'd1,
  localparam logic [31:0] LPARA_PHASE_PREPARE = 32'd0,
  localparam logic [31:0] LPARA_PHASE_COMMIT = 32'd1,
  localparam logic [31:0] LPARA_PHASE_ABORT = 32'd2
) (
  // Clock and reset
  input  wire                               i_clk_cluster,
  input  wire                               i_rst_n_cluster,

  // Current native access/victim line observations; admitted refills drain
  input  wire                               i_cache_access_valid,
  input  wire  [51:0]                       i_cache_access_pa_line,
  output logic                              o_cache_access_locked,
  input  wire                               i_cache_victim_valid,
  input  wire  [51:0]                       i_cache_victim_pa_line,
  output logic                              o_cache_victim_locked,
  output logic [PARA_COH_TXN_NUM-1:0]       o_cache_line_lock_valid,
  output logic [PARA_COH_TXN_NUM-1:0][51:0] o_cache_line_lock_pa_line,
  output logic                              o_lock_diag_event,

  // Hold PREPARE until the matching HPDcache MSHR/refill activity has drained.
  output logic                              o_cache_probe_query_valid,
  output logic [51:0]                       o_cache_probe_query_nline,
  input  wire                               i_cache_probe_line_busy,

  // Cache ownership request; one elastic entry
  input  wire                               i_cache_req_valid,
  output logic                              o_cache_req_ready,
  input  wire  [2:0]                        i_cache_req_id,
  input  wire  [51:0]                       i_cache_req_pa_line,
  input  wire  [1:0]                        i_cache_req_kind,
  output logic                              o_req_valid,
  input  wire                               i_req_ready,
  output logic [2:0]                        o_req_id,
  output logic [51:0]                       o_req_pa_line,
  output logic [1:0]                        o_req_kind,

  // Fabric permission gnt; one elastic entry
  input  wire                               i_gnt_valid,
  output logic                              o_gnt_ready,
  input  wire  [2:0]                        i_gnt_id,
  input  wire  [51:0]                       i_gnt_pa_line,
  input  wire  [1:0]                        i_gnt_state,
  input  wire                               i_gnt_err,
  output logic                              o_cache_gnt_valid,
  input  wire                               i_cache_gnt_ready,
  output logic [2:0]                        o_cache_gnt_id,
  output logic [51:0]                       o_cache_gnt_pa_line,
  output logic [1:0]                        o_cache_gnt_state,
  output logic                              o_cache_gnt_err,

  // Tagged probe request; transparent handshake
  input  wire                               i_probe_req_valid,
  output logic                              o_probe_req_ready,
  input  wire  [LPARA_COH_TAG_W-1:0]        i_probe_req_tag,
  input  wire  [51:0]                       i_probe_req_pa_line,
  input  wire  [1:0]                        i_probe_req_phase,
  input  wire  [1:0]                        i_probe_req_target_state,
  input  wire                               i_probe_req_wback_en,
  output logic                              o_cache_probe_req_valid,
  input  wire                               i_cache_probe_req_ready,
  output logic [LPARA_COH_TAG_W-1:0]        o_cache_probe_req_tag,
  output logic [51:0]                       o_cache_probe_req_pa_line,
  output logic [1:0]                        o_cache_probe_req_phase,
  output logic [1:0]                        o_cache_probe_req_target_state,
  output logic                              o_cache_probe_req_wback_en,

  // Tagged probe response; transparent handshake
  input  wire                               i_cache_probe_rsp_valid,
  output logic                              o_cache_probe_rsp_ready,
  input  wire  [LPARA_COH_TAG_W-1:0]        i_cache_probe_rsp_tag,
  input  wire  [51:0]                       i_cache_probe_rsp_pa_line,
  input  wire  [1:0]                        i_cache_probe_rsp_phase,
  input  wire  [1:0]                        i_cache_probe_rsp_state,
  input  wire                               i_cache_probe_rsp_err,
  input  wire                               i_cache_probe_rsp_wback_done,
  output logic                              o_probe_rsp_valid,
  input  wire                               i_probe_rsp_ready,
  output logic [LPARA_COH_TAG_W-1:0]        o_probe_rsp_tag,
  output logic [51:0]                       o_probe_rsp_pa_line,
  output logic [1:0]                        o_probe_rsp_phase,
  output logic [1:0]                        o_probe_rsp_state,
  output logic                              o_probe_rsp_err,
  output logic                              o_probe_rsp_wback_done
);

  logic w_handshake_active;

  // Clear immediately on reset and admit handshakes after the first active edge.
  if (PARA_REGISTER_RESET_RELEASE == 32'd1) begin : gen_reset_release
    logic reg_handshake_active;
    always_ff @(posedge i_clk_cluster, negedge i_rst_n_cluster) begin : p_ff_reset_release
      if (!i_rst_n_cluster)
        reg_handshake_active <= 1'b0;
      else
        reg_handshake_active <= 1'b1;
    end
    assign w_handshake_active = reg_handshake_active;
  end else begin : gen_reset_direct
    assign w_handshake_active = i_rst_n_cluster;
  end

  // Elastic payloads hold their fields while their consumer is stalled.
  logic reg_req_valid;
  logic [2:0] reg_req_id;
  logic [51:0] reg_req_pa_line;
  logic [1:0] reg_req_kind;
  logic reg_gnt_valid;
  logic [2:0] reg_gnt_id;
  logic [51:0] reg_gnt_pa_line;
  logic [1:0] reg_gnt_state;
  logic reg_gnt_err;
  logic w_lock_acquire_ready;
  logic w_lock_acquire_valid;
  logic w_lock_release_valid;
  logic w_probe_req_allow;

  // Admit PREPARE only when the local tag/line lock can be reserved.
  assign w_probe_req_allow = (32'(i_probe_req_phase) != LPARA_PHASE_PREPARE)
                             | (w_lock_acquire_ready & ~i_cache_probe_line_busy);
  // Reserve a line only on the actual cache-side PREPARE handshake.
  assign w_lock_acquire_valid = o_cache_probe_req_valid & i_cache_probe_req_ready
                                 & (32'(i_probe_req_phase) == LPARA_PHASE_PREPARE)
                                 & w_handshake_active;
  // Retain the lock across PREPARE errors and terminal-response backpressure.
  assign w_lock_release_valid = i_cache_probe_rsp_valid & o_cache_probe_rsp_ready
                                 & ~i_cache_probe_rsp_err
                                 & ((32'(i_cache_probe_rsp_phase) == LPARA_PHASE_COMMIT)
                                    | (32'(i_cache_probe_rsp_phase) == LPARA_PHASE_ABORT));

  // Replace a consumed req entry on the same edge for one transfer per cycle.
  assign o_cache_req_ready = w_handshake_active & (~reg_req_valid | i_req_ready);
  assign o_req_valid = reg_req_valid;
  assign o_req_id = reg_req_id;
  assign o_req_pa_line = reg_req_pa_line;
  assign o_req_kind = reg_req_kind;

  // Replace a consumed gnt entry on the same edge for one transfer per cycle.
  assign o_gnt_ready = w_handshake_active & (~reg_gnt_valid | i_cache_gnt_ready);
  assign o_cache_gnt_valid = reg_gnt_valid;
  assign o_cache_gnt_id = reg_gnt_id;
  assign o_cache_gnt_pa_line = reg_gnt_pa_line;
  assign o_cache_gnt_state = reg_gnt_state;
  assign o_cache_gnt_err = reg_gnt_err;

  // Keep the PREPARE line query active while the cache drains same-line work;
  // forward the probe only after the local lock slot and busy query are clear.
  assign o_cache_probe_req_valid = i_probe_req_valid & w_handshake_active & w_probe_req_allow;
  assign o_probe_req_ready = i_cache_probe_req_ready & w_handshake_active & w_probe_req_allow;
  assign o_cache_probe_req_tag = i_probe_req_tag;
  assign o_cache_probe_req_pa_line = i_probe_req_pa_line;
  assign o_cache_probe_req_phase = i_probe_req_phase;
  assign o_cache_probe_req_target_state = i_probe_req_target_state;
  assign o_cache_probe_req_wback_en = i_probe_req_wback_en;

  // Present the requested physical line to the cache-side admission query.
  assign o_cache_probe_query_valid = i_probe_req_valid & w_handshake_active
                                     & (32'(i_probe_req_phase) == LPARA_PHASE_PREPARE);
  // Keep the cache query address paired with the active probe request.
  assign o_cache_probe_query_nline = i_probe_req_pa_line;

  // Return the cache's tagged probe status to the scheduler without changing
  // tag, line, phase, state, writeback status, or backpressure semantics.
  assign o_probe_rsp_valid = i_cache_probe_rsp_valid & w_handshake_active;
  assign o_cache_probe_rsp_ready = i_probe_rsp_ready & w_handshake_active;
  assign o_probe_rsp_tag = i_cache_probe_rsp_tag;
  assign o_probe_rsp_pa_line = i_cache_probe_rsp_pa_line;
  assign o_probe_rsp_phase = i_cache_probe_rsp_phase;
  assign o_probe_rsp_state = i_cache_probe_rsp_state;
  assign o_probe_rsp_err = i_cache_probe_rsp_err;
  assign o_probe_rsp_wback_done = i_cache_probe_rsp_wback_done;

  // Store the req payload only on its source handshake.
  always_ff @(posedge i_clk_cluster, negedge i_rst_n_cluster) begin : p_ff_req_entry
    if (!i_rst_n_cluster) begin
      reg_req_valid <= 1'b0;
      reg_req_id <= '0;
      reg_req_pa_line <= '0;
      reg_req_kind <= '0;
    end else if (o_cache_req_ready) begin
      reg_req_valid <= i_cache_req_valid;
      if (i_cache_req_valid) begin
        reg_req_id <= i_cache_req_id;
        reg_req_pa_line <= i_cache_req_pa_line;
        reg_req_kind <= i_cache_req_kind;
      end
    end
  end

  // Store the gnt payload only on its source handshake.
  always_ff @(posedge i_clk_cluster, negedge i_rst_n_cluster) begin : p_ff_gnt_entry
    if (!i_rst_n_cluster) begin
      reg_gnt_valid <= 1'b0;
      reg_gnt_id <= '0;
      reg_gnt_pa_line <= '0;
      reg_gnt_state <= '0;
      reg_gnt_err <= '0;
    end else if (o_gnt_ready) begin
      reg_gnt_valid <= i_gnt_valid;
      if (i_gnt_valid) begin
        reg_gnt_id <= i_gnt_id;
        reg_gnt_pa_line <= i_gnt_pa_line;
        reg_gnt_state <= i_gnt_state;
        reg_gnt_err <= i_gnt_err;
      end
    end
  end

  // One local lock record per CCU tag; no timeout or forced replacement.
  m_vlsit_riscv_cache_line_locks #(
      .PARA_REGISTER_RESET_RELEASE(PARA_REGISTER_RESET_RELEASE),
    .PARA_COH_TXN_NUM(PARA_COH_TXN_NUM)
  ) u_vlsit_riscv_cache_line_locks (
    .i_clk_cluster(i_clk_cluster),
    .i_rst_n_cluster(i_rst_n_cluster),
    .i_acquire_valid(w_lock_acquire_valid),
    .o_acquire_ready(w_lock_acquire_ready),
    .i_acquire_tag(i_probe_req_tag),
    .i_acquire_pa_line(i_probe_req_pa_line),
    .i_release_valid(w_lock_release_valid),
    .i_release_tag(i_cache_probe_rsp_tag),
    .i_release_pa_line(i_cache_probe_rsp_pa_line),
    .o_diag_event(o_lock_diag_event),
    .i_access_valid(i_cache_access_valid),
    .i_access_pa_line(i_cache_access_pa_line),
    .o_access_locked(o_cache_access_locked),
    .i_victim_valid(i_cache_victim_valid),
    .i_victim_pa_line(i_cache_victim_pa_line),
    .o_victim_locked(o_cache_victim_locked),
    .o_line_lock_valid(o_cache_line_lock_valid),
    .o_line_lock_pa_line(o_cache_line_lock_pa_line)
  );

endmodule
