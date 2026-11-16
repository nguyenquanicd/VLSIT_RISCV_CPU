/*
 * Project      : VLSIT RISC-V CPU Cluster
 * Author       : Quan Nguyen (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-15
 * Change History: 2026-11-16 - Quan Nguyen and Codex - VLSI Technology page:
 *   DEC-039/040: capture reset-only fatal metadata and expose RO fault CSR.
 * Description  : Integrates CPU tiles, AXI routing, shared LLC, CSR, and PMU.
 * Change History:
 * 2026-11-15 - Quan Nguyen and Codex - VLSI Technology page:
 *              Create the first structural AXI-profile core integration.
 * 2026-11-15 - Quan Nguyen and Codex - VLSI Technology page:
 *              Route per-hart pending CBO metadata from CVA6 tiles to the core boundary.
 * 2026-11-15 - Quan Nguyen and Codex - VLSI Technology page:
 *              Route retained LLC writeback fault to cluster status/interrupt.
 */
// 2026-11-15 - Quan Nguyen and Codex - VLSI Technology page:
// DEC-036/A-03: retain ordinary-eviction fatal IRQ until cluster reset.
`timescale 1ns/1ps

// 2026-11-15 - Quan Nguyen and Codex - VLSI Technology page:
// Size the native LLC test-enable connection explicitly to one bit.
module m_vlsit_riscv_cluster_core #(
  // Parameter Description: number of active CVA6 harts.
  // Parameter values: 2 or 4; default is 4.
  // Parameter unit: harts.
  parameter logic [31:0] PARA_CPU_NUM = 32'd4,
  // Parameter Description: number of independent coherence transaction contexts.
  // Parameter values: 2 through 16; default is 8.
  // Parameter unit: contexts.
  parameter logic [31:0] PARA_COH_TXN_NUM = 32'd8,
  // Parameter Description: LLC associativity.
  // Parameter values: 1 through 32; default is 4, subject to axi_llc limits.
  // Parameter unit: ways.
  parameter logic [31:0] PARA_LLC_WAY_NUM = 32'd4,
  // Parameter Description: number of cache lines in each LLC way.
  // Parameter values: power of two greater than 2; default is 4096.
  // Parameter unit: lines per way.
  parameter logic [31:0] PARA_LLC_NO_LINES = 32'd4096,
  // Parameter Description: number of 64-bit blocks in each LLC line.
  // Parameter values: power of two and at least 2; default is 2.
  // Parameter unit: blocks.
  parameter logic [31:0] PARA_LLC_BLOCK_NUM = 32'd2,
  // Parameter Description: AXI4-Lite base address for the 4-KiB CSR and LLC windows.
  // Parameter values: 4-KiB aligned addresses from 0 through 0xFFFFA000; default is 0.
  // Parameter unit: bytes.
  parameter logic [31:0] PARA_AXIL_BASE_ADDR = 32'h0000_0000,
  // Parameter Description: number of programmable cluster performance counters.
  // Parameter values: 1 through 32; default is 16.
  // Parameter unit: counters.
  parameter logic [31:0] PARA_PMU_COUNTER_NUM = 32'd16,
  // Parameter Description: width of each programmable counter.
  // Parameter values: 32 or 64; default is 64.
  // Parameter unit: bits.
  parameter logic [31:0] PARA_PMU_COUNTER_W = 32'd64,
  // Parameter Description: number of active physical-address regions shared by PMA and router.
  // Parameter values: 1 through 16; default is the CVA6 cacheable range only.
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
  // Parameter Description: low 32 bits of each region byte length.
  // Parameter values: active lengths are non-zero 16-byte multiples.
  // Parameter unit: bytes.
  parameter logic [31:0] PARA_ADDR_REGION_SIZE_LO [0:15] = '{default:32'd0, 0:32'h4000_0000},
  // Parameter Description: high 32 bits of each region byte length.
  // Parameter values: active lengths are 16-byte multiples.
  // Parameter unit: bytes.
  parameter logic [31:0] PARA_ADDR_REGION_SIZE_HI [0:15] = '{default:32'd0},
  // Parameter Description: bits [1:0] carry class; upper bits must be zero.
  // Parameter values: 0 cacheable, 1 normal uncached, 2 MMIO; 3 is reserved.
  // Parameter unit: none.
  parameter logic [31:0] PARA_ADDR_REGION_TYPE [0:15] = '{default:32'd0},
  localparam logic [31:0] LPARA_LLC_TEST_EN = 32'd0,
  localparam logic [31:0] LPARA_CPU_NUM_DUAL = 32'd2) (
  // Clock and reset
  input  wire                              i_clk_cluster,
  input  wire                              i_rst_n_cluster,

  // Boot, interrupt, debug, and PMU status
  input  wire  [63:0]                      i_boot_addr,
  input  wire  [3:0]                       i_int_msip,
  input  wire  [3:0]                       i_int_mtip,
  input  wire  [3:0]                       i_int_meip,
  input  wire  [3:0]                       i_int_ssip,
  input  wire  [3:0]                       i_int_stip,
  input  wire  [3:0]                       i_int_seip,
  input  wire  [3:0]                       i_hart_debug_req,
  output logic [3:0]                       o_hart_debug_mode,
  output logic                             o_int_pmu,
  output logic                             o_int_fault,

  // AXI4-Lite subordinate interface
  input  wire  [31:0]                      i_axil_awaddr,
  input  wire  [2:0]                       i_axil_awprot,
  input  wire                              i_axil_awvalid,
  output logic                             o_axil_awready,
  input  wire  [31:0]                      i_axil_wdata,
  input  wire  [3:0]                       i_axil_wstrb,
  input  wire                              i_axil_wvalid,
  output logic                             o_axil_wready,
  output logic [1:0]                       o_axil_bresp,
  output logic                             o_axil_bvalid,
  input  wire                              i_axil_bready,
  input  wire  [31:0]                      i_axil_araddr,
  input  wire  [2:0]                       i_axil_arprot,
  input  wire                              i_axil_arvalid,
  output logic                             o_axil_arready,
  output logic [31:0]                      o_axil_rdata,
  output logic [1:0]                       o_axil_rresp,
  output logic                             o_axil_rvalid,
  input  wire                              i_axil_rready,

  // AXI4 MMIO manager interface
  output logic [5:0]                       o_axi_mmio_awid,
  output logic [63:0]                      o_axi_mmio_awaddr,
  output logic [7:0]                       o_axi_mmio_awlen,
  output logic [2:0]                       o_axi_mmio_awsize,
  output logic [1:0]                       o_axi_mmio_awburst,
  output logic                             o_axi_mmio_awlock,
  output logic [3:0]                       o_axi_mmio_awcache,
  output logic [2:0]                       o_axi_mmio_awprot,
  output logic [3:0]                       o_axi_mmio_awqos,
  output logic [3:0]                       o_axi_mmio_awregion,
  output logic                             o_axi_mmio_awvalid,
  input  wire                              i_axi_mmio_awready,
  output logic [63:0]                      o_axi_mmio_wdata,
  output logic [7:0]                       o_axi_mmio_wstrb,
  output logic                             o_axi_mmio_wlast,
  output logic                             o_axi_mmio_wvalid,
  input  wire                              i_axi_mmio_wready,
  input  wire  [5:0]                       i_axi_mmio_bid,
  input  wire  [1:0]                       i_axi_mmio_bresp,
  input  wire                              i_axi_mmio_bvalid,
  output logic                             o_axi_mmio_bready,
  output logic [5:0]                       o_axi_mmio_arid,
  output logic [63:0]                      o_axi_mmio_araddr,
  output logic [7:0]                       o_axi_mmio_arlen,
  output logic [2:0]                       o_axi_mmio_arsize,
  output logic [1:0]                       o_axi_mmio_arburst,
  output logic                             o_axi_mmio_arlock,
  output logic [3:0]                       o_axi_mmio_arcache,
  output logic [2:0]                       o_axi_mmio_arprot,
  output logic [3:0]                       o_axi_mmio_arqos,
  output logic [3:0]                       o_axi_mmio_arregion,
  output logic                             o_axi_mmio_arvalid,
  input  wire                              i_axi_mmio_arready,
  input  wire  [5:0]                       i_axi_mmio_rid,
  input  wire  [63:0]                      i_axi_mmio_rdata,
  input  wire  [1:0]                       i_axi_mmio_rresp,
  input  wire                              i_axi_mmio_rlast,
  input  wire                              i_axi_mmio_rvalid,
  output logic                             o_axi_mmio_rready,

  // AXI4 memory manager interface
  output logic [6:0]                       o_axi_mem_awid,
  output logic [5:0]                       o_axi_mem_awatop,
  output logic [63:0]                      o_axi_mem_awaddr,
  output logic [7:0]                       o_axi_mem_awlen,
  output logic [2:0]                       o_axi_mem_awsize,
  output logic [1:0]                       o_axi_mem_awburst,
  output logic                             o_axi_mem_awlock,
  output logic [3:0]                       o_axi_mem_awcache,
  output logic [2:0]                       o_axi_mem_awprot,
  output logic [3:0]                       o_axi_mem_awqos,
  output logic [3:0]                       o_axi_mem_awregion,
  output logic                             o_axi_mem_awvalid,
  input  wire                              i_axi_mem_awready,
  output logic [63:0]                      o_axi_mem_wdata,
  output logic [7:0]                       o_axi_mem_wstrb,
  output logic                             o_axi_mem_wlast,
  output logic                             o_axi_mem_wvalid,
  input  wire                              i_axi_mem_wready,
  input  wire  [6:0]                       i_axi_mem_bid,
  input  wire  [1:0]                       i_axi_mem_bresp,
  input  wire                              i_axi_mem_bvalid,
  output logic                             o_axi_mem_bready,
  output logic [6:0]                       o_axi_mem_arid,
  output logic [63:0]                      o_axi_mem_araddr,
  output logic [7:0]                       o_axi_mem_arlen,
  output logic [2:0]                       o_axi_mem_arsize,
  output logic [1:0]                       o_axi_mem_arburst,
  output logic                             o_axi_mem_arlock,
  output logic [3:0]                       o_axi_mem_arcache,
  output logic [2:0]                       o_axi_mem_arprot,
  output logic [3:0]                       o_axi_mem_arqos,
  output logic [3:0]                       o_axi_mem_arregion,
  output logic                             o_axi_mem_arvalid,
  input  wire                              i_axi_mem_arready,
  input  wire  [6:0]                       i_axi_mem_rid,
  input  wire  [63:0]                      i_axi_mem_rdata,
  input  wire  [1:0]                       i_axi_mem_rresp,
  input  wire                              i_axi_mem_rlast,
  input  wire                              i_axi_mem_rvalid,
  output logic                             o_axi_mem_rready
);

  // External CMO path uses native retirement, shared CCU contexts, and LLC service.
  logic [3:0] w_cmo_req_valid;
  logic [3:0] w_cmo_req_ready;
  logic [3:0][1:0] w_cmo_req_op;
  logic [3:0][51:0] w_cmo_req_pa_line;
  logic [3:0][63:0] w_cmo_req_vaddr;
  logic [3:0][63:0] w_cmo_req_pc;
  logic [3:0] w_cmo_rsp_done;
  logic [3:0] w_cmo_rsp_err;
  logic  w_cmo_ccu_begin_valid;
  logic  w_cmo_ccu_begin_ready;
  logic [1:0] w_cmo_ccu_begin_op;
  logic [51:0] w_cmo_ccu_begin_pa_line;
  logic [1:0] w_cmo_ccu_begin_hart;
  logic  w_cmo_ccu_begin_wback_en;
  logic  w_cmo_ccu_prepare_valid;
  logic  w_cmo_ccu_prepare_ready;
  logic [$clog2(PARA_COH_TXN_NUM)-1:0] w_cmo_ccu_prepare_tag;
  logic  w_cmo_ccu_prepare_err;
  logic  w_cmo_ccu_finish_valid;
  logic  w_cmo_ccu_finish_ready;
  logic [$clog2(PARA_COH_TXN_NUM)-1:0] w_cmo_ccu_finish_tag;
  logic  w_cmo_ccu_finish_commit;
  logic  w_cmo_ccu_finish_done;
  logic w_cmo_valid, w_cmo_ready, w_cmo_done, w_cmo_error;
  logic [1:0] w_cmo_op, w_cmo_hart;
  logic [51:0] w_cmo_pa_line;
  logic [63:0] w_cmo_vaddr, w_cmo_pc;
  logic w_maint_valid, w_maint_ready, w_maint_done, w_maint_error;
  logic [1:0] w_maint_op;
  logic [51:0] w_maint_pa_line;
  m_vlsit_riscv_cmo_arbiter #(.PARA_CPU_NUM(PARA_CPU_NUM)) u_vlsit_riscv_cmo_arbiter (
    .i_clk_cluster, .i_rst_n_cluster,
    .i_req_valid(w_cmo_req_valid),.o_req_ready(w_cmo_req_ready),
    .i_req_op(w_cmo_req_op),.i_req_pa_line(w_cmo_req_pa_line),
    .i_req_vaddr(w_cmo_req_vaddr),.i_req_pc(w_cmo_req_pc),
    .o_rsp_done(w_cmo_rsp_done),.o_rsp_err(w_cmo_rsp_err),
    .o_cmo_valid(w_cmo_valid),.i_cmo_ready(w_cmo_ready),.o_cmo_op(w_cmo_op),
    .o_cmo_pa_line(w_cmo_pa_line),.o_cmo_vaddr(w_cmo_vaddr),.o_cmo_pc(w_cmo_pc),
    .o_cmo_hart(w_cmo_hart),.i_cmo_done(w_cmo_done),.i_cmo_err(w_cmo_error)
  );
  m_vlsit_riscv_cmo_controller #(.PARA_CPU_NUM(PARA_CPU_NUM),.PARA_COH_TXN_NUM(PARA_COH_TXN_NUM)) u_vlsit_riscv_cmo_controller (
    .i_clk_cluster, .i_rst_n_cluster,
    .i_cmo_valid(w_cmo_valid),.o_cmo_ready(w_cmo_ready),.i_cmo_op(w_cmo_op),
    .i_cmo_pa_line(w_cmo_pa_line),.i_cmo_vaddr(w_cmo_vaddr),.i_cmo_pc(w_cmo_pc),
    .i_cmo_hart(w_cmo_hart),.o_cmo_done(w_cmo_done),.o_cmo_error(w_cmo_error),
    .o_cmo_vaddr(),.o_cmo_pc(),.o_cmo_hart(),
    .o_maint_valid(w_maint_valid),.i_maint_ready(w_maint_ready),
    .o_maint_op(w_maint_op),.o_maint_pa_line(w_maint_pa_line),
    .i_maint_done(w_maint_done),.i_maint_error(w_maint_error),
    .o_ccu_begin_valid(w_cmo_ccu_begin_valid),
    .i_ccu_begin_ready(w_cmo_ccu_begin_ready),
    .o_ccu_begin_op(w_cmo_ccu_begin_op),
    .o_ccu_begin_pa_line(w_cmo_ccu_begin_pa_line),
    .o_ccu_begin_hart(w_cmo_ccu_begin_hart),
    .o_ccu_begin_wback_en(w_cmo_ccu_begin_wback_en),
    .i_ccu_prepare_valid(w_cmo_ccu_prepare_valid),
    .o_ccu_prepare_ready(w_cmo_ccu_prepare_ready),
    .i_ccu_prepare_tag(w_cmo_ccu_prepare_tag),
    .i_ccu_prepare_err(w_cmo_ccu_prepare_err),
    .o_ccu_finish_valid(w_cmo_ccu_finish_valid),
    .i_ccu_finish_ready(w_cmo_ccu_finish_ready),
    .o_ccu_finish_tag(w_cmo_ccu_finish_tag),
    .o_ccu_finish_commit(w_cmo_ccu_finish_commit),
    .i_ccu_finish_done(w_cmo_ccu_finish_done)
  );

  // Fixed integration controls and cached-range endpoints for the pinned LLC.
  logic [63:0] w_llc_cached_start_addr;
  logic [63:0] w_llc_cached_end_addr;
  logic [3:0] w_hart_active;
  logic [11:0][2:0] w_ccu_evt_count;
  logic [27:0] w_llc_events;
  logic w_llc_wb_fault;
  logic w_llc_wb_fault_event;
  logic [63:0] w_llc_wb_fault_addr;
  logic [1:0] w_llc_wb_fault_resp;
  logic [3:0][55:0] w_l1_fault_addr;
  logic [31:0] w_fault_sts;
  logic [31:0] w_fault_info;
  logic [31:0] w_fault_addr_lo;
  logic [31:0] w_fault_addr_hi;

  // Derive the LLC cache aperture from region zero, the configured default cacheable range.
  assign w_llc_cached_start_addr = {PARA_ADDR_REGION_BASE_HI[0], PARA_ADDR_REGION_BASE_LO[0]};
  assign w_llc_cached_end_addr = w_llc_cached_start_addr +
                                 {PARA_ADDR_REGION_SIZE_HI[0], PARA_ADDR_REGION_SIZE_LO[0]};
  // Mark only the configured harts active in the fixed four-slot event interface.
  assign w_hart_active = (PARA_CPU_NUM == LPARA_CPU_NUM_DUAL) ? 4'b0011 : 4'b1111;

  // CVA6 tile array exports native CPU/HPDcache performance taps and the per-hart AXI channels.
  logic [3:0] w_tile_coh_access_locked;
  logic [3:0] w_tile_coh_victim_locked;
  logic [3:0][3:0] w_tile_axi_awid;
  logic [3:0][5:0] w_tile_axi_awatop;
  logic [3:0][63:0] w_tile_axi_awaddr;
  logic [3:0][7:0] w_tile_axi_awlen;
  logic [3:0][2:0] w_tile_axi_awsize;
  logic [3:0][1:0] w_tile_axi_awburst;
  logic [3:0] w_tile_axi_awlock;
  logic [3:0][3:0] w_tile_axi_awcache;
  logic [3:0][2:0] w_tile_axi_awprot;
  logic [3:0][3:0] w_tile_axi_awqos;
  logic [3:0][3:0] w_tile_axi_awregion;
  logic [3:0] w_tile_axi_awvalid;
  logic [3:0][63:0] w_tile_axi_wdata;
  logic [3:0][7:0] w_tile_axi_wstrb;
  logic [3:0] w_tile_axi_wlast;
  logic [3:0] w_tile_axi_wvalid;
  logic [3:0] w_tile_axi_bready;
  logic [3:0][3:0] w_tile_axi_arid;
  logic [3:0][63:0] w_tile_axi_araddr;
  logic [3:0][7:0] w_tile_axi_arlen;
  logic [3:0][2:0] w_tile_axi_arsize;
  logic [3:0][1:0] w_tile_axi_arburst;
  logic [3:0] w_tile_axi_arlock;
  logic [3:0][3:0] w_tile_axi_arcache;
  logic [3:0][2:0] w_tile_axi_arprot;
  logic [3:0][3:0] w_tile_axi_arqos;
  logic [3:0][3:0] w_tile_axi_arregion;
  logic [3:0] w_tile_axi_arvalid;
  logic [3:0] w_tile_axi_rready;
  logic [3:0] w_tile_axi_aw_region_match;
  logic [3:0][1:0] w_tile_axi_aw_region_type;
  logic [3:0] w_tile_axi_aw_region_err;
  logic [3:0] w_tile_axi_ar_region_match;
  logic [3:0][1:0] w_tile_axi_ar_region_type;
  logic [3:0] w_tile_axi_ar_region_err;
  logic [3:0][21:0] w_tile_perf_event;
  logic [3:0][15:0] w_tile_hpdcache_perf_event;
  // Routed to the core boundary; the shared CMO controller/retirement handshake
  // is not yet connected, so these metadata taps are currently observation-only.
  logic [3:0] w_tile_cmo_entry_valid;
  logic [3:0][7:0] w_tile_cmo_entry_op;
  logic [3:0][51:0] w_tile_cmo_entry_pa_line;
  logic [3:0][63:0] w_tile_cmo_entry_vaddr;
  logic [3:0] w_tile_dcache_flush_ack_valid;
  logic [3:0][51:0] w_tile_dcache_flush_ack_nline;
  logic [3:0][1:0] w_tile_dcache_flush_ack_origin;
  logic [3:0] w_tile_dcache_flush_ack_err;
  logic [3:0] w_tile_flush_rsp_invalid;
  logic [3:0] w_tile_coh_lock_diag_event;
  logic w_tile_coh_proto_diag_event;
  logic [3:0] w_route_awready;
  logic [3:0] w_route_wready;
  logic [3:0] [3:0] w_route_bid;
  logic [3:0] [1:0] w_route_bresp;
  logic [3:0] w_route_bvalid;
  logic [3:0] w_route_arready;
  logic [3:0] [3:0] w_route_rid;
  logic [3:0] [63:0] w_route_rdata;
  logic [3:0] [1:0] w_route_rresp;
  logic [3:0] w_route_rlast;
  logic [3:0] w_route_rvalid;
  logic [3:0] [3:0] w_route_mem_awid;
  logic [3:0] [5:0] w_route_mem_awatop;
  logic [3:0] [63:0] w_route_mem_awaddr;
  logic [3:0] [7:0] w_route_mem_awlen;
  logic [3:0] [2:0] w_route_mem_awsize;
  logic [3:0] [1:0] w_route_mem_awburst;
  logic [3:0] w_route_mem_awlock;
  logic [3:0] [3:0] w_route_mem_awcache;
  logic [3:0] [2:0] w_route_mem_awprot;
  logic [3:0] [3:0] w_route_mem_awqos;
  logic [3:0] [3:0] w_route_mem_awregion;
  logic [3:0] [1:0] w_route_mem_aw_route_class;
  logic [3:0] w_route_mem_awvalid;
  logic [3:0] [63:0] w_route_mem_wdata;
  logic [3:0] [7:0] w_route_mem_wstrb;
  logic [3:0] w_route_mem_wlast;
  logic [3:0] w_route_mem_wvalid;
  logic [3:0] w_route_mem_bready;
  logic [3:0] [3:0] w_route_mem_arid;
  logic [3:0] [63:0] w_route_mem_araddr;
  logic [3:0] [7:0] w_route_mem_arlen;
  logic [3:0] [2:0] w_route_mem_arsize;
  logic [3:0] [1:0] w_route_mem_arburst;
  logic [3:0] w_route_mem_arlock;
  logic [3:0] [3:0] w_route_mem_arcache;
  logic [3:0] [2:0] w_route_mem_arprot;
  logic [3:0] [3:0] w_route_mem_arqos;
  logic [3:0] [3:0] w_route_mem_arregion;
  logic [3:0] [1:0] w_route_mem_ar_route_class;
  logic [3:0] w_route_mem_arvalid;
  logic [3:0] w_route_mem_rready;
  logic [3:0] [3:0] w_route_mmio_awid;
  logic [3:0] [63:0] w_route_mmio_awaddr;
  logic [3:0] [7:0] w_route_mmio_awlen;
  logic [3:0] [2:0] w_route_mmio_awsize;
  logic [3:0] [1:0] w_route_mmio_awburst;
  logic [3:0] w_route_mmio_awlock;
  logic [3:0] [3:0] w_route_mmio_awcache;
  logic [3:0] [2:0] w_route_mmio_awprot;
  logic [3:0] [3:0] w_route_mmio_awqos;
  logic [3:0] [3:0] w_route_mmio_awregion;
  logic [3:0] w_route_mmio_awvalid;
  logic [3:0] [63:0] w_route_mmio_wdata;
  logic [3:0] [7:0] w_route_mmio_wstrb;
  logic [3:0] w_route_mmio_wlast;
  logic [3:0] w_route_mmio_wvalid;
  logic [3:0] w_route_mmio_bready;
  logic [3:0] [3:0] w_route_mmio_arid;
  logic [3:0] [63:0] w_route_mmio_araddr;
  logic [3:0] [7:0] w_route_mmio_arlen;
  logic [3:0] [2:0] w_route_mmio_arsize;
  logic [3:0] [1:0] w_route_mmio_arburst;
  logic [3:0] w_route_mmio_arlock;
  logic [3:0] [3:0] w_route_mmio_arcache;
  logic [3:0] [2:0] w_route_mmio_arprot;
  logic [3:0] [3:0] w_route_mmio_arqos;
  logic [3:0] [3:0] w_route_mmio_arregion;
  logic [3:0] w_route_mmio_arvalid;
  logic [3:0] w_route_mmio_rready;
  logic [3:0] w_mem_mux_src_awready;
  logic [3:0] w_mem_mux_src_wready;
  logic [3:0][3:0] w_mem_mux_src_bid;
  logic [3:0][1:0] w_mem_mux_src_bresp;
  logic [3:0] w_mem_mux_src_bvalid;
  logic [3:0] w_mem_mux_src_arready;
  logic [3:0][3:0] w_mem_mux_src_rid;
  logic [3:0][63:0] w_mem_mux_src_rdata;
  logic [3:0][1:0] w_mem_mux_src_rresp;
  logic [3:0] w_mem_mux_src_rlast;
  logic [3:0] w_mem_mux_src_rvalid;
  logic [3:0] w_mmio_mux_src_awready;
  logic [3:0] w_mmio_mux_src_wready;
  logic [3:0][3:0] w_mmio_mux_src_bid;
  logic [3:0][1:0] w_mmio_mux_src_bresp;
  logic [3:0] w_mmio_mux_src_bvalid;
  logic [3:0] w_mmio_mux_src_arready;
  logic [3:0][3:0] w_mmio_mux_src_rid;
  logic [3:0][63:0] w_mmio_mux_src_rdata;
  logic [3:0][1:0] w_mmio_mux_src_rresp;
  logic [3:0] w_mmio_mux_src_rlast;
  logic [3:0] w_mmio_mux_src_rvalid;
  logic [5:0] w_llc_axi_req_awid;
  logic [5:0] w_llc_axi_req_awatop;
  logic [63:0] w_llc_axi_req_awaddr;
  logic [7:0] w_llc_axi_req_awlen;
  logic [2:0] w_llc_axi_req_awsize;
  logic [1:0] w_llc_axi_req_awburst;
  logic w_llc_axi_req_awlock;
  logic [3:0] w_llc_axi_req_awcache;
  logic [2:0] w_llc_axi_req_awprot;
  logic [3:0] w_llc_axi_req_awqos;
  logic [3:0] w_llc_axi_req_awregion;
  logic w_llc_axi_req_awvalid;
  logic w_llc_axi_rsp_awready;
  logic [63:0] w_llc_axi_req_wdata;
  logic [7:0] w_llc_axi_req_wstrb;
  logic w_llc_axi_req_wlast;
  logic w_llc_axi_req_wvalid;
  logic w_llc_axi_rsp_wready;
  logic [5:0] w_llc_axi_rsp_bid;
  logic [1:0] w_llc_axi_rsp_bresp;
  logic w_llc_axi_rsp_bvalid;
  logic w_llc_axi_req_bready;
  logic [5:0] w_llc_axi_req_arid;
  logic [63:0] w_llc_axi_req_araddr;
  logic [7:0] w_llc_axi_req_arlen;
  logic [2:0] w_llc_axi_req_arsize;
  logic [1:0] w_llc_axi_req_arburst;
  logic w_llc_axi_req_arlock;
  logic [3:0] w_llc_axi_req_arcache;
  logic [2:0] w_llc_axi_req_arprot;
  logic [3:0] w_llc_axi_req_arqos;
  logic [3:0] w_llc_axi_req_arregion;
  logic w_llc_axi_req_arvalid;
  logic w_llc_axi_rsp_arready;
  logic [5:0] w_llc_axi_rsp_rid;
  logic [63:0] w_llc_axi_rsp_rdata;
  logic [1:0] w_llc_axi_rsp_rresp;
  logic w_llc_axi_rsp_rlast;
  logic w_llc_axi_rsp_rvalid;
  logic w_llc_axi_req_rready;

  // Address-table classification and per-hart AXI routing.
  m_vlsit_riscv_cpu_tile_array #(
    .PARA_CMO_EN(32'd1),
    .PARA_CPU_NUM(PARA_CPU_NUM),
    .PARA_COH_TXN_NUM(PARA_COH_TXN_NUM),
    .PARA_ADDR_REGION_NUM(PARA_ADDR_REGION_NUM),
    .PARA_ADDR_REGION_BASE_LO(PARA_ADDR_REGION_BASE_LO),
    .PARA_ADDR_REGION_BASE_HI(PARA_ADDR_REGION_BASE_HI),
    .PARA_ADDR_REGION_SIZE_LO(PARA_ADDR_REGION_SIZE_LO),
    .PARA_ADDR_REGION_SIZE_HI(PARA_ADDR_REGION_SIZE_HI),
    .PARA_ADDR_REGION_TYPE(PARA_ADDR_REGION_TYPE)
  ) u_vlsit_riscv_cpu_tile_array (
    .o_cmo_req_valid(w_cmo_req_valid),
    .i_cmo_req_ready(w_cmo_req_ready),
    .o_cmo_req_op(w_cmo_req_op),
    .o_cmo_req_pa_line(w_cmo_req_pa_line),
    .o_cmo_req_vaddr(w_cmo_req_vaddr),
    .o_cmo_req_pc(w_cmo_req_pc),
    .i_cmo_rsp_done(w_cmo_rsp_done),
    .i_cmo_rsp_err(w_cmo_rsp_err),
    .i_ccu_begin_valid(w_cmo_ccu_begin_valid),
    .o_ccu_begin_ready(w_cmo_ccu_begin_ready),
    .i_ccu_begin_op(w_cmo_ccu_begin_op),
    .i_ccu_begin_pa_line(w_cmo_ccu_begin_pa_line),
    .i_ccu_begin_hart(w_cmo_ccu_begin_hart),
    .i_ccu_begin_wback_en(w_cmo_ccu_begin_wback_en),
    .o_ccu_prepare_valid(w_cmo_ccu_prepare_valid),
    .i_ccu_prepare_ready(w_cmo_ccu_prepare_ready),
    .o_ccu_prepare_tag(w_cmo_ccu_prepare_tag),
    .o_ccu_prepare_err(w_cmo_ccu_prepare_err),
    .i_ccu_finish_valid(w_cmo_ccu_finish_valid),
    .o_ccu_finish_ready(w_cmo_ccu_finish_ready),
    .i_ccu_finish_tag(w_cmo_ccu_finish_tag),
    .i_ccu_finish_commit(w_cmo_ccu_finish_commit),
    .o_ccu_finish_done(w_cmo_ccu_finish_done),
    .i_clk_cluster(i_clk_cluster),
    .i_rst_n_cluster(i_rst_n_cluster),
    .i_boot_addr(i_boot_addr),
    .i_int_msip(i_int_msip),
    .i_int_mtip(i_int_mtip),
    .i_int_meip(i_int_meip),
    .i_int_ssip(i_int_ssip),
    .i_int_stip(i_int_stip),
    .i_int_seip(i_int_seip),
    .i_hart_debug_req(i_hart_debug_req),
    .o_hart_debug_mode(o_hart_debug_mode),
    .o_coh_access_locked(w_tile_coh_access_locked),
    .o_coh_victim_locked(w_tile_coh_victim_locked),
    .o_axi_awid(w_tile_axi_awid),
    .o_axi_awatop(w_tile_axi_awatop),
    .o_axi_awaddr(w_tile_axi_awaddr),
    .o_axi_awlen(w_tile_axi_awlen),
    .o_axi_awsize(w_tile_axi_awsize),
    .o_axi_awburst(w_tile_axi_awburst),
    .o_axi_awlock(w_tile_axi_awlock),
    .o_axi_awcache(w_tile_axi_awcache),
    .o_axi_awprot(w_tile_axi_awprot),
    .o_axi_awqos(w_tile_axi_awqos),
    .o_axi_awregion(w_tile_axi_awregion),
    .o_axi_awvalid(w_tile_axi_awvalid),
    .i_axi_awready(w_route_awready),
    .o_axi_wdata(w_tile_axi_wdata),
    .o_axi_wstrb(w_tile_axi_wstrb),
    .o_axi_wlast(w_tile_axi_wlast),
    .o_axi_wvalid(w_tile_axi_wvalid),
    .i_axi_wready(w_route_wready),
    .i_axi_bid(w_route_bid),
    .i_axi_bresp(w_route_bresp),
    .i_axi_bvalid(w_route_bvalid),
    .o_axi_bready(w_tile_axi_bready),
    .o_axi_arid(w_tile_axi_arid),
    .o_axi_araddr(w_tile_axi_araddr),
    .o_axi_arlen(w_tile_axi_arlen),
    .o_axi_arsize(w_tile_axi_arsize),
    .o_axi_arburst(w_tile_axi_arburst),
    .o_axi_arlock(w_tile_axi_arlock),
    .o_axi_arcache(w_tile_axi_arcache),
    .o_axi_arprot(w_tile_axi_arprot),
    .o_axi_arqos(w_tile_axi_arqos),
    .o_axi_arregion(w_tile_axi_arregion),
    .o_axi_arvalid(w_tile_axi_arvalid),
    .i_axi_arready(w_route_arready),
    .i_axi_rid(w_route_rid),
    .i_axi_rdata(w_route_rdata),
    .i_axi_rresp(w_route_rresp),
    .i_axi_rlast(w_route_rlast),
    .i_axi_rvalid(w_route_rvalid),
    .o_axi_rready(w_tile_axi_rready),
    .o_axi_aw_region_match(w_tile_axi_aw_region_match),
    .o_axi_aw_region_idx(),
    .o_axi_aw_region_type(w_tile_axi_aw_region_type),
    .o_axi_aw_region_err(w_tile_axi_aw_region_err),
    .o_axi_ar_region_match(w_tile_axi_ar_region_match),
    .o_axi_ar_region_idx(),
    .o_axi_ar_region_type(w_tile_axi_ar_region_type),
    .o_axi_ar_region_err(w_tile_axi_ar_region_err),
    .o_tile_region_cfg_valid(),
    .o_region_cfg_valid(),
    .o_perf_event(w_tile_perf_event),
    .o_hpdcache_perf_event(w_tile_hpdcache_perf_event),
    .o_cmo_entry_valid(w_tile_cmo_entry_valid),
    .o_cmo_entry_op(w_tile_cmo_entry_op),
    .o_cmo_entry_pa_line(w_tile_cmo_entry_pa_line),
    .o_cmo_entry_vaddr(w_tile_cmo_entry_vaddr),
    .o_dcache_flush_ack_valid(w_tile_dcache_flush_ack_valid),
    .o_dcache_flush_ack_nline(w_tile_dcache_flush_ack_nline),
    .o_dcache_flush_ack_origin(w_tile_dcache_flush_ack_origin),
    .o_dcache_flush_ack_err(w_tile_dcache_flush_ack_err),
    .o_dcache_flush_rsp_invalid(w_tile_flush_rsp_invalid),
    .o_coh_lock_diag_event(w_tile_coh_lock_diag_event),
    .o_coh_proto_diag_event(w_tile_coh_proto_diag_event),
    .o_dir_lookup_count(),
    .o_dir_update_count(),
    .o_ccu_evt_count(w_ccu_evt_count)
  );

  for (genvar tile_idx = 0; tile_idx < 4; tile_idx++) begin : gen_axi_route
    m_vlsit_riscv_axi_route u_vlsit_riscv_axi_route (
        .i_clk_cluster(i_clk_cluster),
        .i_rst_n_cluster(i_rst_n_cluster),
        .i_awid(w_tile_axi_awid[tile_idx]),
        .i_awatop(w_tile_axi_awatop[tile_idx]),
        .i_awaddr(w_tile_axi_awaddr[tile_idx]),
        .i_awlen(w_tile_axi_awlen[tile_idx]),
        .i_awsize(w_tile_axi_awsize[tile_idx]),
        .i_awburst(w_tile_axi_awburst[tile_idx]),
        .i_awlock(w_tile_axi_awlock[tile_idx]),
        .i_awcache(w_tile_axi_awcache[tile_idx]),
        .i_awprot(w_tile_axi_awprot[tile_idx]),
        .i_awqos(w_tile_axi_awqos[tile_idx]),
        .i_awregion(w_tile_axi_awregion[tile_idx]),
        .i_awvalid(w_tile_axi_awvalid[tile_idx]),
        .o_awready(w_route_awready[tile_idx]),
        .i_aw_region_match(w_tile_axi_aw_region_match[tile_idx]),
        .i_aw_region_type(w_tile_axi_aw_region_type[tile_idx]),
        .i_aw_region_err(w_tile_axi_aw_region_err[tile_idx]),
        .i_wdata(w_tile_axi_wdata[tile_idx]),
        .i_wstrb(w_tile_axi_wstrb[tile_idx]),
        .i_wlast(w_tile_axi_wlast[tile_idx]),
        .i_wvalid(w_tile_axi_wvalid[tile_idx]),
        .o_wready(w_route_wready[tile_idx]),
        .o_bid(w_route_bid[tile_idx]),
        .o_bresp(w_route_bresp[tile_idx]),
        .o_bvalid(w_route_bvalid[tile_idx]),
        .i_bready(w_tile_axi_bready[tile_idx]),
        .i_arid(w_tile_axi_arid[tile_idx]),
        .i_araddr(w_tile_axi_araddr[tile_idx]),
        .i_arlen(w_tile_axi_arlen[tile_idx]),
        .i_arsize(w_tile_axi_arsize[tile_idx]),
        .i_arburst(w_tile_axi_arburst[tile_idx]),
        .i_arlock(w_tile_axi_arlock[tile_idx]),
        .i_arcache(w_tile_axi_arcache[tile_idx]),
        .i_arprot(w_tile_axi_arprot[tile_idx]),
        .i_arqos(w_tile_axi_arqos[tile_idx]),
        .i_arregion(w_tile_axi_arregion[tile_idx]),
        .i_arvalid(w_tile_axi_arvalid[tile_idx]),
        .o_arready(w_route_arready[tile_idx]),
        .i_ar_region_match(w_tile_axi_ar_region_match[tile_idx]),
        .i_ar_region_type(w_tile_axi_ar_region_type[tile_idx]),
        .i_ar_region_err(w_tile_axi_ar_region_err[tile_idx]),
        .o_rid(w_route_rid[tile_idx]),
        .o_rdata(w_route_rdata[tile_idx]),
        .o_rresp(w_route_rresp[tile_idx]),
        .o_rlast(w_route_rlast[tile_idx]),
        .o_rvalid(w_route_rvalid[tile_idx]),
        .i_rready(w_tile_axi_rready[tile_idx]),
        .o_mem_awid(w_route_mem_awid[tile_idx]),
        .o_mem_awatop(w_route_mem_awatop[tile_idx]),
        .o_mem_awaddr(w_route_mem_awaddr[tile_idx]),
        .o_mem_awlen(w_route_mem_awlen[tile_idx]),
        .o_mem_awsize(w_route_mem_awsize[tile_idx]),
        .o_mem_awburst(w_route_mem_awburst[tile_idx]),
        .o_mem_awlock(w_route_mem_awlock[tile_idx]),
        .o_mem_awcache(w_route_mem_awcache[tile_idx]),
        .o_mem_awprot(w_route_mem_awprot[tile_idx]),
        .o_mem_awqos(w_route_mem_awqos[tile_idx]),
        .o_mem_awregion(w_route_mem_awregion[tile_idx]),
        .o_mem_aw_route_class(),
        .o_mem_awvalid(w_route_mem_awvalid[tile_idx]),
        .i_mem_awready(w_mem_mux_src_awready[tile_idx]),
        .o_mem_wdata(w_route_mem_wdata[tile_idx]),
        .o_mem_wstrb(w_route_mem_wstrb[tile_idx]),
        .o_mem_wlast(w_route_mem_wlast[tile_idx]),
        .o_mem_wvalid(w_route_mem_wvalid[tile_idx]),
        .i_mem_wready(w_mem_mux_src_wready[tile_idx]),
        .i_mem_bid(w_mem_mux_src_bid[tile_idx]),
        .i_mem_bresp(w_mem_mux_src_bresp[tile_idx]),
        .i_mem_bvalid(w_mem_mux_src_bvalid[tile_idx]),
        .o_mem_bready(w_route_mem_bready[tile_idx]),
        .o_mem_arid(w_route_mem_arid[tile_idx]),
        .o_mem_araddr(w_route_mem_araddr[tile_idx]),
        .o_mem_arlen(w_route_mem_arlen[tile_idx]),
        .o_mem_arsize(w_route_mem_arsize[tile_idx]),
        .o_mem_arburst(w_route_mem_arburst[tile_idx]),
        .o_mem_arlock(w_route_mem_arlock[tile_idx]),
        .o_mem_arcache(w_route_mem_arcache[tile_idx]),
        .o_mem_arprot(w_route_mem_arprot[tile_idx]),
        .o_mem_arqos(w_route_mem_arqos[tile_idx]),
        .o_mem_arregion(w_route_mem_arregion[tile_idx]),
        .o_mem_ar_route_class(),
        .o_mem_arvalid(w_route_mem_arvalid[tile_idx]),
        .i_mem_arready(w_mem_mux_src_arready[tile_idx]),
        .i_mem_rid(w_mem_mux_src_rid[tile_idx]),
        .i_mem_rdata(w_mem_mux_src_rdata[tile_idx]),
        .i_mem_rresp(w_mem_mux_src_rresp[tile_idx]),
        .i_mem_rlast(w_mem_mux_src_rlast[tile_idx]),
        .i_mem_rvalid(w_mem_mux_src_rvalid[tile_idx]),
        .o_mem_rready(w_route_mem_rready[tile_idx]),
        .o_mmio_awid(w_route_mmio_awid[tile_idx]),
        .o_mmio_awaddr(w_route_mmio_awaddr[tile_idx]),
        .o_mmio_awlen(w_route_mmio_awlen[tile_idx]),
        .o_mmio_awsize(w_route_mmio_awsize[tile_idx]),
        .o_mmio_awburst(w_route_mmio_awburst[tile_idx]),
        .o_mmio_awlock(w_route_mmio_awlock[tile_idx]),
        .o_mmio_awcache(w_route_mmio_awcache[tile_idx]),
        .o_mmio_awprot(w_route_mmio_awprot[tile_idx]),
        .o_mmio_awqos(w_route_mmio_awqos[tile_idx]),
        .o_mmio_awregion(w_route_mmio_awregion[tile_idx]),
        .o_mmio_awvalid(w_route_mmio_awvalid[tile_idx]),
        .i_mmio_awready(w_mmio_mux_src_awready[tile_idx]),
        .o_mmio_wdata(w_route_mmio_wdata[tile_idx]),
        .o_mmio_wstrb(w_route_mmio_wstrb[tile_idx]),
        .o_mmio_wlast(w_route_mmio_wlast[tile_idx]),
        .o_mmio_wvalid(w_route_mmio_wvalid[tile_idx]),
        .i_mmio_wready(w_mmio_mux_src_wready[tile_idx]),
        .i_mmio_bid(w_mmio_mux_src_bid[tile_idx]),
        .i_mmio_bresp(w_mmio_mux_src_bresp[tile_idx]),
        .i_mmio_bvalid(w_mmio_mux_src_bvalid[tile_idx]),
        .o_mmio_bready(w_route_mmio_bready[tile_idx]),
        .o_mmio_arid(w_route_mmio_arid[tile_idx]),
        .o_mmio_araddr(w_route_mmio_araddr[tile_idx]),
        .o_mmio_arlen(w_route_mmio_arlen[tile_idx]),
        .o_mmio_arsize(w_route_mmio_arsize[tile_idx]),
        .o_mmio_arburst(w_route_mmio_arburst[tile_idx]),
        .o_mmio_arlock(w_route_mmio_arlock[tile_idx]),
        .o_mmio_arcache(w_route_mmio_arcache[tile_idx]),
        .o_mmio_arprot(w_route_mmio_arprot[tile_idx]),
        .o_mmio_arqos(w_route_mmio_arqos[tile_idx]),
        .o_mmio_arregion(w_route_mmio_arregion[tile_idx]),
        .o_mmio_arvalid(w_route_mmio_arvalid[tile_idx]),
        .i_mmio_arready(w_mmio_mux_src_arready[tile_idx]),
        .i_mmio_rid(w_mmio_mux_src_rid[tile_idx]),
        .i_mmio_rdata(w_mmio_mux_src_rdata[tile_idx]),
        .i_mmio_rresp(w_mmio_mux_src_rresp[tile_idx]),
        .i_mmio_rlast(w_mmio_mux_src_rlast[tile_idx]),
        .i_mmio_rvalid(w_mmio_mux_src_rvalid[tile_idx]),
        .o_mmio_rready(w_route_mmio_rready[tile_idx]),
        .o_aw_local_err_event(),
        .o_ar_local_err_event()
    );
  end

  // Merge normal-memory traffic before the LLC and MMIO traffic to the external fabric.
  m_vlsit_riscv_axi_mem_mux #(
    .PARA_CPU_NUM(PARA_CPU_NUM)
  ) u_vlsit_riscv_axi_mem_mux (
    .i_clk_cluster(i_clk_cluster),
    .i_rst_n_cluster(i_rst_n_cluster),
    .i_axi_src_awid(w_route_mem_awid),
    .i_axi_src_awatop(w_route_mem_awatop),
    .i_axi_src_awaddr(w_route_mem_awaddr),
    .i_axi_src_awlen(w_route_mem_awlen),
    .i_axi_src_awsize(w_route_mem_awsize),
    .i_axi_src_awburst(w_route_mem_awburst),
    .i_axi_src_awlock(w_route_mem_awlock),
    .i_axi_src_awcache(w_route_mem_awcache),
    .i_axi_src_awprot(w_route_mem_awprot),
    .i_axi_src_awqos(w_route_mem_awqos),
    .i_axi_src_awregion(w_route_mem_awregion),
    .i_axi_src_awvalid(w_route_mem_awvalid),
    .o_axi_src_awready(w_mem_mux_src_awready),
    .i_axi_src_wdata(w_route_mem_wdata),
    .i_axi_src_wstrb(w_route_mem_wstrb),
    .i_axi_src_wlast(w_route_mem_wlast),
    .i_axi_src_wvalid(w_route_mem_wvalid),
    .o_axi_src_wready(w_mem_mux_src_wready),
    .o_axi_src_bid(w_mem_mux_src_bid),
    .o_axi_src_bresp(w_mem_mux_src_bresp),
    .o_axi_src_bvalid(w_mem_mux_src_bvalid),
    .i_axi_src_bready(w_route_mem_bready),
    .i_axi_src_arid(w_route_mem_arid),
    .i_axi_src_araddr(w_route_mem_araddr),
    .i_axi_src_arlen(w_route_mem_arlen),
    .i_axi_src_arsize(w_route_mem_arsize),
    .i_axi_src_arburst(w_route_mem_arburst),
    .i_axi_src_arlock(w_route_mem_arlock),
    .i_axi_src_arcache(w_route_mem_arcache),
    .i_axi_src_arprot(w_route_mem_arprot),
    .i_axi_src_arqos(w_route_mem_arqos),
    .i_axi_src_arregion(w_route_mem_arregion),
    .i_axi_src_arvalid(w_route_mem_arvalid),
    .o_axi_src_arready(w_mem_mux_src_arready),
    .o_axi_src_rid(w_mem_mux_src_rid),
    .o_axi_src_rdata(w_mem_mux_src_rdata),
    .o_axi_src_rresp(w_mem_mux_src_rresp),
    .o_axi_src_rlast(w_mem_mux_src_rlast),
    .o_axi_src_rvalid(w_mem_mux_src_rvalid),
    .i_axi_src_rready(w_route_mem_rready),
    .o_axi_llc_awid(w_llc_axi_req_awid),
    .o_axi_llc_awatop(w_llc_axi_req_awatop),
    .o_axi_llc_awaddr(w_llc_axi_req_awaddr),
    .o_axi_llc_awlen(w_llc_axi_req_awlen),
    .o_axi_llc_awsize(w_llc_axi_req_awsize),
    .o_axi_llc_awburst(w_llc_axi_req_awburst),
    .o_axi_llc_awlock(w_llc_axi_req_awlock),
    .o_axi_llc_awcache(w_llc_axi_req_awcache),
    .o_axi_llc_awprot(w_llc_axi_req_awprot),
    .o_axi_llc_awqos(w_llc_axi_req_awqos),
    .o_axi_llc_awregion(w_llc_axi_req_awregion),
    .o_axi_llc_awvalid(w_llc_axi_req_awvalid),
    .i_axi_llc_awready(w_llc_axi_rsp_awready),
    .o_axi_llc_wdata(w_llc_axi_req_wdata),
    .o_axi_llc_wstrb(w_llc_axi_req_wstrb),
    .o_axi_llc_wlast(w_llc_axi_req_wlast),
    .o_axi_llc_wvalid(w_llc_axi_req_wvalid),
    .i_axi_llc_wready(w_llc_axi_rsp_wready),
    .i_axi_llc_bid(w_llc_axi_rsp_bid),
    .i_axi_llc_bresp(w_llc_axi_rsp_bresp),
    .i_axi_llc_bvalid(w_llc_axi_rsp_bvalid),
    .o_axi_llc_bready(w_llc_axi_req_bready),
    .o_axi_llc_arid(w_llc_axi_req_arid),
    .o_axi_llc_araddr(w_llc_axi_req_araddr),
    .o_axi_llc_arlen(w_llc_axi_req_arlen),
    .o_axi_llc_arsize(w_llc_axi_req_arsize),
    .o_axi_llc_arburst(w_llc_axi_req_arburst),
    .o_axi_llc_arlock(w_llc_axi_req_arlock),
    .o_axi_llc_arcache(w_llc_axi_req_arcache),
    .o_axi_llc_arprot(w_llc_axi_req_arprot),
    .o_axi_llc_arqos(w_llc_axi_req_arqos),
    .o_axi_llc_arregion(w_llc_axi_req_arregion),
    .o_axi_llc_arvalid(w_llc_axi_req_arvalid),
    .i_axi_llc_arready(w_llc_axi_rsp_arready),
    .i_axi_llc_rid(w_llc_axi_rsp_rid),
    .i_axi_llc_rdata(w_llc_axi_rsp_rdata),
    .i_axi_llc_rresp(w_llc_axi_rsp_rresp),
    .i_axi_llc_rlast(w_llc_axi_rsp_rlast),
    .i_axi_llc_rvalid(w_llc_axi_rsp_rvalid),
    .o_axi_llc_rready(w_llc_axi_req_rready)
  );

  m_vlsit_riscv_axi_mmio #(
    .PARA_CPU_NUM(PARA_CPU_NUM)
  ) u_vlsit_riscv_axi_mmio (
    .i_clk_cluster(i_clk_cluster),
    .i_rst_n_cluster(i_rst_n_cluster),
    .i_axi_src_awid(w_route_mmio_awid),
    .i_axi_src_awaddr(w_route_mmio_awaddr),
    .i_axi_src_awlen(w_route_mmio_awlen),
    .i_axi_src_awsize(w_route_mmio_awsize),
    .i_axi_src_awburst(w_route_mmio_awburst),
    .i_axi_src_awlock(w_route_mmio_awlock),
    .i_axi_src_awcache(w_route_mmio_awcache),
    .i_axi_src_awprot(w_route_mmio_awprot),
    .i_axi_src_awqos(w_route_mmio_awqos),
    .i_axi_src_awregion(w_route_mmio_awregion),
    .i_axi_src_awvalid(w_route_mmio_awvalid),
    .o_axi_src_awready(w_mmio_mux_src_awready),
    .i_axi_src_wdata(w_route_mmio_wdata),
    .i_axi_src_wstrb(w_route_mmio_wstrb),
    .i_axi_src_wlast(w_route_mmio_wlast),
    .i_axi_src_wvalid(w_route_mmio_wvalid),
    .o_axi_src_wready(w_mmio_mux_src_wready),
    .o_axi_src_bid(w_mmio_mux_src_bid),
    .o_axi_src_bresp(w_mmio_mux_src_bresp),
    .o_axi_src_bvalid(w_mmio_mux_src_bvalid),
    .i_axi_src_bready(w_route_mmio_bready),
    .i_axi_src_arid(w_route_mmio_arid),
    .i_axi_src_araddr(w_route_mmio_araddr),
    .i_axi_src_arlen(w_route_mmio_arlen),
    .i_axi_src_arsize(w_route_mmio_arsize),
    .i_axi_src_arburst(w_route_mmio_arburst),
    .i_axi_src_arlock(w_route_mmio_arlock),
    .i_axi_src_arcache(w_route_mmio_arcache),
    .i_axi_src_arprot(w_route_mmio_arprot),
    .i_axi_src_arqos(w_route_mmio_arqos),
    .i_axi_src_arregion(w_route_mmio_arregion),
    .i_axi_src_arvalid(w_route_mmio_arvalid),
    .o_axi_src_arready(w_mmio_mux_src_arready),
    .o_axi_src_rid(w_mmio_mux_src_rid),
    .o_axi_src_rdata(w_mmio_mux_src_rdata),
    .o_axi_src_rresp(w_mmio_mux_src_rresp),
    .o_axi_src_rlast(w_mmio_mux_src_rlast),
    .o_axi_src_rvalid(w_mmio_mux_src_rvalid),
    .i_axi_src_rready(w_route_mmio_rready),
    .o_axi_mmio_awid(o_axi_mmio_awid),
    .o_axi_mmio_awaddr(o_axi_mmio_awaddr),
    .o_axi_mmio_awlen(o_axi_mmio_awlen),
    .o_axi_mmio_awsize(o_axi_mmio_awsize),
    .o_axi_mmio_awburst(o_axi_mmio_awburst),
    .o_axi_mmio_awlock(o_axi_mmio_awlock),
    .o_axi_mmio_awcache(o_axi_mmio_awcache),
    .o_axi_mmio_awprot(o_axi_mmio_awprot),
    .o_axi_mmio_awqos(o_axi_mmio_awqos),
    .o_axi_mmio_awregion(o_axi_mmio_awregion),
    .o_axi_mmio_awvalid(o_axi_mmio_awvalid),
    .i_axi_mmio_awready(i_axi_mmio_awready),
    .o_axi_mmio_wdata(o_axi_mmio_wdata),
    .o_axi_mmio_wstrb(o_axi_mmio_wstrb),
    .o_axi_mmio_wlast(o_axi_mmio_wlast),
    .o_axi_mmio_wvalid(o_axi_mmio_wvalid),
    .i_axi_mmio_wready(i_axi_mmio_wready),
    .i_axi_mmio_bid(i_axi_mmio_bid),
    .i_axi_mmio_bresp(i_axi_mmio_bresp),
    .i_axi_mmio_bvalid(i_axi_mmio_bvalid),
    .o_axi_mmio_bready(o_axi_mmio_bready),
    .o_axi_mmio_arid(o_axi_mmio_arid),
    .o_axi_mmio_araddr(o_axi_mmio_araddr),
    .o_axi_mmio_arlen(o_axi_mmio_arlen),
    .o_axi_mmio_arsize(o_axi_mmio_arsize),
    .o_axi_mmio_arburst(o_axi_mmio_arburst),
    .o_axi_mmio_arlock(o_axi_mmio_arlock),
    .o_axi_mmio_arcache(o_axi_mmio_arcache),
    .o_axi_mmio_arprot(o_axi_mmio_arprot),
    .o_axi_mmio_arqos(o_axi_mmio_arqos),
    .o_axi_mmio_arregion(o_axi_mmio_arregion),
    .o_axi_mmio_arvalid(o_axi_mmio_arvalid),
    .i_axi_mmio_arready(i_axi_mmio_arready),
    .i_axi_mmio_rid(i_axi_mmio_rid),
    .i_axi_mmio_rdata(i_axi_mmio_rdata),
    .i_axi_mmio_rresp(i_axi_mmio_rresp),
    .i_axi_mmio_rlast(i_axi_mmio_rlast),
    .i_axi_mmio_rvalid(i_axi_mmio_rvalid),
    .o_axi_mmio_rready(o_axi_mmio_rready)
  );

  // LLC uses address range matching to bypass normal-uncached accesses.
  m_vlsit_axi_llc #(
    .PARA_LLC_WAY_NUM(PARA_LLC_WAY_NUM),
    .PARA_LLC_NO_LINES(PARA_LLC_NO_LINES),
    .PARA_LLC_BLOCK_NUM(PARA_LLC_BLOCK_NUM)
  ) u_vlsit_axi_llc (
    .i_maint_valid(w_maint_valid),.o_maint_ready(w_maint_ready),
    .i_maint_op(w_maint_op),.i_maint_pa_line(w_maint_pa_line),
    .o_maint_done(w_maint_done),.o_maint_error(w_maint_error),
    .i_clk_cluster(i_clk_cluster),
    .i_rst_n_cluster(i_rst_n_cluster),
    .i_test_en(1'(LPARA_LLC_TEST_EN)),
    .i_cached_start_addr(w_llc_cached_start_addr),
    .i_cached_end_addr(w_llc_cached_end_addr),
    .i_axi_cpu_awid(w_llc_axi_req_awid),
    .i_axi_cpu_awatop(w_llc_axi_req_awatop),
    .i_axi_cpu_awaddr(w_llc_axi_req_awaddr),
    .i_axi_cpu_awlen(w_llc_axi_req_awlen),
    .i_axi_cpu_awsize(w_llc_axi_req_awsize),
    .i_axi_cpu_awburst(w_llc_axi_req_awburst),
    .i_axi_cpu_awlock(w_llc_axi_req_awlock),
    .i_axi_cpu_awcache(w_llc_axi_req_awcache),
    .i_axi_cpu_awprot(w_llc_axi_req_awprot),
    .i_axi_cpu_awqos(w_llc_axi_req_awqos),
    .i_axi_cpu_awregion(w_llc_axi_req_awregion),
    .i_axi_cpu_awvalid(w_llc_axi_req_awvalid),
    .o_axi_cpu_awready(w_llc_axi_rsp_awready),
    .i_axi_cpu_wdata(w_llc_axi_req_wdata),
    .i_axi_cpu_wstrb(w_llc_axi_req_wstrb),
    .i_axi_cpu_wlast(w_llc_axi_req_wlast),
    .i_axi_cpu_wvalid(w_llc_axi_req_wvalid),
    .o_axi_cpu_wready(w_llc_axi_rsp_wready),
    .o_axi_cpu_bid(w_llc_axi_rsp_bid),
    .o_axi_cpu_bresp(w_llc_axi_rsp_bresp),
    .o_axi_cpu_bvalid(w_llc_axi_rsp_bvalid),
    .i_axi_cpu_bready(w_llc_axi_req_bready),
    .i_axi_cpu_arid(w_llc_axi_req_arid),
    .i_axi_cpu_araddr(w_llc_axi_req_araddr),
    .i_axi_cpu_arlen(w_llc_axi_req_arlen),
    .i_axi_cpu_arsize(w_llc_axi_req_arsize),
    .i_axi_cpu_arburst(w_llc_axi_req_arburst),
    .i_axi_cpu_arlock(w_llc_axi_req_arlock),
    .i_axi_cpu_arcache(w_llc_axi_req_arcache),
    .i_axi_cpu_arprot(w_llc_axi_req_arprot),
    .i_axi_cpu_arqos(w_llc_axi_req_arqos),
    .i_axi_cpu_arregion(w_llc_axi_req_arregion),
    .i_axi_cpu_arvalid(w_llc_axi_req_arvalid),
    .o_axi_cpu_arready(w_llc_axi_rsp_arready),
    .o_axi_cpu_rid(w_llc_axi_rsp_rid),
    .o_axi_cpu_rdata(w_llc_axi_rsp_rdata),
    .o_axi_cpu_rresp(w_llc_axi_rsp_rresp),
    .o_axi_cpu_rlast(w_llc_axi_rsp_rlast),
    .o_axi_cpu_rvalid(w_llc_axi_rsp_rvalid),
    .i_axi_cpu_rready(w_llc_axi_req_rready),
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
    .i_reg_req_valid(w_llc_reg_req_valid),
    .i_reg_req_wr(w_llc_reg_req_wr),
    .i_reg_req_addr(w_llc_reg_req_addr),
    .i_reg_req_wdata(w_llc_reg_req_wdata),
    .i_reg_req_wstrb(w_llc_reg_req_wstrb),
    .o_reg_rsp_ready(w_llc_reg_rsp_ready),
    .o_reg_rsp_rdata(w_llc_reg_rsp_rdata),
    .o_reg_rsp_err(w_llc_reg_rsp_err),
    .o_wb_fault(w_llc_wb_fault),
    .o_wb_fault_event(w_llc_wb_fault_event),
    .o_wb_fault_addr(w_llc_wb_fault_addr),
    .o_wb_fault_resp(w_llc_wb_fault_resp),
    .o_llc_events(w_llc_events)
  );


  // DEC-036/A-03: an ordinary eviction failure cannot be recovered by W1C.
  // Preserve its interrupt source until reset even if diagnostic CSR is cleared.
  logic reg_l1_evict_fault;
  logic [3:0] w_l1_evict_fault_event;
  for (genvar gen_idx = 0; gen_idx < 4; gen_idx++) begin : gen_evict_fault
    // Decode only accepted ordinary writeback failures for this hart.
    assign w_l1_evict_fault_event[gen_idx] = w_tile_dcache_flush_ack_valid[gen_idx] &&
                                            w_tile_dcache_flush_ack_err[gen_idx] &&
                                            (w_tile_dcache_flush_ack_origin[gen_idx] == 2'b00);
  end
  // DEC-039/040: native flush ACK is combinational from the ID-checked
  // accepted tile B response. Capture its raw BRESP before error compression.
  for (genvar gen_idx = 0; gen_idx < 4; gen_idx++) begin : gen_fault_addr
    // Reconstruct the matched physical line base with four zero offset bits.
    assign w_l1_fault_addr[gen_idx] = {w_tile_dcache_flush_ack_nline[gen_idx], 4'b0};
  end
  m_vlsit_riscv_fault_record #(.PARA_CPU_NUM(PARA_CPU_NUM)) u_vlsit_riscv_fault_record (
    .i_clk_cluster(i_clk_cluster), .i_rst_n_cluster(i_rst_n_cluster),
    .i_l1_fault_valid(w_l1_evict_fault_event), .i_l1_fault_addr(w_l1_fault_addr),
    .i_l1_fault_resp(w_route_bresp), .i_llc_fault_valid(w_llc_wb_fault_event),
    .i_llc_fault_addr(w_llc_wb_fault_addr[55:0]), .i_llc_fault_resp(w_llc_wb_fault_resp),
    .o_fault_sts(w_fault_sts), .o_fault_info(w_fault_info),
    .o_fault_addr_lo(w_fault_addr_lo), .o_fault_addr_hi(w_fault_addr_hi)
  );

  // Hold fatal eviction notification through software W1C until reset.
  always_ff @(posedge i_clk_cluster, negedge i_rst_n_cluster) begin : p_ff_l1_evict_fault
    if (!i_rst_n_cluster)
      reg_l1_evict_fault <= 1'b0;
    else if (|w_l1_evict_fault_event)
      reg_l1_evict_fault <= 1'b1;
  end

  // Capture tile-array coherence and writeback diagnostics in the generated sticky CSR.
  assign w_fault_set_event = (|w_tile_coh_proto_diag_event) |
                             (|w_tile_coh_lock_diag_event) |
                             (|w_tile_dcache_flush_ack_err) |
                             (|w_tile_flush_rsp_invalid) | w_llc_wb_fault | reg_l1_evict_fault;
  // Nonfatal diagnostics retain W1C; fatal ordinary-eviction IRQ requires reset.
  assign w_cpucl_coh_fault_wdata = 1'b1;
  assign w_cpucl_coh_fault_we = w_fault_set_event;
  assign o_int_fault = w_cpucl_coh_fault | reg_l1_evict_fault;

  m_vlsit_riscv_pmu #(
    .PARA_CPU_NUM(PARA_CPU_NUM),
    .PARA_PMU_CNT_NUM(PARA_PMU_COUNTER_NUM),
    .PARA_PMU_CNT_W(PARA_PMU_COUNTER_W)
  ) u_vlsit_riscv_pmu (
    .i_clk_cluster(i_clk_cluster), .i_rst_n_cluster(i_rst_n_cluster),
    .i_hart_active(w_hart_active[PARA_CPU_NUM-1:0]),
    .i_cva6_evt(w_tile_perf_event[PARA_CPU_NUM-1:0]),
    .i_hpdcache_evt(w_tile_hpdcache_perf_event[PARA_CPU_NUM-1:0]),
    .i_llc_evt(w_llc_events), .i_ccu_evt_count(w_ccu_evt_count),
    .i_pmu_evt_event_id(w_pmu_evt_event_id), .i_pmu_evt_scope(w_pmu_evt_scope),
    .i_pmu_evt_en(w_pmu_evt_en), .i_pmu_ctrl_snapshot_req(w_pmu_ctrl_snapshot_req),
    .i_irq_en_overflow_en(w_irq_en_overflow_en), .i_irq_raw_overflow(w_irq_raw_overflow),
    .o_pmu_count_lo_value(w_pmu_count_lo_value), .o_pmu_count_hi_value(w_pmu_count_hi_value),
    .o_pmu_ctrl_snapshot_req_clear(w_pmu_ctrl_snapshot_req_clear),
    .o_pmu_ctrl_snapshot_done_wdata(w_pmu_ctrl_snapshot_done_wdata),
    .o_pmu_ctrl_snapshot_done_we(w_pmu_ctrl_snapshot_done_we),
    .o_irq_raw_overflow_wdata(w_irq_raw_overflow_wdata),
    .o_irq_raw_overflow_we(w_irq_raw_overflow_we),
    .o_irq_sts_overflow_pending(w_irq_sts_overflow_pending), .o_int_pmu(o_int_pmu)
  );


  // Target response wires join CSR and LLC service blocks to the AXI-Lite decoder.
  logic [1:0][31:0] w_axil_target_awaddr;
  logic [1:0][2:0] w_axil_target_awprot;
  logic [1:0] w_axil_target_awvalid;
  logic [1:0] w_axil_target_awready;
  logic [1:0][31:0] w_axil_target_wdata;
  logic [1:0][3:0] w_axil_target_wstrb;
  logic [1:0] w_axil_target_wvalid;
  logic [1:0] w_axil_target_wready;
  logic [1:0][1:0] w_axil_target_bresp;
  logic [1:0] w_axil_target_bvalid;
  logic [1:0] w_axil_target_bready;
  logic [1:0][31:0] w_axil_target_araddr;
  logic [1:0][2:0] w_axil_target_arprot;
  logic [1:0] w_axil_target_arvalid;
  logic [1:0] w_axil_target_arready;
  logic [1:0][31:0] w_axil_target_rdata;
  logic [1:0][1:0] w_axil_target_rresp;
  logic [1:0] w_axil_target_rvalid;
  logic [1:0] w_axil_target_rready;

  // PMU and fault CSR signals.
  logic w_pmu_ctrl_snapshot_req;
  logic w_pmu_ctrl_snapshot_req_clear;
  logic w_pmu_ctrl_snapshot_done;
  logic w_pmu_ctrl_snapshot_done_wdata;
  logic w_pmu_ctrl_snapshot_done_we;
  logic [31:0] w_irq_en_overflow_en;
  logic [31:0] w_irq_raw_overflow;
  logic [31:0] w_irq_raw_overflow_wdata;
  logic w_irq_raw_overflow_we;
  logic [31:0] w_irq_sts_overflow_pending;
  logic w_cpucl_coh_fault;
  logic w_cpucl_coh_fault_wdata;
  logic w_cpucl_coh_fault_we;
  logic [PARA_PMU_COUNTER_NUM-1:0][15:0] w_pmu_evt_event_id;
  logic [PARA_PMU_COUNTER_NUM-1:0][2:0] w_pmu_evt_scope;
  logic [PARA_PMU_COUNTER_NUM-1:0] w_pmu_evt_en;
  logic [PARA_PMU_COUNTER_NUM-1:0][31:0] w_pmu_count_lo_value;
  logic [PARA_PMU_COUNTER_NUM-1:0][31:0] w_pmu_count_hi_value;
  logic w_fault_set_event;

  m_vlsit_riscv_axil_decode #(.PARA_AXIL_BASE_ADDR(PARA_AXIL_BASE_ADDR))
  u_vlsit_riscv_axil_decode (
    .i_clk_cluster(i_clk_cluster), .i_rst_n_cluster(i_rst_n_cluster),
    .i_axil_awaddr(i_axil_awaddr), .i_axil_awprot(i_axil_awprot), .i_axil_awvalid(i_axil_awvalid),
    .o_axil_awready(o_axil_awready), .i_axil_wdata(i_axil_wdata), .i_axil_wstrb(i_axil_wstrb),
    .i_axil_wvalid(i_axil_wvalid), .o_axil_wready(o_axil_wready), .o_axil_bresp(o_axil_bresp),
    .o_axil_bvalid(o_axil_bvalid), .i_axil_bready(i_axil_bready), .i_axil_araddr(i_axil_araddr),
    .i_axil_arprot(i_axil_arprot), .i_axil_arvalid(i_axil_arvalid), .o_axil_arready(o_axil_arready),
    .o_axil_rdata(o_axil_rdata), .o_axil_rresp(o_axil_rresp), .o_axil_rvalid(o_axil_rvalid),
    .i_axil_rready(i_axil_rready), .o_axil_target_awaddr(w_axil_target_awaddr),
    .o_axil_target_awprot(w_axil_target_awprot), .o_axil_target_awvalid(w_axil_target_awvalid),
    .i_axil_target_awready(w_axil_target_awready), .o_axil_target_wdata(w_axil_target_wdata),
    .o_axil_target_wstrb(w_axil_target_wstrb), .o_axil_target_wvalid(w_axil_target_wvalid),
    .i_axil_target_wready(w_axil_target_wready), .i_axil_target_bresp(w_axil_target_bresp),
    .i_axil_target_bvalid(w_axil_target_bvalid), .o_axil_target_bready(w_axil_target_bready),
    .o_axil_target_araddr(w_axil_target_araddr), .o_axil_target_arprot(w_axil_target_arprot),
    .o_axil_target_arvalid(w_axil_target_arvalid), .i_axil_target_arready(w_axil_target_arready),
    .i_axil_target_rdata(w_axil_target_rdata), .i_axil_target_rresp(w_axil_target_rresp),
    .i_axil_target_rvalid(w_axil_target_rvalid), .o_axil_target_rready(w_axil_target_rready)
  );

  m_vlsit_cpucl_csr #(
    .PARA_PMU_EVT_COUNT(PARA_PMU_COUNTER_NUM),
    .PARA_PMU_COUNT_LO_COUNT(PARA_PMU_COUNTER_NUM),
    .PARA_PMU_COUNT_HI_COUNT(PARA_PMU_COUNTER_NUM)
  ) u_vlsit_cpucl_csr (
    .i_clk_axi(i_clk_cluster), .i_rst_n_axi(i_rst_n_cluster),
    .i_clk_reg(i_clk_cluster), .i_rst_n_reg(i_rst_n_cluster),
    .i_axi_awvalid(w_axil_target_awvalid[0]), .o_axi_awready(w_axil_target_awready[0]),
    .i_axi_awaddr(w_axil_target_awaddr[0]), .i_axi_awprot(w_axil_target_awprot[0]),
    .i_axi_wvalid(w_axil_target_wvalid[0]), .o_axi_wready(w_axil_target_wready[0]),
    .i_axi_wdata(w_axil_target_wdata[0]), .i_axi_wstrb(w_axil_target_wstrb[0]),
    .o_axi_bvalid(w_axil_target_bvalid[0]), .i_axi_bready(w_axil_target_bready[0]),
    .o_axi_bresp(w_axil_target_bresp[0]), .i_axi_arvalid(w_axil_target_arvalid[0]),
    .o_axi_arready(w_axil_target_arready[0]), .i_axi_araddr(w_axil_target_araddr[0]),
    .i_axi_arprot(w_axil_target_arprot[0]), .o_axi_rvalid(w_axil_target_rvalid[0]),
    .i_axi_rready(w_axil_target_rready[0]), .o_axi_rdata(w_axil_target_rdata[0]),
    .o_axi_rresp(w_axil_target_rresp[0]), .o_pmu_ctrl_snapshot_req(w_pmu_ctrl_snapshot_req),
    .i_hw_clr_pmu_ctrl_snapshot_req(w_pmu_ctrl_snapshot_req_clear),
    .o_pmu_ctrl_snapshot_done(w_pmu_ctrl_snapshot_done),
    .i_hw_wdata_pmu_snap_done(w_pmu_ctrl_snapshot_done_wdata),
    .i_hw_we_pmu_ctrl_snapshot_done(w_pmu_ctrl_snapshot_done_we),
    .o_irq_en_overflow_en(w_irq_en_overflow_en), .o_irq_raw_overflow(w_irq_raw_overflow),
    .i_hw_wdata_irq_raw_overflow(w_irq_raw_overflow_wdata),
    .i_hw_we_irq_raw_overflow(w_irq_raw_overflow_we),
    .i_irq_sts_overflow_pending(w_irq_sts_overflow_pending),
    .i_cpucl_fault_sts_value(w_fault_sts), .i_cpucl_fault_info_value(w_fault_info),
    .i_cpucl_fault_lo_value(w_fault_addr_lo), .i_cpucl_fault_hi_value(w_fault_addr_hi),
    .o_cpucl_coh_fault(w_cpucl_coh_fault),
    .i_hw_wdata_cpucl_coh_fault(w_cpucl_coh_fault_wdata),
    .i_hw_we_cpucl_coh_fault(w_cpucl_coh_fault_we),
    .o_pmu_evt_event_id(w_pmu_evt_event_id), .o_pmu_evt_scope(w_pmu_evt_scope),
    .o_pmu_evt_en(w_pmu_evt_en), .i_pmu_count_lo_value(w_pmu_count_lo_value),
    .i_pmu_count_hi_value(w_pmu_count_hi_value)
  );

  m_vlsit_axil_reg_bridge u_vlsit_axil_reg_bridge (
    .i_clk_cluster(i_clk_cluster), .i_rst_n_cluster(i_rst_n_cluster),
    .i_axil_awaddr(w_axil_target_awaddr[1]), .i_axil_awprot(w_axil_target_awprot[1]),
    .i_axil_awvalid(w_axil_target_awvalid[1]), .o_axil_awready(w_axil_target_awready[1]),
    .i_axil_wdata(w_axil_target_wdata[1]), .i_axil_wstrb(w_axil_target_wstrb[1]),
    .i_axil_wvalid(w_axil_target_wvalid[1]), .o_axil_wready(w_axil_target_wready[1]),
    .o_axil_bresp(w_axil_target_bresp[1]), .o_axil_bvalid(w_axil_target_bvalid[1]),
    .i_axil_bready(w_axil_target_bready[1]), .i_axil_araddr(w_axil_target_araddr[1]),
    .i_axil_arprot(w_axil_target_arprot[1]), .i_axil_arvalid(w_axil_target_arvalid[1]),
    .o_axil_arready(w_axil_target_arready[1]), .o_axil_rdata(w_axil_target_rdata[1]),
    .o_axil_rresp(w_axil_target_rresp[1]), .o_axil_rvalid(w_axil_target_rvalid[1]),
    .i_axil_rready(w_axil_target_rready[1]), .o_reg_req_valid(w_llc_reg_req_valid),
    .o_reg_req_wr(w_llc_reg_req_wr), .o_reg_req_addr(w_llc_reg_req_addr),
    .o_reg_req_wdata(w_llc_reg_req_wdata), .o_reg_req_wstrb(w_llc_reg_req_wstrb),
    .i_reg_rsp_ready(w_llc_reg_rsp_ready), .i_reg_rsp_rdata(w_llc_reg_rsp_rdata),
    .i_reg_rsp_err(w_llc_reg_rsp_err)
  );

  logic w_llc_reg_req_valid;
  logic w_llc_reg_req_wr;
  logic [6:0] w_llc_reg_req_addr;
  logic [31:0] w_llc_reg_req_wdata;
  logic [3:0] w_llc_reg_req_wstrb;
  logic w_llc_reg_rsp_ready;
  logic [31:0] w_llc_reg_rsp_rdata;
  logic w_llc_reg_rsp_err;


endmodule
