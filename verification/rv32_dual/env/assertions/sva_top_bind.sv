// -----------------------------------------------------------------------------
// AI-GENERATED (Claude Opus 5.5, 2026-11-28) - candidate artifact (R-117, R-231).
// sva_top_bind: boundary checkers of plan Section 5.3, all enabled by default
// (R-241). Written as clocked immediate checks with explicit failure, attempt
// and cover counters (R-203) so that 2-state Verilator reports activity.
// Sources: IHI 0022H A3.1.2 (VALID low in reset), A3.2 (stability), A3.4
// (burst rules, 4 KiB), B1; AMBA 5 E1.1 (AWATOP encodings); RV32 HDS 6.2, 15.3
// (SVA-102, SVA-103), REF-001 REQ-IF-005, REQ-ERR-003, REQ-RST-001, REQ-DBG-001,
// REQ-PMU-004 with Q-G0-10 (o_int_pmu low with no overflow cause).
// Internal SVA-101/104/105 are NOT here (sva_internal_bind, blocked by Q-G0-13).
// Plusargs: +SVA_LOG=<file.ndjson>; +SVA_DISABLE=<id> is not supported on purpose.
// -----------------------------------------------------------------------------
/* verilator lint_off UNUSEDSIGNAL */
/* verilator lint_off BLKSEQ */  // failure/attempt/cover counters are updated with blocking increments
module sva_top_bind #(parameter int HARTS = 2) (
  input logic clk, input logic rst_n, input logic [63:0] boot_addr,
  // memory port (DUT manager)
  input logic [63:0] m_awaddr, input logic [7:0] m_awlen, input logic [2:0] m_awsize, input logic [1:0] m_awburst,
  input logic m_awlock, input logic [5:0] m_awatop, input logic [6:0] m_awid, input logic m_awvalid, input logic m_awready,
  input logic [63:0] m_wdata, input logic [7:0] m_wstrb, input logic m_wlast, input logic m_wvalid, input logic m_wready,
  input logic [63:0] m_araddr, input logic [7:0] m_arlen, input logic [2:0] m_arsize, input logic [1:0] m_arburst,
  input logic m_arlock, input logic [6:0] m_arid, input logic m_arvalid, input logic m_arready,
  // MMIO port (DUT manager)
  input logic [63:0] p_awaddr, input logic [7:0] p_awlen, input logic [2:0] p_awsize, input logic [1:0] p_awburst,
  input logic [5:0] p_awid, input logic p_awvalid, input logic p_awready,
  input logic [63:0] p_wdata, input logic [7:0] p_wstrb, input logic p_wlast, input logic p_wvalid, input logic p_wready,
  input logic [63:0] p_araddr, input logic [7:0] p_arlen, input logic [2:0] p_arsize, input logic [1:0] p_arburst,
  input logic [5:0] p_arid, input logic p_arvalid, input logic p_arready,
  // AXI4-Lite (DUT subordinate): B and R are DUT-sourced
  input logic [1:0] l_bresp, input logic l_bvalid, input logic l_bready,
  input logic [31:0] l_rdata, input logic [1:0] l_rresp, input logic l_rvalid, input logic l_rready,
  // sideband
  input logic [HARTS-1:0] dbg_req, input logic [HARTS-1:0] dbg_mode, input logic int_pmu, input logic int_fault
);
  typedef enum int {A_MEM_STABLE, A_MMIO_STABLE, A_AXIL_STABLE, A_ADDR_HI_ZERO, A_BURST_LEGAL, A_AWATOP_LEGAL,
                    A_RESET_VALID_LOW, A_BOOT_HI_ZERO, A_FAULT_STICKY, A_RST_OUTPUTS, A_DBG_MODE, A_INT_PMU_NO_CAUSE, N_A} aid_e;
  string names [N_A] = '{"a_axi_mem_stable", "a_axi_mmio_stable", "a_axil_stable", "a_axi_addr_hi_zero", "a_axi_burst_legal",
                         "a_awatop_legal", "a_axi_reset_valid_low", "a_boot_hi_zero", "a_fault_sticky", "a_rst_outputs",
                         "a_dbg_mode", "a_int_pmu_no_cause"};
  longint unsigned fails [N_A], attempts [N_A], covers [N_A];
  logic prev_rst_n, prev_fault;
  logic [HARTS-1:0] prev_mode, req_seen;
  // previous-cycle payloads for stability (A3.2)
  logic [91:0] pm_aw, pm_ar, pp_aw, pp_ar;
  logic [72:0] pm_w, pp_w;
  logic [33:0] pl_b, pl_r;
  logic pm_aws, pm_ws, pm_ars, pp_aws, pp_ws, pp_ars, pl_bs, pl_rs;
  wire [91:0] cm_aw = {m_awaddr, m_awlen, m_awsize, m_awburst, m_awlock, m_awatop, m_awid, 1'b0};
  wire [91:0] cm_ar = {m_araddr, m_arlen, m_arsize, m_arburst, m_arlock, 6'd0, m_arid, 1'b0};
  wire [91:0] cp_aw = {p_awaddr, p_awlen, p_awsize, p_awburst, 1'b0, 6'd0, 2'b0, p_awid};
  wire [91:0] cp_ar = {p_araddr, p_arlen, p_arsize, p_arburst, 1'b0, 6'd0, 2'b0, p_arid};
  wire [72:0] cm_w = {m_wdata, m_wstrb, m_wlast};
  wire [72:0] cp_w = {p_wdata, p_wstrb, p_wlast};
  wire [33:0] cl_b = {32'd0, l_bresp};
  wire [33:0] cl_r = {l_rdata, l_rresp};

  task automatic chk(aid_e id, logic attempt, logic ok);
    if (attempt) begin
      attempts[id]++;
      if (!ok) begin
        fails[id]++;
        $display("[%0t] ASSERTION %s FAILED", $time, names[id]);
      end
    end
  endtask

  function automatic logic burst_ok(logic [63:0] a, logic [7:0] len, logic [2:0] size, logic [1:0] burst);
    logic [12:0] bytes = 13'((16'(len) + 16'd1) << size);
    if (burst == 2'b11 || size > 3'd3) return 1'b0;
    if (burst == 2'b10) return (len == 8'd1 || len == 8'd3 || len == 8'd7 || len == 8'd15) && (a[2:0] & ((3'd1 << size) - 3'd1)) == 3'd0;
    if (burst == 2'b01) return (13'(a[11:0]) + bytes) <= 13'd4096 || (bytes <= 13'(1 << size));   // A3.4: no 4 KiB crossing
    return 1'b1;
  endfunction

  function automatic logic atop_ok(logic [5:0] t, logic lock, logic [1:0] burst);
    logic enc = (t == 6'b000000) || (t[5:4] == 2'b01) || (t[5:4] == 2'b10) || (t == 6'b110000) || (t == 6'b110001);
    if (t == 6'b000000) return 1'b1;
    return enc && !lock && (burst == 2'b01 || (t == 6'b110001 && burst == 2'b10));
  endfunction

  initial begin
    foreach (fails[i]) begin fails[i] = 0; attempts[i] = 0; covers[i] = 0; end
    prev_rst_n = 1'b0; prev_fault = 1'b0; prev_mode = '0; req_seen = '0;
    {pm_aws, pm_ws, pm_ars, pp_aws, pp_ws, pp_ars, pl_bs, pl_rs} = '0;
  end

  always @(posedge clk) begin
    if (!rst_n) begin
      // A3.1.2 during reset: DUT-sourced VALIDs low; SVA-102: boot address upper half zero
      chk(A_RESET_VALID_LOW, 1'b1, !(m_awvalid || m_wvalid || m_arvalid || p_awvalid || p_wvalid || p_arvalid || l_bvalid || l_rvalid));
      covers[A_RESET_VALID_LOW]++;
      chk(A_BOOT_HI_ZERO, 1'b1, boot_addr[63:32] == 32'h0);
      covers[A_BOOT_HI_ZERO]++;
      req_seen <= '0;
      {pm_aws, pm_ws, pm_ars, pp_aws, pp_ws, pp_ars, pl_bs, pl_rs} <= '0;
    end else begin
      // stability: a stalled transfer keeps VALID and payload (A3.2, REQ-IF-005)
      chk(A_MEM_STABLE, pm_aws, m_awvalid && cm_aw == pm_aw);
      chk(A_MEM_STABLE, pm_ws, m_wvalid && cm_w == pm_w);
      chk(A_MEM_STABLE, pm_ars, m_arvalid && cm_ar == pm_ar);
      chk(A_MMIO_STABLE, pp_aws, p_awvalid && cp_aw == pp_aw);
      chk(A_MMIO_STABLE, pp_ws, p_wvalid && cp_w == pp_w);
      chk(A_MMIO_STABLE, pp_ars, p_arvalid && cp_ar == pp_ar);
      chk(A_AXIL_STABLE, pl_bs, l_bvalid && cl_b == pl_b);
      chk(A_AXIL_STABLE, pl_rs, l_rvalid && cl_r == pl_r);
      if (pm_aws || pm_ws || pm_ars) covers[A_MEM_STABLE]++;
      if (pp_aws || pp_ws || pp_ars) covers[A_MMIO_STABLE]++;
      if (pl_bs || pl_rs) covers[A_AXIL_STABLE]++;
      pm_aws <= m_awvalid && !m_awready; pm_aw <= cm_aw;
      pm_ws  <= m_wvalid && !m_wready;   pm_w  <= cm_w;
      pm_ars <= m_arvalid && !m_arready; pm_ar <= cm_ar;
      pp_aws <= p_awvalid && !p_awready; pp_aw <= cp_aw;
      pp_ws  <= p_wvalid && !p_wready;   pp_w  <= cp_w;
      pp_ars <= p_arvalid && !p_arready; pp_ar <= cp_ar;
      pl_bs  <= l_bvalid && !l_bready;   pl_b  <= cl_b;
      pl_rs  <= l_rvalid && !l_rready;   pl_r  <= cl_r;
      // I-X32-2 / SVA-103: AXI address bits 63:34 zero (REQ-XL-006)
      chk(A_ADDR_HI_ZERO, m_awvalid, m_awaddr[63:34] == '0);
      chk(A_ADDR_HI_ZERO, m_arvalid, m_araddr[63:34] == '0);
      chk(A_ADDR_HI_ZERO, p_awvalid, p_awaddr[63:34] == '0);
      chk(A_ADDR_HI_ZERO, p_arvalid, p_araddr[63:34] == '0);
      if ((m_awvalid && m_awready) || (m_arvalid && m_arready) || (p_awvalid && p_awready) || (p_arvalid && p_arready)) covers[A_ADDR_HI_ZERO]++;
      // A3.4 burst legality
      chk(A_BURST_LEGAL, m_awvalid, burst_ok(m_awaddr, m_awlen, m_awsize, m_awburst));
      chk(A_BURST_LEGAL, m_arvalid, burst_ok(m_araddr, m_arlen, m_arsize, m_arburst));
      chk(A_BURST_LEGAL, p_awvalid, burst_ok(p_awaddr, p_awlen, p_awsize, p_awburst));
      chk(A_BURST_LEGAL, p_arvalid, burst_ok(p_araddr, p_arlen, p_arsize, p_arburst));
      if ((m_awvalid && m_awready && m_awlen != 0) || (m_arvalid && m_arready && m_arlen != 0)) covers[A_BURST_LEGAL]++;
      // E1.1 AWATOP legal subset
      chk(A_AWATOP_LEGAL, m_awvalid, atop_ok(m_awatop, m_awlock, m_awburst));
      if (m_awvalid && m_awready && m_awatop != 6'd0) covers[A_AWATOP_LEGAL]++;
      // REQ-ERR-003: o_int_fault never falls while out of reset
      chk(A_FAULT_STICKY, prev_rst_n && prev_fault, int_fault);
      if (int_fault) covers[A_FAULT_STICKY]++;
      // REQ-RST-001: outputs quiet on the first cycle after reset release
      chk(A_RST_OUTPUTS, !prev_rst_n, !int_fault && !int_pmu && dbg_mode == '0);
      if (!prev_rst_n) covers[A_RST_OUTPUTS]++;
      // REQ-DBG-001: a hart enters debug mode only after its own request
      for (int h = 0; h < HARTS; h++) begin
        chk(A_DBG_MODE, dbg_mode[h] && !prev_mode[h], req_seen[h] || dbg_req[h]);
        if (dbg_mode[h] && !prev_mode[h]) covers[A_DBG_MODE]++;
      end
      req_seen <= (req_seen | dbg_req) & ~(prev_mode & ~dbg_mode);
      // Q-G0-10 TOP check: no overflow cause can arise within a test budget, so o_int_pmu stays low
      chk(A_INT_PMU_NO_CAUSE, 1'b1, !int_pmu);
      covers[A_INT_PMU_NO_CAUSE]++;
    end
    prev_rst_n <= rst_n;
    prev_fault <= int_fault;
    prev_mode <= dbg_mode;
  end

  final begin
    string f; int fd;
    if ($value$plusargs("SVA_LOG=%s", f)) begin
      fd = $fopen(f, "w");
      for (int i = 0; i < N_A; i++)
        $fwrite(fd, "{\"type\":\"sva\",\"id\":\"%s\",\"fails\":%0d,\"attempts\":%0d,\"covers\":%0d}\n", names[i], fails[i], attempts[i], covers[i]);
      $fclose(fd);
    end
  end
endmodule
/* verilator lint_on BLKSEQ */
/* verilator lint_on UNUSEDSIGNAL */
