`timescale 1ns/1ps
module tb_fence_i_end_to_end #(parameter int HARTS=2, TRACE=1, TIMING_PROFILE=0);
  logic  i_clk_cluster;
  logic  i_rst_n_cluster;
  logic [63:0] i_boot_addr;
  logic [3:0] i_int_msip;
  logic [3:0] i_int_mtip;
  logic [3:0] i_int_meip;
  logic [3:0] i_int_ssip;
  logic [3:0] i_int_stip;
  logic [3:0] i_int_seip;
  logic [3:0] i_hart_debug_req;
  logic [3:0] o_hart_debug_mode;
  logic  o_int_pmu;
  logic  o_int_fault;
  logic [31:0] i_axil_awaddr;
  logic [2:0] i_axil_awprot;
  logic  i_axil_awvalid;
  logic  o_axil_awready;
  logic [31:0] i_axil_wdata;
  logic [3:0] i_axil_wstrb;
  logic  i_axil_wvalid;
  logic  o_axil_wready;
  logic [1:0] o_axil_bresp;
  logic  o_axil_bvalid;
  logic  i_axil_bready;
  logic [31:0] i_axil_araddr;
  logic [2:0] i_axil_arprot;
  logic  i_axil_arvalid;
  logic  o_axil_arready;
  logic [31:0] o_axil_rdata;
  logic [1:0] o_axil_rresp;
  logic  o_axil_rvalid;
  logic  i_axil_rready;
  logic [5:0] o_axi_mmio_awid;
  logic [63:0] o_axi_mmio_awaddr;
  logic [7:0] o_axi_mmio_awlen;
  logic [2:0] o_axi_mmio_awsize;
  logic [1:0] o_axi_mmio_awburst;
  logic  o_axi_mmio_awlock;
  logic [3:0] o_axi_mmio_awcache;
  logic [2:0] o_axi_mmio_awprot;
  logic [3:0] o_axi_mmio_awqos;
  logic [3:0] o_axi_mmio_awregion;
  logic  o_axi_mmio_awvalid;
  logic  i_axi_mmio_awready;
  logic [63:0] o_axi_mmio_wdata;
  logic [7:0] o_axi_mmio_wstrb;
  logic  o_axi_mmio_wlast;
  logic  o_axi_mmio_wvalid;
  logic  i_axi_mmio_wready;
  logic [5:0] i_axi_mmio_bid;
  logic [1:0] i_axi_mmio_bresp;
  logic  i_axi_mmio_bvalid;
  logic  o_axi_mmio_bready;
  logic [5:0] o_axi_mmio_arid;
  logic [63:0] o_axi_mmio_araddr;
  logic [7:0] o_axi_mmio_arlen;
  logic [2:0] o_axi_mmio_arsize;
  logic [1:0] o_axi_mmio_arburst;
  logic  o_axi_mmio_arlock;
  logic [3:0] o_axi_mmio_arcache;
  logic [2:0] o_axi_mmio_arprot;
  logic [3:0] o_axi_mmio_arqos;
  logic [3:0] o_axi_mmio_arregion;
  logic  o_axi_mmio_arvalid;
  logic  i_axi_mmio_arready;
  logic [5:0] i_axi_mmio_rid;
  logic [63:0] i_axi_mmio_rdata;
  logic [1:0] i_axi_mmio_rresp;
  logic  i_axi_mmio_rlast;
  logic  i_axi_mmio_rvalid;
  logic  o_axi_mmio_rready;
  logic [6:0] o_axi_mem_awid;
  logic [5:0] o_axi_mem_awatop;
  logic [63:0] o_axi_mem_awaddr;
  logic [7:0] o_axi_mem_awlen;
  logic [2:0] o_axi_mem_awsize;
  logic [1:0] o_axi_mem_awburst;
  logic  o_axi_mem_awlock;
  logic [3:0] o_axi_mem_awcache;
  logic [2:0] o_axi_mem_awprot;
  logic [3:0] o_axi_mem_awqos;
  logic [3:0] o_axi_mem_awregion;
  logic  o_axi_mem_awvalid;
  logic  i_axi_mem_awready;
  logic [64-1:0] o_axi_mem_wdata;
  logic [64/8-1:0] o_axi_mem_wstrb;
  logic  o_axi_mem_wlast;
  logic  o_axi_mem_wvalid;
  logic  i_axi_mem_wready;
  logic [6:0] i_axi_mem_bid;
  logic [1:0] i_axi_mem_bresp;
  logic  i_axi_mem_bvalid;
  logic  o_axi_mem_bready;
  logic [6:0] o_axi_mem_arid;
  logic [63:0] o_axi_mem_araddr;
  logic [7:0] o_axi_mem_arlen;
  logic [2:0] o_axi_mem_arsize;
  logic [1:0] o_axi_mem_arburst;
  logic  o_axi_mem_arlock;
  logic [3:0] o_axi_mem_arcache;
  logic [2:0] o_axi_mem_arprot;
  logic [3:0] o_axi_mem_arqos;
  logic [3:0] o_axi_mem_arregion;
  logic  o_axi_mem_arvalid;
  logic  i_axi_mem_arready;
  logic [6:0] i_axi_mem_rid;
  logic [64-1:0] i_axi_mem_rdata;
  logic [1:0] i_axi_mem_rresp;
  logic  i_axi_mem_rlast;
  logic  i_axi_mem_rvalid;
  logic  o_axi_mem_rready;
  m_vlsit_riscv_cluster_axi_top #(.PARA_CPU_NUM(32'(HARTS)),
    .PARA_TIMING_PROFILE(32'(TIMING_PROFILE)),
    .PARA_LLC_WAY_NUM(32'd4),.PARA_LLC_NO_LINES(32'd64)) dut (
    .i_clk_cluster(i_clk_cluster),
    .i_rst_n_cluster(i_rst_n_cluster),
    .i_boot_addr(i_boot_addr),
    .i_int_msip(i_int_msip),
    .i_int_mtip(i_int_mtip),
    .i_int_meip(i_int_meip),
    .i_int_ssip(i_int_ssip),
    .i_int_stip(i_int_stip),
    .i_int_seip(i_int_seip),
    .i_hart_debug_req(i_hart_debug_req),
    .o_hart_debug_mode(o_hart_debug_mode),
    .o_int_pmu(o_int_pmu),
    .o_int_fault(o_int_fault),
    .i_axil_awaddr(i_axil_awaddr),
    .i_axil_awprot(i_axil_awprot),
    .i_axil_awvalid(i_axil_awvalid),
    .o_axil_awready(o_axil_awready),
    .i_axil_wdata(i_axil_wdata),
    .i_axil_wstrb(i_axil_wstrb),
    .i_axil_wvalid(i_axil_wvalid),
    .o_axil_wready(o_axil_wready),
    .o_axil_bresp(o_axil_bresp),
    .o_axil_bvalid(o_axil_bvalid),
    .i_axil_bready(i_axil_bready),
    .i_axil_araddr(i_axil_araddr),
    .i_axil_arprot(i_axil_arprot),
    .i_axil_arvalid(i_axil_arvalid),
    .o_axil_arready(o_axil_arready),
    .o_axil_rdata(o_axil_rdata),
    .o_axil_rresp(o_axil_rresp),
    .o_axil_rvalid(o_axil_rvalid),
    .i_axil_rready(i_axil_rready),
    .o_axi_mmio_awid(o_axi_mmio_awid),
    .o_axi_mmio_awaddr(o_axi_mmio_awaddr),
    .o_axi_mmio_awlen(o_axi_mmio_awlen),
    .o_axi_mmio_awsize(o_axi_mmio_awsize),
    .o_axi_mmio_awburst(o_axi_mmio_awburst),
    .o_axi_mmio_awlock(o_axi_mmio_awlock),
    .o_axi_mmio_awcache(o_axi_mmio_awcache),
    .o_axi_mmio_awprot(o_axi_mmio_awprot),
    .o_axi_mmio_awqos(o_axi_mmio_awqos),
    .o_axi_mmio_awregion(o_axi_mmio_awregion),
    .o_axi_mmio_awvalid(o_axi_mmio_awvalid),
    .i_axi_mmio_awready(i_axi_mmio_awready),
    .o_axi_mmio_wdata(o_axi_mmio_wdata),
    .o_axi_mmio_wstrb(o_axi_mmio_wstrb),
    .o_axi_mmio_wlast(o_axi_mmio_wlast),
    .o_axi_mmio_wvalid(o_axi_mmio_wvalid),
    .i_axi_mmio_wready(i_axi_mmio_wready),
    .i_axi_mmio_bid(i_axi_mmio_bid),
    .i_axi_mmio_bresp(i_axi_mmio_bresp),
    .i_axi_mmio_bvalid(i_axi_mmio_bvalid),
    .o_axi_mmio_bready(o_axi_mmio_bready),
    .o_axi_mmio_arid(o_axi_mmio_arid),
    .o_axi_mmio_araddr(o_axi_mmio_araddr),
    .o_axi_mmio_arlen(o_axi_mmio_arlen),
    .o_axi_mmio_arsize(o_axi_mmio_arsize),
    .o_axi_mmio_arburst(o_axi_mmio_arburst),
    .o_axi_mmio_arlock(o_axi_mmio_arlock),
    .o_axi_mmio_arcache(o_axi_mmio_arcache),
    .o_axi_mmio_arprot(o_axi_mmio_arprot),
    .o_axi_mmio_arqos(o_axi_mmio_arqos),
    .o_axi_mmio_arregion(o_axi_mmio_arregion),
    .o_axi_mmio_arvalid(o_axi_mmio_arvalid),
    .i_axi_mmio_arready(i_axi_mmio_arready),
    .i_axi_mmio_rid(i_axi_mmio_rid),
    .i_axi_mmio_rdata(i_axi_mmio_rdata),
    .i_axi_mmio_rresp(i_axi_mmio_rresp),
    .i_axi_mmio_rlast(i_axi_mmio_rlast),
    .i_axi_mmio_rvalid(i_axi_mmio_rvalid),
    .o_axi_mmio_rready(o_axi_mmio_rready),
    .o_axi_mem_awid(o_axi_mem_awid),
    .o_axi_mem_awatop(o_axi_mem_awatop),
    .o_axi_mem_awaddr(o_axi_mem_awaddr),
    .o_axi_mem_awlen(o_axi_mem_awlen),
    .o_axi_mem_awsize(o_axi_mem_awsize),
    .o_axi_mem_awburst(o_axi_mem_awburst),
    .o_axi_mem_awlock(o_axi_mem_awlock),
    .o_axi_mem_awcache(o_axi_mem_awcache),
    .o_axi_mem_awprot(o_axi_mem_awprot),
    .o_axi_mem_awqos(o_axi_mem_awqos),
    .o_axi_mem_awregion(o_axi_mem_awregion),
    .o_axi_mem_awvalid(o_axi_mem_awvalid),
    .i_axi_mem_awready(i_axi_mem_awready),
    .o_axi_mem_wdata(o_axi_mem_wdata),
    .o_axi_mem_wstrb(o_axi_mem_wstrb),
    .o_axi_mem_wlast(o_axi_mem_wlast),
    .o_axi_mem_wvalid(o_axi_mem_wvalid),
    .i_axi_mem_wready(i_axi_mem_wready),
    .i_axi_mem_bid(i_axi_mem_bid),
    .i_axi_mem_bresp(i_axi_mem_bresp),
    .i_axi_mem_bvalid(i_axi_mem_bvalid),
    .o_axi_mem_bready(o_axi_mem_bready),
    .o_axi_mem_arid(o_axi_mem_arid),
    .o_axi_mem_araddr(o_axi_mem_araddr),
    .o_axi_mem_arlen(o_axi_mem_arlen),
    .o_axi_mem_arsize(o_axi_mem_arsize),
    .o_axi_mem_arburst(o_axi_mem_arburst),
    .o_axi_mem_arlock(o_axi_mem_arlock),
    .o_axi_mem_arcache(o_axi_mem_arcache),
    .o_axi_mem_arprot(o_axi_mem_arprot),
    .o_axi_mem_arqos(o_axi_mem_arqos),
    .o_axi_mem_arregion(o_axi_mem_arregion),
    .o_axi_mem_arvalid(o_axi_mem_arvalid),
    .i_axi_mem_arready(i_axi_mem_arready),
    .i_axi_mem_rid(i_axi_mem_rid),
    .i_axi_mem_rdata(i_axi_mem_rdata),
    .i_axi_mem_rresp(i_axi_mem_rresp),
    .i_axi_mem_rlast(i_axi_mem_rlast),
    .i_axi_mem_rvalid(i_axi_mem_rvalid),
    .o_axi_mem_rready(o_axi_mem_rready)
  );
  bit INJECT_ERROR;
  bit SUPERVISOR;
  initial begin if (!$value$plusargs("INJECT_ERROR=%d",INJECT_ERROR)) INJECT_ERROR=0; end
  logic [63:0] memory [0:8191];
  logic write_active=0,read_active=0,write_fail=0;
  logic [63:0] write_addr,read_addr;
  logic [7:0] write_left,read_left;
  logic [2:0] write_size,read_size;
  logic [6:0] write_id,read_id;
  logic [HARTS-1:0] passed='0;
  int retired_count[HARTS];
  int cbo_count[HARTS];
  int old_code[HARTS], new_code[HARTS], traps[HARTS];
  bit icache_complete[HARTS];
  int held[HARTS], prepare_m[HARTS], abort_m[HARTS], commit_e[HARTS];
  int cycles=0;
  int service_phase=0, service_hart=0;
  int completed[HARTS], aborted[HARTS];
  bit pmu_check_done;
  bit axil_aw_hs, axil_w_hs, axil_b_hs, axil_ar_hs, axil_r_hs;
  logic [1:0] axil_bresp_sample, axil_rresp_sample;
  logic [31:0] axil_rdata_sample;
  logic [31:0] pmu_expected_count;
  logic [31:0] pmu_read_data;
  int wave_file;
  string wave_path;
  bit wave_enabled;

  // Sample AXI4-Lite handshakes at the active edge for race-free BFM tasks.
  always @(posedge i_clk_cluster) begin
    axil_aw_hs = i_axil_awvalid & o_axil_awready;
    axil_w_hs = i_axil_wvalid & o_axil_wready;
    axil_b_hs = i_axil_bvalid & o_axil_bready;
    axil_ar_hs = i_axil_arvalid & o_axil_arready;
    axil_r_hs = o_axil_rvalid & i_axil_rready;
    axil_bresp_sample = o_axil_bresp;
    axil_rresp_sample = o_axil_rresp;
    axil_rdata_sample = o_axil_rdata;
  end

  // Independent event-tap scoreboard for the profile-1 PMU pipeline test.
  always_ff @(posedge i_clk_cluster, negedge i_rst_n_cluster) begin : p_ff_pmu_event_scoreboard
    if (!i_rst_n_cluster) pmu_expected_count <= '0;
    else if ((TIMING_PROFILE == 1) && dut.u_vlsit_riscv_cluster_core.w_pmu_evt_en[0])
      pmu_expected_count <= pmu_expected_count +
        32'(dut.u_vlsit_riscv_cluster_core.w_ccu_evt_count[0]);
  end

  // Drive one AXI4-Lite write and wait for independent AW/W and B handshakes.
  task automatic axil_write32(input logic [31:0] addr, input logic [31:0] data);
    bit aw_done, w_done, b_done;
    int timeout_count;
    begin
      @(negedge i_clk_cluster);
      i_axil_awaddr = addr;
      i_axil_awprot = '0;
      i_axil_awvalid = 1'b1;
      i_axil_wdata = data;
      i_axil_wstrb = 4'hf;
      i_axil_wvalid = 1'b1;
      aw_done = 1'b0;
      w_done = 1'b0;
      timeout_count = 0;
      while (!aw_done || !w_done) begin
        @(negedge i_clk_cluster);
        if (axil_aw_hs) begin i_axil_awvalid = 1'b0; aw_done = 1'b1; end
        if (axil_w_hs) begin i_axil_wvalid = 1'b0; w_done = 1'b1; end
        timeout_count++;
        if (timeout_count >= 100) $fatal(1, "AXI4-Lite write address/data timeout at %h", addr);
      end
      i_axil_bready = 1'b1;
      b_done = 1'b0;
      timeout_count = 0;
      while (!b_done) begin
        @(negedge i_clk_cluster);
        if (axil_b_hs) begin
          if (axil_bresp_sample != 2'b00) $fatal(1, "AXI4-Lite write response error at %h", addr);
          i_axil_bready = 1'b0;
          b_done = 1'b1;
        end
        timeout_count++;
        if (timeout_count >= 100) $fatal(1, "AXI4-Lite write response timeout at %h", addr);
      end
    end
  endtask

  // Drive one AXI4-Lite read and return the accepted R-channel value.
  task automatic axil_read32(input logic [31:0] addr, output logic [31:0] data);
    bit ar_done, r_done;
    int timeout_count;
    begin
      @(negedge i_clk_cluster);
      i_axil_araddr = addr;
      i_axil_arprot = '0;
      i_axil_arvalid = 1'b1;
      ar_done = 1'b0;
      timeout_count = 0;
      while (!ar_done) begin
        @(negedge i_clk_cluster);
        if (axil_ar_hs) begin
          i_axil_arvalid = 1'b0;
          ar_done = 1'b1;
        end
        timeout_count++;
        if (timeout_count >= 100) $fatal(1, "AXI4-Lite read address timeout at %h", addr);
      end
      i_axil_rready = 1'b1;
      r_done = 1'b0;
      timeout_count = 0;
      while (!r_done) begin
        @(negedge i_clk_cluster);
        if (axil_r_hs) begin
          if (axil_rresp_sample != 2'b00) $fatal(1, "AXI4-Lite read response error at %h", addr);
          data = axil_rdata_sample;
          i_axil_rready = 1'b0;
          r_done = 1'b1;
        end
        timeout_count++;
        if (timeout_count >= 100) $fatal(1, "AXI4-Lite read response timeout at %h", addr);
      end
    end
  endtask

  // Profile 1 PMU check uses software-visible CSRs and real CPU-generated CCU events.
  initial begin : p_check_pmu_timing_profile
    logic [31:0] ctrl_value;
    pmu_check_done = (TIMING_PROFILE == 0);
    if (TIMING_PROFILE == 1) begin
      wait (i_rst_n_cluster);
      axil_write32(32'h0000_1000, 32'h000d_0300); // CCU request event, cluster scope, enabled
      wait (passed == '1);
      axil_write32(32'h0000_0000, 32'h0000_0002); // W1C old snapshot_done
      axil_write32(32'h0000_0000, 32'h0000_0001); // request one coherent snapshot
      ctrl_value = '0;
      for (int poll_idx = 0; poll_idx < 20; poll_idx++) begin
        axil_read32(32'h0000_0000, ctrl_value);
        if (ctrl_value[1]) break;
      end
      if (!ctrl_value[1]) $fatal(1, "profile 1 PMU snapshot did not complete");
      axil_read32(32'h0000_2000, pmu_read_data);
      if (pmu_read_data == 0) $fatal(1, "profile 1 PMU lost CPU-generated CCU events");
      if (pmu_read_data != pmu_expected_count)
        $fatal(1, "profile 1 PMU event count mismatch: expected=%0d actual=%0d",
          pmu_expected_count, pmu_read_data);
      pmu_check_done = 1'b1;
      $display("CHECK profile=%0d PMU CCU request snapshot=%0d expected=%0d",
        TIMING_PROFILE, pmu_read_data, pmu_expected_count);
    end
  end

  initial begin
    wave_enabled=$value$plusargs("WAVE=%s",wave_path);
    if(wave_enabled) begin
      wave_file=$fopen(wave_path,"w");
      if(wave_file==0) $fatal(1,"cannot open service waveform");
      $fdisplay(wave_file,"$timescale 1ns $end\n$scope module cmo_service $end");
      $fdisplay(wave_file,"$var wire 1 a begin_valid $end\n$var wire 1 b begin_ready $end");
      $fdisplay(wave_file,"$var wire 1 c prepare_valid $end\n$var wire 1 d prepare_ready $end");
      $fdisplay(wave_file,"$var wire 1 e maint_valid $end\n$var wire 1 f maint_ready $end");
      $fdisplay(wave_file,"$var wire 1 g maint_done $end\n$var wire 1 h maint_error $end");
      $fdisplay(wave_file,"$var wire 1 i finish_valid $end\n$var wire 1 j finish_ready $end");
      $fdisplay(wave_file,"$var wire 1 k finish_commit $end\n$var wire 1 l finish_done $end");
      $fdisplay(wave_file,"$var wire 1 m cmo_done $end\n$var wire 1 n cmo_error $end");
      $fdisplay(wave_file,"$var wire 2 o hart $end");
      for(int h=0;h<HARTS;h++) begin
        $fdisplay(wave_file,"$var wire 1 f%0d fence_pending_%0d $end",h,h);
        $fdisplay(wave_file,"$var wire 1 t%0d trap_valid_%0d $end",h,h);
        $fdisplay(wave_file,"$var wire 64 c%0d trap_cause_%0d $end",h,h);
        $fdisplay(wave_file,"$var wire 1 r%0d retire_%0d $end",h,h);
        $fdisplay(wave_file,"$var wire 1 x%0d icache_invalidate_%0d $end",h,h);
      end
      $fdisplay(wave_file,"$upscope $end\n$enddefinitions $end");
    end
    for(int h=0;h<HARTS;h++) begin completed[h]=0; aborted[h]=0; end
  end
  // REQ-MEM-014: terminal retirement follows PREPARE, LLC and COMMIT/ABORT ACK.
  always @(posedge i_clk_cluster) begin
    if(i_rst_n_cluster) begin
      if(wave_enabled) begin
        $fdisplay(wave_file,"#%0d",$time);
        $fdisplay(wave_file,"%ba\n%bb\n%bc\n%bd\n%be\n%bf\n%bg\n%bh\n%bi\n%bj\n%bk\n%bl\n%bm\n%bn\nb%02b o",
        dut.u_vlsit_riscv_cluster_core.w_cmo_ccu_begin_valid,
        dut.u_vlsit_riscv_cluster_core.w_cmo_ccu_begin_ready,
        dut.u_vlsit_riscv_cluster_core.w_cmo_ccu_prepare_valid,
        dut.u_vlsit_riscv_cluster_core.w_cmo_ccu_prepare_ready,
        dut.u_vlsit_riscv_cluster_core.w_maint_valid,
        dut.u_vlsit_riscv_cluster_core.w_maint_ready,
        dut.u_vlsit_riscv_cluster_core.w_maint_done,
        dut.u_vlsit_riscv_cluster_core.w_maint_error,
        dut.u_vlsit_riscv_cluster_core.w_cmo_ccu_finish_valid,
        dut.u_vlsit_riscv_cluster_core.w_cmo_ccu_finish_ready,
        dut.u_vlsit_riscv_cluster_core.w_cmo_ccu_finish_commit,
        dut.u_vlsit_riscv_cluster_core.w_cmo_ccu_finish_done,
        dut.u_vlsit_riscv_cluster_core.w_cmo_done,
        dut.u_vlsit_riscv_cluster_core.w_cmo_error,
          dut.u_vlsit_riscv_cluster_core.w_cmo_hart);
      end
      if(dut.u_vlsit_riscv_cluster_core.w_cmo_ccu_begin_valid && dut.u_vlsit_riscv_cluster_core.w_cmo_ccu_begin_ready) begin
        if(service_phase!=0) $fatal(1,"overlapping shared CMO service");
        service_hart=int'(dut.u_vlsit_riscv_cluster_core.w_cmo_ccu_begin_hart);
        service_phase=1;
      end
      if(dut.u_vlsit_riscv_cluster_core.w_cmo_ccu_prepare_valid && dut.u_vlsit_riscv_cluster_core.w_cmo_ccu_prepare_ready) begin
        if(service_phase!=1) $fatal(1,"PREPARE without begin");
        service_phase=2;
      end
      if(dut.u_vlsit_riscv_cluster_core.w_maint_valid && dut.u_vlsit_riscv_cluster_core.w_maint_ready) begin
        $fatal(1,"DEC-030 FENCE.I must not request LLC-to-DRAM maintenance");
        if(service_phase!=2) $fatal(1,"LLC before PREPARE completion");
        service_phase=3;
      end
      if(dut.u_vlsit_riscv_cluster_core.w_maint_done) begin
        if(service_phase!=3) $fatal(1,"unexpected LLC completion");
        service_phase=4;
      end
      if(dut.u_vlsit_riscv_cluster_core.w_cmo_ccu_finish_valid && dut.u_vlsit_riscv_cluster_core.w_cmo_ccu_finish_ready) begin
        if(service_phase!=2) $fatal(1,"terminal command before PREPARE completion");
        if(dut.u_vlsit_riscv_cluster_core.w_cmo_ccu_finish_commit == 1'(INJECT_ERROR && completed[service_hart]==0))
          $fatal(1,"incorrect COMMIT/ABORT decision");
        service_phase=5;
      end
      if(dut.u_vlsit_riscv_cluster_core.w_cmo_ccu_finish_done) begin
        if(service_phase!=5) $fatal(1,"unexpected terminal ACK");
        service_phase=6;
      end
      if(dut.u_vlsit_riscv_cluster_core.w_cmo_done) begin
        if(service_phase!=6) $fatal(1,"CPU completion before terminal CCU ACK");
        completed[service_hart]++;
        if(dut.u_vlsit_riscv_cluster_core.w_cmo_error) aborted[service_hart]++;
        service_phase=0;
      end
    end
  end
  assign i_axi_mem_awready = !write_active && !i_axi_mem_bvalid;
  assign i_axi_mem_wready = write_active;
  assign i_axi_mem_arready = !read_active && !i_axi_mem_rvalid;
  always #5 i_clk_cluster=~i_clk_cluster;
  function automatic int memory_index(input logic [63:0] addr);
    if(addr<64'h8000_0000 || addr>=64'h8001_0000) $fatal(1,"memory address out of model range %h",addr);
    return int'((addr-64'h8000_0000)>>3);
  endfunction
  always_ff @(posedge i_clk_cluster) begin
    if(!i_rst_n_cluster) begin
      write_active<=0; read_active<=0;
      i_axi_mem_bvalid<=0; i_axi_mem_bid<=0; i_axi_mem_bresp<=0;
      i_axi_mem_rvalid<=0; i_axi_mem_rid<=0; i_axi_mem_rdata<=0;
      i_axi_mem_rresp<=0; i_axi_mem_rlast<=0;
    end else begin
      if(o_axi_mem_awvalid && i_axi_mem_awready) begin
        if(o_axi_mem_awatop!=0 || o_axi_mem_awburst!=1 || o_axi_mem_awsize>3)
          $fatal(1,"unexpected write protocol in FENCE.I test");
        write_active<=1; write_addr<=o_axi_mem_awaddr;
        write_left<=o_axi_mem_awlen; write_size<=o_axi_mem_awsize;
        write_id<=o_axi_mem_awid;
        write_fail<=0;
        $fatal(1,"FENCE.I must not write DRAM");
      end
      if(o_axi_mem_wvalid && i_axi_mem_wready) begin
        if(o_axi_mem_wlast !== (write_left==0)) $fatal(1,"write last mismatch");
        if(!write_fail)
          for(int byte_idx=0;byte_idx<8;byte_idx++)
            if(o_axi_mem_wstrb[byte_idx])
              memory[memory_index(write_addr)][byte_idx*8+:8]<=o_axi_mem_wdata[byte_idx*8+:8];
        if(write_left==0) begin
          write_active<=0; i_axi_mem_bvalid<=1;
          i_axi_mem_bid<=write_id; i_axi_mem_bresp<=write_fail ? 2'b10:2'b00;
        end else begin write_left<=write_left-1'b1; write_addr<=write_addr+(64'd1<<write_size); end
      end
      if(i_axi_mem_bvalid && o_axi_mem_bready) i_axi_mem_bvalid<=0;
      if(o_axi_mem_arvalid && i_axi_mem_arready) begin
        if(o_axi_mem_arburst!=1 || o_axi_mem_arsize>3) $fatal(1,"unexpected read protocol");
        read_active<=1; read_addr<=o_axi_mem_araddr;
        read_left<=o_axi_mem_arlen; read_size<=o_axi_mem_arsize; read_id<=o_axi_mem_arid;
      end
      if(read_active && !i_axi_mem_rvalid) begin
        i_axi_mem_rvalid<=1; i_axi_mem_rid<=read_id;
        i_axi_mem_rdata<=memory[memory_index(read_addr)]; i_axi_mem_rresp<=0;
        i_axi_mem_rlast<=(read_left==0);
      end
      if(i_axi_mem_rvalid && o_axi_mem_rready) begin
        i_axi_mem_rvalid<=0;
        if(read_left==0) read_active<=0;
        else begin read_left<=read_left-1'b1; read_addr<=read_addr+(64'd1<<read_size); end
      end
    end
  end
  initial begin
    if (!$value$plusargs("SUPERVISOR=%d",SUPERVISOR)) SUPERVISOR=0;
    for(int idx=0;idx<8192;idx++) memory[idx]='0;
    memory[0][0+:32]=32'h00000297;
    memory[0][32+:32]=32'h20028293;
    memory[1][0+:32]=32'h30529073;
    memory[1][32+:32]=32'hf1402573;
    memory[2][0+:32]=32'h800015b7;
    memory[2][32+:32]=32'h02059593;
    memory[3][0+:32]=32'h0205d593;
    memory[3][32+:32]=32'h00651613;
    memory[4][0+:32]=32'h00c585b3;
    memory[4][32+:32]=32'h000580e7; // jalr ra,0(a1): prime old ADDI
    memory[5][0+:32]=32'h002006b7;  // lui a3,0x200
    memory[5][32+:32]=32'h71368693; // addi a3,a3,0x713 -> ADDI a4,zero,2
    memory[6][0+:32]=32'h00d5a023;  // sw a3,0(a1)
    memory[6][32+:32]=32'h0000100f; // FENCE.I at PC 0x80000034
    memory[7][0+:32]=32'h000580e7;  // execute modified code
    memory[7][32+:32]=32'h0000006f;
    for(int h=0; h<HARTS; h++) begin
      memory[(32'h1000+h*64)>>3]=64'h00008067_00100713; // ADDI a4,zero,1; RET
    end
    memory[64][0+:32]=32'h34202373;
    memory[64][32+:32]=32'h341023f3;
    memory[65][0+:32]=32'h34302e73;
    memory[65][32+:32]=32'h30200073; // MRET retries faulting FENCE.I
    if(SUPERVISOR) begin
      memory[0][0+:32]=32'h4000006f; // JAL zero,+0x400
      memory[64][0+:32]=32'h14202373; // scause
      memory[64][32+:32]=32'h141023f3; // sepc
      memory[65][0+:32]=32'h14302e73; // stval
      memory[65][32+:32]=32'h10200073; // SRET
      memory[128][0+:32]=32'hf1402573;
      memory[128][32+:32]=32'h00000297;
      memory[129][0+:32]=32'hdfc28293;
      memory[129][32+:32]=32'h30529073;
      memory[130][0+:32]=32'h10529073;
      memory[130][32+:32]=32'h010002b7;
      memory[131][0+:32]=32'h30229073;
      memory[131][32+:32]=32'hfff00293;
      memory[132][0+:32]=32'h3b029073;
      memory[132][32+:32]=32'h01f00293;
      memory[133][0+:32]=32'h3a029073;
      memory[133][32+:32]=32'h000012b7;
      memory[134][0+:32]=32'h80028293;
      memory[134][32+:32]=32'h30029073;
      memory[135][0+:32]=32'h00000297;
      memory[135][32+:32]=32'hbd828293;
      memory[136][0+:32]=32'h34129073;
      memory[136][32+:32]=32'h30200073;
    end
    i_boot_addr='0;
    i_int_msip='0;
    i_int_mtip='0;
    i_int_meip='0;
    i_int_ssip='0;
    i_int_stip='0;
    i_int_seip='0;
    i_hart_debug_req='0;
    i_axil_awaddr='0;
    i_axil_awprot='0;
    i_axil_awvalid='0;
    i_axil_wdata='0;
    i_axil_wstrb='0;
    i_axil_wvalid='0;
    i_axil_bready='0;
    i_axil_araddr='0;
    i_axil_arprot='0;
    i_axil_arvalid='0;
    i_axil_rready='0;
    i_axi_mmio_awready='0;
    i_axi_mmio_wready='0;
    i_axi_mmio_bid='0;
    i_axi_mmio_bresp='0;
    i_axi_mmio_bvalid='0;
    i_axi_mmio_arready='0;
    i_axi_mmio_rid='0;
    i_axi_mmio_rdata='0;
    i_axi_mmio_rresp='0;
    i_axi_mmio_rlast='0;
    i_axi_mmio_rvalid='0;
    i_boot_addr=64'h8000_0000;
    i_clk_cluster=0; i_rst_n_cluster=0;
    repeat(8) @(negedge i_clk_cluster);
    i_rst_n_cluster=1;
  end
  for(genvar h=0;h<HARTS;h++) begin : gen_hart_monitor
    always @(posedge i_clk_cluster) begin
      if(!i_rst_n_cluster) begin cbo_count[h]=0; retired_count[h]=0; passed[h]=0; old_code[h]=0; new_code[h]=0; traps[h]=0; held[h]=0; prepare_m[h]=0; abort_m[h]=0; commit_e[h]=0; icache_complete[h]=0; end
      else begin
        if(wave_enabled) $fdisplay(wave_file,"%bf%0d\n%bt%0d\nb%064b c%0d\n%br%0d\n%bx%0d",
          dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.fence_sync,h,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.commit_stage_i.exception_o.valid,h,
          dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.commit_stage_i.exception_o.cause,h,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.commit_ack_commit_id[0],h,
          dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.fence_icache_req,h);
        if(dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.fence_icache_done && dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.commit_stage_i.fence_icache_issued_q) icache_complete[h]=1;
        if(dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.commit_ack_commit_id[0]) begin
          retired_count[h]++;
          if(dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.commit_instr_id_commit[0].pc==64'h80001000+64'(h*64)) begin
            if(dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.commit_instr_id_commit[0].result==64'd1 && cbo_count[h]==0) old_code[h]++;
            else if(dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.commit_instr_id_commit[0].result==64'd2 && cbo_count[h]==1) begin
              new_code[h]++;
              if(old_code[h]!=1) $fatal(1,"old instruction line was not primed");
              passed[h]=1;
            end else $fatal(1,"stale or incorrect instruction after FENCE.I");
          end

          if((TRACE!=0) && retired_count[h]<30) $display("hart %0d pc=%h op=%0d",h,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.commit_instr_id_commit[0].pc,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.commit_instr_id_commit[0].op);
          if(dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.commit_instr_id_commit[0].op == ariane_pkg::FENCE_I) begin
            if(INJECT_ERROR && traps[h]!=1) $fatal(1,"FENCE.I retired before precise fault and retry");
            if(!icache_complete[h]) $fatal(1,"FENCE.I retired before I-cache flush ACK");
            cbo_count[h]++;
            if(completed[h] != (INJECT_ERROR ? 2:1)) $fatal(1,"retirement before all terminal ACKs");

          end
        end
        if(dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.commit_stage_i.exception_o.valid && dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.commit_stage_i.exception_o.cause==24) begin
          if(!INJECT_ERROR || completed[h]!=1 || aborted[h]!=1 || cbo_count[h]!=0)
            $fatal(1,"cause 24 before ABORT ACK / retirement ordering");
          if(dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.commit_instr_id_commit[0].pc!=64'h80000034 ||
             dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.commit_stage_i.exception_o.tval!=64'h80001000+64'(h*64))
            $fatal(1,"incorrect FENCE.I fault PC/physical line base");
          traps[h]++;
        end
        // REQ-MEM-018 / DEC-031: no retirement or I-cache invalidate while pending.
        if(dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.fence_sync && dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.cmo_active && !dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.commit_stage_i.cmo_complete_q) begin
          held[h]++;
          if(dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.commit_ack_commit_id!='0 || dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.fence_icache_req)
            $fatal(1,"FENCE.I/younger retired or I-cache invalidated before terminal completion");
        end
        if(dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.fence_icache_req && (!dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.commit_stage_i.cmo_complete_q || dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.commit_stage_i.cmo_error_q)) $fatal(1,"early/error I-cache invalidate");
        if(o_hart_debug_mode[h]) $fatal(1,"maintenance cause 24 misrouted to debug");
        if(dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.commit_stage_i.exception_o.valid && dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.commit_stage_i.exception_o.cause!=24)
          $fatal(1,"unexpected architectural exception");
        if(traps[h]>0 && !dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.commit_stage_i.exception_o.valid) begin
          if(SUPERVISOR) begin
            if(dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.csr_regfile_i.scause_q!=24 || dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.csr_regfile_i.sepc_q!=64'h80000034 ||
               dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.csr_regfile_i.stval_q!=64'h80001000+64'(h*64)) $fatal(1,"S-mode trap CSR mismatch");
          end else begin
            if(dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.csr_regfile_i.mcause_q!=24 || dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.csr_regfile_i.mepc_q!=64'h80000034 ||
               dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.csr_regfile_i.mtval_q!=64'h80001000+64'(h*64)) $fatal(1,"M-mode trap CSR mismatch");
          end
        end
        if(dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.w_tile_probe_rsp_valid[h] && dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.w_tile_probe_rsp_ready[h]) begin
          case(dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.w_tile_probe_rsp_phase[h])
            0: begin
              if(dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.w_tile_probe_rsp_state[h]==3) prepare_m[h]++;
            end
            1: begin
              if(dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.w_tile_probe_rsp_state[h]!=2) $fatal(1,"FENCE.I COMMIT did not produce E");
              commit_e[h]++;
            end
            2: begin
              if(dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.w_tile_probe_rsp_state[h]!=3) $fatal(1,"FENCE.I ABORT did not preserve M");
              abort_m[h]++;
            end
            default: $fatal(1,"invalid probe phase");
          endcase
        end

      end
    end
  end
  always @(negedge i_clk_cluster) begin
    if(i_rst_n_cluster) begin
      if((TRACE!=0) && o_axi_mem_awvalid && i_axi_mem_awready)
        $display("MEM AW addr=%h error_case=%b",o_axi_mem_awaddr,INJECT_ERROR);
      if((TRACE!=0) && i_axi_mem_bvalid && o_axi_mem_bready)
        $display("MEM B resp=%b",i_axi_mem_bresp);
      if((TRACE!=0) && dut.u_vlsit_riscv_cluster_core.w_maint_valid && dut.u_vlsit_riscv_cluster_core.w_maint_ready)
        $display("LLC MAINT op=%0d line=%h",dut.u_vlsit_riscv_cluster_core.w_maint_op,dut.u_vlsit_riscv_cluster_core.w_maint_pa_line);
      if((TRACE!=0) && dut.u_vlsit_riscv_cluster_core.w_maint_done)
        $display("LLC MAINT DONE err=%b",dut.u_vlsit_riscv_cluster_core.w_maint_error);
      cycles++;
      if((passed=='1) && pmu_check_done) begin
        for(int h=0;h<HARTS;h++) begin
          if(completed[h]!=(INJECT_ERROR ? 2:1) || aborted[h]!=(INJECT_ERROR ? 1:0))
            $fatal(1,"missing native service completion hart=%0d",h);
          if(held[h]==0 || prepare_m[h]!=(INJECT_ERROR ? 2:1) || abort_m[h]!=(INJECT_ERROR ? 1:0) || commit_e[h]!=1)
            $fatal(1,"unexercised maintenance state/order checks");
          $display("CHECK old=%0d new=%0d traps=%0d held=%0d PREPARE_M=%0d ABORT_M=%0d COMMIT_E=%0d",old_code[h],new_code[h],traps[h],held[h],prepare_m[h],abort_m[h],commit_e[h]);
          $display("CHECK hart=%0d retired_FENCE.I=%0d completed_service=%0d aborted=%0d",h,cbo_count[h],completed[h],aborted[h]);
        end
        if(wave_enabled) $fclose(wave_file);
        $display("PASS: real CVA6 FENCE.I through arbiter/CCU/LLC; harts=%0d error=%0d profile=%0d cycles=%0d",HARTS,INJECT_ERROR,TIMING_PROFILE,cycles);
        $finish;
      end
      if(cycles>50000) begin
        for(int k=0;k<HARTS;k++) $display("hart %0d retired=%0d FENCE.I=%0d passed=%b",k,retired_count[k],cbo_count[k],passed[k]);
        $fatal(1,"FENCE.I end-to-end watchdog");
      end
    end
  end
  // DEC-039/040: precise AMO/CMO/FENCE.I errors are not ordinary fatal eviction records.
  always @(posedge i_clk_cluster) begin
    if(i_rst_n_cluster && dut.u_vlsit_riscv_cluster_core.w_fault_sts[0])
      $fatal(1,"precise/nonfatal operation incorrectly populated fatal record");
  end
endmodule
