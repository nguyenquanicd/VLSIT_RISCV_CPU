// -----------------------------------------------------------------------------
// AI-GENERATED (Claude Opus 5.5, 2026-11-28) - candidate artifact (R-117, R-231).
// mon_axi: passive AXI4 monitor (plan 5.2 mon_axi_mem / mon_axi_mmio; R-124).
// Records one NDJSON 'axi' record per completed handshake (IHI 0022H A3.2).
// It has no output port and drives nothing. Schema: models/README.md.
// Plusarg: +<PFX>_MON=<file.ndjson>
// -----------------------------------------------------------------------------
module mon_axi #(parameter int IDW = 7, parameter string PFX = "MEM") (
  input logic clk, input logic rst_n,
  input logic [IDW-1:0] awid, input logic [63:0] awaddr, input logic [7:0] awlen, input logic [2:0] awsize,
  input logic [1:0] awburst, input logic awlock, input logic [3:0] awcache, input logic [2:0] awprot,
  input logic [5:0] awatop, input logic awvalid, input logic awready,
  input logic [63:0] wdata, input logic [7:0] wstrb, input logic wlast, input logic wvalid, input logic wready,
  input logic [IDW-1:0] bid, input logic [1:0] bresp, input logic bvalid, input logic bready,
  input logic [IDW-1:0] arid, input logic [63:0] araddr, input logic [7:0] arlen, input logic [2:0] arsize,
  input logic [1:0] arburst, input logic arlock, input logic [3:0] arcache, input logic [2:0] arprot,
  input logic arvalid, input logic arready,
  input logic [IDW-1:0] rid, input logic [63:0] rdata, input logic [1:0] rresp, input logic rlast,
  input logic rvalid, input logic rready
);
  int fd;
  longint unsigned cyc;
  string port;
  initial begin
    string f;
    fd = 0; cyc = 0; port = (PFX == "MEM") ? "mem" : "mmio";
    if ($value$plusargs({PFX, "_MON=%s"}, f)) fd = $fopen(f, "w");
  end
  always @(posedge clk) begin
    cyc <= cyc + 1;
    if (fd != 0) begin
      if (!rst_n) begin
        if (cyc == 0 || $past(rst_n)) $fwrite(fd, "{\"type\":\"axi\",\"port\":\"%s\",\"ch\":\"RST\",\"cycle\":%0d}\n", port, cyc);
      end else begin
        if (awvalid && awready)
          $fwrite(fd, "{\"type\":\"axi\",\"port\":\"%s\",\"ch\":\"AW\",\"cycle\":%0d,\"id\":%0d,\"addr\":\"0x%016h\",\"len\":%0d,\"size\":%0d,\"burst\":%0d,\"lock\":%0d,\"cache\":%0d,\"prot\":%0d,\"atop\":%0d}\n",
                  port, cyc, awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot, awatop);
        if (wvalid && wready)
          $fwrite(fd, "{\"type\":\"axi\",\"port\":\"%s\",\"ch\":\"W\",\"cycle\":%0d,\"data\":\"0x%016h\",\"strb\":%0d,\"last\":%0d}\n",
                  port, cyc, wdata, wstrb, wlast);
        if (bvalid && bready)
          $fwrite(fd, "{\"type\":\"axi\",\"port\":\"%s\",\"ch\":\"B\",\"cycle\":%0d,\"id\":%0d,\"resp\":%0d}\n", port, cyc, bid, bresp);
        if (arvalid && arready)
          $fwrite(fd, "{\"type\":\"axi\",\"port\":\"%s\",\"ch\":\"AR\",\"cycle\":%0d,\"id\":%0d,\"addr\":\"0x%016h\",\"len\":%0d,\"size\":%0d,\"burst\":%0d,\"lock\":%0d,\"cache\":%0d,\"prot\":%0d}\n",
                  port, cyc, arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot);
        if (rvalid && rready)
          $fwrite(fd, "{\"type\":\"axi\",\"port\":\"%s\",\"ch\":\"R\",\"cycle\":%0d,\"id\":%0d,\"data\":\"0x%016h\",\"resp\":%0d,\"last\":%0d}\n",
                  port, cyc, rid, rdata, rresp, rlast);
      end
    end
  end
  final if (fd != 0) $fclose(fd);
endmodule
