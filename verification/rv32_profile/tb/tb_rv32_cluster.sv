// =============================================================================
// Testbench   : tb_rv32_cluster - RV32 profile of the VLSIT dual/quad CPU cluster
// Project     : VLSIT RISC-V CPU Cluster
// Author      : Quan Nguyen (user)
// Date        : 2026-11-25
// Spec        : doc/specification_32/VLSIT_RISCV32_DUAL_QUAD_CPU_CLUSTER_HDS.md rev 0.1
// Plan        : verification/rv32_profile/TEST_PLAN.md
// Description : Production AXI TOP built with rtl/rv32_profile/filelist_rv32.f.
//               * AXI4 memory model on the memory port (0x8000_0000, 1 MiB) and AXI4
//                 device model on the MMIO port (0x1000_0000, 4 KiB), written from IHI 0022H.
//               * Programs report results as 32-bit MMIO stores to SIG(h) = 0x1000_0000+0x100*h
//                 and finish with 0x600D at SIG(h)+0x80. Expected values come from the
//                 independent Python oracle (rule R-023): exp_h<h>.hex, meta.hex, memchk.hex,
//                 mmioexp.hex in the run folder given by +RUN=<folder>.
//               * 46 counted AXI4 protocol / relation assertions (23 per port). The run fails
//                 when a check fails, an assertion fails, or a required assertion has no hit.
//               * +FAULT=<n> applies one controlled fault for fault qualification (rule R-096).
// =============================================================================
`timescale 1ns/1ps
module tb_rv32_cluster #(parameter int HARTS = 2, parameter int PROFILE = 0);
`include "dut_ports_decl.svh"

  localparam logic [63:0] MEM_BASE  = 64'h8000_0000;
  localparam int          MEM_WORDS = 131072;               // 1 MiB of 64-bit words
  localparam logic [63:0] MMIO_BASE = 64'h1000_0000;
  localparam logic [63:0] MMIO_SIZE = 64'h1000;
  localparam int          MAXCHK    = 256;

  // Region table: 0 = cacheable DRAM window, 1 = MMIO device window (REQ-XL-011: below 2^34).
  m_vlsit_riscv_cluster_axi_top #(
    .PARA_CPU_NUM(32'(HARTS)), .PARA_TIMING_PROFILE(32'(PROFILE)),
    .PARA_LLC_WAY_NUM(32'd4), .PARA_LLC_NO_LINES(32'd64),
    .PARA_ADDR_REGION_NUM(32'd2),
    .PARA_ADDR_REGION_BASE_LO('{default:32'd0, 0:32'h8000_0000, 1:32'h1000_0000}),
    .PARA_ADDR_REGION_SIZE_LO('{default:32'd0, 0:32'h4000_0000, 1:32'h0000_1000}),
    .PARA_ADDR_REGION_TYPE('{default:32'd0, 0:32'd0, 1:32'd2})
  ) dut (
`include "dut_ports_conn.svh"

  // ---------------------------------------------------------------- run control
  string run_dir;
  int    fault = 0, boot_hi = 0, timeout = 400000, cycles = 0;
  logic [63:0] memory [0:MEM_WORDS-1];
  logic [31:0] exp0 [0:MAXCHK-1], exp1 [0:MAXCHK-1], exp2 [0:MAXCHK-1], exp3 [0:MAXCHK-1];
  function automatic logic [31:0] exp_val(input int h, input int i);
    case (h) 0: return exp0[i]; 1: return exp1[i]; 2: return exp2[i]; default: return exp3[i]; endcase
  endfunction
  logic [31:0] meta [0:7];
  logic [31:0] memchk [0:63];
  logic [31:0] mmioexp [0:63];
  int got_cnt[4], fail_cnt = 0, pass_cnt = 0;
  logic [3:0] done = '0;
  int done_cycle = -1;
  logic [31:0] mmio_regs [0:63];
  int mmio_wlog = 0;

  always #5 i_clk_cluster = ~i_clk_cluster;

  // ---------------------------------------------------------------- counted assertions
  localparam int NA = 48;
  string nm [NA];
  int hit [NA], bad [NA];
  bit req [NA];
  task automatic chk(input int id, input bit ante, input bit cons);
    if (ante) begin
      hit[id]++;
      if (!cons) begin
        bad[id]++;
        $display("ASSERT FAIL @%0t: %0s", $time, nm[id]);
      end
    end
  endtask
  initial begin
    // Memory port (A = AMBA AXI IHI 0022H clause; XL = RV32 profile requirement)
    nm[0]="MEM-01 AW payload stable while AWREADY low (A3.2.1)";      req[0]=1;
    nm[1]="MEM-02 W payload stable while WREADY low (A3.2.1)";        req[1]=1;
    nm[2]="MEM-03 AR payload stable while ARREADY low (A3.2.1)";      req[2]=1;
    nm[3]="MEM-04 AWBURST not reserved (A3.4.1)";                      req[3]=1;
    nm[4]="MEM-05 ARBURST not reserved (A3.4.1)";                      req[4]=1;
    nm[5]="MEM-06 AWSIZE within 64-bit bus (A3.4.1)";                  req[5]=1;
    nm[6]="MEM-07 ARSIZE within 64-bit bus (A3.4.1)";                  req[6]=1;
    nm[7]="MEM-08 AW INCR burst inside 4 KiB (A3.4.1)";                req[7]=1;
    nm[8]="MEM-09 AR INCR burst inside 4 KiB (A3.4.1)";                req[8]=1;
    nm[9]="MEM-10 AW WRAP length 2/4/8/16 (A3.4.1)";                   req[9]=0;
    nm[10]="MEM-11 AR WRAP length 2/4/8/16 (A3.4.1)";                  req[10]=0;
    nm[11]="MEM-12 AW WRAP address aligned to size (A3.4.1)";          req[11]=0;
    nm[12]="MEM-13 AR WRAP address aligned to size (A3.4.1)";          req[12]=0;
    nm[13]="MEM-14 WLAST on the final beat only (A3.4.1)";             req[13]=1;
    nm[14]="MEM-15 WSTRB only in active byte lanes (A3.4.3)";          req[14]=1;
    nm[15]="MEM-16 BID matches the AW (stimulus legality, A5.3)";      req[15]=1;
    nm[16]="MEM-17 RID matches the AR (stimulus legality, A5.3)";      req[16]=1;
    nm[17]="MEM-18 RLAST on the final beat only (A3.4.1)";             req[17]=1;
    nm[18]="MEM-19 AWADDR bits 63:34 zero (REQ-XL-006)";               req[18]=1;
    nm[19]="MEM-20 ARADDR bits 63:34 zero (REQ-XL-006)";               req[19]=1;
    nm[20]="MEM-21 AW address inside the cacheable region (REQ-XL-011)"; req[20]=1;
    nm[21]="MEM-22 AR address inside the cacheable region (REQ-XL-011)"; req[21]=1;
    nm[22]="MEM-23 no AWVALID/ARVALID/WVALID during reset (A3.1.2)";   req[22]=1;
    // MMIO port
    nm[23]="MMIO-01 AW payload stable while AWREADY low (A3.2.1)";     req[23]=1;
    nm[24]="MMIO-02 W payload stable while WREADY low (A3.2.1)";       req[24]=1;
    nm[25]="MMIO-03 AR payload stable while ARREADY low (A3.2.1)";     req[25]=0;
    nm[26]="MMIO-04 AWBURST not reserved (A3.4.1)";                     req[26]=1;
    nm[27]="MMIO-05 ARBURST not reserved (A3.4.1)";                     req[27]=0;
    nm[28]="MMIO-06 AWSIZE within 64-bit bus (A3.4.1)";                 req[28]=1;
    nm[29]="MMIO-07 ARSIZE within 64-bit bus (A3.4.1)";                 req[29]=0;
    nm[30]="MMIO-08 AW INCR burst inside 4 KiB (A3.4.1)";               req[30]=1;
    nm[31]="MMIO-09 AR INCR burst inside 4 KiB (A3.4.1)";               req[31]=0;
    nm[32]="MMIO-10 AW WRAP length 2/4/8/16 (A3.4.1)";                  req[32]=0;
    nm[33]="MMIO-11 AR WRAP length 2/4/8/16 (A3.4.1)";                  req[33]=0;
    nm[34]="MMIO-12 AW WRAP address aligned (A3.4.1)";                  req[34]=0;
    nm[35]="MMIO-13 AR WRAP address aligned (A3.4.1)";                  req[35]=0;
    nm[36]="MMIO-14 WLAST on the final beat only (A3.4.1)";             req[36]=1;
    nm[37]="MMIO-15 WSTRB only in active byte lanes (A3.4.3)";          req[37]=1;
    nm[38]="MMIO-16 BID matches the AW (stimulus legality, A5.3)";      req[38]=1;
    nm[39]="MMIO-17 RID matches the AR (stimulus legality, A5.3)";      req[39]=0;
    nm[40]="MMIO-18 RLAST on the final beat only (A3.4.1)";             req[40]=0;
    nm[41]="MMIO-19 AWADDR bits 63:34 zero (REQ-XL-006)";               req[41]=1;
    nm[42]="MMIO-20 ARADDR bits 63:34 zero (REQ-XL-006)";               req[42]=0;
    nm[43]="MMIO-21 AW address inside the MMIO region (REQ-XL-011)";    req[43]=1;
    nm[44]="MMIO-22 AR address inside the MMIO region (REQ-XL-011)";    req[44]=0;
    nm[45]="MMIO-23 no MMIO valid during reset (A3.1.2)";              req[45]=1;
    // Coherence fabric (REF-001 DEC-047, OPEN-DIR-UPD-TAG): a context retires from DIR_UPDATE / DIR_CANCEL
    // only on the bank handshake that carries its own tag.
    nm[46]="SVA-104 DIR_UPDATE exit on own-tag update handshake (DEC-047)"; req[46]=0;
    nm[47]="SVA-105 DIR_CANCEL exit on own-tag cancel or no reservation (DEC-047)"; req[47]=0;
  end

  // ---------------------------------------------------------------- coherence fabric checks SVA-104/105 (DEC-047)
`define FAB dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.u_vlsit_riscv_coh_tile_array.u_vlsit_riscv_coh_fabric
  always @(posedge i_clk_cluster) begin
    if (i_rst_n_cluster) begin
      for (int sl = 0; sl < 8; sl++) begin
        logic [1:0] bk;
        bk = `FAB.w_ctx_pa_line[sl][1:0];
        chk(46, (`FAB.reg_fsm_ctx_current_state[sl] == 5'b01100) && (`FAB.w_fsm_ctx_nxt_state[sl] != 5'b01100),
            `FAB.w_update_hs[bk] && (int'(`FAB.w_dir_update_tag[bk]) == sl));
        chk(47, (`FAB.reg_fsm_ctx_current_state[sl] == 5'b01101) && (`FAB.w_fsm_ctx_nxt_state[sl] != 5'b01101),
            !`FAB.reg_ctx_dir_reserved[sl] || (`FAB.w_cancel_hs[bk] && (int'(`FAB.w_dir_cancel_tag[bk]) == sl)));
      end
    end
  end
`undef FAB

  // ---------------------------------------------------------------- AXI4 memory model (single outstanding per direction)
  logic mw_act = 0, mr_act = 0;
  logic [63:0] mw_addr, mr_addr;
  logic [7:0]  mw_left, mr_left;
  logic [2:0]  mw_size, mr_size;
  logic [6:0]  mw_id, mr_id;
  // Wait states: ready only on some cycles, so every stability assertion is exercised.
  assign i_axi_mem_awready = !mw_act && !i_axi_mem_bvalid && (cycles % 3 == 0);
  assign i_axi_mem_wready  = mw_act && (cycles % 2 == 1);
  assign i_axi_mem_arready = !mr_act && !i_axi_mem_rvalid && (cycles % 3 == 1);

  function automatic int midx(input logic [63:0] a);
    if (a < MEM_BASE || a >= MEM_BASE + 64'(MEM_WORDS) * 8) begin
      $display("TB ERROR: memory access outside the model %h", a);
      return 0;
    end
    return int'((a - MEM_BASE) >> 3);
  endfunction
  function automatic logic [63:0] incr_wrap(input logic [63:0] a, input logic [2:0] s, input logic [1:0] b, input logic [7:0] len);
    logic [63:0] nxt, span;
    nxt  = a + (64'd1 << s);
    span = (64'(len) + 1) << s;
    if (b == 2'b10) nxt = (a & ~(span - 1)) | (nxt & (span - 1));
    return nxt;
  endfunction
  logic [1:0] mw_burst, mr_burst;
  logic [7:0] mw_len, mr_len;

  always @(posedge i_clk_cluster) begin
    if (!i_rst_n_cluster) begin
      mw_act <= 0; mr_act <= 0;
      i_axi_mem_bvalid <= 0; i_axi_mem_bid <= 0; i_axi_mem_bresp <= 0;
      i_axi_mem_rvalid <= 0; i_axi_mem_rid <= 0; i_axi_mem_rdata <= 0; i_axi_mem_rresp <= 0; i_axi_mem_rlast <= 0;
    end else begin
      if (o_axi_mem_awvalid && i_axi_mem_awready) begin
        mw_act <= 1; mw_addr <= o_axi_mem_awaddr; mw_left <= o_axi_mem_awlen; mw_len <= o_axi_mem_awlen;
        mw_size <= o_axi_mem_awsize; mw_id <= o_axi_mem_awid; mw_burst <= o_axi_mem_awburst;
      end
      if (o_axi_mem_wvalid && i_axi_mem_wready) begin
        for (int b = 0; b < 8; b++)
          if (o_axi_mem_wstrb[b]) memory[midx(mw_addr)][b*8 +: 8] <= o_axi_mem_wdata[b*8 +: 8];
        if (mw_left == 0) begin
          mw_act <= 0; i_axi_mem_bvalid <= 1; i_axi_mem_bid <= mw_id; i_axi_mem_bresp <= 2'b00;
        end else begin
          mw_left <= mw_left - 1'b1; mw_addr <= incr_wrap(mw_addr, mw_size, mw_burst, mw_len);
        end
      end
      if (i_axi_mem_bvalid && o_axi_mem_bready) i_axi_mem_bvalid <= 0;
      if (o_axi_mem_arvalid && i_axi_mem_arready) begin
        mr_act <= 1; mr_addr <= o_axi_mem_araddr; mr_left <= o_axi_mem_arlen; mr_len <= o_axi_mem_arlen;
        mr_size <= o_axi_mem_arsize; mr_id <= o_axi_mem_arid; mr_burst <= o_axi_mem_arburst;
      end
      if (mr_act && !i_axi_mem_rvalid) begin
        i_axi_mem_rvalid <= 1; i_axi_mem_rid <= mr_id; i_axi_mem_rdata <= memory[midx(mr_addr)];
        i_axi_mem_rresp <= 2'b00; i_axi_mem_rlast <= (mr_left == 0);
      end
      if (i_axi_mem_rvalid && o_axi_mem_rready) begin
        i_axi_mem_rvalid <= 0;
        if (mr_left == 0) mr_act <= 0;
        else begin mr_left <= mr_left - 1'b1; mr_addr <= incr_wrap(mr_addr, mr_size, mr_burst, mr_len); end
      end
    end
  end

  // ---------------------------------------------------------------- AXI4 MMIO device model
  logic xw_act = 0, xr_act = 0, xw_aw = 0;
  logic [63:0] xw_addr, xr_addr;
  logic [7:0]  xw_left, xr_left;
  logic [2:0]  xw_size;
  logic [5:0]  xw_id, xr_id;
  assign i_axi_mmio_awready = !xw_aw && !i_axi_mmio_bvalid && (cycles % 2 == 0);
  assign i_axi_mmio_wready  = xw_aw && (cycles % 2 == 1);
  assign i_axi_mmio_arready = !xr_act && !i_axi_mmio_rvalid && (cycles % 2 == 0);

  task automatic mmio_write(input logic [63:0] a, input logic [63:0] d, input logic [7:0] s);
    logic [31:0] v;
    int h, off;
    v = a[2] ? d[63:32] : d[31:0];
    if (a >= MMIO_BASE && a < MMIO_BASE + 64'h400) begin
      h = int'((a - MMIO_BASE) >> 8);
      off = int'(a[7:0]);
      if (h >= HARTS) $display("TB ERROR: signature store for absent hart %0d", h);
      else if (off == 0) begin
        if (got_cnt[h] >= int'(meta[h])) begin
          $display("CHECK h%0d #%0d FAIL extra value %h", h, got_cnt[h], v); fail_cnt++;
        end else if (v === exp_val(h, got_cnt[h])) begin
          $display("CHECK h%0d #%0d PASS %h", h, got_cnt[h], v); pass_cnt++;
        end else begin
          $display("CHECK h%0d #%0d FAIL got %h expected %h", h, got_cnt[h], v, exp_val(h, got_cnt[h])); fail_cnt++;
        end
        got_cnt[h]++;
      end else if (off == 32'h80) begin
        if (v != 32'h600D) begin $display("CHECK h%0d DONE FAIL code %h", h, v); fail_cnt++; end
        done[h] <= 1'b1;
      end
    end else if (a >= MMIO_BASE + 64'h800 && a < MMIO_BASE + 64'h900) begin
      mmio_regs[int'((a - MMIO_BASE - 64'h800) >> 2)] = v;
      if (mmio_wlog < int'(meta[6])) begin
        if (a[31:0] == mmioexp[2*mmio_wlog] && v == mmioexp[2*mmio_wlog+1]) begin
          $display("CHECK mmio-order #%0d PASS %h=%h", mmio_wlog, a[31:0], v); pass_cnt++;
        end else begin
          $display("CHECK mmio-order #%0d FAIL got %h=%h expected %h=%h", mmio_wlog, a[31:0], v,
                   mmioexp[2*mmio_wlog], mmioexp[2*mmio_wlog+1]); fail_cnt++;
        end
      end
      mmio_wlog++;
    end else $display("TB ERROR: MMIO write outside the device %h", a);
  endtask

  always @(posedge i_clk_cluster) begin
    if (!i_rst_n_cluster) begin
      xw_aw <= 0; xr_act <= 0;
      i_axi_mmio_bvalid <= 0; i_axi_mmio_bid <= 0; i_axi_mmio_bresp <= 0;
      i_axi_mmio_rvalid <= 0; i_axi_mmio_rid <= 0; i_axi_mmio_rdata <= 0; i_axi_mmio_rresp <= 0; i_axi_mmio_rlast <= 0;
    end else begin
      if (o_axi_mmio_awvalid && i_axi_mmio_awready) begin
        xw_aw <= 1; xw_addr <= o_axi_mmio_awaddr; xw_left <= o_axi_mmio_awlen; xw_size <= o_axi_mmio_awsize; xw_id <= o_axi_mmio_awid;
      end
      if (o_axi_mmio_wvalid && i_axi_mmio_wready) begin
        mmio_write(xw_addr, o_axi_mmio_wdata, o_axi_mmio_wstrb);
        if (xw_left == 0) begin xw_aw <= 0; i_axi_mmio_bvalid <= 1; i_axi_mmio_bid <= xw_id; end
        else begin xw_left <= xw_left - 1'b1; xw_addr <= xw_addr + (64'd1 << xw_size); end
      end
      if (i_axi_mmio_bvalid && o_axi_mmio_bready) i_axi_mmio_bvalid <= 0;
      if (o_axi_mmio_arvalid && i_axi_mmio_arready) begin
        xr_act <= 1; xr_addr <= o_axi_mmio_araddr; xr_left <= o_axi_mmio_arlen; xr_id <= o_axi_mmio_arid;
      end
      if (xr_act && !i_axi_mmio_rvalid) begin
        logic [31:0] rv;
        rv = (xr_addr >= MMIO_BASE + 64'h800 && xr_addr < MMIO_BASE + 64'h900)
             ? mmio_regs[int'((xr_addr - MMIO_BASE - 64'h800) >> 2)] : 32'hDEAD_BEEF;
        i_axi_mmio_rvalid <= 1; i_axi_mmio_rid <= xr_id; i_axi_mmio_rdata <= {rv, rv};
        i_axi_mmio_rresp <= 2'b00; i_axi_mmio_rlast <= (xr_left == 0);
      end
      if (i_axi_mmio_rvalid && o_axi_mmio_rready) begin
        i_axi_mmio_rvalid <= 0;
        if (xr_left == 0) xr_act <= 0; else begin xr_left <= xr_left - 1'b1; xr_addr <= xr_addr + 64'd8; end
      end
    end
  end

  // ---------------------------------------------------------------- assertion sampling
  logic aw_stall_q, w_stall_q, ar_stall_q, xaw_stall_q, xw_stall_q, xar_stall_q;
  logic [127:0] aw_pl_q, ar_pl_q, xaw_pl_q, xar_pl_q;
  logic [72:0] w_pl_q, xw_pl_q;
  wire  [127:0] aw_pl  = {28'd0, o_axi_mem_awid, o_axi_mem_awaddr, o_axi_mem_awlen, o_axi_mem_awsize, o_axi_mem_awburst, o_axi_mem_awatop, o_axi_mem_awlock, o_axi_mem_awcache};
  wire  [127:0] ar_pl  = {28'd0, o_axi_mem_arid, o_axi_mem_araddr, o_axi_mem_arlen, o_axi_mem_arsize, o_axi_mem_arburst, o_axi_mem_arlock, o_axi_mem_arcache};
  wire  [127:0] xaw_pl = {28'd0, o_axi_mmio_awid, o_axi_mmio_awaddr, o_axi_mmio_awlen, o_axi_mmio_awsize, o_axi_mmio_awburst, o_axi_mmio_awlock, o_axi_mmio_awcache};
  wire  [127:0] xar_pl = {28'd0, o_axi_mmio_arid, o_axi_mmio_araddr, o_axi_mmio_arlen, o_axi_mmio_arsize, o_axi_mmio_arburst, o_axi_mmio_arlock, o_axi_mmio_arcache};
  wire  [72:0] w_pl   = {o_axi_mem_wdata, o_axi_mem_wstrb, o_axi_mem_wlast};
  wire  [72:0] xw_pl  = {o_axi_mmio_wdata, o_axi_mmio_wstrb, o_axi_mmio_wlast};

  function automatic bit inside4k(input logic [63:0] a, input logic [7:0] len, input logic [2:0] s);
    return (32'(a[11:0]) + ((32'(len) + 1) << s)) <= 4096;
  endfunction
  function automatic bit wraplen(input logic [7:0] len);
    return len == 1 || len == 3 || len == 7 || len == 15;
  endfunction
  function automatic bit lanes_ok(input logic [63:0] a, input logic [2:0] s, input logic [7:0] st);
    logic [7:0] m;
    m = 8'((32'(1) << (32'(1) << s)) - 1) << a[2:0];
    if (s == 3) m = 8'hFF;
    return (st & ~m) == 0;
  endfunction

  always @(posedge i_clk_cluster) begin
    cycles <= cycles + 1;
    chk(22, !i_rst_n_cluster, !o_axi_mem_awvalid && !o_axi_mem_arvalid && !o_axi_mem_wvalid);
    chk(45, !i_rst_n_cluster, !o_axi_mmio_awvalid && !o_axi_mmio_arvalid && !o_axi_mmio_wvalid);
    if (i_rst_n_cluster) begin
      // stability: a stalled valid must stay asserted with the same payload in the next cycle
      chk(0, aw_stall_q, o_axi_mem_awvalid && aw_pl == aw_pl_q);
      chk(1, w_stall_q, o_axi_mem_wvalid && w_pl == w_pl_q);
      chk(2, ar_stall_q, o_axi_mem_arvalid && ar_pl == ar_pl_q);
      chk(23, xaw_stall_q, o_axi_mmio_awvalid && xaw_pl == xaw_pl_q);
      chk(24, xw_stall_q, o_axi_mmio_wvalid && xw_pl == xw_pl_q);
      chk(25, xar_stall_q, o_axi_mmio_arvalid && xar_pl == xar_pl_q);
      // memory port request rules
      chk(3, o_axi_mem_awvalid, o_axi_mem_awburst != 2'b11);
      chk(4, o_axi_mem_arvalid, o_axi_mem_arburst != 2'b11);
      chk(5, o_axi_mem_awvalid, o_axi_mem_awsize <= 3);
      chk(6, o_axi_mem_arvalid, o_axi_mem_arsize <= 3);
      chk(7, o_axi_mem_awvalid && o_axi_mem_awburst == 2'b01, inside4k(o_axi_mem_awaddr, o_axi_mem_awlen, o_axi_mem_awsize));
      chk(8, o_axi_mem_arvalid && o_axi_mem_arburst == 2'b01, inside4k(o_axi_mem_araddr, o_axi_mem_arlen, o_axi_mem_arsize));
      chk(9, o_axi_mem_awvalid && o_axi_mem_awburst == 2'b10, wraplen(o_axi_mem_awlen));
      chk(10, o_axi_mem_arvalid && o_axi_mem_arburst == 2'b10, wraplen(o_axi_mem_arlen));
      chk(11, o_axi_mem_awvalid && o_axi_mem_awburst == 2'b10, (o_axi_mem_awaddr & ((64'd1 << o_axi_mem_awsize) - 1)) == 0);
      chk(12, o_axi_mem_arvalid && o_axi_mem_arburst == 2'b10, (o_axi_mem_araddr & ((64'd1 << o_axi_mem_arsize) - 1)) == 0);
      chk(13, o_axi_mem_wvalid && i_axi_mem_wready, o_axi_mem_wlast == (mw_left == 0));
      chk(14, o_axi_mem_wvalid && i_axi_mem_wready, lanes_ok(mw_addr, mw_size, o_axi_mem_wstrb));
      chk(15, i_axi_mem_bvalid && o_axi_mem_bready, i_axi_mem_bid == mw_id);
      chk(16, i_axi_mem_rvalid && o_axi_mem_rready, i_axi_mem_rid == mr_id);
      chk(17, i_axi_mem_rvalid && o_axi_mem_rready, i_axi_mem_rlast == (mr_left == 0));
      chk(18, o_axi_mem_awvalid, o_axi_mem_awaddr[63:34] == 0);
      chk(19, o_axi_mem_arvalid, o_axi_mem_araddr[63:34] == 0);
      chk(20, o_axi_mem_awvalid, o_axi_mem_awaddr >= MEM_BASE && o_axi_mem_awaddr < MEM_BASE + 64'h4000_0000);
      chk(21, o_axi_mem_arvalid, o_axi_mem_araddr >= MEM_BASE && o_axi_mem_araddr < MEM_BASE + 64'h4000_0000);
      // MMIO port request rules
      chk(26, o_axi_mmio_awvalid, o_axi_mmio_awburst != 2'b11);
      chk(27, o_axi_mmio_arvalid, o_axi_mmio_arburst != 2'b11);
      chk(28, o_axi_mmio_awvalid, o_axi_mmio_awsize <= 3);
      chk(29, o_axi_mmio_arvalid, o_axi_mmio_arsize <= 3);
      chk(30, o_axi_mmio_awvalid && o_axi_mmio_awburst == 2'b01, inside4k(o_axi_mmio_awaddr, o_axi_mmio_awlen, o_axi_mmio_awsize));
      chk(31, o_axi_mmio_arvalid && o_axi_mmio_arburst == 2'b01, inside4k(o_axi_mmio_araddr, o_axi_mmio_arlen, o_axi_mmio_arsize));
      chk(32, o_axi_mmio_awvalid && o_axi_mmio_awburst == 2'b10, wraplen(o_axi_mmio_awlen));
      chk(33, o_axi_mmio_arvalid && o_axi_mmio_arburst == 2'b10, wraplen(o_axi_mmio_arlen));
      chk(34, o_axi_mmio_awvalid && o_axi_mmio_awburst == 2'b10, (o_axi_mmio_awaddr & ((64'd1 << o_axi_mmio_awsize) - 1)) == 0);
      chk(35, o_axi_mmio_arvalid && o_axi_mmio_arburst == 2'b10, (o_axi_mmio_araddr & ((64'd1 << o_axi_mmio_arsize) - 1)) == 0);
      chk(36, o_axi_mmio_wvalid && i_axi_mmio_wready, o_axi_mmio_wlast == (xw_left == 0));
      chk(37, o_axi_mmio_wvalid && i_axi_mmio_wready, lanes_ok(xw_addr, xw_size, o_axi_mmio_wstrb));
      chk(38, i_axi_mmio_bvalid && o_axi_mmio_bready, i_axi_mmio_bid == xw_id);
      chk(39, i_axi_mmio_rvalid && o_axi_mmio_rready, i_axi_mmio_rid == xr_id);
      chk(40, i_axi_mmio_rvalid && o_axi_mmio_rready, i_axi_mmio_rlast == (xr_left == 0));
      chk(41, o_axi_mmio_awvalid, o_axi_mmio_awaddr[63:34] == 0);
      chk(42, o_axi_mmio_arvalid, o_axi_mmio_araddr[63:34] == 0);
      chk(43, o_axi_mmio_awvalid, o_axi_mmio_awaddr >= MMIO_BASE && o_axi_mmio_awaddr < MMIO_BASE + MMIO_SIZE);
      chk(44, o_axi_mmio_arvalid, o_axi_mmio_araddr >= MMIO_BASE && o_axi_mmio_araddr < MMIO_BASE + MMIO_SIZE);
    end
    aw_stall_q  <= i_rst_n_cluster && o_axi_mem_awvalid && !i_axi_mem_awready;  aw_pl_q  <= aw_pl;
    w_stall_q   <= i_rst_n_cluster && o_axi_mem_wvalid && !i_axi_mem_wready;    w_pl_q   <= w_pl;
    ar_stall_q  <= i_rst_n_cluster && o_axi_mem_arvalid && !i_axi_mem_arready;  ar_pl_q  <= ar_pl;
    xaw_stall_q <= i_rst_n_cluster && o_axi_mmio_awvalid && !i_axi_mmio_awready; xaw_pl_q <= xaw_pl;
    xw_stall_q  <= i_rst_n_cluster && o_axi_mmio_wvalid && !i_axi_mmio_wready;   xw_pl_q  <= xw_pl;
    xar_stall_q <= i_rst_n_cluster && o_axi_mmio_arvalid && !i_axi_mmio_arready; xar_pl_q <= xar_pl;
  end

  // ---------------------------------------------------------------- waveform taps (depth-1 signals)
  wire        wv_probe0_req_valid = dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[0].gen_active_tile.u_vlsit_riscv_cpu_tile.i_coh_probe_req_valid;
  wire [51:0] wv_probe0_req_nline = dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[0].gen_active_tile.u_vlsit_riscv_cpu_tile.i_coh_probe_req_nline;
  wire [1:0]  wv_probe0_req_phase = dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[0].gen_active_tile.u_vlsit_riscv_cpu_tile.i_coh_probe_req_phase;
  wire        wv_probe0_rsp_valid = dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[0].gen_active_tile.u_vlsit_riscv_cpu_tile.o_coh_probe_rsp_valid;
  wire [51:0] wv_probe0_rsp_nline = dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[0].gen_active_tile.u_vlsit_riscv_cpu_tile.o_coh_probe_rsp_nline;
  wire        wv_own1_req_valid   = dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[1].gen_active_tile.u_vlsit_riscv_cpu_tile.o_coh_cache_req_valid;
  wire [51:0] wv_own1_req_nline   = dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[1].gen_active_tile.u_vlsit_riscv_cpu_tile.o_coh_cache_req_nline;
  wire        wv_gnt1_valid       = dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[1].gen_active_tile.u_vlsit_riscv_cpu_tile.i_coh_cache_gnt_valid;

  // ---------------------------------------------------------------- controlled faults (rule R-096)
`ifndef TB_RV64   // faults force signals of the RV32 tile adapter
`include "tb_faults.svh"
`else
`include "tb_experiments_rv64.svh"
`endif

  // ---------------------------------------------------------------- stimulus, end of test
  initial begin
    if (!$value$plusargs("RUN=%s", run_dir)) $fatal(1, "+RUN=<folder> required");
    void'($value$plusargs("FAULT=%d", fault));
    void'($value$plusargs("BOOT_HI=%d", boot_hi));
    void'($value$plusargs("TIMEOUT=%d", timeout));
    for (int i = 0; i < MEM_WORDS; i++) memory[i] = '0;
    for (int i = 0; i < 64; i++) mmio_regs[i] = '0;
    $readmemh({run_dir, "/program.hex"}, memory);
    $readmemh({run_dir, "/meta.hex"}, meta);
    if (meta[0] != 0) $readmemh({run_dir, "/exp_h0.hex"}, exp0);
    if (HARTS > 1 && meta[1] != 0) $readmemh({run_dir, "/exp_h1.hex"}, exp1);
    if (HARTS > 2 && meta[2] != 0) $readmemh({run_dir, "/exp_h2.hex"}, exp2);
    if (HARTS > 3 && meta[3] != 0) $readmemh({run_dir, "/exp_h3.hex"}, exp3);
    if (meta[5] != 0) $readmemh({run_dir, "/memchk.hex"}, memchk);
    if (meta[6] != 0) $readmemh({run_dir, "/mmioexp.hex"}, mmioexp);
    // Scenario-dependent assertions (meta[7]): bit 0 = memory-port write traffic expected,
    // bit 1 = MMIO read traffic expected. Others are scenario-inapplicable and reported, not required.
    foreach (req[i]) begin
      if (i inside {0, 1, 3, 5, 7, 13, 14, 15, 18, 20}) req[i] = meta[7][0];
      if (i inside {25, 27, 29, 31, 39, 40, 42, 44}) req[i] = meta[7][1];
      if (i == 46) req[i] = meta[7][2];   // bit 2 = cached sharing between harts expected (directory updates)
    end
    $dumpfile({run_dir, "/wave.vcd"});
    $dumpvars(1, tb_rv32_cluster);
    $display("RUN %s harts=%0d profile=%0d fault=%0d boot_hi=%0d", run_dir, HARTS, PROFILE, fault, boot_hi);
    i_boot_addr = {32'(boot_hi), 32'h8000_0000};
    {i_int_msip, i_int_mtip, i_int_meip, i_int_ssip, i_int_stip, i_int_seip, i_hart_debug_req} = '0;
    {i_axil_awaddr, i_axil_awprot, i_axil_awvalid, i_axil_wdata, i_axil_wstrb, i_axil_wvalid, i_axil_bready} = '0;
    {i_axil_araddr, i_axil_arprot, i_axil_arvalid, i_axil_rready} = '0;
    i_clk_cluster = 0; i_rst_n_cluster = 0;
    repeat (10) @(negedge i_clk_cluster);
    i_rst_n_cluster = 1;
  end

  always @(posedge i_clk_cluster) begin
    if (i_rst_n_cluster && done_cycle < 0 && (done & 4'((1 << HARTS) - 1)) == 4'((1 << HARTS) - 1)) done_cycle <= cycles;
    if (done_cycle >= 0 && cycles == done_cycle + 200) finish_test();
    if (cycles > timeout) begin
      $display("CHECK watchdog FAIL: harts done=%b after %0d cycles", done, cycles);
      fail_cnt++;
      finish_test();
    end
  end

  task automatic finish_test();
    int never = 0, afail = 0;
    for (int h = 0; h < HARTS; h++)
      if (got_cnt[h] != int'(meta[h])) begin
        $display("CHECK h%0d count FAIL got %0d values, expected %0d", h, got_cnt[h], meta[h]); fail_cnt++;
      end
    for (int i = 0; i < int'(meta[5]); i++) begin
      logic [31:0] a, v, m;
      a = memchk[2*i]; v = memchk[2*i+1];
      m = a[2] ? memory[midx(64'(a))][63:32] : memory[midx(64'(a))][31:0];
      if (m === v) begin $display("CHECK mem %h PASS %h", a, m); pass_cnt++; end
      else begin $display("CHECK mem %h FAIL got %h expected %h", a, m, v); fail_cnt++; end
    end
    if (mmio_wlog != int'(meta[6])) begin
      $display("CHECK mmio-order count FAIL got %0d expected %0d", mmio_wlog, meta[6]); fail_cnt++;
    end
    $display("ASSERTION TABLE (id hits fails required name)");
    for (int i = 0; i < NA; i++) begin
      $display("  A%02d %8d %4d %0d %0s", i, hit[i], bad[i], req[i], nm[i]);
      afail += bad[i];
      if (req[i] && hit[i] == 0) never++;
    end
    $display("checks passed: %0d, checks failed: %0d", pass_cnt, fail_cnt);
    $display("assertion failures: %0d, assertions never exercised: %0d", afail, never);
    if (fail_cnt == 0 && afail == 0 && never == 0) $display("RESULT: PASS cycles=%0d", cycles);
    else $display("RESULT: FAIL cycles=%0d", cycles);
    $dumpflush;
    if (fail_cnt == 0 && afail == 0 && never == 0) $finish;
    else $fatal(1, "test failed");
  endtask
endmodule
