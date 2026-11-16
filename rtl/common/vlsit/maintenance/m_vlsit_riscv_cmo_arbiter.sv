/*
 * Project      : VLSIT RISC-V CPU Cluster
 * Author       : Quan Nguyen (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-15
 * Description  : Buffer and arbitrate retirement CBO commands; route completion
 *                only to the hart whose command was accepted by the controller.
 * Change History:
 * 2026-11-15 - Quan Nguyen and Codex - VLSI Technology page: Initial implementation.
 */
`timescale 1ns/1ps
module m_vlsit_riscv_cmo_arbiter #(
  // Parameter Description: number of active retirement requesters.
  // Parameter values: 2 or 4; default 4.
  // Parameter unit: harts.
  parameter logic [31:0] PARA_CPU_NUM = 32'd4
) (
  // Retirement request and shared sequencer command/completion channels.
  input  wire              i_clk_cluster,
  input  wire              i_rst_n_cluster,
  input  wire  [3:0]       i_req_valid,
  output logic [3:0]       o_req_ready,
  input  wire  [3:0][1:0]  i_req_op,
  input  wire  [3:0][51:0] i_req_pa_line,
  input  wire  [3:0][63:0] i_req_vaddr,
  input  wire  [3:0][63:0] i_req_pc,
  output logic [3:0]       o_rsp_done,
  output logic [3:0]       o_rsp_err,
  output logic             o_cmo_valid,
  input  wire              i_cmo_ready,
  output logic [1:0]       o_cmo_op,
  output logic [51:0]      o_cmo_pa_line,
  output logic [63:0]      o_cmo_vaddr,
  output logic [63:0]      o_cmo_pc,
  output logic [1:0]       o_cmo_hart,
  input  wire              i_cmo_done,
  input  wire              i_cmo_err
);
  logic reg_cmd_valid;
  logic reg_busy;
  logic [1:0] reg_rr_hart;
  logic [1:0] reg_cmd_hart;
  logic [1:0] reg_cmd_op;
  logic [51:0] reg_cmd_pa_line;
  logic [63:0] reg_cmd_vaddr;
  logic [63:0] reg_cmd_pc;
  logic w_pick_valid;
  logic [1:0] w_pick_hart;
  logic [31:0] w_scan_hart;
  logic w_capture;
  logic w_issue;
  logic w_complete;

  // Capture one requester before presenting VALID so payload cannot change
  // when other harts arrive while the shared sequencer is backpressured.
  always_comb begin : p_com_pick
    w_pick_valid = 1'b0;
    w_pick_hart = '0;
    w_scan_hart = '0;
    for (int idx = 0; idx < PARA_CPU_NUM; idx++) begin
      w_scan_hart = 32'(reg_rr_hart) + 32'(idx);
      if (w_scan_hart >= PARA_CPU_NUM)
        w_scan_hart = w_scan_hart - PARA_CPU_NUM;
      if (~w_pick_valid & i_req_valid[w_scan_hart]) begin
        w_pick_valid = 1'b1;
        w_pick_hart = 2'(w_scan_hart);
      end
    end
    o_req_ready = '0;
    if (~reg_cmd_valid & ~reg_busy & i_rst_n_cluster & w_pick_valid)
      o_req_ready[w_pick_hart] = 1'b1;
  end

  // Command capture and sequencer handshake use registered metadata.
  assign w_capture = |(i_req_valid & o_req_ready);
  assign o_cmo_valid = reg_cmd_valid & i_rst_n_cluster;
  assign o_cmo_op = reg_cmd_op;
  assign o_cmo_pa_line = reg_cmd_pa_line;
  assign o_cmo_vaddr = reg_cmd_vaddr;
  assign o_cmo_pc = reg_cmd_pc;
  assign o_cmo_hart = reg_cmd_hart;
  assign w_issue = o_cmo_valid & i_cmo_ready;
  assign w_complete = i_cmo_done & (reg_busy | w_issue) & i_rst_n_cluster;

  // Do not broadcast a completion or accept a second command while one is active.
  always_comb begin : p_com_completion
    o_rsp_done = '0;
    o_rsp_err = '0;
    if (w_complete) begin
      o_rsp_done[reg_cmd_hart] = 1'b1;
      o_rsp_err[reg_cmd_hart] = i_cmo_err;
    end
  end

  // Preserve ownership until the sequencer reports terminal completion.
  always_ff @(posedge i_clk_cluster, negedge i_rst_n_cluster) begin : p_ff_cmd
    if (~i_rst_n_cluster) begin
      reg_cmd_valid <= 1'b0;
      reg_busy <= 1'b0;
      reg_rr_hart <= '0;
      reg_cmd_hart <= '0;
      reg_cmd_op <= '0;
      reg_cmd_pa_line <= '0;
      reg_cmd_vaddr <= '0;
      reg_cmd_pc <= '0;
    end else begin
      if (w_capture) begin
        reg_cmd_valid <= 1'b1;
        reg_cmd_hart <= w_pick_hart;
        reg_cmd_op <= i_req_op[w_pick_hart];
        reg_cmd_pa_line <= i_req_pa_line[w_pick_hart];
        reg_cmd_vaddr <= i_req_vaddr[w_pick_hart];
        reg_cmd_pc <= i_req_pc[w_pick_hart];
        reg_rr_hart <= (32'(w_pick_hart) == PARA_CPU_NUM - 32'd1)
                       ? 2'd0 : $bits(reg_rr_hart)'(w_pick_hart + 2'd1);
      end
      if (w_issue) begin
        reg_cmd_valid <= 1'b0;
        reg_busy <= 1'b1;
      end
      if (w_complete)
        reg_busy <= 1'b0;
    end
  end
endmodule
