#!/usr/bin/env python3
# -----------------------------------------------------------------------------
# AI-GENERATED (Claude Opus 5.5, 2026-11-27) - candidate artifact (R-117, R-231).
# Minimal .xlsx reader (Office Open XML SpreadsheetML: workbook.xml, rels,
# sharedStrings.xml, sheetN.xml) using only zipfile + xml.etree. Used by
# chk_csr_model and chk_pmu_model (shared code: correlated-error note in the
# qualification records). Human review: pending.
# -----------------------------------------------------------------------------
"""Read cell values (strings/numbers as text) from an .xlsx worksheet."""
import re
import zipfile
import xml.etree.ElementTree as ET

NS = {"m": "http://schemas.openxmlformats.org/spreadsheetml/2006/main",
      "r": "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
      "pr": "http://schemas.openxmlformats.org/package/2006/relationships"}


def _col_index(ref):
    letters = re.match(r"([A-Z]+)", ref).group(1)
    n = 0
    for ch in letters:
        n = n * 26 + (ord(ch) - 64)
    return n - 1


def read_sheet(path, sheet_name):
    """Return list of rows; each row is a list of cell strings (None for empty)."""
    with zipfile.ZipFile(path) as z:
        shared = []
        if "xl/sharedStrings.xml" in z.namelist():
            root = ET.fromstring(z.read("xl/sharedStrings.xml"))
            for si in root.findall("m:si", NS):
                shared.append("".join(t.text or "" for t in si.iter("{%s}t" % NS["m"])))
        wb = ET.fromstring(z.read("xl/workbook.xml"))
        rels = ET.fromstring(z.read("xl/_rels/workbook.xml.rels"))
        target = None
        for sh in wb.find("m:sheets", NS):
            if sh.get("name") == sheet_name:
                rid = sh.get("{%s}id" % NS["r"])
                for rel in rels.findall("pr:Relationship", NS):
                    if rel.get("Id") == rid:
                        target = rel.get("Target")
        if target is None:
            raise KeyError("sheet %r not found" % sheet_name)
        target = target.lstrip("/")
        if not target.startswith("xl/"):
            target = "xl/" + target
        root = ET.fromstring(z.read(target))
        rows = []
        for row in root.iter("{%s}row" % NS["m"]):
            cells = {}
            for c in row.findall("m:c", NS):
                t = c.get("t")
                v = c.find("m:v", NS)
                if t == "s" and v is not None:
                    val = shared[int(v.text)]
                elif t == "inlineStr":
                    val = "".join(x.text or "" for x in c.iter("{%s}t" % NS["m"]))
                else:
                    val = v.text if v is not None else None
                cells[_col_index(c.get("r"))] = val
            width = max(cells) + 1 if cells else 0
            rows.append([cells.get(i) for i in range(width)])
        return rows


def sheet_names(path):
    with zipfile.ZipFile(path) as z:
        wb = ET.fromstring(z.read("xl/workbook.xml"))
        return [sh.get("name") for sh in wb.find("m:sheets", NS)]
