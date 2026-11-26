// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Author: Wolfgang Roenninger <wroennin@iis.ee.ethz.ch>
// Date:   06.06.2019

// VLSIT Modification History:
// 2026-11-15 - Quan Nguyen and Codex - VLSI Technology page:
//   Defer way-flush tag invalidation until successful AXI writeback completion.
//   Preserve dirty line state on a failed writeback; reset is required for recovery.

// 2026-11-15 - Quan Nguyen and Codex - VLSI Technology page:
//   Defer dirty replacement-tag writes until OKAY B; retain fault/descriptor
//   on writeback errors and export the fault through the cluster wrappers.

// 2026-11-15 - Quan Nguyen and Codex - VLSI Technology page:
//   Permit deferred commit during full-table lookup stalls; prevent hit-stream
//   starvation of pending writes. Verified full-table escape and pointer wrap.

/// This is the Tag storage for the LLC
/// There are four types of requests which can be made onto this unit.
/// `axi_llc_pkg::Bist`:
///   The pattern gets written or read to all macros, BIST resulte gets activated
/// `axi_llc_pkg::Flush`:
///   Perform a way targeted eviction, the tag is written in with all zero.
/// `axi_llc_pkg::Lookup`:
///   Perform a tag lookup in all non SPM ways, hit/eviction gets set if needed.
///   Writes the tag into the macro if needed.
`include "common_cells/registers.svh"
// 2026-11-15 - Quan Nguyen and Codex - VLSI Technology page:
// Initialize the SRAM index at its own width rather than the number-of-ways width.
// 2026-11-15 - Quan Nguyen and Codex - VLSI Technology page:
// DEC-038/A-02: commit refill tags only after complete successful R data;
// failed refills propagate error and invalidate the reserved allocation.
// 2026-11-15 - Quan Nguyen and Codex - VLSI Technology page:
// DEC-036/A-03 stress: backpressure every miss when the pending ring is full;
// clean misses reserve slots too and must not overwrite live entries.
module axi_llc_tag_store #(
  /// Static LLC configuration struct
  parameter axi_llc_pkg::llc_cfg_t Cfg = axi_llc_pkg::llc_cfg_t'{default: '0},
  /// Way indicator type
  /// EG: typedef logic [Cfg.SetAssociativity-1:0] way_ind_t;
  parameter type way_ind_t = logic,
  /// Type of the request payload made to the tag storage
  parameter type store_req_t = logic,
  /// Type of the response payload expected from the tag storage
  parameter type store_res_t = logic,
  /// Whether to print SRAM configs
  parameter bit  PrintSramCfg = 0
) (
  /// Clock, positive edge triggered
  input  logic       clk_i,
  /// Asynchronous reset, active low
  input  logic       rst_ni,
  /// Testmode enable
  input  logic       test_i,
  // Successful completion of the one outstanding way-flush descriptor.
  input logic flush_commit_i,
  input logic wb_commit_i,
  input logic wb_error_i,
  input logic refill_done_i,
  input logic refill_error_i,
  input way_ind_t refill_way_i,
  input logic [Cfg.IndexLength-1:0] refill_index_i,

  input logic maint_wb_done_i,
  input logic maint_wb_error_i,
  output logic maint_done_o,
  output logic maint_error_o,
  /// SPM lock signal input.
  ///
  /// For each way there is one signal. When high the way is configured as SPM. They are disabled
  /// for store requests.
  input  way_ind_t   spm_lock_i,
  /// Flushed indicator from `axi_llc_config`.
  ///
  /// This indicates that a way is flushed. No LOOKUP operations are performed on flushed ways.
  input  way_ind_t   flushed_i,
  /// Tag storage request payload.
  input  store_req_t req_i,
  /// Request to the tag storage is valid.
  input  logic       valid_i,
  /// Tag storage is ready for an request.
  output logic       ready_o,
  /// Tag storage response payload
  output store_res_t res_o,
  /// Tag stoarage response is valid.
  output logic       valid_o,
  /// Hit miss unit is ready to accept response.
  input  logic       ready_i,
  /// BIST result output. If one of these bits is high, when `bist_valid_o` is `1`. The
  /// corresponding tag storage SRAM macro failed the test.
  output way_ind_t   bist_res_o,
  /// BIST output is valid.
  output logic       bist_valid_o
);

  // typedef, because we use in this module many signals with the width of SetAssiciativity
  typedef logic [Cfg.IndexLength-1:0] index_t; // index type (equals the address for sram)
  typedef logic [Cfg.TagLength-1:0]   tag_t;

  // typedef to have consistent tag data (that what gets written into the sram)
  localparam int unsigned TagDataLen = Cfg.TagLength + 32'd2;
  /// Packed struct for the data stored in the memory macros.
  typedef struct packed {
    /// The tag stored is valid.
    logic val;
    /// The tag stored is dirty.
    logic dit;
    /// The stored tag itself.
    tag_t tag;
  } tag_data_t;

  // Binary indicator of the output way selected.
  localparam int unsigned BinIndicatorWidth = cf_math_pkg::idx_width(Cfg.SetAssociativity);
  typedef logic [BinIndicatorWidth-1:0] bin_ind_t;

  // The module can be busy or not.
  logic       busy_q,      busy_d,       switch_busy;

  // Save the request in state
  store_req_t req_q;
  logic       load_req;

  // Macro signals
  // Request for the macros
  way_ind_t   ram_req;
  // Write enable for the macros, active high. (Also functions as byte enable as there is one byte).
  way_ind_t   ram_we;
  // Index is the address.
  index_t     ram_index;
  // Write data for the macros.
  tag_data_t  ram_wdata;
  // Read data is valid
  way_ind_t   ram_rvalid,  ram_rvalid_q, ram_rvalid_d;
  logic       lock_rvalid;
  // Hit indication signals
  way_ind_t   hit, tag_val, tag_dit,     tag_equ;
  tag_data_t  [Cfg.SetAssociativity-1:0] stored_tag;
  // Binary representation of the selected output indicator
  bin_ind_t   bin_ind;
  // The pattern generation unit signals
  logic       gen_valid,   gen_ready;
  index_t     gen_index;
  tag_data_t  gen_pattern, bist_pattern;
  logic       gen_req,     gen_we;
  way_ind_t   bist_res;
  logic       bist_valid,  gen_eoc;
  // Evict box signals
  logic       evict_req,   evict_valid;
  // Response output into the spill register
  store_res_t res;
  logic       res_valid,   res_ready;

  logic flush_wait_q;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) flush_wait_q <= 1'b0;
    else begin
      if (busy_q && req_q.mode == axi_llc_pkg::Flush && res_valid && res_ready)
        flush_wait_q <= 1'b1;
      if (flush_commit_i) flush_wait_q <= 1'b0;
    end
  end

  // Evictions use one AXI ID (axi_llc_pkg::AxReqId), so B responses and
  // pending replacement entries have the same order. Keep each set locked
  // until its deferred SRAM update completes; unrelated sets remain available.
  localparam int PendingDepth = axi_llc_pkg::EvictFifoDepth;
  localparam int PendingPtrWidth = $clog2(PendingDepth);
  logic [PendingDepth-1:0] pending_valid_q, pending_done_q;
  logic [PendingDepth-1:0] pending_wb_acked_q, pending_wb_ok_q, pending_error_q;
  logic wb_match_valid;
  logic [PendingPtrWidth-1:0] wb_match_slot;
  index_t pending_index_q [PendingDepth];
  way_ind_t pending_way_q [PendingDepth];
  tag_data_t pending_tag_q [PendingDepth];
  logic [PendingPtrWidth-1:0] pending_write_q, pending_read_q;
  logic pending_full, request_blocked, pending_push, pending_pop;
  assign pending_full = pending_valid_q[pending_write_q];
  assign pending_push = busy_q && req_q.mode == axi_llc_pkg::Lookup
                        && res_valid && res_ready && !res.hit;
  // A full-table miss must not prevent the SRAM commit that frees its slot.
  // During this stall there is no outgoing lookup response or new SRAM read.
  assign pending_pop = (!busy_q || (req_q.mode == axi_llc_pkg::Lookup && pending_full))
                       && !maint_finish && pending_valid_q[pending_read_q]
                       && pending_done_q[pending_read_q] && pending_wb_ok_q[pending_read_q];
  always_comb begin
    request_blocked = 1'b0;
    for (int k=0; k<PendingDepth; k++)
      if (pending_valid_q[k] && req_i.index == pending_index_q[k])
        request_blocked = 1'b1;
    if (maint_pending_q && req_i.index == maint_index_q)
      request_blocked = 1'b1;
    if (maint_pending_q && maint_result_q) request_blocked = 1'b1;
    if (req_i.mode == axi_llc_pkg::Bist && ((|pending_valid_q) || maint_pending_q))
      request_blocked = 1'b1;
    // Break a continuous hit/look-ahead stream to service a completed tag write.
    if (pending_valid_q[pending_read_q] && pending_done_q[pending_read_q] && pending_wb_ok_q[pending_read_q])
      request_blocked = 1'b1;
  end
  // B completions are ordered, while clean misses consume no B response.
  // Select the oldest entry that actually needs an eviction acknowledgement.
  always_comb begin
    wb_match_valid = 1'b0;
    wb_match_slot = '0;
    for (int k=0; k<PendingDepth; k++) begin
      if (pending_valid_q[(int'(pending_read_q)+k)%PendingDepth] &&
          !pending_wb_acked_q[(int'(pending_read_q)+k)%PendingDepth] && !wb_match_valid) begin
        wb_match_valid = 1'b1;
        wb_match_slot = PendingPtrWidth'((int'(pending_read_q)+k)%PendingDepth);
      end
    end
  end
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      pending_valid_q <= '0;
      pending_done_q <= '0;
      pending_write_q <= '0;
      pending_wb_acked_q <= '0;
      pending_wb_ok_q <= '0;
      pending_error_q <= '0;
      pending_read_q <= '0;
      for (int k=0; k<PendingDepth; k++) begin
        pending_index_q[k] <= '0;
        pending_way_q[k] <= '0;
        pending_tag_q[k] <= '0;
      end
    end else begin
      if (pending_push) begin
        pending_valid_q[pending_write_q] <= 1'b1;
        pending_done_q[pending_write_q] <= 1'b0;
        pending_wb_acked_q[pending_write_q] <= !res.evict;
        pending_wb_ok_q[pending_write_q] <= !res.evict;
        pending_error_q[pending_write_q] <= 1'b0;
        pending_index_q[pending_write_q] <= req_q.index;
        pending_way_q[pending_write_q] <= res.indicator;
        pending_tag_q[pending_write_q] <= tag_data_t'{val:1'b1,dit:req_q.dirty,tag:req_q.tag};
        pending_write_q <= (pending_write_q == PendingPtrWidth'(PendingDepth-1))
                           ? '0 : pending_write_q + 1'b1;
      end
      if ((wb_commit_i || wb_error_i) && wb_match_valid) begin
        pending_wb_acked_q[wb_match_slot] <= 1'b1;
        pending_wb_ok_q[wb_match_slot] <= wb_commit_i;
      end
      if (refill_done_i) begin
        for (int k=0; k<PendingDepth; k++) begin
          if (pending_valid_q[k] && (pending_index_q[k] == refill_index_i) &&
              (pending_way_q[k] == refill_way_i)) begin
            pending_done_q[k] <= 1'b1;
            pending_error_q[k] <= refill_error_i;
          end
        end
      end
      if (pending_pop) begin
        pending_valid_q[pending_read_q] <= 1'b0;
        pending_done_q[pending_read_q] <= 1'b0;
        pending_read_q <= (pending_read_q == PendingPtrWidth'(PendingDepth-1))
                          ? '0 : pending_read_q + 1'b1;
      end
    end
  end

  logic maint_pending_q, maint_result_q, maint_error_q;
  index_t maint_index_q;
  way_ind_t maint_way_q;
  tag_data_t maint_tag_q;
  logic [1:0] maint_op_q;
  logic maint_finish;
  assign maint_finish = maint_pending_q && maint_result_q && !busy_q;
  assign maint_done_o = maint_finish;
  assign maint_error_o = maint_error_q;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      maint_pending_q <= 1'b0;
      maint_result_q <= 1'b0;
      maint_error_q <= 1'b0;
      maint_index_q <= '0;
      maint_way_q <= '0;
      maint_tag_q <= '0;
      maint_op_q <= '0;
    end else begin
      if (busy_q && req_q.mode == axi_llc_pkg::Maintain && res_valid && res_ready) begin
        maint_pending_q <= 1'b1;
        maint_result_q <= 1'b0;
        maint_error_q <= 1'b0;
        maint_index_q <= req_q.index;
        maint_way_q <= res.indicator;
        maint_tag_q <= tag_data_t'{val:1'b1,dit:1'b0,tag:req_q.tag};
        maint_op_q <= req_q.maint_op;
      end
      if (maint_pending_q && maint_wb_done_i) begin
        maint_result_q <= 1'b1;
        maint_error_q <= maint_wb_error_i;
      end
      if (maint_finish) begin
        maint_pending_q <= 1'b0;
        maint_result_q <= 1'b0;
      end
    end
  end

  // macro control
  always_comb begin : proc_macro_ctrl
    // default assignments
    // FFs
    switch_busy  = 1'b0;
    ready_o      = 1'b0;
    load_req     = 1'b0;
    res_valid    = 1'b0;
    ram_req      = way_ind_t'(0);
    ram_we       = way_ind_t'(0);
    ram_index    = '0;
    ram_wdata    = tag_data_t'{default: '0};
    // Evict box
    evict_req    = 1'b0;
    // generation request
    gen_valid    = 1'b0;
    bist_valid   = 1'b0;

    if (busy_q) begin
      // We are busy so there are active operations going on, we are not ready.
      unique case (req_q.mode)
          axi_llc_pkg::Bist: begin
            // During BIST connect the request to the tag pattern generator.
            ram_req    = {Cfg.SetAssociativity{gen_req}};
            ram_we     = {Cfg.SetAssociativity{gen_we}};
            ram_index  = gen_index;
            ram_wdata  = gen_pattern;
            bist_valid = |ram_rvalid;
            // If BIST finished, go to idle.
            if (gen_eoc) begin
              switch_busy = 1'b1;
            end
          end
          axi_llc_pkg::Lookup: begin
            // Wait for valid macro output
            if ((|ram_rvalid) | (|ram_rvalid_q)) begin
              // We are valid on hit.
              if (|hit) begin
                res_valid = 1'b1;
              end else begin
                evict_req = 1'b1;
                res_valid = evict_valid;
              end
            end

            // Every miss reserves a pending entry, including a clean/invalid victim.
            // Never overwrite a live entry when the allocation ring is full.
            if (!res.hit && pending_full) res_valid = 1'b0;
            // Do we have to write back something?
            if (res_valid && res_ready) begin
              if (res.hit) begin
                // This is a hit
                if (req_q.dirty && !tag_dit[bin_ind]) begin
                  // Do we have to store a dirty as the hit was not dirty until now?
                  ram_req   = res.indicator;
                  ram_we    = res.indicator;
                  ram_index = req_q.index;
                  ram_wdata = tag_data_t'{
                                val: 1'b1,
                                dit: 1'b1,
                                tag: req_q.tag
                              };
                  switch_busy = 1'b1;
                end else begin
                  // Noting to write back, do we have a new LOOKUP request?
                  if (valid_i && (req_i.mode == axi_llc_pkg::Lookup)) begin
                    ready_o = 1'b1;
                    // Do the lookup on the requested macros
                    ram_req     = req_i.indicator;
                    ram_index   = req_i.index;
                    load_req    = 1'b1;
                  end else begin
                    // Go back to IDLE if no Lookup
                    switch_busy = 1'b1;
                  end
                end
              end else begin
                // This is a miss!
                // Reserve the set in the pending table. Refill completion
                // installs the new tag or invalidates the failed allocation.
                switch_busy = 1'b1;
              end
            end
          end
          axi_llc_pkg::Maintain: begin
            if ((|ram_rvalid) | (|ram_rvalid_q)) res_valid = !maint_pending_q;
            if (res_valid && res_ready) switch_busy = 1'b1;
          end
          axi_llc_pkg::Flush: begin
            if ((|ram_rvalid) | (|ram_rvalid_q)) begin
              // We are valid when the read output of the macros is valid!
              res_valid = 1'b1;
            end

            // The response only launches the eviction; it is not writeback completion.
            // Keep tag/dirty/data intact and retain this request until the W master
            // reports a successful B response (or a clean line needs no writeback).
            if (flush_wait_q) res_valid = 1'b0;
            if (flush_wait_q && flush_commit_i) begin
              ram_req     = req_q.indicator;
              ram_we      = req_q.indicator;
              ram_index   = req_q.index;
              ram_wdata   = tag_data_t'{default: '0};
              switch_busy = 1'b1;
            end
          end
        default : /* default */;
      endcase
    end else begin
      // we are not busy, so we are ready to get a new request.
      ready_o = 1'b1;

      if (valid_i) begin
        // There is a request to the tag store.
        switch_busy = 1'b1;
        load_req    = 1'b1;

        // Make the requests to the tag macros.
        unique case (req_i.mode)
          axi_llc_pkg::Bist: begin
            gen_valid   = 1'b1;
            ready_o     = gen_ready;
            // Only switch the state, if the request is valid
            switch_busy = gen_ready;
          end
          axi_llc_pkg::Lookup, axi_llc_pkg::Flush, axi_llc_pkg::Maintain: begin
            // Do the lookup on the requested macros
            ram_req     = req_i.indicator;
            ram_index   = req_i.index;
            load_req    = 1'b1;
            switch_busy = 1'b1;
          end
          default : /* do nothing */;
        endcase
      end
    end
    // Cancel an attempted look-ahead/new request to a reserved set. A current
    // lookup response can still leave the unit and return it to idle.
    if (load_req && request_blocked) begin
      ready_o = 1'b0;
      load_req = 1'b0;
      ram_req = '0;
      ram_we = '0;
      gen_valid = 1'b0;
      switch_busy = busy_q;
    end
    // Deferred commits take one SRAM cycle between lookups. The pending entry
    // remains valid until that edge, preventing a same-set read/write collision.
    if (maint_finish) begin
      ready_o = 1'b0;
      load_req = 1'b0;
      switch_busy = 1'b0;
      gen_valid = 1'b0;
      ram_req = maint_way_q;
      ram_we = maint_error_q ? way_ind_t'(0) : maint_way_q;
      ram_index = maint_index_q;
      ram_wdata = (maint_op_q == 2'd0) ? maint_tag_q : tag_data_t'('0);
    end
    if (pending_pop) begin
      ready_o = 1'b0;
      load_req = 1'b0;
      switch_busy = 1'b0;
      ram_req = pending_way_q[pending_read_q];
      ram_we = pending_way_q[pending_read_q];
      ram_index = pending_index_q[pending_read_q];
      ram_wdata = pending_tag_q[pending_read_q];
      ram_wdata.val = !pending_error_q[pending_read_q];
      ram_wdata.dit = pending_tag_q[pending_read_q].dit && !pending_error_q[pending_read_q];
      gen_valid = 1'b0;
    end
  end

  `FFLARN(req_q, req_i, load_req, store_req_t'(0), clk_i, rst_ni)
  `FFLARN(busy_q, busy_d, switch_busy, 1'b0, clk_i, rst_ni)
  assign busy_d = ~busy_q;
  `FFLARN(ram_rvalid_q, ram_rvalid_d, lock_rvalid, way_ind_t'(0), clk_i, rst_ni)
  assign ram_rvalid_d = (res_valid & res_ready) ? way_ind_t'(0) : ram_rvalid;
  assign lock_rvalid  = (res_valid & res_ready) | (|ram_rvalid);

  // generate for each Way one tag storage macro
  for (genvar i = 0; unsigned'(i) < Cfg.SetAssociativity; i++) begin : gen_tag_macros
    tag_data_t ram_rdata;    // read data from the sram
    tag_data_t ram_compared; // comparison result of tags

    tc_sram #(
      .NumWords    ( Cfg.NumLines                 ),
      .DataWidth   ( TagDataLen                   ),
      .ByteWidth   ( TagDataLen                   ),
      .NumPorts    ( 32'd1                        ),
      .Latency     ( axi_llc_pkg::TagMacroLatency ),
      .SimInit     ( "none"                       ),
      .PrintSimCfg ( PrintSramCfg                 )
    ) i_tag_store (
      .clk_i,
      .rst_ni,
      .req_i   ( ram_req[i] ),
      .we_i    ( ram_we[i]  ),
      .addr_i  ( ram_index  ),
      .wdata_i ( ram_wdata  ),
      .be_i    ( ram_we[i]  ),
      .rdata_o ( ram_rdata  )
    );

    // shift register for a validtoken for read data, this pulses once for each read request
    shift_reg #(
      .dtype ( logic                        ),
      .Depth ( axi_llc_pkg::TagMacroLatency )
    ) i_shift_reg_rvalid (
      .clk_i,
      .rst_ni,
      .d_i    ( ram_req[i] & ~ram_we[i] ),
      .d_o    ( ram_rvalid[i]           )
    );

    // comparator (XNOR)
    tag_t tag_compare;
    logic i_tag_equ;

    assign tag_compare  = (req_q.mode == axi_llc_pkg::Bist) ? bist_pattern.tag : req_q.tag;
    assign i_tag_equ    = &(ram_rdata.tag ~^ tag_compare);
    assign tag_equ[i]   = i_tag_equ;
    assign tag_val[i]   = ram_rdata.val;
    assign tag_dit[i]   = ram_rdata.dit;

    assign hit[i]      = req_q.indicator[i] & tag_val[i] & tag_equ[i];
    assign bist_res[i] = (ram_rdata.val == bist_pattern.val) &
                         (ram_rdata.dit == bist_pattern.dit) &
                         i_tag_equ;

    // assignment to wide output signal that goes to the tag output mux
    assign stored_tag[i] = ram_rdata;
  end

  axi_llc_tag_pattern_gen #(
    .Cfg       ( Cfg        ),
    .pattern_t ( tag_data_t ),
    .way_ind_t ( way_ind_t  ),
    .index_t   ( index_t    )
  ) i_tag_pattern_gen (
    .clk_i,
    .rst_ni,
    .valid_i          ( gen_valid   ),
    .ready_o          ( gen_ready   ),
    .index_o          ( gen_index   ),
    .pattern_o        ( gen_pattern ),
    .req_o            ( gen_req     ),
    .we_o             ( gen_we      ),
    .bist_res_i       ( bist_res    ),
    .bist_res_valid_i ( bist_valid  ),
    .bist_res_o       ( bist_res_o  ),
    .eoc_o            ( gen_eoc     )
  );
  assign bist_valid_o = gen_eoc;

  // This shift register holds the pattern for comparison of the bist.
  shift_reg #(
    .dtype ( tag_data_t                   ),
    .Depth ( axi_llc_pkg::TagMacroLatency )
  ) i_shift_reg_bist (
    .clk_i,
    .rst_ni,
    .d_i    ( gen_pattern  ),
    .d_o    ( bist_pattern )
  );

  way_ind_t evict_way_ind;
  logic     evict_flag;

  axi_llc_evict_box #(
    .Cfg       ( Cfg       ),
    .way_ind_t ( way_ind_t )
  ) i_evict_box (
    .clk_i,
    .rst_ni,
    .req_i       ( evict_req     ),
    .tag_valid_i ( tag_val       ),
    .tag_dirty_i ( tag_dit       ),
    .spm_lock_i  ( spm_lock_i    ),
    .way_ind_o   ( evict_way_ind ),
    .evict_o     ( evict_flag    ),
    .valid_o     ( evict_valid   )
  );

  onehot_to_bin #(
    .ONEHOT_WIDTH ( Cfg.SetAssociativity )
  ) i_onehot_to_bin (
    .onehot ( res.indicator ),
    .bin    ( bin_ind       )
  );

  // Silence output when not in a mode where it is required.
  always_comb begin
    // Default assignment
    res = store_res_t'{default: '0};
    if (busy_q) begin
      unique case (req_q.mode)
        axi_llc_pkg::Lookup: begin
          res = store_res_t'{
            indicator: (|hit) ? hit       : evict_way_ind,
            hit:       (|hit) ? 1'b1      : 1'b0,
            evict:     (|hit) ? 1'b0      : evict_flag,
            evict_tag: (|hit) ? tag_t'(0) : stored_tag[bin_ind].tag,
            default:   '0
          };
        end
        axi_llc_pkg::Maintain: begin
          res = store_res_t'{indicator:hit, hit:|hit,
            evict:(|hit) && stored_tag[bin_ind].dit && req_q.maint_op != 2'd2,
            evict_tag:req_q.tag, default:'0};
        end
        axi_llc_pkg::Flush: begin
          res = store_res_t'{
            indicator: req_q.indicator,
            hit:       1'b0,
            evict:     stored_tag[bin_ind].val & stored_tag[bin_ind].dit,
            evict_tag: stored_tag[bin_ind].tag,
            default:   '0
          };
        end
        default : /* not used */;
      endcase
    end
  end

  // Output spill register for breaking timing path
  spill_register #(
    .T       ( store_res_t                 ),
    .Bypass  ( !axi_llc_pkg::SpillTagStore )
  ) i_spill_register (
    .clk_i,
    .rst_ni,
    .valid_i ( res_valid ),
    .ready_o ( res_ready ),
    .data_i  ( res       ),
    .valid_o ( valid_o   ),
    .ready_i ( ready_i   ),
    .data_o  ( res_o     )
  );

  // Assertions
  // pragma translate_off
  `ifndef VERILATOR
  onehot_hit:  assert property ( @(posedge clk_i) disable iff (!rst_ni)
      (req_q.mode inside {axi_llc_pkg::Lookup, axi_llc_pkg::Flush}) |-> $onehot0(hit)) else
      $fatal(1, "[hit_ind] More than two bit set in the one-hot signal, multiple hits!");
  onehot_ind:  assert property ( @(posedge clk_i) disable iff (!rst_ni)
      (req_q.mode inside {axi_llc_pkg::Lookup, axi_llc_pkg::Flush}) |-> $onehot0(res.indicator)) else
      $fatal(1, "[way_ind_o] More than two bit set in the one-hot signal, multiple hits!");
  // trigger warning if output valid gets deasserted without ready
  check_valid: assert property ( @(posedge clk_i) disable iff (!rst_ni)
      (res_valid && !res_ready) |=> res_valid) else
      $warning("Valid was deasserted, even when no ready was set.");
  check_all_spm: assert property ( @(posedge clk_i) disable iff (~rst_ni)
      ((flushed_i == {Cfg.SetAssociativity{1'b1}}) |-> (evict_req == 1'b0))) else
      $fatal(1, "Should not have a request for the evict box, if all ways are flushed!");
  `endif
  // pragma translate_on
endmodule
