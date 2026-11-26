/*
 * Project      : VLSIT RISC-V CPU Cluster
 * Author       : Quan Nguyen (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-15
 * Description  : Instantiates the active CVA6 tiles and connects their native
 *                ownership/probe channels to the shared coherence tile array.
 * Change History:
 * 2026-11-15 - Quan Nguyen and Codex - VLSI Technology page:
 *              Export per-hart HPDcache PMU event indicators.
 * 2026-11-15 - Quan Nguyen and Codex - VLSI Technology page:
 *              Route per-hart oldest pending CBO metadata to the cluster core.
 * History      : Quan Nguyen and Codex - VLSI Technology page.
 *                DEC-045: Add optional cluster boundary timing profile support.
 */
`timescale 1ns/1ps

module m_vlsit_riscv_cpu_tile_array #(
  // Parameter Description: enable the internal CMO retirement/service path.
  // Parameter values: 0 or 1; default 0 for standalone adapters.
  // Parameter unit: none.
  parameter logic [31:0] PARA_CMO_EN = 32'd0,
  // Parameter Description: number of active CVA6 harts.
  // Parameter values: 2 or 4; default is 4.
  // Parameter unit: harts.
  parameter logic [31:0] PARA_CPU_NUM = 32'd4,
  // Parameter Description: number of tagged CCU transactions.
  // Parameter values: 2 through 16; default is 8.
  // Parameter unit: transaction contexts.
  parameter logic [31:0] PARA_COH_TXN_NUM = 32'd8,
  // Parameter Description: register the release of handshake gates.
  // Parameter values: 0 = legacy, 1 = registered; default is 0.
  // Parameter unit: mode
  parameter logic [31:0] PARA_REGISTER_RESET_RELEASE = 32'd0,
  // Parameter Description: use synchronous directory storage.
  // Parameter values: 0 = legacy, 1 = synchronous; default is 0.
  // Parameter unit: mode
  parameter logic [31:0] PARA_DIR_SYNC_READ = 32'd0,
  // Parameter Description: active address regions shared by CVA6 PMA and AXI routing.
  // Parameter values: 1 through 16; default contains the CVA6 cacheable window.
  // Parameter unit: regions.
  parameter logic [31:0] PARA_ADDR_REGION_NUM = 32'd1,
  // Parameter Description: low 32 bits of each region base address.
  // Parameter values: active bases are aligned to a 16-byte line.
  // Parameter unit: bytes.
  parameter logic [31:0] PARA_ADDR_REGION_BASE_LO [0:15] = '{default:32'd0, 0:32'h8000_0000},
  // Parameter Description: high 32 bits of each region base address.
  // Parameter values: active bases are below 2^56.
  // Parameter unit: bytes.
  parameter logic [31:0] PARA_ADDR_REGION_BASE_HI [0:15] = '{default:32'd0},
  // Parameter Description: low 32 bits of each region size.
  // Parameter values: active sizes are non-zero 16-byte multiples.
  // Parameter unit: bytes.
  parameter logic [31:0] PARA_ADDR_REGION_SIZE_LO [0:15] = '{default:32'd0, 0:32'h4000_0000},
  // Parameter Description: high 32 bits of each region size.
  // Parameter values: active sizes are 16-byte multiples.
  // Parameter unit: bytes.
  parameter logic [31:0] PARA_ADDR_REGION_SIZE_HI [0:15] = '{default:32'd0},
  // Parameter Description: region class encoding: 0 cacheable, 1 normal uncached, 2 MMIO.
  // Parameter values: upper bits must be zero; class 3 is reserved.
  // Parameter unit: none.
  parameter logic [31:0] PARA_ADDR_REGION_TYPE [0:15] = '{default:32'd0},
  localparam logic [31:0] LPARA_COH_TAG_W = (PARA_COH_TXN_NUM > 32'd1)
                                           ? 32'($clog2(PARA_COH_TXN_NUM)) : 32'd1
) (
  // Retirement-owned CMO command and completion.
  output logic [3:0]                 o_cmo_req_valid,
  input  wire  [3:0]                 i_cmo_req_ready,
  output logic [3:0][1:0]            o_cmo_req_op,
  output logic [3:0][51:0]           o_cmo_req_pa_line,
  output logic [3:0][63:0]           o_cmo_req_vaddr,
  output logic [3:0][63:0]           o_cmo_req_pc,
  input  wire  [3:0]                 i_cmo_rsp_done,
  input  wire  [3:0]                 i_cmo_rsp_err,

  // Shared CMO controller service; contexts and locks remain in this fabric.
  input  wire                        i_ccu_begin_valid,
  output logic                       o_ccu_begin_ready,
  input  wire  [1:0]                 i_ccu_begin_op,
  input  wire  [51:0]                i_ccu_begin_pa_line,
  input  wire  [1:0]                 i_ccu_begin_hart,
  input  wire                        i_ccu_begin_wback_en,
  output logic                       o_ccu_prepare_valid,
  input  wire                        i_ccu_prepare_ready,
  output logic [LPARA_COH_TAG_W-1:0] o_ccu_prepare_tag,
  output logic                       o_ccu_prepare_err,
  input  wire                        i_ccu_finish_valid,
  output logic                       o_ccu_finish_ready,
  input  wire  [LPARA_COH_TAG_W-1:0] i_ccu_finish_tag,
  input  wire                        i_ccu_finish_commit,
  output logic                       o_ccu_finish_done,

  // Clock and reset
  input  wire                        i_clk_cluster,
  input  wire                        i_rst_n_cluster,

  // Boot and interrupt control
  input  wire  [63:0]                i_boot_addr,
  input  wire  [3:0]                 i_int_msip,
  input  wire  [3:0]                 i_int_mtip,
  input  wire  [3:0]                 i_int_meip,
  input  wire  [3:0]                 i_int_ssip,
  input  wire  [3:0]                 i_int_stip,
  input  wire  [3:0]                 i_int_seip,
  input  wire  [3:0]                 i_hart_debug_req,
  output logic [3:0]                 o_hart_debug_mode,

  // Coherence line-lock observation from each native HPDcache Stage-1 request
  // and selected replacement victim.
  output logic [3:0]                 o_coh_access_locked,
  output logic [3:0]                 o_coh_victim_locked,

  // AXI4 AW channel
  output logic [3:0][3:0]            o_axi_awid,
  output logic [3:0][5:0]            o_axi_awatop,
  output logic [3:0][63:0]           o_axi_awaddr,
  output logic [3:0][7:0]            o_axi_awlen,
  output logic [3:0][2:0]            o_axi_awsize,
  output logic [3:0][1:0]            o_axi_awburst,
  output logic [3:0]                 o_axi_awlock,
  output logic [3:0][3:0]            o_axi_awcache,
  output logic [3:0][2:0]            o_axi_awprot,
  output logic [3:0][3:0]            o_axi_awqos,
  output logic [3:0][3:0]            o_axi_awregion,
  output logic [3:0]                 o_axi_awvalid,
  input  wire  [3:0]                 i_axi_awready,

  // AXI4 W and B channels
  output logic [3:0][63:0]           o_axi_wdata,
  output logic [3:0][7:0]            o_axi_wstrb,
  output logic [3:0]                 o_axi_wlast,
  output logic [3:0]                 o_axi_wvalid,
  input  wire  [3:0]                 i_axi_wready,
  input  wire  [3:0][3:0]            i_axi_bid,
  input  wire  [3:0][1:0]            i_axi_bresp,
  input  wire  [3:0]                 i_axi_bvalid,
  output logic [3:0]                 o_axi_bready,

  // AXI4 AR channel
  output logic [3:0][3:0]            o_axi_arid,
  output logic [3:0][63:0]           o_axi_araddr,
  output logic [3:0][7:0]            o_axi_arlen,
  output logic [3:0][2:0]            o_axi_arsize,
  output logic [3:0][1:0]            o_axi_arburst,
  output logic [3:0]                 o_axi_arlock,
  output logic [3:0][3:0]            o_axi_arcache,
  output logic [3:0][2:0]            o_axi_arprot,
  output logic [3:0][3:0]            o_axi_arqos,
  output logic [3:0][3:0]            o_axi_arregion,
  output logic [3:0]                 o_axi_arvalid,
  input  wire  [3:0]                 i_axi_arready,

  // AXI4 R channel
  input  wire  [3:0][3:0]            i_axi_rid,
  input  wire  [3:0][63:0]           i_axi_rdata,
  input  wire  [3:0][1:0]            i_axi_rresp,
  input  wire  [3:0]                 i_axi_rlast,
  input  wire  [3:0]                 i_axi_rvalid,
  output logic [3:0]                 o_axi_rready,

  // Region, performance, and coherence status
  output logic [3:0]                 o_axi_aw_region_match,
  output logic [3:0][3:0]            o_axi_aw_region_idx,
  output logic [3:0][1:0]            o_axi_aw_region_type,
  output logic [3:0]                 o_axi_aw_region_err,
  output logic [3:0]                 o_axi_ar_region_match,
  output logic [3:0][3:0]            o_axi_ar_region_idx,
  output logic [3:0][1:0]            o_axi_ar_region_type,
  output logic [3:0]                 o_axi_ar_region_err,
  output logic [3:0]                 o_tile_region_cfg_valid,
  output logic                       o_region_cfg_valid,
  output logic [3:0][21:0]           o_perf_event,
  output logic [3:0][15:0]           o_hpdcache_perf_event,
  output logic [3:0]                 o_cmo_entry_valid,
  output logic [3:0][7:0]            o_cmo_entry_op,
  output logic [3:0][51:0]           o_cmo_entry_pa_line,
  output logic [3:0][63:0]           o_cmo_entry_vaddr,
  output logic [3:0]                 o_dcache_flush_ack_valid,
  output logic [3:0][51:0]           o_dcache_flush_ack_nline,
  output logic [3:0][1:0]            o_dcache_flush_ack_origin,
  output logic [3:0]                 o_dcache_flush_ack_err,
  output logic [3:0]                 o_dcache_flush_rsp_invalid,
  output logic [3:0]                 o_coh_lock_diag_event,
  output logic                       o_coh_proto_diag_event,
  output logic [2:0]                 o_dir_lookup_count,
  output logic [2:0]                 o_dir_update_count,
  output logic [11:0][2:0]           o_ccu_evt_count
);

  // Coherence transaction channels between active CPU tiles and the shared tile array.
  logic [PARA_CPU_NUM-1:0] w_tile_access_valid;
  logic [PARA_CPU_NUM-1:0][51:0] w_tile_access_pa_line;
  logic [PARA_CPU_NUM-1:0] w_tile_access_locked;
  logic [PARA_CPU_NUM-1:0] w_tile_victim_valid;
  logic [PARA_CPU_NUM-1:0][51:0] w_tile_victim_pa_line;
  logic [PARA_CPU_NUM-1:0] w_tile_victim_locked;
  logic [PARA_CPU_NUM-1:0] w_tile_req_valid;
  logic [PARA_CPU_NUM-1:0] w_tile_req_ready;
  logic [PARA_CPU_NUM-1:0][2:0] w_tile_req_id;
  logic [PARA_CPU_NUM-1:0][51:0] w_tile_req_pa_line;
  logic [PARA_CPU_NUM-1:0][1:0] w_tile_req_kind;
  logic [PARA_CPU_NUM-1:0] w_tile_gnt_valid;
  logic [PARA_CPU_NUM-1:0] w_tile_gnt_ready;
  logic [PARA_CPU_NUM-1:0][2:0] w_tile_gnt_id;
  logic [PARA_CPU_NUM-1:0][51:0] w_tile_gnt_pa_line;
  logic [PARA_CPU_NUM-1:0][1:0] w_tile_gnt_state;
  logic [PARA_CPU_NUM-1:0] w_tile_gnt_err;
  logic [PARA_CPU_NUM-1:0] w_tile_probe_req_valid;
  logic [PARA_CPU_NUM-1:0] w_tile_probe_req_ready;
  logic [PARA_CPU_NUM-1:0][LPARA_COH_TAG_W-1:0] w_tile_probe_req_tag;
  logic [PARA_CPU_NUM-1:0][51:0] w_tile_probe_req_pa_line;
  logic [PARA_CPU_NUM-1:0][1:0] w_tile_probe_req_phase;
  logic [PARA_CPU_NUM-1:0][1:0] w_tile_probe_req_target_state;
  logic [PARA_CPU_NUM-1:0] w_tile_probe_req_wback_en;
  logic [PARA_CPU_NUM-1:0] w_tile_probe_rsp_valid;
  logic [PARA_CPU_NUM-1:0] w_tile_probe_rsp_ready;
  logic [PARA_CPU_NUM-1:0][LPARA_COH_TAG_W-1:0] w_tile_probe_rsp_tag;
  logic [PARA_CPU_NUM-1:0][51:0] w_tile_probe_rsp_pa_line;
  logic [PARA_CPU_NUM-1:0][1:0] w_tile_probe_rsp_phase;
  logic [PARA_CPU_NUM-1:0][1:0] w_tile_probe_rsp_state;
  logic [PARA_CPU_NUM-1:0] w_tile_probe_rsp_err;
  logic [PARA_CPU_NUM-1:0] w_tile_probe_rsp_wback_done;
  logic [PARA_CPU_NUM-1:0] w_tile_probe_query_valid;
  logic [PARA_CPU_NUM-1:0][51:0] w_tile_probe_query_pa_line;
  logic [PARA_CPU_NUM-1:0] w_tile_probe_line_busy;
  logic [PARA_CPU_NUM-1:0][PARA_COH_TXN_NUM-1:0] w_tile_line_lock_valid;
  logic [PARA_CPU_NUM-1:0][PARA_COH_TXN_NUM-1:0][51:0] w_tile_line_lock_pa_line;
  logic [PARA_CPU_NUM-1:0] w_tile_lock_diag_event;
  logic w_coh_proto_diag_event;
  logic [2:0] w_dir_lookup_count;
  logic [2:0] w_dir_update_count;
  logic [11:0][2:0] w_ccu_evt_count;
  logic [3:0] w_addr_region_config_valid;

  // Route tagged ownership, probe, query, and line-lock channels for all active tiles.
  m_vlsit_riscv_coh_tile_array #(
      .PARA_REGISTER_RESET_RELEASE(PARA_REGISTER_RESET_RELEASE),
    .PARA_DIR_SYNC_READ(PARA_DIR_SYNC_READ),
    .PARA_CMO_EN(PARA_CMO_EN),
    .PARA_CPU_NUM(PARA_CPU_NUM),
    .PARA_COH_TXN_NUM(PARA_COH_TXN_NUM)
  ) u_vlsit_riscv_coh_tile_array (
    .i_ccu_begin_valid,
    .o_ccu_begin_ready,
    .i_ccu_begin_op,
    .i_ccu_begin_pa_line,
    .i_ccu_begin_hart,
    .i_ccu_begin_wback_en,
    .o_ccu_prepare_valid,
    .i_ccu_prepare_ready,
    .o_ccu_prepare_tag,
    .o_ccu_prepare_err,
    .i_ccu_finish_valid,
    .o_ccu_finish_ready,
    .i_ccu_finish_tag,
    .i_ccu_finish_commit,
    .o_ccu_finish_done,
    .i_clk_cluster(i_clk_cluster),
    .i_rst_n_cluster(i_rst_n_cluster),
    .i_tile_access_valid(w_tile_access_valid),
    .i_tile_access_pa_line(w_tile_access_pa_line),
    .o_tile_access_locked(w_tile_access_locked),
    .i_tile_victim_valid(w_tile_victim_valid),
    .i_tile_victim_pa_line(w_tile_victim_pa_line),
    .o_tile_victim_locked(w_tile_victim_locked),
    .i_tile_req_valid(w_tile_req_valid),
    .o_tile_req_ready(w_tile_req_ready),
    .i_tile_req_id(w_tile_req_id),
    .i_tile_req_pa_line(w_tile_req_pa_line),
    .i_tile_req_kind(w_tile_req_kind),
    .o_tile_gnt_valid(w_tile_gnt_valid),
    .i_tile_gnt_ready(w_tile_gnt_ready),
    .o_tile_gnt_id(w_tile_gnt_id),
    .o_tile_gnt_pa_line(w_tile_gnt_pa_line),
    .o_tile_gnt_state(w_tile_gnt_state),
    .o_tile_gnt_err(w_tile_gnt_err),
    .o_tile_probe_req_valid(w_tile_probe_req_valid),
    .i_tile_probe_req_ready(w_tile_probe_req_ready),
    .o_tile_probe_req_tag(w_tile_probe_req_tag),
    .o_tile_probe_req_pa_line(w_tile_probe_req_pa_line),
    .o_tile_probe_req_phase(w_tile_probe_req_phase),
    .o_tile_probe_req_target_state(w_tile_probe_req_target_state),
    .o_tile_probe_req_wback_en(w_tile_probe_req_wback_en),
    .i_tile_probe_rsp_valid(w_tile_probe_rsp_valid),
    .o_tile_probe_rsp_ready(w_tile_probe_rsp_ready),
    .i_tile_probe_rsp_tag(w_tile_probe_rsp_tag),
    .i_tile_probe_rsp_pa_line(w_tile_probe_rsp_pa_line),
    .i_tile_probe_rsp_phase(w_tile_probe_rsp_phase),
    .i_tile_probe_rsp_state(w_tile_probe_rsp_state),
    .i_tile_probe_rsp_err(w_tile_probe_rsp_err),
    .i_tile_probe_rsp_wback_done(w_tile_probe_rsp_wback_done),
    .o_tile_probe_query_valid(w_tile_probe_query_valid),
    .o_tile_probe_query_pa_line(w_tile_probe_query_pa_line),
    .i_tile_probe_line_busy(w_tile_probe_line_busy),
    .o_tile_line_lock_valid(w_tile_line_lock_valid),
    .o_tile_line_lock_pa_line(w_tile_line_lock_pa_line),
    .o_tile_lock_diag_event(w_tile_lock_diag_event),
    .o_coh_proto_diag_event(w_coh_proto_diag_event),
    .o_dir_lookup_count(w_dir_lookup_count),
    .o_dir_update_count(w_dir_update_count),
    .o_ccu_evt_count(w_ccu_evt_count)
  );

  // Instantiate one real CVA6 wrapper per active hart; inactive fixed slots are quiet.
  for (genvar tile_idx = 0; tile_idx < 4; tile_idx++) begin : gen_tile
    if (tile_idx < PARA_CPU_NUM) begin : gen_active_tile
      m_vlsit_riscv_cpu_tile #(
        .PARA_CMO_EN(PARA_CMO_EN),
        .PARA_ADDR_REGION_NUM(PARA_ADDR_REGION_NUM),
        .PARA_ADDR_REGION_BASE_LO(PARA_ADDR_REGION_BASE_LO),
        .PARA_ADDR_REGION_BASE_HI(PARA_ADDR_REGION_BASE_HI),
        .PARA_ADDR_REGION_SIZE_LO(PARA_ADDR_REGION_SIZE_LO),
        .PARA_ADDR_REGION_SIZE_HI(PARA_ADDR_REGION_SIZE_HI),
        .PARA_ADDR_REGION_TYPE(PARA_ADDR_REGION_TYPE),
        .PARA_COH_TXN_NUM(PARA_COH_TXN_NUM)
      ) u_vlsit_riscv_cpu_tile (
        .o_cmo_req_valid(o_cmo_req_valid[tile_idx]),
        .i_cmo_req_ready(i_cmo_req_ready[tile_idx]),
        .o_cmo_req_op(o_cmo_req_op[tile_idx]),
        .o_cmo_req_pa_line(o_cmo_req_pa_line[tile_idx]),
        .o_cmo_req_vaddr(o_cmo_req_vaddr[tile_idx]),
        .o_cmo_req_pc(o_cmo_req_pc[tile_idx]),
        .i_cmo_rsp_done(i_cmo_rsp_done[tile_idx]),
        .i_cmo_rsp_err(i_cmo_rsp_err[tile_idx]),
        .i_clk_tile(i_clk_cluster),
        .i_rst_n_tile(i_rst_n_cluster),
        .i_boot_addr(i_boot_addr),
        .i_hart_id(64'(tile_idx)),
        .i_int_msip(i_int_msip[tile_idx]),
        .i_int_mtip(i_int_mtip[tile_idx]),
        .i_int_meip(i_int_meip[tile_idx]),
        .i_int_ssip(i_int_ssip[tile_idx]),
        .i_int_stip(i_int_stip[tile_idx]),
        .i_int_seip(i_int_seip[tile_idx]),
        .i_hart_debug_req(i_hart_debug_req[tile_idx]),
        .o_hart_debug_mode(o_hart_debug_mode[tile_idx]),
        .o_perf_event(o_perf_event[tile_idx]),
        .o_hpdcache_perf_event(o_hpdcache_perf_event[tile_idx]),
        .o_cmo_entry_valid(o_cmo_entry_valid[tile_idx]),
        .o_cmo_entry_op(o_cmo_entry_op[tile_idx]),
        .o_cmo_entry_pa_line(o_cmo_entry_pa_line[tile_idx]),
        .o_cmo_entry_vaddr(o_cmo_entry_vaddr[tile_idx]),
        .o_dcache_flush_ack_valid(o_dcache_flush_ack_valid[tile_idx]),
        .o_dcache_flush_ack_nline(o_dcache_flush_ack_nline[tile_idx]),
        .o_dcache_flush_ack_origin(o_dcache_flush_ack_origin[tile_idx]),
        .o_dcache_flush_ack_err(o_dcache_flush_ack_err[tile_idx]),
        .o_dcache_flush_rsp_invalid(o_dcache_flush_rsp_invalid[tile_idx]),
        .i_coh_probe_query_valid(w_tile_probe_query_valid[tile_idx]),
        .i_coh_probe_query_nline(w_tile_probe_query_pa_line[tile_idx]),
        .o_coh_probe_line_busy(w_tile_probe_line_busy[tile_idx]),
        .o_coh_access_line_valid(w_tile_access_valid[tile_idx]),
        .o_coh_access_nline(w_tile_access_pa_line[tile_idx]),
        .o_coh_victim_line_valid(w_tile_victim_valid[tile_idx]),
        .o_coh_victim_nline(w_tile_victim_pa_line[tile_idx]),
        .i_coh_line_lock_valid(w_tile_line_lock_valid[tile_idx]),
        .i_coh_line_lock_nline(w_tile_line_lock_pa_line[tile_idx]),
        .i_coh_probe_req_valid(w_tile_probe_req_valid[tile_idx]),
        .o_coh_probe_req_ready(w_tile_probe_req_ready[tile_idx]),
        .i_coh_probe_req_tag(w_tile_probe_req_tag[tile_idx]),
        .i_coh_probe_req_nline(w_tile_probe_req_pa_line[tile_idx]),
        .i_coh_probe_req_phase(w_tile_probe_req_phase[tile_idx]),
        .i_coh_probe_req_target_state(w_tile_probe_req_target_state[tile_idx]),
        .i_coh_probe_req_wback_en(w_tile_probe_req_wback_en[tile_idx]),
        .o_coh_probe_rsp_valid(w_tile_probe_rsp_valid[tile_idx]),
        .i_coh_probe_rsp_ready(w_tile_probe_rsp_ready[tile_idx]),
        .o_coh_probe_rsp_tag(w_tile_probe_rsp_tag[tile_idx]),
        .o_coh_probe_rsp_nline(w_tile_probe_rsp_pa_line[tile_idx]),
        .o_coh_probe_rsp_phase(w_tile_probe_rsp_phase[tile_idx]),
        .o_coh_probe_rsp_state(w_tile_probe_rsp_state[tile_idx]),
        .o_coh_probe_rsp_err(w_tile_probe_rsp_err[tile_idx]),
        .o_coh_probe_rsp_wback_done(w_tile_probe_rsp_wback_done[tile_idx]),
        .o_coh_cache_req_valid(w_tile_req_valid[tile_idx]),
        .i_coh_cache_req_ready(w_tile_req_ready[tile_idx]),
        .o_coh_cache_req_id(w_tile_req_id[tile_idx]),
        .o_coh_cache_req_nline(w_tile_req_pa_line[tile_idx]),
        .o_coh_cache_req_kind(w_tile_req_kind[tile_idx]),
        .i_coh_cache_gnt_valid(w_tile_gnt_valid[tile_idx]),
        .o_coh_cache_gnt_ready(w_tile_gnt_ready[tile_idx]),
        .i_coh_cache_gnt_id(w_tile_gnt_id[tile_idx]),
        .i_coh_cache_gnt_nline(w_tile_gnt_pa_line[tile_idx]),
        .i_coh_cache_gnt_state(w_tile_gnt_state[tile_idx]),
        .i_coh_cache_gnt_err(w_tile_gnt_err[tile_idx]),
        .o_axi_awid(o_axi_awid[tile_idx]),
        .o_axi_awatop(o_axi_awatop[tile_idx]),
        .o_axi_awaddr(o_axi_awaddr[tile_idx]),
        .o_axi_awlen(o_axi_awlen[tile_idx]),
        .o_axi_awsize(o_axi_awsize[tile_idx]),
        .o_axi_awburst(o_axi_awburst[tile_idx]),
        .o_axi_awlock(o_axi_awlock[tile_idx]),
        .o_axi_awcache(o_axi_awcache[tile_idx]),
        .o_axi_awprot(o_axi_awprot[tile_idx]),
        .o_axi_awqos(o_axi_awqos[tile_idx]),
        .o_axi_awregion(o_axi_awregion[tile_idx]),
        .o_axi_awvalid(o_axi_awvalid[tile_idx]),
        .o_axi_aw_region_match(o_axi_aw_region_match[tile_idx]),
        .o_axi_aw_region_idx(o_axi_aw_region_idx[tile_idx]),
        .o_axi_aw_region_type(o_axi_aw_region_type[tile_idx]),
        .o_axi_aw_region_err(o_axi_aw_region_err[tile_idx]),
        .o_axi_wdata(o_axi_wdata[tile_idx]),
        .o_axi_wstrb(o_axi_wstrb[tile_idx]),
        .o_axi_wlast(o_axi_wlast[tile_idx]),
        .o_axi_wvalid(o_axi_wvalid[tile_idx]),
        .o_axi_bready(o_axi_bready[tile_idx]),
        .o_axi_arid(o_axi_arid[tile_idx]),
        .o_axi_araddr(o_axi_araddr[tile_idx]),
        .o_axi_arlen(o_axi_arlen[tile_idx]),
        .o_axi_arsize(o_axi_arsize[tile_idx]),
        .o_axi_arburst(o_axi_arburst[tile_idx]),
        .o_axi_arlock(o_axi_arlock[tile_idx]),
        .o_axi_arcache(o_axi_arcache[tile_idx]),
        .o_axi_arprot(o_axi_arprot[tile_idx]),
        .o_axi_arqos(o_axi_arqos[tile_idx]),
        .o_axi_arregion(o_axi_arregion[tile_idx]),
        .o_axi_arvalid(o_axi_arvalid[tile_idx]),
        .o_axi_ar_region_match(o_axi_ar_region_match[tile_idx]),
        .o_axi_ar_region_idx(o_axi_ar_region_idx[tile_idx]),
        .o_axi_ar_region_type(o_axi_ar_region_type[tile_idx]),
        .o_axi_ar_region_err(o_axi_ar_region_err[tile_idx]),
        .o_addr_region_config_valid(o_tile_region_cfg_valid[tile_idx]),
        .o_axi_rready(o_axi_rready[tile_idx]),
        .i_axi_awready(i_axi_awready[tile_idx]),
        .i_axi_wready(i_axi_wready[tile_idx]),
        .i_axi_bid(i_axi_bid[tile_idx]),
        .i_axi_bresp(i_axi_bresp[tile_idx]),
        .i_axi_bvalid(i_axi_bvalid[tile_idx]),
        .i_axi_arready(i_axi_arready[tile_idx]),
        .i_axi_rid(i_axi_rid[tile_idx]),
        .i_axi_rdata(i_axi_rdata[tile_idx]),
        .i_axi_rresp(i_axi_rresp[tile_idx]),
        .i_axi_rlast(i_axi_rlast[tile_idx]),
        .i_axi_rvalid(i_axi_rvalid[tile_idx])
      );

      // Return lock observations and diagnostics with the active hart index.
      assign o_coh_access_locked[tile_idx] = w_tile_access_locked[tile_idx];
      assign o_coh_victim_locked[tile_idx] = w_tile_victim_locked[tile_idx];
      assign o_coh_lock_diag_event[tile_idx] = w_tile_lock_diag_event[tile_idx];
      assign w_addr_region_config_valid[tile_idx] = o_tile_region_cfg_valid[tile_idx];
    end else begin : gen_inactive_tile
      // Unused fixed hart slots drive quiet values and cannot issue AXI requests.
      // Unused fixed hart slots drive quiet values and cannot issue AXI requests.
      assign o_cmo_req_valid[tile_idx] = '0;
      assign o_cmo_req_op[tile_idx] = '0;
      assign o_cmo_req_pa_line[tile_idx] = '0;
      assign o_cmo_req_vaddr[tile_idx] = '0;
      assign o_cmo_req_pc[tile_idx] = '0;
      assign o_hart_debug_mode[tile_idx] = 1'b0;
      assign o_perf_event[tile_idx] = '0;
      assign o_hpdcache_perf_event[tile_idx] = '0;
      assign o_cmo_entry_valid[tile_idx] = 1'b0;
      assign o_cmo_entry_op[tile_idx] = '0;
      assign o_cmo_entry_pa_line[tile_idx] = '0;
      assign o_cmo_entry_vaddr[tile_idx] = '0;
      assign o_dcache_flush_ack_valid[tile_idx] = 1'b0;
      assign o_dcache_flush_ack_nline[tile_idx] = '0;
      assign o_dcache_flush_ack_origin[tile_idx] = '0;
      assign o_dcache_flush_ack_err[tile_idx] = 1'b0;
      assign o_dcache_flush_rsp_invalid[tile_idx] = 1'b0;
      assign o_coh_access_locked[tile_idx] = 1'b0;
      assign o_coh_victim_locked[tile_idx] = 1'b0;
      assign o_coh_lock_diag_event[tile_idx] = 1'b0;
      assign w_addr_region_config_valid[tile_idx] = 1'b0;
      assign o_tile_region_cfg_valid[tile_idx] = 1'b0;
      assign o_axi_awid[tile_idx] = '0;
      assign o_axi_awatop[tile_idx] = '0;
      assign o_axi_awaddr[tile_idx] = '0;
      assign o_axi_awlen[tile_idx] = '0;
      assign o_axi_awsize[tile_idx] = '0;
      assign o_axi_awburst[tile_idx] = '0;
      assign o_axi_awlock[tile_idx] = '0;
      assign o_axi_awcache[tile_idx] = '0;
      assign o_axi_awprot[tile_idx] = '0;
      assign o_axi_awqos[tile_idx] = '0;
      assign o_axi_awregion[tile_idx] = '0;
      assign o_axi_awvalid[tile_idx] = '0;
      assign o_axi_aw_region_match[tile_idx] = '0;
      assign o_axi_aw_region_idx[tile_idx] = '0;
      assign o_axi_aw_region_type[tile_idx] = '0;
      assign o_axi_aw_region_err[tile_idx] = '0;
      assign o_axi_wdata[tile_idx] = '0;
      assign o_axi_wstrb[tile_idx] = '0;
      assign o_axi_wlast[tile_idx] = '0;
      assign o_axi_wvalid[tile_idx] = '0;
      assign o_axi_bready[tile_idx] = '0;
      assign o_axi_arid[tile_idx] = '0;
      assign o_axi_araddr[tile_idx] = '0;
      assign o_axi_arlen[tile_idx] = '0;
      assign o_axi_arsize[tile_idx] = '0;
      assign o_axi_arburst[tile_idx] = '0;
      assign o_axi_arlock[tile_idx] = '0;
      assign o_axi_arcache[tile_idx] = '0;
      assign o_axi_arprot[tile_idx] = '0;
      assign o_axi_arqos[tile_idx] = '0;
      assign o_axi_arregion[tile_idx] = '0;
      assign o_axi_arvalid[tile_idx] = '0;
      assign o_axi_ar_region_match[tile_idx] = '0;
      assign o_axi_ar_region_idx[tile_idx] = '0;
      assign o_axi_ar_region_type[tile_idx] = '0;
      assign o_axi_ar_region_err[tile_idx] = '0;
      assign o_axi_rready[tile_idx] = '0;
    end
  end

  // The table must be valid for every active CPU tile before integration is usable.
  assign o_region_cfg_valid = &w_addr_region_config_valid[PARA_CPU_NUM-1:0];
  // Forward shared coherence diagnostics from the fabric to the cluster parent.
  assign o_coh_proto_diag_event = w_coh_proto_diag_event;
  assign o_dir_lookup_count = w_dir_lookup_count;
  assign o_dir_update_count = w_dir_update_count;
  assign o_ccu_evt_count = w_ccu_evt_count;

endmodule

