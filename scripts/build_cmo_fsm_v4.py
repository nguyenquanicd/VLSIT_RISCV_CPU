"""Build the editable FSM-011 CBO/CMO page from the VLSIT draw.io library.

Usage:
    python scripts/build_cmo_fsm_v4.py [--skill-root PATH]

Inputs:
    The existing FSM V3 multi-page draw.io source and the immutable VLSIT
    draw.io symbol library installed with vlsit-rtl-hierarchy-diagram.

Outputs:
    project_support/specification/figures/fsm/VLSIT_RISCV_CLUSTER_FSM_V4.drawio
    The script preserves all V3 pages and appends the FSM-011 review draft.

Exit codes:
    0 on success; 1 when an input, template, or output operation fails.
"""

from __future__ import annotations

import argparse
import copy
import hashlib
import json
import sys
import xml.etree.ElementTree as ET
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
FSM_DIR = PROJECT_ROOT / 'doc/specification/figures/fsm'
SOURCE_V3 = FSM_DIR / "VLSIT_RISCV_CLUSTER_FSM_V3.drawio"
OUTPUT_V4 = FSM_DIR / "VLSIT_RISCV_CLUSTER_FSM_V4.drawio"
DEFAULT_SKILL_ROOT = Path(r"C:\Users\PC\.codex\skills\vlsit-rtl-hierarchy-diagram")
LIBRARY_RELATIVE = Path("assets") / "VLSIT_DRAWIO_LIB_V1.drawio.xml"
EXPECTED_LIBRARY_SHA256 = "D1631ACF98A920526B235E8970FEDDC9305EA2F0D6A35C6529CD220D62AFABB6"
FSM_ID = "FSM011"


def fail(message: str) -> None:
    print(f"ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


def load_library(path: Path) -> tuple[list[dict[str, object]], str]:
    if not path.is_file():
        fail(f"VLSIT symbol library not found: {path}")
    raw = path.read_bytes()
    digest = hashlib.sha256(raw).hexdigest().upper()
    if digest != EXPECTED_LIBRARY_SHA256:
        fail(f"VLSIT symbol library hash mismatch: {digest}")
    root = ET.fromstring(raw)
    if root.tag != "mxlibrary":
        fail("The symbol library root is not <mxlibrary>.")
    try:
        templates = json.loads(root.text or "")
    except json.JSONDecodeError as exc:
        fail(f"Could not parse VLSIT library JSON: {exc}")
    if len(templates) != 39:
        fail(f"Expected 39 library templates, found {len(templates)}.")
    return templates, digest


def clone_cell(
    templates: list[dict[str, object]], entry: int, instance: str, label: str,
    cell_id: str, x: int, y: int, width: int, height: int, library_hash: str,
) -> ET.Element:
    model = ET.fromstring(str(templates[entry]["xml"]))
    cells = [cell for cell in model.findall("./root/mxCell") if cell.get("id") not in {"0", "1"}]
    if len(cells) != 1:
        fail(f"Template {entry} is not a single-cell shape/connector template.")
    cell = copy.deepcopy(cells[0])
    source_cell_id = cell.get("id", "")
    cell.set("id", cell_id)
    cell.set("value", label)
    cell.set("parent", "1")
    cell.set("vlsit_library_sha256", library_hash)
    cell.set("vlsit_library_entry", str(entry))
    cell.set("vlsit_library_cell", source_cell_id)
    cell.set("vlsit_library_instance", instance)
    style = cell.get("style", "") + "fontSize=18;fontColor=#000000;"
    if entry == 0:
        style += "strokeColor=none;fillColor=none;"
    elif entry in {13, 33, 34}:
        style += "strokeColor=#000000;fillColor=#FFFFFF;"
    elif entry == 1:
        style += "strokeColor=#000000;fillColor=#FFFFFF;"
    cell.set("style", style)
    geometry = cell.find("mxGeometry")
    if geometry is None:
        fail(f"Template {entry} has no geometry.")
    if entry == 1:
        geometry.set("relative", "1")
        geometry.set("width", "50")
        geometry.set("height", "50")
    else:
        geometry.attrib.pop("relative", None)
        geometry.set("x", str(x))
        geometry.set("y", str(y))
        geometry.set("width", str(width))
        geometry.set("height", str(height))
    return cell


def add_node(root: ET.Element, templates: list[dict[str, object]], library_hash: str,
             node: dict[str, object]) -> None:
    cell = clone_cell(
        templates, int(node["entry"]), f"{FSM_ID}_{node['name']}",
        str(node["label"]), f"{FSM_ID}_{node['name']}",
        int(node["x"]), int(node["y"]), int(node["w"]), int(node["h"]), library_hash,
    )
    root.append(cell)


def add_edge(root: ET.Element, templates: list[dict[str, object]], library_hash: str,
             edge: dict[str, object], nodes: dict[str, dict[str, object]]) -> None:
    cell = clone_cell(
        templates, 1, f"{FSM_ID}_{edge['name']}", str(edge["label"]),
        f"{FSM_ID}_{edge['name']}", 0, 0, 50, 50, library_hash,
    )
    cell.set("source", f"{FSM_ID}_{edge['source']}")
    cell.set("target", f"{FSM_ID}_{edge['target']}")
    style = cell.get("style", "")
    style += (
        f"fontColor=#000000;strokeColor=#000000;fillColor=#FFFFFF;"
        f"exitX={edge['exit_x']};exitY={edge['exit_y']};exitPerimeter=0;"
        f"entryX={edge['entry_x']};entryY={edge['entry_y']};entryPerimeter=0;"
    )
    cell.set("style", style)
    geometry = cell.find("mxGeometry")
    if geometry is None:
        fail(f"Edge template lacks geometry for {edge['name']}.")
    geometry.clear()
    geometry.set("width", "50")
    geometry.set("height", "50")
    geometry.set("relative", "1")
    geometry.set("as", "geometry")
    source = nodes[str(edge["source"])]
    target = nodes[str(edge["target"])]
    sx, sy, sw, sh = int(source["x"]), int(source["y"]), int(source["w"]), int(source["h"])
    tx, ty, tw, th = int(target["x"]), int(target["y"]), int(target["w"]), int(target["h"])
    source_point = (round(sx + float(edge["exit_x"]) * sw), round(sy + float(edge["exit_y"]) * sh))
    target_point = (round(tx + float(edge["entry_x"]) * tw), round(ty + float(edge["entry_y"]) * th))
    ET.SubElement(geometry, "mxPoint", {"x": str(source_point[0]), "y": str(source_point[1]), "as": "sourcePoint"})
    ET.SubElement(geometry, "mxPoint", {"x": str(target_point[0]), "y": str(target_point[1]), "as": "targetPoint"})
    points = ET.SubElement(geometry, "Array", {"as": "points"})
    for x, y in edge["points"]:  # type: ignore[union-attr]
        ET.SubElement(points, "mxPoint", {"x": str(x), "y": str(y)})
    root.append(cell)


def build_page(templates: list[dict[str, object]], library_hash: str) -> ET.Element:
    page = ET.Element("diagram", {"id": FSM_ID, "name": "FSM-011_CBO_CMO_V1"})
    model = ET.SubElement(page, "mxGraphModel", {
        "dx": "1790", "dy": "1600", "grid": "1", "gridSize": "10",
        "guides": "1", "tooltips": "1", "connect": "1", "arrows": "1",
        "fold": "1", "page": "1", "pageScale": "1",
        "pageWidth": "1800", "pageHeight": "1700", "math": "0", "shadow": "0",
    })
    root = ET.SubElement(model, "root")
    ET.SubElement(root, "mxCell", {"id": "0"})
    ET.SubElement(root, "mxCell", {"id": "1", "parent": "0"})

    nodes = [
        {"name": "title", "entry": 0, "label": "<b>FSM-011 — System-wide CBO maintenance and precise fault</b>", "x": 100, "y": 10, "w": 1600, "h": 45},
        {"name": "start", "entry": 33, "label": "<b>RESET RELEASED</b><br>Reset đã nhả", "x": 770, "y": 70, "w": 260, "h": 65},
        {"name": "idle", "entry": 13, "label": "<b>ST_IDLE</b><br>Wait for legal CBO<br>Chờ CBO hợp lệ", "x": 760, "y": 170, "w": 280, "h": 95},
        {"name": "older", "entry": 13, "label": "<b>ST_WAIT_OLDER</b><br>Drain older stores; latch op, paddr, PC, vaddr<br>Chờ store cũ; giữ ngữ cảnh CBO", "x": 700, "y": 315, "w": 400, "h": 115},
        {"name": "prepare", "entry": 13, "label": "<b>ST_PREPARE</b><br>Allocate shared CCU context; lock line<br>Target directory-recorded L1 holders", "x": 700, "y": 480, "w": 400, "h": 120},
        {"name": "wait_prepare", "entry": 13, "label": "<b>ST_WAIT_PREPARE</b><br>Collect tagged PREPARE status<br>CLEAN/FLUSH/INVAL-as-FLUSH: M owner writes back through AXI; retain M<br>True INVAL: keep dirty M; skip writeback", "x": 700, "y": 650, "w": 400, "h": 160},
        {"name": "prep_ok", "entry": 34, "label": "<b>All PREPARE statuses OK?</b><br>Mọi PREPARE thành công?", "x": 790, "y": 830, "w": 220, "h": 120},
        {"name": "llc", "entry": 13, "label": "<b>ST_LLC_CMO</b><br>Per-line lookup; no refill<br>CLEAN/FLUSH: write dirty line to memory<br>True INVAL: invalidate without writeback<br>INVAL-as-FLUSH follows FLUSH", "x": 1280, "y": 700, "w": 400, "h": 160},
        {"name": "llc_ok", "entry": 34, "label": "<b>CMO complete without writeback error?</b><br>CMO xong, không lỗi writeback?", "x": 1360, "y": 930, "w": 240, "h": 120},
        {"name": "commit", "entry": 13, "label": "<b>ST_COMMIT</b><br>CLEAN: sole M→E; retain copies<br>FLUSH/true INVAL: invalidate L1 and LLC<br>Commit directory after required ACKs", "x": 700, "y": 1120, "w": 400, "h": 150},
        {"name": "wait_commit", "entry": 13, "label": "<b>ST_WAIT_COMMIT_ACK</b><br>Keep line lock/context until all ACKs<br>No timeout; reset is recovery", "x": 700, "y": 1325, "w": 400, "h": 105},
        {"name": "success", "entry": 33, "label": "<b>CMO SUCCESS</b><br>Allow CBO retirement once", "x": 790, "y": 1480, "w": 220, "h": 75},
        {"name": "abort", "entry": 13, "label": "<b>ST_ABORT</b><br>Send ABORT to prepared holders<br>Preserve stable MESI/directory and dirty data", "x": 100, "y": 865, "w": 410, "h": 130},
        {"name": "wait_abort", "entry": 13, "label": "<b>ST_WAIT_ABORT_ACK</b><br>Wait for every ABORT ACK<br>No timeout; retain context/line lock", "x": 100, "y": 1065, "w": 410, "h": 110},
        {"name": "fault", "entry": 33, "label": "<b>PRECISE CBO FAULT</b><br>Writeback-required operations only<br>Store/AMO access fault before retirement<br>Use original PC and effective address", "x": 120, "y": 1245, "w": 370, "h": 125},
    ]
    for node in nodes:
        add_node(root, templates, library_hash, node)
    node_map = {str(node["name"]): node for node in nodes}

    edges = [
        {"name": "e_reset", "source": "start", "target": "idle", "label": "reset / reset", "exit_x": "0.5", "exit_y": "1", "entry_x": "0.5", "entry_y": "0", "points": [(900, 150)]},
        {"name": "e_accept", "source": "idle", "target": "older", "label": "legal CBO at retirement head / CBO hợp lệ", "exit_x": "0.5", "exit_y": "1", "entry_x": "0.5", "entry_y": "0", "points": [(900, 290)]},
        {"name": "e_drain", "source": "older", "target": "prepare", "label": "older stores drained / store cũ đã xong", "exit_x": "0.5", "exit_y": "1", "entry_x": "0.5", "entry_y": "0", "points": [(900, 455)]},
        {"name": "e_lock", "source": "prepare", "target": "wait_prepare", "label": "line locked; PREPARE sent / đã khóa line", "exit_x": "0.5", "exit_y": "1", "entry_x": "0.5", "entry_y": "0", "points": [(900, 625)]},
        {"name": "e_prepared", "source": "wait_prepare", "target": "prep_ok", "label": "all targeted responses collected / đủ response", "exit_x": "0.5", "exit_y": "1", "entry_x": "0.5", "entry_y": "0", "points": [(900, 805)]},
        {"name": "e_prep_yes", "source": "prep_ok", "target": "llc", "label": "YES / CÓ", "exit_x": "1", "exit_y": "0.5", "entry_x": "0", "entry_y": "0.5", "points": [(1130, 890), (1130, 780), (1190, 780)]},
        {"name": "e_prep_no", "source": "prep_ok", "target": "abort", "label": "NO: owner/PREPARE error / lỗi", "exit_x": "0", "exit_y": "0.5", "entry_x": "1", "entry_y": "0.25", "points": [(650, 890), (650, 898), (570, 898)]},
        {"name": "e_llc_rsp", "source": "llc", "target": "llc_ok", "label": "maintenance response / response bảo trì", "exit_x": "0.5", "exit_y": "1", "entry_x": "0.5", "entry_y": "0", "points": [(1480, 895)]},
        {"name": "e_llc_yes", "source": "llc_ok", "target": "commit", "label": "YES / CÓ", "exit_x": "0", "exit_y": "0.5", "entry_x": "1", "entry_y": "0.5", "points": [(1260, 990), (1200, 990), (1200, 1195), (1100, 1195)]},
        {"name": "e_llc_no", "source": "llc_ok", "target": "abort", "label": "NO: preserve LLC dirty line / lỗi, giữ dirty", "exit_x": "1", "exit_y": "0.5", "entry_x": "1", "entry_y": "0.75", "points": [(1660, 990), (1660, 1080), (560, 1080), (560, 962)]},
        {"name": "e_commit_wait", "source": "commit", "target": "wait_commit", "label": "COMMIT issued / đã gửi COMMIT", "exit_x": "0.5", "exit_y": "1", "entry_x": "0.5", "entry_y": "0", "points": [(900, 1300)]},
        {"name": "e_commit_done", "source": "wait_commit", "target": "success", "label": "all commit ACKs; release line/context / đủ ACK", "exit_x": "0.5", "exit_y": "1", "entry_x": "0.5", "entry_y": "0", "points": [(900, 1460)]},
        {"name": "e_abort_wait", "source": "abort", "target": "wait_abort", "label": "ABORT issued / đã gửi ABORT", "exit_x": "0.5", "exit_y": "1", "entry_x": "0.5", "entry_y": "0", "points": [(305, 1030)]},
        {"name": "e_abort_done", "source": "wait_abort", "target": "fault", "label": "all abort ACKs; return error / đủ ACK, trả lỗi", "exit_x": "0.5", "exit_y": "1", "entry_x": "0.5", "entry_y": "0", "points": [(305, 1210)]},
    ]
    for edge in edges:
        add_edge(root, templates, library_hash, edge, node_map)

    note = add_note(root, templates, library_hash)
    root.append(note)
    return page


def add_note(root: ET.Element, templates: list[dict[str, object]], library_hash: str) -> ET.Element:
    cell = clone_cell(
        templates, 0, f"{FSM_ID}_notes",
        "True CBIE-decoded INVAL locks holders and invalidates at COMMIT without owner or LLC writeback; dirty copies may be discarded. CLEAN/FLUSH and INVAL-as-FLUSH perform required writebacks. Only their writeback errors reach the precise CBO fault path. Missing PREPARE/COMMIT/ABORT ACKs wait without timeout; reset is the only recovery. CBO is not retired until success; on error, no younger instruction retires. FENCE.I has a separate D-cache-to-LLC scan followed by local I-cache/fetch invalidation; it does not wait for LLC-to-DRAM writeback. On L1-to-LLC B error, preserve M/directory state, ABORT and wait for all ACKs, then raise precise synchronous custom exception cause 24 at the FENCE.I PC with the aligned physical line base in mtval/stval; suppress retirement and local fetch invalidation on error. This contract is outside the CMO FSM.<br>FENCE.I có luồng riêng: quét D-cache, chuyển line dirty lên LLC rồi invalidate I-cache/fetch cục bộ; không đợi writeback LLC-ra-DRAM. Nếu B L1-to-LLC lỗi, giữ M/directory state, gửi ABORT chờ đủ ACK, sau đó phát exception đồng bộ chính xác cause 24 tại PC FENCE.I với physical line base đã căn chỉnh trong mtval/stval; không retire và không invalidate fetch cục bộ khi lỗi. Hợp đồng này nằm ngoài FSM CMO.",
        f"{FSM_ID}_notes", 80, 1580, 1640, 80, library_hash,
    )
    return cell


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--skill-root", type=Path, default=DEFAULT_SKILL_ROOT)
    args = parser.parse_args()
    if not SOURCE_V3.is_file():
        fail(f"FSM V3 source not found: {SOURCE_V3}")
    library_path = args.skill_root / LIBRARY_RELATIVE
    templates, library_hash = load_library(library_path)
    document = ET.parse(SOURCE_V3).getroot()
    if any(page.get("id") == FSM_ID for page in document.findall("diagram")):
        fail("FSM V3 source unexpectedly already contains FSM-011.")
    document.append(build_page(templates, library_hash))
    ET.indent(document, space="  ")
    OUTPUT_V4.write_bytes(ET.tostring(document, encoding="utf-8", xml_declaration=True))
    print(f"Wrote {OUTPUT_V4}")
    print(f"Appended FSM-011 CBO/CMO review draft; V3 pages preserved; library SHA-256 {library_hash}.")


if __name__ == "__main__":
    main()
