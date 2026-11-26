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
  task automatic request_mask(input logic [3:0] hart_mask,
                              input int phase,
                              output int accepted_tag);
    int wait_count;
    int first_hart;
    begin
      wait_count=0;
      while ((o_probe_req_valid & hart_mask) != hart_mask) begin
        @(negedge i_clk_cluster);
        wait_count++;
        if (wait_count > 40) begin
          $display("valid=%b owner_valid=%b owner_tag=%h claim_found=%b claim_tag=%h needed=%h all_owned=%h available=%h ctx_valid=%h active=%h phase0=%h phase1=%h expected0=%b expected1=%b",
                   o_probe_req_valid,dut.reg_phase_owner_valid,dut.reg_phase_owner_tag,
                   dut.w_claim_found,dut.w_claim_tag,dut.w_claim_needed,
                   dut.w_claim_all_owned,dut.w_claim_available,i_ctx_valid,
                   i_ctx_phase_active,i_ctx_phase[0],i_ctx_phase[1],
                   i_ctx_ack_expected[0],i_ctx_ack_expected[1]);
          $fatal(1,"probe mask timeout mask=%b phase=%0d",hart_mask,phase);
        end
      end
      first_hart=0;
      while (~hart_mask[first_hart]) first_hart++;
      accepted_tag=int'(o_probe_req_tag[first_hart]);
      for (int hart_idx=0; hart_idx<4; hart_idx++) begin
        if (hart_mask[hart_idx]) begin
          if (o_probe_req_tag[hart_idx] != 3'(accepted_tag))
            $fatal(1,"split claim: harts selected tags %0d and %0d",
                   accepted_tag,o_probe_req_tag[hart_idx]);
          if (o_probe_req_phase[hart_idx] != 2'(phase))
            $fatal(1,"wrong phase on hart %0d",hart_idx);
        end
      end
      i_probe_req_ready=i_probe_req_ready | hart_mask;
      @(negedge i_clk_cluster);
      i_probe_req_ready=i_probe_req_ready & ~hart_mask;
    end
  endtask
  task automatic response_mask(input logic [3:0] hart_mask,
                               input int tag,
                               input int phase,
                               input bit error);
    int wait_count;
    begin
      for (int hart_idx=0; hart_idx<4; hart_idx++) begin
        if (hart_mask[hart_idx]) begin
          i_probe_rsp_valid[hart_idx]=1'b1;
          i_probe_rsp_tag[hart_idx]=3'(tag);
          i_probe_rsp_pa_line[hart_idx]=i_ctx_pa_line[tag];
          i_probe_rsp_phase[hart_idx]=2'(phase);
          i_probe_rsp_state[hart_idx]=i_ctx_target_state[tag];
          i_probe_rsp_err[hart_idx]=error;
          i_probe_rsp_wback_done[hart_idx]=1'b0;
        end
      end
      @(negedge i_clk_cluster);
      i_probe_rsp_valid=i_probe_rsp_valid & ~hart_mask;
      wait_count=0;
      while ((o_ack_valid & hart_mask) != hart_mask) begin
        @(negedge i_clk_cluster);
        wait_count++;
        if (wait_count > 40)
          $fatal(1,"ACK mask timeout tag=%0d phase=%0d",tag,phase);
      end
      for (int hart_idx=0; hart_idx<4; hart_idx++) begin
        if (hart_mask[hart_idx]
            & ((o_ack_tag[hart_idx] != 3'(tag))
               | (o_ack_phase[hart_idx] != 2'(phase))
               | (o_ack_err[hart_idx] != error)))
          $fatal(1,"ACK association failed hart=%0d tag=%0d phase=%0d",
                 hart_idx,tag,phase);
      end
      i_ctx_ack_received[tag]=i_ctx_ack_received[tag] | hart_mask;
      i_ctx_phase_active[tag]=1'b0;
      @(negedge i_clk_cluster);
    end
  endtask
  initial begin
    int winner_tag;
    int loser_tag;
    int accepted_tag;
    int wait_count;
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

    // Reset the scheduler, then skew H3's local round-robin pointer only.
    @(negedge i_clk_cluster);
    i_rst_n_cluster=0;
    i_ctx_valid='0;
    i_ctx_phase_active='0;
    i_ctx_ack_expected='0;
    i_ctx_ack_received='0;
    i_probe_req_ready='0;
    i_probe_rsp_valid='0;
    repeat(2) @(negedge i_clk_cluster);
    i_rst_n_cluster=1;
    @(negedge i_clk_cluster);

    // Warm-up tag 0 on H3 advances only H3's per-hart request pointer.
    i_ctx_valid[0]=1'b1;
    i_ctx_phase_active[0]=1'b1;
    i_ctx_pa_line[0]=52'h8000400;
    i_ctx_target_state[0]=2'd1;
    i_ctx_phase[0]=2'd0;
    i_ctx_ack_expected[0]=4'b1000;
    request_mask(4'b1000,0,accepted_tag);
    if (accepted_tag!=0) $fatal(1,"warm-up selected wrong context");
    response_mask(4'b1000,0,0,0);
    i_ctx_phase[0]=2'd1;
    i_ctx_ack_received[0]='0;
    i_ctx_phase_active[0]=1'b1;
    request_mask(4'b1000,1,accepted_tag);
    if (accepted_tag!=0) $fatal(1,"warm-up terminal selected wrong context");
    response_mask(4'b1000,0,1,0);
    i_ctx_valid[0]=1'b0;

    // Two transactions now require H2 and H3. The legacy independent RR
    // pointers would split ownership: H2 chooses tag 0, H3 chooses tag 1.
    i_ctx_pa_line[0]=52'h8000500;
    i_ctx_pa_line[1]=52'h8000600;
    i_ctx_target_state[0]=2'd1;
    i_ctx_target_state[1]=2'd1;
    i_ctx_phase[1:0]='0;
    i_ctx_ack_expected[0]=4'b1100;
    i_ctx_ack_expected[1]=4'b1100;
    i_ctx_ack_received[1:0]='0;
    i_ctx_valid[1:0]=2'b11;
    i_ctx_phase_active[1:0]=2'b11;
    request_mask(4'b1100,0,winner_tag);
    if ((winner_tag!=0) & (winner_tag!=1))
      $fatal(1,"invalid winning tag %0d",winner_tag);
    response_mask(4'b1100,winner_tag,0,0);
    i_ctx_phase[winner_tag]=2'd1;
    i_ctx_ack_received[winner_tag]='0;
    i_ctx_phase_active[winner_tag]=1'b1;
    request_mask(4'b1100,1,accepted_tag);
    if (accepted_tag!=winner_tag)
      $fatal(1,"terminal phase changed owner tag");
    response_mask(4'b1100,winner_tag,1,0);
    i_ctx_valid[winner_tag]=1'b0;

    loser_tag=winner_tag ^ 1;
    request_mask(4'b1100,0,accepted_tag);
    if (accepted_tag!=loser_tag)
      $fatal(1,"waiting context did not claim both slots after release");
    response_mask(4'b1100,loser_tag,0,0);
    i_ctx_phase[loser_tag]=2'd1;
    i_ctx_ack_received[loser_tag]='0;
    i_ctx_phase_active[loser_tag]=1'b1;
    request_mask(4'b1100,1,accepted_tag);
    if (accepted_tag!=loser_tag)
      $fatal(1,"waiting context changed owner during terminal phase");
    response_mask(4'b1100,loser_tag,1,0);
    i_ctx_valid[loser_tag]=1'b0;

    // Disjoint one-hart masks can still claim and issue concurrently.
    @(negedge i_clk_cluster);
    i_rst_n_cluster=0;
    i_ctx_valid='0;
    i_ctx_phase_active='0;
    i_ctx_ack_expected='0;
    i_ctx_ack_received='0;
    i_probe_req_ready='0;
    i_probe_rsp_valid='0;
    repeat(2) @(negedge i_clk_cluster);
    i_rst_n_cluster=1;
    @(negedge i_clk_cluster);
    i_ctx_pa_line[0]=52'h8000700;
    i_ctx_pa_line[1]=52'h8000800;
    i_ctx_valid[1:0]=2'b11;
    i_ctx_phase_active[1:0]=2'b11;
    i_ctx_phase[1:0]='0;
    i_ctx_ack_expected[0]=4'b0001;
    i_ctx_ack_expected[1]=4'b0010;
    wait_count=0;
    while (~(o_probe_req_valid[0] & o_probe_req_valid[1])) begin
      @(negedge i_clk_cluster);
      wait_count++;
      if (wait_count>40) $fatal(1,"disjoint target requests did not overlap");
    end
    if ((o_probe_req_tag[0]!=3'd0) | (o_probe_req_tag[1]!=3'd1))
      $fatal(1,"disjoint contexts were not independently issued");
    if(o_coh_proto_diag_event!=0) $fatal(1,"unexpected protocol diagnostic");
    $display("PASS: phase ownership, atomic multi-hart claim, and disjoint progress");
    $finish;
  end
  initial begin #10000; $fatal(1,"phase ownership watchdog"); end
endmodule
