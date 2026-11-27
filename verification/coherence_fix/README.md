# verification/coherence_fix — Regression of the 2026-11-27 coherence fixes / Regression cho bản sửa coherence

Regression used to qualify the three coherence deadlock fixes (DEC-046, DEC-047) before and after the merge into `rtl/common/`. The suites here are **copies** of four suites from `verification/non_coherence_cluster/`, so their reports do not overwrite the recorded baseline evidence.

Regression dùng để kiểm chứng ba bản sửa deadlock coherence trước và sau khi merge vào `rtl/common/`. Các suite ở đây là **bản sao** của bốn suite trong `verification/non_coherence_cluster/`, để báo cáo không ghi đè bằng chứng baseline.

| Path | Content / Nội dung |
|---|---|
| `atomic_end_to_end/`, `cmo_end_to_end/`, `fence_i_end_to_end/`, `directory_holder_end_to_end/` | Suite copies; their `run.py` builds into `verification/coherence_fix/build` and writes reports to `verification/coherence_fix/reports` / Bản sao suite, ghi vào thư mục riêng |
| `run_v2_all.sh` | Full regression of plan v2: 5 builds, testbench runs on both cluster versions, negative run, 36 suite runs / Regression đầy đủ |
| `run_suites.sh`, `rerun_rest.sh` | Suite-only reruns / Chạy lại suite |
| `v2_summary.txt` | Results after fixes 1-3, before the merge: 36/36 suite runs PASS / Kết quả trước khi merge |
| `merge_summary.txt` | Results on the merged tree: 32-bit TC-01 to TC-10 and 64-bit TC-04 to 07, 09, 10 PASS; pre-fix snapshot still hangs / Kết quả sau khi merge |

## Notes / Lưu ý

- After the merge the suite copies still point to the filelists in `rtl/coherence_fix/filelists/` (`cva6_fix.Flist`, `filelist_vlsit_cluster_fix.f`). Those list RTL that is byte-identical to the merged files, so results stay valid; for new work, run the original suites in `verification/non_coherence_cluster/`. / Bản sao vẫn trỏ tới filelist cũ có RTL giống hệt bản đã merge.
- `*.out`, `build/` and `reports/` are tool outputs and are ignored by Git. / Output của tool, không commit.
- Background and results: [test report](../rv32_profile/REPORT.md) sections 3c-3f · [64-bit HDS Section 14.7](../../doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) · [change plan](../../doc/specification/HPDCACHE_ATOMIC_DEADLOCK_CHANGE_PLAN.md).
