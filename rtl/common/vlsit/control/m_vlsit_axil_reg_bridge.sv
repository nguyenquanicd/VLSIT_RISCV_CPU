/*
 * Project      : VLSIT RISC-V CPU Cluster
 * Author       : Quan Nguyen (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-08
 * Description  : Converts the LLC AXI4-Lite service window to the PULP RegBus handshake.
 */
`timescale 1ns/1ps

module m_vlsit_axil_reg_bridge #(
  localparam logic [31:0] LPARA_AXIL_RESP_OKAY   = 32'd0,
  localparam logic [31:0] LPARA_AXIL_RESP_SLVERR = 32'd2,
  localparam logic [31:0] LPARA_AXIL_RESP_DECERR = 32'd3,
  localparam logic [31:0] LPARA_LLC_CFG_SPM_LOW  = 32'h00,
  localparam logic [31:0] LPARA_LLC_CFG_SPM_HIGH = 32'h04,
  localparam logic [31:0] LPARA_LLC_CFG_FLUSH_LOW = 32'h08,
  localparam logic [31:0] LPARA_LLC_CFG_FLUSH_HIGH = 32'h0C,
  localparam logic [31:0] LPARA_LLC_COMMIT_CFG = 32'h10,
  localparam logic [31:0] LPARA_LLC_FLUSHED_LOW = 32'h18,
  localparam logic [31:0] LPARA_LLC_FLUSHED_HIGH = 32'h1C,
  localparam logic [31:0] LPARA_LLC_BIST_OUT_LOW = 32'h20,
  localparam logic [31:0] LPARA_LLC_BIST_OUT_HIGH = 32'h24,
  localparam logic [31:0] LPARA_LLC_SET_ASSO_LOW = 32'h28,
  localparam logic [31:0] LPARA_LLC_SET_ASSO_HIGH = 32'h2C,
  localparam logic [31:0] LPARA_LLC_NUM_LINES_LOW = 32'h30,
  localparam logic [31:0] LPARA_LLC_NUM_LINES_HIGH = 32'h34,
  localparam logic [31:0] LPARA_LLC_NUM_BLOCKS_LOW = 32'h38,
  localparam logic [31:0] LPARA_LLC_NUM_BLOCKS_HIGH = 32'h3C,
  localparam logic [31:0] LPARA_LLC_VERSION_LOW = 32'h40,
  localparam logic [31:0] LPARA_LLC_VERSION_HIGH = 32'h44,
  localparam logic [31:0] LPARA_LLC_BIST_STS = 32'h48
) (
  // Clock and reset
  input  wire         i_clk_cluster,
  input  wire         i_rst_n_cluster,

  // AXI4-Lite write address and data channels
  input  wire  [31:0] i_axil_awaddr,
  input  wire  [2:0]  i_axil_awprot,
  input  wire         i_axil_awvalid,
  output logic        o_axil_awready,
  input  wire  [31:0] i_axil_wdata,
  input  wire  [3:0]  i_axil_wstrb,
  input  wire         i_axil_wvalid,
  output logic        o_axil_wready,

  // AXI4-Lite write response channel
  output logic [1:0]  o_axil_bresp,
  output logic        o_axil_bvalid,
  input  wire         i_axil_bready,

  // AXI4-Lite read address and response channels
  input  wire  [31:0] i_axil_araddr,
  input  wire  [2:0]  i_axil_arprot,
  input  wire         i_axil_arvalid,
  output logic        o_axil_arready,
  output logic [31:0] o_axil_rdata,
  output logic [1:0]  o_axil_rresp,
  output logic        o_axil_rvalid,
  input  wire         i_axil_rready,

  // Flattened PULP RegBus request fields
  output logic        o_reg_req_valid,
  output logic        o_reg_req_wr,
  output logic [6:0]  o_reg_req_addr,
  output logic [31:0] o_reg_req_wdata,
  output logic [3:0]  o_reg_req_wstrb,

  // PULP RegBus response fields
  input  wire         i_reg_rsp_ready,
  input  wire  [31:0] i_reg_rsp_rdata,
  input  wire         i_reg_rsp_err
);

  typedef enum logic [2:0] {
    ENUM_ST_IDLE   = 3'b000,
    ENUM_ST_WR_REQ = 3'b001,
    ENUM_ST_RD_REQ = 3'b010
  } axil_reg_fsm_state_type_def;

  axil_reg_fsm_state_type_def reg_fsm_axil_reg_current_state;
  axil_reg_fsm_state_type_def w_fsm_axil_reg_nxt_state;
  logic reg_axi_rr_rd;
  logic reg_aw_pending;
  logic reg_w_pending;
  logic reg_ar_pending;
  logic [31:0] reg_awaddr;
  logic [31:0] reg_wdata;
  logic [3:0] reg_wstrb;
  logic [31:0] reg_araddr;
  logic [6:0] reg_req_addr;
  logic reg_req_wr;
  logic [31:0] reg_req_wdata;
  logic [3:0] reg_req_wstrb;
  logic reg_bvalid;
  logic [1:0] reg_bresp;
  logic reg_rvalid;
  logic [31:0] reg_rdata;
  logic [1:0] reg_rresp;
  logic w_aw_hs;
  logic w_w_hs;
  logic w_ar_hs;
  logic w_wr_available;
  logic w_rd_available;
  logic w_pick_wr;
  logic w_pick_rd;
  logic [31:0] w_wr_addr_selected;
  logic [31:0] w_rd_addr_selected;
  logic w_wr_addr_mapped;
  logic w_rd_addr_mapped;
  logic w_wr_addr_wr_denied;
  logic w_wr_addr_aligned;
  logic w_rd_addr_aligned;
  logic w_wr_dispatch;
  logic w_rd_dispatch;
  logic w_wr_local_err;
  logic w_rd_local_err;
  logic w_reg_req_hs;

  // Expose registered AXI responses and the currently selected RegBus request.
  assign o_axil_bvalid = reg_bvalid;
  assign o_axil_bresp = reg_bresp;
  assign o_axil_rvalid = reg_rvalid;
  assign o_axil_rdata = reg_rdata;
  assign o_axil_rresp = reg_rresp;
  assign o_reg_req_valid = (reg_fsm_axil_reg_current_state != ENUM_ST_IDLE);
  assign o_reg_req_wr = reg_req_wr;
  assign o_reg_req_addr = reg_req_addr;
  assign o_reg_req_wdata = reg_req_wdata;
  assign o_reg_req_wstrb = reg_req_wstrb;
  assign w_aw_hs = i_axil_awvalid & o_axil_awready;
  assign w_w_hs = i_axil_wvalid & o_axil_wready;
  assign w_ar_hs = i_axil_arvalid & o_axil_arready;
  assign w_wr_available = (reg_aw_pending | w_aw_hs) & (reg_w_pending | w_w_hs);
  assign w_rd_available = reg_ar_pending | w_ar_hs;
  assign w_wr_addr_selected = reg_aw_pending ? reg_awaddr : i_axil_awaddr;
  assign w_rd_addr_selected = reg_ar_pending ? reg_araddr : i_axil_araddr;
  assign w_wr_addr_aligned = ~(|w_wr_addr_selected[1:0]);
  assign w_rd_addr_aligned = ~(|w_rd_addr_selected[1:0]);
  assign w_wr_dispatch = (reg_fsm_axil_reg_current_state == ENUM_ST_IDLE) & w_pick_wr;
  assign w_rd_dispatch = (reg_fsm_axil_reg_current_state == ENUM_ST_IDLE) & w_pick_rd;
  assign w_wr_local_err = w_wr_dispatch
                        & (~w_wr_addr_aligned | ~w_wr_addr_mapped | w_wr_addr_wr_denied);
  // Record local read errors before a request reaches the RegBus target.
  assign w_rd_local_err = w_rd_dispatch & (~w_rd_addr_aligned | ~w_rd_addr_mapped);
  // Complete a RegBus request when the target asserts response-ready.
  assign w_reg_req_hs = o_reg_req_valid & i_reg_rsp_ready;

  // Decode pinned LLC register offsets and protect the disabled runtime SPM feature.
  always_comb begin : p_com_axil_reg_map
    w_wr_addr_mapped = 1'b0;
    w_rd_addr_mapped = 1'b0;
    case (w_wr_addr_selected[31:0])
      LPARA_LLC_CFG_SPM_LOW,
      LPARA_LLC_CFG_SPM_HIGH,
      LPARA_LLC_CFG_FLUSH_LOW,
      LPARA_LLC_CFG_FLUSH_HIGH,
      LPARA_LLC_COMMIT_CFG,
      LPARA_LLC_FLUSHED_LOW,
      LPARA_LLC_FLUSHED_HIGH,
      LPARA_LLC_BIST_OUT_LOW,
      LPARA_LLC_BIST_OUT_HIGH,
      LPARA_LLC_SET_ASSO_LOW,
      LPARA_LLC_SET_ASSO_HIGH,
      LPARA_LLC_NUM_LINES_LOW,
      LPARA_LLC_NUM_LINES_HIGH,
      LPARA_LLC_NUM_BLOCKS_LOW,
      LPARA_LLC_NUM_BLOCKS_HIGH,
      LPARA_LLC_VERSION_LOW,
      LPARA_LLC_VERSION_HIGH,
      LPARA_LLC_BIST_STS: w_wr_addr_mapped = 1'b1;
      default: w_wr_addr_mapped = 1'b0;
    endcase
    case (w_rd_addr_selected[31:0])
      LPARA_LLC_CFG_SPM_LOW,
      LPARA_LLC_CFG_SPM_HIGH,
      LPARA_LLC_CFG_FLUSH_LOW,
      LPARA_LLC_CFG_FLUSH_HIGH,
      LPARA_LLC_COMMIT_CFG,
      LPARA_LLC_FLUSHED_LOW,
      LPARA_LLC_FLUSHED_HIGH,
      LPARA_LLC_BIST_OUT_LOW,
      LPARA_LLC_BIST_OUT_HIGH,
      LPARA_LLC_SET_ASSO_LOW,
      LPARA_LLC_SET_ASSO_HIGH,
      LPARA_LLC_NUM_LINES_LOW,
      LPARA_LLC_NUM_LINES_HIGH,
      LPARA_LLC_NUM_BLOCKS_LOW,
      LPARA_LLC_NUM_BLOCKS_HIGH,
      LPARA_LLC_VERSION_LOW,
      LPARA_LLC_VERSION_HIGH,
      LPARA_LLC_BIST_STS: w_rd_addr_mapped = 1'b1;
      default: w_rd_addr_mapped = 1'b0;
    endcase
    w_wr_addr_wr_denied = 1'b0;
    case (w_wr_addr_selected[31:0])
      LPARA_LLC_CFG_SPM_LOW,
      LPARA_LLC_CFG_SPM_HIGH,
      LPARA_LLC_FLUSHED_LOW,
      LPARA_LLC_FLUSHED_HIGH,
      LPARA_LLC_BIST_OUT_LOW,
      LPARA_LLC_BIST_OUT_HIGH,
      LPARA_LLC_SET_ASSO_LOW,
      LPARA_LLC_SET_ASSO_HIGH,
      LPARA_LLC_NUM_LINES_LOW,
      LPARA_LLC_NUM_LINES_HIGH,
      LPARA_LLC_NUM_BLOCKS_LOW,
      LPARA_LLC_NUM_BLOCKS_HIGH,
      LPARA_LLC_VERSION_LOW,
      LPARA_LLC_VERSION_HIGH,
      LPARA_LLC_BIST_STS: w_wr_addr_wr_denied = 1'b1;
      default: w_wr_addr_wr_denied = 1'b0;
    endcase
  end

  // Arbitrate simultaneous read and write requests with alternating priority.
  always_comb begin : p_com_axil_reg_fsm
    w_pick_wr = 1'b0;
    w_pick_rd = 1'b0;
    w_fsm_axil_reg_nxt_state = reg_fsm_axil_reg_current_state;
    casez ({w_wr_available, w_rd_available, reg_axi_rr_rd})
      3'b111: w_pick_rd = 1'b1;
      3'b110: w_pick_wr = 1'b1;
      3'b10?: w_pick_wr = 1'b1;
      3'b01?: w_pick_rd = 1'b1;
      default: begin
        w_pick_wr = 1'b0;
        w_pick_rd = 1'b0;
      end
    endcase
    case (reg_fsm_axil_reg_current_state)
      ENUM_ST_IDLE: begin
        if (w_pick_wr & w_wr_addr_aligned & w_wr_addr_mapped)
          w_fsm_axil_reg_nxt_state = ENUM_ST_WR_REQ;
        else if (w_pick_rd & w_rd_addr_aligned & w_rd_addr_mapped)
          w_fsm_axil_reg_nxt_state = ENUM_ST_RD_REQ;
      end
      ENUM_ST_WR_REQ,
      ENUM_ST_RD_REQ: begin
        if (w_reg_req_hs)
          w_fsm_axil_reg_nxt_state = ENUM_ST_IDLE;
      end
      default: w_fsm_axil_reg_nxt_state = ENUM_ST_IDLE;
    endcase
  end

  // Advance the request state only when the RegBus target accepts the request.
  always_ff @(posedge i_clk_cluster, negedge i_rst_n_cluster) begin : p_ff_axil_reg_fsm
    if (!i_rst_n_cluster)
      reg_fsm_axil_reg_current_state <= ENUM_ST_IDLE;
    else
      reg_fsm_axil_reg_current_state <= w_fsm_axil_reg_nxt_state;
  end

  // Capture the independent AXI address/data channels and preserve response payloads.
  always_ff @(posedge i_clk_cluster, negedge i_rst_n_cluster) begin : p_ff_axil_reg_data
    if (!i_rst_n_cluster) begin
      reg_axi_rr_rd <= 1'b1;
      reg_aw_pending <= 1'b0;
      reg_w_pending <= 1'b0;
      reg_ar_pending <= 1'b0;
      reg_awaddr <= '0;
      reg_wdata <= '0;
      reg_wstrb <= '0;
      reg_araddr <= '0;
      reg_req_addr <= '0;
      reg_req_wr <= 1'b0;
      reg_req_wdata <= '0;
      reg_req_wstrb <= '0;
      reg_bvalid <= 1'b0;
      reg_bresp <= 2'(LPARA_AXIL_RESP_OKAY);
      reg_rvalid <= 1'b0;
      reg_rdata <= '0;
      reg_rresp <= 2'(LPARA_AXIL_RESP_OKAY);
    end else begin
      if (w_aw_hs)
        reg_awaddr <= i_axil_awaddr;
      if (w_w_hs) begin
        reg_wdata <= i_axil_wdata;
        reg_wstrb <= i_axil_wstrb;
      end
      if (w_ar_hs)
        reg_araddr <= i_axil_araddr;
      if (w_wr_dispatch) begin
        reg_aw_pending <= 1'b0;
        reg_w_pending <= 1'b0;
        reg_req_addr <= w_wr_addr_selected[6:0];
        reg_req_wr <= 1'b1;
        reg_req_wdata <= reg_w_pending ? reg_wdata : i_axil_wdata;
        reg_req_wstrb <= reg_w_pending ? reg_wstrb : i_axil_wstrb;
        reg_axi_rr_rd <= 1'b1;
      end else begin
        if (w_aw_hs)
          reg_aw_pending <= 1'b1;
        if (w_w_hs)
          reg_w_pending <= 1'b1;
      end
      if (w_rd_dispatch) begin
        reg_ar_pending <= 1'b0;
        reg_req_addr <= w_rd_addr_selected[6:0];
        reg_req_wr <= 1'b0;
        reg_req_wdata <= '0;
        reg_req_wstrb <= '0;
        reg_axi_rr_rd <= 1'b0;
      end else if (w_ar_hs) begin
        reg_ar_pending <= 1'b1;
      end
      casez ({w_wr_local_err, (w_reg_req_hs & reg_req_wr),
              (reg_bvalid & i_axil_bready)})
        3'b1??: begin
          reg_bvalid <= 1'b1;
          reg_bresp <= (w_wr_addr_aligned & w_wr_addr_mapped)
                     ? 2'(LPARA_AXIL_RESP_SLVERR)
                     : (w_wr_addr_aligned ? 2'(LPARA_AXIL_RESP_DECERR)
                                          : 2'(LPARA_AXIL_RESP_SLVERR));
        end
        3'b01?: begin
          reg_bvalid <= 1'b1;
          reg_bresp <= i_reg_rsp_err ? 2'(LPARA_AXIL_RESP_SLVERR)
                                     : 2'(LPARA_AXIL_RESP_OKAY);
        end
        3'b001: reg_bvalid <= 1'b0;
        default: reg_bvalid <= reg_bvalid;
      endcase
      casez ({w_rd_local_err, (w_reg_req_hs & ~reg_req_wr),
              (reg_rvalid & i_axil_rready)})
        3'b1??: begin
          reg_rvalid <= 1'b1;
          reg_rdata <= '0;
          reg_rresp <= w_rd_addr_aligned ? 2'(LPARA_AXIL_RESP_DECERR)
                                         : 2'(LPARA_AXIL_RESP_SLVERR);
        end
        3'b01?: begin
          reg_rvalid <= 1'b1;
          reg_rdata <= i_reg_rsp_err ? '0 : i_reg_rsp_rdata;
          reg_rresp <= i_reg_rsp_err ? 2'(LPARA_AXIL_RESP_SLVERR)
                                     : 2'(LPARA_AXIL_RESP_OKAY);
        end
        3'b001: reg_rvalid <= 1'b0;
        default: reg_rvalid <= reg_rvalid;
      endcase
    end
  end

  // Gate each request channel until its prior response has been accepted.
  always_comb begin : p_com_axil_ready
    o_axil_awready = ~reg_aw_pending & ~reg_bvalid
                   & (reg_fsm_axil_reg_current_state != ENUM_ST_WR_REQ);
    o_axil_wready = ~reg_w_pending & ~reg_bvalid
                  & (reg_fsm_axil_reg_current_state != ENUM_ST_WR_REQ);
    o_axil_arready = ~reg_ar_pending & ~reg_rvalid
                   & (reg_fsm_axil_reg_current_state != ENUM_ST_RD_REQ);
  end

endmodule
