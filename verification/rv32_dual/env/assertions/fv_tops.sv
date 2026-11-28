// -----------------------------------------------------------------------------
// AI-GENERATED (Claude Opus 5.5, 2026-11-28) - candidate artifact (R-117, R-231).
// Formal wrapper tops (the open-source Yosys front end has no bind support):
// each instantiates one component by its REF-001 rev 0.39 Section 14.4 port
// contract and the matching property checker. All component inputs are
// top-level inputs, unconstrained except by the checkers' documented
// assumptions. FV_W selects the counter width (32 or 64). Parameter names
// PARA_PMU_CNT_NUM/PARA_PMU_CNT_W appear in the 14.4 port declarations; N=2
// keeps the proof small (legal range 1-32, REQ-PMU-001).
// -----------------------------------------------------------------------------
`ifndef FV_W
`define FV_W 64
`endif
module fv_top_pmu (
  input logic i_clk_cluster, input logic i_rst_n_cluster,
  input logic [1:0] i_pmu_cnt_en, input logic [1:0][2:0] i_evt_cnt,
  input logic [31:0] i_irq_raw, input logic [31:0] i_irq_en,
  input logic i_snapshot_req, input logic [1:0][`FV_W-1:0] i_snap_cnt_val
);
  localparam int N = 2, W = `FV_W;
  logic [N-1:0][W-1:0] cnt_val; logic [N-1:0] cnt_ovf;
  logic [31:0] raw_wdata, pending; logic raw_we, int_pmu;
  logic [N-1:0][31:0] lo, hi; logic req_clear, done_wdata, done_we;
  m_vlsit_pmu_counter_bank #(.PARA_PMU_CNT_NUM(N), .PARA_PMU_CNT_W(W)) u_bank (
    .i_clk_cluster(i_clk_cluster), .i_rst_n_cluster(i_rst_n_cluster), .i_pmu_cnt_en(i_pmu_cnt_en), .i_evt_cnt(i_evt_cnt),
    .o_pmu_cnt_val(cnt_val), .o_pmu_cnt_ovf(cnt_ovf));
  fv_pmu_counter_bank_props #(.N(N), .W(W), .EW(3)) u_bank_props (
    .i_clk_cluster(i_clk_cluster), .i_rst_n_cluster(i_rst_n_cluster), .i_pmu_cnt_en(i_pmu_cnt_en), .i_evt_cnt(i_evt_cnt),
    .o_pmu_cnt_val(cnt_val), .o_pmu_cnt_ovf(cnt_ovf));
  m_vlsit_pmu_irq #(.PARA_PMU_CNT_NUM(N)) u_irq (
    .i_irq_raw(i_irq_raw), .i_irq_en(i_irq_en), .i_pmu_cnt_ovf(cnt_ovf),
    .o_irq_raw_wdata(raw_wdata), .o_irq_raw_we(raw_we), .o_irq_pending(pending), .o_int_pmu(int_pmu));
  fv_pmu_irq_props #(.N(N), .F(32)) u_irq_props (
    .i_irq_raw(i_irq_raw), .i_irq_en(i_irq_en), .i_pmu_cnt_ovf(cnt_ovf),
    .o_irq_raw_wdata(raw_wdata), .o_irq_raw_we(raw_we), .o_irq_pending(pending), .o_int_pmu(int_pmu));
  m_vlsit_pmu_snapshot #(.PARA_PMU_CNT_NUM(N), .PARA_PMU_CNT_W(W)) u_snap (
    .i_clk_cluster(i_clk_cluster), .i_rst_n_cluster(i_rst_n_cluster), .i_snapshot_req(i_snapshot_req), .i_pmu_cnt_val(i_snap_cnt_val),
    .o_pmu_cnt_lo_value(lo), .o_pmu_cnt_hi_value(hi), .o_snapshot_req_clear(req_clear), .o_snapshot_done_wdata(done_wdata),
    .o_snapshot_done_we(done_we));
  fv_pmu_snapshot_props #(.N(N), .W(W), .CW(32)) u_snap_props (
    .i_clk_cluster(i_clk_cluster), .i_rst_n_cluster(i_rst_n_cluster), .i_snapshot_req(i_snapshot_req), .i_pmu_cnt_val(i_snap_cnt_val),
    .o_pmu_cnt_lo_value(lo), .o_pmu_cnt_hi_value(hi), .o_snapshot_req_clear(req_clear), .o_snapshot_done_wdata(done_wdata),
    .o_snapshot_done_we(done_we));
endmodule

module fv_top_axil (
  input logic i_clk_cluster, input logic i_rst_n_cluster,
  input logic [31:0] i_axil_awaddr, input logic [2:0] i_axil_awprot, input logic i_axil_awvalid,
  input logic [31:0] i_axil_wdata, input logic [3:0] i_axil_wstrb, input logic i_axil_wvalid, input logic i_axil_bready,
  input logic [31:0] i_axil_araddr, input logic [2:0] i_axil_arprot, input logic i_axil_arvalid, input logic i_axil_rready,
  input logic [1:0] i_t_awready, input logic [1:0] i_t_wready, input logic [1:0][1:0] i_t_bresp, input logic [1:0] i_t_bvalid,
  input logic [1:0] i_t_arready, input logic [1:0][31:0] i_t_rdata, input logic [1:0][1:0] i_t_rresp, input logic [1:0] i_t_rvalid,
  input logic i_b_awvalid, input logic i_b_wvalid, input logic i_b_bready, input logic [31:0] i_b_awaddr, input logic [31:0] i_b_wdata,
  input logic [3:0] i_b_wstrb, input logic i_b_arvalid, input logic [31:0] i_b_araddr, input logic i_b_rready,
  input logic i_reg_rsp_ready, input logic [31:0] i_reg_rsp_rdata, input logic i_reg_rsp_err
);
  logic awready, wready, bvalid, arready, rvalid; logic [1:0] bresp, rresp; logic [31:0] rdata;
  logic [1:0][31:0] t_awaddr, t_wdata, t_araddr; logic [1:0][2:0] t_awprot, t_arprot; logic [1:0][3:0] t_wstrb;
  logic [1:0] t_awvalid, t_wvalid, t_bready, t_arvalid, t_rready;
  m_vlsit_riscv_axil_decode u_dec (
    .i_clk_cluster(i_clk_cluster), .i_rst_n_cluster(i_rst_n_cluster),
    .i_axil_awaddr(i_axil_awaddr), .i_axil_awprot(i_axil_awprot), .i_axil_awvalid(i_axil_awvalid), .o_axil_awready(awready),
    .i_axil_wdata(i_axil_wdata), .i_axil_wstrb(i_axil_wstrb), .i_axil_wvalid(i_axil_wvalid), .o_axil_wready(wready),
    .o_axil_bresp(bresp), .o_axil_bvalid(bvalid), .i_axil_bready(i_axil_bready),
    .i_axil_araddr(i_axil_araddr), .i_axil_arprot(i_axil_arprot), .i_axil_arvalid(i_axil_arvalid), .o_axil_arready(arready),
    .o_axil_rdata(rdata), .o_axil_rresp(rresp), .o_axil_rvalid(rvalid), .i_axil_rready(i_axil_rready),
    .o_axil_target_awaddr(t_awaddr), .o_axil_target_awprot(t_awprot), .o_axil_target_awvalid(t_awvalid), .i_axil_target_awready(i_t_awready),
    .o_axil_target_wdata(t_wdata), .o_axil_target_wstrb(t_wstrb), .o_axil_target_wvalid(t_wvalid), .i_axil_target_wready(i_t_wready),
    .i_axil_target_bresp(i_t_bresp), .i_axil_target_bvalid(i_t_bvalid), .o_axil_target_bready(t_bready),
    .o_axil_target_araddr(t_araddr), .o_axil_target_arprot(t_arprot), .o_axil_target_arvalid(t_arvalid), .i_axil_target_arready(i_t_arready),
    .i_axil_target_rdata(i_t_rdata), .i_axil_target_rresp(i_t_rresp), .i_axil_target_rvalid(i_t_rvalid), .o_axil_target_rready(t_rready));
  fv_axil_decode_props u_dec_props (
    .i_clk_cluster(i_clk_cluster), .i_rst_n_cluster(i_rst_n_cluster),
    .i_axil_awaddr(i_axil_awaddr), .i_axil_awvalid(i_axil_awvalid), .o_axil_awready(awready),
    .i_axil_wvalid(i_axil_wvalid), .o_axil_wready(wready), .o_axil_bresp(bresp), .o_axil_bvalid(bvalid), .i_axil_bready(i_axil_bready),
    .i_axil_araddr(i_axil_araddr), .i_axil_arvalid(i_axil_arvalid), .o_axil_arready(arready),
    .o_axil_rdata(rdata), .o_axil_rresp(rresp), .o_axil_rvalid(rvalid), .i_axil_rready(i_axil_rready),
    .o_axil_target_awaddr(t_awaddr), .o_axil_target_awvalid(t_awvalid), .o_axil_target_araddr(t_araddr), .o_axil_target_arvalid(t_arvalid));
  // the bridge is checked standalone with its own unconstrained AXI4-Lite inputs
  logic b_awready, b_wready, b_bvalid, b_arready, b_rvalid, r_valid, r_wr; logic [1:0] b_bresp, b_rresp; logic [31:0] b_rdata, r_wdata;
  logic [6:0] r_addr; logic [3:0] r_wstrb;
  m_vlsit_axil_reg_bridge u_br (
    .i_clk_cluster(i_clk_cluster), .i_rst_n_cluster(i_rst_n_cluster),
    .i_axil_awaddr(i_b_awaddr), .i_axil_awprot(3'd0), .i_axil_awvalid(i_b_awvalid), .o_axil_awready(b_awready),
    .i_axil_wdata(i_b_wdata), .i_axil_wstrb(i_b_wstrb), .i_axil_wvalid(i_b_wvalid), .o_axil_wready(b_wready),
    .o_axil_bresp(b_bresp), .o_axil_bvalid(b_bvalid), .i_axil_bready(i_b_bready),
    .i_axil_araddr(i_b_araddr), .i_axil_arprot(3'd0), .i_axil_arvalid(i_b_arvalid), .o_axil_arready(b_arready),
    .o_axil_rdata(b_rdata), .o_axil_rresp(b_rresp), .o_axil_rvalid(b_rvalid), .i_axil_rready(i_b_rready),
    .o_reg_req_valid(r_valid), .o_reg_req_wr(r_wr), .o_reg_req_addr(r_addr), .o_reg_req_wdata(r_wdata), .o_reg_req_wstrb(r_wstrb),
    .i_reg_rsp_ready(i_reg_rsp_ready), .i_reg_rsp_rdata(i_reg_rsp_rdata), .i_reg_rsp_err(i_reg_rsp_err));
  fv_axil_bridge_props u_br_props (
    .i_clk_cluster(i_clk_cluster), .i_rst_n_cluster(i_rst_n_cluster),
    .i_axil_awvalid(i_b_awvalid), .o_axil_awready(b_awready), .i_axil_wvalid(i_b_wvalid), .o_axil_wready(b_wready),
    .o_axil_bresp(b_bresp), .o_axil_bvalid(b_bvalid), .i_axil_bready(i_b_bready),
    .o_reg_req_valid(r_valid), .o_reg_req_wr(r_wr), .o_reg_req_addr(r_addr), .o_reg_req_wdata(r_wdata), .o_reg_req_wstrb(r_wstrb),
    .i_reg_rsp_ready(i_reg_rsp_ready), .i_reg_rsp_err(i_reg_rsp_err));
endmodule

module fv_top_addr_decode (input logic [63:0] i_phys_addr, input logic [11:0] i_access_bytes, input logic i_atomic);
  logic cfg_ok, match, err; logic [3:0] idx; logic [1:0] typ;
  // Campaign table of REF-001 rev 0.40 14.4.20 (same values as tb/generated/region_params.svh).
  // ASSUMPTION: the decoder takes the TOP region parameters under the same names (14.4.13 lists ports only);
  // a different parameter set makes elaboration fail, it cannot silently weaken the proof.
  m_vlsit_riscv_addr_decode #(
    .PARA_ADDR_REGION_NUM     (32'd5),
    .PARA_ADDR_REGION_BASE_LO ('{0:32'h8000_0000, 1:32'h1000_0000, 2:32'h0000_0000, 3:32'h4000_0000, 4:32'hC000_0000, default:32'd0}),
    .PARA_ADDR_REGION_BASE_HI ('{4:32'h0000_0003, default:32'd0}),
    .PARA_ADDR_REGION_SIZE_LO ('{0:32'h4000_0000, 1:32'h1000_0000, 2:32'h0000_1000, 3:32'h1000_0000, 4:32'h4000_0000, default:32'd0}),
    .PARA_ADDR_REGION_SIZE_HI ('{default:32'd0}),
    .PARA_ADDR_REGION_TYPE    ('{0:32'd0, 1:32'd2, 2:32'd2, 3:32'd1, 4:32'd1, default:32'd0})
  ) u_dec (.i_phys_addr(i_phys_addr), .i_access_bytes(i_access_bytes), .i_atomic(i_atomic),
    .o_config_valid(cfg_ok), .o_region_match(match), .o_region_idx(idx), .o_region_type(typ), .o_access_err(err));
  fv_addr_decode_props u_props (.i_phys_addr(i_phys_addr), .i_access_bytes(i_access_bytes), .i_atomic(i_atomic),
    .o_config_valid(cfg_ok), .o_region_match(match), .o_region_idx(idx), .o_region_type(typ), .o_access_err(err));
endmodule
