from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[4]
FILES = [
    ROOT / "rtl/vlsit/m_vlsit_riscv_cache_line_locks.sv",
    ROOT / "rtl/vlsit/m_vlsit_riscv_tile_coh_adapter.sv",
    ROOT / "rtl/vlsit/m_vlsit_riscv_cpu_tile.sv",
]
PORT_RE = re.compile(r"^(\s*)(input|output|inout)\s+(wire|logic)\s*((?:\[[^\]]+\]\s*)*)\s+([A-Za-z_]\w*)(,?)\s*$")

for path in FILES:
    text = path.read_text(encoding="utf-8")
    start = text.index(") (\n") + len(") (\n")
    end = text.index("\n);", start)
    lines = text[start:end].splitlines()
    ports = []
    for line in lines:
        match = PORT_RE.match(line)
        if match:
            indent, direction, data_type, packed, name, comma = match.groups()
            packed = " ".join(packed.split())
            ports.append((direction, data_type, packed))
    direction_width = max(len(port[0]) for port in ports)
    type_width = max(len(port[1]) for port in ports)
    packed_width = max(len(port[2]) for port in ports)
    formatted = []
    for line in lines:
        match = PORT_RE.match(line)
        if not match:
            formatted.append(line)
            continue
        indent, direction, data_type, packed, name, comma = match.groups()
        packed = " ".join(packed.split())
        formatted.append(
            f"  {direction:<{direction_width}} {data_type:<{type_width}} "
            f"{packed:<{packed_width}} {name}{comma}"
        )
    path.write_text(text[:start] + "\n".join(formatted) + text[end:], encoding="utf-8")
