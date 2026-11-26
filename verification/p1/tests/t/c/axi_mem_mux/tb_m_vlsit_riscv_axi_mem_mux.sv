`timescale 1ns/1ps

module tb_m_vlsit_riscv_axi_mem_mux #(
  parameter logic [31:0] PARA_CPU_NUM = 32'd4
);
  logic i_clk_cluster;
  logic i_rst_n_cluster;
  logic [3:0][3:0] i_axi_src_awid;
  logic [3:0][5:0] i_axi_src_awatop;
  logic [3:0][63:0] i_axi_src_awaddr;
  logic [3:0][7:0] i_axi_src_awlen;
  logic [3:0][2:0] i_axi_src_awsize;
  logic [3:0][1:0] i_axi_src_awburst;
  logic [3:0] i_axi_src_awlock;
  logic [3:0][3:0] i_axi_src_awcache;
  logic [3:0][2:0] i_axi_src_awprot;
  logic [3:0][3:0] i_axi_src_awqos;
  logic [3:0][3:0] i_axi_src_awregion;
  logic [3:0] i_axi_src_awvalid;
  logic [3:0] o_axi_src_awready;
  logic [3:0][63:0] i_axi_src_wdata;
  logic [3:0][7:0] i_axi_src_wstrb;
  logic [3:0] i_axi_src_wlast;
  logic [3:0] i_axi_src_wvalid;
  logic [3:0] o_axi_src_wready;
  logic [3:0][3:0] o_axi_src_bid;
  logic [3:0][1:0] o_axi_src_bresp;
  logic [3:0] o_axi_src_bvalid;
  logic [3:0] i_axi_src_bready;
  logic [3:0][3:0] i_axi_src_arid;
  logic [3:0][63:0] i_axi_src_araddr;
  logic [3:0][7:0] i_axi_src_arlen;
  logic [3:0][2:0] i_axi_src_arsize;
  logic [3:0][1:0] i_axi_src_arburst;
  logic [3:0] i_axi_src_arlock;
  logic [3:0][3:0] i_axi_src_arcache;
  logic [3:0][2:0] i_axi_src_arprot;
  logic [3:0][3:0] i_axi_src_arqos;
  logic [3:0][3:0] i_axi_src_arregion;
  logic [3:0] i_axi_src_arvalid;
  logic [3:0] o_axi_src_arready;
  logic [3:0][3:0] o_axi_src_rid;
  logic [3:0][63:0] o_axi_src_rdata;
  logic [3:0][1:0] o_axi_src_rresp;
  logic [3:0] o_axi_src_rlast;
  logic [3:0] o_axi_src_rvalid;
  logic [3:0] i_axi_src_rready;
  logic [5:0] o_axi_llc_awid;
  logic [5:0] o_axi_llc_awatop;
  logic [63:0] o_axi_llc_awaddr;
  logic [7:0] o_axi_llc_awlen;
  logic [2:0] o_axi_llc_awsize;
  logic [1:0] o_axi_llc_awburst;
  logic o_axi_llc_awlock;
  logic [3:0] o_axi_llc_awcache;
  logic [2:0] o_axi_llc_awprot;
  logic [3:0] o_axi_llc_awqos;
  logic [3:0] o_axi_llc_awregion;
  logic o_axi_llc_awvalid;
  logic i_axi_llc_awready;
  logic [63:0] o_axi_llc_wdata;
  logic [7:0] o_axi_llc_wstrb;
  logic o_axi_llc_wlast;
  logic o_axi_llc_wvalid;
  logic i_axi_llc_wready;
  logic [5:0] i_axi_llc_bid;
  logic [1:0] i_axi_llc_bresp;
  logic i_axi_llc_bvalid;
  logic o_axi_llc_bready;
  logic [5:0] o_axi_llc_arid;
  logic [63:0] o_axi_llc_araddr;
  logic [7:0] o_axi_llc_arlen;
  logic [2:0] o_axi_llc_arsize;
  logic [1:0] o_axi_llc_arburst;
  logic o_axi_llc_arlock;
  logic [3:0] o_axi_llc_arcache;
  logic [2:0] o_axi_llc_arprot;
  logic [3:0] o_axi_llc_arqos;
  logic [3:0] o_axi_llc_arregion;
  logic o_axi_llc_arvalid;
  logic i_axi_llc_arready;
  logic [5:0] i_axi_llc_rid;
  logic [63:0] i_axi_llc_rdata;
  logic [1:0] i_axi_llc_rresp;
  logic i_axi_llc_rlast;
  logic i_axi_llc_rvalid;
  logic o_axi_llc_rready;

  localparam logic [31:0] LPARA_TEST_HART = (PARA_CPU_NUM == 32'd2) ? 32'd1 : 32'd3;
  always #5 i_clk_cluster = ~i_clk_cluster;

  m_vlsit_riscv_axi_mem_mux #(.PARA_CPU_NUM(PARA_CPU_NUM)) u_dut (.*);

  task automatic reset_mux;
    begin
      i_rst_n_cluster = 1'b0;
      repeat (3) @(negedge i_clk_cluster);
      i_rst_n_cluster = 1'b1;
      repeat (2) @(negedge i_clk_cluster);
    end
  endtask

  task automatic check_write_path;
    int unsigned v_wait;
    logic [5:0] v_id;
    begin
      v_id = {2'(LPARA_TEST_HART), 4'hA};
      i_axi_src_awid[LPARA_TEST_HART] = 4'hA;
      i_axi_src_awatop[LPARA_TEST_HART] = 6'h15;
      i_axi_src_awaddr[LPARA_TEST_HART] = 64'h0000_0000_8000_0120;
      i_axi_src_awlen[LPARA_TEST_HART] = 8'd0;
      i_axi_src_awsize[LPARA_TEST_HART] = 3'd3;
      i_axi_src_awburst[LPARA_TEST_HART] = 2'b01;
      i_axi_src_awvalid[LPARA_TEST_HART] = 1'b1;
      v_wait = 0;
      while ((o_axi_src_awready[LPARA_TEST_HART] !== 1'b1) && (v_wait < 8)) begin
        @(negedge i_clk_cluster);
        v_wait++;
      end
      if (o_axi_src_awready[LPARA_TEST_HART] !== 1'b1) $fatal(1, "AW source was not accepted");
      @(posedge i_clk_cluster);
      @(negedge i_clk_cluster);
      i_axi_src_awvalid[LPARA_TEST_HART] = 1'b0;
      v_wait = 0;
      while ((o_axi_llc_awvalid !== 1'b1) && (v_wait < 8)) begin
        @(negedge i_clk_cluster);
        v_wait++;
      end
      if ((o_axi_llc_awvalid !== 1'b1) || (o_axi_llc_awid !== v_id) ||
          (o_axi_llc_awatop !== 6'h15) || (o_axi_llc_awaddr !== 64'h0000_0000_8000_0120))
        $fatal(1, "AW ID, ATOP, or address mismatch");
      i_axi_llc_awready = 1'b1;
      @(posedge i_clk_cluster);
      @(negedge i_clk_cluster);
      i_axi_llc_awready = 1'b0;

      i_axi_src_wdata[LPARA_TEST_HART] = 64'hDEAD_BEEF_0123_4567;
      i_axi_src_wstrb[LPARA_TEST_HART] = 8'hA5;
      i_axi_src_wlast[LPARA_TEST_HART] = 1'b1;
      i_axi_src_wvalid[LPARA_TEST_HART] = 1'b1;
      #1;
      if ((o_axi_llc_wvalid !== 1'b1) || (o_axi_llc_wdata !== 64'hDEAD_BEEF_0123_4567) ||
          (o_axi_llc_wstrb !== 8'hA5) || (o_axi_llc_wlast !== 1'b1))
        $fatal(1, "W payload mismatch");
      i_axi_llc_wready = 1'b1;
      @(posedge i_clk_cluster);
      @(negedge i_clk_cluster);
      i_axi_llc_wready = 1'b0;
      i_axi_src_wvalid[LPARA_TEST_HART] = 1'b0;

      i_axi_src_bready[LPARA_TEST_HART] = 1'b0;
      i_axi_llc_bid = v_id;
      i_axi_llc_bresp = 2'b10;
      i_axi_llc_bvalid = 1'b1;
      #1;
      if ((o_axi_src_bvalid[LPARA_TEST_HART] !== 1'b1) ||
          (o_axi_src_bid[LPARA_TEST_HART] !== 4'hA) ||
          (o_axi_src_bresp[LPARA_TEST_HART] !== 2'b10))
        $fatal(1, "B response source-ID/RESP mismatch");
      i_axi_src_bready[LPARA_TEST_HART] = 1'b1;
      @(posedge i_clk_cluster);
      @(negedge i_clk_cluster);
      i_axi_llc_bvalid = 1'b0;
    end
  endtask

  task automatic check_read_path;
    int unsigned v_wait;
    logic [5:0] v_id;
    begin
      v_id = {2'(LPARA_TEST_HART), 4'h5};
      i_axi_src_arid[LPARA_TEST_HART] = 4'h5;
      i_axi_src_araddr[LPARA_TEST_HART] = 64'h0000_0000_8000_0200;
      i_axi_src_arlen[LPARA_TEST_HART] = 8'd0;
      i_axi_src_arsize[LPARA_TEST_HART] = 3'd3;
      i_axi_src_arburst[LPARA_TEST_HART] = 2'b01;
      i_axi_src_arvalid[LPARA_TEST_HART] = 1'b1;
      v_wait = 0;
      while ((o_axi_src_arready[LPARA_TEST_HART] !== 1'b1) && (v_wait < 8)) begin
        @(negedge i_clk_cluster);
        v_wait++;
      end
      if (o_axi_src_arready[LPARA_TEST_HART] !== 1'b1) $fatal(1, "AR source was not accepted");
      @(posedge i_clk_cluster);
      @(negedge i_clk_cluster);
      i_axi_src_arvalid[LPARA_TEST_HART] = 1'b0;
      v_wait = 0;
      while ((o_axi_llc_arvalid !== 1'b1) && (v_wait < 8)) begin
        @(negedge i_clk_cluster);
        v_wait++;
      end
      if ((o_axi_llc_arvalid !== 1'b1) || (o_axi_llc_arid !== v_id) ||
          (o_axi_llc_araddr !== 64'h0000_0000_8000_0200)) $fatal(1, "AR ID/address mismatch");
      i_axi_llc_arready = 1'b1;
      @(posedge i_clk_cluster);
      @(negedge i_clk_cluster);
      i_axi_llc_arready = 1'b0;

      i_axi_src_rready[LPARA_TEST_HART] = 1'b0;
      i_axi_llc_rid = v_id;
      i_axi_llc_rdata = 64'h0123_4567_89AB_CDEF;
      i_axi_llc_rresp = 2'b00;
      i_axi_llc_rlast = 1'b1;
      i_axi_llc_rvalid = 1'b1;
      #1;
      if ((o_axi_src_rvalid[LPARA_TEST_HART] !== 1'b1) ||
          (o_axi_src_rid[LPARA_TEST_HART] !== 4'h5) ||
          (o_axi_src_rdata[LPARA_TEST_HART] !== 64'h0123_4567_89AB_CDEF) ||
          (o_axi_src_rlast[LPARA_TEST_HART] !== 1'b1)) $fatal(1, "R response source-ID/payload mismatch");
      i_axi_src_rready[LPARA_TEST_HART] = 1'b1;
      @(posedge i_clk_cluster);
      @(negedge i_clk_cluster);
      i_axi_llc_rvalid = 1'b0;
    end
  endtask

  initial begin
    i_axi_src_awid = '0;
    i_axi_src_awatop = '0;
    i_axi_src_awaddr = '0;
    i_axi_src_awlen = '0;
    i_axi_src_awsize = '0;
    i_axi_src_awburst = '0;
    i_axi_src_awlock = '0;
    i_axi_src_awcache = '0;
    i_axi_src_awprot = '0;
    i_axi_src_awqos = '0;
    i_axi_src_awregion = '0;
    i_axi_src_awvalid = '0;
    i_axi_src_wdata = '0;
    i_axi_src_wstrb = '0;
    i_axi_src_wlast = '0;
    i_axi_src_wvalid = '0;
    i_axi_src_bready = '0;
    i_axi_src_arid = '0;
    i_axi_src_araddr = '0;
    i_axi_src_arlen = '0;
    i_axi_src_arsize = '0;
    i_axi_src_arburst = '0;
    i_axi_src_arlock = '0;
    i_axi_src_arcache = '0;
    i_axi_src_arprot = '0;
    i_axi_src_arqos = '0;
    i_axi_src_arregion = '0;
    i_axi_src_arvalid = '0;
    i_axi_src_rready = '0;
    i_axi_llc_awready = '0;
    i_axi_llc_wready = '0;
    i_axi_llc_bid = '0;
    i_axi_llc_bresp = '0;
    i_axi_llc_bvalid = '0;
    i_axi_llc_arready = '0;
    i_axi_llc_rid = '0;
    i_axi_llc_rdata = '0;
    i_axi_llc_rresp = '0;
    i_axi_llc_rlast = '0;
    i_axi_llc_rvalid = '0;

    i_clk_cluster = 1'b0;
    i_rst_n_cluster = 1'b0;
    repeat (2) @(negedge i_clk_cluster);
    i_rst_n_cluster = 1'b1;
    repeat (2) @(negedge i_clk_cluster);

    if (PARA_CPU_NUM == 32'd2) begin
      i_axi_src_awvalid[3] = 1'b1;
      repeat (4) @(negedge i_clk_cluster);
      if ((o_axi_src_awready[3] !== 1'b0) || (o_axi_llc_awvalid !== 1'b0))
        $fatal(1, "inactive hart 3 request was not masked");
      i_axi_src_awvalid[3] = 1'b0;
      reset_mux();
    end

    i_axi_llc_awready = 1'b0;
    i_axi_llc_wready = 1'b0;
    i_axi_llc_arready = 1'b0;
    check_write_path();
    reset_mux();
    check_read_path();
    $display("PASS: AXI IDs, ATOP, W/R payloads, response routing, and inactive-hart mask; harts=%0d", PARA_CPU_NUM);
    $finish;
  end
endmodule
