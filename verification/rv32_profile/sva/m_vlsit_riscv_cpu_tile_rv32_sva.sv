/*
 * Project      : VLSIT RISC-V CPU Cluster
 * Author       : Quan Nguyen (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-25
 * Description  : Verification-only assertions for the RV32 CPU tile width adapters,
 *                bound to m_vlsit_riscv_cpu_tile (kept out of design RTL, rule R-010).
 * Decision     : DEC-104 (doc/specification_32)
 * Requirements : SVA-101 / REQ-XL-007, SVA-102 / REQ-XL-008, SVA-103 / REQ-XL-006.
 */
`timescale 1ns/1ps

module m_vlsit_riscv_cpu_tile_rv32_sva #(
  parameter logic [31:0] PARA_COH_TXN_NUM = 32'd8,
  parameter logic [31:0] PARA_CORE_NLINE_W = 32'd30,
  parameter logic [31:0] PARA_CORE_PLEN = 32'd34
) (
  // Clock and reset
  input wire                                    i_clk_tile,
  input wire                                    i_rst_n_tile,

  // Boot address
  input wire  [63:0]                            i_boot_addr,

  // Line addresses entering the core
  input wire                                    i_coh_probe_query_valid,
  input wire  [51:0]                            i_coh_probe_query_nline,
  input wire  [PARA_COH_TXN_NUM-1:0]            i_coh_line_lock_valid,
  input wire  [PARA_COH_TXN_NUM-1:0][51:0]      i_coh_line_lock_nline,
  input wire                                    i_coh_probe_req_valid,
  input wire  [51:0]                            i_coh_probe_req_nline,
  input wire                                    i_coh_cache_gnt_valid,
  input wire  [51:0]                            i_coh_cache_gnt_nline,

  // AXI addresses leaving the tile
  input wire                                    o_axi_awvalid,
  input wire  [63:0]                            o_axi_awaddr,
  input wire                                    o_axi_arvalid,
  input wire  [63:0]                            o_axi_araddr
);

  // SVA-101: upper line-address bits entering the core are zero (REQ-XL-007).
  if (PARA_CORE_NLINE_W < 32'd52) begin : gen_line_checks
    a_sva101_probe_query: assert property (@(posedge i_clk_tile) disable iff (!i_rst_n_tile)
      i_coh_probe_query_valid |-> (i_coh_probe_query_nline[51:PARA_CORE_NLINE_W] == '0));
    a_sva101_probe_req: assert property (@(posedge i_clk_tile) disable iff (!i_rst_n_tile)
      i_coh_probe_req_valid |-> (i_coh_probe_req_nline[51:PARA_CORE_NLINE_W] == '0));
    a_sva101_gnt: assert property (@(posedge i_clk_tile) disable iff (!i_rst_n_tile)
      i_coh_cache_gnt_valid |-> (i_coh_cache_gnt_nline[51:PARA_CORE_NLINE_W] == '0));
    for (genvar lock_idx = 0; lock_idx < PARA_COH_TXN_NUM; lock_idx++) begin : gen_lock
      a_sva101_lock: assert property (@(posedge i_clk_tile) disable iff (!i_rst_n_tile)
        i_coh_line_lock_valid[lock_idx]
        |-> (i_coh_line_lock_nline[lock_idx][51:PARA_CORE_NLINE_W] == '0));
    end
  end

  // SVA-102: boot address upper half is zero while reset is asserted (REQ-XL-008).
  a_sva102_boot: assert property (@(posedge i_clk_tile)
    !i_rst_n_tile |-> (i_boot_addr[63:32] == 32'd0));

  // SVA-103: AXI address bits above PLEN are zero (REQ-XL-006).
  if (PARA_CORE_PLEN < 32'd64) begin : gen_axi_checks
    a_sva103_aw: assert property (@(posedge i_clk_tile) disable iff (!i_rst_n_tile)
      o_axi_awvalid |-> (o_axi_awaddr[63:PARA_CORE_PLEN] == '0));
    a_sva103_ar: assert property (@(posedge i_clk_tile) disable iff (!i_rst_n_tile)
      o_axi_arvalid |-> (o_axi_araddr[63:PARA_CORE_PLEN] == '0));
  end

endmodule

// Bind into every tile instance; PARA_CORE_NLINE_W and PLEN follow the tile's RV32 widths.
bind m_vlsit_riscv_cpu_tile m_vlsit_riscv_cpu_tile_rv32_sva #(
  .PARA_COH_TXN_NUM(PARA_COH_TXN_NUM),
  .PARA_CORE_NLINE_W(LPARA_CORE_NLINE_W),
  .PARA_CORE_PLEN(LPARA_CORE_NLINE_W + 32'd4)
) u_rv32_sva (.*);
