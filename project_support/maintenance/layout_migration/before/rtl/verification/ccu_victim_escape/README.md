# CCU victim escape verification / Kiểm thử slot thoát của CCU

`tb_victim_escape.sv` checks the context-capacity and exact completion contracts with an independent cache-state/request-ID BFM. Run `run_unit.py --slots 2`, `8` or `16`; no production array is forced or seeded by hierarchical writes. All entries are created through real fabric request/grant handshakes.

`build_program.py` encodes RV64 instructions and independent expected data; `.lst` files list the actual encoded words and `.hex` files are replayable images. `tb_victim_escape_cpu.sv` runs native CVA6 harts through production TOP with two contexts, 16-KiB-spaced lines and AXI memory backpressure. It checks real retirement, exact data/atomic results, traps, final CBO memory publication, actual victim/full-table/root-stall activation, and 40 activated AXI checks. The renamed LLC wrapper and fault shim are verification-only; production sources are unchanged.

VI: Unit dùng BFM độc lập để kiểm tra capacity và matching ID; tạo directory bằng request/grant, không force array. CPU test dùng lệnh RV64 thật, chín line cách 16 KiB và hai context; kiểm tra retirement, dữ liệu/atomic, trap, CBO cuối và assertion AXI. Shim LLC chỉ thuộc testbench.

Run the complete flow from the existing [Makefile](../cmo_end_to_end/Makefile):

```sh
make victim-regression
```

Focused command examples:

```sh
python run_unit.py --slots 16 --jobs 3
python run.py --harts 2 --jobs 3
python run.py --harts 2 --case clean_eviction --run-only
```

`--run-only` for CPU tests requires an exact production/bench/program fingerprint match. Mutation commands change only a copied fabric under the build directory; expected assertion failures are recorded separately. All supported commands are described in the single Makefile. Logs, reports and sampled VCD files: [A-05 evidence](../../reports/ccu_victim_escape/README.md). Code coverage is not measured.

VI: `--run-only` kiểm tra hash trước khi tái dùng CPU model. Mutation chỉ sửa bản sao build, tách log lỗi cố ý khỏi log production. Toàn bộ lệnh nằm trong Makefile chung; chưa đo code coverage.
