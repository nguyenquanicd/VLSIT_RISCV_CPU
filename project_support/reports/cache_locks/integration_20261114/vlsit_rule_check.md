# RTL rule check

Files: m_vlsit_cpucl_csr.sv, m_csr_async_fifo.sv, m_csr_sync.sv, m_csr_sync_fifo.sv, m_vlsit_axil_reg_bridge.sv, m_vlsit_pmu_aggregate.sv, m_vlsit_pmu_cluster_evt.sv, m_vlsit_pmu_counter_bank.sv, m_vlsit_pmu_event_select.sv, m_vlsit_pmu_hart_evt.sv, m_vlsit_pmu_irq.sv, m_vlsit_pmu_snapshot.sv, m_vlsit_riscv_addr_decode.sv, m_vlsit_riscv_axi_mmio.sv, m_vlsit_riscv_axi_route.sv, m_vlsit_riscv_axil_decode.sv, m_vlsit_riscv_cache_line_locks.sv, m_vlsit_riscv_cluster_axi_top.sv, m_vlsit_riscv_cmo_controller.sv, m_vlsit_riscv_coh_bank_arb.sv, m_vlsit_riscv_coh_txn_table.sv, m_vlsit_riscv_cpu_tile.sv, m_vlsit_riscv_debug_router.sv, m_vlsit_riscv_pmu.sv, m_vlsit_riscv_probe_scheduler.sv, m_vlsit_riscv_sharer_directory.sv, m_vlsit_riscv_tile_coh_adapter.sv

| Level | Rule | File:line | Finding |
|---|---|---|---|
| WARN | HIE-02 | m_vlsit_cpucl_csr.sv:12 | module has instances and also logic; a structural top should contain instances only (HIE-02) |
| WARN | HIE-02 | m_vlsit_riscv_axi_mmio.sv:12 | module has instances and also logic; a structural top should contain instances only (HIE-02) |
| WARN | HIE-02 | m_vlsit_riscv_axi_route.sv:12 | module has instances and also logic; a structural top should contain instances only (HIE-02) |
| WARN | HIE-02 | m_vlsit_riscv_cpu_tile.sv:23 | module has instances and also logic; a structural top should contain instances only (HIE-02) |
| WARN | HIE-02 | m_vlsit_riscv_tile_coh_adapter.sv:22 | module has instances and also logic; a structural top should contain instances only (HIE-02) |
| WARN | NAM-08 | m_vlsit_riscv_cluster_axi_top.sv:40 | parameter 'PARA_PMU_COUNTER_NUM' spells out 'counter'; NAM-08 writes 'cnt' |
| WARN | NAM-08 | m_vlsit_riscv_cluster_axi_top.sv:44 | parameter 'PARA_PMU_COUNTER_W' spells out 'counter'; NAM-08 writes 'cnt' |
| WARN | NAM-08 | m_vlsit_riscv_cmo_controller.sv:46 | port 'o_cmo_error' spells out 'error'; NAM-08 writes 'err' |
| WARN | NAM-08 | m_vlsit_riscv_cmo_controller.sv:69 | port 'i_maint_error' spells out 'error'; NAM-08 writes 'err' |
| WARN | NAM-08 | m_vlsit_riscv_cpu_tile.sv:80 | port 'o_dcache_flush_ack_error' spells out 'error'; NAM-08 writes 'err' |

Rules failed: none
Rules warned: HIE-02, NAM-08
Rules clean: ARI-04, CMT-01, CMT-05, COM-02, COM-03, COM-04, COM-06, COM-07, ENM-01, ENM-03, ENM-04, ENM-05, ENM-06, FIL-01, FIL-02, FIL-03, FIL-04, FIL-05, FIL-06, HIE-01, HIE-03, HIE-05, NAM-07, NAM-09, NAM-TBL, P1, P11, P12, P13, P14, P17, P18, P19, P2, P20, P21, P22, P24, P25, P26, P27, P29, P3, P30, P4, P6, P7, PAR-01, PAR-02, PAR-03, R-019, R-027, R-032, R-035, R-036, R-038, R-071, R-072, SCP-01, SEC-8.1, SEQ-01, TYP-02, TYP-06
