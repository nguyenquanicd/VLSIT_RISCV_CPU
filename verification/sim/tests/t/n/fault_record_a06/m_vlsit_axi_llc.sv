/*
 * Project      : VLSIT RISC-V CPU Cluster
 * Author       : Quan Nguyen (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-15
 * Description  : Binds fixed-width cluster AXI and RegBus signals to the pinned PULP LLC.
 * Reuse        : Instantiates axi_llc_reg_wrap without changing its upstream RTL or license.
 * Status       : CPU AXI and software service wrapper only; per-line CMO is not yet integrated.
 * 2026-11-15 - Quan Nguyen and Codex - VLSI Technology page:
 *              Route retained LLC writeback fault to cluster status/interrupt.
 */
`timescale 1ns/1ps
`include "axi/typedef.svh"
`include "register_interface/typedef.svh"

module m_vlsit_axi_llc #(
  // Parameter Description: static LLC associativity.
  // Parameter values: 1 through 32; default is 4.
  // Parameter unit: ways.
  parameter logic [31:0] PARA_LLC_WAY_NUM = 32'd4,
  // Parameter Description: number of cache lines in each LLC way.
  // Parameter values: a power of two greater than 2; default is 4096.
  // Parameter unit: lines per way.
  parameter logic [31:0] PARA_LLC_NO_LINES = 32'd4096,
  // Parameter Description: number of 64-bit blocks in each LLC line.
  // Parameter values: a power of two of at least 2; default is 2.
  // Parameter unit: blocks.
  parameter logic [31:0] PARA_LLC_BLOCK_NUM = 32'd2,
  localparam logic [31:0] LPARA_AXI_ADDR_W = 32'd64,
  localparam logic [31:0] LPARA_AXI_DATA_W = 32'd64,
  localparam logic [31:0] LPARA_AXI_SLAVE_ID_W = 32'd6,
  localparam logic [31:0] LPARA_AXI_MASTER_ID_W = 32'd7,
  localparam logic [31:0] LPARA_AXI_USER_W = 32'd1,
  localparam logic [31:0] LPARA_REG_ADDR_W = 32'd7,
  localparam logic [31:0] LPARA_REG_DATA_W = 32'd32,
  localparam logic [31:0] LPARA_REG_STRB_W = 32'd4,
  localparam logic [31:0] LPARA_AXI_ID_LOOKUP_BITS = 32'd4,
  localparam logic [31:0] LPARA_AXI_LEN_W = 32'd8,
  localparam logic [31:0] LPARA_AXI_SIZE_W = 32'd3,
  localparam logic [31:0] LPARA_AXI_BURST_W = 32'd2,
  localparam logic [31:0] LPARA_AXI_CACHE_W = 32'd4,
  localparam logic [31:0] LPARA_AXI_PROT_W = 32'd3,
  localparam logic [31:0] LPARA_AXI_QOS_W = 32'd4,
  localparam logic [31:0] LPARA_AXI_REGION_W = 32'd4,
  localparam logic [31:0] LPARA_AXI_ATOP_W = 32'd6,
  localparam logic [31:0] LPARA_AXI_RESP_W = 32'd2,
  localparam logic [31:0] LPARA_AXI_LAST_W = 32'd1,
  localparam logic [31:0] LPARA_AXI_VALID_W = 32'd1,
  localparam logic [31:0] LPARA_AXI_READY_W = 32'd1,
  localparam logic [31:0] LPARA_AXI_CHANNEL_NUM = 32'd3,
  localparam logic [31:0] LPARA_AXI_VALID_CHANNEL_NUM = 32'd2,
  localparam logic [31:0] LPARA_AXI_BYTE_W = 32'd8,
  localparam logic [31:0] LPARA_EVENT_NUM_BYTES_W = 32'd16,
  // Packed channel widths and offsets used by the flattened AXI adapter.
  localparam logic [31:0] LPARA_SLV_R_W = 32'd74,
  localparam logic [31:0] LPARA_SLV_B_W = 32'd9,
  localparam logic [31:0] LPARA_MST_AR_W = 32'd101,
  localparam logic [31:0] LPARA_MST_W_W = 32'd74,
  localparam logic [31:0] LPARA_MST_AW_W = 32'd107,
  localparam logic [31:0] LPARA_SLV_RESP_W = LPARA_SLV_R_W + LPARA_SLV_B_W +
                                               (LPARA_AXI_CHANNEL_NUM * LPARA_AXI_READY_W) +
                                               (LPARA_AXI_VALID_CHANNEL_NUM * LPARA_AXI_VALID_W),
  localparam logic [31:0] LPARA_MST_REQ_W = LPARA_MST_AR_W + LPARA_MST_W_W + LPARA_MST_AW_W +
                                              (LPARA_AXI_CHANNEL_NUM * LPARA_AXI_VALID_W) +
                                              ((LPARA_AXI_CHANNEL_NUM - LPARA_AXI_VALID_W) * LPARA_AXI_READY_W),
  localparam logic [31:0] LPARA_REG_RSP_W = 32'd34,
  localparam logic [31:0] LPARA_REG_RSP_CTRL_W = LPARA_AXI_READY_W + LPARA_AXI_VALID_W,
  localparam logic [31:0] LPARA_EVENT_W = LPARA_EVENT_NUM_BYTES_W + LPARA_AXI_VALID_W,
  localparam logic [31:0] LPARA_LLC_EVENT_NUM = 32'd24,
  localparam logic [31:0] LPARA_LLC_FLAG_NUM = 32'd4,
  localparam logic [31:0] LPARA_LLC_EVENT_OUTPUT_NUM = LPARA_LLC_EVENT_NUM + LPARA_LLC_FLAG_NUM,
  localparam logic [31:0] LPARA_LLC_FLAG_OFFSET_1 = 32'd1,
  localparam logic [31:0] LPARA_LLC_FLAG_OFFSET_2 = 32'd2,
  localparam logic [31:0] LPARA_AXI_LLC_EVENTS_W = (LPARA_LLC_EVENT_NUM * LPARA_EVENT_W) + LPARA_LLC_FLAG_NUM,
  localparam logic [31:0] LPARA_MST_REQ_AR_LSB = 32'd2,
  localparam logic [31:0] LPARA_MST_REQ_BRDY_BIT = 32'd103,
  localparam logic [31:0] LPARA_MST_REQ_WVLD_BIT = 32'd104,
  localparam logic [31:0] LPARA_MST_REQ_W_LSB = 32'd105,
  localparam logic [31:0] LPARA_MST_REQ_AWVLD_BIT = 32'd179,
  localparam logic [31:0] LPARA_MST_REQ_AW_LSB = 32'd180,
  localparam logic [31:0] LPARA_AW_ATOP_LSB = 32'd1,
  localparam logic [31:0] LPARA_AW_REGION_LSB = 32'd7,
  localparam logic [31:0] LPARA_AW_QOS_LSB = 32'd11,
  localparam logic [31:0] LPARA_AW_PROT_LSB = 32'd15,
  localparam logic [31:0] LPARA_AW_CACHE_LSB = 32'd18,
  localparam logic [31:0] LPARA_AW_LOCK_LSB = 32'd22,
  localparam logic [31:0] LPARA_AW_BURST_LSB = 32'd23,
  localparam logic [31:0] LPARA_AW_SIZE_LSB = 32'd25,
  localparam logic [31:0] LPARA_AW_LEN_LSB = 32'd28,
  localparam logic [31:0] LPARA_AW_ADDR_LSB = 32'd36,
  localparam logic [31:0] LPARA_AW_ID_LSB = 32'd100,
  localparam logic [31:0] LPARA_AR_REGION_LSB = 32'd1,
  localparam logic [31:0] LPARA_AR_QOS_LSB = 32'd5,
  localparam logic [31:0] LPARA_AR_PROT_LSB = 32'd9,
  localparam logic [31:0] LPARA_AR_CACHE_LSB = 32'd12,
  localparam logic [31:0] LPARA_AR_LOCK_LSB = 32'd16,
  localparam logic [31:0] LPARA_AR_BURST_LSB = 32'd17,
  localparam logic [31:0] LPARA_AR_SIZE_LSB = 32'd19,
  localparam logic [31:0] LPARA_AR_LEN_LSB = 32'd22,
  localparam logic [31:0] LPARA_AR_ADDR_LSB = 32'd30,
  localparam logic [31:0] LPARA_AR_ID_LSB = 32'd94,
  localparam logic [31:0] LPARA_W_LAST_LSB = LPARA_AXI_USER_W,
  localparam logic [31:0] LPARA_W_STRB_LSB = LPARA_W_LAST_LSB + LPARA_AXI_LAST_W,
  localparam logic [31:0] LPARA_W_DATA_LSB = LPARA_W_STRB_LSB + LPARA_AXI_DATA_W/LPARA_AXI_BYTE_W,
  localparam logic [31:0] LPARA_R_LAST_LSB = LPARA_AXI_USER_W,
  localparam logic [31:0] LPARA_R_RESP_LSB = LPARA_R_LAST_LSB + LPARA_AXI_LAST_W,
  localparam logic [31:0] LPARA_R_DATA_LSB = LPARA_R_RESP_LSB + LPARA_AXI_RESP_W,
  localparam logic [31:0] LPARA_R_ID_LSB = LPARA_R_DATA_LSB + LPARA_AXI_DATA_W,
  localparam logic [31:0] LPARA_B_RESP_LSB = LPARA_AXI_USER_W,
  localparam logic [31:0] LPARA_B_ID_LSB = LPARA_B_RESP_LSB + LPARA_AXI_RESP_W,
  localparam logic [31:0] LPARA_SLV_RESP_R_LSB = 32'd0,
  localparam logic [31:0] LPARA_SLV_RESP_RVLD_BIT = 32'd74,
  localparam logic [31:0] LPARA_SLV_RESP_B_LSB = 32'd75,
  localparam logic [31:0] LPARA_SLV_RESP_BVLD_BIT = 32'd84,
  localparam logic [31:0] LPARA_SLV_RESP_W_RDY_BIT = 32'd85,
  localparam logic [31:0] LPARA_SLV_RESP_AR_RDY_BIT = 32'd86,
  localparam logic [31:0] LPARA_SLV_RESP_AW_RDY_BIT = 32'd87
) (
  // Clock, reset, and test control
  input  wire         i_clk_cluster,
  input  wire         i_rst_n_cluster,
  input  wire         i_test_en,

  // Cached physical-address range; end address follows the PULP LLC exclusive-end convention
  input  wire  [63:0] i_cached_start_addr,
  input  wire  [63:0] i_cached_end_addr,

  // AXI4+ATOP slave request from the cluster memory mux
  input  wire  [5:0]  i_axi_cpu_awid,
  input  wire  [5:0]  i_axi_cpu_awatop,
  input  wire  [63:0] i_axi_cpu_awaddr,
  input  wire  [7:0]  i_axi_cpu_awlen,
  input  wire  [2:0]  i_axi_cpu_awsize,
  input  wire  [1:0]  i_axi_cpu_awburst,
  input  wire         i_axi_cpu_awlock,
  input  wire  [3:0]  i_axi_cpu_awcache,
  input  wire  [2:0]  i_axi_cpu_awprot,
  input  wire  [3:0]  i_axi_cpu_awqos,
  input  wire  [3:0]  i_axi_cpu_awregion,
  input  wire         i_axi_cpu_awvalid,
  output logic        o_axi_cpu_awready,
  input  wire  [63:0] i_axi_cpu_wdata,
  input  wire  [7:0]  i_axi_cpu_wstrb,
  input  wire         i_axi_cpu_wlast,
  input  wire         i_axi_cpu_wvalid,
  output logic        o_axi_cpu_wready,
  output logic [5:0]  o_axi_cpu_bid,
  output logic [1:0]  o_axi_cpu_bresp,
  output logic        o_axi_cpu_bvalid,
  input  wire         i_axi_cpu_bready,
  input  wire  [5:0]  i_axi_cpu_arid,
  input  wire  [63:0] i_axi_cpu_araddr,
  input  wire  [7:0]  i_axi_cpu_arlen,
  input  wire  [2:0]  i_axi_cpu_arsize,
  input  wire  [1:0]  i_axi_cpu_arburst,
  input  wire         i_axi_cpu_arlock,
  input  wire  [3:0]  i_axi_cpu_arcache,
  input  wire  [2:0]  i_axi_cpu_arprot,
  input  wire  [3:0]  i_axi_cpu_arqos,
  input  wire  [3:0]  i_axi_cpu_arregion,
  input  wire         i_axi_cpu_arvalid,
  output logic        o_axi_cpu_arready,
  output logic [5:0]  o_axi_cpu_rid,
  output logic [63:0] o_axi_cpu_rdata,
  output logic [1:0]  o_axi_cpu_rresp,
  output logic        o_axi_cpu_rlast,
  output logic        o_axi_cpu_rvalid,
  input  wire         i_axi_cpu_rready,

  // AXI4+ATOP master interface to external memory
  output logic [6:0]  o_axi_mem_awid,
  output logic [5:0]  o_axi_mem_awatop,
  output logic [63:0] o_axi_mem_awaddr,
  output logic [7:0]  o_axi_mem_awlen,
  output logic [2:0]  o_axi_mem_awsize,
  output logic [1:0]  o_axi_mem_awburst,
  output logic        o_axi_mem_awlock,
  output logic [3:0]  o_axi_mem_awcache,
  output logic [2:0]  o_axi_mem_awprot,
  output logic [3:0]  o_axi_mem_awqos,
  output logic [3:0]  o_axi_mem_awregion,
  output logic        o_axi_mem_awvalid,
  input  wire         i_axi_mem_awready,
  output logic [63:0] o_axi_mem_wdata,
  output logic [7:0]  o_axi_mem_wstrb,
  output logic        o_axi_mem_wlast,
  output logic        o_axi_mem_wvalid,
  input  wire         i_axi_mem_wready,
  input  wire  [6:0]  i_axi_mem_bid,
  input  wire  [1:0]  i_axi_mem_bresp,
  input  wire         i_axi_mem_bvalid,
  output logic        o_axi_mem_bready,
  output logic [6:0]  o_axi_mem_arid,
  output logic [63:0] o_axi_mem_araddr,
  output logic [7:0]  o_axi_mem_arlen,
  output logic [2:0]  o_axi_mem_arsize,
  output logic [1:0]  o_axi_mem_arburst,
  output logic        o_axi_mem_arlock,
  output logic [3:0]  o_axi_mem_arcache,
  output logic [2:0]  o_axi_mem_arprot,
  output logic [3:0]  o_axi_mem_arqos,
  output logic [3:0]  o_axi_mem_arregion,
  output logic        o_axi_mem_arvalid,
  input  wire         i_axi_mem_arready,
  input  wire  [6:0]  i_axi_mem_rid,
  input  wire  [63:0] i_axi_mem_rdata,
  input  wire  [1:0]  i_axi_mem_rresp,
  input  wire         i_axi_mem_rlast,
  input  wire         i_axi_mem_rvalid,
  output logic        o_axi_mem_rready,

  // Per-line maintenance command and terminal completion.
  input  wire         i_maint_valid,
  output logic        o_maint_ready,
  input  wire  [1:0]  i_maint_op,
  input  wire  [51:0] i_maint_pa_line,
  output logic        o_maint_done,
  output logic        o_maint_error,

  // LLC service RegBus interface from the AXI4-Lite bridge
  input  wire         i_reg_req_valid,
  input  wire         i_reg_req_wr,
  input  wire  [6:0]  i_reg_req_addr,
  input  wire  [31:0] i_reg_req_wdata,
  input  wire  [3:0]  i_reg_req_wstrb,
  output logic        o_reg_rsp_ready,
  output logic [31:0] o_reg_rsp_rdata,
  output logic        o_reg_rsp_err,

  // LLC performance events for PMU mapping
  output logic        o_wb_fault,
  output logic        o_wb_fault_event,
  output logic [63:0] o_wb_fault_addr,
  output logic [1:0]  o_wb_fault_resp,
  output logic [27:0] o_llc_events
);
  // Verification-only AXI subordinate B-response fault model. No internal force.
  // TEST-050: delay native B; inject one ordinary-eviction error per hart.
  // Failure-history belongs to the BFM and persists over DUT reset so recovery
  // boots run without a repeated injected fault. No DUT state is forced.
  int inject_error;
  int llc_mode=0;
  initial void'($value$plusargs("LLC_MODE=%d",llc_mode));
  logic first_error_valid=0;logic [63:0] first_error_addr;logic [1:0] first_error_hart;
  logic [63:0] addr_by_id [64];
  initial if (!$value$plusargs("INJECT_ERROR=%d",inject_error)) inject_error=0;
  logic [63:0] fail_by_id;
  logic [3:0] failed_hart = '0;
  logic [1:0] hart_by_id [64];
  logic [1:0] native_bresp;
  logic [5:0] native_bid;
  int reverse_order=0, fault_harts=4;
  initial begin
    void'($value$plusargs("REVERSE=%d",reverse_order));
    void'($value$plusargs("FAULT_HARTS=%d",fault_harts));
  end
  logic [3:0] queued=0;
  logic [3:0][5:0] queued_id;
  logic reorder_draining=0;
  logic [1:0] reorder_pick;
  wire [3:0] active_fault_mask=fault_harts==2?4'b0011:4'b1111;
  wire reorder_active=(reverse_order!=0) && (llc_mode==0) && ((failed_hart & active_fault_mask)!=active_fault_mask);
  // Only the first one-per-hart response batch is reordered. Different AXI
  // IDs may complete out of order; each ID retains its single transaction.
  always_comb begin
    reorder_pick=0;
    for(int h=0;h<4;h++) if(queued[h])reorder_pick=2'(h);
  end
  always @(posedge i_clk_cluster) begin
    if(!i_rst_n_cluster)begin queued<=0;reorder_draining<=0;queued_id<=0;end
    else if(reorder_active)begin
      if(native_bvalid && native_bready)begin
        if(queued[native_bid[5:4]] || int'(native_bid[5:4])>=fault_harts)$fatal(1,"illegal first-response reorder batch");
        queued[native_bid[5:4]]<=1;queued_id[native_bid[5:4]]<=native_bid;
      end
      if((queued & active_fault_mask)==active_fault_mask)reorder_draining<=1;
      if(o_axi_cpu_bvalid && i_axi_cpu_bready)queued[reorder_pick]<=0;
    end
  end
  logic native_bvalid, native_bready;
  int b_delay;
  always_ff @(posedge i_clk_cluster) begin
    if(!i_rst_n_cluster) begin fail_by_id <= '0; b_delay<=0; end
    else begin
      if((reorder_active?reorder_draining:native_bvalid) && b_delay<96) b_delay<=b_delay+1;
      if(o_axi_cpu_bvalid && i_axi_cpu_bready) begin
        b_delay<=0;
        if(fail_by_id[o_axi_cpu_bid] && !first_error_valid) begin
          first_error_valid<=1;first_error_addr<=addr_by_id[o_axi_cpu_bid];first_error_hart<=hart_by_id[o_axi_cpu_bid];
        end
        if(fail_by_id[o_axi_cpu_bid]) failed_hart[hart_by_id[o_axi_cpu_bid]] <= 1;
        fail_by_id[o_axi_cpu_bid] <= 0;
      end
      if(i_axi_cpu_awvalid && o_axi_cpu_awready) begin
        hart_by_id[i_axi_cpu_awid] <= i_axi_cpu_awaddr[5:4];
        addr_by_id[i_axi_cpu_awid] <= i_axi_cpu_awaddr;
        fail_by_id[i_axi_cpu_awid] <= (inject_error!=0) && (llc_mode==0) &&
          !failed_hart[i_axi_cpu_awaddr[5:4]];
      end
    end
  end
  assign o_axi_cpu_bid = reorder_active ? queued_id[reorder_pick] : native_bid;
  assign o_axi_cpu_bresp = fail_by_id[o_axi_cpu_bid] ? 2'(inject_error) : native_bresp;
  assign o_axi_cpu_bvalid = (reorder_active ? (reorder_draining && (|queued)) : native_bvalid) && b_delay>=96;
  assign native_bready = reorder_active ? (!reorder_draining && !queued[native_bid[5:4]]) : (i_axi_cpu_bready && b_delay>=96);
  m_vlsit_axi_llc_native #(
    .PARA_LLC_WAY_NUM(PARA_LLC_WAY_NUM), .PARA_LLC_NO_LINES(PARA_LLC_NO_LINES),
    .PARA_LLC_BLOCK_NUM(PARA_LLC_BLOCK_NUM)
  ) u_native (
    .i_clk_cluster(i_clk_cluster),
    .i_rst_n_cluster(i_rst_n_cluster),
    .i_test_en(i_test_en),
    .i_cached_start_addr(i_cached_start_addr),
    .i_cached_end_addr(i_cached_end_addr),
    .i_axi_cpu_awid(i_axi_cpu_awid),
    .i_axi_cpu_awatop(i_axi_cpu_awatop),
    .i_axi_cpu_awaddr(i_axi_cpu_awaddr),
    .i_axi_cpu_awlen(i_axi_cpu_awlen),
    .i_axi_cpu_awsize(i_axi_cpu_awsize),
    .i_axi_cpu_awburst(i_axi_cpu_awburst),
    .i_axi_cpu_awlock(i_axi_cpu_awlock),
    .i_axi_cpu_awcache(i_axi_cpu_awcache),
    .i_axi_cpu_awprot(i_axi_cpu_awprot),
    .i_axi_cpu_awqos(i_axi_cpu_awqos),
    .i_axi_cpu_awregion(i_axi_cpu_awregion),
    .i_axi_cpu_awvalid(i_axi_cpu_awvalid),
    .o_axi_cpu_awready(o_axi_cpu_awready),
    .i_axi_cpu_wdata(i_axi_cpu_wdata),
    .i_axi_cpu_wstrb(i_axi_cpu_wstrb),
    .i_axi_cpu_wlast(i_axi_cpu_wlast),
    .i_axi_cpu_wvalid(i_axi_cpu_wvalid),
    .o_axi_cpu_wready(o_axi_cpu_wready),
    .o_axi_cpu_bid(native_bid),
    .o_axi_cpu_bresp(native_bresp),
    .o_axi_cpu_bvalid(native_bvalid),
    .i_axi_cpu_bready(native_bready),
    .i_axi_cpu_arid(i_axi_cpu_arid),
    .i_axi_cpu_araddr(i_axi_cpu_araddr),
    .i_axi_cpu_arlen(i_axi_cpu_arlen),
    .i_axi_cpu_arsize(i_axi_cpu_arsize),
    .i_axi_cpu_arburst(i_axi_cpu_arburst),
    .i_axi_cpu_arlock(i_axi_cpu_arlock),
    .i_axi_cpu_arcache(i_axi_cpu_arcache),
    .i_axi_cpu_arprot(i_axi_cpu_arprot),
    .i_axi_cpu_arqos(i_axi_cpu_arqos),
    .i_axi_cpu_arregion(i_axi_cpu_arregion),
    .i_axi_cpu_arvalid(i_axi_cpu_arvalid),
    .o_axi_cpu_arready(o_axi_cpu_arready),
    .o_axi_cpu_rid(o_axi_cpu_rid),
    .o_axi_cpu_rdata(o_axi_cpu_rdata),
    .o_axi_cpu_rresp(o_axi_cpu_rresp),
    .o_axi_cpu_rlast(o_axi_cpu_rlast),
    .o_axi_cpu_rvalid(o_axi_cpu_rvalid),
    .i_axi_cpu_rready(i_axi_cpu_rready),
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
    .o_axi_mem_rready(o_axi_mem_rready),
    .i_maint_valid(i_maint_valid),
    .o_maint_ready(o_maint_ready),
    .i_maint_op(i_maint_op),
    .i_maint_pa_line(i_maint_pa_line),
    .o_maint_done(o_maint_done),
    .o_maint_error(o_maint_error),
    .i_reg_req_valid(i_reg_req_valid),
    .i_reg_req_wr(i_reg_req_wr),
    .i_reg_req_addr(i_reg_req_addr),
    .i_reg_req_wdata(i_reg_req_wdata),
    .i_reg_req_wstrb(i_reg_req_wstrb),
    .o_reg_rsp_ready(o_reg_rsp_ready),
    .o_reg_rsp_rdata(o_reg_rsp_rdata),
    .o_reg_rsp_err(o_reg_rsp_err),
    .o_wb_fault(o_wb_fault),
    .o_wb_fault_event(o_wb_fault_event),
    .o_wb_fault_addr(o_wb_fault_addr),
    .o_wb_fault_resp(o_wb_fault_resp),
    .o_llc_events(o_llc_events)
  );

  // IHI0022 AXI4 channel encoding/alignment/stability checks; each must be exercised.
  int hit[20];
  int total_hit[20];
  logic aw_stall, w_stall, ar_stall, b_stall, r_stall;
  logic [63:0] aw_addr_q, ar_addr_q, w_data_q, r_data_q;
  logic [5:0] aw_id_q, ar_id_q, b_id_q, r_id_q;
  task automatic chk(input int id,input bit antecedent,input bit consequent);
    if(antecedent) begin
      hit[id]++;total_hit[id]++;
      if(!consequent) $fatal(1,"AXI-IHI0022 check %0d failed",id);
    end
  endtask
  always @(posedge i_clk_cluster) begin
    if(!i_rst_n_cluster) begin
      aw_stall=0; w_stall=0; ar_stall=0; b_stall=0; r_stall=0;
      foreach(hit[k]) hit[k]=0;
    end else begin
      chk(0,i_axi_cpu_awvalid,i_axi_cpu_awburst!=2'b11);
      chk(1,i_axi_cpu_awvalid,i_axi_cpu_awsize<=3);
      chk(2,i_axi_cpu_awvalid,i_axi_cpu_awaddr[2:0]==0);
      chk(3,i_axi_cpu_awvalid,({1'b0,i_axi_cpu_awaddr[11:0]}+((13'(i_axi_cpu_awlen)+1)<<i_axi_cpu_awsize))<=4096);
      chk(4,i_axi_cpu_awvalid,!aw_stall || (i_axi_cpu_awaddr==aw_addr_q && i_axi_cpu_awid==aw_id_q));
      chk(5,i_axi_cpu_wvalid,!w_stall || i_axi_cpu_wdata==w_data_q);
      chk(6,i_axi_cpu_wvalid,i_axi_cpu_wstrb!=0);
      chk(7,i_axi_cpu_wvalid,!$isunknown({i_axi_cpu_wdata,i_axi_cpu_wlast,i_axi_cpu_wstrb}));
      chk(8,o_axi_cpu_bvalid,o_axi_cpu_bresp inside {2'b00,2'b10,2'b11});
      chk(9,o_axi_cpu_bvalid,!b_stall || o_axi_cpu_bid==b_id_q);
      chk(10,i_axi_cpu_arvalid,i_axi_cpu_arburst!=2'b11);
      chk(11,i_axi_cpu_arvalid,i_axi_cpu_arsize<=3);
      chk(12,i_axi_cpu_arvalid,i_axi_cpu_araddr[2:0]==0);
      chk(13,i_axi_cpu_arvalid,({1'b0,i_axi_cpu_araddr[11:0]}+((13'(i_axi_cpu_arlen)+1)<<i_axi_cpu_arsize))<=4096);
      chk(14,i_axi_cpu_arvalid,!ar_stall || (i_axi_cpu_araddr==ar_addr_q && i_axi_cpu_arid==ar_id_q));
      chk(15,o_axi_cpu_rvalid,o_axi_cpu_rresp inside {2'b00,2'b10,2'b11});
      chk(16,o_axi_cpu_rvalid,!r_stall || (o_axi_cpu_rid==r_id_q && o_axi_cpu_rdata==r_data_q));
      chk(17,i_axi_cpu_awvalid,!$isunknown({i_axi_cpu_awaddr,i_axi_cpu_awid,i_axi_cpu_awlen}));
      chk(18,i_axi_cpu_arvalid,!$isunknown({i_axi_cpu_araddr,i_axi_cpu_arid,i_axi_cpu_arlen}));
      chk(19,o_axi_cpu_rvalid,!$isunknown({o_axi_cpu_rid,o_axi_cpu_rresp,o_axi_cpu_rlast}));
      aw_stall=i_axi_cpu_awvalid && !o_axi_cpu_awready; aw_addr_q=i_axi_cpu_awaddr; aw_id_q=i_axi_cpu_awid;
      w_stall=i_axi_cpu_wvalid && !o_axi_cpu_wready; w_data_q=i_axi_cpu_wdata;
      ar_stall=i_axi_cpu_arvalid && !o_axi_cpu_arready; ar_addr_q=i_axi_cpu_araddr; ar_id_q=i_axi_cpu_arid;
      b_stall=o_axi_cpu_bvalid && !i_axi_cpu_bready; b_id_q=o_axi_cpu_bid;
      r_stall=o_axi_cpu_rvalid && !i_axi_cpu_rready; r_id_q=o_axi_cpu_rid; r_data_q=o_axi_cpu_rdata;
    end
  end
  // Success case closes all assertion activation points; read-fault cases
  // have no legal AW/W traffic. All protocol assertions remain active.
  final begin
    foreach(hit[k]) begin
      $display("AXI-IHI0022 ASSERT %0d hits=%0d",k,total_hit[k]);
      if(total_hit[k]==0) $fatal(1,"unexercised AXI assertion %0d",k);
    end
  end
endmodule
