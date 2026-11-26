"""Independent RV64A instruction encoder and architectural result oracle.

DEC-038 / TEST-036: shared counter, AMO W/D operations, LR/SC reservations.
No cache implementation is imported to compute expected results.
"""
from pathlib import Path

HERE = Path(__file__).resolve().parent


def generate():
    code, labels, fixups, checks, listing = [], {}, [], {}, []

    def emit(word, desc):
        pc = len(code) * 4
        code.append(word)
        listing.append(f"{0x80000000 + pc:08x}: {word:08x}  {desc}")
        return pc

    def mark(name):
        labels[name] = len(code) * 4

    def addi(rd, rs, imm):
        return emit(((imm & 4095) << 20) | (rs << 15) | (rd << 7) | 0x13,
                    f"addi x{rd},x{rs},{imm}")

    def address(rd, addr):
        emit(((addr + 0x800) & 0xfffff000) | (rd << 7) | 0x37, f"lui x{rd},address")
        if addr & 4095:
            addi(rd, rd, ((addr & 4095) ^ 2048) - 2048)
        # RV64 LUI sign extends. Use a logical shift pair to form the PA.
        emit((32 << 20) | (rd << 15) | (1 << 12) | (rd << 7) | 0x13, "slli address,32")
        emit((32 << 20) | (rd << 15) | (5 << 12) | (rd << 7) | 0x13, "srli address,32")

    def ld(rd, rs, off=0):
        return emit(((off & 4095) << 20) | (rs << 15) | (3 << 12) | (rd << 7) | 3,
                    f"ld x{rd},{off}(x{rs})")

    def sd(rs2, rs, off=0):
        emit(((off & 0xfe0) << 20) | (rs2 << 20) | (rs << 15) | (3 << 12) |
             ((off & 31) << 7) | 0x23, f"sd x{rs2},{off}(x{rs})")

    def branch(rs1, rs2, label, funct3=0):
        fixups.append((len(code), rs1, rs2, label, funct3))
        emit(0, f"branch.{funct3} x{rs1},x{rs2},{label}")

    def amo(fn, size, rd, operand, base, desc, expected=None):
        # Set aq and rl on all operations; preserve their architectural ordering.
        pc = emit((fn << 27) | (3 << 25) | (operand << 20) | (base << 15) |
                  (size << 12) | (rd << 7) | 0x2f, desc)
        if expected is not None:
            checks[pc] = expected & ((1 << 64) - 1)
        return pc

    # Trap vector, hart ID and physically addressed shared data.
    address(5, 0x80000700)
    emit((0x305 << 20) | (5 << 15) | (1 << 12) | 0x73, "csrw mtvec,x5")
    emit((0xf14 << 20) | (2 << 12) | (10 << 7) | 0x73, "csrr x10,mhartid")
    address(11, 0x80001000)
    address(12, 0x80001100)
    branch(10, 0, 'boot_ready', 1)
    addi(13, 0, 10)
    sd(13, 11)  # Dirty owner; DRAM retains its initial value zero.
    addi(13, 0, 1)
    sd(13, 12)
    mark('boot_ready')
    ld(13, 12)
    branch(13, 0, 'boot_ready')
    addi(13, 0, 1)
    addi(20, 0, 8)
    mark('contended')
    shared_pc = amo(0, 3, 14, 13, 11, 'amoadd.d.aqrl x14,x13,(x11) -- shared counter')
    addi(20, 20, -1)
    branch(20, 0, 'contended', 1)
    emit((1 << 20) | (11 << 15) | (2 << 12) | 0xf, 'cbo.clean (x11)')

    # Each hart's private test line uses a separate 64-byte address stride.
    address(12, 0x80002000)
    emit((6 << 20) | (10 << 15) | (1 << 12) | (5 << 7) | 0x13, 'slli x5,x10,6')
    emit((5 << 20) | (12 << 15) | (12 << 7) | 0x33, 'add x12,x12,x5')
    ops = [('add', 0, 3), ('xor', 4, 0x55), ('and', 12, 31), ('or', 8, 128),
           ('min', 16, -4), ('max', 20, 5), ('minu', 24, -1), ('maxu', 28, 7),
           ('swap', 1, -7)]
    for size, offset in [(3, 0), (2, 0), (2, 4)]:
        addi(13, 0, -8)
        if size == 2:
            # Fill both words with -8; a sign-extended immediate alone would
            # leave the upper word at -1, not -8.
            emit((32<<20)|(13<<15)|(1<<12)|(5<<7)|0x13, 'slli x5,x13,32')
            emit((32<<20)|(13<<15)|(1<<12)|(13<<7)|0x13, 'slli x13,x13,32')
            emit((32<<20)|(13<<15)|(5<<12)|(13<<7)|0x13, 'srli x13,x13,32')
            emit((5<<20)|(13<<15)|(6<<12)|(13<<7)|0x33, 'or x13,x13,x5')
        sd(13, 12)
        addi(11, 12, offset)
        bits = 64 if size == 3 else 32
        mask, old = (1 << bits) - 1, (-8) & ((1 << bits) - 1)
        signed = lambda x: x - (1 << bits) if x >> (bits - 1) else x
        for name, fn, operand in ops:
            addi(13, 0, operand)
            amo(fn, size, 14, 13, 11, f'amo{name}.{bits} offset={offset}', signed(old))
            val = operand & mask
            if name == 'add': new = old + val
            elif name == 'xor': new = old ^ val
            elif name == 'and': new = old & val
            elif name == 'or': new = old | val
            elif name == 'min': new = min(signed(old), signed(val))
            elif name == 'max': new = max(signed(old), signed(val))
            elif name == 'minu': new = min(old, val)
            elif name == 'maxu': new = max(old, val)
            else: new = val
            old = new & mask
        pc = ld(18, 11, -offset)
        if size == 3:
            checks[pc] = old
        else:
            checks[pc] = ((0xfffffff8 << 32) | old) if offset == 0 else ((old << 32) | 0xfffffff8)

    # Successful SC, second SC without LR, and replacement LR at another line.
    for size, offset in [(3, 0), (2, 0), (2, 4)]:
        addi(13, 0, 23)
        sd(13, 12)
        addi(11, 12, offset)
        amo(2, size, 14, 0, 11, 'lr acquire', 23 if offset == 0 else 0)
        addi(13, 0, 77)
        amo(3, size, 16, 13, 11, 'sc successful', 0)
        amo(3, size, 17, 13, 11, 'sc without lr must fail', 1)
        pc = ld(18, 12)
        checks[pc] = (77 << 32) | 23 if offset else 77
    addi(11, 12, 0)
    amo(2, 3, 14, 0, 11, 'lr original line')
    addi(11, 12, 16)
    amo(2, 3, 14, 0, 11, 'replacement lr different line', 0)
    addi(11, 12, 0)
    amo(3, 3, 17, 13, 11, 'sc original reservation replaced', 1)

    # Hart 1 modifies a line after hart 0's LR, coordinated through actual
    # coherent flag loads/stores. No native cache state/completion is forced.
    address(11, 0x80001200)
    address(12, 0x80001300)
    branch(10, 0, 'remote_writer', 1)
    amo(2, 3, 14, 0, 11, 'lr before remote store', 5)
    addi(13, 0, 1)
    sd(13, 12)
    mark('wait_remote')
    ld(13, 12)
    addi(5, 0, 2)
    branch(13, 5, 'wait_remote', 1)
    addi(13, 0, 111)
    amo(3, 3, 17, 13, 11, 'sc invalidated by remote store', 1)
    pc = ld(18, 11)
    checks[pc] = 99
    branch(0, 0, 'done')
    mark('remote_writer')
    addi(5, 0, 1)
    branch(10, 5, 'done', 1)
    mark('wait_lr')
    ld(13, 12)
    branch(13, 0, 'wait_lr')
    addi(13, 0, 99)
    sd(13, 11)
    addi(13, 0, 2)
    sd(13, 12)
    mark('done')
    done_pc = emit(0x6f, 'j done')

    for idx, rs1, rs2, label, f3 in fixups:
        off = labels[label] - idx * 4
        assert off % 2 == 0 and -4096 <= off <= 4094
        code[idx] = (((off >> 12) & 1) << 31) | (((off >> 5) & 63) << 25) | (rs2 << 20) | (rs1 << 15) | (f3 << 12) | (((off >> 1) & 15) << 8) | (((off >> 11) & 1) << 7) | 0x63
        listing[idx] = f'{0x80000000+idx*4:08x}: {code[idx]:08x}  ' + listing[idx].split('  ', 1)[1]
    assert len(code) * 4 < 0x700
    words = [0] * 8192
    for idx, insn in enumerate(code): words[idx // 2] |= insn << ((idx % 2) * 32)
    words[0x700 // 8] = 0x6f
    words[0x1200 // 8] = 5
    (HERE / 'program.hex').write_text(''.join(f'{x:016x}\n' for x in words))
    (HERE / 'program_listing.txt').write_text('\n'.join(listing) + '\n')
    case = ''.join(f"      64'h{0x80000000+pc:016x}: begin check_valid=1; expected=64'h{val:016x}; end\n" for pc, val in checks.items())
    (HERE / 'program_checks.svh').write_text(case)
    (HERE / 'program_constants.svh').write_text(f"localparam logic [63:0] SHARED_PC=64'h{0x80000000+shared_pc:016x}, DONE_PC=64'h{0x80000000+done_pc:016x};\nlocalparam int EXPECTED_CHECKS={len(checks)};\n")
    # Independent fault-only images: no AMO may retire or update its rd.
    for name, fn in [('amo_fault',0),('lr_fault',2)]:
        image=[0]*8192
        ins=[0x800002b7,0x70028293,0x02029293,0x0202d293,0x30529073,
             0xf1402573,0x800035b7,0x02059593,0x0205d593,
             (6<<20)|(10<<15)|(1<<12)|(5<<7)|0x13,
             (5<<20)|(11<<15)|(11<<7)|0x33,
             (13<<7)|0x13|(3<<20),
             (fn<<27)|(3<<25)|((0 if fn==2 else 13)<<20)|(11<<15)|(3<<12)|(14<<7)|0x2f,
             0x07b00913,0x6f]
        for idx,word in enumerate(ins): image[idx//2] |= word<<((idx%2)*32)
        image[0x700//8]=0x6f
        (HERE/f'{name}.hex').write_text(''.join(f'{x:016x}\n' for x in image))
    # Dirty-owner writeback error must ABORT before the requester faults.
    code, labels, fixups = [], {}, []
    address(5, 0x80000700)
    emit((0x305<<20)|(5<<15)|(1<<12)|0x73, 'csrw mtvec,x5')
    emit((0xf14<<20)|(2<<12)|(10<<7)|0x73, 'csrr mhartid')
    address(11, 0x80001000)
    address(12, 0x80001100)
    branch(10,0,'owner',0)
    mark('owner_ready')
    ld(13,12)
    branch(13,0,'owner_ready',0)
    addi(13,0,1)
    owner_fault_pc=amo(0,3,14,13,11,'amoadd dirty remote owner -- expected fault')
    emit(0x6f,'unexpected successful requester')
    mark('owner')
    addi(13,0,41); sd(13,11)
    addi(13,0,1); sd(13,12)
    mark('owner_loop')
    owner_read_pc=ld(14,11)
    branch(0,0,'owner_loop')
    for idx,rs1,rs2,label,f3 in fixups:
        off=labels[label]-idx*4
        code[idx]=(((off>>12)&1)<<31)|(((off>>5)&63)<<25)|(rs2<<20)|(rs1<<15)|(f3<<12)|(((off>>1)&15)<<8)|(((off>>11)&1)<<7)|0x63
    image=[0]*8192
    for idx,word in enumerate(code): image[idx//2] |= word<<((idx%2)*32)
    image[0x700//8]=0x6f
    (HERE/'owner_fault.hex').write_text(''.join(f'{x:016x}\n' for x in image))
    with (HERE/'program_constants.svh').open('a') as f:
        f.write(f"localparam logic [63:0] OWNER_FAULT_PC=64'h{0x80000000+owner_fault_pc:016x}, OWNER_READ_PC=64'h{0x80000000+owner_read_pc:016x};\n")
    # Real contended LR/SC retry loop. Reuse the architectural old-value
    # checkpoint at SHARED_PC only after SC returned success; unsuccessful
    # attempts never reach the checkpoint. All remaining tests stay unchanged.
    lrsc_words=list(words)
    def put32(pc,word):
        shift=(pc%8)*8
        lrsc_words[pc//8]=(lrsc_words[pc//8]&~(0xffffffff<<shift))|(word<<shift)
    def jump(pc,target):
        d=target-pc
        return (((d>>20)&1)<<31)|(((d>>1)&1023)<<21)|(((d>>11)&1)<<20)|(((d>>12)&255)<<12)|0x6f
    def retry_branch(pc,target,rs):
        d=target-pc
        return (((d>>12)&1)<<31)|(((d>>5)&63)<<25)|(rs<<15)|(1<<12)|(((d>>1)&15)<<8)|(((d>>11)&1)<<7)|0x63
    put32(0x50,jump(0x50,0x5e0))
    put32(shared_pc,(14<<15)|(14<<7)|0x13)
    put32(0x60,retry_branch(0x60,0x600,20))
    put32(0x5e0,(8<<20)|(20<<7)|0x13); put32(0x5e4,jump(0x5e4,0x600))
    put32(0x600,(2<<27)|(3<<25)|(11<<15)|(3<<12)|(14<<7)|0x2f)
    put32(0x604,(1<<20)|(14<<15)|(13<<7)|0x13)
    put32(0x608,(3<<27)|(3<<25)|(13<<20)|(11<<15)|(3<<12)|(16<<7)|0x2f)
    put32(0x60c,retry_branch(0x60c,0x600,16)); put32(0x610,jump(0x610,shared_pc))
    (HERE/'lrsc_contention.hex').write_text(''.join(f'{w:016x}\n' for w in lrsc_words))
    (HERE/'lrsc_contention.S').write_text('# Program overlay for the shared-counter phase; remaining program is unchanged.\n# x11 = shared X, x20 = remaining successful increments.\n# The old-value checkpoint is reached only after SC returns zero.\n0x80000050: j 0x800005e0\n0x80000058: addi x14,x14,0  # architectural old-value checkpoint\n0x8000005c: addi x20,x20,-1\n0x80000060: bnez x20,0x80000600\n0x800005e0: addi x20,x0,8\n0x800005e4: j 0x80000600\n0x80000600: lr.d.aqrl x14,(x11)\n0x80000604: addi x13,x14,1\n0x80000608: sc.d.aqrl x16,x13,(x11)\n0x8000060c: bnez x16,0x80000600\n0x80000610: j 0x80000058\n')
    return shared_pc, done_pc


if __name__ == '__main__':
    generate()
