// -----------------------------------------------------------------------------
// AI-GENERATED (Claude Opus 5.5, 2026-11-28) - candidate artifact (R-117, R-231).
// bfm_axil_mgr: AXI4-Lite manager BFM (plan 5.2). Sources: AMBA IHI 0022H B1
// (independent AW/W, B/R handshakes), REF-001 rev 0.39 Section 6.2 (32/32,
// 4 strobes), REQ-IF-010 (AW/W may handshake independently). Not a VIP (R-262).
// Script (+AXIL_SCRIPT=<file>), one operation per line, executed in order:
//   W <addr> <data> <strb> <skew>   write; skew -3..+3 = W valid cycles after(+)/before(-) AW
//   R <addr>                        read
//   WAIT <cycles>                   idle
//   WAITCK <id>                     wait until the MMIO checkpoint register equals <id> (hex)
//   END                             stop issuing
// Responses are recorded by the passive mon_axil, never by this BFM.
// -----------------------------------------------------------------------------
/* verilator lint_off UNUSEDSIGNAL */  // responses are observed by mon_axil, not by the driver
module bfm_axil_mgr (
  input  logic        clk,
  input  logic        rst_n,
  input  logic [31:0] ckpt,
  output logic [31:0] awaddr, output logic [2:0] awprot, output logic awvalid, input logic awready,
  output logic [31:0] wdata,  output logic [3:0] wstrb,  output logic wvalid,  input logic wready,
  input  logic [1:0]  bresp,  input  logic bvalid, output logic bready,
  output logic [31:0] araddr, output logic [2:0] arprot, output logic arvalid, input logic arready,
  input  logic [31:0] rdata,  input  logic [1:0] rresp,  input  logic rvalid,  output logic rready,
  output logic        done,
  output logic [31:0] ops_done        // operations completed (read by programs through MMIO 0x10000600)
);
  assign ops_done = 32'(pc);
  typedef enum logic [2:0] {OP_W, OP_R, OP_WAIT, OP_WAITCK, OP_END} op_e;
  op_e         ops  [256];
  logic [31:0] a_v  [256], d_v [256];
  logic [3:0]  s_v  [256];
  int          k_v  [256];
  int n_ops, pc, wait_cnt, skew_cnt, seed, rdy_pct;
  logic aw_done, w_done, b_pend, r_pend;
  logic [31:0] lfsr;

  initial pc = 0;
  initial begin
    string f, line, op; int fd, c; logic [31:0] a, d; int s, k;
    n_ops = 0; seed = 1; rdy_pct = 100;
    void'($value$plusargs("SEED=%d", seed));
    void'($value$plusargs("AXIL_RDY=%d", rdy_pct));
    lfsr = 32'hACE1_0001 ^ seed;
    if ($value$plusargs("AXIL_SCRIPT=%s", f)) begin
      fd = $fopen(f, "r");
      if (fd == 0) begin $display("AXIL BFM: cannot open %s", f); $fatal(1); end
      while (!$feof(fd) && n_ops < 255) begin
        c = $fgets(line, fd);
        if (c <= 0) continue;
        if ($sscanf(line, "W %h %h %h %d", a, d, s, k) == 4) begin ops[n_ops] = OP_W; a_v[n_ops] = a; d_v[n_ops] = d; s_v[n_ops] = 4'(s); k_v[n_ops] = k; n_ops++; end
        else if ($sscanf(line, "R %h", a) == 1) begin ops[n_ops] = OP_R; a_v[n_ops] = a; n_ops++; end
        else if ($sscanf(line, "WAITCK %h", a) == 1) begin ops[n_ops] = OP_WAITCK; a_v[n_ops] = a; n_ops++; end
        else if ($sscanf(line, "WAIT %d", k) == 1) begin ops[n_ops] = OP_WAIT; k_v[n_ops] = k; n_ops++; end
        else if ($sscanf(line, "%s", op) == 1 && op == "END") begin ops[n_ops] = OP_END; n_ops++; end
      end
      $fclose(fd);
    end
    ops[n_ops] = OP_END;
  end

  logic [1:0] wph;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      // a mid-test coordinated reset (DEC-041) restarts the current operation but keeps the script position
      wait_cnt <= 0; skew_cnt <= 0; aw_done <= 1'b0; w_done <= 1'b0; b_pend <= 1'b0; r_pend <= 1'b0;
      wph <= 2'd0; awvalid <= 1'b0; wvalid <= 1'b0; arvalid <= 1'b0; bready <= 1'b0; rready <= 1'b0; done <= 1'b0;
      awaddr <= '0; wdata <= '0; wstrb <= '0; araddr <= '0; awprot <= '0; arprot <= '0;
    end else begin
      lfsr <= {lfsr[30:0], lfsr[31] ^ lfsr[21] ^ lfsr[1] ^ lfsr[0]};
      bready <= (lfsr % 100) < rdy_pct;
      rready <= ((lfsr >> 7) % 100) < rdy_pct;
      if (awvalid && awready) begin awvalid <= 1'b0; aw_done <= 1'b1; end
      if (wvalid && wready)   begin wvalid  <= 1'b0; w_done  <= 1'b1; end
      if (arvalid && arready) arvalid <= 1'b0;
      if (bvalid && bready) b_pend <= 1'b1;          // b_pend = B seen for the current write
      if (rvalid && rready) r_pend <= 1'b1;          // r_pend = R seen for the current read
      case (ops[pc])
        OP_W: case (wph)
          2'd0: begin
            awaddr <= a_v[pc]; wdata <= d_v[pc]; wstrb <= s_v[pc];
            if (k_v[pc] >= 0) awvalid <= 1'b1;
            if (k_v[pc] <= 0) wvalid <= 1'b1;
            skew_cnt <= (k_v[pc] < 0) ? -k_v[pc] : k_v[pc];
            b_pend <= 1'b0; wph <= 2'd1;
          end
          2'd1: begin
            if (skew_cnt > 0) begin
              skew_cnt <= skew_cnt - 1;
              if (skew_cnt == 1) begin if (k_v[pc] > 0) wvalid <= 1'b1; else awvalid <= 1'b1; end
            end else if (aw_done && w_done) wph <= 2'd2;
          end
          default: if (b_pend || (bvalid && bready)) begin
            wph <= 2'd0; aw_done <= 1'b0; w_done <= 1'b0; b_pend <= 1'b0; pc <= pc + 1;
          end
        endcase
        OP_R: begin
          if (wph == 2'd0) begin araddr <= a_v[pc]; arvalid <= 1'b1; r_pend <= 1'b0; wph <= 2'd1; end
          else if (r_pend || (rvalid && rready)) begin wph <= 2'd0; r_pend <= 1'b0; pc <= pc + 1; end
        end
        OP_WAIT: begin
          if (wait_cnt + 1 >= k_v[pc]) begin wait_cnt <= 0; pc <= pc + 1; end
          else wait_cnt <= wait_cnt + 1;
        end
        OP_WAITCK: if (ckpt == a_v[pc]) pc <= pc + 1;
        default: done <= 1'b1;
      endcase
    end
  end
endmodule
/* verilator lint_on UNUSEDSIGNAL */
