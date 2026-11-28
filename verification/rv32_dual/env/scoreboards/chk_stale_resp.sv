// -----------------------------------------------------------------------------
// AI-GENERATED (Claude Opus 5.5, 2026-11-28) - candidate artifact (R-117, R-231).
// chk_stale_resp: online checker of REQ-RST-001 / DEC-041 (no response to a
// pre-reset request may be delivered after cluster reset release). Counts, per
// AXI ID, requests outstanding when reset asserts; after release any R/B
// handshake whose ID has no post-reset request outstanding is a violation, and
// so is any R/B handshake with no outstanding request at all (IHI 0022H A3.3).
// Passive. Plusarg: +STALE_LOG=<file.ndjson>
// -----------------------------------------------------------------------------
module chk_stale_resp #(parameter int IDW = 7, parameter string PFX = "MEM") (
  input logic clk, input logic rst_n,
  input logic [IDW-1:0] awid, input logic awvalid, input logic awready,
  input logic [IDW-1:0] bid,  input logic bvalid,  input logic bready,
  input logic [IDW-1:0] arid, input logic arvalid, input logic arready,
  input logic [IDW-1:0] rid,  input logic rlast,   input logic rvalid, input logic rready
);
  int unsigned wr_out [1 << IDW], rd_out [1 << IDW];
  int unsigned stale_wr [1 << IDW], stale_rd [1 << IDW];
  longint unsigned violations, resets, cyc;
  int fd;
  logic prev_rst_n;
  initial begin
    string f;
    fd = 0; violations = 0; resets = 0; cyc = 0; prev_rst_n = 1'b1;
    foreach (wr_out[i]) begin wr_out[i] = 0; rd_out[i] = 0; stale_wr[i] = 0; stale_rd[i] = 0; end
    if ($value$plusargs({PFX, "_STALE_LOG=%s"}, f)) fd = $fopen(f, "w");
  end
  always @(posedge clk) begin
    cyc <= cyc + 1;
    prev_rst_n <= rst_n;
    if (!rst_n) begin
      if (prev_rst_n) begin
        resets <= resets + 1;
        for (int i = 0; i < (1 << IDW); i++) begin stale_wr[i] <= wr_out[i]; stale_rd[i] <= rd_out[i]; wr_out[i] <= 0; rd_out[i] <= 0; end
      end
    end else begin
      if (awvalid && awready) wr_out[awid] <= wr_out[awid] + 1;
      if (arvalid && arready) rd_out[arid] <= rd_out[arid] + 1;
      if (bvalid && bready) begin
        if (wr_out[bid] == 0 || (awvalid && awready && awid == bid && wr_out[bid] == 0)) begin
          violations <= violations + 1;
          if (fd != 0) $fwrite(fd, "{\"type\":\"stale\",\"port\":\"%s\",\"ch\":\"B\",\"id\":%0d,\"pre_reset_outstanding\":%0d,\"cycle\":%0d}\n", PFX, bid, stale_wr[bid], cyc);
        end else wr_out[bid] <= wr_out[bid] - 1 + ((awvalid && awready && awid == bid) ? 1 : 0);
      end
      if (rvalid && rready && rlast) begin
        if (rd_out[rid] == 0) begin
          violations <= violations + 1;
          if (fd != 0) $fwrite(fd, "{\"type\":\"stale\",\"port\":\"%s\",\"ch\":\"R\",\"id\":%0d,\"pre_reset_outstanding\":%0d,\"cycle\":%0d}\n", PFX, rid, stale_rd[rid], cyc);
        end else rd_out[rid] <= rd_out[rid] - 1 + ((arvalid && arready && arid == rid) ? 1 : 0);
      end
    end
  end
  final if (fd != 0) begin
    $fwrite(fd, "{\"type\":\"stale_summary\",\"port\":\"%s\",\"violations\":%0d,\"resets\":%0d}\n", PFX, violations, resets);
    $fclose(fd);
  end
endmodule
