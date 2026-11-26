/*
 * Project      : VLSIT RISC-V CPU Cluster
 * Author       : Quan Nguyen (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-08
 * Description  : Captures all PMU counter values atomically for AXI4-Lite low/high reads.
 */
`timescale 1ns/1ps

module m_vlsit_pmu_snapshot #(
  // Parameter Description: number of counter values captured by one snapshot command.
  // Parameter values: 1 through 32; default is 16.
  // Parameter unit: counters
  parameter logic [31:0] PARA_PMU_CNT_NUM = 32'd16,
  // Parameter Description: width of each live PMU counter.
  // Parameter values: 32 or 64; default is 64.
  // Parameter unit: bits
  parameter logic [31:0] PARA_PMU_CNT_W = 32'd64,
  localparam logic [31:0] LPARA_CSR_WORD_W = 32'd32,
  localparam logic [31:0] LPARA_PMU_CNT_W_64 = 32'd64
) (
  // Clock and reset
  input  wire                                               i_clk_cluster,
  input  wire                                               i_rst_n_cluster,

  // Snapshot command and live counter values
  input  wire                                               i_snapshot_req,
  input  wire  [PARA_PMU_CNT_NUM-1:0][PARA_PMU_CNT_W-1:0]   i_pmu_cnt_val,

  // Snapshot values and CSR hardware updates
  output logic [PARA_PMU_CNT_NUM-1:0][LPARA_CSR_WORD_W-1:0] o_pmu_cnt_lo_value,
  output logic [PARA_PMU_CNT_NUM-1:0][LPARA_CSR_WORD_W-1:0] o_pmu_cnt_hi_value,
  output logic                                              o_snapshot_req_clear,
  output logic                                              o_snapshot_done_wdata,
  output logic                                              o_snapshot_done_we
);

  logic [PARA_PMU_CNT_NUM-1:0][PARA_PMU_CNT_W-1:0] reg_pmu_snapshot_value;

  // Clear the write-only request and set the sticky done field on the same capture edge.
  always_comb begin : p_com_snapshot_ack
    o_snapshot_req_clear = i_snapshot_req;
    o_snapshot_done_wdata = i_snapshot_req;
    o_snapshot_done_we = i_snapshot_req;
  end

  // Capture every live counter on one clock edge and hold it until the next command.
  always_ff @(posedge i_clk_cluster, negedge i_rst_n_cluster) begin : p_ff_pmu_snapshot
    if (!i_rst_n_cluster)
      reg_pmu_snapshot_value <= '0;
    else if (i_snapshot_req)
      reg_pmu_snapshot_value <= i_pmu_cnt_val;
  end

  // Provide a consistent low/high pair to the generated 32-bit CSR registers.
  for (genvar gen_cnt_idx = 0; gen_cnt_idx < PARA_PMU_CNT_NUM; gen_cnt_idx++) begin : gen_snap_words
    // The low word exists in both supported counter widths.
    assign o_pmu_cnt_lo_value[gen_cnt_idx] = reg_pmu_snapshot_value[gen_cnt_idx][31:0];
    if (PARA_PMU_CNT_W == LPARA_PMU_CNT_W_64) begin : gen_pmu_cnt_64
      // The 64-bit profile exposes the captured high word.
      assign o_pmu_cnt_hi_value[gen_cnt_idx] = reg_pmu_snapshot_value[gen_cnt_idx][63:32];
    end else begin : gen_pmu_cnt_32
      // The 32-bit profile has no high word.
      assign o_pmu_cnt_hi_value[gen_cnt_idx] = '0;
    end
  end

endmodule
