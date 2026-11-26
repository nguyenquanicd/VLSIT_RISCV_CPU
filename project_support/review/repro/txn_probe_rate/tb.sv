`timescale 1ns/1ps
// Re-measurement of PF-05 (probe rate) and CC-02 (duplicate ACK) against the current transaction table
// and probe scheduler. An ideal cache answers every probe one cycle after the request handshake.
module tb;
  localparam CPU=4, TXN=8, TW=3;
  logic clk=0, rst_n=0; always #5 clk=~clk;
  // transaction table
  logic av=0; wire ar; logic [2:0] asrc=0, aid=0; logic [51:0] apa; logic [1:0] akind=0, atgt=0; logic awb=1; wire [TW-1:0] atag;
  logic rv=0; logic [TW-1:0] rtag=0; wire rr;
  logic pv=0; logic [TW-1:0] ptag=0; logic [1:0] pph=0; logic [CPU-1:0] pexp=0; wire pr;
  logic ocv=0; wire ocr; logic [TW-1:0] octag=0; logic ocpres=0; logic [1:0] ochart=0;
  wire [CPU-1:0] ack_ready; wire [CPU-1:0] ack_valid; wire [CPU-1:0][TW-1:0] ack_tag; wire [CPU-1:0][1:0] ack_phase, ack_state;
  wire [CPU-1:0] ack_err, ack_wb;
  wire [TXN-1:0] cv, cpa_act, cdone, cerr, cwb, cwben, cown_known, cown_pres, ctxerr, cwberr;
  wire [TXN-1:0][2:0] csrc, cid; wire [TXN-1:0][51:0] cpa; wire [TXN-1:0][1:0] ckind, cph, ctgt, cown_hart;
  wire [TXN-1:0][CPU-1:0] cexp, crcv;
  wire tt_diag;
  m_vlsit_riscv_coh_txn_table #(.PARA_COH_TXN_NUM(TXN), .PARA_CPU_NUM(CPU)) tt(
    .i_clk_cluster(clk), .i_rst_n_cluster(rst_n),
    .i_alloc_valid(av), .o_alloc_ready(ar), .i_alloc_src(asrc), .i_alloc_req_id(aid), .i_alloc_pa_line(apa), .i_alloc_kind(akind),
    .i_alloc_target_state(atgt), .i_alloc_wback_en(awb), .o_alloc_tag(atag),
    .i_release_valid(rv), .i_release_tag(rtag), .o_release_ready(rr),
    .i_phase_start_valid(pv), .i_phase_start_tag(ptag), .i_phase_start(pph), .i_phase_expected(pexp), .o_phase_start_ready(pr),
    .i_owner_capture_valid(ocv), .o_owner_capture_ready(ocr), .i_owner_capture_tag(octag), .i_owner_capture_present(ocpres), .i_owner_capture_hart(ochart),
    .i_ack_valid(ack_valid), .o_ack_ready(ack_ready), .i_ack_tag(ack_tag), .i_ack_phase(ack_phase), .i_ack_err(ack_err), .i_ack_wback_done(ack_wb),
    .o_ctx_valid(cv), .o_ctx_src(csrc), .o_ctx_req_id(cid), .o_ctx_pa_line(cpa), .o_ctx_kind(ckind), .o_ctx_phase(cph),
    .o_ctx_ack_expected(cexp), .o_ctx_ack_received(crcv), .o_ctx_phase_active(cpa_act), .o_ctx_phase_done(cdone), .o_ctx_phase_err(cerr),
    .o_ctx_owner_wback_done(cwb), .o_ctx_target_state(ctgt), .o_ctx_wback_en(cwben), .o_ctx_owner_known(cown_known),
    .o_ctx_owner_present(cown_pres), .o_ctx_owner_hart(cown_hart), .o_ctx_txn_err(ctxerr), .o_ctx_owner_wback_err(cwberr),
    .o_coh_proto_diag_event(tt_diag));
  // probe scheduler
  wire [CPU-1:0] preq_v; logic [CPU-1:0] preq_r='1; wire [CPU-1:0][TW-1:0] preq_tag; wire [CPU-1:0][51:0] preq_pa; wire [CPU-1:0][1:0] preq_ph, preq_ts;
  wire [CPU-1:0] preq_wb, ps_diag;
  logic [CPU-1:0] prsp_v=0; wire [CPU-1:0] prsp_r; logic [CPU-1:0][TW-1:0] prsp_tag='0; logic [CPU-1:0][51:0] prsp_pa='0; logic [CPU-1:0][1:0] prsp_ph='0;
  m_vlsit_riscv_probe_scheduler #(.PARA_CPU_NUM(CPU), .PARA_COH_TXN_NUM(TXN)) ps(
    .i_clk_cluster(clk), .i_rst_n_cluster(rst_n),
    .i_ctx_valid(cv), .i_ctx_pa_line(cpa), .i_ctx_phase(cph), .i_ctx_ack_expected(cexp), .i_ctx_ack_received(crcv),
    .i_ctx_phase_active(cpa_act), .i_ctx_target_state(ctgt), .i_ctx_wback_en(cwben),
    .o_probe_req_valid(preq_v), .i_probe_req_ready(preq_r), .o_probe_req_tag(preq_tag), .o_probe_req_pa_line(preq_pa),
    .o_probe_req_phase(preq_ph), .o_probe_req_target_state(preq_ts), .o_probe_req_wback_en(preq_wb),
    .i_probe_rsp_valid(prsp_v), .o_probe_rsp_ready(prsp_r), .i_probe_rsp_tag(prsp_tag), .i_probe_rsp_pa_line(prsp_pa),
    .i_probe_rsp_phase(prsp_ph), .i_probe_rsp_state('0), .i_probe_rsp_err('0), .i_probe_rsp_wback_done('0),
    .o_ack_valid(ack_valid), .i_ack_ready(ack_ready), .o_ack_tag(ack_tag), .o_ack_phase(ack_phase), .o_ack_state(ack_state),
    .o_ack_err(ack_err), .o_ack_wback_done(ack_wb), .o_coh_proto_diag_event(ps_diag));
  logic [CPU-1:0] pend=0; logic [CPU-1:0][TW-1:0] ptg; logic [CPU-1:0][51:0] ppa; logic [CPU-1:0][1:0] pph2;
  always @(posedge clk) begin
    for (int h=0; h<CPU; h++) begin
      if (preq_v[h] & preq_r[h]) begin pend[h] <= 1; ptg[h] <= preq_tag[h]; ppa[h] <= preq_pa[h]; pph2[h] <= preq_ph[h]; end
      if (pend[h] & ~prsp_v[h]) begin prsp_v[h] <= 1; prsp_tag[h] <= ptg[h]; prsp_pa[h] <= ppa[h]; prsp_ph[h] <= pph2[h]; pend[h] <= 0; end
      else if (prsp_v[h] & prsp_r[h]) prsp_v[h] <= 0;
    end
  end
  integer cyc=0; always @(posedge clk) cyc <= cyc+1;
  integer t0, t1, k, wd;
  integer diag_cnt = 0; always @(posedge clk) if (tt_diag) diag_cnt <= diag_cnt + 1;
  initial begin
    apa='0;
    repeat(3) @(posedge clk); #1 rst_n=1; repeat(2) @(posedge clk); #1;
    for (k=0;k<4;k++) begin
      av=1; apa=52'(k+1); @(posedge clk); #1; av=0;
      ocv=1; octag=k[TW-1:0]; ocpres=0; @(posedge clk); #1; ocv=0;   // owner metadata: no dirty owner
    end
    // One transaction at a time per target hart: the scheduler keeps a hart bound to the context whose
    // PREPARE it answered until that context's terminal phase finishes, so measure PREPARE + COMMIT.
    t0 = cyc;
    for (k=0;k<4;k++) begin
      pv=1; ptag=k[TW-1:0]; pph=2'd0; pexp=4'b0001; @(posedge clk); #1; pv=0;
      wd = 0; while (!cdone[k] && wd < 100) begin @(posedge clk); wd = wd + 1; end
      pv=1; ptag=k[TW-1:0]; pph=2'd1; pexp=4'b0001; @(posedge clk); #1; pv=0;
      wd = 0; while (!(cdone[k] & ~cpa_act[k] & (cph[k]==2'd1)) && wd < 100) begin @(posedge clk); wd = wd + 1; end
    end
    t1 = cyc;
    $display("TXN-RATE: 4 transactions (PREPARE then COMMIT) targeting ONE hart, ideal 1-cycle cache: %0d cycles -> %0d cycles per transaction (%0d per phase)",
             t1-t0, (t1-t0)/4, (t1-t0)/8);
    // Independent contexts on different harts proceed in parallel
    for (k=0;k<4;k++) begin
      av=1; apa=52'(16+k); @(posedge clk); #1; av=0;
      ocv=1; octag=3'(k); ocpres=0; @(posedge clk); #1; ocv=0;
    end
    t0 = cyc;
    for (k=0;k<4;k++) begin
      pv=1; ptag=3'(k); pph=2'd0; pexp=(4'b0001 << k); @(posedge clk); #1; pv=0;
    end
    wd = 0; while (!(&cdone[3:0]) && wd < 100) begin @(posedge clk); wd = wd + 1; end
    $display("PARALLEL: 4 PREPARE phases, each to a DIFFERENT hart, complete in %0d cycles", cyc-t0);
    // duplicate ACK for a finished phase: it must be drained and flagged, never left blocking the lane
    force ack_valid[0]=1'b1; force ack_tag[0]=3'd0; force ack_phase[0]=2'd0; force ack_err[0]=0; force ack_wb[0]=0;
    #1;
    $display("DUP-ACK: duplicate ack (tag0, phase PREPARE, phase already done): o_ack_ready=%b (1 means it is drained), diag_event=%b", ack_ready[0], tt_diag);
    repeat(3) @(posedge clk);
    release ack_valid[0]; release ack_tag[0]; release ack_phase[0]; release ack_err[0]; release ack_wb[0];
    $display("DUP-ACK: diag pulses counted: %0d (a protocol diagnostic event is raised)", diag_cnt);
    $finish;
  end
endmodule
