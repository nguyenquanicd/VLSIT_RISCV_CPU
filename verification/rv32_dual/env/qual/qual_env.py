# AI-GENERATED (Claude Opus 5.5, 2026-11-28) - candidate; human review pending.
"""Qualification suites (plan 5.6) for the Python environment checkers, run on synthetic
NDJSON logs that follow models/README.md: chk_axi_mem_sb, chk_axi_mmio_sb, chk_axil_sb,
chk_sig, cov_collect and the evaluator scripts/evaluate_run.py."""
import json
import os
import shutil
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
for p in ("models/qual", "models", "models/common", "env/scoreboards", "env/coverage", "scripts"):
    sys.path.insert(0, os.path.join(ROOT, p))
from qual_common import Suite          # noqa: E402
import axi_sb_core                     # noqa: E402
import chk_axi_mem_sb as MEMSB         # noqa: E402
import chk_axi_mmio_sb as MMIOSB       # noqa: E402
import chk_axil_sb as AXILSB           # noqa: E402
import chk_sig as SIG                  # noqa: E402
import cov_collect as COV              # noqa: E402

CK = 0x10000200


def ck(v, cyc):
    return [{"type": "axi", "port": "mmio", "ch": "AW", "cycle": cyc, "id": 1, "addr": hex(CK), "len": 0, "size": 2, "burst": 1, "lock": 0, "atop": 0},
            {"type": "axi", "port": "mmio", "ch": "W", "cycle": cyc + 1, "data": hex(v), "strb": 15, "last": 1},
            {"type": "axi", "port": "mmio", "ch": "B", "cycle": cyc + 3, "id": 1, "resp": 0}]


def line_write(addr, words, cyc, idv=3, beats=2, strb=0xFF, resp=0, last_on=None, port="mem"):
    d = [words[0] | (words[1] << 32), words[2] | (words[3] << 32)]
    out = [{"type": "axi", "port": port, "ch": "AW", "cycle": cyc, "id": idv, "addr": hex(addr), "len": beats - 1, "size": 3, "burst": 1, "lock": 0, "atop": 0}]
    for i in range(beats):
        out.append({"type": "axi", "port": port, "ch": "W", "cycle": cyc + 1 + i, "data": hex(d[i % 2]), "strb": strb,
                    "last": int(i == (beats - 1 if last_on is None else last_on))})
    out.append({"type": "axi", "port": port, "ch": "B", "cycle": cyc + 5, "id": idv, "resp": resp})
    return out


def line_read(addr, cyc, idv=5, beats=2, port="mem"):
    out = [{"type": "axi", "port": port, "ch": "AR", "cycle": cyc, "id": idv, "addr": hex(addr), "len": 1, "size": 3, "burst": 1, "lock": 0}]
    for i in range(beats):
        out.append({"type": "axi", "port": port, "ch": "R", "cycle": cyc + 2 + i, "id": idv, "data": "0x0", "resp": 0, "last": int(i == beats - 1)})
    return out


WORDS = [0x11111111, 0x22222222, 0x33333333, 0x44444444]
DATA = "".join(w.to_bytes(4, "little").hex() for w in WORDS)
RULES = [{"kind": "write_line", "addr": 0x80001000, "window": [0x11, 0x12], "beats": 2, "strobe_full": True, "data": DATA, "resp": 0},
         {"kind": "no_write", "lo": 0x80002000, "hi": 0x8000200F, "window": [0x11, 0x12]},
         {"kind": "read_present", "lo": 0x80003000, "hi": 0x8000300F, "window": [0x11, 0x12]},
         {"kind": "structural", "window": [None, None], "complete": True}]


def base_log():
    return ck(0x11, 10) + line_write(0x80001000, WORDS, 20) + line_read(0x80003000, 30) + ck(0x12, 50) + line_write(0x80002000, WORDS, 60)


def errs(results):
    return [e for _, es in results for e in es]


def suite_axi_mem():
    s = Suite()
    s.eq("known_answer", "line write, absence, read presence and structure in a checkpoint window", [], errs(MEMSB.check(base_log(), RULES)))
    w, r, e = axi_sb_core.rebuild(base_log(), "mem")
    s.eq("known_answer", "transactions rebuilt (2 writes, 1 read, no structural error)", (2, 1, []), (len(w), len(r), e))
    s.eq("known_answer", "checkpoints extracted from MMIO writes", [(0x11, 10), (0x12, 50)], axi_sb_core.checkpoints(base_log()))
    s.eq("boundary", "write outside the window is ignored by no_write", [], errs(MEMSB.check(base_log(), [RULES[1]])))
    s.eq("boundary", "open window [None, None] covers the whole run", [], errs(MEMSB.check(base_log(), [{"kind": "read_present", "lo": 0x80003000, "hi": 0x80003000, "window": [None, None]}])))
    s.eq("boundary", "reset record clears outstanding state", [], axi_sb_core.rebuild([{"type": "axi", "port": "mem", "ch": "AR", "cycle": 1, "id": 2, "addr": "0x80000000", "len": 0, "size": 3, "burst": 1},
                                                                                    {"type": "axi", "port": "mem", "ch": "RST", "cycle": 2}], "mem")[2])
    s.eq("negative", "missing checkpoint reported", True, bool(errs(MEMSB.check(base_log(), [dict(RULES[0], window=[0x77, None])]))))
    s.eq("negative", "unknown rule kind reported", True, bool(errs(MEMSB.check(base_log(), [{"kind": "bogus", "window": [None, None]}]))))
    s.not_applicable("reset", "stateless per call; RST records covered under boundary")
    faults = {
        "3 beats instead of 2 (REQ-XL-012)": ck(0x11, 10) + line_write(0x80001000, WORDS, 20, beats=3) + line_read(0x80003000, 30) + ck(0x12, 50),
        "data byte flipped": ck(0x11, 10) + line_write(0x80001000, [0x11111110] + WORDS[1:], 20) + line_read(0x80003000, 30) + ck(0x12, 50),
        "partial strobe on line writeback": ck(0x11, 10) + line_write(0x80001000, WORDS, 20, strb=0x0F) + line_read(0x80003000, 30) + ck(0x12, 50),
        "B with an unknown ID": base_log() + [{"type": "axi", "port": "mem", "ch": "B", "cycle": 99, "id": 9, "resp": 0}],
        "write to a line that must not be written": ck(0x11, 10) + line_write(0x80001000, WORDS, 20) + line_write(0x80002000, WORDS, 25, idv=4) + line_read(0x80003000, 30) + ck(0x12, 50),
        "address bit 34 set (REQ-XL-006)": base_log() + line_read(0x400000000, 70, idv=6),
        "WLAST on the first beat": ck(0x11, 10) + line_write(0x80001000, WORDS, 20, last_on=0) + line_read(0x80003000, 30) + ck(0x12, 50),
        "expected read missing": ck(0x11, 10) + line_write(0x80001000, WORDS, 20) + ck(0x12, 50),
        "error response where OKAY expected": ck(0x11, 10) + line_write(0x80001000, WORDS, 20, resp=2) + line_read(0x80003000, 30) + ck(0x12, 50),
    }
    for name, log in faults.items():
        s.detected(name, errs(MEMSB.check(log, RULES)))
    return s


def suite_axi_mmio():
    s = Suite()
    log = ck(0xC0, 10) + [{"type": "axi", "port": "mmio", "ch": "AW", "cycle": 20, "id": 2, "addr": "0x10000804", "len": 0, "size": 2, "burst": 1, "lock": 0, "atop": 0},
                          {"type": "axi", "port": "mmio", "ch": "W", "cycle": 21, "data": "0x1234567800000000", "strb": 0xF0, "last": 1},
                          {"type": "axi", "port": "mmio", "ch": "B", "cycle": 23, "id": 2, "resp": 0}] + ck(0xC2, 40)
    rules = [{"kind": "write_present", "lo": 0x10000804, "hi": 0x10000807, "window": [0xC0, 0xC2], "data32": 0x12345678},
             {"kind": "structural", "window": [None, None]}]
    s.eq("known_answer", "MMIO word store at byte lane 4 with data on the upper half", [], errs(MMIOSB.check(log, rules)))
    s.eq("boundary", "memory-port rules ignore MMIO records", [], errs(MEMSB.check(log, [{"kind": "no_write", "lo": 0x10000000, "hi": 0x1FFFFFFF, "window": [None, None]}])))
    s.eq("negative", "absent write reported", True, bool(errs(MMIOSB.check(ck(0xC0, 10) + ck(0xC2, 40), rules[:1]))))
    s.not_applicable("reset", "same engine as chk_axi_mem_sb")
    bad_data = [dict(r, data="0x1234567900000000") if r.get("ch") == "W" and r["cycle"] == 21 else r for r in log]
    s.detected("wrong MMIO store data", errs(MMIOSB.check(bad_data, rules)))
    s.detected("MMIO address leaked to the memory port", errs(MEMSB.check(log + [dict(r, port="mem") for r in log[3:6]],
                                                                         [{"kind": "no_write", "lo": 0x10000000, "hi": 0x1FFFFFFF, "window": [None, None]}])))
    s.detected("MMIO R without request", errs(MMIOSB.check(log + [{"type": "axi", "port": "mmio", "ch": "R", "cycle": 50, "id": 3, "data": "0x0", "resp": 0, "last": 1}], rules)))
    s.detected("store outside its checkpoint window", errs(MMIOSB.check(ck(0xC0, 10) + ck(0xC2, 15) + log[3:6], rules[:1])))
    s.detected("B response lost (incomplete write)", errs(MMIOSB.check(log[:5] + ck(0xC2, 40), [{"kind": "structural", "window": [None, None], "complete": True}])))
    return s


def axil_ok():
    return [{"type": "axilch", "ch": "AW", "cycle": 1, "addr": "0x4"}, {"type": "axilch", "ch": "W", "cycle": 1},
            {"type": "axil", "op": "write", "cycle": 3, "addr": "0x4", "wdata": "0x1", "wstrb": 15, "resp": "OKAY"},
            {"type": "axilch", "ch": "AR", "cycle": 4, "addr": "0x14"},
            {"type": "axil", "op": "read", "cycle": 6, "addr": "0x14", "rdata": "0x0", "resp": "DECERR"}]


def suite_axil():
    s = Suite()
    s.eq("known_answer", "one B per write, one R per read, legal codes", [], AXILSB.check(axil_ok()))
    s.eq("boundary", "empty log is consistent", [], AXILSB.check([]))
    s.eq("negative", "non-axil records ignored", [], AXILSB.check(axil_ok() + [{"type": "pin", "name": "x"}]))
    s.not_applicable("reset", "stateless accounting over one log")
    s.detected("orphan B", AXILSB.check(axil_ok() + [{"type": "axilch", "ch": "B_ORPHAN", "cycle": 9, "resp": "OKAY"}]))
    s.detected("missing R for an accepted AR", AXILSB.check(axil_ok() + [{"type": "axilch", "ch": "AR", "cycle": 9, "addr": "0x8"}]))
    s.detected("AW without W at end of run", AXILSB.check(axil_ok() + [{"type": "axilch", "ch": "AW", "cycle": 9, "addr": "0x8"}]))
    s.detected("EXOKAY on AXI4-Lite", AXILSB.check([dict(r, resp="EXOKAY") if r.get("op") == "read" else r for r in axil_ok()]))
    s.detected("duplicate B", AXILSB.check(axil_ok() + [{"type": "axil", "op": "write", "cycle": 7, "addr": "0x4", "wdata": "0x1", "wstrb": 15, "resp": "OKAY"}]))
    return s


def dump(words):
    out = []
    for a in sorted(set(k & ~7 for k in words)):
        lo, hi = words.get(a, 0), words.get(a + 4, 0)
        out.append({"type": "mem", "addr": hex(a), "size": 8, "data": hex(lo | (hi << 32))})
    return out


def suite_sig():
    s = Suite()
    tb = 0x80090000
    w = {0x80080000: 7, 0x80080004: 0x12345678, tb: 1, tb + 16: 7, tb + 20: 0x80000100, tb + 24: 0x90000007, tb + 28: 3}
    m = SIG.mem_bytes(dump(w))
    s.eq("known_answer", "slot decode", 0x12345678, SIG.word(m, 0x80080004))
    s.eq("known_answer", "trap record decode", [{"hart": 0, "level": "M", "mcause": 7, "mepc": 0x80000100, "mtval": 0x90000007}], SIG.traps(m, tb, 0))
    s.eq("known_answer", "slot compare match", [], SIG.check_slot(m, 0x80080000, 7))
    s.eq("boundary", "masked compare", [], SIG.check_slot(m, 0x80080004, 0x12000000, mask=0xFF000000))
    s.eq("boundary", "allowed-set compare", [], SIG.check_slot(m, 0x80080000, allowed=[6, 7]))
    s.eq("negative", "unpublished trap area -> None", None, SIG.traps(m, tb, 1))
    s.not_applicable("reset", "decoder is stateless")
    s.detected("slot value wrong", SIG.check_slot(m, 0x80080000, 8))
    s.detected("slot not published", SIG.check_slot(m, 0x80080100, 0))
    s.detected("value outside allowed set", SIG.check_slot(m, 0x80080000, allowed=[1, 2]))
    import chk_trap_oracle as T
    s.detected("trap cause wrong vs oracle", T.compare([T.expected_trap(0, "exception", 5, 0x80000100, 0x90000007)], SIG.traps(m, tb, 0)))
    s.detected("trap epc wrong vs oracle", T.compare([T.expected_trap(0, "exception", 7, 0x80000104, 0x90000007)], SIG.traps(m, tb, 0)))
    return s


def suite_cov():
    s = Suite()
    vb = [{"bin": "cg_a", "req": "REQ-A", "test": "t1", "status": "planned", "configs": ["P0"]},
          {"bin": "cg_b", "req": "REQ-B", "test": "t1", "status": "planned", "configs": ["P0", "P1"]},
          {"bin": "cg_c", "req": "REQ-C", "test": "t2", "status": "blocked", "configs": ["P0"]}]
    r1 = {"test": "t1", "seed": 1, "checks": [{"req": "REQ-A", "status": "pass"}, {"req": "REQ-B", "status": "pass"}]}
    c = COV.collect(vb, [(r1, "P0")])
    s.eq("known_answer", "two bins hit on P0, catalog of 3 non-blocked (bin,config) pairs, 1 blocked", (2, 3, 1), (c["hit"], c["catalog_size"], c["blocked"]))
    c2 = COV.collect(vb, [(r1, "P0"), (r1, "P1")])
    s.eq("known_answer", "union across configurations", 3, c2["hit"])
    s.eq("boundary", "repeated identical run counted once (set union, R-202)", 2, COV.collect(vb, [(r1, "P0"), (r1, "P0")])["hit"])
    s.eq("negative", "no runs -> zero hits", 0, COV.collect(vb, [])["hit"])
    s.not_applicable("reset", "stateless merge")
    s.detected("failed check credited", [] if COV.collect(vb, [({"test": "t1", "seed": 1, "checks": [{"req": "REQ-A", "status": "fail"}]}, "P0")])["hit"] != 0 else ["rejected: bin not credited"])
    s.detected("run on a configuration outside the row credited", [] if COV.collect(vb, [({"test": "t1", "seed": 1, "checks": [{"req": "REQ-A", "status": "pass"}]}, "P2")])["hit"] != 0 else ["rejected: bin not credited"])
    s.detected("blocked bin credited", [] if COV.collect(vb, [({"test": "t2", "seed": 1, "checks": [{"req": "REQ-C", "status": "pass"}]}, "P0")])["hit"] != 0 else ["rejected: bin not credited"])
    s.detected("other test's pass credited to this bin", [] if COV.collect(vb, [({"test": "t9", "seed": 1, "checks": [{"req": "REQ-A", "status": "pass"}]}, "P0")])["hit"] != 0 else ["rejected: bin not credited"])
    s.detected("not_run check credited", [] if COV.collect(vb, [({"test": "t1", "seed": 1, "checks": [{"req": "REQ-A", "status": "not_run"}]}, "P0")])["hit"] != 0 else ["rejected: bin not credited"])
    # real vplan catalog loads
    s.eq("known_answer", "vplan bin catalog loads (non-empty)", True, len(COV.bins_from_vplan(os.path.join(ROOT, "docs", "00_plan", "vplan.csv"))) > 100)
    return s


def smoke_run(tmp, mutate=None, drop=None):
    """Synthetic logs that satisfy every check of the generated t_rv32d_smoke expectations."""
    exp_p = os.path.join(ROOT, "tests", "generated", "t_rv32d_smoke", "expected.json")
    exp = json.load(open(exp_p))
    shutil.copy(exp_p, os.path.join(tmp, "expected.json"))
    slots = {k: int(v, 0) for k, v in exp["slots"].items()}
    words = {slots["1:peer"]: 0x5A0C0DE5, slots["0:hid"]: 0, slots["1:hid"]: 1, 0x80090000: 0, 0x80090400: 0}
    logs = {"mem_dump.ndjson": dump(words),
            "axi_mem.ndjson": line_read(0x80000000, 5),
            "axi_mmio.ndjson": [],
            "watchdog.ndjson": [{"type": "watchdog", "event": "tohost", "hart": 0, "code": "0x1", "cycle": 900},
                                {"type": "watchdog", "event": "tohost", "hart": 1, "code": "0x1", "cycle": 900}],
            "sva.ndjson": [{"type": "sva", "id": i, "fails": 0, "attempts": 10, "covers": 3} for i in ("a_axi_mem_stable", "a_axi_addr_hi_zero")]}
    if mutate:
        mutate(logs)
    for n, recs in logs.items():
        if n == drop:
            continue
        with open(os.path.join(tmp, n), "w") as f:
            for r in recs:
                f.write(json.dumps(r) + "\n")
    import evaluate_run
    import io
    import contextlib
    with contextlib.redirect_stdout(io.StringIO()):
        rc = evaluate_run.main([tmp])
    return rc, json.load(open(os.path.join(tmp, "results.json")))


def suite_eval():
    s = Suite()
    def run(**kw):
        tmp = tempfile.mkdtemp(prefix="rv32d_q_")
        try:
            return smoke_run(tmp, **kw)
        finally:
            shutil.rmtree(tmp, ignore_errors=True)
    rc, res = run()
    s.eq("known_answer", "consistent synthetic smoke run -> PASS with 6 executed checks", (0, "PASS", 6), (rc, res["verdict"], res["distinct_checks"]))
    s.eq("boundary", "every check status is pass", ["pass"] * 6, [c["status"] for c in res["checks"]])
    rc2, res2 = run(drop="watchdog.ndjson")
    s.eq("negative", "missing log -> check not_run and verdict FAIL (never pass)", ("FAIL", "not_run"),
         (res2["verdict"], [c["status"] for c in res2["checks"] if c["id"] == "CK-SMK-03"][0]))
    s.not_applicable("reset", "each evaluation starts from the run directory only")
    def m_sva(l): l["sva.ndjson"][0]["fails"] = 2
    def m_vac(l): l["sva.ndjson"][1]["covers"] = 0
    def m_slot(l): l["mem_dump.ndjson"] = dump({int(json.load(open(os.path.join(ROOT, "tests", "generated", "t_rv32d_smoke", "expected.json")))["slots"]["1:peer"], 0): 0})
    def m_wd(l): l["watchdog.ndjson"].append({"type": "watchdog", "event": "expired", "tohost_done": 1, "cycle": 999})
    def m_code(l): l["watchdog.ndjson"][1]["code"] = "0xbad0"
    def m_noread(l): l["axi_mem.ndjson"] = []
    for name, m in (("assertion failure", m_sva), ("vacuous assertion (0 covers)", m_vac), ("wrong signature value", m_slot),
                    ("watchdog expired", m_wd), ("hart reported fail code", m_code), ("boot fetch missing", m_noread)):
        rc, res = run(mutate=m)
        s.detected(name, [] if res["verdict"] == "PASS" else ["verdict %s" % res["verdict"]])
    return s


SUITES = {"chk_axi_mem_sb": (suite_axi_mem, ["env/scoreboards/axi_sb_core.py", "env/scoreboards/chk_axi_mem_sb.py"]),
          "chk_axi_mmio_sb": (suite_axi_mmio, ["env/scoreboards/axi_sb_core.py", "env/scoreboards/chk_axi_mmio_sb.py"]),
          "chk_axil_sb": (suite_axil, ["env/scoreboards/chk_axil_sb.py"]),
          "chk_sig": (suite_sig, ["env/scoreboards/chk_sig.py"]),
          "cov_collect": (suite_cov, ["env/coverage/cov_collect.py"]),
          "evaluate_run": (suite_eval, ["scripts/evaluate_run.py"])}
