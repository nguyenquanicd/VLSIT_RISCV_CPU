`timescale 1ns/1ps
// Regression of finding CC-01 (2026-11-09 review) against the v0.19+ directory.
// Original defect: a hit transaction (T1) kept no reservation, a miss transaction (T2) reserved the set,
// T1's update was then blocked by T2's reservation and also blocked T2's own cancel -> deadlock.
// Current directory: every lookup (hit or miss) reserves the set, a reservation owner's UPDATE/CANCEL
// escapes arbitration, and other operations on the set are ineligible until the owner terminates.
module tb;
  localparam CPU=2, TXN=8, TW=3;
  logic clk=0, rst_n=0; always #5 clk=~clk;
  logic [3:0] lv; wire [3:0] lr; logic [3:0][51:0] lpa; logic [3:0][TW-1:0] ltag;
  wire [3:0] rv; logic [3:0] rr=4'hF; wire [3:0] hit; wire [3:0][TW-1:0] rtag; wire [3:0][2:0] way;
  wire [3:0] vv; wire [3:0][51:0] vpa; wire [3:0][CPU-1:0] hold; wire [3:0][1:0] own, st;
  logic [3:0] uv; wire [3:0] ur; logic [3:0][TW-1:0] utag; logic [3:0][51:0] upa; logic [3:0][2:0] uway;
  logic [3:0][CPU-1:0] uhold; logic [3:0][1:0] uown, ust;
  logic [3:0] cv; wire [3:0] cr; logic [3:0][TW-1:0] ctag; logic [3:0][51:0] cpa;
  wire [2:0] lc, uc; wire [3:0] diag;
  m_vlsit_riscv_sharer_directory #(.PARA_CPU_NUM(CPU), .PARA_COH_TXN_NUM(TXN)) dut(
    .i_clk_cluster(clk), .i_rst_n_cluster(rst_n),
    .i_lookup_valid(lv), .o_lookup_ready(lr), .i_lookup_pa_line(lpa), .i_lookup_tag(ltag),
    .o_lookup_rsp_valid(rv), .i_lookup_rsp_ready(rr), .o_lookup_hit(hit), .o_lookup_rsp_tag(rtag),
    .o_lookup_way(way), .o_lookup_victim_valid(vv), .o_lookup_victim_pa_line(vpa),
    .o_lookup_holders(hold), .o_lookup_owner(own), .o_lookup_state(st),
    .i_update_valid(uv), .o_update_ready(ur), .i_update_tag(utag), .i_update_pa_line(upa),
    .i_update_way(uway), .i_update_holders(uhold), .i_update_owner(uown), .i_update_state(ust),
    .i_cancel_valid(cv), .o_cancel_ready(cr), .i_cancel_tag(ctag), .i_cancel_pa_line(cpa),
    .o_dir_lookup_count(lc), .o_dir_update_count(uc), .o_coh_proto_diag_event(diag));
  function automatic [51:0] pa(input [42:0] t, input [6:0] s, input [1:0] b); pa = {t,s,b}; endfunction
  integer errors = 0;
  task automatic check(input logic cond, input string what);
    begin
      if (cond) $display("  ok   : %s", what);
      else begin $display("  FAIL : %s", what); errors = errors + 1; end
    end
  endtask
  // handshake helpers: present a request on bank 0 and wait until it is accepted (at most 12 cycles)
  task automatic do_update(input [TW-1:0] tag, input [51:0] line, input [2:0] w, input [CPU-1:0] h, input [1:0] s, output logic done);
    integer n;
    begin
      uv[0]=1; utag[0]=tag; upa[0]=line; uway[0]=w; uhold[0]=h; ust[0]=s; done=0;
      for (n=0; n<12 && !done; n=n+1) begin #1; done = ur[0]; @(posedge clk); #1; end
      uv[0]=0;
    end
  endtask
  logic d;
  initial begin
    lv=0; uv=0; cv=0; lpa='0; ltag='0; utag='0; upa='0; uway='0; uhold='0; uown='0; ust='0; ctag='0; cpa='0;
    repeat(3) @(posedge clk); #1 rst_n=1; repeat(2) @(posedge clk); #1;
    $display("--- install line A (tag1,set5,bank0) as the owner of a fresh lookup, then commit it");
    lv[0]=1; lpa[0]=pa(1,5,0); ltag[0]=0; @(posedge clk); #1 lv[0]=0; @(posedge clk); #1;
    do_update(3'd0, pa(1,5,0), 3'd0, 2'b01, 2'd1, d);
    check(d, "update of the lookup owner is accepted");
    $display("--- T1 hits A and thereby reserves set 5");
    lv[0]=1; lpa[0]=pa(1,5,0); ltag[0]=1; @(posedge clk); #1 lv[0]=0; @(posedge clk); #1;
    check(hit[0], "T1 lookup of A is a hit");
    $display("--- T2 looks up B in the same set while T1 owns the reservation");
    lv[0]=1; lpa[0]=pa(2,5,0); ltag[0]=2; #1;
    check(!lr[0], "T2 lookup is NOT accepted while T1 owns the set (serialised, no deadlock)");
    $display("--- T1 commits: its owner UPDATE must be accepted");
    do_update(3'd1, pa(1,5,0), 3'd0, 2'b11, 2'd1, d);
    check(d, "T1 update accepted");
    @(posedge clk); #1;
    check(lr[0] || rv[0] , "T2 lookup proceeds once T1 has terminated");
    @(posedge clk); #1 lv[0]=0; repeat(2) @(posedge clk); #1;
    $display("--- T2 (now reservation owner) cancels while an unrelated update from T3 is held on the same bank");
    uv[0]=1; utag[0]=3'd3; upa[0]=pa(9,5,0); uway[0]=3'd1; uhold[0]=2'b01; ust[0]=2'd1;
    cv[0]=1; ctag[0]=3'd2; cpa[0]=pa(2,5,0);
    #1 check(cr[0] && !ur[0], "owner CANCEL escapes while a non-owner UPDATE is held");
    @(posedge clk); #1 cv[0]=0;
    #1 check(ur[0], "the held non-owner UPDATE proceeds once the reservation is released");
    @(posedge clk); #1 uv[0]=0;
    if (errors==0) $display("RESULT: PASS (CC-01 no longer reproduces)");
    else begin $display("RESULT: FAIL (%0d check(s))", errors); end
    $finish;
  end
endmodule
