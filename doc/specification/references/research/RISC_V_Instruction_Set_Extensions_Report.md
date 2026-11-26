# RISC-V Instruction Set Extensions — Detailed Report
# Báo cáo chi tiết các tập lệnh RISC-V (đặc biệt RVV — Vector Extension)

**Project / Dự án:** VLSIT RISC-V CPU
**Version / Phiên bản:** 1.0
**Research date / Ngày biên soạn:** 2026-11-15, Asia/Saigon
**Scope / Phạm vi:** Bảng phân loại đầy đủ các tập lệnh (base ISA + extensions) của RISC-V, với phần chuyên sâu về Vector Extension (RVV) — thanh ghi, CSR, LMUL/SEW, phân nhóm lệnh, mã hóa và ví dụ.

> Tài liệu tham chiếu chuẩn RISC-V: *The RISC-V Instruction Set Manual*, Vol. I (Unprivileged) và *Vector Extension Version 1.0* (ratified 2021). Các con số CSR, mã hóa và tên lệnh được trích từ tài liệu chuẩn; không phát sinh nội dung ngoài phạm vi chuẩn.

---

## Mục lục

1. Tổng quan kiến trúc RISC-V
2. Tập lệnh nền (Base ISA)
3. Các extension tiêu chuẩn (unprivileged)
4. Các extension đặc quyền và hệ thống
5. Cách viết tên ISA đầy đủ
6. RVV — Vector Extension (trọng tâm)
   6.1. Mô hình lập trình vector
   6.2. Thanh ghi vector và CSR
   6.3. SEW, LMUL và nhóm thanh ghi
   6.4. Mã hóa lệnh vector
   6.5. Phân nhóm lệnh RVV
   6.6. Ví dụ lập trình
7. RVV thu gọn (Zve*) cho hệ nhúng
8. So sánh RVV với các kiến trúc SIMD khác
9. Liên hệ với dự án VLSIT RISC-V CPU

---

## 1. Tổng quan kiến trúc RISC-V

RISC-V là một **đặc tả kiến trúc** (specification), không phải một con chip cụ thể. Kiến trúc được chia thành hai phần độc lập:

- **Base ISA**: tập lệnh nền bắt buộc, đóng băng (frozen), gồm số nguyên 32/64 bit.
- **Extensions**: các phần mở rộng tùy chọn, mỗi phần mang một ký hiệu chữ cái.

Các nguyên tắc thiết kế chính:

| Nguyên tắc | Ý nghĩa |
|---|---|
| **Modular** | Base + extensions lắp ghép tùy nhu cầu; không bắt buộc mang cả bộ |
| **XLEN** | Độ rộng thanh ghi/địa chỉ: 32 hoặc 64 bit |
| **32 thanh ghi nguyên** | `x0`–`x31`; `x0` nối cứng về 0 |
| **Định dạng lệnh cố định** | R/I/S/B/U/J, các trường `rs1/rs2/rd` ở vị trí cố định |
| **3 chế độ đặc quyền** | M (Machine), S (Supervisor), U (User) |
| **RVWMO** | Mô hình thứ tự bộ nhớ yếu (weak memory model), là nghĩa vụ riêng, không ngầm định |

---

## 2. Tập lệnh nền (Base ISA)

| Ký hiệu | Tên đầy đủ | Mô tả | Số thanh ghi |
|---|---|---|---|
| **RV32I** | 32-bit Integer | Tập lệnh số nguyên 32-bit, bắt buộc cho mọi lõi 32-bit | 32 |
| **RV32E** | 32-bit Embedded | Biến thể nhúng, giảm còn 16 thanh ghi | 16 |
| **RV64I** | 64-bit Integer | Số nguyên 64-bit (XLEN=64) | 32 |
| **RV128I** | 128-bit Integer | Dự trữ cho tương lai, chưa chuẩn hóa | 32 |

> Dự án VLSIT RISC-V CPU nhắm tới **RV64I** (homogeneous RV64) làm nền cho cluster 2/4 core.

---

## 3. Các extension tiêu chuẩn (unprivileged)

| Ký hiệu | Tên | Chức năng | Ghi chú |
|---|---|---|---|
| **M** | Integer Multiply/Divide | `mul`, `div`, `rem`, `mulh`… | Cần cho hầu hết workload |
| **A** | Atomic | `lr.w/d`, `sc.w/d`, `amo*.w/d` | Bắt buộc cho coherence đa lõi |
| **F** | Single-Precision FP | Số thực 32-bit, 32 thanh ghi `f0`–`f31` | |
| **D** | Double-Precision FP | Số thực 64-bit | Cần F |
| **Q** | Quad-Precision FP | Số thực 128-bit | Cần D |
| **C** | Compressed | Lệnh nén 16-bit | Tăng mật độ mã, giảm năng lượng |
| **V** | Vector (RVV) | Vector chiều dài thay đổi | Xem mục 6 |
| **Zicsr** | CSR instructions | `csrrw/csrrs/csrrc`… | Bắt buộc cho quản lý trạng thái |
| **Zifencei** | Instruction-Fetch Fence | `fence.i` | Đồng bộ I-cache |
| **Zicntr** | Base Counters | `cycle`, `time`, `instret` | Bộ đếm kiến trúc |
| **B** | Bit Manipulation | `Zba` (địa chỉ), `Zbb` (cơ bản), `Zbc` (CLMUL), `Zbs` (single-bit) | |
| **Zk\*** | Scalar Crypto | `Zkn` (NIST), `Zks` (SM), `Zkr` (TRNG), `Zkt` | AES, SHA2, SM3/SM4 |
| **Zv\*** | Vector Crypto | `Zvkn`, `Zvkg`, `Zvks`, `Zvbc`, `Zvbb` | AES/SHA/SM dạng vector |

### Ghi chú về ký hiệu gộp

- **`G`** = `IMAFD` + `Zicsr` + `Zifencei` (profile "general-purpose" phổ biến nhất).

### Các extension đã rút khỏi / không chuẩn hóa

| Ký hiệu | Tên | Trạng thái |
|---|---|---|
| `P` | Packed-SIMD | Đã bỏ, thay bằng `V` (RVV) |
| `J` | Dynamic Languages (JIT) | Đã rút |
| `T` | Transactional Memory | Đã rút |
| `L` | Decimal Floating-Point | Đã rút |

---

## 4. Các extension đặc quyền và hệ thống

| Ký hiệu | Tên | Chức năng |
|---|---|---|
| **U** | User mode | Chế độ người dùng |
| **S** | Supervisor mode | Chế độ hệ điều hành |
| **H** | Hypervisor | Hỗ trợ ảo hóa |
| **M** (privilege) | Machine mode | Chế độ máy, luôn có ở mọi lõi |
| **Sv32** | 32-bit paging | 2 cấp, trang 4 KiB |
| **Sv39** | 39-bit paging | 3 cấp (RV64) |
| **Sv48** | 48-bit paging | 4 cấp (RV64) |
| **Sv57** | 57-bit paging | 5 cấp (RV64) |

---

## 5. Cách viết tên ISA đầy đủ

Quy ước: `RV<XLEN><tập lệnh>` với các chữ cái liền nhau biểu thị tập lệnh nền + extensions.

| Ví dụ | Diễn giải |
|---|---|
| `RV64I` | Chỉ tập nền số nguyên 64-bit |
| `RV64IMAC` | + nhân/chia, atomic, compressed |
| `RV64GC` | = RV64I + IMAFD + Zicsr + Zifencei + C |
| `RV64GCV` | = RV64GC + Vector |
| `RV32IMC_Zicsr_Zve32f` | RV32 + M + C + CSR + vector nhúng 32-bit |

---

## 6. RVV — RISC-V Vector Extension (trọng tâm)

### 6.1 Mô hình lập trình vector

RVV là kiến trúc **vector chiều dài thay đổi (vector-length agnostic, VLA)**. Khác với SIMD chiều dài cố định (NEON/AVX), một đoạn mã RVV chạy đúng trên mọi phần cứng có `VLEN` khác nhau (128 → 1024+ bit) mà **không cần biên dịch lại**, nhờ cơ chế "strip-mining" dựa trên `VL`.

**Khái niệm lõi:**

| Khái niệm | Ý nghĩa |
|---|---|
| **VLEN** | Độ rộng vật lý của một thanh ghi vector (số bit) |
| **ELEN** | Độ rộng phần tử tối đa mà phần cứng hỗ trợ (≤ 64) |
| **SEW** | Selected Element Width — độ rộng phần tử đang dùng (8/16/32/64) |
| **LMUL** | Nhóm thanh ghi để tạo vector dài hơn hoặc ngắn hơn |
| **VL** | Số phần tử thực sự được xử lý trong lệnh hiện tại |

Số phần tử tối đa trong một thanh ghi = `VLEN / SEW`. Ví dụ VLEN=256, SEW=32 → tối đa 8 phần tử.

### 6.2 Thanh ghi vector và CSR

**Thanh ghi vector:** `v0`–`v31`, mỗi thanh ghi `VLEN` bit.

**Thanh ghi mask:** `v0` (hoặc bất kỳ thanh ghi nào khi dùng bit mask 1-bit) giữ 1 bit cho mỗi phần tử; bit=1 nghĩa là phần tử được thực thi.

**CSR điều khiển vector:**

| CSR | Địa chỉ | Vai trò |
|---|---|---|
| `vstart` | 0x008 | Vị trí phần tử tiếp tục sau ngắt/trap |
| `vxsat` | 0x009 | Cờ bão hòa (fixed-point) |
| `vxrm` | 0x00A | Chế độ làm tròn fixed-point |
| `vcsr` | 0x00F | Alias gộp `vxrm` + `vxsat` |
| `vl` | 0xC20 | Vector length hiện tại (số phần tử) |
| `vtype` | 0xC21 | Cấu hình SEW/LMUL/agnostic |
| `vlenb` | 0xC22 | Chiều dài thanh ghi vector theo byte (VLEN/8) |

**Cấu trúc bit của `vtype`:**

| Bit | Trường | Mô tả |
|---|---|---|
| [2:0] | `vlmul` | Nhóm thanh ghi (xem 6.3) |
| [4:2] | `vsew` | Độ rộng phần tử (xem 6.3) |
| 5 | `vta` | Vector tail agnostic |
| 6 | `vma` | Vector mask agnostic |
| 7 | `vill` | =1 khi tổ hợp SEW/LMUL bất hợp lệ |
| [63:8] | — | Dự trữ (WPRI) |

**Bảng mã `vsew`:**

| `vsew[2:0]` | SEW (bit) |
|---|---|
| 000 | 8 |
| 001 | 16 |
| 010 | 32 |
| 011 | 64 |
| 1xx | dự trữ |

**Bảng mã `vlmul`:**

| `vlmul[2:0]` | LMUL |
|---|---|
| 000 | 1 |
| 001 | 2 |
| 010 | 4 |
| 011 | 8 |
| 100 | dự trữ |
| 101 | 1/8 |
| 110 | 1/4 |
| 111 | 1/2 |

### 6.3 SEW, LMUL và nhóm thanh ghi

`LMUL` ghép nhiều thanh ghi thành một vector dài hơn, hoặc chia một thanh ghi cho nhiều vector ngắn hơn.

| LMUL | Số thanh ghi / nhóm | Số nhóm khả dụng | Tên nhóm (LMUL=1 trở lên) |
|---|---|---|---|
| 1/8 | 1 thanh ghi = 8 vector | 32 × 8 | chia nhỏ `v0`–`v31` |
| 1/4 | 1 thanh ghi = 4 vector | 32 × 4 | chia nhỏ |
| 1/2 | 1 thanh ghi = 2 vector | 32 × 2 | chia nhỏ |
| 1 | 1 thanh ghi = 1 vector | 32 | `v0`–`v31` |
| 2 | 2 thanh ghi = 1 vector | 16 | `v0, v2, v4, …` |
| 4 | 4 thanh ghi = 1 vector | 8 | `v0, v4, v8, …` |
| 8 | 8 thanh ghi = 1 vector | 4 | `v0, v8, v16, v24` |

**Ràng buộc hợp lệ:** `VLEN / SEW * LMUL` phải nằm trong khoảng `1 … 32` thanh ghi. Nếu vi phạm, `vill` = 1 và các lệnh vector phát sinh *illegal instruction*.

### 6.4 Mã hóa lệnh vector

Các lệnh vector tái dùng cấu trúc mã hóa chuẩn, với hai đặc điểm:

- **Bit `vm` (bit 25):** `vm=0` → lệnh bị che bởi `v0` (masked); `vm=1` → không che (unmasked).
- **Opcode:** số học vector dùng `OP-V` (0x57); dấu phẩy động vector dùng cùng 0x57 phân biệt qua `funct6`; load/store vector dùng `LOAD-FP` (0x07) và `STORE-FP` (0x27).

| Trường | Vị trí | Vai trò |
|---|---|---|
| `opcode` | [6:0] | 0x57 (arith), 0x07/0x27 (load/store) |
| `rd` | [11:7] | Thanh ghi đích vector |
| `funct3` | [14:12] | Độ rộng phần tử (load/store) / kiểu |
| `rs1` | [19:15] | Thanh ghi nguồn (vector hoặc scalar) |
| `rs2` | [24:20] | Thanh ghi nguồn thứ hai |
| `vm` | 25 | Che mask / không che |
| `funct6` | [31:26] | Mã thao tác (add/sub/…), một số bit dùng làm `vs2` |

### 6.5 Phân nhóm lệnh RVV

| Nhóm lệnh | Ví dụ | Ghi chú |
|---|---|---|
| **Cấu hình** | `vsetvli`, `vsetivli`, `vsetvl` | Thiết lập `vtype` + `vl`; `vsetvli` tự tính VL còn lại |
| **Load/Store unit-stride** | `vle8/16/32/64`, `vse8/16/32/64` | Kế tiếp liên tục |
| **Load/Store strided** | `vlse8…`, `vsse8…` | Khoảng cách cố định giữa các phần tử |
| **Load/Store indexed** | `vluxei8…`, `vloxei`, `vsuxei`, `vsoxei` | Gather/scatter theo chỉ số từ vector khác |
| **Load/Store whole-register** | `vl1re`…`vl8re`, `vs1r`…`vs8r` | Không phụ thuộc `vtype`/`vl` |
| **Load first-fault** | `vle8ff`, `vle32ff`, … | Dừng ở phần tử lỗi đầu tiên (page-fault) |
| **Số học số nguyên** | `vadd`, `vsub`, `vand`, `vor`, `vxor`, `vmul`, `vmadd`, `vdiv`, `vrem` | Dạng `.vv`, `.vx`, `.vi` |
| **Mở rộng (widening)** | `vwadd`, `vwmulu`, `vwmul`, `vwaddu` | Kết quả rộng gấp đôi phần tử |
| **Thu hẹp (narrowing)** | `vnsrl`, `vnsra`, `vnclipu`, `vnclip` | Kết quả hẹp hơn phần tử |
| **Bão hòa** | `vsaddu`, `vssubu`, `vssra`, `vssrl` | Fixed-point, dùng `vxrm`/`vxsat` |
| **Dấu phẩy động** | `vfadd`, `vfsub`, `vfmul`, `vfdiv`, `vfsqrt`, `vfmadd`, `vfmin`, `vfmax` | Cần F/D |
| **Hàm đặc biệt FP** | `vfrec7`, `vfrsqrt7`, `vfclass`, `vfcvt.*` | Xấp xỉ nghịch đảo, căn, phân loại, đổi kiểu |
| **So sánh** | `vmseq`, `vmsne`, `vmslt`, `vmsle`, `vmsltu`, `vmfeq`, `vmflt`, `vmfge` | Sinh mask vào thanh ghi đích |
| **Thao tác mask** | `vmand`, `vmnand`, `vmor`, `vmxor`, `vmnot`, `vmsbf`, `vmsif`, `vmsof`, `vfirst`, `vcpop` | Logic trên bit mask |
| **Reduction** | `vredsum`, `vredmax`, `vredmin`, `vredand`, `vredor`, `vredxor`, `vfwredsum` | Thu gọn vector → 1 phần tử |
| **Permutation** | `vslideup`, `vslidedown`, `vslide1up/down`, `vrgather`, `vrgatherei16`, `vcompress` | Dịch, gom, nén theo mask |
| **Vector ↔ scalar** | `vmv.x.s`, `vmv.s.x`, `vmv.v.v`, `vmv.v.i`, `vmv.v.x` | Di chuyển giữa vector và thanh ghi |
| **Merge** | `vmerge`, `vfmerge` | Chọn theo mask giữa hai nguồn |
| **Mở rộng dấu** | `vzext.vf2/4/8`, `vsext.vf2/4/8` | Mở rộng zero/sign |

### 6.6 Ví dụ lập trình

**Ví dụ 1 — Cộng hai mảng 64-bit:**

```asm
# a0 = số phần tử, a1 = con trỏ A, a2 = con trỏ B, a3 = con trỏ C
loop:
    vsetvli t0, a0, e64, m1   # SEW=64, LMUL=1; t0 = VL thực tế
    vle64.v v1, (a1)          # nạp A
    vle64.v v2, (a2)          # nạp B
    vadd.vv v3, v1, v2        # v3[i] = v1[i] + v2[i]
    vse64.v v3, (a3)          # ghi C
    sub     a0, a0, t0        # giảm số phần tử còn lại
    slli    t1, t0, 3         # t1 = VL * 8 (byte)
    add     a1, a1, t1
    add     a2, a2, t1
    add     a3, a3, t1
    bnez    a0, loop
```

**Ví dụ 2 — Tích vô hướng (dot product) dùng mask và reduction:**

```asm
# v1, v2 chứa 2 vector; tính sum(v1[i]*v2[i])
vsetvli t0, a0, e32, m1
vmul.vv v3, v1, v2          # v3[i] = v1[i] * v2[i]
vredsum.vs v4, v3, v0       # v4[0] = tổng các phần tử của v3
vmv.x.s  a1, v4             # đưa kết quả về thanh ghi scalar
```

---

## 7. RVV thu gọn (Zve*) cho hệ nhúng

RVV đầy đủ (`V`) yêu cầu hỗ trợ `ELEN=64` và toàn bộ nhóm lệnh. Với lõi nhúng diện tích nhỏ, RISC-V định nghĩa các **tập con Zve\*** giảm bớt:

| Tập con | Đặc điểm | Phù hợp |
|---|---|---|
| **Zve64d** | ELEN=64, có FP64 | Đầy đủ nhất trong nhóm nhúng |
| **Zve64f** | ELEN=64, FP32 | |
| **Zve64x** | ELEN=64, không FP | |
| **Zve32f** | ELEN=32, FP32 | Lõi nhúng nhỏ |
| **Zve32x** | ELEN=32, không FP | Nhỏ nhất |

> Ghi chú quan trọng cho dự án: với cluster CVA6 (RV64 in-order), cần quyết định giữa `V` đầy đủ hay `Zve64d`. `Zve32f` chỉ hợp cho lõi RV32 nhúng (như CV32E), không phù hợp baseline RV64 của dự án hiện tại.

---

## 8. So sánh RVV với các kiến trúc SIMD khác

| Đặc điểm | RISC-V RVV | ARM NEON/SVE | x86 AVX/SSE |
|---|---|---|---|
| Chiều dài vector | Thay đổi theo VLEN (VLA) | NEON cố định 128-bit; SVE thay đổi | Cố định theo thế hệ (128/256/512) |
| Khả năng chạy lại | Một mã chạy mọi VLEN | NEON: phải biên dịch lại theo độ rộng | Cố định theo CPU |
| Thanh ghi | 32 (VLEN bit) | 32 (NEON 128-bit) | 8/16/32 (XMM/YMM/ZMM) |
| Lập trình | Intrinsic + assembler | Intrinsic + assembler | Intrinsic + assembler |
| Tiền đề | Mở, không royalty | Phụ thuộc license ARM | Phụ thuộc Intel/AMD |
| Strip-mining | Tự động qua `vsetvli` + `vl` | SVE có `ptrue`/predicate | Thủ công |

**Ưu điểm nổi bật của RVV:**
1. **Vector-length agnostic**: phần mềm tương lai chạy trên phần cứng cũ/mới không cần rebuild.
2. **Tail/mask agnostic (`vta`/`vma`)**: phần cứng tự do xử lý phần dư, giảm diện tích.
3. **LMUL linh hoạt**: tái dùng tài nguyên thanh ghi cho cả vector dài và ngắn.
4. **Miễn phí bản quyền**, phù hợp ASIC/SoC nguồn mở.

---

## 9. Liên hệ với dự án VLSIT RISC-V CPU

| Hạng mục | Hiện trạng / đề xuất |
|---|---|
| Base ISA | RV64I (homogeneous, đã chốt hướng trong cluster architecture) |
| Atomics + translation | Bắt buộc có `A` + `S`/`U` (SV39) để chạy Linux SMP coherent |
| Coherence | Culsans ACE CCU (MOESI); `A` + RVWMO được hiện thực tại fabric/home |
| Vector | **Chưa chốt**: cần quyết định `V` đầy đủ hay `Zve64d`; CVA6 hiện không có pipeline vector sẵn, phải tích hợp VPU |
| Đề xuất cho workload DSP/AI | Khảo sát `Zve64d` (hoặc `V` với VPU như Ara/Veer) thay vì lõi nhúng `Zve32f` |

**Khuyến nghị mở:** trước khi thêm vector vào baseline, cần xác định workload mục tiêu (DSP? matrix? crypto?), từ đó chọn `V` đầy đủ hay `Zve*`, và chọn VPU open-source (Ara, Vicuna, …) tương thích coherence CVA6/Culsans. Quyết định này chưa có trong cluster architecture hiện tại và nên được đưa vào bản cập nhật spec.

---

## Tài liệu tham khảo

1. RISC-V Instruction Set Manual, Volume I: Unprivileged ISA.
2. RISC-V "V" Vector Extension, Version 1.0 (ratified 2021).
3. RISC-V Cryptography Extensions (scalar `Zk*`, vector `Zv*`).
4. Tài liệu nội bộ: `VLSIT_RISCV_CPU_Cluster_Architecture.md` và `RISC_V_Core_Selection_Dual_Quad_Cluster_Report.md`.
