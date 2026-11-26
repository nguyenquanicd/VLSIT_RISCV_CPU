# Project tools / Công cụ dự án

See [layout and replay commands](../PROJECT_LAYOUT.md). / Xem cấu trúc và lệnh chạy tại liên kết trên.

# Cluster build and checking scripts
# Script tạo tài liệu, RTL và kiểm tra cluster

These Python 3 scripts build specification diagrams, generate selected RTL boundaries,
and run scoped RTL checks. The specification remains the design authority.
Standalone lint does not establish full-cluster correctness. / Các script Python 3
tạo sơ đồ, sinh một số biên RTL và chạy kiểm tra theo phạm vi. Đặc tả vẫn là nguồn
chuẩn; lint từng khối không chứng minh tính đúng đắn của toàn cluster.

## Scripts / Các script

| Script | Function / Chức năng |
|---|---|
| `gen_cluster_axi_top.py` | Generates the AXI cluster top and connects the cluster core to the parameterized external-memory width adapter. / Sinh AXI cluster TOP và nối cluster core với adapter độ rộng memory ngoài có parameter. |
| `run_cluster_top_lint.py` | Runs Verilator on the complete AXI cluster top at 2 or 4 harts, captures the native exit code, and stops at a configurable timeout. / Chạy Verilator trên AXI cluster TOP đầy đủ ở 2 hoặc 4 hart, thu exit code native và dừng khi hết timeout cấu hình. |
| `gen_tile_coh_adapter.py` | Generates the ownership/grant elastic boundary and transparent probe paths; refuses to overwrite an existing output. / Sinh adapter xin/cấp quyền và probe; không ghi đè file đã có. |
| `lint_cluster_mmio.py` | Lints the MMIO mux with pinned upstream dependencies for 2/4 harts. / Lint MMIO với dependency đúng pin cho 2/4 hart. |
| `lint_axi_region_route.py` | Lints the per-tile AXI region router against pinned PULP AXI sources at MaxTrans 1/8/32. / Lint router AXI từng tile với source PULP đã pin ở MaxTrans 1/8/32. |
| `lint_cmo_tile.py` | Lints standalone CMO and tile adapter for 2/8/16 context sizes and applicable hart counts. / Lint CMO và adapter ở các cấu hình context/hart. |
| `lint_modified_cva6_cache_path.py` | Lints modified CVA6+HPDcache subsystem; `--top-module hpdcache_query_lint` runs the faster configured HPDcache query-path check. / Lint subsystem CVA6+HPDcache đã sửa; tùy chọn trên chạy kiểm tra query HPDcache nhanh hơn. |
| `integrate_coh_v019.py` | One-time v0.19 integration migration; preserves a baseline and refuses a repeat migration. / Migration v0.19 một lần, lưu baseline và chặn chạy lặp. |
| `build_cluster_diagram.py` | Builds the editable level-1 cluster architecture from the architecture document. / Tạo sơ đồ kiến trúc cluster cấp 1 có thể chỉnh sửa từ tài liệu kiến trúc. |
| `build_cluster_detail_diagrams.py` | Expands seven subsystems by one level, records each block's planned source/status/function, writes editable draw.io pages, and runs library/geometry checks. / Phân rã bảy subsystem thêm một cấp, ghi nguồn/trạng thái/chức năng dự kiến của từng khối, tạo trang draw.io và chạy kiểm tra thư viện/hình học. |
| `render_cluster_preview.py` | Renders the level-1 topology as SVG and local HTML. / Kết xuất topology cấp 1 thành SVG và HTML cục bộ. |
| `render_cluster_detail_previews.py` | Renders one SVG topology preview for each level-2 draw.io page. / Kết xuất một ảnh SVG cho mỗi trang draw.io cấp 2. |

The level-2 diagrams are architectural proposals because no integrated cluster
RTL tree is pinned. `REUSE*` means candidate reuse pending version and interface
checks; `MODIFY` means adaptation/wrapper/memory binding; `NEW` means VLSIT RTL
to design; `GENERATED` means CSR RTL from the approved workbook. / Sơ đồ cấp 2
là kiến trúc đề xuất vì chưa chốt cây RTL cluster đã tích hợp. `REUSE*` là khối
dự kiến tái sử dụng sau khi kiểm tra version/giao diện; `MODIFY` là phần điều
chỉnh/wrapper/gắn memory; `NEW` là RTL VLSIT cần thiết kế; `GENERATED` là RTL
CSR sinh từ workbook được duyệt.

## Build level-2 pages / Tạo sơ đồ cấp 2

Run from the project root. The builder requires Python 3 and the installed
VLSIT RTL hierarchy-diagram library and scripts at
`C:\Users\PC\.codex\skills\vlsit-rtl-hierarchy-diagram`. / Chạy từ thư mục gốc
dự án. Builder cần Python 3 và thư viện/script VLSIT RTL hierarchy-diagram đã
cài tại đường dẫn trên.

```powershell
python scripts/build_cluster_detail_diagrams.py --analyze-only
python scripts/build_cluster_detail_diagrams.py
python scripts/render_cluster_detail_previews.py
```

Editable pages, the combined seven-page diagram, SVG previews, JSON specs, and
validation report are written to
`doc/specification/figures/detail_level2/`. The validation checks template
provenance, routing completeness, and geometric rules; it does not prove RTL
behavior or protocol compliance. / Trang có thể chỉnh sửa, sơ đồ gộp bảy trang,
ảnh SVG, JSON spec và báo cáo kiểm tra được lưu tại
`doc/specification/figures/detail_level2/`. Kiểm tra xác nhận nguồn template,
đường nối và quy tắc hình học; không chứng minh hành vi RTL hay tính tuân thủ
protocol.

## Level-1 tools / Công cụ cấp 1

```powershell
python scripts/build_cluster_diagram.py --seed 2 --gap-v 140
python scripts/render_cluster_preview.py
```

## Full AXI TOP lint / Lint AXI TOP đầy đủ

Run either command from the project root. A timeout or interrupted process is
not a lint pass; inspect the timestamped log and native exit code. / Chạy một
trong hai lệnh từ thư mục gốc dự án. Timeout hoặc tiến trình bị ngắt không phải
lint pass; kiểm tra log có timestamp và native exit code.

```powershell
python scripts/run_cluster_top_lint.py --hart-count 2
python scripts/run_cluster_top_lint.py --hart-count 4 --timeout 420
powershell -NoProfile -ExecutionPolicy Bypass -File rtl/reports/full_integration/run_top_lint.ps1 -HartCount 4
```

The lint uses `-Wno-fatal`; warning review remains a separate sign-off task.
It does not prove functional integration, synthesis, or PPA. / Lệnh lint dùng
`-Wno-fatal`; rà soát warning vẫn là bước sign-off riêng. Kết quả không chứng
minh tích hợp chức năng, synthesis hoặc PPA.
