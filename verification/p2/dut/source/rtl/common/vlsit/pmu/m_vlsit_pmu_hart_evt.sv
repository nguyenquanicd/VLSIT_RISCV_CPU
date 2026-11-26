/*
 * Project      : VLSIT RISC-V CPU Cluster
 * Author       : Quan Nguyen (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-08
 * Description  : Packs the reviewed CVA6 and HPDcache event taps for each active hart.
 */
`timescale 1ns/1ps

module m_vlsit_pmu_hart_evt #(
  // Parameter Description: number of active CVA6/HPDcache event sources.
  // Parameter values: 2 or 4; default is 4.
  // Parameter unit: harts
  parameter logic [31:0] PARA_CPU_NUM = 32'd4,
  localparam logic [31:0] LPARA_CVA6_EVT_NUM = 32'd22,
  localparam logic [31:0] LPARA_HPD_EVT_NUM  = 32'd16,
  localparam logic [31:0] LPARA_HART_EVT_NUM = 32'd38
) (
  // Per-hart CVA6 event taps
  input  wire  [PARA_CPU_NUM-1:0][LPARA_CVA6_EVT_NUM-1:0] i_cva6_evt,

  // Per-hart HPDcache event taps
  input  wire  [PARA_CPU_NUM-1:0][LPARA_HPD_EVT_NUM-1:0]  i_hpdcache_evt,

  // Packed CVA6 then HPDcache events for each hart
  output logic [PARA_CPU_NUM-1:0][LPARA_HART_EVT_NUM-1:0] o_hart_evt
);

  // Preserve the event-map order: CVA6 IDs 0x0001..0x0016, then HPDcache 0x0100..0x010F.
  for (genvar gen_hart_idx = 0; gen_hart_idx < PARA_CPU_NUM; gen_hart_idx++) begin : gen_hart_evt
    // Keep each hart's CVA6 and HPDcache event vectors adjacent in the packed output.
    assign o_hart_evt[gen_hart_idx] = {i_hpdcache_evt[gen_hart_idx], i_cva6_evt[gen_hart_idx]};
  end

endmodule
