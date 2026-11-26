# Tensor Coprocessor Instruction Set and Datapath

Normative companion to the tensor coprocessor HDS.

## 1. Purpose and scope

This file defines the programmer-visible tensor instruction set, command lifecycle, operation families, result behavior, datapath sequence, and descriptor ABI for release 1. It is included by `VLSIT_TENSOR_COPROCESSOR_HDS.md`. HDS requirements remain normative for detailed numerical edge cases, interfaces, errors, security, reset, and physical signoff.

All tensor operations use a DMA descriptor. Release 1 uses `PARA_MEM_PATH=0`. The SoC can back the AXI physical address map with SRAM or DRAM. The RISC-V instruction identifies operation and precision and supplies a descriptor pointer. Bulk operands and tensor outputs travel on non-coherent AXI4/IF-003 through tensor-owned banked SRAM. The CV-X-IF result is a scalar GPR writeback or status/completion only; it never carries tensor tiles. The trusted S-mode driver creates descriptors and validates U-mode buffer handles before issue.

## 2. Instruction encoding

The 32-bit custom instruction uses R-type field placement and major opcode custom-0.

| Bits | Field | Meaning |
|---|---|---|
| 31:25 | `funct7` | Flat operation ID; fixes algorithm family and result class |
| 24:20 | `rs2` | RV32 high 32 descriptor-address bits; RV64 unused by hardware; software encodes x0 |
| 19:15 | `rs1` | RV32 low 32 descriptor-address bits; RV64 full descriptor address |
| 14:12 | `funct3` | `000=INT8`, `001=BF16`, `010=FP16`; other values reserved |
| 11:7 | `rd` | Status destination or operation-defined scalar result |
| 6:0 | `opcode` | `0001011` (`custom-0`, 0x0B) |

| `funct7` | Operation | Algorithm-mask bit | Result class | Release-1 precision scope | Selector |
|---:|---|---:|---|---|---|
| `0x00` | Reserved | — | — | — | Reject at issue |
| `0x01` | OP-001 dense/tiled GEMM | 0 | Status | INT8, BF16, FP16 | Dense GEMM descriptor |
| `0x02` | OP-002 elementwise/epilogue | 3 | Status | INT8, BF16, FP16 | One OP-002 mode per descriptor |
| `0x03` | OP-003 scalar REDUCE | 5 | Scalar | INT8, BF16, FP16 | SUM or MAX; CSR build and `rd!=x0` |
| `0x04` | OP-004 ARGMAX/GREEDY_TOKEN | 5 | Scalar | INT8, BF16, FP16 | Standalone or fused build schema; CSR and `rd!=x0` |
| `0x05` | OP-005 exact tiled attention | 1 | Status | BF16, FP16 | Attention/mask descriptor |
| `0x06` | OP-006 row softmax | 2 | Status | BF16, FP16 | Mask/row descriptor |
| `0x07` | OP-007 LayerNorm | 2 | Status | BF16, FP16 | Affine/epsilon descriptor |
| `0x08` | OP-008 structured 2:4 sparse GEMM | 4 | Status | INT8 | Packed-weight/metadata descriptor |
| `0x09` | OP-009 kernelized causal linear attention | 6 | Status | BF16, FP16 | Feature-map/state descriptor |
| `0x0A`–`0x7F` | Reserved | — | — | — | Reject at issue |

A precision listed above is in scope for qualification. An elaborated build must enable bit 0. Bit 1 also requires bit 2. Bits 1, 2 and 6 require the BF16/FP16 datapaths. Bit 5 requires the CSR mode because both defined opcodes in that family return scalar GPR results. Issue accepts a pair only when its family is enabled, the build includes the datapath, and the pair is qualified for that release build. In an engineering qualification build, exercise explicitly selected candidate pairs to produce that evidence. For example, reject INT8 OP-005 even if INT8 GEMM is enabled, and reject BF16 OP-008 even if the build has BF16 arithmetic. A descriptor-only mode violation after acceptance returns `TC_ERR_DESCRIPTOR_MODE`. It has a completion; an issue-time rejection has no completion and performs no descriptor DMA.

On RV32 the descriptor pointer is `{rs2_value,rs1_value}`; on RV64 it is `rs1_value`, and `rs2` is not requested. The pointer is formed only from the matching accepted CV-X-IF register transaction. At acceptance, the implementation latches operation ID, precision, result class, build variant, `rd`, hart/transaction identity, and pointer. Descriptor contents cannot override operation, precision, or result class.

## 3. Issue, acceptance, and command lifecycle

The tensor-enabled CVA6 host uses `X_ISSUE_REGISTER_SPLIT=0`: issue and register-read handshakes are coupled. The coprocessor accepts only with a free command context and all requested source lanes valid. Rejection allocates no tensor command context or result. The host still resolves the rejected issue in its CV-X-IF commit/kill ordering. A rejected issue may mark the start of a killed younger suffix. In mode 2, a legal instruction waits while the APB enable has not yet synchronized into the core. Acceptance captures the descriptor pointer but does not yet access memory.

CVA6 delays non-kill commit until a per-hart fault-resolved frontier proves the tensor instruction and all older instructions can no longer raise an exception or flush. A command killed before that authorization is discarded with no descriptor DMA, tensor DMA, output write, or result. After matching non-kill commit, the IP reads and validates the descriptor, executes the selected operation, drains accepted memory/array traffic, and returns exactly one completion. An authorized command cannot later be killed.

The queue may capture a different operation/precision while a command computes. First-release scheduling executes one active command at a time; queued commands do not imply array-level command concurrency. Descriptor prefetch for N+1 may overlap N compute only after N+1 has a matching safe commit. Selectors are latched per command, so later mode changes do not alter active state.

## 4. Interface and datapath separation

| Diagram label | Immediate endpoints | Transfers |
|---|---|---|
| XIF / RES | CVA6 host ↔ `m_cvxif_adapter` | Issue instruction word, source register values, acceptance, commit/kill and scalar or status completion. Ready signals travel opposite their corresponding payload. |
| MEM / IF-003 | `m_mem_path` AXI manager ↔ SoC memory fabric through the tensor DMA firewall | Read descriptor, operands and metadata. Write tensor output to its descriptor-specified DMA allocation. Receive data, read status and write responses. The fabric routes addresses to the memory target. |
| MEM-001 | `m_mem_path` and compute controllers ↔ internal banked SRAM | Stage operand/result tiles, ping-pong buffers and live attention/recurrent state. |
| APB / mode 2 | SoC APB manager ↔ `m_csr` | Enable, status, sticky first-error record, W1C and scalar acknowledgment. |
| QREQ / QACK | SoC reset controller ↔ tensor top IF-004 | Request graceful quiesce and acknowledge completed drain before ordinary functional reset. |
| CRCLK | SoC clock/reset control → tensor top | Core clock/reset and APB clock/reset in mode 2. |

The custom instruction word lives in ordinary CPU code memory. CVA6 fetches it through its instruction path and sends it on CV-X-IF issue. Source registers carry the descriptor pointer. After safe commit, `m_mem_path` reads the pointed-to descriptor through IF-003. The descriptor identifies the input and output allocations. Tensor-valued output goes through IF-003. The completion or scalar return goes back to CVA6 on RES and writes `rd` when `we=1`.

The driver performs non-coherent cache maintenance: clean descriptor/input data before issue; clean/invalidate output cache lines before DMA; invalidate outputs after successful completion and drained responses. On an accepted error, discard the whole command output. A write burst that has already offered either AW or W can still update memory during drain. Its address, all data beats and matching response complete before the ordinary error result; a bus timeout follows the full-SoC reset contract. For AXI reads, the matching beat expected from ARLEN must carry RLAST (DEC-074). A late RLAST cannot release the read ID. An unresolved response obligation that reaches the SoC watchdog causes full-SoC reset and abandons the command with no result.

## 5. Result classes and software behavior

The driver must establish producer success and DMA write visibility before submitting a later command that consumes its output. The ABI has no dependency token. Use device-only buffer ownership across a chain only when the platform guarantees visibility and CPU aliases are excluded. See HDS §11.2.

| Result class | Success payload | Accepted-error payload | Tensor output |
|---|---|---|---|
| Status | `TC_STATUS_OK=0` when a nonzero `rd` is requested | Stable nonzero status; sticky first-error CSR also records identity/detail when present | Written through IF-003 |
| OP-003 scalar | SUM/MAX value sign-extended or encoding zero-extended into `rd` | `rd=0`; CSR distinguishes error from valid zero; global fence holds through software check/W1C/ack | None |
| OP-004 scalar | Unsigned winning token index | All-ones XLEN sentinel; CSR holds status | Fused path need not write logits |

Status-result commands in CSR mode may use `rd=x0`; completion has `we=0`. The submitting driver must observe the matching host outcome by handle before consuming or publishing the result buffer. The service-hart journal provides fault details. In mode 0, `rd` must be nonzero so status is observable. Scalar-result IDs require `PARA_CTRL_MODE=2` and `rd!=x0`. Result class/write-enable is fixed at issue and cannot be changed by descriptor parsing.

Both CVA6 profiles use XLEN-bit register payloads and a 64-bit descriptor pointer. For example, an INT8 REDUCE result of -2 is `0xFFFFFFFE` on RV32 and `0xFFFFFFFFFFFFFFFE` on RV64. A BF16 negative zero is `0x00008000` or `0x0000000000008000` respectively. Status is unsigned and zero-extended on RV64. The selected mode-2 host keeps routed hart/transaction identities representable in the 32-bit CSR words used for error attribution.

The sticky CSR keeps the first error with status, hart ID, and CV-X-IF ID; younger execution pauses until W1C. OP-003 additionally requires a global clean tensor boundary and blocks all harts until result attribution. For an all-zero integer GPR payload, software checks `err_valid`, reads/clears any error, writes one-shot `scalar_ack`, then waits for the fence to release. Test the raw bits before interpreting a floating-point encoding. FP negative zero is 0x8000 zero-extended to XLEN and releases the fence on the result handshake.

For the first mode-2 integration, DEC-075 assigns ordinary error service to a privileged agent independent of the submitting hart. The agent saves the complete CSR record under the submission handle before W1C. An ordinary command owner retrieves the saved record by that handle, including when the live CSR is already clear. For OP-003, obtain exclusive access to the error CSRs from that agent after the clean boundary and before issue. Return access after the fenced owner's result check or after a rejection or pre-commit kill has been resolved. OP-003 zero still uses the owner's `err_valid`/W1C/`scalar_ack` sequence. CV-X-IF result fields and descriptor encodings stay the same.
## 6. Operation-by-operation instruction behavior and datapath

The equations below state the operation. HDS REQ-FUNC-014 and REQ-FUNC-018 through REQ-FUNC-023 remain the exact numeric/error contracts; this section explains their use and datapath. Descriptor offsets are fixed in §10.

### OP-001 — Dense/tiled GEMM (`funct7=0x01`)

- **Application:** Transformer Q/K/V/output projections, feed-forward projections, and other dense matrix products. Large prefill tiles favor systolic reuse; decode can use narrow M with N channel tiles.
- **Operation:** `C[M,N] = sum_k(A[M,K]*B[K,N]) + enabled initial_C + enabled bias + enabled residual`. M/N/K always describe logical axes. Independent transpose flags allow each input's two physical axes to be exchanged without a copy; K or N is the innermost contiguous dimension as selected. Output C is row-major with N contiguous.
- **Datapath:** validate schema/layout/spans/caps; for INT8 prove the conservative accumulator bound and validate all per-channel requant records before numeric reads; stream A/B tiles in logical K order through systolic arrays; accumulate; add declared terms in accumulator scale; requantize INT8 with Q31 multiplier/exponent, symmetric nearest-even and saturation, then optional NONE/RELU/LUT8; or for BF16/FP16 accumulate from FP32 +0 using a fused FP32 FMA in increasing logical K order. Carry the FP32 result across K tiles. Then add enabled initial C, bias and residual in that order in FP32 with activation NONE. Use RNE at each FMA/add and at the single final BF16/FP16 conversion. Preserve signed zero and subnormals. NaN or infinity/overflow follows HDS DEC-068 and invalidates the complete output. Store C via IF-003.
- **Caps:** M,N,K<=16,384; dense selected products M*N*K<=2^35; output tiles<=4,096; summed logical input spans<=64 MiB and output spans<=64 MiB. Checked before tensor-data DMA. Split a larger logical operation along M/N only, never K. Check the actual declared physical spans, including pitch gaps and alignment, for every chunk. If disjoint logical N slices share physical span bytes, stage them into disjoint allocations or serialize them under one exclusive output lease with writes restricted to each slice. Any failed chunk invalidates the complete software output.
- **Restriction:** Dense GEMM does not decode sparse metadata; use OP-008 for 2:4 weights.

### OP-002 — Elementwise/epilogue (`funct7=0x02`)

- **Application:** Residual adds, bias, scale, activation, and SwiGLU around Transformer projections/MLPs. A command can process a vector/tensor; producer fusion is only legal where an operation explicitly specifies it.
- **Modes:** One of ADD, BIAS_ADD, RESIDUAL_ADD, SCALE, ACT_ONLY, SWIGLU; activation is NONE, RELU, GELU_TANH, SILU, or LUT8. Shapes must match except 1-D bias broadcast on the last axis. No general broadcast, reduction, or arbitrary sequence of operators. A later queued command may select another mode.
- **INT8 path:** signed symmetric values, zero point 0. Add modes use exact signed-16 sum, one saturation to [-128,127], then activation. SCALE uses signed Q16.16 alpha, a signed 40-bit product, nearest-even shift, and saturation. Nonlinear activation uses the inline 256-byte signed-output LUT. SWIGLU maps gate through the SiLU LUT, multiplies by up in signed 16-bit, then uses the Q31/exponent coefficient and saturates. No integer wrap.
- **BF16/FP16 path:** widen exactly to FP32; round each named node nearest-even; forbid reassociation/FMA contraction; convert once at output. SCALE uses finite FP32 scalar. SWIGLU computes SiLU(gate) then multiplies by up. GELU_TANH is `0.5*x*(1+tanh(0.7978845608*(x+0.044715*x^3)))`; SILU is `x/(1+exp(-x))`. Function error and NaN/Inf tails are as in REQ-FUNC-018.
- **Sequence:** validate mode/activation, shape, scalar and inline table/coefficient before numeric read; stream one/two source tiles to vector lanes; compute in the specified order; output conversion; write via IF-003.

### OP-003 — Scalar REDUCE (`funct7=0x03`)

- **Application:** software-visible one-vector SUM or MAX. Attention/softmax/LayerNorm/ARGMAX internal reductions do not use this opcode.
- **Shape:** one flattened vector, length 1..1,048,576. No mask, multi-axis reduction, or broadcast.
- **INT8:** SUM exactly accumulates raw signed bytes in signed 32 bits; cap bounds magnitude to 134,217,728. MAX uses signed comparison. Sum is sign-extended to XLEN; MAX sign-extends the winning byte.
- **BF16/FP16:** inputs widen to FP32. SUM uses a fixed balanced tree over logical index order, +0 padded leaves, nearest-even at each node, then one conversion; the 16-bit encoding is zero-extended into `rd`. MAX compares decoded values and returns the original winning encoding; +0 wins over -0.
- **Errors:** input/generated NaN, including +Inf + -Inf in SUM, returns `TC_ERR_NUMERIC_NAN` and `rd=0`; remaining infinities follow IEEE behavior. Requires mode 2 and `rd!=x0`. The global fence plus CSR distinguishes a valid zero from failure and requires the W1C/ack sequence.

### OP-004 — ARGMAX/GREEDY_TOKEN (`funct7=0x04`)

- **Application:** greedy next-token choice without returning the vocabulary logits vector to the CPU; no top-k/top-p or stochastic sampling.
- **Build-time path:** `PARA_ARGMAX_IMPL=0` reads an existing logits vector; `=1` fuses final projection and winner reduction. One schema/datapath is built and cannot switch per command. Vocabulary<=65,536; fused input width<=4,096. For fused builds, derive the maximum logical tile visits and worst-case physical AXI traffic from those caps and the fixed build schedule (DEC-073). The build's signed service envelope determines the conditional latency bound.
- **Standalone path:** read valid logits in command precision, decode without another conversion, attach the logical vocabulary index, and merge local/tile winners.
- **Fused path:** compute `z_j=sum_k(x_k*W_kj)+bias_j` and merge `(score,index,valid)` without storing the logits vector. BF16/FP16 compare FP32 accumulators before output rounding. INT8 uses per-output-channel positive scale coefficients and an exact scale-aware wide fixed-point comparator; compare the scaled scores. For example, raw accumulators 10 and 8 with channel scale factors 0.5 and 1 yield scores 5 and 8. The second channel wins. INT8 fused bias is disabled in release 1 because no compatible bias-scale ABI was selected.
- **Winner rule:** larger score wins; exact ties choose lower token index at every lane/tile/array merge. No epsilon band and no completion-arrival tie rule. NaN is an error, -Inf is ineligible, +Inf wins, all -Inf is `TC_ERR_ARGMAX_NO_VALID_LOGIT`. No softmax is computed.
- **Trade-off:** fused avoids a command and full logits materialization, but must read projection weights and can be bandwidth-bound. Standalone is reusable if logits exist or have another consumer. Requires mode 2 and nonzero `rd`; accepted failure returns all-ones XLEN sentinel and CSR status.
- **Software dispatch:** read the integration build manifest before submitting OP-004. A fused build cannot issue the standalone descriptor variant. If software needs an existing logits vector on a fused build, it must select another available reduction path or perform ARGMAX on the CPU. The driver must account for the compare domain when using a fallback. For BF16 scores 1 and 1+2^-9 at indices 0 and 1, fused FP32 comparison selects index 1. Materializing those scores as BF16 makes them tie, so standalone selects index 0.

### OP-005 — Exact tiled attention (`funct7=0x05`)

- **Application:** standard softmax attention for causal decoder or non-causal encoder/vision Transformer models. It is not interchangeable with approximate OP-009.
- **Inputs/caps:** BF16/FP16 Q/K/V and same-precision output; uniform heads; batch 1..4, heads<=64, Lq/Lkv<=2,048, aggregate Q/K and V widths<=4,096, and V width/head<=128. Mask is NONE, CAUSAL with per-sample query position, or BOOL byte matrix shared across heads.
- **Datapath:** widen Q/K/V to FP32. For every valid query/key pair, accumulate QK using increasing-feature FP32 FMA with nearest-even after each FMA, multiply by attention scale and round. Each live query/head holds FP32 online state `(m,l,o)`. Process K/V tiles in increasing key order: mask before max; compute new max; rescale old l/o; evaluate exp weights; fixed balanced key-index reductions update l/o. Each P×V product rounds independently to FP32 before the fixed add tree. A streaming implementation may retain partials by tree level as described in HDS §10.2.2; after final tile use reciprocal of l and convert normalized output once. Empty valid-key row errors. Masked keys never enter max/sum.
- **Scheduling:** keep active `(m,l,o)` in local SRAM across K/V tiles; DMA may fill the next K/V ping-pong bank during compute. Query/head tiles and samples run in configured waves. Tile sizes/context counts are static build choices; they must fit SRAM and pass PPA/accuracy signoff. Different key-tile geometry can change FP rounding and needs tolerance qualification.

For OP-005, DEC-070 holds state on an all-masked tile and uses alpha=+0 on the first nonempty tile for each query row. For OP-005 and OP-006, a centered difference that overflows to -Inf from finite operands yields exp=+0. Existing non-finite operand and all-masked row errors still apply.

### OP-006 — Row softmax (`funct7=0x06`)

- **Application:** normalize a score or vocabulary-logit row where OP-005 cannot fuse score generation and value accumulation.
- **Inputs/caps:** BF16/FP16 logits and probabilities; row_count/row_length<=65,536 and product<=16,777,216. Mask is NONE or byte BOOL; masked outputs are exact +0.
- **Datapath:** per row, fixed balanced max tree over valid logical indices, subtract max, evaluate bounded exp, fixed balanced sum tree with nearest-even at every FP32 node, multiply by pipelined reciprocal, and convert once. Physical scheduling cannot change tree pairing. All-masked row is `TC_ERR_NO_VALID_SOFTMAX_ROW`; masked NaN/Inf is ignored.

The OP-006 implementation may retain FP32 exponentials or recompute them using the same inputs and exp implementation after the denominator is ready. Any DMA replay uses the same immutable logits/mask and the same fixed tree. See HDS §10.2.2.

### OP-007 — LayerNorm (`funct7=0x07`)

- **Application:** pre-attention/pre-MLP LayerNorm. RMSNorm is not encoded by this ID.
- **Inputs/caps:** BF16/FP16; row_count and row_width<=65,536, total<=16,777,216; optional same-precision gamma/beta vectors; finite FP32 epsilon in [2^-24,1].
- **Statistics datapath:** widen x to FP32; create Welford `(count,mean,M2)` leaves; pad with empty identities and merge a fixed balanced logical-index tree, rounding each specified node nearest-even. Compute population variance `M2/row_width`, add epsilon, then bounded pipelined rsqrt.
- **Output datapath:** center x, multiply by inverse standard deviation, optionally multiply gamma and add beta in that order, with nearest-even at named nodes; convert once to BF16/FP16. Welford is more stable than raw-moment subtraction but uses merge state and a row buffer.

### OP-008 — Structured 2:4 sparse GEMM (`funct7=0x08`)

- **Application:** INT8 projections/MLP weights stored in exactly two-of-four structured sparsity, typically from a matching trained/pruned checkpoint. Hardware does not infer sparsity from zeros.
- **Encoding:** for group g/output n, one nibble holds `p0,p1` as two 2-bit positions; valid only if `p0<p1`. Flatten `q=g*N+n`; even q is low nibble. Packed payload order is `[g][n][slot]`; slots map to p0/p1. An unused last high nibble is zero. Zero-valued payload slots are still real products.
- **Datapath:** compute conservative INT8 accumulator bound; validate full requant vector before numeric operands. Fetch and validate selector metadata tile by tile; do not read activation/weight values for a tile until all its selectors/tail fields are valid. Gather two activations, run paired MAC lanes, combine both products, and update accumulator once. Prefetch/validate next metadata tile during current compute when buffers permit. Then apply the common GEMM epilogue and write C.
- **Errors/caps:** bad tile stops unstarted tiles and invalidates the entire destination; earlier tiles may have partial writes, which software discards. Same M/N/K/product/tile/span caps as OP-001; K divisible by four; selected work is M*N*K/2. Paired lanes add area/routing/feed demand and do not promise 2x end-to-end speedup.

### OP-009 — Kernelized causal linear attention (`funct7=0x09`)

- **Application/compatibility:** causal autoregressive attention only for a model trained or validated against this exact approximate formula. It is not standard softmax; hardware never silently falls back from OP-005.
- **Feature map/state:** only `feature_map_id=0`, ELU+1: `phi(x)=x+1` for x>0 and `exp(x)` otherwise. Q/K/V/output use command BF16/FP16; recurrent S/z state is FP32. RESET starts at zero. CONTINUE validates TLAS header/shape/precision/count and finite payload. State input/output buffers are separate; a failed command preserves the old checkpoint.
- **Causal recurrence:** per sample/head, hold S[R,Dv] and z[R]. In token order, first update `S[r,d]=S[r,d]+phi(k[r])*v[d]`, `z[r]=z[r]+phi(k[r])`; then compute `num[d]=sum_r phi(q[r])*S[r,d]`, `den=sum_r phi(q[r])*z[r]` by fixed balanced feature trees and nearest-even FP32 nodes. Output `num/den` and convert once. Update-before-output includes the current token. Denominator below the specified positive threshold errors.
- **Limits/trade-off:** batch<=4, sequence<=65,536, heads<=64, per-head R/Dv<=128, aggregate widths<=4,096; checked state/work caps also apply. State transfer can dominate one-token decode; active-context concurrency must fit SRAM. Model manifest owns accuracy acceptance.

**Vocabulary head dispatch.** Choose a build with standalone OP-004 if the target model normally materializes logits, uses a final OP-008 packed 2:4 projection, or needs the vector for another consumer. The standalone descriptor compares the stored logits, including OP-008 results if they represent one common logit scale and match the model's intended final epilogue. A fused build consumes a dense projection input and dense weights. It does not consume OP-008 selector metadata or a previously stored logits vector. When the model still requires a materialized vector on a fused build, complete its producer, synchronize ownership to CPU, and scan the decoded logits in software if the model permits that score domain. OP-003 MAX returns a value only and does not substitute for the token-index operation.

A model that requires the fused compare domain must instead use an independently qualified path that preserves the pre-conversion scores, for example a CPU reference of the fused dot and comparator. Do not use an already narrowed logits vector to recover that winner. In INT8, a common requantization scale of 1/4 maps accumulator values 509 and 511 to pre-narrow scores 127.25 and 127.75. Fused comparison picks index 1. Both stored logits are 127 after the defined rounding and saturation, so standalone picks index 0. A floating-point producer can differ in fault policy as well: OP-001 rejects non-finite computation results, while a valid +Inf score can win in fused OP-004. Validate token selection in the path the deployed model actually uses.

**Diagnosing ties and near ties.** A token index identifies a vocabulary entry. One word can contain several tokens. A logit is the model's score for a candidate next token at the current prefix. Equal scores give no ordering information within that prefix. The selected OP-004 tie-break is the lower token index, so it yields the same winner across array scheduling and reduction order. This choice supplies reproducibility. It does not measure semantic importance.

For model qualification, use the highest and second-highest eligible scores in the actual comparison domain. For two distinct token indices with finite scores define the margin Delta = s_top1 - s_top2. A zero margin is an exact tie. For finite softmax logits at temperature T, the probability ratio of the two candidates is exp(Delta/T), because their shared normalization cancels. This ratio does not determine either candidate's absolute probability. No softmax pass is needed to compute the margin or the winner. When only one eligible candidate exists, the margin is unavailable. Keep NaN faults, excluded -Inf, unique +Inf, and multiple +Inf as separate cases under OP-004's policy. Do not numerically subtract two infinities.

If every candidate score in a comparison run differs from its reference by at most epsilon in the same scale, a reference top-two margin greater than 2*epsilon guarantees the unique top token is unchanged. At or below that value the bound gives no guarantee. An offline per-channel bound can test the winner's lower score bound against every competitor's upper score bound. This diagnostic leaves the hardware comparison exact in the selected representation. Example: scores 3.00 and 2.96 have a 0.04 margin. An absolute error bound of 0.01 per score guarantees the same winner. A bound of 0.03 does not.

For a standalone build, collect diagnostics by scanning the materialized vector or a qualified reference with matching stored score format. For a fused build, use the corresponding pre-conversion FP32 or exact INT8 scaled-score reference. OP-004 returns only the token index or error sentinel, so hardware execution of the fused instruction alone cannot provide the top-two margin. On fixed prefixes, report exact tie count, near-tie count for a named threshold and score domain, and top-token disagreement by precision and model configuration. Use checkpoint evaluation before changing the decoding policy.

**Chunked vocabulary projection for the standalone build.** When the final projection exceeds OP-001's output-channel or read-span cap, split N into contiguous vocabulary intervals and keep the full K reduction in each command. Use one common stored-logit format and, for INT8, one common output logit scale across the intervals. The chunk output offsets preserve original vocabulary order for the final OP-004 token index.

For example, take batch-one BF16 with K=4,096, V=65,536 and the DEC-064 caps. With no addends, choose 16 chunks of 4,096 channels. Each command uses M=1, K=4,096 and N=4,096. A compact B shard occupies 32 MiB, the shared A row is 8 KiB, and each output slice is 8 KiB. Each command does 16,777,216 products and uses 128 logical output tiles on a 32-column array or 256 on a 16-column array. The commands each pass the first-build work, axis, tile and logical span caps with these compact allocations. They still fetch the whole model weight matrix across all 16 commands.

The B reference must describe a compact shard for this example. If the checkpoint stores B as one row-major [4,096,65,536] tensor, offsetting the base to select a column interval while keeping its 128-KiB global row pitch gives a minimum shard footprint of 536,748,032 bytes. It exceeds the 64-MiB per-command read-span cap even though only 32 MiB of weight payload is useful. Pack the weights into compact per-chunk shards during model preparation or, if the checkpoint stores contiguous [V,K] channel rows, select the corresponding run of rows and set transpose_B. In both cases validate stride, padding, contiguity and the actual aligned declared span.

In a 64-byte alignment example, each chunk writes directly to a disjoint 8-KiB interval of the final 128-KiB logit vector. Keep that complete vector under the producer group's ownership. Observe successful results for every chunk and the required DMA visibility before issuing one standalone OP-004 with vocab_length=65,536. A failed chunk invalidates the whole higher-level vector; never run ARGMAX on a partially valid vector. Reclaim or retry the allocation only after any already accepted commands that can touch it have completed or the specified full-SoC recovery has finished. Splitting N preserves each channel's K order; the standalone compare still uses the stored BF16 scores. Fused projection can choose a different winner in its pre-conversion FP32 score domain.

## 7. Runtime selection and Transformer use

In the first mode-2 build, a dedicated privileged hart performs ordinary DEC-075 fault service. It saves a command's error record before W1C. The dedicated service hart discovers ordinary faults through the level IRQ in DEC-076 and uses bounded periodic APB polling if delivery is delayed or masked. Both triggers share one serialized CSR service routine. IRQ acknowledgment does not clear the fault. OP-003 continues to use the fenced owner's CSR path. Issue CSR W1C and scalar_ack using aligned 32-bit writes with all four byte strobes set, as specified by the HDS APB profile. The submitting driver reads the saved record by the command handle. The service-hart integration candidate waits for the matching host clear completion before reading another multiword CSR snapshot. This allows consecutive errors even when no read observes err_valid clear between them. Fenced OP-003 zero/error checking remains with the owning submitter under DEC-021. The role split does not change instruction encoding, result payloads or the CSR map.

Software dispatches each command from the model manifest, prefill/decode phase, shape, build mask, precision, sparse metadata, and accuracy requirements. Use OP-001 for dense projections; OP-008 only for compatible 2:4 checkpoints; OP-005 for exact attention; OP-009 only for compatible linear-attention models; OP-006 where softmax is standalone; OP-007 for LayerNorm; OP-002 for vector/activation/SwiGLU work; and OP-004 for greedy token extraction. Hardware does not run a variable-latency heuristic to guess which algorithm is better. For OP-005 qualify each fixed tile geometry against the arithmetic and model references. Enable OP-009 for a deployment model only after qualifying its feature map and checkpointed recurrence under the HDS attention quality procedure. A subsequent command may select a new mode while the active command runs, but a mode cannot change within an accepted command. A queued command can complete descriptor validation while the previous command computes. It starts numeric work only after it owns the shared resources and the old state has been released under HDS Section 10.4.

Before submitting from a release driver, use the qualified operation/precision rows and the selected control mode and ARGMAX variant in the trusted platform build record. The record accompanies the generated release issue configuration described in HDS §9.1. Select model-compatible operations only within those rows and validate descriptor modes and buffer limits separately. For example, a build may provide BF16 and FP16 datapaths but qualify OP-005 only for BF16. An application requesting FP16 attention must choose a compatible software path or report unavailable support. The APB version alone cannot establish these capabilities.

### 7.1 Worked exact-attention layer schedule

Consider a decoder layer using LayerNorm, causal softmax attention, and SwiGLU, with BF16 activations and one request. This is one model layout. Use the order required by the actual model manifest.

| Phase | Command and producer/consumer rule |
|---|---|
| Prepare the layer input | Run OP-007 with the model epsilon and optional gamma/beta. Its output must complete successfully before the projections consume it. |
| Form Q, K and V | Run OP-001 projections and place their results into the head/sequence layout required by OP-005. Q, K and V projections are independent once the normalized input is visible. They can be queued with the same immutable input and disjoint outputs. The first-release scheduler still executes one active command at a time. Any layout conversion or model-specific position transform outside the selected operations belongs to the software or another qualified engine. |
| Execute causal attention | In prefill with 128 query tokens and no preceding context, use `Lq=Lkv=128` and `query_position_start=0`. For the next single-token decode, append the new K/V rows in valid memory first, then pass `Lq=1`, `Lkv=129` and `query_position_start=128`. The K/V views must satisfy the validated contiguous-span and pitch rules. This includes the current token in its own attention. For a larger batch use each sample's own validated start position. |
| Apply output projection and MLP | Run output projection and residual addition in model order. For the gated MLP, OP-001 gate/up projections can be queued together once their input is valid. OP-002 SwiGLU reads both outputs and applies SiLU only to the gate before multiplication. Down projection consumes that result after success. Use OP-008 in place of a compatible INT8 projection only with the validated 2:4 weight format and matching quantization. BF16-to-INT8 conversion is a separate model-defined step. |
| Select the token after the last layer | In the fused OP-004 build, use the validated final projection input and weights and return the winning index in `rd`. In the standalone build, complete the final projection, then submit its stored logits to OP-004. Compare each build in its defined score domain. The logits need no OP-006 step for greedy selection. |

The driver can prepare independent descriptors and buffer leases while hardware works, and the host may prefetch a queued descriptor only after its safe commit. Queue a consumer only after its producer's result gives success and the platform makes the written tensor visible. A prepared descriptor is not an authorization to submit it early. For status-class producers in this schedule use `rd!=x0` and associate their status with the correct buffer. If Q, K or V fails, do not submit attention using that projection. Preserve the prior committed KV view until all required updates are valid. Hardware sticky-error clear permits younger independent work to resume and does not validate the failed tensor.

A model trained for the OP-009 feature map uses a different sequence. Submit RESET for the first prompt chunk and CONTINUE with the published TLAS checkpoint for subsequent chunks or decode tokens. Advance the software checkpoint handle only after full command success and write visibility. Keep the previous checkpoint on failure. Exact attention and this linear recurrence must match the model's chosen semantics throughout the request.

#### Exact-attention K/V append

For the fixed-capacity cache candidate, allocate K and V separately, with head-major token rows matching the OP-005 TREF64 layout. Keep the head pitch based on allocated capacity and change only the logical K/V length in each issued descriptor. For a token at index t, the row for head h starts at base+h*head_pitch+t*token_pitch. The driver checks this calculation for both tensors, DMA alignment, capacity and the applicable reference span. An OP-001 output packed across all heads is not physically the same layout as those rows; use a qualified copy into the per-head rows or project into aligned per-head destinations. A two-span wrapped cache cannot be described as a single contiguous OP-005 view under this ABI.

Example for one sample with 32 heads, 128 BF16 features per head and capacity 2,048 tokens. If the build alignment allows a 256-byte token pitch, the head pitch is 524,288 bytes. Each K and V allocation consumes 16 MiB. After 128 committed tokens, append at row index 128 for every head. When both new sets of rows are visible to IF-003, prepare the private attention descriptor with Lq=1, Lkv=129, CAUSAL, and query_position_start=128. The byte offsets of the head starts do not change as Lkv grows. Use a full validated allocation span or an aligned span sufficient for the last head and logical row.

Keep a driver-owned committed length and a pending length under an exclusive append lease. Drain earlier readers of a conflicting allocation range before acquiring the write lease. Submit attention with the pending length only after Q is ready and both K and V append producers report success and reach the DMA visibility point. Publish the committed length for the next token after the consuming step succeeds, using the model runtime's retry boundary. If either producer or the consuming step fails, keep the old length. Never publish a partly written tail or use it on retry unless the driver reconstructs and validates the complete pending append. This relies on the old prefix being outside producer writes and remains subject to the cache-line/alias contract in HDS §11.2.

### 7.2 Grouped-query attention using the existing OP-005 ABI

OP-005 uses one `head_count` for Q, K, V and output. A model with more Q heads than K/V heads cannot express the sharing by setting a zero head stride. A legal mapping is to issue one `H=1` command per Q head, each referencing its group's immutable K/V head buffer. This avoids copying K/V in memory but can reread the same K/V once per Q head. An alternative is to expand K/V into a separate physical copy per Q head and submit a uniform-head descriptor. That uses more storage and DMA traffic.

For single-token decode, prefer to test folding the Q heads of each group into the query-row axis. If four Q heads use one K/V head, submit `H=1`, `Lq=4`, with each logical query row holding one Q head's vector for that token. Use `NONE` only when the supplied K/V interval contains exactly the keys visible to that token and no future, invalid or otherwise masked keys. All four queries then see the same K/V set. Keep the Q rows and output rows in group order so software can restore the head layout. With an active query tile of at least four rows and a schedule holding a shared K/V tile across those rows, this permits one K/V pass per group under the existing ABI. It does not require changing the hardware head-count fields or introducing implicit buffer aliasing.

For 32 Q heads, eight K/V heads, BF16 widths `Dqk=Dv=128`, and a visible context of 2,048 tokens, each K/V group contains 1 MiB of useful K+V data. Issuing one command per Q head can read 32 MiB over 32 commands. The four-row mapping can read 8 MiB over eight commands when each group makes one K/V pass. Count any Q/output repacking and the link's physical DMA beats separately. This is a logical-payload comparison for the stated schedule.

When all groups have the same number of query heads, common visible key length and regular checked input/output pitches, put the distinct K/V groups in the descriptor's head axis. The single-token example can then use one descriptor with B=1, H=8 and Lq=4. Q and output use [1,8,4,128]; K and V use [1,8,2048,128]. Hardware head g owns K/V head g. Row r in that head contains original query head 4*g+r for the same token. With compact BF16 Q/output, one row has a 256-byte payload and a group has 1,024 bytes. The two outer axes still use legal descriptor pitches. Each distinct K/V head has a 1-MiB combined K+V payload. Under the same one-pass schedule this command reads 8 MiB of K/V over one issue/result sequence. It can save seven command boundaries versus issuing a four-row descriptor for each of eight groups. This mapping leaves the sample axis available for actual independent requests and does not assume that all head contexts run simultaneously. If the grouping or the physical views are irregular, split into compatible groups/descriptors or repack and include this cost in the benchmark.

For multiple query tokens, folding the query-head axis into rows changes the relationship between row index and causal position. Use a `BOOL` mask indexed by each folded row's original token position, or use the one-command-per-Q-head causal mapping. For a folded row originating at token index t, an ordinary causal mask marks key k valid when `k <= query_position_start + t`, even if other folded rows have the same t. Keep each folded `Lq<=PARA_MAX_ATTN_Q`, account for the physical BOOL mask and possible loss of whole-tile causal skipping, and split query rows when needed. Honor the same query scale, increasing K/V tile sequence, FP32 reduction order and output format per original Q head. Verify folded and per-head results on the same build before model use. Publish the model's assembled output only after all group commands succeed.

For multi-token GQA, a software layout candidate uses token-major query rows: original token t contributes G consecutive rows, one per query head sharing that K/V group. Split at original-token boundaries so G times the chunk token count fits the Lq cap. Set `mask_mode=BOOL`, keep all descriptor `query_position_start[]` fields zero as required for BOOL, and put the global original-token positions into the software-generated mask. The key span for a chunk may end at its last visible key. Under byte-mask sharing across hardware heads, one sample mask suffices for all groups that use the same token/key positions and visibility policy.

Use per-query-head CAUSAL as the baseline for long prefill. With a fixed number of physical query rows per tile, folding G query heads into those rows reduces the number of original tokens per tile. A K/V traffic reduction therefore requires a measured scheduling advantage; fewer commands alone does not prove it. See the HDS §13 prefill comparison for a concrete count.

## 8. Shared datapath and pipeline-boundary behavior

Bring-up defaults bypass all five optional cuts. Release build records supply each selected cut explicitly. Five approved optional register cuts are individually elaboration-selectable: operand input, multiplier result, epilogue, output path, and memory response. PE forwarding and accumulator feedback remain fixed. A selected cut inserts a register; bypass is a static generate-time connection, not a runtime mux. Every cut carries payload, valid/ready or equivalent stall state, command ID, precision, tile coordinates, lane mask, destination, and error flags together. A stall may not drop or duplicate a tile. The multiplier cut preserves exact FP FMA input semantics on OP-001 and fused OP-004. It can retain an unrounded product or fused-path state. OP-005 P×V has its own separate product rounding rule. Each pipeline combination needs its own functional and timing qualification; deeper pipelining can improve Fmax while increasing first-result latency and buffering. Tile reads may overlap compute through ping-pong SRAM. Each SRAM read whose return cannot be stalled must reserve response storage before launch. Reuse a bank only after all fills and dependent reads or output drains for its previous owner are accounted for, as specified in HDS §10.5. Illustrative waveforms show operation order.

## 9. Remaining release gates

| Open item | Current contract / required evidence |
|---|---|
| OP-002 vector service | DEC-067 uses a per-mode element cap and separate logical allocation limits for reads and writes. Vector width, nonlinear throughput, physical DMA latency and model accuracy require qualification. |
| OP-005 SRAM/tile configuration | DMA-managed SRAM keeps m/l/o resident. Bring-up uses 16 query rows, 64 K/V tokens, one active context and one active sample. Release builds explicitly select tile and concurrency values and verify SRAM fit and timing. |
| Precision/model qualification | Each operation/precision pair must be explicitly qualified; LUTs, quantization, and OP-009 need model acceptance evidence |
| SoC memory/security/reset contract | Bind AXI widths/IDs, arbitration/service assumptions, firewall aperture, cache maintenance, watchdog, and full-SoC reset to an actual integration |
| Performance/PPA | Report workload percentiles and conditional hard bounds, measured throughput/utilization, area/power/STA per build; 64 TOPS is a target until physically measured |

Instruction and descriptor encoding are fixed in §§2 and 10. Remaining gates require model data and SoC/physical evidence; they do not leave operation IDs or offsets unspecified.
## 10. Normative descriptor body ABI (DEC-065)

This section freezes the release-1 descriptor body layouts. The common 64-byte header is defined by HDS DEC-040. These maps replace earlier statements that per-operation body offsets were open. Use the companion [descriptor layout map](descriptor_layout.json) and the generator linked in the README for C and SystemVerilog field constants. Keep the map and the byte tables synchronized. The tables and HDS still specify field meaning, operation-dependent validation, and numeric behavior.

### 10.1 Shared descriptor and reference rules

- Header `schema_bytes` is the exact total descriptor size including the 64-byte header. Each operation/build has one fixed positive multiple-of-64 size; no TLV, variable tail, or descriptor-controlled fetch length is supported. `PARA_MAX_DESCRIPTOR_BYTES=896` is the release-1 maximum. OP-004 size is selected by `PARA_ARGMAX_IMPL`.
- The trusted S-mode driver places a descriptor in one physically contiguous 64-byte-aligned span, keeps it immutable through completion, cleans non-coherent cache lines, and fences before issue. After safe commit, the IP reads/validates the header, then fetches exactly the build-known remainder. The full body is validated before numeric tensor reads or output writes. No field can enlarge the fetch.
- All multibyte fields are little-endian. Reserved bytes and unused array entries are zero. Malformed magic/version/schema/reserved bytes return `TC_ERR_DESCRIPTOR_FORMAT`; unsupported enum/flag/variant combinations return `TC_ERR_DESCRIPTOR_MODE`; invalid dimensions/extents/strides/caps return `TC_ERR_SHAPE`. Address wrap, insufficient span, unrepresentable AXI addresses or payload misalignment return `TC_ERR_ADDRESS`. The driver rejects allocations outside the configured aperture before issue. If the firewall denies an issued burst, the IP observes the read or write response and reports the corresponding AXI status in HDS §12. Apply the selected DEC-066 build alignment as specified below.
- A 64-byte tensor reference (`TREF64`) is: bytes 0–7 `base_addr` u64; 8–15 `span_bytes` u64; 16–31 `extent[4]` (four u32 logical element counts); 32–63 `stride_bytes[4]` (four u64 byte strides). Rank, element format and axis meaning are fixed by that reference slot. Unused dimensions have zero extent and stride. Present references have nonzero defined extents and identify the entire contiguous physical allocation, including padding. Before numeric DMA, check `element_bytes + sum((extent[d]-1)*stride_bytes[d]) <= span_bytes` with checked multiply/add over only the operation-defined active rank dimensions; unused zero-extent dimensions are excluded. Both the driver and IP require checked u64 `end=base_addr+span_bytes` and require the last addressed byte `end-1` to fit the AXI address width. The trusted driver also requires `base_addr>=TCOP_DMA_BASE` and `end<=TCOP_DMA_LIMIT`. The SoC firewall enforces the aperture on each issued burst. The exclusive end can equal the limit. A larger span may include declared padding; all declared bytes count toward logical-span limits and firewall checks.
- An absent optional reference is all 64 bytes zero. Required or enabled references undergo normal checks. Descriptor span shall not overlap tensor-reference spans. Output/state-output spans shall not overlap other references; release 1 defines no in-place alias exception. Read-only inputs may alias each other except for OP-006 and OP-007, whose present references must be pairwise disjoint. Ordinary elements use command precision (INT8=1 byte; BF16/FP16=2 bytes). Slot-defined auxiliary formats include `REQUANT8`, 2:4 metadata, BOOL masks, inline LUTs and OP-009 FP32 state. Strides are bytes in logical-axis order; only operation-defined contiguous axes and padded outer pitches are legal. For each present TREF64, `base_addr` and `span_bytes` are multiples of HDS `PARA_DMA_ALIGN_BYTES`, and independent row/batch pitches are multiples of it, except compact OP-008 packed lane/group strides fixed by DEC-062. The parameter is a positive power of two >= max(64 bytes, AXI data-beat bytes, CPU cache-line bytes), static per build, and identical in RTL and driver. OP-009 state bases/record strides align to max(64, parameter); descriptor bases remain 64-byte aligned. Misalignment returns `TC_ERR_ADDRESS` before numeric access.

For the alias check, use each entire validated half-open allocation [base,end), including its declared padding. Two allocations overlap exactly when each start is below the other's end. Equal adjacent endpoints do not overlap. Compare the descriptor range with every present reference. Compare every writable reference with all other present references, including another output. For OP-006 with BOOL and OP-007 with affine enabled, compare the read-only input pairs as well. An absent optional slot has no range to compare. A prohibited overlap returns `TC_ERR_ADDRESS` during the individual-reference checks of §10.4, before aggregate byte caps or numeric DMA.

For example, OP-002 ADD can use the same read-only range [0x2000,0x2080) for X and RHS. An output starting at 0x2080 is disjoint. An output starting at 0x2040 overlaps the inputs even when those bytes are allocation padding. Each input reference still contributes its declared span to the read budget. OP-001 initial C and the output C always use separate ranges despite the mathematical notation. OP-009 state output is disjoint from old state, every other input and the context output, so a failed continuation can keep the old state.

### 10.2 Fixed schema-size map

| Operation / build | Exact `schema_bytes` | Body after common header |
|---|---:|---|
| OP-001 dense GEMM | 832 | config 64B + seven TREF64 + inline LUT 256B |
| OP-002 elementwise/epilogue | 640 | config 64B + four TREF64 + inline LUT 256B |
| OP-003 REDUCE | 192 | config 64B + one TREF64 |
| OP-004 ARGMAX, `PARA_ARGMAX_IMPL=0` | 192 | config 64B + one TREF64 |
| OP-004 ARGMAX, `PARA_ARGMAX_IMPL=1` | 384 | config 64B + four TREF64 |
| OP-005 exact attention | 448 | config 64B + five TREF64 |
| OP-006 softmax | 320 | config 64B + three TREF64 |
| OP-007 LayerNorm | 384 | config 64B + four TREF64 |
| OP-008 sparse GEMM | 896 | config 64B + eight TREF64 + inline LUT 256B |
| OP-009 linear attention | 512 | config 64B + six TREF64 |

Each config occupies bytes 64–127. References and inline data start at byte 128 in §10.3 order. Header byte 16 is zero except OP-004, where it echoes `PARA_ARGMAX_IMPL`. Header `schema_bytes` must equal this table. No body-version substitution exists in release 1.

### 10.3 Operation layouts

#### OP-001 (`funct7=0x01`), size 832

Config: bytes 64–67 M u32; 68–71 N u32; 72–75 K u32; 76–79 flags (`bit0=transpose_A`, `bit1=transpose_B`, `bit2=initial_C_enable`, `bit3=bias_enable`, `bit4=residual_enable`; bits 5–31 zero); byte 80 activation (`0=NONE`, `1=RELU`, `2=LUT8`); bytes 81–127 zero. Fused activation 1/2 is INT8-only; BF16/FP16 require NONE. Disabled addends have zero references. LUT area bytes 576–831 is nonzero only for INT8 LUT8.

| Offset | Reference | Shape/layout |
|---:|---|---|
| 128 | A | rank 2 `[M,K]`; logical strides `S_A_M,S_A_K`; transpose rules per REQ-FUNC-015 |
| 192 | B | rank 2 `[K,N]`; logical strides `S_B_K,S_B_N`; transpose rules per REQ-FUNC-015 |
| 256 | C output | rank 2 `[M,N]`, logical row-major, N contiguous |
| 320 | initial C | optional rank 2 `[M,N]`; command precision; accumulator addend semantics per HDS §9.1/REQ-ERR-005 |
| 384 | bias | optional rank 1 `[N]`; command precision and declared accumulator scaling |
| 448 | residual | optional rank 2 `[M,N]`; command precision and declared accumulator scaling |
| 512 | INT8 requant vector | required for INT8; rank 1 `[N]`, record stride 8, `REQUANT8`; all zero for BF16/FP16 |
| 576 | activation LUT | 256 signed-INT8 bytes; REQ-FUNC-017; zero unless INT8 LUT8 |

A/B extents are logical even when physically transposed. No output transpose or gather stride is encoded. `PARA_MAX_GEMM_READ_SPAN_BYTES` sums each enabled input/addend/metadata/coefficient reference `span_bytes` once; write-span cap sums output spans.

#### OP-002 (`funct7=0x02`), size 640

Config: byte 64 rank u8 (1–4); 65 mode (`0 ADD`, `1 BIAS_ADD`, `2 RESIDUAL_ADD`, `3 SCALE`, `4 ACT_ONLY`, `5 SWIGLU`); 66 activation (`0 NONE`, `1 RELU`, `2 GELU_TANH`, `3 SILU`, `4 LUT8`); 67 zero; 68–71 `scale_q16_16` s32; 72–75 `scale_fp32_bits` u32; 76–79 `swiglu_multiplier_q31` u32; byte 80 `swiglu_exponent` s8; bytes 81–127 zero. Shape is in X extents; Y matches. SCALE uses Q16.16 for INT8 or finite FP32 for BF16/FP16; irrelevant scalar field is zero. INT8 SWIGLU uses its Q31/exponent and SiLU table; otherwise those coefficient fields are zero. LUT bytes 384–639 are zero unless the selected INT8 mode uses them. To implement GELU or SiLU with INT8, encode LUT8 (4) and supply the table. The FP nonlinear selector codes (2 and 3) are invalid for INT8. SwiGLU uses its own LUT with activation=NONE (0).

| Offset | Reference | Shape/layout |
|---:|---|---|
| 128 | X | configured rank, up to four dimensions; inner dimension contiguous |
| 192 | RHS | required for ADD/RESIDUAL_ADD/SWIGLU, same extents as X; otherwise absent |
| 256 | Y output | same rank/extents as X; disjoint from inputs |
| 320 | bias | required for BIAS_ADD; rank 1 equal to X's final extent; otherwise absent |
| 384 | inline LUT | 256 signed-INT8 bytes |

Mode/activation legality, arithmetic order, final-axis bias broadcast and LUT rules follow REQ-FUNC-018. The descriptor cannot encode a general operation list or arbitrary broadcast. After validating op2_mode, select the build-time entry PARA_MAX_ELEMWISE_ELEMENTS[op2_mode]. For valid active X extents E, start count at 1 and reject before multiplication if count > floor(cap/E). Unused dimensions, padding and broadcast bias do not contribute to the element count. Independently, after validating present references, checked-sum their declared span_bytes by direction: X plus enabled RHS or bias for reads, and Y for writes. Count each enabled reference once, including its allocation padding, even when read-only references alias. Compare the sums against PARA_MAX_ELEMWISE_READ_SPAN_BYTES and PARA_MAX_ELEMWISE_WRITE_SPAN_BYTES. An element/span cap violation or cumulative sum overflow returns TC_ERR_SHAPE before numeric operand DMA, compute or output writes. REQ-IF-009 still governs malformed individual references. The first-build candidate table assigns 33,554,432 elements to modes 0..4 and 16,777,216 to SWIGLU. The independent directional limits are 128 MiB read and 64 MiB write. For compact BF16/FP16 ADD on a [4, 2048, 4096] tensor, two 64 MiB inputs and one 64 MiB output meet the caps exactly. For SwiGLU at the same shape, two [2, 2048, 4096] commands each read two 32 MiB inputs and write one 32 MiB output. Split workloads that exceed any of these limits along outer axes into disjoint output chunks and retain the full feature axis and shared bias where applicable. Publish the aggregate result only after all chunks succeed.

#### OP-003 (`funct7=0x03`), size 192

Config byte 64 is `reduce_mode` (`0=SUM`, `1=MAX`); bytes 65–127 zero. Offset 128 is required rank-1 input: extent[0]=length, stride[0]=element_bytes; other extents/strides zero. Length is 1..`PARA_MAX_REDUCE_ELEMENTS`. No tensor output reference exists; scalar/fence behavior is in §5 and REQ-FUNC-019.

#### OP-004 (`funct7=0x04`), standalone size 192 / fused size 384

Both variants have `vocab_length` u32 at 64–67. Standalone variant 0 requires bytes 68–127 zero; offset 128 is rank-1 logits `[vocab_length]`, contiguous in command precision. INT8 standalone logits must share one positive scale over vocabulary; per-index scales are unsupported.

Fused variant 1 has `input_width` u32 at 68–71, `bias_enable` byte 72 (0/1), and zero bytes 73–127. References: 128 activation `[input_width]`; 192 vocabulary weights rank 2 `[input_width,vocab_length]`, vocabulary channel contiguous; 256 optional bias `[vocab_length]`; 320 INT8 coefficient vector `[vocab_length]`, record stride 8, `REQUANT8`. INT8 requires coefficients and `bias_enable=0`; release 1 does not define INT8 fused bias scaling. BF16/FP16 require an all-zero coefficient reference and may supply same-precision bias.

For INT8 fused comparison, raw accumulators cannot be compared when channel weight scales differ. Let `a_j` be signed dot-product accumulator and `(M_j,e_j)` its validated REQUANT8 record as in REQ-FUNC-016. The common positive activation scale cancels; compare represented values `a_j*M_j*2^(e_j-31)` without INT8 rounding. First handle zero: if both accumulators are zero, scores tie and the lower vocabulary index wins; if exactly one is zero, zero is greater than a negative score and less than a positive score. For nonzero accumulators, a positive score beats a negative score. For equal signs, calculate `p_j=abs(a_j)*M_j` in `PARA_ACCUM_W+32` unsigned bits, `q_j=e_j-31`, and `E_j=msb_index(p_j)+q_j`; `p_j` is nonzero here. Unequal E orders magnitude, with the order reversed when both scores are negative. Form abs(a) as an unsigned magnitude so the most-negative signed accumulator is representable. For the supported widths W<=64 and valid coefficients, E fits a signed 8-bit field: a conservative range is -62 through W+29. For equal E, left-normalize each full product so its MSB reaches bit `PARA_ACCUM_W+31`, then compare normalized products, again reversing magnitude order for negative values. Exact equality uses the common lower-index rule. Validate the full coefficient vector before activation/weight numeric reads; malformed records return `TC_ERR_REQUANT_COEFF`. BF16/FP16 fused mode widens activation and weight values exactly. Start each token score at FP32 +0, then apply one FP32 RNE FMA per logical input feature in increasing index order. Retain this accumulator across feature tiles. Add the optional model bias once in FP32 RNE after the dot, then compare directly in FP32 with no output conversion. Preserve IEEE signed zero and gradual underflow. +0 and -0 tie. In valid lanes, NaN from invalid FP arithmetic follows the OP-004 NaN error path. A +Inf score is eligible and a -Inf score is excluded, including scores generated by the projection. These rules are specific to OP-004 (DEC-069). Both variants require mode 2 and `rd!=x0`, use the 65,536 vocabulary cap, and return the all-ones XLEN sentinel on accepted failure. The fused scheduler can partition vocabulary channels into disjoint stripes. FP feature order is fixed within each stripe. The merge consumes only complete scaled or bias-adjusted scores. For example, let F be the largest finite BF16 number. With activation [1,2], weights [-F,F] for token 0 and [+Inf,1] for token 1, the ordered FP32 FMA produces scores F and +Inf. Token 1 wins. Separately rounding the product 2F would produce +Inf for token 0 and incorrectly make it win the tie.
#### OP-005 (`funct7=0x05`), size 448

Config: bytes 64–67 `batch_count` u32; 68–71 `head_count` u32; 72–75 Lq u32; 76–79 Lkv u32; 80–83 Dqk/head u32; 84–87 Dv/head u32; byte 88 mask (`0 NONE`, `1 CAUSAL`, `2 BOOL`); 89–91 zero; 92–95 finite `attention_scale_fp32_bits`; 96–111 `query_position_start[4]` u32; 112–127 zero. Position entries for samples >=batch_count are zero; NONE/BOOL require every position zero. In CAUSAL mode, compare each zero-based key index against the corresponding sample's query start plus the logical query index. Check unsigned 32-bit overflow against the last live query before reading operands. The controller can skip a K/V tile if all its logical keys are beyond all queries in the context's clipped query tile. Masked and padded pairs bypass operand classification and feed +0 into the reduction leaves. A valid V is still classified when its probability rounds to zero. AXI faults on already-issued reads remain visible. Caps and masking follow REQ-FUNC-020.

| Offset | Reference | Shape |
|---:|---|---|
| 128 | Q | rank 4 `[B,H,Lq,Dqk_head]` |
| 192 | K | rank 4 `[B,H,Lkv,Dqk_head]` |
| 256 | V | rank 4 `[B,H,Lkv,Dv_head]` |
| 320 | output | rank 4 `[B,H,Lq,Dv_head]` |
| 384 | BOOL mask | only for BOOL; rank 3 `[B,Lq,Lkv]`, byte elements, shared across heads |

Feature axis is contiguous; other axes use checked padded pitches. Query/KV tile and active-wave settings are static build parameters, not descriptor controls.

#### OP-006 (`funct7=0x06`), size 320

Config: bytes 64–67 `row_count` u32; 68–71 `row_length` u32; byte 72 mask (`0 NONE`, `1 BOOL`); bytes 73–127 zero. Offsets 128/192/256 are input/output/optional BOOL mask. All are rank 2 `[row_count,row_length]`, inner axis contiguous; mask is one byte per element and absent for NONE. Caps and arithmetic follow REQ-FUNC-021. HDS §10.2.2 describes row buffering and DMA replay schedules. All schedules preserve the logical-index max and sum trees and store masked probabilities as exact +0.

#### OP-007 (`funct7=0x07`), size 384

Config: bytes 64–67 `row_count` u32; 68–71 `row_width` u32; byte 72 `affine_enable` (0/1); 73–75 zero; 76–79 epsilon FP32 bits; 80–127 zero. References: 128 input rank 2 `[row_count,row_width]`; 192 output same shape; 256 gamma rank 1 `[row_width]`; 320 beta rank 1 `[row_width]`. When affine is disabled gamma/beta refs are zero; when enabled both are required, command precision. Feature axis is contiguous. Input, enabled gamma/beta, and output spans are pairwise disjoint under REQ-FUNC-022. The Welford tree may reuse count-derived coefficients across rows. The coefficient ratios and final variance division use one FP32 nearest-even rounding of the exact ratio. For row [-8,-8,-7], the internal variance encoding is 0x3E638E39. Multiplying by a rounded reciprocal of the width gives a different FP32 value for this row.

#### OP-008 (`funct7=0x08`), size 896

Config: 64–67 M u32; 68–71 N u32; 72–75 K u32; 76–79 flags (`bit0=transpose_A`, `bit1=initial_C_enable`, `bit2=bias_enable`, `bit3=residual_enable`; all other bits zero); byte 80 activation (`0 NONE`, `1 RELU`, `2 LUT8`); 81–127 zero. Precision is INT8 only; K divisible by four; G=K/4.

| Offset | Reference | Shape/layout |
|---:|---|---|
| 128 | A activation | rank 2 logical `[M,K]`; transpose/padding follows OP-001 A rules |
| 192 | packed weight values | rank 3 `[G,N,2]`, group-major `[g][n][slot]`; byte strides slot=1, N=2, group=2N |
| 256 | selector metadata | rank 1 byte array `ceil(G*N/2)`; flattened nibble q=`g*N+n`, even q in low nibble |
| 320 | C output | rank 2 `[M,N]`, logical row-major |
| 384 | initial C | optional rank 2 `[M,N]` |
| 448 | bias | optional rank 1 `[N]` |
| 512 | residual | optional rank 2 `[M,N]` |
| 576 | requant vector | required rank 1 `[N]`, record stride 8 |
| 640 | activation LUT | 256 signed-INT8 bytes; nonzero only for LUT8 |

Selector/payload validity, tail nibble, per-tile validate-before-use, and addend rules follow REQ-FUNC-009/016 and DEC-063. A tile validates only its owned nibbles plus the global unused high nibble when it owns the final low nibble. Shared-byte coverage does not authorize an adjacent tile. Keep a validated slot tied to its K-group/channel interval until consumption as described in HDS §10.2.2. Enable flags must match optional-reference presence. OP-001/008 work/tile/span caps in DEC-064 apply. Sign-extend each paired product and use at least 17 signed bits for their sum, including at the enabled multiplier cut.

#### OP-009 (`funct7=0x09`), size 512

Config: 64–67 `batch_count` u32; 68–71 `sequence_length` u32; 72–75 `head_count` u32; 76–79 R u32; 80–83 Dv u32; byte 84 state mode (`0 RESET`, `1 CONTINUE`); byte 85 feature map (`0 ELU_PLUS_ONE`); 86–127 zero.

| Offset | Reference | Shape/layout |
|---:|---|---|
| 128 | Q | rank 4 `[B,H,T,R]`, command precision |
| 192 | K | rank 4 `[B,H,T,R]`, command precision |
| 256 | V | rank 4 `[B,H,T,Dv]`, command precision |
| 320 | context output | rank 4 `[B,H,T,Dv]`, command precision |
| 384 | TLAS state input | rank 1; extent[0]=B; stride[0]=record_stride; absent only for RESET |
| 448 | TLAS state output | rank 1; extent[0]=B; same record stride; required |

Each sample record begins at `base+b*record_stride`, with a 64-byte TLAS header, then `payload_bytes=4*H*R*(Dv+1)` FP32 payload bytes, then unused alignment padding. The engine ignores its value and does not write it. TLAS reserved header bytes still require zero. `record_stride=align_up(64+payload_bytes,max(64,PARA_DMA_ALIGN_BYTES))`. For each state TREF64, `extent[0]=B`, `stride_bytes[0]=record_stride`, and the checked required span is `(B-1)*record_stride + 64 + payload_bytes`; this full-record rule replaces the generic 4-byte final-element span for this slot. Base and record stride are aligned to max(64, PARA_DMA_ALIGN_BYTES). Input and output state spans are disjoint. Payload is `[head][r][S[r,0..Dv-1],z[r]]` FP32 little-endian. RESET requires absent state input; CONTINUE requires it. Header/count/state checks follow REQ-FUNC-023. For CONTINUE, validate sample headers/counts before recurrence and validate each active head payload before its dependent Q/K/V. On success every sample contributes exactly T new tokens. The output count is T for RESET and old_count[b]+T for CONTINUE. In a batch with old counts [7, 100] and T=2, the new counts are [9, 102]. Check the sums before the recurrence, including overflow in any sample. Header bytes alone do not indicate completion. Keep the prior state handle until the command succeeds and writes drain. The S-mode driver associates each checkpoint with its owning model/layer and sequence since the TLAS header identifies layout and precision only.

#### Descriptor field offset summary

Each row identifies OP and build variant. Config entries are name:offset:width in bytes. Each named reference is 64 bytes, starting at its given byte offset. The inline LUT is listed separately from tensor references. The machine-readable layout in [descriptor_layout.json](descriptor_layout.json) shall match this table. Use the operation descriptions above for meanings, required versus optional references, and reserved-zero rules.

| OP/variant | Config fields | TREF64 offsets | Inline LUT |
|---|---|---|---|
| OP-001/0 | m:64:4, n:68:4, k:72:4, flags:76:4, activation:80:1 | a:128, b:192, output:256, initial_c:320, bias:384, residual:448, requant:512 | 576:256 |
| OP-002/0 | rank:64:1, mode:65:1, activation:66:1, scale_q16_16:68:4, scale_fp32_bits:72:4, swiglu_multiplier_q31:76:4, swiglu_exponent:80:1 | x:128, rhs:192, output:256, bias:320 | 384:256 |
| OP-003/0 | mode:64:1 | input:128 | - |
| OP-004/0 | vocab_length:64:4 | logits:128 | - |
| OP-004/1 | vocab_length:64:4, input_width:68:4, bias_enable:72:1 | input:128, weights:192, bias:256, requant:320 | - |
| OP-005/0 | batch_count:64:4, head_count:68:4, lq:72:4, lkv:76:4, dqk:80:4, dv:84:4, mask_mode:88:1, attention_scale_fp32_bits:92:4, query_position_start:96:16 | q:128, k:192, v:256, output:320, mask:384 | - |
| OP-006/0 | row_count:64:4, row_length:68:4, mask_mode:72:1 | input:128, output:192, mask:256 | - |
| OP-007/0 | row_count:64:4, row_width:68:4, affine_enable:72:1, epsilon_fp32_bits:76:4 | input:128, output:192, gamma:256, beta:320 | - |
| OP-008/0 | m:64:4, n:68:4, k:72:4, flags:76:4, activation:80:1 | a:128, packed_weights:192, metadata:256, output:320, initial_c:384, bias:448, residual:512, requant:576 | 640:256 |
| OP-009/0 | batch_count:64:4, sequence_length:68:4, head_count:72:4, r:76:4, dv:80:4, state_mode:84:1, feature_map_id:85:1 | q:128, k:192, v:256, output:320, state_input:384, state_output:448 | - |

### 10.4 Validation sequence and error boundaries

After issue-time operation/precision/build-mask/result-class checks and matching safe commit:

1. Check descriptor pointer alignment and addressability for the complete 64-byte header before issuing its DMA. After the header is fully received with no AXI fault, check its format fields and reserved bytes first, then the build variant. Validate `schema_bytes` against the size selected by the accepted instruction and the elaborated build. Format failures return `TC_ERR_DESCRIPTOR_FORMAT`. A variant-byte mismatch with all format fields valid returns `TC_ERR_DESCRIPTOR_MODE`. For example, the 192-byte standalone OP-004 header presented to the 384-byte fused build fails the size check and returns `TC_ERR_DESCRIPTOR_FORMAT`. If the header declares 384 bytes and only its variant byte incorrectly names standalone, it returns `TC_ERR_DESCRIPTOR_MODE`. Both failures stop before body DMA.
2. Check addressability of the exact complete schema range before fetching its body. The validated header size must match the build-known size, and cannot select the length. If an issued header or body read faults, drain that phase and select AXI status using DEC-012. Discard invalid beats. Do not interpret a partially faulted stage or allow its data to contribute a descriptor error.
3. After a successful body fetch, select the first failing check group in the order below. RTL may evaluate checks in parallel if it returns the same result. No numeric tensor reads, array launch or output writes can occur until every group passes.
4. Run algorithm-specific prevalidation before protected numeric reads: INT8 GEMM accumulator bound and coefficient vector; fused INT8 OP-004 coefficient vector; OP-008 current selector tile; OP-009 TLAS sample headers/counts followed by each head state before that head consumes dependent operands. Then read the allowed numeric operands and compute.
5. Completion uses the result class captured from the instruction. Accepted errors follow HDS DEC-012. If a late error follows partial output writes, the entire destination is invalid under REQ-ERR-003.

| Check group in priority order | Examples | Status |
|---|---|---|
| Unconditional body format | Reserved-zero bits/bytes, including unused fields with unconditional definitions | `TC_ERR_DESCRIPTOR_FORMAT` |
| Mode and precision dependency | Unsupported enum or illegal selected mode/activation combination | `TC_ERR_DESCRIPTOR_MODE` |
| Dependent body format | Invalid scalar format/range or nonzero fields that the now-valid mode requires to be zero | `TC_ERR_DESCRIPTOR_FORMAT` |
| Shape and pitch layout | Extent/rank, operation-specific pitch layout, checked dimension products and work caps | `TC_ERR_SHAPE` |
| Individual address/reference | Misaligned base/span/otherwise legal pitch, too-short allocation, address unrepresentability or prohibited overlap | `TC_ERR_ADDRESS` |
| Aggregate allocation cap | Checked sum of declared spans exceeds the operation limit or overflows | `TC_ERR_SHAPE` |

A group only checks fields whose applicability and prerequisites are established. In particular, an invalid mode has no implied mode-dependent field layout, and a failed shape cannot provide an address footprint. Aggregate byte caps sum valid present references as specified by the operation. An invalid individual reference is reported by its individual format/layout/address rule before it can contribute to aggregate span-cap validation. Keep transfers within validated allocations as in HDS §6.3. Driver aperture prechecks use the platform map. A denial observed on an attempted DMA transfer returns an AXI error, not a locally synthesized address status. For example, a 64-byte aligned span at 0xFFFF_FFC0 ends at 0x1_0000_0000 and is addressable on a 32-bit AXI port. A 128-byte span at the same base fails addressability before numeric DMA. A 64-byte span just outside the aperture but within the AXI address range passes the IP address-width check. The driver rejects it in preflight. If a request still reaches the firewall, its denial uses the AXI response path.

Descriptor fields never change operation ID, result class, precision, or build variant. A later queued command can select a different operation/mode because selectors are latched per command.

### 10.5 Worked descriptor encodings

The addresses below are illustrative. The platform must supply valid allocations inside its actual DMA aperture. Examples use a 64-byte DMA alignment build and the release-1 default schema version. Every descriptor byte omitted from the encoding tables is zero.

#### OP-003 INT8 SUM, RV32 and RV64

Use a 192-byte descriptor at DMA address 0x0000000100000000 and a 64-byte input allocation at 0x0000000100001000. The vector has three signed INT8 elements [4,-3,5], stored as `04 FD 05`. Set a nonzero destination x12 and use a mode-2 build.

| Descriptor byte offsets | Bytes in memory | Meaning |
|---|---|---|
| 0–16 | `54 43 4F 50 01 00 00 00 40 00 03 00 C0 00 00 00 00` | TCOP, schema 1.0, header 64 bytes, OP-003, INT8, total 192 bytes, variant zero |
| 64 | `00` | SUM |
| 128–135 | `00 10 00 00 01 00 00 00` | Input base address |
| 136–143 | `40 00 00 00 00 00 00 00` | Declared span 64 bytes |
| 144–147 | `03 00 00 00` | Active extent 3 |
| 160–167 | `01 00 00 00 00 00 00 00` | Active stride 1 byte |

On RV32, set x10=0 and x11=1. The instruction word with rs1=x10, rs2=x11 and rd=x12 is `0x06B5060B`. On RV64, set x10=0x0000000100000000, encode rs2=x0 and use `0x0605060B`. After safe commit and success x12 is 6 in both cases. With the same build, `span_bytes=0` rejects before numeric DMA with `TC_ERR_ADDRESS` after acceptance. An unsupported reduce mode rejects that body with `TC_ERR_DESCRIPTOR_MODE`.

##### Issuing the worked command from privileged CPU code

Place the instruction word in the CPU executable text. CVA6 fetches it through its instruction path. Place the descriptor and input in the DMA-visible data allocations above. The trusted driver completes descriptor/input publication and the OP-003 clean-boundary/CSR ownership sequence before reaching the instruction. The following snippets use fixed registers from the worked example, with a0=x10, a1=x11 and a2=x12.

```asm
# RV32. a0 and a1 carry the low and high halves of the physical descriptor pointer.
li a0, 0
li a1, 1
.word 0x06b5060b     # OP-003 INT8 SUM, rd=a2, rs1=a0, rs2=a1
```

```asm
# RV64. a0 carries the physical descriptor pointer; rs2 is encoded with x0.
li a0, 0x0000000100000000
.word 0x0605060b     # OP-003 INT8 SUM, rd=a2, rs1=a0, rs2=x0
```

For GNU assembler, the R-type `.insn` directive accepts the register names directly. Pass precision as `funct3` and operation ID as `funct7`. Use the macro with immediates from the selected ABI table. The selected build still decides whether a valid encoding can execute. [GNU assembler RISC-V instruction formats](https://sourceware.org/binutils/docs/as/RISC_002dV_002dFormats.html)

```asm
.macro tcop_command op, precision, dest, pointer_low, pointer_high
    .insn r 0x0b, \precision, \op, \dest, \pointer_low, \pointer_high
.endm

# RV32 after loading a0/a1 as above. Encodes 0x06b5060b.
tcop_command 0x03, 0, a2, a0, a1

# RV64 after loading a0 as above. Encodes 0x0605060b.
tcop_command 0x03, 0, a2, a0, x0
```

Use only the line for the selected XLEN. For inline assembly, declare the instruction's register operands and observable memory side effects to the compiler. The platform driver still performs the CPU/DMA cache and ordering operations before publication and after completion.

The CPU forwards the decoded instruction and requested source values on the coupled CV-X-IF issue/register handshake. The tensor reads descriptor bytes via IF-003 after matching non-kill commit. Successful result retirement leaves 6 in a2 for this input. The full zero-result CSR/W1C/ack rule still applies to a zero payload on another input or an accepted error. These snippets illustrate instruction emission; the platform driver still owns privilege, physical address formation, DMA visibility and fence handling.

#### OP-009 BF16 RESET with two heads and one token

Use a 512-byte descriptor for B=1, H=2, T=1, R=1 and Dv=1. Set header operation 09, precision 01, schema size bytes `00 02 00 00` at offsets 12–15, and variant 00. Config u32 values are 1,1,2,1,1 at offsets 64,68,72,76,80. Bytes 84–85 are 00 00 for RESET and ELU_PLUS_ONE.

| Reference offsets | Extents in ABI order | Byte strides | Declared span |
|---|---|---|---:|
| 128, 192, 256, 320 (Q, K, V, context output) | [1,2,1,1] | [128,64,64,2] | 128 bytes each |
| 384 (state input) | all zero | all zero | 0, base also zero |
| 448 (state output) | [1,0,0,0] | [128,0,0,0] | 128 bytes |

Use separate aligned allocations for every present reference and for the descriptor. Head 1 of each Q/K/V/context allocation starts 64 bytes after head 0 even though the sequence length is one. Each head contributes two FP32 state words, S and z, so the TLAS payload has 16 bytes. State output has a 64-byte header followed by head 0 at byte 64 and head 1 at byte 72. The processed-token count is one. The required footprint ends at byte 80 and the declared allocation is rounded to 128 bytes. Bytes 80–127 are unused alignment padding and receive no write strobes. For Q=K=+0 and V=1 in each head, the state payload is four FP32 words equal to 1 and each context output is BF16 1. Successful retirement and drained writes make the checkpoint eligible for a later CONTINUE.

