`timescale 1ns/1ps
// REQ-IF-008/010, TEST-054: independent endpoint cookies detect offset aliasing.
module tb_fault_map #(parameter int MODE=0);
 localparam logic [31:0] BASE=MODE==0?32'h01000000:(MODE==1?32'hffffa000:32'hffffb000);
 logic  i_clk_cluster;
 logic  i_rst_n_cluster;
 logic [31:0] i_axil_awaddr;
 logic [2:0] i_axil_awprot;
 logic  i_axil_awvalid;
 logic  o_axil_awready;
 logic [31:0] i_axil_wdata;
 logic [3:0] i_axil_wstrb;
 logic  i_axil_wvalid;
 logic  o_axil_wready;
 logic [1:0] o_axil_bresp;
 logic  o_axil_bvalid;
 logic  i_axil_bready;
 logic [31:0] i_axil_araddr;
 logic [2:0] i_axil_arprot;
 logic  i_axil_arvalid;
 logic  o_axil_arready;
 logic [31:0] o_axil_rdata;
 logic [1:0] o_axil_rresp;
 logic  o_axil_rvalid;
 logic  i_axil_rready;
 logic [1:0][31:0] o_axil_target_awaddr;
 logic [1:0][2:0] o_axil_target_awprot;
 logic [1:0] o_axil_target_awvalid;
 logic [1:0] i_axil_target_awready;
 logic [1:0][31:0] o_axil_target_wdata;
 logic [1:0][3:0] o_axil_target_wstrb;
 logic [1:0] o_axil_target_wvalid;
 logic [1:0] i_axil_target_wready;
 logic [1:0][1:0] i_axil_target_bresp;
 logic [1:0] i_axil_target_bvalid;
 logic [1:0] o_axil_target_bready;
 logic [1:0][31:0] o_axil_target_araddr;
 logic [1:0][2:0] o_axil_target_arprot;
 logic [1:0] o_axil_target_arvalid;
 logic [1:0] i_axil_target_arready;
 logic [1:0][31:0] i_axil_target_rdata;
 logic [1:0][1:0] i_axil_target_rresp;
 logic [1:0] i_axil_target_rvalid;
 logic [1:0] o_axil_target_rready;
 m_vlsit_riscv_axil_decode #(.PARA_AXIL_BASE_ADDR(BASE)) dut(.*);
 logic [1:0] have_aw=0,have_w=0;int read_count[2],write_count[2],checks=0;
 always #5 i_clk_cluster=~i_clk_cluster;
 for(genvar t=0;t<2;t++) begin:gen_endpoint
  assign i_axil_target_awready[t]=!have_aw[t] && !i_axil_target_bvalid[t];
  assign i_axil_target_wready[t]=!have_w[t] && !i_axil_target_bvalid[t];
  assign i_axil_target_arready[t]=!i_axil_target_rvalid[t];
  assign i_axil_target_bresp[t]=0;assign i_axil_target_rresp[t]=0;
  always @(posedge i_clk_cluster) begin
   if(!i_rst_n_cluster) begin
    have_aw[t]<=0;have_w[t]<=0;i_axil_target_bvalid[t]<=0;i_axil_target_rvalid[t]<=0;i_axil_target_rdata[t]<=0;
    read_count[t]=0;write_count[t]=0;
   end else begin
    if(o_axil_target_awvalid[t] && i_axil_target_awready[t])have_aw[t]<=1;
    if(o_axil_target_wvalid[t] && i_axil_target_wready[t]) begin
     have_w[t]<=1;
     if(o_axil_target_wstrb[t]!==i_axil_wstrb || o_axil_target_wdata[t]!==i_axil_wdata)$fatal(1,"write payload/strobe translation changed");
    end
    if(have_aw[t] && have_w[t])begin have_aw[t]<=0;have_w[t]<=0;i_axil_target_bvalid[t]<=1;write_count[t]++;end
    if(i_axil_target_bvalid[t] && o_axil_target_bready[t])i_axil_target_bvalid[t]<=0;
    if(i_axil_target_rvalid[t] && o_axil_target_rready[t])i_axil_target_rvalid[t]<=0;
    if(o_axil_target_arvalid[t] && i_axil_target_arready[t])begin
     i_axil_target_rvalid[t]<=1;
     i_axil_target_rdata[t]<=(t==0?32'ha0000000:32'hb0000000)^o_axil_target_araddr[t];read_count[t]++;
    end
   end
  end
 end
 task automatic rd(input logic[31:0] offset,input logic[31:0] expected,input logic[1:0] response);
  @(negedge i_clk_cluster);i_axil_araddr=BASE+offset;i_axil_arvalid=1;i_axil_rready=0;
  do @(posedge i_clk_cluster);while(!o_axil_arready);
  @(negedge i_clk_cluster);i_axil_arvalid=0;
  while(!o_axil_rvalid)@(negedge i_clk_cluster);
  repeat(3)@(negedge i_clk_cluster);
  checks++;if(o_axil_rresp!==response || o_axil_rdata!==expected)$fatal(1,"map read offset=%h got=%h/%h expected=%h/%h",offset,o_axil_rdata,o_axil_rresp,expected,response);
  i_axil_rready=1;@(negedge i_clk_cluster);i_axil_rready=0;
 endtask
 task automatic wr(input logic[31:0] offset,input logic[1:0] response);
  bit aw,w;aw=0;w=0;
  @(negedge i_clk_cluster);i_axil_awaddr=BASE+offset;i_axil_awvalid=1;i_axil_wdata=1;i_axil_wstrb=1;i_axil_wvalid=1;i_axil_bready=0;
  while(!aw || !w)begin
   @(posedge i_clk_cluster);if(i_axil_awvalid && o_axil_awready)aw=1;if(i_axil_wvalid && o_axil_wready)w=1;
   @(negedge i_clk_cluster);if(aw)i_axil_awvalid=0;if(w)i_axil_wvalid=0;
  end
  while(!o_axil_bvalid)@(negedge i_clk_cluster);
  repeat(3)@(negedge i_clk_cluster);
  checks++;if(o_axil_bresp!==response)$fatal(1,"map write response offset=%h",offset);
  i_axil_bready=1;@(negedge i_clk_cluster);i_axil_bready=0;
 endtask
 // IHI0022 AXI4-Lite plus REQ-IF-008: every assertion must activate.
 int protocol_hits[20];int rd_pending=0,aw_pending=0,w_pending=0;
 logic r_stall=0,b_stall=0;logic[33:0] r_saved;logic[1:0] b_saved;
 task automatic chk(input int k,input bit ante,input bit okay);
  if(ante)begin protocol_hits[k]++;if(!okay)$fatal(1,"AXIL map protocol assertion %0d",k);end
 endtask
 always @(posedge i_clk_cluster) begin
  if(!i_rst_n_cluster) begin
   rd_pending=0;aw_pending=0;w_pending=0;r_stall=0;b_stall=0;
   chk(19,1,!(o_axil_rvalid || o_axil_bvalid));
  end else begin
   if(i_axil_arvalid && o_axil_arready)rd_pending++;
   if(i_axil_awvalid && o_axil_awready)aw_pending++;
   if(i_axil_wvalid && o_axil_wready)w_pending++;
   chk(0,i_axil_arvalid,!$isunknown(i_axil_araddr));
   chk(1,i_axil_arvalid,i_axil_araddr[1:0]==0);
   chk(2,i_axil_arvalid,!$isunknown(i_axil_arprot));
   chk(3,o_axil_rvalid,o_axil_rresp inside {0,2,3});
   chk(4,o_axil_rvalid,!$isunknown(o_axil_rdata));
   chk(5,r_stall,o_axil_rvalid);
   chk(6,r_stall,o_axil_rresp==r_saved[33:32]);
   chk(7,r_stall,o_axil_rdata==r_saved[31:0]);
   chk(8,i_axil_awvalid,!$isunknown(i_axil_awaddr));
   chk(9,i_axil_awvalid,i_axil_awaddr[1:0]==0);
   chk(10,i_axil_awvalid,!$isunknown(i_axil_awprot));
   chk(11,i_axil_wvalid,!$isunknown(i_axil_wdata));
   chk(12,i_axil_wvalid,!$isunknown(i_axil_wstrb));
   chk(13,o_axil_bvalid,o_axil_bresp inside {0,2,3});
   chk(14,b_stall,o_axil_bvalid);
   chk(15,b_stall,o_axil_bresp==b_saved);
   chk(16,o_axil_rvalid,rd_pending==1);
   chk(17,o_axil_bvalid,aw_pending==1 && w_pending==1);
   chk(18,i_axil_arvalid || i_axil_awvalid || i_axil_wvalid,rd_pending<=1 && aw_pending<=1 && w_pending<=1);
   r_stall=o_axil_rvalid && !i_axil_rready;r_saved={o_axil_rresp,o_axil_rdata};
   b_stall=o_axil_bvalid && !i_axil_bready;b_saved=o_axil_bresp;
   if(o_axil_rvalid && i_axil_rready)rd_pending--;
   if(o_axil_bvalid && i_axil_bready)begin aw_pending--;w_pending--;end
  end
 end
 initial begin
  i_clk_cluster=0;i_rst_n_cluster=0;i_axil_araddr=0;i_axil_arprot=0;i_axil_arvalid=0;i_axil_rready=0;
  i_axil_awaddr=0;i_axil_awprot=0;i_axil_awvalid=0;i_axil_wdata=0;i_axil_wstrb=0;i_axil_wvalid=0;i_axil_bready=0;
  repeat(4)@(negedge i_clk_cluster);i_rst_n_cluster=1;
  for(int g=0;g<6;g++)begin
   logic[31:0] off,expect_data;off=32'(g*4096+36);
   expect_data=MODE==2?32'd0:(g==5?32'hb0000024:(32'ha0000000^off));
   rd(off,expect_data,MODE==2?2'd3:2'd0);wr(off,MODE==2?2'd3:2'd0);
  end
  rd('h6000,0,3);wr('h6000,3);rd(32'hfffffffc,0,3);
  if(MODE!=2 && (read_count[0]!=5 || read_count[1]!=1 || write_count[0]!=5 || write_count[1]!=1))$fatal(1,"endpoint count/window selection mismatch");
  if(MODE==2 && (read_count[0]+read_count[1]+write_count[0]+write_count[1])!=0)$fatal(1,"invalid base reached target");
  for(int k=0;k<20;k++)begin
   if(protocol_hits[k]==0)$fatal(1,"inactive AXIL map assertion %0d",k);
   $display("AXIL-MAP ASSERT %0d hits=%0d",k,protocol_hits[k]);
  end
  $display("PASS: TEST-054 4-KiB groups/LLC translation/aperture boundary mode=%0d checks=%0d",MODE,checks);$finish;
 end
 initial begin #30000;$fatal(1,"map watchdog");end
endmodule
