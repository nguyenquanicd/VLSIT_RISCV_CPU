// -----------------------------------------------------------------------------
// AI-GENERATED (Claude Opus 5.5, 2026-11-28) - candidate artifact (R-117, R-231).
// Formal property checkers for t_rv32d_fv_pmu (Q-G0-10 A). Port contracts from
// REF-001 rev 0.39 Section 14.4.8 (m_vlsit_pmu_counter_bank), 14.4.11
// (m_vlsit_pmu_irq), 14.4.12 (m_vlsit_pmu_snapshot); semantics from REQ-PMU-002,
// REQ-PMU-003, REQ-PMU-004 and the 14.4 working/data-flow text. Immediate
// assertions with $past for the open-source Yosys formal front end. Bound with
// `bind` in fv_pmu_bind.sv. No RTL read. Human review pending.
// -----------------------------------------------------------------------------
// a_pmu_wrap / a_pmu_ovf_on_carry : counter bank (REQ-PMU-002, REQ-PMU-004)
module fv_pmu_counter_bank_props #(parameter int N = 16, parameter int W = 64, parameter int EW = 3) (
  input logic i_clk_cluster, input logic i_rst_n_cluster,
  input logic [N-1:0] i_pmu_cnt_en, input logic [N-1:0][EW-1:0] i_evt_cnt,
  input logic [N-1:0][W-1:0] o_pmu_cnt_val, input logic [N-1:0] o_pmu_cnt_ovf
);
  logic past_valid = 1'b0;
  always @(posedge i_clk_cluster) past_valid <= 1'b1;
  always @(posedge i_clk_cluster) begin
    if (past_valid && $past(i_rst_n_cluster) && i_rst_n_cluster) begin
      for (int k = 0; k < N; k++) begin
        if ($past(i_pmu_cnt_en[k])) begin
          // a_pmu_wrap: value' = (value + count) mod 2^W
          a_pmu_wrap: assert (o_pmu_cnt_val[k] == W'($past(o_pmu_cnt_val[k]) + W'($past(i_evt_cnt[k]))));
        end else begin
          a_pmu_hold: assert (o_pmu_cnt_val[k] == $past(o_pmu_cnt_val[k]));
        end
      end
    end
  end
  // a_pmu_ovf_on_carry: overflow event equals the carry out of the enabled update (combinational, same cycle)
  always @* begin
    for (int k = 0; k < N; k++) begin
      a_pmu_ovf_on_carry: assert (o_pmu_cnt_ovf[k] == (i_pmu_cnt_en[k] && ((W+1)'(o_pmu_cnt_val[k]) + (W+1)'(i_evt_cnt[k])) >> W != 0));
      c_pmu_ovf: cover (o_pmu_cnt_ovf[k]);
    end
  end
endmodule

// a_pmu_irq_level / a_pmu_hw_wins : IRQ merge (REQ-PMU-004; 14.4.11 "reload the hardware
// update word with old raw causes OR new causes"; pending = raw AND enable)
module fv_pmu_irq_props #(parameter int N = 16, parameter int F = 32) (
  input logic [F-1:0] i_irq_raw, input logic [F-1:0] i_irq_en, input logic [N-1:0] i_pmu_cnt_ovf,
  input logic [F-1:0] o_irq_raw_wdata, input logic o_irq_raw_we, input logic [F-1:0] o_irq_pending, input logic o_int_pmu
);
  always @* begin
    a_pmu_pending: assert (o_irq_pending == (i_irq_raw & i_irq_en));
    a_pmu_irq_level: assert (o_int_pmu == |(i_irq_raw & i_irq_en));
    a_pmu_raw_we: assert (o_irq_raw_we == |i_pmu_cnt_ovf);
    if (o_irq_raw_we) a_pmu_hw_wins: assert (o_irq_raw_wdata == (i_irq_raw | F'(i_pmu_cnt_ovf)));
    c_pmu_irq_rise_fall: cover (o_int_pmu);
    c_pmu_collision: cover (o_irq_raw_we && i_irq_raw != '0);
  end
endmodule

// a_pmu_snap_atomic : snapshot (REQ-PMU-003; 14.4.12 capture all live values on the edge
// that observes the stored request, keep until next request/reset, 32-bit profile hi = 0)
module fv_pmu_snapshot_props #(parameter int N = 16, parameter int W = 64, parameter int CW = 32) (
  input logic i_clk_cluster, input logic i_rst_n_cluster, input logic i_snapshot_req,
  input logic [N-1:0][W-1:0] i_pmu_cnt_val,
  input logic [N-1:0][CW-1:0] o_pmu_cnt_lo_value, input logic [N-1:0][CW-1:0] o_pmu_cnt_hi_value,
  input logic o_snapshot_req_clear, input logic o_snapshot_done_wdata, input logic o_snapshot_done_we
);
  logic past_valid = 1'b0;
  always @(posedge i_clk_cluster) past_valid <= 1'b1;
  always @(posedge i_clk_cluster) begin
    if (past_valid && $past(i_rst_n_cluster) && i_rst_n_cluster) begin
      for (int k = 0; k < N; k++) begin
        if ($past(i_snapshot_req)) begin
          a_pmu_snap_atomic: assert (o_pmu_cnt_lo_value[k] == CW'($past(i_pmu_cnt_val[k])) &&
                                     o_pmu_cnt_hi_value[k] == ((W > CW) ? CW'($past(i_pmu_cnt_val[k]) >> CW) : '0));
        end else begin
          a_pmu_snap_stable: assert (o_pmu_cnt_lo_value[k] == $past(o_pmu_cnt_lo_value[k]) &&
                                     o_pmu_cnt_hi_value[k] == $past(o_pmu_cnt_hi_value[k]));
        end
        if (W <= CW) a_pmu_snap_hi_zero: assert (o_pmu_cnt_hi_value[k] == '0);
      end
      // 14.4.12 does not fix whether clear/done are combinational or registered: accept the
      // observing cycle or the next one (interpretation recorded in the test header)
      if ($past(i_snapshot_req) && !($past(o_snapshot_req_clear) && $past(o_snapshot_done_we) && $past(o_snapshot_done_wdata)))
        a_pmu_snap_done: assert (o_snapshot_done_we && o_snapshot_done_wdata && o_snapshot_req_clear);
    end
    c_pmu_snap_twice: cover (past_valid && i_snapshot_req && $past(i_snapshot_req, 3));
  end
endmodule
