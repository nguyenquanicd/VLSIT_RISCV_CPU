#!/usr/bin/env python3
# -----------------------------------------------------------------------------
# AI-GENERATED (Claude Opus 5.5, 2026-11-28) - candidate artifact (R-117, R-231, R-276).
# Program/expectation builder used by gen_prog.py. Sources: plan Section 5.5
# (common software flow), env/README.md (memory map, MMIO control window),
# RISC-V Privileged ISA (mtvec/stvec, mscratch, mepc, mret/sret, mstatus.FS),
# REF-001 REQ-SYS-003 (one boot address, branch on mhartid), Q-G0-03 region table.
# No RTL used. Human review pending.
# -----------------------------------------------------------------------------
"""Prog: one two-hart RV32 test program plus its expected-value records.

Memory map (cacheable region 0, Q-G0-03):
  0x80000000 code (crt + hart bodies)    0x80040000 test data (DATA_BASE)
  0x80080000 + 0x1000*h signature slots  0x80090000 + 0x400*h trap records
  0x80098000 + 0x40*h trap save area     0x800B0000 - 0x1000*h stack top
MMIO control window (region 1, testbench): see CTRL_* below and env/README.md.
Register convention: s10 = hart id, s11 = signature base; tests must not clobber them.
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, "models", "asm_rv32"))
sys.path.insert(0, os.path.join(ROOT, "models"))
import asm_rv32  # noqa: E402

BOOT = 0x80000000
DATA_BASE = 0x80040000
SIG_BASE = 0x80080000
TRAP_BASE = 0x80090000
SAVE_BASE = 0x80098000
STACK_TOP = 0x800B0000
CTRL = 0x10000000
CTRL_TOHOST, CTRL_IRQ, CTRL_DBG, CTRL_CKPT = 0x000, 0x100, 0x104, 0x200
CTRL_RESUME, CTRL_HALTED, CTRL_DBGEXC, CTRL_AXILOPS = 0x300, 0x400, 0x500, 0x600
IRQ_INDEX = {"msip": 0, "mtip": 1, "meip": 2, "ssip": 3, "stip": 4, "seip": 5}
PASS_CODE = 1
HARTS = 2
TRAP_SKIP, TRAP_RESUME, TRAP_STOP = 0, 1, 2


class Prog:
    def __init__(self, test_id, seed=1):
        self.test = test_id
        self.seed = seed
        self.body = {h: [] for h in range(HARTS)}
        self.data = []
        self.nslots = {h: 0 for h in range(HARTS)}
        self.slots = {}                  # (hart, name) -> address
        self.checks = []
        self.blocked = []
        self.plusargs = {"TIMEOUT_CYCLES": 2000000}
        self.mem_rules, self.mmio_rules, self.axil = [], [], []
        self.dump = [(SIG_BASE, SIG_BASE + 0x2000 - 1), (TRAP_BASE, TRAP_BASE + 0x800 - 1)]
        self.labels_needed = []
        self.uid = 0
        self.config = "CFG-RV32-2-P0"
        self.waveform = None
        self.extra = {}

    # ------------------------------------------------------------ helpers
    def label(self, stem):
        self.uid += 1
        return "%s_%d" % (stem, self.uid)

    def slot(self, h, name):
        key = (h, name)
        if key not in self.slots:
            self.slots[key] = SIG_BASE + 0x1000 * h + 4 * self.nslots[h]
            self.nslots[h] += 1
            if self.nslots[h] > 1000:
                raise ValueError("too many signature slots")
        return self.slots[key] - (SIG_BASE + 0x1000 * h)

    def asm(self, h, *lines):
        for ln in lines:
            self.body[h].extend(ln.strip("\n").split("\n"))

    def both(self, *lines):
        for h in range(HARTS):
            self.asm(h, *lines)

    def store_slot(self, h, reg, name):
        self.asm(h, "sw %s, %d(s11)" % (reg, self.slot(h, name)))

    def ckpt(self, h, value):
        """Checkpoint marker (MMIO write) used for AXI windows and AXI4-Lite sync."""
        self.asm(h, "li t6, 0x%x" % value, "lui t5, 0x10000", "sw t6, 0x200(t5)")

    def irq(self, h, target_hart, name, level):
        v = IRQ_INDEX[name] | (target_hart << 8) | ((1 if level else 0) << 16)
        self.asm(h, "li t6, 0x%x" % v, "lui t5, 0x10000", "sw t6, 0x100(t5)")

    def wait_axil_ops(self, h, n):
        l = self.label("wait_axil")
        self.asm(h, "lui t5, 0x10000", "li t6, %d" % n, "%s:" % l, "lw t4, 0x600(t5)", "bltu t4, t6, %s" % l)

    def delay(self, h, n):
        l = self.label("delay")
        self.asm(h, "li t6, %d" % n, "%s:" % l, "addi t6, t6, -1", "bnez t6, %s" % l)

    def flag_set(self, h, addr_label, value=1):
        self.asm(h, "la t5, %s" % addr_label, "li t6, %d" % value, "sw t6, 0(t5)")

    def flag_wait(self, h, addr_label, value=1):
        l = self.label("wait_flag")
        self.asm(h, "la t5, %s" % addr_label, "li t6, %d" % value, "%s:" % l, "lw t4, 0(t5)", "bne t4, t6, %s" % l)

    def trap_action(self, h, action, resume_label=None):
        self.asm(h, "li t5, 0x%x" % (SAVE_BASE + 0x40 * h), "li t6, %d" % action, "sw t6, 24(t5)")
        if resume_label:
            self.asm(h, "la t6, %s" % resume_label, "sw t6, 28(t5)")

    def axil_block(self, h, ck, ops):
        """Hart h raises checkpoint ck; the AXI4-Lite BFM waits for it, executes ops, and the
        hart polls MMIO 0x10000600 until all script lines so far have completed."""
        self.axil.append("WAITCK %x" % ck)
        self.axil.extend(ops)
        self.ckpt(h, ck)
        self.wait_axil_ops(h, len(self.axil))

    @staticmethod
    def axw(addr, data, strb=0xF, skew=0):
        return "W %x %x %x %d" % (addr, data & 0xFFFFFFFF, strb, skew)

    @staticmethod
    def axr(addr):
        return "R %x" % addr

    @staticmethod
    def pmu_evt_word(event_id, scope, en=1):
        return event_id | (scope << 16) | (en << 19)          # workbook pmu_evt fields

    def pmu_snapshot_ops(self, counters):
        """REF-001 11.2 S07/S08: W1C snapshot_done, request, wait, read done, read lo/hi words."""
        ops = [self.axw(0x0, 0x2), self.axw(0x0, 0x1), "WAIT 40", self.axr(0x0)]
        for k in counters:
            ops += [self.axr(0x2000 + 4 * k), self.axr(0x3000 + 4 * k)]
        return ops

    def cbo(self, h, op, label, off=0):
        self.asm(h, "la t0, %s" % label)
        if off:
            self.asm(h, "addi t0, t0, %d" % off)
        self.asm(h, "cbo.%s (t0)" % op)

    def encode(self, line):
        """Machine word of one instruction (for self-modifying code)."""
        img, _ = asm_rv32.assemble_text(line, 0)
        return sum(img[i] << (8 * i) for i in range(len(img)))

    def end(self, h, code=PASS_CODE):
        self.asm(h, "li a0, %d" % code, "j test_end")

    def check(self, cid, req, kind, **params):
        self.checks.append({"id": cid, "req": req, "kind": kind, "params": params})

    def block(self, cid, req, reason):
        self.blocked.append({"id": cid, "req": req, "reason": reason})

    def word(self, label, *values, align=4):
        self.data.append(".align %d" % align)
        self.data.append("%s:" % label)
        self.data.append(".word " + ", ".join("0x%x" % (v & 0xFFFFFFFF) for v in values))

    def line(self, label, words=(0, 0, 0, 0)):
        """A 16-byte cache line (REF-001 9: 16-byte line) at a 64-byte aligned address."""
        self.data.append(".align 6")
        self.data.append("%s:" % label)
        self.data.append(".word " + ", ".join("0x%x" % (w & 0xFFFFFFFF) for w in words))

    # ------------------------------------------------------------- source
    def crt(self):
        return """
# ---- crt: common software flow (plan 5.5) ----
_start:
        csrr  s10, mhartid
        li    t0, %d
        bgeu  s10, t0, park
        la    t0, trap_m
        csrw  mtvec, t0
        la    t0, trap_s
        csrw  stvec, t0
        slli  t1, s10, 12
        li    sp, 0x%x
        sub   sp, sp, t1
        li    s11, 0x%x
        add   s11, s11, t1
        slli  t1, s10, 6
        li    t0, 0x%x
        add   t0, t0, t1
        csrw  mscratch, t0
        slli  t2, s10, 10
        li    t3, 0x%x
        add   t3, t3, t2
        sw    zero, 0(t3)
        addi  t3, t3, 16
        sw    t3, 16(t0)
        sw    zero, 24(t0)
        csrw  sscratch, t0
        li    t0, 0x2000
        csrs  mstatus, t0                 # mstatus.FS = Initial: enable the F extension
        csrw  fcsr, zero
        beqz  s10, hart0_main
        j     hart1_main
park:
        wfi
        j     park
# ---- end of test: publish signature, trap records and save area, then TOHOST ----
test_end:
        mv    s9, a0
        mv    t0, s11
        li    t1, %d
end_flush_sig:
        cbo.flush (t0)
        addi  t0, t0, 16
        addi  t1, t1, -1
        bnez  t1, end_flush_sig
        slli  t2, s10, 10
        li    t0, 0x%x
        add   t0, t0, t2
        li    t1, 64
end_flush_trap:
        cbo.flush (t0)
        addi  t0, t0, 16
        addi  t1, t1, -1
        bnez  t1, end_flush_trap
        fence rw, rw
        lui   t0, 0x10000
        slli  t1, s10, 3
        add   t0, t0, t1
        sw    s9, 0(t0)                   # TOHOST[hart]
end_park:
        wfi
        j     end_park
# ---- machine trap handler: record {cause, epc, tval, level}, then act ----
trap_m:
        csrrw t0, mscratch, t0
        sw    t1, 4(t0)
        sw    t2, 8(t0)
        sw    t3, 12(t0)
        csrr  t1, mscratch
        sw    t1, 0(t0)
        lw    t2, 16(t0)
        csrr  t1, mcause
        sw    t1, 0(t2)
        csrr  t1, mepc
        sw    t1, 4(t2)
        csrr  t1, mtval
        sw    t1, 8(t2)
        li    t1, 3
        sw    t1, 12(t2)
        addi  t2, t2, 16
        sw    t2, 16(t0)
        slli  t3, s10, 10
        li    t1, 0x%x
        add   t3, t3, t1
        lw    t1, 0(t3)
        addi  t1, t1, 1
        sw    t1, 0(t3)
        csrr  t1, mcause
        blt   t1, zero, trap_m_irq
        lw    t3, 24(t0)
        li    t1, 1
        beq   t3, t1, trap_m_resume
        li    t1, 2
        beq   t3, t1, trap_m_stop
        csrr  t1, mepc
        lhu   t2, 0(t1)
        andi  t2, t2, 3
        li    t3, 3
        bne   t2, t3, trap_m_skip2
        addi  t1, t1, 2
trap_m_skip2:
        addi  t1, t1, 2
        csrw  mepc, t1
        j     trap_m_ret
trap_m_resume:
        lw    t1, 28(t0)
        csrw  mepc, t1
        sw    zero, 24(t0)
        j     trap_m_ret
trap_m_stop:
        li    a0, 0xDEAD
        j     test_end
trap_m_irq:
        andi  t1, t1, 0x3ff
        la    t2, irq_index_map
        slli  t1, t1, 2
        add   t2, t2, t1
        lw    t1, 0(t2)
        slli  t2, s10, 8
        or    t1, t1, t2
        lui   t2, 0x10000
        sw    t1, 0x100(t2)               # drop the level of the serviced source
        li    t1, 0x2                     # also clear software-writable SSIP
        csrc  mip, t1
trap_m_ret:
        lw    t1, 4(t0)
        lw    t2, 8(t0)
        lw    t3, 12(t0)
        csrw  mscratch, t0
        lw    t0, 0(t0)
        mret
# ---- supervisor trap handler (delegated traps): same record, level 1 ----
trap_s:
        csrrw t0, sscratch, t0
        sw    t1, 4(t0)
        sw    t2, 8(t0)
        sw    t3, 12(t0)
        csrr  t1, sscratch
        sw    t1, 0(t0)
        lw    t2, 16(t0)
        csrr  t1, scause
        sw    t1, 0(t2)
        csrr  t1, sepc
        sw    t1, 4(t2)
        csrr  t1, stval
        sw    t1, 8(t2)
        li    t1, 1
        sw    t1, 12(t2)
        addi  t2, t2, 16
        sw    t2, 16(t0)
        slli  t3, s10, 10
        li    t1, 0x%x
        add   t3, t3, t1
        lw    t1, 0(t3)
        addi  t1, t1, 1
        sw    t1, 0(t3)
        csrr  t1, scause
        blt   t1, zero, trap_s_irq
        lw    t3, 24(t0)
        li    t1, 1
        beq   t3, t1, trap_s_resume
        csrr  t1, sepc
        lhu   t2, 0(t1)
        andi  t2, t2, 3
        li    t3, 3
        bne   t2, t3, trap_s_skip2
        addi  t1, t1, 2
trap_s_skip2:
        addi  t1, t1, 2
        csrw  sepc, t1
        j     trap_s_ret
trap_s_resume:
        lw    t1, 28(t0)
        csrw  sepc, t1
        sw    zero, 24(t0)
        j     trap_s_ret
trap_s_irq:
        andi  t1, t1, 0x3ff
        la    t2, irq_index_map
        slli  t1, t1, 2
        add   t2, t2, t1
        lw    t1, 0(t2)
        slli  t2, s10, 8
        or    t1, t1, t2
        lui   t2, 0x10000
        sw    t1, 0x100(t2)
        li    t1, 0x2
        csrc  sip, t1
trap_s_ret:
        lw    t1, 4(t0)
        lw    t2, 8(t0)
        lw    t3, 12(t0)
        csrw  sscratch, t0
        lw    t0, 0(t0)
        sret
""" % (HARTS, STACK_TOP, SIG_BASE, SAVE_BASE, TRAP_BASE, self._sig_lines(), TRAP_BASE, TRAP_BASE, TRAP_BASE)

    def _sig_lines(self):
        return max(1, (max(self.nslots.values()) * 4 + 15) // 16)

    def source(self):
        out = ["# AI-GENERATED by scripts/generators/gen_prog.py for %s (seed %d). DO NOT EDIT." % (self.test, self.seed),
               ".org 0x%x" % BOOT, self.crt()]
        for h in range(HARTS):
            out.append("hart%d_main:" % h)
            out.extend("        " + l if not l.endswith(":") else l for l in self.body[h])
            out.append("        li a0, 0xBAD0")
            out.append("        j test_end")
        out.append(".align 2")
        out.append("irq_index_map:      # mcause code -> testbench IRQ index (level 0 clears)")
        m = [0] * 12
        m[3], m[7], m[11], m[1], m[5], m[9] = 0, 1, 2, 3, 4, 5
        out.append(".word " + ", ".join(str(v) for v in m))
        out.append(".org 0x%x" % DATA_BASE)
        out.extend(self.data if self.data else [".word 0"])
        return "\n".join(out) + "\n"

    def build(self, outdir):
        src = self.source()
        img, syms = asm_rv32.assemble_text(src, BOOT)
        files = {"prog.S": src}
        lo = min(img)
        lines, addr = [], None
        for a in sorted(set(k & ~3 for k in img)):
            if addr is None or a != addr + 4:
                lines.append("@%08x" % (a // 4))
            lines.append("%08x" % sum(img.get(a + i, 0) << (8 * i) for i in range(4)))
            addr = a
        files["prog.memh"] = "\n".join(lines) + "\n"
        files["symbols.json"] = json.dumps({k: "0x%08x" % (v & 0xFFFFFFFF) for k, v in sorted(syms.items())}, indent=1) + "\n"
        resolved = json.loads(json.dumps(self.checks), object_hook=lambda d: _resolve(d, syms))
        exp = {"test": self.test, "seed": self.seed, "configuration": self.config,
               "slots": {"%d:%s" % k: "0x%08x" % v for k, v in sorted(self.slots.items())},
               "trap_base": "0x%08x" % TRAP_BASE, "sig_base": "0x%08x" % SIG_BASE,
               "checks": resolved, "blocked_checks": self.blocked, "extra": self.extra}
        files["expected.json"] = json.dumps(exp, indent=1) + "\n"
        files["mem_rules.txt"] = "\n".join(_sub(r, syms) for r in self.mem_rules) + ("\n" if self.mem_rules else "")
        files["mmio_rules.txt"] = "\n".join(_sub(r, syms) for r in self.mmio_rules) + ("\n" if self.mmio_rules else "")
        files["axil_script.txt"] = "\n".join(self.axil + ["END"]) + "\n"
        files["dump_ranges.txt"] = "\n".join("%x %x" % r for r in self.dump) + "\n"
        pa = dict(self.plusargs)
        pa.update({"TEST": self.test, "SEED": self.seed, "MEM_IMAGE": "prog.memh", "MMIO_ROM": "../../../env/generated/debug_rom.memh",
                   "MEM_ERR": "mem_rules.txt", "MMIO_ERR": "mmio_rules.txt", "AXIL_SCRIPT": "axil_script.txt",
                   "MEM_DUMP": "dump_ranges.txt", "MEM_DUMP_OUT": "mem_dump.ndjson", "MEM_MON": "axi_mem.ndjson",
                   "MMIO_MON": "axi_mmio.ndjson", "AXIL_MON": "axil.ndjson", "PIN_MON": "pins.ndjson",
                   "SVA_LOG": "sva.ndjson", "MEM_STALE_LOG": "stale_mem.ndjson", "MMIO_STALE_LOG": "stale_mmio.ndjson",
                   "WD_LOG": "watchdog.ndjson", "MEM_LOG": "bfm_mem.ndjson", "MMIO_LOG": "bfm_mmio.ndjson"})
        if self.waveform:
            pa["WAVE"] = "wave.vcd"
            pa["WAVE_SCOPE"] = "ports"
        files["plusargs.txt"] = "\n".join("+%s=%s" % (k, v) for k, v in sorted(pa.items())) + "\n"
        return files


def _resolve(d, syms):
    """Replace {'label': name, 'off': n} objects by absolute addresses."""
    if set(d) <= {"label", "off"} and "label" in d:
        return (syms[d["label"]] + d.get("off", 0)) & 0xFFFFFFFF
    return d


def L(name, off=0):
    """Reference to a program label inside check parameters."""
    return {"label": name, "off": off}


def SLOT(p, h, name):
    """Absolute address of signature slot 'name' of hart h."""
    return SIG_BASE + 0x1000 * h + p.slot(h, name)


def _sub(rule, syms):
    """Replace {label} / {label+N} tokens in BFM rule lines by hexadecimal addresses."""
    import re
    def rep(m):
        name, off = m.group(1), int(m.group(2) or "0", 0)
        return "%x" % ((syms[name] + off) & 0xFFFFFFFFFFFFFFFF)
    return re.sub(r"\{(\w+)(?:\+(\w+))?\}", rep, rule)
