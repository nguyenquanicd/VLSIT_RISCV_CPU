/*
 * Project      : VLSIT RISC-V CPU Cluster
 * Author       : Quan Nguyen (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-08
 * Description  : Sums same-cycle per-hart event occurrences for aggregate PMU scope.
 */
`timescale 1ns/1ps

module m_vlsit_pmu_aggregate #(
  // Parameter Description: number of active harts included in aggregation.
  // Parameter values: 2 or 4; default is 4.
  // Parameter unit: harts
  parameter logic [31:0] PARA_CPU_NUM = 32'd4,
  localparam logic [31:0] LPARA_HART_EVT_NUM = 32'd38
) (
  // Hart activity and event indicators
  input  wire  [PARA_CPU_NUM-1:0]                         i_hart_active,
  input  wire  [PARA_CPU_NUM-1:0][LPARA_HART_EVT_NUM-1:0] i_hart_evt,

  // Sum of event occurrences across active harts
  output logic [LPARA_HART_EVT_NUM-1:0][2:0]              o_evt_cnt
);

  // A four-hart cluster can produce at most four occurrences of a per-hart event per cycle.
  always_comb begin : p_com_pmu_aggregate
    o_evt_cnt = '0;
    for (int event_idx = 0; event_idx < LPARA_HART_EVT_NUM; event_idx++) begin
      for (int hart_idx = 0; hart_idx < PARA_CPU_NUM; hart_idx++) begin
        if (i_hart_active[hart_idx] && i_hart_evt[hart_idx][event_idx])
          o_evt_cnt[event_idx] = $bits(o_evt_cnt[event_idx])'(o_evt_cnt[event_idx] + 1'b1);
      end
    end
  end

endmodule
