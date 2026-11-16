`timescale 1ns/1ps
module tb_cmo_arbiter #(parameter int HARTS=4);
  logic clk=0, rst=0;
  logic [3:0] valid=0, ready, done, err;
  logic [3:0][1:0] op='0;
  logic [3:0][51:0] pa='0;
  logic [3:0][63:0] va='0, pc='0;
  logic cv, cr=0, cd=0, ce=0;
  logic [1:0] co, ch;
  logic [51:0] cp;
  logic [63:0] cva, cpc;
  always #5 clk=~clk;
  m_vlsit_riscv_cmo_arbiter #(.PARA_CPU_NUM(32'(HARTS))) dut (
    .i_clk_cluster(clk), .i_rst_n_cluster(rst),
    .i_req_valid(valid), .o_req_ready(ready), .i_req_op(op),
    .i_req_pa_line(pa), .i_req_vaddr(va), .i_req_pc(pc),
    .o_rsp_done(done), .o_rsp_err(err), .o_cmo_valid(cv),
    .i_cmo_ready(cr), .o_cmo_op(co), .o_cmo_pa_line(cp),
    .o_cmo_vaddr(cva), .o_cmo_pc(cpc), .o_cmo_hart(ch),
    .i_cmo_done(cd), .i_cmo_err(ce));
  initial begin
    repeat(2) @(negedge clk);
    rst=1;
    for(int h=0;h<4;h++) begin
      pa[h]=52'(h+16); va[h]=64'(h+256); pc[h]=64'(h+512);
      op[h]=2'(h%3);
    end
    valid=4'((1 << HARTS)-1);
    for(int h=0;h<HARTS;h++) begin
      #1;
      if(ready !== (4'b1 << h)) $fatal(1,"round-robin selection mismatch");
      @(posedge clk); #1;
      valid[h]=0;
      if(!cv || ch!=2'(h) || cp!=52'(h+16) || cva!=64'(h+256) || cpc!=64'(h+512))
        $fatal(1,"buffered command metadata mismatch");
      // New contenders cannot replace the selected command under backpressure.
      repeat(3) begin
        @(negedge clk); pa[h]='1; va[h]='1; pc[h]='1;
        @(posedge clk); #1;
        if(!cv || ch!=2'(h) || cp!=52'(h+16) || cva!=64'(h+256) || cpc!=64'(h+512) || ready!=0)
          $fatal(1,"command changed during controller stall");
      end
      @(negedge clk); cr=1;
      @(posedge clk); #1; cr=0;
      if(cv || ready!=0 || done!=0) $fatal(1,"accepted command not held busy");
      @(negedge clk); cd=1; ce=1'(h%2);
      #1;
      if(done !== (4'b1 << h) || err !== ((h%2) ? (4'b1 << h) : 4'b0))
        $fatal(1,"completion delivered to incorrect hart");
      @(posedge clk); #1; cd=0; ce=0;
    end
    // An unsolicited completion with no accepted command cannot reach a hart.
    @(negedge clk); cd=1;
    #1; if(done!=0) $fatal(1,"unsolicited completion escaped");
    $display("PASS: CMO arbitration, stable payload, exclusive ownership, error demultiplexing");
    $finish;
  end
endmodule
