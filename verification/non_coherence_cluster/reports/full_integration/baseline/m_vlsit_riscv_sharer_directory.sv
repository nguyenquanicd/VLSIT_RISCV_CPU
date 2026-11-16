/*
 * Project      : VLSIT RISC-V CPU Cluster
 * Author       : Quan Nguyen (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-08
 * Description  : Four-bank MESI directory with tagged replacement reservations.
 */
`timescale 1ns/1ps

module m_vlsit_riscv_sharer_directory #(
  // Parameter Description: number of active CPU harts in the cluster.
  // Parameter values: 2 or 4; default is 4.
  // Parameter unit: harts
  parameter logic [31:0] PARA_CPU_NUM = 32'd4,
  // Parameter Description: number of concurrent coherence transaction contexts.
  // Parameter values: 2 through 16; default is 8.
  // Parameter unit: contexts
  parameter logic [31:0] PARA_COH_TXN_NUM = 32'd8,
  localparam logic [31:0] LPARA_DIR_BANK_NUM = 32'd4,
  localparam logic [31:0] LPARA_DIR_WAY_NUM = 32'd8,
  localparam logic [31:0] LPARA_DIR_SET_NUM = PARA_CPU_NUM * 32'd64,
  localparam logic [31:0] LPARA_DIR_SET_W = 32'($clog2(LPARA_DIR_SET_NUM)),
  localparam logic [31:0] LPARA_DIR_TAG_W = 32'd52 - 32'd2 - LPARA_DIR_SET_W,
  localparam logic [31:0] LPARA_COH_TAG_W = (PARA_COH_TXN_NUM > 32'd1)
                                            ? 32'($clog2(PARA_COH_TXN_NUM)) : 32'd1,
  localparam logic [31:0] LPARA_MESI_I = 32'd0,
  localparam logic [31:0] LPARA_MESI_S = 32'd1,
  localparam logic [31:0] LPARA_MESI_E = 32'd2,
  localparam logic [31:0] LPARA_MESI_M = 32'd3
) (
  // Clock and reset
  input  wire                             i_clk_cluster,
  input  wire                             i_rst_n_cluster,

  // Four independent directory lookup request banks
  input  wire  [3:0]                      i_lookup_valid,
  output logic [3:0]                      o_lookup_ready,
  input  wire  [3:0][51:0]                i_lookup_pa_line,
  input  wire  [3:0][LPARA_COH_TAG_W-1:0] i_lookup_tag,

  // Lookup response with replacement candidate and current victim metadata
  output logic [3:0]                      o_lookup_rsp_valid,
  input  wire  [3:0]                      i_lookup_rsp_ready,
  output logic [3:0]                      o_lookup_hit,
  output logic [3:0][LPARA_COH_TAG_W-1:0] o_lookup_rsp_tag,
  output logic [3:0][2:0]                 o_lookup_way,
  output logic [3:0]                      o_lookup_victim_valid,
  output logic [3:0][51:0]                o_lookup_victim_pa_line,
  output logic [3:0][PARA_CPU_NUM-1:0]    o_lookup_holders,
  output logic [3:0][1:0]                 o_lookup_owner,
  output logic [3:0][1:0]                 o_lookup_state,

  // Commit a directory state only after all cache COMMIT acknowledgements
  input  wire  [3:0]                      i_update_valid,
  output logic [3:0]                      o_update_ready,
  input  wire  [3:0][LPARA_COH_TAG_W-1:0] i_update_tag,
  input  wire  [3:0][51:0]                i_update_pa_line,
  input  wire  [3:0][2:0]                 i_update_way,
  input  wire  [3:0][PARA_CPU_NUM-1:0]    i_update_holders,
  input  wire  [3:0][1:0]                 i_update_owner,
  input  wire  [3:0][1:0]                 i_update_state,

  // Release a reserved replacement candidate after a pre-COMMIT abort
  input  wire  [3:0]                      i_cancel_valid,
  output logic [3:0]                      o_cancel_ready,
  input  wire  [3:0][LPARA_COH_TAG_W-1:0] i_cancel_tag,
  input  wire  [3:0][51:0]                i_cancel_pa_line,

  // Accepted operations for the cluster PMU occurrence counters
  output logic [2:0]                      o_dir_lookup_count,
  output logic [2:0]                      o_dir_update_count
);

  logic [LPARA_DIR_TAG_W-1:0] reg_dir_tag [3:0][LPARA_DIR_SET_NUM-1:0][LPARA_DIR_WAY_NUM-1:0];
  logic [PARA_CPU_NUM-1:0] reg_dir_holders [3:0][LPARA_DIR_SET_NUM-1:0][LPARA_DIR_WAY_NUM-1:0];
  logic [1:0] reg_dir_owner [3:0][LPARA_DIR_SET_NUM-1:0][LPARA_DIR_WAY_NUM-1:0];
  logic [1:0] reg_dir_state [3:0][LPARA_DIR_SET_NUM-1:0][LPARA_DIR_WAY_NUM-1:0];
  logic reg_dir_valid [3:0][LPARA_DIR_SET_NUM-1:0][LPARA_DIR_WAY_NUM-1:0];
  logic [6:0] reg_dir_plru [3:0][LPARA_DIR_SET_NUM-1:0];
  logic reg_dir_resv_valid [3:0][LPARA_DIR_SET_NUM-1:0];
  logic [LPARA_COH_TAG_W-1:0] reg_dir_resv_tag [3:0][LPARA_DIR_SET_NUM-1:0];
  logic [3:0] reg_lookup_rsp_valid;
  logic [3:0] reg_lookup_hit;
  logic [3:0][LPARA_COH_TAG_W-1:0] reg_lookup_rsp_tag;
  logic [3:0][2:0] reg_lookup_way;
  logic [3:0] reg_lookup_victim_valid;
  logic [3:0][51:0] reg_lookup_victim_pa_line;
  logic [3:0][PARA_CPU_NUM-1:0] reg_lookup_holders;
  logic [3:0][1:0] reg_lookup_owner;
  logic [3:0][1:0] reg_lookup_state;
  logic [3:0] w_lookup_hs;
  logic [3:0] w_update_hs;
  logic [3:0] w_cancel_hs;
  logic [3:0] w_lookup_bank_match;
  logic [3:0] w_update_bank_match;
  logic [3:0] w_cancel_bank_match;
  logic [3:0] w_lookup_set_busy;
  logic [3:0] w_update_set_busy;
  logic [3:0][LPARA_DIR_SET_W-1:0] w_lookup_set;
  logic [3:0][LPARA_DIR_SET_W-1:0] w_update_set;
  logic [3:0][LPARA_DIR_SET_W-1:0] w_cancel_set;
  logic [3:0][LPARA_DIR_TAG_W-1:0] w_lookup_tag;
  logic [3:0] w_lookup_hit;
  logic [3:0][2:0] w_lookup_hit_way;
  logic [3:0] w_lookup_invalid_found;
  logic [3:0][2:0] w_lookup_victim_way;
  logic [3:0] w_lookup_victim_valid;
  logic [3:0][51:0] w_lookup_victim_pa_line;
  logic [3:0][PARA_CPU_NUM-1:0] w_lookup_holders;
  logic [3:0][1:0] w_lookup_owner;
  logic [3:0][1:0] w_lookup_state;
  logic [2:0] w_lookup_count;
  logic [2:0] w_update_count;

  // Expose the registered lookup result and one-cycle PMU occurrence counts.
  assign o_lookup_rsp_valid = reg_lookup_rsp_valid;
  assign o_lookup_hit = reg_lookup_hit;
  assign o_lookup_rsp_tag = reg_lookup_rsp_tag;
  assign o_lookup_way = reg_lookup_way;
  assign o_lookup_victim_valid = reg_lookup_victim_valid;
  assign o_lookup_victim_pa_line = reg_lookup_victim_pa_line;
  assign o_lookup_holders = reg_lookup_holders;
  assign o_lookup_owner = reg_lookup_owner;
  assign o_lookup_state = reg_lookup_state;
  assign o_dir_lookup_count = w_lookup_count;
  assign o_dir_update_count = w_update_count;
  assign w_lookup_hs = i_lookup_valid & o_lookup_ready;
  assign w_update_hs = i_update_valid & o_update_ready;
  assign w_cancel_hs = i_cancel_valid & o_cancel_ready;

  // Find the matching line and the invalid-first, tree-PLRU replacement candidate.
  always_comb begin : p_com_dir_lookup
    w_lookup_bank_match = '0;
    w_update_bank_match = '0;
    w_cancel_bank_match = '0;
    w_lookup_set_busy = '0;
    w_update_set_busy = '0;
    w_lookup_set = '0;
    w_update_set = '0;
    w_cancel_set = '0;
    w_lookup_tag = '0;
    w_lookup_hit = '0;
    w_lookup_hit_way = '0;
    w_lookup_invalid_found = '0;
    w_lookup_victim_way = '0;
    w_lookup_victim_valid = '0;
    w_lookup_victim_pa_line = '0;
    w_lookup_holders = '0;
    w_lookup_owner = '0;
    w_lookup_state = '0;
    w_lookup_count = '0;
    w_update_count = '0;
    for (int bank_idx = 0; bank_idx < LPARA_DIR_BANK_NUM; bank_idx++) begin
      w_lookup_bank_match[bank_idx] = (i_lookup_pa_line[bank_idx][1:0] == 2'(bank_idx));
      w_update_bank_match[bank_idx] = (i_update_pa_line[bank_idx][1:0] == 2'(bank_idx));
      w_cancel_bank_match[bank_idx] = (i_cancel_pa_line[bank_idx][1:0] == 2'(bank_idx));
      w_lookup_set[bank_idx] = i_lookup_pa_line[bank_idx][2 +: LPARA_DIR_SET_W];
      w_update_set[bank_idx] = i_update_pa_line[bank_idx][2 +: LPARA_DIR_SET_W];
      w_cancel_set[bank_idx] = i_cancel_pa_line[bank_idx][2 +: LPARA_DIR_SET_W];
      w_lookup_tag[bank_idx] = i_lookup_pa_line[bank_idx][2 + LPARA_DIR_SET_W +: LPARA_DIR_TAG_W];
      w_lookup_set_busy[bank_idx] = reg_dir_resv_valid[bank_idx][w_lookup_set[bank_idx]];
      w_update_set_busy[bank_idx] = reg_dir_resv_valid[bank_idx][w_update_set[bank_idx]]
                                  & (reg_dir_resv_tag[bank_idx][w_update_set[bank_idx]]
                                     != i_update_tag[bank_idx]);
      for (int way_idx = 0; way_idx < LPARA_DIR_WAY_NUM; way_idx++) begin
        if (reg_dir_valid[bank_idx][w_lookup_set[bank_idx]][way_idx]
            & (reg_dir_tag[bank_idx][w_lookup_set[bank_idx]][way_idx] == w_lookup_tag[bank_idx])
            & ~w_lookup_hit[bank_idx]) begin
          w_lookup_hit[bank_idx] = 1'b1;
          w_lookup_hit_way[bank_idx] = 3'(way_idx);
        end
        if (~reg_dir_valid[bank_idx][w_lookup_set[bank_idx]][way_idx]
            & ~w_lookup_invalid_found[bank_idx]) begin
          w_lookup_invalid_found[bank_idx] = 1'b1;
          w_lookup_victim_way[bank_idx] = 3'(way_idx);
        end
      end
      if (~w_lookup_hit[bank_idx]) begin
        if (~w_lookup_invalid_found[bank_idx]) begin
          w_lookup_victim_way[bank_idx] = fun_plru_victim(reg_dir_plru[bank_idx][w_lookup_set[bank_idx]]);
          w_lookup_victim_valid[bank_idx] = 1'b1;
          w_lookup_victim_pa_line[bank_idx] = {
            reg_dir_tag[bank_idx][w_lookup_set[bank_idx]][w_lookup_victim_way[bank_idx]],
            w_lookup_set[bank_idx], 2'(bank_idx)
          };
          w_lookup_holders[bank_idx] = reg_dir_holders[bank_idx]
                                       [w_lookup_set[bank_idx]][w_lookup_victim_way[bank_idx]];
          w_lookup_owner[bank_idx] = reg_dir_owner[bank_idx]
                                     [w_lookup_set[bank_idx]][w_lookup_victim_way[bank_idx]];
          w_lookup_state[bank_idx] = reg_dir_state[bank_idx]
                                     [w_lookup_set[bank_idx]][w_lookup_victim_way[bank_idx]];
        end
      end else begin
        w_lookup_victim_way[bank_idx] = w_lookup_hit_way[bank_idx];
        w_lookup_holders[bank_idx] = reg_dir_holders[bank_idx]
                                     [w_lookup_set[bank_idx]][w_lookup_hit_way[bank_idx]];
        w_lookup_owner[bank_idx] = reg_dir_owner[bank_idx]
                                   [w_lookup_set[bank_idx]][w_lookup_hit_way[bank_idx]];
        w_lookup_state[bank_idx] = reg_dir_state[bank_idx]
                                   [w_lookup_set[bank_idx]][w_lookup_hit_way[bank_idx]];
      end
      if (w_lookup_hs[bank_idx])
        w_lookup_count = w_lookup_count + 3'd1;
      if (w_update_hs[bank_idx])
        w_update_count = w_update_count + 3'd1;
    end
  end

  // Arbitrate one directory operation per bank and hold a stalled response stable.
  always_comb begin : p_com_dir_ready
    o_lookup_ready = '0;
    o_update_ready = '0;
    o_cancel_ready = '0;
    for (int bank_idx = 0; bank_idx < LPARA_DIR_BANK_NUM; bank_idx++) begin
      casez ({i_update_valid[bank_idx], i_cancel_valid[bank_idx]})
        2'b1?: o_update_ready[bank_idx] = w_update_bank_match[bank_idx]
                                        & ~w_update_set_busy[bank_idx];
        2'b01: o_cancel_ready[bank_idx] = w_cancel_bank_match[bank_idx];
        default: begin
          if (~reg_lookup_rsp_valid[bank_idx] | i_lookup_rsp_ready[bank_idx]) begin
            case (i_lookup_valid[bank_idx])
              1'b1: o_lookup_ready[bank_idx] = w_lookup_bank_match[bank_idx]
                                             & ~w_lookup_set_busy[bank_idx];
              default: begin
                o_lookup_ready[bank_idx] = 1'b1;
                o_update_ready[bank_idx] = 1'b1;
                o_cancel_ready[bank_idx] = 1'b1;
              end
            endcase
          end
        end
      endcase
    end
  end

  // The PLRU bits point away from the most recently accessed child at each tree node.
  function automatic logic [6:0] fun_plru_update(input logic [6:0] i_plru,
                                                  input logic [2:0] i_way);
    logic [6:0] w_plru;
    w_plru = i_plru;
    w_plru[0] = ~i_way[2];
    if (~i_way[2]) begin
      w_plru[1] = ~i_way[1];
      if (~i_way[1])
        w_plru[3] = ~i_way[0];
      else
        w_plru[4] = ~i_way[0];
    end else begin
      w_plru[2] = ~i_way[1];
      if (~i_way[1])
        w_plru[5] = ~i_way[0];
      else
        w_plru[6] = ~i_way[0];
    end
    return w_plru;
  endfunction

  // Walk the tree-selected least-recently-used directions to choose an eight-way victim.
  function automatic logic [2:0] fun_plru_victim(input logic [6:0] i_plru);
    logic [2:0] w_way;
    w_way[2] = i_plru[0];
    w_way[1] = w_way[2] ? i_plru[2] : i_plru[1];
    if (w_way[2])
      w_way[0] = w_way[1] ? i_plru[6] : i_plru[5];
    else
      w_way[0] = w_way[1] ? i_plru[4] : i_plru[3];
    return w_way;
  endfunction

  // Reset only valid and PLRU metadata; tag and owner arrays are ignored while invalid.
  always_ff @(posedge i_clk_cluster, negedge i_rst_n_cluster) begin : p_ff_dir_storage
    if (!i_rst_n_cluster) begin
      reg_lookup_rsp_valid <= '0;
      reg_lookup_hit <= '0;
      reg_lookup_rsp_tag <= '0;
      reg_lookup_way <= '0;
      reg_lookup_victim_valid <= '0;
      reg_lookup_victim_pa_line <= '0;
      reg_lookup_holders <= '0;
      reg_lookup_owner <= '0;
      reg_lookup_state <= '0;
      for (int bank_idx = 0; bank_idx < LPARA_DIR_BANK_NUM; bank_idx++) begin
        for (int set_idx = 0; set_idx < LPARA_DIR_SET_NUM; set_idx++) begin
          reg_dir_plru[bank_idx][set_idx] <= '0;
          reg_dir_resv_valid[bank_idx][set_idx] <= 1'b0;
          for (int way_idx = 0; way_idx < LPARA_DIR_WAY_NUM; way_idx++)
            reg_dir_valid[bank_idx][set_idx][way_idx] <= 1'b0;
        end
      end
    end else begin
      for (int bank_idx = 0; bank_idx < LPARA_DIR_BANK_NUM; bank_idx++) begin
        if (~reg_lookup_rsp_valid[bank_idx] | i_lookup_rsp_ready[bank_idx]) begin
          reg_lookup_rsp_valid[bank_idx] <= w_lookup_hs[bank_idx];
          if (w_lookup_hs[bank_idx]) begin
            reg_lookup_hit[bank_idx] <= w_lookup_hit[bank_idx];
            reg_lookup_rsp_tag[bank_idx] <= i_lookup_tag[bank_idx];
            reg_lookup_way[bank_idx] <= w_lookup_hit[bank_idx]
                                     ? w_lookup_hit_way[bank_idx]
                                     : w_lookup_victim_way[bank_idx];
            reg_lookup_victim_valid[bank_idx] <= w_lookup_victim_valid[bank_idx];
            reg_lookup_victim_pa_line[bank_idx] <= w_lookup_victim_pa_line[bank_idx];
            reg_lookup_holders[bank_idx] <= w_lookup_holders[bank_idx];
            reg_lookup_owner[bank_idx] <= w_lookup_owner[bank_idx];
            reg_lookup_state[bank_idx] <= w_lookup_state[bank_idx];
          end
        end
        if (w_lookup_hs[bank_idx] & w_lookup_hit[bank_idx])
          reg_dir_plru[bank_idx][w_lookup_set[bank_idx]] <=
            fun_plru_update(reg_dir_plru[bank_idx][w_lookup_set[bank_idx]],
                            w_lookup_hit_way[bank_idx]);
        if (w_lookup_hs[bank_idx] & ~w_lookup_hit[bank_idx]) begin
          reg_dir_resv_valid[bank_idx][w_lookup_set[bank_idx]] <= 1'b1;
          reg_dir_resv_tag[bank_idx][w_lookup_set[bank_idx]] <= i_lookup_tag[bank_idx];
        end
        if (w_update_hs[bank_idx]) begin
          case (i_update_state[bank_idx])
            2'(LPARA_MESI_I):
              reg_dir_valid[bank_idx][w_update_set[bank_idx]][i_update_way[bank_idx]] <= 1'b0;
            2'(LPARA_MESI_S),
            2'(LPARA_MESI_E),
            2'(LPARA_MESI_M):
              reg_dir_valid[bank_idx][w_update_set[bank_idx]][i_update_way[bank_idx]] <=
                |i_update_holders[bank_idx];
            default:
              reg_dir_valid[bank_idx][w_update_set[bank_idx]][i_update_way[bank_idx]] <= 1'b0;
          endcase
          reg_dir_tag[bank_idx][w_update_set[bank_idx]][i_update_way[bank_idx]] <=
            i_update_pa_line[bank_idx][2 + LPARA_DIR_SET_W +: LPARA_DIR_TAG_W];
          reg_dir_holders[bank_idx][w_update_set[bank_idx]][i_update_way[bank_idx]] <=
            i_update_holders[bank_idx];
          reg_dir_owner[bank_idx][w_update_set[bank_idx]][i_update_way[bank_idx]] <=
            i_update_owner[bank_idx];
          reg_dir_state[bank_idx][w_update_set[bank_idx]][i_update_way[bank_idx]] <=
            i_update_state[bank_idx];
          reg_dir_plru[bank_idx][w_update_set[bank_idx]] <=
            fun_plru_update(reg_dir_plru[bank_idx][w_update_set[bank_idx]],
                            i_update_way[bank_idx]);
          if (reg_dir_resv_valid[bank_idx][w_update_set[bank_idx]]
              & (reg_dir_resv_tag[bank_idx][w_update_set[bank_idx]] == i_update_tag[bank_idx]))
            reg_dir_resv_valid[bank_idx][w_update_set[bank_idx]] <= 1'b0;
        end
        if (w_cancel_hs[bank_idx]
            & reg_dir_resv_valid[bank_idx][w_cancel_set[bank_idx]]
            & (reg_dir_resv_tag[bank_idx][w_cancel_set[bank_idx]] == i_cancel_tag[bank_idx]))
          reg_dir_resv_valid[bank_idx][w_cancel_set[bank_idx]] <= 1'b0;
      end
    end
  end

endmodule
