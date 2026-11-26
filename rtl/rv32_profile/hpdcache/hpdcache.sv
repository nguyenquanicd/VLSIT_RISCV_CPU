/**
 *  Copyright 2023,2024 Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA)
 *  Copyright 2025 Univ. Grenoble Alpes, Inria, TIMA Laboratory
 *
 *  SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
 */
/*
 *  Authors       : Cesar Fuguet
 *  Creation Date : April, 2021
 *  Description   : HPDcache top
 *  History       :
 *  2026-11-26 - Quan Nguyen and Claude - VLSI Technology page:
 *    OPEN-X32-CBO4 (DEC-046): pass grant uniqueness (E/M) to hpdcache_ctrl.
 *  2026-11-14 - Quan Nguyen and Codex - VLSI Technology page:
 *    Connect the modified flush-engine origin, line, B-error and invalid-ID
 *    status to the cache subsystem boundary.
 *  2026-11-14 - Quan Nguyen and Codex - VLSI Technology page:
 *    Add a clean-line exclusive metadata bit for the planned MESI extension;
 *    legacy update paths keep it zero pending CCU permission integration.
 *  2026-11-14 - Quan Nguyen and Codex - VLSI Technology page:
 *    Expose exact-line MSHR/refill activity to the coherence integration boundary.
 *  2026-11-14 - Quan Nguyen and Codex - VLSI Technology page:
 *    Route per-tag coherence line-lock vectors into the modified controller.
 *  2026-11-14 - Quan Nguyen and Codex - VLSI Technology page:
 *    Combine exact-line MSHR/refill and controller-pipeline activity in the
 *    probe-admission busy query.
 *  2026-11-14 - Quan Nguyen and Codex - VLSI Technology page:
 *    Use width-inferred all-one constants for uncached request IDs, avoiding
 *    zero-count replication when the configured memory ID width is one bit.
 *  2026-11-14 - Quan Nguyen and Codex - VLSI Technology page:
 *    Route a backpressured tagged directory lookup channel to the HPDcache
 *    controller for native coherence probe service.
 *  2026-11-14 - Quan Nguyen and Codex - VLSI Technology page:
 *    Carry the four-bit CCU transaction tag through the held directory lookup
 *    response, supporting up to sixteen coherence contexts.
 *  2026-11-14 - Quan Nguyen and Codex - VLSI Technology page:
 *    Integrate the tagged two-phase probe engine, matching writeback response,
 *    and COMMIT-only MESI directory update inside the cache boundary.
 *  2026-11-14 - Quan Nguyen and Codex - VLSI Technology page:
 *    Qualify replay-table flush completion by origin so probe/CMO B responses
 *    cannot release an unrelated CPU victim dependency with the same line.
 *  2026-11-14 - Quan Nguyen and Codex - VLSI Technology page:
 *    Cast configuration-derived type widths to explicit two-state localparams
 *    for portable parameterized-range elaboration in Verilator 5.053.
 *  2026-11-14 - Quan Nguyen and Codex - VLSI Technology page:
 *    Restore upstream configuration-derived type ranges after explicit-width
 *    localparams failed in the configured Verilator elaboration.
 *  2026-11-14 - Quan Nguyen and Codex - VLSI Technology page:
 *    Export the cache-line ownership request/grant handshake used to gate
 *    cacheable misses before refill AR issuance.
 *  2026-11-15 - Quan Nguyen and Codex - VLSI Technology page:
 *    Export current Stage-1 access and selected victim line observations.
 *  2026-11-15 - Quan Nguyen and Codex - VLSI Technology page:
 *    Export CPU replay, miss and pipeline idle for CBO ordering after retired stores.
 */
`include "hpdcache_typedef.svh"

// 2026-11-15 - Quan Nguyen and Codex - VLSI Technology page:
// DEC-030/031: retain FENCE.I through coherent clean completion and precise fault.
// Change: Gate new load/prefetch admission during fence; retain store drain and probe progress.
// 2026-11-15 - Quan Nguyen and Codex - VLSI Technology page:
// DEC-038/A-02: connect probe/eviction reservation invalidation and protect
// the local cached atomic read-modify-write against same-line probes.
module hpdcache
import hpdcache_pkg::*;
    //  Parameters
    //  {{{
#(
    parameter hpdcache_cfg_t HPDcacheCfg = '0,

    parameter type wbuf_timecnt_t = logic,

    //  Request Interface Definitions
    //  {{{
    parameter type hpdcache_tag_t = logic,
    parameter type hpdcache_data_word_t = logic,
    parameter type hpdcache_data_be_t = logic,
    parameter type hpdcache_req_offset_t = logic,
    parameter type hpdcache_req_data_t = logic,
    parameter type hpdcache_req_be_t = logic,
    parameter type hpdcache_req_sid_t = logic,
    parameter type hpdcache_req_tid_t = logic,
    parameter type hpdcache_req_t = logic,
    parameter type hpdcache_rsp_t = logic,
    //  }}}

    //  Memory Interface Definitions
    //  {{{
    parameter type hpdcache_mem_addr_t = logic,
    parameter type hpdcache_mem_id_t = logic,
    parameter type hpdcache_mem_data_t = logic,
    parameter type hpdcache_mem_be_t = logic,
    parameter type hpdcache_mem_req_t = logic,
    parameter type hpdcache_mem_req_w_t = logic,
    parameter type hpdcache_mem_resp_r_t = logic,
    parameter type hpdcache_mem_resp_w_t = logic,
    //  }}}

    localparam type hpdcache_nline_t = logic [HPDcacheCfg.nlineWidth-1:0]
)
    //  }}}

    //  Ports
    //  {{{
(
    //      Clock and reset signals
    input  logic                          clk_i,
    input  logic                          rst_ni,

    //      Force the write buffer to send all pending writes
    input  logic                          wbuf_flush_i,

    //      Core request interface
    //         1st cycle
    // DEC-030/031 coherent instruction synchronization.
    input logic fence_sync_i,
    output logic fence_line_valid_o,
    input logic fence_line_ready_i,
    output hpdcache_nline_t fence_line_o,
    input logic fence_line_done_i,
    input logic fence_line_error_i,
    output logic fence_error_o,
    output hpdcache_nline_t fence_error_line_o,
    input  logic                          core_req_valid_i [HPDcacheCfg.u.nRequesters],
    output logic                          core_req_ready_o [HPDcacheCfg.u.nRequesters],
    input  hpdcache_req_t                 core_req_i       [HPDcacheCfg.u.nRequesters],
    //         2nd cycle
    input  logic                          core_req_abort_i [HPDcacheCfg.u.nRequesters],
    input  hpdcache_tag_t                 core_req_tag_i   [HPDcacheCfg.u.nRequesters],
    input  hpdcache_pma_t                 core_req_pma_i   [HPDcacheCfg.u.nRequesters],

    //      Core response interface
    output logic                          core_rsp_valid_o [HPDcacheCfg.u.nRequesters],
    output hpdcache_rsp_t                 core_rsp_o       [HPDcacheCfg.u.nRequesters],

    //      Read / Invalidation memory interface
    input  logic                          mem_req_read_ready_i,
    output logic                          mem_req_read_valid_o,
    output hpdcache_mem_req_t             mem_req_read_o,

    output logic                          mem_resp_read_ready_o,
    input  logic                          mem_resp_read_valid_i,
    input  hpdcache_mem_resp_r_t          mem_resp_read_i,

    input  logic                          mem_resp_read_inval_i,
    input  hpdcache_nline_t               mem_resp_read_inval_nline_i,

    //      Write memory interface
    input  logic                          mem_req_write_ready_i,
    output logic                          mem_req_write_valid_o,
    output hpdcache_mem_req_t             mem_req_write_o,

    input  logic                          mem_req_write_data_ready_i,
    output logic                          mem_req_write_data_valid_o,
    output hpdcache_mem_req_w_t           mem_req_write_data_o,

    output logic                          mem_resp_write_ready_o,
    input  logic                          mem_resp_write_valid_i,
    input  hpdcache_mem_resp_w_t          mem_resp_write_i,

    //      Performance events
    output logic                          evt_cache_write_miss_o,
    output logic                          evt_cache_read_miss_o,
    output logic                          evt_cache_dir_unc_err_o,
    output logic                          evt_cache_dir_cor_err_o,
    output logic                          evt_cache_dat_unc_err_o,
    output logic                          evt_cache_dat_cor_err_o,
    output logic                          evt_scrub_complete_o,
    output logic                          evt_uncached_req_o,
    output logic                          evt_cmo_req_o,
    output logic                          evt_write_req_o,
    output logic                          evt_read_req_o,
    output logic                          evt_prefetch_req_o,
    output logic                          evt_req_on_hold_o,
    output logic                          evt_rtab_rollback_o,
    output logic                          evt_stall_refill_o,
    output logic                          evt_stall_o,

    //      Status interface
    output logic                          wbuf_empty_o,
    output logic                          coh_cpu_idle_o,

    //      Configuration interface
    input  logic                          cfg_enable_i,
    input  wbuf_timecnt_t                 cfg_wbuf_threshold_i,
    input  logic                          cfg_wbuf_reset_timecnt_on_write_i,
    input  logic                          cfg_wbuf_sequential_waw_i,
    input  logic                          cfg_wbuf_inhibit_write_coalescing_i,
    input  logic                          cfg_prefetch_updt_plru_i,
    input  logic                          cfg_error_on_cacheable_amo_i,
    input  logic                          cfg_rtab_single_entry_i,
    input  logic                          cfg_default_wb_i,
    input  logic                          cfg_scrub_enable_i,
    input  logic unsigned [5:0]           cfg_scrub_period_i,
    input  logic                          cfg_scrub_restart_i,

    // Flush write-response metadata for the coherence/maintenance integration.
    output logic                          flush_ack_valid_o,
    output logic [HPDcacheCfg.nlineWidth-1:0] flush_ack_nline_o,
    output logic [1:0]                    flush_ack_origin_o,
    output logic                          flush_ack_error_o,
    output logic                          flush_rsp_invalid_o,

    // Exact-line busy query for the coherence probe scheduler.
    input  logic                          coh_probe_query_valid_i,
    input  hpdcache_nline_t               coh_probe_query_nline_i,
    output logic                          coh_probe_line_busy_o,
    output logic                          coh_access_line_valid_o,
    output hpdcache_nline_t               coh_access_nline_o,
    output logic                          coh_victim_line_valid_o,
    output hpdcache_nline_t               coh_victim_nline_o,
    input  logic [15:0]                   coh_line_lock_valid_i,
    input  logic [15:0][HPDcacheCfg.nlineWidth-1:0] coh_line_lock_nline_i,

    // Tagged PREPARE/COMMIT/ABORT endpoint for the CCU.
    input  logic                          coh_probe_req_valid_i,
    output logic                          coh_probe_req_ready_o,
    input  logic [3:0]                    coh_probe_req_tag_i,
    input  hpdcache_nline_t               coh_probe_req_nline_i,
    input  logic [1:0]                    coh_probe_req_phase_i,
    input  logic [1:0]                    coh_probe_req_target_state_i,
    input  logic                          coh_probe_req_wback_en_i,
    output logic                          coh_probe_rsp_valid_o,
    input  logic                          coh_probe_rsp_ready_i,
    output logic [3:0]                    coh_probe_rsp_tag_o,
    output hpdcache_nline_t               coh_probe_rsp_nline_o,
    output logic [1:0]                    coh_probe_rsp_phase_o,
    output logic [1:0]                    coh_probe_rsp_state_o,
    output logic                          coh_probe_rsp_err_o,
    output logic                          coh_probe_rsp_wback_done_o,

    // CCU ownership must be granted before a cacheable miss can issue refill AR.
    output logic                          coh_own_req_valid_o,
    input  logic                          coh_own_req_ready_i,
    output logic [2:0]                    coh_own_req_id_o,
    output hpdcache_nline_t               coh_own_req_nline_o,
    output logic [1:0]                    coh_own_req_kind_o,
    input  logic                          coh_own_gnt_valid_i,
    output logic                          coh_own_gnt_ready_o,
    input  logic [2:0]                    coh_own_gnt_id_i,
    input  hpdcache_nline_t               coh_own_gnt_nline_i,
    input  logic [1:0]                    coh_own_gnt_state_i,
    input  logic                          coh_own_gnt_err_i
);
    //  }}}

    //  Declaration of internal types
    //  {{{
    typedef logic [HPDcacheCfg.u.paWidth-1:0] hpdcache_req_addr_t;
    typedef logic [HPDcacheCfg.setWidth-1:0] hpdcache_set_t;
    typedef logic [HPDcacheCfg.clOffsetWidth-1:0] hpdcache_offset_t;
    typedef logic unsigned [HPDcacheCfg.clWordIdxWidth-1:0] hpdcache_word_t;
    typedef logic unsigned [HPDcacheCfg.u.ways-1:0] hpdcache_way_vector_t;
    typedef logic unsigned [HPDcacheCfg.wayIndexWidth-1:0] hpdcache_way_t;

    //  Cache Directory entry definition
    //  {{{
    typedef struct packed {
        //  Cacheline state
        //  Encoding: {valid, wb, dirty, exclusive, fetch}
        //            {0,X,X,0}: Invalid
        //            {0,X,X,1}: Invalid and Fetching
        //            {1,X,X,1}: Valid and Fetching (cacheline being replaced is accessible)
        //            {1,0,0,0}: Write-through
        //            {1,1,0,0,0}: Write-back Shared (clean)
        //            {1,1,0,1,0}: Write-back Exclusive (clean)
        //            {1,1,1,0,0}: Write-back Modified (dirty)
        //  {{{
        logic valid; //  valid cacheline
        logic wback; //  cacheline in write-back mode
        logic dirty; //  cacheline is locally modified (memory is obsolete)
        logic exclusive; //  clean line is exclusively held by this cache
        logic fetch; //  cacheline is reserved for a new cacheline being fetched
        //  }}}

        //  Cacheline address tag
        //  {{{
        hpdcache_tag_t tag;
        //  }}}
    } hpdcache_dir_entry_t;
    //  }}}

    typedef hpdcache_data_word_t [HPDcacheCfg.u.accessWords-1:0] hpdcache_access_data_t;
    typedef hpdcache_data_be_t [HPDcacheCfg.u.accessWords-1:0] hpdcache_access_be_t;

    typedef hpdcache_req_addr_t wbuf_addr_t;
    typedef hpdcache_req_data_t wbuf_data_t;
    typedef hpdcache_req_be_t wbuf_be_t;
    //  }}}

    //  Declaration of internal signals
    //  {{{
    logic                  refill_req_valid;
    logic                  refill_req_ready;
    logic                  refill_is_error;
    logic                  refill_busy;
    logic                  refill_updt_sel_victim;
    hpdcache_set_t         refill_set;
    hpdcache_way_vector_t  refill_way;
    hpdcache_dir_entry_t   refill_dir_entry;
    logic                  refill_write_dir;
    logic                  refill_write_data;
    hpdcache_word_t        refill_word;
    hpdcache_access_data_t refill_data;
    logic                  refill_core_rsp_valid;
    hpdcache_rsp_t         refill_core_rsp;
    hpdcache_nline_t       refill_nline;
    logic                  refill_updt_rtab;

    logic                  inval_check_dir;
    logic                  inval_write_dir;
    hpdcache_nline_t       inval_nline;
    logic                  inval_hit;

    logic                  miss_mshr_empty;
    logic                  miss_mshr_check;
    hpdcache_req_offset_t  miss_mshr_check_offset;
    hpdcache_nline_t       miss_mshr_check_nline;
    logic                  miss_mshr_hit;
    logic                  miss_mshr_alloc_cs;
    logic                  miss_mshr_alloc;
    logic                  miss_mshr_alloc_ready;
    logic                  miss_mshr_alloc_full;
    logic                  miss_mshr_alloc_cbuf_full;
    logic                  miss_mshr_alloc_exclusive;
    hpdcache_nline_t       miss_mshr_alloc_nline;
    hpdcache_req_tid_t     miss_mshr_alloc_tid;
    hpdcache_req_sid_t     miss_mshr_alloc_sid;
    hpdcache_word_t        miss_mshr_alloc_word;
    hpdcache_req_data_t    miss_mshr_alloc_wdata;
    hpdcache_req_be_t      miss_mshr_alloc_be;
    hpdcache_way_vector_t  miss_mshr_alloc_victim_way;
    logic                  miss_mshr_alloc_need_rsp;
    logic                  miss_mshr_alloc_is_prefetch;
    logic                  miss_mshr_alloc_wback;
    logic                  miss_mshr_alloc_dirty;

    logic                  wbuf_flush_all;
    logic                  wbuf_write;
    logic                  wbuf_write_ready;
    wbuf_addr_t            wbuf_write_addr;
    wbuf_data_t            wbuf_write_data;
    wbuf_be_t              wbuf_write_be;
    logic                  wbuf_write_uncacheable;
    logic                  wbuf_read_hit;
    logic                  wbuf_read_flush_hit;
    hpdcache_req_addr_t    wbuf_rtab_addr;
    logic                  wbuf_rtab_is_read;
    logic                  wbuf_rtab_hit_open;
    logic                  wbuf_rtab_hit_pend;
    logic                  wbuf_rtab_hit_sent;
    logic                  wbuf_rtab_not_ready;

    logic                  uc_ready;
    logic                  uc_req_valid;
    hpdcache_uc_op_t       uc_req_op;
    hpdcache_req_addr_t    uc_req_addr;
    hpdcache_req_size_t    uc_req_size;
    hpdcache_req_data_t    uc_req_data;
    hpdcache_req_be_t      uc_req_be;
    logic                  uc_req_uncacheable;
    hpdcache_req_sid_t     uc_req_sid;
    hpdcache_req_tid_t     uc_req_tid;
    logic                  uc_req_need_rsp;
    hpdcache_way_vector_t  uc_req_dir_hit_way;
    hpdcache_req_data_t    uc_req_old_data;
    logic                  uc_data_amo_write;
    logic                  uc_data_amo_write_enable;
    hpdcache_set_t         uc_data_amo_write_set;
    hpdcache_req_size_t    uc_data_amo_write_size;
    hpdcache_word_t        uc_data_amo_write_word;
    hpdcache_way_vector_t  uc_data_amo_write_way;
    hpdcache_req_data_t    uc_data_amo_write_data;
    hpdcache_req_be_t      uc_data_amo_write_be;
    logic                  uc_lrsc_invalidate;
    hpdcache_nline_t       uc_lrsc_invalidate_nline;
    logic                  uc_local_atomic_busy;
    hpdcache_nline_t       uc_local_atomic_nline;
    logic                  st2_mshr_alloc_probe_shared;
    logic                  uc_lrsc_match;
    logic                  uc_lrsc_snoop;
    hpdcache_req_addr_t    uc_lrsc_snoop_addr;
    hpdcache_req_size_t    uc_lrsc_snoop_size;
    logic                  uc_core_rsp_ready;
    logic                  uc_core_rsp_valid;
    hpdcache_rsp_t         uc_core_rsp;

    logic                  cmo_req_valid;
    logic                  cmo_ready;
    hpdcache_cmoh_op_t     cmo_req_op;
    hpdcache_req_addr_t    cmo_req_addr;
    hpdcache_req_sid_t     cmo_req_sid;
    hpdcache_req_tid_t     cmo_req_tid;
    logic                  cmo_req_need_rsp;
    logic                  cmo_dirty_set_en;
    hpdcache_set_t         cmo_dirty_min_set;
    hpdcache_set_t         cmo_dirty_max_set;
    logic                  cmo_valid_set_en;
    hpdcache_set_t         cmo_valid_min_set;
    hpdcache_set_t         cmo_valid_max_set;
    logic                  cmo_flush_all;
    logic                  cmo_inval_all;
    logic                  cmo_dir_check_entry;
    hpdcache_set_t         cmo_dir_check_entry_set;
    hpdcache_way_vector_t  cmo_dir_check_entry_way;
    logic                  cmo_dir_check_entry_valid;
    logic                  cmo_dir_check_entry_wback;
    logic                  cmo_dir_check_entry_dirty;
    hpdcache_tag_t         cmo_dir_check_entry_tag;
    logic                  cmo_dir_updt;
    hpdcache_set_t         cmo_dir_updt_set;
    hpdcache_way_vector_t  cmo_dir_updt_way;
    logic                  cmo_dir_updt_valid;
    logic                  cmo_dir_updt_wback;
    logic                  cmo_dir_updt_dirty;
    logic                  cmo_dir_updt_fetch;
    hpdcache_tag_t         cmo_dir_updt_tag;
    logic                  cmo_flush_alloc;
    hpdcache_nline_t       cmo_flush_alloc_nline;
    hpdcache_way_vector_t  cmo_flush_alloc_way;
    logic                  cmo_core_rsp_ready;
    logic                  cmo_core_rsp_valid;
    hpdcache_rsp_t         cmo_core_rsp;

    logic                  flush_empty;
    logic                  flush_busy;
    hpdcache_nline_t       flush_check_nline;
    logic                  flush_check_hit;
    logic                  flush_alloc;
    logic                  flush_alloc_ready;
    hpdcache_nline_t       flush_alloc_nline;
    hpdcache_way_vector_t  flush_alloc_way;
    logic                  flush_data_read;
    hpdcache_set_t         flush_data_read_set;
    hpdcache_word_t        flush_data_read_word;
    hpdcache_way_vector_t  flush_data_read_way;
    hpdcache_access_data_t flush_data_read_data;
    logic                  flush_ack;
    hpdcache_nline_t       flush_ack_nline;
    logic [1:0]            flush_alloc_origin;
    logic [1:0]            flush_ack_origin;
    logic                  flush_ack_error;
    logic                  flush_rsp_invalid;

    logic                  probe_flush_alloc;
    logic                  probe_flush_alloc_ready;
    logic                  probe_flush_array_grant;
    hpdcache_nline_t       probe_flush_alloc_nline;
    hpdcache_way_vector_t  probe_flush_alloc_way;
    logic                  ctrl_flush_alloc_ready;
    logic                  cmo_flush_alloc_ready;

    logic                  coh_probe_lookup_valid;
    logic                  coh_probe_lookup_ready;
    logic [3:0]            coh_probe_lookup_tag;
    hpdcache_nline_t       coh_probe_lookup_nline;
    logic                  coh_probe_lookup_rsp_valid;
    logic                  coh_probe_lookup_rsp_ready;
    logic [3:0]            coh_probe_lookup_rsp_tag;
    hpdcache_way_vector_t  coh_probe_lookup_rsp_way;
    logic                  coh_probe_lookup_rsp_hit;
    logic [1:0]            coh_probe_lookup_rsp_state;
    logic                  coh_probe_lookup_rsp_error;
    hpdcache_nline_t       coh_probe_lookup_rsp_nline;

    logic                  coh_probe_state_update_valid;
    logic                  coh_probe_state_update_ready;
    hpdcache_nline_t       coh_probe_state_update_nline;
    hpdcache_way_vector_t  coh_probe_state_update_way;
    logic [1:0]            coh_probe_state_update_state;

    logic                  ctrl_flush_alloc;
    hpdcache_nline_t       ctrl_flush_alloc_nline;
    hpdcache_way_vector_t  ctrl_flush_alloc_way;

    logic                  rtab_empty;
    logic                  ctrl_empty;

    logic                  core_rsp_valid;
    hpdcache_rsp_t         core_rsp;

    logic                  arb_req_valid;
    logic                  arb_req_ready;
    hpdcache_req_t         arb_req;
    logic                  arb_abort;
    hpdcache_tag_t         arb_tag;
    hpdcache_pma_t         arb_pma;

    logic                  mem_req_read_miss_ready;
    logic                  mem_req_read_miss_valid;
    hpdcache_mem_req_t     mem_req_read_miss;

    logic                  mem_resp_read_miss_ready;
    logic                  mem_resp_read_miss_valid;
    hpdcache_mem_resp_r_t  mem_resp_read_miss;
    logic                  mem_resp_read_miss_inval;
    hpdcache_nline_t       mem_resp_read_miss_inval_nline;

    logic                  mem_req_read_uc_ready;
    logic                  mem_req_read_uc_valid;
    hpdcache_mem_req_t     mem_req_read_uc;

    logic                  mem_resp_read_uc_ready;
    logic                  mem_resp_read_uc_valid;
    hpdcache_mem_resp_r_t  mem_resp_read_uc;

    logic                  mem_req_write_wbuf_ready;
    logic                  mem_req_write_wbuf_valid;
    hpdcache_mem_req_t     mem_req_write_wbuf;

    logic                  mem_req_write_wbuf_data_ready;
    logic                  mem_req_write_wbuf_data_valid;
    hpdcache_mem_req_w_t   mem_req_write_wbuf_data;

    logic                  mem_resp_write_wbuf_ready;
    logic                  mem_resp_write_wbuf_valid;
    hpdcache_mem_resp_w_t  mem_resp_write_wbuf;

    logic                  mem_req_write_flush_ready;
    logic                  mem_req_write_flush_valid;
    hpdcache_mem_req_t     mem_req_write_flush;

    logic                  mem_req_write_flush_data_ready;
    logic                  mem_req_write_flush_data_valid;
    hpdcache_mem_req_w_t   mem_req_write_flush_data;

    logic                  mem_resp_write_flush_ready;
    logic                  mem_resp_write_flush_valid;
    hpdcache_mem_resp_w_t  mem_resp_write_flush;

    logic                  mem_req_write_uc_ready;
    logic                  mem_req_write_uc_valid;
    hpdcache_mem_req_t     mem_req_write_uc;

    logic                  mem_req_write_uc_data_ready;
    logic                  mem_req_write_uc_data_valid;
    hpdcache_mem_req_w_t   mem_req_write_uc_data;

    logic                  mem_resp_write_uc_ready;
    logic                  mem_resp_write_uc_valid;
    hpdcache_mem_resp_w_t  mem_resp_write_uc;

    logic                  cfg_default_wb;

    logic                  coh_probe_mshr_busy;
    logic                  coh_probe_pipeline_busy;

    localparam logic [HPDcacheCfg.u.memIdWidth-1:0] HPDCACHE_UC_READ_ID = '1;
    localparam logic [HPDcacheCfg.u.memIdWidth-1:0] HPDCACHE_UC_WRITE_ID = '1;
    //  }}}

    // Stop younger CPU/prefetch reads while older stores and refills drain.
    logic fence_req_valid [HPDcacheCfg.u.nRequesters];
    logic fence_req_ready [HPDcacheCfg.u.nRequesters];
    logic fence_req_allow [HPDcacheCfg.u.nRequesters];
    for (genvar req_idx=0; req_idx<HPDcacheCfg.u.nRequesters; req_idx++) begin : gen_fence_admission
      assign fence_req_allow[req_idx] = (req_idx == 0) || !fence_sync_i ||
          (core_req_i[req_idx].op == HPDCACHE_REQ_STORE) ||
          (core_req_i[req_idx].op == HPDCACHE_REQ_CMO_FLUSH_ALL);
      assign fence_req_valid[req_idx] = core_req_valid_i[req_idx] && fence_req_allow[req_idx];
      assign core_req_ready_o[req_idx] = fence_req_ready[req_idx] && fence_req_allow[req_idx];
    end
    //  Requesters arbiter
    //  {{{
    hpdcache_core_arbiter #(
        .HPDcacheCfg                        (HPDcacheCfg),
        .hpdcache_tag_t                     (hpdcache_tag_t),
        .hpdcache_req_t                     (hpdcache_req_t),
        .hpdcache_rsp_t                     (hpdcache_rsp_t)
    ) core_req_arbiter_i (
        .clk_i,
        .rst_ni,

        .core_req_valid_i(fence_req_valid),
        .core_req_ready_o(fence_req_ready),
        .core_req_i,
        .core_req_abort_i,
        .core_req_tag_i,
        .core_req_pma_i,

        .core_rsp_valid_i                   (core_rsp_valid),
        .core_rsp_i                         (core_rsp),
        .core_rsp_valid_o,
        .core_rsp_o,

        .arb_req_valid_o                    (arb_req_valid),
        .arb_req_ready_i                    (arb_req_ready),
        .arb_req_o                          (arb_req),
        .arb_abort_o                        (arb_abort),
        .arb_tag_o                          (arb_tag),
        .arb_pma_o                          (arb_pma)
    );
    //  }}}

    //  HPDcache controller
    //  {{{
    if (HPDcacheCfg.u.wtEn && HPDcacheCfg.u.wbEn) begin : gen_cfg_default_wt_wb
        assign cfg_default_wb = cfg_default_wb_i;
    end else if (HPDcacheCfg.u.wbEn) begin : gen_cfg_default_wb
        assign cfg_default_wb = 1'b1;
    end else begin : gen_cfg_default_wt
        assign cfg_default_wb = 1'b0;
    end

    hpdcache_ctrl #(
        .HPDcacheCfg                        (HPDcacheCfg),
        .hpdcache_nline_t                   (hpdcache_nline_t),
        .hpdcache_tag_t                     (hpdcache_tag_t),
        .hpdcache_set_t                     (hpdcache_set_t),
        .hpdcache_word_t                    (hpdcache_word_t),
        .hpdcache_data_word_t               (hpdcache_data_word_t),
        .hpdcache_data_be_t                 (hpdcache_data_be_t),
        .hpdcache_dir_entry_t               (hpdcache_dir_entry_t),
        .hpdcache_way_vector_t              (hpdcache_way_vector_t),
        .hpdcache_way_t                     (hpdcache_way_t),
        .wbuf_addr_t                        (wbuf_addr_t),
        .wbuf_data_t                        (wbuf_data_t),
        .wbuf_be_t                          (wbuf_be_t),
        .hpdcache_access_data_t             (hpdcache_access_data_t),
        .hpdcache_access_be_t               (hpdcache_access_be_t),
        .hpdcache_req_addr_t                (hpdcache_req_addr_t),
        .hpdcache_req_offset_t              (hpdcache_req_offset_t),
        .hpdcache_req_tid_t                 (hpdcache_req_tid_t),
        .hpdcache_req_sid_t                 (hpdcache_req_sid_t),
        .hpdcache_req_data_t                (hpdcache_req_data_t),
        .hpdcache_req_be_t                  (hpdcache_req_be_t),
        .hpdcache_req_t                     (hpdcache_req_t),
        .hpdcache_rsp_t                     (hpdcache_rsp_t)
    ) hpdcache_ctrl_i(
        .clk_i,
        .rst_ni,

        .core_req_valid_i                   (arb_req_valid),
        .core_req_ready_o                   (arb_req_ready),
        .core_req_i                         (arb_req),
        .core_req_abort_i                   (arb_abort),
        .core_req_tag_i                     (arb_tag),
        .core_req_pma_i                     (arb_pma),

        .core_rsp_valid_o                   (core_rsp_valid),
        .core_rsp_o                         (core_rsp),

        .wbuf_flush_i,
        .coh_line_lock_valid_i,
        .coh_line_lock_nline_i,
        .coh_probe_query_valid_i,
        .coh_probe_query_nline_i,
        .coh_probe_pipeline_busy_o(coh_probe_pipeline_busy),
        .coh_probe_flush_pending_i(probe_flush_alloc),
        .coh_atomic_grant_i(coh_own_gnt_valid_i && coh_own_gnt_ready_o &&
                            !coh_own_gnt_err_i && (coh_own_gnt_state_i != 2'd0)),
        .coh_atomic_grant_nline_i(coh_own_gnt_nline_i),
        .coh_atomic_grant_unique_i(coh_own_gnt_state_i[1]),
        .coh_access_line_valid_o,
        .coh_access_nline_o,
        .coh_victim_line_valid_o,
        .coh_victim_nline_o,
        .coh_probe_lookup_valid_i            (coh_probe_lookup_valid),
        .coh_probe_lookup_ready_o            (coh_probe_lookup_ready),
        .coh_probe_lookup_tag_i              (coh_probe_lookup_tag),
        .coh_probe_lookup_nline_i            (coh_probe_lookup_nline),
        .coh_probe_lookup_rsp_valid_o        (coh_probe_lookup_rsp_valid),
        .coh_probe_lookup_rsp_ready_i        (coh_probe_lookup_rsp_ready),
        .coh_probe_lookup_rsp_tag_o          (coh_probe_lookup_rsp_tag),
        .coh_probe_lookup_rsp_way_o          (coh_probe_lookup_rsp_way),
        .coh_probe_lookup_rsp_hit_o          (coh_probe_lookup_rsp_hit),
        .coh_probe_lookup_rsp_state_o        (coh_probe_lookup_rsp_state),
        .coh_probe_lookup_rsp_error_o        (coh_probe_lookup_rsp_error),
        .coh_probe_lookup_rsp_nline_o        (coh_probe_lookup_rsp_nline),
        .coh_probe_state_update_valid_i      (coh_probe_state_update_valid),
        .coh_probe_state_update_ready_o      (coh_probe_state_update_ready),
        .coh_probe_state_update_nline_i      (coh_probe_state_update_nline),
        .coh_probe_state_update_way_i        (coh_probe_state_update_way),
        .coh_probe_state_update_state_i      (coh_probe_state_update_state),

        .st0_mshr_check_o                   (miss_mshr_check),
        .st0_mshr_check_offset_o            (miss_mshr_check_offset),
        .st1_mshr_check_nline_o             (miss_mshr_check_nline),
        .st1_mshr_hit_i                     (miss_mshr_hit),
        .st1_mshr_alloc_ready_i             (miss_mshr_alloc_ready),
        .st1_mshr_alloc_full_i              (miss_mshr_alloc_full),
        .st1_mshr_alloc_cbuf_full_i         (miss_mshr_alloc_cbuf_full),
        .st2_mshr_alloc_o                   (miss_mshr_alloc),
        .st2_mshr_alloc_cs_o                (miss_mshr_alloc_cs),
        .st2_mshr_alloc_nline_o             (miss_mshr_alloc_nline),
        .st2_mshr_alloc_tid_o               (miss_mshr_alloc_tid),
        .st2_mshr_alloc_sid_o               (miss_mshr_alloc_sid),
        .st2_mshr_alloc_word_o              (miss_mshr_alloc_word),
        .st2_mshr_alloc_wdata_o             (miss_mshr_alloc_wdata),
        .st2_mshr_alloc_be_o                (miss_mshr_alloc_be),
        .st2_mshr_alloc_victim_way_o        (miss_mshr_alloc_victim_way),
        .st2_mshr_alloc_need_rsp_o          (miss_mshr_alloc_need_rsp),
        .st2_mshr_alloc_is_prefetch_o       (miss_mshr_alloc_is_prefetch),
        .st2_mshr_alloc_wback_o             (miss_mshr_alloc_wback),
        .st2_mshr_alloc_dirty_o             (miss_mshr_alloc_dirty),
        .st2_mshr_alloc_probe_shared_o      (st2_mshr_alloc_probe_shared),
        .st2_mshr_alloc_exclusive_o         (miss_mshr_alloc_exclusive),

        .refill_req_valid_i                 (refill_req_valid),
        .refill_req_ready_o                 (refill_req_ready),
        .refill_is_error_i                  (refill_is_error),
        .refill_busy_i                      (refill_busy),
        .refill_updt_sel_victim_i           (refill_updt_sel_victim),
        .refill_set_i                       (refill_set),
        .refill_way_i                       (refill_way),
        .refill_dir_entry_i                 (refill_dir_entry),
        .refill_write_dir_i                 (refill_write_dir),
        .refill_write_data_i                (refill_write_data),
        .refill_word_i                      (refill_word),
        .refill_data_i                      (refill_data),
        .refill_core_rsp_valid_i            (refill_core_rsp_valid),
        .refill_core_rsp_i                  (refill_core_rsp),
        .refill_nline_i                     (refill_nline),
        .refill_updt_rtab_i                 (refill_updt_rtab),

        .flush_busy_i                       (flush_busy),
        .flush_check_nline_o                (flush_check_nline),
        .flush_check_hit_i                  (flush_check_hit),
        .flush_alloc_o                      (ctrl_flush_alloc),
        .flush_alloc_ready_i                (ctrl_flush_alloc_ready),
        .flush_alloc_nline_o                (ctrl_flush_alloc_nline),
        .flush_alloc_way_o                  (ctrl_flush_alloc_way),
        .flush_data_read_i                  (flush_data_read),
        .flush_data_read_set_i              (flush_data_read_set),
        .flush_data_read_word_i             (flush_data_read_word),
        .flush_data_read_way_i              (flush_data_read_way),
        .flush_data_read_data_o             (flush_data_read_data),
        .flush_ack_i                        (flush_ack & (flush_ack_origin == 2'b00)),
        .flush_ack_nline_i                  (flush_ack_nline),
        .flush_ack_error_i                  (flush_ack_error),

        .inval_check_dir_i                  (inval_check_dir),
        .inval_write_dir_i                  (inval_write_dir),
        .inval_nline_i                      (inval_nline),
        .inval_hit_o                        (inval_hit),

        .wbuf_empty_i                       (wbuf_empty_o),
        .wbuf_flush_all_o                   (wbuf_flush_all),
        .wbuf_write_o                       (wbuf_write),
        .wbuf_write_ready_i                 (wbuf_write_ready),
        .wbuf_write_addr_o                  (wbuf_write_addr),
        .wbuf_write_data_o                  (wbuf_write_data),
        .wbuf_write_be_o                    (wbuf_write_be),
        .wbuf_write_uncacheable_o           (wbuf_write_uncacheable),
        .wbuf_read_hit_i                    (wbuf_read_hit),
        .wbuf_read_flush_hit_o              (wbuf_read_flush_hit),
        .wbuf_rtab_addr_o                   (wbuf_rtab_addr),
        .wbuf_rtab_is_read_o                (wbuf_rtab_is_read),
        .wbuf_rtab_hit_open_i               (wbuf_rtab_hit_open),
        .wbuf_rtab_hit_pend_i               (wbuf_rtab_hit_pend),
        .wbuf_rtab_hit_sent_i               (wbuf_rtab_hit_sent),
        .wbuf_rtab_not_ready_i              (wbuf_rtab_not_ready),

        .uc_busy_i                          (~uc_ready),
        .uc_lrsc_match_i                    (uc_lrsc_match),
        .uc_lrsc_invalidate_o               (uc_lrsc_invalidate),
        .uc_lrsc_invalidate_nline_o         (uc_lrsc_invalidate_nline),
        .uc_lrsc_snoop_o                    (uc_lrsc_snoop),
        .uc_lrsc_snoop_addr_o               (uc_lrsc_snoop_addr),
        .uc_lrsc_snoop_size_o               (uc_lrsc_snoop_size),
        .uc_req_valid_o                     (uc_req_valid),
        .uc_req_op_o                        (uc_req_op),
        .uc_req_addr_o                      (uc_req_addr),
        .uc_req_size_o                      (uc_req_size),
        .uc_req_data_o                      (uc_req_data),
        .uc_req_be_o                        (uc_req_be),
        .uc_req_uc_o                        (uc_req_uncacheable),
        .uc_req_sid_o                       (uc_req_sid),
        .uc_req_tid_o                       (uc_req_tid),
        .uc_req_need_rsp_o                  (uc_req_need_rsp),
        .uc_req_dir_hit_way_o               (uc_req_dir_hit_way),
        .uc_req_old_data_o                  (uc_req_old_data),
        .uc_data_amo_write_i                (uc_data_amo_write),
        .uc_data_amo_write_enable_i         (uc_data_amo_write_enable),
        .uc_data_amo_write_set_i            (uc_data_amo_write_set),
        .uc_data_amo_write_size_i           (uc_data_amo_write_size),
        .uc_data_amo_write_word_i           (uc_data_amo_write_word),
        .uc_data_amo_write_way_i            (uc_data_amo_write_way),
        .uc_data_amo_write_data_i           (uc_data_amo_write_data),
        .uc_data_amo_write_be_i             (uc_data_amo_write_be),
        .uc_core_rsp_ready_o                (uc_core_rsp_ready),
        .uc_core_rsp_valid_i                (uc_core_rsp_valid),
        .uc_core_rsp_i                      (uc_core_rsp),

        .cmo_busy_i                         (~cmo_ready),
        .cmo_req_valid_o                    (cmo_req_valid),
        .cmo_req_op_o                       (cmo_req_op),
        .cmo_req_addr_o                     (cmo_req_addr),
        .cmo_req_sid_o                      (cmo_req_sid),
        .cmo_req_tid_o                      (cmo_req_tid),
        .cmo_req_need_rsp_o                 (cmo_req_need_rsp),
        .cmo_dirty_set_en_o                 (cmo_dirty_set_en),
        .cmo_dirty_min_set_o                (cmo_dirty_min_set),
        .cmo_dirty_max_set_o                (cmo_dirty_max_set),
        .cmo_valid_set_en_o                 (cmo_valid_set_en),
        .cmo_valid_min_set_o                (cmo_valid_min_set),
        .cmo_valid_max_set_o                (cmo_valid_max_set),
        .cmo_flush_all_i                    (cmo_flush_all),
        .cmo_inval_all_i                    (cmo_inval_all),
        .cmo_dir_check_entry_i              (cmo_dir_check_entry),
        .cmo_dir_check_entry_set_i          (cmo_dir_check_entry_set),
        .cmo_dir_check_entry_way_i          (cmo_dir_check_entry_way),
        .cmo_dir_check_entry_valid_o        (cmo_dir_check_entry_valid),
        .cmo_dir_check_entry_wback_o        (cmo_dir_check_entry_wback),
        .cmo_dir_check_entry_dirty_o        (cmo_dir_check_entry_dirty),
        .cmo_dir_check_entry_tag_o          (cmo_dir_check_entry_tag),
        .cmo_dir_updt_i                     (cmo_dir_updt),
        .cmo_dir_updt_set_i                 (cmo_dir_updt_set),
        .cmo_dir_updt_way_i                 (cmo_dir_updt_way),
        .cmo_dir_updt_valid_i               (cmo_dir_updt_valid),
        .cmo_dir_updt_wback_i               (cmo_dir_updt_wback),
        .cmo_dir_updt_dirty_i               (cmo_dir_updt_dirty),
        .cmo_dir_updt_fetch_i               (cmo_dir_updt_fetch),
        .cmo_dir_updt_tag_i                 (cmo_dir_updt_tag),
        .cmo_core_rsp_ready_o               (cmo_core_rsp_ready),
        .cmo_core_rsp_valid_i               (cmo_core_rsp_valid),
        .cmo_core_rsp_i                     (cmo_core_rsp),

        .mshr_empty_i                       (miss_mshr_empty),
        .flush_empty_i                      (flush_empty),

        .rtab_empty_o                       (rtab_empty),
        .ctrl_empty_o                       (ctrl_empty),

        .cfg_enable_i,
        .cfg_prefetch_updt_plru_i,
        .cfg_rtab_single_entry_i,
        .cfg_default_wb_i                   (cfg_default_wb),
        .cfg_scrub_enable_i,
        .cfg_scrub_period_i,
        .cfg_scrub_restart_i,

        .evt_cache_write_miss_o,
        .evt_cache_read_miss_o,
        .evt_cache_dir_unc_err_o,
        .evt_cache_dir_cor_err_o,
        .evt_cache_dat_unc_err_o,
        .evt_cache_dat_cor_err_o,
        .evt_scrub_complete_o,
        .evt_uncached_req_o,
        .evt_cmo_req_o,
        .evt_write_req_o,
        .evt_read_req_o,
        .evt_prefetch_req_o,
        .evt_req_on_hold_o,
        .evt_rtab_rollback_o,
        .evt_stall_refill_o,
        .evt_stall_o
    );
    //  }}}

    //  HPDcache write-buffer
    //  {{{
    if (HPDcacheCfg.u.wtEn) begin : gen_wbuf
        hpdcache_wbuf #(
            .HPDcacheCfg                        (HPDcacheCfg),
            .wbuf_addr_t                        (wbuf_addr_t),
            .wbuf_timecnt_t                     (wbuf_timecnt_t),
            .hpdcache_mem_id_t                  (hpdcache_mem_id_t),
            .hpdcache_mem_req_t                 (hpdcache_mem_req_t),
            .hpdcache_mem_req_w_t               (hpdcache_mem_req_w_t),
            .hpdcache_mem_resp_w_t              (hpdcache_mem_resp_w_t)
        ) hpdcache_wbuf_i(
            .clk_i,
            .rst_ni,

            .empty_o                            (wbuf_empty_o),
            .full_o                             (/* unused */),
            .flush_all_i                        (wbuf_flush_all),

            .cfg_threshold_i                    (cfg_wbuf_threshold_i),
            .cfg_reset_timecnt_on_write_i       (cfg_wbuf_reset_timecnt_on_write_i),
            .cfg_sequential_waw_i               (cfg_wbuf_sequential_waw_i),
            .cfg_inhibit_write_coalescing_i     (cfg_wbuf_inhibit_write_coalescing_i),

            .write_i                            (wbuf_write),
            .write_ready_o                      (wbuf_write_ready),
            .write_addr_i                       (wbuf_write_addr),
            .write_data_i                       (wbuf_write_data),
            .write_be_i                         (wbuf_write_be),
            .write_uc_i                         (wbuf_write_uncacheable),

            .read_addr_i                        (wbuf_write_addr),
            .read_hit_o                         (wbuf_read_hit),
            .read_flush_hit_i                   (wbuf_read_flush_hit),

            .replay_addr_i                      (wbuf_rtab_addr),
            .replay_is_read_i                   (wbuf_rtab_is_read),
            .replay_open_hit_o                  (wbuf_rtab_hit_open),
            .replay_pend_hit_o                  (wbuf_rtab_hit_pend),
            .replay_sent_hit_o                  (wbuf_rtab_hit_sent),
            .replay_not_ready_o                 (wbuf_rtab_not_ready),

            .mem_req_write_ready_i              (mem_req_write_wbuf_ready),
            .mem_req_write_valid_o              (mem_req_write_wbuf_valid),
            .mem_req_write_o                    (mem_req_write_wbuf),

            .mem_req_write_data_ready_i         (mem_req_write_wbuf_data_ready),
            .mem_req_write_data_valid_o         (mem_req_write_wbuf_data_valid),
            .mem_req_write_data_o               (mem_req_write_wbuf_data),

            .mem_resp_write_ready_o             (mem_resp_write_wbuf_ready),
            .mem_resp_write_valid_i             (mem_resp_write_wbuf_valid),
            .mem_resp_write_i                   (mem_resp_write_wbuf)
        );
    end else begin : gen_no_wbuf
        //  The write-buffer behaves as a black-hole: consumes but do not produce data
        assign wbuf_empty_o                  = 1'b1;
        assign wbuf_write_ready              = 1'b1;
        assign wbuf_read_hit                 = 1'b0;
        assign wbuf_rtab_hit_open            = 1'b0;
        assign wbuf_rtab_hit_pend            = 1'b0;
        assign wbuf_rtab_hit_sent            = 1'b0;
        assign wbuf_rtab_not_ready           = 1'b0;
        assign mem_req_write_wbuf_valid      = 1'b0;
        assign mem_req_write_wbuf            = '{
            mem_req_command: HPDCACHE_MEM_READ,
            mem_req_atomic : HPDCACHE_MEM_ATOMIC_ADD,
            default        : '0
        };
        assign mem_req_write_wbuf_data_valid = 1'b0;
        assign mem_req_write_wbuf_data       = '0;
        assign mem_resp_write_wbuf_ready     = 1'b1;
    end
    //  }}}

    //  Miss handler
    //  {{{
    hpdcache_miss_handler #(
        .HPDcacheCfg                        (HPDcacheCfg),
        .hpdcache_nline_t                   (hpdcache_nline_t),
        .hpdcache_set_t                     (hpdcache_set_t),
        .hpdcache_tag_t                     (hpdcache_tag_t),
        .hpdcache_word_t                    (hpdcache_word_t),
        .hpdcache_way_vector_t              (hpdcache_way_vector_t),
        .hpdcache_way_t                     (hpdcache_way_t),
        .hpdcache_dir_entry_t               (hpdcache_dir_entry_t),
        .hpdcache_refill_data_t             (hpdcache_access_data_t),
        .hpdcache_req_data_t                (hpdcache_req_data_t),
        .hpdcache_req_be_t                  (hpdcache_req_be_t),
        .hpdcache_req_offset_t              (hpdcache_req_offset_t),
        .hpdcache_req_sid_t                 (hpdcache_req_sid_t),
        .hpdcache_req_tid_t                 (hpdcache_req_tid_t),
        .hpdcache_req_t                     (hpdcache_req_t),
        .hpdcache_rsp_t                     (hpdcache_rsp_t),
        .hpdcache_mem_id_t                  (hpdcache_mem_id_t),
        .hpdcache_mem_req_t                 (hpdcache_mem_req_t),
        .hpdcache_mem_resp_r_t              (hpdcache_mem_resp_r_t)
    ) hpdcache_miss_handler_i(
        .clk_i,
        .rst_ni,

        .mshr_empty_o                       (miss_mshr_empty),
        .mshr_full_o                        (/* unused */),

        .cfg_prefetch_updt_sel_victim_i     (cfg_prefetch_updt_plru_i),

        .mshr_check_i                       (miss_mshr_check),
        .mshr_check_offset_i                (miss_mshr_check_offset),
        .mshr_check_nline_i                 (miss_mshr_check_nline),
        .mshr_check_hit_o                   (miss_mshr_hit),
        .probe_check_valid_i                (coh_probe_query_valid_i),
        .probe_check_nline_i                (coh_probe_query_nline_i),
        .probe_line_busy_o                  (coh_probe_mshr_busy),

        .mshr_alloc_ready_o                 (miss_mshr_alloc_ready),
        .mshr_alloc_i                       (miss_mshr_alloc),
        .mshr_alloc_cs_i                    (miss_mshr_alloc_cs),
        .mshr_alloc_nline_i                 (miss_mshr_alloc_nline),
        .mshr_alloc_full_o                  (miss_mshr_alloc_full),
        .mshr_alloc_cbuf_full_o             (miss_mshr_alloc_cbuf_full),
        .mshr_alloc_tid_i                   (miss_mshr_alloc_tid),
        .mshr_alloc_sid_i                   (miss_mshr_alloc_sid),
        .mshr_alloc_word_i                  (miss_mshr_alloc_word),
        .mshr_alloc_victim_way_i            (miss_mshr_alloc_victim_way),
        .mshr_alloc_need_rsp_i              (miss_mshr_alloc_need_rsp),
        .mshr_alloc_is_prefetch_i           (miss_mshr_alloc_is_prefetch),
        .mshr_alloc_wback_i                 (miss_mshr_alloc_wback),
        .mshr_alloc_dirty_i                 (miss_mshr_alloc_dirty),
        .mshr_alloc_probe_shared_i          (st2_mshr_alloc_probe_shared),
        .mshr_alloc_exclusive_i             (miss_mshr_alloc_exclusive),
        .mshr_alloc_wdata_i                 (miss_mshr_alloc_wdata),
        .mshr_alloc_be_i                    (miss_mshr_alloc_be),

        .refill_req_ready_i                 (refill_req_ready),
        .refill_req_valid_o                 (refill_req_valid),
        .refill_is_error_o                  (refill_is_error),
        .refill_busy_o                      (refill_busy),
        .refill_updt_sel_victim_o           (refill_updt_sel_victim),
        .refill_set_o                       (refill_set),
        .refill_way_o                       (refill_way),
        .refill_dir_entry_o                 (refill_dir_entry),
        .refill_write_dir_o                 (refill_write_dir),
        .refill_write_data_o                (refill_write_data),
        .refill_data_o                      (refill_data),
        .refill_word_o                      (refill_word),
        .refill_nline_o                     (refill_nline),
        .refill_updt_rtab_o                 (refill_updt_rtab),

        .inval_check_dir_o                  (inval_check_dir),
        .inval_write_dir_o                  (inval_write_dir),
        .inval_nline_o                      (inval_nline),
        .inval_hit_i                        (inval_hit),

        .refill_core_rsp_valid_o            (refill_core_rsp_valid),
        .refill_core_rsp_o                  (refill_core_rsp),

        .mem_req_ready_i                    (mem_req_read_miss_ready),
        .mem_req_valid_o                    (mem_req_read_miss_valid),
        .mem_req_o                          (mem_req_read_miss),

        .mem_resp_ready_o                   (mem_resp_read_miss_ready),
        .mem_resp_valid_i                   (mem_resp_read_miss_valid),
        .mem_resp_i                         (mem_resp_read_miss),
        .mem_resp_inval_i                   (mem_resp_read_miss_inval),
        .mem_resp_inval_nline_i             (mem_resp_read_miss_inval_nline),
        .coh_own_req_valid_o,
        .coh_own_req_ready_i,
        .coh_own_req_id_o,
        .coh_own_req_nline_o,
        .coh_own_req_kind_o,
        .coh_own_gnt_valid_i,
        .coh_own_gnt_ready_o,
        .coh_own_gnt_id_i,
        .coh_own_gnt_nline_i,
        .coh_own_gnt_state_i,
        .coh_own_gnt_err_i
    );

    // Retirement must not start a CBO while a retired store still waits in
    // replay, refill, or the native cache pipeline after the LSU grant.
    assign coh_cpu_idle_o = rtab_empty && ctrl_empty && miss_mshr_empty;

    assign coh_probe_line_busy_o = coh_probe_mshr_busy | coh_probe_pipeline_busy |
        (coh_probe_query_valid_i && uc_local_atomic_busy &&
         (coh_probe_query_nline_i == uc_local_atomic_nline));
    //  }}}

    //  Uncacheable request handler
    //  {{{
    hpdcache_uncached #(
        .HPDcacheCfg                   (HPDcacheCfg),
        .hpdcache_nline_t              (hpdcache_nline_t),
        .hpdcache_tag_t                (hpdcache_tag_t),
        .hpdcache_set_t                (hpdcache_set_t),
        .hpdcache_offset_t             (hpdcache_offset_t),
        .hpdcache_word_t               (hpdcache_word_t),
        .hpdcache_req_addr_t           (hpdcache_req_addr_t),
        .hpdcache_req_tid_t            (hpdcache_req_tid_t),
        .hpdcache_req_sid_t            (hpdcache_req_sid_t),
        .hpdcache_req_data_t           (hpdcache_req_data_t),
        .hpdcache_req_be_t             (hpdcache_req_be_t),
        .hpdcache_way_vector_t         (hpdcache_way_vector_t),
        .hpdcache_req_t                (hpdcache_req_t),
        .hpdcache_rsp_t                (hpdcache_rsp_t),
        .hpdcache_mem_id_t             (hpdcache_mem_id_t),
        .hpdcache_mem_req_t            (hpdcache_mem_req_t),
        .hpdcache_mem_req_w_t          (hpdcache_mem_req_w_t),
        .hpdcache_mem_resp_r_t         (hpdcache_mem_resp_r_t),
        .hpdcache_mem_resp_w_t         (hpdcache_mem_resp_w_t)
    ) hpdcache_uc_i(
        .clk_i,
        .rst_ni,

        .req_valid_i                   (uc_req_valid),
        .req_ready_o                   (uc_ready),
        .req_op_i                      (uc_req_op),
        .req_addr_i                    (uc_req_addr),
        .req_size_i                    (uc_req_size),
        .req_data_i                    (uc_req_data),
        .req_be_i                      (uc_req_be),
        .req_uc_i                      (uc_req_uncacheable),
        .req_sid_i                     (uc_req_sid),
        .req_tid_i                     (uc_req_tid),
        .req_need_rsp_i                (uc_req_need_rsp),
        .req_hit_way_i                 (uc_req_dir_hit_way),
        .req_old_data_i                (uc_req_old_data),

        .data_amo_write_o              (uc_data_amo_write),
        .data_amo_write_enable_o       (uc_data_amo_write_enable),
        .data_amo_write_set_o          (uc_data_amo_write_set),
        .data_amo_write_size_o         (uc_data_amo_write_size),
        .data_amo_write_word_o         (uc_data_amo_write_word),
        .data_amo_write_way_o          (uc_data_amo_write_way),
        .data_amo_write_data_o         (uc_data_amo_write_data),
        .data_amo_write_be_o           (uc_data_amo_write_be),

        .local_fault_i                 (core_rsp_valid & core_rsp.error),
        .coh_invalidate_i              (coh_probe_state_update_valid &
                                       coh_probe_state_update_ready &
                                       (coh_probe_state_update_state == 2'd0)),
        .coh_invalidate_nline_i        (coh_probe_state_update_nline),
        .local_invalidate_i            (uc_lrsc_invalidate),
        .local_invalidate_nline_i      (uc_lrsc_invalidate_nline),
        .lrsc_match_o                 (uc_lrsc_match),
        .local_atomic_busy_o          (uc_local_atomic_busy),
        .local_atomic_nline_o         (uc_local_atomic_nline),
        .lrsc_snoop_i                  (uc_lrsc_snoop),
        .lrsc_snoop_addr_i             (uc_lrsc_snoop_addr),
        .lrsc_snoop_size_i             (uc_lrsc_snoop_size),

        .core_rsp_ready_i              (uc_core_rsp_ready),
        .core_rsp_valid_o              (uc_core_rsp_valid),
        .core_rsp_o                    (uc_core_rsp),

        .mem_read_id_i                 (HPDCACHE_UC_READ_ID),
        .mem_write_id_i                (HPDCACHE_UC_WRITE_ID),

        .mem_req_read_ready_i          (mem_req_read_uc_ready),
        .mem_req_read_valid_o          (mem_req_read_uc_valid),
        .mem_req_read_o                (mem_req_read_uc),

        .mem_resp_read_ready_o         (mem_resp_read_uc_ready),
        .mem_resp_read_valid_i         (mem_resp_read_uc_valid),
        .mem_resp_read_i               (mem_resp_read_uc),

        .mem_req_write_ready_i         (mem_req_write_uc_ready),
        .mem_req_write_valid_o         (mem_req_write_uc_valid),
        .mem_req_write_o               (mem_req_write_uc),

        .mem_req_write_data_ready_i    (mem_req_write_uc_data_ready),
        .mem_req_write_data_valid_o    (mem_req_write_uc_data_valid),
        .mem_req_write_data_o          (mem_req_write_uc_data),

        .mem_resp_write_ready_o        (mem_resp_write_uc_ready),
        .mem_resp_write_valid_i        (mem_resp_write_uc_valid),
        .mem_resp_write_i              (mem_resp_write_uc),

        .cfg_error_on_cacheable_amo_i
    );
    //  }}}

    //  CMO Request Handler
    //  {{{
    hpdcache_cmo #(
        .HPDcacheCfg                   (HPDcacheCfg),

        .hpdcache_nline_t              (hpdcache_nline_t),
        .hpdcache_tag_t                (hpdcache_tag_t),
        .hpdcache_set_t                (hpdcache_set_t),
        .hpdcache_data_word_t          (hpdcache_data_word_t),
        .hpdcache_way_vector_t         (hpdcache_way_vector_t),

        .hpdcache_rsp_t                (hpdcache_rsp_t),
        .hpdcache_req_addr_t           (hpdcache_req_addr_t),
        .hpdcache_req_tid_t            (hpdcache_req_tid_t),
        .hpdcache_req_sid_t            (hpdcache_req_sid_t),
        .hpdcache_req_data_t           (hpdcache_req_data_t)
    ) hpdcache_cmo_i(
        .fence_sync_i,
        .fence_line_valid_o,
        .fence_line_ready_i,
        .fence_line_o,
        .fence_line_done_i,
        .fence_line_error_i,
        .fence_error_o,
        .fence_error_line_o,
        .clk_i,
        .rst_ni,

        .req_valid_i                   (cmo_req_valid),
        .req_ready_o                   (cmo_ready),
        .req_op_i                      (cmo_req_op),
        .req_addr_i                    (cmo_req_addr),
        .req_sid_i                     (cmo_req_sid),
        .req_tid_i                     (cmo_req_tid),
        .req_need_rsp_i                (cmo_req_need_rsp),

        .dirty_set_en_i                (cmo_dirty_set_en),
        .dirty_min_set_i               (cmo_dirty_min_set),
        .dirty_max_set_i               (cmo_dirty_max_set),
        .valid_set_en_i                (cmo_valid_set_en),
        .valid_min_set_i               (cmo_valid_min_set),
        .valid_max_set_i               (cmo_valid_max_set),
        .flush_all_o                   (cmo_flush_all),
        .inval_all_o                   (cmo_inval_all),

        .core_rsp_ready_i              (cmo_core_rsp_ready),
        .core_rsp_valid_o              (cmo_core_rsp_valid),
        .core_rsp_o                    (cmo_core_rsp),


        .dir_check_entry_o             (cmo_dir_check_entry),
        .dir_check_entry_set_o         (cmo_dir_check_entry_set),
        .dir_check_entry_way_o         (cmo_dir_check_entry_way),
        .dir_check_entry_valid_i       (cmo_dir_check_entry_valid),
        .dir_check_entry_wback_i       (cmo_dir_check_entry_wback),
        .dir_check_entry_dirty_i       (cmo_dir_check_entry_dirty),
        .dir_check_entry_tag_i         (cmo_dir_check_entry_tag),

        .dir_updt_o                    (cmo_dir_updt),
        .dir_updt_set_o                (cmo_dir_updt_set),
        .dir_updt_way_o                (cmo_dir_updt_way),
        .dir_updt_valid_o              (cmo_dir_updt_valid),
        .dir_updt_wback_o              (cmo_dir_updt_wback),
        .dir_updt_dirty_o              (cmo_dir_updt_dirty),
        .dir_updt_fetch_o              (cmo_dir_updt_fetch),
        .dir_updt_tag_o                (cmo_dir_updt_tag),

        .flush_empty_i                 (flush_empty),
        .flush_alloc_o                 (cmo_flush_alloc),
        .flush_alloc_ready_i           (cmo_flush_alloc_ready),
        .flush_alloc_nline_o           (cmo_flush_alloc_nline),
        .flush_alloc_way_o             (cmo_flush_alloc_way)
    );
    //  }}}

    //  Native tagged probe engine: PREPARE lookup/writeback and COMMIT directory update.
    //  {{{
    m_vlsit_riscv_hpd_probe_engine #(
        .PARA_WAY_NUM (32'(HPDcacheCfg.u.ways)),
        .PARA_NLINE_W (32'(HPDcacheCfg.nlineWidth))  // RV32 plan v2 Q6-A
    ) u_vlsit_riscv_hpd_probe_engine (
        .i_clk_cache                 (clk_i),
        .i_rst_n_cache               (rst_ni),
        .i_probe_req_valid           (coh_probe_req_valid_i),
        .o_probe_req_ready           (coh_probe_req_ready_o),
        .i_probe_req_tag             (coh_probe_req_tag_i),
        .i_probe_req_nline           (coh_probe_req_nline_i),
        .i_probe_req_phase           (coh_probe_req_phase_i),
        .i_probe_req_target_state    (coh_probe_req_target_state_i),
        .i_probe_req_wback_en         (coh_probe_req_wback_en_i),
        .o_probe_rsp_valid           (coh_probe_rsp_valid_o),
        .i_probe_rsp_ready           (coh_probe_rsp_ready_i),
        .o_probe_rsp_tag             (coh_probe_rsp_tag_o),
        .o_probe_rsp_nline            (coh_probe_rsp_nline_o),
        .o_probe_rsp_phase            (coh_probe_rsp_phase_o),
        .o_probe_rsp_state            (coh_probe_rsp_state_o),
        .o_probe_rsp_err              (coh_probe_rsp_err_o),
        .o_probe_rsp_wback_done       (coh_probe_rsp_wback_done_o),
        .o_lookup_valid               (coh_probe_lookup_valid),
        .i_lookup_ready               (coh_probe_lookup_ready),
        .o_lookup_tag                 (coh_probe_lookup_tag),
        .o_lookup_nline               (coh_probe_lookup_nline),
        .i_lookup_rsp_valid           (coh_probe_lookup_rsp_valid),
        .o_lookup_rsp_ready           (coh_probe_lookup_rsp_ready),
        .i_lookup_rsp_tag             (coh_probe_lookup_rsp_tag),
        .i_lookup_rsp_nline           (coh_probe_lookup_rsp_nline),
        .i_lookup_rsp_way             (coh_probe_lookup_rsp_way),
        .i_lookup_rsp_hit             (coh_probe_lookup_rsp_hit),
        .i_lookup_rsp_state           (coh_probe_lookup_rsp_state),
        .i_lookup_rsp_err             (coh_probe_lookup_rsp_error),
        .o_flush_valid                (probe_flush_alloc),
        .i_flush_ready                (probe_flush_alloc_ready),
        .o_flush_nline                (probe_flush_alloc_nline),
        .o_flush_way                  (probe_flush_alloc_way),
        .i_flush_ack_valid            (flush_ack & (flush_ack_origin == 2'b10)),
        .i_flush_ack_nline            (flush_ack_nline),
        .i_flush_ack_err              (flush_ack_error),
        .o_state_update_valid         (coh_probe_state_update_valid),
        .i_state_update_ready         (coh_probe_state_update_ready),
        .o_state_update_nline         (coh_probe_state_update_nline),
        .o_state_update_way           (coh_probe_state_update_way),
        .o_state_update_state         (coh_probe_state_update_state)
    );
    //  }}}

    //  Flush controller
    //  {{{
    if (HPDcacheCfg.u.wbEn) begin : gen_flush
        assign ctrl_flush_alloc_ready = flush_alloc_ready;
        assign cmo_flush_alloc_ready = flush_alloc_ready & ~ctrl_flush_alloc;
        // Probe allocation reads the first data word in the same cycle. Stop
        // new CPU/replay admission, drain admitted work, then grant the array.
        assign probe_flush_array_grant = ctrl_empty & uc_ready & ~refill_busy;
        assign probe_flush_alloc_ready = flush_alloc_ready & ~ctrl_flush_alloc & ~cmo_flush_alloc
                                         & probe_flush_array_grant;
        assign flush_alloc = ctrl_flush_alloc | cmo_flush_alloc |
                             (probe_flush_alloc & probe_flush_array_grant);
        assign flush_alloc_nline = ctrl_flush_alloc ? ctrl_flush_alloc_nline
                                   : cmo_flush_alloc ? cmo_flush_alloc_nline
                                   : probe_flush_alloc_nline;
        assign flush_alloc_way = ctrl_flush_alloc ? ctrl_flush_alloc_way
                                 : cmo_flush_alloc ? cmo_flush_alloc_way
                                 : probe_flush_alloc_way;
        assign flush_alloc_origin = ctrl_flush_alloc ? 2'b00
                                    : cmo_flush_alloc ? 2'b01
                                    : 2'b10;

        hpdcache_flush #(
            .HPDcacheCfg                   (HPDcacheCfg),

            .hpdcache_nline_t              (hpdcache_nline_t),
            .hpdcache_set_t                (hpdcache_set_t),
            .hpdcache_word_t               (hpdcache_word_t),
            .hpdcache_way_vector_t         (hpdcache_way_vector_t),
            .hpdcache_access_data_t        (hpdcache_access_data_t),

            .hpdcache_mem_id_t             (hpdcache_mem_id_t),
            .hpdcache_mem_data_t           (hpdcache_mem_data_t),
            .hpdcache_mem_req_t            (hpdcache_mem_req_t),
            .hpdcache_mem_req_w_t          (hpdcache_mem_req_w_t),
            .hpdcache_mem_resp_w_t         (hpdcache_mem_resp_w_t)
        ) flush_i(
            .clk_i,
            .rst_ni,

            .flush_empty_o                 (flush_empty),
            .flush_full_o                  (/* open */),
            .flush_busy_o                  (flush_busy),

            .flush_check_nline_i           (flush_check_nline),
            .flush_check_hit_o             (flush_check_hit),

            .flush_alloc_i                 (flush_alloc),
            .flush_alloc_ready_o           (flush_alloc_ready),
            .flush_alloc_nline_i           (flush_alloc_nline),
            .flush_alloc_way_i             (flush_alloc_way),
            .flush_alloc_origin_i          (flush_alloc_origin),

            .flush_data_read_o             (flush_data_read),
            .flush_data_read_set_o         (flush_data_read_set),
            .flush_data_read_word_o        (flush_data_read_word),
            .flush_data_read_way_o         (flush_data_read_way),
            .flush_data_read_data_i        (flush_data_read_data),

            .flush_ack_o                   (flush_ack),
            .flush_ack_nline_o             (flush_ack_nline),
            .flush_ack_origin_o            (flush_ack_origin),
            .flush_ack_error_o             (flush_ack_error),
            .flush_rsp_invalid_o           (flush_rsp_invalid),

            .mem_req_write_ready_i         (mem_req_write_flush_ready),
            .mem_req_write_valid_o         (mem_req_write_flush_valid),
            .mem_req_write_o               (mem_req_write_flush),

            .mem_req_write_data_ready_i    (mem_req_write_flush_data_ready),
            .mem_req_write_data_valid_o    (mem_req_write_flush_data_valid),
            .mem_req_write_data_o          (mem_req_write_flush_data),

            .mem_resp_write_ready_o        (mem_resp_write_flush_ready),
            .mem_resp_write_valid_i        (mem_resp_write_flush_valid),
            .mem_resp_write_i              (mem_resp_write_flush)
        );
    end else begin : gen_no_flush
        //  The flush controller behaves as a black-hole: consumes but do not produce data
        assign flush_empty                     = 1'b1;
        assign flush_busy                      = 1'b0;
        assign flush_check_hit                 = 1'b0;
        assign flush_alloc_ready               = 1'b1;
        assign ctrl_flush_alloc_ready          = 1'b1;
        assign cmo_flush_alloc_ready           = 1'b1;
        assign probe_flush_alloc_ready         = 1'b0;
        assign probe_flush_array_grant         = 1'b0;
        assign flush_data_read                 = 1'b0;
        assign flush_data_read_set             = '0;
        assign flush_data_read_word            = '0;
        assign flush_data_read_way             = '0;
        assign flush_ack                       = 1'b0;
        assign flush_ack_nline                 = '0;
        assign flush_alloc_origin              = '0;
        assign flush_ack_origin                = '0;
        assign flush_ack_error                 = 1'b0;
        assign flush_rsp_invalid               = 1'b0;
        assign mem_req_write_flush_valid       = 1'b0;
        assign mem_req_write_flush             = '{
            mem_req_command: HPDCACHE_MEM_READ,
            mem_req_atomic : HPDCACHE_MEM_ATOMIC_ADD,
            default        : '0
        };
        assign mem_req_write_flush_data_valid  = 1'b0;
        assign mem_req_write_flush_data        = '0;
        assign mem_resp_write_flush_ready      = 1'b1;
    end
    //  }}}

    // Preserve the matching B response result for the CVA6/CCU integration.
    assign flush_ack_valid_o = flush_ack;
    assign flush_ack_nline_o = flush_ack_nline;
    assign flush_ack_origin_o = flush_ack_origin;
    assign flush_ack_error_o = flush_ack_error;
    assign flush_rsp_invalid_o = flush_rsp_invalid;

    //  Read and Write Arbiters for Memory interfaces
    //  {{{

    //      Read request interface
    //
    //      There is a fixed-priority arbiter between:
    //      - the miss_handler (higher priority);
    //      - the uncacheable request handler (lower priority)
    logic              [1:0] arb_mem_req_read_ready;
    logic              [1:0] arb_mem_req_read_valid;
    hpdcache_mem_req_t [1:0] arb_mem_req_read;

    assign mem_req_read_miss_ready = arb_mem_req_read_ready[0];
    assign arb_mem_req_read_valid[0] = mem_req_read_miss_valid;
    assign arb_mem_req_read[0] = mem_req_read_miss;

    assign mem_req_read_uc_ready = arb_mem_req_read_ready[1];
    assign arb_mem_req_read_valid[1] = mem_req_read_uc_valid;
    assign arb_mem_req_read[1] = mem_req_read_uc;

    hpdcache_mem_req_read_arbiter #(
        .N                     (2),
        .hpdcache_mem_req_t    (hpdcache_mem_req_t)
    ) hpdcache_mem_req_read_arbiter_i(
        .clk_i,
        .rst_ni,

        .mem_req_read_ready_o  (arb_mem_req_read_ready),
        .mem_req_read_valid_i  (arb_mem_req_read_valid),
        .mem_req_read_i        (arb_mem_req_read),

        .mem_req_read_ready_i,
        .mem_req_read_valid_o,
        .mem_req_read_o        (mem_req_read_o),

        .gnt_index_o           (/*unused*/)
    );

    //      Read response interface
    always_comb
    begin : mem_resp_read_demux_comb
        mem_resp_read_uc_valid = 1'b0;
        mem_resp_read_miss_valid = 1'b0;
        mem_resp_read_ready_o = 1'b0;
        if (mem_resp_read_valid_i) begin
            if (mem_resp_read_i.mem_resp_r_id == {HPDcacheCfg.u.memIdWidth{1'b1}}
                && ~mem_resp_read_miss_inval) begin
                mem_resp_read_uc_valid = 1'b1;
                mem_resp_read_ready_o = mem_resp_read_uc_ready;
            end else begin
                mem_resp_read_miss_valid = 1'b1;
                mem_resp_read_ready_o = mem_resp_read_miss_ready;
            end
        end
    end

    assign mem_resp_read_uc               = mem_resp_read_i;
    assign mem_resp_read_miss             = mem_resp_read_i;

    assign mem_resp_read_miss_inval       = mem_resp_read_inval_i;
    assign mem_resp_read_miss_inval_nline = mem_resp_read_inval_nline_i;

    //      Write request interface
    //
    //      There is a fixed-priority arbiter between:
    //      - the flush controller (higher priority)
    //      - the write buffer
    //      - the uncacheable request handler (lower priority)
    logic                [2:0] arb_mem_req_write_ready;
    logic                [2:0] arb_mem_req_write_valid;
    hpdcache_mem_req_t   [2:0] arb_mem_req_write;

    logic                [2:0] arb_mem_req_write_data_valid;
    logic                [2:0] arb_mem_req_write_data_ready;
    hpdcache_mem_req_w_t [2:0] arb_mem_req_write_data;

    //      Split the ID space into 3 segments:
    //      1111...1111  -> Uncached writes
    //      1xxx...xxxx  -> Flush writes (where at least one x is 0)
    //      0xxx...xxxx  -> Write buffer writes
    //
    //      If only one write policy is implemented (write-through or write-back),
    //      the ID space is split into 2 segments:
    //      1111...1111  -> Uncached writes
    //      xxxx...xxxx  -> Flush/Write buffer writes (where at least one x is 0)
    function automatic hpdcache_mem_req_t hpdcache_req_write_sel_id(
        hpdcache_mem_req_t req, int kind
    );
        //  Request from the uncached controller
        if (kind == 2) begin
            req.mem_req_id = '1;
            return req;
        end

        if (HPDcacheCfg.u.wtEn && HPDcacheCfg.u.wbEn) begin
            unique case (kind)
                //  Request from the write buffer
                0: req.mem_req_id = {1'b0, req.mem_req_id[0 +: HPDcacheCfg.u.memIdWidth-1]};

                //  Request from the flush controller
                1: req.mem_req_id = {1'b1, req.mem_req_id[0 +: HPDcacheCfg.u.memIdWidth-1]};
            endcase
        end
        return req;
    endfunction

    function automatic hpdcache_mem_resp_w_t hpdcache_resp_write_sel_id(
        hpdcache_mem_resp_w_t resp, int kind
    );
        //  Response to the uncached controller
        if (kind == 2) begin
            resp.mem_resp_w_id = '1;
            return resp;
        end

        //  Response to the write buffer or to the flush controller
        if (HPDcacheCfg.u.wtEn && HPDcacheCfg.u.wbEn) begin
            resp.mem_resp_w_id = {1'b0, resp.mem_resp_w_id[0 +: HPDcacheCfg.u.memIdWidth-1]};
        end
        return resp;
    endfunction

    function automatic int hpdcache_resp_write_kind(
        hpdcache_mem_id_t resp_id
    );
        //  Response to the uncached controller
        if (resp_id == {HPDcacheCfg.u.memIdWidth{1'b1}}) begin
            return 2;
        end

        //  Response to the write buffer or to the flush controller
        if (HPDcacheCfg.u.wtEn && !HPDcacheCfg.u.wbEn) begin
            return 0;
        end
        if (!HPDcacheCfg.u.wtEn && HPDcacheCfg.u.wbEn) begin
            return 1;
        end
        return (resp_id[HPDcacheCfg.u.memIdWidth-1] == 1'b1) ? 1 : 0;
    endfunction

    assign mem_req_write_wbuf_ready        = arb_mem_req_write_ready[0];
    assign arb_mem_req_write_valid[0]      = mem_req_write_wbuf_valid;
    assign arb_mem_req_write[0]            = hpdcache_req_write_sel_id(mem_req_write_wbuf, 0);

    assign mem_req_write_wbuf_data_ready   = arb_mem_req_write_data_ready[0];
    assign arb_mem_req_write_data_valid[0] = mem_req_write_wbuf_data_valid;
    assign arb_mem_req_write_data[0]       = mem_req_write_wbuf_data;

    assign mem_req_write_flush_ready       = arb_mem_req_write_ready[1];
    assign arb_mem_req_write_valid[1]      = mem_req_write_flush_valid;
    assign arb_mem_req_write[1]            = hpdcache_req_write_sel_id(mem_req_write_flush, 1);

    assign mem_req_write_flush_data_ready  = arb_mem_req_write_data_ready[1];
    assign arb_mem_req_write_data_valid[1] = mem_req_write_flush_data_valid;
    assign arb_mem_req_write_data[1]       = mem_req_write_flush_data;

    assign mem_req_write_uc_ready          = arb_mem_req_write_ready[2];
    assign arb_mem_req_write_valid[2]      = mem_req_write_uc_valid;
    assign arb_mem_req_write[2]            = hpdcache_req_write_sel_id(mem_req_write_uc, 2);

    assign mem_req_write_uc_data_ready     = arb_mem_req_write_data_ready[2];
    assign arb_mem_req_write_data_valid[2] = mem_req_write_uc_data_valid;
    assign arb_mem_req_write_data[2]       = mem_req_write_uc_data;

    hpdcache_mem_req_write_arbiter #(
        .N                             (3),
        .hpdcache_mem_req_t            (hpdcache_mem_req_t),
        .hpdcache_mem_req_w_t          (hpdcache_mem_req_w_t)
    ) hpdcache_mem_req_write_arbiter_i (
        .clk_i,
        .rst_ni,

        .mem_req_write_ready_o         (arb_mem_req_write_ready),
        .mem_req_write_valid_i         (arb_mem_req_write_valid),
        .mem_req_write_i               (arb_mem_req_write),

        .mem_req_write_data_ready_o    (arb_mem_req_write_data_ready),
        .mem_req_write_data_valid_i    (arb_mem_req_write_data_valid),
        .mem_req_write_data_i          (arb_mem_req_write_data),

        .mem_req_write_ready_i,
        .mem_req_write_valid_o,
        .mem_req_write_o               (mem_req_write_o),

        .mem_req_write_data_ready_i,
        .mem_req_write_data_valid_o,
        .mem_req_write_data_o          (mem_req_write_data_o)
    );

    //      Write response interface
    always_comb
    begin : mem_resp_write_demux_comb
        mem_resp_write_flush_valid = 1'b0;
        mem_resp_write_wbuf_valid = 1'b0;
        mem_resp_write_uc_valid = 1'b0;
        mem_resp_write_ready_o = 1'b0;
        if (mem_resp_write_valid_i) begin
            unique case (hpdcache_resp_write_kind(mem_resp_write_i.mem_resp_w_id))
                0: begin
                    mem_resp_write_wbuf_valid = 1'b1;
                    mem_resp_write_ready_o = mem_resp_write_wbuf_ready;
                end
                1: begin
                    mem_resp_write_flush_valid = 1'b1;
                    mem_resp_write_ready_o = mem_resp_write_flush_ready;
                end
                2: begin
                    mem_resp_write_uc_valid = 1'b1;
                    mem_resp_write_ready_o = mem_resp_write_uc_ready;
                end
            endcase
        end
    end

    assign mem_resp_write_wbuf = hpdcache_resp_write_sel_id(mem_resp_write_i, 0);
    assign mem_resp_write_flush = hpdcache_resp_write_sel_id(mem_resp_write_i, 1);
    assign mem_resp_write_uc = hpdcache_resp_write_sel_id(mem_resp_write_i, 2);
    //  }}}

    //  Assertions
    //  {{{
`ifndef HPDCACHE_ASSERT_OFF
    assert property (@(posedge clk_i) disable iff (rst_ni !== 1'b1)
        ctrl_flush_alloc |-> !cmo_flush_alloc) else
            $error("Unsupported concurrent flush from ctrl and cmo");

    if (!(HPDcacheCfg.u.wordWidth inside {32, 64})) begin : gen_word_width_assertion
        $fatal(1, "word width shall be 32 or 64");
    end
    if (HPDcacheCfg.u.reqWords > HPDcacheCfg.u.accessWords) begin : gen_req_data_width_assertion
        $fatal(1, "req data width shall be l.e. to cache access width");
    end
    if (HPDcacheCfg.u.clWords < HPDcacheCfg.u.accessWords) begin : gen_access_width_assertion
        $fatal(1, "cache access width shall be l.e. to cache-line width");
    end
    if (HPDcacheCfg.u.clWords <= 1) begin : gen_cacheline_words_assertion
        $fatal(1, "cacheline words shall be greater than 1");
    end
    if (HPDcacheCfg.clWidth < HPDcacheCfg.u.memDataWidth) begin : gen_cacheline_mem_data_assertion
        $fatal(1, "cacheline width shall be g.e. to memory interface data width");
    end
    if (HPDcacheCfg.u.memDataWidth < HPDcacheCfg.reqDataWidth) begin : gen_mem_data_width_assertion
        $fatal(1, "memory interface data width shall be g.e. to req data width");
    end
    if ((2**HPDcacheCfg.u.memIdWidth - 1) < (HPDcacheCfg.u.mshrWays * HPDcacheCfg.u.mshrSets))
    begin : gen_mem_id_mshr_width_assertion
        $fatal(1, "insufficient ID bits on the mem interface to transport reads");
    end
    if (HPDcacheCfg.u.wtEn && HPDcacheCfg.u.wbEn &&
        (2**(HPDcacheCfg.u.memIdWidth - 1) < HPDcacheCfg.u.wbufDirEntries))
    begin : gen_wt_wb_mem_id_wbuf_width_assertion
        $fatal(1, "insufficient ID bits on the mem interface to transport wbuf writes");
    end
    if (HPDcacheCfg.u.wtEn && !HPDcacheCfg.u.wbEn &&
        ((2**HPDcacheCfg.u.memIdWidth - 1) < HPDcacheCfg.u.wbufDirEntries))
    begin : gen_wt_mem_id_wbuf_width_assertion
        $fatal(1, "insufficient ID bits on the mem interface to transport wbuf writes");
    end
    if (HPDcacheCfg.u.wtEn && HPDcacheCfg.u.wbEn &&
        ((2**(HPDcacheCfg.u.memIdWidth - 1) - 1) < HPDcacheCfg.u.flushEntries))
    begin : gen_wt_wb_mem_id_flush_width_assertion
        $fatal(1, "insufficient ID bits on the mem interface to transport flush writes");
    end
    if (!HPDcacheCfg.u.wtEn && HPDcacheCfg.u.wbEn &&
        ((2**HPDcacheCfg.u.memIdWidth - 1) < HPDcacheCfg.u.flushEntries))
    begin : gen_wb_mem_id_flush_width_assertion
        $fatal(1, "insufficient ID bits on the mem interface to transport flush writes");
    end
    if (HPDcacheCfg.u.wtEn && (HPDcacheCfg.wbufDataWidth > HPDcacheCfg.u.memDataWidth))
    begin : gen_mem_data_wbuf_width_assertion
        $fatal(1, "write buffer data width shall be l.e. to mem interface data width");
    end
    if (HPDcacheCfg.u.wbEn &&
        (2**(HPDcacheCfg.u.memIdWidth - 1) < (HPDcacheCfg.u.flushEntries + 1)))
    begin : gen_mem_id_flush_width_assertion
        $fatal(1, "insufficient ID bits on the mem interface to transport flushes");
    end
    if (!HPDcacheCfg.u.lowLatency && HPDcacheCfg.u.eccEn) begin : gen_latency_and_ecc_assertion
        $fatal(1, "ECC only supported in lowLatency mode");
    end
    if (HPDcacheCfg.u.reqSrcIdWidth < $clog2(HPDcacheCfg.u.nRequesters)) begin : gen_sid_assertion
        $fatal(1, "insufficient Source ID bits to identify all requesters");
    end
`endif
    // }}}

endmodule
// vim: ts=4 : sts=4 : sw=4 : et : tw=100 : spell : spelllang=en : fdm=marker
