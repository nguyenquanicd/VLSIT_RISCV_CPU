# rtl/rv32_profile — 32-bit cluster version / Phiên bản cluster 32-bit

The RV32 version of the 2/4-hart cluster. It reuses the whole 64-bit cluster (TOP, coherence, LLC, CSR, PMU, ports) and replaces only what XLEN=32 needs. Every file here is either new or a copy of an original that stays unchanged in `rtl/common/`.

Phiên bản RV32 của cluster 2/4 hart. Dùng lại toàn bộ cluster 64-bit (TOP, coherence, LLC, CSR, PMU, cổng) và chỉ thay những phần cần cho XLEN=32. Mỗi file ở đây là file mới hoặc bản sao; bản gốc trong `rtl/common/` không đổi.

## Source / Mã nguồn

| Path | Function / Chức năng | Original / Bản gốc |
|---|---|---|
| `cva6/cv32a6_imafc_sv32_hpdcache_wb_config_pkg.sv` | CVA6 configuration: XLEN 32, VLEN 32, RVD 0 (F without D), DataUserWidth 64; AXI user width pinned at 64. Declares `cva6_config_pkg`, so only this package or the 64-bit one may be in a filelist | NEW, derived from `cv64a6_imafdc_sv39_hpdcache_wb_config_pkg.sv` |
| `cpu/m_vlsit_riscv_cpu_tile.sv` | CPU tile with width adapters: 30-bit core line addresses zero-extended to the 52-bit cluster format and truncated on the way in; 32-bit boot address, hart ID and CMO addresses | `rtl/common/vlsit/cpu/` |
| `coherence/m_vlsit_riscv_hpd_probe_engine.sv` | HPDcache probe engine with parameter `PARA_NLINE_W` instead of fixed 52-bit line ports | `rtl/common/vlsit/coherence/` |
| `hpdcache/hpdcache.sv` | Passes `PARA_NLINE_W` to the probe engine; also carries the DEC-046 grant-uniqueness connection | `rtl/common/modified/hpdcache/rtl/src/` |
| `cvfpu/fpnew_divsqrt_th_64_multi.sv` | FPU divide/square-root wrapper: FP32 operands NaN-boxed with ones before the 64-bit C910 divider (DEC-106) | `rtl/common/modified/cvfpu/src/` |
| `filelist_rv32.f`, `filelists/` | RV32 filelist chain (CVA6, HPDcache, cluster) | — |
| `lint/rv32_upstream_waivers.vlt`, `.md` | 68 per-line Verilator waivers for upstream XLEN/Sv39 constant patterns, each justified in the `.md` | — |
| `spec_backup/` | Copy of the specification before RTL decisions and SHA-256 of the originals | — |

## Use / Cách dùng

TOP `m_vlsit_riscv_cluster_axi_top`, filelist `filelist_rv32.f`, plus `lint/rv32_upstream_waivers.vlt`. Testbench: [verification/rv32_profile](../../verification/rv32_profile/) (`python run.py build --harts 4`).

## Notes / Lưu ý

- The shared coherence fixes (DEC-046, DEC-047) are in `rtl/common/`; this profile picks them up through its filelists. / Các bản sửa coherence dùng chung nằm trong `rtl/common/`.
- Every AXI port stays 64-bit; the upper address bits are zero (PLEN 34). The cluster directory keeps 52-bit line tags, so bits 51:30 are constant zero (OPEN-X32-DIR). / Mọi cổng AXI vẫn 64-bit; bit cao của địa chỉ bằng 0.
- Not backward compatible with RV64 software, and the 64-bit cluster cannot run RV32 binaries (XLEN is fixed). / Không chạy được phần mềm RV64.
- Filelists use absolute paths; rewrite the prefix on another machine.
- Specification: [RV32 HDS](../../doc/specification_32/VLSIT_RISCV32_DUAL_QUAD_CPU_CLUSTER_HDS.md) Sections 8 and 14 · [change plan](../../doc/specification_32/RV32_RTL_CHANGE_PLAN.md).
