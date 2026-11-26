// Controlled faults for fault qualification (rule R-096). Selected with +FAULT=<n>.
// Each fault forces one DUT signal of the RV32 adaptation or of the path a testcase depends on.
// The expected detecting check of each fault is recorded in verification/rv32_profile/FAULTS.md.
`define TILE(h) dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile
  initial begin
    @(posedge i_rst_n_cluster);
    case (fault)
      1: force `TILE(1).w_core_hart_id = 32'd0;                                  // TC-01: hart 1 reports id 0
      2: force `TILE(0).w_core_boot_addr = 32'h8000_0004;                         // TC-02: hart 0 skips the first instruction
      3: force `TILE(1).w_core_probe_req_nline = `TILE(1).i_coh_probe_req_nline[29:0] ^ 30'h1; // TC-04/05: probe hits the wrong line
      4: force `TILE(0).w_core_probe_req_nline = `TILE(0).i_coh_probe_req_nline[29:0] ^ 30'h1; // TC-05: owner probed at the wrong line
      5: force `TILE(0).o_cmo_req_pa_line = 52'(`TILE(0).w_core_cmo_req_pa_line) + 52'd1;           // TC-07: CMO cleans the next line
      6: force `TILE(0).u_dont_touch_cva6.ex_stage_i.i_mult.result_o = '0;               // TC-02: multiplier/divider result lost
      7: force `TILE(0).u_dont_touch_cva6.ex_stage_i.fpu_gen.fpu_i.fpu_gen.fpu_status = 5'h0;    // TC-03: FPU exception flags lost
      8: force `TILE(1).w_core_own_gnt_nline = `TILE(1).i_coh_cache_gnt_nline[29:0] ^ 30'h1; // TC-06: grant line adapter corrupt
      9: force `TILE(0).u_dont_touch_cva6.csr_regfile_i.satp_q = '0;                     // TC-08: translation disabled
      10: force dut.o_axi_mmio_wstrb = 8'h0F;                                             // TC-09: MMIO strobes in the wrong lane
      default: ;
    endcase
  end
`undef TILE
