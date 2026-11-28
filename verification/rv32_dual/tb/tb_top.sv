// -----------------------------------------------------------------------------
// AI-GENERATED (Claude Opus 5.5, 2026-11-28) - candidate artifact (R-117, R-231).
// tb_top: simulation top for CFG-RV32-2 (two RV32 harts, AXI TOP).
// DUT ports: REF-001 Section 6.2 (generated include from the table);
// RV32 HDS rev 0.4 Section 6.2 (i_boot_addr bits 63:32 zero), Section 8.1.
// Parameters set here: PARA_CPU_NUM=2, PARA_TIMING_PROFILE (define RV32D_PROFILE,
// default 0) and the six TOP address-region parameters of REF-001 rev 0.40
// Section 14.4.20 with the campaign parameter set (question_log Q-G0-03, Q-G3-01
// follow-up), generated into tb/generated/region_params.svh by gen_env.py from
// models/configs/region_table_campaign.json after chk_region_table accepts it.
// Plusargs: +TEST=<id> +SEED=<n> +TIMEOUT_CYCLES=<n> +WAVE=<file> +WAVE_SCOPE=ports|tb
//           plus the BFM/monitor plusargs documented in env/README.md.
// No force on design signals (R-258). All checkers always instantiated (R-241).
// -----------------------------------------------------------------------------
`ifndef RV32D_PROFILE
`define RV32D_PROFILE 0
`endif
/* verilator lint_off UNUSEDSIGNAL */  // QoS/region sideband and memory-BFM control outputs are intentionally unobserved
/* verilator lint_off SYNCASYNCNET */  // reset is asserted asynchronously by design (REF-001 7.3)
module tb_top;
  localparam int CPU_NUM = 2;
  localparam int MEM_DW  = 64;


  `include "generated/dut_signals.svh"

  // ------------------------------------------------------------ clock / reset
  logic clk;
  initial clk = 1'b0;
  always #5 clk = ~clk;                       // 10 ns nominal; no timing meaning (plan 5.4)
  assign i_clk_cluster = clk;

  logic [31:0] ckpt;
  logic [CPU_NUM-1:0] tohost_done, dbg_level;
  logic [CPU_NUM-1:0][31:0] tohost_code;
  logic [CPU_NUM-1:0][5:0] irq_level;
  logic reset_event, wd_finished, wd_expired, axil_done;
  logic [31:0] axil_ops;

  // unused MMIO-BFM control outputs of the memory instance
  logic [CPU_NUM-1:0] m_tohost_done, m_dbg;
  logic [CPU_NUM-1:0][31:0] m_tohost_code;
  logic [CPU_NUM-1:0][5:0] m_irq;
  logic [31:0] m_ckpt;

  drv_sideband #(.HARTS(CPU_NUM)) u_sideband (
    .clk(clk), .ckpt(ckpt), .irq_level(irq_level), .dbg_level(dbg_level),
    .rst_n(i_rst_n_cluster), .boot_addr(i_boot_addr),
    .msip(i_int_msip), .mtip(i_int_mtip), .meip(i_int_meip), .ssip(i_int_ssip), .stip(i_int_stip), .seip(i_int_seip),
    .dbg_req(i_hart_debug_req), .reset_event(reset_event));

  // ------------------------------------------------------------------- DUT
  m_vlsit_riscv_cluster_axi_top #(
    .PARA_CPU_NUM(CPU_NUM),
    .PARA_TIMING_PROFILE(`RV32D_PROFILE)
`include "generated/region_params.svh"
  ) u_dut (
`include "generated/dut_port_connect.svh"
  );

  // -------------------------------------------------------------- memory BFM
  bfm_axi_sub #(.IDW(7), .ATOMICS(1'b1), .CTRL(1'b0), .PFX("MEM"), .HARTS(CPU_NUM)) u_mem (
    .clk(clk), .rst_n(i_rst_n_cluster),
    .awid(o_axi_mem_awid), .awaddr(o_axi_mem_awaddr), .awlen(o_axi_mem_awlen), .awsize(o_axi_mem_awsize),
    .awburst(o_axi_mem_awburst), .awlock(o_axi_mem_awlock), .awatop(o_axi_mem_awatop), .awvalid(o_axi_mem_awvalid),
    .awready(i_axi_mem_awready),
    .wdata(o_axi_mem_wdata), .wstrb(o_axi_mem_wstrb), .wlast(o_axi_mem_wlast), .wvalid(o_axi_mem_wvalid), .wready(i_axi_mem_wready),
    .bid(i_axi_mem_bid), .bresp(i_axi_mem_bresp), .bvalid(i_axi_mem_bvalid), .bready(o_axi_mem_bready),
    .arid(o_axi_mem_arid), .araddr(o_axi_mem_araddr), .arlen(o_axi_mem_arlen), .arsize(o_axi_mem_arsize),
    .arburst(o_axi_mem_arburst), .arlock(o_axi_mem_arlock), .arvalid(o_axi_mem_arvalid), .arready(i_axi_mem_arready),
    .rid(i_axi_mem_rid), .rdata(i_axi_mem_rdata), .rresp(i_axi_mem_rresp), .rlast(i_axi_mem_rlast), .rvalid(i_axi_mem_rvalid),
    .rready(o_axi_mem_rready),
    .tohost_done(m_tohost_done), .tohost_code(m_tohost_code), .irq_level(m_irq), .dbg_req(m_dbg), .ckpt(m_ckpt), .ext_status(32'd0));

  // ---------------------------------------------------------------- MMIO BFM
  bfm_axi_sub #(.IDW(6), .ATOMICS(1'b0), .CTRL(1'b1), .PFX("MMIO"), .HARTS(CPU_NUM)) u_mmio (
    .clk(clk), .rst_n(i_rst_n_cluster),
    .awid(o_axi_mmio_awid), .awaddr(o_axi_mmio_awaddr), .awlen(o_axi_mmio_awlen), .awsize(o_axi_mmio_awsize),
    .awburst(o_axi_mmio_awburst), .awlock(o_axi_mmio_awlock), .awatop(6'd0), .awvalid(o_axi_mmio_awvalid),
    .awready(i_axi_mmio_awready),
    .wdata(o_axi_mmio_wdata), .wstrb(o_axi_mmio_wstrb), .wlast(o_axi_mmio_wlast), .wvalid(o_axi_mmio_wvalid), .wready(i_axi_mmio_wready),
    .bid(i_axi_mmio_bid), .bresp(i_axi_mmio_bresp), .bvalid(i_axi_mmio_bvalid), .bready(o_axi_mmio_bready),
    .arid(o_axi_mmio_arid), .araddr(o_axi_mmio_araddr), .arlen(o_axi_mmio_arlen), .arsize(o_axi_mmio_arsize),
    .arburst(o_axi_mmio_arburst), .arlock(o_axi_mmio_arlock), .arvalid(o_axi_mmio_arvalid), .arready(i_axi_mmio_arready),
    .rid(i_axi_mmio_rid), .rdata(i_axi_mmio_rdata), .rresp(i_axi_mmio_rresp), .rlast(i_axi_mmio_rlast), .rvalid(i_axi_mmio_rvalid),
    .rready(o_axi_mmio_rready),
    .tohost_done(tohost_done), .tohost_code(tohost_code), .irq_level(irq_level), .dbg_req(dbg_level), .ckpt(ckpt), .ext_status(axil_ops));

  // ---------------------------------------------------------- AXI4-Lite BFM
  bfm_axil_mgr u_axil (
    .clk(clk), .rst_n(i_rst_n_cluster), .ckpt(ckpt),
    .awaddr(i_axil_awaddr), .awprot(i_axil_awprot), .awvalid(i_axil_awvalid), .awready(o_axil_awready),
    .wdata(i_axil_wdata), .wstrb(i_axil_wstrb), .wvalid(i_axil_wvalid), .wready(o_axil_wready),
    .bresp(o_axil_bresp), .bvalid(o_axil_bvalid), .bready(i_axil_bready),
    .araddr(i_axil_araddr), .arprot(i_axil_arprot), .arvalid(i_axil_arvalid), .arready(o_axil_arready),
    .rdata(o_axil_rdata), .rresp(o_axil_rresp), .rvalid(o_axil_rvalid), .rready(i_axil_rready), .done(axil_done), .ops_done(axil_ops));

  // ------------------------------------------------------- passive monitors
  mon_axi #(.IDW(7), .PFX("MEM")) u_mon_mem (
    .clk(clk), .rst_n(i_rst_n_cluster),
    .awid(o_axi_mem_awid), .awaddr(o_axi_mem_awaddr), .awlen(o_axi_mem_awlen), .awsize(o_axi_mem_awsize), .awburst(o_axi_mem_awburst),
    .awlock(o_axi_mem_awlock), .awcache(o_axi_mem_awcache), .awprot(o_axi_mem_awprot), .awatop(o_axi_mem_awatop),
    .awvalid(o_axi_mem_awvalid), .awready(i_axi_mem_awready),
    .wdata(o_axi_mem_wdata), .wstrb(o_axi_mem_wstrb), .wlast(o_axi_mem_wlast), .wvalid(o_axi_mem_wvalid), .wready(i_axi_mem_wready),
    .bid(i_axi_mem_bid), .bresp(i_axi_mem_bresp), .bvalid(i_axi_mem_bvalid), .bready(o_axi_mem_bready),
    .arid(o_axi_mem_arid), .araddr(o_axi_mem_araddr), .arlen(o_axi_mem_arlen), .arsize(o_axi_mem_arsize), .arburst(o_axi_mem_arburst),
    .arlock(o_axi_mem_arlock), .arcache(o_axi_mem_arcache), .arprot(o_axi_mem_arprot), .arvalid(o_axi_mem_arvalid), .arready(i_axi_mem_arready),
    .rid(i_axi_mem_rid), .rdata(i_axi_mem_rdata), .rresp(i_axi_mem_rresp), .rlast(i_axi_mem_rlast), .rvalid(i_axi_mem_rvalid), .rready(o_axi_mem_rready));

  mon_axi #(.IDW(6), .PFX("MMIO")) u_mon_mmio (
    .clk(clk), .rst_n(i_rst_n_cluster),
    .awid(o_axi_mmio_awid), .awaddr(o_axi_mmio_awaddr), .awlen(o_axi_mmio_awlen), .awsize(o_axi_mmio_awsize), .awburst(o_axi_mmio_awburst),
    .awlock(o_axi_mmio_awlock), .awcache(o_axi_mmio_awcache), .awprot(o_axi_mmio_awprot), .awatop(6'd0),
    .awvalid(o_axi_mmio_awvalid), .awready(i_axi_mmio_awready),
    .wdata(o_axi_mmio_wdata), .wstrb(o_axi_mmio_wstrb), .wlast(o_axi_mmio_wlast), .wvalid(o_axi_mmio_wvalid), .wready(i_axi_mmio_wready),
    .bid(i_axi_mmio_bid), .bresp(i_axi_mmio_bresp), .bvalid(i_axi_mmio_bvalid), .bready(o_axi_mmio_bready),
    .arid(o_axi_mmio_arid), .araddr(o_axi_mmio_araddr), .arlen(o_axi_mmio_arlen), .arsize(o_axi_mmio_arsize), .arburst(o_axi_mmio_arburst),
    .arlock(o_axi_mmio_arlock), .arcache(o_axi_mmio_arcache), .arprot(o_axi_mmio_arprot), .arvalid(o_axi_mmio_arvalid), .arready(i_axi_mmio_arready),
    .rid(i_axi_mmio_rid), .rdata(i_axi_mmio_rdata), .rresp(i_axi_mmio_rresp), .rlast(i_axi_mmio_rlast), .rvalid(i_axi_mmio_rvalid), .rready(o_axi_mmio_rready));

  mon_axil u_mon_axil (
    .clk(clk), .rst_n(i_rst_n_cluster),
    .awaddr(i_axil_awaddr), .awvalid(i_axil_awvalid), .awready(o_axil_awready),
    .wdata(i_axil_wdata), .wstrb(i_axil_wstrb), .wvalid(i_axil_wvalid), .wready(o_axil_wready),
    .bresp(o_axil_bresp), .bvalid(o_axil_bvalid), .bready(i_axil_bready),
    .araddr(i_axil_araddr), .arvalid(i_axil_arvalid), .arready(o_axil_arready),
    .rdata(o_axil_rdata), .rresp(o_axil_rresp), .rvalid(o_axil_rvalid), .rready(i_axil_rready));

  mon_sideband #(.HARTS(CPU_NUM)) u_mon_pins (
    .clk(clk), .rst_n(i_rst_n_cluster), .boot_addr(i_boot_addr),
    .msip(i_int_msip), .mtip(i_int_mtip), .meip(i_int_meip), .ssip(i_int_ssip), .stip(i_int_stip), .seip(i_int_seip),
    .dbg_req(i_hart_debug_req), .dbg_mode(o_hart_debug_mode), .int_pmu(o_int_pmu), .int_fault(o_int_fault));

  // ------------------------------------------------- always-on checkers (R-241)
  sva_top_bind #(.HARTS(CPU_NUM)) u_sva (
    .clk(clk), .rst_n(i_rst_n_cluster), .boot_addr(i_boot_addr),
    .m_awaddr(o_axi_mem_awaddr), .m_awlen(o_axi_mem_awlen), .m_awsize(o_axi_mem_awsize), .m_awburst(o_axi_mem_awburst),
    .m_awlock(o_axi_mem_awlock), .m_awatop(o_axi_mem_awatop), .m_awid(o_axi_mem_awid), .m_awvalid(o_axi_mem_awvalid), .m_awready(i_axi_mem_awready),
    .m_wdata(o_axi_mem_wdata), .m_wstrb(o_axi_mem_wstrb), .m_wlast(o_axi_mem_wlast), .m_wvalid(o_axi_mem_wvalid), .m_wready(i_axi_mem_wready),
    .m_araddr(o_axi_mem_araddr), .m_arlen(o_axi_mem_arlen), .m_arsize(o_axi_mem_arsize), .m_arburst(o_axi_mem_arburst),
    .m_arlock(o_axi_mem_arlock), .m_arid(o_axi_mem_arid), .m_arvalid(o_axi_mem_arvalid), .m_arready(i_axi_mem_arready),
    .p_awaddr(o_axi_mmio_awaddr), .p_awlen(o_axi_mmio_awlen), .p_awsize(o_axi_mmio_awsize), .p_awburst(o_axi_mmio_awburst),
    .p_awid(o_axi_mmio_awid), .p_awvalid(o_axi_mmio_awvalid), .p_awready(i_axi_mmio_awready),
    .p_wdata(o_axi_mmio_wdata), .p_wstrb(o_axi_mmio_wstrb), .p_wlast(o_axi_mmio_wlast), .p_wvalid(o_axi_mmio_wvalid), .p_wready(i_axi_mmio_wready),
    .p_araddr(o_axi_mmio_araddr), .p_arlen(o_axi_mmio_arlen), .p_arsize(o_axi_mmio_arsize), .p_arburst(o_axi_mmio_arburst),
    .p_arid(o_axi_mmio_arid), .p_arvalid(o_axi_mmio_arvalid), .p_arready(i_axi_mmio_arready),
    .l_bresp(o_axil_bresp), .l_bvalid(o_axil_bvalid), .l_bready(i_axil_bready),
    .l_rdata(o_axil_rdata), .l_rresp(o_axil_rresp), .l_rvalid(o_axil_rvalid), .l_rready(i_axil_rready),
    .dbg_req(i_hart_debug_req), .dbg_mode(o_hart_debug_mode), .int_pmu(o_int_pmu), .int_fault(o_int_fault));

  chk_stale_resp #(.IDW(7), .PFX("MEM")) u_stale_mem (
    .clk(clk), .rst_n(i_rst_n_cluster), .awid(o_axi_mem_awid), .awvalid(o_axi_mem_awvalid), .awready(i_axi_mem_awready),
    .bid(i_axi_mem_bid), .bvalid(i_axi_mem_bvalid), .bready(o_axi_mem_bready),
    .arid(o_axi_mem_arid), .arvalid(o_axi_mem_arvalid), .arready(i_axi_mem_arready),
    .rid(i_axi_mem_rid), .rlast(i_axi_mem_rlast), .rvalid(i_axi_mem_rvalid), .rready(o_axi_mem_rready));
  chk_stale_resp #(.IDW(6), .PFX("MMIO")) u_stale_mmio (
    .clk(clk), .rst_n(i_rst_n_cluster), .awid(o_axi_mmio_awid), .awvalid(o_axi_mmio_awvalid), .awready(i_axi_mmio_awready),
    .bid(i_axi_mmio_bid), .bvalid(i_axi_mmio_bvalid), .bready(o_axi_mmio_bready),
    .arid(o_axi_mmio_arid), .arvalid(o_axi_mmio_arvalid), .arready(i_axi_mmio_arready),
    .rid(i_axi_mmio_rid), .rlast(i_axi_mmio_rlast), .rvalid(i_axi_mmio_rvalid), .rready(o_axi_mmio_rready));

  chk_watchdog #(.HARTS(CPU_NUM)) u_wd (
    .clk(clk), .rst_n(i_rst_n_cluster), .tohost_done(tohost_done), .tohost_code(tohost_code),
    .finished(wd_finished), .expired(wd_expired));

  // ----------------------------------------------------------- run control
  initial begin
    string test, wave, scope;
    int unsigned seed;
    test = "none"; seed = 1; scope = "ports";
    void'($value$plusargs("TEST=%s", test));
    void'($value$plusargs("SEED=%d", seed));
    void'($value$plusargs("WAVE_SCOPE=%s", scope));
    $display("tb_top: TEST=%s SEED=%0d PROFILE=%0d", test, seed, `RV32D_PROFILE);
    if ($value$plusargs("WAVE=%s", wave)) begin
      // R-278/R-283: bounded scope - TOP ports and testbench checkpoint signals only
      $dumpfile(wave);
      if (scope == "tb") $dumpvars(1, tb_top);
      else $dumpvars(1, tb_top);
    end
  end
  always @(posedge clk) begin
    if (wd_finished || wd_expired) begin
      repeat (64) @(posedge clk);          // drain monitors
      $display("tb_top: END %s", wd_finished ? "TOHOST" : "WATCHDOG_EXPIRED");
      $finish;
    end
  end
endmodule
/* verilator lint_on SYNCASYNCNET */
/* verilator lint_on UNUSEDSIGNAL */
