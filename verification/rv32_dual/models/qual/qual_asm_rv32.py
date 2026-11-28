# AI-GENERATED (Claude Opus 5.5, 2026-11-27) - candidate; human review pending.
"""Qualification of asm_rv32 (plan 5.6; RISK-04 decision at G1)."""
import copy
import json
import os
from qual_common import Suite, MODELS
import asm_rv32 as A

KAT = os.path.join(MODELS, "asm_rv32", "kat_encodings.json")
NEG = os.path.join(MODELS, "asm_rv32", "kat_negative.json")
SOURCES = ["asm_rv32/asm_rv32.py", "asm_rv32/kat_encodings.json", "asm_rv32/kat_negative.json", "qual/qual_asm_rv32.py"]
KIND = "model"


def words(text, base=0x1000):
    img, _ = A.assemble_text(text, base)
    n = len(img)
    if n == 2:
        return [img[base] | img[base + 1] << 8]
    return [sum(img[base + 4 * j + i] << (8 * i) for i in range(4)) for j in range(n // 4)]


def kat_failures(kat):
    bad = 0
    for v in kat["vectors"]:
        try:
            if words(v[0]) != [int(v[1].replace(" ", ""), 2)]:
                bad += 1
        except A.AsmError:
            bad += 1
    return bad


def run():
    s = Suite()
    kat = json.load(open(KAT, encoding="utf-8"))
    for v in kat["vectors"]:
        exp = int(v[1].replace(" ", ""), 2)
        try:
            got = words(v[0])
        except A.AsmError as e:
            got = str(e)
        s.eq("known_answer", "%s [%s]" % (v[0], v[2]), [exp], got)
        if len(v) > 3 and v[3].startswith("anchor"):
            s.eq("known_answer", "anchor consistency: %s" % v[0], int(v[3].split()[1], 16), exp)
    for v in kat["pseudo"]:
        s.eq("known_answer", "pseudo %s" % v[0], [int(b.replace(" ", ""), 2) for b in v[1]], words(v[0]))
    for v in json.load(open(NEG, encoding="utf-8"))["vectors"]:
        s.raises("negative", "%s (%s)" % (v[0].replace("\n", " | "), v[1]), lambda t=v[0]: A.assemble_text(t, 0x1000), A.AsmError)
    # boundary: extreme legal immediates accepted with the right field values
    for src, exp in [("addi a0, a1, 2047", 0x7FF58513), ("addi a0, a1, -2048", 0x80058513),
                     ("beq a0, a1, 4094", int("0 111111 01011 01010 000 1111 1 1100011".replace(" ", ""), 2)),
                     ("beq a0, a1, -4096", int("1 000000 01011 01010 000 0000 0 1100011".replace(" ", ""), 2)),
                     ("jal x0, 1048574", int("0 1111111111 1 11111111 00000 1101111".replace(" ", ""), 2)),
                     ("jal x0, -1048576", int("1 0000000000 0 00000000 00000 1101111".replace(" ", ""), 2)),
                     ("lui a0, 0xfffff", 0xFFFFF537), ("csrrw x0, 4095, x0", 0xFFF01073),
                     ("slli a0, a1, 0", 0x00059513)]:
        s.eq("boundary", src, [exp], words(src))
    for src, exp in [("c.addi a0, 31", int("000 0 01010 11111 01".replace(" ", ""), 2)),
                     ("c.addi a0, -32", int("000 1 01010 00000 01".replace(" ", ""), 2)),
                     ("c.j 2046", int("101 0 1 11 1 1 1 111 1 01".replace(" ", ""), 2)),
                     ("c.j -2048", int("101 1 0 00 0 0 0 000 0 01".replace(" ", ""), 2)),
                     ("c.addi4spn a0, sp, 1020", int("000 11111111 010 00".replace(" ", ""), 2)),
                     ("c.addi16sp sp, 496", int("011 0 00010 1 1 11 1 01".replace(" ", ""), 2)),
                     ("c.beqz a0, 254", int("110 0 11 010 11 11 1 01".replace(" ", ""), 2)),
                     ("c.beqz a0, -256", int("110 1 00 010 00 00 0 01".replace(" ", ""), 2))]:
        s.eq("boundary", src, [exp], words(src))
    prog = "start: li t0, 0x12345678\n  la a0, data\n  beqz a0, start\n  j end\n  .align 3\ndata: .word 0xdeadbeef, start\nend: c.nop\n"
    s.eq("boundary", "determinism: same program assembled twice gives identical image",
         A.assemble_text(prog)[0], A.assemble_text(prog)[0])
    img, syms = A.assemble_text(prog, 0x80000000)
    s.eq("boundary", "forward label + .word of a label", syms["start"], sum(img[syms["data"] + 4 + i] << (8 * i) for i in range(4)))
    s.not_applicable("reset", "stateless tool: each assemble_text call starts from an empty image and symbol table")
    # fault detection: mutate the encoding tables; the KAT must fail
    muts = [("R_OPS['sub'] funct7 0x20->0x00", lambda: A.R_OPS.__setitem__("sub", (0x00, 0))),
            ("I_ALU['xori'] funct3 4->6", lambda: A.I_ALU.__setitem__("xori", 6)),
            ("AMO_OPS['amoadd.w'] funct5 0x00->0x01", lambda: A.AMO_OPS.__setitem__("amoadd.w", 0x01)),
            ("FP_R['fdiv.s'] funct7 0x0C->0x08", lambda: A.FP_R.__setitem__("fdiv.s", (0x08, None))),
            ("UNARY_IMM['rev8'] imm 0x698->0x688", lambda: A.UNARY_IMM.__setitem__("rev8", (0x688, 5))),
            ("CBO['cbo.clean'] imm 1->2", lambda: A.CBO.__setitem__("cbo.clean", 0x002)),
            ("CB_ALU['c.xor'] 1->2", lambda: A.CB_ALU.__setitem__("c.xor", 2)),
            ("btype offset bit 11 dropped", lambda: setattr(A, "btype", _bad_btype(A.btype)))]
    for name, apply in muts:
        saved = {k: copy.copy(getattr(A, k)) for k in ("R_OPS", "I_ALU", "AMO_OPS", "FP_R", "UNARY_IMM", "CBO", "CB_ALU")}
        saved_b = A.btype
        apply()
        n = kat_failures(kat) + _branch_extra()
        for k, v in saved.items():
            getattr(A, k).clear()
            getattr(A, k).update(v)
        A.btype = saved_b
        s.detected("model mutation %s" % name, ["%d KAT vector(s) failed" % n] if n else [])
    return s


def _bad_btype(orig):
    return lambda off, rs2, rs1, f3: orig(off & ~0x800, rs2, rs1, f3)


def _branch_extra():
    """A KAT-style vector with offset bit 11 set (beq -4 sets bits 11..)."""
    try:
        return 0 if words("bne a0, a1, -4") == [int("1 111111 01011 01010 001 1110 1 1100011".replace(" ", ""), 2)] else 1
    except A.AsmError:
        return 1
