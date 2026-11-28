// -----------------------------------------------------------------------------
// AI-GENERATED (Claude Opus 5.5, 2026-11-28) - candidate artifact (R-117, R-231).
// Formal property checkers for t_rv32d_fv_axil. Port contracts: REF-001 rev 0.39
// Section 14.4.18 (m_vlsit_riscv_axil_decode) and 14.4.4 (m_vlsit_axil_reg_bridge).
// Semantics: REQ-IF-001/007/008/010, Address_Map sheet (CSR 0x0000-0x4FFF -> target 0
// with full relative offset; LLC 0x5000-0x5FFF -> target 1 with the LLC base
// subtracted; outside the 24-KiB aperture rejected locally), IHI 0022H B1.
// Environment assumptions (each listed in the .sby and reviewed): AXI4-Lite
// compliant manager; at most one outstanding read and one outstanding write
// (bounds the tracking logic); PARA_AXIL_BASE_ADDR = 0. No RTL read.
// -----------------------------------------------------------------------------
module fv_axil_decode_props (
  input logic i_clk_cluster, input logic i_rst_n_cluster,
  input logic [31:0] i_axil_awaddr, input logic i_axil_awvalid, input logic o_axil_awready,
  input logic i_axil_wvalid, input logic o_axil_wready,
  input logic [1:0] o_axil_bresp, input logic o_axil_bvalid, input logic i_axil_bready,
  input logic [31:0] i_axil_araddr, input logic i_axil_arvalid, input logic o_axil_arready,
  input logic [31:0] o_axil_rdata, input logic [1:0] o_axil_rresp, input logic o_axil_rvalid, input logic i_axil_rready,
  input logic [1:0][31:0] o_axil_target_awaddr, input logic [1:0] o_axil_target_awvalid,
  input logic [1:0][31:0] o_axil_target_araddr, input logic [1:0] o_axil_target_arvalid
);
  logic past_valid = 1'b0;
  logic rd_out_pending, rd_out, wr_pending, rd_pending;
  initial begin rd_out_pending = 1'b0; wr_pending = 1'b0; rd_pending = 1'b0; end
  always @(posedge i_clk_cluster) past_valid <= 1'b1;
  // ---- environment assumptions (manager side) ----
  always @(posedge i_clk_cluster) begin
    if (!i_rst_n_cluster) begin
      rd_out_pending <= 1'b0; wr_pending <= 1'b0; rd_pending <= 1'b0;
    end else begin
      if (past_valid && $past(i_axil_arvalid && !o_axil_arready)) assume (i_axil_arvalid && i_axil_araddr == $past(i_axil_araddr));
      if (past_valid && $past(i_axil_awvalid && !o_axil_awready)) assume (i_axil_awvalid && i_axil_awaddr == $past(i_axil_awaddr));
      if (rd_pending) assume (!i_axil_arvalid);
      if (wr_pending) assume (!i_axil_awvalid);
      if (i_axil_arvalid && o_axil_arready) begin rd_pending <= 1'b1; rd_out_pending <= (i_axil_araddr >= 32'h6000); end
      if (o_axil_rvalid && i_axil_rready) rd_pending <= 1'b0;
      if (i_axil_awvalid && o_axil_awready) wr_pending <= 1'b1;
      if (o_axil_bvalid && i_axil_bready) wr_pending <= 1'b0;
    end
  end
  // ---- properties ----
  always @(posedge i_clk_cluster) begin
    if (past_valid && i_rst_n_cluster && $past(i_rst_n_cluster)) begin
      // a_axil_decode_onehot: each request goes to at most one target, inside that target's window
      a_axil_decode_onehot: assert (!(o_axil_target_awvalid[0] && o_axil_target_awvalid[1]) && !(o_axil_target_arvalid[0] && o_axil_target_arvalid[1]));
      if (o_axil_target_awvalid[0]) a_axil_csr_window_w: assert (o_axil_target_awaddr[0] < 32'h5000);
      if (o_axil_target_arvalid[0]) a_axil_csr_window_r: assert (o_axil_target_araddr[0] < 32'h5000);
      if (o_axil_target_awvalid[1]) a_axil_llc_window_w: assert (o_axil_target_awaddr[1] < 32'h1000);
      if (o_axil_target_arvalid[1]) a_axil_llc_window_r: assert (o_axil_target_araddr[1] < 32'h1000);
      // a_axil_decerr: a read outside the aperture never reaches a target and returns DECERR with zero data
      if (rd_out_pending) a_axil_out_no_target: assert (o_axil_target_arvalid == 2'b00);
      if (rd_out_pending && o_axil_rvalid) a_axil_decerr: assert (o_axil_rresp == 2'b11 && o_axil_rdata == 32'h0);
      // a_axil_stable: B and R hold while stalled (B1)
      if ($past(o_axil_bvalid && !i_axil_bready)) a_axil_stable_b: assert (o_axil_bvalid && o_axil_bresp == $past(o_axil_bresp));
      if ($past(o_axil_rvalid && !i_axil_rready)) a_axil_stable_r: assert (o_axil_rvalid && o_axil_rresp == $past(o_axil_rresp) && o_axil_rdata == $past(o_axil_rdata));
    end
    c_axil_each_window: cover (o_axil_target_arvalid[0] || o_axil_target_arvalid[1]);
    c_axil_reserved: cover (rd_out_pending && o_axil_rvalid);
    c_axil_stall: cover (o_axil_rvalid && !i_axil_rready);
  end
endmodule

module fv_axil_bridge_props (
  input logic i_clk_cluster, input logic i_rst_n_cluster,
  input logic i_axil_awvalid, input logic o_axil_awready, input logic i_axil_wvalid, input logic o_axil_wready,
  input logic [1:0] o_axil_bresp, input logic o_axil_bvalid, input logic i_axil_bready,
  input logic o_reg_req_valid, input logic o_reg_req_wr, input logic [6:0] o_reg_req_addr, input logic [31:0] o_reg_req_wdata,
  input logic [3:0] o_reg_req_wstrb, input logic i_reg_rsp_ready, input logic i_reg_rsp_err
);
  logic past_valid = 1'b0;
  logic aw_got, w_got, wr_open;
  logic [1:0] reg_writes;
  logic last_err;
  initial begin aw_got = 1'b0; w_got = 1'b0; wr_open = 1'b0; reg_writes = '0; last_err = 1'b0; end
  always @(posedge i_clk_cluster) past_valid <= 1'b1;
  always @(posedge i_clk_cluster) begin
    if (!i_rst_n_cluster) begin
      aw_got <= 1'b0; w_got <= 1'b0; wr_open <= 1'b0; reg_writes <= '0;
    end else begin
      if (wr_open) assume (!i_axil_awvalid && !i_axil_wvalid);       // one outstanding write
      if (i_axil_awvalid && o_axil_awready) aw_got <= 1'b1;
      if (i_axil_wvalid && o_axil_wready) w_got <= 1'b1;
      if ((aw_got || (i_axil_awvalid && o_axil_awready)) && (w_got || (i_axil_wvalid && o_axil_wready))) wr_open <= 1'b1;
      if (o_reg_req_valid && o_reg_req_wr && i_reg_rsp_ready) begin reg_writes <= reg_writes + 2'd1; last_err <= i_reg_rsp_err; end
      if (o_axil_bvalid && i_axil_bready) begin aw_got <= 1'b0; w_got <= 1'b0; wr_open <= 1'b0; reg_writes <= '0; end
    end
  end
  always @(posedge i_clk_cluster) begin
    if (past_valid && i_rst_n_cluster && $past(i_rst_n_cluster)) begin
      // a_bridge_one_write: no RegBus write before both AW and W are captured; at most one per AXI write
      if (o_reg_req_valid && o_reg_req_wr) a_bridge_after_aw_w: assert (aw_got && w_got);
      a_bridge_one_write: assert (reg_writes <= 2'd1);
      if (o_axil_bvalid) a_bridge_b_after_pair: assert (aw_got && w_got);
      // RegBus request held until ready
      if ($past(o_reg_req_valid && !i_reg_rsp_ready)) a_bridge_req_stable: assert (o_reg_req_valid && o_reg_req_wr == $past(o_reg_req_wr) &&
                                                                                      o_reg_req_addr == $past(o_reg_req_addr) && o_reg_req_wdata == $past(o_reg_req_wdata) &&
                                                                                      o_reg_req_wstrb == $past(o_reg_req_wstrb));
      // a_bridge_resp_match: the B response follows the RegBus result of that write
      if (o_axil_bvalid && reg_writes == 2'd1) a_bridge_resp_match: assert ((o_axil_bresp == 2'b00) == !last_err);
    end
    c_bridge_w_first: cover (w_got && !aw_got);
    c_bridge_aw_first: cover (aw_got && !w_got);
    c_bridge_err: cover (o_axil_bvalid && reg_writes == 2'd1 && last_err);
  end
endmodule
