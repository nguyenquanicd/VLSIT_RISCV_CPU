`timescale 1ns/1ps
module tb_llc_refill_error;
  localparam axi_llc_pkg::llc_cfg_t CFG='{SetAssociativity:1,NumLines:8,
    NumBlocks:2,BlockSize:64,TagLength:57,IndexLength:3,
    BlockOffsetLength:1,ByteOffsetLength:3,SPMLength:128};
  typedef struct packed {logic [1:0] x_resp; logic refill;
    logic [63:0] a_x_addr; logic way_ind;} desc_t;
  typedef struct packed {axi_llc_pkg::cache_unit_e cache_unit;
    logic way_ind; logic [2:0] line_addr; logic blk_offset,we;
    logic [63:0] data; logic [7:0] strb;} way_t;
  typedef struct packed {logic [63:0] data; logic last; logic [1:0] resp;} r_t;
  logic clk=0,rst=0,iv=0,ir,ov,orr=0,rv=0,rr,wv,wr=1;
  desc_t inp='0,outp;
  way_t way_req;
  r_t r='0;
  always #5 clk=~clk;
  axi_llc_r_master #(.Cfg(CFG),.desc_t(desc_t),.way_inp_t(way_t),.r_chan_t(r_t)) dut(
    .clk_i(clk),.rst_ni(rst),.desc_i(inp),.desc_valid_i(iv),.desc_ready_o(ir),
    .desc_o(outp),.desc_valid_o(ov),.desc_ready_i(orr),
    .r_chan_mst_i(r),.r_chan_valid_i(rv),.r_chan_ready_o(rr),
    .way_inp_o(way_req),.way_inp_valid_o(wv),.way_inp_ready_i(wr));
  task automatic run_case(input logic [1:0] first, input logic [1:0] last);
    @(negedge clk); inp='{x_resp:0,refill:1,a_x_addr:64'h80003000,way_ind:1}; iv=1;
    do @(posedge clk); while(!ir);
    @(negedge clk); iv=0; r='{data:64'h0123,last:0,resp:first}; rv=1;
    do @(posedge clk); while(!rr);
    @(negedge clk); r='{data:64'h4567,last:1,resp:last};
    do @(posedge clk); while(!rr);
    @(negedge clk); rv=0;
    if(!ov || outp.x_resp!=(first!=0 ? first:last)) $fatal(1,"refill lost beat error");
    repeat(4) begin
      @(negedge clk);
      if(!ov || outp.x_resp!=(first!=0 ? first:last)) $fatal(1,"stalled descriptor lost error");
    end
    orr=1; @(negedge clk); orr=0;
  endtask
  initial begin
    repeat(3) @(negedge clk); rst=1;
    run_case(2'b10,0);
    run_case(0,2'b11);
    run_case(0,0);
    $display("PASS: LLC first/last RRESP error aggregation, descriptor stall, clean retry");
    $finish;
  end
  initial begin #10000; $fatal(1,"refill-error watchdog"); end
endmodule
