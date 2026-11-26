# R-04 Probe-Claim Fix / Kết quả sửa R-04

## Outcome / Kết quả

**EN:** The probe scheduler now atomically reserves every expected hart service slot for one PREPARE context before issuing any probe. If one target slot is busy, the context claims none. A fair round-robin context pointer selects the next eligible all-target claim. Existing tags, per-hart interfaces, line locks, PREPARE/COMMIT/ABORT behavior, and the no-timeout policy remain unchanged.

**VI:** Probe scheduler hiện đặt chỗ nguyên tử toàn bộ slot service của các hart đích cho một context PREPARE trước khi phát probe. Nếu một slot bận, context không giữ slot nào. Con trỏ round-robin chọn context đủ điều kiện tiếp theo. Tag, interface từng hart, line lock, hành vi PREPARE/COMMIT/ABORT và chính sách không timeout được giữ nguyên.

## Files changed / File đã sửa

- `rtl/common/vlsit/coherence/m_vlsit_riscv_probe_scheduler.sv` — global round-robin all-target claim, same-edge owner assignment, and request gating on the owned tag.
- `verification/non_coherence_cluster/atomic_end_to_end/tb_probe_phase_owner.sv` — warm-up skews H3's local request pointer; two contexts then target H2/H3. Checks same-tag ownership, terminal release, loser progress, and overlap for disjoint masks.
- `verification/non_coherence_cluster/atomic_end_to_end/run_probe_owner.py` — corrected the scheduler source path to the current `coherence/` directory.
- `doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md` — revision 0.31; added REQ-MEM-024, TEST-056, DEC-043, resource ordering, fairness/performance limits, and WF-023.
- `doc/specification/architecture/VLSIT_RISCV_CPU_Cluster_Architecture.md` — revision 0.5; aligned the architecture summary with HDS 0.31.
- `doc/specification/review/VLSIT_RISCV_CPU_Consolidated_Review_2026-11-20.md` — records the R-04 implementation and evidence limits.
- `doc/specification/figures/waveforms/WF-023_probe_atomic_claim.json` and `.svg` — abstract event ordering; no cycle-latency promise.

## Checks / Kiểm tra

| Check | Result |
|---|---|
| Baseline 4-hart probe-owner unit after correcting the stale runner path | PASS before RTL change |
| Updated focused simulation, Verilator 5.053 | PASS at 920 ns; atomic overlapping-mask ownership and disjoint-mask progress |
| Verilator `--lint-only --Wall` on `m_vlsit_riscv_probe_scheduler` | PASS |
| VLSIT RTL rule check on the changed scheduler | PASS, 0 errors / 0 warnings |
| WF-023 label-fit check and SVG render | PASS |
| HDS checker | Reports one English-only rule error because this project HDS is intentionally bilingual; changing it to English-only would conflict with the project documentation requirement |
| Full TOP lint at 2/4 harts and formal wait-for proof | Not run; remain qualification work |

Simulation log: `verification/non_coherence_cluster/reports/atomic_coherence/probe_unit/simulation_4h_error0.log`.

## Snapshot / Bản gốc

The pre-edit scheduler, testbench, runner, HDS, architecture document, and review were copied under `baseline/`. Existing unrelated worktree changes were preserved.
