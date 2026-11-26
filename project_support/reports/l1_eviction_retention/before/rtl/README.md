# Cluster RTL / RTL cluster

TOP: [`m_vlsit_riscv_cluster_axi_top`](../../../../../verification/non_coherence_cluster/reports/l1_eviction_retention/before/rtl/vlsit/m_vlsit_riscv_cluster_axi_top.sv).
Select `PARA_CPU_NUM=2` or `4`; default is 4.

TOP dùng `PARA_CPU_NUM=2` hoặc `4`, mặc định 4 hart.

| Directory / Thư mục | Purpose / Chức năng |
|---|---|
| `vlsit` | New VLSIT modules and adapters / Module và adapter VLSIT mới |
| `third_party` | Pristine licensed upstream sources / Nguồn upstream giữ nguyên |
| `modified` | Licensed local modifications with history / Bản sửa giữ license và history |
| `verification` | Testbenches and replay commands / Testbench và lệnh chạy lại |
| `reports` | Lint logs and simulation evidence / Log lint và bằng chứng mô phỏng |

External CMO is enabled in the production core. See [real CBO instruction tests and TOP lint](../../../../../verification/non_coherence_cluster/reports/l1_eviction_retention/before/rtl/reports/cmo_end_to_end/README.md), including remaining warnings and validation limits.

Core production đã bật external CMO. Xem test CBO thật và lint TOP tại liên kết trên; báo cáo nêu warning còn lại và giới hạn kiểm chứng.

TOP lint at 2/4 harts has 0 errors and 0 warnings; see [cleanup evidence](../../../../../verification/non_coherence_cluster/reports/l1_eviction_retention/before/rtl/reports/lint_cleanup/README.md). / Lint TOP 2/4 hart có 0 lỗi và 0 warning; xem bằng chứng tại liên kết trên.


FENCE.I DEC-030/031: retirement waits for coherent clean and I-cache completion; errors trap cause 24 only after ABORT ACK. Eight real-instruction 2/4-hart M/S-mode cases pass. [Report and changed files](../../../../../verification/non_coherence_cluster/reports/l1_eviction_retention/before/rtl/reports/fence_i/README.md), [replay and waveforms](../../../../../verification/non_coherence_cluster/reports/l1_eviction_retention/before/rtl/verification/fence_i_end_to_end/README.md).

FENCE.I giữ retirement đến khi clean coherent và I-cache hoàn tất; lỗi chỉ trap cause 24 sau ACK ABORT. Tám ca instruction thật ở 2/4 hart, M/S-mode đều pass; xem báo cáo và lệnh chạy lại tại các liên kết trên.


FPU warning cleanup: both native simulation models and TOP lint at 2/4 harts have zero warnings; FPU equivalence and all eight real FENCE.I cases pass. [Evidence and modified files](../../../../../verification/non_coherence_cluster/reports/l1_eviction_retention/before/rtl/reports/fpu_warning_fix/README.md).

Đã sửa hai warning FPU: model mô phỏng và lint TOP 2/4 hart đều không còn warning; test tương đương FPU và tám ca FENCE.I thật đều pass. Báo cáo trên ghi bằng chứng và file sửa.


Silent E→M fix: LOAD→STORE→CBO success/error, baseline CBO and FENCE.I regressions pass at 2/4 harts. No state check or warning was disabled. [Evidence](../../../../../verification/non_coherence_cluster/reports/l1_eviction_retention/before/rtl/reports/e_to_m_fix/README.md).

Đã sửa E→M cục bộ: LOAD→STORE→CBO thành công/lỗi, CBO gốc và FENCE.I đều pass ở 2/4 hart. Không bỏ check state hoặc tắt warning.


A-02 DEC-038: cached AMO/LR-SC executes in coherent L1. Contended AMO and LR/SC retry, refill faults and dirty-owner ABORT faults pass at 2/4 harts, with CBO/FENCE.I regression and strict TOP lint. [Results, replay and limits](reports/atomic_coherence/README.md).

A-02: AMO/LR-SC cached chạy tại L1 coherent; test tranh chấp/retry, lỗi refill và ABORT owner dirty đều pass 2/4 hart. CBO/FENCE.I và lint TOP đã chạy lại; báo cáo trên nêu giới hạn còn lại.
