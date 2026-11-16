/*
 * Project      : VLSIT RISC-V CPU Cluster
 * Author       : Quan Nguyen (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-14
 * Description  : Serializes one HPDcache probe through lookup, optional writeback, and MESI commit.
 */
// 2026-11-15 - Quan Nguyen and Codex - VLSI Technology page:
// DEC-013/A-04: absent PREPARE remains I at COMMIT for any target;
// acknowledge without allocating or updating a nonresident cache line.
`timescale 1ns/1ps

module m_vlsit_riscv_hpd_probe_engine #(
  // Parameter Description: number of D-cache ways in the selected CVA6 profile.
  // Parameter values: 1 through 32; default is 8.
  // Parameter unit: ways.
  parameter logic [31:0] PARA_WAY_NUM = 32'd8,
  localparam logic [31:0] LPARA_PHASE_PREPARE = 32'd0,
  localparam logic [31:0] LPARA_PHASE_COMMIT = 32'd1,
  localparam logic [31:0] LPARA_PHASE_ABORT = 32'd2,
  localparam logic [31:0] LPARA_MESI_I = 32'd0,
  localparam logic [31:0] LPARA_MESI_M = 32'd3,
  localparam logic [31:0] LPARA_ST_IDLE = 32'd0,
  localparam logic [31:0] LPARA_ST_LOOKUP_REQ = 32'd1,
  localparam logic [31:0] LPARA_ST_LOOKUP_WAIT = 32'd2,
  localparam logic [31:0] LPARA_ST_FLUSH_REQ = 32'd3,
  localparam logic [31:0] LPARA_ST_FLUSH_WAIT = 32'd4,
  localparam logic [31:0] LPARA_ST_PREPARE_RSP = 32'd5,
  localparam logic [31:0] LPARA_ST_TERMINAL_WAIT = 32'd6,
  localparam logic [31:0] LPARA_ST_UPDATE_REQ = 32'd7,
  localparam logic [31:0] LPARA_ST_TERMINAL_RSP = 32'd8,
  localparam logic [31:0] LPARA_ST_ERR_RSP = 32'd9,
  localparam logic [31:0] LPARA_ST_STRAY_RSP = 32'd10
) (
  // Clock and reset
  input  wire                     i_clk_cache,
  input  wire                     i_rst_n_cache,

  // Two-phase coherence probe request from the tile boundary
  input  wire                     i_probe_req_valid,
  output logic                    o_probe_req_ready,
  input  wire  [3:0]              i_probe_req_tag,
  input  wire  [51:0]             i_probe_req_nline,
  input  wire  [1:0]              i_probe_req_phase,
  input  wire  [1:0]              i_probe_req_target_state,
  input  wire                     i_probe_req_wback_en,

  // Held tagged response to the coherence scheduler
  output logic                    o_probe_rsp_valid,
  input  wire                     i_probe_rsp_ready,
  output logic [3:0]              o_probe_rsp_tag,
  output logic [51:0]             o_probe_rsp_nline,
  output logic [1:0]              o_probe_rsp_phase,
  output logic [1:0]              o_probe_rsp_state,
  output logic                    o_probe_rsp_err,
  output logic                    o_probe_rsp_wback_done,

  // Read-only HPDcache directory lookup
  output logic                    o_lookup_valid,
  input  wire                     i_lookup_ready,
  output logic [3:0]              o_lookup_tag,
  output logic [51:0]             o_lookup_nline,
  input  wire                     i_lookup_rsp_valid,
  output logic                    o_lookup_rsp_ready,
  input  wire  [3:0]              i_lookup_rsp_tag,
  input  wire  [51:0]             i_lookup_rsp_nline,
  input  wire  [PARA_WAY_NUM-1:0] i_lookup_rsp_way,
  input  wire                     i_lookup_rsp_hit,
  input  wire  [1:0]              i_lookup_rsp_state,
  input  wire                     i_lookup_rsp_err,

  // Existing HPDcache full-line writeback engine
  output logic                    o_flush_valid,
  input  wire                     i_flush_ready,
  output logic [51:0]             o_flush_nline,
  output logic [PARA_WAY_NUM-1:0] o_flush_way,
  input  wire                     i_flush_ack_valid,
  input  wire  [51:0]             i_flush_ack_nline,
  input  wire                     i_flush_ack_err,

  // Directory MESI update, issued only after a matching COMMIT request
  output logic                    o_state_update_valid,
  input  wire                     i_state_update_ready,
  output logic [51:0]             o_state_update_nline,
  output logic [PARA_WAY_NUM-1:0] o_state_update_way,
  output logic [1:0]              o_state_update_state
);

  typedef enum logic [3:0] {
    ENUM_ST_IDLE = 4'(LPARA_ST_IDLE),
    ENUM_ST_LOOKUP_REQ = 4'(LPARA_ST_LOOKUP_REQ),
    ENUM_ST_LOOKUP_WAIT = 4'(LPARA_ST_LOOKUP_WAIT),
    ENUM_ST_FLUSH_REQ = 4'(LPARA_ST_FLUSH_REQ),
    ENUM_ST_FLUSH_WAIT = 4'(LPARA_ST_FLUSH_WAIT),
    ENUM_ST_PREPARE_RSP = 4'(LPARA_ST_PREPARE_RSP),
    ENUM_ST_TERMINAL_WAIT = 4'(LPARA_ST_TERMINAL_WAIT),
    ENUM_ST_UPDATE_REQ = 4'(LPARA_ST_UPDATE_REQ),
    ENUM_ST_TERMINAL_RSP = 4'(LPARA_ST_TERMINAL_RSP),
    ENUM_ST_ERR_RSP = 4'(LPARA_ST_ERR_RSP),
    ENUM_ST_STRAY_RSP = 4'(LPARA_ST_STRAY_RSP)
  } probe_fsm_type_def;

  probe_fsm_type_def reg_fsm_probe_current_state;
  probe_fsm_type_def w_fsm_probe_nxt_state;
  logic [3:0] reg_probe_tag;
  logic [51:0] reg_probe_nline;
  logic [1:0] reg_probe_target_state;
  logic reg_probe_wback_en;
  logic [1:0] reg_probe_state;
  logic [PARA_WAY_NUM-1:0] reg_probe_way;
  logic reg_probe_hit;
  logic reg_probe_err;
  logic reg_probe_wback_done;
  logic [3:0] reg_rsp_tag;
  logic [51:0] reg_rsp_nline;
  logic [1:0] reg_rsp_phase;
  logic [1:0] reg_rsp_state;
  logic reg_rsp_err;
  logic reg_rsp_wback_done;
  logic w_probe_req_hs;
  logic w_probe_rsp_hs;
  logic w_lookup_hs;
  logic w_lookup_rsp_hs;
  logic w_flush_hs;
  logic w_state_update_hs;

  // State decode covers all legal encodings; invalid states are don't-care.
  always_comb begin : p_com_probe_outputs
    o_probe_req_ready = 1'b0;
    o_probe_rsp_valid = 1'b0;
    o_probe_rsp_tag = reg_rsp_tag;
    o_probe_rsp_nline = reg_rsp_nline;
    o_probe_rsp_phase = reg_rsp_phase;
    o_probe_rsp_state = reg_rsp_state;
    o_probe_rsp_err = reg_rsp_err;
    o_probe_rsp_wback_done = reg_rsp_wback_done;
    o_lookup_valid = 1'b0;
    o_lookup_tag = reg_probe_tag;
    o_lookup_nline = reg_probe_nline;
    o_lookup_rsp_ready = 1'b0;
    o_flush_valid = 1'b0;
    o_flush_nline = reg_probe_nline;
    o_flush_way = reg_probe_way;
    o_state_update_valid = 1'b0;
    o_state_update_nline = reg_probe_nline;
    o_state_update_way = reg_probe_way;
    o_state_update_state = reg_probe_target_state;

    casez (reg_fsm_probe_current_state)
      ENUM_ST_IDLE,
      ENUM_ST_TERMINAL_WAIT: begin
        o_probe_req_ready = 1'b1;
      end
      ENUM_ST_LOOKUP_REQ: begin
        o_lookup_valid = 1'b1;
      end
      ENUM_ST_LOOKUP_WAIT: begin
        o_lookup_rsp_ready = 1'b1;
      end
      ENUM_ST_FLUSH_REQ: begin
        o_flush_valid = 1'b1;
      end
      ENUM_ST_PREPARE_RSP,
      ENUM_ST_TERMINAL_RSP,
      ENUM_ST_ERR_RSP,
      ENUM_ST_STRAY_RSP: begin
        o_probe_rsp_valid = 1'b1;
      end
      ENUM_ST_UPDATE_REQ: begin
        o_state_update_valid = 1'b1;
      end
      ENUM_ST_FLUSH_WAIT: begin
      end
      default: begin
        o_probe_req_ready = 'x;
        o_probe_rsp_valid = 'x;
        o_lookup_valid = 'x;
        o_lookup_rsp_ready = 'x;
        o_flush_valid = 'x;
        o_state_update_valid = 'x;
      end
    endcase
  end

  // Compute the next protocol state independently from registered payload updates.
  always_comb begin : p_com_probe_nxt
    w_fsm_probe_nxt_state = reg_fsm_probe_current_state;
    casez (reg_fsm_probe_current_state)
      ENUM_ST_IDLE: begin
        if (w_probe_req_hs) begin
          if (32'(i_probe_req_phase) == LPARA_PHASE_PREPARE)
            w_fsm_probe_nxt_state = ENUM_ST_LOOKUP_REQ;
          else
            w_fsm_probe_nxt_state = ENUM_ST_STRAY_RSP;
        end
      end
      ENUM_ST_LOOKUP_REQ: begin
        if (w_lookup_hs)
          w_fsm_probe_nxt_state = ENUM_ST_LOOKUP_WAIT;
      end
      ENUM_ST_LOOKUP_WAIT: begin
        if (w_lookup_rsp_hs) begin
          if (i_lookup_rsp_err
              | (i_lookup_rsp_tag != reg_probe_tag)
              | (i_lookup_rsp_nline != reg_probe_nline))
            w_fsm_probe_nxt_state = ENUM_ST_PREPARE_RSP;
          else if (i_lookup_rsp_hit
                   & (i_lookup_rsp_state == 2'(LPARA_MESI_M))
                   & reg_probe_wback_en)
            w_fsm_probe_nxt_state = ENUM_ST_FLUSH_REQ;
          else
            w_fsm_probe_nxt_state = ENUM_ST_PREPARE_RSP;
        end
      end
      ENUM_ST_FLUSH_REQ: begin
        if (w_flush_hs)
          w_fsm_probe_nxt_state = ENUM_ST_FLUSH_WAIT;
      end
      ENUM_ST_FLUSH_WAIT: begin
        if (i_flush_ack_valid)
          w_fsm_probe_nxt_state = ENUM_ST_PREPARE_RSP;
      end
      ENUM_ST_PREPARE_RSP: begin
        if (w_probe_rsp_hs)
          w_fsm_probe_nxt_state = ENUM_ST_TERMINAL_WAIT;
      end
      ENUM_ST_TERMINAL_WAIT: begin
        if (w_probe_req_hs) begin
          if ((i_probe_req_tag != reg_probe_tag)
              | (i_probe_req_nline != reg_probe_nline)
              | (i_probe_req_target_state != reg_probe_target_state)) begin
            w_fsm_probe_nxt_state = ENUM_ST_ERR_RSP;
          end else begin
            casez (i_probe_req_phase)
              2'(LPARA_PHASE_ABORT):
                w_fsm_probe_nxt_state = ENUM_ST_TERMINAL_RSP;
              2'(LPARA_PHASE_COMMIT): begin
                casez ({reg_probe_err, reg_probe_hit,
                        (i_probe_req_target_state == 2'(LPARA_MESI_I))})
                  3'b1??: w_fsm_probe_nxt_state = ENUM_ST_ERR_RSP;
                  3'b01?: w_fsm_probe_nxt_state = ENUM_ST_UPDATE_REQ;
                  3'b00?: w_fsm_probe_nxt_state = ENUM_ST_TERMINAL_RSP;
                  default: w_fsm_probe_nxt_state = ENUM_ST_ERR_RSP;
                endcase
              end
              default: w_fsm_probe_nxt_state = ENUM_ST_ERR_RSP;
            endcase
          end
        end
      end
      ENUM_ST_UPDATE_REQ: begin
        if (w_state_update_hs)
          w_fsm_probe_nxt_state = ENUM_ST_TERMINAL_RSP;
      end
      ENUM_ST_TERMINAL_RSP: begin
        if (w_probe_rsp_hs)
          w_fsm_probe_nxt_state = ENUM_ST_IDLE;
      end
      ENUM_ST_ERR_RSP: begin
        if (w_probe_rsp_hs)
          w_fsm_probe_nxt_state = ENUM_ST_TERMINAL_WAIT;
      end
      ENUM_ST_STRAY_RSP: begin
        if (w_probe_rsp_hs)
          w_fsm_probe_nxt_state = ENUM_ST_IDLE;
      end
      default: w_fsm_probe_nxt_state = probe_fsm_type_def'('x);
    endcase
  end

  // Handshakes advance the lookup, writeback, and two-phase state transition.
  assign w_probe_req_hs = i_probe_req_valid & o_probe_req_ready;
  assign w_probe_rsp_hs = o_probe_rsp_valid & i_probe_rsp_ready;
  assign w_lookup_hs = o_lookup_valid & i_lookup_ready;
  assign w_lookup_rsp_hs = i_lookup_rsp_valid & o_lookup_rsp_ready;
  assign w_flush_hs = o_flush_valid & i_flush_ready;
  assign w_state_update_hs = o_state_update_valid & i_state_update_ready;

  // Isolate the FSM state register from transaction payload registers.
  always_ff @(posedge i_clk_cache, negedge i_rst_n_cache) begin : p_ff_probe_state
    if (!i_rst_n_cache) begin
      reg_fsm_probe_current_state <= ENUM_ST_IDLE;
    end else begin
      reg_fsm_probe_current_state <= w_fsm_probe_nxt_state;
    end
  end

  // Capture request, lookup, writeback, and state-update payloads for the active phase.
  always_ff @(posedge i_clk_cache, negedge i_rst_n_cache) begin : p_ff_probe_payload
    if (!i_rst_n_cache) begin
      reg_probe_tag <= '0;
      reg_probe_nline <= '0;
      reg_probe_target_state <= 2'(LPARA_MESI_I);
      reg_probe_wback_en <= 1'b0;
      reg_probe_state <= 2'(LPARA_MESI_I);
      reg_probe_way <= '0;
      reg_probe_hit <= 1'b0;
      reg_probe_err <= 1'b0;
      reg_probe_wback_done <= 1'b0;
      reg_rsp_tag <= '0;
      reg_rsp_nline <= '0;
      reg_rsp_phase <= 2'(LPARA_PHASE_PREPARE);
      reg_rsp_state <= 2'(LPARA_MESI_I);
      reg_rsp_err <= 1'b0;
      reg_rsp_wback_done <= 1'b0;
    end else begin
      casez (reg_fsm_probe_current_state)
        ENUM_ST_IDLE: begin
          if (w_probe_req_hs) begin
            reg_rsp_tag <= i_probe_req_tag;
            reg_rsp_nline <= i_probe_req_nline;
            reg_rsp_phase <= i_probe_req_phase;
            reg_rsp_state <= 2'(LPARA_MESI_I);
            reg_rsp_err <= 1'b0;
            reg_rsp_wback_done <= 1'b0;
            if (32'(i_probe_req_phase) == LPARA_PHASE_PREPARE) begin
              reg_probe_tag <= i_probe_req_tag;
              reg_probe_nline <= i_probe_req_nline;
              reg_probe_target_state <= i_probe_req_target_state;
              reg_probe_wback_en <= i_probe_req_wback_en;
              reg_probe_state <= 2'(LPARA_MESI_I);
              reg_probe_way <= '0;
              reg_probe_hit <= 1'b0;
              reg_probe_err <= 1'b0;
              reg_probe_wback_done <= 1'b0;
            end else begin
              reg_rsp_err <= 1'b1;
            end
          end
        end
        ENUM_ST_LOOKUP_REQ: begin
        end
        ENUM_ST_LOOKUP_WAIT: begin
          if (w_lookup_rsp_hs) begin
            reg_probe_way <= i_lookup_rsp_way;
            reg_probe_hit <= i_lookup_rsp_hit;
            reg_probe_state <= i_lookup_rsp_state;
            // No-writeback dirty M is valid only for an invalidate-to-I transaction.
            reg_probe_err <= i_lookup_rsp_err
                           | (i_lookup_rsp_tag != reg_probe_tag)
                           | (i_lookup_rsp_nline != reg_probe_nline)
                           | (i_lookup_rsp_hit
                              & (i_lookup_rsp_state == 2'(LPARA_MESI_M))
                              & ~reg_probe_wback_en
                              & (reg_probe_target_state != 2'(LPARA_MESI_I)));
            if (i_lookup_rsp_err
                | (i_lookup_rsp_tag != reg_probe_tag)
                | (i_lookup_rsp_nline != reg_probe_nline)
                | (i_lookup_rsp_hit
                   & (i_lookup_rsp_state == 2'(LPARA_MESI_M))
                      & ~reg_probe_wback_en
                      & (reg_probe_target_state != 2'(LPARA_MESI_I)))) begin
              reg_rsp_tag <= reg_probe_tag;
              reg_rsp_nline <= reg_probe_nline;
              reg_rsp_phase <= 2'(LPARA_PHASE_PREPARE);
              reg_rsp_state <= i_lookup_rsp_state;
              reg_rsp_err <= 1'b1;
              reg_rsp_wback_done <= 1'b0;
            end else begin
              reg_rsp_tag <= reg_probe_tag;
              reg_rsp_nline <= reg_probe_nline;
              reg_rsp_phase <= 2'(LPARA_PHASE_PREPARE);
              reg_rsp_state <= i_lookup_rsp_state;
              reg_rsp_err <= 1'b0;
              reg_rsp_wback_done <= 1'b0;
            end
          end
        end
        ENUM_ST_FLUSH_REQ: begin
        end
        ENUM_ST_FLUSH_WAIT: begin
          if (i_flush_ack_valid) begin
            reg_rsp_tag <= reg_probe_tag;
            reg_rsp_nline <= reg_probe_nline;
            reg_rsp_phase <= 2'(LPARA_PHASE_PREPARE);
            reg_rsp_state <= reg_probe_state;
            reg_rsp_err <= i_flush_ack_err | (i_flush_ack_nline != reg_probe_nline);
            reg_rsp_wback_done <= ~i_flush_ack_err
                                  & (i_flush_ack_nline == reg_probe_nline);
            reg_probe_err <= i_flush_ack_err | (i_flush_ack_nline != reg_probe_nline);
            reg_probe_wback_done <= ~i_flush_ack_err
                                    & (i_flush_ack_nline == reg_probe_nline);
          end
        end
        ENUM_ST_PREPARE_RSP: begin
        end
        ENUM_ST_TERMINAL_WAIT: begin
          if (w_probe_req_hs) begin
            reg_rsp_tag <= i_probe_req_tag;
            reg_rsp_nline <= i_probe_req_nline;
            reg_rsp_phase <= i_probe_req_phase;
            reg_rsp_state <= reg_probe_state;
            reg_rsp_err <= 1'b0;
            reg_rsp_wback_done <= reg_probe_wback_done;
            casez ({(i_probe_req_tag != reg_probe_tag)
                    | (i_probe_req_nline != reg_probe_nline)
                    | (i_probe_req_target_state != reg_probe_target_state),
                    i_probe_req_phase,
                    reg_probe_err,
                    reg_probe_hit,
                    (i_probe_req_target_state == 2'(LPARA_MESI_I))})
              {1'b1, 2'b??, 1'b?, 1'b?, 1'b?}: begin
                reg_rsp_err <= 1'b1;
              end
              {1'b0, 2'(LPARA_PHASE_ABORT), 1'b?, 1'b?, 1'b?}: begin
                reg_rsp_state <= reg_probe_state;
              end
              {1'b0, 2'(LPARA_PHASE_COMMIT), 1'b1, 1'b?, 1'b?}: begin
                reg_rsp_err <= 1'b1;
              end
              {1'b0, 2'(LPARA_PHASE_COMMIT), 1'b0, 1'b1, 1'b?}: begin
                reg_rsp_state <= reg_probe_target_state;
              end
              {1'b0, 2'(LPARA_PHASE_COMMIT), 1'b0, 1'b0, 1'b?}: begin
                reg_rsp_state <= 2'(LPARA_MESI_I);
              end
              default: begin
                reg_rsp_err <= 1'b1;
              end
            endcase
          end
        end
        ENUM_ST_UPDATE_REQ: begin
          if (w_state_update_hs) begin
            reg_rsp_state <= reg_probe_target_state;
          end
        end
        ENUM_ST_TERMINAL_RSP: begin
        end
        ENUM_ST_ERR_RSP: begin
        end
        ENUM_ST_STRAY_RSP: begin
        end
        default: begin
        end
      endcase
    end
  end

endmodule
