# rtl/coherence_cluster — External ACE profile (reserved) / Profile ACE bên ngoài (dự phòng)

Reserved for a future TOP that would make the cluster coherent with agents outside it through AMBA ACE. **Not implemented**: the folder intentionally contains no RTL, only a placeholder `filelist.f`.

Dành cho một TOP tương lai, giúp cluster coherence với agent bên ngoài qua AMBA ACE. **Chưa triển khai**: thư mục cố ý không chứa RTL, chỉ có `filelist.f` giữ chỗ.

## Notes / Lưu ý

- Do not use this folder in a build. The product TOP is [`rtl/non_coherence_cluster`](../non_coherence_cluster/). / Không dùng thư mục này để build.
- An ACE TOP would be a separate fixed-port module and needs its own specification and approval; there is no run-time switch between profiles (HDS Section 1.1, OPEN-ACE-MAP).
- The comment in `filelist.f` points to `doc/rtl_layout/README.md`, which no longer exists; the layout is described in [doc/PROJECT_LAYOUT.md](../../doc/PROJECT_LAYOUT.md). / Comment trong `filelist.f` trỏ tới file không còn tồn tại.
