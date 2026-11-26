/*
 * Project      : VLSIT RISC-V CPU Cluster
 * Author       : Quan Nguyen (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-08
 * Description  : Exposes sticky counter-overflow causes and one aggregate level interrupt.
 */
`timescale 1ns/1ps

module m_vlsit_pmu_irq #(
  // Parameter Description: number of implemented counter causes.
  // Parameter values: 1 through 32; default is 16.
  // Parameter unit: counters
  parameter logic [31:0] PARA_PMU_CNT_NUM = 32'd16,
  localparam logic [31:0] LPARA_IRQ_FIELD_W = 32'd32
) (
  // Raw causes and enables from the generated CSR
  input  wire  [LPARA_IRQ_FIELD_W-1:0] i_irq_raw,
  input  wire  [LPARA_IRQ_FIELD_W-1:0] i_irq_en,

  // Counter overflow events
  input  wire  [PARA_PMU_CNT_NUM-1:0]  i_pmu_cnt_ovf,

  // Generated CSR hardware load, pending status, and interrupt
  output logic [LPARA_IRQ_FIELD_W-1:0] o_irq_raw_wdata,
  output logic                         o_irq_raw_we,
  output logic [LPARA_IRQ_FIELD_W-1:0] o_irq_pending,
  output logic                         o_int_pmu
);

  // Any new overflow reloads the full W1C field with old causes preserved and new causes set.
  always_comb begin : p_com_pmu_irq
    o_irq_raw_wdata = i_irq_raw;
    o_irq_raw_we = 1'b0;
    o_irq_pending = i_irq_raw & i_irq_en;
    o_int_pmu = |o_irq_pending;
    for (int cnt_idx = 0; cnt_idx < PARA_PMU_CNT_NUM; cnt_idx++) begin
      if (i_pmu_cnt_ovf[cnt_idx]) begin
        o_irq_raw_wdata[cnt_idx] = 1'b1;
        o_irq_raw_we = 1'b1;
      end
    end
  end

endmodule
