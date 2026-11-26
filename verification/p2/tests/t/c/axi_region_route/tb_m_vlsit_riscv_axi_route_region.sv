`timescale 1ns/1ps

module tb_m_vlsit_riscv_axi_route_region;

  logic i_clk_cluster;
  logic i_rst_n_cluster;
  logic [3:0] i_awid;
  logic [5:0] i_awatop;
  logic [63:0] i_awaddr;
  logic [7:0] i_awlen;
  logic [2:0] i_awsize;
  logic [1:0] i_awburst;
  logic i_awlock;
  logic [3:0] i_awcache;
  logic [2:0] i_awprot;
  logic [3:0] i_awqos;
  logic [3:0] i_awregion;
  logic i_awvalid;
  logic o_awready;
  logic i_aw_region_match;
  logic [1:0] i_aw_region_type;
  logic i_aw_region_err;
  logic [63:0] i_wdata;
  logic [7:0] i_wstrb;
  logic i_wlast;
  logic i_wvalid;
  logic o_wready;
  logic [3:0] o_bid;
  logic [1:0] o_bresp;
  logic o_bvalid;
  logic i_bready;
  logic [3:0] i_arid;
  logic [63:0] i_araddr;
  logic [7:0] i_arlen;
  logic [2:0] i_arsize;
  logic [1:0] i_arburst;
  logic i_arlock;
  logic [3:0] i_arcache;
  logic [2:0] i_arprot;
  logic [3:0] i_arqos;
  logic [3:0] i_arregion;
  logic i_arvalid;
  logic o_arready;
  logic i_ar_region_match;
  logic [1:0] i_ar_region_type;
  logic i_ar_region_err;
  logic [3:0] o_rid;
  logic [63:0] o_rdata;
  logic [1:0] o_rresp;
  logic o_rlast;
  logic o_rvalid;
  logic i_rready;
  logic [3:0] o_mem_awid;
  logic [5:0] o_mem_awatop;
  logic [63:0] o_mem_awaddr;
  logic [7:0] o_mem_awlen;
  logic [2:0] o_mem_awsize;
  logic [1:0] o_mem_awburst;
  logic o_mem_awlock;
  logic [3:0] o_mem_awcache;
  logic [2:0] o_mem_awprot;
  logic [3:0] o_mem_awqos;
  logic [3:0] o_mem_awregion;
  logic [1:0] o_mem_aw_route_class;
  logic o_mem_awvalid;
  logic i_mem_awready;
  logic [63:0] o_mem_wdata;
  logic [7:0] o_mem_wstrb;
  logic o_mem_wlast;
  logic o_mem_wvalid;
  logic i_mem_wready;
  logic [3:0] i_mem_bid;
  logic [1:0] i_mem_bresp;
  logic i_mem_bvalid;
  logic o_mem_bready;
  logic [3:0] o_mem_arid;
  logic [63:0] o_mem_araddr;
  logic [7:0] o_mem_arlen;
  logic [2:0] o_mem_arsize;
  logic [1:0] o_mem_arburst;
  logic o_mem_arlock;
  logic [3:0] o_mem_arcache;
  logic [2:0] o_mem_arprot;
  logic [3:0] o_mem_arqos;
  logic [3:0] o_mem_arregion;
  logic [1:0] o_mem_ar_route_class;
  logic o_mem_arvalid;
  logic i_mem_arready;
  logic [3:0] i_mem_rid;
  logic [63:0] i_mem_rdata;
  logic [1:0] i_mem_rresp;
  logic i_mem_rlast;
  logic i_mem_rvalid;
  logic o_mem_rready;
  logic [3:0] o_mmio_awid;
  logic [63:0] o_mmio_awaddr;
  logic [7:0] o_mmio_awlen;
  logic [2:0] o_mmio_awsize;
  logic [1:0] o_mmio_awburst;
  logic o_mmio_awlock;
  logic [3:0] o_mmio_awcache;
  logic [2:0] o_mmio_awprot;
  logic [3:0] o_mmio_awqos;
  logic [3:0] o_mmio_awregion;
  logic o_mmio_awvalid;
  logic i_mmio_awready;
  logic [63:0] o_mmio_wdata;
  logic [7:0] o_mmio_wstrb;
  logic o_mmio_wlast;
  logic o_mmio_wvalid;
  logic i_mmio_wready;
  logic [3:0] i_mmio_bid;
  logic [1:0] i_mmio_bresp;
  logic i_mmio_bvalid;
  logic o_mmio_bready;
  logic [3:0] o_mmio_arid;
  logic [63:0] o_mmio_araddr;
  logic [7:0] o_mmio_arlen;
  logic [2:0] o_mmio_arsize;
  logic [1:0] o_mmio_arburst;
  logic o_mmio_arlock;
  logic [3:0] o_mmio_arcache;
  logic [2:0] o_mmio_arprot;
  logic [3:0] o_mmio_arqos;
  logic [3:0] o_mmio_arregion;
  logic o_mmio_arvalid;
  logic i_mmio_arready;
  logic [3:0] i_mmio_rid;
  logic [63:0] i_mmio_rdata;
  logic [1:0] i_mmio_rresp;
  logic i_mmio_rlast;
  logic i_mmio_rvalid;
  logic o_mmio_rready;
  logic o_aw_local_err_event;
  logic o_ar_local_err_event;

  localparam logic [31:0] LPARA_REGION_NUM = 32'd3;
  localparam logic [31:0] LPARA_REGION_BASE_LO [0:15] = '{default:32'd0, 0:32'h8000_0000, 1:32'h4000_0000, 2:32'h6000_0000};
  localparam logic [31:0] LPARA_REGION_BASE_HI [0:15] = '{default:32'd0};
  localparam logic [31:0] LPARA_REGION_SIZE_LO [0:15] = '{default:32'd0, 0:32'h4000_0000, 1:32'h1000_0000, 2:32'h1000_0000};
  localparam logic [31:0] LPARA_REGION_SIZE_HI [0:15] = '{default:32'd0};
  localparam logic [31:0] LPARA_REGION_TYPE [0:15] = '{default:32'd0, 0:32'd0, 1:32'd1, 2:32'd2};
  logic w_aw_config_valid;
  logic w_aw_region_match;
  logic [3:0] w_aw_region_idx;
  logic [1:0] w_aw_region_type;
  logic w_aw_access_err;
  logic w_ar_config_valid;
  logic w_ar_region_match;
  logic [3:0] w_ar_region_idx;
  logic [1:0] w_ar_region_type;
  logic w_ar_access_err;

  always #5 i_clk_cluster = ~i_clk_cluster;

  // The same table format drives address classification and the AXI route metadata.
  m_vlsit_riscv_addr_decode #(
    .PARA_ADDR_REGION_NUM(LPARA_REGION_NUM),
    .PARA_ADDR_REGION_BASE_LO(LPARA_REGION_BASE_LO),
    .PARA_ADDR_REGION_BASE_HI(LPARA_REGION_BASE_HI),
    .PARA_ADDR_REGION_SIZE_LO(LPARA_REGION_SIZE_LO),
    .PARA_ADDR_REGION_SIZE_HI(LPARA_REGION_SIZE_HI),
    .PARA_ADDR_REGION_TYPE(LPARA_REGION_TYPE)
  ) u_aw_addr_decode (
    .i_phys_addr(i_awaddr), .i_access_bytes(12'd8), .i_atomic(|i_awatop),
    .o_config_valid(w_aw_config_valid), .o_region_match(w_aw_region_match),
    .o_region_idx(w_aw_region_idx), .o_region_type(w_aw_region_type), .o_access_err(w_aw_access_err)
  );
  m_vlsit_riscv_addr_decode #(
    .PARA_ADDR_REGION_NUM(LPARA_REGION_NUM),
    .PARA_ADDR_REGION_BASE_LO(LPARA_REGION_BASE_LO),
    .PARA_ADDR_REGION_BASE_HI(LPARA_REGION_BASE_HI),
    .PARA_ADDR_REGION_SIZE_LO(LPARA_REGION_SIZE_LO),
    .PARA_ADDR_REGION_SIZE_HI(LPARA_REGION_SIZE_HI),
    .PARA_ADDR_REGION_TYPE(LPARA_REGION_TYPE)
  ) u_ar_addr_decode (
    .i_phys_addr(i_araddr), .i_access_bytes(12'd8), .i_atomic(1'b0),
    .o_config_valid(w_ar_config_valid), .o_region_match(w_ar_region_match),
    .o_region_idx(w_ar_region_idx), .o_region_type(w_ar_region_type), .o_access_err(w_ar_access_err)
  );
  assign i_aw_region_match = w_aw_region_match;
  assign i_aw_region_type = w_aw_region_type;
  assign i_aw_region_err = w_aw_access_err;
  assign i_ar_region_match = w_ar_region_match;
  assign i_ar_region_type = w_ar_region_type;
  assign i_ar_region_err = w_ar_access_err;

  m_vlsit_riscv_axi_route u_dut (.*);

  task automatic clear_requests;
    begin
      i_awvalid = 1'b0;
      i_arvalid = 1'b0;
      i_awaddr = 64'd0;
      i_araddr = 64'd0;
      i_awlen = 8'd0;
      i_arlen = 8'd0;
      i_awsize = 3'd3;
      i_arsize = 3'd3;
      i_awburst = 2'b01;
      i_arburst = 2'b01;
      i_awatop = 6'd0;
    end
  endtask

  task automatic check_aw_route(input logic [63:0] i_addr, input logic [1:0] i_exp_class, input string i_name);
    begin
      @(negedge i_clk_cluster);
      i_rst_n_cluster = 1'b0;
      clear_requests();
      repeat (2) @(negedge i_clk_cluster);
      i_awaddr = i_addr;
      i_awvalid = 1'b1;
      i_rst_n_cluster = 1'b1;
      repeat (3) @(negedge i_clk_cluster);
      #1;
      if ((w_aw_config_valid !== 1'b1) || (w_aw_access_err !== 1'b0) ||
          ((i_exp_class == 2'd2) && ((o_mmio_awvalid !== 1'b1) || (o_mem_awvalid !== 1'b0))) ||
          ((i_exp_class != 2'd2) && ((o_mem_awvalid !== 1'b1) || (o_mmio_awvalid !== 1'b0))) ||
          ((i_exp_class != 2'd2) && (o_mem_aw_route_class !== i_exp_class))) begin
        $error("FAIL AW %s: cfg=%b err=%b class=%0d mem_valid=%b mmio_valid=%b", i_name, w_aw_config_valid, w_aw_access_err, o_mem_aw_route_class, o_mem_awvalid, o_mmio_awvalid);
        $fatal(1);
      end
      i_rst_n_cluster = 1'b0;
      @(negedge i_clk_cluster);
    end
  endtask

  task automatic check_ar_route(input logic [63:0] i_addr, input logic [1:0] i_exp_class, input string i_name);
    begin
      @(negedge i_clk_cluster);
      i_rst_n_cluster = 1'b0;
      clear_requests();
      repeat (2) @(negedge i_clk_cluster);
      i_araddr = i_addr;
      i_arvalid = 1'b1;
      i_rst_n_cluster = 1'b1;
      repeat (3) @(negedge i_clk_cluster);
      #1;
      if ((w_ar_config_valid !== 1'b1) || (w_ar_access_err !== 1'b0) ||
          ((i_exp_class == 2'd2) && ((o_mmio_arvalid !== 1'b1) || (o_mem_arvalid !== 1'b0))) ||
          ((i_exp_class != 2'd2) && ((o_mem_arvalid !== 1'b1) || (o_mmio_arvalid !== 1'b0))) ||
          ((i_exp_class != 2'd2) && (o_mem_ar_route_class !== i_exp_class))) begin
        $error("FAIL AR %s: cfg=%b err=%b class=%0d mem_valid=%b mmio_valid=%b", i_name, w_ar_config_valid, w_ar_access_err, o_mem_ar_route_class, o_mem_arvalid, o_mmio_arvalid);
        $fatal(1);
      end
      i_rst_n_cluster = 1'b0;
      @(negedge i_clk_cluster);
    end
  endtask

  initial begin
    i_awid = '0;
    i_awatop = '0;
    i_awaddr = '0;
    i_awlen = '0;
    i_awsize = '0;
    i_awburst = '0;
    i_awlock = '0;
    i_awcache = '0;
    i_awprot = '0;
    i_awqos = '0;
    i_awregion = '0;
    i_awvalid = '0;
    i_wdata = '0;
    i_wstrb = '0;
    i_wlast = '0;
    i_wvalid = '0;
    i_bready = '0;
    i_arid = '0;
    i_araddr = '0;
    i_arlen = '0;
    i_arsize = '0;
    i_arburst = '0;
    i_arlock = '0;
    i_arcache = '0;
    i_arprot = '0;
    i_arqos = '0;
    i_arregion = '0;
    i_arvalid = '0;
    i_rready = '0;
    i_mem_awready = '0;
    i_mem_wready = '0;
    i_mem_bid = '0;
    i_mem_bresp = '0;
    i_mem_bvalid = '0;
    i_mem_arready = '0;
    i_mem_rid = '0;
    i_mem_rdata = '0;
    i_mem_rresp = '0;
    i_mem_rlast = '0;
    i_mem_rvalid = '0;
    i_mmio_awready = '0;
    i_mmio_wready = '0;
    i_mmio_bid = '0;
    i_mmio_bresp = '0;
    i_mmio_bvalid = '0;
    i_mmio_arready = '0;
    i_mmio_rid = '0;
    i_mmio_rdata = '0;
    i_mmio_rresp = '0;
    i_mmio_rlast = '0;
    i_mmio_rvalid = '0;
    i_clk_cluster = 1'b0;
    i_rst_n_cluster = 1'b0;
    repeat (3) @(negedge i_clk_cluster);
    i_rst_n_cluster = 1'b1;
    repeat (2) @(negedge i_clk_cluster);
    check_aw_route(64'h0000_0000_8000_0000, 2'd0, "cacheable");
    check_aw_route(64'h0000_0000_4000_0010, 2'd1, "normal uncached");
    check_aw_route(64'h0000_0000_6000_0000, 2'd2, "MMIO");
    check_ar_route(64'h0000_0000_8000_0000, 2'd0, "cacheable");
    check_ar_route(64'h0000_0000_4000_0010, 2'd1, "normal uncached");
    check_ar_route(64'h0000_0000_6000_0000, 2'd2, "MMIO");
    $display("PASS: shared region classifier drives cacheable, uncached, and MMIO AXI routes");
    $finish;
  end
endmodule
