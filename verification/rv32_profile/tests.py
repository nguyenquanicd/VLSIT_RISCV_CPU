"""RV32 profile testcases: programs and independent expected results (rule R-023).

Each testcase function receives a Prog and the hart count and emits per-hart code under the label
main_h<h>. Expected values are computed here from the ISA definition, not from the RTL.
Testcase headers (rule R-095) are the docstrings of the tc_* functions.
"""
from asm_rv32 import Prog, BASE, MMIO_BASE, u32, s32, f32_bits
from fractions import Fraction
from math import isqrt

F32_QNAN = 0x7FC0_0000          # RISC-V canonical NaN
NV, DZ, OF, UF, NX = 0x10, 0x08, 0x04, 0x02, 0x01


def f32_value(bits):
    """Exact rational value of a finite normal binary32 pattern (the TC-03 operands are normal)."""
    e = (bits >> 23) & 0xFF
    assert 0 < e < 0xFF, 'operand must be a normal number'
    v = Fraction((1 << 23) | (bits & 0x7F_FFFF), 1 << 23) * Fraction(2) ** (e - 127)
    return -v if bits >> 31 else v


def f32_round(v, rm, sticky=False):
    """Round a nonzero rational to binary32 (normal range only), IEEE 754-2019 section 4.3.
    rm: 0 RNE, 1 RTZ, 2 RDN, 3 RUP, 4 RMM. sticky: the true value lies strictly above |v|.
    Returns (bits, inexact). Independent of the RTL: exact integer arithmetic only."""
    neg = v < 0
    a = -v if neg else v
    e = 0
    while a >= 2:
        a /= 2; e += 1
    while a < 1:
        a *= 2; e -= 1
    scaled = a * (1 << 23)                     # in [2^23, 2^24)
    q, r = divmod(scaled.numerator, scaled.denominator)
    frac = Fraction(r, scaled.denominator)
    inexact = frac != 0 or sticky
    half = Fraction(1, 2)
    if rm == 0:
        up = frac > half or (frac == half and (sticky or q & 1))
    elif rm == 1:
        up = False
    elif rm == 2:
        up = neg and inexact
    elif rm == 3:
        up = (not neg) and inexact
    else:
        up = frac > half or (frac == half)
    q += up
    if q == 1 << 24:
        q >>= 1; e += 1
    assert -126 <= e <= 127, 'result must stay normal'
    return ((neg << 31) | ((e + 127) << 23) | (q & 0x7F_FFFF)), inexact


def f32_div(a_bits, b_bits, rm=0):
    """(result bits, fflags) of FDIV.S for normal, zero, or NaN-free operands."""
    if b_bits & 0x7FFF_FFFF == 0:
        if a_bits & 0x7FFF_FFFF == 0:
            return F32_QNAN, NV                                  # 0/0 invalid
        return ((a_bits ^ b_bits) & 0x8000_0000) | 0x7F80_0000, DZ   # x/0 = signed infinity
    bits, nx = f32_round(f32_value(a_bits) / f32_value(b_bits), rm)
    return bits, NX if nx else 0


def f32_sqrt(a_bits, rm=0):
    """(result bits, fflags) of FSQRT.S for a normal operand."""
    if a_bits >> 31:
        return F32_QNAN, NV                                      # sqrt of a negative number is invalid
    x = f32_value(a_bits)
    k = 80                                                       # 2^k scale gives far more than 24 bits
    n = x * Fraction(4) ** k
    assert n.denominator == 1
    s = isqrt(n.numerator)
    bits, nx = f32_round(Fraction(s, 1 << k), rm, sticky=(s * s != n.numerator))
    return bits, NX if nx else 0

DATA = BASE + 0x10000
CHECKS = {}
MISA_EXPECT = (1 << 0) | (1 << 2) | (1 << 5) | (1 << 8) | (1 << 12) | (1 << 18) | (1 << 20)   # A C F I M S U
MISA_MASK = MISA_EXPECT | (1 << 3)                                                           # D must be 0


# ============================================================================ framework
def prologue(p, harts, fp=False):
    p.auipc('s9', 0)                    # boot PC of this hart (TC-01, TC-10)
    p.csrr('t0', 'mhartid')
    p.li('s10', MMIO_BASE)
    p.slli('t1', 't0', 8)
    p.add('s10', 's10', 't1')
    p.la('t2', 'trap')
    p.csrw('mtvec', 't2')
    if fp:
        p.li('t1', 0x2000)               # mstatus.FS = Initial
        p.csrs('mstatus', 't1')
    for h in range(1, harts):
        p.li('t1', h)
        p.beq('t0', 't1', f'main_h{h}')
    p.j('main_h0')
    # Trap handler: report mcause and mepc; ECALL resumes in M-mode at t4, others at mepc+4.
    p.align(4)
    p.label('trap')
    p.csrr('t5', 'mcause')
    p.sw('t5', 's10', 0)
    p.csrr('t6', 'mepc')
    p.sw('t6', 's10', 0)
    for cause in (8, 9, 11):
        p.li('t6', cause)
        p.beq('t5', 't6', 'trap_ecall')
    p.csrr('t6', 'mepc')
    p.addi('t6', 't6', 4)
    p.csrw('mepc', 't6')
    p.mret()
    p.label('trap_ecall')
    p.csrw('mepc', 't4')
    p.li('t6', 0x1800)
    p.csrs('mstatus', 't6')
    p.mret()


def exp_trap(p, h, cause, label):
    p.expect.setdefault(h, []).append(('trap.mcause', cause))
    p.expect.setdefault(h, []).append(('trap.mepc@' + label, ('label', label)))


def barrier(p, h, harts, counter_addr, tag):
    """All harts increment a shared counter with AMOADD.W and wait until it reaches harts."""
    p.li('t1', counter_addr)
    p.li('t2', 1)
    p.amoadd_w('zero', 't2', 't1')
    p.li('t3', harts)
    p.label(f'bar_{tag}_h{h}')
    p.lw('t2', 't1', 0)
    p.blt('t2', 't3', f'bar_{tag}_h{h}')


# ============================================================================ TC-01
def tc01(p, harts):
    """TC-01 priority P1. Objective: boot fan-out, hart identity, misa and RV64-only encodings.
    Spec: REQ-XL-002, REQ-XL-003, REQ-XL-004, REQ-XL-005; TEST-101, TEST-102, TEST-103. Config: 2 harts, profile 0.
    Sequence: every hart boots at i_boot_addr[31:0]; reads mhartid and misa; executes ADDW, LD, SD, AMOADD.D, LR.D
    and FADD.D; the trap handler reports mcause and mepc and resumes at mepc+4.
    Method: MMIO signature compared with this oracle. Failure mode: wrong boot PC, wrong hart id, RV64 or D
    instructions accepted, illegal instruction writes its destination.
    Checks: boot.pc, mhartid, misa.MXL, misa.ext, 6 x (trap.mcause, trap.mepc), rd.unchanged."""
    prologue(p, harts, fp=True)
    for h in range(harts):
        p.label(f'main_h{h}')
        p.check(h, 'boot.pc', 's9', BASE)
        p.check(h, 'mhartid', 't0', h)
        p.csrr('a0', 'misa')
        p.srli('a1', 'a0', 30)
        p.check(h, 'misa.MXL', 'a1', 1)
        p.li('a2', MISA_MASK)
        p.and_('a3', 'a0', 'a2')
        p.check(h, 'misa.ext', 'a3', MISA_EXPECT)
        p.li('t2', 0x1234)
        p.li('a0', DATA + 0x100 * h)
        for name in ('addw', 'ld', 'sd', 'amoadd.d', 'lr.d', 'fadd.d'):
            lab = f'tc01_{name.replace(".", "_")}_h{h}'
            p.label(lab)
            p.raw(Prog.RV64_ONLY[name](), name + ' (must trap)')
            exp_trap(p, h, 2, lab)
        p.check(h, 'rd.unchanged', 't2', 0x1234)
        p.done()


# ============================================================================ TC-02
def tc02(p, harts):
    """TC-02 priority P1. Objective: RV32 integer datapath with M, B, Zcb, Zicond and 64-bit counters.
    Spec: REQ-XL-003, REQ-XL-013; TEST-101, TEST-113. Config: 2 harts, profile 0.
    Sequence: per hart, compute about 40 operations on hart-specific operands; set mcycle/minstret near a
    low-word carry and read the high halves.
    Method: MMIO signature against Python integer semantics. Failure mode: 64-bit results, wrong sign
    extension, broken compressed decode, counter carry lost. Checks: one per operation, mcycleh.carry,
    minstreth.carry, instret.delta."""
    prologue(p, harts)
    for h in range(harts):
        A = u32(0x8765_4321 + 0x1111 * h)
        B = 0x0000_00F3 + h
        p.label(f'main_h{h}')
        p.li('s0', A)
        p.li('s1', B)
        a, b = A, B
        sa, sb = s32(a), s32(b)
        sh = b & 31
        ops = [
            ('add', p.add, u32(a + b)), ('sub', p.sub, u32(a - b)), ('sll', p.sll, u32(a << sh)),
            ('srl', p.srl, a >> sh), ('sra', p.sra, u32(sa >> sh)), ('slt', p.slt, int(sa < sb)),
            ('sltu', p.sltu, int(a < b)), ('xor', p.xor, a ^ b), ('mul', p.mul, u32(a * b)),
            ('mulh', p.mulh, u32((sa * sb) >> 32)), ('mulhu', p.mulhu, u32((a * b) >> 32)),
            ('div', p.div, u32(int(sa / sb))), ('divu', p.divu, a // b),
            ('rem', p.rem, u32(sa - sb * int(sa / sb))), ('remu', p.remu, a % b),
            ('andn', p.andn, a & ~b & 0xFFFFFFFF), ('min', p.min_, u32(min(sa, sb))), ('maxu', p.maxu, max(a, b)),
            ('sh2add', p.sh2add, u32((a << 2) + b)), ('ror', p.ror, u32((a >> sh) | (a << (32 - sh)))),
            ('bset', p.bset, a | (1 << sh)), ('bext', p.bext, (a >> sh) & 1),
        ]
        cl = 0
        for i in range(32):
            if (b >> i) & 1:
                cl ^= a << i
        ops.append(('clmul', p.clmul, u32(cl)))
        for name, fn, val in ops:
            fn('a0', 's0', 's1')
            p.check(h, name, 'a0', val)
        un = [('clz', p.clz, 32 - a.bit_length()), ('cpop', p.cpop, bin(a).count('1')),
              ('sext.b', p.sext_b, u32(((a & 0xFF) ^ 0x80) - 0x80)),
              ('rev8', p.rev8, int.from_bytes(a.to_bytes(4, 'little'), 'big')),
              ('orc.b', p.orc_b, sum((0xFF << (8 * k)) for k in range(4) if (a >> (8 * k)) & 0xFF))]
        for name, fn, val in un:
            fn('a0', 's0')
            p.check(h, name, 'a0', val)
        # division by zero (RISC-V M: quotient all ones, remainder = dividend)
        p.divu('a0', 's0', 'zero'); p.check(h, 'divu0', 'a0', 0xFFFFFFFF)
        p.rem('a0', 's0', 'zero'); p.check(h, 'rem0', 'a0', a)
        # Zicond
        p.czero_eqz('a0', 's0', 'zero'); p.check(h, 'czero.eqz', 'a0', 0)
        p.czero_nez('a0', 's0', 'zero'); p.check(h, 'czero.nez', 'a0', a)
        # Zcb compressed forms on x8..x15
        p.addi('a1', 's0', 0); p.c_mul('a1', 's1'); p.check(h, 'c.mul', 'a1', u32(a * b))
        p.addi('a1', 's0', 0); p.c_not('a1'); p.check(h, 'c.not', 'a1', u32(~a))
        p.addi('a1', 's0', 0); p.c_zext_b('a1'); p.check(h, 'c.zext.b', 'a1', a & 0xFF)
        p.addi('a1', 's0', 0); p.c_sext_h('a1'); p.check(h, 'c.sext.h', 'a1', u32(((a & 0xFFFF) ^ 0x8000) - 0x8000))
        p.li('a2', DATA + 0x100 * h)
        p.sw('s0', 'a2', 0)
        p.c_lbu('a3', 'a2', 2); p.check(h, 'c.lbu', 'a3', (a >> 16) & 0xFF)
        p.align(4)
        # 64-bit counters across a low-word carry (Zicntr, M-mode writable mcycle/minstret)
        p.li('a0', 0xFFFF_FF00); p.csrw('mcycle', 'a0'); p.li('a0', 5); p.csrw('mcycleh', 'a0')
        p.li('a1', 200)
        p.label(f'tc02_loop_h{h}')
        p.addi('a1', 'a1', -1)
        p.bnez('a1', f'tc02_loop_h{h}')
        p.csrr('a0', 'mcycleh'); p.check(h, 'mcycleh.carry', 'a0', 6)
        # write the high half first so that no carry happens before the low half is set
        p.li('a0', 7); p.csrw('minstreth', 'a0'); p.li('a0', 0xFFFF_FFFE); p.csrw('minstret', 'a0')
        p.nop(); p.nop(); p.nop(); p.nop()
        p.csrr('a0', 'minstreth'); p.check(h, 'minstreth.carry', 'a0', 8)
        p.done()


# ============================================================================ TC-03
def tc03(p, harts):
    """TC-03 priority P1. Objective: single-precision F datapath, fflags, D encodings rejected.
    Spec: REQ-XL-004; TEST-104. Config: 2 harts, profile 0.
    Sequence: enable mstatus.FS; FADD/FMUL/FDIV/FSQRT/FCVT/FLT on exact operands; read fflags; inexact FDIV
    sets NX; FADD.D traps.
    Method: IEEE 754 binary32 values from Python struct. Failure mode: FLEN 64 boxing visible, wrong
    rounding or flags, D accepted; divider fed without NaN boxing (DEC-106). Checks: 8 results, 3 fflags,
    13 divide/square-root results each with its fflags (DZ, NV, NX, rounding modes RNE/RTZ/RDN/RUP),
    trap.mcause, trap.mepc. Oracle: exact rational rounding (f32_round), not the host FPU."""
    prologue(p, harts, fp=True)
    for h in range(harts):
        p.label(f'main_h{h}')
        vals = {1: 1.5, 2: 2.25, 3: 3.0, 4: 0.5, 5: 7.0, 6: 2.0, 7: 16.0, 8: 1.0}
        for f, v in vals.items():
            p.li('a0', f32_bits(v)); p.fmv_w_x(f, 'a0')
        p.csrw('fflags', 'zero')
        p.fadd_s(10, 1, 2); p.fmv_x_w('a0', 10); p.check(h, 'fadd.s', 'a0', f32_bits(3.75))
        p.fmul_s(11, 3, 4); p.fmv_x_w('a0', 11); p.check(h, 'fmul.s', 'a0', f32_bits(1.5))
        p.fdiv_s(12, 5, 6); p.fmv_x_w('a0', 12); p.check(h, 'fdiv.s', 'a0', f32_bits(3.5))
        p.fsqrt_s(13, 7); p.fmv_x_w('a0', 13); p.check(h, 'fsqrt.s', 'a0', f32_bits(4.0))
        p.flt_s('a0', 1, 2); p.check(h, 'flt.s', 'a0', 1)
        p.csrr('a0', 'fflags'); p.check(h, 'fflags.exact', 'a0', 0)
        # FCVT.W.S of 3.75 with RTZ gives 3, which is inexact: NX is set (F extension, FCVT section).
        # Before 2026-11-26 this check ran after the FCVT and expected 0 (test defect hidden by the DEC-106 issue).
        p.fcvt_w_s('a0', 10, rm=1); p.check(h, 'fcvt.w.s', 'a0', 3)
        p.csrr('a0', 'fflags'); p.check(h, 'fcvt.w.s.flags', 'a0', NX)
        p.csrw('fflags', 'zero')
        p.fdiv_s(14, 8, 3); p.fmv_x_w('a0', 14); p.check(h, 'fdiv.s.inexact', 'a0', f32_bits(1.0 / 3.0))
        p.csrr('a0', 'fflags'); p.check(h, 'fflags.NX', 'a0', 0x01)
        # Divide/square-root corner cases: each result is checked together with its own fflags, so a correct
        # flag cannot pass with a wrong value (review 2026-11-26). Operands loaded with FMV.W.X into f20/f21.
        div_cases = [('fdiv.7_2', 7.0, 2.0, 0), ('fdiv.1_7', 1.0, 7.0, 0), ('fdiv.neg10_4', -10.0, 4.0, 0),
                     ('fdiv.2_3.rne', 2.0, 3.0, 0), ('fdiv.2_3.rtz', 2.0, 3.0, 1), ('fdiv.2_3.rup', 2.0, 3.0, 3),
                     ('fdiv.neg2_3.rdn', -2.0, 3.0, 2), ('fdiv.1_0', 1.0, 0.0, 0), ('fdiv.0_0', 0.0, 0.0, 0)]
        for name, x, y, rm in div_cases:
            xb, yb = f32_bits(x), f32_bits(y)
            res, flg = f32_div(xb, yb, rm)
            p.li('a0', xb); p.fmv_w_x(20, 'a0'); p.li('a0', yb); p.fmv_w_x(21, 'a0')
            p.csrw('fflags', 'zero')
            p.fdiv_s(22, 20, 21, rm=rm); p.fmv_x_w('a0', 22); p.check(h, name, 'a0', res)
            p.csrr('a0', 'fflags'); p.check(h, name + '.flags', 'a0', flg)
        sqrt_cases = [('fsqrt.2.rne', 2.0, 0), ('fsqrt.2.rup', 2.0, 3), ('fsqrt.0p25', 0.25, 0),
                      ('fsqrt.neg1', -1.0, 0)]
        for name, x, rm in sqrt_cases:
            xb = f32_bits(x)
            res, flg = f32_sqrt(xb, rm)
            p.li('a0', xb); p.fmv_w_x(20, 'a0')
            p.csrw('fflags', 'zero')
            p.fsqrt_s(22, 20, rm=rm); p.fmv_x_w('a0', 22); p.check(h, name, 'a0', res)
            p.csrr('a0', 'fflags'); p.check(h, name + '.flags', 'a0', flg)
        lab = f'tc03_faddd_h{h}'
        p.label(lab); p.raw(Prog.RV64_ONLY['fadd.d'](), 'fadd.d (must trap)'); exp_trap(p, h, 2, lab)
        p.done()


# ============================================================================ TC-04
def tc04(p, harts):
    """TC-04 priority P1. Objective: cached load/store and read sharing between harts with 34-bit addresses.
    Spec: REQ-XL-006, REQ-XL-007, REQ-XL-009; TEST-106, TEST-107, TEST-109. Config: 2 and 4 harts.
    Sequence: hart 0 writes 8 words over two lines and publishes a flag; every other hart waits for the flag,
    reads the words, writes its own block and publishes; hart 0 reads every block.
    Method: values from this oracle; AXI address bits 63:34 checked by MEM-19/20 and SVA-103.
    Failure mode: stale data, lost store, wrong line address. Checks: 8 reads per reader, hart 0 reads 4
    words of every other hart."""
    prologue(p, harts)
    p.flags |= 4                        # cached sharing between harts: SVA-104 required
    flag = DATA + 0x2000
    for h in range(harts):
        p.label(f'main_h{h}')
        if h == 0:
            p.li('a1', DATA)
            for k in range(8):
                p.li('a0', 0xA000_0000 + k); p.sw('a0', 'a1', 4 * k)
            p.li('a2', flag); p.li('a0', 1); p.fence(); p.sw('a0', 'a2', 0)
            for o in range(1, harts):
                p.li('a2', flag + 0x40 * o)
                p.label(f'tc04_w{o}')
                p.lw('a0', 'a2', 0)
                p.beqz('a0', f'tc04_w{o}')
                p.li('a1', DATA + 0x400 * o)
                for k in range(4):
                    p.lw('a0', 'a1', 4 * k); p.check(0, f'read.h{o}.w{k}', 'a0', 0xB000_0000 + 0x100 * o + k)
        else:
            p.li('a2', flag)
            p.label(f'tc04_wait_h{h}')
            p.lw('a0', 'a2', 0)
            p.beqz('a0', f'tc04_wait_h{h}')
            p.li('a1', DATA)
            for k in range(8):
                p.lw('a0', 'a1', 4 * k); p.check(h, f'read.w{k}', 'a0', 0xA000_0000 + k)
            p.li('a1', DATA + 0x400 * h)
            for k in range(4):
                p.li('a0', 0xB000_0000 + 0x100 * h + k); p.sw('a0', 'a1', 4 * k)
            p.li('a2', flag + 0x40 * h); p.li('a0', 1); p.fence(); p.sw('a0', 'a2', 0)
        p.done()


# ============================================================================ TC-05
def tc05(p, harts):
    """TC-05 (WF-101) priority P1. Objective: dirty-owner transfer with RV32 line addresses.
    Spec: REQ-XL-007, REQ-XL-009, REQ-XL-012; TEST-107, TEST-109, TEST-112; WF-101. Config: 2 harts.
    Sequence: four ping-pong rounds on one line X: the owner writes X (M state) and publishes a token; the
    other hart reads X (dirty-owner probe and writeback), checks it, increments it and passes the token back.
    Method: values from this oracle; SVA-101 on every probe line; full-line owner writebacks counted from the
    tile AXI ports (two 64-bit beats). Failure mode: stale data, probe on the wrong line, partial writeback.
    Checks: 4 values per hart, final value, full-line writeback count (testbench)."""
    prologue(p, harts)
    p.flags |= 4                        # cached sharing between harts: SVA-104 required
    X = DATA + 0x3000
    TOK = DATA + 0x3100
    rounds = 4
    for h in range(2):
        p.label(f'main_h{h}')
        p.li('a1', X); p.li('a2', TOK)
        val = 0x5A5A_0000
        for rnd in range(rounds):
            owner = rnd % 2
            if h == owner:
                if rnd == 0:
                    p.li('a0', val); p.sw('a0', 'a1', 0); p.sw('a0', 'a1', 4); p.sw('a0', 'a1', 8); p.sw('a0', 'a1', 12)
                p.fence()
                p.li('a0', rnd + 1); p.sw('a0', 'a2', 0)
            else:
                p.li('a3', rnd + 1)
                p.label(f'tc05_wait_r{rnd}_h{h}')
                p.lw('a0', 'a2', 0)
                p.bne('a0', 'a3', f'tc05_wait_r{rnd}_h{h}')
                exp = val + rnd
                p.lw('a0', 'a1', 0); p.check(h, f'r{rnd}.w0', 'a0', exp)
                p.lw('a0', 'a1', 12); p.check(h, f'r{rnd}.w3', 'a0', exp if rnd == 0 else val)
                p.addi('a0', 'a0', 0)
                p.lw('a0', 'a1', 0); p.addi('a0', 'a0', 1); p.sw('a0', 'a1', 0)
        p.fence()
        p.lw('a0', 'a1', 0)
        if h == 0:
            # hart 0 is the reader of the last round (rnd 3) and then increments: final = val + rounds
            p.check(h, 'final', 'a0', val + rounds)
        p.done()
    for h in range(2, harts):
        p.label(f'main_h{h}')
        p.done()


# ============================================================================ TC-06
def tc06(p, harts):
    """TC-06 priority P1. Objective: LR.W/SC.W and AMO*.W across harts on cached memory.
    Spec: REQ-XL-003, REQ-XL-012; TEST-103, TEST-112. Config: 2 and 4 harts.
    Sequence: every hart adds 1 eight times with AMOADD.W and four times with an LR.W/SC.W loop to one counter;
    each hart runs AMOSWAP/AMOXOR/AMOAND/AMOOR/AMOMAX/AMOMINU on a private word; SC without reservation
    fails; a barrier ends the phase and hart 0 reads the counter.
    Method: old values and final values from this oracle. Failure mode: lost update, wrong old value, SC
    success without reservation. Checks: 6 private AMO old values, private final, SC fail, counter final."""
    prologue(p, harts)
    p.flags |= 4                        # cached sharing between harts: SVA-104 required
    CNT = DATA + 0x4000
    BAR = DATA + 0x4040
    for h in range(harts):
        p.label(f'main_h{h}')
        p.li('a1', CNT); p.li('a2', 1)
        for _ in range(8):
            p.amoadd_w('zero', 'a2', 'a1')
        for k in range(4):
            p.label(f'tc06_lr_{k}_h{h}')
            p.lr_w('a0', 'a1')
            p.addi('a0', 'a0', 1)
            p.sc_w('a3', 'a0', 'a1')
            p.bnez('a3', f'tc06_lr_{k}_h{h}')
        priv = DATA + 0x4100 + 0x40 * h
        p.li('a4', priv)
        v = 0x0F0F_0F0F + h
        p.li('a0', v); p.sw('a0', 'a4', 0)
        seq = [('amoswap', p.amoswap_w, 0x1234_5678, lambda o, x: x),
               ('amoxor', p.amoxor_w, 0xFFFF_0000, lambda o, x: o ^ x),
               ('amoand', p.amoand_w, 0xF0F0_FFFF, lambda o, x: o & x),
               ('amoor', p.amoor_w, 0x0000_0101, lambda o, x: o | x),
               ('amomax', p.amomax_w, 0x7000_0000, lambda o, x: u32(max(s32(o), s32(x)))),
               ('amominu', p.amominu_w, 0x0000_1000, lambda o, x: min(o, x))]
        cur = v
        for name, fn, operand, f in seq:
            p.li('a5', operand)
            fn('a0', 'a5', 'a4')
            p.check(h, f'{name}.old', 'a0', cur)
            cur = f(cur, operand)
        p.lw('a0', 'a4', 0); p.check(h, 'private.final', 'a0', cur)
        p.lr_w('a0', 'a4'); p.sc_w('a3', 'a0', 'a4')          # pair succeeds
        p.sc_w('a3', 'a0', 'a4'); p.check(h, 'sc.no_reservation', 'a3', 1)
        barrier(p, h, harts, BAR, 'tc06')
        if h == 0:
            p.lw('a0', 'a1', 0); p.check(0, 'counter.final', 'a0', 12 * harts)
        p.done()


# ============================================================================ TC-07
def tc07(p, harts):
    """TC-07 priority P1. Objective: CBO.CLEAN, CBO.FLUSH, CBO.INVAL and FENCE.I with 32-bit addresses.
    Spec: REQ-XL-008, REQ-XL-012; TEST-112. Config: 2 harts.
    Sequence: hart 0 writes line A then CBO.CLEAN, line B then CBO.FLUSH, line C then CBO.INVAL; writes two
    instructions to memory, FENCE.I, and executes them; hart 1 reads lines A and B after a barrier.
    Method: memory-model words after the run, values from this oracle; CMO virtual address upper half
    checked by the testbench. Failure mode: dirty data not written back, wrong line, stale instruction.
    Checks: memory words of A and B, hart 1 reads, FENCE.I result, completion of CBO.INVAL."""
    prologue(p, harts)
    p.flags |= 4                        # cached sharing between harts: SVA-104 required
    A, Bl, C = DATA + 0x5000, DATA + 0x5040, DATA + 0x5080
    BAR = DATA + 0x5100
    CODE = BASE + 0x3800
    p.flags |= 1                        # CBO.CLEAN/FLUSH write to DRAM
    for h in range(harts):
        p.label(f'main_h{h}')
        if h == 0:
            p.li('a1', A)
            for k in range(4):
                p.li('a0', 0xC1EA_0000 + k); p.sw('a0', 'a1', 4 * k)
                p.mem_expect.append((A + 4 * k, 0xC1EA_0000 + k))
            p.cbo_clean('a1')
            p.li('a0', 0xC1); p.check(0, 'cbo.clean.completed', 'a0', 0xC1)
            p.li('a1', Bl)
            for k in range(4):
                p.li('a0', 0xF1A5_0000 + k); p.sw('a0', 'a1', 4 * k)
                p.mem_expect.append((Bl + 4 * k, 0xF1A5_0000 + k))
            p.cbo_flush('a1')
            p.li('a0', 0xF1); p.check(0, 'cbo.flush.completed', 'a0', 0xF1)
            p.li('a1', C)
            p.li('a0', 0x1BAD_0001); p.sw('a0', 'a1', 0)
            p.lw('a2', 'a1', 0); p.check(0, 'line.C.store', 'a2', 0x1BAD_0001)
            p.cbo_inval('a1')
            p.li('a0', 1); p.check(0, 'cbo.inval.completed', 'a0', 1)
            p.li('a1', CODE)
            p.li('a0', (0x55 << 20) | (10 << 7) | 0x13); p.sw('a0', 'a1', 0)      # addi a0, x0, 0x55
            p.li('a0', (1 << 15) | 0x67); p.sw('a0', 'a1', 4)                   # jalr x0, 0(ra)
            p.fence_i()
            p.li('a0', 0)
            p.jalr('ra', 'a1', 0)
            p.check(0, 'fence.i.exec', 'a0', 0x55)
        part = int(__import__('os').environ.get('TC07_PART', harts))   # diagnostic: harts in the barrier
        if h >= part:
            p.done()
            continue
        barrier(p, h, part, BAR, 'tc07')
        if h == 1:
            p.li('a1', A); p.lw('a0', 'a1', 4); p.check(1, 'read.A.w1', 'a0', 0xC1EA_0001)
            p.li('a1', Bl); p.lw('a0', 'a1', 8); p.check(1, 'read.B.w2', 'a0', 0xF1A5_0002)
        p.done()


# ============================================================================ TC-08
def tc08(p, harts):
    """TC-08 priority P1. Objective: Sv32 two-level walk, 4 KiB and 4 MiB pages, S/U modes, page faults.
    Spec: REQ-XL-005; TEST-105. Config: 2 harts (each hart uses its own page tables and data pages).
    Sequence: M-mode builds the tables, enters S-mode with MRET; S stores and loads through a 4 KiB page,
    loads from a U page with SUM=0 (load page fault); enters U-mode with SRET; U loads its page, loads an
    S page (load page fault) and ECALLs back to M-mode.
    Method: physical locations and causes from the Sv32 definition. Failure mode: wrong translation,
    missing fault, 64-bit PTE format. Checks: S value, memory word via M, two page faults (cause, epc),
    U value, ECALL cause/epc."""
    prologue(p, harts)
    for h in range(harts):
        root = BASE + 0x20000 + 0x4000 * h
        l0 = root + 0x1000
        pa_s = BASE + 0x30000 + 0x4000 * h      # S page
        pa_u = pa_s + 0x1000                     # U data page
        ucode_pa = BASE + 0x3000                 # U code page (shared, read-only use)
        V, R, W, X, U, G, A_, D = 1, 2, 4, 8, 16, 32, 64, 128

        def pte(pa, flags):
            return ((pa >> 12) << 10) | flags
        p.label(f'main_h{h}')
        p.li('a1', root)
        # superpages (VPN1 index = VA >> 22): code/data 0x8000_0000, MMIO 0x1000_0000
        p.li('a2', root + 4 * (BASE >> 22))
        p.li('a0', pte(BASE, V | R | W | X | A_ | D)); p.sw('a0', 'a2', 0)
        p.li('a0', pte(MMIO_BASE, V | R | W | A_ | D)); p.sw('a0', 'a1', 4 * (MMIO_BASE >> 22))
        p.li('a0', pte(l0, V)); p.sw('a0', 'a1', 4 * (0x4000_0000 >> 22))
        p.li('a1', l0)
        p.li('a0', pte(pa_s, V | R | W | A_ | D)); p.sw('a0', 'a1', 0)                # VA 0x4000_0000 S page
        p.li('a0', pte(pa_u, V | R | W | U | A_ | D)); p.sw('a0', 'a1', 4)            # VA 0x4000_1000 U page
        p.li('a0', pte(ucode_pa, V | R | X | U | A_)); p.sw('a0', 'a1', 8)            # VA 0x4000_2000 U code
        p.li('a1', pa_u); p.li('a0', 0x0055_AA00 + h); p.sw('a0', 'a1', 0)
        # PMP entry 0: NAPOT over the whole 34-bit space, RWX, so S/U accesses are allowed (Privileged ISA 3.7)
        p.li('a0', 0xFFFF_FFFF); p.csrw('pmpaddr0', 'a0'); p.li('a0', 0x1F); p.csrw('pmpcfg0', 'a0')
        p.fence()
        p.li('a0', (1 << 31) | (root >> 12)); p.csrw('satp', 'a0'); p.sfence_vma()
        # MRET to S-mode at s_entry
        p.li('a0', 0x1800); p.csrc('mstatus', 'a0'); p.li('a0', 0x0800); p.csrs('mstatus', 'a0')
        p.la('a0', f'tc08_s_h{h}'); p.csrw('mepc', 'a0'); p.mret()
        p.label(f'tc08_s_h{h}')
        p.li('a1', 0x4000_0000); p.li('a0', 0x5EED_0000 + h); p.sw('a0', 'a1', 16)
        p.lw('a2', 'a1', 16); p.check(h, 's.load', 'a2', 0x5EED_0000 + h)
        p.li('a1', 0x4000_1000)
        lab = f'tc08_sum_h{h}'
        p.label(lab); p.lw('a2', 'a1', 0); exp_trap(p, h, 13, lab)
        # SRET to U-mode at VA 0x4000_2000 + offset of the U routine
        p.li('a0', 0x100); p.csrc('sstatus', 'a0')
        p.li('a0', 0x4000_2000 + (h * 0x40)); p.csrw('sepc', 'a0')
        p.la('t4', f'tc08_back_h{h}')
        p.sret()
        p.label(f'tc08_back_h{h}')          # M-mode after the U ECALL
        p.check(h, 'u.load', 'a2', 0x0055_AA00 + h)
        p.csrw('satp', 'zero')
        p.li('a1', pa_s); p.lw('a0', 'a1', 16); p.check(h, 'pa.s.word', 'a0', 0x5EED_0000 + h)
        p.done()
        # U-mode traps: mepc holds the virtual address (Privileged ISA 3.1.14), VA = PA - 0x8000_3000 + 0x4000_2000
        p.expect[h] += [('trap.mcause', 13), ('trap.mepc.va@tc08_ufault', ('labelva', f'tc08_ufault_h{h}')),
                        ('trap.mcause', 8), ('trap.mepc.va@tc08_uecall', ('labelva', f'tc08_uecall_h{h}'))]
    # U routines at PA 0x8000_3000 + 0x40*h (VA 0x4000_2000 + 0x40*h)
    for h in range(harts):
        p.org(0x3000 + 0x40 * h)
        p.li('a1', 0x4000_1000); p.lw('a2', 'a1', 0)
        p.li('a1', 0x4000_0000)
        p.label(f'tc08_ufault_h{h}'); p.lw('a3', 'a1', 0)
        p.label(f'tc08_uecall_h{h}'); p.ecall()
    _reorder_tc08(p, harts)


def _reorder_tc08(p, harts):
    # The trap entries of the U routine are reported before u.load/pa.s.word: move them into place.
    for h in range(harts):
        e = p.expect[h]
        tail = e[-4:]
        del e[-4:]
        idx = next(i for i, (n, _) in enumerate(e) if n == 'u.load')
        e[idx:idx] = tail


# ============================================================================ TC-09
def tc09(p, harts):
    """TC-09 priority P2. Objective: MMIO writes and reads through the MMIO port in program order.
    Spec: REQ-XL-006, REQ-XL-010; TEST-106, TEST-110. Config: 2 harts.
    Sequence: hart 0 writes four device registers, reads two back and publishes a cached flag; hart 1 waits
    and reads register 0.
    Method: device-model write log against the program order; read-back values from this oracle; MMIO-19..23
    on every access. Failure mode: reordered or lost MMIO store, MMIO routed to memory. Checks: 4 write-order
    entries, 2 hart-0 reads, 1 hart-1 read."""
    prologue(p, harts)
    REGS = MMIO_BASE + 0x800
    FLAG = DATA + 0x6000
    vals = [0xD0D0_0001, 0xD0D0_0002, 0xD0D0_0003, 0xD0D0_0004]
    p.mmio_expect = []
    p.flags |= 2                        # MMIO reads
    for h in range(harts):
        p.label(f'main_h{h}')
        if h == 0:
            p.li('a1', REGS)
            for k, v in enumerate(vals):
                p.li('a0', v); p.sw('a0', 'a1', 4 * k)
                p.mmio_expect.append((REGS + 4 * k, v))
            p.lw('a0', 'a1', 4); p.check(0, 'mmio.read1', 'a0', vals[1])
            p.lw('a0', 'a1', 12); p.check(0, 'mmio.read3', 'a0', vals[3])
            p.li('a2', FLAG); p.li('a0', 1); p.fence(); p.sw('a0', 'a2', 0)
        elif h == 1:
            p.li('a2', FLAG)
            p.label('tc09_wait')
            p.lw('a0', 'a2', 0); p.beqz('a0', 'tc09_wait')
            p.fence()
            p.li('a1', REGS); p.lw('a0', 'a1', 0); p.check(1, 'mmio.read0.h1', 'a0', vals[0])
        p.done()


# ============================================================================ TC-10
def tc10(p, harts):
    """TC-10 priority P2. Objective: boot address upper half and reset release.
    Spec: REQ-XL-008; TEST-108; SVA-102. Config: 2 harts; positive run BOOT_HI=0, negative run BOOT_HI=1
    (SVA-102 shall fail).
    Sequence: every hart boots, reports its boot PC, its hart id and a store/load through cached memory.
    Method: oracle values; SVA-102 in the bind file. Failure mode: core uses bits 63:32 of i_boot_addr.
    Checks: boot.pc, mhartid, cached round trip, done marker; negative run: SVA-102 failure reported."""
    prologue(p, harts)
    for h in range(harts):
        p.label(f'main_h{h}')
        p.check(h, 'boot.pc', 's9', BASE)
        p.check(h, 'mhartid', 't0', h)
        p.li('a1', DATA + 0x7000 + 0x40 * h); p.li('a0', 0xB007_0000 + h); p.sw('a0', 'a1', 0)
        p.lw('a2', 'a1', 0); p.check(h, 'cached.roundtrip', 'a2', 0xB007_0000 + h)
        p.done()


CASES = {'TC-01': tc01, 'TC-02': tc02, 'TC-03': tc03, 'TC-04': tc04, 'TC-05': tc05, 'TC-06': tc06,
         'TC-07': tc07, 'TC-08': tc08, 'TC-09': tc09, 'TC-10': tc10}


def write_case(tc, harts, run_dir):
    p = Prog()
    p.mmio_expect = []
    p.flags = 0
    CASES[tc](p, harts)
    img = p.image64(131072)
    last = max(i for i, v in enumerate(img) if v) + 1
    (run_dir / 'program.hex').write_text('\n'.join('%016x' % v for v in img[:max(last, 1)]) + '\n')
    names = []
    meta = [0] * 8
    for h in range(harts):
        vals = []
        for name, v in p.expect.get(h, []):
            if isinstance(v, tuple) and v[0] == 'labelva':
                v = p.labels[v[1]] - 0x3000 + 0x4000_2000
            elif isinstance(v, tuple):
                v = p.addr(v[1])
            vals.append(u32(v))
            names.append(f'h{h}#{len(vals) - 1} {name} {u32(v):08x}')
        meta[h] = len(vals)
        (run_dir / f'exp_h{h}.hex').write_text('\n'.join('%08x' % v for v in vals) + '\n')
    meta[5] = len(p.mem_expect)
    (run_dir / 'memchk.hex').write_text(''.join('%08x\n%08x\n' % (a, v) for a, v in p.mem_expect) or '0\n')
    meta[6] = len(p.mmio_expect)
    (run_dir / 'mmioexp.hex').write_text(''.join('%08x\n%08x\n' % (a, v) for a, v in p.mmio_expect) or '0\n')
    meta[7] = p.flags
    (run_dir / 'meta.hex').write_text('\n'.join('%08x' % v for v in meta) + '\n')
    (run_dir / 'checks.txt').write_text('\n'.join(names) + '\n')
    (run_dir / 'listing.txt').write_text('\n'.join(p.listing) + '\n')
    return p
