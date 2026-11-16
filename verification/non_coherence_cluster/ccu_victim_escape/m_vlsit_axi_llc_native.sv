/*
 * Project      : VLSIT RISC-V CPU Cluster
 * Author       : Quan Nguyen (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-15
 * Change History: 2026-11-16 - Quan Nguyen and Codex - VLSI Technology page:
 *   DEC-039/040: expose matched fatal writeback event/address/raw BRESP.
 * Description  : Binds fixed-width cluster AXI and RegBus signals to the pinned PULP LLC.
 * Reuse        : Instantiates axi_llc_reg_wrap without changing its upstream RTL or license.
 * Status       : CPU AXI and software service wrapper only; per-line CMO is not yet integrated.
 * 2026-11-15 - Quan Nguyen and Codex - VLSI Technology page:
 *              Route retained LLC writeback fault to cluster status/interrupt.
 */
`timescale 1ns/1ps
`include "axi/typedef.svh"
`include "register_interface/typedef.svh"

module m_vlsit_axi_llc_native #(
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

  typedef logic [LPARA_AXI_ADDR_W-1:0] axi_addr_type_def;
  typedef logic [LPARA_AXI_DATA_W-1:0] axi_data_type_def;
  typedef logic [LPARA_AXI_DATA_W/LPARA_AXI_BYTE_W-1:0] axi_strb_type_def;
  typedef logic [LPARA_AXI_SLAVE_ID_W-1:0] axi_slv_id_type_def;
  typedef logic [LPARA_AXI_MASTER_ID_W-1:0] axi_mst_id_type_def;
  typedef logic [LPARA_AXI_USER_W-1:0] axi_user_type_def;

  `AXI_TYPEDEF_AW_CHAN_T(axi_slv_aw_type_def, axi_addr_type_def, axi_slv_id_type_def, axi_user_type_def)
  `AXI_TYPEDEF_AW_CHAN_T(axi_mst_aw_type_def, axi_addr_type_def, axi_mst_id_type_def, axi_user_type_def)
  `AXI_TYPEDEF_W_CHAN_T(axi_w_type_def, axi_data_type_def, axi_strb_type_def, axi_user_type_def)
  `AXI_TYPEDEF_B_CHAN_T(axi_slv_b_type_def, axi_slv_id_type_def, axi_user_type_def)
  `AXI_TYPEDEF_B_CHAN_T(axi_mst_b_type_def, axi_mst_id_type_def, axi_user_type_def)
  `AXI_TYPEDEF_AR_CHAN_T(axi_slv_ar_type_def, axi_addr_type_def, axi_slv_id_type_def, axi_user_type_def)
  `AXI_TYPEDEF_AR_CHAN_T(axi_mst_ar_type_def, axi_addr_type_def, axi_mst_id_type_def, axi_user_type_def)
  `AXI_TYPEDEF_R_CHAN_T(axi_slv_r_type_def, axi_data_type_def, axi_slv_id_type_def, axi_user_type_def)
  `AXI_TYPEDEF_R_CHAN_T(axi_mst_r_type_def, axi_data_type_def, axi_mst_id_type_def, axi_user_type_def)
  `AXI_TYPEDEF_REQ_T(axi_slv_req_type_def, axi_slv_aw_type_def, axi_w_type_def, axi_slv_ar_type_def)
  `AXI_TYPEDEF_RESP_T(axi_slv_resp_type_def, axi_slv_b_type_def, axi_slv_r_type_def)
  `AXI_TYPEDEF_REQ_T(axi_mst_req_type_def, axi_mst_aw_type_def, axi_w_type_def, axi_mst_ar_type_def)
  `AXI_TYPEDEF_RESP_T(axi_mst_resp_type_def, axi_mst_b_type_def, axi_mst_r_type_def)

  typedef logic [LPARA_REG_ADDR_W-1:0] reg_addr_type_def;
  typedef logic [LPARA_REG_DATA_W-1:0] reg_data_type_def;
  typedef logic [LPARA_REG_STRB_W-1:0] reg_strb_type_def;
  `REG_BUS_TYPEDEF_ALL(llc_reg, reg_addr_type_def, reg_data_type_def, reg_strb_type_def)

  logic [LPARA_SLV_RESP_W-1:0] w_axi_slv_resp_flat;
  logic [LPARA_MST_REQ_W-1:0] w_axi_mst_req_flat;
  logic [LPARA_REG_RSP_W-1:0] w_llc_reg_rsp_flat;
  logic [LPARA_AXI_LLC_EVENTS_W-1:0] w_llc_events_flat;
  axi_slv_req_type_def  w_axi_slv_req;
  axi_slv_resp_type_def w_axi_slv_resp;
  axi_mst_req_type_def  w_axi_mst_req;
  axi_mst_resp_type_def w_axi_mst_resp;
  llc_reg_req_t         w_llc_reg_req;
  llc_reg_rsp_t         w_llc_reg_rsp;
  axi_llc_pkg::events_t w_llc_events;

  // Pack flattened cluster channels in the exact packed-field order of PULP AXI typedefs.
  assign w_axi_slv_req = axi_slv_req_type_def'({
    axi_slv_aw_type_def'({i_axi_cpu_awid, i_axi_cpu_awaddr, i_axi_cpu_awlen, i_axi_cpu_awsize,
                          i_axi_cpu_awburst, i_axi_cpu_awlock, i_axi_cpu_awcache, i_axi_cpu_awprot,
                          i_axi_cpu_awqos, i_axi_cpu_awregion, i_axi_cpu_awatop, 1'b0}),
    i_axi_cpu_awvalid,
    axi_w_type_def'({i_axi_cpu_wdata, i_axi_cpu_wstrb, i_axi_cpu_wlast, 1'b0}),
    i_axi_cpu_wvalid,
    i_axi_cpu_bready,
    axi_slv_ar_type_def'({i_axi_cpu_arid, i_axi_cpu_araddr, i_axi_cpu_arlen, i_axi_cpu_arsize,
                          i_axi_cpu_arburst, i_axi_cpu_arlock, i_axi_cpu_arcache, i_axi_cpu_arprot,
                          i_axi_cpu_arqos, i_axi_cpu_arregion, 1'b0}),
    i_axi_cpu_arvalid,
    i_axi_cpu_rready
  });

  // Pack the external memory responses into the typed AXI response record.
  assign w_axi_mst_resp = axi_mst_resp_type_def'({
    i_axi_mem_awready,
    i_axi_mem_arready,
    i_axi_mem_wready,
    i_axi_mem_bvalid,
    axi_mst_b_type_def'({i_axi_mem_bid, i_axi_mem_bresp, 1'b0}),
    i_axi_mem_rvalid,
    axi_mst_r_type_def'({i_axi_mem_rid, i_axi_mem_rdata, i_axi_mem_rresp, i_axi_mem_rlast, 1'b0})
  });

  // Convert the external RegBus request fields into the upstream LLC request record.
  assign w_llc_reg_req = llc_reg_req_t'({i_reg_req_addr, i_reg_req_wr, i_reg_req_wdata, i_reg_req_wstrb,
                                         i_reg_req_valid});

  // Flatten typed upstream responses and event records for the VLSIT scalar-port boundary.
  assign w_axi_slv_resp_flat = w_axi_slv_resp;
  assign w_axi_mst_req_flat = w_axi_mst_req;
  assign w_llc_reg_rsp_flat = w_llc_reg_rsp;
  assign w_llc_events_flat = w_llc_events;

  // Unpack the packed PULP responses using offsets derived from the declared channel types.
  assign o_axi_cpu_awready = w_axi_slv_resp_flat[LPARA_SLV_RESP_AW_RDY_BIT];
  assign o_axi_cpu_arready = w_axi_slv_resp_flat[LPARA_SLV_RESP_AR_RDY_BIT];
  assign o_axi_cpu_wready = w_axi_slv_resp_flat[LPARA_SLV_RESP_W_RDY_BIT];
  assign o_axi_cpu_bvalid = w_axi_slv_resp_flat[LPARA_SLV_RESP_BVLD_BIT];
  assign o_axi_cpu_bid = w_axi_slv_resp_flat[LPARA_SLV_RESP_B_LSB + LPARA_B_ID_LSB +: LPARA_AXI_SLAVE_ID_W];
  assign o_axi_cpu_bresp = w_axi_slv_resp_flat[LPARA_SLV_RESP_B_LSB + LPARA_B_RESP_LSB +: LPARA_AXI_RESP_W];
  assign o_axi_cpu_rvalid = w_axi_slv_resp_flat[LPARA_SLV_RESP_RVLD_BIT];
  assign o_axi_cpu_rid = w_axi_slv_resp_flat[LPARA_SLV_RESP_R_LSB + LPARA_R_ID_LSB +: LPARA_AXI_SLAVE_ID_W];
  assign o_axi_cpu_rdata = w_axi_slv_resp_flat[LPARA_SLV_RESP_R_LSB + LPARA_R_DATA_LSB +: LPARA_AXI_DATA_W];
  assign o_axi_cpu_rresp = w_axi_slv_resp_flat[LPARA_SLV_RESP_R_LSB + LPARA_R_RESP_LSB +: LPARA_AXI_RESP_W];
  assign o_axi_cpu_rlast = w_axi_slv_resp_flat[LPARA_SLV_RESP_R_LSB + LPARA_R_LAST_LSB];

  // Unpack the LLC memory request into the external 64-bit AXI4+ATOP channel set.
  assign o_axi_mem_awvalid = w_axi_mst_req_flat[LPARA_MST_REQ_AWVLD_BIT];
  assign o_axi_mem_awid = w_axi_mst_req_flat[LPARA_MST_REQ_AW_LSB + LPARA_AW_ID_LSB +: LPARA_AXI_MASTER_ID_W];
  assign o_axi_mem_awaddr = w_axi_mst_req_flat[LPARA_MST_REQ_AW_LSB + LPARA_AW_ADDR_LSB +: LPARA_AXI_ADDR_W];
  assign o_axi_mem_awlen = w_axi_mst_req_flat[LPARA_MST_REQ_AW_LSB + LPARA_AW_LEN_LSB +: LPARA_AXI_LEN_W];
  assign o_axi_mem_awsize = w_axi_mst_req_flat[LPARA_MST_REQ_AW_LSB + LPARA_AW_SIZE_LSB +: LPARA_AXI_SIZE_W];
  assign o_axi_mem_awburst = w_axi_mst_req_flat[LPARA_MST_REQ_AW_LSB + LPARA_AW_BURST_LSB +: LPARA_AXI_BURST_W];
  assign o_axi_mem_awlock = w_axi_mst_req_flat[LPARA_MST_REQ_AW_LSB + LPARA_AW_LOCK_LSB];
  assign o_axi_mem_awcache = w_axi_mst_req_flat[LPARA_MST_REQ_AW_LSB + LPARA_AW_CACHE_LSB +: LPARA_AXI_CACHE_W];
  assign o_axi_mem_awprot = w_axi_mst_req_flat[LPARA_MST_REQ_AW_LSB + LPARA_AW_PROT_LSB +: LPARA_AXI_PROT_W];
  assign o_axi_mem_awqos = w_axi_mst_req_flat[LPARA_MST_REQ_AW_LSB + LPARA_AW_QOS_LSB +: LPARA_AXI_QOS_W];
  assign o_axi_mem_awregion = w_axi_mst_req_flat[LPARA_MST_REQ_AW_LSB + LPARA_AW_REGION_LSB +: LPARA_AXI_REGION_W];
  assign o_axi_mem_awatop = w_axi_mst_req_flat[LPARA_MST_REQ_AW_LSB + LPARA_AW_ATOP_LSB +: LPARA_AXI_ATOP_W];
  assign o_axi_mem_wvalid = w_axi_mst_req_flat[LPARA_MST_REQ_WVLD_BIT];
  assign o_axi_mem_wdata = w_axi_mst_req_flat[LPARA_MST_REQ_W_LSB + LPARA_W_DATA_LSB +: LPARA_AXI_DATA_W];
  assign o_axi_mem_wstrb = w_axi_mst_req_flat[LPARA_MST_REQ_W_LSB + LPARA_W_STRB_LSB +: LPARA_AXI_DATA_W/LPARA_AXI_BYTE_W];
  assign o_axi_mem_wlast = w_axi_mst_req_flat[LPARA_MST_REQ_W_LSB + LPARA_W_LAST_LSB];
  assign o_axi_mem_bready = w_axi_mst_req_flat[LPARA_MST_REQ_BRDY_BIT];
  assign o_axi_mem_arvalid = w_axi_mst_req_flat[LPARA_MST_REQ_AR_LSB - 32'd1];
  assign o_axi_mem_arid = w_axi_mst_req_flat[LPARA_MST_REQ_AR_LSB + LPARA_AR_ID_LSB +: LPARA_AXI_MASTER_ID_W];
  assign o_axi_mem_araddr = w_axi_mst_req_flat[LPARA_MST_REQ_AR_LSB + LPARA_AR_ADDR_LSB +: LPARA_AXI_ADDR_W];
  assign o_axi_mem_arlen = w_axi_mst_req_flat[LPARA_MST_REQ_AR_LSB + LPARA_AR_LEN_LSB +: LPARA_AXI_LEN_W];
  assign o_axi_mem_arsize = w_axi_mst_req_flat[LPARA_MST_REQ_AR_LSB + LPARA_AR_SIZE_LSB +: LPARA_AXI_SIZE_W];
  assign o_axi_mem_arburst = w_axi_mst_req_flat[LPARA_MST_REQ_AR_LSB + LPARA_AR_BURST_LSB +: LPARA_AXI_BURST_W];
  assign o_axi_mem_arlock = w_axi_mst_req_flat[LPARA_MST_REQ_AR_LSB + LPARA_AR_LOCK_LSB];
  assign o_axi_mem_arcache = w_axi_mst_req_flat[LPARA_MST_REQ_AR_LSB + LPARA_AR_CACHE_LSB +: LPARA_AXI_CACHE_W];
  assign o_axi_mem_arprot = w_axi_mst_req_flat[LPARA_MST_REQ_AR_LSB + LPARA_AR_PROT_LSB +: LPARA_AXI_PROT_W];
  assign o_axi_mem_arqos = w_axi_mst_req_flat[LPARA_MST_REQ_AR_LSB + LPARA_AR_QOS_LSB +: LPARA_AXI_QOS_W];
  assign o_axi_mem_arregion = w_axi_mst_req_flat[LPARA_MST_REQ_AR_LSB + LPARA_AR_REGION_LSB +: LPARA_AXI_REGION_W];
  assign o_axi_mem_rready = w_axi_mst_req_flat[32'd0];

  // Return the LLC RegBus response fields to the AXI4-Lite service bridge.
  assign o_reg_rsp_ready = w_llc_reg_rsp_flat[32'd0];
  assign o_reg_rsp_err = w_llc_reg_rsp_flat[32'd1];
  assign o_reg_rsp_rdata = w_llc_reg_rsp_flat[LPARA_REG_RSP_CTRL_W +: LPARA_REG_DATA_W];
  // Map PULP byte-count events to their active bits in the approved PMU event order.
  for (genvar event_idx = 0; event_idx < LPARA_LLC_EVENT_NUM; event_idx++) begin : gen_llc_event
    // Select the active bit at the least-significant position of each byte-count record.
    assign o_llc_events[event_idx] = w_llc_events_flat[32'd4 +
                                                       ((LPARA_LLC_EVENT_NUM - 32'd1 - event_idx) * LPARA_EVENT_W)];
  end
  // Append the four LLC engine request events after the byte-count event indicators.
  assign o_llc_events[LPARA_LLC_EVENT_NUM] = w_llc_events_flat[3];
  assign o_llc_events[LPARA_LLC_EVENT_NUM + LPARA_LLC_FLAG_OFFSET_1] = w_llc_events_flat[2];
  assign o_llc_events[LPARA_LLC_EVENT_NUM + LPARA_LLC_FLAG_OFFSET_2] = w_llc_events_flat[1];
  assign o_llc_events[LPARA_LLC_EVENT_OUTPUT_NUM-32'd1] = w_llc_events_flat[0];

  // Bind the pinned PULP LLC with static geometry and the configured address range.
  axi_llc_reg_wrap #(
    .SetAssociativity(PARA_LLC_WAY_NUM),
    .NumLines(PARA_LLC_NO_LINES),
    .NumBlocks(PARA_LLC_BLOCK_NUM),
    .AxiIdWidth(LPARA_AXI_SLAVE_ID_W),
    .AxiAddrWidth(LPARA_AXI_ADDR_W),
    .AxiDataWidth(LPARA_AXI_DATA_W),
    .AxiUserWidth(LPARA_AXI_USER_W),
    .AxiIdLookupBits(LPARA_AXI_ID_LOOKUP_BITS),
    .slv_req_t(axi_slv_req_type_def),
    .slv_resp_t(axi_slv_resp_type_def),
    .mst_req_t(axi_mst_req_type_def),
    .mst_resp_t(axi_mst_resp_type_def),
    .reg_req_t(llc_reg_req_t),
    .reg_resp_t(llc_reg_rsp_t),
    .rule_full_t(axi_pkg::xbar_rule_64_t)
  ) u_dont_touch_axi_llc_reg_wrap (
    .maint_valid_i(i_maint_valid), .maint_ready_o(o_maint_ready),
    .maint_op_i(i_maint_op), .maint_pa_line_i(i_maint_pa_line),
    .maint_done_o(o_maint_done), .maint_error_o(o_maint_error),
    .clk_i(i_clk_cluster),
    .rst_ni(i_rst_n_cluster),
    .test_i(i_test_en),
    .slv_req_i(w_axi_slv_req),
    .slv_resp_o(w_axi_slv_resp),
    .mst_req_o(w_axi_mst_req),
    .mst_resp_i(w_axi_mst_resp),
    .conf_req_i(w_llc_reg_req),
    .conf_resp_o(w_llc_reg_rsp),
    .cached_start_addr_i(i_cached_start_addr),
    .cached_end_addr_i(i_cached_end_addr),
    .spm_start_addr_i(axi_addr_type_def'(64'd0)),
    .wb_fault_o(o_wb_fault),
    .wb_fault_event_o(o_wb_fault_event),
    .wb_fault_addr_o(o_wb_fault_addr),
    .wb_fault_resp_o(o_wb_fault_resp),
    .axi_llc_events_o(w_llc_events)
  );

endmodule
