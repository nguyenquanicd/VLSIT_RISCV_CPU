# A-03 implementation plan / Kế hoạch triển khai

Authorized by the user's A-03 instruction and DEC-036. Keep original licenses; modified copies only. / Được yêu cầu A-03 và DEC-036 cho phép; chỉ sửa bản sao giữ license.

1. HPDcache controller: retain the existing stage-2 replacement context and resident dirty victim until the native writeback returns OKAY. Emit the writeback allocation once. Gate directory mutation and MSHR allocation; preserve stage-2 payload during waits. Match full line at completion. A failed B leaves the context and line exclusion until reset. Refills already in flight may drain.
2. Controller PE: pause admission/replay while that writeback is unresolved; retain the existing refill-priority path. Include the victim and pending replacement in the probe busy query.
3. Top HPDcache: forward native origin-00 B error. Cluster core adds a reset-only fatal source so software W1C cannot clear the fatal IRQ. Existing diagnostic CSR receives that source continuously. No new external port or auto-retry.
4. Verification: real CPU conflict misses force ordinary L1 eviction; inject delayed OKAY/SLVERR/DECERR at L1→LLC, check retained tag/dirty/data, no premature refill, no retry, sticky IRQ, response draining and reset recovery. Replay all atomic/CBO/FENCE.I cases and strict TOP lint for 2/4 harts.

Performance: one native stage-2 ordinary eviction waits for the B round trip; new controller requests pause, but previously issued refill responses retain priority. A failed context blocks this hart's controller until reset. Peer caches/fabric remain independently clocked; shared-resource forward progress still depends on their transactions and the existing CCU limits. Detailed fault-address CSR remains A-06, not hidden as A-03 closure.


Scope extension required by the four-hart directed test: modify the licensed `axi_llc_tag_store.sv` copy to backpressure all misses at pending-table capacity, including clean misses. Its previous dirty-only check allowed ring overwrite after A-02 began tracking every miss. Add clean/full-ring and oldest-completion escape to `tb_llc_pending.sv`. This preserves existing capacity/ordering semantics and adds no user-selectable behavior.

Mở rộng cần thiết từ test 4 hart: sửa guard full của bảng pending LLC cho mọi miss, thêm test clean/full và completion escape. Không đổi capacity, port hay cấu hình đã duyệt.
