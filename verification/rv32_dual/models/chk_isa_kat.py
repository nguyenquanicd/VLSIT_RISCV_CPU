#!/usr/bin/env python3
# -----------------------------------------------------------------------------
# AI-GENERATED (Claude Opus 5.5, 2026-11-27) - candidate artifact (R-117, R-231).
# Sources: RISC-V Unprivileged ISA (RV32I/M, Zba/Zbb/Zbc/Zbs, Zicond, Zcb
# semantics), RISC-V Scalar Cryptography v1.0 (Zbkb/Zbkx/Zkne/Zknd/Zknh RV32
# pseudo-code), FIPS 197 (AES S-box, MixColumns), FIPS 180-4 (SHA-256/512
# sigma functions). No RTL used. Human review: pending.
# -----------------------------------------------------------------------------
"""chk_isa_kat - reference semantics for the RV32 integer/extension instructions
checked by known-answer tests (plan 5.2; REQ-XL-003).

API: isa_op(op, rs1, rs2=0, imm=0) -> 32-bit result
     check_record(rec) -> list of mismatch strings (NDJSON record type 'isa').
"""
M32 = 0xFFFFFFFF


def s32(x):
    x &= M32
    return x - (1 << 32) if x & 0x80000000 else x


def ror(x, n):
    n &= 31
    return ((x >> n) | (x << (32 - n))) & M32 if n else x & M32


def rol(x, n):
    return ror(x, (32 - (n & 31)) & 31)


# ----------------------------------------------------------------- AES (FIPS 197)
def gmul(a, b):
    p = 0
    for _ in range(8):
        if b & 1:
            p ^= a
        hi = a & 0x80
        a = (a << 1) & 0xFF
        if hi:
            a ^= 0x1B
        b >>= 1
    return p


def _ginv(a):
    if a == 0:
        return 0
    r = 1
    for _ in range(254):          # a^254 = a^-1 in GF(2^8)
        r = gmul(r, a)
    return r


def _affine(x):
    r = 0x63
    for i in range(8):
        b = ((x >> i) ^ (x >> ((i + 4) % 8)) ^ (x >> ((i + 5) % 8)) ^ (x >> ((i + 6) % 8)) ^ (x >> ((i + 7) % 8))) & 1
        r ^= b << i
    return r


SBOX = [_affine(_ginv(i)) for i in range(256)]
INV_SBOX = [0] * 256
for _i, _v in enumerate(SBOX):
    INV_SBOX[_v] = _i


def aes32(op, rs1, rs2, bs):
    si = (rs2 >> (8 * bs)) & 0xFF
    if op in ("aes32esi", "aes32esmi"):
        so = SBOX[si]
        if op == "aes32esmi":
            mixed = (gmul(so, 3) << 24) | (so << 16) | (so << 8) | gmul(so, 2)
        else:
            mixed = so
    else:
        so = INV_SBOX[si]
        if op == "aes32dsmi":
            mixed = (gmul(so, 0xB) << 24) | (gmul(so, 0xD) << 16) | (gmul(so, 0x9) << 8) | gmul(so, 0xE)
        else:
            mixed = so
    return (rs1 ^ rol(mixed, 8 * bs)) & M32


# -------------------------------------------------------------- bit helpers
def clmul_full(a, b):
    r = 0
    for i in range(32):
        if (b >> i) & 1:
            r ^= a << i
    return r


def zip32(x):
    r = 0
    for i in range(16):
        r |= ((x >> i) & 1) << (2 * i)
        r |= ((x >> (i + 16)) & 1) << (2 * i + 1)
    return r


def unzip32(x):
    r = 0
    for i in range(16):
        r |= ((x >> (2 * i)) & 1) << i
        r |= ((x >> (2 * i + 1)) & 1) << (i + 16)
    return r


def xperm(rs1, rs2, width):
    n = 32 // width
    mask = (1 << width) - 1
    r = 0
    for i in range(n):
        idx = (rs2 >> (i * width)) & mask
        v = (rs1 >> (idx * width)) & mask if idx < n else 0
        r |= v << (i * width)
    return r


def isa_op(op, rs1, rs2=0, imm=0):
    a, b = rs1 & M32, rs2 & M32
    sh = b & 31
    t = {
        "add": lambda: a + b, "sub": lambda: a - b, "sll": lambda: a << sh, "srl": lambda: a >> sh,
        "sra": lambda: s32(a) >> sh, "slt": lambda: int(s32(a) < s32(b)), "sltu": lambda: int(a < b),
        "xor": lambda: a ^ b, "or": lambda: a | b, "and": lambda: a & b,
        "mul": lambda: a * b, "mulh": lambda: (s32(a) * s32(b)) >> 32, "mulhsu": lambda: (s32(a) * b) >> 32,
        "mulhu": lambda: (a * b) >> 32,
        "div": lambda: -1 if b == 0 else (s32(a) if (s32(a) == -(1 << 31) and s32(b) == -1) else int(abs(s32(a)) // abs(s32(b))) * (1 if (s32(a) < 0) == (s32(b) < 0) else -1)),
        "divu": lambda: M32 if b == 0 else a // b,
        "rem": lambda: a if b == 0 else (0 if (s32(a) == -(1 << 31) and s32(b) == -1) else (abs(s32(a)) % abs(s32(b))) * (-1 if s32(a) < 0 else 1)),
        "remu": lambda: a if b == 0 else a % b,
        "sh1add": lambda: (a << 1) + b, "sh2add": lambda: (a << 2) + b, "sh3add": lambda: (a << 3) + b,
        "andn": lambda: a & ~b, "orn": lambda: a | ~b, "xnor": lambda: ~(a ^ b),
        "clz": lambda: 32 - a.bit_length(), "ctz": lambda: 32 if a == 0 else (a & -a).bit_length() - 1,
        "cpop": lambda: bin(a).count("1"),
        "max": lambda: a if s32(a) > s32(b) else b, "maxu": lambda: max(a, b),
        "min": lambda: a if s32(a) < s32(b) else b, "minu": lambda: min(a, b),
        "sext.b": lambda: s32(((a & 0xFF) ^ 0x80) - 0x80), "sext.h": lambda: s32(((a & 0xFFFF) ^ 0x8000) - 0x8000),
        "zext.h": lambda: a & 0xFFFF, "zext.b": lambda: a & 0xFF, "not": lambda: ~a,
        "rol": lambda: rol(a, sh), "ror": lambda: ror(a, sh), "rori": lambda: ror(a, imm),
        "orc.b": lambda: sum((0xFF if (a >> (8 * i)) & 0xFF else 0) << (8 * i) for i in range(4)),
        "rev8": lambda: sum(((a >> (8 * i)) & 0xFF) << (8 * (3 - i)) for i in range(4)),
        "clmul": lambda: clmul_full(a, b), "clmulh": lambda: clmul_full(a, b) >> 32,
        "clmulr": lambda: clmul_full(a, b) >> 31,
        "bclr": lambda: a & ~(1 << sh), "bset": lambda: a | (1 << sh), "binv": lambda: a ^ (1 << sh),
        "bext": lambda: (a >> sh) & 1,
        "bclri": lambda: a & ~(1 << imm), "bseti": lambda: a | (1 << imm), "binvi": lambda: a ^ (1 << imm),
        "bexti": lambda: (a >> imm) & 1,
        "pack": lambda: (a & 0xFFFF) | ((b & 0xFFFF) << 16), "packh": lambda: (a & 0xFF) | ((b & 0xFF) << 8),
        "brev8": lambda: sum(int("{:08b}".format((a >> (8 * i)) & 0xFF)[::-1], 2) << (8 * i) for i in range(4)),
        "zip": lambda: zip32(a), "unzip": lambda: unzip32(a),
        "xperm4": lambda: xperm(a, b, 4), "xperm8": lambda: xperm(a, b, 8),
        "czero.eqz": lambda: 0 if b == 0 else a, "czero.nez": lambda: 0 if b != 0 else a,
        "sha256sum0": lambda: ror(a, 2) ^ ror(a, 13) ^ ror(a, 22),
        "sha256sum1": lambda: ror(a, 6) ^ ror(a, 11) ^ ror(a, 25),
        "sha256sig0": lambda: ror(a, 7) ^ ror(a, 18) ^ (a >> 3),
        "sha256sig1": lambda: ror(a, 17) ^ ror(a, 19) ^ (a >> 10),
        "sha512sum0r": lambda: (a << 25) ^ (a << 30) ^ (a >> 28) ^ (b >> 7) ^ (b >> 2) ^ (b << 4),
        "sha512sum1r": lambda: (a << 23) ^ (a >> 14) ^ (a >> 18) ^ (b >> 9) ^ (b << 18) ^ (b << 14),
        "sha512sig0l": lambda: (a >> 1) ^ (a >> 7) ^ (a >> 8) ^ (b << 31) ^ (b << 25) ^ (b << 24),
        "sha512sig0h": lambda: (a >> 1) ^ (a >> 7) ^ (a >> 8) ^ (b << 31) ^ (b << 24),
        "sha512sig1l": lambda: (a << 3) ^ (a >> 6) ^ (a >> 19) ^ (b >> 29) ^ (b << 26) ^ (b << 13),
        "sha512sig1h": lambda: (a << 3) ^ (a >> 6) ^ (a >> 19) ^ (b >> 29) ^ (b << 13),
    }
    if op in ("aes32esi", "aes32esmi", "aes32dsi", "aes32dsmi"):
        if not 0 <= imm <= 3:
            raise ValueError("bs out of range")
        return aes32(op, a, b, imm)
    if op in ("rori", "bclri", "bseti", "binvi", "bexti") and not 0 <= imm <= 31:
        raise ValueError("shamt out of range")
    if op not in t:
        raise ValueError("unsupported op %r" % op)
    return t[op]() & M32


# ----------------------------------------- FIPS 180-4 64-bit reference functions
def _ror64(x, n):
    return ((x >> n) | (x << (64 - n))) & ((1 << 64) - 1)


def sha512_ref(fn, x):
    return {"sum0": lambda: _ror64(x, 28) ^ _ror64(x, 34) ^ _ror64(x, 39),
            "sum1": lambda: _ror64(x, 14) ^ _ror64(x, 18) ^ _ror64(x, 41),
            "sig0": lambda: _ror64(x, 1) ^ _ror64(x, 8) ^ (x >> 7),
            "sig1": lambda: _ror64(x, 19) ^ _ror64(x, 61) ^ (x >> 6)}[fn]()


def check_record(rec):
    """NDJSON 'isa' record: {op, rs1, rs2?, imm?, rd}."""
    h = lambda k, d=0: (int(rec[k], 0) if isinstance(rec[k], str) else int(rec[k])) if k in rec and rec[k] is not None else d
    exp = isa_op(rec["op"], h("rs1"), h("rs2"), h("imm"))
    got = h("rd") & M32
    return [] if got == exp else ["%s rs1=0x%08x rs2=0x%08x imm=%d rd 0x%08x expected 0x%08x" % (rec["op"], h("rs1"), h("rs2"), h("imm"), got, exp)]
