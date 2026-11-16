`timescale 1ns/1ps
module tb;
  localparam TXN=8, SW=3;
  logic clk=0, rst_n=0; always #5 clk=~clk;
  logic [TXN-1:0] rv=0; logic [TXN-1:0][1:0] rb='0; logic [3:0] gr=0; wire [3:0] gv; wire [3:0][SW-1:0] gs;
  m_vlsit_riscv_coh_bank_arb #(.PARA_COH_TXN_NUM(TXN)) dut(.i_clk_cluster(clk), .i_rst_n_cluster(rst_n),
    .i_req_valid(rv), .i_req_bank(rb), .i_gnt_ready(gr), .o_gnt_valid(gv), .o_gnt_slot(gs));
  integer grants=0, delay;
  // consumer: accepts the grant when ready is high, drops the request DELAY cycles after the acceptance edge
  integer drop_cnt=-1;
  always @(posedge clk) if (rst_n) begin
    if (gv[0] & gr[0]) begin grants = grants+1; $display("  t=%0t grant accepted slot=%0d (count %0d)", $time, gs[0], grants); if (drop_cnt < 0) drop_cnt = delay; end
    if (drop_cnt==0) rv[2] <= 0;
    if (drop_cnt>=0) drop_cnt <= drop_cnt-1;
  end
  task automatic run(input integer d);
    begin
      delay=d; grants=0; drop_cnt=-1; rv=0; gr=0;
      @(posedge clk); #1 rv[2]=1; rb[2]=2'd0; gr[0]=1;
      repeat(12) @(posedge clk);
      $display("drop delay %0d cycle(s) after acceptance edge: grants for ONE request = %0d", d, grants);
      #1 rv=0; repeat(3) @(posedge clk);
    end
  endtask
  initial begin
    repeat(3) @(posedge clk); #1 rst_n=1; repeat(2) @(posedge clk);
    run(0); run(1); run(2);
    $finish;
  end
endmodule
