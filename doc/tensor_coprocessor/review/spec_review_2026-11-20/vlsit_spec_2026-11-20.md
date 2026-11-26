# Specification review of VLSIT Tensor Coprocessor - 2026-11-20

## 1. Summary

| Item | Value |
|---|---|
| Design | `VLSIT Tensor Coprocessor` |
| Review | Specification review |
| Date | 2026-11-20 |
| Findings | 22 |
| Critical | 1 |
| High | 11 |
| Medium | 8 |
| Low | 2 |
| Waivable | 1 |
| Fixable | 19 |

Verdict: Conditional (weighted score 2.95 of 5). Gate: `RESULT: PASS` after waiver W-2 of F-001 granted by the project owner on 2026-11-21 (before: FAIL), waiver usage 2/10.
Full bilingual report: `REVIEW_VLSIT_TENSOR_COPROCESSOR.md`.

## 2. Findings

Each finding has an assessment, a verdict and, when it can be fixed, the RTL change
and the reason it works.

### F-001 The host commit frontier the IP depends on has no mapped CVA6 implementation

- Severity: `Critical`
- Evidence: `doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:4240; doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:148-149; rtl/common/third_party/cva6/core/cvxif_issue_register_commit_if_driver.sv:57-64`
- Assessment: FACT. REQ-IF-006 and REQ-IF-007 require a per-hart, age-ordered fault-resolved commit frontier and a kill rule; RV-017 states the signal mapping and host RTL remain P0, and the pinned CVA6 driver emits commit from issue-valid and ready with commit_kill tied to zero, so DMA could start before an older load or branch fault.
- Verdict: `fix`
- Fix: Add a host-side requirement and a signal table (scoreboard age, fault-resolved, squash suffix, per-hart ledger) for the modified cvxif_issue_register_commit_if_driver, and gate every DMA, output and result effect on the matching non-kill authorization.
- Why: The IP is safe only if no tensor DMA starts before older host work is fault-free; naming the host signals turns RV-017 from an open risk into a design and verification item.

```systemverilog
// authorise a tensor command only after the older work is fault-resolved
assign commit_valid_o = issue_valid_o & issue_ready_i & w_frontier_clear;
assign commit_o.commit_kill = w_squash_hit;
```

### F-002 The 2 GHz goal has no technology basis and shares the host clock

- Severity: `High`
- Evidence: `doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:3723; doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:1023-1030; https://arxiv.org/html/2505.03762v2 (accessed 2026-11-20); doc/specification/review/VLSIT_RISCV_CPU_Consolidated_Review_2026-11-20.md section 2A`
- Assessment: INFERENCE. PPA-001 sets at least 1 GHz and a 2 GHz characterization point for CFG-64TOPS at an SS corner, while §1.2 selects no technology; the tensor datapath shares CLK-CORE with the CVA6 host (§7.1). The related cluster synthesis (ARM sc12 55LPx RVT, ss 1.08 V 125 C) measured a 3.40 ns CVA6 critical path, and a published GF22 FDX synthesis reports about 1.09 GHz at 0.72 V and -40 C, so the host alone bounds the clock.
- Verdict: `fix`
- Fix: Record the PDK, library and corner in §1.2, add a decision that a reference PE (carry-propagate, carry-save, two-bank) must close at the target period in that flow before RTL freeze, and reject PARA_ACCUM_W of 48 or 64 with a period below the proven value at elaboration.
- Why: A measured PE result turns the 2 GHz goal into a pass or fail and lets the host clock be decoupled (a separate compute clock, §7.1) only when the experiment shows the datapath, not the host, is the limit.

### F-003 64 TOPS peak has no sustained target and the first memory path is one 256-bit AXI port

- Severity: `High`
- Evidence: `doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:3726; doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:3729; doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:794; doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:73 (FEAT-006: 2.048 TB/s)`
- Assessment: FACT. PPA-004 states an ideal peak of 65.536 TOPS (16 arrays of 32 by 32 at 2 GHz) and FEAT-006 says it needs up to 2.048 TB/s of on-chip operand injection; PPA-007 gives the first target as one 256-bit AXI port with minimum SoC bandwidth, SRAM and arbitration left to sign-off, and §6.1.1 says the port does not sustain 64 TOPS for every workload.
- Verdict: `fix`
- Fix: Add REQ-PERF-004: sustained INT8 TOPS and array utilization at the DEC-018 prefill points, with the required external bandwidth and SRAM size derived from the tile model, and mark CFG-64TOPS as unusable until they are met.
- Why: Peak arithmetic is not a requirement; a sustained target with its bandwidth shows whether one 256-bit port or a wider memory path is needed.

### F-004 Latency and tokens-per-second targets are still TBD

- Severity: `High`
- Evidence: `doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:4225; doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:3727-3728; doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:3732`
- Assessment: FACT. RV-002 (Critical) says numeric latency targets remain TBD and its follow-up asks the team to supply them; PPA-005, PPA-006 and PPA-010 only define what to report, and the earlier 50 ms per token figure is called a preliminary example.
- Verdict: `fix`
- Fix: Add a table of targets (TTFT, p95 inter-token latency, tokens per second, handler-entry bound) for one named model, batch and context length, and a sign-off column that names the build and the measurement test.
- Why: Without a number every pipeline-cut and array-count decision stays unjustified, and the decode path cannot be judged.

### F-005 No area or power basis although the structure implies a very large array

- Severity: `High`
- Evidence: `doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:3724-3725; doc/specification/review/VLSIT_RISCV_CPU_Consolidated_Review_2026-11-20.md section 2A.1 (10.56 um2 per sequential cell)`
- Assessment: INFERENCE. PPA-002 and PPA-003 are qualitative. As a structural proxy, 16 arrays of 32 by 32 PEs hold 16,384 accumulators of 32 bits, so at least 524,288 accumulator flops; using the 10.56 um2 average sequential cell of the supplied ARM sc12 55LPx RVT synthesis this is about 5.5 mm2 before multipliers, operand registers and SRAM (proxy, not a mapped number for this design).
- Verdict: `fix`
- Fix: Add to §13 a proxy table per configuration (MAC count, accumulator flops, operand-register flops, SRAM bits per bank) and require a mapped number with library and corner before a configuration is marked released.
- Why: The cost of CFG-64TOPS is then visible against the edge-SoC budget before the RTL is written.

### F-006 Power goal is 'datapath-active only' while no clock gating is allowed

- Severity: `High`
- Evidence: `doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:1023-1030; doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:4079-4090; doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:3725`
- Assessment: FACT. §7.1 and §16 state there is no internal clock gating and the clock-gating test enable is N/A, while PPA-003 sets the power goal as datapath-active only; an array of 16,384 MACs that is idle between commands would still toggle its clock tree.
- Verdict: `fix`
- Fix: Replace the no-ICG rule by a rule that array and SRAM-bank clocks use integrated clock-gating cells with a test_en input driven by the DFT wrapper, and state the idle-power behavior of PPA-003.
- Why: Gating is the main lever for idle array power and a test_en port keeps the gated flops scannable.

### F-007 Interface timing budgets are integrator-supplied or TBD, including the AXI data path

- Severity: `High`
- Evidence: `doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:4104-4112`
- Assessment: FACT. §17.1.2 lists CV-X-IF and APB budgets as 'integrator' and the IF-003 tensor-data path as burst and width TBD with SDC after port sizing; CLK-CORE has no period or uncertainty.
- Verdict: `fix`
- Fix: Add to §17.1.2 an input and output budget per port group (percent of the period), a rule that ready and valid outputs come from registers, and the AXI width and outstanding-request sizing used for the budget.
- Why: The cluster experience shows that unbudgeted combinational input-to-output paths dominate interface violations; a stated budget prevents the same pattern here.

### F-008 The normative CV-X-IF revision is a development release

- Severity: `High`
- Evidence: `doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:98; doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:762; doc/tensor_coprocessor/reference/md_doc/vlsit_cvxif_openhw_core_v_xif_v1_0_0.md`
- Assessment: FACT. REF-001 names the Core-V eXtension interface Release v1.0.1-dev.0 (Development, 2024-05-23) as the protocol authority, while the locally converted reference is the v1.0.0 document (file vlsit_cvxif_openhw_core_v_xif_v1_0_0.md); the two can differ in clause numbers and behavior.
- Verdict: `fix`
- Fix: Change REF-001 to the ratified v1.0.0 and list each use of a development-only behavior as a deviation, or pin the development commit hash and update the local converted copy to match.
- Why: A development release can change; the protocol authority must be one fixed document that the converted copy and the clause citations both match.

### F-009 Occupancy of the fused batch-one projection is unmeasured

- Severity: `Medium`
- Evidence: `doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:4239; doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:1572; doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:4327 (DEC-073)`
- Assessment: FACT. A matrix-vector and small-M dataflow profile exists (REQ-FUNC-010, §10 line 1972), but RV-016 (Critical) notes that a 1 by K by K by V projection on a 32-row output-stationary mapping occupies one PE row (3.125 percent) and DEC-073 leaves the build tile geometry and latency evidence open, so the occupancy of the fused OP-004 build is not defined.
- Verdict: `fix`
- Fix: Add the occupancy and cycles per token of the selected fused dataflow (direct array, split-K or vector-dot lanes) for both PARA_ARGMAX_IMPL builds to §13, and close RV-016 only when the benchmark meets the decode target.
- Why: Decode is the latency-critical phase and an unmeasured 3.125 percent occupancy can dominate cycles per token.

### F-010 One active command owns every array, so short operations idle the MACs

- Severity: `Medium`
- Evidence: `doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:4260 (DEC-006); doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:4226 (RV-003)`
- Assessment: INFERENCE. The first release schedules one active command across all arrays and hands over at completion; row softmax, layer normalization and argmax are limited by exp, reciprocal and reduction lanes (PPA-008) while the MAC arrays are idle.
- Verdict: `fix`
- Fix: Add array-utilization per operation to the PPA-006 report and set a trigger (for example below a stated utilization on the representative workload) for the deferred cross-command scheduler.
- Why: A measured utilization shows whether the deferred overlap is worth its verification cost.

### F-011 The OP-003 zero-result fence stalls every hart across an asynchronous round trip

- Severity: `High`
- Evidence: `doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:165 (REQ-ERR-004); doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:1044-1045 (CDC-005, CDC-006)`
- Assessment: INFERENCE. REQ-ERR-004 holds a global all-hart issue stall for an OP-003 result of zero until software reads and clears the error record and writes scalar_ack through APB (CDC-005, CDC-006); zero is a common result (a sum of zeros, a max after ReLU), so the slow path is frequent and a software error could hold the stall.
- Verdict: `fix`
- Fix: Add a requirement that bounds the fence duration (a timeout that releases with an error status) and a workload measurement of the OP-003 zero-result rate; record the alternative of a distinct scalar encoding for an error.
- Why: A bounded fence prevents a software fault from freezing all harts and the measurement shows whether the global stall is rare enough to keep.

### F-012 A missing AXI response is recoverable only by full SoC reset

- Severity: `High`
- Evidence: `doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:4245; doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:4283; doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:155`
- Assessment: FACT. AXI4 has no cancel for an accepted transaction; the user rejected tensor-local abort and DEC-029 selects full SoC reset after a watchdog timeout, with the host waiting on a pending result in the meantime.
- Verdict: `waive`
- Why: Approved by the user decision recorded in DEC-029 and RV-022.
- Risk: A stuck memory target stalls the issuing hart and all tensor work until the SoC watchdog resets the chip; accepted by DEC-029.
- Owner: SoC architect
- Invalidation: The SoC has no watchdog or full-reset path, or a product availability target forbids chip-wide reset.

### F-013 ECC is optional and only parity on one SRAM is mentioned

- Severity: `Medium`
- Evidence: `doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:4129-4140`
- Assessment: FACT. §18 lists 'optional parity on MEM-001' with simulation as the check and no ECC requirement for the banks that hold weights, accumulators or recurrent state, and no error-injection requirement for them.
- Verdict: `fix`
- Fix: Add REQ-RAS-001 choosing parity with detect-and-fail or SECDED per bank (operand, result, recurrent state) and an error-injection test that reports the corrupted command through the first-error record.
- Why: A silent bit flip in a weight bank produces a wrong token without any report, which is the failure the error record is meant to expose.

### F-014 Multi-tenant isolation and side channels are left open

- Severity: `Medium`
- Evidence: `doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:152; doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:4129-4140`
- Assessment: FACT. The DMA firewall is an immutable BASE and LIMIT aperture and the spec states it does not isolate S-mode code or two U-mode clients; §18 marks information leakage open for multi-tenant operation and a single global CSR record exposes physical error addresses.
- Verdict: `fix`
- Fix: Add a scope statement that release 1 supports one trusted S-mode driver and one tenant, and move multi-tenant isolation, error-address masking and secure scrub to a future requirement with an owner.
- Why: A stated scope prevents a deployment from assuming isolation the hardware does not provide.

### F-015 No coverage thresholds although properties and covergroups exist

- Severity: `Medium`
- Evidence: `doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:4031-4045`
- Assessment: FACT. The specification has 35 properties (for example SVA-001) and cover points but no section sets a line, toggle, functional or assertion-coverage threshold.
- Verdict: `fix`
- Fix: Add a coverage table to §15.3 with a threshold per metric and a rule that an unreachable point needs a written justification before sign-off.
- Why: A threshold turns the coverage report into a pass or fail criterion.

### F-016 No tensor RTL exists; every configuration is verification-planned

- Severity: `Low`
- Evidence: `doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:205-207`
- Assessment: FACT. The configuration table states 'Planned; simulation/lint have not run because tensor RTL is absent' for CFG-BASE and 'Analytical only' for CFG-64TOPS, so the 76 decisions and 62 requirements have not been exercised.
- Verdict: `none`
- Why: no change needed; kept as a recorded result.

### F-017 Version 0.1 with no revision history, a review table inside the normative text

- Severity: `Medium`
- Evidence: `doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:6; doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:4222-4247`
- Assessment: FACT. The front matter still says version 0.1 and no revision history exists although the document grew to 76 decisions; §20.1 embeds a review-findings table (RV-001 to RV-022) in the normative text, and the file has about 4,400 lines averaging more than 200 characters.
- Verdict: `fix`
- Fix: Add a revision history after the front matter, bump the version at each approved change, move §20.1 to the review folder and wrap long table rows into sub-tables.
- Why: A reader can then tell which revision a test or review refers to and read the normative text without review commentary.

### F-018 Earlier reviews are not re-baselined against the current specification

- Severity: `Medium`
- Evidence: `doc/tensor_coprocessor/README.md:16; doc/tensor_coprocessor/review/VLSIT_TENSOR_COPROCESSOR_Rereview_2026-11-17.md:6`
- Assessment: FACT. The README links the 2026-11-17 review and the architecture-options analysis but not the re-review, and the 2026-11-17 re-review cites an HDS of 1,743 lines while the file now has 4,356 lines; the status of each earlier finding is not recorded in the specification.
- Verdict: `fix`
- Fix: Add the re-review to the README and a status column (closed, open, superseded) per earlier finding in the review folder.
- Why: A re-baselined list avoids reopening items that were already closed and shows what is still open.

### F-019 An edge-SoC product with a 64 TOPS headline and an open workload envelope

- Severity: `High`
- Evidence: `doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:60; doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:69; doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:73; https://newsroom.arm.com/blog/ethos-u85 (accessed 2026-11-20)`
- Assessment: INFERENCE. §1.2 says target shapes and the accuracy and latency envelope remain open, yet FEAT-002 and FEAT-006 size the IP at 65.536 TOPS and up to 2.048 TB/s on-chip injection; Arm's edge NPU Ethos-U85 is published at 128 to 2048 MACs per cycle, 256 GOPS to 4 TOPS at 1 GHz with transformer support, so the stated target is 16 times larger than that edge class.
- Verdict: `fix`
- Fix: Add the target model, its batch and context length and the SoC power and area budget to §1.2, and derive the array count from them instead of from the 64 TOPS headline.
- Why: A budget-derived array count keeps the IP inside the edge envelope and gives the 64 TOPS configuration a stated reason or a retirement.

### F-020 No PPA or utilization evidence against commercial and open reference accelerators

- Severity: `High`
- Evidence: `https://newsroom.arm.com/blog/ethos-u85 (accessed 2026-11-20); https://arxiv.org/pdf/2511.10397 (accessed 2026-11-20); https://github.com/ucb-bar/gemmini (accessed 2026-11-20); doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:3726`
- Assessment: INFERENCE. Arm states the Ethos-U85 reaches 4 TOPS in silicon in a 2048-MAC configuration; the open Gemmini generator offers a 16 by 16 systolic array of 512 ops per cycle over RoCC and a configuration study estimates 41.49 percent of peak for one workload. This specification gives peak only, with no sustained, area or power evidence to place it against them.
- Verdict: `fix`
- Fix: Add a market-position note to §1 with the commercial and open reference points (source and date) and require sustained utilization and area per TOPS for each released configuration.
- Why: The CV-X-IF coprocessor pattern is competitive in flexibility only if its sustained efficiency is comparable.

### F-021 The port list and AXI sizing are still candidates

- Severity: `Medium`
- Evidence: `doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:4252; doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:3729; doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:4109`
- Assessment: FACT. ASM-002 (packed CV-X-IF payload ports) is open, PPA-007 gives a 256-bit, 16-read, 8-write candidate and §17.1.2 marks IF-003 sizing TBD, so the top-level module boundary is not frozen even though the parameter caps are.
- Verdict: `fix`
- Fix: Close ASM-002 with the flattened CV-X-IF port list and freeze the IF-003 width, outstanding reads and writes, and burst size in §6.1.1 as release-1 values.
- Why: The SDC, the RTL top and the integration wrapper all need the same fixed boundary.

### F-022 Several earlier findings are closed in the current specification

- Severity: `Low`
- Evidence: `doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:4270; doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:149; doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md:3732; doc/tensor_coprocessor/review/VLSIT_TENSOR_COPROCESSOR_Rereview_2026-11-17.md:22-37`
- Assessment: FACT. The roofline now separates 8.2 TOPS at T=128 from the 64 TOPS goal, the control FSM has ERR_DRAIN, the CSR record holds hart, ID and status, DEC-016 separates the tensor top from the cluster, and REQ-IF-007 and PPA-010 give an interrupt and debug handler-entry bound.
- Verdict: `none`
- Why: no change needed; kept as a recorded result.

## 3. Actions

| Action | Owner | Blocks sign-off |
|---|---|---|
| Specify the CVA6 change as a requirement with its signal map before RTL start. (F-001) | CVA6 integration | yes |
| Choose the technology and corner, and gate the accumulator-loop architecture on a processing-element experiment. (F-002) | Architect | no |
| Add a sustained-throughput requirement per workload and the bandwidth it implies. (F-003) | Architect | no |
| Set numeric TTFT, inter-token and handler-entry targets for a named model. (F-004) | Architect / Product | no |
| Add a structural area table and a power estimation method with assumptions. (F-005) | Spec | no |
| Allow approved ICG cells with a test-enable port or require operand isolation, and align PPA-003. (F-006) | Architect / DFT | no |
| State a port-group budget as a percent of the period and the register-output rule. (F-007) | Architect | no |
| Pin the ratified v1.0.0 or record the exact development commit and the differences. (F-008) | Spec | no |
| Measure the zero-result frequency and consider returning an error flag in the result instead. (F-011) | Architect | no |
| Keep the approved decision and require a SoC watchdog and interrupt path. (F-012) | SoC architect | no |
| Tie the array count to a named model and an SoC power and area budget. (F-019) | Product / Architect | no |
| Add a comparison row set with sustained utilization and area per TOPS once available. (F-020) | Product | no |
| Characterize the fused dataflow (direct, split-K or vector lanes) and state its occupancy before the ABI freeze. (F-009) | Architect | no |
| Report utilization per operation and decide when cross-command overlap is required. (F-010) | Architect | no |
| Decide the protection level per memory. (F-013) | Architect | no |
| State single-tenant as the supported scope or specify per-client isolation. (F-014) | Security / Architect | no |
| Set coverage thresholds per release configuration. (F-015) | Verification | no |
| Add a revision table and move the review table to a separate file. (F-017) | Spec | no |
| Link the re-review and record a status per earlier finding. (F-018) | Spec | no |
| Freeze the port list and the AXI data-path sizing together. (F-021) | Architect | no |

## 4. Limits

- No simulation, lint or synthesis was run; no tensor RTL exists.
- Structural CDC and RDC, ASIC timing, area and power were not assessed; the area figure is a proxy.
- The CSR workbook, figures and waveforms were not opened; the instruction-set companion was sampled.
- Market data comes from vendor pages, a paper and a repository dated in the full report, not from datasheets.

