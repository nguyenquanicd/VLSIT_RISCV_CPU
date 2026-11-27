# verification/non_coherence_cluster — End-to-end suites of the 64-bit cluster / Suite end-to-end của cluster 64-bit

Suites that build the production 64-bit cluster TOP (`rtl/non_coherence_cluster`) with Verilator and run real CVA6 instruction programs through it. Each suite has its own `run.py`; most take `--harts 2|4` and an error-injection or case option.

Các suite build TOP cluster 64-bit sản phẩm bằng Verilator và chạy chương trình lệnh CVA6 thật. Mỗi suite có `run.py` riêng; đa số nhận `--harts 2|4` và tùy chọn case hoặc chèn lỗi.

| Suite | What it checks / Kiểm tra gì | Options / Tùy chọn |
|---|---|---|
| `atomic_end_to_end` | Cached AMO and LR/SC between harts, contention, access faults / Atomic có cache, tranh chấp, lỗi truy cập | `--case success, lrsc_contention, amo_fault, lr_fault, owner_fault` |
| `cmo_end_to_end` | CBO through retirement, CMO arbiter, CCU and LLC, with and without write-back error / CBO qua arbiter, CCU, LLC | `--error 0/1`, `--load-first` |
| `fence_i_end_to_end` | FENCE.I synchronization through coherent clean (WF-019) / Đồng bộ FENCE.I | `--error 0/1`, `--supervisor` |
| `directory_holder_end_to_end` | Directory holder lifecycle: dirty/clean eviction, refill errors / Vòng đời holder trong directory | `--case dirty_eviction, clean_eviction, amo_refill_error, lr_refill_error` |
| `ccu_victim_escape` | Directory victim/CANCEL progress with 2, 8 or 16 contexts (WF-020) / Tiến triển victim và CANCEL | `--case ...`, `--slots 2/8/16` |
| `l1_eviction_end_to_end` | Ordinary L1 eviction and write-back / Eviction L1 thông thường | `--error 0/2/3` |
| `e_to_m_fix` | Silent E-to-M upgrade at the unique owner (4 harts) / Nâng E lên M không cần transaction | `--error 0/1` |
| `fault_record_a06` | First-fatal fault record (A-06) / Ghi lỗi fatal đầu tiên | `--error 2/3` |
| `cluster_completeness_audit` | Full-cluster audit program / Chương trình audit toàn cluster | `--error 0/1` |
| `fpu_warning_fix` | Cycle equivalence of the lint-cleaned FPU against the unmodified FPU / Tương đương chu kỳ của FPU sau khi sửa lint | — |

`reports/` holds the recorded evidence of each suite (results, VCD and logs ignored by Git); `traces/` holds CVA6 traces (ignored); `build/` is generated.

`reports/` chứa bằng chứng đã ghi của từng suite (VCD và log không commit); `traces/` chứa trace CVA6 (không commit); `build/` sinh tự động.

## Example / Ví dụ

```powershell
cd verification/non_coherence_cluster/atomic_end_to_end
python run.py --harts 4 --case success
python run.py --harts 4 --case lrsc_contention --run-only   # reuse the last build
```

## Notes / Lưu ý

- Running a suite overwrites its files in `reports/` and its `build/` folder. To keep the recorded evidence, run a copy (as `verification/coherence_fix/` does). / Chạy suite sẽ ghi đè `reports/`; muốn giữ bằng chứng thì chạy bản sao.
- `run.py` calls `scripts/lint_source_overrides.py`, which may rewrite the shared filelists in `rtl/common/filelists/` when `lint/config/lint_source_overrides.json` lists overrides. / Script có thể sửa filelist dùng chung.
- After the 2026-11-27 merge, the atomic, CMO, FENCE.I and directory-holder suites pass with 2 and 4 harts on the fixed RTL; the other suites were not rerun. / Các suite khác chưa chạy lại sau khi merge.
- Tool paths are absolute (`C:/Users/PC/Tools/...`); edit them on another machine.
