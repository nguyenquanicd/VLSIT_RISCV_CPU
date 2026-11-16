/*
 * Project      : VLSIT RISC-V CPU Cluster
 * Author       : Quan Nguyen (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-08
 * Description  : Routes per-hart debug requests and returns active-hart debug status.
 */
`timescale 1ns/1ps

module m_vlsit_riscv_debug_router #(
  // Parameter Description: number of implemented CVA6 harts.
  // Parameter values: 2 or 4; default is 4.
  // Parameter unit: harts
  parameter logic [31:0] PARA_CPU_NUM = 32'd4,
  localparam logic [31:0] LPARA_DEBUG_LANE_NUM = 32'd4
) (
  // Four-lane cluster debug interface
  input  wire  [LPARA_DEBUG_LANE_NUM-1:0] i_hart_debug_req,
  output logic [LPARA_DEBUG_LANE_NUM-1:0] o_hart_debug_mode,

  // Active CVA6 debug interface
  output logic [PARA_CPU_NUM-1:0]         o_cva6_debug_req,
  input  wire  [PARA_CPU_NUM-1:0]         i_cva6_debug_mode
);

  // Route only implemented request lanes and clear status for unimplemented harts.
  always_comb begin : p_com_debug_router
    o_cva6_debug_req = i_hart_debug_req[PARA_CPU_NUM-1:0];
    o_hart_debug_mode = '0;
    for (int hart_idx = 0; hart_idx < PARA_CPU_NUM; hart_idx++) begin
      o_hart_debug_mode[hart_idx] = i_cva6_debug_mode[hart_idx];
    end
  end

endmodule
