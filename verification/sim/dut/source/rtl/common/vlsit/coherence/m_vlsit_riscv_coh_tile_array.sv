/*
 * Project      : VLSIT RISC-V CPU Cluster
 * Author       : Quan Nguyen (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-14
 * Description  : Connects per-hart tile coherence adapters to the shared MESI fabric.
 * Specification: VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md, Plan V3/V4
 */
`timescale 1ns/1ps

module m_vlsit_riscv_coh_tile_array #(
  // Parameter Description: enable the internal CMO retirement/service path.
  // Parameter values: 0 or 1; default 0 for standalone adapters.
  // Parameter unit: none.
  parameter logic [31:0] PARA_CMO_EN = 32'd0,
  // Parameter Description: number of active hart coherence interfaces.
  // Parameter values: 2 or 4; default is 4.
  // Parameter unit: harts.
  parameter logic [31:0] PARA_CPU_NUM = 32'd4,
  // Parameter Description: number of tagged CCU line transaction contexts.
  // Parameter values: 2 through 16; default is 8.
  // Parameter unit: contexts.
  parameter logic [31:0] PARA_COH_TXN_NUM = 32'd8,
  localparam logic [31:0] LPARA_COH_TAG_W = (PARA_COH_TXN_NUM > 32'd1)
                                           ? 32'($clog2(PARA_COH_TXN_NUM)) : 32'd1
) (
  // Shared CMO controller service; contexts and locks remain in this fabric.
  input  wire                                                 i_ccu_begin_valid,
  output logic                                                o_ccu_begin_ready,
  input  wire  [1:0]                                          i_ccu_begin_op,
  input  wire  [51:0]                                         i_ccu_begin_pa_line,
  input  wire  [1:0]                                          i_ccu_begin_hart,
  input  wire                                                 i_ccu_begin_wback_en,
  output logic                                                o_ccu_prepare_valid,
  input  wire                                                 i_ccu_prepare_ready,
  output logic [LPARA_COH_TAG_W-1:0]                          o_ccu_prepare_tag,
  output logic                                                o_ccu_prepare_err,
  input  wire                                                 i_ccu_finish_valid,
  output logic                                                o_ccu_finish_ready,
  input  wire  [LPARA_COH_TAG_W-1:0]                          i_ccu_finish_tag,
  input  wire                                                 i_ccu_finish_commit,
  output logic                                                o_ccu_finish_done,

  // Cluster clock and reset
  input  wire                                                 i_clk_cluster,
  input  wire                                                 i_rst_n_cluster,

  // Cache access/victim probes support same-line exclusion around maintenance.
  input  wire  [PARA_CPU_NUM-1:0]                             i_tile_access_valid,
  input  wire  [PARA_CPU_NUM-1:0][51:0]                       i_tile_access_pa_line,
  output logic [PARA_CPU_NUM-1:0]                             o_tile_access_locked,
  input  wire  [PARA_CPU_NUM-1:0]                             i_tile_victim_valid,
  input  wire  [PARA_CPU_NUM-1:0][51:0]                       i_tile_victim_pa_line,
  output logic [PARA_CPU_NUM-1:0]                             o_tile_victim_locked,

  // Cache ownership request and returned permission grant.
  input  wire  [PARA_CPU_NUM-1:0]                             i_tile_req_valid,
  output logic [PARA_CPU_NUM-1:0]                             o_tile_req_ready,
  input  wire  [PARA_CPU_NUM-1:0][2:0]                        i_tile_req_id,
  input  wire  [PARA_CPU_NUM-1:0][51:0]                       i_tile_req_pa_line,
  input  wire  [PARA_CPU_NUM-1:0][1:0]                        i_tile_req_kind,
  output logic [PARA_CPU_NUM-1:0]                             o_tile_gnt_valid,
  input  wire  [PARA_CPU_NUM-1:0]                             i_tile_gnt_ready,
  output logic [PARA_CPU_NUM-1:0][2:0]                        o_tile_gnt_id,
  output logic [PARA_CPU_NUM-1:0][51:0]                       o_tile_gnt_pa_line,
  output logic [PARA_CPU_NUM-1:0][1:0]                        o_tile_gnt_state,
  output logic [PARA_CPU_NUM-1:0]                             o_tile_gnt_err,

  // Two-phase tagged probe request/response to each native D-cache.
  output logic [PARA_CPU_NUM-1:0]                             o_tile_probe_req_valid,
  input  wire  [PARA_CPU_NUM-1:0]                             i_tile_probe_req_ready,
  output logic [PARA_CPU_NUM-1:0][LPARA_COH_TAG_W-1:0]        o_tile_probe_req_tag,
  output logic [PARA_CPU_NUM-1:0][51:0]                       o_tile_probe_req_pa_line,
  output logic [PARA_CPU_NUM-1:0][1:0]                        o_tile_probe_req_phase,
  output logic [PARA_CPU_NUM-1:0][1:0]                        o_tile_probe_req_target_state,
  output logic [PARA_CPU_NUM-1:0]                             o_tile_probe_req_wback_en,
  input  wire  [PARA_CPU_NUM-1:0]                             i_tile_probe_rsp_valid,
  output logic [PARA_CPU_NUM-1:0]                             o_tile_probe_rsp_ready,
  input  wire  [PARA_CPU_NUM-1:0][LPARA_COH_TAG_W-1:0]        i_tile_probe_rsp_tag,
  input  wire  [PARA_CPU_NUM-1:0][51:0]                       i_tile_probe_rsp_pa_line,
  input  wire  [PARA_CPU_NUM-1:0][1:0]                        i_tile_probe_rsp_phase,
  input  wire  [PARA_CPU_NUM-1:0][1:0]                        i_tile_probe_rsp_state,
  input  wire  [PARA_CPU_NUM-1:0]                             i_tile_probe_rsp_err,
  input  wire  [PARA_CPU_NUM-1:0]                             i_tile_probe_rsp_wback_done,

  // Busy query prevents PREPARE from racing an admitted same-line cache refill.
  output logic [PARA_CPU_NUM-1:0]                             o_tile_probe_query_valid,
  output logic [PARA_CPU_NUM-1:0][51:0]                       o_tile_probe_query_pa_line,
  input  wire  [PARA_CPU_NUM-1:0]                             i_tile_probe_line_busy,

  // Per-tag line locks are forwarded to the native HPDcache exclusion logic.
  output logic [PARA_CPU_NUM-1:0][PARA_COH_TXN_NUM-1:0]       o_tile_line_lock_valid,
  output logic [PARA_CPU_NUM-1:0][PARA_COH_TXN_NUM-1:0][51:0] o_tile_line_lock_pa_line,
  output logic [PARA_CPU_NUM-1:0]                             o_tile_lock_diag_event,
  output logic                                                o_coh_proto_diag_event,
  output logic [2:0]                                          o_dir_lookup_count,
  output logic [2:0]                                          o_dir_update_count,
  output logic [11:0][2:0]                                    o_ccu_evt_count
);

  // Adapter-to-fabric ownership channels.
  logic [PARA_CPU_NUM-1:0] w_fabric_req_valid;
  logic [PARA_CPU_NUM-1:0] w_fabric_req_ready;
  logic [PARA_CPU_NUM-1:0][2:0] w_fabric_req_id;
  logic [PARA_CPU_NUM-1:0][51:0] w_fabric_req_pa_line;
  logic [PARA_CPU_NUM-1:0][1:0] w_fabric_req_kind;
  logic [PARA_CPU_NUM-1:0] w_fabric_gnt_valid;
  logic [PARA_CPU_NUM-1:0] w_fabric_gnt_ready;
  logic [PARA_CPU_NUM-1:0][2:0] w_fabric_gnt_id;
  logic [PARA_CPU_NUM-1:0][51:0] w_fabric_gnt_pa_line;
  logic [PARA_CPU_NUM-1:0][1:0] w_fabric_gnt_state;
  logic [PARA_CPU_NUM-1:0] w_fabric_gnt_err;

  // Adapter-to-fabric tagged probe channels.
  logic [PARA_CPU_NUM-1:0] w_fabric_probe_req_valid;
  logic [PARA_CPU_NUM-1:0] w_fabric_probe_req_ready;
  logic [PARA_CPU_NUM-1:0][LPARA_COH_TAG_W-1:0] w_fabric_probe_req_tag;
  logic [PARA_CPU_NUM-1:0][51:0] w_fabric_probe_req_pa_line;
  logic [PARA_CPU_NUM-1:0][1:0] w_fabric_probe_req_phase;
  logic [PARA_CPU_NUM-1:0][1:0] w_fabric_probe_target_state;
  logic [PARA_CPU_NUM-1:0] w_fabric_probe_req_wback_en;
  logic [PARA_CPU_NUM-1:0] w_fabric_probe_rsp_valid;
  logic [PARA_CPU_NUM-1:0] w_fabric_probe_rsp_ready;
  logic [PARA_CPU_NUM-1:0][LPARA_COH_TAG_W-1:0] w_fabric_probe_rsp_tag;
  logic [PARA_CPU_NUM-1:0][51:0] w_fabric_probe_rsp_pa_line;
  logic [PARA_CPU_NUM-1:0][1:0] w_fabric_probe_rsp_phase;
  logic [PARA_CPU_NUM-1:0][1:0] w_fabric_probe_rsp_state;
  logic [PARA_CPU_NUM-1:0] w_fabric_probe_rsp_err;
  logic [PARA_CPU_NUM-1:0] w_fabric_probe_rsp_wback_done;
  logic w_same_line_lock_stall;

  // This PMU source is one cycle indicator, even if several harts are blocked.
  always_comb begin : p_com_lock_stall_event
    w_same_line_lock_stall = |(i_tile_access_valid & o_tile_access_locked);
  end

  // Each tile boundary buffers ownership/grant traffic and owns its PREPARE locks.
  for (genvar tile_idx = 0; tile_idx < PARA_CPU_NUM; tile_idx++) begin : gen_tile_adapter
    m_vlsit_riscv_tile_coh_adapter #(
      .PARA_COH_TXN_NUM(PARA_COH_TXN_NUM)
    ) u_vlsit_riscv_tile_coh_adapter (
      .i_clk_cluster(i_clk_cluster),
      .i_rst_n_cluster(i_rst_n_cluster),
      .i_cache_access_valid(i_tile_access_valid[tile_idx]),
      .i_cache_access_pa_line(i_tile_access_pa_line[tile_idx]),
      .o_cache_access_locked(o_tile_access_locked[tile_idx]),
      .i_cache_victim_valid(i_tile_victim_valid[tile_idx]),
      .i_cache_victim_pa_line(i_tile_victim_pa_line[tile_idx]),
      .o_cache_victim_locked(o_tile_victim_locked[tile_idx]),
      .o_cache_line_lock_valid(o_tile_line_lock_valid[tile_idx]),
      .o_cache_line_lock_pa_line(o_tile_line_lock_pa_line[tile_idx]),
      .o_lock_diag_event(o_tile_lock_diag_event[tile_idx]),
      .o_cache_probe_query_valid(o_tile_probe_query_valid[tile_idx]),
      .o_cache_probe_query_nline(o_tile_probe_query_pa_line[tile_idx]),
      .i_cache_probe_line_busy(i_tile_probe_line_busy[tile_idx]),
      .i_cache_req_valid(i_tile_req_valid[tile_idx]),
      .o_cache_req_ready(o_tile_req_ready[tile_idx]),
      .i_cache_req_id(i_tile_req_id[tile_idx]),
      .i_cache_req_pa_line(i_tile_req_pa_line[tile_idx]),
      .i_cache_req_kind(i_tile_req_kind[tile_idx]),
      .o_req_valid(w_fabric_req_valid[tile_idx]),
      .i_req_ready(w_fabric_req_ready[tile_idx]),
      .o_req_id(w_fabric_req_id[tile_idx]),
      .o_req_pa_line(w_fabric_req_pa_line[tile_idx]),
      .o_req_kind(w_fabric_req_kind[tile_idx]),
      .i_gnt_valid(w_fabric_gnt_valid[tile_idx]),
      .o_gnt_ready(w_fabric_gnt_ready[tile_idx]),
      .i_gnt_id(w_fabric_gnt_id[tile_idx]),
      .i_gnt_pa_line(w_fabric_gnt_pa_line[tile_idx]),
      .i_gnt_state(w_fabric_gnt_state[tile_idx]),
      .i_gnt_err(w_fabric_gnt_err[tile_idx]),
      .o_cache_gnt_valid(o_tile_gnt_valid[tile_idx]),
      .i_cache_gnt_ready(i_tile_gnt_ready[tile_idx]),
      .o_cache_gnt_id(o_tile_gnt_id[tile_idx]),
      .o_cache_gnt_pa_line(o_tile_gnt_pa_line[tile_idx]),
      .o_cache_gnt_state(o_tile_gnt_state[tile_idx]),
      .o_cache_gnt_err(o_tile_gnt_err[tile_idx]),
      .i_probe_req_valid(w_fabric_probe_req_valid[tile_idx]),
      .o_probe_req_ready(w_fabric_probe_req_ready[tile_idx]),
      .i_probe_req_tag(w_fabric_probe_req_tag[tile_idx]),
      .i_probe_req_pa_line(w_fabric_probe_req_pa_line[tile_idx]),
      .i_probe_req_phase(w_fabric_probe_req_phase[tile_idx]),
      .i_probe_req_target_state(w_fabric_probe_target_state[tile_idx]),
      .i_probe_req_wback_en(w_fabric_probe_req_wback_en[tile_idx]),
      .o_cache_probe_req_valid(o_tile_probe_req_valid[tile_idx]),
      .i_cache_probe_req_ready(i_tile_probe_req_ready[tile_idx]),
      .o_cache_probe_req_tag(o_tile_probe_req_tag[tile_idx]),
      .o_cache_probe_req_pa_line(o_tile_probe_req_pa_line[tile_idx]),
      .o_cache_probe_req_phase(o_tile_probe_req_phase[tile_idx]),
      .o_cache_probe_req_target_state(o_tile_probe_req_target_state[tile_idx]),
      .o_cache_probe_req_wback_en(o_tile_probe_req_wback_en[tile_idx]),
      .i_cache_probe_rsp_valid(i_tile_probe_rsp_valid[tile_idx]),
      .o_cache_probe_rsp_ready(o_tile_probe_rsp_ready[tile_idx]),
      .i_cache_probe_rsp_tag(i_tile_probe_rsp_tag[tile_idx]),
      .i_cache_probe_rsp_pa_line(i_tile_probe_rsp_pa_line[tile_idx]),
      .i_cache_probe_rsp_phase(i_tile_probe_rsp_phase[tile_idx]),
      .i_cache_probe_rsp_state(i_tile_probe_rsp_state[tile_idx]),
      .i_cache_probe_rsp_err(i_tile_probe_rsp_err[tile_idx]),
      .i_cache_probe_rsp_wback_done(i_tile_probe_rsp_wback_done[tile_idx]),
      .o_probe_rsp_valid(w_fabric_probe_rsp_valid[tile_idx]),
      .i_probe_rsp_ready(w_fabric_probe_rsp_ready[tile_idx]),
      .o_probe_rsp_tag(w_fabric_probe_rsp_tag[tile_idx]),
      .o_probe_rsp_pa_line(w_fabric_probe_rsp_pa_line[tile_idx]),
      .o_probe_rsp_phase(w_fabric_probe_rsp_phase[tile_idx]),
      .o_probe_rsp_state(w_fabric_probe_rsp_state[tile_idx]),
      .o_probe_rsp_err(w_fabric_probe_rsp_err[tile_idx]),
      .o_probe_rsp_wback_done(w_fabric_probe_rsp_wback_done[tile_idx])
    );
  end

  // The shared fabric arbitrates directory access and manages tagged MESI transitions.
  m_vlsit_riscv_coh_fabric #(
    .PARA_CMO_EN(PARA_CMO_EN),
    .PARA_CPU_NUM(PARA_CPU_NUM),
    .PARA_COH_TXN_NUM(PARA_COH_TXN_NUM)
  ) u_vlsit_riscv_coh_fabric (
    .i_ccu_begin_valid,
    .o_ccu_begin_ready,
    .i_ccu_begin_op,
    .i_ccu_begin_pa_line,
    .i_ccu_begin_hart,
    .i_ccu_begin_wback_en,
    .o_ccu_prepare_valid,
    .i_ccu_prepare_ready,
    .o_ccu_prepare_tag,
    .o_ccu_prepare_err,
    .i_ccu_finish_valid,
    .o_ccu_finish_ready,
    .i_ccu_finish_tag,
    .i_ccu_finish_commit,
    .o_ccu_finish_done,
    .i_clk_cluster(i_clk_cluster),
    .i_rst_n_cluster(i_rst_n_cluster),
    .i_req_valid(w_fabric_req_valid),
    .o_req_ready(w_fabric_req_ready),
    .i_req_id(w_fabric_req_id),
    .i_req_pa_line(w_fabric_req_pa_line),
    .i_req_kind(w_fabric_req_kind),
    .o_gnt_valid(w_fabric_gnt_valid),
    .i_gnt_ready(w_fabric_gnt_ready),
    .o_gnt_req_id(w_fabric_gnt_id),
    .o_gnt_pa_line(w_fabric_gnt_pa_line),
    .o_gnt_state(w_fabric_gnt_state),
    .o_gnt_err(w_fabric_gnt_err),
    .o_probe_req_valid(w_fabric_probe_req_valid),
    .i_probe_req_ready(w_fabric_probe_req_ready),
    .o_probe_req_tag(w_fabric_probe_req_tag),
    .o_probe_req_pa_line(w_fabric_probe_req_pa_line),
    .o_probe_req_phase(w_fabric_probe_req_phase),
    .o_probe_req_target_state(w_fabric_probe_target_state),
    .o_probe_req_wback_en(w_fabric_probe_req_wback_en),
    .i_probe_rsp_valid(w_fabric_probe_rsp_valid),
    .o_probe_rsp_ready(w_fabric_probe_rsp_ready),
    .i_probe_rsp_tag(w_fabric_probe_rsp_tag),
    .i_probe_rsp_pa_line(w_fabric_probe_rsp_pa_line),
    .i_probe_rsp_phase(w_fabric_probe_rsp_phase),
    .i_probe_rsp_state(w_fabric_probe_rsp_state),
    .i_probe_rsp_err(w_fabric_probe_rsp_err),
    .i_probe_rsp_wback_done(w_fabric_probe_rsp_wback_done),
    .i_same_line_lock_stall(w_same_line_lock_stall),
    .o_coh_proto_diag_event(o_coh_proto_diag_event),
    .o_dir_lookup_count(o_dir_lookup_count),
    .o_dir_update_count(o_dir_update_count),
    .o_ccu_evt_count(o_ccu_evt_count)
  );

endmodule
