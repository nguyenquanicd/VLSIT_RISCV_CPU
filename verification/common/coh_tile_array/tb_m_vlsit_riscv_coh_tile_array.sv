`timescale 1ns/1ps

module tb_m_vlsit_riscv_coh_tile_array #(
  parameter int unsigned PARA_CPU_NUM = 4
);
  localparam int unsigned PARA_COH_TXN_NUM = 8;
  localparam int unsigned LPARA_TAG_W = $clog2(PARA_COH_TXN_NUM);
  localparam logic [1:0] LPARA_MESI_S = 2'd1;
  localparam logic [1:0] LPARA_MESI_E = 2'd2;
  localparam logic [1:0] LPARA_REQ_SHARED = 2'd0;
  localparam logic [1:0] LPARA_PHASE_PREPARE = 2'd0;
  localparam logic [1:0] LPARA_PHASE_COMMIT = 2'd1;

  logic i_clk_cluster;
  logic i_rst_n_cluster;
  logic [PARA_CPU_NUM-1:0] i_tile_access_valid;
  logic [PARA_CPU_NUM-1:0][51:0] i_tile_access_pa_line;
  logic [PARA_CPU_NUM-1:0] o_tile_access_locked;
  logic [PARA_CPU_NUM-1:0] i_tile_victim_valid;
  logic [PARA_CPU_NUM-1:0][51:0] i_tile_victim_pa_line;
  logic [PARA_CPU_NUM-1:0] o_tile_victim_locked;
  logic [PARA_CPU_NUM-1:0] i_tile_req_valid;
  logic [PARA_CPU_NUM-1:0] o_tile_req_ready;
  logic [PARA_CPU_NUM-1:0][2:0] i_tile_req_id;
  logic [PARA_CPU_NUM-1:0][51:0] i_tile_req_pa_line;
  logic [PARA_CPU_NUM-1:0][1:0] i_tile_req_kind;
  logic [PARA_CPU_NUM-1:0] o_tile_gnt_valid;
  logic [PARA_CPU_NUM-1:0] i_tile_gnt_ready;
  logic [PARA_CPU_NUM-1:0][2:0] o_tile_gnt_id;
  logic [PARA_CPU_NUM-1:0][51:0] o_tile_gnt_pa_line;
  logic [PARA_CPU_NUM-1:0][1:0] o_tile_gnt_state;
  logic [PARA_CPU_NUM-1:0] o_tile_gnt_err;
  logic [PARA_CPU_NUM-1:0] o_tile_probe_req_valid;
  logic [PARA_CPU_NUM-1:0] i_tile_probe_req_ready;
  logic [PARA_CPU_NUM-1:0][LPARA_TAG_W-1:0] o_tile_probe_req_tag;
  logic [PARA_CPU_NUM-1:0][51:0] o_tile_probe_req_pa_line;
  logic [PARA_CPU_NUM-1:0][1:0] o_tile_probe_req_phase;
  logic [PARA_CPU_NUM-1:0][1:0] o_tile_probe_req_target_state;
  logic [PARA_CPU_NUM-1:0] o_tile_probe_req_wback_en;
  logic [PARA_CPU_NUM-1:0] i_tile_probe_rsp_valid;
  logic [PARA_CPU_NUM-1:0] o_tile_probe_rsp_ready;
  logic [PARA_CPU_NUM-1:0][LPARA_TAG_W-1:0] i_tile_probe_rsp_tag;
  logic [PARA_CPU_NUM-1:0][51:0] i_tile_probe_rsp_pa_line;
  logic [PARA_CPU_NUM-1:0][1:0] i_tile_probe_rsp_phase;
  logic [PARA_CPU_NUM-1:0][1:0] i_tile_probe_rsp_state;
  logic [PARA_CPU_NUM-1:0] i_tile_probe_rsp_err;
  logic [PARA_CPU_NUM-1:0] i_tile_probe_rsp_wback_done;
  logic [PARA_CPU_NUM-1:0] o_tile_probe_query_valid;
  logic [PARA_CPU_NUM-1:0][51:0] o_tile_probe_query_pa_line;
  logic [PARA_CPU_NUM-1:0] i_tile_probe_line_busy;
  logic [PARA_CPU_NUM-1:0][PARA_COH_TXN_NUM-1:0] o_tile_line_lock_valid;
  logic [PARA_CPU_NUM-1:0][PARA_COH_TXN_NUM-1:0][51:0] o_tile_line_lock_pa_line;
  logic [PARA_CPU_NUM-1:0] o_tile_lock_diag_event;
  logic o_coh_proto_diag_event;
  logic [2:0] o_dir_lookup_count;
  logic [2:0] o_dir_update_count;
  logic [11:0][2:0] w_ccu_evt_count;
  logic [11:0][31:0] reg_ccu_evt_total;
  int unsigned reg_evt_idx;
  int unsigned reg_lookup_cycles_seen;
  int unsigned reg_update_cycles_seen;

  m_vlsit_riscv_coh_tile_array #(
    .PARA_CPU_NUM(32'(PARA_CPU_NUM)),
    .PARA_COH_TXN_NUM(32'(PARA_COH_TXN_NUM))
  ) u_vlsit_riscv_coh_tile_array (
    .i_clk_cluster(i_clk_cluster),
    .i_rst_n_cluster(i_rst_n_cluster),
    .i_tile_access_valid(i_tile_access_valid),
    .i_tile_access_pa_line(i_tile_access_pa_line),
    .o_tile_access_locked(o_tile_access_locked),
    .i_tile_victim_valid(i_tile_victim_valid),
    .i_tile_victim_pa_line(i_tile_victim_pa_line),
    .o_tile_victim_locked(o_tile_victim_locked),
    .i_tile_req_valid(i_tile_req_valid),
    .o_tile_req_ready(o_tile_req_ready),
    .i_tile_req_id(i_tile_req_id),
    .i_tile_req_pa_line(i_tile_req_pa_line),
    .i_tile_req_kind(i_tile_req_kind),
    .o_tile_gnt_valid(o_tile_gnt_valid),
    .i_tile_gnt_ready(i_tile_gnt_ready),
    .o_tile_gnt_id(o_tile_gnt_id),
    .o_tile_gnt_pa_line(o_tile_gnt_pa_line),
    .o_tile_gnt_state(o_tile_gnt_state),
    .o_tile_gnt_err(o_tile_gnt_err),
    .o_tile_probe_req_valid(o_tile_probe_req_valid),
    .i_tile_probe_req_ready(i_tile_probe_req_ready),
    .o_tile_probe_req_tag(o_tile_probe_req_tag),
    .o_tile_probe_req_pa_line(o_tile_probe_req_pa_line),
    .o_tile_probe_req_phase(o_tile_probe_req_phase),
    .o_tile_probe_req_target_state(o_tile_probe_req_target_state),
    .o_tile_probe_req_wback_en(o_tile_probe_req_wback_en),
    .i_tile_probe_rsp_valid(i_tile_probe_rsp_valid),
    .o_tile_probe_rsp_ready(o_tile_probe_rsp_ready),
    .i_tile_probe_rsp_tag(i_tile_probe_rsp_tag),
    .i_tile_probe_rsp_pa_line(i_tile_probe_rsp_pa_line),
    .i_tile_probe_rsp_phase(i_tile_probe_rsp_phase),
    .i_tile_probe_rsp_state(i_tile_probe_rsp_state),
    .i_tile_probe_rsp_err(i_tile_probe_rsp_err),
    .i_tile_probe_rsp_wback_done(i_tile_probe_rsp_wback_done),
    .o_tile_probe_query_valid(o_tile_probe_query_valid),
    .o_tile_probe_query_pa_line(o_tile_probe_query_pa_line),
    .i_tile_probe_line_busy(i_tile_probe_line_busy),
    .o_tile_line_lock_valid(o_tile_line_lock_valid),
    .o_tile_line_lock_pa_line(o_tile_line_lock_pa_line),
    .o_tile_lock_diag_event(o_tile_lock_diag_event),
    .o_coh_proto_diag_event(o_coh_proto_diag_event),
    .o_dir_lookup_count(o_dir_lookup_count),
    .o_dir_update_count(o_dir_update_count),
    .o_ccu_evt_count(w_ccu_evt_count)
  );

  initial i_clk_cluster = 1'b0;
  always #5 i_clk_cluster = ~i_clk_cluster;

  always @(posedge i_clk_cluster) begin
    if (|o_dir_lookup_count)
      reg_lookup_cycles_seen <= reg_lookup_cycles_seen + 1;
    if (|o_dir_update_count)
      reg_update_cycles_seen <= reg_update_cycles_seen + 1;
    for (reg_evt_idx = 0; reg_evt_idx < 12; reg_evt_idx++) begin
      reg_ccu_evt_total[reg_evt_idx] <= reg_ccu_evt_total[reg_evt_idx]
        + 32'(w_ccu_evt_count[reg_evt_idx]);
    end
  end

  task automatic fail(input string message);
    $error("FAIL: %s at %0t", message, $time);
    $fatal(1);
  endtask

  task automatic send_req(input int unsigned hart,
                          input logic [2:0] req_id,
                          input logic [51:0] pa_line);
    int unsigned timeout_count;
    timeout_count = 0;
    @(negedge i_clk_cluster);
    i_tile_req_valid[hart] = 1'b1;
    i_tile_req_id[hart] = req_id;
    i_tile_req_pa_line[hart] = pa_line;
    i_tile_req_kind[hart] = LPARA_REQ_SHARED;
    do begin
      @(posedge i_clk_cluster);
      timeout_count++;
      if (timeout_count > 100)
        fail("ownership request handshake timeout");
    end while (!o_tile_req_ready[hart]);
    @(negedge i_clk_cluster);
    i_tile_req_valid[hart] = 1'b0;
  endtask

  task automatic accept_grant(input int unsigned hart,
                              input logic [2:0] req_id,
                              input logic [51:0] pa_line,
                              input logic [1:0] state);
    int unsigned timeout_count;
    timeout_count = 0;
    while (!o_tile_gnt_valid[hart]) begin
      @(negedge i_clk_cluster);
      timeout_count++;
      if (timeout_count > 150)
        fail("ownership grant timeout");
    end
    if (o_tile_gnt_err[hart] || (o_tile_gnt_id[hart] != req_id)
        || (o_tile_gnt_pa_line[hart] != pa_line) || (o_tile_gnt_state[hart] != state))
      fail("ownership grant payload mismatch");
    i_tile_gnt_ready[hart] = 1'b1;
    @(posedge i_clk_cluster);
    @(negedge i_clk_cluster);
    i_tile_gnt_ready[hart] = 1'b0;
  endtask

  task automatic service_probe(input int unsigned hart,
                               input logic [1:0] phase,
                               input logic [1:0] response_state,
                               input logic [51:0] pa_line,
                               input logic stall_busy);
    int unsigned timeout_count;
    logic [LPARA_TAG_W-1:0] w_tag;
    timeout_count = 0;
    if (stall_busy) begin
      while (!o_tile_probe_query_valid[hart]) begin
        @(negedge i_clk_cluster);
        timeout_count++;
        if (timeout_count > 100)
          fail("PREPARE query did not reach the cache");
      end
      if (o_tile_probe_query_pa_line[hart] != pa_line)
        fail("PREPARE query line mismatch");
      repeat (2) begin
        @(negedge i_clk_cluster);
        if (o_tile_probe_req_valid[hart])
          fail("PREPARE passed while same-line refill was busy");
      end
      i_tile_probe_line_busy[hart] = 1'b0;
    end
    timeout_count = 0;
    while (!o_tile_probe_req_valid[hart]) begin
      @(negedge i_clk_cluster);
      timeout_count++;
      if (timeout_count > 100)
        fail("probe request timeout");
    end
    if ((o_tile_probe_req_phase[hart] != phase)
        || (o_tile_probe_req_pa_line[hart] != pa_line)
        || (o_tile_probe_req_target_state[hart] != LPARA_MESI_S)
        || (o_tile_probe_req_wback_en[hart] != (phase == LPARA_PHASE_PREPARE))) begin
      $display("probe payload got phase=%0d line=%h target=%0d wback=%b; expected phase=%0d line=%h target=S wback=%b",
               o_tile_probe_req_phase[hart], o_tile_probe_req_pa_line[hart],
               o_tile_probe_req_target_state[hart], o_tile_probe_req_wback_en[hart],
               phase, pa_line, (phase == LPARA_PHASE_PREPARE));
      fail("probe request payload mismatch");
    end
    w_tag = o_tile_probe_req_tag[hart];
    i_tile_probe_req_ready[hart] = 1'b1;
    @(posedge i_clk_cluster);
    #1;
    if (phase == LPARA_PHASE_PREPARE) begin
      if (!o_tile_line_lock_valid[hart][w_tag])
        fail("PREPARE did not acquire a tagged line lock");
      if (o_tile_line_lock_pa_line[hart][w_tag] != pa_line)
        fail("PREPARE line lock address mismatch");
      i_tile_access_pa_line[hart] = pa_line;
      i_tile_access_valid[hart] = 1'b1;
      i_tile_victim_pa_line[hart] = pa_line;
      i_tile_victim_valid[hart] = 1'b1;
      #1;
      if (!o_tile_access_locked[hart] || !o_tile_victim_locked[hart])
        fail("same-line access/victim exclusion was not asserted");
    end
    @(negedge i_clk_cluster);
    i_tile_probe_req_ready[hart] = 1'b0;
    i_tile_probe_rsp_valid[hart] = 1'b1;
    i_tile_probe_rsp_tag[hart] = w_tag;
    i_tile_probe_rsp_pa_line[hart] = pa_line;
    i_tile_probe_rsp_phase[hart] = phase;
    i_tile_probe_rsp_state[hart] = response_state;
    i_tile_probe_rsp_err[hart] = 1'b0;
    i_tile_probe_rsp_wback_done[hart] = 1'b0;
    timeout_count = 0;
    do begin
      @(posedge i_clk_cluster);
      timeout_count++;
      if (timeout_count > 100)
        fail("probe response handshake timeout");
    end while (!o_tile_probe_rsp_ready[hart]);
    @(negedge i_clk_cluster);
    i_tile_probe_rsp_valid[hart] = 1'b0;
    #1;
    if (phase == LPARA_PHASE_COMMIT && o_tile_line_lock_valid[hart][w_tag])
      fail("successful COMMIT did not release its tagged line lock");
    if (phase == LPARA_PHASE_COMMIT) begin
      i_tile_access_pa_line[hart] = '0;
      i_tile_access_valid[hart] = 1'b0;
      i_tile_victim_pa_line[hart] = '0;
      i_tile_victim_valid[hart] = 1'b0;
      #1;
      if (o_tile_access_locked[hart] || o_tile_victim_locked[hart])
        fail("terminal response did not release access/victim exclusion");
    end
  endtask

  initial begin : p_test
    logic [51:0] w_shared_line;
    i_rst_n_cluster = 1'b0;
    i_tile_access_valid = '0;
    i_tile_access_pa_line = '0;
    i_tile_victim_valid = '0;
    i_tile_victim_pa_line = '0;
    i_tile_req_valid = '0;
    i_tile_req_id = '0;
    i_tile_req_pa_line = '0;
    i_tile_req_kind = '0;
    i_tile_gnt_ready = '0;
    i_tile_probe_req_ready = '0;
    i_tile_probe_rsp_valid = '0;
    i_tile_probe_rsp_tag = '0;
    i_tile_probe_rsp_pa_line = '0;
    i_tile_probe_rsp_phase = '0;
    i_tile_probe_rsp_state = '0;
    i_tile_probe_rsp_err = '0;
    i_tile_probe_rsp_wback_done = '0;
    i_tile_probe_line_busy = '0;
    reg_lookup_cycles_seen = 0;
    reg_update_cycles_seen = 0;
    reg_ccu_evt_total = '0;
    w_shared_line = 52'h0000_1234_5678_9;
    repeat (3) @(posedge i_clk_cluster);
    @(negedge i_clk_cluster);
    i_rst_n_cluster = 1'b1;

    send_req(0, 3'd1, w_shared_line);
    accept_grant(0, 3'd1, w_shared_line, LPARA_MESI_E);

    if (PARA_CPU_NUM < 2)
      fail("test requires at least two harts");
    i_tile_probe_line_busy[0] = 1'b1;
    send_req(1, 3'd2, w_shared_line);
    service_probe(0, LPARA_PHASE_PREPARE, LPARA_MESI_E, w_shared_line, 1'b1);
    service_probe(0, LPARA_PHASE_COMMIT, LPARA_MESI_S, w_shared_line, 1'b0);
    accept_grant(1, 3'd2, w_shared_line, LPARA_MESI_S);

    if ((|o_tile_line_lock_valid[0]) || o_coh_proto_diag_event || (|o_tile_lock_diag_event)
        || (reg_lookup_cycles_seen == 0) || (reg_update_cycles_seen == 0))
      fail("unexpected retained line lock or protocol diagnostic");
    @(posedge i_clk_cluster);
    #1;
    if ($isunknown(w_ccu_evt_count))
      fail("CCU event outputs contain X");
    if ((reg_ccu_evt_total[0] != 2) || (reg_ccu_evt_total[1] != 1)
        || (reg_ccu_evt_total[2] != 1) || (reg_ccu_evt_total[3] != 1)
        || (reg_ccu_evt_total[4] != 1) || (reg_ccu_evt_total[7] != 2))
      fail("CCU PMU event totals do not match the two ownership requests");
    if (reg_ccu_evt_total[9] == 0)
      fail("same-line lock stall was not counted by the CCU PMU tap");
    for (int unsigned check_evt_idx = 5; check_evt_idx < 12; check_evt_idx++) begin
      if ((check_evt_idx != 7) && (check_evt_idx != 9)
          && (reg_ccu_evt_total[check_evt_idx] != 0))
        fail($sformatf("unexpected CCU PMU event index %0d total %0d",
                       check_evt_idx, reg_ccu_evt_total[check_evt_idx]));
    end
    $display("PASS: %0d-hart adapter/fabric integration, ownership, busy-gated probe, and lock release",
             PARA_CPU_NUM);
    $finish;
  end
endmodule
