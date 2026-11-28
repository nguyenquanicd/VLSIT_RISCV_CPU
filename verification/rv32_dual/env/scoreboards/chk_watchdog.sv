// -----------------------------------------------------------------------------
// AI-GENERATED (Claude Opus 5.5, 2026-11-28) - candidate artifact (R-117, R-231).
// chk_watchdog: finite test timeout (R-109, R-127; plan 6.2 cycle budgets).
// The cluster has no timeout of its own (REF-001 REQ-MEM-013); this is a
// test-harness budget, not DUT behaviour. Ends the run when every hart has
// written TOHOST (pass) or the cycle budget expires (fail).
// Plusargs: +TIMEOUT_CYCLES=<n> (default 2000000), +WD_LOG=<file.ndjson>
// -----------------------------------------------------------------------------
module chk_watchdog #(parameter int HARTS = 2) (
  input logic clk, input logic rst_n,
  input logic [HARTS-1:0] tohost_done, input logic [HARTS-1:0][31:0] tohost_code,
  output logic finished, output logic expired
);
  longint unsigned budget, cyc;
  int fd;
  initial begin
    string f;
    budget = 2000000; cyc = 0; fd = 0; finished = 1'b0; expired = 1'b0;
    void'($value$plusargs("TIMEOUT_CYCLES=%d", budget));
    if ($value$plusargs("WD_LOG=%s", f)) fd = $fopen(f, "w");
  end
  always @(posedge clk) begin
    cyc <= cyc + 1;
    if (!finished && !expired) begin
      if (rst_n && &tohost_done) begin
        finished <= 1'b1;
        if (fd != 0) for (int h = 0; h < HARTS; h++)
          $fwrite(fd, "{\"type\":\"watchdog\",\"event\":\"tohost\",\"hart\":%0d,\"code\":\"0x%08h\",\"cycle\":%0d}\n", h, tohost_code[h], cyc);
      end else if (cyc >= budget) begin
        expired <= 1'b1;
        if (fd != 0) $fwrite(fd, "{\"type\":\"watchdog\",\"event\":\"expired\",\"tohost_done\":%0d,\"cycle\":%0d}\n", tohost_done, cyc);
        $display("WATCHDOG: cycle budget %0d expired", budget);
      end
    end
  end
  final if (fd != 0) $fclose(fd);
endmodule
