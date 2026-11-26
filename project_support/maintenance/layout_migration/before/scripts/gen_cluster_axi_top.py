#!/usr/bin/env python3
"""Generate the structural AXI cluster top port shell from HDS Section 6.2."""

from __future__ import annotations

import argparse
import re
from pathlib import Path


PROJECT = "VLSIT RISC-V CPU Cluster"
AUTHOR = "Quan Nguyen (user)"
AI_PAGE = "https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model"
TOP = "m_vlsit_riscv_cluster_axi_top"


def read_axi_ports(spec_path: Path) -> list[tuple[str, str, int | str, str]]:
    text = spec_path.read_text(encoding="utf-8")
    start = text.index("### 6.2 Complete AXI-profile port list")
    stop = text.index("#### ACE coherent memory ports", start)
    section = text[start:stop]
    ports: list[tuple[str, str, int | str, str]] = []
    for raw_line in section.splitlines():
        if not raw_line.startswith("|"):
            continue
        cols = [cell.strip() for cell in raw_line.strip().strip("|").split("|")]
        if len(cols) < 9 or cols[0] in {"Port", "---"}:
            continue
        name, direction, width_text = cols[0:3]
        config = cols[8]
        if not re.fullmatch(r"[io]_[a-z0-9_]+", name):
            continue
        if direction not in {"Input", "Output"}:
            continue
        if not ("All" in config or "CFG-AXI" in config):
            continue
        if width_text in {"PARA_AXI_MEM_DATA_W", "PARA_AXI_MEM_DATA_W/8"}:
            width: int | str = width_text
        else:
            match = re.match(r"(\d+)", width_text)
            if match is None:
                raise ValueError(f"Cannot parse width for {name}: {width_text!r}")
            width = int(match.group(1))
        meaning = cols[3].replace("`", "")
        ports.append((name, direction.lower(), width, meaning))

    names = [port[0] for port in ports]
    if len(names) != len(set(names)):
        raise ValueError("Duplicate port names found in HDS Section 6.2")
    if not ports:
        raise ValueError("No AXI-profile ports found in HDS Section 6.2")
    return ports


def render(ports: list[tuple[str, str, int | str, str]]) -> str:
    def packed_width(width: int | str) -> str:
        if isinstance(width, int):
            return "" if width == 1 else f"[{width - 1}:0]"
        if width == "PARA_AXI_MEM_DATA_W":
            return "[PARA_AXI_MEM_DATA_W-1:0]"
        if width == "PARA_AXI_MEM_DATA_W/8":
            return "[PARA_AXI_MEM_DATA_W/8-1:0]"
        raise ValueError(f"Unsupported width expression: {width}")

    output = [
        "/*",
        f" * Project      : {PROJECT}",
        f" * Author       : {AUTHOR}",
        " * AI Flow      : VLSIT RTL Generator AI Automation Flow",
        f" * AI Flow Page : {AI_PAGE}",
        " * Date         : 2026-11-14",
        " * Description  : Structural AXI-profile top with an external memory width adapter.",
        " * Change History:",
        " * 2026-11-14 - Quan Nguyen and Codex - VLSI Technology page:",
        " *              Add approved sticky fault interrupt boundary (DEC-036).",
        " * 2026-11-14 - Quan Nguyen and Codex - VLSI Technology page:",
        " *              Add the shared compile-time PMA/router region table (DEC-037).",
        " * 2026-11-14 - Quan Nguyen and Codex - VLSI Technology page:",
        " *              Add parameterized memory AXI width adapter (DEC-034).",
        " */",
        "`timescale 1ns/1ps",
        "",
        f"module {TOP} #(",
        "  // Parameter Description: number of active CVA6 harts.",
        "  // Parameter values: 2 or 4; default is 4.",
        "  // Parameter unit: harts.",
        "  parameter logic [31:0] PARA_CPU_NUM = 32'd4,",
        "  // Parameter Description: number of independent coherence transaction contexts.",
        "  // Parameter values: 2 through 16; default is 8.",
        "  // Parameter unit: contexts.",
        "  parameter logic [31:0] PARA_COH_TXN_NUM = 32'd8,",
        "  // Parameter Description: LLC associativity.",
        "  // Parameter values: 1 through 32; default is 4, subject to axi_llc limits.",
        "  // Parameter unit: ways.",
        "  parameter logic [31:0] PARA_LLC_WAY_NUM = 32'd4,",
        "  // Parameter Description: number of cache lines in each LLC way.",
        "  // Parameter values: power of two greater than 2; default is 4096.",
        "  // Parameter unit: lines per way.",
        "  parameter logic [31:0] PARA_LLC_NO_LINES = 32'd4096,",
        "  // Parameter Description: number of 64-bit blocks in each LLC line.",
        "  // Parameter values: power of two and at least 2; default is 2.",
        "  // Parameter unit: blocks.",
        "  parameter logic [31:0] PARA_LLC_BLOCK_NUM = 32'd2,",
        "  // Parameter Description: AXI memory data width outside the fixed 64-bit LLC interface.",
        "  // Parameter values: 32, 64, 128, or 256; default is 64.",
        "  // Parameter unit: bits.",
        "  parameter logic [31:0] PARA_AXI_MEM_DATA_W = 32'd64,",
        "  // Parameter Description: number of programmable cluster performance counters.",
        "  // Parameter values: 1 through 32; default is 16.",
        "  // Parameter unit: counters.",
        "  parameter logic [31:0] PARA_PMU_COUNTER_NUM = 32'd16,",
        "  // Parameter Description: width of each programmable counter.",
        "  // Parameter values: 32 or 64; default is 64.",
        "  // Parameter unit: bits.",
        "  parameter logic [31:0] PARA_PMU_COUNTER_W = 32'd64,",
        "  // Parameter Description: number of active physical-address regions shared by PMA and router.",
        "  // Parameter values: 1 through 16; default is the CVA6 cacheable range only.",
        "  // Parameter unit: regions.",
        "  parameter logic [31:0] PARA_ADDR_REGION_NUM = 32'd1,",
        "  // Parameter Description: low 32 bits of each region base address.",
        "  // Parameter values: active entries are 16-byte aligned and below 2^56.",
        "  // Parameter unit: bytes.",
        "  parameter logic [31:0] PARA_ADDR_REGION_BASE_LO [0:15] = '{default:32'd0, 0:32'h8000_0000},",
        "  // Parameter Description: high 32 bits of each region base address.",
        "  // Parameter values: active entries are 16-byte aligned and below 2^56.",
        "  // Parameter unit: bytes.",
        "  parameter logic [31:0] PARA_ADDR_REGION_BASE_HI [0:15] = '{default:32'd0},",
        "  // Parameter Description: low 32 bits of each region byte length.",
        "  // Parameter values: active lengths are non-zero 16-byte multiples.",
        "  // Parameter unit: bytes.",
        "  parameter logic [31:0] PARA_ADDR_REGION_SIZE_LO [0:15] = '{default:32'd0, 0:32'h4000_0000},",
        "  // Parameter Description: high 32 bits of each region byte length.",
        "  // Parameter values: active lengths are 16-byte multiples.",
        "  // Parameter unit: bytes.",
        "  parameter logic [31:0] PARA_ADDR_REGION_SIZE_HI [0:15] = '{default:32'd0},",
        "  // Parameter Description: bits [1:0] carry class; upper bits must be zero.",
        "  // Parameter values: 0 cacheable, 1 normal uncached, 2 MMIO; 3 is reserved.",
        "  // Parameter unit: none.",
        "  parameter logic [31:0] PARA_ADDR_REGION_TYPE [0:15] = '{default:32'd0}",
        ") (",
    ]
    groups = {
        "clock": "Clock and reset",
        "control": "Boot, interrupt, debug, and PMU status",
        "axil": "AXI4-Lite subordinate interface",
        "mmio": "AXI4 MMIO manager interface",
        "memory": "AXI4 memory manager interface",
    }

    def group_of(name: str) -> str:
        if name in {"i_clk_cluster", "i_rst_n_cluster"}:
            return "clock"
        if name.startswith(("i_axil_", "o_axil_")):
            return "axil"
        if name.startswith(("i_axi_mmio_", "o_axi_mmio_")):
            return "mmio"
        if name.startswith(("i_axi_mem_", "o_axi_mem_")):
            return "memory"
        return "control"

    max_width = max(len(packed_width(width)) for _, _, width, _ in ports)
    previous_group = ""
    for index, (name, direction, width, meaning) in enumerate(ports):
        current_group = group_of(name)
        if current_group != previous_group:
            if previous_group:
                output.append("")
            output.append(f"  // {groups[current_group]}")
            previous_group = current_group
        sv_direction = "input" if direction == "input" else "output"
        sv_type = "wire" if direction == "input" else "logic"
        packed = packed_width(width)
        packed = f" {packed}" if packed else ""
        comma = "," if index != len(ports) - 1 else ""
        width_field = packed.strip()
        output.append(
            f"  {sv_direction:<6} {sv_type:<5} {width_field:<{max_width}} {name}{comma}"
        )
    output += [
        ");",
        "",
        "  // Fixed-width memory-side signals connect the core's 64-bit LLC port to the converter.",
    ]
    memory_widths = {
        "o_axi_mem_wdata": 64,
        "o_axi_mem_wstrb": 8,
        "i_axi_mem_rdata": 64,
    }
    for name, direction, width, _ in ports:
        if not name.startswith(("o_axi_mem_", "i_axi_mem_")):
            continue
        suffix = name.removeprefix("o_axi_mem_").removeprefix("i_axi_mem_")
        core_width = memory_widths.get(name, width)
        packed = packed_width(core_width)
        if packed:
            output.append(f"  logic {packed:<33} w_axi_llc_{suffix};")
        else:
            output.append(f"  logic                               w_axi_llc_{suffix};")
    output += [
        "",
        "  // The cluster core keeps its native LLC memory interface at 64 bits.",
        "  m_vlsit_riscv_cluster_core #(",
        "    .PARA_CPU_NUM(PARA_CPU_NUM),",
        "    .PARA_COH_TXN_NUM(PARA_COH_TXN_NUM),",
        "    .PARA_LLC_WAY_NUM(PARA_LLC_WAY_NUM),",
        "    .PARA_LLC_NO_LINES(PARA_LLC_NO_LINES),",
        "    .PARA_LLC_BLOCK_NUM(PARA_LLC_BLOCK_NUM),",
        "    .PARA_PMU_COUNTER_NUM(PARA_PMU_COUNTER_NUM),",
        "    .PARA_PMU_COUNTER_W(PARA_PMU_COUNTER_W),",
        "    .PARA_ADDR_REGION_NUM(PARA_ADDR_REGION_NUM),",
        "    .PARA_ADDR_REGION_BASE_LO(PARA_ADDR_REGION_BASE_LO),",
        "    .PARA_ADDR_REGION_BASE_HI(PARA_ADDR_REGION_BASE_HI),",
        "    .PARA_ADDR_REGION_SIZE_LO(PARA_ADDR_REGION_SIZE_LO),",
        "    .PARA_ADDR_REGION_SIZE_HI(PARA_ADDR_REGION_SIZE_HI),",
        "    .PARA_ADDR_REGION_TYPE(PARA_ADDR_REGION_TYPE)",
        "  ) u_vlsit_riscv_cluster_core (",
    ]
    core_ports = [port for port in ports if not port[0].startswith(("o_axi_mem_", "i_axi_mem_"))]
    core_ports += [port for port in ports if port[0].startswith(("o_axi_mem_", "i_axi_mem_"))]
    for index, (name, _, _, _) in enumerate(core_ports):
        comma = "," if index != len(core_ports) - 1 else ""
        if name.startswith(("o_axi_mem_", "i_axi_mem_")):
            suffix = name.removeprefix("o_axi_mem_").removeprefix("i_axi_mem_")
            signal = f"w_axi_llc_{suffix}"
        else:
            signal = name
        output.append(f"    .{name}({signal}){comma}")
    output += ["  );", "", "  // The adapter preserves the 64-bit LLC interface while converting the external bus width.", "  m_vlsit_riscv_axi_dw_adapter #(", "    .PARA_AXI_MEM_DATA_W(PARA_AXI_MEM_DATA_W)", "  ) u_vlsit_riscv_axi_dw_adapter (", "    .i_clk_cluster(i_clk_cluster),", "    .i_rst_n_cluster(i_rst_n_cluster),"]
    adapter_pairs: list[tuple[str, str]] = []
    for name, direction, _, _ in ports:
        if not name.startswith(("o_axi_mem_", "i_axi_mem_")):
            continue
        if direction == "output":
            suffix = name.removeprefix("o_axi_mem_")
            adapter_name = f"i_axi_llc_{suffix}"
        else:
            suffix = name.removeprefix("i_axi_mem_")
            adapter_name = f"o_axi_llc_{suffix}"
        internal = f"w_axi_llc_{suffix}"
        adapter_pairs.append((adapter_name, internal))
    external_pairs = [
        (name, name)
        for name, _, _, _ in ports
        if name.startswith(("o_axi_mem_", "i_axi_mem_"))
    ]
    adapter_connections = adapter_pairs + external_pairs
    for index, (adapter_name, signal) in enumerate(adapter_connections):
        comma = "," if index != len(adapter_connections) - 1 else ""
        output.append(f"    .{adapter_name}({signal}){comma}")
    output += ["  );", "", "endmodule", ""]
    return "\n".join(output)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("spec", type=Path, help="HDS Markdown file")
    parser.add_argument("output", type=Path, help="Output SystemVerilog path")
    args = parser.parse_args()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(render(read_axi_ports(args.spec)), encoding="utf-8", newline="\n")
    print(f"Generated {args.output} from {args.spec}")


if __name__ == "__main__":
    main()
