"""Independent RV32 instruction encoder and program builder for the RV32 profile testbench.

Source: RISC-V Unprivileged ISA (RV32I, M, A, F, C/Zcb, B, Zicond, Zicbom) and Privileged ISA
(CSRs, MRET/SRET, Sv32). Nothing here is derived from the DUT RTL (rule R-023).

Program convention (doc/specification_32 TEST_PLAN.md):
  * one image at 0x8000_0000 shared by every hart;
  * each hart reports results with 32-bit stores to its MMIO signature port
    SIG(h) = 0x1000_0000 + 0x100*h (sequence of check values, offset 0x00) and
    signals completion by storing 0x600D to SIG(h)+0x80;
  * x26 (s10) holds SIG(h); x27 (s11) is reserved; x29-x31 (t4-t6) belong to the trap handler.
"""
import os
import struct

BASE = 0x8000_0000
MMIO_BASE = 0x1000_0000
SIG_STRIDE = 0x100
DONE_OFF = 0x80
DONE_VALUE = 0x600D
MASK32 = 0xFFFF_FFFF

REG = {f'x{i}': i for i in range(32)}
REG.update({'zero': 0, 'ra': 1, 'sp': 2, 'gp': 3, 'tp': 4, 't0': 5, 't1': 6, 't2': 7, 's0': 8, 's1': 9,
            'a0': 10, 'a1': 11, 'a2': 12, 'a3': 13, 'a4': 14, 'a5': 15, 'a6': 16, 'a7': 17,
            's2': 18, 's3': 19, 's4': 20, 's5': 21, 's6': 22, 's7': 23, 's8': 24, 's9': 25,
            's10': 26, 's11': 27, 't3': 28, 't4': 29, 't5': 30, 't6': 31})
CSR = {'mstatus': 0x300, 'misa': 0x301, 'medeleg': 0x302, 'mideleg': 0x303, 'mie': 0x304, 'mtvec': 0x305,
       'mscratch': 0x340, 'mepc': 0x341, 'mcause': 0x342, 'mtval': 0x343, 'mhartid': 0xF14,
       'satp': 0x180, 'sstatus': 0x100, 'sepc': 0x141, 'fflags': 0x001, 'frm': 0x002, 'fcsr': 0x003,
       'cycle': 0xC00, 'instret': 0xC02, 'cycleh': 0xC80, 'instreth': 0xC82,
       'mcycle': 0xB00, 'mcycleh': 0xB80, 'minstret': 0xB02, 'minstreth': 0xB82,
       'mcounteren': 0x306, 'pmpcfg0': 0x3A0, 'pmpaddr0': 0x3B0, 'scounteren': 0x106, 'menvcfg': 0x30A}


def r(x):
    return REG[x] if isinstance(x, str) else x


def u32(v):
    return v & MASK32


def s32(v):
    v &= MASK32
    return v - (1 << 32) if v & 0x8000_0000 else v


def f32_bits(x):
    return struct.unpack('<I', struct.pack('<f', x))[0]


class Prog:
    """Builds one memory image; words are 32-bit, compressed instructions take 16 bits."""

    def __init__(self, base=BASE):
        self.base = base
        # VLSIT_TB_XLEN=64 runs the same RV32 program on the 64-bit cluster (step 2a): LUI sign-extends
        # there, so li zero-extends values in the DRAM window [BASE, BASE + 1 GiB) to keep them addresses.
        self.xlen = int(os.environ.get('VLSIT_TB_XLEN', '32'))
        self.hw = {}            # halfword offset -> 16-bit value
        self.pc = 0             # byte offset
        self.labels = {}
        self.fix = []           # (offset, kind, label)
        self.expect = {}        # hart -> list of (check_name, expected value)
        self.mem_expect = []    # (address, 32-bit value) to compare in the memory model at the end
        self.listing = []

    # ---------------------------------------------------------------- emission
    def _put32(self, w, txt):
        assert self.pc % 2 == 0
        self.hw[self.pc // 2] = w & 0xFFFF
        self.hw[self.pc // 2 + 1] = (w >> 16) & 0xFFFF
        self.listing.append('%08x: %08x  %s' % (self.base + self.pc, w & MASK32, txt))
        self.pc += 4

    def _put16(self, h, txt):
        self.hw[self.pc // 2] = h & 0xFFFF
        self.listing.append('%08x: %04x      %s' % (self.base + self.pc, h & 0xFFFF, txt))
        self.pc += 2

    def align(self, n):
        while self.pc % n:
            self.nop() if self.pc % 4 == 0 else self._put16(0x0001, 'c.nop')

    def org(self, off):
        assert off >= self.pc, (hex(off), hex(self.pc))
        self.pc = off

    def label(self, name):
        assert name not in self.labels, name
        self.labels[name] = self.pc

    def addr(self, name):
        return self.base + self.labels[name]

    def word(self, v, txt='.word'):
        self._put32(u32(v), txt)

    # ---------------------------------------------------------------- base formats
    def R(self, f7, rs2, rs1, f3, rd, op, txt):
        self._put32((f7 << 25) | (r(rs2) << 20) | (r(rs1) << 15) | (f3 << 12) | (r(rd) << 7) | op, txt)

    def I(self, imm, rs1, f3, rd, op, txt):
        self._put32(((imm & 0xFFF) << 20) | (r(rs1) << 15) | (f3 << 12) | (r(rd) << 7) | op, txt)

    def S(self, imm, rs2, rs1, f3, op, txt):
        assert -2048 <= imm <= 2047, ('store offset out of range', txt)
        self._put32((((imm >> 5) & 0x7F) << 25) | (r(rs2) << 20) | (r(rs1) << 15) | (f3 << 12)
                    | ((imm & 0x1F) << 7) | op, txt)

    def U(self, imm20, rd, op, txt):
        self._put32(((imm20 & 0xFFFFF) << 12) | (r(rd) << 7) | op, txt)

    # ---------------------------------------------------------------- RV32I
    def lui(self, rd, imm20): self.U(imm20, rd, 0x37, f'lui {rd},0x{imm20 & 0xFFFFF:x}')
    def auipc(self, rd, imm20): self.U(imm20, rd, 0x17, f'auipc {rd},0x{imm20 & 0xFFFFF:x}')
    def addi(self, rd, rs, imm): self.I(imm, rs, 0, rd, 0x13, f'addi {rd},{rs},{imm}')
    def slti(self, rd, rs, imm): self.I(imm, rs, 2, rd, 0x13, f'slti {rd},{rs},{imm}')
    def sltiu(self, rd, rs, imm): self.I(imm, rs, 3, rd, 0x13, f'sltiu {rd},{rs},{imm}')
    def xori(self, rd, rs, imm): self.I(imm, rs, 4, rd, 0x13, f'xori {rd},{rs},{imm}')
    def ori(self, rd, rs, imm): self.I(imm, rs, 6, rd, 0x13, f'ori {rd},{rs},{imm}')
    def andi(self, rd, rs, imm): self.I(imm, rs, 7, rd, 0x13, f'andi {rd},{rs},{imm}')
    def slli(self, rd, rs, sh): self.I(sh & 31, rs, 1, rd, 0x13, f'slli {rd},{rs},{sh}')
    def srli(self, rd, rs, sh): self.I(sh & 31, rs, 5, rd, 0x13, f'srli {rd},{rs},{sh}')
    def srai(self, rd, rs, sh): self.I(0x400 | (sh & 31), rs, 5, rd, 0x13, f'srai {rd},{rs},{sh}')
    def add(self, rd, a, b): self.R(0, b, a, 0, rd, 0x33, f'add {rd},{a},{b}')
    def sub(self, rd, a, b): self.R(0x20, b, a, 0, rd, 0x33, f'sub {rd},{a},{b}')
    def sll(self, rd, a, b): self.R(0, b, a, 1, rd, 0x33, f'sll {rd},{a},{b}')
    def slt(self, rd, a, b): self.R(0, b, a, 2, rd, 0x33, f'slt {rd},{a},{b}')
    def sltu(self, rd, a, b): self.R(0, b, a, 3, rd, 0x33, f'sltu {rd},{a},{b}')
    def xor(self, rd, a, b): self.R(0, b, a, 4, rd, 0x33, f'xor {rd},{a},{b}')
    def srl(self, rd, a, b): self.R(0, b, a, 5, rd, 0x33, f'srl {rd},{a},{b}')
    def sra(self, rd, a, b): self.R(0x20, b, a, 5, rd, 0x33, f'sra {rd},{a},{b}')
    def or_(self, rd, a, b): self.R(0, b, a, 6, rd, 0x33, f'or {rd},{a},{b}')
    def and_(self, rd, a, b): self.R(0, b, a, 7, rd, 0x33, f'and {rd},{a},{b}')
    def lw(self, rd, rs, off=0):
        assert -2048 <= off <= 2047, 'load offset out of range'
        self.I(off, rs, 2, rd, 0x03, f'lw {rd},{off}({rs})')
    def lh(self, rd, rs, off=0): self.I(off, rs, 1, rd, 0x03, f'lh {rd},{off}({rs})')
    def lbu(self, rd, rs, off=0): self.I(off, rs, 4, rd, 0x03, f'lbu {rd},{off}({rs})')
    def sw(self, rs2, rs, off=0): self.S(off, rs2, rs, 2, 0x23, f'sw {rs2},{off}({rs})')
    def sb(self, rs2, rs, off=0): self.S(off, rs2, rs, 0, 0x23, f'sb {rs2},{off}({rs})')
    def nop(self): self.addi('zero', 'zero', 0)
    def fence(self): self._put32(0x0FF0000F, 'fence iorw,iorw')
    def fence_i(self): self._put32(0x0000100F, 'fence.i')
    def ecall(self): self._put32(0x00000073, 'ecall')
    def mret(self): self._put32(0x30200073, 'mret')
    def sret(self): self._put32(0x10200073, 'sret')
    def sfence_vma(self): self._put32(0x12000073, 'sfence.vma')
    def wfi(self): self._put32(0x10500073, 'wfi')

    def li(self, rd, value):
        v = u32(value)
        lo = ((v & 0xFFF) ^ 0x800) - 0x800
        hi = u32(v - lo) >> 12
        if hi:
            self.lui(rd, hi)
            if lo:
                self.addi(rd, rd, lo)
            if self.xlen == 64 and BASE <= v < BASE + 0x4000_0000:
                self.I(32, rd, 1, rd, 0x13, f'slli {rd},{rd},32 (rv64)')
                self.I(32, rd, 5, rd, 0x13, f'srli {rd},{rd},32 (rv64)')
        else:
            self.addi(rd, 'zero', lo)

    def la(self, rd, name):
        self.fix.append((self.pc, 'la', name, rd))
        self._put32(0, f'la.hi {rd},{name}')
        self._put32(0, f'la.lo {rd},{name}')

    def _b(self, f3, a, b, name, mnem):
        self.fix.append((self.pc, 'b', name, (f3, r(a), r(b))))
        self._put32(0, f'{mnem} {a},{b},{name}')

    def beq(self, a, b, n): self._b(0, a, b, n, 'beq')
    def bne(self, a, b, n): self._b(1, a, b, n, 'bne')
    def blt(self, a, b, n): self._b(4, a, b, n, 'blt')
    def bge(self, a, b, n): self._b(5, a, b, n, 'bge')
    def bltu(self, a, b, n): self._b(6, a, b, n, 'bltu')
    def bgeu(self, a, b, n): self._b(7, a, b, n, 'bgeu')
    def beqz(self, a, n): self.beq(a, 'zero', n)
    def bnez(self, a, n): self.bne(a, 'zero', n)

    def j(self, name, rd='zero'):
        self.fix.append((self.pc, 'j', name, r(rd)))
        self._put32(0, f'jal {rd},{name}')

    def jalr(self, rd, rs, off=0): self.I(off, rs, 0, rd, 0x67, f'jalr {rd},{off}({rs})')

    # ---------------------------------------------------------------- CSR
    def csrrw(self, rd, csr, rs): self.I(CSR[csr], rs, 1, rd, 0x73, f'csrrw {rd},{csr},{rs}')
    def csrrs(self, rd, csr, rs): self.I(CSR[csr], rs, 2, rd, 0x73, f'csrrs {rd},{csr},{rs}')
    def csrrc(self, rd, csr, rs): self.I(CSR[csr], rs, 3, rd, 0x73, f'csrrc {rd},{csr},{rs}')
    def csrr(self, rd, csr): self.csrrs(rd, csr, 'zero')
    def csrw(self, csr, rs): self.csrrw('zero', csr, rs)
    def csrs(self, csr, rs): self.csrrs('zero', csr, rs)
    def csrc(self, csr, rs): self.csrrc('zero', csr, rs)

    # ---------------------------------------------------------------- M
    def mul(self, rd, a, b): self.R(1, b, a, 0, rd, 0x33, f'mul {rd},{a},{b}')
    def mulh(self, rd, a, b): self.R(1, b, a, 1, rd, 0x33, f'mulh {rd},{a},{b}')
    def mulhu(self, rd, a, b): self.R(1, b, a, 3, rd, 0x33, f'mulhu {rd},{a},{b}')
    def div(self, rd, a, b): self.R(1, b, a, 4, rd, 0x33, f'div {rd},{a},{b}')
    def divu(self, rd, a, b): self.R(1, b, a, 5, rd, 0x33, f'divu {rd},{a},{b}')
    def rem(self, rd, a, b): self.R(1, b, a, 6, rd, 0x33, f'rem {rd},{a},{b}')
    def remu(self, rd, a, b): self.R(1, b, a, 7, rd, 0x33, f'remu {rd},{a},{b}')

    # ---------------------------------------------------------------- A (word only on RV32)
    def _amo(self, f5, rd, rs2, rs1, name, aq=0, rl=0):
        self.R((f5 << 2) | (aq << 1) | rl, rs2, rs1, 2, rd, 0x2F, f'{name}.w {rd},{rs2},({rs1})')

    def lr_w(self, rd, rs1): self._amo(0b00010, rd, 'zero', rs1, 'lr')
    def sc_w(self, rd, rs2, rs1): self._amo(0b00011, rd, rs2, rs1, 'sc')
    def amoswap_w(self, rd, rs2, rs1): self._amo(0b00001, rd, rs2, rs1, 'amoswap')
    def amoadd_w(self, rd, rs2, rs1): self._amo(0b00000, rd, rs2, rs1, 'amoadd')
    def amoxor_w(self, rd, rs2, rs1): self._amo(0b00100, rd, rs2, rs1, 'amoxor')
    def amoand_w(self, rd, rs2, rs1): self._amo(0b01100, rd, rs2, rs1, 'amoand')
    def amoor_w(self, rd, rs2, rs1): self._amo(0b01000, rd, rs2, rs1, 'amoor')
    def amomax_w(self, rd, rs2, rs1): self._amo(0b10100, rd, rs2, rs1, 'amomax')
    def amominu_w(self, rd, rs2, rs1): self._amo(0b11000, rd, rs2, rs1, 'amominu')

    # ---------------------------------------------------------------- B (Zba/Zbb/Zbc/Zbs) and Zicond
    def andn(self, rd, a, b): self.R(0x20, b, a, 7, rd, 0x33, f'andn {rd},{a},{b}')
    def min_(self, rd, a, b): self.R(0x05, b, a, 4, rd, 0x33, f'min {rd},{a},{b}')
    def maxu(self, rd, a, b): self.R(0x05, b, a, 7, rd, 0x33, f'maxu {rd},{a},{b}')
    def sh2add(self, rd, a, b): self.R(0x10, b, a, 4, rd, 0x33, f'sh2add {rd},{a},{b}')
    def ror(self, rd, a, b): self.R(0x30, b, a, 5, rd, 0x33, f'ror {rd},{a},{b}')
    def bset(self, rd, a, b): self.R(0x14, b, a, 1, rd, 0x33, f'bset {rd},{a},{b}')
    def bext(self, rd, a, b): self.R(0x24, b, a, 5, rd, 0x33, f'bext {rd},{a},{b}')
    def clmul(self, rd, a, b): self.R(0x05, b, a, 1, rd, 0x33, f'clmul {rd},{a},{b}')
    def clz(self, rd, a): self.I(0x600, a, 1, rd, 0x13, f'clz {rd},{a}')
    def cpop(self, rd, a): self.I(0x602, a, 1, rd, 0x13, f'cpop {rd},{a}')
    def sext_b(self, rd, a): self.I(0x604, a, 1, rd, 0x13, f'sext.b {rd},{a}')
    def rev8(self, rd, a): self.I(0x698, a, 5, rd, 0x13, f'rev8 {rd},{a}')
    def orc_b(self, rd, a): self.I(0x287, a, 5, rd, 0x13, f'orc.b {rd},{a}')
    def czero_eqz(self, rd, a, b): self.R(0x07, b, a, 5, rd, 0x33, f'czero.eqz {rd},{a},{b}')
    def czero_nez(self, rd, a, b): self.R(0x07, b, a, 7, rd, 0x33, f'czero.nez {rd},{a},{b}')

    # ---------------------------------------------------------------- Zcb (16-bit)
    @staticmethod
    def _cr(x):
        n = r(x)
        assert 8 <= n <= 15, x
        return n - 8

    def c_mul(self, rd, rs2): self._put16(0x9C41 | (self._cr(rd) << 7) | (self._cr(rs2) << 2), f'c.mul {rd},{rs2}')
    def c_not(self, rd): self._put16(0x9C75 | (self._cr(rd) << 7), f'c.not {rd}')
    def c_zext_b(self, rd): self._put16(0x9C61 | (self._cr(rd) << 7), f'c.zext.b {rd}')
    def c_sext_h(self, rd): self._put16(0x9C6D | (self._cr(rd) << 7), f'c.sext.h {rd}')

    def c_lbu(self, rd, rs1, uimm):
        assert 0 <= uimm <= 3
        self._put16(0x8000 | (self._cr(rs1) << 7) | ((uimm & 1) << 6) | (((uimm >> 1) & 1) << 5)
                    | (self._cr(rd) << 2), f'c.lbu {rd},{uimm}({rs1})')

    # ---------------------------------------------------------------- F (single precision only)
    def flw(self, fd, rs, off=0): self.I(off, rs, 2, fd, 0x07, f'flw f{fd},{off}({rs})')
    def fsw(self, fs, rs, off=0): self.S(off, fs, rs, 2, 0x27, f'fsw f{fs},{off}({rs})')
    def fadd_s(self, fd, a, b, rm=0): self.R(0x00, b, a, rm, fd, 0x53, f'fadd.s f{fd},f{a},f{b}')
    def fmul_s(self, fd, a, b, rm=0): self.R(0x08, b, a, rm, fd, 0x53, f'fmul.s f{fd},f{a},f{b}')
    def fdiv_s(self, fd, a, b, rm=0): self.R(0x0C, b, a, rm, fd, 0x53, f'fdiv.s f{fd},f{a},f{b}')
    def fsqrt_s(self, fd, a, rm=0): self.R(0x2C, 0, a, rm, fd, 0x53, f'fsqrt.s f{fd},f{a}')
    def fmv_w_x(self, fd, rs): self.R(0x78, 0, rs, 0, fd, 0x53, f'fmv.w.x f{fd},{rs}')
    def fmv_x_w(self, rd, fs): self.R(0x70, 0, fs, 0, rd, 0x53, f'fmv.x.w {rd},f{fs}')
    def fcvt_w_s(self, rd, fs, rm=1): self.R(0x60, 0, fs, rm, rd, 0x53, f'fcvt.w.s {rd},f{fs}')
    def flt_s(self, rd, a, b): self.R(0x50, b, a, 1, rd, 0x53, f'flt.s {rd},f{a},f{b}')

    # ---------------------------------------------------------------- Zicbom
    def cbo_inval(self, rs): self.I(0, rs, 2, 0, 0x0F, f'cbo.inval ({rs})')
    def cbo_clean(self, rs): self.I(1, rs, 2, 0, 0x0F, f'cbo.clean ({rs})')
    def cbo_flush(self, rs): self.I(2, rs, 2, 0, 0x0F, f'cbo.flush ({rs})')

    # ---------------------------------------------------------------- RV64-only and D encodings
    RV64_ONLY = {
        'addw': lambda: (0 << 25) | (6 << 20) | (5 << 15) | (0 << 12) | (7 << 7) | 0x3B,
        'ld': lambda: (0 << 20) | (10 << 15) | (3 << 12) | (7 << 7) | 0x03,
        'sd': lambda: (7 << 20) | (10 << 15) | (3 << 12) | 0x23,
        'amoadd.d': lambda: (0 << 27) | (6 << 20) | (10 << 15) | (3 << 12) | (7 << 7) | 0x2F,
        'lr.d': lambda: (0b00010 << 27) | (10 << 15) | (3 << 12) | (7 << 7) | 0x2F,
        'fadd.d': lambda: (0x01 << 25) | (2 << 20) | (1 << 15) | (0 << 12) | (3 << 7) | 0x53,
    }

    def raw(self, w, txt): self._put32(w, txt)

    # ---------------------------------------------------------------- reporting helpers
    def check(self, hart, name, reg, expected):
        """Store reg to the hart's signature port and record the expected value."""
        self.sw(reg, 's10', 0)
        self.expect.setdefault(hart, []).append((name, u32(expected)))

    def done(self):
        self.li('t3', DONE_VALUE)
        self.sw('t3', 's10', DONE_OFF)
        self.label_unique('spin')

    def label_unique(self, stem):
        n = 0
        while f'{stem}{n}' in self.labels:
            n += 1
        self.label(f'{stem}{n}')
        self.j(f'{stem}{n}')

    # ---------------------------------------------------------------- resolve and write
    def resolve(self):
        for off, kind, name, arg in self.fix:
            tgt = self.labels[name]
            if kind == 'b':
                f3, a, b = arg
                d = tgt - off
                assert -4096 <= d < 4096 and d % 2 == 0, (name, d)
                w = ((((d >> 12) & 1) << 31) | (((d >> 5) & 0x3F) << 25) | (b << 20) | (a << 15)
                     | (f3 << 12) | (((d >> 1) & 0xF) << 8) | (((d >> 11) & 1) << 7) | 0x63)
            elif kind == 'j':
                d = tgt - off
                assert -(1 << 20) <= d < (1 << 20), name
                w = ((((d >> 20) & 1) << 31) | (((d >> 1) & 0x3FF) << 21) | (((d >> 11) & 1) << 20)
                     | (((d >> 12) & 0xFF) << 12) | (arg << 7) | 0x6F)
            elif kind == 'la':
                a = u32(self.base + tgt)
                lo = ((a & 0xFFF) ^ 0x800) - 0x800
                hi = u32(a - lo) >> 12
                self.hw[off // 2] = ((hi << 12) | (r(arg) << 7) | 0x37) & 0xFFFF
                self.hw[off // 2 + 1] = (((hi << 12) | (r(arg) << 7) | 0x37) >> 16) & 0xFFFF
                w2 = ((lo & 0xFFF) << 20) | (r(arg) << 15) | (r(arg) << 7) | 0x13
                self.hw[off // 2 + 2] = w2 & 0xFFFF
                self.hw[off // 2 + 3] = (w2 >> 16) & 0xFFFF
                continue
            self.hw[off // 2] = w & 0xFFFF
            self.hw[off // 2 + 1] = (w >> 16) & 0xFFFF

    def image64(self, words64):
        """Return a list of 64-bit memory words (little endian) covering the program."""
        self.resolve()
        out = [0] * words64
        for hidx, v in self.hw.items():
            byte = hidx * 2
            i = byte // 8
            assert i < words64, hex(byte)
            out[i] |= (v & 0xFFFF) << ((byte % 8) * 8)
        return out
