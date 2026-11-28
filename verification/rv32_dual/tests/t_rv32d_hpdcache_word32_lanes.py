"""
AI-GENERATED (Claude Opus 5.5, 2026-11-28) testcase source - candidate (R-117, R-231); engineer review pending (R-284).
Authored from the specification baseline only (RV32 HDS rev 0.4, REF-001 rev 0.39, CSR workbook, question_log answers); no RTL used (R-103, R-232).

| Field | Content |
|---|---|
| Test ID and title | t_rv32d_hpdcache_word32_lanes - Proves REQ-XL-012 line content and beat count with a 32-bit HPDcache word |
| Priority and rationale | high; rank 8 of the plan 6.3 risk-ranked list: Highest-risk new RV32 datapath (RV32 HDS 15.1) |
| Purpose | Proves REQ-XL-012 line content and beat count with a 32-bit HPDcache word. |
| Requirements and features | REQ-MEM-001, REQ-MEM-015, REQ-XL-004, REQ-XL-012; features: cbo_maintenance, fp_single, hpdcache_word32, mesi_coherence; functions: hpdcache_word32+cbo_maintenance+mesi_coherence+fp_single |
| DUT configuration and preconditions | CFG-RV32-2-P0; four lines w0-w3 in region 0, initially zero. Plan configuration column: CFG-RV32-2-P0. Campaign region table bound through tb/generated/region_params.svh (REF-001 rev 0.40 14.4.20, Q-G3-01 answered) |
| Software flow | 1 boot; 2 hart 0 writes w0 with 16 byte stores, w1 with 8 half stores, w2 with 4 word stores, w3 with 4 FSW of known binary32 values; 3 flag; hart 1 reads all 16 words of w0-w2 and FLW/fmv.x.w of w3; 4 hart 0 CBO.CLEAN w0-w3 in checkpoint window 0xA1/0xA2; 5 TOHOST |
| Stimulus | Every byte/half/word/FP lane of 16-byte lines through the 32-bit HPDcache word |
| Functional checkpoints and assertions | See the check table below (5 planned checks; R-286 requires >= 5). Every check runs through scripts/evaluate_run.py with the oracle/scoreboard named; deadline = test cycle budget unless stated; failure condition as listed |
| Expected outcome | Peer reads every byte; each CLEAN writes exactly 2 beats with full strobes and the byte-exact line |
| Defect/fault targeted | Lane swap, wrong strobe, lost word in the 4-ways-per-RAM-word layout, wrong beat count; failure modes FM-CBO-01, FM-COH-02, FM-FP-03, FM-W32-01, FM-W32-02, FM-W32-03 |
| Checker/oracle | chk_axi_mem_sb, chk_mem_oracle; qualification records under docs/01_qualification and docs/02_env |
| Reproducibility | SEED and every plusarg in tests/generated/t_rv32d_hpdcache_word32_lanes/plusargs.txt (generated deterministically by scripts/generators/gen_prog.py); replay: build tb_top, run the simulator with +f-style plusargs from that file in a fresh runs/<run_id>/, then python scripts/evaluate_run.py runs/<run_id> |
| Waveform | wave.vcd of the run (TOP ports and checkpoint window, +WAVE=wave.vcd +WAVE_SCOPE=ports); R-283 rank 8 |
| Evidence | Not run: no simulation in this phase (free disk below the approved 2 GiB threshold) |

Planned checks (from verification_plan.md Section 6.1, R-286):

| Check ID | Requirement / clause | Trigger | Expected observation | Checker / assertion | Deadline | Failure condition |
|---|---|---|---|---|---|---|
| CK-W32-01 | REQ-XL-012 | CBO.CLEAN per line | exactly 2 W beats of 64 bits per line | chk_axi_mem_sb | op retire | other count |
| CK-W32-02 | REQ-XL-012 | W beats | byte-exact data vs model for every offset pattern | chk_axi_mem_sb | op retire | byte mismatch |
| CK-W32-03 | REQ-XL-012 | W beats | WSTRB = 0xFF for line writebacks | chk_axi_mem_sb | op retire | partial strobe |
| CK-W32-04 | REQ-MEM-001 | peer read of partially written line | peer reads all bytes written by owner | chk_mem_oracle | test end | byte mismatch |
| CK-W32-05 | REQ-XL-004 | FLW after FSW | bit-exact single value | chk_mem_oracle | test end | mismatch |
"""
TEST = 't_rv32d_hpdcache_word32_lanes'
SEED = 1
KIND = 'cpu'
REQS = {
    'CK-W32-01': 'REQ-XL-012',
    'CK-W32-02': 'REQ-XL-012',
    'CK-W32-03': 'REQ-XL-012',
    'CK-W32-04': 'REQ-MEM-001',
    'CK-W32-05': 'REQ-XL-004',
}

from rv32d_lib import L, SLOT  # noqa: E402


def build(p):
    p.waveform = True
    for n in range(4):
        p.line("w%d" % n, [0, 0, 0, 0])
    p.word("go", 0)
    p.asm(0, "la t0, w0")
    for i in range(16):
        p.asm(0, "li t1, 0x%x" % (0x10 + i), "sb t1, %d(t0)" % i)
    p.asm(0, "la t0, w1")
    for i in range(8):
        p.asm(0, "li t1, 0x%x" % (0x2000 + 0x101 * i), "sh t1, %d(t0)" % (2 * i))
    p.asm(0, "la t0, w2")
    for i in range(4):
        p.asm(0, "li t1, 0x%x" % (0x30303030 + i), "sw t1, %d(t0)" % (4 * i))
    fpv = [0x3F800000, 0xC0490FDB, 0x7F7FFFFF, 0x00000001]
    p.asm(0, "la t0, w3")
    for i, v in enumerate(fpv):
        p.asm(0, "li t1, 0x%x" % v, "fmv.w.x ft0, t1", "fsw ft0, %d(t0)" % (4 * i))
    p.flag_set(0, "go", 1); p.flag_wait(1, "go", 1)
    for n in range(3):
        for i in range(4):
            p.asm(1, "la t0, w%d" % n, "lw t1, %d(t0)" % (4 * i))
            p.store_slot(1, "t1", "w%d_%d" % (n, i))
    for i in range(4):
        p.asm(1, "la t0, w3", "flw ft1, %d(t0)" % (4 * i), "fmv.x.w t1, ft1")
        p.store_slot(1, "t1", "w3_%d" % i)
    p.flag_set(1, "go", 2); p.flag_wait(0, "go", 2)
    p.ckpt(0, 0xA1)
    for n in range(4):
        p.cbo(0, "clean", "w%d" % n)
    p.ckpt(0, 0xA2)
    p.end(0); p.end(1)
    exp_w = {0: bytes(0x10 + i for i in range(16)),
             1: b"".join((0x2000 + 0x101 * i).to_bytes(2, "little") for i in range(8)),
             2: b"".join((0x30303030 + i).to_bytes(4, "little") for i in range(4)),
             3: b"".join(v.to_bytes(4, "little") for v in fpv)}
    p.check("CK-W32-01", REQS["CK-W32-01"], "axi_mem", rules=[{"kind": "write_line", "addr": L("w%d" % n), "window": [0xA1, 0xA2], "beats": 2} for n in range(4)])
    p.check("CK-W32-02", REQS["CK-W32-02"], "axi_mem", rules=[{"kind": "write_line", "addr": L("w%d" % n), "window": [0xA1, 0xA2], "data": exp_w[n].hex()} for n in range(4)])
    p.check("CK-W32-03", REQS["CK-W32-03"], "axi_mem", rules=[{"kind": "write_line", "addr": L("w%d" % n), "window": [0xA1, 0xA2], "strobe_full": True} for n in range(4)])
    p.check("CK-W32-04", REQS["CK-W32-04"], "slot", addr=SLOT(p, 1, "w0_1"), expect=int.from_bytes(exp_w[0][4:8], "little"))
    p.check("CK-W32-04b", REQS["CK-W32-04"], "slot", addr=SLOT(p, 1, "w1_3"), expect=int.from_bytes(exp_w[1][12:16], "little"))
    p.check("CK-W32-05", REQS["CK-W32-05"], "slot", addr=SLOT(p, 1, "w3_1"), expect=0xC0490FDB)
    p.check("CK-W32-05b", REQS["CK-W32-05"], "slot", addr=SLOT(p, 1, "w3_3"), expect=0x00000001)
