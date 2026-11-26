/*
 * Project      : VLSIT RISC-V CPU Cluster
 * Author       : Quan Nguyen (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-16
 * Description  : Reset-only first-fatal record; DEC-039/040, REQ-ERR-003.
 */
`timescale 1ns/1ps

module m_vlsit_riscv_fault_record #(
  // Parameter Description: number of active L1 fault sources.
  // Parameter values: 2 or 4; default is 4.
  // Parameter unit: harts
  parameter logic [31:0] PARA_CPU_NUM = 32'd4,
  localparam logic [31:0] LPARA_SRC_L1 = 32'd1,
  localparam logic [31:0] LPARA_SRC_LLC = 32'd2,
  localparam logic [31:0] LPARA_STS_L1 = 32'h0000_001D,
  localparam logic [31:0] LPARA_STS_LLC = 32'h0000_0015
) (
  // Clock and reset
  input  wire              i_clk_cluster,
  input  wire              i_rst_n_cluster,

  // Accepted ordinary L1 writeback errors, indexed by hart
  input  wire  [3:0]       i_l1_fault_valid,
  input  wire  [3:0][55:0] i_l1_fault_addr,
  input  wire  [3:0][1:0]  i_l1_fault_resp,

  // Accepted non-maintenance LLC writeback error
  input  wire              i_llc_fault_valid,
  input  wire  [55:0]      i_llc_fault_addr,
  input  wire  [1:0]       i_llc_fault_resp,

  // Stable read-only CSR payload; reset is the only clear
  output logic [31:0]      o_fault_sts,
  output logic [31:0]      o_fault_info,
  output logic [31:0]      o_fault_addr_lo,
  output logic [31:0]      o_fault_addr_hi
);

  logic w_event_valid;
  logic w_event_more;
  logic [31:0] w_event_sts;
  logic [31:0] w_event_info;
  logic [55:0] w_event_addr;
  logic [31:0] reg_fault_sts;
  logic [31:0] reg_fault_info;
  logic [55:0] reg_fault_addr;

  // Select the lowest active L1 hart before LLC; count additional events
  // without treating an already-sticky notification as another event.
  always_comb begin : p_com_fault_pick
    w_event_valid = 1'b0;
    w_event_more = 1'b0;
    w_event_sts = '0;
    w_event_info = '0;
    w_event_addr = '0;
    for (int hart_idx = 0; hart_idx < PARA_CPU_NUM; hart_idx++) begin
      if (i_l1_fault_valid[hart_idx]) begin
        if (~w_event_valid) begin
          w_event_sts = LPARA_STS_L1;
          w_event_info = {22'b0, 2'(hart_idx), 2'b0,
                          i_l1_fault_resp[hart_idx], 4'(LPARA_SRC_L1)};
          w_event_addr = i_l1_fault_addr[hart_idx];
        end
        w_event_more = w_event_more | w_event_valid;
        w_event_valid = 1'b1;
      end
    end
    if (i_llc_fault_valid) begin
      if (~w_event_valid) begin
        w_event_sts = LPARA_STS_LLC;
        w_event_info = {26'b0, i_llc_fault_resp, 4'(LPARA_SRC_LLC)};
        w_event_addr = i_llc_fault_addr;
      end
      w_event_more = w_event_more | w_event_valid;
      w_event_valid = 1'b1;
    end
  end

  // Publish payload and valid together. Later errors change only multiple;
  // no software operation can release the failed cache transaction.
  always_ff @(posedge i_clk_cluster, negedge i_rst_n_cluster) begin : p_ff_fault_record
    if (!i_rst_n_cluster) begin
      reg_fault_sts <= '0;
      reg_fault_info <= '0;
      reg_fault_addr <= '0;
    end else if (w_event_valid) begin
      if (~reg_fault_sts[0]) begin
        reg_fault_sts <= w_event_sts | {30'b0, w_event_more, 1'b0};
        reg_fault_info <= w_event_info;
        reg_fault_addr <= w_event_addr;
      end else begin
        reg_fault_sts[1] <= 1'b1;
      end
    end
  end

  // High byte is zero because the cluster implements a 56-bit physical address.
  assign o_fault_sts = reg_fault_sts;
  assign o_fault_info = reg_fault_info;
  assign o_fault_addr_lo = reg_fault_addr[31:0];
  assign o_fault_addr_hi = {8'b0, reg_fault_addr[55:32]};

endmodule
