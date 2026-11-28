// -----------------------------------------------------------------------------
// AI-GENERATED (Claude Opus 5.5, 2026-11-28) - candidate artifact (R-117, R-231).
// drv_sideband: drives reset, boot address, per-hart IRQ levels and debug
// requests (REF-001 rev 0.39 Section 6.2, 7.3; RV32 HDS 6.2 i_boot_addr).
// Reset: active low for +RST_CYCLES (default 16) after time 0; optional second
// (coordinated, DEC-041) reset when the MMIO checkpoint equals +RESET_AT_CKPT,
// held for +RESET_HOLD cycles. Asynchronous assertion, deassertion on a clock edge.
// IRQ/debug levels come from the MMIO control window (bfm_axi_sub CTRL=1).
// +BOOT_ADDR=<hex> (default 0x80000000); levels are synchronous to clk.
// -----------------------------------------------------------------------------
module drv_sideband #(parameter int HARTS = 2) (
  input  logic                   clk,
  input  logic [31:0]            ckpt,
  input  logic [HARTS-1:0][5:0]  irq_level,
  input  logic [HARTS-1:0]       dbg_level,
  output logic                   rst_n,
  output logic [63:0]            boot_addr,
  output logic [HARTS-1:0]       msip, output logic [HARTS-1:0] mtip, output logic [HARTS-1:0] meip,
  output logic [HARTS-1:0]       ssip, output logic [HARTS-1:0] stip, output logic [HARTS-1:0] seip,
  output logic [HARTS-1:0]       dbg_req,
  output logic                   reset_event   // pulse: second reset asserted
);
  int unsigned rst_cycles, reset_hold, cnt;
  logic [31:0] reset_ckpt;
  logic        reset_armed, in_second;
  initial begin
    logic [63:0] b;
    rst_cycles = 16; reset_hold = 32; reset_ckpt = 32'hFFFF_FFFF; b = 64'h0000_0000_8000_0000;
    void'($value$plusargs("RST_CYCLES=%d", rst_cycles));
    void'($value$plusargs("RESET_HOLD=%d", reset_hold));
    void'($value$plusargs("RESET_AT_CKPT=%h", reset_ckpt));
    void'($value$plusargs("BOOT_ADDR=%h", b));
    boot_addr = b;          // stable through reset release (REQ-SYS-003)
    rst_n = 1'b0; cnt = 0; reset_armed = (reset_ckpt != 32'hFFFF_FFFF); in_second = 1'b0; reset_event = 1'b0;
  end
  always @(posedge clk) begin
    reset_event <= 1'b0;
    if (!rst_n) begin
      cnt <= cnt + 1;
      if (cnt + 1 >= (in_second ? reset_hold : rst_cycles)) begin rst_n <= 1'b1; cnt <= 0; in_second <= 1'b0; end
    end else if (reset_armed && ckpt == reset_ckpt) begin
      rst_n <= 1'b0; reset_armed <= 1'b0; in_second <= 1'b1; reset_event <= 1'b1;
    end
  end
  always_comb begin
    for (int h = 0; h < HARTS; h++) begin
      msip[h] = irq_level[h][0]; mtip[h] = irq_level[h][1]; meip[h] = irq_level[h][2];
      ssip[h] = irq_level[h][3]; stip[h] = irq_level[h][4]; seip[h] = irq_level[h][5];
    end
    dbg_req = dbg_level;
  end
endmodule
