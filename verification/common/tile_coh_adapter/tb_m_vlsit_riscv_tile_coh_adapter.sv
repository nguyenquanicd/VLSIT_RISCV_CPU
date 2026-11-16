`timescale 1ns/1ps

module tb_m_vlsit_riscv_tile_coh_adapter;
  localparam int unsigned PARA_COH_TXN_NUM = 8;
  localparam int unsigned LPARA_COH_TAG_W = $clog2(PARA_COH_TXN_NUM);
  localparam logic [1:0] LPARA_PHASE_PREPARE = 2'd0;
  localparam logic [1:0] LPARA_PHASE_COMMIT = 2'd1;
  localparam logic [1:0] LPARA_PHASE_ABORT = 2'd2;

  logic i_clk_cluster;
  logic i_rst_n_cluster;
  logic i_cache_access_valid;
  logic [51:0] i_cache_access_pa_line;
  logic o_cache_access_locked;
  logic i_cache_victim_valid;
  logic [51:0] i_cache_victim_pa_line;
  logic o_cache_victim_locked;
  logic [PARA_COH_TXN_NUM-1:0] o_cache_line_lock_valid;
  logic [PARA_COH_TXN_NUM-1:0][51:0] o_cache_line_lock_pa_line;
  logic o_lock_diag_event;
  logic o_cache_probe_query_valid;
  logic [51:0] o_cache_probe_query_nline;
  logic i_cache_probe_line_busy;
  logic i_cache_req_valid;
  logic o_cache_req_ready;
  logic [2:0] i_cache_req_id;
  logic [51:0] i_cache_req_pa_line;
  logic [1:0] i_cache_req_kind;
  logic o_req_valid;
  logic i_req_ready;
  logic [2:0] o_req_id;
  logic [51:0] o_req_pa_line;
  logic [1:0] o_req_kind;
  logic i_gnt_valid;
  logic o_gnt_ready;
  logic [2:0] i_gnt_id;
  logic [51:0] i_gnt_pa_line;
  logic [1:0] i_gnt_state;
  logic i_gnt_err;
  logic o_cache_gnt_valid;
  logic i_cache_gnt_ready;
  logic [2:0] o_cache_gnt_id;
  logic [51:0] o_cache_gnt_pa_line;
  logic [1:0] o_cache_gnt_state;
  logic o_cache_gnt_err;
  logic i_probe_req_valid;
  logic o_probe_req_ready;
  logic [LPARA_COH_TAG_W-1:0] i_probe_req_tag;
  logic [51:0] i_probe_req_pa_line;
  logic [1:0] i_probe_req_phase;
  logic [1:0] i_probe_req_target_state;
  logic i_probe_req_wback_en;
  logic o_cache_probe_req_valid;
  logic i_cache_probe_req_ready;
  logic [LPARA_COH_TAG_W-1:0] o_cache_probe_req_tag;
  logic [51:0] o_cache_probe_req_pa_line;
  logic [1:0] o_cache_probe_req_phase;
  logic [1:0] o_cache_probe_req_target_state;
  logic o_cache_probe_req_wback_en;
  logic i_cache_probe_rsp_valid;
  logic o_cache_probe_rsp_ready;
  logic [LPARA_COH_TAG_W-1:0] i_cache_probe_rsp_tag;
  logic [51:0] i_cache_probe_rsp_pa_line;
  logic [1:0] i_cache_probe_rsp_phase;
  logic [1:0] i_cache_probe_rsp_state;
  logic i_cache_probe_rsp_err;
  logic i_cache_probe_rsp_wback_done;
  logic o_probe_rsp_valid;
  logic i_probe_rsp_ready;
  logic [LPARA_COH_TAG_W-1:0] o_probe_rsp_tag;
  logic [51:0] o_probe_rsp_pa_line;
  logic [1:0] o_probe_rsp_phase;
  logic [1:0] o_probe_rsp_state;
  logic o_probe_rsp_err;
  logic o_probe_rsp_wback_done;

  m_vlsit_riscv_tile_coh_adapter #(
    .PARA_COH_TXN_NUM(32'(PARA_COH_TXN_NUM))
  ) u_vlsit_riscv_tile_coh_adapter (
    .i_clk_cluster(i_clk_cluster),
    .i_rst_n_cluster(i_rst_n_cluster),
    .i_cache_access_valid(i_cache_access_valid),
    .i_cache_access_pa_line(i_cache_access_pa_line),
    .o_cache_access_locked(o_cache_access_locked),
    .i_cache_victim_valid(i_cache_victim_valid),
    .i_cache_victim_pa_line(i_cache_victim_pa_line),
    .o_cache_victim_locked(o_cache_victim_locked),
    .o_cache_line_lock_valid(o_cache_line_lock_valid),
    .o_cache_line_lock_pa_line(o_cache_line_lock_pa_line),
    .o_lock_diag_event(o_lock_diag_event),
    .o_cache_probe_query_valid(o_cache_probe_query_valid),
    .o_cache_probe_query_nline(o_cache_probe_query_nline),
    .i_cache_probe_line_busy(i_cache_probe_line_busy),
    .i_cache_req_valid(i_cache_req_valid),
    .o_cache_req_ready(o_cache_req_ready),
    .i_cache_req_id(i_cache_req_id),
    .i_cache_req_pa_line(i_cache_req_pa_line),
    .i_cache_req_kind(i_cache_req_kind),
    .o_req_valid(o_req_valid),
    .i_req_ready(i_req_ready),
    .o_req_id(o_req_id),
    .o_req_pa_line(o_req_pa_line),
    .o_req_kind(o_req_kind),
    .i_gnt_valid(i_gnt_valid),
    .o_gnt_ready(o_gnt_ready),
    .i_gnt_id(i_gnt_id),
    .i_gnt_pa_line(i_gnt_pa_line),
    .i_gnt_state(i_gnt_state),
    .i_gnt_err(i_gnt_err),
    .o_cache_gnt_valid(o_cache_gnt_valid),
    .i_cache_gnt_ready(i_cache_gnt_ready),
    .o_cache_gnt_id(o_cache_gnt_id),
    .o_cache_gnt_pa_line(o_cache_gnt_pa_line),
    .o_cache_gnt_state(o_cache_gnt_state),
    .o_cache_gnt_err(o_cache_gnt_err),
    .i_probe_req_valid(i_probe_req_valid),
    .o_probe_req_ready(o_probe_req_ready),
    .i_probe_req_tag(i_probe_req_tag),
    .i_probe_req_pa_line(i_probe_req_pa_line),
    .i_probe_req_phase(i_probe_req_phase),
    .i_probe_req_target_state(i_probe_req_target_state),
    .i_probe_req_wback_en(i_probe_req_wback_en),
    .o_cache_probe_req_valid(o_cache_probe_req_valid),
    .i_cache_probe_req_ready(i_cache_probe_req_ready),
    .o_cache_probe_req_tag(o_cache_probe_req_tag),
    .o_cache_probe_req_pa_line(o_cache_probe_req_pa_line),
    .o_cache_probe_req_phase(o_cache_probe_req_phase),
    .o_cache_probe_req_target_state(o_cache_probe_req_target_state),
    .o_cache_probe_req_wback_en(o_cache_probe_req_wback_en),
    .i_cache_probe_rsp_valid(i_cache_probe_rsp_valid),
    .o_cache_probe_rsp_ready(o_cache_probe_rsp_ready),
    .i_cache_probe_rsp_tag(i_cache_probe_rsp_tag),
    .i_cache_probe_rsp_pa_line(i_cache_probe_rsp_pa_line),
    .i_cache_probe_rsp_phase(i_cache_probe_rsp_phase),
    .i_cache_probe_rsp_state(i_cache_probe_rsp_state),
    .i_cache_probe_rsp_err(i_cache_probe_rsp_err),
    .i_cache_probe_rsp_wback_done(i_cache_probe_rsp_wback_done),
    .o_probe_rsp_valid(o_probe_rsp_valid),
    .i_probe_rsp_ready(i_probe_rsp_ready),
    .o_probe_rsp_tag(o_probe_rsp_tag),
    .o_probe_rsp_pa_line(o_probe_rsp_pa_line),
    .o_probe_rsp_phase(o_probe_rsp_phase),
    .o_probe_rsp_state(o_probe_rsp_state),
    .o_probe_rsp_err(o_probe_rsp_err),
    .o_probe_rsp_wback_done(o_probe_rsp_wback_done)
  );

  initial i_clk_cluster = 1'b0;
  always #5 i_clk_cluster = ~i_clk_cluster;

  task automatic check(input logic condition, input string message);
    if (condition !== 1'b1) begin
      $error("FAIL: %s at %0t", message, $time);
      $fatal(1);
    end
  endtask

  task automatic cycle;
    @(posedge i_clk_cluster);
    #1;
  endtask

  task automatic reset_dut;
    i_rst_n_cluster = 1'b0;
    repeat (2) cycle();
    i_rst_n_cluster = 1'b1;
    cycle();
  endtask

  initial begin
    i_rst_n_cluster = 1'b0;
    i_cache_access_valid = 1'b0;
    i_cache_access_pa_line = '0;
    i_cache_victim_valid = 1'b0;
    i_cache_victim_pa_line = '0;
    i_cache_probe_line_busy = 1'b0;
    i_cache_req_valid = 1'b0;
    i_cache_req_id = '0;
    i_cache_req_pa_line = '0;
    i_cache_req_kind = '0;
    i_req_ready = 1'b0;
    i_gnt_valid = 1'b0;
    i_gnt_id = '0;
    i_gnt_pa_line = '0;
    i_gnt_state = '0;
    i_gnt_err = 1'b0;
    i_cache_gnt_ready = 1'b0;
    i_probe_req_valid = 1'b0;
    i_probe_req_tag = '0;
    i_probe_req_pa_line = '0;
    i_probe_req_phase = '0;
    i_probe_req_target_state = '0;
    i_probe_req_wback_en = 1'b0;
    i_cache_probe_req_ready = 1'b0;
    i_cache_probe_rsp_valid = 1'b0;
    i_cache_probe_rsp_tag = '0;
    i_cache_probe_rsp_pa_line = '0;
    i_cache_probe_rsp_phase = '0;
    i_cache_probe_rsp_state = '0;
    i_cache_probe_rsp_err = 1'b0;
    i_cache_probe_rsp_wback_done = 1'b0;
    i_probe_rsp_ready = 1'b0;

    reset_dut();
    check(o_cache_line_lock_valid == '0, "reset clears all line locks");

    // Ownership request is buffered and remains stable under fabric stall.
    @(negedge i_clk_cluster);
    i_cache_req_valid = 1'b1;
    i_cache_req_id = 3'd5;
    i_cache_req_pa_line = 52'h0000_1234;
    i_cache_req_kind = 2'd1;
    #1;
    check(o_cache_req_ready, "request source has capacity");
    cycle();
    @(negedge i_clk_cluster);
    i_cache_req_valid = 1'b0;
    check(o_req_valid, "ownership request reaches fabric");
    repeat (2) begin
      cycle();
      check(o_req_valid && o_req_id == 3'd5
            && o_req_pa_line == 52'h0000_1234 && o_req_kind == 2'd1,
            "ownership request payload holds while stalled");
    end
    @(negedge i_clk_cluster);
    i_req_ready = 1'b1;
    cycle();
    @(negedge i_clk_cluster);
    i_req_ready = 1'b0;
    check(!o_req_valid, "ownership request clears after fabric handshake");

    // Grant response is separately buffered and preserves errors under stall.
    @(negedge i_clk_cluster);
    i_gnt_valid = 1'b1;
    i_gnt_id = 3'd2;
    i_gnt_pa_line = 52'h0000_5678;
    i_gnt_state = 2'd2;
    i_gnt_err = 1'b1;
    #1;
    check(o_gnt_ready, "grant source has capacity");
    cycle();
    @(negedge i_clk_cluster);
    i_gnt_valid = 1'b0;
    check(o_cache_gnt_valid && o_cache_gnt_err
          && o_cache_gnt_id == 3'd2 && o_cache_gnt_pa_line == 52'h0000_5678
          && o_cache_gnt_state == 2'd2, "grant payload reaches cache");
    repeat (2) begin
      cycle();
      check(o_cache_gnt_valid && o_cache_gnt_err
            && o_cache_gnt_id == 3'd2 && o_cache_gnt_pa_line == 52'h0000_5678,
            "grant and error hold while cache is stalled");
    end
    @(negedge i_clk_cluster);
    i_cache_gnt_ready = 1'b1;
    cycle();
    @(negedge i_clk_cluster);
    i_cache_gnt_ready = 1'b0;
    check(!o_cache_gnt_valid, "grant clears after cache handshake");

    // PREPARE remains visible to the busy query but cannot enter cache until
    // same-line MSHR/refill work has drained.
    @(negedge i_clk_cluster);
    i_probe_req_valid = 1'b1;
    i_probe_req_tag = LPARA_COH_TAG_W'(3'd3);
    i_probe_req_pa_line = 52'h0000_9abc;
    i_probe_req_phase = LPARA_PHASE_PREPARE;
    i_probe_req_target_state = 2'd1;
    i_probe_req_wback_en = 1'b1;
    i_cache_probe_line_busy = 1'b1;
    i_cache_probe_req_ready = 1'b1;
    #1;
    check(o_cache_probe_query_valid && o_cache_probe_query_nline == 52'h0000_9abc,
          "PREPARE drives matching line query while busy");
    check(!o_cache_probe_req_valid && !o_probe_req_ready,
          "busy line blocks PREPARE forwarding");
    cycle();
    @(negedge i_clk_cluster);
    i_cache_probe_line_busy = 1'b0;
    #1;
    check(o_cache_probe_req_valid && o_probe_req_ready,
          "PREPARE forwards after busy query clears");
    check(o_cache_probe_req_tag == i_probe_req_tag
          && o_cache_probe_req_pa_line == i_probe_req_pa_line
          && o_cache_probe_req_phase == i_probe_req_phase
          && o_cache_probe_req_target_state == i_probe_req_target_state
          && o_cache_probe_req_wback_en,
          "PREPARE payload is transparent");
    cycle();
    @(negedge i_clk_cluster);
    i_probe_req_valid = 1'b0;
    i_cache_access_valid = 1'b1;
    i_cache_victim_valid = 1'b1;
    i_cache_access_pa_line = 52'h0000_9abc;
    i_cache_victim_pa_line = 52'h0000_9abc;
    #1;
    check(o_cache_line_lock_valid[3]
          && o_cache_line_lock_pa_line[3] == 52'h0000_9abc,
          "accepted PREPARE reserves its tag and line");
    for (int lock_idx = 0; lock_idx < PARA_COH_TXN_NUM; lock_idx++) begin
      if (lock_idx != 3)
        check(!o_cache_line_lock_valid[lock_idx]
              && o_cache_line_lock_pa_line[lock_idx] == '0,
              "only the matching tag owns a line-lock record");
    end
    check(o_cache_access_locked && o_cache_victim_locked,
          "locked line blocks both access and victim use");
    i_cache_access_valid = 1'b0;
    i_cache_victim_valid = 1'b0;
    #1;
    check(!o_cache_access_locked && !o_cache_victim_locked,
          "invalid address observations do not alias an active line lock");
    i_cache_access_valid = 1'b1;
    i_cache_victim_valid = 1'b1;
    #1;
    check(o_cache_access_locked && o_cache_victim_locked,
          "valid address observations match active line locks");

    // Failed terminal response retains the lock; successful ABORT releases it.
    i_cache_probe_rsp_valid = 1'b1;
    i_cache_probe_rsp_tag = LPARA_COH_TAG_W'(3'd3);
    i_cache_probe_rsp_pa_line = 52'h0000_9abc;
    i_cache_probe_rsp_phase = LPARA_PHASE_COMMIT;
    i_cache_probe_rsp_state = 2'd1;
    i_cache_probe_rsp_err = 1'b1;
    i_cache_probe_rsp_wback_done = 1'b0;
    i_probe_rsp_ready = 1'b1;
    #1;
    check(o_probe_rsp_valid && o_probe_rsp_err
          && o_probe_rsp_tag == LPARA_COH_TAG_W'(3'd3)
          && o_probe_rsp_pa_line == 52'h0000_9abc
          && o_probe_rsp_phase == LPARA_PHASE_COMMIT,
          "tagged failed COMMIT response is transparent");
    check(o_probe_rsp_state == 2'd1 && !o_probe_rsp_wback_done
          && o_cache_probe_rsp_ready,
          "probe response payload and handshake are transparent");
    cycle();
    @(negedge i_clk_cluster);
    check(o_cache_line_lock_valid[3], "failed COMMIT keeps the line lock");

    // A different transaction tag may hold a different line concurrently.
    i_cache_probe_rsp_valid = 1'b0;
    i_probe_req_valid = 1'b1;
    i_probe_req_tag = LPARA_COH_TAG_W'(3'd4);
    i_probe_req_pa_line = 52'h0000_abcd;
    i_probe_req_phase = LPARA_PHASE_PREPARE;
    i_probe_req_target_state = 2'd2;
    i_probe_req_wback_en = 1'b1;
    #1;
    check(o_cache_probe_req_valid && o_probe_req_ready,
          "second tag can reserve a different line");
    cycle();
    @(negedge i_clk_cluster);
    i_probe_req_valid = 1'b0;
    i_cache_access_pa_line = 52'h0000_9abc;
    i_cache_victim_pa_line = 52'h0000_abcd;
    #1;
    check(o_cache_line_lock_valid[3] && o_cache_line_lock_valid[4]
          && o_cache_line_lock_pa_line[3] == 52'h0000_9abc
          && o_cache_line_lock_pa_line[4] == 52'h0000_abcd,
          "two tags retain independent line locks");
    check(o_cache_access_locked && o_cache_victim_locked,
          "independent access and victim queries see their locked lines");

    // A second tag cannot alias an already locked line.
    i_probe_req_valid = 1'b1;
    i_probe_req_tag = LPARA_COH_TAG_W'(3'd5);
    i_probe_req_pa_line = 52'h0000_9abc;
    #1;
    check(!o_cache_probe_req_valid && !o_probe_req_ready && !o_lock_diag_event,
          "same-line alias waits without acquiring a second lock");
    i_probe_req_valid = 1'b0;

    // ABORT of tag 3 releases only its line; tag 4 remains independently held.
    i_cache_probe_rsp_valid = 1'b1;
    i_cache_probe_rsp_tag = LPARA_COH_TAG_W'(3'd3);
    i_cache_probe_rsp_pa_line = 52'h0000_9abc;
    i_cache_probe_rsp_phase = LPARA_PHASE_ABORT;
    i_cache_probe_rsp_err = 1'b0;
    cycle();
    @(negedge i_clk_cluster);
    #1;
    check(!o_cache_line_lock_valid[3] && o_cache_line_lock_valid[4]
          && !o_cache_access_locked && o_cache_victim_locked,
          "ABORT releases only its matching tag and line lock");

    i_cache_probe_rsp_tag = LPARA_COH_TAG_W'(3'd4);
    i_cache_probe_rsp_pa_line = 52'h0000_abcd;
    i_cache_probe_rsp_phase = LPARA_PHASE_COMMIT;
    i_cache_probe_rsp_state = 2'd2;
    cycle();
    @(negedge i_clk_cluster);
    i_cache_probe_rsp_valid = 1'b0;
    #1;
    check(!o_cache_line_lock_valid[4] && !o_cache_victim_locked,
          "COMMIT releases the other matching line lock");
    check(!o_lock_diag_event, "legal scenario does not raise lock diagnostic");

    $display("PASS: tile elasticity, PREPARE busy drain, independent tagged locks, alias blocking, error retention, and terminal release");
    $finish;
  end
endmodule
