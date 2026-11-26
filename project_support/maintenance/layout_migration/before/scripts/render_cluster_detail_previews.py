"""Render the topology portion of the cluster detail draw.io pages as SVG.

Usage: python scripts/render_cluster_detail_previews.py
Input: doc/specification/figures/detail_level2/VLSIT_RISCV_CLUSTER_DETAIL_LEVEL2.drawio
Output: one SVG preview per detail page beside the source diagram.
The editable draw.io file remains the source for the function/interface tables.
Standard library only; no network access.
"""
from pathlib import Path
import html
import re
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "doc" / "specification" / "figures" / "detail_level2"
SOURCE = OUT / "VLSIT_RISCV_CLUSTER_DETAIL_LEVEL2.drawio"


def plain(value):
    value = re.sub(r"<br\s*/?>", "\n", value or "", flags=re.I)
    return html.unescape(re.sub(r"<[^>]*>", "", value))


def bounds(cell):
    geo = cell.find("mxGeometry")
    if geo is None or geo.get("width") is None:
        return None
    x, y, w, h = (float(geo.get(k, 0)) for k in ("x", "y", "width", "height"))
    return x, y, x + w, y + h


def edge_points(cell):
    geo = cell.find("mxGeometry")
    if geo is None:
        return []
    points = []
    for role in ("sourcePoint", None, "targetPoint"):
        if role is None:
            points.extend((float(p.get("x", 0)), float(p.get("y", 0)))
                          for p in geo.findall("./Array/mxPoint"))
        else:
            p = geo.find(f"mxPoint[@as='{role}']")
            if p is not None:
                points.append((float(p.get("x", 0)), float(p.get("y", 0))))
    return points


def render_page(diagram):
    name = diagram.get("name", "detail")
    model = diagram.find("mxGraphModel")
    cells = [c for c in model.findall("./root/mxCell") if c.get("parent") == "1"
             and not c.get("vlsit_native_table")]
    frames = [c for c in cells if c.get("vlsit_library_entry") == "32"
              and not plain(c.get("value", "")).strip()]
    if not frames:
        raise ValueError(f"Missing library frame on {name}")
    frame = bounds(frames[0])
    fx0, fy0, fx1, fy1 = frame
    pad = 170
    clip = (fx0 - pad, fy0 - pad, fx1 + pad, fy1 + pad)
    visible, extents, edges = [], [], []
    for cell in cells:
        if cell.get("edge") == "1":
            pts = edge_points(cell)
            if pts and any(clip[0] <= x <= clip[2] and clip[1] <= y <= clip[3] for x, y in pts):
                edges.append((cell, pts))
                extents.extend((x, y, x, y) for x, y in pts)
            continue
        rect = bounds(cell)
        if rect is None:
            continue
        x0, y0, x1, y1 = rect
        if x1 < clip[0] or x0 > clip[2] or y1 < clip[1] or y0 > clip[3]:
            continue
        visible.append((cell, rect))
        extents.append(rect)
    if not extents:
        raise ValueError(f"No visible diagram cells on {name}")
    x0 = min(r[0] for r in extents) - 24
    y0 = min(r[1] for r in extents) - 24
    x1 = max(r[2] for r in extents) + 24
    y1 = max(r[3] for r in extents) + 24
    width, height = x1 - x0, y1 - y0
    svg = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{width:g}" height="{height:g}" viewBox="{x0:g} {y0:g} {width:g} {height:g}">',
           '<rect x="0" y="0" width="100%" height="100%" fill="white"/>',
           '<defs><marker id="arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0,0 L10,5 L0,10 Z" fill="#20252b"/></marker></defs>']
    for cell, pts in edges:
        path = "M " + " L ".join(f"{x:g} {y:g}" for x, y in pts)
        svg.append(f'<path d="{path}" fill="none" stroke="#20252b" stroke-width="2" marker-end="url(#arrow)"/>')
    for cell, (x0c, y0c, x1c, y1c) in visible:
        entry = cell.get("vlsit_library_entry", "")
        value = plain(cell.get("value", ""))
        if not value:
            stroke = "#263746" if entry == "32" else "#48535c"
            dash = ' stroke-dasharray="8 5"' if "dashed=1" in cell.get("style", "") else ""
            svg.append(f'<rect x="{x0c:g}" y="{y0c:g}" width="{x1c-x0c:g}" height="{y1c-y0c:g}" fill="#f8fafc" stroke="{stroke}" stroke-width="2"{dash}/>')
            continue
        lines = value.split("\n")
        line_h = 20 if entry == "32" else 18
        font = 14 if entry == "32" else 13
        y = (y0c + y1c) / 2 - (len(lines) - 1) * line_h / 2 + font * 0.35
        svg.append(f'<text x="{(x0c+x1c)/2:g}" y="{y:g}" text-anchor="middle" font-family="Arial,Helvetica,sans-serif" font-size="{font}" fill="#16212a">')
        for idx, line in enumerate(lines):
            dy = 0 if idx == 0 else line_h
            svg.append(f'<tspan x="{(x0c+x1c)/2:g}" dy="{dy:g}">{html.escape(line)}</tspan>')
        svg.append("</text>")
    svg.append("</svg>")
    target = OUT / f"{name.lower()}_preview.svg"
    target.write_text("\n".join(svg), encoding="utf-8")
    return target


def main():
    if not SOURCE.is_file():
        raise FileNotFoundError(SOURCE)
    root = ET.parse(SOURCE).getroot()
    outputs = [render_page(page) for page in root.findall("diagram")]
    for path in outputs:
        print(path)


if __name__ == "__main__":
    main()
