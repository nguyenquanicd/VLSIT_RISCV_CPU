"""
AI-GENERATED (Claude Opus 5.5, 2026-11-28) testcase source - candidate (R-117, R-231); engineer review pending (R-284).
Authored from the specification baseline only (RV32 HDS rev 0.4, REF-001 rev 0.39, CSR workbook, question_log answers); no RTL used (R-103, R-232).

| Field | Content |
|---|---|
| Test ID and title | t_rv32d_cbo_matrix - Proves the REQ-MEM-015/016 operation table on all reachable state combinations, with memory observed as the DMA-visible point |
| Priority and rationale | high; rank 7 of the plan 6.3 risk-ranked list: Full CMO state table |
| Purpose | Proves the REQ-MEM-015/016 operation table on all reachable state combinations, with memory observed as the DMA-visible point. |
| Requirements and features | REQ-MEM-005, REQ-MEM-015, REQ-MEM-016, REQ-PMU-007, REQ-XL-012; features: cbo_maintenance, hpdcache_word32, mesi_coherence, pmu_counting; functions: cbo_maintenance+mesi_coherence+hpdcache_word32+pmu_counting |
| DUT configuration and preconditions | CFG-RV32-2-P0; nine lines {c,f,i} x {M,S,I} in region 0 with known image data. Plan configuration column: CFG-RV32-2-P0. Campaign region table bound through tb/generated/region_params.svh (REF-001 rev 0.40 14.4.20, Q-G3-01 answered) |
| Software flow | 1 boot; 2 set-up: hart 0 dirties the *_M lines (M), both harts read the *_S lines (S, LLC clean), *_I lines are never touched (LLC miss); 3 hart 0 runs CBO.CLEAN on c_*, CBO.FLUSH on f_*, CBO.INVAL on i_*, each in its own checkpoint window; 4 hart 1 then reads c_M (peer read after CLEAN), f_S (after FLUSH) and i_M (after true INVAL) in checkpoint window 0x9A/0x9B; 5 TOHOST |
| Stimulus | All three CMO operations on L1 M/S/I states with LLC dirty/clean/miss |
| Functional checkpoints and assertions | See the check table below (6 planned checks; R-286 requires >= 5). Every check runs through scripts/evaluate_run.py with the oracle/scoreboard named; deadline = test cycle budget unless stated; failure condition as listed |
| Expected outcome | CLEAN/FLUSH of M lines write the stored data (2 beats); no external read for CMO misses; FLUSH of an S line forces a later external read; INVAL of a dirty line writes nothing and a later read returns the memory data; CLEAN of a clean line writes nothing; the peer reads the cleaned line without an external read |
| Defect/fault targeted | Missing holder, CMO refill on an LLC miss, invalidation before writeback, INVAL writing back, wrong post-CMO state; failure modes FM-CBO-01, FM-CBO-02, FM-CBO-03, FM-CBO-04, FM-COH-03, FM-PMU-02, FM-W32-01 |
| Checker/oracle | chk_axi_mem_sb, chk_mem_oracle; qualification records under docs/01_qualification and docs/02_env |
| Reproducibility | SEED and every plusarg in tests/generated/t_rv32d_cbo_matrix/plusargs.txt (generated deterministically by scripts/generators/gen_prog.py); replay: build tb_top, run the simulator with +f-style plusargs from that file in a fresh runs/<run_id>/, then python scripts/evaluate_run.py runs/<run_id> |
| Waveform | wave.vcd of the run (TOP ports and checkpoint window, +WAVE=wave.vcd +WAVE_SCOPE=ports); R-283 rank 7 |
| Evidence | Not run: no simulation in this phase (free disk below the approved 2 GiB threshold) |

Planned checks (from verification_plan.md Section 6.1, R-286):

| Check ID | Requirement / clause | Trigger | Expected observation | Checker / assertion | Deadline | Failure condition |
|---|---|---|---|---|---|---|
| CK-CBM-01 | REQ-MEM-015 | CLEAN/FLUSH of a dirty line | external memory holds the latest data (2 beats) | chk_axi_mem_sb | op retire | stale memory |
| CK-CBM-02 | REQ-MEM-015 | CMO on an LLC miss | no external AR (no refill) | chk_axi_mem_sb | op retire | AR observed |
| CK-CBM-03 | REQ-MEM-015 | load after FLUSH | external AR for the line (invalidated in LLC) | chk_axi_mem_sb | next access | no AR |
| CK-CBM-04 | REQ-MEM-015 | true INVAL of dirty line | no AW; later load returns memory (pre-store) data | chk_axi_mem_sb; chk_mem_oracle | next access | AW or new data |
| CK-CBM-05 | REQ-MEM-016 | CLEAN of a clean/missing LLC line | no AW (no-op) | chk_axi_mem_sb | op retire | AW observed |
| CK-CBM-06 | REQ-MEM-005 | CLEAN with peer S copy | peer still reads the value without external AR | chk_mem_oracle; chk_axi_mem_sb | test end | peer copy lost |
"""
TEST = 't_rv32d_cbo_matrix'
SEED = 1
KIND = 'cpu'
REQS = {
    'CK-CBM-01': 'REQ-MEM-015',
    'CK-CBM-02': 'REQ-MEM-015',
    'CK-CBM-03': 'REQ-MEM-015',
    'CK-CBM-04': 'REQ-MEM-015',
    'CK-CBM-05': 'REQ-MEM-016',
    'CK-CBM-06': 'REQ-MEM-005',
}

from rv32d_lib import L, SLOT  # noqa: E402


def build(p):
    p.waveform = True
    names = ["c_M", "c_S", "c_I", "f_M", "f_S", "f_I", "i_M", "i_S", "i_I"]
    for n, nm in enumerate(names):
        p.line(nm, [0xA0000000 + 0x10 * n + j for j in range(4)])
    for nm in ("c_M", "f_M", "i_M"):
        p.asm(0, "la t0, %s" % nm, "li t1, 0x%x" % (0xD0000000 | names.index(nm)), "sw t1, 0(t0)")
    for nm in ("c_S", "f_S", "i_S"):
        p.both("la t0, %s" % nm, "lw t1, 0(t0)")
    p.word("go", 0)
    p.flag_set(1, "go", 1); p.flag_wait(0, "go", 1)
    ck = 0x90
    for op, pre in (("clean", "c"), ("flush", "f"), ("inval", "i")):
        p.ckpt(0, ck)
        for st in ("M", "S", "I"):
            p.cbo(0, op, "%s_%s" % (pre, st))
        p.ckpt(0, ck + 1)
        ck += 2
    p.flag_set(0, "go", 2); p.flag_wait(1, "go", 2)
    p.ckpt(1, 0x9A)
    p.asm(1, "la t0, c_M", "lw t1, 0(t0)", "la t0, f_S", "lw t2, 0(t0)", "la t0, i_M", "lw t3, 0(t0)")
    p.ckpt(1, 0x9B)
    p.store_slot(1, "t1", "cM"); p.store_slot(1, "t3", "iM")
    p.end(0); p.end(1)
    vM = lambda nm: 0xD0000000 | names.index(nm)
    def line_hex(nm, w0):
        n = names.index(nm)
        ws = [w0] + [0xA0000000 + 0x10 * n + j for j in range(1, 4)]
        return "".join("%08x" % int.from_bytes(w.to_bytes(4, "little"), "big") for w in ws)
    p.check("CK-CBM-01", REQS["CK-CBM-01"], "axi_mem", rules=[
        {"kind": "write_line", "addr": L("c_M"), "window": [0x90, 0x91], "beats": 2, "data": line_hex("c_M", vM("c_M"))},
        {"kind": "write_line", "addr": L("f_M"), "window": [0x92, 0x93], "beats": 2, "data": line_hex("f_M", vM("f_M"))}])
    p.check("CK-CBM-02", REQS["CK-CBM-02"], "axi_mem", rules=[
        {"kind": "no_read", "lo": L("c_I"), "hi": L("c_I", 15), "window": [0x90, 0x91]},
        {"kind": "no_read", "lo": L("f_I"), "hi": L("f_I", 15), "window": [0x92, 0x93]},
        {"kind": "no_read", "lo": L("i_I"), "hi": L("i_I", 15), "window": [0x94, 0x95]}])
    p.check("CK-CBM-03", REQS["CK-CBM-03"], "axi_mem", rules=[{"kind": "read_present", "lo": L("f_S"), "hi": L("f_S", 15), "window": [0x9A, 0x9B]}])
    p.check("CK-CBM-04", REQS["CK-CBM-04"], "axi_mem", rules=[{"kind": "no_write", "lo": L("i_M"), "hi": L("i_M", 15), "window": [0x94, 0x95]}])
    p.check("CK-CBM-04b", REQS["CK-CBM-04"], "slot", addr=SLOT(p, 1, "iM"), expect=0xA0000060)
    p.check("CK-CBM-05", REQS["CK-CBM-05"], "axi_mem", rules=[{"kind": "no_write", "lo": L("c_S"), "hi": L("c_S", 15), "window": [0x90, 0x91]}])
    p.check("CK-CBM-06", REQS["CK-CBM-06"], "slot", addr=SLOT(p, 1, "cM"), expect=vM("c_M"))
    p.check("CK-CBM-06b", REQS["CK-CBM-06"], "axi_mem", rules=[{"kind": "no_read", "lo": L("c_M"), "hi": L("c_M", 15), "window": [0x9A, 0x9B]}])
