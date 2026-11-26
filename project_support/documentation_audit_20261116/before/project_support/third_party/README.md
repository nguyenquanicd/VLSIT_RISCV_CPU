# Third-party RTL sources

These repositories are pinned source snapshots for reuse or modification in the VLSIT RISC-V cluster. The cloned source files retain their original license and copyright headers. Do not reformat or replace those headers.

| Repository | Revision | Repository license file |
|---|---|---|
| [OpenHW CVA6](https://github.com/openhwfoundation/cva6) | `742dc82a0c706e0a3bfb98b709fd3ee06d50d12a` | Solderpad Hardware License 0.51; individual RTL files may declare another applicable license. |
| [OpenHW HPDcache](https://github.com/openhwfoundation/cv-hpdcache) | `40d2897eda70644df2eb857efd9fa573eaacafab` | Solderpad Hardware License 2.1; retain each file's SPDX/header notices. |
| [PULP Culsans](https://github.com/pulp-platform/culsans) | `a3d741600d03bba2f21b795eda4f6faf7124a152` | Solderpad Hardware License 0.51. Its `.gitmodules` points to the PlanV CVA6 and LLC forks. |
| [PlanV CVA6 pinned by Culsans](https://github.com/planvtech/cva6) | `338d4c1e8df55363a57ac3e936ffc6ce86e7e016` | Solderpad Hardware License 0.51; cloned for interface comparison, not selected as the RTL baseline. |
| [PULP AXI, cluster-shared snapshot](https://github.com/pulp-platform/axi) | `d436bd4936ba1c49cd87521df54580c5159114d3` | Solderpad Hardware License 0.51. |
| [PULP AXI, axi_llc lockfile snapshot](https://github.com/pulp-platform/axi) | `a8c53cee2520d328d390c507c88818e8ac144c8c` | Solderpad Hardware License 0.51; standalone checkout at `axi_llc_locked/axi`. |
| [PULP common_cells, axi_llc lockfile snapshot](https://github.com/pulp-platform/common_cells) | `9ca8a7655f741e7dd5736669a20a301325194c28` | Solderpad Hardware License 0.51; standalone checkout at `axi_llc_locked/common_cells`. |
| [PULP AXI LLC](https://github.com/pulp-platform/axi_llc) | `31059c4be62985f81bc46138f09e442d996aa3f3` | Solderpad Hardware License 0.51. |
| [PULP ACE](https://github.com/pulp-platform/ace) | `f919f5cabf41961321bf37327ab4eb726dfdbd0c` | Solderpad Hardware License 0.51. |
| [PULP register_interface](https://github.com/pulp-platform/register_interface) | `d6e1d4cdaab7870f4faf3f88a1c788eaf5ac129d` | Solderpad Hardware License 0.51. Transitive dependency of `axi_llc`; cloned from its lockfile. |
| [PULP tech_cells_generic](https://github.com/pulp-platform/tech_cells_generic) | `7968dd6e6180df2c644636bc6d2908a49f2190cf` | Solderpad Hardware License 0.51. Transitive dependency of `axi_llc`; provides generic SRAM cells. |
| [PULP common_verification](https://github.com/pulp-platform/common_verification) | `fb1885f48ea46164a10568aeff51884389f67ae3` | Solderpad Hardware License 0.51. Transitive dependency of `axi_llc` and its support libraries. |
| [PULP APB](https://github.com/pulp-platform/apb) | `77ddf073f194d44b9119949d2421be59789e69ae` | Solderpad Hardware License 0.51. Transitive dependency of `register_interface`. |

The axi_llc dependency checkouts use the exact revisions in `scripts/third_party/axi_llc/Bender.lock`, including AXI v0.39.10 and common_cells v1.39.0. The cluster-shared snapshots remain unchanged. A manifest-derived 223-file dependency list elaborates `m_vlsit_axi_llc` with Verilator 5.053: 0 errors and 70 warnings, all from upstream sources; the VLSIT rule checker reports 0 errors and one intentional HIE-02 wrapper warning. This is compile evidence only. The wrapper has not been simulated or connected to the cluster core, and LLC CMO support is not implemented.

## LLC dependency status / Trạng thái dependency LLC

The locked LLC dependency sources, reproducible filelist, and scalar-port VLSIT wrapper are present. Verilator elaboration has 0 errors, with 70 upstream warnings; rule checking has 0 errors and one intentional wrapper warning. The wrapper is not simulated or wired into the cluster core, and per-line CMO is still missing. Do not treat this as full LLC or cluster verification. / Đã có source dependency LLC đúng lockfile, filelist chạy lại được và wrapper VLSIT chuyển đổi cổng. Verilator elaboration có 0 lỗi và 70 cảnh báo upstream; rule check có 0 lỗi và một cảnh báo wrapper có chủ ý. Wrapper chưa được mô phỏng hoặc nối vào cluster core; CMO theo line còn thiếu. Chưa thể xem đây là xác minh đầy đủ LLC hay cluster.

At the pinned Culsans revision, the submodule entries include PlanV CVA6 `338d4c1e8df55363a57ac3e936ffc6ce86e7e016` and PlanV AXI LLC `39355b975eb9618761e40711e299d19a8833f5cd`. The CVA6 commit is present here for interface comparison; neither fork has been accepted as the cluster baseline.

For each modified upstream module, keep the pristine source in its original repository directory and create the modified copy under `rtl/common/modified/`. Preserve copyright/SPDX notices and add a clear modification notice required by the applicable license. New VLSIT modules belong under `rtl/common/vlsit/` and must follow the local VLSIT RTL rule.

Before tapeout or distribution, review the license of every file actually present in the synthesis filelist, including vendored dependencies. Repository-level license metadata is not a substitute for that file-level audit.
