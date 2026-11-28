#!/usr/bin/env python3
# -----------------------------------------------------------------------------
# AI-GENERATED (Claude Opus 5.5, 2026-11-27) - candidate artifact (R-117, R-231).
# Specification-only authoring context: RISC-V Unprivileged ISA encoding tables
# (RV32I, M, A, F, C, Zba/Zbb/Zbc/Zbs, Zbkb/Zbkc/Zbkx, Zknd/Zkne/Zknh, Zicond,
# Zcb, Zicbom, Zicsr, Zifencei), RISC-V Privileged ISA (mret/sret/wfi/sfence.vma),
# RISC-V Debug Spec 0.13.2 (dret). No RTL and no toolchain output used.
# Human review: pending.
# -----------------------------------------------------------------------------
"""Project-local RV32 assembler (plan Section 5.2, component asm_rv32).

Deterministic two-pass assembler for the ISA subset of the rv32_dual campaign.
No automatic compression: compressed instructions are written with their c.*
mnemonic. Every immediate is range-checked; an out-of-range value, an unknown
mnemonic (including every RV64-only and D-extension mnemonic) or a malformed
operand raises AsmError. RV64/D encodings needed by negative tests are written
with the .word directive.

Directives: .org ADDR, .align N (2**N bytes, zero fill), .word/.half/.byte EXPR,
.space N, .equ NAME, EXPR. Comments start with '#' or '//'.
Expressions: integers (dec/hex/bin), labels, .equ names, NAME+/-INT, %hi(E), %lo(E).

Usage: python asm_rv32.py SOURCE.S --base 0x80000000 -o OUT.memh [--bin OUT.bin]
"""
import argparse
import re
import sys

XLEN_MASK = 0xFFFFFFFF


class AsmError(Exception):
    """Assembly failure with a source line reference."""


# ----------------------------------------------------------------- registers
ABI_X = ["zero", "ra", "sp", "gp", "tp", "t0", "t1", "t2", "s0", "s1"] + \
        ["a%d" % i for i in range(8)] + ["s%d" % i for i in range(2, 12)] + ["t%d" % i for i in range(3, 7)]
ABI_F = ["ft%d" % i for i in range(8)] + ["fs0", "fs1"] + ["fa%d" % i for i in range(8)] + \
        ["fs%d" % i for i in range(2, 12)] + ["ft%d" % i for i in range(8, 12)]
XREG = {name: i for i, name in enumerate(ABI_X)}
XREG.update({"x%d" % i: i for i in range(32)})
XREG["fp"] = 8
FREG = {name: i for i, name in enumerate(ABI_F)}
FREG.update({"f%d" % i: i for i in range(32)})

CSR = {
    "fflags": 0x001, "frm": 0x002, "fcsr": 0x003,
    "sstatus": 0x100, "sie": 0x104, "stvec": 0x105, "scounteren": 0x106, "senvcfg": 0x10A,
    "sscratch": 0x140, "sepc": 0x141, "scause": 0x142, "stval": 0x143, "sip": 0x144, "satp": 0x180,
    "mstatus": 0x300, "misa": 0x301, "medeleg": 0x302, "mideleg": 0x303, "mie": 0x304, "mtvec": 0x305,
    "mcounteren": 0x306, "menvcfg": 0x30A, "mstatush": 0x310, "menvcfgh": 0x31A, "mcountinhibit": 0x320,
    "mscratch": 0x340, "mepc": 0x341, "mcause": 0x342, "mtval": 0x343, "mip": 0x344,
    "mcycle": 0xB00, "minstret": 0xB02, "mcycleh": 0xB80, "minstreth": 0xB82,
    "cycle": 0xC00, "time": 0xC01, "instret": 0xC02, "cycleh": 0xC80, "timeh": 0xC81, "instreth": 0xC82,
    "mvendorid": 0xF11, "marchid": 0xF12, "mimpid": 0xF13, "mhartid": 0xF14,
    "dcsr": 0x7B0, "dpc": 0x7B1, "dscratch0": 0x7B2, "dscratch1": 0x7B3,
}
for _i in range(4):
    CSR["pmpcfg%d" % _i] = 0x3A0 + _i
for _i in range(16):
    CSR["pmpaddr%d" % _i] = 0x3B0 + _i
for _i in range(3, 32):
    CSR["mhpmcounter%d" % _i] = 0xB00 + _i
    CSR["mhpmcounter%dh" % _i] = 0xB80 + _i
    CSR["mhpmevent%d" % _i] = 0x320 + _i
    CSR["hpmcounter%d" % _i] = 0xC00 + _i
    CSR["hpmcounter%dh" % _i] = 0xC80 + _i

RM = {"rne": 0, "rtz": 1, "rdn": 2, "rup": 3, "rmm": 4, "dyn": 7}

# ------------------------------------------------------------ opcode tables
OP, OP_IMM, LOAD, STORE, BRANCH = 0x33, 0x13, 0x03, 0x23, 0x63
JALR, JAL, LUI, AUIPC, MISC_MEM, SYSTEM, AMO = 0x67, 0x6F, 0x37, 0x17, 0x0F, 0x73, 0x2F
LOAD_FP, STORE_FP, OP_FP = 0x07, 0x27, 0x53
R4 = {"fmadd.s": 0x43, "fmsub.s": 0x47, "fnmsub.s": 0x4B, "fnmadd.s": 0x4F}

# R-type register-register: mnemonic -> (funct7, funct3)
R_OPS = {
    "add": (0x00, 0), "sub": (0x20, 0), "sll": (0x00, 1), "slt": (0x00, 2), "sltu": (0x00, 3),
    "xor": (0x00, 4), "srl": (0x00, 5), "sra": (0x20, 5), "or": (0x00, 6), "and": (0x00, 7),
    "mul": (0x01, 0), "mulh": (0x01, 1), "mulhsu": (0x01, 2), "mulhu": (0x01, 3),
    "div": (0x01, 4), "divu": (0x01, 5), "rem": (0x01, 6), "remu": (0x01, 7),
    "sh1add": (0x10, 2), "sh2add": (0x10, 4), "sh3add": (0x10, 6),
    "andn": (0x20, 7), "orn": (0x20, 6), "xnor": (0x20, 4),
    "max": (0x05, 6), "maxu": (0x05, 7), "min": (0x05, 4), "minu": (0x05, 5),
    "rol": (0x30, 1), "ror": (0x30, 5),
    "clmul": (0x05, 1), "clmulr": (0x05, 2), "clmulh": (0x05, 3),
    "bclr": (0x24, 1), "bext": (0x24, 5), "binv": (0x34, 1), "bset": (0x14, 1),
    "pack": (0x04, 4), "packh": (0x04, 7), "xperm4": (0x14, 2), "xperm8": (0x14, 4),
    "czero.eqz": (0x07, 5), "czero.nez": (0x07, 7),
    "sha512sum0r": (0x28, 0), "sha512sum1r": (0x29, 0), "sha512sig0l": (0x2A, 0),
    "sha512sig1l": (0x2B, 0), "sha512sig0h": (0x2E, 0), "sha512sig1h": (0x2F, 0),
}
# unary OP-IMM with fixed imm12: mnemonic -> (imm12, funct3)
UNARY_IMM = {
    "clz": (0x600, 1), "ctz": (0x601, 1), "cpop": (0x602, 1), "sext.b": (0x604, 1), "sext.h": (0x605, 1),
    "orc.b": (0x287, 5), "rev8": (0x698, 5), "brev8": (0x687, 5), "zip": (0x08F, 1), "unzip": (0x08F, 5),
    "sha256sum0": (0x100, 1), "sha256sum1": (0x101, 1), "sha256sig0": (0x102, 1), "sha256sig1": (0x103, 1),
}
# shift-immediate: mnemonic -> (funct7, funct3)
SHIFT_IMM = {"slli": (0x00, 1), "srli": (0x00, 5), "srai": (0x20, 5), "rori": (0x30, 5),
             "bclri": (0x24, 1), "bexti": (0x24, 5), "binvi": (0x34, 1), "bseti": (0x14, 1)}
I_ALU = {"addi": 0, "slti": 2, "sltiu": 3, "xori": 4, "ori": 6, "andi": 7}
LOADS = {"lb": 0, "lh": 1, "lw": 2, "lbu": 4, "lhu": 5}
STORES = {"sb": 0, "sh": 1, "sw": 2}
BRANCHES = {"beq": 0, "bne": 1, "blt": 4, "bge": 5, "bltu": 6, "bgeu": 7}
AMO_OPS = {"amoswap.w": 0x01, "amoadd.w": 0x00, "amoxor.w": 0x04, "amoand.w": 0x0C, "amoor.w": 0x08,
           "amomin.w": 0x10, "amomax.w": 0x14, "amominu.w": 0x18, "amomaxu.w": 0x1C}
AES32 = {"aes32esi": 0x11, "aes32esmi": 0x13, "aes32dsi": 0x15, "aes32dsmi": 0x17}
CSR_OPS = {"csrrw": 1, "csrrs": 2, "csrrc": 3, "csrrwi": 5, "csrrsi": 6, "csrrci": 7}
FIXED = {"ecall": 0x00000073, "ebreak": 0x00100073, "mret": 0x30200073, "sret": 0x10200073,
         "wfi": 0x10500073, "dret": 0x7B200073, "fence.i": 0x0000100F, "nop": 0x00000013}
CBO = {"cbo.inval": 0x000, "cbo.clean": 0x001, "cbo.flush": 0x002}
# OP-FP two-source: mnemonic -> (funct7, funct3 or None for rm)
FP_R = {"fadd.s": (0x00, None), "fsub.s": (0x04, None), "fmul.s": (0x08, None), "fdiv.s": (0x0C, None),
        "fsgnj.s": (0x10, 0), "fsgnjn.s": (0x10, 1), "fsgnjx.s": (0x10, 2),
        "fmin.s": (0x14, 0), "fmax.s": (0x14, 1)}
FP_CMP = {"feq.s": 2, "flt.s": 1, "fle.s": 0}
# OP-FP one-source: mnemonic -> (funct7, rs2, funct3 or None, dest kind, src kind)
FP_U = {"fsqrt.s": (0x2C, 0, None, "f", "f"), "fcvt.w.s": (0x60, 0, None, "x", "f"),
        "fcvt.wu.s": (0x60, 1, None, "x", "f"), "fcvt.s.w": (0x68, 0, None, "f", "x"),
        "fcvt.s.wu": (0x68, 1, None, "f", "x"), "fmv.x.w": (0x70, 0, 0, "x", "f"),
        "fclass.s": (0x70, 0, 1, "x", "f"), "fmv.w.x": (0x78, 0, 0, "f", "x")}
CB_ALU = {"c.sub": 0, "c.xor": 1, "c.or": 2, "c.and": 3}
ZCB_UNARY = {"c.zext.b": 0, "c.sext.b": 1, "c.zext.h": 2, "c.sext.h": 3, "c.not": 5}


# ------------------------------------------------------------------ helpers
def fits_signed(v, bits):
    return -(1 << (bits - 1)) <= v < (1 << (bits - 1))


def bit(v, n):
    return (v >> n) & 1


def rtype(f7, rs2, rs1, f3, rd, op):
    return (f7 << 25) | (rs2 << 20) | (rs1 << 15) | (f3 << 12) | (rd << 7) | op


def itype(imm, rs1, f3, rd, op):
    return ((imm & 0xFFF) << 20) | (rs1 << 15) | (f3 << 12) | (rd << 7) | op


def stype(imm, rs2, rs1, f3, op):
    imm &= 0xFFF
    return ((imm >> 5) << 25) | (rs2 << 20) | (rs1 << 15) | (f3 << 12) | ((imm & 0x1F) << 7) | op


def btype(off, rs2, rs1, f3):
    o = off & 0x1FFF
    return (bit(o, 12) << 31) | (((o >> 5) & 0x3F) << 25) | (rs2 << 20) | (rs1 << 15) | (f3 << 12) | \
           (((o >> 1) & 0xF) << 8) | (bit(o, 11) << 7) | BRANCH


def jtype(off, rd):
    o = off & 0x1FFFFF
    return (bit(o, 20) << 31) | (((o >> 1) & 0x3FF) << 21) | (bit(o, 11) << 20) | (((o >> 12) & 0xFF) << 12) | \
           (rd << 7) | JAL


class Line:
    def __init__(self, num, text, label, mnem, ops):
        self.num, self.text, self.label, self.mnem, self.ops = num, text, label, mnem, ops


class Assembler:
    def __init__(self, base=0x80000000):
        self.base = base
        self.symbols = {}
        self.image = {}  # byte address -> value

    # --------------------------------------------------------- parsing
    @staticmethod
    def split_ops(s):
        out, depth, cur = [], 0, ""
        for ch in s:
            if ch == "(":
                depth += 1
            elif ch == ")":
                depth -= 1
            if ch == "," and depth == 0:
                out.append(cur.strip())
                cur = ""
            else:
                cur += ch
        if cur.strip():
            out.append(cur.strip())
        return out

    def parse(self, text):
        lines = []
        for num, raw in enumerate(text.splitlines(), 1):
            s = raw.split("#")[0].split("//")[0].strip()
            labels = []
            while True:
                m = re.match(r"^([A-Za-z_.$][\w.$]*)\s*:\s*(.*)$", s)
                if not m:
                    break
                labels.append(m.group(1))
                s = m.group(2).strip()
            for lab in labels:
                lines.append(Line(num, raw, lab, None, []))
            if s:
                parts = s.split(None, 1)
                lines.append(Line(num, raw, None, parts[0].lower(), self.split_ops(parts[1]) if len(parts) > 1 else []))
        return lines

    # ------------------------------------------------------ expressions
    def value(self, expr, line, pass2=True):
        e = expr.strip()
        m = re.match(r"^%(hi|lo)\((.*)\)$", e)
        if m:
            v = self.value(m.group(2), line, pass2) & XLEN_MASK
            if m.group(1) == "hi":
                return ((v + 0x800) >> 12) & 0xFFFFF
            lo = v & 0xFFF
            return lo - 0x1000 if lo & 0x800 else lo
        tokens = re.findall(r"[+-]?\s*[^+-]+", e.replace(" ", ""))
        if not tokens:
            raise AsmError("line %d: empty expression" % line.num)
        total = 0
        for tok in tokens:
            sign = -1 if tok.startswith("-") else 1
            t = tok.lstrip("+-")
            if re.match(r"^(0x[0-9a-fA-F_]+|0b[01_]+|[0-9][0-9_]*)$", t):
                total += sign * int(t.replace("_", ""), 0)
            elif re.match(r"^[A-Za-z_.$][\w.$]*$", t):
                if t in self.symbols:
                    total += sign * self.symbols[t]
                elif pass2:
                    raise AsmError("line %d: undefined symbol '%s'" % (line.num, t))
                else:
                    return None
            else:
                raise AsmError("line %d: bad expression '%s'" % (line.num, expr))
        return total

    def const(self, expr, line):
        v = self.value(expr, line, pass2=False)
        if v is None:
            raise AsmError("line %d: '%s' must be a constant known in pass 1" % (line.num, expr))
        return v

    def xr(self, s, line):
        r = XREG.get(s.strip().lower())
        if r is None:
            raise AsmError("line %d: bad integer register '%s'" % (line.num, s))
        return r

    def fr(self, s, line):
        r = FREG.get(s.strip().lower())
        if r is None:
            raise AsmError("line %d: bad FP register '%s'" % (line.num, s))
        return r

    def cr(self, s, line, fp=False):
        r = self.fr(s, line) if fp else self.xr(s, line)
        if not 8 <= r <= 15:
            raise AsmError("line %d: register '%s' is not one of x8-x15/f8-f15 (compressed)" % (line.num, s))
        return r - 8

    def memop(self, s, line):
        m = re.match(r"^(.*)\(\s*([\w]+)\s*\)$", s.strip())
        if not m:
            raise AsmError("line %d: expected offset(reg), got '%s'" % (line.num, s))
        off = m.group(1).strip() or "0"
        return off, m.group(2)

    def need(self, line, n):
        if len(line.ops) != n:
            raise AsmError("line %d: '%s' needs %d operand(s), got %d" % (line.num, line.mnem, n, len(line.ops)))

    @staticmethod
    def check(cond, line, msg):
        if not cond:
            raise AsmError("line %d: %s" % (line.num, msg))

    def csr_num(self, s, line):
        k = s.strip().lower()
        v = CSR[k] if k in CSR else self.const(s, line)
        self.check(0 <= v <= 0xFFF, line, "CSR number out of range 0..4095")
        return v

    def rm(self, ops, n, line):
        if len(ops) == n:
            return 7
        self.check(len(ops) == n + 1, line, "wrong operand count")
        k = ops[n].strip().lower()
        self.check(k in RM, line, "bad rounding mode '%s'" % ops[n])
        return RM[k]

    # ---------------------------------------------------------- sizing
    def size(self, ln):
        m = ln.mnem
        if m.startswith("c."):
            return 2
        if m == "li":
            v = self.const(ln.ops[1], ln)
            self.check(-(1 << 31) <= v <= XLEN_MASK, ln, "li value out of 32-bit range")
            if -2048 <= v <= 2047:
                return 4
            return 4 if (v & 0xFFF) == 0 else 8
        if m in ("la", "call"):
            return 8
        return 4

    # ------------------------------------------------------- assembling
    def assemble(self, text):
        lines = self.parse(text)
        # pass 1: symbols
        pc = self.base
        for ln in lines:
            if ln.label is not None:
                self.check(ln.label not in self.symbols, ln, "duplicate symbol '%s'" % ln.label)
                self.symbols[ln.label] = pc
                continue
            pc = self.directive_or_size(ln, pc, emit=False)
        # pass 2: emit
        pc = self.base
        for ln in lines:
            if ln.label is not None:
                continue
            pc = self.directive_or_size(ln, pc, emit=True)
        return self.image

    def put(self, addr, value, nbytes, ln):
        for i in range(nbytes):
            a = addr + i
            self.check(a not in self.image, ln, "overlapping output at 0x%x" % a)
            self.image[a] = (value >> (8 * i)) & 0xFF

    def directive_or_size(self, ln, pc, emit):
        m = ln.mnem
        if m == ".equ":
            self.need(ln, 2)
            if not emit:
                self.check(ln.ops[0] not in self.symbols, ln, "duplicate symbol '%s'" % ln.ops[0])
                self.symbols[ln.ops[0]] = self.const(ln.ops[1], ln)
            return pc
        if m == ".org":
            new = self.const(ln.ops[0], ln)
            self.check(new >= pc, ln, ".org moves backwards")
            return new
        if m == ".align":
            n = 1 << self.const(ln.ops[0], ln)
            return (pc + n - 1) // n * n
        if m == ".space":
            n = self.const(ln.ops[0], ln)
            self.check(n >= 0, ln, "negative .space")
            if emit:
                self.put(pc, 0, n, ln)
            return pc + n
        if m in (".word", ".half", ".byte"):
            w = {".word": 4, ".half": 2, ".byte": 1}[m]
            for op in ln.ops:
                if emit:
                    v = self.value(op, ln)
                    self.check(-(1 << (8 * w - 1)) <= v < (1 << (8 * w)), ln, "%s value out of range" % m)
                    self.put(pc, v & ((1 << (8 * w)) - 1), w, ln)
                pc += w
            return pc
        if m.startswith("."):
            raise AsmError("line %d: unknown directive '%s'" % (ln.num, m))
        n = self.size(ln)
        if emit:
            self.check(pc % 2 == 0, ln, "instruction at odd address")
            words = self.encode(ln, pc)
            off = 0
            for val, w in words:
                self.put(pc + off, val, w, ln)
                off += w
            self.check(off == n, ln, "internal size mismatch")
        return pc + n

    # ----------------------------------------------------------- encoder
    def encode(self, ln, pc):
        m, ops = ln.mnem, ln.ops
        X, F, V = (lambda s: self.xr(s, ln)), (lambda s: self.fr(s, ln)), (lambda s: self.value(s, ln))
        chk = lambda c, msg: self.check(c, ln, msg)
        if m.startswith("c."):
            return [(self.encode_c(ln, pc), 2)]
        if m in FIXED:
            self.need(ln, 0)
            return [(FIXED[m], 4)]
        if m in R_OPS:
            self.need(ln, 3)
            f7, f3 = R_OPS[m]
            return [(rtype(f7, X(ops[2]), X(ops[1]), f3, X(ops[0]), OP), 4)]
        if m == "zext.h":
            self.need(ln, 2)
            return [(rtype(0x04, 0, X(ops[1]), 4, X(ops[0]), OP), 4)]
        if m in UNARY_IMM:
            self.need(ln, 2)
            imm, f3 = UNARY_IMM[m]
            return [(itype(imm, X(ops[1]), f3, X(ops[0]), OP_IMM), 4)]
        if m in SHIFT_IMM:
            self.need(ln, 3)
            f7, f3 = SHIFT_IMM[m]
            sh = V(ops[2])
            chk(0 <= sh <= 31, "shift amount out of range 0..31")
            return [(rtype(f7, sh, X(ops[1]), f3, X(ops[0]), OP_IMM), 4)]
        if m in I_ALU:
            self.need(ln, 3)
            imm = V(ops[2])
            chk(fits_signed(imm, 12), "12-bit signed immediate out of range")
            return [(itype(imm, X(ops[1]), I_ALU[m], X(ops[0]), OP_IMM), 4)]
        if m in LOADS:
            self.need(ln, 2)
            off, rs1 = self.memop(ops[1], ln)
            imm = V(off)
            chk(fits_signed(imm, 12), "load offset out of range")
            return [(itype(imm, X(rs1), LOADS[m], X(ops[0]), LOAD), 4)]
        if m in STORES:
            self.need(ln, 2)
            off, rs1 = self.memop(ops[1], ln)
            imm = V(off)
            chk(fits_signed(imm, 12), "store offset out of range")
            return [(stype(imm, X(ops[0]), X(rs1), STORES[m], STORE), 4)]
        if m in BRANCHES or m in ("beqz", "bnez", "bgt", "ble", "bgtu", "bleu"):
            if m in ("beqz", "bnez"):
                self.need(ln, 2)
                f3, rs1, rs2, tgt = BRANCHES["beq" if m == "beqz" else "bne"], X(ops[0]), 0, ops[1]
            elif m in ("bgt", "ble", "bgtu", "bleu"):
                self.need(ln, 3)
                real = {"bgt": "blt", "ble": "bge", "bgtu": "bltu", "bleu": "bgeu"}[m]
                f3, rs1, rs2, tgt = BRANCHES[real], X(ops[1]), X(ops[0]), ops[2]
            else:
                self.need(ln, 3)
                f3, rs1, rs2, tgt = BRANCHES[m], X(ops[0]), X(ops[1]), ops[2]
            off = self.target(tgt, pc, ln)
            chk(off % 2 == 0 and fits_signed(off, 13), "branch offset odd or out of range")
            return [(btype(off, rs2, rs1, f3), 4)]
        if m in ("jal", "j"):
            if m == "j":
                self.need(ln, 1)
                rd, tgt = 0, ops[0]
            elif len(ops) == 1:
                rd, tgt = 1, ops[0]
            else:
                self.need(ln, 2)
                rd, tgt = X(ops[0]), ops[1]
            off = self.target(tgt, pc, ln)
            chk(off % 2 == 0 and fits_signed(off, 21), "jal offset odd or out of range")
            return [(jtype(off, rd), 4)]
        if m == "jalr":
            if len(ops) == 1:
                return [(itype(0, X(ops[0]), 0, 1, JALR), 4)]
            self.need(ln, 2)
            off, rs1 = self.memop(ops[1], ln)
            imm = V(off)
            chk(fits_signed(imm, 12), "jalr offset out of range")
            return [(itype(imm, X(rs1), 0, X(ops[0]), JALR), 4)]
        if m in ("jr", "ret"):
            if m == "ret":
                self.need(ln, 0)
                return [(itype(0, 1, 0, 0, JALR), 4)]
            self.need(ln, 1)
            return [(itype(0, X(ops[0]), 0, 0, JALR), 4)]
        if m in ("lui", "auipc"):
            self.need(ln, 2)
            imm = V(ops[1])
            chk(0 <= imm <= 0xFFFFF, "20-bit upper immediate out of range 0..0xFFFFF")
            return [((imm << 12) | (X(ops[0]) << 7) | (LUI if m == "lui" else AUIPC), 4)]
        if m == "li":
            self.need(ln, 2)
            rd, v = X(ops[0]), self.const(ops[1], ln)
            if -2048 <= v <= 2047:
                return [(itype(v, 0, 0, rd, OP_IMM), 4)]
            v &= XLEN_MASK
            hi, lo = ((v + 0x800) >> 12) & 0xFFFFF, v & 0xFFF
            lo = lo - 0x1000 if lo & 0x800 else lo
            out = [((hi << 12) | (rd << 7) | LUI, 4)]
            if lo:
                out.append((itype(lo, rd, 0, rd, OP_IMM), 4))
            return out
        if m in ("la", "call"):
            if m == "la":
                self.need(ln, 2)
                rd, tgt, tail = X(ops[0]), ops[1], None
            else:
                self.need(ln, 1)
                rd, tgt, tail = 1, ops[0], True
            off = (V(tgt) - pc) & XLEN_MASK
            hi, lo = ((off + 0x800) >> 12) & 0xFFFFF, off & 0xFFF
            lo = lo - 0x1000 if lo & 0x800 else lo
            first = (hi << 12) | (rd << 7) | AUIPC
            second = itype(lo, rd, 0, rd, JALR) if tail else itype(lo, rd, 0, rd, OP_IMM)
            return [(first, 4), (second, 4)]
        if m in ("mv", "not", "neg", "seqz", "snez"):
            self.need(ln, 2)
            rd, rs = X(ops[0]), X(ops[1])
            return [({"mv": itype(0, rs, 0, rd, OP_IMM), "not": itype(-1, rs, 4, rd, OP_IMM),
                      "neg": rtype(0x20, rs, 0, 0, rd, OP), "seqz": itype(1, rs, 3, rd, OP_IMM),
                      "snez": rtype(0, rs, 0, 3, rd, OP)}[m], 4)]
        if m == "fence":
            if not ops:
                return [(0x0FF0000F, 4)]
            self.need(ln, 2)
            enc = []
            for s in ops:
                s = s.strip().lower()
                chk(re.match(r"^[iorw]+$", s) is not None, "bad fence set '%s'" % s)
                enc.append((8 if "i" in s else 0) | (4 if "o" in s else 0) | (2 if "r" in s else 0) | (1 if "w" in s else 0))
            return [((enc[0] << 24) | (enc[1] << 20) | MISC_MEM, 4)]
        if m in CBO:
            self.need(ln, 1)
            off, rs1 = self.memop(ops[0], ln)
            chk(V(off) == 0, "cbo.* offset must be 0")
            return [(itype(CBO[m], X(rs1), 2, 0, MISC_MEM), 4)]
        if m == "sfence.vma":
            rs1 = X(ops[0]) if len(ops) >= 1 else 0
            rs2 = X(ops[1]) if len(ops) == 2 else 0
            chk(len(ops) <= 2, "sfence.vma takes at most 2 operands")
            return [(rtype(0x09, rs2, rs1, 0, 0, SYSTEM), 4)]
        if m in CSR_OPS or m in ("csrr", "csrw", "csrs", "csrc", "csrwi", "csrsi", "csrci"):
            if m == "csrr":
                self.need(ln, 2)
                m2, rd, csr, src = "csrrs", X(ops[0]), ops[1], "x0"
            elif m in ("csrw", "csrs", "csrc", "csrwi", "csrsi", "csrci"):
                self.need(ln, 2)
                m2, rd, csr, src = "csrr" + m[3:], 0, ops[0], ops[1]
            else:
                self.need(ln, 3)
                m2, rd, csr, src = m, X(ops[0]), ops[1], ops[2]
            f3 = CSR_OPS[m2]
            if f3 >= 5:
                z = V(src)
                chk(0 <= z <= 31, "CSR immediate out of range 0..31")
                rs1 = z
            else:
                rs1 = X(src)
            return [(itype(self.csr_num(csr, ln), rs1, f3, rd, SYSTEM), 4)]
        base = m.split(".aq")[0].split(".rl")[0]
        if base in AMO_OPS or base in ("lr.w", "sc.w"):
            suf = m[len(base):]
            chk(suf in ("", ".aq", ".rl", ".aqrl"), "bad AMO ordering suffix '%s'" % suf)
            aq, rl = int("aq" in suf), int("rl" in suf)
            if base == "lr.w":
                self.need(ln, 2)
                f5, rd, rs2, mem = 0x02, X(ops[0]), 0, ops[1]
            else:
                self.need(ln, 3)
                f5, rd, rs2, mem = (0x03 if base == "sc.w" else AMO_OPS[base]), X(ops[0]), X(ops[1]), ops[2]
            off, rs1 = self.memop(mem, ln)
            chk(V(off) == 0, "AMO/LR/SC address must be (rs1) with offset 0")
            return [(rtype((f5 << 2) | (aq << 1) | rl, rs2, X(rs1), 2, rd, AMO), 4)]
        if m in AES32:
            self.need(ln, 4)
            bs = V(ops[3])
            chk(0 <= bs <= 3, "aes32 byte select out of range 0..3")
            return [(rtype((bs << 5) | AES32[m], X(ops[2]), X(ops[1]), 0, X(ops[0]), OP), 4)]
        if m in ("flw", "fsw"):
            self.need(ln, 2)
            off, rs1 = self.memop(ops[1], ln)
            imm = V(off)
            chk(fits_signed(imm, 12), "FP load/store offset out of range")
            if m == "flw":
                return [(itype(imm, X(rs1), 2, F(ops[0]), LOAD_FP), 4)]
            return [(stype(imm, F(ops[0]), X(rs1), 2, STORE_FP), 4)]
        if m in R4:
            rmv = self.rm(ops, 4, ln)
            return [((F(ops[3]) << 27) | (F(ops[2]) << 20) | (F(ops[1]) << 15) | (rmv << 12) | (F(ops[0]) << 7) | R4[m], 4)]
        if m in FP_R:
            f7, f3 = FP_R[m]
            if f3 is None:
                f3 = self.rm(ops, 3, ln)
            else:
                self.need(ln, 3)
            return [(rtype(f7, F(ops[2]), F(ops[1]), f3, F(ops[0]), OP_FP), 4)]
        if m in FP_CMP:
            self.need(ln, 3)
            return [(rtype(0x50, F(ops[2]), F(ops[1]), FP_CMP[m], X(ops[0]), OP_FP), 4)]
        if m in FP_U:
            f7, rs2, f3, dk, sk = FP_U[m]
            if f3 is None:
                f3 = self.rm(ops, 2, ln)
            else:
                self.need(ln, 2)
            rd = F(ops[0]) if dk == "f" else X(ops[0])
            rs1 = F(ops[1]) if sk == "f" else X(ops[1])
            return [(rtype(f7, rs2, rs1, f3, rd, OP_FP), 4)]
        if m in ("fmv.s", "fabs.s", "fneg.s"):
            self.need(ln, 2)
            f3 = {"fmv.s": 0, "fneg.s": 1, "fabs.s": 2}[m]
            return [(rtype(0x10, F(ops[1]), F(ops[1]), f3, F(ops[0]), OP_FP), 4)]
        raise AsmError("line %d: unknown or unsupported mnemonic '%s'" % (ln.num, m))

    def target(self, tgt, pc, ln):
        t = tgt.strip()
        if re.match(r"^[+-]?(0x[0-9a-fA-F]+|[0-9]+)$", t):
            return int(t, 0)          # numeric operand is a PC-relative offset
        return self.value(t, ln) - pc

    # ------------------------------------------------------- compressed
    def encode_c(self, ln, pc):
        m, ops = ln.mnem, ln.ops
        V = lambda s: self.value(s, ln)
        chk = lambda c, msg: self.check(c, ln, msg)
        X = lambda s: self.xr(s, ln)
        if m == "c.nop":
            self.need(ln, 0)
            return 0x0001
        if m == "c.ebreak":
            self.need(ln, 0)
            return 0x9002
        if m in ("c.lw", "c.sw", "c.flw", "c.fsw"):
            self.need(ln, 2)
            fp = m in ("c.flw", "c.fsw")
            r = self.cr(ops[0], ln, fp)
            off, rs1 = self.memop(ops[1], ln)
            u = V(off)
            chk(0 <= u <= 124 and u % 4 == 0, "c.lw/c.sw offset must be 0..124, multiple of 4")
            f3 = {"c.lw": 2, "c.flw": 3, "c.sw": 6, "c.fsw": 7}[m]
            return (f3 << 13) | (((u >> 3) & 7) << 10) | (self.cr(rs1, ln) << 7) | (bit(u, 2) << 6) | (bit(u, 6) << 5) | (r << 2)
        if m == "c.addi4spn":
            self.need(ln, 3)
            chk(X(ops[1]) == 2, "c.addi4spn source must be sp")
            u = V(ops[2])
            chk(4 <= u <= 1020 and u % 4 == 0, "c.addi4spn immediate must be 4..1020, multiple of 4")
            f = (bit(u, 5) << 7) | (bit(u, 4) << 6) | (((u >> 6) & 0xF) << 2) | (bit(u, 2) << 1) | bit(u, 3)
            return (f << 5) | (self.cr(ops[0], ln) << 2)
        if m in ("c.lbu", "c.lhu", "c.lh", "c.sb", "c.sh"):
            self.need(ln, 2)
            r = self.cr(ops[0], ln)
            off, rs1 = self.memop(ops[1], ln)
            u = V(off)
            if m in ("c.lbu", "c.sb"):
                chk(0 <= u <= 3, "c.lbu/c.sb offset must be 0..3")
                b6, b5 = bit(u, 0), bit(u, 1)
            else:
                chk(u in (0, 2), "c.lhu/c.lh/c.sh offset must be 0 or 2")
                b6, b5 = (1 if m == "c.lh" else 0), bit(u, 1)
            f6 = {"c.lbu": 0x20, "c.lhu": 0x21, "c.lh": 0x21, "c.sb": 0x22, "c.sh": 0x23}[m]
            return (f6 << 10) | (self.cr(rs1, ln) << 7) | (b6 << 6) | (b5 << 5) | (r << 2)
        if m in ("c.addi", "c.li"):
            self.need(ln, 2)
            rd, imm = X(ops[0]), V(ops[1])
            chk(rd != 0, "%s rd must not be x0" % m)
            chk(fits_signed(imm, 6), "6-bit signed immediate out of range")
            if m == "c.addi":
                chk(imm != 0, "c.addi immediate must be nonzero")
            return ((0 if m == "c.addi" else 2) << 13) | (bit(imm, 5) << 12) | (rd << 7) | ((imm & 0x1F) << 2) | 1
        if m == "c.addi16sp":
            self.need(ln, 2)
            chk(X(ops[0]) == 2, "c.addi16sp destination must be sp")
            n = V(ops[1])
            chk(n != 0 and n % 16 == 0 and -512 <= n <= 496, "c.addi16sp immediate must be nonzero multiple of 16 in -512..496")
            return (3 << 13) | (bit(n, 9) << 12) | (2 << 7) | (bit(n, 4) << 6) | (bit(n, 6) << 5) | \
                   (((n >> 7) & 3) << 3) | (bit(n, 5) << 2) | 1
        if m == "c.lui":
            self.need(ln, 2)
            rd, n = X(ops[0]), V(ops[1])
            chk(rd not in (0, 2), "c.lui rd must not be x0 or sp")
            chk(n != 0 and -32 <= n <= 31, "c.lui immediate must be nonzero in -32..31")
            return (3 << 13) | (bit(n, 5) << 12) | (rd << 7) | ((n & 0x1F) << 2) | 1
        if m in ("c.srli", "c.srai", "c.andi"):
            self.need(ln, 2)
            r, v = self.cr(ops[0], ln), V(ops[1])
            if m == "c.andi":
                chk(fits_signed(v, 6), "c.andi immediate out of range -32..31")
                return (4 << 13) | (bit(v, 5) << 12) | (2 << 10) | (r << 7) | ((v & 0x1F) << 2) | 1
            chk(1 <= v <= 31, "shift amount must be 1..31 on RV32")
            return (4 << 13) | ((0 if m == "c.srli" else 1) << 10) | (r << 7) | (v << 2) | 1
        if m in CB_ALU:
            self.need(ln, 2)
            return (0x23 << 10) | (self.cr(ops[0], ln) << 7) | (CB_ALU[m] << 5) | (self.cr(ops[1], ln) << 2) | 1
        if m in ZCB_UNARY:
            self.need(ln, 1)
            return (0x27 << 10) | (self.cr(ops[0], ln) << 7) | (3 << 5) | (ZCB_UNARY[m] << 2) | 1
        if m == "c.mul":
            self.need(ln, 2)
            return (0x27 << 10) | (self.cr(ops[0], ln) << 7) | (2 << 5) | (self.cr(ops[1], ln) << 2) | 1
        if m in ("c.j", "c.jal"):
            self.need(ln, 1)
            o = self.target(ops[0], pc, ln)
            chk(o % 2 == 0 and fits_signed(o, 12), "c.j/c.jal offset odd or out of range")
            f = (bit(o, 11) << 10) | (bit(o, 4) << 9) | (((o >> 8) & 3) << 7) | (bit(o, 10) << 6) | \
                (bit(o, 6) << 5) | (bit(o, 7) << 4) | (((o >> 1) & 7) << 1) | bit(o, 5)
            return ((5 if m == "c.j" else 1) << 13) | (f << 2) | 1
        if m in ("c.beqz", "c.bnez"):
            self.need(ln, 2)
            r = self.cr(ops[0], ln)
            o = self.target(ops[1], pc, ln)
            chk(o % 2 == 0 and fits_signed(o, 9), "c.beqz/c.bnez offset odd or out of range")
            return ((6 if m == "c.beqz" else 7) << 13) | (bit(o, 8) << 12) | (((o >> 3) & 3) << 10) | (r << 7) | \
                   (((o >> 6) & 3) << 5) | (((o >> 1) & 3) << 3) | (bit(o, 5) << 2) | 1
        if m == "c.slli":
            self.need(ln, 2)
            rd, v = X(ops[0]), V(ops[1])
            chk(rd != 0, "c.slli rd must not be x0")
            chk(1 <= v <= 31, "shift amount must be 1..31 on RV32")
            return (rd << 7) | (v << 2) | 2
        if m in ("c.lwsp", "c.flwsp"):
            self.need(ln, 2)
            fp = m == "c.flwsp"
            rd = self.fr(ops[0], ln) if fp else X(ops[0])
            if not fp:
                chk(rd != 0, "c.lwsp rd must not be x0")
            off, rs1 = self.memop(ops[1], ln)
            chk(X(rs1) == 2, "base register must be sp")
            u = V(off)
            chk(0 <= u <= 252 and u % 4 == 0, "offset must be 0..252, multiple of 4")
            return ((3 if fp else 2) << 13) | (bit(u, 5) << 12) | (rd << 7) | (((u >> 2) & 7) << 4) | (((u >> 6) & 3) << 2) | 2
        if m in ("c.swsp", "c.fswsp"):
            self.need(ln, 2)
            fp = m == "c.fswsp"
            rs2 = self.fr(ops[0], ln) if fp else X(ops[0])
            off, rs1 = self.memop(ops[1], ln)
            chk(X(rs1) == 2, "base register must be sp")
            u = V(off)
            chk(0 <= u <= 252 and u % 4 == 0, "offset must be 0..252, multiple of 4")
            return ((7 if fp else 6) << 13) | (((u >> 2) & 0xF) << 9) | (((u >> 6) & 3) << 7) | (rs2 << 2) | 2
        if m in ("c.jr", "c.jalr"):
            self.need(ln, 1)
            r = X(ops[0])
            chk(r != 0, "%s rs1 must not be x0" % m)
            return ((8 if m == "c.jr" else 9) << 12) | (r << 7) | 2
        if m in ("c.mv", "c.add"):
            self.need(ln, 2)
            rd, rs2 = X(ops[0]), X(ops[1])
            chk(rd != 0 and rs2 != 0, "%s registers must not be x0" % m)
            return ((8 if m == "c.mv" else 9) << 12) | (rd << 7) | (rs2 << 2) | 2
        raise AsmError("line %d: unknown or unsupported compressed mnemonic '%s'" % (ln.num, m))


# ---------------------------------------------------------------- outputs
def assemble_text(text, base=0x80000000):
    """Return (image dict byte_addr->byte, symbols)."""
    a = Assembler(base)
    img = a.assemble(text)
    return img, dict(a.symbols)


def encode_one(line, pc=0):
    """Assemble one instruction at address pc; return list of (value, width)."""
    a = Assembler(pc)
    img = a.assemble(line)
    if not img:
        return []
    out, addr = [], pc
    ln = a.parse(line)[-1]
    for val, w in a.encode(ln, pc):
        out.append((val, w))
    return out


def write_memh(img, path, word=4):
    """Write $readmemh-style lines '@ADDR' followed by little-endian words."""
    if not img:
        open(path, "w").close()
        return
    lo, hi = min(img), max(img)
    lo -= lo % word
    with open(path, "w", newline="\n") as f:
        f.write("@%08x\n" % (lo // word))
        for a in range(lo, hi + 1, word):
            v = 0
            for i in range(word):
                v |= img.get(a + i, 0) << (8 * i)
            f.write("%0*x\n" % (2 * word, v))


def main(argv=None):
    p = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    p.add_argument("source")
    p.add_argument("--base", default="0x80000000")
    p.add_argument("-o", "--memh", required=True)
    p.add_argument("--bin")
    p.add_argument("--symbols")
    args = p.parse_args(argv)
    try:
        img, syms = assemble_text(open(args.source, encoding="utf-8").read(), int(args.base, 0))
    except AsmError as e:
        print("ASM ERROR: %s" % e, file=sys.stderr)
        return 1
    write_memh(img, args.memh)
    if args.bin and img:
        lo, hi = min(img), max(img)
        open(args.bin, "wb").write(bytes(img.get(a, 0) for a in range(lo, hi + 1)))
    if args.symbols:
        with open(args.symbols, "w", newline="\n") as f:
            for k in sorted(syms):
                f.write("%s 0x%08x\n" % (k, syms[k] & XLEN_MASK))
    return 0


if __name__ == "__main__":
    sys.exit(main())
