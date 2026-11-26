# RV32 profile - simulation test plan, draft 1 / Kế hoạch testbench bản RV32

Derived only from `doc/specification_32/VLSIT_RISCV32_DUAL_QUAD_CPU_CLUSTER_HDS.md` rev 0.1 (REQ-XL-001 to REQ-XL-014, TEST-101 to TEST-114, SVA-101 to SVA-103), the base specification it inherits, the RISC-V ISA (RV32I, M, A, F, C, B, Zcb, Zicond, Zicbom, Sv32) and AMBA AXI4 / AXI4-Lite (IHI 0022H). Expected values come from an independent Python RV32 encoder and oracle, not from the RTL (rule R-023).

## 1. Environment

| Item | Choice | Reason |
|---|---|---|
| DUT | `m_vlsit_riscv_cluster_axi_top`, filelist `rtl/rv32_profile/filelist_rv32.f`, 2 harts (4 harts for TC-04 and TC-06) | REQ-XL-001, REQ-XL-002 |
| Simulator | Verilator 5.053 (`--timing --assert`), g++ from MSYS2 UCRT64 | Same flow as the existing 64-bit CPU tests |
| Programs | Python RV32 encoder writing a hex image; no GCC (none installed) | The existing tests use the same method |
| Memory | AXI4 slave memory model behind the memory port, AXI4 MMIO device model behind the MMIO port, written from IHI 0022H | Independent of the RTL |
| Oracle | Python reference of each program's architectural results and expected AXI traffic | Rule R-023 |
| Assertions | SVA-101 to SVA-103 (bind file) + at least 20 AXI4 protocol assertions on the memory port and 20 on the MMIO port, with hit and fail counters | Rules R-024, R-025 |
| Evidence | One VCD per testcase in `verification/rv32_profile/waveforms_sim/`, `waveform_compare.md` for WF-101, review ledger | Rules R-033, R-097 |

## 2. Integrated testcases (minimum ten, rule R-048)

Each testcase checks at least two specified functions in one sequence and has at least five executable checks.

| ID | Spec tests | Functions exercised together | Main checks |
|---|---|---|---|
| TC-01 | TEST-101, 102, 103 | Boot fan-out, hart identity, misa, RV64-only encodings | Both harts start at `i_boot_addr[31:0]`; `mhartid` 0/1; `misa.MXL=1`; ADDW, LD, SD, AMOADD.D, LR.D each trap with cause 2 and `mtval` = encoding; execution resumes |
| TC-02 | TEST-101, 113 | RV32 integer ALU, M, B, Zcb, Zicond, 64-bit counters | Results equal the oracle; `cycleh:cycle` and `instreth:instret` consistent across a low-word carry |
| TC-03 | TEST-104 | F single precision, fflags, D encodings | FADD.S/FMUL.S/FDIV.S/FSQRT.S results and fflags equal the oracle; FADD.D traps illegal |
| TC-04 | TEST-106, 107, 109 | Cached load/store, read sharing between harts, AXI address width | Final memory equals the oracle; every AXI address has bits 63:34 = 0 (SVA-103); MESI shared read sees the writer's value |
| TC-05 (WF-101) | TEST-107, 109, 112 | Dirty-owner transfer, probe line address, owner writeback | Hart 1 reads a line dirty in hart 0 and gets the new value; probe line address bits 51:30 = 0 (SVA-101); owner writeback is two 64-bit W beats with full strobes; directory/grant order as base WF-002 |
| TC-06 | TEST-103, 112 | LR.W/SC.W and AMO*.W across harts, cached and uncached | Shared counter reaches 10 + 8 x harts with no lost update; SC fails after a remote write; uncached AMOADD.W uses AWATOP with 4-byte size; results equal the oracle |
| TC-07 | TEST-112 | CBO.CLEAN, CBO.FLUSH, CBO.INVAL, FENCE.I on 32-bit addresses | Memory holds the dirty data after CLEAN/FLUSH; INVAL drops it; FENCE.I then executes newly written code; CMO virtual address on the 64-bit port is zero-extended |
| TC-08 | TEST-105 | Sv32 two-level walk, 4 KiB and 4 MiB pages, S/U modes, page faults | Translated loads/stores hit the oracle physical address; a U access to an S page faults with the right cause and `stval`; MRET/SRET mode changes correct |
| TC-09 | TEST-106, 110 | MMIO access, uncached ordering, AXI4 MMIO protocol | MMIO writes and reads reach the MMIO model in program order with correct size and strobes; no MMIO access goes to the memory port |
| TC-10 | TEST-108 | Boot address upper bits, reset | With `i_boot_addr[63:32]=0` boot succeeds; a run with nonzero upper bits makes SVA-102 fail (negative run expected to fail) |
| TC-11 | TEST-113 | Cluster PMU through AXI4-Lite, hart events | Event counters selected by software count retired instructions and cache misses of TC-04's sequence within the oracle range; snapshot read is consistent |
| TC-12 | TEST-114 | Timing profiles 1 and 2 | TC-04 and TC-05 pass unchanged with `PARA_TIMING_PROFILE` 1 and 2 |

TEST-110 (port list identity) and TEST-111 (region bound) are static checks run by script; TEST-114 lint is already clean.

## 3. Fault qualification (rule R-096)

For each testcase, one plausible fault on a disposable copy of the DUT, with the check expected to catch it recorded before the run. Examples: line adapter drops bit 0 (TC-05), boot address takes bits 63:32 (TC-01), VLEN left at 64 (TC-08), AMO keeps the high 32 bits (TC-06), CMO address not zero-extended (TC-07).

## 4. Open question

Code coverage (rule R-047): see the chat question. No coverage target is set yet.
