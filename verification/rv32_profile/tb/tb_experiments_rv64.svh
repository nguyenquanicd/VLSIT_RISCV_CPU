// Step 2b experiments (OPEN-X32-CBO4), 64-bit build only, selected with +EXPERIMENT=<n>. No RTL file changes:
// the experiments force HPDcache controller nets in simulation only, to test the two root-cause hypotheses.
//  1: hpdcache.sv passes a SHARED ownership grant to hpdcache_ctrl as coh_atomic_grant_i, so a pending AMO
//     takes atomic permission (DEC-038) while it still needs unique ownership and blocks the competing
//     PREPARE probe. Experiment 1 counts only E/M grants.
//  2: experiment 1 plus: the RTAB fence (which stops new core requests) drops as soon as the fenced AMO
//     loses its pend_trans dependency, although the AMO is still in the RTAB. A younger same-line load is
//     then linked behind it; when the AMO is rolled back again with pend_trans, fence_only can never become
//     true. Experiment 2 keeps the fence while any non-read entry (AMO) is valid in the RTAB.
`define HPD(h) dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache
  int experiment;
  initial begin
    if (!$value$plusargs("EXPERIMENT=%d", experiment)) experiment = 0;
    if (experiment != 0) $display("EXPERIMENT %0d", experiment);
  end
  for (genvar gh = 0; gh < HARTS; gh++) begin : gen_exp
    initial begin
      #1;
      if (experiment >= 1)
        force `HPD(gh).hpdcache_ctrl_i.coh_atomic_grant_i = `HPD(gh).coh_own_gnt_valid_i && `HPD(gh).coh_own_gnt_ready_o
                                                          && !`HPD(gh).coh_own_gnt_err_i && `HPD(gh).coh_own_gnt_state_i[1];
      if (experiment >= 2)
        force `HPD(gh).hpdcache_ctrl_i.rtab_fence = (|`HPD(gh).hpdcache_ctrl_i.hpdcache_rtab_i.fence_bv)
                                                  | (|(`HPD(gh).hpdcache_ctrl_i.hpdcache_rtab_i.valid_q
                                                       & ~`HPD(gh).hpdcache_ctrl_i.hpdcache_rtab_i.is_read_bv));
    end
  end
`undef HPD
