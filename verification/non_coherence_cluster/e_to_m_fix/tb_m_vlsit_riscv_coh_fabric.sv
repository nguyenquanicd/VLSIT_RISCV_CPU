`timescale 1ns/1ps

module tb_m_vlsit_riscv_coh_fabric;
  localparam int unsigned PARA_CPU_NUM = 4;
  localparam int unsigned PARA_COH_TXN_NUM = 8;
  localparam int unsigned LPARA_TAG_W = $clog2(PARA_COH_TXN_NUM);
  localparam logic [1:0] LPARA_MESI_I = 2'd0;
  localparam logic [1:0] LPARA_MESI_S = 2'd1;
  localparam logic [1:0] LPARA_MESI_E = 2'd2;
  localparam logic [1:0] LPARA_MESI_M = 2'd3;
  localparam logic [1:0] LPARA_REQ_SHARED = 2'd0;
  localparam logic [1:0] LPARA_REQ_EXCLUSIVE = 2'd1;
  localparam logic [1:0] LPARA_PHASE_PREPARE = 2'd0;
  localparam logic [1:0] LPARA_PHASE_COMMIT = 2'd1;
  localparam logic [1:0] LPARA_PHASE_ABORT = 2'd2;

  logic i_clk_cluster;
  logic i_rst_n_cluster;
  logic [PARA_CPU_NUM-1:0] i_req_valid;
  logic [PARA_CPU_NUM-1:0] o_req_ready;
  logic [PARA_CPU_NUM-1:0][2:0] i_req_id;
  logic [PARA_CPU_NUM-1:0][51:0] i_req_pa_line;
  logic [PARA_CPU_NUM-1:0][1:0] i_req_kind;
  logic [PARA_CPU_NUM-1:0] o_gnt_valid;
  logic [PARA_CPU_NUM-1:0] i_gnt_ready;
  logic [PARA_CPU_NUM-1:0][2:0] o_gnt_req_id;
  logic [PARA_CPU_NUM-1:0][51:0] o_gnt_pa_line;
  logic [PARA_CPU_NUM-1:0][1:0] o_gnt_state;
  logic [PARA_CPU_NUM-1:0] o_gnt_err;
  logic [PARA_CPU_NUM-1:0] o_probe_req_valid;
  logic [PARA_CPU_NUM-1:0] i_probe_req_ready;
  logic [PARA_CPU_NUM-1:0][LPARA_TAG_W-1:0] o_probe_req_tag;
  logic [PARA_CPU_NUM-1:0][51:0] o_probe_req_pa_line;
  logic [PARA_CPU_NUM-1:0][1:0] o_probe_req_phase;
  logic [PARA_CPU_NUM-1:0][1:0] o_probe_req_target_state;
  logic [PARA_CPU_NUM-1:0] o_probe_req_wback_en;
  logic [PARA_CPU_NUM-1:0] i_probe_rsp_valid;
  logic [PARA_CPU_NUM-1:0] o_probe_rsp_ready;
  logic [PARA_CPU_NUM-1:0][LPARA_TAG_W-1:0] i_probe_rsp_tag;
  logic [PARA_CPU_NUM-1:0][51:0] i_probe_rsp_pa_line;
  logic [PARA_CPU_NUM-1:0][1:0] i_probe_rsp_phase;
  logic [PARA_CPU_NUM-1:0][1:0] i_probe_rsp_state;
  logic [PARA_CPU_NUM-1:0] i_probe_rsp_err;
  logic [PARA_CPU_NUM-1:0] i_probe_rsp_wback_done;
  logic i_same_line_lock_stall;
  logic [11:0][2:0] o_ccu_evt_count;
  logic o_coh_proto_diag_event;
  logic [2:0] o_dir_lookup_count;
  logic [2:0] o_dir_update_count;
  int unsigned reg_lookup_cycles_seen;
  int unsigned reg_update_cycles_seen;
  int unsigned reg_ccu_evt_sum [0:11];
  logic reg_test_active;

  m_vlsit_riscv_coh_fabric #(
    .PARA_CPU_NUM(32'(PARA_CPU_NUM)),
    .PARA_COH_TXN_NUM(32'(PARA_COH_TXN_NUM))
  ) u_vlsit_riscv_coh_fabric (
    .i_ccu_begin_valid('0),
    .o_ccu_begin_ready(),
    .i_ccu_begin_op('0),
    .i_ccu_begin_pa_line('0),
    .i_ccu_begin_hart('0),
    .i_ccu_begin_wback_en('0),
    .o_ccu_prepare_valid(),
    .i_ccu_prepare_ready('0),
    .o_ccu_prepare_tag(),
    .o_ccu_prepare_err(),
    .i_ccu_finish_valid('0),
    .o_ccu_finish_ready(),
    .i_ccu_finish_tag('0),
    .i_ccu_finish_commit('0),
    .o_ccu_finish_done(),

    .i_clk_cluster(i_clk_cluster),
    .i_rst_n_cluster(i_rst_n_cluster),
    .i_req_valid(i_req_valid),
    .o_req_ready(o_req_ready),
    .i_req_id(i_req_id),
    .i_req_pa_line(i_req_pa_line),
    .i_req_kind(i_req_kind),
    .o_gnt_valid(o_gnt_valid),
    .i_gnt_ready(i_gnt_ready),
    .o_gnt_req_id(o_gnt_req_id),
    .o_gnt_pa_line(o_gnt_pa_line),
    .o_gnt_state(o_gnt_state),
    .o_gnt_err(o_gnt_err),
    .o_probe_req_valid(o_probe_req_valid),
    .i_probe_req_ready(i_probe_req_ready),
    .o_probe_req_tag(o_probe_req_tag),
    .o_probe_req_pa_line(o_probe_req_pa_line),
    .o_probe_req_phase(o_probe_req_phase),
    .o_probe_req_target_state(o_probe_req_target_state),
    .o_probe_req_wback_en(o_probe_req_wback_en),
    .i_probe_rsp_valid(i_probe_rsp_valid),
    .o_probe_rsp_ready(o_probe_rsp_ready),
    .i_probe_rsp_tag(i_probe_rsp_tag),
    .i_probe_rsp_pa_line(i_probe_rsp_pa_line),
    .i_probe_rsp_phase(i_probe_rsp_phase),
    .i_probe_rsp_state(i_probe_rsp_state),
    .i_probe_rsp_err(i_probe_rsp_err),
    .i_probe_rsp_wback_done(i_probe_rsp_wback_done),
    .i_same_line_lock_stall(i_same_line_lock_stall),
    .o_coh_proto_diag_event(o_coh_proto_diag_event),
    .o_dir_lookup_count(o_dir_lookup_count),
    .o_dir_update_count(o_dir_update_count),
    .o_ccu_evt_count(o_ccu_evt_count)
  );

  initial i_clk_cluster = 1'b0;
  always #5 i_clk_cluster = ~i_clk_cluster;

  always @(posedge i_clk_cluster) begin
    if (reg_test_active) begin
      if (|o_dir_lookup_count)
        reg_lookup_cycles_seen <= reg_lookup_cycles_seen + 1;
      if (|o_dir_update_count)
        reg_update_cycles_seen <= reg_update_cycles_seen + 1;
      for (int event_idx = 0; event_idx < 12; event_idx++) begin
        if (o_ccu_evt_count[event_idx] > 3'd4)
          $fatal(1, "CCU event %0d exceeds the four-occurrence bound", event_idx);
        reg_ccu_evt_sum[event_idx] <= reg_ccu_evt_sum[event_idx]
                                      + 32'(o_ccu_evt_count[event_idx]);
      end
    end
  end

  task automatic send_request(input int unsigned hart_idx,
                             input logic [2:0] req_id,
                             input logic [51:0] pa_line,
                             input logic [1:0] req_kind);
    int unsigned timeout_count;
    timeout_count = 0;
    @(negedge i_clk_cluster);
    i_req_valid[hart_idx] = 1'b1;
    i_req_id[hart_idx] = req_id;
    i_req_pa_line[hart_idx] = pa_line;
    i_req_kind[hart_idx] = req_kind;
    do begin
      @(posedge i_clk_cluster);
      timeout_count++;
      if (timeout_count > 100)
        $fatal(1, "request handshake timeout for hart %0d", hart_idx);
    end while (!o_req_ready[hart_idx]);
    @(negedge i_clk_cluster);
    i_req_valid[hart_idx] = 1'b0;
  endtask

  task automatic expect_grant(input int unsigned hart_idx,
                              input logic [2:0] exp_req_id,
                              input logic [51:0] exp_pa_line,
                              input logic [1:0] exp_state);
    int unsigned timeout_count;
    timeout_count = 0;
    while (!o_gnt_valid[hart_idx]) begin
      @(negedge i_clk_cluster);
      timeout_count++;
      if (timeout_count > 100) begin
        $display("grant timeout req_valid=%b req_ready=%b gnt_valid=%b lookup=%0d update=%0d diag=%b",
                 i_req_valid, o_req_ready, o_gnt_valid, o_dir_lookup_count,
                 o_dir_update_count, o_coh_proto_diag_event);
        $display("update valid=%b ready=%b pick=%b tag=%h line=%h way=%h dir_diag=%b table_diag=%b",
                 u_vlsit_riscv_coh_fabric.w_dir_update_valid,
                 u_vlsit_riscv_coh_fabric.w_dir_update_ready,
                 u_vlsit_riscv_coh_fabric.w_update_pick_valid,
                 u_vlsit_riscv_coh_fabric.w_dir_update_tag[0],
                 u_vlsit_riscv_coh_fabric.w_dir_update_line[0],
                 u_vlsit_riscv_coh_fabric.w_dir_update_way[0],
                 u_vlsit_riscv_coh_fabric.w_dir_diag,
                 u_vlsit_riscv_coh_fabric.w_table_diag);
        for (int slot_idx = 0; slot_idx < PARA_COH_TXN_NUM; slot_idx++) begin
          $display("slot %0d state=%0d valid=%b line=%h reserved=%b phase_done=%b phase_err=%b",
                   slot_idx,
                   u_vlsit_riscv_coh_fabric.reg_fsm_ctx_current_state[slot_idx],
                   u_vlsit_riscv_coh_fabric.w_ctx_valid[slot_idx],
                   u_vlsit_riscv_coh_fabric.w_ctx_pa_line[slot_idx],
                   u_vlsit_riscv_coh_fabric.reg_ctx_dir_reserved[slot_idx],
                   u_vlsit_riscv_coh_fabric.w_ctx_phase_done[slot_idx],
                   u_vlsit_riscv_coh_fabric.w_ctx_phase_err[slot_idx]);
        end
        $fatal(1, "permission grant timeout for hart %0d", hart_idx);
      end
    end
    if (o_gnt_err[hart_idx] !== 1'b0)
      $fatal(1, "unexpected error grant for hart %0d", hart_idx);
    if (o_gnt_req_id[hart_idx] !== exp_req_id)
      $fatal(1, "request ID mismatch for hart %0d", hart_idx);
    if (o_gnt_pa_line[hart_idx] !== exp_pa_line)
      $fatal(1, "line address mismatch for hart %0d", hart_idx);
    if (o_gnt_state[hart_idx] !== exp_state)
      $fatal(1, "MESI grant mismatch for hart %0d: got %0d expected %0d",
             hart_idx, o_gnt_state[hart_idx], exp_state);
    @(posedge i_clk_cluster);
  endtask

  task automatic expect_error_grant(input int unsigned hart_idx,
                                    input logic [2:0] exp_req_id,
                                    input logic [51:0] exp_pa_line);
    int unsigned timeout_count;
    timeout_count = 0;
    while (!o_gnt_valid[hart_idx]) begin
      @(negedge i_clk_cluster);
      timeout_count++;
      if (timeout_count > 100)
        $fatal(1, "error grant timeout for hart %0d", hart_idx);
    end
    if (o_gnt_err[hart_idx] !== 1'b1)
      $fatal(1, "expected failed coherence grant for hart %0d", hart_idx);
    if (o_gnt_req_id[hart_idx] !== exp_req_id)
      $fatal(1, "error grant request ID mismatch for hart %0d", hart_idx);
    if (o_gnt_pa_line[hart_idx] !== exp_pa_line)
      $fatal(1, "error grant line mismatch for hart %0d", hart_idx);
    @(posedge i_clk_cluster);
  endtask

  task automatic respond_to_hart_probe(input int unsigned hart_idx,
                                       input logic [1:0] expected_phase,
                                       input logic [1:0] expected_target_state,
                                       input logic [1:0] response_state,
                                       input logic expected_wback_en,
                                       input logic wback_done,
                                       input logic response_err=1'b0);
    int unsigned timeout_count;
    logic [LPARA_TAG_W-1:0] probe_tag;
    logic [51:0] probe_line;
    timeout_count = 0;
    while (!o_probe_req_valid[hart_idx]) begin
      @(negedge i_clk_cluster);
      timeout_count++;
      if (timeout_count > 100) begin
        $display("probe timeout diagnostics: hart=%0d phase=%0d req=%b gnt=%b probe_valid=%b",
                 hart_idx, expected_phase, i_req_valid, o_gnt_valid, o_probe_req_valid);
        for (int slot_idx = 0; slot_idx < PARA_COH_TXN_NUM; slot_idx++) begin
          $display("slot %0d state=%0d line=%h hart=%0d holders=%b old_state=%0d",
                   slot_idx,
                   u_vlsit_riscv_coh_fabric.reg_fsm_ctx_current_state[slot_idx],
                   u_vlsit_riscv_coh_fabric.w_ctx_pa_line[slot_idx],
                   u_vlsit_riscv_coh_fabric.reg_ctx_hart[slot_idx],
                   u_vlsit_riscv_coh_fabric.reg_ctx_probe_holders[slot_idx],
                   u_vlsit_riscv_coh_fabric.reg_ctx_old_state[slot_idx]);
        end
        for (int way_idx = 0; way_idx < 8; way_idx++) begin
          $display("dir bank0 set0 way%0d valid=%b holders=%b owner=%0d state=%0d tag=%h",
                   way_idx,
                   u_vlsit_riscv_coh_fabric.u_vlsit_riscv_sharer_directory.reg_dir_valid[0][0][way_idx],
                   u_vlsit_riscv_coh_fabric.u_vlsit_riscv_sharer_directory.reg_dir_holders[0][0][way_idx],
                   u_vlsit_riscv_coh_fabric.u_vlsit_riscv_sharer_directory.reg_dir_owner[0][0][way_idx],
                   u_vlsit_riscv_coh_fabric.u_vlsit_riscv_sharer_directory.reg_dir_state[0][0][way_idx],
                   u_vlsit_riscv_coh_fabric.u_vlsit_riscv_sharer_directory.reg_dir_tag[0][0][way_idx]);
        end
        $fatal(1, "probe request timeout for hart %0d, phase %0d", hart_idx, expected_phase);
      end
    end
    if (o_probe_req_phase[hart_idx] !== expected_phase)
      $fatal(1, "unexpected probe phase: got %0d expected %0d",
             o_probe_req_phase[hart_idx], expected_phase);
    if (o_probe_req_target_state[hart_idx] !== expected_target_state)
      $fatal(1, "probe target state mismatch for hart %0d: got %0d expected %0d",
             hart_idx, o_probe_req_target_state[hart_idx], expected_target_state);
    if (o_probe_req_wback_en[hart_idx] !== expected_wback_en)
      $fatal(1, "probe writeback enable did not match the phase");
    probe_tag = o_probe_req_tag[hart_idx];
    probe_line = o_probe_req_pa_line[hart_idx];
    i_probe_req_ready[hart_idx] = 1'b1;
    @(posedge i_clk_cluster);
    @(negedge i_clk_cluster);
    i_probe_req_ready[hart_idx] = 1'b0;
    i_probe_rsp_valid[hart_idx] = 1'b1;
    i_probe_rsp_tag[hart_idx] = probe_tag;
    i_probe_rsp_pa_line[hart_idx] = probe_line;
    i_probe_rsp_phase[hart_idx] = expected_phase;
    i_probe_rsp_state[hart_idx] = response_state;
    i_probe_rsp_err[hart_idx] = response_err;
    i_probe_rsp_wback_done[hart_idx] = wback_done;
    timeout_count = 0;
    do begin
      @(posedge i_clk_cluster);
      timeout_count++;
      if (timeout_count > 100)
        $fatal(1, "probe response backpressure timeout for hart %0d", hart_idx);
    end while (!o_probe_rsp_ready[hart_idx]);
    @(negedge i_clk_cluster);
    i_probe_rsp_valid[hart_idx] = 1'b0;
  endtask

  initial begin : p_test
    logic [51:0] w_test_line;
    logic [51:0] w_parallel_line_a;
    logic [51:0] w_parallel_line_b;
    i_rst_n_cluster = 1'b0;
    i_req_valid = '0;
    i_req_id = '0;
    i_req_pa_line = '0;
    i_req_kind = '0;
    i_gnt_ready = '1;
    i_probe_req_ready = '0;
    i_probe_rsp_valid = '0;
    i_probe_rsp_tag = '0;
    i_probe_rsp_pa_line = '0;
    i_probe_rsp_phase = '0;
    i_probe_rsp_state = '0;
    i_probe_rsp_err = '0;
    i_probe_rsp_wback_done = '0;
    i_same_line_lock_stall = 1'b0;
    reg_lookup_cycles_seen = 0;
    reg_update_cycles_seen = 0;
    reg_test_active = 1'b0;
    for (int event_idx = 0; event_idx < 12; event_idx++)
      reg_ccu_evt_sum[event_idx] = 0;
    w_test_line = 52'h000008000;
    w_parallel_line_a = 52'h000008001;
    w_parallel_line_b = 52'h000008002;

    repeat (4) @(posedge i_clk_cluster);
    @(negedge i_clk_cluster);
    i_rst_n_cluster = 1'b1;
    reg_test_active = 1'b1;

    // Cold shared read receives E with no probes.
    send_request(0, 3'd2, w_test_line, LPARA_REQ_SHARED);
    expect_grant(0, 3'd2, w_test_line, LPARA_MESI_E);

    // A second read shares the E line; the first hart transitions to S.
    send_request(1, 3'd5, w_test_line, LPARA_REQ_SHARED);
    respond_to_hart_probe(0, LPARA_PHASE_PREPARE, LPARA_MESI_S,
                          LPARA_MESI_E, 1'b1, 1'b0);
    respond_to_hart_probe(0, LPARA_PHASE_COMMIT, LPARA_MESI_S,
                          LPARA_MESI_S, 1'b0, 1'b0);
    expect_grant(1, 3'd5, w_test_line, LPARA_MESI_S);

    // A third hart requests M; every sharer must PREPARE and COMMIT I.
    send_request(2, 3'd3, w_test_line, LPARA_REQ_EXCLUSIVE);
    respond_to_hart_probe(0, LPARA_PHASE_PREPARE, LPARA_MESI_I,
                          LPARA_MESI_S, 1'b1, 1'b0);
    respond_to_hart_probe(1, LPARA_PHASE_PREPARE, LPARA_MESI_I,
                          LPARA_MESI_S, 1'b1, 1'b0);
    respond_to_hart_probe(0, LPARA_PHASE_COMMIT, LPARA_MESI_I,
                          LPARA_MESI_I, 1'b0, 1'b0);
    respond_to_hart_probe(1, LPARA_PHASE_COMMIT, LPARA_MESI_I,
                          LPARA_MESI_I, 1'b0, 1'b0);
    expect_grant(2, 3'd3, w_test_line, LPARA_MESI_M);

    // A dirty M owner must complete writeback during PREPARE before ownership moves.
    send_request(3, 3'd6, w_test_line, LPARA_REQ_EXCLUSIVE);
    respond_to_hart_probe(2, LPARA_PHASE_PREPARE, LPARA_MESI_I,
                          LPARA_MESI_M, 1'b1, 1'b1);
    respond_to_hart_probe(2, LPARA_PHASE_COMMIT, LPARA_MESI_I,
                          LPARA_MESI_I, 1'b0, 1'b0);
    expect_grant(3, 3'd6, w_test_line, LPARA_MESI_M);

    // A failed dirty-owner writeback must ABORT and keep M as the old state.
    send_request(0, 3'd1, w_test_line, LPARA_REQ_SHARED);
    respond_to_hart_probe(3, LPARA_PHASE_PREPARE, LPARA_MESI_S,
                          LPARA_MESI_M, 1'b1, 1'b0);
    respond_to_hart_probe(3, LPARA_PHASE_ABORT, LPARA_MESI_S,
                          LPARA_MESI_M, 1'b0, 1'b0);
    expect_error_grant(0, 3'd1, w_test_line);

    // A later successful read-sharing request confirms that the failed attempt left M intact.
    send_request(0, 3'd4, w_test_line, LPARA_REQ_SHARED);
    respond_to_hart_probe(3, LPARA_PHASE_PREPARE, LPARA_MESI_S,
                          LPARA_MESI_M, 1'b1, 1'b1);
    respond_to_hart_probe(3, LPARA_PHASE_COMMIT, LPARA_MESI_S,
                          LPARA_MESI_S, 1'b0, 1'b0);
    expect_grant(0, 3'd4, w_test_line, LPARA_MESI_S);

    // Hold a hart 1 grant from bank 1 under backpressure, then verify an
    // unrelated bank 2 request can still complete and be consumed.
    i_gnt_ready[1] = 1'b0;
    send_request(1, 3'd1, w_parallel_line_a, LPARA_REQ_SHARED);
    expect_grant(1, 3'd1, w_parallel_line_a, LPARA_MESI_E);
    send_request(2, 3'd2, w_parallel_line_b, LPARA_REQ_SHARED);
    expect_grant(2, 3'd2, w_parallel_line_b, LPARA_MESI_E);
    if (o_gnt_err[1] !== 1'b0 || o_gnt_req_id[1] !== 3'd1
        || o_gnt_pa_line[1] !== w_parallel_line_a
        || o_gnt_state[1] !== LPARA_MESI_E)
      $fatal(1, "hart 1 independent-bank grant payload mismatch");
    repeat (3) begin
      @(posedge i_clk_cluster);
      if (o_gnt_valid[1] !== 1'b1 || o_gnt_err[1] !== 1'b0
          || o_gnt_req_id[1] !== 3'd1 || o_gnt_pa_line[1] !== w_parallel_line_a
          || o_gnt_state[1] !== LPARA_MESI_E)
        $fatal(1, "hart 1 grant changed during backpressure");
    end
    @(negedge i_clk_cluster);
    i_gnt_ready[1] = 1'b1;
    @(posedge i_clk_cluster);
    @(negedge i_clk_cluster);
    if (o_gnt_valid[1] !== 1'b0)
      $fatal(1, "hart 1 grant did not retire after ready");

    if (reg_lookup_cycles_seen < 8 || reg_update_cycles_seen < 5)
      $fatal(1, "directory activity was not observed for all ownership requests");
    if (reg_ccu_evt_sum[0] != 8 || reg_ccu_evt_sum[1] != 5
        || reg_ccu_evt_sum[2] != 3 || reg_ccu_evt_sum[3] != 6
        || reg_ccu_evt_sum[4] != 5 || reg_ccu_evt_sum[5] != 1
        || reg_ccu_evt_sum[6] != 2 || reg_ccu_evt_sum[7] != 8)
      $fatal(1, "CCU PMU transaction tap totals are incorrect");
    if (reg_ccu_evt_sum[8] != 0 || reg_ccu_evt_sum[9] != 0
        || reg_ccu_evt_sum[10] != 0 || reg_ccu_evt_sum[11] != 0)
      $fatal(1, "unexpected CCU stall or replacement event");
    if (o_coh_proto_diag_event !== 1'b0)
      $fatal(1, "unexpected coherence diagnostic event");
    // REQ-MEM-001: a directory E owner can be clean E or silently dirty M.
    for(int scenario=0;scenario<4;scenario++) begin
      logic [51:0] line_e;
      line_e=52'h9000+52'(scenario*4);
      send_request(0,3'd0,line_e,LPARA_REQ_SHARED);
      expect_grant(0,3'd0,line_e,LPARA_MESI_E);
      send_request(1,3'd1,line_e,LPARA_REQ_SHARED);
      case(scenario)
        0: begin
          respond_to_hart_probe(0,LPARA_PHASE_PREPARE,LPARA_MESI_S,LPARA_MESI_M,1,1);
          respond_to_hart_probe(0,LPARA_PHASE_COMMIT,LPARA_MESI_S,LPARA_MESI_S,0,0);
          expect_grant(1,3'd1,line_e,LPARA_MESI_S);
        end
        1,2: begin
          // Missing writeback-done or explicit B error must not be accepted as success.
          respond_to_hart_probe(0,LPARA_PHASE_PREPARE,LPARA_MESI_S,LPARA_MESI_M,1,0,1'(scenario==2));
          respond_to_hart_probe(0,LPARA_PHASE_ABORT,LPARA_MESI_S,LPARA_MESI_M,0,0);
          expect_error_grant(1,3'd1,line_e);
          // Retry while directory remains E and the real locked state remains M.
          send_request(1,3'd2,line_e,LPARA_REQ_SHARED);
          respond_to_hart_probe(0,LPARA_PHASE_PREPARE,LPARA_MESI_S,LPARA_MESI_M,1,1);
          respond_to_hart_probe(0,LPARA_PHASE_COMMIT,LPARA_MESI_S,LPARA_MESI_S,0,0);
          expect_grant(1,3'd2,line_e,LPARA_MESI_S);
        end
        3: begin
          // E->S is not a legal silent private-owner transition: reject it.
          respond_to_hart_probe(0,LPARA_PHASE_PREPARE,LPARA_MESI_S,LPARA_MESI_S,1,1);
          respond_to_hart_probe(0,LPARA_PHASE_ABORT,LPARA_MESI_S,LPARA_MESI_E,0,0);
          expect_error_grant(1,3'd1,line_e);
        end
      endcase
    end
    $display("PASS: E-to-M dirty writeback, clean-E baseline, missing writeback rejection, B-error ABORT/M, retry and illegal-state rejection");
    $display("PASS: MESI ownership, ABORT recovery, independent-bank progress, grant backpressure, and CCU PMU taps");
    $finish;
  end
endmodule
