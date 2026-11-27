# verification/work — Local scratch area / Thư mục làm việc tạm

Scratch space for tool runs. Its only content, `legacy/`, holds old tool outputs (simulator logs, databases and a browser preview cache under `.test_tmp/`). Everything in it is ignored by Git; only this README is tracked.

Thư mục tạm cho các lần chạy tool. Nội dung duy nhất, `legacy/`, chứa output cũ của tool (log mô phỏng, database và cache xem trước trình duyệt trong `.test_tmp/`). Mọi thứ bên trong đều bị Git bỏ qua; chỉ README này được track.

## Notes / Lưu ý

- No regression or report depends on this folder; it can be emptied at any time. / Không regression hay báo cáo nào phụ thuộc thư mục này; có thể xóa nội dung bất cứ lúc nào.
- Do not put evidence that a report links to here: it is not committed. / Không đặt bằng chứng mà báo cáo cần dẫn tới vào đây, vì không được commit.
