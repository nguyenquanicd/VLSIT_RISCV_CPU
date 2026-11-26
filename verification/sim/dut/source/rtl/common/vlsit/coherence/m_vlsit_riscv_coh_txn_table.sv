/*
 * Project      : VLSIT RISC-V CPU Cluster
 * Author       : Quan Nguyen (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-08
 * Description  : Stores tagged coherence contexts and tracks PREPARE/COMMIT/ABORT acknowledgements.
 * Change History:
 * 2026-11-14 - Quan Nguyen and Codex - VLSI Technology page:
 *              Retain/forward explicit PREPARE writeback enable;
 *              true INVAL disables writeback (REQ-MEM-015, DEC-028).
 * 2026-11-09 - Modified by Quan Nguyen and Codex - VLSI Technology page:
 *              Retained target MESI, owner metadata, transaction/writeback errors;
 *              added owner-capture handshake, unconditional ACK draining, and
 *              COMMIT gating after retained errors (REQ-MEM-021/023).
 */
`timescale 1ns/1ps

module m_vlsit_riscv_coh_txn_table #(
  // Parameter Description: number of concurrent coherence transaction contexts.
  // Parameter values: 2 through 16; default is 8.
  // Parameter unit: contexts
  parameter logic [31:0] PARA_COH_TXN_NUM = 32'd8,
  // Parameter Description: number of active CPU hart slots in this cluster.
  // Parameter values: 2 or 4; default is 4.
  // Parameter unit: harts
  parameter logic [31:0] PARA_CPU_NUM = 32'd4,
  localparam logic [31:0] LPARA_COH_TAG_W = (PARA_COH_TXN_NUM > 32'd1)
                                           ? 32'($clog2(PARA_COH_TXN_NUM)) : 32'd1,
  localparam logic [31:0] LPARA_COH_PHASE_PREPARE = 32'd0,
  localparam logic [31:0] LPARA_COH_PHASE_COMMIT = 32'd1,
  localparam logic [31:0] LPARA_COH_PHASE_ABORT = 32'd2
) (
  // Clock and reset
  input  wire                                           i_clk_cluster,
  input  wire                                           i_rst_n_cluster,

  // Allocate and release a line-locked transaction context
  input  wire                                           i_alloc_valid,
  output logic                                          o_alloc_ready,
  input  wire  [2:0]                                    i_alloc_src,
  input  wire  [2:0]                                    i_alloc_req_id,
  input  wire  [51:0]                                   i_alloc_pa_line,
  input  wire  [1:0]                                    i_alloc_kind,
  input  wire  [1:0]                                    i_alloc_target_state,
  input  wire                                           i_alloc_wback_en,
  output logic [LPARA_COH_TAG_W-1:0]                    o_alloc_tag,
  input  wire                                           i_release_valid,
  input  wire  [LPARA_COH_TAG_W-1:0]                    i_release_tag,
  output logic                                          o_release_ready,

  // Start one tagged PREPARE, COMMIT, or ABORT acknowledgement phase
  input  wire                                           i_phase_start_valid,
  input  wire  [LPARA_COH_TAG_W-1:0]                    i_phase_start_tag,
  input  wire  [1:0]                                    i_phase_start,
  input  wire  [PARA_CPU_NUM-1:0]                       i_phase_expected,
  output logic                                          o_phase_start_ready,

  // Capture owner metadata from the matching directory lookup before PREPARE.
  input  wire                                           i_owner_capture_valid,
  output logic                                          o_owner_capture_ready,
  input  wire  [LPARA_COH_TAG_W-1:0]                    i_owner_capture_tag,
  input  wire                                           i_owner_capture_present,
  input  wire  [1:0]                                    i_owner_capture_hart,

  // One tagged acknowledgement lane per hart
  input  wire  [PARA_CPU_NUM-1:0]                       i_ack_valid,
  output logic [PARA_CPU_NUM-1:0]                       o_ack_ready,
  input  wire  [PARA_CPU_NUM-1:0][LPARA_COH_TAG_W-1:0]  i_ack_tag,
  input  wire  [PARA_CPU_NUM-1:0][1:0]                  i_ack_phase,
  input  wire  [PARA_CPU_NUM-1:0]                       i_ack_err,
  input  wire  [PARA_CPU_NUM-1:0]                       i_ack_wback_done,

  // Transaction context and phase status, indexed by the allocated tag
  output logic [PARA_COH_TXN_NUM-1:0]                   o_ctx_valid,
  output logic [PARA_COH_TXN_NUM-1:0][2:0]              o_ctx_src,
  output logic [PARA_COH_TXN_NUM-1:0][2:0]              o_ctx_req_id,
  output logic [PARA_COH_TXN_NUM-1:0][51:0]             o_ctx_pa_line,
  output logic [PARA_COH_TXN_NUM-1:0][1:0]              o_ctx_kind,
  output logic [PARA_COH_TXN_NUM-1:0][1:0]              o_ctx_phase,
  output logic [PARA_COH_TXN_NUM-1:0][PARA_CPU_NUM-1:0] o_ctx_ack_expected,
  output logic [PARA_COH_TXN_NUM-1:0][PARA_CPU_NUM-1:0] o_ctx_ack_received,
  output logic [PARA_COH_TXN_NUM-1:0]                   o_ctx_phase_active,
  output logic [PARA_COH_TXN_NUM-1:0]                   o_ctx_phase_done,
  output logic [PARA_COH_TXN_NUM-1:0]                   o_ctx_phase_err,
  output logic [PARA_COH_TXN_NUM-1:0]                   o_ctx_owner_wback_done,
  output logic [PARA_COH_TXN_NUM-1:0][1:0]              o_ctx_target_state,
  output logic [PARA_COH_TXN_NUM-1:0]                   o_ctx_wback_en,
  output logic [PARA_COH_TXN_NUM-1:0]                   o_ctx_owner_known,
  output logic [PARA_COH_TXN_NUM-1:0]                   o_ctx_owner_present,
  output logic [PARA_COH_TXN_NUM-1:0][1:0]              o_ctx_owner_hart,
  output logic [PARA_COH_TXN_NUM-1:0]                   o_ctx_txn_err,
  output logic [PARA_COH_TXN_NUM-1:0]                   o_ctx_owner_wback_err,
  output logic                                          o_coh_proto_diag_event
);

  logic [PARA_COH_TXN_NUM-1:0] reg_ctx_valid;
  logic [PARA_COH_TXN_NUM-1:0][2:0] reg_ctx_src;
  logic [PARA_COH_TXN_NUM-1:0][2:0] reg_ctx_req_id;
  logic [PARA_COH_TXN_NUM-1:0][51:0] reg_ctx_pa_line;
  logic [PARA_COH_TXN_NUM-1:0][1:0] reg_ctx_kind;
  logic [PARA_COH_TXN_NUM-1:0][1:0] reg_ctx_target_state;
  logic [PARA_COH_TXN_NUM-1:0] reg_ctx_wback_en;
  logic [PARA_COH_TXN_NUM-1:0] reg_ctx_owner_known;
  logic [PARA_COH_TXN_NUM-1:0] reg_ctx_owner_present;
  logic [PARA_COH_TXN_NUM-1:0][1:0] reg_ctx_owner_hart;
  logic [PARA_COH_TXN_NUM-1:0][1:0] reg_ctx_phase;
  logic [PARA_COH_TXN_NUM-1:0][PARA_CPU_NUM-1:0] reg_ctx_ack_expected;
  logic [PARA_COH_TXN_NUM-1:0][PARA_CPU_NUM-1:0] reg_ctx_ack_received;
  logic [PARA_COH_TXN_NUM-1:0] reg_ctx_phase_active;
  logic [PARA_COH_TXN_NUM-1:0] reg_ctx_phase_done;
  logic [PARA_COH_TXN_NUM-1:0] reg_ctx_phase_err;
  logic [PARA_COH_TXN_NUM-1:0] reg_ctx_owner_wback_done;
  logic [PARA_COH_TXN_NUM-1:0] reg_ctx_txn_err;
  logic [PARA_COH_TXN_NUM-1:0] reg_ctx_owner_wback_err;
  logic [PARA_COH_TXN_NUM-1:0][PARA_CPU_NUM-1:0] w_ack_take;
  logic [PARA_COH_TXN_NUM-1:0] w_ack_err;
  logic [PARA_COH_TXN_NUM-1:0] w_ack_wback_done;
  logic [PARA_COH_TXN_NUM-1:0] w_ack_owner_wback_err;
  logic [PARA_CPU_NUM-1:0] w_ack_valid_match;
  logic [PARA_COH_TXN_NUM-1:0] w_owner_capture_take;
  logic w_owner_capture_tag_valid;
  logic w_owner_capture_context_valid;
  logic w_owner_capture_accepted;
  logic w_alloc_found;
  logic w_alloc_line_busy;
  logic [LPARA_COH_TAG_W-1:0] w_alloc_tag;

  // Expose the context table state to the coherence fabric.
  assign o_ctx_valid = reg_ctx_valid;
  assign o_ctx_src = reg_ctx_src;
  assign o_ctx_req_id = reg_ctx_req_id;
  assign o_ctx_pa_line = reg_ctx_pa_line;
  assign o_ctx_kind = reg_ctx_kind;
  assign o_ctx_target_state = reg_ctx_target_state;
  assign o_ctx_wback_en = reg_ctx_wback_en;
  assign o_ctx_owner_known = reg_ctx_owner_known;
  assign o_ctx_owner_present = reg_ctx_owner_present;
  assign o_ctx_owner_hart = reg_ctx_owner_hart;
  assign o_ctx_phase = reg_ctx_phase;
  assign o_ctx_ack_expected = reg_ctx_ack_expected;
  assign o_ctx_ack_received = reg_ctx_ack_received;
  assign o_ctx_phase_active = reg_ctx_phase_active;
  assign o_ctx_phase_done = reg_ctx_phase_done;
  assign o_ctx_phase_err = reg_ctx_phase_err;
  assign o_ctx_owner_wback_done = reg_ctx_owner_wback_done;
  assign o_ctx_txn_err = reg_ctx_txn_err;
  assign o_ctx_owner_wback_err = reg_ctx_owner_wback_err;
  assign o_alloc_ready = w_alloc_found & ~w_alloc_line_busy;
  assign o_alloc_tag = w_alloc_tag;
  // Gate release and phase changes by valid tags and completed prior work.
  always_comb begin : p_com_coh_ctl_ready
    o_release_ready = 1'b0;
    o_phase_start_ready = 1'b0;
    o_owner_capture_ready = 1'b1;
    w_owner_capture_tag_valid = (32'(i_owner_capture_tag) < PARA_COH_TXN_NUM);
    w_owner_capture_context_valid = 1'b0;
    w_owner_capture_accepted = 1'b0;
    w_owner_capture_take = '0;
    if (32'(i_release_tag) < PARA_COH_TXN_NUM)
      o_release_ready = reg_ctx_valid[i_release_tag] & ~reg_ctx_phase_active[i_release_tag];
    if (w_owner_capture_tag_valid) begin
      w_owner_capture_context_valid = reg_ctx_valid[i_owner_capture_tag]
                                    & ~reg_ctx_owner_known[i_owner_capture_tag]
                                    & (~i_owner_capture_present
                                       | (32'(i_owner_capture_hart) < PARA_CPU_NUM));
      w_owner_capture_accepted = i_owner_capture_valid & w_owner_capture_context_valid;
      w_owner_capture_take[i_owner_capture_tag] = w_owner_capture_accepted;
    end
    if (32'(i_phase_start_tag) < PARA_COH_TXN_NUM) begin
      o_phase_start_ready = reg_ctx_valid[i_phase_start_tag]
                          & ~reg_ctx_phase_active[i_phase_start_tag]
                          & ((i_phase_start != 2'(LPARA_COH_PHASE_PREPARE))
                             | reg_ctx_owner_known[i_phase_start_tag])
                          & ((i_phase_start != 2'(LPARA_COH_PHASE_COMMIT))
                             | (~reg_ctx_txn_err[i_phase_start_tag]
                                & ~reg_ctx_owner_wback_err[i_phase_start_tag]))
                          & ((i_phase_start == 2'(LPARA_COH_PHASE_PREPARE))
                          | (i_phase_start == 2'(LPARA_COH_PHASE_COMMIT))
                          | (i_phase_start == 2'(LPARA_COH_PHASE_ABORT)));
    end
  end

  // Allocate the lowest free tag and prevent two active contexts from locking one line.
  always_comb begin : p_com_coh_alloc
    w_alloc_found = 1'b0;
    w_alloc_line_busy = 1'b0;
    w_alloc_tag = '0;
    for (int slot_idx = 0; slot_idx < PARA_COH_TXN_NUM; slot_idx++) begin
      if (~reg_ctx_valid[slot_idx] & ~w_alloc_found) begin
        w_alloc_found = 1'b1;
        w_alloc_tag = $bits(w_alloc_tag)'(slot_idx);
      end
      if (reg_ctx_valid[slot_idx] & (reg_ctx_pa_line[slot_idx] == i_alloc_pa_line))
        w_alloc_line_busy = 1'b1;
    end
  end

  // Drain every ACK; only a unique expected ACK may update its context.
  always_comb begin : p_com_coh_ack_match
    o_ack_ready = '1;
    w_ack_take = '0;
    w_ack_err = '0;
    w_ack_wback_done = '0;
    w_ack_owner_wback_err = '0;
    w_ack_valid_match = '0;
    for (int hart_idx = 0; hart_idx < PARA_CPU_NUM; hart_idx++) begin
      if (32'(i_ack_tag[hart_idx]) < PARA_COH_TXN_NUM) begin
        if (reg_ctx_valid[i_ack_tag[hart_idx]]
            & reg_ctx_phase_active[i_ack_tag[hart_idx]]
            & (reg_ctx_phase[i_ack_tag[hart_idx]] == i_ack_phase[hart_idx])
            & reg_ctx_ack_expected[i_ack_tag[hart_idx]][hart_idx]
            & ~reg_ctx_ack_received[i_ack_tag[hart_idx]][hart_idx])
          w_ack_valid_match[hart_idx] = 1'b1;
      end
    end
    for (int slot_idx = 0; slot_idx < PARA_COH_TXN_NUM; slot_idx++) begin
      for (int hart_idx = 0; hart_idx < PARA_CPU_NUM; hart_idx++) begin
        if (i_ack_valid[hart_idx] & w_ack_valid_match[hart_idx]
            & (32'(i_ack_tag[hart_idx]) == slot_idx)) begin
          w_ack_take[slot_idx][hart_idx] = 1'b1;
          w_ack_err[slot_idx] = w_ack_err[slot_idx] | i_ack_err[hart_idx];
          if ((reg_ctx_phase[slot_idx] == 2'(LPARA_COH_PHASE_PREPARE))
              & reg_ctx_owner_present[slot_idx]
              & (reg_ctx_owner_hart[slot_idx] == 2'(hart_idx))) begin
            w_ack_wback_done[slot_idx] = w_ack_wback_done[slot_idx]
                                       | (i_ack_wback_done[hart_idx] & ~i_ack_err[hart_idx]);
            w_ack_owner_wback_err[slot_idx] = w_ack_owner_wback_err[slot_idx]
                                            | i_ack_err[hart_idx];
          end
        end
      end
    end
    o_coh_proto_diag_event = |(i_ack_valid & ~w_ack_valid_match)
                           | (i_owner_capture_valid
                              & ~(w_owner_capture_tag_valid & w_owner_capture_context_valid));
  end

  // Store context metadata and complete a phase only after every expected ACK arrives.
  always_ff @(posedge i_clk_cluster, negedge i_rst_n_cluster) begin : p_ff_coh_context
    if (!i_rst_n_cluster) begin
      reg_ctx_valid <= '0;
      reg_ctx_src <= '0;
      reg_ctx_req_id <= '0;
      reg_ctx_pa_line <= '0;
      reg_ctx_kind <= '0;
      reg_ctx_target_state <= '0;
      reg_ctx_wback_en <= '0;
      reg_ctx_owner_known <= '0;
      reg_ctx_owner_present <= '0;
      reg_ctx_owner_hart <= '0;
      reg_ctx_phase <= '0;
      reg_ctx_ack_expected <= '0;
      reg_ctx_ack_received <= '0;
      reg_ctx_phase_active <= '0;
      reg_ctx_phase_done <= '0;
      reg_ctx_phase_err <= '0;
      reg_ctx_owner_wback_done <= '0;
      reg_ctx_txn_err <= '0;
      reg_ctx_owner_wback_err <= '0;
    end else begin
      for (int slot_idx = 0; slot_idx < PARA_COH_TXN_NUM; slot_idx++) begin
        casez ({(i_alloc_valid & o_alloc_ready
                 & (w_alloc_tag == $bits(w_alloc_tag)'(slot_idx))),
                (i_release_valid & o_release_ready
                 & (32'(i_release_tag) == slot_idx)),
                (i_phase_start_valid & o_phase_start_ready
                 & (32'(i_phase_start_tag) == slot_idx)),
                (|w_ack_take[slot_idx])})
          4'b1???: begin
          reg_ctx_valid[slot_idx] <= 1'b1;
          reg_ctx_src[slot_idx] <= i_alloc_src;
          reg_ctx_req_id[slot_idx] <= i_alloc_req_id;
          reg_ctx_pa_line[slot_idx] <= i_alloc_pa_line;
          reg_ctx_kind[slot_idx] <= i_alloc_kind;
          reg_ctx_target_state[slot_idx] <= i_alloc_target_state;
          reg_ctx_wback_en[slot_idx] <= i_alloc_wback_en;
          reg_ctx_owner_known[slot_idx] <= 1'b0;
          reg_ctx_owner_present[slot_idx] <= 1'b0;
          reg_ctx_owner_hart[slot_idx] <= '0;
          reg_ctx_phase[slot_idx] <= '0;
          reg_ctx_ack_expected[slot_idx] <= '0;
          reg_ctx_ack_received[slot_idx] <= '0;
          reg_ctx_phase_active[slot_idx] <= 1'b0;
          reg_ctx_phase_done[slot_idx] <= 1'b0;
          reg_ctx_phase_err[slot_idx] <= 1'b0;
          reg_ctx_owner_wback_done[slot_idx] <= 1'b0;
          reg_ctx_txn_err[slot_idx] <= 1'b0;
          reg_ctx_owner_wback_err[slot_idx] <= 1'b0;
          end
          4'b01??: begin
          reg_ctx_valid[slot_idx] <= 1'b0;
          reg_ctx_phase_active[slot_idx] <= 1'b0;
          reg_ctx_phase_done[slot_idx] <= 1'b0;
          end
          4'b001?: begin
          reg_ctx_phase[slot_idx] <= i_phase_start;
          reg_ctx_ack_expected[slot_idx] <= i_phase_expected;
          reg_ctx_ack_received[slot_idx] <= '0;
          reg_ctx_phase_active[slot_idx] <= |i_phase_expected;
          reg_ctx_phase_done[slot_idx] <= ~(|i_phase_expected);
          reg_ctx_phase_err[slot_idx] <= 1'b0;
          end
          4'b0001: begin
          reg_ctx_ack_received[slot_idx] <= reg_ctx_ack_received[slot_idx]
                                          | w_ack_take[slot_idx];
          reg_ctx_phase_err[slot_idx] <= reg_ctx_phase_err[slot_idx]
                                       | w_ack_err[slot_idx];
          reg_ctx_owner_wback_done[slot_idx] <= reg_ctx_owner_wback_done[slot_idx]
                                              | w_ack_wback_done[slot_idx];
          reg_ctx_txn_err[slot_idx] <= reg_ctx_txn_err[slot_idx] | w_ack_err[slot_idx];
          reg_ctx_owner_wback_err[slot_idx] <= reg_ctx_owner_wback_err[slot_idx]
                                            | w_ack_owner_wback_err[slot_idx];
          if ((reg_ctx_ack_received[slot_idx] | w_ack_take[slot_idx])
              == reg_ctx_ack_expected[slot_idx]) begin
            reg_ctx_phase_active[slot_idx] <= 1'b0;
            reg_ctx_phase_done[slot_idx] <= 1'b1;
          end
          end
          default: begin
          end
        endcase
        if (w_owner_capture_take[slot_idx]) begin
          reg_ctx_owner_known[slot_idx] <= 1'b1;
          reg_ctx_owner_present[slot_idx] <= i_owner_capture_present;
          reg_ctx_owner_hart[slot_idx] <= i_owner_capture_hart;
        end
      end
    end
  end

endmodule
