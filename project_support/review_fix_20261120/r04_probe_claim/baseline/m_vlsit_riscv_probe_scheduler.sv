/*
 * Project      : VLSIT RISC-V CPU Cluster
 * Author       : Quan Nguyen (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-08
 * Description  : Schedules tagged probes and routes D-cache responses to the transaction table.
 * Change History:
 * 2026-11-14 - Quan Nguyen and Codex - VLSI Technology page:
 *              Retain/forward explicit PREPARE writeback enable;
 *              true INVAL disables writeback (REQ-MEM-015, DEC-028).
 * 2026-11-09 - Modified by Quan Nguyen and Codex - VLSI Technology page:
 *              Drain invalid/stale probe responses whenever the ACK buffer is
 *              free and expose a diagnostic event (REQ-MEM-021/023).
 */
// 2026-11-15 - Quan Nguyen and Codex - VLSI Technology page:
// DEC-038/A-02: retain per-cache transaction ownership across all probe phases;
// unrelated PREPARE requests cannot displace a required COMMIT/ABORT.
`timescale 1ns/1ps

module m_vlsit_riscv_probe_scheduler #(
  // Parameter Description: number of active CPU hart probe endpoints.
  // Parameter values: 2 or 4; default is 4.
  // Parameter unit: harts
  parameter logic [31:0] PARA_CPU_NUM = 32'd4,
  // Parameter Description: number of concurrent coherence transaction contexts.
  // Parameter values: 2 through 16; default is 8.
  // Parameter unit: contexts
  parameter logic [31:0] PARA_COH_TXN_NUM = 32'd8,
  localparam logic [31:0] LPARA_COH_TAG_W = (PARA_COH_TXN_NUM > 32'd1)
                                            ? 32'($clog2(PARA_COH_TXN_NUM)) : 32'd1
) (
  // Clock and reset
  input  wire                                           i_clk_cluster,
  input  wire                                           i_rst_n_cluster,

  // Active transaction contexts from the coherence transaction table
  input  wire  [PARA_COH_TXN_NUM-1:0]                   i_ctx_valid,
  input  wire  [PARA_COH_TXN_NUM-1:0][51:0]             i_ctx_pa_line,
  input  wire  [PARA_COH_TXN_NUM-1:0][1:0]              i_ctx_phase,
  input  wire  [PARA_COH_TXN_NUM-1:0][PARA_CPU_NUM-1:0] i_ctx_ack_expected,
  input  wire  [PARA_COH_TXN_NUM-1:0][PARA_CPU_NUM-1:0] i_ctx_ack_received,
  input  wire  [PARA_COH_TXN_NUM-1:0]                   i_ctx_phase_active,
  input  wire  [PARA_COH_TXN_NUM-1:0][1:0]              i_ctx_target_state,
  input  wire  [PARA_COH_TXN_NUM-1:0]                   i_ctx_wback_en,

  // Tagged probe request channel, one outstanding probe per hart
  output logic [PARA_CPU_NUM-1:0]                       o_probe_req_valid,
  input  wire  [PARA_CPU_NUM-1:0]                       i_probe_req_ready,
  output logic [PARA_CPU_NUM-1:0][LPARA_COH_TAG_W-1:0]  o_probe_req_tag,
  output logic [PARA_CPU_NUM-1:0][51:0]                 o_probe_req_pa_line,
  output logic [PARA_CPU_NUM-1:0][1:0]                  o_probe_req_phase,
  output logic [PARA_CPU_NUM-1:0][1:0]                  o_probe_req_target_state,
  output logic [PARA_CPU_NUM-1:0]                       o_probe_req_wback_en,

  // Tagged probe response channel from each D-cache
  input  wire  [PARA_CPU_NUM-1:0]                       i_probe_rsp_valid,
  output logic [PARA_CPU_NUM-1:0]                       o_probe_rsp_ready,
  input  wire  [PARA_CPU_NUM-1:0][LPARA_COH_TAG_W-1:0]  i_probe_rsp_tag,
  input  wire  [PARA_CPU_NUM-1:0][51:0]                 i_probe_rsp_pa_line,
  input  wire  [PARA_CPU_NUM-1:0][1:0]                  i_probe_rsp_phase,
  input  wire  [PARA_CPU_NUM-1:0][1:0]                  i_probe_rsp_state,
  input  wire  [PARA_CPU_NUM-1:0]                       i_probe_rsp_err,
  input  wire  [PARA_CPU_NUM-1:0]                       i_probe_rsp_wback_done,

  // One acknowledgement lane per hart for the transaction table
  output logic [PARA_CPU_NUM-1:0]                       o_ack_valid,
  input  wire  [PARA_CPU_NUM-1:0]                       i_ack_ready,
  output logic [PARA_CPU_NUM-1:0][LPARA_COH_TAG_W-1:0]  o_ack_tag,
  output logic [PARA_CPU_NUM-1:0][1:0]                  o_ack_phase,
  output logic [PARA_CPU_NUM-1:0][1:0]                  o_ack_state,
  output logic [PARA_CPU_NUM-1:0]                       o_ack_err,
  output logic [PARA_CPU_NUM-1:0]                       o_ack_wback_done,
  output logic [PARA_CPU_NUM-1:0]                       o_coh_proto_diag_event
);

  logic [PARA_CPU_NUM-1:0] reg_req_valid;
  logic [PARA_CPU_NUM-1:0][LPARA_COH_TAG_W-1:0] reg_req_tag;
  logic [PARA_CPU_NUM-1:0][51:0] reg_req_pa_line;
  logic [PARA_CPU_NUM-1:0][1:0] reg_req_phase;
  logic [PARA_CPU_NUM-1:0][1:0] reg_req_target_state;
  logic [PARA_CPU_NUM-1:0] reg_req_wback_en;
  logic [PARA_CPU_NUM-1:0][LPARA_COH_TAG_W-1:0] reg_rr_ptr;
  // One cache keeps its PREPARE context until successful terminal response.
  // Phase transport completion alone does not release the cache service slot.
  logic [PARA_CPU_NUM-1:0] reg_phase_owner_valid;
  logic [PARA_CPU_NUM-1:0][LPARA_COH_TAG_W-1:0] reg_phase_owner_tag;
  logic [PARA_CPU_NUM-1:0] reg_probe_active;
  logic [PARA_CPU_NUM-1:0][LPARA_COH_TAG_W-1:0] reg_active_tag;
  logic [PARA_CPU_NUM-1:0][51:0] reg_active_pa_line;
  logic [PARA_CPU_NUM-1:0][1:0] reg_active_phase;
  logic [PARA_CPU_NUM-1:0] reg_ack_valid;
  logic [PARA_CPU_NUM-1:0][LPARA_COH_TAG_W-1:0] reg_ack_tag;
  logic [PARA_CPU_NUM-1:0][1:0] reg_ack_phase;
  logic [PARA_CPU_NUM-1:0][1:0] reg_ack_state;
  logic [PARA_CPU_NUM-1:0] reg_ack_err;
  logic [PARA_CPU_NUM-1:0] reg_ack_wback_done;
  logic [PARA_CPU_NUM-1:0] w_pick_found;
  logic [PARA_CPU_NUM-1:0][LPARA_COH_TAG_W-1:0] w_pick_tag;
  logic [PARA_CPU_NUM-1:0][PARA_COH_TXN_NUM-1:0][31:0] w_scan_idx;
  logic [PARA_CPU_NUM-1:0] w_req_hs;
  logic [PARA_CPU_NUM-1:0] w_rsp_hs;
  logic [PARA_CPU_NUM-1:0] w_rsp_match;
  logic [PARA_CPU_NUM-1:0] w_ack_hs;

  // Expose held request and acknowledgement records to their ready/valid consumers.
  assign o_probe_req_valid = reg_req_valid;
  assign o_probe_req_tag = reg_req_tag;
  assign o_probe_req_pa_line = reg_req_pa_line;
  assign o_probe_req_phase = reg_req_phase;
  assign o_probe_req_target_state = reg_req_target_state;
  assign o_probe_req_wback_en = reg_req_wback_en;
  assign o_ack_valid = reg_ack_valid;
  assign o_ack_tag = reg_ack_tag;
  assign o_ack_phase = reg_ack_phase;
  assign o_ack_state = reg_ack_state;
  assign o_ack_err = reg_ack_err;
  assign o_ack_wback_done = reg_ack_wback_done;

  // Select one unissued expected target per idle hart with round-robin context priority.
  always_comb begin : p_com_probe_sel
    w_pick_found = '0;
    w_pick_tag = '0;
    w_scan_idx = '0;
    for (int hart_idx = 0; hart_idx < PARA_CPU_NUM; hart_idx++) begin
      if (~reg_req_valid[hart_idx] & ~reg_probe_active[hart_idx] & ~reg_ack_valid[hart_idx]) begin
        for (int offset_idx = 0; offset_idx < PARA_COH_TXN_NUM; offset_idx++) begin
          w_scan_idx[hart_idx][offset_idx] = 32'(reg_rr_ptr[hart_idx])
                                           + 32'(offset_idx);
          if (w_scan_idx[hart_idx][offset_idx] >= PARA_COH_TXN_NUM)
            w_scan_idx[hart_idx][offset_idx] = w_scan_idx[hart_idx][offset_idx]
                                             - PARA_COH_TXN_NUM;
          if (i_ctx_valid[w_scan_idx[hart_idx][offset_idx]]
              & i_ctx_phase_active[w_scan_idx[hart_idx][offset_idx]]
              & (~reg_phase_owner_valid[hart_idx]
                 | (reg_phase_owner_tag[hart_idx]
                    == LPARA_COH_TAG_W'(w_scan_idx[hart_idx][offset_idx])))
              & i_ctx_ack_expected[w_scan_idx[hart_idx][offset_idx]][hart_idx]
              & ~i_ctx_ack_received[w_scan_idx[hart_idx][offset_idx]][hart_idx]
              & ~w_pick_found[hart_idx]) begin
            w_pick_found[hart_idx] = 1'b1;
            w_pick_tag[hart_idx] = LPARA_COH_TAG_W'(w_scan_idx[hart_idx][offset_idx]);
          end
        end
      end
    end
  end

  // Accept only a response that matches the single outstanding probe for that hart.
  always_comb begin : p_com_probe_handshake
    o_probe_rsp_ready = '0;
    w_req_hs = reg_req_valid & i_probe_req_ready;
    w_rsp_hs = '0;
    w_rsp_match = '0;
    o_coh_proto_diag_event = '0;
    w_ack_hs = reg_ack_valid & i_ack_ready;
    for (int hart_idx = 0; hart_idx < PARA_CPU_NUM; hart_idx++) begin
      o_probe_rsp_ready[hart_idx] = ~reg_ack_valid[hart_idx];
      w_rsp_hs[hart_idx] = i_probe_rsp_valid[hart_idx] & o_probe_rsp_ready[hart_idx];
      w_rsp_match[hart_idx] = reg_probe_active[hart_idx]
                            & (i_probe_rsp_tag[hart_idx] == reg_active_tag[hart_idx])
                            & (i_probe_rsp_pa_line[hart_idx] == reg_active_pa_line[hart_idx])
                            & (i_probe_rsp_phase[hart_idx] == reg_active_phase[hart_idx]);
      o_coh_proto_diag_event[hart_idx] = w_rsp_hs[hart_idx] & ~w_rsp_match[hart_idx];
    end
  end

  // Hold each probe and returned acknowledgement stable until its consumer accepts it.
  always_ff @(posedge i_clk_cluster, negedge i_rst_n_cluster) begin : p_ff_probe_schedule
    if (!i_rst_n_cluster) begin
      reg_req_valid <= '0;
      reg_req_tag <= '0;
      reg_req_pa_line <= '0;
      reg_req_phase <= '0;
      reg_req_target_state <= '0;
      reg_req_wback_en <= '0;
      reg_rr_ptr <= '0;
      reg_probe_active <= '0;
      reg_phase_owner_valid <= '0;
      reg_phase_owner_tag <= '0;
      reg_active_tag <= '0;
      reg_active_pa_line <= '0;
      reg_active_phase <= '0;
      reg_ack_valid <= '0;
      reg_ack_tag <= '0;
      reg_ack_phase <= '0;
      reg_ack_state <= '0;
      reg_ack_err <= '0;
      reg_ack_wback_done <= '0;
    end else begin
      for (int hart_idx = 0; hart_idx < PARA_CPU_NUM; hart_idx++) begin
        if (~reg_req_valid[hart_idx] & ~reg_probe_active[hart_idx]
            & ~reg_ack_valid[hart_idx] & w_pick_found[hart_idx]) begin
          reg_req_valid[hart_idx] <= 1'b1;
          reg_req_tag[hart_idx] <= w_pick_tag[hart_idx];
          reg_req_pa_line[hart_idx] <= i_ctx_pa_line[w_pick_tag[hart_idx]];
          reg_req_phase[hart_idx] <= i_ctx_phase[w_pick_tag[hart_idx]];
          reg_req_target_state[hart_idx] <= i_ctx_target_state[w_pick_tag[hart_idx]];
          reg_req_wback_en[hart_idx] <= i_ctx_wback_en[w_pick_tag[hart_idx]]
                                         & (i_ctx_phase[w_pick_tag[hart_idx]] == 2'd0);
        end
        if (w_req_hs[hart_idx]) begin
          reg_req_valid[hart_idx] <= 1'b0;
          reg_probe_active[hart_idx] <= 1'b1;
          reg_active_tag[hart_idx] <= reg_req_tag[hart_idx];
          reg_active_pa_line[hart_idx] <= reg_req_pa_line[hart_idx];
          reg_active_phase[hart_idx] <= reg_req_phase[hart_idx];
          if (reg_req_phase[hart_idx] == 2'd0) begin
            reg_phase_owner_valid[hart_idx] <= 1'b1;
            reg_phase_owner_tag[hart_idx] <= reg_req_tag[hart_idx];
          end
          if ((32'(reg_req_tag[hart_idx]) + 32'd1) == PARA_COH_TXN_NUM)
            reg_rr_ptr[hart_idx] <= '0;
          else
            reg_rr_ptr[hart_idx] <= reg_req_tag[hart_idx] + 1'b1;
        end
        if (w_rsp_hs[hart_idx] & w_rsp_match[hart_idx]) begin
          reg_probe_active[hart_idx] <= 1'b0;
          if ((reg_active_phase[hart_idx] != 2'd0)
              & ~i_probe_rsp_err[hart_idx])
            reg_phase_owner_valid[hart_idx] <= 1'b0;
          reg_ack_valid[hart_idx] <= 1'b1;
          reg_ack_tag[hart_idx] <= reg_active_tag[hart_idx];
          reg_ack_phase[hart_idx] <= reg_active_phase[hart_idx];
          reg_ack_state[hart_idx] <= i_probe_rsp_state[hart_idx];
          reg_ack_err[hart_idx] <= i_probe_rsp_err[hart_idx];
          reg_ack_wback_done[hart_idx] <= i_probe_rsp_wback_done[hart_idx];
        end else if (w_ack_hs[hart_idx]) begin
          reg_ack_valid[hart_idx] <= 1'b0;
        end
      end
    end
  end

endmodule
