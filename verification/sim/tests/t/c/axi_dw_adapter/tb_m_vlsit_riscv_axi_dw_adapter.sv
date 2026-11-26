`timescale 1ns/1ps

module tb_m_vlsit_riscv_axi_dw_adapter #(
  parameter logic [31:0] PARA_AXI_MEM_DATA_W = 32'd64
) ();
  logic i_clk_cluster = 1'b0;
  logic i_rst_n_cluster = 1'b0;
  always #5 i_clk_cluster = ~i_clk_cluster;

  logic [6:0] i_axi_llc_awid;
  logic [5:0] i_axi_llc_awatop;
  logic [63:0] i_axi_llc_awaddr;
  logic [7:0] i_axi_llc_awlen;
  logic [2:0] i_axi_llc_awsize;
  logic [1:0] i_axi_llc_awburst;
  logic i_axi_llc_awlock;
  logic [3:0] i_axi_llc_awcache;
  logic [2:0] i_axi_llc_awprot;
  logic [3:0] i_axi_llc_awqos;
  logic [3:0] i_axi_llc_awregion;
  logic i_axi_llc_awvalid;
  logic o_axi_llc_awready;
  logic [63:0] i_axi_llc_wdata;
  logic [7:0] i_axi_llc_wstrb;
  logic i_axi_llc_wlast;
  logic i_axi_llc_wvalid;
  logic o_axi_llc_wready;
  logic [6:0] o_axi_llc_bid;
  logic [1:0] o_axi_llc_bresp;
  logic o_axi_llc_bvalid;
  logic i_axi_llc_bready;
  logic [6:0] i_axi_llc_arid;
  logic [63:0] i_axi_llc_araddr;
  logic [7:0] i_axi_llc_arlen;
  logic [2:0] i_axi_llc_arsize;
  logic [1:0] i_axi_llc_arburst;
  logic i_axi_llc_arlock;
  logic [3:0] i_axi_llc_arcache;
  logic [2:0] i_axi_llc_arprot;
  logic [3:0] i_axi_llc_arqos;
  logic [3:0] i_axi_llc_arregion;
  logic i_axi_llc_arvalid;
  logic o_axi_llc_arready;
  logic [6:0] o_axi_llc_rid;
  logic [63:0] o_axi_llc_rdata;
  logic [1:0] o_axi_llc_rresp;
  logic o_axi_llc_rlast;
  logic o_axi_llc_rvalid;
  logic i_axi_llc_rready;

  logic [6:0] o_axi_mem_awid;
  logic [5:0] o_axi_mem_awatop;
  logic [63:0] o_axi_mem_awaddr;
  logic [7:0] o_axi_mem_awlen;
  logic [2:0] o_axi_mem_awsize;
  logic [1:0] o_axi_mem_awburst;
  logic o_axi_mem_awlock;
  logic [3:0] o_axi_mem_awcache;
  logic [2:0] o_axi_mem_awprot;
  logic [3:0] o_axi_mem_awqos;
  logic [3:0] o_axi_mem_awregion;
  logic o_axi_mem_awvalid;
  logic i_axi_mem_awready;
  logic [PARA_AXI_MEM_DATA_W-1:0] o_axi_mem_wdata;
  logic [PARA_AXI_MEM_DATA_W/8-1:0] o_axi_mem_wstrb;
  logic o_axi_mem_wlast;
  logic o_axi_mem_wvalid;
  logic i_axi_mem_wready;
  logic [6:0] i_axi_mem_bid;
  logic [1:0] i_axi_mem_bresp;
  logic i_axi_mem_bvalid;
  logic o_axi_mem_bready;
  logic [6:0] o_axi_mem_arid;
  logic [63:0] o_axi_mem_araddr;
  logic [7:0] o_axi_mem_arlen;
  logic [2:0] o_axi_mem_arsize;
  logic [1:0] o_axi_mem_arburst;
  logic o_axi_mem_arlock;
  logic [3:0] o_axi_mem_arcache;
  logic [2:0] o_axi_mem_arprot;
  logic [3:0] o_axi_mem_arqos;
  logic [3:0] o_axi_mem_arregion;
  logic o_axi_mem_arvalid;
  logic i_axi_mem_arready;
  logic [6:0] i_axi_mem_rid;
  logic [PARA_AXI_MEM_DATA_W-1:0] i_axi_mem_rdata;
  logic [1:0] i_axi_mem_rresp;
  logic i_axi_mem_rlast;
  logic i_axi_mem_rvalid;
  logic o_axi_mem_rready;
  int w_llc_r_handshake_num;
  logic [6:0] w_llc_rid_sample;
  logic [63:0] w_llc_rdata_sample;
  logic [1:0] w_llc_rresp_sample;
  logic w_llc_rlast_sample;

  m_vlsit_riscv_axi_dw_adapter #(
    .PARA_AXI_MEM_DATA_W(PARA_AXI_MEM_DATA_W)
  ) u_dut (.*);

  always @(posedge i_clk_cluster) begin
    if (i_rst_n_cluster && o_axi_llc_rvalid && i_axi_llc_rready) begin
      w_llc_r_handshake_num++;
      w_llc_rid_sample = o_axi_llc_rid;
      w_llc_rdata_sample = o_axi_llc_rdata;
      w_llc_rresp_sample = o_axi_llc_rresp;
      w_llc_rlast_sample = o_axi_llc_rlast;
    end
  end

  task automatic t_check(input logic i_condition, input string i_message);
    if (i_condition !== 1'b1) begin
      $display("FAIL: width=%0d: %s", PARA_AXI_MEM_DATA_W, i_message);
      $fatal(1);
    end
  endtask

  task automatic t_accept_external_wbeat(input logic [PARA_AXI_MEM_DATA_W-1:0] i_expected_data,
                                          input logic [PARA_AXI_MEM_DATA_W/8-1:0] i_expected_strb,
                                          input logic i_expected_last);
    int wait_count;
    logic w_source_accept;
    begin
      wait_count = 0;
      while (o_axi_mem_wvalid !== 1'b1) begin
        @(negedge i_clk_cluster);
        wait_count++;
        if (wait_count > 40) t_check(1'b0, "external W beat did not appear");
      end
      t_check(o_axi_mem_wdata == i_expected_data, "converted WDATA mismatch");
      t_check(o_axi_mem_wstrb == i_expected_strb, "converted WSTRB mismatch");
      t_check(o_axi_mem_wlast == i_expected_last, "converted WLAST mismatch");
      i_axi_mem_wready = 1'b1;
      @(posedge i_clk_cluster);
      w_source_accept = o_axi_llc_wready;
      @(negedge i_clk_cluster);
      i_axi_mem_wready = 1'b0;
      if (w_source_accept) i_axi_llc_wvalid = 1'b0;
    end
  endtask

  task automatic t_drive_external_rbeat(input logic [PARA_AXI_MEM_DATA_W-1:0] i_data,
                                         input logic i_last);
    int wait_count;
    begin
      @(negedge i_clk_cluster);
      i_axi_mem_rid = 7'h2a;
      i_axi_mem_rdata = i_data;
      i_axi_mem_rresp = 2'b10;
      i_axi_mem_rlast = i_last;
      i_axi_mem_rvalid = 1'b1;
      #1ps;
      wait_count = 0;
      while (o_axi_mem_rready !== 1'b1) begin
        @(negedge i_clk_cluster);
        #1ps;
        wait_count++;
        if (wait_count > 40) t_check(1'b0, "external R beat was not accepted");
      end
      @(posedge i_clk_cluster);
    end
  endtask

  initial begin : p_test
    int wait_count;
    logic [PARA_AXI_MEM_DATA_W-1:0] w_data_low;
    logic [PARA_AXI_MEM_DATA_W/8-1:0] w_strb_full;
    logic [PARA_AXI_MEM_DATA_W/8-1:0] w_strb_low;
    i_axi_llc_awid = '0;
    i_axi_llc_awatop = '0;
    i_axi_llc_awaddr = '0;
    i_axi_llc_awlen = '0;
    i_axi_llc_awsize = '0;
    i_axi_llc_awburst = '0;
    i_axi_llc_awlock = '0;
    i_axi_llc_awcache = '0;
    i_axi_llc_awprot = '0;
    i_axi_llc_awqos = '0;
    i_axi_llc_awregion = '0;
    i_axi_llc_awvalid = '0;
    i_axi_llc_wdata = '0;
    i_axi_llc_wstrb = '0;
    i_axi_llc_wlast = '0;
    i_axi_llc_wvalid = '0;
    i_axi_llc_bready = '0;
    i_axi_llc_arid = '0;
    i_axi_llc_araddr = '0;
    i_axi_llc_arlen = '0;
    i_axi_llc_arsize = '0;
    i_axi_llc_arburst = '0;
    i_axi_llc_arlock = '0;
    i_axi_llc_arcache = '0;
    i_axi_llc_arprot = '0;
    i_axi_llc_arqos = '0;
    i_axi_llc_arregion = '0;
    i_axi_llc_arvalid = '0;
    i_axi_llc_rready = '0;
    i_axi_mem_awready = '0;
    i_axi_mem_wready = '0;
    i_axi_mem_bid = '0;
    i_axi_mem_bresp = '0;
    i_axi_mem_bvalid = '0;
    i_axi_mem_arready = '0;
    i_axi_mem_rid = '0;
    i_axi_mem_rdata = '0;
    i_axi_mem_rresp = '0;
    i_axi_mem_rlast = '0;
    i_axi_mem_rvalid = '0;
    w_llc_r_handshake_num = 0;
    w_llc_rid_sample = '0;
    w_llc_rdata_sample = '0;
    w_llc_rresp_sample = '0;
    w_llc_rlast_sample = '0;
    w_data_low = '0;
    w_strb_full = '0;
    w_strb_full[7:0] = 8'hff;
    w_strb_low = '0;
    w_data_low = PARA_AXI_MEM_DATA_W'(64'h8877_6655_4433_2211);
    w_strb_low[3:0] = 4'hf;

    repeat (4) @(posedge i_clk_cluster);
    @(negedge i_clk_cluster);
    i_rst_n_cluster = 1'b1;

    // Write one aligned 64-bit transfer and check width conversion.
    @(negedge i_clk_cluster);
    i_axi_llc_awid = 7'h35;
    i_axi_llc_awaddr = 64'h0000_0000_0000_1000;
    i_axi_llc_awlen = 8'd0;
    i_axi_llc_awsize = 3'd3;
    i_axi_llc_awburst = 2'b01;
    i_axi_llc_awcache = 4'b0011;
    i_axi_llc_awvalid = 1'b1;
    i_axi_llc_wdata = 64'h8877_6655_4433_2211;
    i_axi_llc_wstrb = 8'hff;
    i_axi_llc_wlast = 1'b1;
    i_axi_llc_wvalid = 1'b0;
    i_axi_llc_bready = 1'b1;
    wait_count = 0;
    while ((o_axi_mem_awvalid !== 1'b1) && (wait_count < 40)) begin
      @(posedge i_clk_cluster);
      if (i_axi_llc_awvalid && o_axi_llc_awready) begin
        @(negedge i_clk_cluster);
        i_axi_llc_awvalid = 1'b0;
      end
      wait_count++;
    end
    t_check(wait_count < 40, "external AW did not appear");
    t_check(o_axi_mem_awid == 7'h35, "AW ID changed");
    t_check(o_axi_mem_awaddr == 64'h1000, "AW address changed");
    t_check(o_axi_mem_awburst == 2'b01, "AW burst changed");
    if (PARA_AXI_MEM_DATA_W == 32'd32) begin
      t_check(o_axi_mem_awlen == 8'd1, "64-to-32 AWLEN must split into two beats");
      t_check(o_axi_mem_awsize == 3'd2, "64-to-32 AWSIZE must be four bytes");
    end else begin
      t_check(o_axi_mem_awlen == 8'd0, "one-transfer AWLEN changed");
      t_check(o_axi_mem_awsize == 3'd3, "one-transfer AWSIZE changed");
    end
    i_axi_mem_awready = 1'b1;
    @(posedge i_clk_cluster);
    @(negedge i_clk_cluster);
    i_axi_mem_awready = 1'b0;
    if (i_axi_llc_awvalid && o_axi_llc_awready) i_axi_llc_awvalid = 1'b0;
    i_axi_llc_wvalid = 1'b1;

    if (PARA_AXI_MEM_DATA_W == 32'd32) begin
      t_accept_external_wbeat(PARA_AXI_MEM_DATA_W'(32'h4433_2211), w_strb_low, 1'b0);
      t_accept_external_wbeat(PARA_AXI_MEM_DATA_W'(32'h8877_6655), w_strb_low, 1'b1);
    end else begin
      t_accept_external_wbeat(w_data_low, w_strb_full, 1'b1);
    end
    // Verify that every width returns the original transaction ID and AXI error response.
    repeat (2) @(posedge i_clk_cluster);
    @(negedge i_clk_cluster);
    i_axi_llc_bready = 1'b1;
    i_axi_mem_bid = 7'h35;
    i_axi_mem_bresp = 2'b10;
    i_axi_mem_bvalid = 1'b1;
    #1ps;
    wait_count = 0;
    while (((o_axi_mem_bready !== 1'b1) || (o_axi_llc_bvalid !== 1'b1)) && (wait_count < 40)) begin
      @(negedge i_clk_cluster);
      wait_count++;
    end
    t_check(wait_count < 40, "LLC B response did not assert with external B");
    t_check(o_axi_llc_bid == 7'h35, "B ID changed");
    t_check(o_axi_llc_bresp == 2'b10, "B error response changed");
    @(posedge i_clk_cluster);
    @(negedge i_clk_cluster);
    i_axi_mem_bvalid = 1'b0;
    i_axi_llc_bready = 1'b0;

    // Read one 64-bit transfer; narrower memory emits two beats.
    i_axi_llc_arid = 7'h2a;
    i_axi_llc_araddr = 64'h0000_0000_0000_2000;
    i_axi_llc_arlen = 8'd0;
    i_axi_llc_arsize = 3'd3;
    i_axi_llc_arburst = 2'b01;
    i_axi_llc_arcache = 4'b0011;
    i_axi_llc_arvalid = 1'b1;
    wait_count = 0;
    while ((o_axi_mem_arvalid !== 1'b1) && (wait_count < 40)) begin
      @(posedge i_clk_cluster);
      if (i_axi_llc_arvalid && o_axi_llc_arready) begin
        @(negedge i_clk_cluster);
        i_axi_llc_arvalid = 1'b0;
      end
      wait_count++;
    end
    t_check(wait_count < 40, "external AR did not appear");
    t_check(o_axi_mem_arid == 7'h2a, "AR ID changed");
    t_check(o_axi_mem_araddr == 64'h2000, "AR address changed");
    t_check(o_axi_mem_arburst == 2'b01, "AR burst changed");
    if (PARA_AXI_MEM_DATA_W == 32'd32) begin
      t_check(o_axi_mem_arlen == 8'd1, "64-to-32 ARLEN must split into two beats");
      t_check(o_axi_mem_arsize == 3'd2, "64-to-32 ARSIZE must be four bytes");
    end else begin
      t_check(o_axi_mem_arlen == 8'd0, "one-transfer ARLEN changed");
      t_check(o_axi_mem_arsize == 3'd3, "one-transfer ARSIZE changed");
    end
    i_axi_mem_arready = 1'b1;
    @(posedge i_clk_cluster);
    @(negedge i_clk_cluster);
    i_axi_mem_arready = 1'b0;
    if (i_axi_llc_arvalid && o_axi_llc_arready) i_axi_llc_arvalid = 1'b0;

    i_axi_llc_rready = 1'b1;
    if (PARA_AXI_MEM_DATA_W == 32'd32) begin
      t_drive_external_rbeat(PARA_AXI_MEM_DATA_W'(32'h4433_2211), 1'b0);
      t_drive_external_rbeat(PARA_AXI_MEM_DATA_W'(32'h8877_6655), 1'b1);
    end else begin
      t_drive_external_rbeat(PARA_AXI_MEM_DATA_W'(64'h8877_6655_4433_2211), 1'b1);
    end
    @(negedge i_clk_cluster);
    i_axi_mem_rvalid = 1'b0;
    repeat (2) @(posedge i_clk_cluster);
    t_check(w_llc_r_handshake_num == 1, "expected exactly one LLC R beat");
    t_check(w_llc_rid_sample == 7'h2a, "R ID changed");
    t_check(w_llc_rdata_sample == 64'h8877_6655_4433_2211, "converted RDATA mismatch");
    t_check(w_llc_rlast_sample == 1'b1, "LLC RLAST mismatch");
    t_check(w_llc_rresp_sample == 2'b10, "R error response changed");
    @(negedge i_clk_cluster);
    i_axi_llc_rready = 1'b0;

    // Confirm that the converter retains AXI4+ATOP metadata for every width profile.
    i_axi_llc_awid = 7'h16;
    i_axi_llc_awatop = 6'b000001;
    i_axi_llc_awaddr = 64'h0000_0000_0000_3000;
    i_axi_llc_awlen = 8'd0;
    i_axi_llc_awsize = 3'd2;
    i_axi_llc_awburst = 2'b01;
    i_axi_llc_awvalid = 1'b1;
    wait_count = 0;
    while (o_axi_mem_awvalid !== 1'b1 && wait_count < 40) begin
      @(negedge i_clk_cluster);
      wait_count++;
    end
    t_check(wait_count < 40, "ATOP AW did not reach memory port");
    t_check(o_axi_mem_awatop == 6'b000001, "AWATOP changed");
    t_check(o_axi_mem_awid == 7'h16, "ATOP AW ID changed");

    $display("PASS: AXI width conversion, channel payloads, and supported response checks; data_width=%0d",
             PARA_AXI_MEM_DATA_W);
    $finish;
  end

endmodule
