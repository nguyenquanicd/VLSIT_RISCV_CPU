"""Generate shared C or SystemVerilog constants for the release-1 descriptor ABI."""

import argparse
import json
import re
from pathlib import Path


LAYOUT_PATH = (
    Path(__file__).resolve().parents[1]
    / "doc"
    / "tensor_coprocessor"
    / "descriptor_layout.json"
)
HDS_PATH = LAYOUT_PATH.with_name("VLSIT_TENSOR_COPROCESSOR_HDS.md")


def validate_fields(fields, start, end):
    """Reject overlaps and out-of-range fields. Unlisted bytes are reserved."""
    names = set()
    position = start
    for name, offset, size in sorted(fields, key=lambda field: field[1]):
        if not re.fullmatch(r"[a-z][a-z0-9_]*", name) or name in names:
            raise ValueError(f"invalid or duplicate field name: {name}")
        if size < 1 or offset < position or offset + size > end:
            raise ValueError(f"invalid offset or width for {name}")
        names.add(name)
        position = offset + size


def constants(layout):
    align = layout["descriptor_alignment"]
    config_start = layout["config_offset"]
    ref_start = config_start + layout["config_bytes"]
    ref_bytes = 64
    if layout["byte_order"] != "little" or align != 64:
        raise ValueError("release-1 descriptors use little endian and 64-byte alignment")
    if config_start != 64 or ref_start != 128:
        raise ValueError("release-1 descriptor common header and config must be 64 bytes each")
    validate_fields(layout["header_fields"], 0, config_start)
    validate_fields(layout["tref_fields"], 0, ref_bytes)
    result = {
        "SCHEMA_MAJOR": layout["major"],
        "SCHEMA_MINOR": layout["minor"],
        "HEADER_BYTES": config_start,
        "DESCRIPTOR_ALIGNMENT": align,
        "CONFIG_OFFSET": config_start,
        "CONFIG_BYTES": layout["config_bytes"],
        "TREF_BYTES": ref_bytes,
        "MAX_DESCRIPTOR_BYTES": layout["max_descriptor_bytes"],
        "MAJOR_OPCODE": layout["major_opcode"],
    }
    if layout["major_opcode"] != 0x0B or layout["precision_ids"] != {"int8": 0, "bf16": 1, "fp16": 2}:
        raise ValueError("instruction opcode or precision IDs differ from release 1")
    result.update({f"PRECISION_{name.upper()}": value
                   for name, value in layout["precision_ids"].items()})

    def add_fields(prefix, fields):
        for name, offset, width in fields:
            result[f"{prefix}_{name.upper()}_OFFSET"] = offset
            result[f"{prefix}_{name.upper()}_BYTES"] = width

    add_fields("HEADER", layout["header_fields"])
    add_fields("TREF", layout["tref_fields"])

    tlas = layout["tlas_header"]
    if (tlas["size"], tlas["magic"], tlas["major"],
            tlas["feature_map_id"], tlas["state_format"]) != (64, "TLAS", 1, 0, 1):
        raise ValueError("TLAS header constants differ from release 1")
    validate_fields(tlas["fields"], 0, tlas["size"])
    result.update({
        "TLAS_HEADER_BYTES": tlas["size"],
        "TLAS_MAGIC_LE": int.from_bytes(tlas["magic"].encode("ascii"), "little"),
        "TLAS_MAJOR": tlas["major"],
        "TLAS_FEATURE_MAP_ID": tlas["feature_map_id"],
        "TLAS_STATE_FORMAT": tlas["state_format"],
        "TLAS_PAYLOAD_OFFSET": tlas["size"],
    })
    add_fields("TLAS", tlas["fields"])

    keys, names = set(), set()
    for schema in layout["schemas"]:
        name = schema["name"]
        key = (schema["operation"], schema["variant"])
        if key in keys or name in names or not re.fullmatch(r"[a-z][a-z0-9_]*", name):
            raise ValueError(f"duplicate or invalid schema: {name}")
        keys.add(key)
        names.add(name)
        validate_fields(schema["config"], config_start, ref_start)
        refs = schema["references"]
        fields = [(ref, ref_start + i * ref_bytes, ref_bytes) for i, ref in enumerate(refs)]
        lut_start = ref_start + len(refs) * ref_bytes
        lut_bytes = schema["inline_lut_bytes"]
        size = schema["size"]
        if lut_bytes not in (0, 256) or lut_start + lut_bytes != size or size % align:
            raise ValueError(f"schema size mismatch for {name}")
        validate_fields(fields, ref_start, size)
        prefix = name.upper()
        result[f"{prefix}_OPERATION_ID"] = key[0]
        result[f"{prefix}_VARIANT"] = key[1]
        result[f"{prefix}_SCHEMA_BYTES"] = size
        result[f"{prefix}_REF_END"] = lut_start
        add_fields(f"{prefix}_CFG", schema["config"])
        add_fields(f"{prefix}_REF", fields)
        if lut_bytes:
            add_fields(prefix, [("lut", lut_start, lut_bytes)])

    if keys != {(op, 0) for op in range(1, 10)} | {(4, 1)}:
        raise ValueError("release-1 schema set must cover OP-001..009 and fused OP-004")
    if max(schema["size"] for schema in layout["schemas"]) != result["MAX_DESCRIPTOR_BYTES"]:
        raise ValueError("maximum descriptor size mismatch")
    return result


def status_constants(hds):
    """Read the normative status numbers from the HDS table."""
    marker = "| Status code | Symbol | Meaning |"
    if hds.count(marker) != 1:
        raise ValueError("expected one HDS status code table")
    table = hds.split(marker, 1)[1].lstrip("\n").split("\n\n", 1)[0]
    rows = table.splitlines()[1:]
    result = {}
    for row in rows:
        match = re.match(r"^\| `(0x[0-9a-fA-F]{4}_[0-9a-fA-F]{4})` \| `TC_([A-Z0-9_]+)` \|", row)
        if not match:
            raise ValueError(f"invalid HDS status row: {row}")
        code, name = match.groups()
        value = int(code.replace("_", ""), 16)
        if name in result or value in result.values():
            raise ValueError(f"duplicate HDS status: {name} / {code}")
        result[name] = value
    if result.get("STATUS_OK") != 0 or "ERR_AXI_TIMEOUT" in result:
        raise ValueError("HDS status table violates the selected result/reset ABI")
    return result


def capability_constants(profile):
    """Validate an explicit build's qualified operation/precision matrix."""
    mask = profile["algorithm_mask"]
    precision = profile["data_precision"]
    mode = profile["control_mode"]
    argmax = profile["argmax_impl"]
    xlen = profile["xlen"]
    rows = profile["qualified_precision_rows"]
    if any(type(value) is not int for value in (mask, precision, mode, argmax, xlen)):
        raise ValueError("build selectors must use integer encodings")
    if (not 1 <= mask <= 0x7f or not mask & 1 or precision not in (0, 1)
            or mode not in (0, 2) or argmax not in (0, 1) or xlen not in (32, 64)):
        raise ValueError("invalid release-1 build selectors")
    if mask & 0x02 and not mask & 0x04:
        raise ValueError("exact attention requires the normalization family")
    if (not isinstance(rows, list) or len(rows) != 9
            or any(type(row) is not int or not 0 <= row <= 7 for row in rows)):
        raise ValueError("qualified_precision_rows must contain nine 3-bit integers")

    family_bits = (0, 3, 5, 5, 1, 2, 2, 4, 6)
    structural_rows = (7, 7, 7, 7, 6, 6, 6, 1, 6)
    selected_precisions = 7 if precision else 1
    qualified_families = 0
    for op, (row, family, structural) in enumerate(zip(rows, family_bits, structural_rows), 1):
        legal = structural & selected_precisions
        if not mask & (1 << family) or (family == 5 and mode != 2):
            legal = 0
        if row & ~legal:
            raise ValueError(f"OP-{op:03d} qualifies an unavailable precision")
        if row:
            qualified_families |= 1 << family
    if qualified_families != mask:
        raise ValueError("each enabled family requires a qualified operation/precision pair")

    values = {
        "BUILD_ALGORITHM_MASK": mask,
        "BUILD_DATA_PREC": precision,
        "BUILD_CTRL_MODE": mode,
        "BUILD_ARGMAX_IMPL": argmax,
        "BUILD_XLEN": xlen,
    }
    values.update({f"BUILD_OP_{op:03d}_PRECISION_MASK": row for op, row in enumerate(rows, 1)})
    return values


def render(layout, values, output_format):
    notice = "// Generated from descriptor_layout.json and the tensor HDS status table."
    is_c = output_format == "c"
    if is_c:
        lines = [notice, "#ifndef TCOP_DESCRIPTOR_LAYOUT_H", "#define TCOP_DESCRIPTOR_LAYOUT_H"]
        lines += [f"#define TCOP_{name} {value}u" for name, value in values.items()]
    else:
        lines = [notice, "package tcop_descriptor_layout_pkg;"]
        lines += [f"  localparam int unsigned TCOP_{name} = {value};" for name, value in values.items()]

    for function, suffix in (
        ("tcop_descriptor_schema_bytes", "SCHEMA_BYTES"),
        ("tcop_descriptor_ref_end", "REF_END"),
    ):
        lines.append("")
        if is_c:
            lines += [
                f"static inline unsigned {function}(unsigned operation, unsigned variant)",
                "{",
                "    switch (operation) {",
            ]
        else:
            lines += [
                f"  function automatic int unsigned {function}(",
                "      input int unsigned operation, input int unsigned variant);",
                "    case (operation)",
            ]
        for operation in range(1, 10):
            schemas = [s for s in layout["schemas"] if s["operation"] == operation]
            label = f"TCOP_{schemas[0]['name'].upper()}_OPERATION_ID"
            lines.append(f"    case {label}:" if is_c else f"      {label}: begin")
            for schema in schemas:
                prefix = f"TCOP_{schema['name'].upper()}"
                lines.append(f"        if (variant == {prefix}_VARIANT)")
                lines.append(f"          return {prefix}_{suffix};")
            lines.append("        break;" if is_c else "      end")
        if is_c:
            lines += ["    }", "    return 0;", "}"]
        else:
            lines += ["      default: return 0;", "    endcase", "    return 0;", "  endfunction"]
    lines += ["", "#endif" if is_c else "endpackage"]
    return "\n".join(lines) + "\n"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--format", required=True, choices=("c", "sv"))
    parser.add_argument("--output", type=Path, help="Write generated constants to this file")
    parser.add_argument("--build-profile", type=Path, help="Include validated operation/precision rows")
    args = parser.parse_args()
    layout = json.loads(LAYOUT_PATH.read_text(encoding="utf-8"))
    values = constants(layout)
    values.update(status_constants(HDS_PATH.read_text(encoding="utf-8")))
    if args.build_profile is not None:
        values.update(capability_constants(json.loads(args.build_profile.read_text(encoding="utf-8"))))
    output = render(layout, values, args.format)
    if args.output is None:
        print(output, end="")
    else:
        args.output.write_text(output, encoding="utf-8", newline="\n")


if __name__ == "__main__":
    main()
