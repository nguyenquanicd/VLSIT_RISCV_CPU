#!/usr/bin/env python3
"""Compute source-level line/expression/toggle union coverage from native Verilator data."""
import argparse
import json
import re
from collections import defaultdict
from pathlib import Path

FIELD = {
    name: re.compile(r"\x01" + name + r"\x02([^\x01]+)")
    for name in ("f", "l", "n", "t", "page", "o", "S")
}
COUNT = re.compile(r"'\s+(\d+)\s*$")


def percent(hit: int, total: int):
    return round(100.0 * hit / total, 4) if total else None


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--scope", type=Path, required=True)
    p.add_argument("--merged", type=Path, required=True)
    p.add_argument("--json", type=Path, required=True)
    p.add_argument("--markdown", type=Path, required=True)
    args = p.parse_args()
    scope = json.loads(args.scope.read_text(encoding="utf-8"))
    scoped = {item["path"]: item["class"] for item in scope["sources"]
              if item.get("coverage_threshold_scope") is True}
    keys = {kind: defaultdict(set) for kind in ("line", "expr", "toggle")}
    hit_keys = {kind: defaultdict(set) for kind in keys}
    point_refs = {kind: defaultdict(list) for kind in keys}
    seen_instrumented = set()
    prefix = "/dut/source/"
    with args.merged.open("r", encoding="utf-8", errors="replace") as stream:
        for line in stream:
            if not line.startswith("C "):
                continue
            values = {name: match.group(1) for name, regex in FIELD.items()
                      if (match := regex.search(line))}
            typ = values.get("t")
            if typ not in keys or "f" not in values or "l" not in values:
                continue
            raw_path = values["f"].replace("\\", "/")
            lower = raw_path.lower()
            position = lower.rfind(prefix)
            if position < 0:
                continue
            relative = raw_path[position + len(prefix):]
            if relative not in scoped:
                continue
            count_match = COUNT.search(line)
            if not count_match:
                continue
            count = int(count_match.group(1))
            seen_instrumented.add(relative)
            line_no = values.get("l", "").split("-", 1)[0]
            col = values.get("n", "")
            option = values.get("o", "")
            if typ == "line":
                source_lines = []
                for part in values.get("S", line_no).split(","):
                    bounds = part.split("-", 1)
                    if bounds[0].isdigit():
                        start = int(bounds[0])
                        end = int(bounds[1]) if len(bounds) == 2 and bounds[1].isdigit() else start
                        source_lines.extend(str(number) for number in range(start, end + 1))
                for source_line in source_lines or [line_no]:
                    key = (source_line,)
                    keys[typ][relative].add(key)
                    if count > 0:
                        hit_keys[typ][relative].add(key)
                continue
            elif typ == "expr":
                key = (line_no, col, option)
            else:
                key = (line_no, col, option)
            keys[typ][relative].add(key)
            if count > 0:
                hit_keys[typ][relative].add(key)
            elif len(point_refs[typ][relative]) < 25:
                point_refs[typ][relative].append({"line": line_no, "column": col, "point": option})

    per_source = {}
    totals = {kind: {"covered": 0, "points": 0} for kind in keys}
    never_instrumented = []
    for path, class_name in sorted(scoped.items()):
        per_source[path] = {"class": class_name, "metrics": {}}
        any_points = False
        for kind in keys:
            total = len(keys[kind][path])
            hit = len(hit_keys[kind][path])
            any_points |= total > 0
            totals[kind]["covered"] += hit
            totals[kind]["points"] += total
            per_source[path]["metrics"][kind] = {
                "covered": hit, "points": total, "percent": percent(hit, total),
                "uncovered_samples": point_refs[kind][path],
            }
        if not any_points:
            never_instrumented.append(path)
    for item in totals.values():
        item["percent"] = percent(item["covered"], item["points"])
    result = {
        "schema_version": 1,
        "source_scope": "100% target set from active_rtl_source_scope.json; union across supplied configuration runs; source-line/point union ignores instance replication",
        "data_file": args.merged.name,
        "scoped_source_count": len(scoped),
        "instrumented_source_count": len(seen_instrumented),
        "never_instrumented_source_count": len(never_instrumented),
        "never_instrumented_sources": never_instrumented,
        "metrics": totals,
        "sources": per_source,
    }
    args.json.parent.mkdir(parents=True, exist_ok=True)
    args.json.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    rows = ["# Source coverage union / Coverage theo source", "",
            "The percentages union coverage points by source and source location across all input runs; replicated instances are not counted as new source points. `None` means no instrumented points, not 100%. This is Verilator expression coverage, not condition coverage.", "",
            "| Metric | Covered | Points | Percent |", "|---|---:|---:|---:|"]
    for kind, item in totals.items():
        rows.append(f"| {kind} | {item['covered']} | {item['points']} | {item['percent']}% |")
    rows += ["", f"Threshold sources instrumented: {len(seen_instrumented)}/{len(scoped)}. Sources with no recorded points: {len(never_instrumented)}.", "",
             "| Source | Class | Metric | Covered / points | Percent |", "|---|---|---|---:|---:|"]
    for path, source in sorted(per_source.items()):
        for kind, metric in source["metrics"].items():
            pc = "n/a" if metric["percent"] is None else f"{metric['percent']}%"
            rows.append(f"| `{path}` | {source['class']} | {kind} | {metric['covered']}/{metric['points']} | {pc} |")
    args.markdown.parent.mkdir(parents=True, exist_ok=True)
    args.markdown.write_text("\n".join(rows) + "\n", encoding="utf-8")
    print("Source coverage union:", ", ".join(f"{k}={v['percent']}% ({v['covered']}/{v['points']})" for k,v in totals.items()))
    print(f"Threshold sources instrumented: {len(seen_instrumented)}/{len(scoped)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
