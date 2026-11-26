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
 *  2026-11-14 - Quan Nguyen and Codex - VLSI Technology page:
 *              Export the same-line HPDcache MSHR/refill busy query for coherence control.
 *  2026-11-14 - Quan Nguyen and Codex - VLSI Technology page:
 *              Forward active tagged CCU line-lock vectors into CVA6/HPDcache.
 *  2026-11-14 - Quan Nguyen and Codex - VLSI Technology page:
 *              Preserve CCU transaction tags across native directory lookup.
 *  2026-11-14 - Quan Nguyen and Codex - VLSI Technology page:
 *              Export and return HPDcache permission requests before refills.
 * 2026-11-15 - Quan Nguyen and Codex - VLSI Technology page:
 *              Export native HPDcache performance event indicators.
 * 2026-11-15 - Quan Nguyen and Codex - VLSI Technology page:
 *              Export oldest pending CBO operation and address metadata.
 * 2026-11-20 - Modified by Quan Nguyen and Codex - VLSI Technology page:
 *              Correct MEIP/SEIP bit ordering at the CVA6 irq_i boundary (R-02).
 * 2026-11-25 - Modified by Quan Nguyen and Claude - VLSI Technology page:
 *              RV32 profile (DEC-104): adapt core-side line, virtual-address and identity widths
 *              to the unchanged 52-bit/64-bit tile ports; identity connections in the 64-bit build.
 * Rule note    : This functional adapter contains one CVA6 instance and required flat-port mapping.
 * Waiver       : TYP-07 on the PARA_ADDR_REGION_* arrays ([0:15]) is pre-existing and waived by the
 *              designer (RV32 change plan v1, Q4); the same declaration spans 7 files and the TOP.
 */
`timescale 1ns/1ps

// 2026-11-15 - Quan Nguyen and Codex - VLSI Technology page:
// Use inactive scalar CVXIF boundary types for the approved CVXIF-disabled core configuration.
module m_vlsit_riscv_cpu_tile #(
  // Parameter Description: enable the internal CMO retirement/service path.
  // Parameter values: 0 or 1; default 0 for standalone adapters.
  // Parameter unit: none.
  parameter logic [31:0] PARA_CMO_EN = 32'd0,
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
  // Parameter Description: number of tagged CCU line-lock slots passed to HPDcache.
  // Parameter values: 2 through 16; default is 8.
  // Parameter unit: line locks.
  parameter logic [31:0] PARA_COH_TXN_NUM = 32'd8,
  localparam logic [31:0] LPARA_COH_TAG_W = (PARA_COH_TXN_NUM > 32'd1)
                                           ? 32'($clog2(PARA_COH_TXN_NUM)) : 32'd1,
  localparam logic [31:0] LPARA_AXI_MAX_SIZE = 32'd3,
  localparam logic [31:0] LPARA_AXI_WRAP_LEN_2 = 32'd1,
  localparam logic [31:0] LPARA_AXI_WRAP_LEN_4 = 32'd3,
  localparam logic [31:0] LPARA_AXI_WRAP_LEN_8 = 32'd7,
  localparam logic [31:0] LPARA_AXI_WRAP_LEN_16 = 32'd15,
  // DEC-104: core-side widths of the selected CVA6 package. VLEN equals XLEN for Sv32 and Sv39,
  // and PLEN follows build_config_pkg (34 for RV32, 56 for RV64); line address = PLEN - 4.
  localparam logic [31:0] LPARA_CORE_XLEN = 32'(cva6_config_pkg::CVA6ConfigXlen),
  localparam logic [31:0] LPARA_CORE_VLEN = LPARA_CORE_XLEN,
  localparam logic [31:0] LPARA_CORE_NLINE_W = (LPARA_CORE_XLEN == 32'd32) ? 32'd30 : 32'd52
) (
  // Clock, reset, boot and hart identity
  input  wire                               i_clk_tile,
  input  wire                               i_rst_n_tile,
  input  wire  [63:0]                       i_boot_addr,
  input  wire  [63:0]                       i_hart_id,

  // Retirement-owned CMO command and completion.
  output logic                              o_cmo_req_valid,
  input  wire                               i_cmo_req_ready,
  output logic [1:0]                        o_cmo_req_op,
  output logic [51:0]                       o_cmo_req_pa_line,
  output logic [63:0]                       o_cmo_req_vaddr,
  output logic [63:0]                       o_cmo_req_pc,
  input  wire                               i_cmo_rsp_done,
  input  wire                               i_cmo_rsp_err,

  // Per-hart interrupt and debug request inputs
  input  wire                               i_int_msip,
  input  wire                               i_int_mtip,
  input  wire                               i_int_meip,
  input  wire                               i_int_ssip,
  input  wire                               i_int_stip,
  input  wire                               i_int_seip,
  input  wire                               i_hart_debug_req,
  output logic                              o_hart_debug_mode,
  output logic [21:0]                       o_perf_event,
  output logic [15:0]                       o_hpdcache_perf_event,
  output logic                              o_dcache_flush_ack_valid,
  output logic [51:0]                       o_dcache_flush_ack_nline,
  output logic [1:0]                        o_dcache_flush_ack_origin,
  output logic                              o_dcache_flush_ack_err,
  output logic                              o_dcache_flush_rsp_invalid,

  // Oldest speculative CBO metadata consumed by retirement.
  output logic                              o_cmo_entry_valid,
  output logic [7:0]                        o_cmo_entry_op,
  output logic [51:0]                       o_cmo_entry_pa_line,
  output logic [63:0]                       o_cmo_entry_vaddr,

  // Same-line outstanding-miss/refill query; this is not a cache probe or line lock.
  input  wire                               i_coh_probe_query_valid,
  input  wire  [51:0]                       i_coh_probe_query_nline,
  output logic                              o_coh_probe_line_busy,
  output logic                              o_coh_access_line_valid,
  output logic [51:0]                       o_coh_access_nline,
  output logic                              o_coh_victim_line_valid,
  output logic [51:0]                       o_coh_victim_nline,

  // Active per-tag PREPARE locks; each entry is a physical cache-line address.
  input  wire  [PARA_COH_TXN_NUM-1:0]       i_coh_line_lock_valid,
  input  wire  [PARA_COH_TXN_NUM-1:0][51:0] i_coh_line_lock_nline,

  // Native two-phase cache probe endpoint used by the tile-coherence adapter.
  input  wire                               i_coh_probe_req_valid,
  output logic                              o_coh_probe_req_ready,
  input  wire  [LPARA_COH_TAG_W-1:0]        i_coh_probe_req_tag,
  input  wire  [51:0]                       i_coh_probe_req_nline,
  input  wire  [1:0]                        i_coh_probe_req_phase,
  input  wire  [1:0]                        i_coh_probe_req_target_state,
  input  wire                               i_coh_probe_req_wback_en,
  output logic                              o_coh_probe_rsp_valid,
  input  wire                               i_coh_probe_rsp_ready,
  output logic [LPARA_COH_TAG_W-1:0]        o_coh_probe_rsp_tag,
  output logic [51:0]                       o_coh_probe_rsp_nline,
  output logic [1:0]                        o_coh_probe_rsp_phase,
  output logic [1:0]                        o_coh_probe_rsp_state,
  output logic                              o_coh_probe_rsp_err,
  output logic                              o_coh_probe_rsp_wback_done,

  // Per-cache ownership permission request/grant; refill AR waits for a grant.
  output logic                              o_coh_cache_req_valid,
  input  wire                               i_coh_cache_req_ready,
  output logic [2:0]                        o_coh_cache_req_id,
  output logic [51:0]                       o_coh_cache_req_nline,
  output logic [1:0]                        o_coh_cache_req_kind,
  input  wire                               i_coh_cache_gnt_valid,
  output logic                              o_coh_cache_gnt_ready,
  input  wire  [2:0]                        i_coh_cache_gnt_id,
  input  wire  [51:0]                       i_coh_cache_gnt_nline,
  input  wire  [1:0]                        i_coh_cache_gnt_state,
  input  wire                               i_coh_cache_gnt_err,

  // CVA6 AXI4 request channels
  output logic [3:0]                        o_axi_awid,
  output logic [5:0]                        o_axi_awatop,
  output logic [63:0]                       o_axi_awaddr,
  output logic [7:0]                        o_axi_awlen,
  output logic [2:0]                        o_axi_awsize,
  output logic [1:0]                        o_axi_awburst,
  output logic                              o_axi_awlock,
  output logic [3:0]                        o_axi_awcache,
  output logic [2:0]                        o_axi_awprot,
  output logic [3:0]                        o_axi_awqos,
  output logic [3:0]                        o_axi_awregion,
  output logic                              o_axi_awvalid,
  output logic                              o_axi_aw_region_match,
  output logic [3:0]                        o_axi_aw_region_idx,
  output logic [1:0]                        o_axi_aw_region_type,
  output logic                              o_axi_aw_region_err,
  input  wire                               i_axi_awready,
  output logic [63:0]                       o_axi_wdata,
  output logic [7:0]                        o_axi_wstrb,
  output logic                              o_axi_wlast,
  output logic                              o_axi_wvalid,
  input  wire                               i_axi_wready,
  input  wire  [3:0]                        i_axi_bid,
  input  wire  [1:0]                        i_axi_bresp,
  input  wire                               i_axi_bvalid,
  output logic                              o_axi_bready,
  output logic [3:0]                        o_axi_arid,
  output logic [63:0]                       o_axi_araddr,
  output logic [7:0]                        o_axi_arlen,
  output logic [2:0]                        o_axi_arsize,
  output logic [1:0]                        o_axi_arburst,
  output logic                              o_axi_arlock,
  output logic [3:0]                        o_axi_arcache,
  output logic [2:0]                        o_axi_arprot,
  output logic [3:0]                        o_axi_arqos,
  output logic [3:0]                        o_axi_arregion,
  output logic                              o_axi_arvalid,
  output logic                              o_axi_ar_region_match,
  output logic [3:0]                        o_axi_ar_region_idx,
  output logic [1:0]                        o_axi_ar_region_type,
  output logic                              o_axi_ar_region_err,
  output logic                              o_addr_region_config_valid,
  input  wire                               i_axi_arready,
  input  wire  [3:0]                        i_axi_rid,
  input  wire  [63:0]                       i_axi_rdata,
  input  wire  [1:0]                        i_axi_rresp,
  input  wire                               i_axi_rlast,
  input  wire                               i_axi_rvalid,
  output logic                              o_axi_rready
);

  // Core-side boot address, identity and CMO virtual addresses.
  logic [LPARA_CORE_VLEN-1:0]    w_core_boot_addr;
  logic [LPARA_CORE_XLEN-1:0]    w_core_hart_id;
  logic [LPARA_CORE_VLEN-1:0]    w_core_cmo_req_vaddr;
  logic [LPARA_CORE_VLEN-1:0]    w_core_cmo_req_pc;
  logic [LPARA_CORE_VLEN-1:0]    w_core_cmo_entry_vaddr;
  // Core-side cache-line addresses.
  logic [LPARA_CORE_NLINE_W-1:0] w_core_cmo_req_pa_line;
  logic [LPARA_CORE_NLINE_W-1:0] w_core_cmo_entry_pa_line;
  logic [LPARA_CORE_NLINE_W-1:0] w_core_flush_ack_nline;
  logic [LPARA_CORE_NLINE_W-1:0] w_core_access_nline;
  logic [LPARA_CORE_NLINE_W-1:0] w_core_victim_nline;
  logic [LPARA_CORE_NLINE_W-1:0] w_core_probe_rsp_nline;
  logic [LPARA_CORE_NLINE_W-1:0] w_core_own_req_nline;
  logic [LPARA_CORE_NLINE_W-1:0] w_core_probe_query_nline;
  logic [LPARA_CORE_NLINE_W-1:0] w_core_probe_req_nline;
  logic [LPARA_CORE_NLINE_W-1:0] w_core_own_gnt_nline;

  // Pass the low bits into the core; the cluster guarantees zero upper bits (REQ-XL-007/008).
  assign w_core_boot_addr         = i_boot_addr[LPARA_CORE_VLEN-1:0];
  assign w_core_hart_id           = i_hart_id[LPARA_CORE_XLEN-1:0];
  assign w_core_probe_query_nline = i_coh_probe_query_nline[LPARA_CORE_NLINE_W-1:0];
  assign w_core_probe_req_nline   = i_coh_probe_req_nline[LPARA_CORE_NLINE_W-1:0];
  assign w_core_own_gnt_nline     = i_coh_cache_gnt_nline[LPARA_CORE_NLINE_W-1:0];
  // Zero-extend core outputs to the unchanged tile port widths.
  assign o_cmo_req_vaddr          = 64'(w_core_cmo_req_vaddr);
  assign o_cmo_req_pc             = 64'(w_core_cmo_req_pc);
  assign o_cmo_entry_vaddr        = 64'(w_core_cmo_entry_vaddr);
  assign o_cmo_req_pa_line        = 52'(w_core_cmo_req_pa_line);
  assign o_cmo_entry_pa_line      = 52'(w_core_cmo_entry_pa_line);
  assign o_dcache_flush_ack_nline = 52'(w_core_flush_ack_nline);
  assign o_coh_access_nline       = 52'(w_core_access_nline);
  assign o_coh_victim_nline       = 52'(w_core_victim_nline);
  assign o_coh_probe_rsp_nline    = 52'(w_core_probe_rsp_nline);
  assign o_coh_cache_req_nline    = 52'(w_core_own_req_nline);

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
  logic [15:0] w_coh_line_lock_valid;
  logic [15:0][LPARA_CORE_NLINE_W-1:0] w_coh_line_lock_nline;
  logic [3:0] w_coh_probe_rsp_tag;
  logic w_coh_probe_rsp_err;

  // Adapt the synthesis-time context count to the pinned cache's fixed maximum.
  always_comb begin : p_com_coh_lock_expand
    w_coh_line_lock_valid = '0;
    w_coh_line_lock_nline = '0;
    for (int lock_idx = 0; lock_idx < PARA_COH_TXN_NUM; lock_idx++) begin
      w_coh_line_lock_valid[lock_idx] = i_coh_line_lock_valid[lock_idx];
      w_coh_line_lock_nline[lock_idx] = i_coh_line_lock_nline[lock_idx][LPARA_CORE_NLINE_W-1:0];
    end
  end

  // Adapt the configured transaction tag width to HPDcache's four-bit maximum.
  assign o_coh_probe_rsp_tag = LPARA_COH_TAG_W'(w_coh_probe_rsp_tag);
  assign o_coh_probe_rsp_err = w_coh_probe_rsp_err;

  // Function Description: return the conservative byte window covered by one AXI burst.
  function automatic logic [75:0] f_axi_access_window(
    input logic [63:0] i_addr,
    input logic [7:0]  i_len,
    input logic [2:0]  i_size,
    input logic [1:0]  i_burst
  );
    logic [63:0] w_start;
    logic [63:0] w_span;
    logic [63:0] w_total_bytes;
    logic [63:0] w_beat_bytes;
    logic [63:0] w_addr_offset;
    logic [8:0]  w_beat_count;
    begin
      w_start = i_addr;
      w_span = '0;
      w_total_bytes = '0;
      w_beat_bytes = '0;
      w_addr_offset = '0;
      w_beat_count = {1'b0, i_len} + 9'd1;
      if (32'(i_size) <= LPARA_AXI_MAX_SIZE) begin
        w_beat_bytes = 64'd1 << i_size;
        w_addr_offset = i_addr & (w_beat_bytes - 64'd1);
        w_total_bytes = w_beat_bytes * 64'(w_beat_count);
        case (i_burst)
          2'b00: w_span = w_beat_bytes - w_addr_offset;
          2'b01: w_span = w_total_bytes - w_addr_offset;
          2'b10: begin
            if ((32'(i_len) == LPARA_AXI_WRAP_LEN_2) | (32'(i_len) == LPARA_AXI_WRAP_LEN_4) |
                (32'(i_len) == LPARA_AXI_WRAP_LEN_8) | (32'(i_len) == LPARA_AXI_WRAP_LEN_16)) begin
              if (w_addr_offset == 64'd0)
                w_span = w_total_bytes;
              w_start = i_addr & ~(w_span - 64'd1);
            end
          end
          default: begin
            w_span = '0;
          end
        endcase
      end
      return {w_start, 12'(w_span)};
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
    .ExternalCmo(PARA_CMO_EN != 0),
    .cvxif_req_t(logic),
    .cvxif_resp_t(logic),
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
    .cmo_valid_o(o_cmo_req_valid), .cmo_ready_i(i_cmo_req_ready),
    .cmo_op_o(o_cmo_req_op), .cmo_pa_line_o(w_core_cmo_req_pa_line),
    .cmo_vaddr_o(w_core_cmo_req_vaddr), .cmo_pc_o(w_core_cmo_req_pc),
    .cmo_done_i(i_cmo_rsp_done), .cmo_error_i(i_cmo_rsp_err),
    .clk_i(i_clk_tile),
    .rst_ni(i_rst_n_tile),
    .boot_addr_i(w_core_boot_addr),
    .hart_id_i(w_core_hart_id),
    // CVA6 maps irq_i[0] to MEIP and irq_i[1] to SEIP.
    .irq_i({i_int_seip, i_int_meip}),
    .ipi_i(i_int_msip),
    .time_irq_i(i_int_mtip),
    .s_ipi_i(i_int_ssip),
    .s_time_irq_i(i_int_stip),
    .debug_req_i(i_hart_debug_req),
    .perf_event_o(o_perf_event),
    .hpdcache_perf_event_o(o_hpdcache_perf_event),
    .debug_mode_o(o_hart_debug_mode),
    .dcache_flush_ack_valid_o(o_dcache_flush_ack_valid),
    .dcache_flush_ack_nline_o(w_core_flush_ack_nline),
    .dcache_flush_ack_origin_o(o_dcache_flush_ack_origin),
    .dcache_flush_ack_error_o(o_dcache_flush_ack_err),
    .dcache_flush_rsp_invalid_o(o_dcache_flush_rsp_invalid),
    .cmo_entry_valid_o(o_cmo_entry_valid),
    .cmo_entry_op_o(o_cmo_entry_op),
    .cmo_entry_pa_line_o(w_core_cmo_entry_pa_line),
    .cmo_entry_vaddr_o(w_core_cmo_entry_vaddr),
    .dcache_probe_query_valid_i(i_coh_probe_query_valid),
    .dcache_probe_query_nline_i(w_core_probe_query_nline),
    .dcache_probe_line_busy_o(o_coh_probe_line_busy),
    .dcache_access_line_valid_o(o_coh_access_line_valid),
    .dcache_access_nline_o(w_core_access_nline),
    .dcache_victim_line_valid_o(o_coh_victim_line_valid),
    .dcache_victim_nline_o(w_core_victim_nline),
    .dcache_coh_lock_valid_i(w_coh_line_lock_valid),
    .dcache_coh_lock_nline_i(w_coh_line_lock_nline),
    .dcache_probe_req_valid_i(i_coh_probe_req_valid),
    .dcache_probe_req_ready_o(o_coh_probe_req_ready),
    .dcache_probe_req_tag_i(4'(i_coh_probe_req_tag)),
    .dcache_probe_req_nline_i(w_core_probe_req_nline),
    .dcache_probe_req_phase_i(i_coh_probe_req_phase),
    .dcache_probe_req_target_state_i(i_coh_probe_req_target_state),
    .dcache_probe_req_wback_en_i(i_coh_probe_req_wback_en),
    .dcache_probe_rsp_valid_o(o_coh_probe_rsp_valid),
    .dcache_probe_rsp_ready_i(i_coh_probe_rsp_ready),
    .dcache_probe_rsp_tag_o(w_coh_probe_rsp_tag),
    .dcache_probe_rsp_nline_o(w_core_probe_rsp_nline),
    .dcache_probe_rsp_phase_o(o_coh_probe_rsp_phase),
    .dcache_probe_rsp_state_o(o_coh_probe_rsp_state),
    .dcache_probe_rsp_error_o(w_coh_probe_rsp_err),
    .dcache_probe_rsp_wback_done_o(o_coh_probe_rsp_wback_done),
    .dcache_own_req_valid_o(o_coh_cache_req_valid),
    .dcache_own_req_ready_i(i_coh_cache_req_ready),
    .dcache_own_req_id_o(o_coh_cache_req_id),
    .dcache_own_req_nline_o(w_core_own_req_nline),
    .dcache_own_req_kind_o(o_coh_cache_req_kind),
    .dcache_own_gnt_valid_i(i_coh_cache_gnt_valid),
    .dcache_own_gnt_ready_o(o_coh_cache_gnt_ready),
    .dcache_own_gnt_id_i(i_coh_cache_gnt_id),
    .dcache_own_gnt_nline_i(w_core_own_gnt_nline),
    .dcache_own_gnt_state_i(i_coh_cache_gnt_state),
    .dcache_own_gnt_error_i(i_coh_cache_gnt_err),
    .rvfi_probes_o(),
    .cvxif_req_o(),
    .cvxif_resp_i('0),
    .noc_req_o(w_axi_req),
    .noc_resp_i(w_axi_resp)
  );

endmodule
