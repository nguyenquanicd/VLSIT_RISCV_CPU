/*
 * Project      : VLSIT RISC-V CPU Cluster
 * Author       : Quan Nguyen (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-08
 * Description  : Integrates event selection, programmable counters, snapshot, and PMU IRQ logic.
 * Change History:
 * 2026-11-20 - Modified by Quan Nguyen and Codex - VLSI Technology page:
 *              Add optional event/counter pipeline and drain-aware snapshot timing.
 */
`timescale 1ns/1ps

module m_vlsit_riscv_pmu #(
  // Parameter Description: number of instantiated CVA6/HPDcache harts.
  // Parameter values: 2 or 4; default is 4.
  // Parameter unit: harts
  parameter logic [31:0] PARA_CPU_NUM = 32'd4,
  // Parameter Description: number of programmable event counters.
  // Parameter values: 1 through 32; default is 16.
  // Parameter unit: counters
  parameter logic [31:0] PARA_PMU_CNT_NUM = 32'd16,
  // Parameter Description: width of the programmable event counters.
  // Parameter values: 32 or 64; default is 64.
  // Parameter unit: bits
  parameter logic [31:0] PARA_PMU_CNT_W = 32'd64,
  // Parameter Description: compile-time cluster timing profile.
  // Parameter values: 0 = low latency, 1 = registered cluster event path; default is 0.
  // Parameter unit: profile index
  parameter logic [31:0] PARA_TIMING_PROFILE = 32'd0,
  localparam logic [31:0] LPARA_TIMING_PROFILE_LOW_LATENCY = 32'd0,
  localparam logic [31:0] LPARA_TIMING_PROFILE_CLUSTER_TIMING = 32'd1,
  localparam logic [31:0] LPARA_CVA6_EVT_NUM = 32'd22,
  localparam logic [31:0] LPARA_HPD_EVT_NUM  = 32'd16,
  localparam logic [31:0] LPARA_HART_EVT_NUM = 32'd38,
  localparam logic [31:0] LPARA_LLC_EVT_NUM  = 32'd28,
  localparam logic [31:0] LPARA_CCU_EVT_NUM  = 32'd12
) (
  // Clock and reset
  input  wire                                             i_clk_cluster,
  input  wire                                             i_rst_n_cluster,

  // Hart state and source event taps
  input  wire  [PARA_CPU_NUM-1:0]                         i_hart_active,
  input  wire  [PARA_CPU_NUM-1:0][LPARA_CVA6_EVT_NUM-1:0] i_cva6_evt,
  input  wire  [PARA_CPU_NUM-1:0][LPARA_HPD_EVT_NUM-1:0]  i_hpdcache_evt,
  input  wire  [LPARA_LLC_EVT_NUM-1:0]                    i_llc_evt,
  input  wire  [LPARA_CCU_EVT_NUM-1:0][2:0]               i_ccu_evt_count,

  // CSR event configuration
  input  wire  [PARA_PMU_CNT_NUM-1:0][15:0]               i_pmu_evt_event_id,
  input  wire  [PARA_PMU_CNT_NUM-1:0][2:0]                i_pmu_evt_scope,
  input  wire  [PARA_PMU_CNT_NUM-1:0]                     i_pmu_evt_en,

  // CSR snapshot and overflow configuration
  input  wire                                             i_pmu_ctrl_snapshot_req,
  input  wire  [31:0]                                     i_irq_en_overflow_en,
  input  wire  [31:0]                                     i_irq_raw_overflow,

  // CSR counter read data and hardware updates
  output logic [PARA_PMU_CNT_NUM-1:0][31:0]               o_pmu_count_lo_value,
  output logic [PARA_PMU_CNT_NUM-1:0][31:0]               o_pmu_count_hi_value,
  output logic                                            o_pmu_ctrl_snapshot_req_clear,
  output logic                                            o_pmu_ctrl_snapshot_done_wdata,
  output logic                                            o_pmu_ctrl_snapshot_done_we,
  output logic [31:0]                                     o_irq_raw_overflow_wdata,
  output logic                                            o_irq_raw_overflow_we,
  output logic [31:0]                                     o_irq_sts_overflow_pending,

  // Aggregate PMU interrupt
  output logic                                            o_int_pmu
);

  logic [PARA_CPU_NUM-1:0][LPARA_HART_EVT_NUM-1:0] w_hart_evt;
  logic [LPARA_HART_EVT_NUM-1:0][2:0] w_hart_agg_evt_count;
  logic [39:0][2:0] w_cluster_evt_count;
  logic [PARA_PMU_CNT_NUM-1:0][2:0] w_pmu_evt_count;
  logic [PARA_PMU_CNT_NUM-1:0][2:0] w_pmu_evt_count_to_bank;
  logic [PARA_PMU_CNT_NUM-1:0] w_pmu_evt_en_to_bank;
  logic [PARA_PMU_CNT_NUM-1:0][2:0] reg_pmu_evt_count;
  logic [PARA_PMU_CNT_NUM-1:0] reg_pmu_evt_en;
  logic [PARA_PMU_CNT_NUM-1:0][PARA_PMU_CNT_W-1:0] w_pmu_cnt_value;
  logic [PARA_PMU_CNT_NUM-1:0] w_pmu_cnt_ovf;
  logic w_snapshot_req_to_capture;
  logic reg_snapshot_req_stage1;
  logic reg_snapshot_req_stage2;
  logic reg_snapshot_req_seen;

  // Pack native CVA6 and HPDcache event taps in the workbook's per-hart order.
  m_vlsit_pmu_hart_evt #(
    .PARA_CPU_NUM (PARA_CPU_NUM)
  ) u_vlsit_pmu_hart_evt (
    .i_cva6_evt    (i_cva6_evt),
    .i_hpdcache_evt(i_hpdcache_evt),
    .o_hart_evt    (w_hart_evt)
  );

  // Preserve LLC single-event indicators and CCU same-cycle occurrence counts.
  m_vlsit_pmu_cluster_evt u_vlsit_pmu_cluster_evt (
    .i_llc_evt        (i_llc_evt),
    .i_ccu_evt_count  (i_ccu_evt_count),
    .o_cluster_evt_count(w_cluster_evt_count)
  );

  // Sum per-hart indicators for aggregate scope while excluding inactive harts.
  m_vlsit_pmu_aggregate #(
    .PARA_CPU_NUM (PARA_CPU_NUM)
  ) u_vlsit_pmu_aggregate (
    .i_hart_active(i_hart_active),
    .i_hart_evt   (w_hart_evt),
    .o_evt_cnt    (w_hart_agg_evt_count)
  );

  // Select only event IDs and scope combinations defined by the reviewed event catalog.
  m_vlsit_pmu_event_select #(
    .PARA_CPU_NUM     (PARA_CPU_NUM),
    .PARA_PMU_CNT_NUM (PARA_PMU_CNT_NUM)
  ) u_vlsit_pmu_evt_sel (
    .i_hart_active          (i_hart_active),
    .i_hart_evt             (w_hart_evt),
    .i_hart_agg_evt_count   (w_hart_agg_evt_count),
    .i_cluster_evt_count    (w_cluster_evt_count),
    .i_pmu_evt_id           (i_pmu_evt_event_id),
    .i_pmu_evt_scope        (i_pmu_evt_scope),
    .o_pmu_evt_count        (w_pmu_evt_count)
  );

  // Profile 1 registers event counts and enables before the counter incrementer.
  always_ff @(posedge i_clk_cluster, negedge i_rst_n_cluster) begin : p_ff_pmu_event_pipe
    if (!i_rst_n_cluster) begin
      reg_pmu_evt_count <= '0;
      reg_pmu_evt_en <= '0;
    end else begin
      reg_pmu_evt_count <= w_pmu_evt_count;
      reg_pmu_evt_en <= i_pmu_evt_en;
    end
  end

  // Delay and acknowledge one snapshot request after pending event vectors drain.
  always_ff @(posedge i_clk_cluster, negedge i_rst_n_cluster) begin : p_ff_pmu_snapshot_pipe
    if (!i_rst_n_cluster) begin
      reg_snapshot_req_stage1 <= 1'b0;
      reg_snapshot_req_stage2 <= 1'b0;
      reg_snapshot_req_seen <= 1'b0;
    end else begin
      if (!i_pmu_ctrl_snapshot_req)
        reg_snapshot_req_seen <= 1'b0;
      else if (!reg_snapshot_req_seen)
        reg_snapshot_req_seen <= 1'b1;
      reg_snapshot_req_stage1 <= i_pmu_ctrl_snapshot_req & ~reg_snapshot_req_seen;
      reg_snapshot_req_stage2 <= reg_snapshot_req_stage1;
    end
  end

  if (PARA_TIMING_PROFILE == LPARA_TIMING_PROFILE_CLUSTER_TIMING) begin : gen_pmu_timing_profile
    assign w_pmu_evt_count_to_bank = reg_pmu_evt_count;
    assign w_pmu_evt_en_to_bank = reg_pmu_evt_en;
    assign w_snapshot_req_to_capture = reg_snapshot_req_stage2;
  end else begin : gen_pmu_low_latency_profile
    assign w_pmu_evt_count_to_bank = w_pmu_evt_count;
    assign w_pmu_evt_en_to_bank = i_pmu_evt_en;
    assign w_snapshot_req_to_capture = i_pmu_ctrl_snapshot_req;
  end

  // Count selected occurrences modulo the configured 32-bit or 64-bit width.
  m_vlsit_pmu_counter_bank #(
    .PARA_PMU_CNT_NUM (PARA_PMU_CNT_NUM),
    .PARA_PMU_CNT_W   (PARA_PMU_CNT_W)
  ) u_vlsit_pmu_cnt_bank (
    .i_clk_cluster    (i_clk_cluster),
    .i_rst_n_cluster  (i_rst_n_cluster),
    .i_pmu_cnt_en     (w_pmu_evt_en_to_bank),
    .i_evt_cnt        (w_pmu_evt_count_to_bank),
    .o_pmu_cnt_val    (w_pmu_cnt_value),
    .o_pmu_cnt_ovf    (w_pmu_cnt_ovf)
  );

  // Snapshot all counters on one edge and map them to stable low/high CSR words.
  m_vlsit_pmu_snapshot #(
    .PARA_PMU_CNT_NUM (PARA_PMU_CNT_NUM),
    .PARA_PMU_CNT_W   (PARA_PMU_CNT_W)
  ) u_vlsit_pmu_snapshot (
    .i_clk_cluster               (i_clk_cluster),
    .i_rst_n_cluster             (i_rst_n_cluster),
    .i_snapshot_req              (w_snapshot_req_to_capture),
    .i_pmu_cnt_val               (w_pmu_cnt_value),
    .o_pmu_cnt_lo_value          (o_pmu_count_lo_value),
    .o_pmu_cnt_hi_value          (o_pmu_count_hi_value),
    .o_snapshot_req_clear        (o_pmu_ctrl_snapshot_req_clear),
    .o_snapshot_done_wdata       (o_pmu_ctrl_snapshot_done_wdata),
    .o_snapshot_done_we          (o_pmu_ctrl_snapshot_done_we)
  );

  // Latch counter wrap causes in the generated W1C CSR and drive the aggregate level IRQ.
  m_vlsit_pmu_irq #(
    .PARA_PMU_CNT_NUM (PARA_PMU_CNT_NUM)
  ) u_vlsit_pmu_irq (
    .i_irq_raw         (i_irq_raw_overflow),
    .i_irq_en          (i_irq_en_overflow_en),
    .i_pmu_cnt_ovf     (w_pmu_cnt_ovf),
    .o_irq_raw_wdata   (o_irq_raw_overflow_wdata),
    .o_irq_raw_we      (o_irq_raw_overflow_we),
    .o_irq_pending     (o_irq_sts_overflow_pending),
    .o_int_pmu         (o_int_pmu)
  );

endmodule
