`timescale 1ns/1ps
module tb;
  localparam CPU=2, TXN=8, TW=3;
  logic clk=0, rst_n=0; always #5 clk=~clk;
  logic [3:0] lv; wire [3:0] lr; logic [3:0][51:0] lpa; logic [3:0][TW-1:0] ltag;
  wire [3:0] rv; logic [3:0] rr=4'hF; wire [3:0] hit; wire [3:0][TW-1:0] rtag; wire [3:0][2:0] way;
  wire [3:0] vv; wire [3:0][51:0] vpa; wire [3:0][CPU-1:0] hold; wire [3:0][1:0] own, st;
  logic [3:0] uv; wire [3:0] ur; logic [3:0][TW-1:0] utag; logic [3:0][51:0] upa; logic [3:0][2:0] uway;
  logic [3:0][CPU-1:0] uhold; logic [3:0][1:0] uown, ust;
  logic [3:0] cv; wire [3:0] cr; logic [3:0][TW-1:0] ctag; logic [3:0][51:0] cpa;
  wire [2:0] lc, uc;
  m_vlsit_riscv_sharer_directory #(.PARA_CPU_NUM(CPU), .PARA_COH_TXN_NUM(TXN)) dut(
    .i_clk_cluster(clk), .i_rst_n_cluster(rst_n),
    .i_lookup_valid(lv), .o_lookup_ready(lr), .i_lookup_pa_line(lpa), .i_lookup_tag(ltag),
    .o_lookup_rsp_valid(rv), .i_lookup_rsp_ready(rr), .o_lookup_hit(hit), .o_lookup_rsp_tag(rtag),
    .o_lookup_way(way), .o_lookup_victim_valid(vv), .o_lookup_victim_pa_line(vpa),
    .o_lookup_holders(hold), .o_lookup_owner(own), .o_lookup_state(st),
    .i_update_valid(uv), .o_update_ready(ur), .i_update_tag(utag), .i_update_pa_line(upa),
    .i_update_way(uway), .i_update_holders(uhold), .i_update_owner(uown), .i_update_state(ust),
    .i_cancel_valid(cv), .o_cancel_ready(cr), .i_cancel_tag(ctag), .i_cancel_pa_line(cpa),
    .o_dir_lookup_count(lc), .o_dir_update_count(uc));
  function automatic [51:0] pa(input [42:0] t, input [6:0] s, input [1:0] b); pa = {t,s,b}; endfunction
  initial begin
    lv=0; uv=0; cv=0; lpa='0; ltag='0; utag='0; upa='0; uway='0; uhold='0; uown='0; ust='0; ctag='0; cpa='0;
    repeat(3) @(posedge clk); #1 rst_n=1; @(posedge clk); #1;
    // T0: install line A (tag1,set5,bank0) in way0 with holder hart0, state S
    uv[0]=1; utag[0]=0; upa[0]=pa(1,5,0); uway[0]=0; uhold[0]=2'b01; ust[0]=2'd1;
    @(posedge clk); #1 uv[0]=0;
    // T1: lookup A -> hit, no reservation
    lv[0]=1; lpa[0]=pa(1,5,0); ltag[0]=1; @(posedge clk); #1 lv[0]=0;
    $display("T1 lookup A: hit=%b rsp_valid=%b", hit[0], rv[0]);
    // T2: lookup B (tag2, same set/bank) -> miss, reserves the set
    lv[0]=1; lpa[0]=pa(2,5,0); ltag[0]=2; @(posedge clk); #1 lv[0]=0;
    $display("T2 lookup B: hit=%b (miss reserves set 5)", hit[0]);
    // T1 commit update for A: blocked by T2's reservation
    uv[0]=1; utag[0]=1; upa[0]=pa(1,5,0); uway[0]=0; uhold[0]=2'b11; ust[0]=2'd1;
    #1 $display("T1 update A: update_ready=%b (expected 0)", ur[0]);
    // T2 tries to cancel while T1 update valid is held (valid may not be withdrawn)
    cv[0]=1; ctag[0]=2; cpa[0]=pa(2,5,0);
    #1 $display("T2 cancel while T1 update held: cancel_ready=%b update_ready=%b lookup_ready=%b", cr[0], ur[0], lr[0]);
    repeat(20) @(posedge clk);
    $display("after 20 cycles: update_ready=%b cancel_ready=%b -> %s", ur[0], cr[0], (ur[0]|cr[0])?"progress":"DEADLOCK");
    $finish;
  end
endmodule
