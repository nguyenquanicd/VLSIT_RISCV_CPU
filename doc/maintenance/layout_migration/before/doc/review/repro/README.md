# Review reproductions

Small Verilator testbenches that back the findings of
[`../VLSIT_RISCV_CPU_Cluster_Design_Review.md`](../VLSIT_RISCV_CPU_Cluster_Design_Review.md).
Each case runs one module of `rtl/vlsit` in isolation; none of them needs the (missing) cluster top.

| Case | Finding | What it shows |
|---|---|---|
| `dir_deadlock` | CC-01 | A hit transaction's update is blocked by another transaction's set reservation; cancel and lookup are blocked too; no progress after 20 cycles |
| `reg_bridge_denied_write` | RB-01 | A write to `CFG_SPM_LOW` or a read-only register reaches the LLC RegBus and gets two B responses (SLVERR then OKAY) |
| `txn_probe_rate` | PF-05, CC-02 | 5 cycles per probe per hart, 4 cycles per phase with an ideal cache, and a duplicate ACK that is never consumed |
| `bank_arb_dup_grant` | CC-03 | One request is granted twice when the consumer drops `i_req_valid` one cycle late |

## Run

```sh
sh doc/review/repro/<case>/run.sh
```

Needs Verilator (OSS CAD Suite) and MinGW g++. The defaults match `APB-DEC-Generator/tests/run_cov.sh`;
override them with `OSS_CAD_POSIX`, `MSYS_UCRT_POSIX` and `VERILATOR_ROOT_WIN`. Build files go to a
temporary directory (`WORK` overrides it).

## Expected output today

These cases reproduce bugs; they are not passing tests.

| Case | Last lines |
|---|---|
| `dir_deadlock` | `after 20 cycles: update_ready=0 cancel_ready=0 -> DEADLOCK` |
| `reg_bridge_denied_write` | `write 0x0: RegBus writes=1, B responses=2` |
| `txn_probe_rate` | `PROBE-RATE: ... 5 cycles/probe`; `DUP-ACK: ... ready=0` |
| `bank_arb_dup_grant` | `drop delay 1 cycle(s) ...: grants for ONE request = 2` |

Once a finding is fixed, change the testbench to fail (`$fatal`) on the wrong result and keep it as a regression.
