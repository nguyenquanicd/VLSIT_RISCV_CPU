`timescale 1ns/1ps
module tb;
  localparam CPU=4, TXN=8, TW=3;
  logic clk=0, rst_n=0; always #5 clk=~clk;
  // txn table
  logic av=0; wire ar; logic [2:0] asrc=0, aid=0; logic [51:0] apa; logic [1:0] akind=0; wire [TW-1:0] atag;
  logic rv=0; logic [TW-1:0] rtag=0; wire rr;
  logic pv=0; logic [TW-1:0] ptag=0; logic [1:0] pph=0; logic [CPU-1:0] pexp=0; wire pr;
  wire [CPU-1:0] ack_ready; wire [CPU-1:0] ack_valid; wire [CPU-1:0][TW-1:0] ack_tag; wire [CPU-1:0][1:0] ack_phase, ack_state;
  wire [CPU-1:0] ack_err, ack_wb;
  wire [TXN-1:0] cv, cpa_act, cdone, cerr, cwb; wire [TXN-1:0][2:0] csrc, cid; wire [TXN-1:0][51:0] cpa; wire [TXN-1:0][1:0] ckind, cph;
  wire [TXN-1:0][CPU-1:0] cexp, crcv;
  m_vlsit_riscv_coh_txn_table #(.PARA_COH_TXN_NUM(TXN), .PARA_CPU_NUM(CPU)) tt(
    .i_clk_cluster(clk), .i_rst_n_cluster(rst_n),
    .i_alloc_valid(av), .o_alloc_ready(ar), .i_alloc_src(asrc), .i_alloc_req_id(aid), .i_alloc_pa_line(apa), .i_alloc_kind(akind), .o_alloc_tag(atag),
    .i_release_valid(rv), .i_release_tag(rtag), .o_release_ready(rr),
    .i_phase_start_valid(pv), .i_phase_start_tag(ptag), .i_phase_start(pph), .i_phase_expected(pexp), .o_phase_start_ready(pr),
    .i_ack_valid(ack_valid), .o_ack_ready(ack_ready), .i_ack_tag(ack_tag), .i_ack_phase(ack_phase), .i_ack_err(ack_err), .i_ack_wback_done(ack_wb),
    .o_ctx_valid(cv), .o_ctx_src(csrc), .o_ctx_req_id(cid), .o_ctx_pa_line(cpa), .o_ctx_kind(ckind), .o_ctx_phase(cph),
    .o_ctx_ack_expected(cexp), .o_ctx_ack_received(crcv), .o_ctx_phase_active(cpa_act), .o_ctx_phase_done(cdone), .o_ctx_phase_err(cerr), .o_ctx_owner_wback_done(cwb));
  // probe scheduler with an ideal cache model (responds the cycle after the request handshake)
  wire [CPU-1:0] preq_v; logic [CPU-1:0] preq_r='1; wire [CPU-1:0][TW-1:0] preq_tag; wire [CPU-1:0][51:0] preq_pa; wire [CPU-1:0][1:0] preq_ph, preq_ts;
  logic [CPU-1:0] prsp_v=0; wire [CPU-1:0] prsp_r; logic [CPU-1:0][TW-1:0] prsp_tag='0; logic [CPU-1:0][51:0] prsp_pa='0; logic [CPU-1:0][1:0] prsp_ph='0;
  m_vlsit_riscv_probe_scheduler #(.PARA_CPU_NUM(CPU), .PARA_COH_TXN_NUM(TXN)) ps(
    .i_clk_cluster(clk), .i_rst_n_cluster(rst_n),
    .i_ctx_valid(cv), .i_ctx_pa_line(cpa), .i_ctx_phase(cph), .i_ctx_ack_expected(cexp), .i_ctx_ack_received(crcv),
    .i_ctx_phase_active(cpa_act), .i_ctx_target_state('0),
    .o_probe_req_valid(preq_v), .i_probe_req_ready(preq_r), .o_probe_req_tag(preq_tag), .o_probe_req_pa_line(preq_pa),
    .o_probe_req_phase(preq_ph), .o_probe_req_target_state(preq_ts),
    .i_probe_rsp_valid(prsp_v), .o_probe_rsp_ready(prsp_r), .i_probe_rsp_tag(prsp_tag), .i_probe_rsp_pa_line(prsp_pa),
    .i_probe_rsp_phase(prsp_ph), .i_probe_rsp_state('0), .i_probe_rsp_err('0), .i_probe_rsp_wback_done('0),
    .o_ack_valid(ack_valid), .i_ack_ready(ack_ready), .o_ack_tag(ack_tag), .o_ack_phase(ack_phase), .o_ack_state(ack_state),
    .o_ack_err(ack_err), .o_ack_wback_done(ack_wb));
  // ideal cache: one cycle after the request handshake raise the response with the same tag/line/phase
  logic [CPU-1:0] pend=0; logic [CPU-1:0][TW-1:0] ptg; logic [CPU-1:0][51:0] ppa; logic [CPU-1:0][1:0] pph2;
  always @(posedge clk) begin
    for (int h=0; h<CPU; h++) begin
      if (preq_v[h] & preq_r[h]) begin pend[h] <= 1; ptg[h] <= preq_tag[h]; ppa[h] <= preq_pa[h]; pph2[h] <= preq_ph[h]; end
      if (pend[h] & ~prsp_v[h]) begin prsp_v[h] <= 1; prsp_tag[h] <= ptg[h]; prsp_pa[h] <= ppa[h]; prsp_ph[h] <= pph2[h]; pend[h] <= 0; end
      else if (prsp_v[h] & prsp_r[h]) prsp_v[h] <= 0;
    end
  end
  integer cyc=0; always @(posedge clk) cyc <= cyc+1;
  integer t0, t1, k;
  initial begin
    apa='0;
    repeat(3) @(posedge clk); #1 rst_n=1; repeat(2) @(posedge clk); #1;
    // allocate 4 contexts (different lines), each PREPARE expects hart 0 only
    for (k=0;k<4;k++) begin
      av=1; apa=52'(k+1); @(posedge clk); #1; av=0;
    end
    t0 = cyc;
    for (k=0;k<4;k++) begin
      pv=1; ptag=k[TW-1:0]; pph=2'd0; pexp=4'b0001; @(posedge clk); #1; pv=0;
    end
    while (!(&cdone[3:0])) @(posedge clk);
    t1 = cyc;
    $display("PROBE-RATE: 4 PREPARE probes to ONE hart (ideal 1-cycle cache) complete in %0d cycles -> %0d cycles/probe", t1-t0, (t1-t0)/4);
    // single-probe latency for 1 context to 3 harts in parallel
    t0 = cyc; pv=1; ptag=3'd4; pph=2'd1; pexp=4'b0111; 
    av=1; apa=52'd9; @(posedge clk); #1; av=0; pv=0;
    pv=1; ptag=3'd4; pph=2'd1; pexp=4'b0111; @(posedge clk); #1; pv=0; t0=cyc;
    while (!cdone[4]) @(posedge clk);
    $display("PHASE-LATENCY: COMMIT to 3 harts in parallel, ideal cache: %0d cycles from phase start to phase_done", cyc-t0);
    // duplicate ACK after the phase is complete: never consumed
    force ack_valid[0]=1'b1; force ack_tag[0]=3'd0; force ack_phase[0]=2'd0; force ack_err[0]=0; force ack_wb[0]=0;
    repeat(10) @(posedge clk);
    $display("DUP-ACK: duplicate ack (tag0, phase PREPARE, phase already done) ready=%b after 10 cycles (0 means it is never consumed)", ack_ready[0]);
    $finish;
  end
endmodule
