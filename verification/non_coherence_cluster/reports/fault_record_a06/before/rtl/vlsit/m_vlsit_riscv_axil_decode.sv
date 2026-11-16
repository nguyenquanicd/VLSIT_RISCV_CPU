/*
 * Project      : VLSIT RISC-V CPU Cluster
 * Author       : Quan Nguyen (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-08
 * Description  : Routes the cluster AXI4-Lite aperture to CSR and LLC service targets.
 */
`timescale 1ns/1ps

module m_vlsit_riscv_axil_decode #(
  // Parameter Description: absolute base address of the contiguous CSR and LLC windows.
  // Parameter values: 4-KiB aligned values from 0 through 0xFFFFE000; default is 0.
  // Parameter unit: bytes
  parameter logic [31:0] PARA_AXIL_BASE_ADDR = 32'h0000_0000,
  localparam logic [31:0] LPARA_AXIL_CSR_WIN_BYTES = 32'd4096,
  localparam logic [31:0] LPARA_AXIL_TOTAL_WIN_BYTES = 32'd8192,
  localparam logic [31:0] LPARA_AXIL_MAX_BASE_ADDR = 32'hFFFF_E000,
  localparam logic [31:0] LPARA_AXIL_CSR_IDX = 32'd0,
  localparam logic [31:0] LPARA_AXIL_LLC_IDX = 32'd1,
  localparam logic [31:0] LPARA_AXI_RESP_SLVERR = 32'd2,
  localparam logic [31:0] LPARA_AXI_RESP_DECERR = 32'd3,
  localparam logic [31:0] LPARA_WR_ST_IDLE = 32'd0,
  localparam logic [31:0] LPARA_WR_ST_DECODE = 32'd1,
  localparam logic [31:0] LPARA_WR_ST_ISSUE = 32'd2,
  localparam logic [31:0] LPARA_WR_ST_WAIT_B = 32'd3,
  localparam logic [31:0] LPARA_WR_ST_LOCAL_B = 32'd4,
  localparam logic [31:0] LPARA_RD_ST_IDLE = 32'd0,
  localparam logic [31:0] LPARA_RD_ST_DECODE = 32'd1,
  localparam logic [31:0] LPARA_RD_ST_ISSUE = 32'd2,
  localparam logic [31:0] LPARA_RD_ST_WAIT_R = 32'd3,
  localparam logic [31:0] LPARA_RD_ST_LOCAL_R = 32'd4
) (
  // Clock and reset
  input  wire              i_clk_cluster,
  input  wire              i_rst_n_cluster,

  // External AXI4-Lite subordinate interface
  input  wire  [31:0]      i_axil_awaddr,
  input  wire  [2:0]       i_axil_awprot,
  input  wire              i_axil_awvalid,
  output logic             o_axil_awready,
  input  wire  [31:0]      i_axil_wdata,
  input  wire  [3:0]       i_axil_wstrb,
  input  wire              i_axil_wvalid,
  output logic             o_axil_wready,
  output logic [1:0]       o_axil_bresp,
  output logic             o_axil_bvalid,
  input  wire              i_axil_bready,
  input  wire  [31:0]      i_axil_araddr,
  input  wire  [2:0]       i_axil_arprot,
  input  wire              i_axil_arvalid,
  output logic             o_axil_arready,
  output logic [31:0]      o_axil_rdata,
  output logic [1:0]       o_axil_rresp,
  output logic             o_axil_rvalid,
  input  wire              i_axil_rready,

  // CSR and LLC service target interface: index 0 is CSR; index 1 is LLC service
  output logic [1:0][31:0] o_axil_target_awaddr,
  output logic [1:0][2:0]  o_axil_target_awprot,
  output logic [1:0]       o_axil_target_awvalid,
  input  wire  [1:0]       i_axil_target_awready,
  output logic [1:0][31:0] o_axil_target_wdata,
  output logic [1:0][3:0]  o_axil_target_wstrb,
  output logic [1:0]       o_axil_target_wvalid,
  input  wire  [1:0]       i_axil_target_wready,
  input  wire  [1:0][1:0]  i_axil_target_bresp,
  input  wire  [1:0]       i_axil_target_bvalid,
  output logic [1:0]       o_axil_target_bready,
  output logic [1:0][31:0] o_axil_target_araddr,
  output logic [1:0][2:0]  o_axil_target_arprot,
  output logic [1:0]       o_axil_target_arvalid,
  input  wire  [1:0]       i_axil_target_arready,
  input  wire  [1:0][31:0] i_axil_target_rdata,
  input  wire  [1:0][1:0]  i_axil_target_rresp,
  input  wire  [1:0]       i_axil_target_rvalid,
  output logic [1:0]       o_axil_target_rready
);

  logic [2:0] reg_wr_state;
  logic [2:0] reg_rd_state;
  logic reg_aw_have;
  logic reg_w_have;
  logic [31:0] reg_awaddr;
  logic [2:0] reg_awprot;
  logic [31:0] reg_wdata;
  logic [3:0] reg_wstrb;
  logic reg_wr_target;
  logic reg_wr_aw_sent;
  logic reg_wr_w_sent;
  logic [1:0] reg_wr_local_resp;
  logic [31:0] reg_araddr;
  logic [2:0] reg_arprot;
  logic reg_rd_target;
  logic reg_rd_ar_sent;
  logic [1:0] reg_rd_local_resp;
  logic [31:0] w_wr_rel_addr;
  logic [31:0] w_rd_rel_addr;
  logic w_axil_base_valid;
  logic w_wr_aw_hs;
  logic w_wr_w_hs;
  logic w_rd_ar_hs;
  logic w_wr_b_hs;
  logic w_rd_r_hs;
  logic w_aw_capture_hs;
  logic w_w_capture_hs;

  // Compute relative addresses and validate the compile-time window base.
  assign w_wr_rel_addr = reg_awaddr - PARA_AXIL_BASE_ADDR;
  assign w_rd_rel_addr = reg_araddr - PARA_AXIL_BASE_ADDR;
  assign w_axil_base_valid = (PARA_AXIL_BASE_ADDR[11:0] == 12'b0)
                           & (PARA_AXIL_BASE_ADDR <= LPARA_AXIL_MAX_BASE_ADDR);

  // Route registered requests and response backpressure to the selected target.
  always_comb begin : p_com_axil_target
    o_axil_target_awaddr = '0;
    o_axil_target_awprot = '0;
    o_axil_target_awvalid = '0;
    o_axil_target_wdata = '0;
    o_axil_target_wstrb = '0;
    o_axil_target_wvalid = '0;
    o_axil_target_bready = '0;
    o_axil_target_araddr = '0;
    o_axil_target_arprot = '0;
    o_axil_target_arvalid = '0;
    o_axil_target_rready = '0;

    if (reg_wr_state == LPARA_WR_ST_ISSUE[2:0]) begin
      if (reg_wr_target == 1'b0) begin
        o_axil_target_awaddr[LPARA_AXIL_CSR_IDX] = {20'b0, w_wr_rel_addr[11:0]};
        o_axil_target_awprot[LPARA_AXIL_CSR_IDX] = reg_awprot;
        o_axil_target_awvalid[LPARA_AXIL_CSR_IDX] = ~reg_wr_aw_sent;
        o_axil_target_wdata[LPARA_AXIL_CSR_IDX] = reg_wdata;
        o_axil_target_wstrb[LPARA_AXIL_CSR_IDX] = reg_wstrb;
        o_axil_target_wvalid[LPARA_AXIL_CSR_IDX] = ~reg_wr_w_sent;
      end else begin
        o_axil_target_awaddr[LPARA_AXIL_LLC_IDX] = {20'b0, w_wr_rel_addr[11:0]};
        o_axil_target_awprot[LPARA_AXIL_LLC_IDX] = reg_awprot;
        o_axil_target_awvalid[LPARA_AXIL_LLC_IDX] = ~reg_wr_aw_sent;
        o_axil_target_wdata[LPARA_AXIL_LLC_IDX] = reg_wdata;
        o_axil_target_wstrb[LPARA_AXIL_LLC_IDX] = reg_wstrb;
        o_axil_target_wvalid[LPARA_AXIL_LLC_IDX] = ~reg_wr_w_sent;
      end
    end

    if (reg_wr_state == LPARA_WR_ST_WAIT_B[2:0])
      o_axil_target_bready[reg_wr_target] = i_axil_bready;

    if (reg_rd_state == LPARA_RD_ST_ISSUE[2:0]) begin
      if (reg_rd_target == 1'b0) begin
        o_axil_target_araddr[LPARA_AXIL_CSR_IDX] = {20'b0, w_rd_rel_addr[11:0]};
        o_axil_target_arprot[LPARA_AXIL_CSR_IDX] = reg_arprot;
        o_axil_target_arvalid[LPARA_AXIL_CSR_IDX] = ~reg_rd_ar_sent;
      end else begin
        o_axil_target_araddr[LPARA_AXIL_LLC_IDX] = {20'b0, w_rd_rel_addr[11:0]};
        o_axil_target_arprot[LPARA_AXIL_LLC_IDX] = reg_arprot;
        o_axil_target_arvalid[LPARA_AXIL_LLC_IDX] = ~reg_rd_ar_sent;
      end
    end

    if (reg_rd_state == LPARA_RD_ST_WAIT_R[2:0])
      o_axil_target_rready[reg_rd_target] = i_axil_rready;
  end

  // Form handshakes only from the selected active AXI4-Lite channel.
  always_comb begin : p_com_axil_handshake
    w_aw_capture_hs = i_axil_awvalid & o_axil_awready;
    w_w_capture_hs = i_axil_wvalid & o_axil_wready;
    w_wr_aw_hs = 1'b0;
    w_wr_w_hs = 1'b0;
    w_rd_ar_hs = 1'b0;
    w_wr_b_hs = 1'b0;
    w_rd_r_hs = 1'b0;
    if (reg_wr_state == LPARA_WR_ST_ISSUE[2:0]) begin
      w_wr_aw_hs = o_axil_target_awvalid[reg_wr_target]
                 & i_axil_target_awready[reg_wr_target];
      w_wr_w_hs = o_axil_target_wvalid[reg_wr_target]
                & i_axil_target_wready[reg_wr_target];
    end
    if (reg_rd_state == LPARA_RD_ST_ISSUE[2:0])
      w_rd_ar_hs = o_axil_target_arvalid[reg_rd_target]
                 & i_axil_target_arready[reg_rd_target];
    if (reg_wr_state == LPARA_WR_ST_WAIT_B[2:0])
      w_wr_b_hs = o_axil_bvalid & i_axil_bready;
    if (reg_rd_state == LPARA_RD_ST_WAIT_R[2:0])
      w_rd_r_hs = o_axil_rvalid & i_axil_rready;
  end

  // Return either the selected downstream response or the registered local decode error.
  always_comb begin : p_com_axil_resp
    o_axil_awready = (reg_wr_state == LPARA_WR_ST_IDLE[2:0]) & ~reg_aw_have;
    o_axil_wready = (reg_wr_state == LPARA_WR_ST_IDLE[2:0]) & ~reg_w_have;
    o_axil_bresp = reg_wr_local_resp;
    o_axil_bvalid = (reg_wr_state == LPARA_WR_ST_LOCAL_B[2:0]);
    if (reg_wr_state == LPARA_WR_ST_WAIT_B[2:0]) begin
      o_axil_bresp = i_axil_target_bresp[reg_wr_target];
      o_axil_bvalid = i_axil_target_bvalid[reg_wr_target];
    end

    o_axil_arready = (reg_rd_state == LPARA_RD_ST_IDLE[2:0]);
    o_axil_rdata = 32'b0;
    o_axil_rresp = reg_rd_local_resp;
    o_axil_rvalid = 1'b0;
    if (reg_rd_state == LPARA_RD_ST_WAIT_R[2:0]) begin
      o_axil_rdata = i_axil_target_rdata[reg_rd_target];
      o_axil_rresp = i_axil_target_rresp[reg_rd_target];
      o_axil_rvalid = i_axil_target_rvalid[reg_rd_target];
    end else if (reg_rd_state == LPARA_RD_ST_LOCAL_R[2:0]) begin
      o_axil_rvalid = 1'b1;
    end
  end

  // Capture independent AW and W transfers, then route them to a single target.
  always_ff @(posedge i_clk_cluster, negedge i_rst_n_cluster) begin : p_ff_axil_wr
    if (!i_rst_n_cluster) begin
      reg_wr_state <= LPARA_WR_ST_IDLE[2:0];
      reg_aw_have <= 1'b0;
      reg_w_have <= 1'b0;
      reg_awaddr <= '0;
      reg_awprot <= '0;
      reg_wdata <= '0;
      reg_wstrb <= '0;
      reg_wr_target <= 1'b0;
      reg_wr_aw_sent <= 1'b0;
      reg_wr_w_sent <= 1'b0;
      reg_wr_local_resp <= LPARA_AXI_RESP_DECERR[1:0];
    end else begin
      case (reg_wr_state)
        LPARA_WR_ST_IDLE[2:0]: begin
          if (w_aw_capture_hs) begin
            reg_aw_have <= 1'b1;
            reg_awaddr <= i_axil_awaddr;
            reg_awprot <= i_axil_awprot;
          end
          if (w_w_capture_hs) begin
            reg_w_have <= 1'b1;
            reg_wdata <= i_axil_wdata;
            reg_wstrb <= i_axil_wstrb;
          end
          if ((reg_aw_have | w_aw_capture_hs) & (reg_w_have | w_w_capture_hs))
            reg_wr_state <= LPARA_WR_ST_DECODE[2:0];
        end
        LPARA_WR_ST_DECODE[2:0]: begin
          reg_wr_aw_sent <= 1'b0;
          reg_wr_w_sent <= 1'b0;
          case (1'b1)
            (reg_awaddr[1:0] != 2'b00): begin
            reg_wr_local_resp <= LPARA_AXI_RESP_SLVERR[1:0];
              reg_wr_state <= LPARA_WR_ST_LOCAL_B[2:0];
            end
            (w_axil_base_valid & (w_wr_rel_addr < LPARA_AXIL_CSR_WIN_BYTES)): begin
              reg_wr_target <= 1'b0;
              reg_wr_state <= LPARA_WR_ST_ISSUE[2:0];
            end
            (w_axil_base_valid & (w_wr_rel_addr < LPARA_AXIL_TOTAL_WIN_BYTES)): begin
              reg_wr_target <= 1'b1;
              reg_wr_state <= LPARA_WR_ST_ISSUE[2:0];
            end
            default: begin
            reg_wr_local_resp <= LPARA_AXI_RESP_DECERR[1:0];
              reg_wr_state <= LPARA_WR_ST_LOCAL_B[2:0];
            end
          endcase
        end
        LPARA_WR_ST_ISSUE[2:0]: begin
          if (w_wr_aw_hs)
            reg_wr_aw_sent <= 1'b1;
          if (w_wr_w_hs)
            reg_wr_w_sent <= 1'b1;
          if ((reg_wr_aw_sent | w_wr_aw_hs) & (reg_wr_w_sent | w_wr_w_hs))
            reg_wr_state <= LPARA_WR_ST_WAIT_B[2:0];
        end
        LPARA_WR_ST_WAIT_B[2:0]: begin
          if (w_wr_b_hs) begin
            reg_wr_state <= LPARA_WR_ST_IDLE[2:0];
            reg_aw_have <= 1'b0;
            reg_w_have <= 1'b0;
          end
        end
        LPARA_WR_ST_LOCAL_B[2:0]: begin
          if (i_axil_bready) begin
            reg_wr_state <= LPARA_WR_ST_IDLE[2:0];
            reg_aw_have <= 1'b0;
            reg_w_have <= 1'b0;
          end
        end
        default: reg_wr_state <= LPARA_WR_ST_IDLE[2:0];
      endcase
    end
  end

  // Accept one read address at a time and preserve target response backpressure.
  always_ff @(posedge i_clk_cluster, negedge i_rst_n_cluster) begin : p_ff_axil_rd
    if (!i_rst_n_cluster) begin
      reg_rd_state <= LPARA_RD_ST_IDLE[2:0];
      reg_araddr <= '0;
      reg_arprot <= '0;
      reg_rd_target <= 1'b0;
      reg_rd_ar_sent <= 1'b0;
      reg_rd_local_resp <= LPARA_AXI_RESP_DECERR[1:0];
    end else begin
      case (reg_rd_state)
        LPARA_RD_ST_IDLE[2:0]: begin
          if (i_axil_arvalid & o_axil_arready) begin
            reg_araddr <= i_axil_araddr;
            reg_arprot <= i_axil_arprot;
            reg_rd_state <= LPARA_RD_ST_DECODE[2:0];
          end
        end
        LPARA_RD_ST_DECODE[2:0]: begin
          reg_rd_ar_sent <= 1'b0;
          case (1'b1)
            (reg_araddr[1:0] != 2'b00): begin
            reg_rd_local_resp <= LPARA_AXI_RESP_SLVERR[1:0];
              reg_rd_state <= LPARA_RD_ST_LOCAL_R[2:0];
            end
            (w_axil_base_valid & (w_rd_rel_addr < LPARA_AXIL_CSR_WIN_BYTES)): begin
              reg_rd_target <= 1'b0;
              reg_rd_state <= LPARA_RD_ST_ISSUE[2:0];
            end
            (w_axil_base_valid & (w_rd_rel_addr < LPARA_AXIL_TOTAL_WIN_BYTES)): begin
              reg_rd_target <= 1'b1;
              reg_rd_state <= LPARA_RD_ST_ISSUE[2:0];
            end
            default: begin
            reg_rd_local_resp <= LPARA_AXI_RESP_DECERR[1:0];
              reg_rd_state <= LPARA_RD_ST_LOCAL_R[2:0];
            end
          endcase
        end
        LPARA_RD_ST_ISSUE[2:0]: begin
          if (w_rd_ar_hs) begin
            reg_rd_ar_sent <= 1'b1;
            reg_rd_state <= LPARA_RD_ST_WAIT_R[2:0];
          end
        end
        LPARA_RD_ST_WAIT_R[2:0]: begin
          if (w_rd_r_hs)
            reg_rd_state <= LPARA_RD_ST_IDLE[2:0];
        end
        LPARA_RD_ST_LOCAL_R[2:0]: begin
          if (i_axil_rready)
            reg_rd_state <= LPARA_RD_ST_IDLE[2:0];
        end
        default: reg_rd_state <= LPARA_RD_ST_IDLE[2:0];
      endcase
    end
  end

endmodule
