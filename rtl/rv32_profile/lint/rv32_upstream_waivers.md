# RV32 lint waivers / Waiver lint bản RV32

Generated 2026-11-25 from `rv32_2h_p0.log` after a line-by-line review (RV32 change plan v2, item a). Each line of `rv32_upstream_waivers.vlt` waives one rule on one line. The 7 probe-engine port warnings in `hpdcache.sv` are not waived (plan v2, item b).

| # | Rule | File | Line | Reason |
|---|---|---|---|---|
| 1 | WIDTHTRUNC | modified/hpdcache_cva6_pinned/rtl/src/hpdcache_uncached.sv | 631 | 32-bit AMO and SC results are {2{word}} (prepare_amo_data_result); keeping the low 32 bits is exact. |
| 2 | WIDTHTRUNC | modified/hpdcache_cva6_pinned/rtl/src/hpdcache_uncached.sv | 824 | 32-bit AMO and SC results are {2{word}} (prepare_amo_data_result); keeping the low 32 bits is exact. |
| 3 | WIDTHEXPAND | modified/hpdcache/rtl/src/hpdcache_miss_handler.sv | 834 | Refill word index compare of a 1-bit select with a 32-bit counter; value range fits. |
| 4 | SELRANGE | third_party/cva6/core/cva6_mmu/cva6_ptw.sv | 536 | Sv39/hypervisor index slices in branches disabled for Sv32 (upstream). |
| 5 | SELRANGE | third_party/cva6/core/cva6_mmu/cva6_ptw.sv | 598 | Sv39/hypervisor index slices in branches disabled for Sv32 (upstream). |
| 6 | SELRANGE | modified/cva6/core/cva6_mmu/cva6_shared_tlb.sv | 246 | Same Sv39-only indices as cva6_tlb (upstream). |
| 7 | SELRANGE | modified/cva6/core/cva6_mmu/cva6_tlb.sv | 171 | Sv39 third-level VPN and page-size indices in loops sized for Sv32; guarded by PtLevels/IS_XLEN64 (upstream). |
| 8 | WIDTHTRUNC | modified/cva6/core/cva6_mmu/cva6_tlb.sv | 327 | Sv39 third-level VPN and page-size indices in loops sized for Sv32; guarded by PtLevels/IS_XLEN64 (upstream). |
| 9 | WIDTHTRUNC | modified/cva6/core/cache_subsystem/cva6_hpdcache_if_adapter.sv | 257 | RV32 AMO path: operand_b is carried in a 64-bit field with zero upper half; low 32 bits and 4-bit byte enable are the intended word (upstream, used by CVA6 cv32a65x). |
| 10 | WIDTHTRUNC | modified/cva6/core/cache_subsystem/cva6_hpdcache_if_adapter.sv | 263 | RV32 AMO path: operand_b is carried in a 64-bit field with zero upper half; low 32 bits and 4-bit byte enable are the intended word (upstream, used by CVA6 cv32a65x). |
| 11 | WIDTHTRUNC | modified/cva6/core/cache_subsystem/cva6_hpdcache_if_adapter.sv | 265 | RV32 AMO path: operand_b is carried in a 64-bit field with zero upper half; low 32 bits and 4-bit byte enable are the intended word (upstream, used by CVA6 cv32a65x). |
| 12 | WIDTHEXPAND | modified/cva6/core/cache_subsystem/cva6_hpdcache_if_adapter.sv | 355 | RV32 AMO path: operand_b is carried in a 64-bit field with zero upper half; low 32 bits and 4-bit byte enable are the intended word (upstream, used by CVA6 cv32a65x). |
| 13 | WIDTHEXPAND | modified/cva6/core/load_unit.sv | 686 | Assertion-side compare of the 2-bit RV32 alignment field with a 32-bit constant. |
| 14 | WIDTHEXPAND | modified/cva6/core/load_unit.sv | 691 | Assertion-side compare of the 2-bit RV32 alignment field with a 32-bit constant. |
| 15 | SELRANGE | modified/cva6/core/cva6_mmu/cva6_mmu.sv | 408 | G-stage translation term guarded by IS_XLEN64 and RVH=0 (upstream). |
| 16 | WIDTHTRUNC | third_party/cva6/core/multiplier.sv | 132 | MULW branch guarded by IS_XLEN64 (upstream). |
| 17 | WIDTHTRUNC | modified/cva6/core/alu.sv | 287 | Constant IS_XLEN32/IS_XLEN64 selection; the unselected 64-bit arm is wider than XLEN. |
| 18 | WIDTHEXPAND | modified/cva6/core/alu.sv | 401 | Constant IS_XLEN32/IS_XLEN64 selection; the unselected 64-bit arm is wider than XLEN. |
| 19 | WIDTHTRUNC | modified/cva6/core/alu.sv | 401 | Constant IS_XLEN32/IS_XLEN64 selection; the unselected 64-bit arm is wider than XLEN. |
| 20 | WIDTHEXPAND | modified/cva6/core/alu.sv | 403 | Constant IS_XLEN32/IS_XLEN64 selection; the unselected 64-bit arm is wider than XLEN. |
| 21 | WIDTHTRUNC | modified/cva6/core/alu.sv | 403 | Constant IS_XLEN32/IS_XLEN64 selection; the unselected 64-bit arm is wider than XLEN. |
| 22 | WIDTHTRUNC | modified/cva6/core/alu.sv | 410 | Constant IS_XLEN32/IS_XLEN64 selection; the unselected 64-bit arm is wider than XLEN. |
| 23 | WIDTHEXPAND | modified/cva6/core/cache_subsystem/cva6_icache.sv | 167 | Line-offset computation: 32-bit virtual address shifted in a 64-bit expression; result cast to the offset width. |
| 24 | WIDTHTRUNC | modified/cva6/core/aes.sv | 77 | Zkn: RV64-only AES64/SHA512 case arms and the shared S-box shift are elaborated but not selected when XLEN=32 (CVA6 upstream code). |
| 25 | WIDTHTRUNC | modified/cva6/core/aes.sv | 216 | Zkn: RV64-only AES64/SHA512 case arms and the shared S-box shift are elaborated but not selected when XLEN=32 (CVA6 upstream code). |
| 26 | WIDTHTRUNC | modified/cva6/core/aes.sv | 217 | Zkn: RV64-only AES64/SHA512 case arms and the shared S-box shift are elaborated but not selected when XLEN=32 (CVA6 upstream code). |
| 27 | WIDTHTRUNC | modified/cva6/core/aes.sv | 218 | Zkn: RV64-only AES64/SHA512 case arms and the shared S-box shift are elaborated but not selected when XLEN=32 (CVA6 upstream code). |
| 28 | WIDTHTRUNC | modified/cva6/core/aes.sv | 219 | Zkn: RV64-only AES64/SHA512 case arms and the shared S-box shift are elaborated but not selected when XLEN=32 (CVA6 upstream code). |
| 29 | WIDTHTRUNC | modified/cva6/core/aes.sv | 220 | Zkn: RV64-only AES64/SHA512 case arms and the shared S-box shift are elaborated but not selected when XLEN=32 (CVA6 upstream code). |
| 30 | WIDTHTRUNC | modified/cva6/core/aes.sv | 221 | Zkn: RV64-only AES64/SHA512 case arms and the shared S-box shift are elaborated but not selected when XLEN=32 (CVA6 upstream code). |
| 31 | WIDTHTRUNC | modified/cva6/core/aes.sv | 222 | Zkn: RV64-only AES64/SHA512 case arms and the shared S-box shift are elaborated but not selected when XLEN=32 (CVA6 upstream code). |
| 32 | WIDTHTRUNC | modified/cva6/core/aes.sv | 223 | Zkn: RV64-only AES64/SHA512 case arms and the shared S-box shift are elaborated but not selected when XLEN=32 (CVA6 upstream code). |
| 33 | WIDTHTRUNC | modified/cva6/core/aes.sv | 224 | Zkn: RV64-only AES64/SHA512 case arms and the shared S-box shift are elaborated but not selected when XLEN=32 (CVA6 upstream code). |
| 34 | WIDTHTRUNC | modified/cva6/core/aes.sv | 225 | Zkn: RV64-only AES64/SHA512 case arms and the shared S-box shift are elaborated but not selected when XLEN=32 (CVA6 upstream code). |
| 35 | WIDTHTRUNC | modified/cva6/core/aes.sv | 226 | Zkn: RV64-only AES64/SHA512 case arms and the shared S-box shift are elaborated but not selected when XLEN=32 (CVA6 upstream code). |
| 36 | WIDTHTRUNC | modified/cva6/core/aes.sv | 227 | Zkn: RV64-only AES64/SHA512 case arms and the shared S-box shift are elaborated but not selected when XLEN=32 (CVA6 upstream code). |
| 37 | WIDTHTRUNC | modified/cva6/core/aes.sv | 228 | Zkn: RV64-only AES64/SHA512 case arms and the shared S-box shift are elaborated but not selected when XLEN=32 (CVA6 upstream code). |
| 38 | WIDTHTRUNC | modified/cva6/core/aes.sv | 229 | Zkn: RV64-only AES64/SHA512 case arms and the shared S-box shift are elaborated but not selected when XLEN=32 (CVA6 upstream code). |
| 39 | WIDTHTRUNC | modified/cva6/core/aes.sv | 230 | Zkn: RV64-only AES64/SHA512 case arms and the shared S-box shift are elaborated but not selected when XLEN=32 (CVA6 upstream code). |
| 40 | WIDTHEXPAND | modified/cva6/core/fpu_wrap.sv | 410 | FP operand replication: constant RVD/FLEN ternary; the unselected RVD=1 arm is 64-bit (upstream pattern, lint-cleaned copy). |
| 41 | WIDTHTRUNC | modified/cva6/core/fpu_wrap.sv | 410 | FP operand replication: constant RVD/FLEN ternary; the unselected RVD=1 arm is 64-bit (upstream pattern, lint-cleaned copy). |
| 42 | WIDTHEXPAND | modified/cva6/core/fpu_wrap.sv | 412 | FP operand replication: constant RVD/FLEN ternary; the unselected RVD=1 arm is 64-bit (upstream pattern, lint-cleaned copy). |
| 43 | WIDTHTRUNC | modified/cva6/core/fpu_wrap.sv | 412 | FP operand replication: constant RVD/FLEN ternary; the unselected RVD=1 arm is 64-bit (upstream pattern, lint-cleaned copy). |
| 44 | WIDTHEXPAND | modified/cva6/core/fpu_wrap.sv | 414 | FP operand replication: constant RVD/FLEN ternary; the unselected RVD=1 arm is 64-bit (upstream pattern, lint-cleaned copy). |
| 45 | WIDTHTRUNC | modified/cva6/core/fpu_wrap.sv | 414 | FP operand replication: constant RVD/FLEN ternary; the unselected RVD=1 arm is 64-bit (upstream pattern, lint-cleaned copy). |
| 46 | WIDTHEXPAND | modified/cva6/core/fpu_wrap.sv | 419 | FP operand replication: constant RVD/FLEN ternary; the unselected RVD=1 arm is 64-bit (upstream pattern, lint-cleaned copy). |
| 47 | WIDTHTRUNC | modified/cva6/core/fpu_wrap.sv | 419 | FP operand replication: constant RVD/FLEN ternary; the unselected RVD=1 arm is 64-bit (upstream pattern, lint-cleaned copy). |
| 48 | WIDTHEXPAND | modified/cva6/core/fpu_wrap.sv | 421 | FP operand replication: constant RVD/FLEN ternary; the unselected RVD=1 arm is 64-bit (upstream pattern, lint-cleaned copy). |
| 49 | WIDTHTRUNC | modified/cva6/core/fpu_wrap.sv | 421 | FP operand replication: constant RVD/FLEN ternary; the unselected RVD=1 arm is 64-bit (upstream pattern, lint-cleaned copy). |
| 50 | WIDTHEXPAND | modified/cva6/core/fpu_wrap.sv | 423 | FP operand replication: constant RVD/FLEN ternary; the unselected RVD=1 arm is 64-bit (upstream pattern, lint-cleaned copy). |
| 51 | WIDTHTRUNC | modified/cva6/core/fpu_wrap.sv | 423 | FP operand replication: constant RVD/FLEN ternary; the unselected RVD=1 arm is 64-bit (upstream pattern, lint-cleaned copy). |
| 52 | WIDTHTRUNC | modified/cva6/core/fpu_wrap.sv | 570 | FP operand replication: constant RVD/FLEN ternary; the unselected RVD=1 arm is 64-bit (upstream pattern, lint-cleaned copy). |
| 53 | WIDTHTRUNC | modified/cva6/core/mult.sv | 108 | Constant IS_XLEN64 selection of the RV64 word-op sign extension; not selected when XLEN=32. |
| 54 | WIDTHTRUNC | modified/cva6/core/mult.sv | 109 | Constant IS_XLEN64 selection of the RV64 word-op sign extension; not selected when XLEN=32. |
| 55 | WIDTHEXPAND | modified/cva6/core/mult.sv | 150 | Constant IS_XLEN64 selection of the RV64 word-op sign extension; not selected when XLEN=32. |
| 56 | WIDTHTRUNC | modified/cva6/core/mult.sv | 150 | Constant IS_XLEN64 selection of the RV64 word-op sign extension; not selected when XLEN=32. |
| 57 | WIDTHTRUNC | third_party/cva6/core/frontend/instr_queue.sv | 382 | tval padding to 64 bits with VLEN=32 (upstream). |
| 58 | WIDTHEXPAND | modified/cva6/core/perf_counters.sv | 225 | 64-bit counter written from a 32-bit CSR word; RV32 writes low/high halves separately (upstream). |
| 59 | WIDTHEXPAND | modified/cva6/core/csr_regfile.sv | 421 | mstatus_extended / MSTATUSH handling: constant XLEN selection; RV32 arm value is correct after truncation. |
| 60 | WIDTHTRUNC | modified/cva6/core/csr_regfile.sv | 421 | mstatus_extended / MSTATUSH handling: constant XLEN selection; RV32 arm value is correct after truncation. |
| 61 | WIDTHEXPAND | modified/cva6/core/csr_regfile.sv | 1676 | mstatus_extended / MSTATUSH handling: constant XLEN selection; RV32 arm value is correct after truncation. |
| 62 | WIDTHCONCAT | third_party/cva6/core/frontend/frontend.sv | 377 | Unsized constant in a fetch-address concatenation (upstream). |
| 63 | WIDTHEXPAND | modified/cva6/core/cva6.sv | 1394 | CMO maintenance-fault cause compared with 64-bit constant 24; exception cause is XLEN wide; zero extension is correct. |
| 64 | SELRANGE | modified/cva6/core/cva6_mmu/cva6_shared_tlb.sv | 670 | Same Sv39-only indices as cva6_tlb (upstream). |
| 65 | SELRANGE | modified/cva6/core/cva6_mmu/cva6_tlb.sv | 234 | Sv39 third-level VPN and page-size indices in loops sized for Sv32; guarded by PtLevels/IS_XLEN64 (upstream). |
| 66 | SELRANGE | modified/cva6/core/cva6_mmu/cva6_tlb.sv | 250 | Sv39 third-level VPN and page-size indices in loops sized for Sv32; guarded by PtLevels/IS_XLEN64 (upstream). |
| 67 | SELRANGE | modified/cva6/core/cva6_mmu/cva6_tlb.sv | 316 | Sv39 third-level VPN and page-size indices in loops sized for Sv32; guarded by PtLevels/IS_XLEN64 (upstream). |
| 68 | SELRANGE | modified/cva6/core/cva6_mmu/cva6_tlb.sv | 327 | Sv39 third-level VPN and page-size indices in loops sized for Sv32; guarded by PtLevels/IS_XLEN64 (upstream). |
