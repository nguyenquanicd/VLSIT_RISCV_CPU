`timescale 1ns/1ps
`include "axi/typedef.svh"
module tb_isolate_equivalence;
  typedef logic[31:0] addr_t;
  typedef logic[3:0] id_t;
  typedef logic[63:0] data_t;
  typedef logic[7:0] strb_t;
  typedef logic user_t;
  `AXI_TYPEDEF_ALL(test,addr_t,id_t,data_t,strb_t,user_t)
  logic clk=0,rst=0,isolate;
  test_req_t req,master[2];
  test_resp_t rsp,slave[2];
  logic[1:0] isolated;
  always #5 clk=~clk;
  `define CONNECT(K) .clk_i(clk),.rst_ni(rst),.slv_req_i(req),.slv_resp_o(slave[K]), \
    .mst_req_o(master[K]),.mst_resp_i(rsp),.isolate_i(isolate),.isolated_o(isolated[K])
  axi_isolate #(.NumPending(4),.axi_req_t(test_req_t),.axi_resp_t(test_resp_t),.AxiAddrWidth(32),.AxiDataWidth(64),.AxiIdWidth(4),.AxiUserWidth(1)) dut (`CONNECT(0));
  axi_isolate_lint_baseline #(.NumPending(4),.axi_req_t(test_req_t),.axi_resp_t(test_resp_t),.AxiAddrWidth(32),.AxiDataWidth(64),.AxiIdWidth(4),.AxiUserWidth(1)) reference_dut (`CONNECT(1));
  `undef CONNECT
  initial begin
    req='0;rsp='0;isolate=0;repeat(3) @(negedge clk);rst=1;
    for(int trial=0;trial<10000;trial++) begin
      @(negedge clk);
      for(int k=0;k<$bits(req);k++) req[k]=1'($urandom);
      for(int k=0;k<$bits(rsp);k++) rsp[k]=1'($urandom);
      isolate=($urandom_range(0,9)==0);
      #1;
      if(master[0]!==master[1] || slave[0]!==slave[1] || isolated[0]!==isolated[1])
        $fatal(1,"isolation outputs changed trial=%0d",trial);
    end
    $display("PASS: 10000 isolation refactor differential cycles");$finish;
  end
endmodule
