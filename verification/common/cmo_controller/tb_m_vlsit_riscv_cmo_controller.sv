`timescale 1ns/1ps

module tb_m_vlsit_riscv_cmo_controller #(
  parameter int unsigned PARA_CPU_NUM = 4
);
  localparam logic [1:0] LPARA_CMO_CLEAN = 2'd0;
  localparam logic [1:0] LPARA_CMO_FLUSH = 2'd1;
  localparam logic [1:0] LPARA_CMO_INVAL = 2'd2;
  localparam logic [1:0] LPARA_CMO_RESERVED = 2'd3;
  localparam logic [2:0] LPARA_TAG = 3'd5;
  localparam logic [51:0] LPARA_PA_LINE = 52'h00012_3456_789A;
  localparam logic [63:0] LPARA_VADDR = 64'h0000_0000_8123_4567;
  localparam logic [63:0] LPARA_PC = 64'h0000_0000_8000_1020;

  logic i_clk_cluster;
  logic i_rst_n_cluster;
  logic i_cmo_valid;
  logic o_cmo_ready;
  logic [1:0] i_cmo_op;
  logic [51:0] i_cmo_pa_line;
  logic [63:0] i_cmo_vaddr;
  logic [63:0] i_cmo_pc;
  logic [1:0] i_cmo_hart;
  logic o_cmo_done;
  logic o_cmo_error;
  logic [63:0] o_cmo_vaddr;
  logic [63:0] o_cmo_pc;
  logic [1:0] o_cmo_hart;
  logic o_ccu_begin_valid;
  logic i_ccu_begin_ready;
  logic [1:0] o_ccu_begin_op;
  logic [51:0] o_ccu_begin_pa_line;
  logic [1:0] o_ccu_begin_hart;
  logic o_ccu_begin_wback_en;
  logic i_ccu_prepare_valid;
  logic o_ccu_prepare_ready;
  logic [2:0] i_ccu_prepare_tag;
  logic i_ccu_prepare_err;
  logic o_maint_valid;
  logic i_maint_ready;
  logic [1:0] o_maint_op;
  logic [51:0] o_maint_pa_line;
  logic i_maint_done;
  logic i_maint_error;
  logic o_ccu_finish_valid;
  logic i_ccu_finish_ready;
  logic [2:0] o_ccu_finish_tag;
  logic o_ccu_finish_commit;
  logic i_ccu_finish_done;

  int unsigned reg_check_count;
  int unsigned reg_test_count;

  m_vlsit_riscv_cmo_controller #(
    .PARA_CPU_NUM(32'(PARA_CPU_NUM)),
    .PARA_COH_TXN_NUM(32'd8)
  ) u_vlsit_riscv_cmo_controller (
    .i_clk_cluster(i_clk_cluster),
    .i_rst_n_cluster(i_rst_n_cluster),
    .i_cmo_valid(i_cmo_valid),
    .o_cmo_ready(o_cmo_ready),
    .i_cmo_op(i_cmo_op),
    .i_cmo_pa_line(i_cmo_pa_line),
    .i_cmo_vaddr(i_cmo_vaddr),
    .i_cmo_pc(i_cmo_pc),
    .i_cmo_hart(i_cmo_hart),
    .o_cmo_done(o_cmo_done),
    .o_cmo_error(o_cmo_error),
    .o_cmo_vaddr(o_cmo_vaddr),
    .o_cmo_pc(o_cmo_pc),
    .o_cmo_hart(o_cmo_hart),
    .o_ccu_begin_valid(o_ccu_begin_valid),
    .i_ccu_begin_ready(i_ccu_begin_ready),
    .o_ccu_begin_op(o_ccu_begin_op),
    .o_ccu_begin_pa_line(o_ccu_begin_pa_line),
    .o_ccu_begin_hart(o_ccu_begin_hart),
    .o_ccu_begin_wback_en(o_ccu_begin_wback_en),
    .i_ccu_prepare_valid(i_ccu_prepare_valid),
    .o_ccu_prepare_ready(o_ccu_prepare_ready),
    .i_ccu_prepare_tag(i_ccu_prepare_tag),
    .i_ccu_prepare_err(i_ccu_prepare_err),
    .o_maint_valid(o_maint_valid),
    .i_maint_ready(i_maint_ready),
    .o_maint_op(o_maint_op),
    .o_maint_pa_line(o_maint_pa_line),
    .i_maint_done(i_maint_done),
    .i_maint_error(i_maint_error),
    .o_ccu_finish_valid(o_ccu_finish_valid),
    .i_ccu_finish_ready(i_ccu_finish_ready),
    .o_ccu_finish_tag(o_ccu_finish_tag),
    .o_ccu_finish_commit(o_ccu_finish_commit),
    .i_ccu_finish_done(i_ccu_finish_done)
  );

  initial i_clk_cluster = 1'b0;
  always #5 i_clk_cluster = ~i_clk_cluster;

  task automatic check(input logic condition, input string check_name);
    begin
      reg_check_count++;
      if (condition !== 1'b1) begin
        $display("FAIL @%0t: %s", $time, check_name);
        $fatal(1, "CMO controller check failed");
      end
    end
  endtask

  task automatic idle_inputs;
    begin
      i_cmo_valid = 1'b0;
      i_cmo_op = '0;
      i_cmo_pa_line = '0;
      i_cmo_vaddr = '0;
      i_cmo_pc = '0;
      i_cmo_hart = '0;
      i_ccu_begin_ready = 1'b0;
      i_ccu_prepare_valid = 1'b0;
      i_ccu_prepare_tag = '0;
      i_ccu_prepare_err = 1'b0;
      i_maint_ready = 1'b0;
      i_maint_done = 1'b0;
      i_maint_error = 1'b0;
      i_ccu_finish_ready = 1'b0;
      i_ccu_finish_done = 1'b0;
    end
  endtask

  task automatic reset_dut;
    begin
      @(negedge i_clk_cluster);
      idle_inputs();
      i_rst_n_cluster = 1'b0;
      repeat (2) @(posedge i_clk_cluster);
      @(negedge i_clk_cluster);
      i_rst_n_cluster = 1'b1;
      @(negedge i_clk_cluster);
      check(o_cmo_ready === 1'b1, "REQ-MEM-015: legal CMO command accepted while idle");
      check(o_cmo_done === 1'b0, "REQ-MEM-017: completion is inactive after reset");
    end
  endtask

  task automatic send_command(
    input logic [1:0] command_op,
    input logic [51:0] command_pa_line,
    input logic [63:0] command_vaddr,
    input logic [63:0] command_pc,
    input logic [1:0] command_hart
  );
    int unsigned cycles;
    begin
      @(negedge i_clk_cluster);
      i_cmo_valid = 1'b1;
      i_cmo_op = command_op;
      i_cmo_pa_line = command_pa_line;
      i_cmo_vaddr = command_vaddr;
      i_cmo_pc = command_pc;
      i_cmo_hart = command_hart;
      cycles = 0;
      do begin
        @(posedge i_clk_cluster);
        cycles++;
        if (cycles > 8)
          $fatal(1, "REQ-MEM-015: legal CMO command acceptance timed out");
      end while (o_cmo_ready !== 1'b1);
      @(negedge i_clk_cluster);
      i_cmo_valid = 1'b0;
    end
  endtask

  task automatic accept_begin(input logic [1:0] expected_op,
                              input logic [51:0] expected_pa_line,
                              input logic [1:0] expected_hart,
                              input logic expected_wback_en);
    int unsigned cycles;
    begin
      cycles = 0;
      while (o_ccu_begin_valid !== 1'b1) begin
        @(negedge i_clk_cluster);
        cycles++;
        if (cycles > 8)
          $fatal(1, "REQ-MEM-015: CCU begin request did not appear");
      end
      check(o_ccu_begin_op === expected_op, "REQ-MEM-015: CCU begin operation matches command");
      check(o_ccu_begin_pa_line === expected_pa_line, "REQ-MEM-015: CCU begin carries aligned physical line");
      check(o_ccu_begin_hart === expected_hart, "REQ-MEM-015: CCU begin carries source hart");
      check(o_ccu_begin_wback_en === expected_wback_en, "REQ-MEM-015: CCU begin writeback policy matches operation");
      repeat (2) begin
        @(negedge i_clk_cluster);
        check(o_ccu_begin_valid === 1'b1, "REQ-MEM-015: begin VALID remains asserted under backpressure");
        check(o_ccu_begin_pa_line === expected_pa_line, "REQ-MEM-015: begin payload remains stable under backpressure");
      end
      i_ccu_begin_ready = 1'b1;
      @(posedge i_clk_cluster);
      @(negedge i_clk_cluster);
      i_ccu_begin_ready = 1'b0;
      check(o_ccu_begin_valid === 1'b0, "REQ-MEM-015: begin request ends after handshake");
    end
  endtask

  task automatic complete_prepare(input logic [2:0] expected_tag,
                                  input logic expected_error);
    int unsigned cycles;
    begin
      cycles = 0;
      while (o_ccu_prepare_ready !== 1'b1) begin
        @(negedge i_clk_cluster);
        cycles++;
        if (cycles > 8)
          $fatal(1, "REQ-MEM-015: CCU PREPARE response was not accepted");
      end
      i_ccu_prepare_valid = 1'b1;
      i_ccu_prepare_tag = expected_tag;
      i_ccu_prepare_err = expected_error;
      @(posedge i_clk_cluster);
      @(negedge i_clk_cluster);
      i_ccu_prepare_valid = 1'b0;
      i_ccu_prepare_err = 1'b0;
      check(o_cmo_error === expected_error, "REQ-MEM-017: PREPARE status is retained for CMO response");
    end
  endtask

  task automatic accept_maintenance(input logic [1:0] expected_op,
                                    input logic [51:0] expected_pa_line);
    int unsigned cycles;
    begin
      cycles = 0;
      while (o_maint_valid !== 1'b1) begin
        @(negedge i_clk_cluster);
        cycles++;
        if (cycles > 8)
          $fatal(1, "REQ-MEM-016: LLC maintenance request did not appear");
      end
      check(o_maint_op === expected_op, "REQ-MEM-016: LLC maintenance opcode matches CBO");
      check(o_maint_pa_line === expected_pa_line, "REQ-MEM-016: LLC maintenance uses requested physical line");
      repeat (2) begin
        @(negedge i_clk_cluster);
        check(o_maint_valid === 1'b1, "REQ-MEM-016: maintenance VALID remains asserted under backpressure");
        check(o_maint_pa_line === expected_pa_line, "REQ-MEM-016: maintenance address stays stable under backpressure");
      end
      i_maint_ready = 1'b1;
      @(posedge i_clk_cluster);
      @(negedge i_clk_cluster);
      i_maint_ready = 1'b0;
      check(o_maint_valid === 1'b0, "REQ-MEM-016: maintenance request ends after handshake");
    end
  endtask

  task automatic finish_context(input logic [2:0] expected_tag,
                                input logic expected_commit,
                                input logic finish_same_cycle);
    int unsigned cycles;
    begin
      cycles = 0;
      while (o_ccu_finish_valid !== 1'b1) begin
        @(negedge i_clk_cluster);
        cycles++;
        if (cycles > 8)
          $fatal(1, "REQ-MEM-015: CCU finish request did not appear");
      end
      check(o_ccu_finish_tag === expected_tag, "REQ-MEM-015: finish uses PREPARE transaction tag");
      check(o_ccu_finish_commit === expected_commit, "REQ-MEM-015: finish selects COMMIT or ABORT from result");
      repeat (2) begin
        @(negedge i_clk_cluster);
        check(o_ccu_finish_valid === 1'b1, "REQ-MEM-015: finish VALID remains asserted under backpressure");
        check(o_ccu_finish_tag === expected_tag, "REQ-MEM-015: finish tag remains stable under backpressure");
        check(o_ccu_finish_commit === expected_commit, "REQ-MEM-015: finish action remains stable under backpressure");
      end
      i_ccu_finish_ready = 1'b1;
      i_ccu_finish_done = finish_same_cycle;
      @(posedge i_clk_cluster);
      @(negedge i_clk_cluster);
      i_ccu_finish_ready = 1'b0;
      i_ccu_finish_done = 1'b0;
      if (!finish_same_cycle) begin
        check(o_ccu_finish_valid === 1'b0, "REQ-MEM-015: finish request deasserts after acceptance");
        repeat (2) @(negedge i_clk_cluster);
        i_ccu_finish_done = 1'b1;
        @(posedge i_clk_cluster);
        @(negedge i_clk_cluster);
        i_ccu_finish_done = 1'b0;
      end
    end
  endtask

  task automatic check_response(input logic expected_error,
                                input logic [63:0] expected_vaddr,
                                input logic [63:0] expected_pc,
                                input logic [1:0] expected_hart);
    int unsigned cycles;
    begin
      cycles = 0;
      while (o_cmo_done !== 1'b1) begin
        @(negedge i_clk_cluster);
        cycles++;
        if (cycles > 8)
          $fatal(1, "REQ-MEM-017: CMO completion pulse did not appear");
      end
      check(o_cmo_error === expected_error, "REQ-MEM-017: completion reports expected operation status");
      check(o_cmo_vaddr === expected_vaddr, "REQ-MEM-017: response retains original effective address");
      check(o_cmo_pc === expected_pc, "REQ-MEM-017: response retains faulting instruction PC");
      check(o_cmo_hart === expected_hart, "REQ-MEM-017: response retains issuing hart");
      @(negedge i_clk_cluster);
      check(o_cmo_done === 1'b0, "REQ-MEM-017: completion is a one-cycle pulse");
    end
  endtask

  task automatic test_clean_success;
    begin
      reg_test_count++;
      reset_dut();
      send_command(LPARA_CMO_CLEAN, LPARA_PA_LINE, LPARA_VADDR, LPARA_PC, 2'd1);
      accept_begin(LPARA_CMO_CLEAN, LPARA_PA_LINE, 2'd1, 1'b1);
      complete_prepare(LPARA_TAG, 1'b0);
      accept_maintenance(LPARA_CMO_CLEAN, LPARA_PA_LINE);
      i_maint_done = 1'b1;
      i_maint_error = 1'b0;
      @(posedge i_clk_cluster);
      @(negedge i_clk_cluster);
      i_maint_done = 1'b0;
      finish_context(LPARA_TAG, 1'b1, 1'b0);
      check_response(1'b0, LPARA_VADDR, LPARA_PC, 2'd1);
    end
  endtask

  task automatic test_prepare_error_aborts_without_llc;
    int unsigned cycles;
    begin
      reg_test_count++;
      reset_dut();
      send_command(LPARA_CMO_CLEAN, LPARA_PA_LINE, LPARA_VADDR, LPARA_PC, 2'd1);
      accept_begin(LPARA_CMO_CLEAN, LPARA_PA_LINE, 2'd1, 1'b1);
      complete_prepare(LPARA_TAG, 1'b1);
      cycles = 0;
      repeat (3) begin
        @(negedge i_clk_cluster);
        check(o_maint_valid === 1'b0, "REQ-MEM-015: failed PREPARE must not issue LLC maintenance");
        cycles++;
      end
      check(cycles == 3, "REQ-MEM-015: PREPARE error bypass check exercised for three cycles");
      finish_context(LPARA_TAG, 1'b0, 1'b1);
      check_response(1'b1, LPARA_VADDR, LPARA_PC, 2'd1);
    end
  endtask

  task automatic test_maintenance_error_aborts;
    begin
      reg_test_count++;
      reset_dut();
      send_command(LPARA_CMO_FLUSH, LPARA_PA_LINE, LPARA_VADDR, LPARA_PC, 2'd0);
      accept_begin(LPARA_CMO_FLUSH, LPARA_PA_LINE, 2'd0, 1'b1);
      complete_prepare(LPARA_TAG, 1'b0);
      accept_maintenance(LPARA_CMO_FLUSH, LPARA_PA_LINE);
      i_maint_done = 1'b1;
      i_maint_error = 1'b1;
      @(posedge i_clk_cluster);
      @(negedge i_clk_cluster);
      i_maint_done = 1'b0;
      i_maint_error = 1'b0;
      finish_context(LPARA_TAG, 1'b0, 1'b0);
      check_response(1'b1, LPARA_VADDR, LPARA_PC, 2'd0);
    end
  endtask

  task automatic test_true_invalidate_success;
    begin
      reg_test_count++;
      reset_dut();
      send_command(LPARA_CMO_INVAL, LPARA_PA_LINE, LPARA_VADDR, LPARA_PC, 2'd1);
      accept_begin(LPARA_CMO_INVAL, LPARA_PA_LINE, 2'd1, 1'b0);
      complete_prepare(LPARA_TAG, 1'b0);
      accept_maintenance(LPARA_CMO_INVAL, LPARA_PA_LINE);
      i_maint_done = 1'b1;
      i_maint_error = 1'b0;
      @(posedge i_clk_cluster);
      @(negedge i_clk_cluster);
      i_maint_done = 1'b0;
      finish_context(LPARA_TAG, 1'b1, 1'b1);
      check_response(1'b0, LPARA_VADDR, LPARA_PC, 2'd1);
    end
  endtask

  task automatic test_illegal_command_rejected;
    begin
      reg_test_count++;
      reset_dut();
      @(negedge i_clk_cluster);
      i_cmo_valid = 1'b1;
      i_cmo_op = LPARA_CMO_RESERVED;
      i_cmo_hart = 2'd0;
      #1;
      check(o_cmo_ready === 1'b0, "REQ-MEM-015: reserved CMO opcode is rejected before handshake");
      i_cmo_op = LPARA_CMO_CLEAN;
      i_cmo_hart = 2'd2;
      #1;
      if (PARA_CPU_NUM < 4)
        check(o_cmo_ready === 1'b0, "REQ-MEM-015: inactive hart index is rejected before handshake");
      else
        check(o_cmo_ready === 1'b1, "REQ-MEM-015: all 2-bit hart indices are active in a 4-hart profile");
      i_cmo_valid = 1'b0;
      @(posedge i_clk_cluster);
      @(negedge i_clk_cluster);
      check(o_ccu_begin_valid === 1'b0, "REQ-MEM-015: rejected command does not allocate CCU work");
      check(o_maint_valid === 1'b0, "REQ-MEM-016: rejected command does not issue LLC work");
      check(o_cmo_done === 1'b0, "REQ-MEM-017: rejected command produces no completion");
    end
  endtask

  initial begin
    reg_check_count = 0;
    reg_test_count = 0;
    i_rst_n_cluster = 1'b0;
    idle_inputs();
    test_clean_success();
    test_prepare_error_aborts_without_llc();
    test_maintenance_error_aborts();
    test_true_invalidate_success();
    test_illegal_command_rejected();
    $display("CMO directed tests: %0d; checks: %0d", reg_test_count, reg_check_count);
    $display("assertion failures: 0, assertions never exercised: 0");
    $display("PASS: CMO sequencing, backpressure, metadata, errors, and invalid-command rejection");
    $finish;
  end
endmodule
