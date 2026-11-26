# Single dual-hart integrated scenario / Kich ban tich hop 2 hart

## Configuration / Cau hinh

One CASE-CLUSTER-2H, one build, one simulator process and one final verdict. Use
the production AXI TOP at HDS 0.34, two harts, timing profile 2 and the default
64-bit memory port. Retain production LLC geometry unless a separately reviewed
resource pilot calls for a reduced model. Both harts boot real firmware and
report phase signatures. The testbench models synchronous memory, MMIO,
AXI4-Lite software access and the external debug peer required by the HDS.
Simulated peers never drive internal cache, coherence or datapath handshakes.

Mot case, mot lan build, mot qua trinh mo phong va mot ket qua cuoi. Hai hart
chay firmware that. Bao cao phai cho thay tung interface va component da co
giao dich duoc chap nhan va ket qua duoc checker xac nhan.

## Sequence / Trinh tu

| Phase | HDS basis | Stimulus and independent pass evidence |
|---|---|---|
| Boot/PMA | TEST-001, TEST-051, TEST-057 | Boot both harts, check mhartid, then use disjoint cacheable, uncached and MMIO ranges. Confirm MMIO writes/reads at the MMIO BFM and memory traffic at the memory BFM. A returned sentinel confirms neither path was routed to the wrong target. |
| Ownership and atomics | TEST-036, TEST-058, TEST-059 | Hart 0 writes a dirty line, hart 1 reads and claims it, then the harts contend with cached LR/SC and AMO. The memory target separately checks uncached exclusive signaling and supported AWATOP against an atomic reference model. |
| Cache maintenance | TEST-060, TEST-061 | Check ordinary dirty eviction and progress under deterministic AXI stalls. Run CBO.CLEAN and self-modifying code with FENCE.I. Compare values and CPU signatures to firmware expectations. |
| Control and IRQ | TEST-009, TEST-013, TEST-043, OPEN-DV | Access the implemented cluster PMU and LLC service windows by AXI4-Lite. Check a snapshot against counted traffic, exercise the supported LLC service operations, verify target hart IRQ pending/trap and WFI wake. Check the PMU interrupt path separately within the same simulator process using the approved overflow method. |
| Debug and probe | TEST-062, DEP-006 | Assert a per-hart debug request through the TOP. Require debug status and confirm that a second hart can retrieve the halted hart's dirty line. Model the external debug peer only to the extent required by the pinned integration. |
| Fatal fault and reset | TEST-050, DEC-036, DEC-041 | Inject failing AXI B during a real dirty eviction. Check sticky fault IRQ, first-fault CSR and correct reset recovery. Reset DUT and peers together, retain backing memory, and observe new firmware signatures without accepting old responses. |

A single PASS requires all mandatory phase verdicts, both hart signatures,
assertion success, and nonzero witnessed activity for every in-scope interface
and component. Keep ordinary protocol/backpressure checking active in every
phase. Preserve the single Makefile command, exact firmware images/source,
source hashes, logs and per-phase observability checklist. Use the previously
approved serial build and RAM/disk limits. This is a system integration scenario
for one configuration. The ACE profile is deferred. Parameter sweeps, full
formal/coverage closure, DFT, and physical STA are separate obligations.

## Decision before implementation / Diem can chot

The PMU counters expose snapshot, not a software preload used by this scenario.
To observe o_int_pmu in a practical run, use a local testbench-only preload
near wrap at a dedicated phase. Record it explicitly as injected state. Use
real source events for the final increment and check the sticky cause, IRQ and
software clear. This proves the wrap-to-IRQ path from the chosen state, while
normal counting/snapshot is independently demonstrated earlier. If only
external stimulus is permitted, set the overflow observation to a separate
obligation requiring the full count-to-wrap duration.
