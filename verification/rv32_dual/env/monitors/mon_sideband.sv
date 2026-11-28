// -----------------------------------------------------------------------------
// AI-GENERATED (Claude Opus 5.5, 2026-11-28) - candidate artifact (R-117, R-231).
// mon_sideband: passive monitor of reset, boot, IRQ, debug, PMU and fault pins
// (REF-001 rev 0.39 Section 6.2). Emits an NDJSON 'pin' record on every change.
// Drives nothing (R-124). Plusarg: +PIN_MON=<file.ndjson>
// -----------------------------------------------------------------------------
module mon_sideband #(parameter int HARTS = 2) (
  input logic clk, input logic rst_n, input logic [63:0] boot_addr,
  input logic [HARTS-1:0] msip, input logic [HARTS-1:0] mtip, input logic [HARTS-1:0] meip,
  input logic [HARTS-1:0] ssip, input logic [HARTS-1:0] stip, input logic [HARTS-1:0] seip,
  input logic [HARTS-1:0] dbg_req, input logic [HARTS-1:0] dbg_mode,
  input logic int_pmu, input logic int_fault
);
  int fd;
  longint unsigned cyc;
  logic [6*HARTS+2*HARTS+3-1:0] prev;
  wire  [6*HARTS+2*HARTS+3-1:0] now = {rst_n, int_fault, int_pmu, dbg_mode, dbg_req, seip, stip, ssip, meip, mtip, msip};
  initial begin
    string f;
    fd = 0; cyc = 0; prev = '1;
    if ($value$plusargs("PIN_MON=%s", f)) fd = $fopen(f, "w");
  end
  task automatic emit(string name, int idx, logic v);
    if (fd != 0) $fwrite(fd, "{\"type\":\"pin\",\"name\":\"%s\",\"index\":%0d,\"value\":%0d,\"cycle\":%0d}\n", name, idx, v, cyc);
  endtask
  always @(posedge clk) begin
    cyc <= cyc + 1;
    if (now != prev || cyc == 0) begin
      for (int h = 0; h < HARTS; h++) begin
        if (cyc == 0 || msip[h] != prev[0*HARTS+h]) emit("i_int_msip", h, msip[h]);
        if (cyc == 0 || mtip[h] != prev[1*HARTS+h]) emit("i_int_mtip", h, mtip[h]);
        if (cyc == 0 || meip[h] != prev[2*HARTS+h]) emit("i_int_meip", h, meip[h]);
        if (cyc == 0 || ssip[h] != prev[3*HARTS+h]) emit("i_int_ssip", h, ssip[h]);
        if (cyc == 0 || stip[h] != prev[4*HARTS+h]) emit("i_int_stip", h, stip[h]);
        if (cyc == 0 || seip[h] != prev[5*HARTS+h]) emit("i_int_seip", h, seip[h]);
        if (cyc == 0 || dbg_req[h] != prev[6*HARTS+h]) emit("i_hart_debug_req", h, dbg_req[h]);
        if (cyc == 0 || dbg_mode[h] != prev[7*HARTS+h]) emit("o_hart_debug_mode", h, dbg_mode[h]);
      end
      if (cyc == 0 || int_pmu != prev[8*HARTS]) emit("o_int_pmu", 0, int_pmu);
      if (cyc == 0 || int_fault != prev[8*HARTS+1]) emit("o_int_fault", 0, int_fault);
      if (cyc == 0 || rst_n != prev[8*HARTS+2]) begin
        emit("i_rst_n_cluster", 0, rst_n);
        if (fd != 0) $fwrite(fd, "{\"type\":\"pin\",\"name\":\"i_boot_addr\",\"index\":0,\"value\":\"0x%016h\",\"cycle\":%0d}\n", boot_addr, cyc);
      end
    end
    prev <= now;
  end
  final if (fd != 0) $fclose(fd);
endmodule
