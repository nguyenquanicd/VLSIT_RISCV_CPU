# Native CVA6 retirement experiment / Kiểm tra retirement CVA6 native

The licensed `rtl/common/modified/cva6/core/commit_stage.sv` now includes an external-CMO mode. It buffers a command with PC, original effective VA, translated line address and resolved opcode; keeps VALID/payload stable under arbiter backpressure; blocks CBO and younger retirement until terminal completion; suppresses interrupt/debug exceptions during the active command; retires a successful CBO once; and produces cause 7 with the retained effective address on error. A completion received while halted is retained until retirement resumes. PC remains at the CBO head for trap handling.

Bản sao commit stage có license hiện có chế độ external CMO: lưu metadata request, giữ VALID/payload khi backpressure, chặn retirement CBO/lệnh trẻ hơn, hoãn interrupt/debug trong thời gian chờ, retire thành công một lần hoặc phát cause 7 với VA gốc. Completion đến lúc halt được giữ đến khi tiếp tục retirement.

The registered local request buffer commits to servicing the CBO before it asserts external VALID; it does not withdraw VALID when an interrupt arrives during arbitration. Normal interrupt priority remains in effect before this local acceptance. This extends the approved policy A through request-buffer ownership and terminal retirement/fault.

Request buffer local nhận trách nhiệm phục vụ CBO trước khi phát VALID ra ngoài; không rút VALID khi interrupt đến trong lúc phân xử. Trước khi nhận vào buffer, interrupt vẫn theo ưu tiên bình thường. Quy tắc A áp dụng từ lúc buffer local sở hữu request tới retirement/fault cuối cùng.

Run `verification/common/cmo_metadata/run_regression.ps1 -Retirement`. The test uses the real CVA6 package/configuration and modified commit-stage source, with a simplified scoreboard record and modeled CMO completion. It passes older-store drain, stable command payload, delayed completion, blocked younger retirement, interrupt deferral, success, cause-7 error and retained completion during halt. Log: `retirement_sim.log`.

Test dùng package/cấu hình CVA6 thật và commit stage đã sửa; scoreboard record được rút gọn và completion CMO được mô hình hóa. Các check đã pass gồm chờ store cũ, giữ payload, completion trễ, chặn lệnh trẻ hơn, hoãn interrupt, thành công, lỗi cause 7 và giữ completion khi halt.

**Integrated path:** External CMO is enabled by the production cluster core. Real CVA6 instruction tests now exercise retirement, the shared arbiter/controller, CCU transaction contexts and native LLC per-line maintenance. Current results, limitations and replay commands are in [the end-to-end report](../cmo_end_to_end/README.md). The standalone test above remains useful for interrupt deferral and halt/completion races; it is not the source of the end-to-end claim.

**Đã tích hợp:** Cluster production đã bật external CMO. Test instruction CVA6 thật chạy qua retirement, arbiter/controller, context CCU và maintenance LLC native. Kết quả hiện tại và lệnh chạy lại nằm trong báo cáo đầu-cuối được liên kết ở trên. Test standalone vẫn kiểm tra hoãn interrupt và race halt/completion.

Store-buffer command: `run_regression.ps1 -ExternalStore`; log `store_buffer_external_sim.log`. This checks external dequeue bypass and the next entry after simultaneous retire/flush.
