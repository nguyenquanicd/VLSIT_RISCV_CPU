`timescale 1ns/1ps

module tb_holder_probe;
  localparam int unsigned PARA_WAY_NUM = 8;
  localparam logic [1:0] LPARA_PHASE_PREPARE = 2'd0;
  localparam logic [1:0] LPARA_PHASE_COMMIT = 2'd1;
  localparam logic [1:0] LPARA_PHASE_ABORT = 2'd2;
  localparam logic [1:0] LPARA_MESI_I = 2'd0;
  localparam logic [1:0] LPARA_MESI_S = 2'd1;
  localparam logic [1:0] LPARA_MESI_E = 2'd2;
  localparam logic [1:0] LPARA_MESI_M = 2'd3;

  logic i_clk_cache;
  logic i_rst_n_cache;
  logic i_probe_req_valid;
  logic o_probe_req_ready;
  logic [3:0] i_probe_req_tag;
  logic [51:0] i_probe_req_nline;
  logic [1:0] i_probe_req_phase;
  logic [1:0] i_probe_req_target_state;
  logic i_probe_req_wback_en;
  logic o_probe_rsp_valid;
  logic i_probe_rsp_ready;
  logic [3:0] o_probe_rsp_tag;
  logic [51:0] o_probe_rsp_nline;
  logic [1:0] o_probe_rsp_phase;
  logic [1:0] o_probe_rsp_state;
  logic o_probe_rsp_err;
  logic o_probe_rsp_wback_done;
  logic o_lookup_valid;
  logic i_lookup_ready;
  logic [3:0] o_lookup_tag;
  logic [51:0] o_lookup_nline;
  logic i_lookup_rsp_valid;
  logic o_lookup_rsp_ready;
  logic [3:0] i_lookup_rsp_tag;
  logic [51:0] i_lookup_rsp_nline;
  logic [PARA_WAY_NUM-1:0] i_lookup_rsp_way;
  logic i_lookup_rsp_hit;
  logic [1:0] i_lookup_rsp_state;
  logic i_lookup_rsp_err;
  logic o_flush_valid;
  logic i_flush_ready;
  logic [51:0] o_flush_nline;
  logic [PARA_WAY_NUM-1:0] o_flush_way;
  logic i_flush_ack_valid;
  logic [51:0] i_flush_ack_nline;
  logic i_flush_ack_err;
  logic o_state_update_valid;
  logic i_state_update_ready;
  logic [51:0] o_state_update_nline;
  logic [PARA_WAY_NUM-1:0] o_state_update_way;
  logic [1:0] o_state_update_state;

  logic [3:0] reg_active_tag;
  logic [51:0] reg_active_line;
  logic [1:0] reg_active_target;

  m_vlsit_riscv_hpd_probe_engine #(
    .PARA_WAY_NUM(32'(PARA_WAY_NUM))
  ) u_vlsit_riscv_hpd_probe_engine (
    .i_clk_cache,
    .i_rst_n_cache,
    .i_probe_req_valid,
    .o_probe_req_ready,
    .i_probe_req_tag,
    .i_probe_req_nline,
    .i_probe_req_phase,
    .i_probe_req_target_state,
    .i_probe_req_wback_en,
    .o_probe_rsp_valid,
    .i_probe_rsp_ready,
    .o_probe_rsp_tag,
    .o_probe_rsp_nline,
    .o_probe_rsp_phase,
    .o_probe_rsp_state,
    .o_probe_rsp_err,
    .o_probe_rsp_wback_done,
    .o_lookup_valid,
    .i_lookup_ready,
    .o_lookup_tag,
    .o_lookup_nline,
    .i_lookup_rsp_valid,
    .o_lookup_rsp_ready,
    .i_lookup_rsp_tag,
    .i_lookup_rsp_nline,
    .i_lookup_rsp_way,
    .i_lookup_rsp_hit,
    .i_lookup_rsp_state,
    .i_lookup_rsp_err,
    .o_flush_valid,
    .i_flush_ready,
    .o_flush_nline,
    .o_flush_way,
    .i_flush_ack_valid,
    .i_flush_ack_nline,
    .i_flush_ack_err,
    .o_state_update_valid,
    .i_state_update_ready,
    .o_state_update_nline,
    .o_state_update_way,
    .o_state_update_state
  );

  initial i_clk_cache = 1'b0;
  always #5 i_clk_cache = ~i_clk_cache;

  task automatic check_probe_rsp(input logic [3:0] exp_tag,
                                input logic [51:0] exp_line,
                                input logic [1:0] exp_phase,
                                input logic [1:0] exp_state,
                                input logic exp_err,
                                input logic exp_wback_done);
    int unsigned timeout_count;
    timeout_count = 0;
    while (!o_probe_rsp_valid) begin
      @(negedge i_clk_cache);
      timeout_count++;
      if (timeout_count > 40)
        $fatal(1, "probe response timeout, phase=%0d tag=%h", exp_phase, exp_tag);
    end
    if (o_probe_rsp_tag !== exp_tag || o_probe_rsp_nline !== exp_line
        || o_probe_rsp_phase !== exp_phase || o_probe_rsp_state !== exp_state
        || o_probe_rsp_err !== exp_err || o_probe_rsp_wback_done !== exp_wback_done)
      $fatal(1, "probe response mismatch phase=%0d tag=%h line=%h state=%0d err=%b wb=%b",
             o_probe_rsp_phase, o_probe_rsp_tag, o_probe_rsp_nline,
             o_probe_rsp_state, o_probe_rsp_err, o_probe_rsp_wback_done);
    repeat (2) begin
      @(posedge i_clk_cache);
      if (o_probe_rsp_valid !== 1'b1 || o_probe_rsp_tag !== exp_tag
          || o_probe_rsp_nline !== exp_line || o_probe_rsp_phase !== exp_phase
          || o_probe_rsp_state !== exp_state || o_probe_rsp_err !== exp_err
          || o_probe_rsp_wback_done !== exp_wback_done)
        $fatal(1, "probe response payload changed under backpressure");
    end
    @(negedge i_clk_cache);
    i_probe_rsp_ready = 1'b1;
    @(posedge i_clk_cache);
    @(negedge i_clk_cache);
    i_probe_rsp_ready = 1'b0;
  endtask

  task automatic send_probe(input logic [3:0] tag,
                            input logic [51:0] line,
                            input logic [1:0] phase,
                            input logic [1:0] target_state,
                            input logic wback_en);
    int unsigned timeout_count;
    timeout_count = 0;
    @(negedge i_clk_cache);
    i_probe_req_valid = 1'b1;
    i_probe_req_tag = tag;
    i_probe_req_nline = line;
    i_probe_req_phase = phase;
    i_probe_req_target_state = target_state;
    i_probe_req_wback_en = wback_en;
    while (!o_probe_req_ready) begin
      @(negedge i_clk_cache);
      timeout_count++;
      if (timeout_count > 40)
        $fatal(1, "probe request timeout phase=%0d tag=%h", phase, tag);
    end
    @(posedge i_clk_cache);
    @(negedge i_clk_cache);
    i_probe_req_valid = 1'b0;
  endtask

  task automatic provide_lookup(input logic [3:0] tag,
                               input logic [51:0] line,
                               input logic hit,
                               input logic [1:0] state,
                               input logic [PARA_WAY_NUM-1:0] way,
                               input logic err);
    int unsigned timeout_count;
    timeout_count = 0;
    while (!o_lookup_valid) begin
      @(negedge i_clk_cache);
      timeout_count++;
      if (timeout_count > 40)
        $fatal(1, "directory lookup request timeout tag=%h", tag);
    end
    if (o_lookup_tag !== tag || o_lookup_nline !== line)
      $fatal(1, "directory lookup payload mismatch");
    @(negedge i_clk_cache);
    i_lookup_ready = 1'b1;
    @(posedge i_clk_cache);
    @(negedge i_clk_cache);
    i_lookup_ready = 1'b0;
    i_lookup_rsp_valid = 1'b1;
    i_lookup_rsp_tag = tag;
    i_lookup_rsp_nline = line;
    i_lookup_rsp_hit = hit;
    i_lookup_rsp_state = state;
    i_lookup_rsp_way = way;
    i_lookup_rsp_err = err;
    if (!o_lookup_rsp_ready)
      $fatal(1, "lookup response not ready after accepted lookup");
    @(posedge i_clk_cache);
    @(negedge i_clk_cache);
    i_lookup_rsp_valid = 1'b0;
  endtask

  task automatic complete_flush(input logic [51:0] line,
                                input logic [PARA_WAY_NUM-1:0] way,
                                input logic err);
    int unsigned timeout_count;
    timeout_count = 0;
    while (!o_flush_valid) begin
      @(negedge i_clk_cache);
      timeout_count++;
      if (timeout_count > 40)
        $fatal(1, "flush request timeout line=%h", line);
    end
    if (o_flush_nline !== line || o_flush_way !== way)
      $fatal(1, "flush request line/way mismatch");
    repeat (2) begin
      @(posedge i_clk_cache);
      if (o_flush_valid !== 1'b1 || o_flush_nline !== line || o_flush_way !== way)
        $fatal(1, "flush request changed under backpressure");
    end
    @(negedge i_clk_cache);
    i_flush_ready = 1'b1;
    @(posedge i_clk_cache);
    @(negedge i_clk_cache);
    i_flush_ready = 1'b0;
    repeat (2) @(posedge i_clk_cache);
    @(negedge i_clk_cache);
    i_flush_ack_valid = 1'b1;
    i_flush_ack_nline = line;
    i_flush_ack_err = err;
    @(posedge i_clk_cache);
    @(negedge i_clk_cache);
    i_flush_ack_valid = 1'b0;
  endtask

  task automatic complete_state_update(input logic [51:0] line,
                                       input logic [PARA_WAY_NUM-1:0] way,
                                       input logic [1:0] state);
    int unsigned timeout_count;
    timeout_count = 0;
    while (!o_state_update_valid) begin
      @(negedge i_clk_cache);
      timeout_count++;
      if (timeout_count > 40)
        $fatal(1, "MESI directory update timeout state=%0d", state);
    end
    if (o_state_update_nline !== line || o_state_update_way !== way
        || o_state_update_state !== state)
      $fatal(1, "MESI update payload mismatch line=%h way=%h state=%0d",
             o_state_update_nline, o_state_update_way, o_state_update_state);
    repeat (2) begin
      @(posedge i_clk_cache);
      if (o_state_update_valid !== 1'b1 || o_state_update_nline !== line
          || o_state_update_way !== way || o_state_update_state !== state)
        $fatal(1, "MESI update changed under backpressure");
    end
    @(negedge i_clk_cache);
    i_state_update_ready = 1'b1;
    @(posedge i_clk_cache);
    @(negedge i_clk_cache);
    i_state_update_ready = 1'b0;
  endtask

  task automatic expect_no_update;
    repeat (3) begin
      @(negedge i_clk_cache);
      if (o_state_update_valid !== 1'b0)
        $fatal(1, "unexpected directory state update");
    end
  endtask

  task automatic run_prepare_lookup(input logic [3:0] tag,
                                    input logic [51:0] line,
                                    input logic [1:0] target_state,
                                    input logic wback_en,
                                    input logic hit,
                                    input logic [1:0] state,
                                    input logic [PARA_WAY_NUM-1:0] way,
                                    input logic lookup_err);
    send_probe(tag, line, LPARA_PHASE_PREPARE, target_state, wback_en);
    provide_lookup(tag, line, hit, state, way, lookup_err);
  endtask

  initial begin : p_test
    localparam logic [51:0] LPARA_LINE_A = 52'h0000000001234;
    localparam logic [51:0] LPARA_LINE_B = 52'h0000000005678;
    localparam logic [PARA_WAY_NUM-1:0] LPARA_WAY_2 = 8'b00000100;
    localparam logic [PARA_WAY_NUM-1:0] LPARA_WAY_5 = 8'b00100000;

    i_rst_n_cache = 1'b0;
    i_probe_req_valid = 1'b0;
    i_probe_req_tag = '0;
    i_probe_req_nline = '0;
    i_probe_req_phase = '0;
    i_probe_req_target_state = '0;
    i_probe_req_wback_en = 1'b0;
    i_probe_rsp_ready = 1'b0;
    i_lookup_ready = 1'b0;
    i_lookup_rsp_valid = 1'b0;
    i_lookup_rsp_tag = '0;
    i_lookup_rsp_nline = '0;
    i_lookup_rsp_way = '0;
    i_lookup_rsp_hit = 1'b0;
    i_lookup_rsp_state = LPARA_MESI_I;
    i_lookup_rsp_err = 1'b0;
    i_flush_ready = 1'b0;
    i_flush_ack_valid = 1'b0;
    i_flush_ack_nline = '0;
    i_flush_ack_err = 1'b0;
    i_state_update_ready = 1'b0;
    reg_active_tag = '0;
    reg_active_line = '0;
    reg_active_target = '0;

    repeat (3) @(posedge i_clk_cache);
    @(negedge i_clk_cache);
    i_rst_n_cache = 1'b1;

    // Absent-line invalidation: PREPARE reports I and COMMIT performs no RAM write.
    reg_active_tag = 4'd1;
    reg_active_line = LPARA_LINE_A;
    reg_active_target = LPARA_MESI_I;
    run_prepare_lookup(reg_active_tag, reg_active_line, reg_active_target,
                       1'b0, 1'b0, LPARA_MESI_I, '0, 1'b0);
    check_probe_rsp(reg_active_tag, reg_active_line, LPARA_PHASE_PREPARE,
                    LPARA_MESI_I, 1'b0, 1'b0);
    send_probe(reg_active_tag, reg_active_line, LPARA_PHASE_COMMIT,
               reg_active_target, 1'b0);
    expect_no_update();
    check_probe_rsp(reg_active_tag, reg_active_line, LPARA_PHASE_COMMIT,
                    LPARA_MESI_I, 1'b0, 1'b0);

    for(int target=1;target<4;target++) begin
      reg_active_tag=4'(target+8);reg_active_line=LPARA_LINE_A;reg_active_target=2'(target);
      run_prepare_lookup(reg_active_tag,reg_active_line,reg_active_target,1,0,LPARA_MESI_I,'0,0);
      check_probe_rsp(reg_active_tag,reg_active_line,LPARA_PHASE_PREPARE,LPARA_MESI_I,0,0);
      send_probe(reg_active_tag,reg_active_line,LPARA_PHASE_COMMIT,reg_active_target,0);
      expect_no_update();
      check_probe_rsp(reg_active_tag,reg_active_line,LPARA_PHASE_COMMIT,LPARA_MESI_I,0,0);
    end
    $display("PASS: absent COMMIT to S/E/M remains I without RAM allocation/update");
    // Clean E-to-S: COMMIT updates only the matched way and ACK follows the RAM handshake.
    reg_active_tag = 4'd2;
    reg_active_line = LPARA_LINE_A;
    reg_active_target = LPARA_MESI_S;
    run_prepare_lookup(reg_active_tag, reg_active_line, reg_active_target,
                       1'b1, 1'b1, LPARA_MESI_E, LPARA_WAY_2, 1'b0);
    check_probe_rsp(reg_active_tag, reg_active_line, LPARA_PHASE_PREPARE,
                    LPARA_MESI_E, 1'b0, 1'b0);
    send_probe(reg_active_tag, reg_active_line, LPARA_PHASE_COMMIT,
               reg_active_target, 1'b0);
    complete_state_update(reg_active_line, LPARA_WAY_2, LPARA_MESI_S);
    check_probe_rsp(reg_active_tag, reg_active_line, LPARA_PHASE_COMMIT,
                    LPARA_MESI_S, 1'b0, 1'b0);

    // A mismatched COMMIT target is rejected; the matching ABORT can still retire the context.
    reg_active_tag = 4'd6;
    reg_active_line = LPARA_LINE_A;
    reg_active_target = LPARA_MESI_S;
    run_prepare_lookup(reg_active_tag, reg_active_line, reg_active_target,
                       1'b0, 1'b1, LPARA_MESI_E, LPARA_WAY_2, 1'b0);
    check_probe_rsp(reg_active_tag, reg_active_line, LPARA_PHASE_PREPARE,
                    LPARA_MESI_E, 1'b0, 1'b0);
    send_probe(reg_active_tag, reg_active_line, LPARA_PHASE_COMMIT,
               LPARA_MESI_M, 1'b0);
    expect_no_update();
    check_probe_rsp(reg_active_tag, reg_active_line, LPARA_PHASE_COMMIT,
                    LPARA_MESI_E, 1'b1, 1'b0);
    send_probe(reg_active_tag, reg_active_line, LPARA_PHASE_ABORT,
               reg_active_target, 1'b0);
    expect_no_update();
    check_probe_rsp(reg_active_tag, reg_active_line, LPARA_PHASE_ABORT,
                    LPARA_MESI_E, 1'b0, 1'b0);

    // Dirty M-to-S: keep stable M during PREPARE and wait for a matching writeback ACK.
    reg_active_tag = 4'd3;
    reg_active_line = LPARA_LINE_B;
    reg_active_target = LPARA_MESI_S;
    run_prepare_lookup(reg_active_tag, reg_active_line, reg_active_target,
                       1'b1, 1'b1, LPARA_MESI_M, LPARA_WAY_5, 1'b0);
    complete_flush(reg_active_line, LPARA_WAY_5, 1'b0);
    check_probe_rsp(reg_active_tag, reg_active_line, LPARA_PHASE_PREPARE,
                    LPARA_MESI_M, 1'b0, 1'b1);
    send_probe(reg_active_tag, reg_active_line, LPARA_PHASE_COMMIT,
               reg_active_target, 1'b0);
    complete_state_update(reg_active_line, LPARA_WAY_5, LPARA_MESI_S);
    check_probe_rsp(reg_active_tag, reg_active_line, LPARA_PHASE_COMMIT,
                    LPARA_MESI_S, 1'b0, 1'b1);

    // Failed owner writeback: PREPARE errors, ABORT retains M and never updates the directory.
    reg_active_tag = 4'd4;
    reg_active_line = LPARA_LINE_B;
    reg_active_target = LPARA_MESI_S;
    run_prepare_lookup(reg_active_tag, reg_active_line, reg_active_target,
                       1'b1, 1'b1, LPARA_MESI_M, LPARA_WAY_5, 1'b0);
    complete_flush(reg_active_line, LPARA_WAY_5, 1'b1);
    check_probe_rsp(reg_active_tag, reg_active_line, LPARA_PHASE_PREPARE,
                    LPARA_MESI_M, 1'b1, 1'b0);
    send_probe(reg_active_tag, reg_active_line, LPARA_PHASE_ABORT,
               reg_active_target, 1'b0);
    expect_no_update();
    check_probe_rsp(reg_active_tag, reg_active_line, LPARA_PHASE_ABORT,
                    LPARA_MESI_M, 1'b0, 1'b0);

    // True invalidate may discard a dirty line without issuing a writeback.
    reg_active_tag = 4'd5;
    reg_active_line = LPARA_LINE_B;
    reg_active_target = LPARA_MESI_I;
    run_prepare_lookup(reg_active_tag, reg_active_line, reg_active_target,
                       1'b0, 1'b1, LPARA_MESI_M, LPARA_WAY_5, 1'b0);
    expect_no_update();
    if (o_flush_valid !== 1'b0)
      $fatal(1, "true invalidate unexpectedly wrote back the dirty owner");
    check_probe_rsp(reg_active_tag, reg_active_line, LPARA_PHASE_PREPARE,
                    LPARA_MESI_M, 1'b0, 1'b0);
    send_probe(reg_active_tag, reg_active_line, LPARA_PHASE_COMMIT,
               reg_active_target, 1'b0);
    complete_state_update(reg_active_line, LPARA_WAY_5, LPARA_MESI_I);
    check_probe_rsp(reg_active_tag, reg_active_line, LPARA_PHASE_COMMIT,
                    LPARA_MESI_I, 1'b0, 1'b0);

    $display("PASS: probe lookup, E-to-S, COMMIT mismatch recovery, dirty M writeback, ABORT, and invalidation");
    $finish;
  end
endmodule
