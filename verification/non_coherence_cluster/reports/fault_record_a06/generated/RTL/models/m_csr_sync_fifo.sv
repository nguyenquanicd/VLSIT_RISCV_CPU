/*
 * Project      : VLSIT RISC-V CPU Cluster
 * Author       : Quan Nguyen (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-16
 * Description  : Single-clock first-word-fall-through FIFO for CSR bus requests and responses.
 *                Behavioral model only; replace with a technology-qualified FIFO when required.
 *                The RTL follows the VLSIT RTL Design Rule v2.
 */
`timescale 1ns/1ps

module m_csr_sync_fifo #(
  // Parameter Description: width of each FIFO entry.
  // Parameter values: 1 or greater; default is 32.
  // Parameter unit: bits
  parameter logic [31:0] PARA_DATA_W = 32'd32,
  // Parameter Description: number of FIFO entries; must be a power of two.
  // Parameter values: 2 or greater; default is 2.
  // Parameter unit: entries
  parameter logic [31:0] PARA_DEPTH = 32'd2,
  localparam logic [31:0] LPARA_PTR_W = $clog2(PARA_DEPTH),
  localparam logic [31:0] LPARA_CNT_W = $clog2(PARA_DEPTH + 32'd1)
) (
  // FIFO clock and reset
  input  wire                    i_clk_bus,
  input  wire                    i_rst_n_bus,

  // FIFO write interface
  input  wire                    i_w_valid,
  output logic                   o_w_ready,
  input  wire  [PARA_DATA_W-1:0] i_w_data,

  // FIFO read interface
  output logic                   o_r_valid,
  input  wire                    i_r_ready,
  output logic [PARA_DATA_W-1:0] o_r_data
);
  logic [PARA_DATA_W-1:0] reg_mem [0:PARA_DEPTH-1];
  logic [LPARA_PTR_W-1:0] reg_wr_ptr;
  logic [LPARA_PTR_W-1:0] reg_rd_ptr;
  logic [LPARA_CNT_W-1:0] reg_count;
  logic w_wr_hs;
  logic w_rd_hs;

  // Derive FIFO handshake state and expose the current first-word-fall-through entry.
  assign o_r_valid = (reg_count != '0);
  assign o_w_ready = (reg_count < LPARA_CNT_W'(PARA_DEPTH)) | (o_r_valid & i_r_ready);
  assign o_r_data = reg_mem[reg_rd_ptr];
  assign w_wr_hs = i_w_valid & o_w_ready;
  assign w_rd_hs = o_r_valid & i_r_ready;

  // FIFO pointers and occupancy update together on accepted push/pop operations.
  always_ff @(posedge i_clk_bus, negedge i_rst_n_bus) begin : p_ff_sync_fifo_state
    if (!i_rst_n_bus) begin
      reg_wr_ptr <= '0;
      reg_rd_ptr <= '0;
      reg_count <= '0;
    end else begin
      case ({w_wr_hs, w_rd_hs})
        2'b10: reg_count <= reg_count + 1'b1;
        2'b01: reg_count <= reg_count - 1'b1;
        default: reg_count <= reg_count;
      endcase
      if (w_wr_hs) begin
        reg_mem[reg_wr_ptr] <= i_w_data;
        if (reg_wr_ptr == LPARA_PTR_W'(PARA_DEPTH - 32'd1))
          reg_wr_ptr <= '0;
        else
          reg_wr_ptr <= reg_wr_ptr + 1'b1;
      end
      if (w_rd_hs) begin
        if (reg_rd_ptr == LPARA_PTR_W'(PARA_DEPTH - 32'd1))
          reg_rd_ptr <= '0;
        else
          reg_rd_ptr <= reg_rd_ptr + 1'b1;
      end
    end
  end
endmodule
