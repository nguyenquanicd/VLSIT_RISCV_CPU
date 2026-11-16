/*
 *  Copyright 2023,2024 Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA)
 *  Copyright 2025 Univ. Grenoble Alpes, Inria, TIMA Laboratory
 *
 *  SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
 */
/*
 *  Authors       : Cesar Fuguet
 *  Creation Date : April, 2024
 *  Description   : HPDcache Wrapper for Code Linting Check
 *  History       :
 */
// 2026-11-14: Quan Nguyen and Codex - VLSI Technology page:
// Derived typed flush-only lint boundary; upstream license preserved.
`include "hpdcache_typedef.svh"
module hpdcache_flush_lint import hpdcache_pkg::*; #(
localparam hpdcache_pkg::hpdcache_user_cfg_t HPDcacheUserCfg = '{
      nRequesters: 1,
      paWidth: 56,
      wordWidth: 64,
      sets: 256,
      ways: 8,
      clWords: 2,
      reqWords: 1,
      reqTransIdWidth: 3,
      reqSrcIdWidth: 3,
      victimSel: hpdcache_pkg::HPDCACHE_VICTIM_RANDOM,
      dataWaysPerRamWord: 2,
      dataSetsPerRam: 64,
      dataRamByteEnable: 1'b1,
      accessWords: 1,
      mshrSets: 32,
      mshrWays: 2,
      mshrWaysPerRamWord: 2,
      mshrSetsPerRam: 32,
      mshrRamByteEnable: 1'b1,
      mshrUseRegbank: 1,
      cbufEntries: 4,
      refillCoreRspFeedthrough: 1'b1,
      refillFifoDepth: 2,
      wbufDirEntries: 16,
      wbufDataEntries: 8,
      wbufWords: 4,
      wbufTimecntWidth: 3,
      rtabEntries: 4,
      flushEntries: 4,
      flushFifoDepth: 2,
      memAddrWidth: 56,
      memIdWidth: 4,
      memDataWidth: 64,
      wtEn: 1'b1,
      wbEn: 1'b1,
      lowLatency: 1'b1,
      eccEn: 1'b1,
      eccScrubberEn: 1'b1
  },
  localparam hpdcache_cfg_t HPDcacheCfg = hpdcacheBuildConfig(HPDcacheUserCfg),
  localparam type hpdcache_nline_t = logic [HPDcacheCfg.nlineWidth-1:0],
  localparam type hpdcache_set_t = logic [HPDcacheCfg.setWidth-1:0],
  localparam type hpdcache_word_t = logic [HPDcacheCfg.clWordIdxWidth-1:0],
  localparam type hpdcache_way_vector_t = logic [HPDcacheCfg.u.ways-1:0],
  localparam type hpdcache_access_data_t = logic [HPDcacheCfg.accessWidth-1:0],
  localparam type hpdcache_mem_id_t = logic [HPDcacheCfg.u.memIdWidth-1:0],
  localparam type hpdcache_mem_data_t = logic [HPDcacheCfg.u.memDataWidth-1:0],
  localparam type mem_addr_t = logic [HPDcacheCfg.u.memAddrWidth-1:0],
  localparam type mem_be_t = logic [HPDcacheCfg.u.memDataWidth/8-1:0],
  localparam type hpdcache_mem_req_t = `HPDCACHE_DECL_MEM_REQ_T(mem_addr_t, hpdcache_mem_id_t),
  localparam type hpdcache_mem_req_w_t = `HPDCACHE_DECL_MEM_REQ_W_T(hpdcache_mem_data_t, mem_be_t),
  localparam type hpdcache_mem_resp_w_t = `HPDCACHE_DECL_MEM_RESP_W_T(hpdcache_mem_id_t)
)
(
    input  logic                  clk_i,
    input  logic                  rst_ni,

    //      Global control signals
    //      {{{
    output logic                  flush_empty_o,
    output logic                  flush_full_o,
    output logic                  flush_busy_o,
    //      }}}

    //      CHECK interface
    //      {{{
    input  hpdcache_nline_t       flush_check_nline_i,
    output logic                  flush_check_hit_o,
    //      }}}

    //      ALLOC interface
    //      {{{
    input  logic                  flush_alloc_i,
    output logic                  flush_alloc_ready_o,
    input  hpdcache_nline_t       flush_alloc_nline_i,
    input  hpdcache_way_vector_t  flush_alloc_way_i,
    // Origin: 00 native eviction, 01 CMO, 10 coherence probe; 11 reserved.
    input  logic [1:0]            flush_alloc_origin_i,
    //      }}}

    //      CACHE DATA interface
    //      {{{
    output logic                  flush_data_read_o,
    output hpdcache_set_t         flush_data_read_set_o,
    output hpdcache_word_t        flush_data_read_word_o,
    output hpdcache_way_vector_t  flush_data_read_way_o,
    input  hpdcache_access_data_t flush_data_read_data_i,
    //      }}}

    //      ACK monitoring interface
    //      {{{
    output logic                  flush_ack_o,
    output hpdcache_nline_t       flush_ack_nline_o,
    output logic [1:0]            flush_ack_origin_o,
    output logic                  flush_ack_error_o,
    output logic                  flush_rsp_invalid_o,
    //      }}}

    //      MEMORY interface
    //      {{{
    input  logic                  mem_req_write_ready_i,
    output logic                  mem_req_write_valid_o,
    output hpdcache_mem_req_t     mem_req_write_o,

    input  logic                  mem_req_write_data_ready_i,
    output logic                  mem_req_write_data_valid_o,
    output hpdcache_mem_req_w_t   mem_req_write_data_o,

    output logic                  mem_resp_write_ready_o,
    input  logic                  mem_resp_write_valid_i,
    input  hpdcache_mem_resp_w_t  mem_resp_write_i
    //      }}}
);
  hpdcache_flush #(
    .HPDcacheCfg(HPDcacheCfg),
    .hpdcache_nline_t(hpdcache_nline_t),
    .hpdcache_set_t(hpdcache_set_t),
    .hpdcache_word_t(hpdcache_word_t),
    .hpdcache_way_vector_t(hpdcache_way_vector_t),
    .hpdcache_access_data_t(hpdcache_access_data_t),
    .hpdcache_mem_id_t(hpdcache_mem_id_t),
    .hpdcache_mem_data_t(hpdcache_mem_data_t),
    .hpdcache_mem_req_t(hpdcache_mem_req_t),
    .hpdcache_mem_req_w_t(hpdcache_mem_req_w_t),
    .hpdcache_mem_resp_w_t(hpdcache_mem_resp_w_t)
  ) u_flush (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .flush_empty_o(flush_empty_o),
    .flush_full_o(flush_full_o),
    .flush_busy_o(flush_busy_o),
    .flush_check_nline_i(flush_check_nline_i),
    .flush_check_hit_o(flush_check_hit_o),
    .flush_alloc_i(flush_alloc_i),
    .flush_alloc_ready_o(flush_alloc_ready_o),
    .flush_alloc_nline_i(flush_alloc_nline_i),
    .flush_alloc_way_i(flush_alloc_way_i),
    .flush_alloc_origin_i(flush_alloc_origin_i),
    .flush_data_read_o(flush_data_read_o),
    .flush_data_read_set_o(flush_data_read_set_o),
    .flush_data_read_word_o(flush_data_read_word_o),
    .flush_data_read_way_o(flush_data_read_way_o),
    .flush_data_read_data_i(flush_data_read_data_i),
    .flush_ack_o(flush_ack_o),
    .flush_ack_nline_o(flush_ack_nline_o),
    .flush_ack_origin_o(flush_ack_origin_o),
    .flush_ack_error_o(flush_ack_error_o),
    .flush_rsp_invalid_o(flush_rsp_invalid_o),
    .mem_req_write_ready_i(mem_req_write_ready_i),
    .mem_req_write_valid_o(mem_req_write_valid_o),
    .mem_req_write_o(mem_req_write_o),
    .mem_req_write_data_ready_i(mem_req_write_data_ready_i),
    .mem_req_write_data_valid_o(mem_req_write_data_valid_o),
    .mem_req_write_data_o(mem_req_write_data_o),
    .mem_resp_write_ready_o(mem_resp_write_ready_o),
    .mem_resp_write_valid_i(mem_resp_write_valid_i),
    .mem_resp_write_i(mem_resp_write_i)
  );
endmodule
