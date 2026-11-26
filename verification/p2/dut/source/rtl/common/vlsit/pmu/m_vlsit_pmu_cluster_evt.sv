/*
 * Project      : VLSIT RISC-V CPU Cluster
 * Author       : Quan Nguyen (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-08
 * Description  : Packs LLC indicators and CCU occurrence counts into cluster event slots.
 */
`timescale 1ns/1ps

module m_vlsit_pmu_cluster_evt #(
  localparam logic [31:0] LPARA_LLC_EVT_NUM     = 32'd28,
  localparam logic [31:0] LPARA_CCU_EVT_NUM     = 32'd12,
  localparam logic [31:0] LPARA_CLUSTER_EVT_NUM = 32'd40
) (
  // LLC event indicators, in workbook order
  input  wire  [27:0]                           i_llc_evt,

  // CCU event occurrence counts, in workbook order
  input  wire  [11:0][2:0]                      i_ccu_evt_count,

  // Cluster event slots: 28 LLC events followed by 12 CCU events
  output logic [LPARA_CLUSTER_EVT_NUM-1:0][2:0] o_cluster_evt_count
);

  // Expand single LLC indicators to occurrence counts and preserve CCU multiplicity.
  always_comb begin : p_com_cluster_evt
    o_cluster_evt_count = '0;
    for (int event_idx = 0; event_idx < LPARA_LLC_EVT_NUM; event_idx++) begin
      o_cluster_evt_count[event_idx] = {2'b00, i_llc_evt[event_idx]};
    end
    for (int event_idx = 0; event_idx < LPARA_CCU_EVT_NUM; event_idx++) begin
      o_cluster_evt_count[LPARA_LLC_EVT_NUM + event_idx] = i_ccu_evt_count[event_idx];
    end
  end

endmodule
