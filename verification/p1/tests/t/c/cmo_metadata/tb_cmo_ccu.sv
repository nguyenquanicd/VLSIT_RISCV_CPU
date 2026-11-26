`timescale 1ns/1ps
module tb_cmo_ccu #(parameter int HARTS=4);
  logic clk=0,rst=0,bv=0,br,pv,pr=0,pe,fv=0,fr,fc=0,fd;
  logic [1:0] op=0;
  logic [51:0] line_addr=52'h1234;
  logic [2:0] pt,ft=0;
  logic [HARTS-1:0] gv,probe_valid;
  logic [HARTS-1:0][2:0] probe_tag;
  logic [HARTS-1:0][51:0] probe_line;
  logic [HARTS-1:0][1:0] probe_phase,probe_target;
  logic [HARTS-1:0] probe_wb;
  always #5 clk=~clk;
  m_vlsit_riscv_coh_fabric #(.PARA_CPU_NUM(32'(HARTS)),.PARA_CMO_EN(32'd1)) dut (
    .i_clk_cluster(clk),.i_rst_n_cluster(rst),
    .i_ccu_begin_valid(bv),.o_ccu_begin_ready(br),.i_ccu_begin_op(op),
    .i_ccu_begin_pa_line(line_addr),.i_ccu_begin_hart(2'b0),
    .i_ccu_begin_wback_en(op!=2'd2),.o_ccu_prepare_valid(pv),
    .i_ccu_prepare_ready(pr),.o_ccu_prepare_tag(pt),.o_ccu_prepare_err(pe),
    .i_ccu_finish_valid(fv),.o_ccu_finish_ready(fr),.i_ccu_finish_tag(ft),
    .i_ccu_finish_commit(fc),.o_ccu_finish_done(fd),
    .i_req_valid('0),.i_req_id('0),.i_req_pa_line('0),.i_req_kind('0),
    .o_gnt_valid(gv),.i_gnt_ready('1),
    .o_probe_req_valid(probe_valid),.i_probe_req_ready('1),
    .o_probe_req_tag(probe_tag),.o_probe_req_pa_line(probe_line),
    .o_probe_req_phase(probe_phase),.o_probe_req_target_state(probe_target),
    .o_probe_req_wback_en(probe_wb),.i_probe_rsp_valid('0),
    .i_probe_rsp_tag('0),.i_probe_rsp_pa_line('0),.i_probe_rsp_phase('0),
    .i_probe_rsp_state('0),.i_probe_rsp_err('0),.i_probe_rsp_wback_done('0),
    .i_same_line_lock_stall(1'b0));
  task automatic command(input logic [1:0] cmd,input logic success);
    @(negedge clk); op=cmd; bv=1;
    do @(posedge clk); while(!br);
    @(negedge clk); bv=0;
    wait(pv);
    repeat(3) begin
      @(negedge clk);
      if(!pv || pe || gv!=0 || probe_valid!=0 || !dut.reg_cmo_active)
        $fatal(1,"absent-directory CMO PREPARE/hold failed");
    end
    ft=pt; pr=1;
    @(posedge clk); @(negedge clk); pr=0;
    // Reject another context's finish; it must not release this line lock.
    ft=pt^3'd1; fv=1; fc=success;
    repeat(2) begin @(negedge clk); if(fr || fd) $fatal(1,"wrong-tag finish accepted"); end
    ft=pt;
    do @(posedge clk); while(!fr);
    @(negedge clk); fv=0;
    wait(fd);
    if(gv!=0) $fatal(1,"CMO completion leaked onto CPU grant channel");
    @(posedge clk); @(negedge clk);
    if(dut.reg_cmo_active || dut.w_ctx_valid!=0)
      $fatal(1,"CMO terminal context was not released");
  endtask
  initial begin
    repeat(2) @(negedge clk); rst=1;
    command(0,1); command(1,1); command(2,1); command(0,0);
    $display("PASS: native CCU CMO miss PREPARE, held context, wrong-tag rejection, COMMIT and ABORT");
    $finish;
  end
  initial begin #100000; $fatal(1,"CMO CCU watchdog"); end
endmodule
