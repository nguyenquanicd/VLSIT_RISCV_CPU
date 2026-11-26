# Review reproductions

Small Verilator testbenches that back the findings of the reviews
[`../VLSIT_RISCV_CPU_Cluster_Design_Review.md`](../VLSIT_RISCV_CPU_Cluster_Design_Review.md) (2026-11-09) and
[`../VLSIT_RISCV_CPU_Review_2026-11-16.md`](../VLSIT_RISCV_CPU_Review_2026-11-16.md).
Each case runs one module of `rtl/common/vlsit` in isolation; none of them needs the cluster top.
Each testbench ends with a `RESULT: PASS` or `RESULT: FAIL` line, except `txn_probe_rate`, which prints measurements.

| Case | Finding | What it checks | Result on the RTL of 2026-11-16 |
|---|---|---|---|
| `dir_deadlock` | CC-01 | A hit transaction and a miss transaction on one directory set; owner CANCEL/UPDATE must not be blocked by another transaction's held UPDATE | `RESULT: PASS` (fixed) |
| `bank_arb_dup_grant` | CC-03 | One request must be granted once, whatever the cycle in which the consumer drops `i_req_valid` | `RESULT: PASS` (fixed) |
| `txn_probe_rate` | PF-05, CC-02 | Cycles per transaction on one target hart (ideal cache), parallel PREPARE on different harts, duplicate ACK is drained and flagged | Prints `TXN-RATE ... 12 cycles per transaction`; `DUP-ACK ... o_ack_ready=1` (CC-02 fixed) |
| `reg_bridge_denied_write` | RB-01 | A write to `CFG_SPM_LOW` or a read-only LLC register must give no RegBus write and exactly one B response | `RESULT: FAIL (RB-01 present: 4 bad case(s))` |

## Run

```sh
sh doc/review/repro/<case>/run.sh
```

Needs Verilator (OSS CAD Suite) and MinGW g++. The defaults match `APB-DEC-Generator/tests/run_cov.sh`;
override them with `OSS_CAD_POSIX`, `MSYS_UCRT_POSIX` and `VERILATOR_ROOT_WIN`. Build files go to a
temporary directory (`WORK` overrides it).

## Keeping them as regressions

`dir_deadlock` and `bank_arb_dup_grant` should stay PASS. `reg_bridge_denied_write` must turn to PASS when RB-01
is fixed (add `& ~w_wr_addr_wr_denied` to the `IDLE` to `WR_REQ` condition of `m_vlsit_axil_reg_bridge.sv`).
`txn_probe_rate` only measures; change its prints to `$fatal` checks once a cycle budget is agreed.
