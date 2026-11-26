# RTL review fix plan — 2026-11-20

Scope: implement the report's direct RTL findings R-01, R-02, R-03 and R-13, plus the two stale comments called out by R-18. Reused CVA6, HPDcache and LLC sources remain untouched.

1. `m_vlsit_axil_reg_bridge.sv` — prevent a mapped but write-protected LLC register request from entering `WR_REQ`; keep its single local `SLVERR` response. This prevents any RegBus write side effect.
2. `m_vlsit_riscv_cpu_tile.sv` — connect CVA6 `irq_i` as `{SEIP, MEIP}` because CVA6 assigns bit 0 to MEIP and bit 1 to SEIP.
3. `m_vlsit_riscv_cluster_core.sv` and `m_vlsit_riscv_coh_fabric.sv` — move cited module-scope signal declarations ahead of first use, without changing logic.
4. `m_vlsit_riscv_hpd_probe_engine.sv` — drive protocol valids low and recover to IDLE for an illegal FSM encoding.
5. Core and top comments — correct stale CMO and AXI4-Lite aperture descriptions.

Validation requested: static source inspection and diff review only in this change set. No simulation, lint, rule checker, synthesis or timing run is included. R-04 through R-26 remain outside this patch unless directly addressed above.

