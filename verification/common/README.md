# verification/common — Component testbenches and upstream test collateral / Testbench khối và tài nguyên test upstream

Unit-level testbenches for single VLSIT components, their recorded reports, and the verification files of the reused upstream projects.

Testbench mức khối cho từng component VLSIT, báo cáo đã ghi, và các file kiểm chứng của các dự án upstream được dùng lại.

## Component testbenches / Testbench từng khối

| Folder | DUT | Run / Chạy |
|---|---|---|
| `coherence/` | `m_vlsit_riscv_coh_fabric` | `run_regression.ps1`, `Makefile` |
| `coh_tile_array/` | `m_vlsit_riscv_coh_tile_array` | `run_regression.ps1`, `run_lint.ps1` |
| `tile_coh_adapter/` | `m_vlsit_riscv_tile_coh_adapter` | `build_and_run.ps1`, `Makefile` |
| `hpd_probe_engine/` | `m_vlsit_riscv_hpd_probe_engine` | `Makefile` |
| `hpdcache_ownership/` | HPDcache ownership request/grant path / Đường xin và cấp quyền của HPDcache | `tb_m_vlsit_riscv_hpd_ownership.sv` |
| `cmo_controller/` | `m_vlsit_riscv_cmo_controller` | `run_regression.ps1`, `run_mutation_check.ps1` |
| `cmo_metadata/` | CMO metadata through arbiter, CCU, LLC pending/tag, retirement, store unit / Metadata CMO qua các khối | filelists `filelist_*.f` |
| `addr_region_table/` | `m_vlsit_riscv_addr_decode` | `tb_m_vlsit_riscv_addr_decode.sv` |
| `axi_region_route/` | `m_vlsit_riscv_axi_route` | `tb_m_vlsit_riscv_axi_route_region.sv` |
| `axi_mem_mux/` | `m_vlsit_riscv_axi_mem_mux` | `tb_m_vlsit_riscv_axi_mem_mux.sv` |
| `axi_dw_adapter/` | `m_vlsit_riscv_axi_dw_adapter` | `tb_m_vlsit_riscv_axi_dw_adapter.sv` |

`reports/` keeps the recorded results of these testbenches and of earlier component checks (`cache_locks`, `cmo_tile`, `hpdcache_flush`, `mmio`, `lint_cleanup`, ...). Logs inside are ignored by Git.

`reports/` lưu kết quả đã ghi của các testbench này và các lần kiểm tra khối trước đó. Log bên trong không commit.

## third_party/

Verification files of the reused upstream projects (CVA6 `verif/` and `corev_apu/`, Culsans tests, HPDcache testbench, common_cells and AXI tests, ...), kept next to the RTL copies in `rtl/common/third_party/`. They are reference material: the cluster regressions do not use them.

Các file kiểm chứng của dự án upstream được dùng lại, đặt cạnh bản RTL trong `rtl/common/third_party/`. Đây là tài liệu tham khảo; regression của cluster không dùng chúng.

## Notes / Lưu ý

- These testbenches check one block against its specification; integration behavior is covered by `verification/non_coherence_cluster/` and `verification/rv32_profile/`. / Testbench khối không thay cho kiểm chứng tích hợp.
- The 2026-11-27 fabric fix (DEC-047) changes `m_vlsit_riscv_coh_fabric`; `coherence/` was not rerun after it. / Testbench `coherence/` chưa chạy lại sau bản sửa fabric.
- Keep upstream license headers in `third_party/`; licenses are in `project_support/licenses/third_party/`.
