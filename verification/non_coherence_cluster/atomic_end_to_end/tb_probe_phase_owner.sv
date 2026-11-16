`timescale 1ns/1ps
// DEC-038: a cache's PREPARE service remains pinned through COMMIT/ABORT.
module tb_probe_phase_owner;
  logic i_clk_cluster=0, i_rst_n_cluster=0;
  always #5 i_clk_cluster=~i_clk_cluster;
  logic [7:0] i_ctx_valid=0, i_ctx_phase_active=0, i_ctx_wback_en=0;
  logic [7:0][51:0] i_ctx_pa_line=0;
  logic [7:0][1:0] i_ctx_phase=0, i_ctx_target_state=0;
  logic [7:0][3:0] i_ctx_ack_expected=0, i_ctx_ack_received=0;
  logic [3:0] o_probe_req_valid, i_probe_req_ready='0;
  logic [3:0][2:0] o_probe_req_tag;
  logic [3:0][51:0] o_probe_req_pa_line;
  logic [3:0][1:0] o_probe_req_phase, o_probe_req_target_state;
  logic [3:0] o_probe_req_wback_en;
  logic [3:0] i_probe_rsp_valid=0, o_probe_rsp_ready;
  logic [3:0][2:0] i_probe_rsp_tag=0;
  logic [3:0][51:0] i_probe_rsp_pa_line=0;
  logic [3:0][1:0] i_probe_rsp_phase=0, i_probe_rsp_state=0;
  logic [3:0] i_probe_rsp_err=0, i_probe_rsp_wback_done=0;
  logic [3:0] o_ack_valid, i_ack_ready='1;
  logic [3:0][2:0] o_ack_tag;
  logic [3:0][1:0] o_ack_phase, o_ack_state;
  logic [3:0] o_ack_err, o_ack_wback_done, o_coh_proto_diag_event;
  m_vlsit_riscv_probe_scheduler #(.PARA_CPU_NUM(4),.PARA_COH_TXN_NUM(8)) dut(.*);
  task automatic request(input int tag, input int phase);
    int n;
    n=0;
    while(!o_probe_req_valid[0]) begin
      @(negedge i_clk_cluster);
      n++;
      if(n>30) $fatal(1,"missing eligible probe tag=%0d phase=%0d",tag,phase);
    end
    if(o_probe_req_tag[0]!=3'(tag) || o_probe_req_phase[0]!=2'(phase))
      $fatal(1,"wrong context displaced phase owner");
    i_probe_req_ready[0]=1;
    @(negedge i_clk_cluster);
    i_probe_req_ready[0]=0;
  endtask
  task automatic response(input int tag, input int phase, input bit error);
    i_probe_rsp_valid[0]=1;
    i_probe_rsp_tag[0]=3'(tag);
    i_probe_rsp_pa_line[0]=i_ctx_pa_line[tag];
    i_probe_rsp_phase[0]=2'(phase);
    i_probe_rsp_err[0]=error;
    @(negedge i_clk_cluster);
    i_probe_rsp_valid[0]=0;
    wait(o_ack_valid[0]);
    if(o_ack_tag[0]!=3'(tag) || o_ack_phase[0]!=2'(phase) || o_ack_err[0]!=error)
      $fatal(1,"ACK association failed");
    // The table records completion on the ACK handshake.
    i_ctx_ack_received[tag][0]=1;
    i_ctx_phase_active[tag]=0;
    repeat(3) @(negedge i_clk_cluster);
  endtask
  initial begin
    repeat(3) @(negedge i_clk_cluster);
    i_rst_n_cluster=1;
    i_ctx_pa_line[0]=52'h8000100;
    i_ctx_pa_line[1]=52'h8000200;
    i_ctx_ack_expected[0]=1;
    i_ctx_ack_expected[1]=1;
    i_ctx_valid[1:0]=2'b11;
    i_ctx_phase_active[1:0]=2'b11;
    request(0,0);
    response(0,0,0);
    repeat(8) begin
      if(o_probe_req_valid[0]) $fatal(1,"unrelated PREPARE between owner phases");
      @(negedge i_clk_cluster);
    end
    i_ctx_phase[0]=1; i_ctx_ack_received[0]=0; i_ctx_phase_active[0]=1;
    request(0,1); response(0,1,0); i_ctx_valid[0]=0;
    request(1,0); response(1,0,1);
    // PREPARE error must retain the service slot for matching ABORT.
    i_ctx_valid[2]=1; i_ctx_pa_line[2]=52'h8000300;
    i_ctx_ack_expected[2]=1; i_ctx_phase_active[2]=1;
    repeat(8) begin
      if(o_probe_req_valid[0]) $fatal(1,"PREPARE error released service before ABORT");
      @(negedge i_clk_cluster);
    end
    i_ctx_phase[1]=2; i_ctx_ack_received[1]=0; i_ctx_phase_active[1]=1;
    request(1,2); response(1,2,0); i_ctx_valid[1]=0;
    request(2,0); response(2,0,0);
    i_ctx_phase[2]=1; i_ctx_ack_received[2]=0; i_ctx_phase_active[2]=1;
    request(2,1); response(2,1,0); i_ctx_valid[2]=0;
    if(o_coh_proto_diag_event!=0) $fatal(1,"unexpected protocol diagnostic");
    $display("PASS: probe phase ownership COMMIT and PREPARE-error/ABORT");
    $finish;
  end
  initial begin #10000; $fatal(1,"phase ownership watchdog"); end
endmodule
