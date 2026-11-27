# rtl/common — Shared RTL / RTL dùng chung

All RTL shared by the cluster versions, split by origin. A build lists files from these folders through the filelists in `filelists/` and in each TOP folder.

Toàn bộ RTL dùng chung cho các phiên bản cluster, chia theo nguồn gốc. Build lấy file từ các thư mục này qua filelist trong `filelists/` và trong thư mục TOP.

| Folder | Content / Nội dung | Rule / Quy tắc |
|---|---|---|
| `third_party/` | Unchanged upstream RTL: `cva6`, `hpdcache`, `cvfpu`, `axi`, `axi_llc`, `common_cells`, `register_interface`, `tech_cells_generic`, `apb`, `ace`, `culsans` and pinned copies (`*_cva6_pinned`, `axi_llc_locked`) | Never edit. Keep license headers. / Không sửa |
| `modified/` | Local changes of upstream files, at the same relative path as in `third_party/` | Keep the upstream license and header; add a dated change comment per edit / Giữ license, ghi chú thay đổi có ngày |
| `vlsit/` | New VLSIT RTL and generated CSR | Follows the VLSIT RTL design rules / Theo quy tắc RTL VLSIT |
| `filelists/` | Shared filelists (CVA6 + HPDcache path, LLC, MMIO, routers, test subsets) | Absolute paths |

## modified/ — main changes / thay đổi chính

| Component | Files / Số file | Why changed / Lý do |
|---|---|---|
| `cva6/` | 40: cache subsystem, LSU/store buffer, CSR, MMU, `fpu_wrap`, `build_config_pkg`, the 64-bit package `cv64a6_imafdc_sv39_hpdcache_wb_config_pkg.sv` | Coherent HPDcache integration, CBO/FENCE.I retirement, PMA from the address table, PMU taps |
| `hpdcache/` | 9: `hpdcache.sv`, `hpdcache_ctrl.sv`, `hpdcache_ctrl_pe.sv`, `hpdcache_rtab.sv`, `hpdcache_miss_handler.sv`, `hpdcache_mshr.sv`, `hpdcache_flush.sv`, `hpdcache_memctrl.sv`, `hwpf_stride_wrapper.sv` | MESI probes and ownership requests, line locks, coherent atomics (DEC-038), deadlock fixes 1-2 (DEC-046) |
| `cvfpu/` | 8 | Coding-rule fixes only: explicit widths and extensions, descending packed dimensions; no functional change in this folder (the RV32 divider fix DEC-106 is a copy in `rtl/rv32_profile/cvfpu/`) |
| `axi_llc/` | 16 | Writeback-safe flush and replacement (tags change only after OKAY write response), refill tags committed only after complete R data (DEC-038), fatal writeback event forwarding (DEC-039/040), explicit widths |
| `axi_llc_locked/` | 5 | Coding-rule fixes (explicit sizing, separated FSM outputs); no added registers or latency |
| `hpdcache_cva6_pinned/` | 6 | Cached atomics after CCU permission (DEC-038), FENCE.I through coherent clean (DEC-030/031), explicit widths |

## vlsit/ — new RTL by function / RTL mới theo chức năng

| Folder | Modules / Khối | Function / Chức năng |
|---|---|---|
| `cpu/` | `m_vlsit_riscv_cpu_tile`, `m_vlsit_riscv_cpu_tile_array` | CVA6 tile wrapper (PMA from the shared address table) and tile array |
| `coherence/` | `coh_fabric`, `coh_txn_table`, `sharer_directory`, `probe_scheduler`, `coh_bank_arb`, `coh_tile_array`, `tile_coh_adapter`, `cache_line_locks`, `hpd_probe_engine` | MESI coherence: 8 tagged contexts, 4-bank sharer directory, PREPARE/COMMIT/ABORT probes, per-line locks |
| `maintenance/` | `cmo_arbiter`, `cmo_controller` | CBO.CLEAN/FLUSH/INVAL and FENCE.I sequencing through the CCU and LLC |
| `cache/` | `m_vlsit_axi_llc` | Binds cluster AXI and RegBus to the PULP LLC |
| `interconnect/` | `axi_route`, `axi_mem_mux`, `axi_mmio` | Region-based routing of each tile's AXI port; memory and MMIO merge |
| `address_map/` | `m_vlsit_riscv_addr_decode` | One region table for PMA and routing (cacheable / normal uncached / MMIO) |
| `control/` | `axil_decode`, `axil_reg_bridge` | AXI4-Lite aperture to CSR and LLC RegBus |
| `csr/RTL/` | generated | CSR block generated from the CSR workbook (do not hand-edit) |
| `pmu/` | `m_vlsit_riscv_pmu` and 7 sub-blocks | Event selection, counters, snapshot, overflow IRQ |
| `debug/` | `m_vlsit_riscv_debug_router` | Per-hart debug routing |
| `diagnostics/` | `m_vlsit_riscv_fault_record` | First-fatal fault record |

## Notes / Lưu ý

- 2026-11-27: `hpdcache.sv`, `hpdcache_ctrl.sv`, `hpdcache_rtab.sv` and `vlsit/coherence/m_vlsit_riscv_coh_fabric.sv` contain the coherence deadlock fixes (DEC-046, DEC-047). Pre-fix copies: [`rtl/coherence_fix/pre_merge/`](../coherence_fix/). / Các file này chứa bản sửa deadlock coherence.
- `m_vlsit_riscv_coh_fabric.sv` still has 19 pre-existing VLSIT rule findings (COM-09, logical operators in value expressions, lines 321-343); they are not functional defects.
- CSR RTL in `vlsit/csr/RTL/` is generated: change the workbook [VLSIT_RISCV_CPU_Cluster_CSR.xlsx](../../doc/specification/VLSIT_RISCV_CPU_Cluster_CSR.xlsx) and regenerate.
- A restrictive vendored `lzc` header remains in the TOP filelist (HDS OPEN-LIC). Licenses: [project_support/licenses/third_party](../../project_support/licenses/third_party/); provenance: [THIRD_PARTY_SOURCES.md](../../doc/specification/references/THIRD_PARTY_SOURCES.md).
- Filelists use absolute paths (`C:/HQuan/102_MyGithub/VLSIT_RISCV_CPU/...`); rewrite the prefix on another machine.
