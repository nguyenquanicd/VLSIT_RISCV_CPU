/*
 * Project      : VLSIT RISC-V CPU Cluster
 * Author       : Quan Nguyen (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-08
 * Description  : Four-bank MESI directory with tagged replacement reservations.
 * Change History:
 * 2026-11-09 - Modified by Quan Nguyen and Codex - VLSI Technology page:
 *              Added v0.19 eligibility-first round-robin arbitration, matching
 *              reservation-owner terminal escape, and protocol diagnostic event
 *              for simultaneous owner UPDATE/CANCEL (REQ-MEM-019/020).
 * 2026-11-14 - Modified by Quan Nguyen and Codex - VLSI Technology page:
 *              Qualify simultaneous UPDATE/CANCEL diagnostics with both request
 *              VALID signals to prevent default inactive payloads from blocking
 *              a reservation owner.
 * History      : Quan Nguyen and Codex - VLSI Technology page.
 *                DEC-045: Add optional cluster boundary timing profile support.
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
  // Parameter Description: use synchronous directory storage.
  // Parameter values: 0 = legacy, 1 = synchronous; default is 0.
  // Parameter unit: mode
  parameter logic [31:0] PARA_DIR_SYNC_READ = 32'd0,
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
  localparam logic [31:0] LPARA_MESI_M = 32'd3,
  localparam logic [31:0] LPARA_DIR_OP_LOOKUP = 32'd0,
  localparam logic [31:0] LPARA_DIR_OP_UPDATE = 32'd1,
  localparam logic [31:0] LPARA_DIR_OP_CANCEL = 32'd2,
  localparam logic [31:0] LPARA_DIR_OP_COUNT = 32'd3
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
  output logic [2:0]                      o_dir_update_count,
  output logic [3:0]                      o_coh_proto_diag_event
);

  typedef struct packed {
    logic [LPARA_DIR_TAG_W-1:0] tag;
    logic [PARA_CPU_NUM-1:0] holders;
    logic [1:0] owner;
    logic [1:0] state;
  } dir_entry_type_def;

  dir_entry_type_def w_lookup_entry [3:0][LPARA_DIR_WAY_NUM-1:0];
  logic [3:0][LPARA_DIR_WAY_NUM-1:0] w_lookup_valid_ways;
  logic [3:0][6:0] w_lookup_plru;
  logic [3:0] w_lookup_eval, w_read_slot_ready;
  logic [3:0][LPARA_DIR_SET_W-1:0] w_eval_set;
  logic [3:0][LPARA_DIR_TAG_W-1:0] w_eval_tag;
  logic [3:0][LPARA_COH_TAG_W-1:0] w_eval_rsp_tag;
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
  logic [3:0] w_lookup_eligible;
  logic [3:0] w_update_eligible;
  logic [3:0] w_cancel_eligible;
  logic [3:0] w_update_owner_match;
  logic [3:0] w_cancel_owner_match;
  logic [3:0] w_owner_terminal_conflict;
  logic [3:0] w_lookup_rsp_slot_ready;
  logic [3:0][1:0] reg_dir_op_rr_ptr;
  logic [3:0][1:0] w_dir_op_rr_ptr_nxt;
  logic [3:0][1:0] w_dir_op_selected;
  logic [3:0] w_dir_op_selected_valid;
  logic [3:0][31:0] w_dir_op_scan;
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
  assign o_coh_proto_diag_event = w_owner_terminal_conflict;
  assign w_lookup_hs = i_lookup_valid & o_lookup_ready;
  assign w_update_hs = i_update_valid & o_update_ready;
  assign w_cancel_hs = i_cancel_valid & o_cancel_ready;

  // A bank has an elastic read stage and an independent response register.
  for (genvar bank = 0; bank < LPARA_DIR_BANK_NUM; bank++) begin : gen_dir_bank
    if (PARA_DIR_SYNC_READ == 32'd1) begin : gen_read_pipe
      logic reg_read_valid;
      logic [LPARA_DIR_SET_W-1:0] reg_read_set;
      logic [LPARA_DIR_TAG_W-1:0] reg_read_tag;
      logic [LPARA_COH_TAG_W-1:0] reg_read_rsp_tag;
      logic [LPARA_DIR_WAY_NUM-1:0] reg_read_valid_ways;
      logic [6:0] reg_read_plru;

      assign w_read_slot_ready[bank] = ~reg_read_valid | w_lookup_rsp_slot_ready[bank];
      assign w_lookup_eval[bank] = reg_read_valid;
      assign w_eval_set[bank] = reg_read_set;
      assign w_eval_tag[bank] = reg_read_tag;
      assign w_eval_rsp_tag[bank] = reg_read_rsp_tag;
      assign w_lookup_valid_ways[bank] = reg_read_valid_ways;
      assign w_lookup_plru[bank] = reg_read_plru;

      always_ff @(posedge i_clk_cluster, negedge i_rst_n_cluster) begin : p_ff_dir_read_pipe
        if (!i_rst_n_cluster) begin
          reg_read_valid <= 1'b0;
          reg_read_set <= '0;
          reg_read_tag <= '0;
          reg_read_rsp_tag <= '0;
          reg_read_valid_ways <= '0;
          reg_read_plru <= '0;
        end else begin
          if (w_read_slot_ready[bank])
            reg_read_valid <= w_lookup_hs[bank];
          if (w_lookup_hs[bank]) begin
            reg_read_set <= w_lookup_set[bank];
            reg_read_tag <= w_lookup_tag[bank];
            reg_read_rsp_tag <= i_lookup_tag[bank];
            reg_read_plru <= reg_dir_plru[bank][w_lookup_set[bank]];
            for (int way_idx = 0; way_idx < LPARA_DIR_WAY_NUM; way_idx++)
              reg_read_valid_ways[way_idx] <= reg_dir_valid[bank][w_lookup_set[bank]][way_idx];
          end
        end
      end
    end else begin : gen_read_direct
      assign w_read_slot_ready[bank] = w_lookup_rsp_slot_ready[bank];
      assign w_lookup_eval[bank] = w_lookup_hs[bank];
      assign w_eval_set[bank] = w_lookup_set[bank];
      assign w_eval_tag[bank] = w_lookup_tag[bank];
      assign w_eval_rsp_tag[bank] = i_lookup_tag[bank];
      assign w_lookup_plru[bank] = reg_dir_plru[bank][w_lookup_set[bank]];
      for (genvar way = 0; way < LPARA_DIR_WAY_NUM; way++) begin : gen_valid
        assign w_lookup_valid_ways[bank][way] = reg_dir_valid[bank][w_lookup_set[bank]][way];
      end
    end

    // One operation per bank per cycle. Way-local 1RW storage has no reset.
    // Valid bits live outside the array, so a reset never requires a RAM sweep.
    for (genvar way = 0; way < LPARA_DIR_WAY_NUM; way++) begin : gen_way
      dir_entry_type_def reg_entry [LPARA_DIR_SET_NUM-1:0];
      logic w_write_way;
      dir_entry_type_def w_write_entry;
      logic [LPARA_DIR_SET_W-1:0] w_ram_addr;

      assign w_write_way = w_update_hs[bank] & (i_update_way[bank] == 3'(way));
      assign w_write_entry = {
        i_update_pa_line[bank][2 + LPARA_DIR_SET_W +: LPARA_DIR_TAG_W],
        i_update_holders[bank], i_update_owner[bank], i_update_state[bank]
      };
      assign w_ram_addr = w_write_way ? w_update_set[bank] : w_lookup_set[bank];

      if (PARA_DIR_SYNC_READ == 32'd1) begin : gen_sync_ram
        dir_entry_type_def reg_read_entry;
        always_ff @(posedge i_clk_cluster) begin : p_ff_dir_ram
          if (w_write_way)
            reg_entry[w_ram_addr] <= w_write_entry;
          else if (w_lookup_hs[bank])
            reg_read_entry <= reg_entry[w_ram_addr];
        end
        assign w_lookup_entry[bank][way] = reg_read_entry;
      end else begin : gen_async_read
        always_ff @(posedge i_clk_cluster) begin : p_ff_dir_write
          if (w_write_way)
            reg_entry[w_update_set[bank]] <= w_write_entry;
        end
        assign w_lookup_entry[bank][way] = reg_entry[w_lookup_set[bank]];
      end
    end
  end

  // Find the matching line and the invalid-first, tree-PLRU replacement candidate.
  always_comb begin : p_com_dir_lookup
    w_lookup_bank_match = '0;
    w_update_bank_match = '0;
    w_cancel_bank_match = '0;
    w_lookup_set_busy = '0;
    w_update_set_busy = '0;
    w_lookup_eligible = '0;
    w_update_eligible = '0;
    w_cancel_eligible = '0;
    w_update_owner_match = '0;
    w_cancel_owner_match = '0;
    w_owner_terminal_conflict = '0;
    w_lookup_rsp_slot_ready = '0;
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
      w_lookup_rsp_slot_ready[bank_idx] = ~reg_lookup_rsp_valid[bank_idx]
                                        | i_lookup_rsp_ready[bank_idx];
      w_update_owner_match[bank_idx] = w_update_bank_match[bank_idx]
                                     & reg_dir_resv_valid[bank_idx][w_update_set[bank_idx]]
                                     & (reg_dir_resv_tag[bank_idx][w_update_set[bank_idx]]
                                        == i_update_tag[bank_idx]);
      w_cancel_owner_match[bank_idx] = w_cancel_bank_match[bank_idx]
                                     & reg_dir_resv_valid[bank_idx][w_cancel_set[bank_idx]]
                                     & (reg_dir_resv_tag[bank_idx][w_cancel_set[bank_idx]]
                                        == i_cancel_tag[bank_idx]);
      w_owner_terminal_conflict[bank_idx] = i_update_valid[bank_idx]
                                          & i_cancel_valid[bank_idx]
                                          & w_update_owner_match[bank_idx]
                                          & w_cancel_owner_match[bank_idx]
                                          & (w_update_set[bank_idx] == w_cancel_set[bank_idx]);
      w_lookup_eligible[bank_idx] = i_lookup_valid[bank_idx]
                                  & w_lookup_bank_match[bank_idx]
                                  & ~w_lookup_set_busy[bank_idx]
                                  & w_read_slot_ready[bank_idx];
      w_update_eligible[bank_idx] = i_update_valid[bank_idx]
                                  & w_update_bank_match[bank_idx]
                                  & ~w_update_set_busy[bank_idx];
      w_cancel_eligible[bank_idx] = i_cancel_valid[bank_idx]
                                  & w_cancel_owner_match[bank_idx];
      for (int way_idx = 0; way_idx < LPARA_DIR_WAY_NUM; way_idx++) begin
        if (w_lookup_valid_ways[bank_idx][way_idx]
            & (w_lookup_entry[bank_idx][way_idx].tag == w_eval_tag[bank_idx])
            & ~w_lookup_hit[bank_idx]) begin
          w_lookup_hit[bank_idx] = 1'b1;
          w_lookup_hit_way[bank_idx] = 3'(way_idx);
        end
        if (~w_lookup_valid_ways[bank_idx][way_idx]
            & ~w_lookup_invalid_found[bank_idx]) begin
          w_lookup_invalid_found[bank_idx] = 1'b1;
          w_lookup_victim_way[bank_idx] = 3'(way_idx);
        end
      end
      if (~w_lookup_hit[bank_idx]) begin
        if (~w_lookup_invalid_found[bank_idx]) begin
          w_lookup_victim_way[bank_idx] = fun_plru_victim(w_lookup_plru[bank_idx]);
          w_lookup_victim_valid[bank_idx] = 1'b1;
          w_lookup_victim_pa_line[bank_idx] = {
            w_lookup_entry[bank_idx][w_lookup_victim_way[bank_idx]].tag,
            w_eval_set[bank_idx], 2'(bank_idx)
          };
          w_lookup_holders[bank_idx] = w_lookup_entry[bank_idx][w_lookup_victim_way[bank_idx]].holders;
          w_lookup_owner[bank_idx] = w_lookup_entry[bank_idx][w_lookup_victim_way[bank_idx]].owner;
          w_lookup_state[bank_idx] = w_lookup_entry[bank_idx][w_lookup_victim_way[bank_idx]].state;
        end
      end else begin
        w_lookup_victim_way[bank_idx] = w_lookup_hit_way[bank_idx];
        w_lookup_holders[bank_idx] = w_lookup_entry[bank_idx][w_lookup_hit_way[bank_idx]].holders;
        w_lookup_owner[bank_idx] = w_lookup_entry[bank_idx][w_lookup_hit_way[bank_idx]].owner;
        w_lookup_state[bank_idx] = w_lookup_entry[bank_idx][w_lookup_hit_way[bank_idx]].state;
      end
      if (w_lookup_hs[bank_idx])
        w_lookup_count = w_lookup_count + 3'd1;
      if (w_update_hs[bank_idx])
        w_update_count = w_update_count + 3'd1;
    end
  end

  // Filter ineligible requests before arbitration and let an owner terminal operation escape.
  always_comb begin : p_com_dir_ready
    o_lookup_ready = '0;
    o_update_ready = '0;
    o_cancel_ready = '0;
    w_dir_op_rr_ptr_nxt = reg_dir_op_rr_ptr;
    w_dir_op_selected = '0;
    w_dir_op_selected_valid = '0;
    w_dir_op_scan = '0;
    for (int bank_idx = 0; bank_idx < LPARA_DIR_BANK_NUM; bank_idx++) begin
      if (~w_owner_terminal_conflict[bank_idx]) begin
        if (w_update_owner_match[bank_idx] & i_update_valid[bank_idx]) begin
          w_dir_op_selected_valid[bank_idx] = 1'b1;
            w_dir_op_selected[bank_idx] = 2'(LPARA_DIR_OP_UPDATE);
        end else if (w_cancel_owner_match[bank_idx] & i_cancel_valid[bank_idx]) begin
          w_dir_op_selected_valid[bank_idx] = 1'b1;
          w_dir_op_selected[bank_idx] = 2'(LPARA_DIR_OP_CANCEL);
        end else begin
          for (int offset_idx = 0; offset_idx < 3; offset_idx++) begin
            w_dir_op_scan[bank_idx] = 32'(reg_dir_op_rr_ptr[bank_idx])
                                    + 32'(offset_idx);
            if (w_dir_op_scan[bank_idx] >= LPARA_DIR_OP_COUNT)
              w_dir_op_scan[bank_idx] = w_dir_op_scan[bank_idx]
                                      - 32'(LPARA_DIR_OP_COUNT);
            if (~w_dir_op_selected_valid[bank_idx]) begin
              case (w_dir_op_scan[bank_idx])
                32'(LPARA_DIR_OP_LOOKUP): begin
                  if (w_lookup_eligible[bank_idx]) begin
                    w_dir_op_selected_valid[bank_idx] = 1'b1;
                    w_dir_op_selected[bank_idx] = 2'(LPARA_DIR_OP_LOOKUP);
                  end
                end
                32'(LPARA_DIR_OP_UPDATE): begin
                  if (w_update_eligible[bank_idx]) begin
                    w_dir_op_selected_valid[bank_idx] = 1'b1;
                    w_dir_op_selected[bank_idx] = 2'(LPARA_DIR_OP_UPDATE);
                  end
                end
                32'(LPARA_DIR_OP_CANCEL): begin
                  if (w_cancel_eligible[bank_idx]) begin
                    w_dir_op_selected_valid[bank_idx] = 1'b1;
                    w_dir_op_selected[bank_idx] = 2'(LPARA_DIR_OP_CANCEL);
                  end
                end
                default: begin
                end
              endcase
            end
          end
        end
      end
      case (w_dir_op_selected[bank_idx])
        2'(LPARA_DIR_OP_LOOKUP):
          o_lookup_ready[bank_idx] = w_dir_op_selected_valid[bank_idx];
        2'(LPARA_DIR_OP_UPDATE):
          o_update_ready[bank_idx] = w_dir_op_selected_valid[bank_idx];
        2'(LPARA_DIR_OP_CANCEL):
          o_cancel_ready[bank_idx] = w_dir_op_selected_valid[bank_idx];
        default: begin
        end
      endcase
      if (w_dir_op_selected_valid[bank_idx]) begin
        if (w_dir_op_selected[bank_idx] == 2'(LPARA_DIR_OP_CANCEL))
          w_dir_op_rr_ptr_nxt[bank_idx] = 2'd0;
        else
          w_dir_op_rr_ptr_nxt[bank_idx] = w_dir_op_selected[bank_idx] + 2'd1;
      end
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
      reg_dir_op_rr_ptr <= '0;
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
        reg_dir_op_rr_ptr[bank_idx] <= w_dir_op_rr_ptr_nxt[bank_idx];
        if (~reg_lookup_rsp_valid[bank_idx] | i_lookup_rsp_ready[bank_idx]) begin
          reg_lookup_rsp_valid[bank_idx] <= w_lookup_eval[bank_idx];
          if (w_lookup_eval[bank_idx]) begin
            reg_lookup_hit[bank_idx] <= w_lookup_hit[bank_idx];
            reg_lookup_rsp_tag[bank_idx] <= w_eval_rsp_tag[bank_idx];
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
        if (w_lookup_eval[bank_idx] & w_lookup_rsp_slot_ready[bank_idx] & w_lookup_hit[bank_idx])
          reg_dir_plru[bank_idx][w_eval_set[bank_idx]] <=
            fun_plru_update(w_lookup_plru[bank_idx],
                            w_lookup_hit_way[bank_idx]);
        // Reserve the selected set for every lookup result.  A hit also needs
        // ownership of the set until the later COMMIT update or CANCEL.
        if (w_lookup_hs[bank_idx]) begin
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
