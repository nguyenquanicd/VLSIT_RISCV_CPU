`timescale 1ns/1ps
module tb_llc_pending;
  localparam axi_llc_pkg::llc_cfg_t CFG = '{SetAssociativity:1, NumLines:8,
    NumBlocks:2, BlockSize:64, TagLength:57, IndexLength:3,
    BlockOffsetLength:1, ByteOffsetLength:3, SPMLength:128};
  typedef logic [0:0] way_t;
  typedef struct packed {
    axi_llc_pkg::tag_mode_e mode;
    way_t indicator;
    logic [2:0] index;
    logic [56:0] tag;
    logic dirty;
    logic [1:0] maint_op;
  } request_t;
  typedef struct packed {
    way_t indicator;
    logic hit, evict;
    logic [56:0] evict_tag;
  } response_t;

  logic clk=0,rst=0,iv=0,ir,ov,orr=0,commit=0,bist;
  logic refill_done=0, refill_error=0;
  logic [2:0] refill_index=0;
  way_t bist_res;
  request_t req;
  response_t rsp;
  always #5 clk=~clk;
  axi_llc_tag_store #(.Cfg(CFG),.way_ind_t(way_t),
    .store_req_t(request_t),.store_res_t(response_t)) dut (
    .clk_i(clk),.rst_ni(rst),.test_i(1'b0),.flush_commit_i(1'b0),
    .wb_commit_i(commit),.wb_error_i(1'b0),
    .refill_done_i(refill_done),.refill_error_i(refill_error),
    .refill_way_i(1'b1),.refill_index_i(refill_index),.maint_wb_done_i(1'b0),.maint_wb_error_i(1'b0),
    .maint_done_o(),.maint_error_o(),
    .spm_lock_i(1'b0),.flushed_i(1'b0),.req_i(req),.valid_i(iv),
    .ready_o(ir),.res_o(rsp),.valid_o(ov),.ready_i(orr),
    .bist_res_o(bist_res),.bist_valid_o(bist));
  task automatic send(input axi_llc_pkg::tag_mode_e mode, input int idx,
                       input int tag_value, input logic dirty);
    @(negedge clk);
    req='{mode:mode,indicator:1'b1,index:3'(idx),tag:57'(tag_value),dirty:dirty,maint_op:2'b0}; iv=1;
    do @(posedge clk); while(!ir);
    @(negedge clk); iv=0;
  endtask
  task automatic receive(input logic eh,input logic ee);
    while(!ov) @(negedge clk);
    if(rsp.hit!==eh || rsp.evict!==ee) $fatal(1,"tag response mismatch");
    orr=1; @(posedge clk); @(negedge clk); orr=0;
  endtask
  task automatic ack();
    @(negedge clk); commit=1;
    @(posedge clk); @(negedge clk); commit=0;
  endtask
  task automatic refill(input int idx,input bit error=0);
    @(negedge clk); refill_index=3'(idx); refill_error=error; refill_done=1;
    @(posedge clk); @(negedge clk); refill_done=0;
  endtask
  initial begin
    req='0;
    repeat(2) @(negedge clk); rst=1;
    send(axi_llc_pkg::Bist,0,0,0); wait(bist); @(negedge clk);
    for(int k=0;k<8;k++) begin
      send(axi_llc_pkg::Lookup,k,16+k,1); receive(0,0);
      refill(k); wait(dut.pending_valid_q==0);
    end
    // Repeat beyond the four-entry pointer range and check tag identity after wrap.
    for(int round_idx=0;round_idx<3;round_idx++) begin
      if(round_idx!=0) begin
        for(int k=0;k<5;k++) begin
          send(axi_llc_pkg::Lookup,k,32+round_idx*16+k,1); receive(1,0);
        end
      end
      for(int k=0;k<4;k++) begin
        send(axi_llc_pkg::Lookup,k,48+round_idx*16+k,0); receive(0,1);
      end
      if(dut.pending_valid_q!==4'b1111) $fatal(1,"table did not reach full");
      send(axi_llc_pkg::Lookup,4,48+round_idx*16+4,0);
      repeat(4) begin
        @(negedge clk);
        if(ov) $fatal(1,"dirty replacement accepted with pending table full");
      end
      // A B completion must escape a full-table lookup stall.
      ack(); refill(0); receive(0,1);
      for(int k=1;k<5;k++) begin ack(); refill(k); repeat(2) @(negedge clk); end
      wait(dut.pending_valid_q==0);
      for(int k=0;k<5;k++) begin
        send(axi_llc_pkg::Lookup,k,48+round_idx*16+k,0); receive(1,0);
      end
    end
    // Failed refill invalidates its allocation; a retry must miss, not hit poison.
    send(axi_llc_pkg::Lookup,6,123,0); receive(0,1); ack(); refill(6,1);
    wait(dut.pending_valid_q==0);
    send(axi_llc_pkg::Lookup,6,123,0); receive(0,0); refill(6);
    wait(dut.pending_valid_q==0);
    send(axi_llc_pkg::Lookup,6,123,0); receive(1,0);
    $display("PASS: failed LLC refill invalidated, retry refilled successfully");
    $display("PASS: LLC pending table full, completion escape, and 15-entry pointer wraparound");
    $finish;
  end
  initial begin #100000; $fatal(1,"pending table timeout/deadlock"); end
endmodule
