# FENCE.I end-to-end verification / Kiểm chứng FENCE.I đầu-cuối

**EN:** Implements directed TEST-041/042 from REQ-MEM-018, DEC-030/031. Every active hart executes real RV64 instructions: prime old code, store a new instruction through D-cache, execute FENCE.I, then execute the new instruction. Error tests inject one L1→LLC AXI B SLVERR per hart, check ABORT-before-cause-24, enter a software handler and retry with MRET/SRET. Both M-mode and delegated S-mode are tested. No code coverage target was requested.

**VI:** Kiểm tra TEST-041/042 bằng instruction RV64 thật trên từng hart: chạy mã cũ, ghi instruction mới qua D-cache, chạy FENCE.I rồi thực thi mã mới. Test lỗi chèn một B SLVERR trên đường L1→LLC cho mỗi hart, kiểm tra ABORT hoàn tất trước cause 24, sau đó handler trả về bằng MRET/SRET để retry. Kiểm tra cả M-mode và S-mode có delegation. Không đo code coverage.

## Replay / Chạy lại

Use the single replay Makefile in `../cmo_end_to_end`:

```powershell
cd C:\HQuan\102_MyGithub\VLSIT_RISCV_CPU\rtl\verification\cmo_end_to_end
make fence
```

**EN:** `fence2` / `fence4` build fresh models; `fence-error2/4` and `fence-s2/4` reuse those binaries. `lint2/4` lint the production TOP. `retirement` tests completion retention and interrupt deferral directly. All commands are recorded in that Makefile. Logs and VCD traces are in `rtl/reports/fence_i_end_to_end`.

**VI:** `fence2` / `fence4` build model mới; các target lỗi và S-mode dùng lại binary đó. `lint2/4` kiểm tra TOP sản phẩm. `retirement` kiểm tra giữ completion và hoãn interrupt. Mọi lệnh nằm trong Makefile trên. Log và VCD nằm trong `rtl/reports/fence_i_end_to_end`.

## Verification boundary / Phạm vi

**EN:** The production cluster, CVA6, HPDcache, CCU and native LLC execute normally. A verification-only wrapper changes the selected native LLC B response to SLVERR after the write is accepted. It does not force CPU instructions, cache states, completion or ACK signals. The native wrapper copy preserves its production header and is refreshed by the runner. This models an AXI error that may have write side effects; the L1 must still preserve its dirty owner until ABORT. Success tests reject any external-memory AW and verify old-code → new-code execution. The legal simulation LLC is reduced to 4 KiB; production TOP lint uses the default 256 KiB.

**VI:** Cluster, CVA6, HPDcache, CCU và LLC thật chạy bình thường. Wrapper chỉ đổi B response đã chọn thành SLVERR sau khi LLC nhận ghi; không ép instruction, trạng thái cache, completion hoặc ACK. LLC vẫn có thể đã nhận dữ liệu khi trả lỗi AXI; L1 phải giữ dirty owner đến ABORT. Test thành công cấm external-memory AW và kiểm tra thực thi mã cũ → mã mới. LLC mô phỏng giảm còn 4 KiB; lint TOP dùng mặc định 256 KiB.

**EN:** Twenty exercised AXI checks cover the L1→LLC path; maintenance state/order checks cover PREPARE M, ABORT M, COMMIT E, retirement hold, trap PC/line address, handler retry, and I-cache invalidation. This is directed functional evidence, not full protocol, Linux, PPA or signoff verification.

**VI:** Có 20 kiểm tra AXI trên đường L1→LLC cùng kiểm tra PREPARE M, ABORT M, COMMIT E, giữ retirement, PC/địa chỉ lỗi, retry và invalidate I-cache. Đây là kiểm chứng chức năng có định hướng, chưa phải signoff giao thức, Linux hoặc PPA.
