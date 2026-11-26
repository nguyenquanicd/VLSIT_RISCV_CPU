# R-04 Atomic Probe Claim Change Plan

## Authorized scope
The designer approved the proposed deadlock fix and requested the specification update.

## Baseline
The worktree contains unrelated pre-existing changes, including an earlier edit in `m_vlsit_riscv_coh_fabric.sv`. Those changes will be preserved. Current versions of the scheduler, focused probe-owner testbench, and authoritative HDS are snapshotted under `baseline/`.

## Planned edits
1. `rtl/common/vlsit/coherence/m_vlsit_riscv_probe_scheduler.sv`
   - Add one fair round-robin claim arbiter over active PREPARE contexts.
   - Grant a context only when every hart in its expected probe mask can be reserved in the same clock edge.
   - Keep the existing per-hart phase owner through successful COMMIT/ABORT; do not issue PREPARE before the full claim exists.
   - Preserve tagged response matching and unrelated/disjoint-hart concurrency.
2. `verification/non_coherence_cluster/atomic_end_to_end/tb_probe_phase_owner.sv` and its focused runner if needed
   - Add a 4-hart directed test that advances one hart's local round-robin pointer, then presents two transactions requiring the same two harts.
   - Require the first transaction's tag to own both probe channels, complete it, then require the waiting transaction to proceed. This reproduces the old cross-claim condition and checks forward progress under responsive caches.
3. `doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md`
   - Add a normative requirement, test row, traceability row, decision DEC-043, and the atomic all-target claim behavior to §10.2.4's wait-for/resource-order contract.
   - Add a resource-claim figure and symbolic handshake waveform; do not claim a fixed latency.
4. `doc/specification/architecture/VLSIT_RISCV_CPU_Cluster_Architecture.md`
   - Keep the architecture summary and wait-for explanation consistent with the authoritative HDS.

## Behavior preserved
- PREPARE/COMMIT/ABORT tags, line locks, no-timeout ACK policy, response/error behavior, MESI transitions, directory behavior, and cache interfaces remain unchanged.
- A transaction waiting for a busy target owns no partial set of hart probe slots.

## Checks
- Run the existing baseline focused probe scheduler simulation before editing.
- Run the updated directed 4-hart probe scheduler simulation.
- Run Verilator lint for the scheduler and project TOP 2/4 elaborations if resources/tools allow; compare with current baseline and retain logs.
- Validate HDS requirement/test references, waveform source/rendering, and the exact changed-file diff.
