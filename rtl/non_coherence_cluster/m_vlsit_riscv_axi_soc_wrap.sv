/*
 * Project      : VLSIT RISC-V CPU Cluster
 * Author       : Quan Nguyen (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-21
 * Description  : Adapts four-slot SoC IRQ/debug wiring to the parameterized AXI TOP.
 */
`timescale 1ns/1ps

module m_vlsit_riscv_axi_soc_wrap #(
  // Parameter Description: number of active CVA6 harts.
  // Parameter values: 2 or 4; default is 4.
  // Parameter unit: harts.
  parameter logic [31:0] PARA_CPU_NUM = 32'd4,
  // Parameter Description: compile-time cluster timing profile; CVA6 internals are unchanged.
  // Parameter values: 0 = baseline, 1 = tile cuts, 2 = boundary profile.
  // Parameter unit: profile index.
  parameter logic [31:0] PARA_TIMING_PROFILE = 32'd0,
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
  // Parameter Description: AXI4-Lite base address for the 24-KiB cluster CSR
  // and LLC-service aperture.
  // Parameter values: 4-KiB aligned addresses from 0 through 0xFFFFA000; default is 0.
  // Parameter unit: bytes.
  parameter logic [31:0] PARA_AXIL_BASE_ADDR = 32'h0000_0000,
  // Parameter Description: AXI memory data width outside the fixed 64-bit LLC interface.
  // Parameter values: 32, 64, 128, or 256; default is 64.
  // Parameter unit: bits.
  parameter logic [31:0] PARA_AXI_MEM_DATA_W = 32'd64,
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
  parameter logic [31:0] PARA_ADDR_REGION_TYPE [0:15] = '{default:32'd0}
) (
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
  output logic [PARA_AXI_MEM_DATA_W-1:0]   o_axi_mem_wdata,
  output logic [PARA_AXI_MEM_DATA_W/8-1:0] o_axi_mem_wstrb,
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
  input  wire  [PARA_AXI_MEM_DATA_W-1:0]   i_axi_mem_rdata,
  input  wire  [1:0]                       i_axi_mem_rresp,
  input  wire                              i_axi_mem_rlast,
  input  wire                              i_axi_mem_rvalid,
  output logic                             o_axi_mem_rready
);

  logic [PARA_CPU_NUM-1:0] w_hart_debug_mode;

  // Absent hart status bits read zero at the legacy SoC boundary.
  assign o_hart_debug_mode = 4'(w_hart_debug_mode);

  m_vlsit_riscv_cluster_axi_top #(
    .PARA_CPU_NUM(PARA_CPU_NUM),
    .PARA_TIMING_PROFILE(PARA_TIMING_PROFILE),
    .PARA_COH_TXN_NUM(PARA_COH_TXN_NUM),
    .PARA_LLC_WAY_NUM(PARA_LLC_WAY_NUM),
    .PARA_LLC_NO_LINES(PARA_LLC_NO_LINES),
    .PARA_LLC_BLOCK_NUM(PARA_LLC_BLOCK_NUM),
    .PARA_AXIL_BASE_ADDR(PARA_AXIL_BASE_ADDR),
    .PARA_AXI_MEM_DATA_W(PARA_AXI_MEM_DATA_W),
    .PARA_PMU_COUNTER_NUM(PARA_PMU_COUNTER_NUM),
    .PARA_PMU_COUNTER_W(PARA_PMU_COUNTER_W),
    .PARA_ADDR_REGION_NUM(PARA_ADDR_REGION_NUM),
    .PARA_ADDR_REGION_BASE_LO(PARA_ADDR_REGION_BASE_LO),
    .PARA_ADDR_REGION_BASE_HI(PARA_ADDR_REGION_BASE_HI),
    .PARA_ADDR_REGION_SIZE_LO(PARA_ADDR_REGION_SIZE_LO),
    .PARA_ADDR_REGION_SIZE_HI(PARA_ADDR_REGION_SIZE_HI),
    .PARA_ADDR_REGION_TYPE(PARA_ADDR_REGION_TYPE)
  ) u_vlsit_riscv_cluster_axi_top (
    .i_clk_cluster(i_clk_cluster),
    .i_rst_n_cluster(i_rst_n_cluster),
    .i_boot_addr(i_boot_addr),
    .i_int_msip(i_int_msip[PARA_CPU_NUM-1:0]),
    .i_int_mtip(i_int_mtip[PARA_CPU_NUM-1:0]),
    .i_int_meip(i_int_meip[PARA_CPU_NUM-1:0]),
    .i_int_ssip(i_int_ssip[PARA_CPU_NUM-1:0]),
    .i_int_stip(i_int_stip[PARA_CPU_NUM-1:0]),
    .i_int_seip(i_int_seip[PARA_CPU_NUM-1:0]),
    .i_hart_debug_req(i_hart_debug_req[PARA_CPU_NUM-1:0]),
    .o_hart_debug_mode(w_hart_debug_mode),
    .o_int_pmu(o_int_pmu),
    .o_int_fault(o_int_fault),
    .i_axil_awaddr(i_axil_awaddr),
    .i_axil_awprot(i_axil_awprot),
    .i_axil_awvalid(i_axil_awvalid),
    .o_axil_awready(o_axil_awready),
    .i_axil_wdata(i_axil_wdata),
    .i_axil_wstrb(i_axil_wstrb),
    .i_axil_wvalid(i_axil_wvalid),
    .o_axil_wready(o_axil_wready),
    .o_axil_bresp(o_axil_bresp),
    .o_axil_bvalid(o_axil_bvalid),
    .i_axil_bready(i_axil_bready),
    .i_axil_araddr(i_axil_araddr),
    .i_axil_arprot(i_axil_arprot),
    .i_axil_arvalid(i_axil_arvalid),
    .o_axil_arready(o_axil_arready),
    .o_axil_rdata(o_axil_rdata),
    .o_axil_rresp(o_axil_rresp),
    .o_axil_rvalid(o_axil_rvalid),
    .i_axil_rready(i_axil_rready),
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
    .o_axi_mmio_rready(o_axi_mmio_rready),
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
    .o_axi_mem_rready(o_axi_mem_rready)
  );

endmodule
