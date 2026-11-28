#!/usr/bin/env python3
# AI-GENERATED (Claude Opus 5.5, 2026-11-28) - candidate artifact (R-117, R-231). Review pending.
"""chk_axi_mmio_sb - MMIO-port scoreboard (plan 5.2; REQ-IF-002, REQ-ERR-001):
same rule engine as the memory port on port 'mmio'."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from axi_sb_core import check_rules, read_ndjson  # noqa: E402,F401
PORT = "mmio"


def check(records, rules):
    return check_rules(records, PORT, rules)
