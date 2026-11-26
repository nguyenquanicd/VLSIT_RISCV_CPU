# Cluster verification plan v1 — G0 review

**Status:** G0 approved on 2026-11-16. Sealed baseline `c63915dda7ebe05d498225a19df115bf3576c556ccf9e0411279864075cc57ce` executed as `qualification_v1_initial_002` and cold-replayed as `qualification_v1_replay_001`; helper reports `REPLAY_EXECUTED: MATCH`. This qualifies only four initial FENCE.I smoke cases, not the full 97-row plan. Formal and clean lint have not been completed. Coverage remains below the approved 100% targets.

## Scope

- Normative basis: HDS v0.29, Section 3 and Section 15; 58 HDS requirements total.
- In scope: 57 active HDS requirements, plus five protocol-clause obligations listed in `requirements.txt`.
- Deferred: `REQ-IF-004` external ACE profile. The current qualification is the non-coherent external AXI profile with an internally coherent 2/4-hart MESI domain.
- Bus contract: PULP AXI4 with the supported `AWATOP` extension. This is not AXI4 base and not full AXI5. Verify AWATOP only where enabled by the pinned source. Uncached LR/SC uses exclusive-access signaling; AWATOP is for the supported AMO subset.
- Clock/physical metrics: no Fmax, area or power pass criterion is claimed; required implementation inputs are absent.

## Configuration matrix

- Top elaboration and memory-path smoke: hart count 2 and 4 crossed with external memory bus width 32, 64, 128 and 256 bits (8 configurations).
- Full architectural/coherence regression: both hart counts at 64-bit baseline, plus all width-specific adapter tests. Add full CPU runs at other widths if smoke or adapter checks reveal a discrepancy.
- Orthogonal sweeps: CCU contexts 2/8/16; PMU counters 1/16/32 with widths 32/64; address regions 1/16; default production LLC geometry.
- Reset test uses the approved coordinated-reset contract for cluster and connected transaction endpoints. Backing memory contents persist; accepted pre-reset writes may have committed, but their old responses cannot enter the released cluster.

## Test architecture

- Drive the production cluster TOP; do not derive expected answers from internal RTL state.
- Build an independent architectural/data-memory oracle, MESI+directory reference model, transaction/AXI response scoreboard, and separate AXI4-Lite CSR model from the HDS and protocol clauses.
- Use legal bus BFMs and passive monitors; do not label a project-local BFM as a qualified commercial VIP.
- Run directed requirement tests first, then constrained-random coherence/ordering/backpressure and fault injection. Retain every seed and the generated stimulus.
- Test CCU safety in formal; prove liveness only under explicit fairness assumptions. The HDS allows an ACK to be withheld forever, so no finite liveness bound is claimed for that environment.
- Run checker mutation tests in disposable copies; report killed, survived, invalid and equivalent mutations.
- Existing reports and the historical 58-case CPU evidence are not credited until cold-replayed with the new source snapshot and independent checkers.

## Code coverage contract

- Target **100% line, 100% expression and 100% toggle**, separately.
- RTL denominator: the active TOP filelist contains 35 VLSIT-created/generated files and 84 active modified licensed-source files. The 100% target applies to the **full contents** of all 119 files, not just changed lines. The source hashes and upstream counterparts are listed in `active_rtl_source_scope.json`.
- 343 active source files sit under `third_party` paths. They are reuse candidates, not automatic exclusions: compare each against its exact pinned source revision before G1. Any local modification joins the 100% target; only proven unchanged source is reported separately without a threshold. Two verification-support sources are outside DUT coverage.
- This target is demanding: CVA6/FPU/MMU/LLC paths in the modified source set may require broad architectural tests. Existing 58 CPU cases cannot be presumed to reach 100%.
- Use Verilator 5.053 as the candidate. Expression coverage replaces condition coverage; reports must call it expression coverage.
- Report each metric per configuration and as an applicable-configuration union. Never average percentages. Each legal generated branch must be hit in a configuration where it exists. No implicit coverage waiver; unreachable points remain open unless separately proved and approved.
- Functional, assertion, mutation and protocol coverage are required alongside code coverage; 100% code coverage alone is not closure.

## Protocol source clauses

| ID | Source clause | Planned evidence |
|---|---|---|
| PROTO-AXI-A3.2 | Arm IHI 0022H, basic read/write transactions and VALID/READY handshake | Independent channel monitors/checkers, stalls, independent channel timing, ID/response association |
| PROTO-AXI-A7.2 | Arm IHI 0022H, exclusive accesses | Uncached LR/SC sequence, matching IDs, EXOKAY/OKAY and failure semantics |
| PROTO-AXI-B1.1 | Arm IHI 0022H, AXI4-Lite definition | Single-beat/full-width rules, WSTRB, response and error behavior |
| PROTO-AXI-B1.2 | Arm IHI 0022H, AXI4-Lite interoperation | AXI4-Lite to RegBus bridge ordering/response association |
| PROTO-AXI-E1.1 | Arm IHI 0022H, AMBA 5 atomic transaction semantics | Only the pinned PULP `AWATOP` subset; extension semantics, IDs, responses and unsupported operations |

Official source: [Arm IHI 0022H](https://developer.arm.com/-/media/Arm%20Developer%20Community/PDF/IHI0022H_amba_axi_protocol_spec.pdf?hash=6325311012DDADF238C35A6C0FD734E520754F82&la=en&revision=71bd7c57-2ed7-487b-bc3e-68c4ab56fa5f).

## Gate and planned deliverables

After G0 approval, create a self-contained `verification/sim/` package with one top-level Makefile, source snapshot and hashes, requirement and test assets, independent models, BFMs, coverage/assertions, generated-source provenance, per-run manifests, exact replay commands and retained run evidence. All new simulation/testbench collateral will remain below `verification/`; existing logs/evidence will not be overwritten.

The active source inventory is derived from the current AXI TOP filelist closure; it resolves five filelists and lists all 464 source hashes. At least 119 files are confirmed in the 100% coverage denominator; the source-provenance audit may increase that count before G1.

The plan is machine-checked with the skill validator. That check validates planning traceability only and is not simulation, lint, formal or coverage evidence.
