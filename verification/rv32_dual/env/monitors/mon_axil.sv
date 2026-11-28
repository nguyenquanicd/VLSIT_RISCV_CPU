// -----------------------------------------------------------------------------
// AI-GENERATED (Claude Opus 5.5, 2026-11-28) - candidate artifact (R-117, R-231).
// mon_axil: passive AXI4-Lite monitor (plan 5.2; R-124). Pairs AW and W in
// arrival order and emits one 'axil' record per B handshake; one per R
// handshake (IHI 0022H B1). Also emits raw 'axilch' records per handshake so
// the scoreboard can detect lost or duplicate responses. Drives nothing.
// Plusarg: +AXIL_MON=<file.ndjson>
// -----------------------------------------------------------------------------
module mon_axil (
  input logic clk, input logic rst_n,
  input logic [31:0] awaddr, input logic awvalid, input logic awready,
  input logic [31:0] wdata, input logic [3:0] wstrb, input logic wvalid, input logic wready,
  input logic [1:0] bresp, input logic bvalid, input logic bready,
  input logic [31:0] araddr, input logic arvalid, input logic arready,
  input logic [31:0] rdata, input logic [1:0] rresp, input logic rvalid, input logic rready
);
  int fd;
  longint unsigned cyc;
  logic [31:0] aw_q[$], ar_q[$], wd_q[$];
  logic [3:0]  ws_q[$];
  function automatic string resp_s(logic [1:0] r);
    return (r == 2'b00) ? "OKAY" : (r == 2'b01) ? "EXOKAY" : (r == 2'b10) ? "SLVERR" : "DECERR";
  endfunction
  initial begin
    string f;
    fd = 0; cyc = 0;
    if ($value$plusargs("AXIL_MON=%s", f)) fd = $fopen(f, "w");
  end
  always @(posedge clk) begin
    cyc <= cyc + 1;
    if (!rst_n) begin
      aw_q.delete(); ar_q.delete(); wd_q.delete(); ws_q.delete();
    end else begin
      if (awvalid && awready) begin aw_q.push_back(awaddr); if (fd != 0) $fwrite(fd, "{\"type\":\"axilch\",\"ch\":\"AW\",\"cycle\":%0d,\"addr\":\"0x%08h\"}\n", cyc, awaddr); end
      if (wvalid && wready)   begin wd_q.push_back(wdata); ws_q.push_back(wstrb); if (fd != 0) $fwrite(fd, "{\"type\":\"axilch\",\"ch\":\"W\",\"cycle\":%0d}\n", cyc); end
      if (arvalid && arready) begin ar_q.push_back(araddr); if (fd != 0) $fwrite(fd, "{\"type\":\"axilch\",\"ch\":\"AR\",\"cycle\":%0d,\"addr\":\"0x%08h\"}\n", cyc, araddr); end
      if (bvalid && bready && fd != 0) begin
        if (aw_q.size() > 0 && wd_q.size() > 0)
          $fwrite(fd, "{\"type\":\"axil\",\"op\":\"write\",\"cycle\":%0d,\"addr\":\"0x%08h\",\"wdata\":\"0x%08h\",\"wstrb\":%0d,\"resp\":\"%s\"}\n",
                  cyc, aw_q.pop_front(), wd_q.pop_front(), ws_q.pop_front(), resp_s(bresp));
        else
          $fwrite(fd, "{\"type\":\"axilch\",\"ch\":\"B_ORPHAN\",\"cycle\":%0d,\"resp\":\"%s\"}\n", cyc, resp_s(bresp));
      end
      if (rvalid && rready && fd != 0) begin
        if (ar_q.size() > 0)
          $fwrite(fd, "{\"type\":\"axil\",\"op\":\"read\",\"cycle\":%0d,\"addr\":\"0x%08h\",\"rdata\":\"0x%08h\",\"resp\":\"%s\"}\n",
                  cyc, ar_q.pop_front(), rdata, resp_s(rresp));
        else
          $fwrite(fd, "{\"type\":\"axilch\",\"ch\":\"R_ORPHAN\",\"cycle\":%0d,\"resp\":\"%s\"}\n", cyc, resp_s(rresp));
      end
    end
  end
  final if (fd != 0) $fclose(fd);
endmodule
