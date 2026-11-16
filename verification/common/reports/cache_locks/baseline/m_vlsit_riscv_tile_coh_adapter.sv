/*
 * Project      : VLSIT RISC-V CPU Cluster
 * Author       : Quan Nguyen (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-14
 * Description  : Elastic ownership/gnt boundary and transparent tagged probes.
 * Specification: REQ-MEM-006/009/012/015; approved Plan V3 tile boundary.
 * Contract     : HPDcache owns same-line exclusion, MESI, and array arbitration.
 *                This adapter stores neither line locks nor coherence state.
 */
`timescale 1ns/1ps

module m_vlsit_riscv_tile_coh_adapter #(
  // Parameter Description: number of CCU contexts sizing the internal probe tag.
  // Parameter values: 2 through 16; default is 8.
  // Parameter unit: contexts.
  parameter logic [31:0] PARA_COH_TXN_NUM = 32'd8,
  localparam logic [31:0] LPARA_COH_TAG_W = (PARA_COH_TXN_NUM > 32'd1)
                                           ? 32'($clog2(PARA_COH_TXN_NUM)) : 32'd1
) (
  // Clock and reset
  input  wire                        i_clk_cluster,
  input  wire                        i_rst_n_cluster,

  // Cache ownership request; one elastic entry
  input  wire                        i_cache_req_valid,
  output logic                       o_cache_req_ready,
  input  wire  [2:0]                 i_cache_req_id,
  input  wire  [51:0]                i_cache_req_pa_line,
  input  wire  [1:0]                 i_cache_req_kind,
  output logic                       o_req_valid,
  input  wire                        i_req_ready,
  output logic [2:0]                 o_req_id,
  output logic [51:0]                o_req_pa_line,
  output logic [1:0]                 o_req_kind,

  // Fabric permission gnt; one elastic entry
  input  wire                        i_gnt_valid,
  output logic                       o_gnt_ready,
  input  wire  [2:0]                 i_gnt_id,
  input  wire  [51:0]                i_gnt_pa_line,
  input  wire  [1:0]                 i_gnt_state,
  input  wire                        i_gnt_err,
  output logic                       o_cache_gnt_valid,
  input  wire                        i_cache_gnt_ready,
  output logic [2:0]                 o_cache_gnt_id,
  output logic [51:0]                o_cache_gnt_pa_line,
  output logic [1:0]                 o_cache_gnt_state,
  output logic                       o_cache_gnt_err,

  // Tagged probe request; transparent handshake
  input  wire                        i_probe_req_valid,
  output logic                       o_probe_req_ready,
  input  wire  [LPARA_COH_TAG_W-1:0] i_probe_req_tag,
  input  wire  [51:0]                i_probe_req_pa_line,
  input  wire  [1:0]                 i_probe_req_phase,
  input  wire  [1:0]                 i_probe_req_target_state,
  input  wire                        i_probe_req_wback_en,
  output logic                       o_cache_probe_req_valid,
  input  wire                        i_cache_probe_req_ready,
  output logic [LPARA_COH_TAG_W-1:0] o_cache_probe_req_tag,
  output logic [51:0]                o_cache_probe_req_pa_line,
  output logic [1:0]                 o_cache_probe_req_phase,
  output logic [1:0]                 o_cache_probe_req_target_state,
  output logic                       o_cache_probe_req_wback_en,

  // Tagged probe response; transparent handshake
  input  wire                        i_cache_probe_rsp_valid,
  output logic                       o_cache_probe_rsp_ready,
  input  wire  [LPARA_COH_TAG_W-1:0] i_cache_probe_rsp_tag,
  input  wire  [51:0]                i_cache_probe_rsp_pa_line,
  input  wire  [1:0]                 i_cache_probe_rsp_phase,
  input  wire  [1:0]                 i_cache_probe_rsp_state,
  input  wire                        i_cache_probe_rsp_err,
  input  wire                        i_cache_probe_rsp_wback_done,
  output logic                       o_probe_rsp_valid,
  input  wire                        i_probe_rsp_ready,
  output logic [LPARA_COH_TAG_W-1:0] o_probe_rsp_tag,
  output logic [51:0]                o_probe_rsp_pa_line,
  output logic [1:0]                 o_probe_rsp_phase,
  output logic [1:0]                 o_probe_rsp_state,
  output logic                       o_probe_rsp_err,
  output logic                       o_probe_rsp_wback_done

);

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

  // Replace a consumed req entry on the same edge for one transfer per cycle.
  assign o_cache_req_ready = i_rst_n_cluster & (~reg_req_valid | i_req_ready);
  assign o_req_valid = reg_req_valid;
  assign o_req_id = reg_req_id;
  assign o_req_pa_line = reg_req_pa_line;
  assign o_req_kind = reg_req_kind;

  // Replace a consumed gnt entry on the same edge for one transfer per cycle.
  assign o_gnt_ready = i_rst_n_cluster & (~reg_gnt_valid | i_cache_gnt_ready);
  assign o_cache_gnt_valid = reg_gnt_valid;
  assign o_cache_gnt_id = reg_gnt_id;
  assign o_cache_gnt_pa_line = reg_gnt_pa_line;
  assign o_cache_gnt_state = reg_gnt_state;
  assign o_cache_gnt_err = reg_gnt_err;

  // Preserve probe identity and phase; endpoint storage owns backpressure.
  assign o_cache_probe_req_valid = i_probe_req_valid & i_rst_n_cluster;
  assign o_probe_req_ready = i_cache_probe_req_ready & i_rst_n_cluster;
  assign o_cache_probe_req_tag = i_probe_req_tag;
  assign o_cache_probe_req_pa_line = i_probe_req_pa_line;
  assign o_cache_probe_req_phase = i_probe_req_phase;
  assign o_cache_probe_req_target_state = i_probe_req_target_state;
  assign o_cache_probe_req_wback_en = i_probe_req_wback_en;

  // Preserve probe identity and phase; endpoint storage owns backpressure.
  assign o_probe_rsp_valid = i_cache_probe_rsp_valid & i_rst_n_cluster;
  assign o_cache_probe_rsp_ready = i_probe_rsp_ready & i_rst_n_cluster;
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

endmodule
