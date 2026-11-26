/*
 * Project      : VLSIT RISC-V CPU Cluster
 * Author       : Quan Nguyen (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-14
 * Description  : Sequences one resolved CBO through shared CCU preparation,
 *                per-line LLC maintenance, and CCU commit or abort.
 * Specification: REQ-MEM-015/016/017; DEC-028/029.
 * Contract     : CCU owns the context and line lock until finish completion.
 *                PREPARE errors still return a valid context for ABORT.
 *                No acknowledgement timeout or duplicate line-lock table.
 * Rule note    : NAM-08: o_cmo_error and i_maint_error retain approved Plan V3
 *                interface spelling for compatibility with the HDS channel table.
 * History      : Quan Nguyen and Codex - VLSI Technology page.
 *                DEC-045: Add optional cluster boundary timing profile support.
 */
`timescale 1ns/1ps

// 2026-11-15 - Quan Nguyen and Codex - VLSI Technology page:
// DEC-030/031: retain FENCE.I through coherent clean completion and precise fault.
// Change: Add FENCE clean-to-LLC operation; skip DRAM maintenance and wait for terminal CCU ACK.
module m_vlsit_riscv_cmo_controller #(
  // Parameter Description: number of active harts allowed to issue CBO commands.
  // Parameter values: 2 or 4; default is 4.
  // Parameter unit: harts.
  parameter logic [31:0] PARA_CPU_NUM = 32'd4,
  // Parameter Description: number of shared CCU contexts used to size the tag.
  // Parameter values: 2 through 16; default is 8.
  // Parameter unit: contexts.
  parameter logic [31:0] PARA_COH_TXN_NUM = 32'd8,
  // Parameter Description: register the release of handshake gates.
  // Parameter values: 0 = legacy, 1 = registered; default is 0.
  // Parameter unit: mode
  parameter logic [31:0] PARA_REGISTER_RESET_RELEASE = 32'd0,
  localparam logic [31:0] LPARA_COH_TAG_W = (PARA_COH_TXN_NUM > 32'd1)
                                           ? 32'($clog2(PARA_COH_TXN_NUM)) : 32'd1,
  localparam logic [31:0] LPARA_CMO_CLEAN = 32'd0,
  localparam logic [31:0] LPARA_CMO_FLUSH = 32'd1,
  localparam logic [31:0] LPARA_CMO_INVAL = 32'd2,
  localparam logic [31:0] LPARA_CMO_FENCE = 32'd3
) (
  // Clock and reset
  input  wire                        i_clk_cluster,
  input  wire                        i_rst_n_cluster,

  // One resolved CBO command from the core's per-hart arbitration
  input  wire                        i_cmo_valid,
  output logic                       o_cmo_ready,
  input  wire  [1:0]                 i_cmo_op,
  input  wire  [51:0]                i_cmo_pa_line,
  input  wire  [63:0]                i_cmo_vaddr,
  input  wire  [63:0]                i_cmo_pc,
  input  wire  [1:0]                 i_cmo_hart,
  output logic                       o_cmo_done,
  output logic                       o_cmo_error,
  output logic [63:0]                o_cmo_vaddr,
  output logic [63:0]                o_cmo_pc,
  output logic [1:0]                 o_cmo_hart,

  // CCU allocates its shared context, locks the line, and prepares all holders
  output logic                       o_ccu_begin_valid,
  input  wire                        i_ccu_begin_ready,
  output logic [1:0]                 o_ccu_begin_op,
  output logic [51:0]                o_ccu_begin_pa_line,
  output logic [1:0]                 o_ccu_begin_hart,
  output logic                       o_ccu_begin_wback_en,
  input  wire                        i_ccu_prepare_valid,
  output logic                       o_ccu_prepare_ready,
  input  wire  [LPARA_COH_TAG_W-1:0] i_ccu_prepare_tag,
  input  wire                        i_ccu_prepare_err,

  // LLC maintenance starts only after all required owner writebacks succeed
  output logic                       o_maint_valid,
  input  wire                        i_maint_ready,
  output logic [1:0]                 o_maint_op,
  output logic [51:0]                o_maint_pa_line,
  input  wire                        i_maint_done,
  input  wire                        i_maint_error,

  // CCU finishes the existing context; completion includes every required ACK
  output logic                       o_ccu_finish_valid,
  input  wire                        i_ccu_finish_ready,
  output logic [LPARA_COH_TAG_W-1:0] o_ccu_finish_tag,
  output logic                       o_ccu_finish_commit,
  input  wire                        i_ccu_finish_done
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

  // Every command visits PREPARE; only successful preparation may reach the LLC.
  typedef enum logic [3:0] {
    ENUM_ST_CMO_IDLE = 4'd0,
    ENUM_ST_CMO_BEGIN = 4'd1,
    ENUM_ST_CMO_PREPARE = 4'd2,
    ENUM_ST_CMO_MAINT_REQ = 4'd3,
    ENUM_ST_CMO_MAINT_WAIT = 4'd4,
    ENUM_ST_CMO_FINISH_REQ = 4'd5,
    ENUM_ST_CMO_FINISH_WAIT = 4'd6,
    ENUM_ST_CMO_RESP = 4'd7
  } cmo_state_type_def;

  // Command metadata and context identity remain stable until the response pulse.
  cmo_state_type_def reg_fsm_cmo_current_state;
  cmo_state_type_def w_fsm_cmo_nxt_state;
  logic [1:0] reg_cmo_op;
  logic [51:0] reg_cmo_pa_line;
  logic [63:0] reg_cmo_vaddr;
  logic [63:0] reg_cmo_pc;
  logic [1:0] reg_cmo_hart;
  logic [LPARA_COH_TAG_W-1:0] reg_cmo_tag;
  logic reg_cmo_err;
  logic w_cmd_legal;
  logic w_cmd_take;
  logic w_prepare_take;
  logic w_maint_take;

  // Reject reserved operation encodings and inactive hart indices before acceptance.
  assign w_cmd_legal = ((32'(i_cmo_op) == LPARA_CMO_CLEAN)
                       | (32'(i_cmo_op) == LPARA_CMO_FLUSH)
                       | (32'(i_cmo_op) == LPARA_CMO_INVAL)
                       | (32'(i_cmo_op) == LPARA_CMO_FENCE))
                      & (32'(i_cmo_hart) < PARA_CPU_NUM);
  // Consume one command only when the controller is idle and its fields are legal.
  assign w_cmd_take = i_cmo_valid & o_cmo_ready;
  assign w_prepare_take = i_ccu_prepare_valid & o_ccu_prepare_ready;
  // Allow a maintenance endpoint to complete on the same edge it accepts the request.
  assign w_maint_take = i_maint_done
                        & ((reg_fsm_cmo_current_state == ENUM_ST_CMO_MAINT_WAIT)
                           | ((reg_fsm_cmo_current_state == ENUM_ST_CMO_MAINT_REQ)
                              & i_maint_ready));

  // Current-state storage is isolated for FSM extraction.
  always_ff @(posedge i_clk_cluster, negedge i_rst_n_cluster) begin : p_ff_fsm_cmo
    if (!i_rst_n_cluster)
      reg_fsm_cmo_current_state <= ENUM_ST_CMO_IDLE;
    else
      reg_fsm_cmo_current_state <= w_fsm_cmo_nxt_state;
  end

  // No phase advances on acceptance alone when a later completion is required.
  always_comb begin : p_com_fsm_cmo_nxt
    w_fsm_cmo_nxt_state = reg_fsm_cmo_current_state;
    case (reg_fsm_cmo_current_state)
      ENUM_ST_CMO_IDLE: begin
        if (w_cmd_take)
          w_fsm_cmo_nxt_state = ENUM_ST_CMO_BEGIN;
      end
      ENUM_ST_CMO_BEGIN: begin
        if (i_ccu_begin_ready)
          w_fsm_cmo_nxt_state = ENUM_ST_CMO_PREPARE;
      end
      ENUM_ST_CMO_PREPARE: begin
        if (w_prepare_take) begin
          if (i_ccu_prepare_err | (32'(reg_cmo_op) == LPARA_CMO_FENCE))
            w_fsm_cmo_nxt_state = ENUM_ST_CMO_FINISH_REQ;
          else
            w_fsm_cmo_nxt_state = ENUM_ST_CMO_MAINT_REQ;
        end
      end
      ENUM_ST_CMO_MAINT_REQ: begin
        if (i_maint_ready) begin
          if (i_maint_done)
            w_fsm_cmo_nxt_state = ENUM_ST_CMO_FINISH_REQ;
          else
            w_fsm_cmo_nxt_state = ENUM_ST_CMO_MAINT_WAIT;
        end
      end
      ENUM_ST_CMO_MAINT_WAIT: begin
        if (i_maint_done)
          w_fsm_cmo_nxt_state = ENUM_ST_CMO_FINISH_REQ;
      end
      ENUM_ST_CMO_FINISH_REQ: begin
        if (i_ccu_finish_ready) begin
          if (i_ccu_finish_done)
            w_fsm_cmo_nxt_state = ENUM_ST_CMO_RESP;
          else
            w_fsm_cmo_nxt_state = ENUM_ST_CMO_FINISH_WAIT;
        end
      end
      ENUM_ST_CMO_FINISH_WAIT: begin
        if (i_ccu_finish_done)
          w_fsm_cmo_nxt_state = ENUM_ST_CMO_RESP;
      end
      ENUM_ST_CMO_RESP: begin
        w_fsm_cmo_nxt_state = ENUM_ST_CMO_IDLE;
      end
      default: begin
        // Reserved state values are unreachable after reset in normal operation.
        w_fsm_cmo_nxt_state = ENUM_ST_CMO_IDLE;
      end
    endcase
  end

  // Outputs use retained metadata; VALID and payload cannot change during a stall.
  always_comb begin : p_com_fsm_cmo_out
    o_cmo_ready = 1'b0;
    o_cmo_done = 1'b0;
    o_cmo_error = reg_cmo_err;
    o_cmo_vaddr = reg_cmo_vaddr;
    o_cmo_pc = reg_cmo_pc;
    o_cmo_hart = reg_cmo_hart;
    o_ccu_begin_valid = 1'b0;
    o_ccu_begin_op = reg_cmo_op;
    o_ccu_begin_pa_line = reg_cmo_pa_line;
    o_ccu_begin_hart = reg_cmo_hart;
    o_ccu_begin_wback_en = (32'(reg_cmo_op) != LPARA_CMO_INVAL);
    o_ccu_prepare_ready = 1'b0;
    o_maint_valid = 1'b0;
    o_maint_op = reg_cmo_op;
    o_maint_pa_line = reg_cmo_pa_line;
    o_ccu_finish_valid = 1'b0;
    o_ccu_finish_tag = reg_cmo_tag;
    o_ccu_finish_commit = ~reg_cmo_err;
    case (reg_fsm_cmo_current_state)
      ENUM_ST_CMO_IDLE: begin
        o_cmo_ready = w_cmd_legal & w_handshake_active;
      end
      ENUM_ST_CMO_BEGIN: begin
        o_ccu_begin_valid = 1'b1;
      end
      ENUM_ST_CMO_PREPARE: begin
        o_ccu_prepare_ready = 1'b1;
      end
      ENUM_ST_CMO_MAINT_REQ: begin
        o_maint_valid = 1'b1;
      end
      ENUM_ST_CMO_FINISH_REQ: begin
        o_ccu_finish_valid = 1'b1;
      end
      ENUM_ST_CMO_RESP: begin
        o_cmo_done = 1'b1;
      end
      default: begin
        // Wait states intentionally issue no further requests.
      end
    endcase
  end

  // Retain the original CBO PC/effective address for a precise retirement fault.
  always_ff @(posedge i_clk_cluster, negedge i_rst_n_cluster) begin : p_ff_cmo_metadata
    if (!i_rst_n_cluster) begin
      reg_cmo_op <= '0;
      reg_cmo_pa_line <= '0;
      reg_cmo_vaddr <= '0;
      reg_cmo_pc <= '0;
      reg_cmo_hart <= '0;
      reg_cmo_tag <= '0;
      reg_cmo_err <= 1'b0;
    end else begin
      if (w_cmd_take) begin
        reg_cmo_op <= i_cmo_op;
        reg_cmo_pa_line <= i_cmo_pa_line;
        reg_cmo_vaddr <= i_cmo_vaddr;
        reg_cmo_pc <= i_cmo_pc;
        reg_cmo_hart <= i_cmo_hart;
        reg_cmo_err <= 1'b0;
      end
      if (w_prepare_take) begin
        reg_cmo_tag <= i_ccu_prepare_tag;
        reg_cmo_err <= i_ccu_prepare_err;
      end
      if (w_maint_take)
        reg_cmo_err <= reg_cmo_err | i_maint_error;
    end
  end

endmodule
