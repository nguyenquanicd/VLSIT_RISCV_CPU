/*
 * Project      : VLSIT RISC-V CPU Cluster
 * Author       : Quan Nguyen (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-14
 * Description  : Merges four hart AXI4+ATOP memory channels and preserves source IDs.
 * Rule note    : HIE-02 is intentional: this functional adapter packs flat ports
 *                around an unchanged upstream mux; it is not the structural cluster top.
 */
`timescale 1ns/1ps

module m_vlsit_riscv_axi_mem_mux #(
  // Parameter Description: number of active CVA6 hart request ports.
  // Parameter values: 2 or 4; default is 4.
  // Parameter unit: harts.
  parameter logic [31:0] PARA_CPU_NUM = 32'd4,
  localparam logic [31:0] LPARA_CPU_NUM_DUAL = 32'd2,
  localparam logic [31:0] LPARA_AXI_SRC_NUM = 32'd4,
  localparam logic [31:0] LPARA_AXI_ID_W = 32'd4
) (
  // Clock and reset
  input  wire              i_clk_cluster,
  input  wire              i_rst_n_cluster,

  // AXI4+ATOP memory request and response channels for each fixed hart slot
  input  wire  [3:0][3:0]  i_axi_src_awid,
  input  wire  [3:0][5:0]  i_axi_src_awatop,
  input  wire  [3:0][63:0] i_axi_src_awaddr,
  input  wire  [3:0][7:0]  i_axi_src_awlen,
  input  wire  [3:0][2:0]  i_axi_src_awsize,
  input  wire  [3:0][1:0]  i_axi_src_awburst,
  input  wire  [3:0]       i_axi_src_awlock,
  input  wire  [3:0][3:0]  i_axi_src_awcache,
  input  wire  [3:0][2:0]  i_axi_src_awprot,
  input  wire  [3:0][3:0]  i_axi_src_awqos,
  input  wire  [3:0][3:0]  i_axi_src_awregion,
  input  wire  [3:0]       i_axi_src_awvalid,
  output logic [3:0]       o_axi_src_awready,
  input  wire  [3:0][63:0] i_axi_src_wdata,
  input  wire  [3:0][7:0]  i_axi_src_wstrb,
  input  wire  [3:0]       i_axi_src_wlast,
  input  wire  [3:0]       i_axi_src_wvalid,
  output logic [3:0]       o_axi_src_wready,
  output logic [3:0][3:0]  o_axi_src_bid,
  output logic [3:0][1:0]  o_axi_src_bresp,
  output logic [3:0]       o_axi_src_bvalid,
  input  wire  [3:0]       i_axi_src_bready,
  input  wire  [3:0][3:0]  i_axi_src_arid,
  input  wire  [3:0][63:0] i_axi_src_araddr,
  input  wire  [3:0][7:0]  i_axi_src_arlen,
  input  wire  [3:0][2:0]  i_axi_src_arsize,
  input  wire  [3:0][1:0]  i_axi_src_arburst,
  input  wire  [3:0]       i_axi_src_arlock,
  input  wire  [3:0][3:0]  i_axi_src_arcache,
  input  wire  [3:0][2:0]  i_axi_src_arprot,
  input  wire  [3:0][3:0]  i_axi_src_arqos,
  input  wire  [3:0][3:0]  i_axi_src_arregion,
  input  wire  [3:0]       i_axi_src_arvalid,
  output logic [3:0]       o_axi_src_arready,
  output logic [3:0][3:0]  o_axi_src_rid,
  output logic [3:0][63:0] o_axi_src_rdata,
  output logic [3:0][1:0]  o_axi_src_rresp,
  output logic [3:0]       o_axi_src_rlast,
  output logic [3:0]       o_axi_src_rvalid,
  input  wire  [3:0]       i_axi_src_rready,

  // AXI4+ATOP master channel toward the LLC
  output logic [5:0]       o_axi_llc_awid,
  output logic [5:0]       o_axi_llc_awatop,
  output logic [63:0]      o_axi_llc_awaddr,
  output logic [7:0]       o_axi_llc_awlen,
  output logic [2:0]       o_axi_llc_awsize,
  output logic [1:0]       o_axi_llc_awburst,
  output logic             o_axi_llc_awlock,
  output logic [3:0]       o_axi_llc_awcache,
  output logic [2:0]       o_axi_llc_awprot,
  output logic [3:0]       o_axi_llc_awqos,
  output logic [3:0]       o_axi_llc_awregion,
  output logic             o_axi_llc_awvalid,
  input  wire              i_axi_llc_awready,
  output logic [63:0]      o_axi_llc_wdata,
  output logic [7:0]       o_axi_llc_wstrb,
  output logic             o_axi_llc_wlast,
  output logic             o_axi_llc_wvalid,
  input  wire              i_axi_llc_wready,
  input  wire  [5:0]       i_axi_llc_bid,
  input  wire  [1:0]       i_axi_llc_bresp,
  input  wire              i_axi_llc_bvalid,
  output logic             o_axi_llc_bready,
  output logic [5:0]       o_axi_llc_arid,
  output logic [63:0]      o_axi_llc_araddr,
  output logic [7:0]       o_axi_llc_arlen,
  output logic [2:0]       o_axi_llc_arsize,
  output logic [1:0]       o_axi_llc_arburst,
  output logic             o_axi_llc_arlock,
  output logic [3:0]       o_axi_llc_arcache,
  output logic [2:0]       o_axi_llc_arprot,
  output logic [3:0]       o_axi_llc_arqos,
  output logic [3:0]       o_axi_llc_arregion,
  output logic             o_axi_llc_arvalid,
  input  wire              i_axi_llc_arready,
  input  wire  [5:0]       i_axi_llc_rid,
  input  wire  [63:0]      i_axi_llc_rdata,
  input  wire  [1:0]       i_axi_llc_rresp,
  input  wire              i_axi_llc_rlast,
  input  wire              i_axi_llc_rvalid,
  output logic             o_axi_llc_rready
);

  // Local channel types match the field names and widths of the pinned PULP AXI mux.
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
    logic [5:0] atop;
  } axi_aw_slave_type_def;
  typedef struct packed {
    logic [5:0] id;
    logic [63:0] addr;
    logic [7:0] len;
    logic [2:0] size;
    logic [1:0] burst;
    logic lock;
    logic [3:0] cache;
    logic [2:0] prot;
    logic [3:0] qos;
    logic [3:0] region;
    logic [5:0] atop;
  } axi_aw_master_type_def;
  typedef struct packed {
    logic [63:0] data;
    logic [7:0] strb;
    logic last;
  } axi_w_type_def;
  typedef struct packed {
    logic [3:0] id;
    logic [1:0] resp;
  } axi_b_slave_type_def;
  typedef struct packed {
    logic [5:0] id;
    logic [1:0] resp;
  } axi_b_master_type_def;
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
  } axi_ar_slave_type_def;
  typedef struct packed {
    logic [5:0] id;
    logic [63:0] addr;
    logic [7:0] len;
    logic [2:0] size;
    logic [1:0] burst;
    logic lock;
    logic [3:0] cache;
    logic [2:0] prot;
    logic [3:0] qos;
    logic [3:0] region;
  } axi_ar_master_type_def;
  typedef struct packed {
    logic [3:0] id;
    logic [63:0] data;
    logic [1:0] resp;
    logic last;
  } axi_r_slave_type_def;
  typedef struct packed {
    logic [5:0] id;
    logic [63:0] data;
    logic [1:0] resp;
    logic last;
  } axi_r_master_type_def;
  typedef struct packed {
    axi_aw_slave_type_def aw;
    logic aw_valid;
    axi_w_type_def w;
    logic w_valid;
    logic b_ready;
    axi_ar_slave_type_def ar;
    logic ar_valid;
    logic r_ready;
  } axi_slave_req_type_def;
  typedef struct packed {
    logic aw_ready;
    logic w_ready;
    axi_b_slave_type_def b;
    logic b_valid;
    logic ar_ready;
    axi_r_slave_type_def r;
    logic r_valid;
  } axi_slave_resp_type_def;
  typedef struct packed {
    axi_aw_master_type_def aw;
    logic aw_valid;
    axi_w_type_def w;
    logic w_valid;
    logic b_ready;
    axi_ar_master_type_def ar;
    logic ar_valid;
    logic r_ready;
  } axi_master_req_type_def;
  typedef struct packed {
    logic aw_ready;
    logic w_ready;
    axi_b_master_type_def b;
    logic b_valid;
    logic ar_ready;
    axi_r_master_type_def r;
    logic r_valid;
  } axi_master_resp_type_def;

  // Internal records connect flat ports to PULP AXI request/response records.
  logic [3:0] w_active_hart;
  logic [3:0][$bits(axi_slave_resp_type_def)-1:0] w_slave_resp_bits;
  logic [$bits(axi_master_req_type_def)-1:0] w_master_req_bits;
  axi_slave_req_type_def [3:0] w_slave_req;
  axi_slave_resp_type_def [3:0] w_slave_resp;
  axi_master_req_type_def w_master_req;
  axi_master_resp_type_def w_master_resp;

  // Enable only the configured zero-based hart sources; inactive ports remain quiescent.
  assign w_active_hart = (PARA_CPU_NUM == LPARA_CPU_NUM_DUAL) ? 4'b0011 : 4'b1111;

  // Pack the five AXI channels for each hart; inactive hart slots issue no requests.
  for (genvar gen_hart_idx = 0; gen_hart_idx < LPARA_AXI_SRC_NUM; gen_hart_idx++) begin : gen_axi_hart_map
    // Assemble the complete request record while masking disabled hart sources.
    assign w_slave_req[gen_hart_idx] = {
      axi_aw_slave_type_def'({
        i_axi_src_awid[gen_hart_idx], i_axi_src_awaddr[gen_hart_idx],
        i_axi_src_awlen[gen_hart_idx], i_axi_src_awsize[gen_hart_idx],
        i_axi_src_awburst[gen_hart_idx], i_axi_src_awlock[gen_hart_idx],
        i_axi_src_awcache[gen_hart_idx], i_axi_src_awprot[gen_hart_idx],
        i_axi_src_awqos[gen_hart_idx], i_axi_src_awregion[gen_hart_idx],
        i_axi_src_awatop[gen_hart_idx]
      }),
      (i_axi_src_awvalid[gen_hart_idx] & w_active_hart[gen_hart_idx]),
      axi_w_type_def'{data: i_axi_src_wdata[gen_hart_idx],
                     strb: i_axi_src_wstrb[gen_hart_idx],
                     last: i_axi_src_wlast[gen_hart_idx]},
      (i_axi_src_wvalid[gen_hart_idx] & w_active_hart[gen_hart_idx]),
      (i_axi_src_bready[gen_hart_idx] & w_active_hart[gen_hart_idx]),
      axi_ar_slave_type_def'({
        i_axi_src_arid[gen_hart_idx], i_axi_src_araddr[gen_hart_idx],
        i_axi_src_arlen[gen_hart_idx], i_axi_src_arsize[gen_hart_idx],
        i_axi_src_arburst[gen_hart_idx], i_axi_src_arlock[gen_hart_idx],
        i_axi_src_arcache[gen_hart_idx], i_axi_src_arprot[gen_hart_idx],
        i_axi_src_arqos[gen_hart_idx], i_axi_src_arregion[gen_hart_idx]
      }),
      (i_axi_src_arvalid[gen_hart_idx] & w_active_hart[gen_hart_idx]),
      (i_axi_src_rready[gen_hart_idx] & w_active_hart[gen_hart_idx])
    };
    // Decode the packed slave response fields and suppress inactive-hart responses.
    assign w_slave_resp_bits[gen_hart_idx] = w_slave_resp[gen_hart_idx];
    assign o_axi_src_awready[gen_hart_idx] = w_slave_resp_bits[gen_hart_idx][81]
                                             & w_active_hart[gen_hart_idx];
    // Return the write-data ready handshake only to an active source.
    assign o_axi_src_wready[gen_hart_idx] = w_slave_resp_bits[gen_hart_idx][80]
                                            & w_active_hart[gen_hart_idx];
    // Return each write response and route it only to the active source selected by its ID.
    assign {o_axi_src_bid[gen_hart_idx], o_axi_src_bresp[gen_hart_idx]}
      = w_slave_resp_bits[gen_hart_idx][79:74];
    // Gate write-response VALID with the configured source mask.
    assign o_axi_src_bvalid[gen_hart_idx] = w_slave_resp_bits[gen_hart_idx][73]
                                            & w_active_hart[gen_hart_idx];
    // Return read address and beat status for the selected active source.
    assign o_axi_src_arready[gen_hart_idx] = w_slave_resp_bits[gen_hart_idx][72]
                                             & w_active_hart[gen_hart_idx];
    // Return the read payload and response status selected by the extended ID.
    assign {o_axi_src_rid[gen_hart_idx], o_axi_src_rdata[gen_hart_idx],
            o_axi_src_rresp[gen_hart_idx], o_axi_src_rlast[gen_hart_idx]}
      = w_slave_resp_bits[gen_hart_idx][71:1];
    // Gate read-response VALID with the configured source mask.
    assign o_axi_src_rvalid[gen_hart_idx] = w_slave_resp_bits[gen_hart_idx][0]
                                            & w_active_hart[gen_hart_idx];
  end

  // Reuse the pinned PULP AXI mux for ID extension and response routing.
  axi_mux #(
    .SlvAxiIDWidth(LPARA_AXI_ID_W),
    .slv_aw_chan_t(axi_aw_slave_type_def),
    .mst_aw_chan_t(axi_aw_master_type_def),
    .w_chan_t(axi_w_type_def),
    .slv_b_chan_t(axi_b_slave_type_def),
    .mst_b_chan_t(axi_b_master_type_def),
    .slv_ar_chan_t(axi_ar_slave_type_def),
    .mst_ar_chan_t(axi_ar_master_type_def),
    .slv_r_chan_t(axi_r_slave_type_def),
    .mst_r_chan_t(axi_r_master_type_def),
    .slv_req_t(axi_slave_req_type_def),
    .slv_resp_t(axi_slave_resp_type_def),
    .mst_req_t(axi_master_req_type_def),
    .mst_resp_t(axi_master_resp_type_def),
    .NoSlvPorts(LPARA_AXI_SRC_NUM)
  ) u_dont_touch_axi_mux (
    .clk_i(i_clk_cluster),
    .rst_ni(i_rst_n_cluster),
    .test_i(1'b0),
    .slv_reqs_i(w_slave_req),
    .slv_resps_o(w_slave_resp),
    .mst_req_o(w_master_req),
    .mst_resp_i(w_master_resp)
  );

  // Route the packed AXI request and response records to the LLC.
  // Translate the external manager response pins into the packed AXI response record.
  assign w_master_req_bits = w_master_req;
  assign w_master_resp = axi_master_resp_type_def'({
    i_axi_llc_awready,
    i_axi_llc_wready,
    axi_b_master_type_def'({i_axi_llc_bid, i_axi_llc_bresp}),
    i_axi_llc_bvalid,
    i_axi_llc_arready,
    axi_r_master_type_def'({i_axi_llc_rid, i_axi_llc_rdata,
                            i_axi_llc_rresp, i_axi_llc_rlast}),
    i_axi_llc_rvalid
  });
  // Forward the selected AW payload, including ATOP, to the LLC input.
  assign {o_axi_llc_awid, o_axi_llc_awaddr, o_axi_llc_awlen,
          o_axi_llc_awsize, o_axi_llc_awburst, o_axi_llc_awlock,
          o_axi_llc_awcache, o_axi_llc_awprot, o_axi_llc_awqos,
          o_axi_llc_awregion, o_axi_llc_awatop} = w_master_req_bits[281:177];
  // Forward the selected AW handshake.
  assign o_axi_llc_awvalid = w_master_req_bits[176];
  // Drive write data and response backpressure through the shared AXI mux.
  assign {o_axi_llc_wdata, o_axi_llc_wstrb, o_axi_llc_wlast}
    = w_master_req_bits[175:103];
  // Assert WVALID from the selected packed request record.
  assign o_axi_llc_wvalid = w_master_req_bits[102];
  // Route the selected source's B-channel backpressure to the fabric.
  assign o_axi_llc_bready = w_master_req_bits[101];
  // Drive the selected read address and attributes to the LLC.
  assign {o_axi_llc_arid, o_axi_llc_araddr, o_axi_llc_arlen,
          o_axi_llc_arsize, o_axi_llc_arburst, o_axi_llc_arlock,
          o_axi_llc_arcache, o_axi_llc_arprot, o_axi_llc_arqos,
          o_axi_llc_arregion} = w_master_req_bits[100:2];
  // Assert ARVALID from the selected packed request record.
  assign o_axi_llc_arvalid = w_master_req_bits[1];
  // Route read-response backpressure to the selected source.
  assign o_axi_llc_rready = w_master_req_bits[0];

endmodule
