# rtl/coherence_fix — Records of the 2026-11-27 coherence fixes / Hồ sơ bản sửa coherence

Working folder of the three coherence deadlock fixes (DEC-046, DEC-047). The fixes are **merged into `rtl/common/`**, so this folder is **not needed to build** either cluster version. It keeps the pre-fix snapshot to reproduce the bug, and the check records.

Thư mục làm việc của ba bản sửa deadlock coherence (DEC-046, DEC-047). Các bản sửa **đã merge vào `rtl/common/`**, nên **không cần thư mục này để build**. Nó giữ bản trước khi sửa để tái hiện lỗi, cùng hồ sơ kiểm tra.

## Content / Nội dung

| Path | Content / Nội dung |
|---|---|
| `pre_merge/` | Files before the fix: `hpdcache.sv`, `hpdcache_ctrl.sv`, `hpdcache_rtab.sv`, `m_vlsit_riscv_coh_fabric.sv`, with SHA-256 |
| `filelists/pre_merge/filelist_pre.f` | 64-bit cluster built from the pre-fix files; used by `verification/rv32_profile/run.py --base-64` to reproduce the TC-07 hang |
| `filelists/negative_v1/` | RV32 build with fixes 1-2 only (original fabric); shows that testbench assertion SVA-104 detects defect 3 |
| `hpdcache/`, `coherence/` | Verified fixed copies, byte-identical to the merged files in `rtl/common/` |
| `filelist_fix.f`, `filelists/*_fix.*` | Filelists used before the merge |
| `original_sha256.txt` | Hashes of the originals taken before any edit |
| `HDS_rev0.36_before_DEC-046.md` | Copy of the 64-bit HDS before the specification update |
| `rv32_hpdcache_before.sv.bak` | RV32 `hpdcache.sv` before the fix |
| `lint/`, `rulecheck_*` | Lint and rule-check outputs (ignored by Git) |

## The three fixes / Ba bản sửa

| # | File | Change / Thay đổi |
|---|---|---|
| 1 | `hpdcache.sv`, `hpdcache_ctrl.sv` | An AMO takes atomic permission only after an E/M grant (LR keeps S) |
| 2 | `hpdcache_rtab.sv` | The RTAB fence holds while an AMO, uncacheable or CMO entry is queued |
| 3 | `m_vlsit_riscv_coh_fabric.sv` | A context leaves DIR_UPDATE/DIR_CANCEL only on the handshake with its own tag |

Why each fix was needed: [64-bit HDS Section 14.7](../../doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) · [change plan](../../doc/specification/HPDCACHE_ATOMIC_DEADLOCK_CHANGE_PLAN.md) · [test report](../../verification/rv32_profile/REPORT.md) sections 3c-3f.

## Notes / Lưu ý

- Do not add `pre_merge/` files to a product filelist: they contain the deadlock defects. / Không đưa file `pre_merge/` vào filelist sản phẩm.
- The folder can be removed once the pre-fix reproduction is no longer needed; `run.py --base-64` and `negative_v1` then stop working.
