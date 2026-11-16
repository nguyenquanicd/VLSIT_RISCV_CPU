/*
 * Project      : VLSIT RISC-V CPU Cluster
 * Author       : Quan Nguyen (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-08
 * Description  : Implements programmable modulo counters and combinational wrap events.
 */
`timescale 1ns/1ps

module m_vlsit_pmu_counter_bank #(
  // Parameter Description: number of implemented programmable event counters.
  // Parameter values: 1 through 32; default is 16.
  // Parameter unit: counters
  parameter logic [31:0] PARA_PMU_CNT_NUM = 32'd16,
  // Parameter Description: width of each modulo event counter.
  // Parameter values: 32 or 64; default is 64.
  // Parameter unit: bits
  parameter logic [31:0] PARA_PMU_CNT_W = 32'd64,
  localparam logic [31:0] LPARA_EVT_COUNT_W = 32'd3
) (
  // Clock and reset
  input  wire                                                i_clk_cluster,
  input  wire                                                i_rst_n_cluster,

  // Counter enable and selected event occurrence count
  input  wire  [PARA_PMU_CNT_NUM-1:0]                        i_pmu_cnt_en,
  input  wire  [PARA_PMU_CNT_NUM-1:0][LPARA_EVT_COUNT_W-1:0] i_evt_cnt,

  // Counter values and wrap events
  output logic [PARA_PMU_CNT_NUM-1:0][PARA_PMU_CNT_W-1:0]    o_pmu_cnt_val,
  output logic [PARA_PMU_CNT_NUM-1:0]                        o_pmu_cnt_ovf
);

  logic [PARA_PMU_CNT_NUM-1:0][PARA_PMU_CNT_W-1:0] reg_pmu_cnt_val;
  logic [PARA_PMU_CNT_NUM-1:0][PARA_PMU_CNT_W:0]   w_pmu_cnt_sum;

  // Compute the modulo result and detect a carry beyond the configured counter width.
  always_comb begin : p_com_pmu_cnt_sum
    w_pmu_cnt_sum = '0;
    o_pmu_cnt_ovf = '0;
    for (int cnt_idx = 0; cnt_idx < PARA_PMU_CNT_NUM; cnt_idx++) begin
      w_pmu_cnt_sum[cnt_idx] = $bits(w_pmu_cnt_sum[cnt_idx])'(
        {1'b0, reg_pmu_cnt_val[cnt_idx]} +
        $bits(w_pmu_cnt_sum[cnt_idx])'(i_evt_cnt[cnt_idx])
      );
      o_pmu_cnt_ovf[cnt_idx] = i_pmu_cnt_en[cnt_idx] &&
                               (|i_evt_cnt[cnt_idx]) &&
                               w_pmu_cnt_sum[cnt_idx][PARA_PMU_CNT_W];
    end
  end

  // Update each enabled counter once per sampled event-count vector.
  always_ff @(posedge i_clk_cluster, negedge i_rst_n_cluster) begin : p_ff_pmu_cnt
    if (!i_rst_n_cluster) begin
      reg_pmu_cnt_val <= '0;
    end else begin
      for (int cnt_idx = 0; cnt_idx < PARA_PMU_CNT_NUM; cnt_idx++) begin
        if (i_pmu_cnt_en[cnt_idx] && (|i_evt_cnt[cnt_idx]))
          reg_pmu_cnt_val[cnt_idx] <= w_pmu_cnt_sum[cnt_idx][PARA_PMU_CNT_W-1:0];
      end
    end
  end

  // Expose the live modulo count to snapshot logic.
  assign o_pmu_cnt_val = reg_pmu_cnt_val;

endmodule
