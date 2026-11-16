/*
 * Project      : VLSIT RISC-V CPU Cluster
 * Author       : Quan Nguyen (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-14
 * Description  : CVA6 tile wrapper with PMA generated from the shared address table.
 * Decision     : DEC-037
 * Change History:
 * 2026-11-14 - Quan Nguyen and Codex - VLSI Technology page:
 *              Export per-AW/AR region classification from the shared table.
 *  2026-11-14 - Quan Nguyen and Codex - VLSI Technology page:
 *              Export matched HPDcache flush B-response metadata to the tile boundary.
 * Rule note    : This functional adapter contains one CVA6 instance and required flat-port mapping.
 */
`timescale 1ns/1ps

module m_vlsit_riscv_cpu_tile #(
  // Parameter Description: physical-address region count shared by CVA6 PMA and router.
  // Parameter values: 1 through 16; default contains the CVA6 cacheable window.
  // Parameter unit: regions.
  parameter logic [31:0] PARA_ADDR_REGION_NUM = 32'd1,
  // Parameter Description: low 32 bits of each region base address.
  // Parameter values: active entries are 16-byte aligned and below 2^56.
  // Parameter unit: bytes.
  parameter logic [31:0] PARA_ADDR_REGION_BASE_LO [0:15] = '{default:32'd0, 0:32'h8000_0000},
  // Parameter Description: high 32 bits of each region base address.
  // Parameter values: active entries are 16-byte aligned and below 2^56.
  // Parameter unit: bytes.
  parameter logic [31:0] PARA_ADDR_REGION_BASE_HI [0:15] = '{default:32'd0},
  // Parameter Description: low 32 bits of each region size.
  // Parameter values: active entries are non-zero 16-byte multiples.
  // Parameter unit: bytes.
  parameter logic [31:0] PARA_ADDR_REGION_SIZE_LO [0:15] = '{default:32'd0, 0:32'h4000_0000},
  // Parameter Description: high 32 bits of each region size.
  // Parameter values: active entries are 16-byte multiples.
  // Parameter unit: bytes.
  parameter logic [31:0] PARA_ADDR_REGION_SIZE_HI [0:15] = '{default:32'd0},
  // Parameter Description: region class word; low bits encode the address class.
  // Parameter values: 0 cacheable, 1 normal uncached, 2 MMIO; 3 is reserved.
  // Parameter unit: none.
  parameter logic [31:0] PARA_ADDR_REGION_TYPE [0:15] = '{default:32'd0},
  localparam logic [31:0] LPARA_AXI_MAX_SIZE = 32'd3,
  localparam logic [31:0] LPARA_AXI_WRAP_LEN_2 = 32'd1,
  localparam logic [31:0] LPARA_AXI_WRAP_LEN_4 = 32'd3,
  localparam logic [31:0] LPARA_AXI_WRAP_LEN_8 = 32'd7,
  localparam logic [31:0] LPARA_AXI_WRAP_LEN_16 = 32'd15
) (
  // Clock, reset, boot and hart identity
  input  wire         i_clk_tile,
  input  wire         i_rst_n_tile,
  input  wire  [63:0] i_boot_addr,
  input  wire  [63:0] i_hart_id,

  // Per-hart interrupt and debug request inputs
  input  wire         i_int_msip,
  input  wire         i_int_mtip,
  input  wire         i_int_meip,
  input  wire         i_int_ssip,
  input  wire         i_int_stip,
  input  wire         i_int_seip,
  input  wire         i_hart_debug_req,
  output logic        o_hart_debug_mode,
  output logic [21:0] o_perf_event,
  output logic        o_dcache_flush_ack_valid,
  output logic [51:0] o_dcache_flush_ack_nline,
  output logic [1:0]  o_dcache_flush_ack_origin,
  output logic        o_dcache_flush_ack_error,
  output logic        o_dcache_flush_rsp_invalid,

  // CVA6 AXI4 request channels
  output logic [3:0]  o_axi_awid,
  output logic [5:0]  o_axi_awatop,
  output logic [63:0] o_axi_awaddr,
  output logic [7:0]  o_axi_awlen,
  output logic [2:0]  o_axi_awsize,
  output logic [1:0]  o_axi_awburst,
  output logic        o_axi_awlock,
  output logic [3:0]  o_axi_awcache,
  output logic [2:0]  o_axi_awprot,
  output logic [3:0]  o_axi_awqos,
  output logic [3:0]  o_axi_awregion,
  output logic        o_axi_awvalid,
  output logic        o_axi_aw_region_match,
  output logic [3:0]  o_axi_aw_region_idx,
  output logic [1:0]  o_axi_aw_region_type,
  output logic        o_axi_aw_region_err,
  input  wire         i_axi_awready,
  output logic [63:0] o_axi_wdata,
  output logic [7:0]  o_axi_wstrb,
  output logic        o_axi_wlast,
  output logic        o_axi_wvalid,
  input  wire         i_axi_wready,
  input  wire  [3:0]  i_axi_bid,
  input  wire  [1:0]  i_axi_bresp,
  input  wire         i_axi_bvalid,
  output logic        o_axi_bready,
  output logic [3:0]  o_axi_arid,
  output logic [63:0] o_axi_araddr,
  output logic [7:0]  o_axi_arlen,
  output logic [2:0]  o_axi_arsize,
  output logic [1:0]  o_axi_arburst,
  output logic        o_axi_arlock,
  output logic [3:0]  o_axi_arcache,
  output logic [2:0]  o_axi_arprot,
  output logic [3:0]  o_axi_arqos,
  output logic [3:0]  o_axi_arregion,
  output logic        o_axi_arvalid,
  output logic        o_axi_ar_region_match,
  output logic [3:0]  o_axi_ar_region_idx,
  output logic [1:0]  o_axi_ar_region_type,
  output logic        o_axi_ar_region_err,
  output logic        o_addr_region_config_valid,
  input  wire         i_axi_arready,
  input  wire  [3:0]  i_axi_rid,
  input  wire  [63:0] i_axi_rdata,
  input  wire  [1:0]  i_axi_rresp,
  input  wire         i_axi_rlast,
  input  wire         i_axi_rvalid,
  output logic        o_axi_rready
);

  // Packed records match CVA6's AXI type parameters while keeping VLSIT ports flat.
  logic [469:0] w_axi_req;
  logic [209:0] w_axi_resp;
  logic [75:0] w_axi_aw_access_window;
  logic [75:0] w_axi_ar_access_window;
  logic w_aw_region_config_valid;
  logic w_ar_region_config_valid;
  logic w_aw_region_match;
  logic w_ar_region_match;
  logic [3:0] w_aw_region_idx;
  logic [3:0] w_ar_region_idx;
  logic [1:0] w_aw_region_type;
  logic [1:0] w_ar_region_type;
  logic w_aw_region_err;
  logic w_ar_region_err;

  // Function Description: return the conservative byte window covered by one AXI burst.
  function automatic logic [75:0] f_axi_access_window(
    input logic [63:0] i_addr,
    input logic [7:0]  i_len,
    input logic [2:0]  i_size,
    input logic [1:0]  i_burst
  );
    logic [63:0] v_start;
    logic [63:0] v_span;
    logic [63:0] v_total_bytes;
    logic [63:0] v_beat_bytes;
    logic [63:0] v_addr_offset;
    logic [8:0]  v_beat_count;
    begin
      v_start = i_addr;
      v_span = '0;
      v_total_bytes = '0;
      v_beat_bytes = '0;
      v_addr_offset = '0;
      v_beat_count = {1'b0, i_len} + 9'd1;
      if (32'(i_size) <= LPARA_AXI_MAX_SIZE) begin
        v_beat_bytes = 64'd1 << i_size;
        v_addr_offset = i_addr & (v_beat_bytes - 64'd1);
        v_total_bytes = v_beat_bytes * 64'(v_beat_count);
        case (i_burst)
          2'b00: v_span = v_beat_bytes - v_addr_offset;
          2'b01: v_span = v_total_bytes - v_addr_offset;
          2'b10: begin
            if ((32'(i_len) == LPARA_AXI_WRAP_LEN_2) | (32'(i_len) == LPARA_AXI_WRAP_LEN_4) |
                (32'(i_len) == LPARA_AXI_WRAP_LEN_8) | (32'(i_len) == LPARA_AXI_WRAP_LEN_16)) begin
              if (v_addr_offset == 64'd0)
                v_span = v_total_bytes;
              v_start = i_addr & ~(v_span - 64'd1);
            end
          end
          default: begin
            v_span = '0;
          end
        endcase
      end
      return {v_start, 12'(v_span)};
    end
  endfunction

  // Build the CVA6 response record; AXI USER is not in the approved cluster boundary.
  assign w_axi_resp = {
    i_axi_awready,
    i_axi_arready,
    i_axi_wready,
    i_axi_bvalid,
    i_axi_bid,
    i_axi_bresp,
    64'd0,
    i_axi_rvalid,
    i_axi_rid,
    i_axi_rdata,
    i_axi_rresp,
    i_axi_rlast,
    64'd0
  };

  // Slice the fixed selected-configuration CVA6 request record into approved AXI fields.
  assign {o_axi_awid, o_axi_awaddr, o_axi_awlen, o_axi_awsize, o_axi_awburst,
          o_axi_awlock, o_axi_awcache, o_axi_awprot, o_axi_awqos, o_axi_awregion,
          o_axi_awatop} = w_axi_req[469:367];
  // Forward the write-address handshake with no additional buffering.
  assign o_axi_awvalid = w_axi_req[302];
  // Forward write payload and handshake fields from the CVA6 channel record.
  assign {o_axi_wdata, o_axi_wstrb, o_axi_wlast} = w_axi_req[301:229];
  // Forward the write-data and write-response flow control.
  assign o_axi_wvalid = w_axi_req[164];
  assign o_axi_bready = w_axi_req[163];
  // Forward the read request fields without changing address or AXI ID.
  assign {o_axi_arid, o_axi_araddr, o_axi_arlen, o_axi_arsize, o_axi_arburst,
          o_axi_arlock, o_axi_arcache, o_axi_arprot, o_axi_arqos, o_axi_arregion} = w_axi_req[162:66];
  // Forward read-address and read-data handshakes.
  assign o_axi_arvalid = w_axi_req[1];
  assign o_axi_rready = w_axi_req[0];

  // Decode complete AW/AR windows with the same parameter table used to build CVA6 PMA.
  assign w_axi_aw_access_window = f_axi_access_window(
    o_axi_awaddr, o_axi_awlen, o_axi_awsize, o_axi_awburst);
  // Decode the read burst independently so AW and AR may classify concurrently.
  assign w_axi_ar_access_window = f_axi_access_window(
    o_axi_araddr, o_axi_arlen, o_axi_arsize, o_axi_arburst);
  // Return the write-address region result beside the matching AW request.
  assign o_axi_aw_region_match = w_aw_region_match;
  assign o_axi_aw_region_idx = w_aw_region_idx;
  assign o_axi_aw_region_type = w_aw_region_type;
  assign o_axi_aw_region_err = w_aw_region_err | ~w_aw_region_config_valid;
  // Return the read-address region result beside the matching AR request.
  assign o_axi_ar_region_match = w_ar_region_match;
  assign o_axi_ar_region_idx = w_ar_region_idx;
  assign o_axi_ar_region_type = w_ar_region_type;
  assign o_axi_ar_region_err = w_ar_region_err | ~w_ar_region_config_valid;
  assign o_addr_region_config_valid = w_aw_region_config_valid & w_ar_region_config_valid;

  m_vlsit_riscv_addr_decode #(
    .PARA_ADDR_REGION_NUM(PARA_ADDR_REGION_NUM),
    .PARA_ADDR_REGION_BASE_LO(PARA_ADDR_REGION_BASE_LO),
    .PARA_ADDR_REGION_BASE_HI(PARA_ADDR_REGION_BASE_HI),
    .PARA_ADDR_REGION_SIZE_LO(PARA_ADDR_REGION_SIZE_LO),
    .PARA_ADDR_REGION_SIZE_HI(PARA_ADDR_REGION_SIZE_HI),
    .PARA_ADDR_REGION_TYPE(PARA_ADDR_REGION_TYPE)
  ) u_vlsit_riscv_addr_decode_aw (
    .i_phys_addr(w_axi_aw_access_window[75:12]),
    .i_access_bytes(w_axi_aw_access_window[11:0]),
    .i_atomic((|o_axi_awatop) | o_axi_awlock),
    .o_config_valid(w_aw_region_config_valid),
    .o_region_match(w_aw_region_match),
    .o_region_idx(w_aw_region_idx),
    .o_region_type(w_aw_region_type),
    .o_access_err(w_aw_region_err)
  );

  m_vlsit_riscv_addr_decode #(
    .PARA_ADDR_REGION_NUM(PARA_ADDR_REGION_NUM),
    .PARA_ADDR_REGION_BASE_LO(PARA_ADDR_REGION_BASE_LO),
    .PARA_ADDR_REGION_BASE_HI(PARA_ADDR_REGION_BASE_HI),
    .PARA_ADDR_REGION_SIZE_LO(PARA_ADDR_REGION_SIZE_LO),
    .PARA_ADDR_REGION_SIZE_HI(PARA_ADDR_REGION_SIZE_HI),
    .PARA_ADDR_REGION_TYPE(PARA_ADDR_REGION_TYPE)
  ) u_vlsit_riscv_addr_decode_ar (
    .i_phys_addr(w_axi_ar_access_window[75:12]),
    .i_access_bytes(w_axi_ar_access_window[11:0]),
    .i_atomic(o_axi_arlock),
    .o_config_valid(w_ar_region_config_valid),
    .o_region_match(w_ar_region_match),
    .o_region_idx(w_ar_region_idx),
    .o_region_type(w_ar_region_type),
    .o_access_err(w_ar_region_err)
  );

  // Instantiate the selected CVA6 configuration with PMA ranges derived from DEC-037.
  cva6 #(
    .CVA6Cfg(build_config_pkg::build_config_with_addr_regions(
      cva6_config_pkg::cva6_cfg,
      PARA_ADDR_REGION_NUM,
      PARA_ADDR_REGION_BASE_LO,
      PARA_ADDR_REGION_BASE_HI,
      PARA_ADDR_REGION_SIZE_LO,
      PARA_ADDR_REGION_SIZE_HI,
      PARA_ADDR_REGION_TYPE
    ))
  ) u_dont_touch_cva6 (
    .clk_i(i_clk_tile),
    .rst_ni(i_rst_n_tile),
    .boot_addr_i(i_boot_addr),
    .hart_id_i(i_hart_id),
    .irq_i({i_int_meip, i_int_seip}),
    .ipi_i(i_int_msip),
    .time_irq_i(i_int_mtip),
    .s_ipi_i(i_int_ssip),
    .s_time_irq_i(i_int_stip),
    .debug_req_i(i_hart_debug_req),
    .perf_event_o(o_perf_event),
    .debug_mode_o(o_hart_debug_mode),
    .dcache_flush_ack_valid_o(o_dcache_flush_ack_valid),
    .dcache_flush_ack_nline_o(o_dcache_flush_ack_nline),
    .dcache_flush_ack_origin_o(o_dcache_flush_ack_origin),
    .dcache_flush_ack_error_o(o_dcache_flush_ack_error),
    .dcache_flush_rsp_invalid_o(o_dcache_flush_rsp_invalid),
    .rvfi_probes_o(),
    .cvxif_req_o(),
    .cvxif_resp_i('0),
    .noc_req_o(w_axi_req),
    .noc_resp_i(w_axi_resp)
  );

endmodule
