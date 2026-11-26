/*
 * Project      : VLSIT RISC-V CPU Cluster
 * Author       : Quan Nguyen (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-14
 * Description  : Routes one tile AXI4 port by shared-table region metadata.
 * Specification: REQ-IF-011, DEC-037
 * Rule note    : HIE-02 is intentional; this adapter combines route logic and cells.
 * Change History:
 * 2026-11-20 - Modified by Quan Nguyen and Codex - VLSI Technology page:
 *              Add optional registered AXI target cuts for the cluster timing profile.
 *              Preserve CVA6 internals and the existing AXI/route-class payloads.
 */
`timescale 1ns/1ps

module m_vlsit_riscv_axi_route #(
  // Parameter Description: outstanding transaction capacity of the AXI demultiplexer.
  // Parameter values: 1 through 32; default is 8.
  // Parameter unit: transactions.
  parameter logic [31:0] PARA_AXI_MAX_TRANS = 32'd8,
  // Parameter Description: compile-time cluster timing profile.
  // Parameter values: 0 = low latency, 1 = registered AXI target boundaries; default is 0.
  // Parameter unit: profile index.
  parameter logic [31:0] PARA_TIMING_PROFILE = 32'd0,
  localparam logic [31:0] LPARA_TIMING_PROFILE_LOW_LATENCY = 32'd0,
  localparam logic [31:0] LPARA_TIMING_PROFILE_CLUSTER_TIMING = 32'd1,
  localparam logic [31:0] LPARA_AXI_ID_W = 32'd4,
  localparam logic [31:0] LPARA_AXI_ROUTE_MEM = 32'd0,
  localparam logic [31:0] LPARA_AXI_ROUTE_MMIO = 32'd1,
  localparam logic [31:0] LPARA_AXI_ROUTE_ERR = 32'd2,
  localparam logic [31:0] LPARA_AXI_MST_PORT_NUM = 32'd3,
  localparam logic [31:0] LPARA_AXI_ERR_MAX_TRANS = 32'd2,
  localparam logic [31:0] LPARA_AXI_ATOP_W = 32'd6,
  localparam logic [31:0] LPARA_AXI_USER_W = 32'd1,
  localparam logic [31:0] LPARA_AXI_ROUTE_CLASS_W = 32'd2,
  localparam logic [31:0] LPARA_AXI_AW_W = 32'd105,
  localparam logic [31:0] LPARA_AXI_W_W = 32'd73,
  localparam logic [31:0] LPARA_AXI_B_W = 32'd7,
  localparam logic [31:0] LPARA_AXI_AR_W = 32'd99,
  localparam logic [31:0] LPARA_AXI_R_W = 32'd72,
  localparam logic [31:0] LPARA_AXI_AW_MMIO_W = 32'd97,
  localparam logic [31:0] LPARA_AXI_AR_MMIO_W = 32'd97,
  localparam logic [31:0] LPARA_AXI_REQ_W = 32'd282,
  localparam logic [31:0] LPARA_AXI_RESP_W = 32'd84,
  localparam logic [31:0] LPARA_AXI_LOOK_BITS = 32'd3,
  localparam logic [31:0] LPARA_AXI_RESP_DECERR = 32'd3,
  localparam logic [31:0] LPARA_AXI_REQ_R_READY_BIT = 32'd0,
  localparam logic [31:0] LPARA_AXI_REQ_AR_VALID_BIT = 32'd1,
  localparam logic [31:0] LPARA_AXI_REQ_AR_LSB = 32'd2,
  localparam logic [31:0] LPARA_AXI_REQ_AR_MSB = LPARA_AXI_REQ_AR_LSB + LPARA_AXI_AR_W - 32'd1,
  localparam logic [31:0] LPARA_AXI_REQ_B_READY_BIT = LPARA_AXI_REQ_AR_MSB + 32'd1,
  localparam logic [31:0] LPARA_AXI_REQ_W_VALID_BIT = LPARA_AXI_REQ_B_READY_BIT + 32'd1,
  localparam logic [31:0] LPARA_AXI_REQ_W_LSB = LPARA_AXI_REQ_W_VALID_BIT + 32'd1,
  localparam logic [31:0] LPARA_AXI_REQ_W_MSB = LPARA_AXI_REQ_W_LSB + LPARA_AXI_W_W - 32'd1,
  localparam logic [31:0] LPARA_AXI_REQ_AW_VALID_BIT = LPARA_AXI_REQ_W_MSB + 32'd1,
  localparam logic [31:0] LPARA_AXI_REQ_AW_LSB = LPARA_AXI_REQ_AW_VALID_BIT + 32'd1,
  localparam logic [31:0] LPARA_AXI_REQ_AW_MSB = LPARA_AXI_REQ_AW_LSB + LPARA_AXI_AW_W - 32'd1,
  localparam logic [31:0] LPARA_AXI_RESP_R_VALID_BIT = 32'd0,
  localparam logic [31:0] LPARA_AXI_RESP_R_LSB = 32'd1,
  localparam logic [31:0] LPARA_AXI_RESP_R_MSB = LPARA_AXI_RESP_R_LSB + LPARA_AXI_R_W - 32'd1,
  localparam logic [31:0] LPARA_AXI_RESP_AR_READY_BIT = LPARA_AXI_RESP_R_MSB + 32'd1,
  localparam logic [31:0] LPARA_AXI_RESP_B_VALID_BIT = LPARA_AXI_RESP_AR_READY_BIT + 32'd1,
  localparam logic [31:0] LPARA_AXI_RESP_B_LSB = LPARA_AXI_RESP_B_VALID_BIT + 32'd1,
  localparam logic [31:0] LPARA_AXI_RESP_B_MSB = LPARA_AXI_RESP_B_LSB + LPARA_AXI_B_W - 32'd1,
  localparam logic [31:0] LPARA_AXI_RESP_W_READY_BIT = LPARA_AXI_RESP_B_MSB + 32'd1,
  localparam logic [31:0] LPARA_AXI_RESP_AW_READY_BIT = LPARA_AXI_RESP_W_READY_BIT + 32'd1,
  localparam logic [31:0] LPARA_AXI_AW_ID_LSB = LPARA_AXI_AW_W - LPARA_AXI_ID_W,
  localparam logic [31:0] LPARA_AXI_AW_ADDR_MSB = LPARA_AXI_AW_ID_LSB - LPARA_AXI_ATOP_W - 32'd1,
  localparam logic [31:0] LPARA_AXI_AR_ID_LSB = LPARA_AXI_AR_W - LPARA_AXI_ID_W,
  localparam logic [31:0] LPARA_AXI_AR_ADDR_MSB = LPARA_AXI_AR_ID_LSB - 32'd1,
  localparam logic [31:0] LPARA_REGION_CACHEABLE = 32'd0,
  localparam logic [31:0] LPARA_REGION_NORMAL_UNCACHED = 32'd1,
  localparam logic [31:0] LPARA_REGION_MMIO = 32'd2
) (
  // Clock and reset
  input  wire         i_clk_cluster,
  input  wire         i_rst_n_cluster,

  // Tile AW channel and shared-table classification
  input  wire  [3:0]  i_awid,
  input  wire  [5:0]  i_awatop,
  input  wire  [63:0] i_awaddr,
  input  wire  [7:0]  i_awlen,
  input  wire  [2:0]  i_awsize,
  input  wire  [1:0]  i_awburst,
  input  wire         i_awlock,
  input  wire  [3:0]  i_awcache,
  input  wire  [2:0]  i_awprot,
  input  wire  [3:0]  i_awqos,
  input  wire  [3:0]  i_awregion,
  input  wire         i_awvalid,
  output logic        o_awready,
  input  wire         i_aw_region_match,
  input  wire  [1:0]  i_aw_region_type,
  input  wire         i_aw_region_err,

  // Tile W/B channels
  input  wire  [63:0] i_wdata,
  input  wire  [7:0]  i_wstrb,
  input  wire         i_wlast,
  input  wire         i_wvalid,
  output logic        o_wready,
  output logic [3:0]  o_bid,
  output logic [1:0]  o_bresp,
  output logic        o_bvalid,
  input  wire         i_bready,

  // Tile AR channel and shared-table classification
  input  wire  [3:0]  i_arid,
  input  wire  [63:0] i_araddr,
  input  wire  [7:0]  i_arlen,
  input  wire  [2:0]  i_arsize,
  input  wire  [1:0]  i_arburst,
  input  wire         i_arlock,
  input  wire  [3:0]  i_arcache,
  input  wire  [2:0]  i_arprot,
  input  wire  [3:0]  i_arqos,
  input  wire  [3:0]  i_arregion,
  input  wire         i_arvalid,
  output logic        o_arready,
  input  wire         i_ar_region_match,
  input  wire  [1:0]  i_ar_region_type,
  input  wire         i_ar_region_err,
  output logic [3:0]  o_rid,
  output logic [63:0] o_rdata,
  output logic [1:0]  o_rresp,
  output logic        o_rlast,
  output logic        o_rvalid,
  input  wire         i_rready,

  // Memory-side path toward CCU/LLC; route class identifies LLC bypass traffic
  output logic [3:0]  o_mem_awid,
  output logic [5:0]  o_mem_awatop,
  output logic [63:0] o_mem_awaddr,
  output logic [7:0]  o_mem_awlen,
  output logic [2:0]  o_mem_awsize,
  output logic [1:0]  o_mem_awburst,
  output logic        o_mem_awlock,
  output logic [3:0]  o_mem_awcache,
  output logic [2:0]  o_mem_awprot,
  output logic [3:0]  o_mem_awqos,
  output logic [3:0]  o_mem_awregion,
  output logic [1:0]  o_mem_aw_route_class,
  output logic        o_mem_awvalid,
  input  wire         i_mem_awready,
  output logic [63:0] o_mem_wdata,
  output logic [7:0]  o_mem_wstrb,
  output logic        o_mem_wlast,
  output logic        o_mem_wvalid,
  input  wire         i_mem_wready,
  input  wire  [3:0]  i_mem_bid,
  input  wire  [1:0]  i_mem_bresp,
  input  wire         i_mem_bvalid,
  output logic        o_mem_bready,
  output logic [3:0]  o_mem_arid,
  output logic [63:0] o_mem_araddr,
  output logic [7:0]  o_mem_arlen,
  output logic [2:0]  o_mem_arsize,
  output logic [1:0]  o_mem_arburst,
  output logic        o_mem_arlock,
  output logic [3:0]  o_mem_arcache,
  output logic [2:0]  o_mem_arprot,
  output logic [3:0]  o_mem_arqos,
  output logic [3:0]  o_mem_arregion,
  output logic [1:0]  o_mem_ar_route_class,
  output logic        o_mem_arvalid,
  input  wire         i_mem_arready,
  input  wire  [3:0]  i_mem_rid,
  input  wire  [63:0] i_mem_rdata,
  input  wire  [1:0]  i_mem_rresp,
  input  wire         i_mem_rlast,
  input  wire         i_mem_rvalid,
  output logic        o_mem_rready,

  // MMIO manager path
  output logic [3:0]  o_mmio_awid,
  output logic [63:0] o_mmio_awaddr,
  output logic [7:0]  o_mmio_awlen,
  output logic [2:0]  o_mmio_awsize,
  output logic [1:0]  o_mmio_awburst,
  output logic        o_mmio_awlock,
  output logic [3:0]  o_mmio_awcache,
  output logic [2:0]  o_mmio_awprot,
  output logic [3:0]  o_mmio_awqos,
  output logic [3:0]  o_mmio_awregion,
  output logic        o_mmio_awvalid,
  input  wire         i_mmio_awready,
  output logic [63:0] o_mmio_wdata,
  output logic [7:0]  o_mmio_wstrb,
  output logic        o_mmio_wlast,
  output logic        o_mmio_wvalid,
  input  wire         i_mmio_wready,
  input  wire  [3:0]  i_mmio_bid,
  input  wire  [1:0]  i_mmio_bresp,
  input  wire         i_mmio_bvalid,
  output logic        o_mmio_bready,
  output logic [3:0]  o_mmio_arid,
  output logic [63:0] o_mmio_araddr,
  output logic [7:0]  o_mmio_arlen,
  output logic [2:0]  o_mmio_arsize,
  output logic [1:0]  o_mmio_arburst,
  output logic        o_mmio_arlock,
  output logic [3:0]  o_mmio_arcache,
  output logic [2:0]  o_mmio_arprot,
  output logic [3:0]  o_mmio_arqos,
  output logic [3:0]  o_mmio_arregion,
  output logic        o_mmio_arvalid,
  input  wire         i_mmio_arready,
  input  wire  [3:0]  i_mmio_rid,
  input  wire  [63:0] i_mmio_rdata,
  input  wire  [1:0]  i_mmio_rresp,
  input  wire         i_mmio_rlast,
  input  wire         i_mmio_rvalid,
  output logic        o_mmio_rready,

  // Accepted local decode-error events for diagnostic/PMU wiring
  output logic        o_aw_local_err_event,
  output logic        o_ar_local_err_event
);

  // Local packed records preserve standard AXI fields and carry the route class
  // through the demultiplexer to the LLC bypass decision point.
  // Upstream field contract: id atop addr len size burst lock cache prot qos region class.
  typedef struct packed {
    logic [3:0] id;
    logic [5:0] atop;
    logic [63:0] addr;
    logic [7:0] len;
    logic [2:0] size;
    logic [1:0] burst;
    logic lock;
    logic [3:0] cache;
    logic [2:0] prot;
    logic [3:0] qos;
    logic [3:0] region;
    logic [1:0] route_class;
  } axi_aw_chan_type_def;
  // Upstream field contract: data strb last.
  typedef struct packed {
    logic [63:0] data;
    logic [7:0] strb;
    logic last;
  } axi_w_chan_type_def;
  // Upstream field contract: id resp user.
  typedef struct packed {
    logic [3:0] id;
    logic [1:0] resp;
    logic user;
  } axi_b_chan_type_def;
  // Upstream field contract: id addr len size burst lock cache prot qos region class.
  typedef struct packed {
    logic [3:0] id;
    logic [63:0] addr;
    logic [7:0] len;
    logic [2:0] size;
    logic [1:0] burst;
    logic lock;
    logic [3:0] cache;
    logic [2:0] prot;
    logic [3:0] qos;
    logic [3:0] region;
    logic [1:0] route_class;
  } axi_ar_chan_type_def;
  // Upstream field contract: id data resp last user.
  typedef struct packed {
    logic [3:0] id;
    logic [63:0] data;
    logic [1:0] resp;
    logic last;
    logic user;
  } axi_r_chan_type_def;
  // Tile-side AW/W records separate the flat-port adapter from the upstream cell ABI.
  typedef struct packed {
    logic [3:0] id;
    logic [5:0] atop;
    logic [63:0] addr;
    logic [7:0] len;
    logic [2:0] size;
    logic [1:0] burst;
    logic lock;
    logic [3:0] cache;
    logic [2:0] prot;
    logic [3:0] qos;
    logic [3:0] region;
    logic [1:0] route_class;
  } axi_tile_aw_chan_type_def;
  typedef struct packed {
    logic [63:0] data;
    logic [7:0] strb;
    logic last;
  } axi_tile_w_chan_type_def;
  // Upstream request field contract: aw aw_valid w w_valid b_ready ar ar_valid r_ready.
  typedef struct packed {
    axi_aw_chan_type_def aw;
    logic aw_valid;
    axi_w_chan_type_def w;
    logic w_valid;
    logic b_ready;
    axi_ar_chan_type_def ar;
    logic ar_valid;
    logic r_ready;
  } axi_req_type_def;
  // Upstream response field contract: aw_ready w_ready b b_valid ar_ready r r_valid.
  typedef struct packed {
    logic aw_ready;
    logic w_ready;
    axi_b_chan_type_def b;
    logic b_valid;
    logic ar_ready;
    axi_r_chan_type_def r;
    logic r_valid;
  } axi_resp_type_def;
  // Tile-facing records keep the adapter boundary explicitly typed.
  typedef struct packed {
    axi_tile_aw_chan_type_def aw;
    logic aw_valid;
    axi_tile_w_chan_type_def w;
    logic w_valid;
    logic b_ready;
    axi_ar_chan_type_def ar;
    logic ar_valid;
    logic r_ready;
  } axi_tile_req_type_def;
  typedef struct packed {
    logic aw_ready;
    logic w_ready;
    axi_b_chan_type_def b;
    logic b_valid;
    logic ar_ready;
    axi_r_chan_type_def r;
    logic r_valid;
  } axi_tile_resp_type_def;

  logic [1:0] w_aw_sel;
  logic [1:0] w_ar_sel;
  logic w_aw_local_err;
  logic w_ar_local_err;
  axi_req_type_def w_slv_req;
  axi_resp_type_def w_slv_resp;
  axi_tile_req_type_def w_tile_req;
  axi_tile_resp_type_def w_tile_resp;
  axi_req_type_def [LPARA_AXI_MST_PORT_NUM-1:0] w_mst_req;
  axi_resp_type_def [LPARA_AXI_MST_PORT_NUM-1:0] w_mst_resp;
  axi_req_type_def w_mem_target_req;
  axi_resp_type_def w_mem_target_resp;
  axi_req_type_def w_mmio_target_req;
  axi_resp_type_def w_mmio_target_resp;
  logic [LPARA_AXI_REQ_W-1:0] w_slv_req_bits;
  logic [LPARA_AXI_RESP_W-1:0] w_slv_resp_bits;
  logic [LPARA_AXI_MST_PORT_NUM-1:0][LPARA_AXI_RESP_W-1:0] w_mst_resp_bits;
  logic [LPARA_AXI_REQ_W-1:0] w_mem_target_req_bits;
  logic [LPARA_AXI_REQ_W-1:0] w_mmio_target_req_bits;
  logic [LPARA_AXI_RESP_W-1:0] w_mem_target_resp_bits;
  logic [LPARA_AXI_RESP_W-1:0] w_mmio_target_resp_bits;
  logic [LPARA_AXI_AW_W-1:0] w_mem_aw_bits;
  logic [LPARA_AXI_AR_W-1:0] w_mem_ar_bits;
  logic [LPARA_AXI_AW_MMIO_W-1:0] w_mmio_aw_bits;
  logic [LPARA_AXI_AR_MMIO_W-1:0] w_mmio_ar_bits;
  logic [LPARA_AXI_W_W-1:0] w_mem_w_bits;
  logic [LPARA_AXI_W_W-1:0] w_mmio_w_bits;

  // Unmapped, invalid, reserved, and unsupported requests fail closed to the DECERR target.
  always_comb begin : p_com_aw_route
    w_aw_local_err = 1'b1;
    w_aw_sel = 2'(LPARA_AXI_ROUTE_ERR);
    if ((i_aw_region_match == 1'b1) && (i_aw_region_err == 1'b0)) begin
      case (i_aw_region_type)
        LPARA_REGION_CACHEABLE[1:0], LPARA_REGION_NORMAL_UNCACHED[1:0]: begin
          w_aw_local_err = 1'b0;
          w_aw_sel = 2'(LPARA_AXI_ROUTE_MEM);
        end
        LPARA_REGION_MMIO[1:0]: begin
          if ((i_awatop == 6'd0) && (i_awlock == 1'b0)) begin
            w_aw_local_err = 1'b0;
            w_aw_sel = 2'(LPARA_AXI_ROUTE_MMIO);
          end
        end
        default: begin
          // Preserve DECERR for reserved classes and four-state unknown inputs.
        end
      endcase
    end
  end

  // MMIO reads reject exclusive access; other classes share the memory target.
  always_comb begin : p_com_ar_route
    w_ar_local_err = 1'b1;
    w_ar_sel = 2'(LPARA_AXI_ROUTE_ERR);
    if ((i_ar_region_match == 1'b1) && (i_ar_region_err == 1'b0)) begin
      case (i_ar_region_type)
        LPARA_REGION_CACHEABLE[1:0], LPARA_REGION_NORMAL_UNCACHED[1:0]: begin
          w_ar_local_err = 1'b0;
          w_ar_sel = 2'(LPARA_AXI_ROUTE_MEM);
        end
        LPARA_REGION_MMIO[1:0]: begin
          if (i_arlock == 1'b0) begin
            w_ar_local_err = 1'b0;
            w_ar_sel = 2'(LPARA_AXI_ROUTE_MMIO);
          end
        end
        default: begin
          // Preserve DECERR for reserved classes and four-state unknown inputs.
        end
      endcase
    end
  end

  // Bundle flat AXI channels into the unchanged upstream PULP request record.
  assign w_slv_req_bits = {
    i_awid, i_awatop, i_awaddr, i_awlen, i_awsize, i_awburst, i_awlock, i_awcache,
    i_awprot, i_awqos, i_awregion, i_aw_region_type, (i_awvalid & i_rst_n_cluster),
    i_wdata, i_wstrb, i_wlast, (i_wvalid & i_rst_n_cluster),
    (i_bready & i_rst_n_cluster),
    i_arid, i_araddr, i_arlen, i_arsize, i_arburst, i_arlock, i_arcache, i_arprot,
    i_arqos, i_arregion, i_ar_region_type, (i_arvalid & i_rst_n_cluster),
    (i_rready & i_rst_n_cluster)
  };
  // Cast the flat tile request into the tile and upstream record types.
  assign w_tile_req = axi_tile_req_type_def'(w_slv_req_bits);
  assign w_slv_req = axi_req_type_def'(w_tile_req);

  // Keep address-class sidebands in AW/AR records so demux spill stages cannot misalign them.
  axi_demux #(
    .AxiIdWidth(LPARA_AXI_ID_W),
    .AtopSupport(1'b1),
    .aw_chan_t(axi_aw_chan_type_def),
    .w_chan_t(axi_w_chan_type_def),
    .b_chan_t(axi_b_chan_type_def),
    .ar_chan_t(axi_ar_chan_type_def),
    .r_chan_t(axi_r_chan_type_def),
    .axi_req_t(axi_req_type_def),
    .axi_resp_t(axi_resp_type_def),
    .NoMstPorts(LPARA_AXI_MST_PORT_NUM),
    .MaxTrans(PARA_AXI_MAX_TRANS),
    .AxiLookBits(LPARA_AXI_LOOK_BITS)
  ) u_dont_touch_axi_demux (
    .clk_i(i_clk_cluster),
    .rst_ni(i_rst_n_cluster),
    .test_i(1'b0),
    .slv_req_i(w_slv_req),
    .slv_aw_select_i(w_aw_sel),
    .slv_ar_select_i(w_ar_sel),
    .slv_resp_o(w_slv_resp),
    .mst_reqs_o(w_mst_req),
    .mst_resps_i(w_mst_resp)
  );

  // Pack demux responses after optional target cuts before returning them to the tile.
  assign w_mst_resp_bits = w_mst_resp;
  assign w_mem_target_req_bits = w_mem_target_req;
  assign w_mmio_target_req_bits = w_mmio_target_req;
  assign w_tile_resp = axi_tile_resp_type_def'(w_slv_resp);
  assign w_slv_resp_bits = w_tile_resp;

  // The timing profile inserts licensed spill-register cuts at memory and MMIO
  // target boundaries. Channel payloads, IDs, and route-class sidebands remain intact.
  if (PARA_TIMING_PROFILE == LPARA_TIMING_PROFILE_CLUSTER_TIMING) begin : gen_cluster_timing_cuts
    axi_cut #(
      .Bypass      (1'b0),
      .aw_chan_t   (axi_aw_chan_type_def),
      .w_chan_t    (axi_w_chan_type_def),
      .b_chan_t    (axi_b_chan_type_def),
      .ar_chan_t   (axi_ar_chan_type_def),
      .r_chan_t    (axi_r_chan_type_def),
      .axi_req_t   (axi_req_type_def),
      .axi_resp_t  (axi_resp_type_def)
    ) u_mem_axi_cut (
      .clk_i      (i_clk_cluster),
      .rst_ni     (i_rst_n_cluster),
      .slv_req_i  (w_mst_req[LPARA_AXI_ROUTE_MEM]),
      .slv_resp_o(w_mst_resp[LPARA_AXI_ROUTE_MEM]),
      .mst_req_o  (w_mem_target_req),
      .mst_resp_i(w_mem_target_resp)
    );

    axi_cut #(
      .Bypass      (1'b0),
      .aw_chan_t   (axi_aw_chan_type_def),
      .w_chan_t    (axi_w_chan_type_def),
      .b_chan_t    (axi_b_chan_type_def),
      .ar_chan_t   (axi_ar_chan_type_def),
      .r_chan_t    (axi_r_chan_type_def),
      .axi_req_t   (axi_req_type_def),
      .axi_resp_t  (axi_resp_type_def)
    ) u_mmio_axi_cut (
      .clk_i      (i_clk_cluster),
      .rst_ni     (i_rst_n_cluster),
      .slv_req_i  (w_mst_req[LPARA_AXI_ROUTE_MMIO]),
      .slv_resp_o(w_mst_resp[LPARA_AXI_ROUTE_MMIO]),
      .mst_req_o  (w_mmio_target_req),
      .mst_resp_i(w_mmio_target_resp)
    );
  end else begin : gen_low_latency_routes
    assign w_mem_target_req = w_mst_req[LPARA_AXI_ROUTE_MEM];
    assign w_mst_resp[LPARA_AXI_ROUTE_MEM] = w_mem_target_resp;
    assign w_mmio_target_req = w_mst_req[LPARA_AXI_ROUTE_MMIO];
    assign w_mst_resp[LPARA_AXI_ROUTE_MMIO] = w_mmio_target_resp;
  end

  // The pinned PULP slave returns DECERR for invalid or unsupported transactions.
  axi_err_slv #(
    .AxiIdWidth(LPARA_AXI_ID_W),
    .axi_req_t(axi_req_type_def),
    .axi_resp_t(axi_resp_type_def),
    .Resp(2'(LPARA_AXI_RESP_DECERR)),
    .ATOPs(1'b1),
    .MaxTrans(LPARA_AXI_ERR_MAX_TRANS)
  ) u_dont_touch_axi_err_slv (
    .clk_i(i_clk_cluster),
    .rst_ni(i_rst_n_cluster),
    .test_i(1'b0),
    .slv_req_i(w_mst_req[LPARA_AXI_ROUTE_ERR]),
    .slv_resp_o(w_mst_resp[LPARA_AXI_ROUTE_ERR])
  );

  // Return the demultiplexed response channels to the tile AXI master.
  assign o_awready = w_slv_resp_bits[LPARA_AXI_RESP_AW_READY_BIT] & i_rst_n_cluster;
  assign o_wready = w_slv_resp_bits[LPARA_AXI_RESP_W_READY_BIT] & i_rst_n_cluster;
  assign {o_bid, o_bresp} = w_slv_resp_bits[
    LPARA_AXI_RESP_B_MSB:LPARA_AXI_RESP_B_LSB+LPARA_AXI_USER_W
  ];
  // Return B VALID only for the selected target response.
  assign o_bvalid = w_slv_resp_bits[LPARA_AXI_RESP_B_VALID_BIT] & i_rst_n_cluster;
  assign o_arready = w_slv_resp_bits[LPARA_AXI_RESP_AR_READY_BIT] & i_rst_n_cluster;
  assign {o_rid, o_rdata, o_rresp, o_rlast} = w_slv_resp_bits[
    LPARA_AXI_RESP_R_MSB:LPARA_AXI_RESP_R_LSB+LPARA_AXI_USER_W
  ];
  // Return R VALID only for the selected target response.
  assign o_rvalid = w_slv_resp_bits[LPARA_AXI_RESP_R_VALID_BIT] & i_rst_n_cluster;

  // Keep region class so the CCU can bypass LLC for normal-uncached traffic.
  assign w_mem_aw_bits = w_mem_target_req_bits[
    LPARA_AXI_REQ_AW_MSB:LPARA_AXI_REQ_AW_LSB
  ];
  // Extract the selected memory target's AR record.
  assign w_mem_ar_bits = w_mem_target_req_bits[
    LPARA_AXI_REQ_AR_MSB:LPARA_AXI_REQ_AR_LSB
  ];
  // Extract the selected memory target's W record.
  assign w_mem_w_bits = w_mem_target_req_bits[
    LPARA_AXI_REQ_W_MSB:LPARA_AXI_REQ_W_LSB
  ];
  // Drive memory AW fields and retain the shared-table route class.
  assign {o_mem_awid, o_mem_awatop, o_mem_awaddr, o_mem_awlen, o_mem_awsize,
          o_mem_awburst, o_mem_awlock, o_mem_awcache, o_mem_awprot, o_mem_awqos,
          o_mem_awregion, o_mem_aw_route_class} = w_mem_aw_bits;
  // Forward the memory write-address handshake.
  assign o_mem_awvalid = w_mem_target_req_bits[LPARA_AXI_REQ_AW_VALID_BIT];
  // Drive the memory write-data payload.
  assign {o_mem_wdata, o_mem_wstrb, o_mem_wlast} = w_mem_w_bits;
  assign o_mem_wvalid = w_mem_target_req_bits[LPARA_AXI_REQ_W_VALID_BIT];
  assign o_mem_bready = w_mem_target_req_bits[LPARA_AXI_REQ_B_READY_BIT];
  assign {o_mem_arid, o_mem_araddr, o_mem_arlen, o_mem_arsize, o_mem_arburst,
          o_mem_arlock, o_mem_arcache, o_mem_arprot, o_mem_arqos, o_mem_arregion,
          o_mem_ar_route_class} = w_mem_ar_bits;
  // Forward the memory read-address handshake.
  assign o_mem_arvalid = w_mem_target_req_bits[LPARA_AXI_REQ_AR_VALID_BIT];
  assign o_mem_rready = w_mem_target_req_bits[LPARA_AXI_REQ_R_READY_BIT];
  assign w_mem_target_resp_bits = {
    i_mem_awready, i_mem_wready, i_mem_bid, i_mem_bresp, 1'b0, i_mem_bvalid,
    i_mem_arready, i_mem_rid, i_mem_rdata, i_mem_rresp, i_mem_rlast, 1'b0, i_mem_rvalid
  };
  assign w_mem_target_resp = axi_resp_type_def'(w_mem_target_resp_bits);

  // Keep standard AXI fields; external fabric decodes the MMIO address.
  assign w_mmio_aw_bits = {
    w_mmio_target_req_bits[LPARA_AXI_REQ_AW_MSB:
      LPARA_AXI_REQ_AW_LSB+LPARA_AXI_AW_ID_LSB],
    w_mmio_target_req_bits[LPARA_AXI_REQ_AW_LSB+LPARA_AXI_AW_ADDR_MSB:
      LPARA_AXI_REQ_AW_LSB+LPARA_AXI_ROUTE_CLASS_W]
  };
  // Strip the internal route class from the MMIO AR payload.
  assign w_mmio_ar_bits = {
    w_mmio_target_req_bits[LPARA_AXI_REQ_AR_MSB:
      LPARA_AXI_REQ_AR_LSB+LPARA_AXI_AR_ID_LSB],
    w_mmio_target_req_bits[LPARA_AXI_REQ_AR_LSB+LPARA_AXI_AR_ADDR_MSB:
      LPARA_AXI_REQ_AR_LSB+LPARA_AXI_ROUTE_CLASS_W]
  };
  // Extract the MMIO W record for the peripheral fabric.
  assign w_mmio_w_bits = w_mmio_target_req_bits[
    LPARA_AXI_REQ_W_MSB:LPARA_AXI_REQ_W_LSB
  ];
  // Forward standard AW fields without internal sidebands.
  assign {o_mmio_awid, o_mmio_awaddr, o_mmio_awlen, o_mmio_awsize, o_mmio_awburst,
          o_mmio_awlock, o_mmio_awcache, o_mmio_awprot, o_mmio_awqos,
          o_mmio_awregion} = w_mmio_aw_bits;
  // Forward the MMIO write-address handshake.
  assign o_mmio_awvalid = w_mmio_target_req_bits[LPARA_AXI_REQ_AW_VALID_BIT];
  assign {o_mmio_wdata, o_mmio_wstrb, o_mmio_wlast} = w_mmio_w_bits;
  assign o_mmio_wvalid = w_mmio_target_req_bits[LPARA_AXI_REQ_W_VALID_BIT];
  assign o_mmio_bready = w_mmio_target_req_bits[LPARA_AXI_REQ_B_READY_BIT];
  assign {o_mmio_arid, o_mmio_araddr, o_mmio_arlen, o_mmio_arsize, o_mmio_arburst,
          o_mmio_arlock, o_mmio_arcache, o_mmio_arprot, o_mmio_arqos,
          o_mmio_arregion} = w_mmio_ar_bits;
  // Forward the MMIO read-address handshake.
  assign o_mmio_arvalid = w_mmio_target_req_bits[LPARA_AXI_REQ_AR_VALID_BIT];
  assign o_mmio_rready = w_mmio_target_req_bits[LPARA_AXI_REQ_R_READY_BIT];
  assign w_mmio_target_resp_bits = {
    i_mmio_awready, i_mmio_wready, i_mmio_bid, i_mmio_bresp, 1'b0, i_mmio_bvalid,
    i_mmio_arready, i_mmio_rid, i_mmio_rdata, i_mmio_rresp, i_mmio_rlast, 1'b0,
    i_mmio_rvalid
  };
  assign w_mmio_target_resp = axi_resp_type_def'(w_mmio_target_resp_bits);

  // Report a local decode error only when the corresponding address handshake is accepted.
  assign o_aw_local_err_event = i_awvalid & o_awready & w_aw_local_err;
  assign o_ar_local_err_event = i_arvalid & o_arready & w_ar_local_err;

endmodule
