`timescale 1ns/1ps
module tb;
  logic clk=0, rst_n=0; always #5 clk=~clk;
  logic [31:0] awaddr, wdata, araddr; logic awvalid, wvalid, arvalid, bready, rready; logic [3:0] wstrb=4'hF;
  wire awready, wready, arready, bvalid, rvalid; wire [1:0] bresp, rresp; wire [31:0] rdata;
  wire rq_v, rq_wr; wire [6:0] rq_a; wire [31:0] rq_wd; wire [3:0] rq_ws;
  m_vlsit_axil_reg_bridge dut(.i_clk_cluster(clk), .i_rst_n_cluster(rst_n),
    .i_axil_awaddr(awaddr), .i_axil_awprot(3'b0), .i_axil_awvalid(awvalid), .o_axil_awready(awready),
    .i_axil_wdata(wdata), .i_axil_wstrb(wstrb), .i_axil_wvalid(wvalid), .o_axil_wready(wready),
    .o_axil_bresp(bresp), .o_axil_bvalid(bvalid), .i_axil_bready(bready),
    .i_axil_araddr(araddr), .i_axil_arprot(3'b0), .i_axil_arvalid(arvalid), .o_axil_arready(arready),
    .o_axil_rdata(rdata), .o_axil_rresp(rresp), .o_axil_rvalid(rvalid), .i_axil_rready(rready),
    .o_reg_req_valid(rq_v), .o_reg_req_wr(rq_wr), .o_reg_req_addr(rq_a), .o_reg_req_wdata(rq_wd), .o_reg_req_wstrb(rq_ws),
    .i_reg_rsp_ready(rq_v), .i_reg_rsp_rdata(32'h1234), .i_reg_rsp_err(1'b0));
  integer regbus_wr=0, b_cnt=0;
  always @(posedge clk) if (rst_n) begin
    if (rq_v & rq_wr) begin regbus_wr = regbus_wr+1; $display("  RegBus WRITE addr=0x%0h data=0x%0h", rq_a, rq_wd); end
    if (bvalid & bready) begin b_cnt = b_cnt+1; $display("  B response resp=%0d", bresp); end
  end
  task automatic wr(input [31:0] a);
    begin
      regbus_wr=0; b_cnt=0;
      awaddr=a; wdata=32'hDEAD0000; awvalid=1; wvalid=1; bready=1;
      @(posedge clk); #1; 
      while (!(awready)) begin @(posedge clk); #1; end
      awvalid=0; wvalid=0;
      repeat (8) @(posedge clk);
      $display("write 0x%0h: RegBus writes=%0d, B responses=%0d", a, regbus_wr, b_cnt);
    end
  endtask
  initial begin
    awvalid=0; wvalid=0; arvalid=0; bready=1; rready=1; awaddr=0; wdata=0; araddr=0;
    repeat(3) @(posedge clk); #1 rst_n=1; repeat(2) @(posedge clk);
    $display("--- write to CFG_SPM_LOW (0x00): must be rejected (SPM disabled)");   wr(32'h00);
    $display("--- write to VERSION_LOW (0x40, read-only)");                          wr(32'h40);
    $display("--- write to CFG_FLUSH_LOW (0x08, allowed)");                          wr(32'h08);
    $display("--- write to unmapped 0x4C");                                          wr(32'h4C);
    $display("--- write misaligned 0x09");                                           wr(32'h09);
    $finish;
  end
endmodule
