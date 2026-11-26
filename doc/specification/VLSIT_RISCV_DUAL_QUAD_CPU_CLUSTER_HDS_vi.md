# Bản dịch tiếng Việt kèm theo — Đặc tả cluster CPU RISC-V 2/4 hart VLSIT

Tài liệu này giữ các đoạn tiếng Việt đã tách khỏi `VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md` ngày 2026-11-21, nhóm theo tiêu đề mục. Bản tiếng Anh là bản chuẩn; khi hai bản khác nhau thì theo bản tiếng Anh.

This companion keeps the Vietnamese paragraphs that were split from the English specification on 2026-11-21, grouped by section heading. The English file is normative.

## VLSIT RISC-V Dual/Quad CPU Cluster Design Specification

# Đặc tả chi tiết cluster CPU RISC-V 2/4 hart VLSIT

Bản này hợp nhất hợp đồng thiết kế, cách RTL hiện thực và trạng thái verify; không biến source đang có thành bằng chứng thiết kế đúng. Có sơ đồ TOP/từng component, chức năng, interface, FSM và data flow. Các mâu thuẫn/phần chưa verify ghi ở Section 20; không sửa RTL hoặc map CSR.

## 1.1 Purpose and scope

Giai đoạn RTL hiện tại gồm cluster CVA6 hai hoặc bốn hart, coherence MESI cho D-cache, LLC chia sẻ tĩnh, biên bộ nhớ PULP AXI4 với mở rộng AWATOP, ngoại vi AXI4 không coherence, AXI4-Lite có bridge RegBus cho LLC, PMU và debug từng hart. Profile ACE coherence với agent ngoài là phần mở rộng tương lai, chưa thuộc hierarchy/port plan hiện tại.

Giai đoạn hiện tại có một top cấu trúc AXI. Top này đưa traffic bộ nhớ AXI4 thông thường và không snoop agent ngoài. Nếu bổ sung top ACE trong tương lai, top đó phải là module cổng cố định riêng và cần đặc tả/phê duyệt riêng; không có chuyển profile lúc chạy.

## 1.2 Deployment assumptions

Ứng dụng dự kiến là gateway công nghiệp chạy Linux SMP để lọc gói, xử lý giao thức và dịch vụ bảo mật. Đây là ứng dụng đề xuất vì người dùng chưa cung cấp sản phẩm/workload cụ thể. Library ASIC, SRAM macro và số liệu workload thực tế do tích hợp SoC cung cấp.

## 1.4 Real-world applications of the features

Các giá trị dưới đây là cấu hình đề xuất của đặc tả, không phải giới hạn workload đã đo. Chủ hệ thống cần thay thế khi có workload sản phẩm.

## 2.2 Source-of-truth and conflict handling

Protocol tuân thủ theo REF-001. Hành vi core theo cấu hình CVA6 và commit sẽ được pin. Yêu cầu sản phẩm theo đặc tả này và quyết định của người dùng. REF-003 áp dụng cho RTL VLSIT mới; mã nguồn bên thứ ba giữ license và coding convention riêng, không tự sửa. Workbook ở Mục 11 là nguồn duy nhất cho CSR. Tài liệu ACE được duyệt dùng bản PDF chính thức trên web, chưa chuyển đổi cục bộ; cần kiểm soát tài liệu trước signoff.

## 3.2 Requirement change control

Nếu thay core package, line size, memory profile, CSR behavior hoặc tập ACE hỗ trợ thì phải tăng version và rà soát truy vết. Yêu cầu phụ thuộc adapter chưa được chứng minh sẽ giữ trạng thái có điều kiện, không được hiểu là adapter đã tồn tại.

## 4. Features and configurations

Hai profile bộ nhớ là các top module riêng có port list cố định: top AXI có AXI4 memory và không có cổng snoop ACE; top ACE có một ACE memory và không có AXI memory song song. AXI4 MMIO và AXI4-Lite có trong cả hai. Cấu hình số hart chỉ đổi số tile synthesis; vector interrupt/debug luôn rộng bốn bit, bit 3:2 không dùng khi build hai hart.

## 5.1 Overview and block responsibilities

Phiên bản hiện tại là profile AXI. Hai/bốn hart có I-cache riêng và HPDcache D-cache write-back đã sửa. CCU VLSIT quản lý coherence của D-cache bằng directory và probe có tag. I-cache không snoop; phần mềm phải thực hiện `FENCE.I` tại từng hart chạy code mới. Không mô tả CCU mới là RTL Culsans reuse nguyên trạng.

## 5.2 Block diagram

*Hình 5-2. Sơ đồ đầy đủ các module con trực tiếp của cluster core. Tab thông tin ghi chức năng, trạng thái nguồn và các giao tiếp được minh họa. Cấu trúc tile, CCU và cache nằm trong các sơ đồ chi tiết ở Section 14.*

Mỗi component có sơ đồ trong Section 14, kèm draw.io chỉnh sửa được và JSON. Hình phân cấp không tự suy ra liên kết dữ liệu; các luồng được mô tả riêng dưới đây. Diagram không thay bằng chứng mô phỏng.

## 5.3 Transaction and dataflow

Luồng dirty data đi qua AXI hiện có của owner đến LLC, không đi qua payload của CCU. Mọi thao tác có completion phải chờ completion thật, không hoàn tất ngay khi nhận request. Các bước trên xác định thứ tự, không đặt latency chưa đo.

## 5.5 Component provenance

NEW là logic mới; MODIFY là bản native có sửa và history; REUSE giữ nguyên source; GENERATED là output generator không sửa tay. Không đánh đồng có tên trong filelist với đã instantiate hoặc đã kích hoạt trong mô phỏng.

## 6.1 Interface inventory

Profile ACE ngoài được hoãn. AXI ngoài không snoop cache. Các kênh tagged PREPARE/COMMIT/ABORT hiện tại là interface nội bộ có định nghĩa riêng; không tuyên bố chúng tương thích chân ACE chỉ từ tên kiến trúc ban đầu.

## 6.4 Interrupt and debug obligations

IRQ PMU có thể xóa qua CSR theo đúng priority. Fault fatal chỉ phục hồi bằng reset. Trì hoãn IRQ/debug khi CMO đã nhận là quyết định đã duyệt; không được hứa bound hữu hạn khi chính sách ACK không timeout.

## 7.3 Reset domains and sequencing

Reset controller giữ IP reset tới khi CLK-CLUSTER ổn định. Software chờ trạng thái BIST-ready của axi_llc trước khi dùng memory path bị BIST chặn. Reset hủy transaction đang chạy theo hợp đồng reset AXI/ACE của SoC; SoC phải reset hoặc drain các agent ngoài nhất quán.

## 7.4 Power intent

Không có power gating, retention, isolation hoặc DVFS trong v1. Có thể dùng clock gating theo cell/methodology đã duyệt của công nghệ sau khi có clock/reset và scan flow. Hành vi WFI phải đối chiếu với CVA6 commit được pin. SoC sở hữu power intent.

## 8.2 Address arrays, identity and line representation

Phải phân biệt native ID, ID sau mux, tag CCU và tag endpoint; không dùng một độ rộng cho mọi boundary.

## 8.3 Các cấu hình pipeline

[HDS §8.3](VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md#83-compile-time-timing-profiles) chứa sơ đồ, vị trí cắt và công thức đếm thanh ghi theo RTL.

| Cấu hình | Vị trí cắt và tác động | Bit trạng thái thêm, 2 / 4 hart |
|---|---|---:|
| 0 — Baseline | Kết nối trực tiếp tại router và AXI TOP. Directory đọc và so sánh trong cùng chu kỳ. | 0 / 0 |
| 1 — Tile cuts | Cắt năm kênh AXI ở từng ngõ memory/MMIO của router. Thêm một chu kỳ mỗi lần qua cut khi không stall. PMU có thanh ghi trước bộ đếm. | 5.843 / 5.843 khai báo trong RTL |
| 2 — Boundary cuts | Cắt memory sau bộ đổi độ rộng, MMIO sau mux cuối. Thêm một chu kỳ mỗi lần qua AXI cut và một chu kỳ cho lookup directory; PMU và nhả reset có thêm thanh ghi riêng. LLC hit không qua memory cut tại TOP. | 3.846 / 3.960, gồm thanh ghi đọc RAM mô hình |

Số liệu dùng memory AXI 64 bit, 16 bộ đếm PMU và 8 context coherence. Profile 1 khai báo bốn router ở cả hai cấu hình. Synthesis có thể loại logic của hai router không dùng ở cấu hình 2 hart. Lượt đọc AXI qua một cặp cut AR/R thêm hai chu kỳ nếu không stall. Mỗi kênh vẫn có thể truyền một beat mỗi chu kỳ sau khi đầy pipeline và hai đầu tiếp tục truyền. IPC và tần số thực tế cần được đo theo workload và STA.

## 9. Data representation and arithmetic

Mọi tín hiệu là vector unsigned theo rule VLSIT; byte lane theo little-endian. Không dùng signed arithmetic trong RTL. Khi counter 64 bit, phần mềm yêu cầu snapshot trước, rồi low/high biểu diễn cùng giá trị đã chụp.

## 10.1 Modes and state transitions

Đây là các FSM enum thực; chờ đúng handshake/completion, không đặt latency giả.

## CMO-CONTROLLER

Điều kiện chưa thỏa giữ state theo FSM đầy đủ; điểm vào phase không phải reset state mới.

## CCU-CONTEXT

Điều kiện chưa thỏa giữ state theo FSM đầy đủ; điểm vào phase không phải reset state mới.

## HPD-PROBE

Điều kiện chưa thỏa giữ state theo FSM đầy đủ; điểm vào phase không phải reset state mới.

## AXIL-REGBUS

Điều kiện chưa thỏa giữ state theo FSM đầy đủ; điểm vào phase không phải reset state mới.

## HPD-MISS-PERMISSION

Điều kiện chưa thỏa giữ state theo FSM đầy đủ; điểm vào phase không phải reset state mới.

## HPD-FLUSH-CAPTURE

Điều kiện chưa thỏa giữ state theo FSM đầy đủ; điểm vào phase không phải reset state mới.

## CCU-LOOKUP-VICTIM

Điều kiện chưa thỏa giữ state theo FSM đầy đủ; điểm vào phase không phải reset state mới.

## CCU-PREPARE-CMO

Điều kiện chưa thỏa giữ state theo FSM đầy đủ; điểm vào phase không phải reset state mới.

## CCU-COMMIT-RELEASE

Điều kiện chưa thỏa giữ state theo FSM đầy đủ; điểm vào phase không phải reset state mới.

## CCU-ABORT-RELEASE

Điều kiện chưa thỏa giữ state theo FSM đầy đủ; điểm vào phase không phải reset state mới.

## 10.2.3 System-wide Zicbom maintenance

**Tính đúng đắn và hình học directory.** Lookup dùng địa chỉ cache-line vật lý và trả bitmap holder theo hướng bảo thủ. Directory độc lập, không bao hàm trong LLC. Cấu hình có tám way và bốn bank. Tổng số set trên bốn bank là 512 ở cấu hình hai hart và 1.024 ở cấu hình bốn hart, tương ứng 4.096 và 8.192 entry; mỗi bank có 128 hoặc 256 set. Bank được chọn bằng hai bit thấp nhất của địa chỉ line; với line 16 byte, `line_addr[1:0] = physical_address[5:4]`, không phải bit địa chỉ vật lý `[1:0]`. Mỗi bank cấp tối đa một thao tác đủ điều kiện mỗi chu kỳ bằng bộ phân xử round-robin trên các slot transaction đang hoạt động; sau mỗi lần cấp, con trỏ chuyển sang slot kế tiếp. Các bank khác nhau có thể tiến song song, còn xung đột cùng bank được phân xử công bằng theo thứ tự vòng. Mỗi set lưu bảy bit tree-PLRU, khởi tạo bằng 0; khi lần theo cây chọn victim, bit 0 chọn nhánh trái và bit 1 chọn nhánh phải. Access/cấp phát đã commit cập nhật từng bit trên đường đi để trỏ ra xa way vừa truy cập. Trước khi dùng PLRU, chọn way invalid có index thấp nhất; nếu cả tám way hợp lệ thì lần theo bảy bit từ gốc tới lá. Nếu victim đang bị khóa/đặt trước hoặc chưa lấy được transaction context, request vẫn chờ và thao tác đủ điều kiện khác trong bank có thể tiếp tục. Bitmap holder chỉ được set khi cache grant commit và chỉ được clear sau khi transition cache tương ứng commit. Holder thừa có thể gây probe dư nhưng không được bỏ sót holder. LLC eviction không được invalidate D-cache riêng hoặc xóa entry directory. Khi thay set, giữ entry victim cho tới khi mọi holder được prepare để invalidate, dữ liệu M được LLC chấp nhận và mọi invalidate cache đã commit; sau đó mới tái sử dụng way. Không được làm mất holder hoặc dirty data khi thay thế.

Giao thức hiện tại chỉ coherence các D-cache; I-cache không nhận probe. Directory độc lập với LLC, có 8 way và 4 bank: 4.096 entry cho hai hart, 8.192 entry cho bốn hart. Mỗi bank xử lý tối đa một thao tác lookup/update mỗi chu kỳ; bank khác có thể tiến đồng thời. `PARA_COH_TXN_NUM` mặc định 8, cho phép 2–16 context; tag là chỉ số slot và không được tái sử dụng khi response cũ chưa kết thúc. PREPARE khóa line tại cache đích, chờ miss/refill cùng line hoàn tất và trả MESI hiện tại cùng status, không đổi trạng thái stable. Nếu line ở M, owner giữ M và line lock, ghi đủ 16 byte qua AXI writeback path HPDcache hiện có, rồi chỉ trả PREPARE completion sau B response tương ứng; probe không mang payload dữ liệu. Sau khi mọi PREPARE và writeback cần thiết thành công, COMMIT yêu cầu cache chuyển sang S hoặc I; cache trả ACK sau khi áp dụng. CCU chỉ commit directory, cấp quyền requester và nhả line lock sau mọi COMMIT ACK. Lỗi trước COMMIT phát ABORT và đợi toàn bộ ACK; cache giữ nguyên state trước transaction. Không phase nào có timeout ACK. Trong lúc chờ PREPARE ACK, CCU giữ line lock và transaction slot, không đổi directory, không gửi COMMIT và không cấp quyền requester. Lỗi trước COMMIT gửi ABORT tới mọi cache đích; CCU tiếp tục giữ lock và slot đến khi đủ ABORT ACK. Cache nhận ABORT nhả lock cục bộ và giữ stable MESI cũ. Sau khi COMMIT bắt đầu, không rollback; CCU giữ lock/slot, không đổi directory và không cấp quyền requester đến khi đủ COMMIT ACK. Thiếu ACK ở PREPARE, COMMIT hoặc ABORT có thể làm line bị chặn vô thời hạn. Line khác chỉ tiến khi dùng slot và tài nguyên độc lập. COMMIT lặp cùng tag là idempotent. Reset xóa valid state của cache riêng và directory.

Directory giữ bitmap holder bảo thủ theo physical cache line: bit thừa chỉ tạo thêm probe; thiếu holder bị cấm. Directory không inclusive với LLC; LLC eviction không xóa directory entry hoặc invalidate line ở L1. Khi thay entry directory đang có holder, phải PREPARE invalidate holder, ghi dữ liệu M cần thiết về LLC, COMMIT invalidation và chỉ sau đó mới dùng lại way. Probe response ghép theo (tag, hart index). Request cùng line bị khóa; line khác có thể tiến nếu không tranh chấp bank, cache array, MSHR, LLC hoặc AXI. Cấu hình không cam kết IPC hoặc latency cố định. Reset xóa valid state; muốn giữ memory qua reset, SoC/software phải quiesce và clean/flush trước. Với mã tự sửa đổi, phần mềm thông báo các hart liên quan và chạy `FENCE.I` trước khi thực thi code mới.

**Ví dụ 1 — Thiếu COMMIT ACK.** Trong cấu hình bốn hart, hart 0 và hart 1 giữ line X ở S, còn hart 2 yêu cầu M. PREPARE thành công với cả hai holder. CCU gửi COMMIT(I); hart 0 ACK nhưng hart 1 không ACK. Directory vẫn giữ bitmap bảo thủ `{hart 0, hart 1}`, hart 2 không được cấp quyền, còn line lock và transaction slot của X vẫn được giữ. Request line Y có thể hoàn tất qua slot trống khác nếu không xung đột tài nguyên directory, cache, LLC và AXI. Reset xóa valid state cache/directory và giải phóng context của X; software phải clean/flush trước warm reset nếu cần giữ dữ liệu dirty.

## 10.2.2 Coherence performance and IPC evaluation

IPC phải được đo: `IPC_hart = số lệnh đã retire của hart h / tổng chu kỳ clock`; `IPC_cluster = tổng lệnh retire của các hart hoạt động / cùng số chu kỳ`. Báo cáo thêm CPI từng hart, throughput workload, nhóm hit/miss D-cache, số lần S-to-M, số sharer mỗi transaction, probe wait, directory stall, mức sử dụng transaction table, số dirty-owner writeback và thời gian đợi B response, LLC hit/miss, AXI wait và số chu kỳ hai transaction line khác nhau cùng tiến triển. So sánh 2/4 hart với cùng chương trình, compiler, cache, mô hình AXI/DRAM, clock và thời gian chạy. Bao gồm private read nóng, cold miss, LLC hit/miss, producer-consumer, read-mostly, write ping-pong/false sharing, dirty owner và backpressure ngẫu nhiên. Báo cáo IPC từng hart và toàn cluster; không giả định IPC tăng tuyến tính theo số hart.

Trong cấu hình upstream đã chọn, `SuperscalarEn=0` và `NrCommitPorts=2`; không thể suy ra dual-issue hay 2 IPC chỉ từ `NrCommitPorts`. Chưa có mục tiêu IPC hoặc phần trăm tăng hiệu năng; cần build chạy được, benchmark đại diện và mô hình timing/bộ nhớ. PMU chỉ hỗ trợ đo sau khi chốt event dictionary; trước đó vẫn cần trace mô phỏng và performance model độc lập.

Tránh deadlock, bảo đảm tiến triển và stall xấu nhất

Lối thoát reservation directory

Lỗi CC-01 trong bản review là chờ vòng, không phải tuần tự hóa cùng set thông thường. T2 miss và đặt reservation trên một set. T1 đã hit một line khác trong set rồi gửi update. Update của T1 không đủ điều kiện khi T2 giữ reservation; tuy nhiên logic ưu tiên channel cũ để update bị chặn của T1 ngăn cancel hợp lệ của T2. T1 phải giữ `VALID` đến khi có `READY`, nên cả hai giao dịch đều không thể nhả set.

Hợp đồng directory trong phiên bản này:

1. Xác định điều kiện hợp lệ dựa trên bank, set, tag, chủ reservation và loại thao tác **trước** khi chọn request. Request không hợp lệ có thể vẫn giữ `VALID`, nhưng không được chiếm grant đã đăng ký, dùng lượt phân xử hoặc giữ cổng mảng directory.

2. Khi tag T2 giữ reservation của một set, lookup/update từ tag khác vào set đó không hợp lệ. Request sang set khác vẫn đủ điều kiện, theo giới hạn một thao tác mỗi chu kỳ của bank.

3. `UPDATE` hoặc `CANCEL` trước COMMIT của đúng chủ reservation là thao tác kết thúc và phải được phục vụ độc lập với update bị chặn của transaction khác. Nhận `CANCEL(T2)` chỉ xóa reservation T2, không đổi MESI hay holder. Update T1 vẫn giữ VALID và có thể được nhận sau khi reservation nhả. `UPDATE(T2)` commit trạng thái directory rồi nhả reservation.

4. Mỗi bank nhận tối đa một thao tác mỗi chu kỳ. Round-robin chỉ tăng sau thao tác được nhận và quay vòng qua các slot đủ điều kiện. Slot liên tục đủ điều kiện được chọn trong một vòng nếu bank liên tục nhận một thao tác mỗi chu kỳ. Bảo đảm phân xử không áp dụng khi response phía sau bị giữ hoặc reset đang hoạt động.

5. Producer chỉ được phát một terminal action cho mỗi reservation. Nếu owner đồng thời phát `UPDATE` và `CANCEL` cùng reservation, đây là lỗi giao thức: giữ nguyên directory và reservation, chốt diagnostic, chờ recovery cấp hệ thống; không tự đoán commit hay abort.

Thứ tự tài nguyên và đồ thị chờ

Đặt chỗ probe nguyên tử

Trình tự tiếng Việt: trước khi gửi PREPARE cho bất kỳ D-cache nào, scheduler xét toàn bộ mask hart đích. Chỉ cấp claim khi mọi slot đích đều rảnh hoặc đã thuộc cùng tag. Trong một cạnh clock, scheduler ghi cùng tag vào tất cả slot đích. Nếu một slot bận, transaction không giữ slot nào trong mask và chờ lần phân xử sau; context CCU và line lock riêng của transaction vẫn được giữ. Round-robin chọn giữa các context đủ điều kiện và chỉ tăng sau claim thành công.

Sau claim, từng cache có thể nhận và trả PREPARE độc lập. Scheduler giữ nguyên owner tag đến khi response COMMIT hoặc ABORT tương ứng thành công; thiếu ACK vẫn giữ claim vô thời hạn theo DEC-018. Claim có mask rời nhau vẫn có thể chạy chồng lấn; quy tắc này không tuần tự hóa toàn bộ cache.

Ví dụ: T0 và T1 cùng cần `{H2,H3}`. Nếu T0 thắng, H2 và H3 cùng giữ T0 trong một cạnh và chỉ gửi PREPARE của T0. T1 không giữ slot nào cho đến khi response terminal của T0 thành công; sau đó T1 claim cả hai slot. Cấu hình chia chéo `{H2:T0,H3:T1}` bị cấm. Với mask rời nhau `{H0}` và `{H3}`, hai claim có thể được cấp ở hai chu kỳ liên tiếp rồi chạy đồng thời.

Cam kết tiến triển có điều kiện. Giả định reset đã nhả, clock chạy, mỗi cache xử lý probe đang chờ, nguồn AXI cuối cùng thấy `READY` và mỗi AXI transaction được chấp nhận cuối cùng có response. Claim nguyên tử toàn bộ hart đích ngăn transaction giữ một phần slot probe; vì vậy không có vòng chờ qua các slot này, và round-robin công bằng không bỏ đói context liên tục đủ điều kiện claim. Context bị chặn bởi slot đích đang bận không giữ slot probe nào. Quy tắc không giải quyết việc ACK/AXI response bị mất: theo DEC-018, claim đã cấp, context và line lock vẫn được giữ vô thời hạn. Đặc tả **không** cam kết latency tối đa. Khi cả 8 context mặc định (hoặc 16 context tối đa) đều bị chiếm, miss/CMO cần CCU mới có thể dừng trên toàn cluster; L1 hit độc lập vẫn có thể chạy nếu không xung đột line/cache. Reset xóa valid state cache và có thể làm mất dữ liệu dirty, vì vậy reset không phải cách recovery an toàn để bảo toàn dữ liệu khi hệ thống đang chạy.

Giới hạn hiệu năng trong trường hợp xấu nhất

Để đo, phân rã miss theo `T_miss = T_dir_wait + T_probe_queue + T_prepare + T_owner_W/B + T_commit + T_LLC + T_external (nếu LLC miss) + T_refill`. Probe tới các hart khác nhau có thể chạy song song; target chậm nhất quyết định hoàn tất phase, còn probe trong cùng cache phải tuần tự. Công thức là mô hình phân tích, không phải hợp đồng cộng chu kỳ chính xác. Với độ rộng dữ liệu ngoài W và tần số f, tốc độ dữ liệu đỉnh là `W/8 × f` byte/s cho mỗi chiều. Băng thông thực tế bị giới hạn bởi giá trị nhỏ nhất giữa bus peak, tốc độ phục vụ LLC/cache, số line outstanding chia latency trung bình và khả năng memory của SoC. Bus 64-bit mang tối đa 8 byte dữ liệu mỗi beat; kênh đọc/ghi có thể hoạt động đồng thời nhưng không đảm bảo thông lượng tổng cụ thể.

## 10.3 Waveform plan

Người dùng đã duyệt 14 chủ đề waveform. WF-015 mô tả thiếu COMMIT ACK; WF-016/017 bổ sung thiếu PREPARE/ABORT ACK theo cùng hợp đồng không timeout ở mọi phase. Các hình thể hiện lock/slot được giữ, directory và quyền requester không đổi, line độc lập chỉ tiến khi tài nguyên cho phép, và reset để recovery. WF-002 mô tả tra directory, gửi probe tới holder, ghép trạng thái theo tag giao dịch và hart index, owner writeback qua AXI hiện có (hai beat W 64-bit), nhận B response, COMMIT, cập nhật directory rồi cấp shared. Tín hiệu probe là alias logic, không phải port RTL. Trình tự chỉ giải thích thứ tự; khoảng cách chu kỳ là minh họa, không cam kết latency/throughput.

WF-020 minh họa lối thoát CC-01: update T1 không đủ điều kiện vẫn giữ VALID; cancel T2 của chủ reservation bắt tay; reservation được xóa; sau đó update T1 có thể được nhận. Hình chỉ thể hiện thứ tự hợp đồng, không cam kết latency theo chu kỳ.

WF-022 là sơ đồ cận cảnh cùng luồng: UPDATE của T1 giữ VALID khi READY thấp; CANCEL của T2, chủ reservation, bắt tay độc lập; reservation được giải phóng; sau đó UPDATE T1 bắt tay. Các cột là pha sự kiện theo thứ tự, không phải chu kỳ clock hay cam kết latency.

WF-023 minh họa hai transaction cùng cần slot H2/H3: chỉ một tag được claim đồng thời ở cả hai hart; tag còn lại không giữ slot một phần, chờ transaction thắng hoàn tất COMMIT/ABORT rồi mới claim đủ mask. Các cột là pha sự kiện, không phải chu kỳ clock hay cam kết latency.

## 10.4 Timing boundaries

Không cam kết latency AXI/ACE cố định hoặc thời gian snoop tối đa. PREPARE, COMMIT và ABORT nội bộ đều không có timeout ACK: nếu thiếu ACK, line lock và transaction slot được giữ đến khi nhận đủ ACK hoặc reset cluster; trong thời gian chờ không cập nhật directory và không cấp quyền requester. Backpressure AXI/ACE được phép kéo dài nếu hợp đồng tích hợp không quy định giới hạn.

## 10.5.1 Cache hit, miss, refill and upgrade

Cache hit không có nghĩa luôn chạy song song với probe: CPU hit khác line chỉ tiếp tục nếu không tranh chấp tag/data array, replay, refill hoặc flush. Miss có thể chờ ownership và dữ liệu owner trước khi bắt đầu refill. Không dùng số transaction context để suy ra IPC tăng tương ứng.

## 10.6 Native non-enum lifecycles

Các lifecycle trên có trạng thái lưu giữ dù không dùng enum. Không tạo state giả để làm sơ đồ. Các nhánh native tùy chọn phải được verify theo cấu hình thực, không mặc nhiên PASS vì file được compile.

## 11.2 Software programming and use flow

VI: Dùng đúng field workbook; snapshot là lệnh riêng, done sticky cần phân biệt lệnh cũ/mới. Fault fatal chỉ phục hồi theo reset của SoC, không phải W1C. Trình tự phần mềm là hợp đồng mong muốn; PMU và native LLC service còn cần verify đầu-cuối.

## 11.4 Access and update behavior

VI: Dùng tên field thực trong workbook, không tự thêm prefix hoặc irq_inj. RO write không làm thay đổi dữ liệu; reserved/misaligned có response riêng. Snapshot done đang sticky đến W1C; mô tả auto-clear trong workbook chưa khớp RTL và được ghi rõ để review, không tự sửa hành vi.

## 12. Error handling and recovery

Lỗi precise chỉ báo sau cleanup/ABORT đúng thứ tự; lỗi eviction thông thường là fatal bất đồng bộ và giữ dữ liệu đến reset. Không dùng W1C để giả phục hồi cache. Không suy ra LLC hart owner từ giá trị zero.

## 13. Performance, power, and area

Chưa có cơ sở tuyên bố IPC, tần số hoặc công suất đạt mục tiêu. Phải đo đúng workload, SRAM/library/corner và điều kiện backpressure. Thêm context/bank/bit bus không tự bảo đảm throughput tăng tương ứng. ACK mất làm worst case không có bound hữu hạn theo quyết định đã duyệt.

## 14.1 Required coding baseline

Module, component và file source không đồng nghĩa; compile không chứng minh nhánh chức năng đã hoạt động.

## 14.3 Shared implementation rules and figure interpretation

Component mới và sinh tự động

## 14.4.1 `m_csr_async_fifo` — GENERATED

Module không có instance con nên không có sơ đồ phân cấp; hình một khối không thêm thông tin.

## 14.4.2 `m_csr_sync_fifo` — GENERATED

Module không có instance con nên không có sơ đồ phân cấp; hình một khối không thêm thông tin.

## 14.4.3 `m_vlsit_axi_llc` — NEW

Module không có instance con nên không có sơ đồ phân cấp; hình một khối không thêm thông tin.

## 14.4.4 `m_vlsit_axil_reg_bridge` — NEW

Module không có instance con nên không có sơ đồ phân cấp; hình một khối không thêm thông tin.

## 14.4.5 `m_vlsit_cpucl_csr` — GENERATED

Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

## 14.4.6 `m_vlsit_pmu_aggregate` — NEW

Module không có instance con nên không có sơ đồ phân cấp; hình một khối không thêm thông tin.

## 14.4.7 `m_vlsit_pmu_cluster_evt` — NEW

Module không có instance con nên không có sơ đồ phân cấp; hình một khối không thêm thông tin.

## 14.4.8 `m_vlsit_pmu_counter_bank` — NEW

Module không có instance con nên không có sơ đồ phân cấp; hình một khối không thêm thông tin.

## 14.4.9 `m_vlsit_pmu_event_select` — NEW

Module không có instance con nên không có sơ đồ phân cấp; hình một khối không thêm thông tin.

## 14.4.10 `m_vlsit_pmu_hart_evt` — NEW

Module không có instance con nên không có sơ đồ phân cấp; hình một khối không thêm thông tin.

## 14.4.11 `m_vlsit_pmu_irq` — NEW

Module không có instance con nên không có sơ đồ phân cấp; hình một khối không thêm thông tin.

## 14.4.12 `m_vlsit_pmu_snapshot` — NEW

Module không có instance con nên không có sơ đồ phân cấp; hình một khối không thêm thông tin.

## 14.4.13 `m_vlsit_riscv_addr_decode` — NEW

Module không có instance con nên không có sơ đồ phân cấp; hình một khối không thêm thông tin.

## 14.4.14 `m_vlsit_riscv_axi_dw_adapter` — NEW

Module không có instance con nên không có sơ đồ phân cấp; hình một khối không thêm thông tin.

## 14.4.15 `m_vlsit_riscv_axi_mem_mux` — NEW

Module không có instance con nên không có sơ đồ phân cấp; hình một khối không thêm thông tin.

## 14.4.16 `m_vlsit_riscv_axi_mmio` — NEW

Module không có instance con nên không có sơ đồ phân cấp; hình một khối không thêm thông tin.

## 14.4.17 `m_vlsit_riscv_axi_route` — NEW

Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

## 14.4.18 `m_vlsit_riscv_axil_decode` — NEW

Module không có instance con nên không có sơ đồ phân cấp; hình một khối không thêm thông tin.

## 14.4.19 `m_vlsit_riscv_cache_line_locks` — NEW

Module không có instance con nên không có sơ đồ phân cấp; hình một khối không thêm thông tin.

## 14.4.20 `m_vlsit_riscv_cluster_axi_top` — NEW

Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

## 14.4.21 `m_vlsit_riscv_cluster_core` — NEW

Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

## 14.4.22 `m_vlsit_riscv_cmo_arbiter` — NEW

Module không có instance con nên không có sơ đồ phân cấp; hình một khối không thêm thông tin.

## 14.4.23 `m_vlsit_riscv_cmo_controller` — NEW

Hình thể hiện các khối chức năng bên trong; module không có instance con nên các hộp là nhóm logic theo process, generate block và thanh ghi trong RTL, không phải module RTL mới.

## 14.4.24 `m_vlsit_riscv_coh_bank_arb` — NEW

Module không có instance con nên không có sơ đồ phân cấp; hình một khối không thêm thông tin.

## 14.4.25 `m_vlsit_riscv_coh_fabric` — NEW

Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

## 14.4.26 `m_vlsit_riscv_coh_tile_array` — NEW

Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

## 14.4.27 `m_vlsit_riscv_coh_txn_table` — NEW

Hình thể hiện các khối chức năng bên trong; module không có instance con nên các hộp là nhóm logic theo process, generate block và thanh ghi trong RTL, không phải module RTL mới.

## 14.4.28 `m_vlsit_riscv_cpu_tile` — NEW

Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

## 14.4.29 `m_vlsit_riscv_cpu_tile_array` — NEW

Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

## 14.4.30 `m_vlsit_riscv_fault_record` — NEW

Module không có instance con nên không có sơ đồ phân cấp; hình một khối không thêm thông tin.

## 14.4.31 `m_vlsit_riscv_hpd_probe_engine` — NEW

Hình thể hiện các khối chức năng bên trong; module không có instance con nên các hộp là nhóm logic theo process, generate block và thanh ghi trong RTL, không phải module RTL mới.

## 14.4.32 `m_vlsit_riscv_pmu` — NEW

Hình thể hiện phân cấp source; leaf chỉ có symbol ranh giới, không tạo module giả.

## 14.4.33 `m_vlsit_riscv_probe_scheduler` — NEW

Hình thể hiện các khối chức năng bên trong; module không có instance con nên các hộp là nhóm logic theo process, generate block và thanh ghi trong RTL, không phải module RTL mới.

## 14.4.34 `m_vlsit_riscv_sharer_directory` — NEW

Hình thể hiện các khối chức năng bên trong; module không có instance con nên các hộp là nhóm logic theo process, generate block và thanh ghi trong RTL, không phải module RTL mới.

## 14.4.35 `m_vlsit_riscv_tile_coh_adapter` — NEW

Hình thể hiện các khối chức năng bên trong; module không có instance con nên các hộp là nhóm logic theo process, generate block và thanh ghi trong RTL, không phải module RTL mới.

Hợp đồng source native đã sửa

Liệt kê mọi source MODIFY được chọn; package không phải module. Không restyle RTL reuse theo rule VLSIT.

## 14.7 Coherence deadlock fixes (DEC-046, DEC-047), merged 2026-11-27

Ba lỗi làm cluster deadlock khi 4 hart tranh chấp một dòng cache trong lúc một hart khác chạy cache maintenance (TEST-064, tương ứng TC-07 của profile RV32: hart 0 chạy CBO.CLEAN, CBO.FLUSH, CBO.INVAL rồi FENCE.I, trong khi hart 1–3 chạy AMOADD.W rồi đọc vòng trên một dòng dùng chung). Lỗi được phát hiện bằng testbench RV32 và tái hiện được trên cluster 64-bit. Đây là lỗi race theo thời điểm nên không chỉ xảy ra với 4 hart. File đã sửa nằm đúng vị trí gốc; bản trước khi sửa lưu ở `rtl/coherence_fix/pre_merge/`.

1. **AMO nhận quyền atomic khi chỉ có grant Shared** (`hpdcache.sv`, `hpdcache_ctrl.sv`).
   - *Lỗi:* AMO đang chờ nhận grant S rồi bật `atomic_permission_q`, nên từ chối mọi probe trên dòng. Nhưng AMO không thể chạy xong khi chỉ có S: nó phải xin quyền unique, và yêu cầu đó bị fabric xếp sau chính transaction mà nó đang chặn probe. Kết quả là deadlock.
   - *Sửa:* chỉ cấp quyền khi grant là E hoặc M; riêng LR vẫn được nhận S.
   - *Lý do:* đúng với dòng "S-to-M upgrade / AMO hit in S" của spec ("older probes may complete before that grant"). Cơ chế bảo vệ của DEC-038 vẫn giữ sau khi có grant E/M.
2. **Fence của RTAB tắt khi AMO vẫn còn trong hàng đợi** (`hpdcache_rtab.sv`).
   - *Lỗi:* phụ thuộc `pend_trans` của AMO vừa được xóa thì cache nhận một lệnh load cùng dòng và nối nó sau AMO. Sau đó AMO bị rollback để xin quyền unique và lại bị gắn `pend_trans`, rồi không bao giờ được xóa vì lệnh load phía sau không phải fence. Kết quả là deadlock.
   - *Sửa:* `fence_o` giữ mức 1 suốt lúc còn entry AMO, uncached hoặc CMO trong RTAB.
   - *Lý do:* đúng ý đồ của upstream ("all instructions following the fence need to wait"). Không thêm bộ nhớ, và không chặn refill, probe hay write-back.
3. **Một handshake của directory hoàn tất hai context** (`m_vlsit_riscv_coh_fabric.sv`).
   - *Lỗi:* context ở `DIR_UPDATE`/`DIR_CANCEL` rời trạng thái khi thấy handshake của bank mà không kiểm tra tag. Context thứ hai mất update directory (holder không được ghi nhận) và để lại reservation của set, nên lookup về sau (CMO của FENCE.I) bị chặn mãi.
   - *Sửa:* chỉ rời trạng thái khi handshake mang đúng tag của mình, giống quy tắc `RETRY_CANCEL` đang dùng.
   - *Lý do:* không thêm trạng thái hay thanh ghi, đồng thời loại bỏ rủi ro coherence do mất thông tin holder.

Kiểm chứng: lint sạch; testbench RV32 TC-01 đến TC-10 PASS với 2 và 4 hart; trên cluster 64-bit TC-04 đến 07, TC-09, TC-10 PASS; 36/36 lần chạy suite sẵn có (atomic, CMO, FENCE.I, directory holder) PASS, giống baseline; bản trước khi sửa vẫn treo. Assertion mới (kiểm tra tag khi rời DIR_UPDATE) báo lỗi trên fabric chưa sửa đúng chu kỳ xảy ra lỗi. Bằng chứng: `verification/rv32_profile/REPORT.md` mục 3c–3f.

## 15.1 Scope and strategy

Verification flow độc lập với RTL được sinh. Golden source là đặc tả này, RISC-V architectural spec/model đã pin, chuẩn/checker giao thức và reference model độc lập. RTL sinh ra chỉ là DUT. Các mức cần có: unit, protocol, coherence đa hart, tích hợp cluster, formal, CDC/RDC, lint, elaboration/synthesis và signoff physical.

## 15.3 Assertions and coverage

Cho store retire vào line dirty, gây eviction và trả lỗi writeback; kiểm tra dữ liệu/lock giữ lại, IRQ sticky, fault record CSR, nhận đủ response đã gửi, không tự retry/báo thành công, reset recovery và hành vi lỗi đồng bộ riêng của CBO/FENCE.I.

## 17.1 Timing constraints and budgets

Cluster có một clock domain đồng bộ. Chưa thể hoàn thiện SDC chạy được nếu thiếu period, waveform, latency, uncertainty, input/output delay, load, transition, PVT/RC và object name theo tool. SoC phải cung cấp các giá trị này trước STA. Không ngầm định false-path rộng hoặc multicycle chưa review.

## 20. Assumptions, dependencies, and decisions

Các quyết định cũ không phải bằng chứng trạng thái RTL hiện tại.

Người thiết kế chọn phương án fault bất đồng bộ cho eviction thông thường, thay cho mở rộng fault chính xác của store thông thường. Giữ dữ liệu/lock đến reset, thêm IRQ và CSR, tiếp tục nhận response đã gửi, không tự retry. Layout CSR, nối nguồn lỗi và waveform vẫn cần hoàn tất.

Người thiết kế chọn một bảng compile-time làm nguồn chung để tạo PMA CVA6 và decode router. Bộ chuyển đổi đưa class `00` vào cached-region của CVA6, class `10` vào non-idempotent-region; class `01` nằm ngoài cả hai danh sách để giữ thuộc tính idempotent/uncached. Giữ vùng cacheable CVA6 làm entry mặc định; SoC bổ sung normal-uncached/MMIO, không tự đoán địa chỉ. Ví dụ chỉ minh họa cách phân loại. Địa chỉ không khớp bị trả lỗi cục bộ, không phát AXI. Bảng có tối đa 16 entry; LLC hiện hỗ trợ một cửa sổ cacheable. Các vùng thật của SoC và tích hợp bảng vào PMA/router từng hart còn cần triển khai và kiểm chứng.

## 21. Glossary

table row: Lệnh Cache-Block Operation / thao tác Cache-Management Operation. CBO là lệnh RISC-V; CMO là thao tác phần cứng được yêu cầu.

table row: Ngoại lệ đồng bộ gắn với lệnh gây lỗi trước khi lệnh nghỉ hưu, giữ PC lệnh và địa chỉ hiệu dụng trong trạng thái trap.

table row: Máy trạng thái hữu hạn; logic điều khiển được mô tả bằng state có tên và transition có điều kiện.

table row: Điều kiện logic hoặc sự kiện handshake cho phép chuyển state.

table row: Chuyển có hướng giữa hai state, kèm điều kiện và hành động.

table row: Thao tác đủ điều kiện cuối cùng hoàn tất khi thỏa giả định công bằng và phản hồi môi trường; đây không phải cam kết latency hữu hạn.

table row: Request bị chặn ở đầu đường phân xử/response làm request đủ điều kiện phía sau không được nhận.

table row: Mô hình tài nguyên và transaction thể hiện chủ nào đang chờ tài nguyên/response nào; một vòng chờ báo nguy cơ deadlock.

table row: Adapter AXI đổi độ rộng dữ liệu và chuyển đổi beat, strobe, ID, response cùng loại burst được hỗ trợ.

table row: Khối điều khiển coherence; theo dõi và phối hợp ownership cache/probe.

table row: Truy cập ngoại vi qua bus có ánh xạ địa chỉ.

table row: Mux phân xử nguồn request; demux định tuyến giao dịch đến target.

table row: Bản ghi nội bộ mô tả thao tác cache line được tách từ giao dịch bus.

table row: Eviction ghi victim dirty ra; refill nạp line được yêu cầu vào.

table row: Ánh xạ giao diện memory tổng quát sang SRAM macro theo công nghệ.

table row: Trạng thái triển khai được định nghĩa tại Mục 14.3.
