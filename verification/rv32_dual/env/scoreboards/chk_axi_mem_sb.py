#!/usr/bin/env python3
# AI-GENERATED (Claude Opus 5.5, 2026-11-28) - candidate artifact (R-117, R-231). Review pending.
"""chk_axi_mem_sb - memory-port scoreboard (plan 5.2): REF-001 5.3/10.2 transaction
predictions supplied as rules by the testcase (line writebacks, beat counts, presence/absence),
plus structural AXI4 checks (IHI 0022H A3.4/A5) and REQ-XL-006 address width."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from axi_sb_core import check_rules, read_ndjson  # noqa: E402,F401
PORT = "mem"


def check(records, rules):
    return check_rules(records, PORT, rules)
