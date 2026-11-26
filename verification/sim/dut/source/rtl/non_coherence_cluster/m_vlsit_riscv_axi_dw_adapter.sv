/*
 * Project      : VLSIT RISC-V CPU Cluster
 * Author       : Quan Nguyen (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-14
 * Description  : Converts the 64-bit LLC AXI port to a configured memory-bus width.
 * Reuse        : Wraps the pinned PULP axi_dw_converter without modifying upstream RTL.
 */
`timescale 1ns/1ps
`include "axi/typedef.svh"

module m_vlsit_riscv_axi_dw_adapter #(
  // Parameter Description: external AXI memory data width.
  // Parameter values: 32, 64, 128, or 256; default is 64.
  // Parameter unit: bits.
  parameter logic [31:0] PARA_AXI_MEM_DATA_W = 32'd64,
  // Parameter Description: maximum read transactions tracked by the width converter.
  // Parameter values: 1 through 32; default is 8.
  // Parameter unit: transactions.
  parameter logic [31:0] PARA_AXI_MAX_READS = 32'd8,
  localparam logic [31:0] LPARA_AXI_ADDR_W = 32'd64,
  localparam logic [31:0] LPARA_AXI_ID_W = 32'd7,
  localparam logic [31:0] LPARA_AXI_LLC_DATA_W = 32'd64,
  localparam logic [31:0] LPARA_AXI_USER_W = 32'd1
) (
  // Clock and reset
  input  wire                               i_clk_cluster,
  input  wire                               i_rst_n_cluster,

  // Fixed 64-bit AXI4+ATOP port from the LLC.
  input  wire  [LPARA_AXI_ID_W-1:0]         i_axi_llc_awid,
  input  wire  [5:0]                        i_axi_llc_awatop,
  input  wire  [LPARA_AXI_ADDR_W-1:0]       i_axi_llc_awaddr,
  input  wire  [7:0]                        i_axi_llc_awlen,
  input  wire  [2:0]                        i_axi_llc_awsize,
  input  wire  [1:0]                        i_axi_llc_awburst,
  input  wire                               i_axi_llc_awlock,
  input  wire  [3:0]                        i_axi_llc_awcache,
  input  wire  [2:0]                        i_axi_llc_awprot,
  input  wire  [3:0]                        i_axi_llc_awqos,
  input  wire  [3:0]                        i_axi_llc_awregion,
  input  wire                               i_axi_llc_awvalid,
  output logic                              o_axi_llc_awready,
  input  wire  [LPARA_AXI_LLC_DATA_W-1:0]   i_axi_llc_wdata,
  input  wire  [LPARA_AXI_LLC_DATA_W/8-1:0] i_axi_llc_wstrb,
  input  wire                               i_axi_llc_wlast,
  input  wire                               i_axi_llc_wvalid,
  output logic                              o_axi_llc_wready,
  output logic [LPARA_AXI_ID_W-1:0]         o_axi_llc_bid,
  output logic [1:0]                        o_axi_llc_bresp,
  output logic                              o_axi_llc_bvalid,
  input  wire                               i_axi_llc_bready,
  input  wire  [LPARA_AXI_ID_W-1:0]         i_axi_llc_arid,
  input  wire  [LPARA_AXI_ADDR_W-1:0]       i_axi_llc_araddr,
  input  wire  [7:0]                        i_axi_llc_arlen,
  input  wire  [2:0]                        i_axi_llc_arsize,
  input  wire  [1:0]                        i_axi_llc_arburst,
  input  wire                               i_axi_llc_arlock,
  input  wire  [3:0]                        i_axi_llc_arcache,
  input  wire  [2:0]                        i_axi_llc_arprot,
  input  wire  [3:0]                        i_axi_llc_arqos,
  input  wire  [3:0]                        i_axi_llc_arregion,
  input  wire                               i_axi_llc_arvalid,
  output logic                              o_axi_llc_arready,
  output logic [LPARA_AXI_ID_W-1:0]         o_axi_llc_rid,
  output logic [LPARA_AXI_LLC_DATA_W-1:0]   o_axi_llc_rdata,
  output logic [1:0]                        o_axi_llc_rresp,
  output logic                              o_axi_llc_rlast,
  output logic                              o_axi_llc_rvalid,
  input  wire                               i_axi_llc_rready,

  // Parameter-width AXI4+ATOP port toward external memory.
  output logic [LPARA_AXI_ID_W-1:0]         o_axi_mem_awid,
  output logic [5:0]                        o_axi_mem_awatop,
  output logic [LPARA_AXI_ADDR_W-1:0]       o_axi_mem_awaddr,
  output logic [7:0]                        o_axi_mem_awlen,
  output logic [2:0]                        o_axi_mem_awsize,
  output logic [1:0]                        o_axi_mem_awburst,
  output logic                              o_axi_mem_awlock,
  output logic [3:0]                        o_axi_mem_awcache,
  output logic [2:0]                        o_axi_mem_awprot,
  output logic [3:0]                        o_axi_mem_awqos,
  output logic [3:0]                        o_axi_mem_awregion,
  output logic                              o_axi_mem_awvalid,
  input  wire                               i_axi_mem_awready,
  output logic [PARA_AXI_MEM_DATA_W-1:0]    o_axi_mem_wdata,
  output logic [PARA_AXI_MEM_DATA_W/8-1:0]  o_axi_mem_wstrb,
  output logic                              o_axi_mem_wlast,
  output logic                              o_axi_mem_wvalid,
  input  wire                               i_axi_mem_wready,
  input  wire  [LPARA_AXI_ID_W-1:0]         i_axi_mem_bid,
  input  wire  [1:0]                        i_axi_mem_bresp,
  input  wire                               i_axi_mem_bvalid,
  output logic                              o_axi_mem_bready,
  output logic [LPARA_AXI_ID_W-1:0]         o_axi_mem_arid,
  output logic [LPARA_AXI_ADDR_W-1:0]       o_axi_mem_araddr,
  output logic [7:0]                        o_axi_mem_arlen,
  output logic [2:0]                        o_axi_mem_arsize,
  output logic [1:0]                        o_axi_mem_arburst,
  output logic                              o_axi_mem_arlock,
  output logic [3:0]                        o_axi_mem_arcache,
  output logic [2:0]                        o_axi_mem_arprot,
  output logic [3:0]                        o_axi_mem_arqos,
  output logic [3:0]                        o_axi_mem_arregion,
  output logic                              o_axi_mem_arvalid,
  input  wire                               i_axi_mem_arready,
  input  wire  [LPARA_AXI_ID_W-1:0]         i_axi_mem_rid,
  input  wire  [PARA_AXI_MEM_DATA_W-1:0]    i_axi_mem_rdata,
  input  wire  [1:0]                        i_axi_mem_rresp,
  input  wire                               i_axi_mem_rlast,
  input  wire                               i_axi_mem_rvalid,
  output logic                              o_axi_mem_rready
);

  typedef logic [LPARA_AXI_ADDR_W-1:0] axi_addr_type_def;
  typedef logic [LPARA_AXI_ID_W-1:0] axi_id_type_def;
  typedef logic [LPARA_AXI_LLC_DATA_W-1:0] axi_llc_data_type_def;
  typedef logic [PARA_AXI_MEM_DATA_W-1:0] axi_mem_data_type_def;
  typedef logic [LPARA_AXI_LLC_DATA_W/8-1:0] axi_llc_strb_type_def;
  typedef logic [PARA_AXI_MEM_DATA_W/8-1:0] axi_mem_strb_type_def;
  typedef logic [LPARA_AXI_USER_W-1:0] axi_user_type_def;

  `AXI_TYPEDEF_AW_CHAN_T(axi_aw_chan_type_def, axi_addr_type_def, axi_id_type_def, axi_user_type_def)
  `AXI_TYPEDEF_W_CHAN_T(axi_llc_w_chan_type_def, axi_llc_data_type_def, axi_llc_strb_type_def, axi_user_type_def)
  `AXI_TYPEDEF_W_CHAN_T(axi_mem_w_chan_type_def, axi_mem_data_type_def, axi_mem_strb_type_def, axi_user_type_def)
  `AXI_TYPEDEF_B_CHAN_T(axi_b_chan_type_def, axi_id_type_def, axi_user_type_def)
  `AXI_TYPEDEF_AR_CHAN_T(axi_ar_chan_type_def, axi_addr_type_def, axi_id_type_def, axi_user_type_def)
  `AXI_TYPEDEF_R_CHAN_T(axi_llc_r_chan_type_def, axi_llc_data_type_def, axi_id_type_def, axi_user_type_def)
  `AXI_TYPEDEF_R_CHAN_T(axi_mem_r_chan_type_def, axi_mem_data_type_def, axi_id_type_def, axi_user_type_def)
  `AXI_TYPEDEF_REQ_T(axi_llc_req_type_def, axi_aw_chan_type_def, axi_llc_w_chan_type_def, axi_ar_chan_type_def)
  `AXI_TYPEDEF_RESP_T(axi_llc_resp_type_def, axi_b_chan_type_def, axi_llc_r_chan_type_def)
  `AXI_TYPEDEF_REQ_T(axi_mem_req_type_def, axi_aw_chan_type_def, axi_mem_w_chan_type_def, axi_ar_chan_type_def)
  `AXI_TYPEDEF_RESP_T(axi_mem_resp_type_def, axi_b_chan_type_def, axi_mem_r_chan_type_def)

  axi_llc_req_type_def w_axi_llc_req;
  axi_llc_resp_type_def w_axi_llc_resp;
  axi_mem_req_type_def w_axi_mem_req;
  axi_mem_resp_type_def w_axi_mem_resp;
  logic w_axi_llc_b_user;
  logic w_axi_llc_r_user;
  logic w_axi_mem_aw_user;
  logic w_axi_mem_w_user;
  logic w_axi_mem_ar_user;

  // Pack flat LLC ports into the upstream AXI request record.
  assign w_axi_llc_req = {
    {i_axi_llc_awid, i_axi_llc_awaddr, i_axi_llc_awlen, i_axi_llc_awsize,
     i_axi_llc_awburst, i_axi_llc_awlock, i_axi_llc_awcache, i_axi_llc_awprot,
     i_axi_llc_awqos, i_axi_llc_awregion, i_axi_llc_awatop, 1'b0},
    i_axi_llc_awvalid,
    {i_axi_llc_wdata, i_axi_llc_wstrb, i_axi_llc_wlast, 1'b0},
    i_axi_llc_wvalid,
    i_axi_llc_bready,
    {i_axi_llc_arid, i_axi_llc_araddr, i_axi_llc_arlen, i_axi_llc_arsize,
     i_axi_llc_arburst, i_axi_llc_arlock, i_axi_llc_arcache, i_axi_llc_arprot,
     i_axi_llc_arqos, i_axi_llc_arregion, 1'b0},
    i_axi_llc_arvalid,
    i_axi_llc_rready
  };

  // Pack external memory responses into the converter's downstream record.
  assign w_axi_mem_resp = {
    i_axi_mem_awready,
    i_axi_mem_arready,
    i_axi_mem_wready,
    i_axi_mem_bvalid,
    {i_axi_mem_bid, i_axi_mem_bresp, 1'b0},
    i_axi_mem_rvalid,
    {i_axi_mem_rid, i_axi_mem_rdata, i_axi_mem_rresp, i_axi_mem_rlast, 1'b0}
  };

  // Return converted LLC-side responses and unpack external memory requests.
  assign {
    o_axi_llc_awready,
    o_axi_llc_arready,
    o_axi_llc_wready,
    o_axi_llc_bvalid,
    {o_axi_llc_bid, o_axi_llc_bresp, w_axi_llc_b_user},
    o_axi_llc_rvalid,
    {o_axi_llc_rid, o_axi_llc_rdata, o_axi_llc_rresp, o_axi_llc_rlast, w_axi_llc_r_user}
  } = w_axi_llc_resp;
  // Drive converted output data, sidebands and handshakes to external memory.
  assign {
    o_axi_mem_awid, o_axi_mem_awaddr, o_axi_mem_awlen, o_axi_mem_awsize,
    o_axi_mem_awburst, o_axi_mem_awlock, o_axi_mem_awcache, o_axi_mem_awprot,
    o_axi_mem_awqos, o_axi_mem_awregion, o_axi_mem_awatop, w_axi_mem_aw_user,
    o_axi_mem_awvalid,
    o_axi_mem_wdata, o_axi_mem_wstrb, o_axi_mem_wlast, w_axi_mem_w_user,
    o_axi_mem_wvalid, o_axi_mem_bready,
    o_axi_mem_arid, o_axi_mem_araddr, o_axi_mem_arlen, o_axi_mem_arsize,
    o_axi_mem_arburst, o_axi_mem_arlock, o_axi_mem_arcache, o_axi_mem_arprot,
    o_axi_mem_arqos, o_axi_mem_arregion, w_axi_mem_ar_user, o_axi_mem_arvalid,
    o_axi_mem_rready
  } = w_axi_mem_req;

  axi_dw_converter #(
    .AxiMaxReads(PARA_AXI_MAX_READS),
    .AxiSlvPortDataWidth(LPARA_AXI_LLC_DATA_W),
    .AxiMstPortDataWidth(PARA_AXI_MEM_DATA_W),
    .AxiAddrWidth(LPARA_AXI_ADDR_W),
    .AxiIdWidth(LPARA_AXI_ID_W),
    .aw_chan_t(axi_aw_chan_type_def),
    .mst_w_chan_t(axi_mem_w_chan_type_def),
    .slv_w_chan_t(axi_llc_w_chan_type_def),
    .b_chan_t(axi_b_chan_type_def),
    .ar_chan_t(axi_ar_chan_type_def),
    .mst_r_chan_t(axi_mem_r_chan_type_def),
    .slv_r_chan_t(axi_llc_r_chan_type_def),
    .axi_mst_req_t(axi_mem_req_type_def),
    .axi_mst_resp_t(axi_mem_resp_type_def),
    .axi_slv_req_t(axi_llc_req_type_def),
    .axi_slv_resp_t(axi_llc_resp_type_def)
  ) u_dont_touch_axi_dw_converter (
    .clk_i(i_clk_cluster),
    .rst_ni(i_rst_n_cluster),
    .slv_req_i(w_axi_llc_req),
    .slv_resp_o(w_axi_llc_resp),
    .mst_req_o(w_axi_mem_req),
    .mst_resp_i(w_axi_mem_resp)
  );

endmodule
