/*
 * Project      : VLSIT RISC-V CPU Cluster
 * Author       : Quan Nguyen (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-08
 * Description  : Schedules one active coherence transaction per directory bank.
 * Change History:
 * 2026-11-09 - Modified by Quan Nguyen and Codex - VLSI Technology page:
 *              Added per-slot token consumption and VALID-low rearm so a held
 *              request cannot receive duplicate grants (REQ-MEM-022).
 */
`timescale 1ns/1ps

module m_vlsit_riscv_coh_bank_arb #(
  // Parameter Description: number of active coherence transaction slots.
  // Parameter values: legal range is 2 through 16; default is 8.
  // Parameter unit: slots
  parameter logic [31:0] PARA_COH_TXN_NUM = 32'd8,
  localparam logic [31:0] LPARA_COH_SLOT_W = (PARA_COH_TXN_NUM > 32'd1)
                                             ? 32'($clog2(PARA_COH_TXN_NUM)) : 32'd1
) (
  // Clock and active-low reset
  input  wire                              i_clk_cluster,
  input  wire                              i_rst_n_cluster,

  // Active transaction slots request service from one of four fixed banks.
  input  wire  [PARA_COH_TXN_NUM-1:0]      i_req_valid,
  input  wire  [PARA_COH_TXN_NUM-1:0][1:0] i_req_bank,

  // Each bank holds its selected slot until the consumer accepts the grant.
  input  wire  [3:0]                       i_gnt_ready,
  output logic [3:0]                       o_gnt_valid,
  output logic [3:0][LPARA_COH_SLOT_W-1:0] o_gnt_slot,
  output logic                             o_bank_conflict_stall
);

  logic [3:0] w_bank_conflict_stall;

  // Each bank selects independently and holds its grant while backpressured.
  for (genvar g_bank = 0; g_bank < 4; g_bank++) begin : gen_bank
    logic reg_gnt_valid;
    logic [LPARA_COH_SLOT_W-1:0] reg_gnt_slot;
    logic [LPARA_COH_SLOT_W-1:0] reg_rr_slot;
    logic [LPARA_COH_SLOT_W-1:0] w_start_slot;
    logic [LPARA_COH_SLOT_W-1:0] w_pick_slot;
    logic [LPARA_COH_SLOT_W-1:0] w_rr_slot_nxt;
    logic [31:0] w_scan_slot;
    logic w_pick_valid;
    logic w_gnt_valid_nxt;
    logic [LPARA_COH_SLOT_W-1:0] w_gnt_slot_nxt;
    logic [PARA_COH_TXN_NUM-1:0] reg_req_armed;
    logic w_gnt_hs;

    // Identify an accepted grant for the per-slot token state update.
    assign w_gnt_hs = reg_gnt_valid & i_gnt_ready[g_bank];
    // Another eligible operation is waiting behind this bank's active grant.
    assign w_bank_conflict_stall[g_bank] = reg_gnt_valid & w_pick_valid;

    // Search active slots from the current round-robin position.
    // If a held grant is accepted, search begins immediately after that slot.
    always_comb begin : p_com_pick
      w_start_slot = reg_rr_slot;
      if (reg_gnt_valid && i_gnt_ready[g_bank]) begin
        if (reg_gnt_slot == LPARA_COH_SLOT_W'(PARA_COH_TXN_NUM - 32'd1)) begin
          w_start_slot = '0;
        end else begin
          w_start_slot = reg_gnt_slot + 1'b1;
        end
      end

      w_scan_slot = '0;
      w_pick_valid = 1'b0;
      w_pick_slot = '0;
      for (int slot_idx = 0; slot_idx < PARA_COH_TXN_NUM; slot_idx++) begin
        w_scan_slot = 32'(w_start_slot) + 32'(slot_idx);
        if (w_scan_slot >= PARA_COH_TXN_NUM) begin
          w_scan_slot = w_scan_slot - PARA_COH_TXN_NUM;
        end

        if (!w_pick_valid
            && i_req_valid[w_scan_slot]
            && reg_req_armed[w_scan_slot]
            && (i_req_bank[w_scan_slot] == 2'(g_bank))
            && !(reg_gnt_valid
                 && i_gnt_ready[g_bank]
                 && (w_scan_slot == 32'(reg_gnt_slot)))) begin
          w_pick_valid = 1'b1;
          w_pick_slot = LPARA_COH_SLOT_W'(w_scan_slot);
        end
      end
    end

    // Keep the grant stable during backpressure; replace it on acceptance.
    always_comb begin : p_com_nxt
      w_rr_slot_nxt = reg_rr_slot;
      w_gnt_valid_nxt = reg_gnt_valid;
      w_gnt_slot_nxt = reg_gnt_slot;

      if (!reg_gnt_valid || i_gnt_ready[g_bank]) begin
        if (reg_gnt_valid && i_gnt_ready[g_bank]) begin
          w_rr_slot_nxt = w_start_slot;
        end

        w_gnt_valid_nxt = w_pick_valid;
        if (w_pick_valid) begin
          w_gnt_slot_nxt = w_pick_slot;
        end
      end
    end

    // Register the bank-local grant and fairness pointer.
    always_ff @(posedge i_clk_cluster, negedge i_rst_n_cluster) begin : p_ff_gnt
      if (!i_rst_n_cluster) begin
        reg_gnt_valid <= 1'b0;
        reg_gnt_slot <= '0;
        reg_rr_slot <= '0;
        reg_req_armed <= '1;
      end else begin
        reg_gnt_valid <= w_gnt_valid_nxt;
        reg_gnt_slot <= w_gnt_slot_nxt;
        reg_rr_slot <= w_rr_slot_nxt;
        for (int slot_idx = 0; slot_idx < PARA_COH_TXN_NUM; slot_idx++) begin
          if (!i_req_valid[slot_idx])
            reg_req_armed[slot_idx] <= 1'b1;
          if (w_gnt_hs && (reg_gnt_slot == LPARA_COH_SLOT_W'(slot_idx)))
            reg_req_armed[slot_idx] <= 1'b0;
        end
      end
    end

    // Expose this bank's buffered slot grant.
    assign o_gnt_valid[g_bank] = reg_gnt_valid;
    assign o_gnt_slot[g_bank] = reg_gnt_slot;
  end

  // Count at most one cluster stall cycle even if multiple banks conflict.
  assign o_bank_conflict_stall = |w_bank_conflict_stall;

endmodule
