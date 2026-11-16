# L1 eviction retention / Giữ dữ liệu eviction L1

## English

TEST-050 / REQ-ERR-003 / DEC-036. Real CVA6 instructions fill eight ways of one L1 set with two known dirty 64-bit words per line, then load a ninth conflicting line. Each hart uses a different set. A separate older miss is delayed to exercise refill draining while ordinary eviction waits.

The native production TOP and LLC run unchanged except the production fixes. A verification-only LLC shim delays B by 96 cycles and returns one selected SLVERR or DECERR per hart after the native LLC accepts the write. This tests retention even when a target may have partially accepted data. The shim does not force cache state, CPU responses or retirement.

The bench reads actual native SRAM arrays and selected victim tags without writing them. It compares full tag/dirty/data and original miss metadata during the wait/error interval, checks no early MSHR allocation or retry, requires the older refill to complete, checks asynchronous IRQ and the existing diagnostic CSR through AXI4-Lite, attempts W1C, then resets only the public reset input. A fresh program run must complete without injected errors. Initial data loads and the final ninth-line result have independent expected values from the program generator.

From the repository root:

```powershell
python rtl/verification/l1_eviction_end_to_end/run.py --harts 2 --jobs 2
python rtl/verification/l1_eviction_end_to_end/run.py --harts 2 --error 2 --run-only
python rtl/verification/l1_eviction_end_to_end/run.py --harts 2 --error 3 --run-only
```

Repeat with 4 harts. Error 0 = OKAY, 2 = SLVERR, 3 = DECERR. Rebuild after RTL changes. Complete replay: `make l1-eviction-regression` from `rtl/verification/cmo_end_to_end`. It rebuilds all CPU models, runs atomic/CBO/FENCE.I cases, lints both TOP configurations and regenerates evidence. Logs and sampled VCDs: `rtl/reports/l1_eviction_retention`.

Protocol checks stay enabled. Activation counts distinguish exercised handshakes from inactive channels; this focused program need not evict a dirty LLC line to external DRAM, so external-write activity is not assumed. Code coverage is not measured. Detailed fault-address/source records remain A-06; the current functional CSR check covers the existing fault status bit.

## Tiếng Việt

CPU thật ghi hai word đã biết vào tám way cùng set L1 rồi đọc line thứ chín để gây eviction dirty. Mỗi hart dùng set riêng; một miss cũ được trì hoãn để kiểm tra refill vẫn hoàn tất trong lúc chờ B.

Shim kiểm chứng chỉ trì hoãn/thay response B từ LLC native, không force state cache hoặc completion CPU. Test đọc SRAM/tag thực, kiểm tra giữ dữ liệu/context, không refill sớm hoặc retry, IRQ sticky, CSR qua AXI4-Lite và thử W1C. Sau đó chỉ reset qua cổng public rồi chạy lại chương trình để kiểm tra recovery.

Chạy các lệnh trên với 2/4 hart; `--error 2/3` là SLVERR/DECERR. Makefile duy nhất chứa toàn bộ regression và lint. Chưa đo code coverage; fault record chi tiết vẫn thuộc A-06. Số lần kích hoạt assertion được ghi riêng để không coi kênh idle là đã kiểm chứng.
