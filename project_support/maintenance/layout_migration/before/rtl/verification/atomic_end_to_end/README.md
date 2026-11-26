# Atomic instruction tests / Test instruction atomic

## English

The bench boots real CVA6 harts through `m_vlsit_riscv_cluster_axi_top`. `build_program.py` creates RV64 machine code, readable instruction listings and an independent arithmetic oracle. No cache state, CPU completion or retirement is forced.

| Case | Checks |
|---|---|
| `success` | Contended AMOADD.D: eight updates/hart, unique old values, final counter after CBO.CLEAN; all nine AMO operations at D/W-low/W-high; LR/SC success, failure, replacement and remote-store invalidation |
| `lrsc_contention` | Real LR/ADDI/SC/BNE retry loop: eight successful updates/hart; same unique-old-value/final-counter oracle |
| `amo_fault` / `lr_fault` | Native external refill RRESP fault: cause 7 / 5, original PC/VA, no faulty atomic or younger retirement/GPR update |
| `owner_fault` | Dirty owner value 41; injected L1-to-LLC writeback B error; ABORT ACK before error grant/trap; owner loads retain 41 |

The `shared_AMO` console label counts the common successful-update checkpoint, including the LR/SC variant. Inspect `lrsc_contention.S` to see the actual retry instructions. Fault cases run protocol assertions too; only success/contention require activation of every write/read protocol-coverage checkpoint because refill-only fault programs issue no write burst.

Fault injection changes a response in the verification-only LLC shim after the native LLC accepts the write. The native production wrapper is copied with a private module name; it is not replaced by a functional cache model. External memory and AXI backpressure are testbench models. VCDs record selected response/probe vectors at rising edges, not every internal net.

From the repository root:

```powershell
python rtl/verification/atomic_end_to_end/run.py --harts 4 --jobs 2
python rtl/verification/atomic_end_to_end/run.py --harts 4 --case lrsc_contention --run-only
python rtl/verification/atomic_end_to_end/run.py --harts 4 --case amo_fault --run-only
python rtl/verification/atomic_end_to_end/run.py --harts 4 --case lr_fault --run-only
python rtl/verification/atomic_end_to_end/run.py --harts 4 --case owner_fault --run-only
```

Repeat with `--harts 2`. Build before using `--run-only`; rebuild after RTL changes. One complete replay command is `make atomic-regression` from `rtl/verification/cmo_end_to_end`. It includes the focused probe/bank/refill/retirement/LLC tests and CBO/FENCE.I/TOP lint. [Results and limits](../../reports/atomic_coherence/README.md).

## Tiếng Việt

Testbench boot CVA6 thật từ TOP production, chạy mã RV64 sinh tự động và so với oracle phép toán độc lập. Không force state cache hoặc completion CPU. Hai workload kiểm tra tranh chấp AMO và vòng retry LR/SC; ba nhánh lỗi kiểm tra cause/PC/VA, không retire sai và giữ dữ liệu owner sau ABORT.

Nhãn log `shared_AMO` là checkpoint dùng chung, kể cả ca LR/SC; file `.S` ghi instruction thực. Shim lỗi chỉ thay response AXI để kích hoạt đường lỗi; LLC native vẫn thực thi. VCD ghi tín hiệu chọn tại cạnh clock. Chạy `make atomic-regression` từ Makefile nêu trên để tái tạo toàn bộ. Dùng `--run-only` khi model đã build đúng RTL; chưa đo code coverage hoặc kiểm chứng uncached ATOP.
