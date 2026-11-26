"""Check local tensor specification artifacts and numerical reference vectors."""

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from struct import pack, unpack_from

from openpyxl import load_workbook

from audit_documentation import ROOT, anchors, links, target
from generate_tensor_descriptor_layout import capability_constants, constants, render, status_constants


DOCS = ROOT / "doc/tensor_coprocessor"
HDS = DOCS / "VLSIT_TENSOR_COPROCESSOR_HDS.md"
LOCAL_ARM = DOCS / "reference/md_doc/vlsit_axi_amba_axi_ihi0022h.md"


def read(path):
    return path.read_text(encoding="utf-8-sig")


def check_navigation():
    count = 0
    skips = {LOCAL_ARM, DOCS / "reference/md_doc/vlsit_cvxif_openhw_core_v_xif_v1_0_0.md"}
    for source in DOCS.rglob("*.md"):
        if source in skips or "review" in source.relative_to(DOCS).parts:
            continue
        for _, _, link in links(read(source)):
            kind, destination, anchor = target(source, link)
            if kind != "local":
                continue
            if destination == LOCAL_ARM and not destination.exists():
                continue
            if not destination.exists() or (
                anchor and destination.suffix == ".md" and anchor not in anchors(destination)
            ):
                raise ValueError(f"{source.name}: missing navigation target {link}")
            count += 1
    return count


def check_figures(hds):
    embedded = set()
    pattern = r"!\[[^\]\n]+\]\((figures/[^\s)]+\.svg)\).*?^```(?:json|wavedrom)\n(.*?)\n^```"
    for svg, block in re.findall(pattern, hds, flags=re.M | re.S):
        source = (DOCS / svg).with_suffix(".json")
        if source in embedded or json.loads(block) != json.loads(read(source)):
            raise ValueError(f"HDS figure source differs: {source.name}")
        embedded.add(source)
    expected = {
        (DOCS / link).with_suffix(".json")
        for link in re.findall(r"!\[[^\]\n]+\]\((figures/[^\s)]+\.svg)\)", hds)
    }
    if embedded != expected:
        raise ValueError("HDS figure links and embedded source coverage differ")
    return len(embedded)


def check_test_traceability(hds):
    verification = hds.split("\n## 15. ", 1)[1].split("\n## 16. ", 1)[0]
    traceability = hds.split("\n## 19. ", 1)[1].split("\n## 20. ", 1)[0]
    requirements = set(re.findall(r"^\| (REQ-[A-Z]+-\d{3}) \|",
                                  hds.split("\n## 19. ", 1)[0], re.M))
    evidence = set(re.findall(r"^\| ((?:TEST|SVA|COV)-\d{3}) \|", verification, re.M))

    planned = set()
    for test_id, refs in re.findall(r"^\| (TEST-\d{3}) \| ([^|]+)\|", verification, re.M):
        for prefix, first, suffix in re.findall(r"(REQ-[A-Z]+-)(\d{3})([./0-9]*)", refs):
            planned.add((prefix + first, test_id))
            if suffix.startswith(".."):
                for number in range(int(first) + 1, int(suffix[2:]) + 1):
                    planned.add((f"{prefix}{number:03d}", test_id))
            elif suffix.startswith("/"):
                planned.update((prefix + number, test_id) for number in suffix[1:].split("/"))

    traced = set()
    covered_requirements = set()
    for requirement, refs in re.findall(
        r"^\| (REQ-[A-Z]+-\d{3}) \| [^|]+\| ([^|]+)\|", traceability, re.M
    ):
        ids = set(re.findall(r"(?:TEST|SVA|COV)-\d{3}", refs))
        if requirement in covered_requirements or not ids or not ids <= evidence:
            raise ValueError(f"{requirement}: duplicate or invalid traceability row")
        covered_requirements.add(requirement)
        traced.update((requirement, item) for item in ids if item.startswith("TEST-"))

    if requirements != covered_requirements:
        raise ValueError("requirement IDs differ between HDS requirements and traceability matrix")
    if traced != planned:
        raise ValueError(f"test traceability differs: missing {sorted(planned - traced)}, "
                         f"extra {sorted(traced - planned)}")
    return len(covered_requirements), len(traced)


def check_waveform_ordering():
    overlaps = (
        ("Next K/V tile prefetch", "QK tile", "Output writes successful"),
        ("Row 1 prefetch", "Centered exp", "Row writes successful"),
        ("Row 1 prefetch", "Variance, epsilon and rsqrt", "Row writes successful"),
        ("Metadata tile 1 prefetch", "Paired MAC tile 0", "All C writes successful"),
        ("Token 1 Q/K/V prefetch", "S/z FP32 updates", "Context and checkpoint writes successful"),
    )

    def tracks(number, *, value_names=(), source_name=None):
        if source_name is None:
            source, = (DOCS / "figures").glob(f"wf{number:03d}_*.json")
        else:
            source = DOCS / "figures" / source_name
        rows = json.loads(read(source))["signal"]
        flat = (row for group in rows for row in (group[1:] if isinstance(group, list) else [group]))
        result = {}
        for row in flat:
            if row["name"] in value_names:
                labels = iter(row.get("data", []))
                values = {}
                label = None
                for cycle, sample in enumerate(row["wave"]):
                    if sample == "=":
                        label = next(labels, None)
                        if label is None:
                            raise ValueError(f"WF-{number:03d}: missing label for {row['name']}")
                    elif sample != ".":
                        label = None
                    if label is not None:
                        values[cycle] = label
                result[row["name"]] = values
                continue
            high = set()
            level = None
            for cycle, sample in enumerate(row["wave"]):
                if sample != ".":
                    level = sample
                if level == "1":
                    high.add(cycle)
            result[row["name"]] = high
        return result

    def require_order(number, wave, *names):
        for earlier, later in zip(names, names[1:]):
            if not wave[earlier] or not wave[later] or max(wave[earlier]) >= min(wave[later]):
                raise ValueError(f"WF-{number:03d}: {earlier} must precede {later}")

    for number, write_or_ready in ((1, "if003_output_writes_drained (conceptual)"),
                                   (4, "All output writes successful (conceptual)"),
                                   (9, "Global winner valid (conceptual)")):
        wave = tracks(number)
        require_order(number, wave, "o_xif_issue_resp_accept", "i_xif_commit_valid",
                      write_or_ready, "o_xif_result_valid")
        if len(wave["o_xif_issue_resp_accept"] & wave["o_xif_issue_ready"]) != 1:
            raise ValueError(f"WF-{number:03d}: expected one accepted instruction")

    wave = tracks(2)
    if (len(wave["i_xif_issue_valid"] & wave["o_xif_issue_ready"]) != 1
            or wave["i_xif_commit_valid"] != wave["i_xif_commit_kill"]
            or not wave["i_xif_commit_kill"]
            or any(wave[name] for name in ("o_xif_issue_resp_accept", "o_axi_tensor_arvalid",
                                           "o_xif_result_valid"))):
        raise ValueError("WF-002: issue rejection must be disposed without DMA or result")

    wave = tracks(3)
    ar = wave["o_axi_tensor_arvalid"] & wave["i_axi_tensor_arready"]
    r = wave["i_axi_tensor_rvalid"] & wave["o_axi_tensor_rready"]
    if (len(ar) != 1 or len(r) != 2 or wave["i_axi_tensor_rlast"] != {max(r)}
            or min(wave["i_axi_tensor_rvalid"]) <= max(ar)
            or not wave["i_axi_tensor_rvalid"] - wave["o_axi_tensor_rready"]):
        raise ValueError("WF-003: expected one address, held first beat and matching final beat")

    wave = tracks(5)
    require_order(5, wave, "i_xif_commit_valid", "Input read drained (conceptual)",
                  "o_xif_result_valid", "Owner reads err_valid=0 (conceptual)",
                  "Owner writes scalar_ack (conceptual)", "Scalar ack consumed in core (conceptual)")
    if (not wave["o_xif_result_valid"] <= wave["Busy visible in APB (conceptual)"]
            or wave["Error visible in APB (conceptual)"]):
        raise ValueError("WF-005: a valid zero must be published under the clean fence")

    wave = tracks(6, value_names=("i_apb_pstrb[3:0]",))
    apb = wave["i_apb_psel"] & wave["i_apb_penable"] & wave["o_apb_pready"]
    if len(apb) != 2 or min(apb) not in wave["i_apb_pwrite"] or max(apb) in wave["i_apb_pwrite"]:
        raise ValueError("WF-006: expected one APB write followed by one read")
    strobes = wave["i_apb_pstrb[3:0]"]
    if strobes.get(min(apb)) != "0xF" or strobes.get(max(apb)) != "0x0":
        raise ValueError("WF-006: full-word write strobe and inactive read strobe required")

    wave = tracks(7)
    first_ack = min(wave["o_quiesce_ack"])
    released = wave["i_rst_n_core"]
    first_reset = next((i for i in range(max(released)) if i not in released), None)
    read_start = wave["o_axi_arvalid"] & wave["i_axi_arready"]
    read_end = wave["i_axi_rvalid (last required read)"] & wave["o_axi_rready"]
    result = wave["o_xif_result_valid"] & wave["i_xif_result_ready"]
    accepted = wave["o_xif_issue_resp_accept"] & wave["i_xif_issue_valid"] & wave["o_xif_issue_ready"]
    if (first_reset is None or len(read_start) != 1 or len(read_end) != 1 or len(result) != 1
            or not max(read_start) < max(read_end) < max(result) < first_ack < first_reset
            or min(wave["drain_seen (reset controller)"]) not in range(first_ack, first_reset)
            or accepted & wave["i_quiesce_req"]
            or first_reset not in wave["i_quiesce_req"]):
        raise ValueError("WF-007: normal reset must follow quiesce acknowledgement and drain")

    result_fields = ("o_xif_result_data", "o_xif_result_rd", "o_xif_result_id")
    wave = tracks(8, value_names=result_fields)
    valid = wave["o_xif_result_valid"]
    fire = valid & wave["i_xif_result_ready"]
    if valid != set(range(min(valid), max(valid) + 1)) or fire != {max(valid)}:
        raise ValueError("WF-008: hold valid through one final result handshake")
    for field in result_fields:
        held = {wave[field].get(cycle) for cycle in valid}
        if len(held) != 1 or None in held:
            raise ValueError(f"WF-008: {field} changes while result is held")
    if not valid <= wave["o_xif_result_we"]:
        raise ValueError("WF-008: write-enable must stay asserted with the held result")

    wave = tracks(10, value_names=("o_xif_result_data", "IF-003 RRESP (conceptual)"))
    require_order(10, wave, "descriptor validated (conceptual)", "IF-003 operand AR handshake (conceptual)",
                  "IF-003 RLAST on final transfer (conceptual)", "all accepted traffic drained (conceptual)",
                  "APB publication ACK in core (conceptual)", "o_xif_result_valid")
    valid = wave["o_xif_result_valid"]
    read_beats = sorted(wave["IF-003 operand R handshake (conceptual)"])
    if (len(read_beats) != 2
            or wave["IF-003 RLAST on final transfer (conceptual)"] != {read_beats[-1]}
            or [wave["IF-003 RRESP (conceptual)"].get(beat) for beat in read_beats]
            != ["SLVERR", "OKAY"]):
        raise ValueError("WF-010: the first AXI beat faults and the matching final beat still drains")
    if (not valid <= wave["o_xif_result_we"]
            or {wave["o_xif_result_data"].get(cycle) for cycle in valid} != {"all-ones"}
            or valid & wave["i_xif_result_ready"] != {max(valid)}):
        raise ValueError("WF-010: hold the scalar error sentinel until one result handshake")

    wave = tracks(10, source_name="dec072_csr_publish.json")
    visible = wave["snapshot and err_valid readable"]
    require_order(10, wave, "AXI read fault drained", "publish request sent")
    require_order(10, wave, "publish ACK sent", "publish ACK observed in core",
                  "o_xif_result_valid")
    require_order(10, wave, "software reads error record", "software writes W1C",
                  "W1C observed in core")
    if (not visible or max(wave["publish request sent"]) >= min(visible)
            or not (wave["publish ACK sent"] | wave["software reads error record"]
                    | wave["software writes W1C"]) <= visible
            or len(wave["o_xif_result_valid"] & wave["i_xif_result_ready"]) != 1):
        raise ValueError("DEC-072 diagram: coherent APB publication must precede acknowledgement")

    for number, (prefetch, compute, writes) in enumerate(overlaps, 11):
        wave = tracks(number)
        accepts = wave["i_xif_issue_valid"] & wave["o_xif_issue_ready"] & wave["o_xif_issue_resp_accept"]
        commit = wave["i_xif_commit_valid"]
        result = wave["o_xif_result_valid"] & wave["i_xif_result_ready"]
        if (len(accepts) != 1 or len(commit) != 1 or len(result) != 1
                or not max(accepts) < min(commit) < min(wave["Descriptor fetch"])
                or not wave[prefetch] & wave[compute] or not max(wave[writes]) < min(result)):
            raise ValueError(f"WF-{number:03d}: issue, commit, overlap or completion ordering differs")
        if number == 14 and (
            max(wave["Full coefficient vector validated"] | wave["Metadata tile 0 validated"])
            >= min(wave["Numeric tile 0 request"])
            or max(wave["Metadata tile 1 validated"]) >= min(wave["Numeric tile 1 request"])
        ):
            raise ValueError("WF-014: sparse numeric request precedes validation")

    def coupled_accepts(number, wave):
        issue = wave["i_xif_issue_valid"] & wave["o_xif_issue_ready"] & wave["o_xif_issue_resp_accept"]
        register = wave["i_xif_register_valid"] & wave["o_xif_register_ready"]
        if (len(issue) != 2 or issue != register or not issue <= wave["i_xif_register_rs_valid"]
                or wave["o_xif_issue_ready"] != wave["o_xif_register_ready"]
                or any(wave["i_xif_issue_req_id"].get(cycle) is None
                       or wave["i_xif_issue_req_id"][cycle] != wave["i_xif_register_id"].get(cycle)
                       for cycle in issue)):
            raise ValueError(f"WF-{number:03d}: both accepted commands need coupled source capture")
        return sorted(issue)

    captured_ids = ("i_xif_issue_req_id", "i_xif_register_id", "i_xif_commit_id")
    wave = tracks(16, value_names=(*captured_ids, "descriptor_owner_xif_id (conceptual)",
                                   "o_xif_result_id"))
    issues = coupled_accepts(16, wave)
    header_ars = wave["o_axi_tensor_arvalid (header AR only)"] & wave["i_axi_tensor_arready"]
    commits = sorted(wave["i_xif_commit_valid"])
    result = wave["o_xif_result_valid (N)"] & wave["i_xif_result_ready"]
    if (len(commits) != 2 or len(header_ars) != 2 or wave["i_xif_commit_kill"]
            or max(wave["older_load_resolves_clean (conceptual)"]) >= commits[0]
            or not {commits[1], max(header_ars)} <= wave["compute_N_active (conceptual)"]
            or len(result) != 1 or min(result) <= max(header_ars)):
        raise ValueError("WF-016: descriptor overlap must follow delayed commit")
    for issue, commit, ar, owner in zip(issues, commits, sorted(header_ars), ("N", "N+1")):
        if (not issue < commit < ar or wave["i_xif_issue_req_id"].get(issue) != owner
                or wave["i_xif_commit_id"].get(commit) != owner
                or wave["descriptor_owner_xif_id (conceptual)"].get(ar) != owner):
            raise ValueError("WF-016: descriptor must use the matching authorized owner")
    if wave["o_xif_result_id"].get(min(result)) != "N":
        raise ValueError("WF-016: N+1 prefetch cannot supply the result for N")

    wave = tracks(17, value_names=captured_ids)
    issues = coupled_accepts(17, wave)
    kill = wave["i_xif_commit_kill"]
    if (wave["i_xif_commit_valid"] != wave["i_xif_commit_kill"] or not wave["i_xif_commit_kill"]
            or len(kill) != 1 or kill != wave["cva6_flush (conceptual)"]
            or not max(issues) < min(wave["older_load_exception (conceptual)"]) < min(kill)
            or [wave["i_xif_issue_req_id"].get(cycle) for cycle in issues] != ["N", "N+1"]
            or wave["i_xif_commit_id"].get(min(kill)) != "N (earliest affected)"
            or any(wave[name] for name in ("o_axi_tensor_arvalid", "o_axi_tensor_awvalid",
                                           "o_axi_tensor_wvalid", "o_xif_result_valid"))):
        raise ValueError("WF-017: pre-commit kill must produce no DMA or result")
    return 17


def check_csr():
    model = json.loads(read(DOCS / "tcop_regs.json"))
    workbook = load_workbook(DOCS / "TENSOR_COPROCESSOR_CSR.xlsx", read_only=True, data_only=True)
    rows = list(workbook["ASYNC_CSR"].values)
    workbook.close()
    config = {row[0]: row[1] for row in rows[:11] if row[0]}
    if config.get("Module Name") != model["module"] or config.get("Asynchronous") != str(model["async"]):
        raise ValueError("CSR module or clock mode differs")

    registers = {}
    header = next((i for i, row in enumerate(rows) if row[:2] == ("REGISTER", "OFFSET")), None)
    if header is None:
        raise ValueError("CSR workbook register table is missing")
    fields = None
    for name, offset, field, bits, kind, reset, *_ in rows[header + 1:]:
        if name:
            if name in registers:
                raise ValueError(f"duplicate CSR register: {name}")
            fields = {}
            registers[name] = (int(offset, 0), fields)
        if field:
            if fields is None or field in fields:
                raise ValueError(f"unexpected CSR field: {field}")
            fields[field] = (bits, kind, int(reset, 0))
    expected = {
        reg["name"]: (int(reg["offset"], 0),
                      {f["name"]: (f["bits"], f["type"], int(f["reset"], 0)) for f in reg["fields"]})
        for reg in model["registers"]
    }
    if registers != expected:
        raise ValueError("CSR addresses, field bits, types, or reset values differ")
    return len(registers)


def check_abi(hds):
    layout = json.loads(read(DOCS / "descriptor_layout.json"))
    values = constants(layout)
    isa = read(DOCS / "TENSOR_COPROCESSOR_INSTRUCTION_SET.md")
    section = isa.split("### 10.2 Fixed schema-size map", 1)[1].split("### 10.3", 1)[0]
    sizes = [
        (int(op), int(variant or 0), int(size))
        for op, variant, size in re.findall(
            r"^\| OP-(\d{3})[^|]*?(?:`PARA_ARGMAX_IMPL=(\d)`)?\s*\| (\d+) \|",
            section, flags=re.M
        )
    ]
    expected = [(s["operation"], s["variant"], s["size"]) for s in layout["schemas"]]
    if sorted(sizes) != sorted(expected):
        raise ValueError("ISA descriptor sizes differ from descriptor_layout.json")

    offsets = isa.split("#### Descriptor field offset summary", 1)[1].split("### 10.4", 1)[0]
    described = {}
    for op, variant, config, references, lut in re.findall(
        r"^\| OP-(\d{3})/(\d) \| ([^|]+) \| ([^|]+) \| ([^|]+) \|$", offsets, re.M
    ):
        key = (int(op), int(variant))
        if key in described:
            raise ValueError(f"duplicate descriptor byte map for {key}")
        described[key] = (
            [field.split(":") for field in config.split(", ")],
            [field.split(":") for field in references.split(", ")],
            lut,
        )
    if described.keys() != {(op, variant) for op, variant, _ in expected}:
        raise ValueError("ISA descriptor offset table does not cover all schema variants")

    fields = 0
    ref_start = layout["config_offset"] + layout["config_bytes"]
    for schema in layout["schemas"]:
        key = (schema["operation"], schema["variant"])
        config = [[name, str(offset), str(width)] for name, offset, width in schema["config"]]
        references = [[name, str(ref_start + 64 * index)]
                      for index, name in enumerate(schema["references"])]
        lut_bytes = schema["inline_lut_bytes"]
        lut = f"{schema['size'] - lut_bytes}:{lut_bytes}" if lut_bytes else "-"
        if described[key] != (config, references, lut):
            raise ValueError(f"ISA field offsets differ from descriptor_layout.json for OP-{key[0]:03d}/{key[1]}")
        fields += len(config) + len(references) + bool(lut_bytes)

    example = isa.split("##### Issuing the worked command from privileged CPU code", 1)[1]
    example = example.split("#### OP-009 BF16 RESET", 1)[0]
    words = [int(word, 16) for word in re.findall(r"^\.word (0x[0-9a-fA-F]{8})\b", example, re.M)]
    expected_words = [(3 << 25) | (rs2 << 20) | (10 << 15) | (12 << 7) | layout["major_opcode"]
                      for rs2 in (11, 0)]
    if words != expected_words:
        raise ValueError("worked ISA assembly words differ from the RV32/RV64 OP-003 field map")
    return len(sizes), len(values) + len(status_constants(hds)), fields


def check_build_capability():
    profile = {
        "algorithm_mask": 0x7f,
        "data_precision": 1,
        "control_mode": 2,
        "argmax_impl": 1,
        "xlen": 64,
        "qualified_precision_rows": [7, 7, 7, 7, 2, 6, 6, 1, 6],
    }
    values = capability_constants(profile)
    if values["BUILD_OP_005_PRECISION_MASK"] != 2 or values["BUILD_ARGMAX_IMPL"] != 1:
        raise ValueError("qualified attention/ARGMAX profile changed")
    minimal = dict(profile, algorithm_mask=1, data_precision=0, control_mode=0,
                   argmax_impl=0, xlen=32, qualified_precision_rows=[1, 0, 0, 0, 0, 0, 0, 0, 0])
    capability_constants(minimal)

    invalid_overrides = (
        {"control_mode": 0},  # Scalar opcodes require mode 2.
        {"control_mode": 1},
        {"algorithm_mask": 0x7b},  # Attention requires normalization.
        {"qualified_precision_rows": [7, 7, 7, 7, 2, 6, 6, 2, 6]},  # Sparse BF16.
        {"qualified_precision_rows": [7, 7, 7, 7, 0, 6, 6, 1, 6]},  # Empty enabled family.
    )
    for overrides in invalid_overrides:
        try:
            capability_constants(dict(profile, **overrides))
        except ValueError:
            continue
        raise ValueError(f"invalid build profile accepted: {overrides}")
    return values


def check_c_encoder(hds, compiler):
    layout = json.loads(read(DOCS / "descriptor_layout.json"))
    values = constants(layout)
    values.update(status_constants(hds))
    values.update(check_build_capability())
    source = r'''
#include <stdio.h>
#include "tcop_descriptor_encode.h"
#include "tcop_dma_span.h"

#define CHECK(condition) do { \
    if (!(condition)) { fprintf(stderr, "line %d: %s\n", __LINE__, #condition); return 1; } \
} while (0)

int main(void)
{
    CHECK(TCOP_BUILD_ALGORITHM_MASK == 0x7fu);
    CHECK(TCOP_BUILD_CTRL_MODE == 2 && TCOP_BUILD_XLEN == 64);
    CHECK(TCOP_BUILD_ARGMAX_IMPL == 1);
    CHECK(TCOP_BUILD_OP_005_PRECISION_MASK == (1u << TCOP_PRECISION_BF16));
    const struct {
        unsigned operation, variant, bytes, references, precision;
    } schemas[] = {
        {1, 0, 832, 7, 0}, {2, 0, 640, 4, 0}, {3, 0, 192, 1, 0},
        {4, 0, 192, 1, 1}, {4, 1, 384, 4, 2}, {5, 0, 448, 5, 1},
        {6, 0, 320, 3, 2}, {7, 0, 384, 4, 1}, {8, 0, 896, 8, 0},
        {9, 0, 512, 6, 2},
    };
    const uint32_t sample_extents[4] = {1, 2, 3, 4};
    const uint64_t sample_strides[4] = {UINT64_C(0x100000000), UINT64_C(0x200000000), 64, 2};
    const uint8_t expected_tref[64] = {
        0x88, 0x77, 0x66, 0x55, 0x44, 0x33, 0x22, 0x11,
        8, 7, 6, 5, 4, 3, 2, 1,
        [16] = 1, [20] = 2, [24] = 3, [28] = 4,
        [36] = 1, [44] = 2, [48] = 64, [56] = 2,
    };
    for (size_t i = 0; i < sizeof schemas / sizeof schemas[0]; ++i) {
        unsigned op = schemas[i].operation;
        unsigned variant = schemas[i].variant;
        unsigned size = schemas[i].bytes;
        unsigned precision = schemas[i].precision;
        unsigned ref_end = 128 + 64 * schemas[i].references;
        uint8_t buffer[904];
        uint8_t expected_buffer[904];
        const uint8_t header[64] = {
            0x54, 0x43, 0x4f, 0x50, 1, 0, 0, 0, 64, 0, op, precision,
            size & 0xff, size >> 8, 0, 0, variant,
        };
        CHECK(tcop_descriptor_schema_bytes(op, variant) == size);
        CHECK(tcop_descriptor_ref_end(op, variant) == ref_end);
        CHECK(op == 4 || tcop_descriptor_schema_bytes(op, 1) == 0);
        memset(buffer, 0xa5, sizeof buffer);
        memset(expected_buffer, 0xa5, sizeof expected_buffer);
        CHECK(!tcop_init_descriptor(buffer, size - 1, op, precision, variant));
        CHECK(memcmp(buffer, expected_buffer, sizeof buffer) == 0);
        CHECK(tcop_init_descriptor(buffer, sizeof buffer, op, precision, variant));
        memset(expected_buffer, 0, size);
        memcpy(expected_buffer, header, sizeof header);
        CHECK(tcop_validate_descriptor_header(buffer, sizeof header, op, precision, variant) == 0);
        CHECK(memcmp(buffer, expected_buffer, sizeof buffer) == 0);
        for (unsigned slot = 128; slot < ref_end; slot += 64) {
            CHECK(tcop_encode_tref(buffer, size, slot, UINT64_C(0x1122334455667788),
                                  UINT64_C(0x0102030405060708), sample_extents, sample_strides));
            memcpy(expected_buffer + slot, expected_tref, sizeof expected_tref);
        }
        CHECK(!tcop_encode_tref(buffer, size, ref_end, 0, 0, sample_extents, sample_strides));
        CHECK(memcmp(buffer, expected_buffer, sizeof buffer) == 0);
    }
    CHECK(tcop_descriptor_schema_bytes(0, 0) == 0);
    CHECK(tcop_descriptor_schema_bytes(10, 0) == 0);
    CHECK(tcop_descriptor_schema_bytes(4, 2) == 0);

    uint8_t descriptor[192];
    const uint8_t expected[192] = {
        0x54, 0x43, 0x4f, 0x50, 1, 0, 0, 0, 64, 0, 3, 0, 192, 0, 0, 0, 0,
        [129] = 0x10, [132] = 1, [136] = 64, [144] = 3, [160] = 1,
    };
    const uint32_t extent[4] = {3, 0, 0, 0};
    const uint64_t stride[4] = {1, 0, 0, 0};
    uint32_t word;
    memset(descriptor, 0xff, sizeof descriptor);
    CHECK(tcop_init_descriptor(descriptor, sizeof descriptor, 3, 0, 0));
    CHECK(tcop_encode_tref(descriptor, sizeof descriptor, TCOP_REDUCE_REF_INPUT_OFFSET,
                          UINT64_C(0x100001000), 64, extent, stride));
    CHECK(memcmp(descriptor, expected, sizeof expected) == 0);
    CHECK(tcop_encode_instruction_word(32, 3, 0, 12, 10, 11, &word) && word == 0x06b5060bu);
    CHECK(tcop_encode_instruction_word(64, 3, 0, 12, 10, 0, &word) && word == 0x0605060bu);
    CHECK(tcop_validate_descriptor_header(descriptor, 64, 3, 0, 0) == 0);
    descriptor[16] = 1;
    CHECK(tcop_validate_descriptor_header(descriptor, 64, 3, 0, 0) == 2);
    descriptor[17] = 1;
    CHECK(tcop_validate_descriptor_header(descriptor, 64, 3, 0, 0) == 1);

    uint8_t gemm[832];
    CHECK(tcop_init_descriptor(gemm, sizeof gemm, 1, 0, 0));
    CHECK(TCOP_GEMM_LUT_OFFSET == 576);
    CHECK(!tcop_encode_tref(gemm, sizeof gemm, TCOP_GEMM_LUT_OFFSET,
                           UINT64_C(0x100001000), 64, extent, stride));
    CHECK(gemm[576] == 0);

    struct tcop_dma_range range;
    const struct tcop_dma_range aperture = {UINT64_C(0xfffff000), UINT64_C(0x100000000)};
    CHECK(tcop_check_aligned_incr_burst(0xffffffe0u, 0, 5, 32, 32, aperture, &range));
    CHECK(range.start == UINT64_C(0xffffffe0) && range.end == UINT64_C(0x100000000));
    CHECK(!tcop_check_aligned_incr_burst(0xffffffe0u, 1, 5, 32, 32, aperture, &range));
    CHECK(tcop_check_addressable_dma_range(0xffffffc0u, 64, 64, 64, 32, &range));
    CHECK(tcop_dma_range_in_aperture(range, aperture));
    CHECK(!tcop_check_addressable_dma_range(0xffffffc0u, 128, 64, 64, 32, &range));
    CHECK(!tcop_check_addressable_dma_range(UINT64_MAX - 63, 64, 64, 64, 64, &range));
    CHECK(!tcop_check_dma_range(0xffffefc0u, 64, 64, 64, 32, aperture, &range));
    CHECK(range.start == UINT64_C(0xffffffc0) && range.end == UINT64_C(0x100000000));
    CHECK(tcop_check_addressable_dma_range(0xffffefc0u, 64, 64, 64, 32, &range));
    CHECK(!tcop_dma_range_in_aperture(range, aperture));
    return 0;
}
'''
    support = ROOT / "project_support/tensor_coprocessor"
    with tempfile.TemporaryDirectory(prefix="tcop-abi-") as directory:
        work = Path(directory)
        (work / "tcop_descriptor_layout.h").write_text(render(layout, values, "c"), encoding="ascii")
        (work / "fixture.c").write_text(source, encoding="ascii")
        fixture = work / "fixture.exe"
        commands = (
            [compiler, "-std=c11", "-Wall", "-Wextra", "-Werror", "-I", str(work),
             "-I", str(support), str(work / "fixture.c"), "-o", str(fixture)],
            [str(fixture)],
        )
        for command in commands:
            result = subprocess.run(command, capture_output=True, text=True, cwd=work)
            if result.returncode:
                raise ValueError(f"C ABI fixture failed: {result.stderr.strip()}")


def check_sv_package(hds, compiler):
    layout = json.loads(read(DOCS / "descriptor_layout.json"))
    values = constants(layout)
    values.update(status_constants(hds))
    values.update(check_build_capability())
    checks = [
        '    if (TCOP_HEADER_BYTES !== 64 || TCOP_HEADER_IMPLEMENTATION_VARIANT_OFFSET !== 16)',
        '      $fatal(1, "common header extent or variant byte changed");',
        '    if (tcop_descriptor_ref_end(1, 0) !== 576 || TCOP_GEMM_LUT_OFFSET !== 576)',
        '      $fatal(1, "GEMM TREF/LUT boundary changed");',
        '    if (TCOP_LINEAR_ATTENTION_REF_STATE_OUTPUT_OFFSET !== 448 ||',
        '        TCOP_TLAS_PROCESSED_TOKEN_COUNT_OFFSET !== 24 || TCOP_TLAS_PAYLOAD_OFFSET !== 64)',
        '      $fatal(1, "OP-009 state checkpoint offsets changed");',
        '    if (TCOP_ERR_DESCRIPTOR_FORMAT !== 1 || TCOP_ERR_DESCRIPTOR_MODE !== 2)',
        '      $fatal(1, "descriptor error ABI changed");',
        '    if (TCOP_BUILD_OP_005_PRECISION_MASK !== 2 || TCOP_BUILD_ARGMAX_IMPL !== 1)',
        '      $fatal(1, "qualified build capability mismatch");',
    ]
    # Fixed ISA schema sizes also exercise the compiled package lookup functions.
    sizes = (0, 832, 640, 192, 192, 448, 320, 384, 896, 512)
    for op, size in enumerate(sizes):
        checks.append(f'    if (tcop_descriptor_schema_bytes({op}, 0) !== {size}) '
                      f'$fatal(1, "schema size for OP-{op:03d}");')
        checks.append(f'    if (tcop_descriptor_schema_bytes({op}, 1) !== {384 if op == 4 else 0}) '
                      f'$fatal(1, "schema variant for OP-{op:03d}");')
    for name, expected in values.items():
        checks.append(f'    if (TCOP_{name} !== 32\'d{expected}) $fatal(1, "TCOP_{name}");')
    source = "\n".join([
        "module check_tcop_sv_abi;",
        "  import tcop_descriptor_layout_pkg::*;",
        "  initial begin",
        *checks,
        '    $display("PASS SystemVerilog ABI package");',
        "    $finish;",
        "  end",
        "endmodule",
    ])

    verilator = Path(shutil.which(compiler) or compiler).resolve(strict=True)
    cxx = shutil.which("g++")
    if cxx is None:
        raise ValueError("g++ must be on PATH for the SystemVerilog ABI fixture")
    env = os.environ.copy()
    toolbox = verilator.parent.parent
    root = Path(env.get("VERILATOR_ROOT", toolbox / "share/verilator"))
    include = root / "include"
    env["VERILATOR_ROOT"] = str(root)
    env["PATH"] = os.pathsep.join((str(verilator.parent), str(toolbox / "lib"), env.get("PATH", "")))

    def run(command, work):
        result = subprocess.run(command, stdin=subprocess.DEVNULL, capture_output=True, text=True,
                                cwd=work, env=env, timeout=60)
        if result.returncode:
            raise ValueError(f"SystemVerilog ABI fixture failed in {Path(command[0]).name} ({result.returncode}): "
                             f"{result.stdout.strip()} {result.stderr.strip()}")
        return result.stdout

    with tempfile.TemporaryDirectory(prefix=".tcop-sv-", dir=ROOT) as directory:
        work = Path(directory)
        package = work / "layout.sv"
        fixture = work / "fixture.sv"
        obj = work / "obj"
        binary = work / "fixture.exe"
        package.write_text(render(layout, values, "sv"), encoding="ascii")
        fixture.write_text(source, encoding="ascii")
        run([str(verilator), "--cc", "--main", "--timing", "--top-module", "check_tcop_sv_abi",
             "--Mdir", str(obj), str(package), str(fixture)], work)
        runtime = [include / name for name in ("verilated.cpp", "verilated_threads.cpp", "verilated_timing.cpp")]
        sources = sorted(obj.glob("*.cpp")) + runtime
        run([cxx, "-std=c++20", "-O0", "-DVL_TIME_CONTEXT", "-I", str(obj), "-I", str(include),
             "-I", str(include / "vltstd"), *map(str, sources), "-o", str(binary)], work)
        if "PASS SystemVerilog ABI package" not in run([str(binary)], work):
            raise ValueError("SystemVerilog ABI fixture did not report completion")
    return len(values)


def check_numerical_references():
    sys.path.insert(0, str(ROOT / "project_support/tensor_coprocessor"))
    from tcop_argmax_reference import argmax_result, exact_top_two, fp_top_two, project_fp32
    from tcop_attention_reference import attention_row
    from tcop_elementwise_reference import fp_elementwise, int8_elementwise
    from tcop_gemm_reference import fp_gemm_dot
    from tcop_layernorm_reference import _row_statistics
    from tcop_linear_attention_reference import linear_attention_sample
    from tcop_reduce_reference import reduce_result
    from tcop_requant_reference import Requant8, fused_argmax_index
    from tcop_softmax_reference import softmax_row
    from tcop_sparse_reference import sparse_dot

    count = 0

    def compare(label, actual, expected):
        nonlocal count
        if actual != expected:
            raise ValueError(f"{label}: got {actual!r}, expected {expected!r}")
        count += 1

    ok = "TC_STATUS_OK"
    one_bf16 = 0x3F80
    one_fp32 = 0x3F800000
    compare("TEST-003 OP-001 ordered K", fp_gemm_dot(
        [0x4E80, one_bf16, 0xCE80], [one_bf16] * 3, "bf16"), (0, ok))
    compare("TEST-003 OP-001 output overflow", fp_gemm_dot(
        [0x7BFF], [0x4000], "fp16"), (None, "TC_ERR_NUMERIC_NONFINITE"))
    # 2 * F overflows binary32 on its own, but the fused sum -F + 2 * F is F.
    largest_bf16, minus_largest_bf16 = 0x7F7F, 0xFF7F
    activation = [one_bf16, 0x4000]
    finite_weights = [minus_largest_bf16, largest_bf16]
    compare("TEST-003 OP-001 product overflow avoided by FMA", fp_gemm_dot(
        activation, finite_weights, "bf16"), (largest_bf16, ok))
    compare("TEST-003 OP-001 addends ordered C, bias, residual", fp_gemm_dot(
        [0], [one_bf16], "bf16", initial_c=0x4E80, bias=0xCE80, residual=one_bf16),
        (one_bf16, ok))
    compare("TEST-003 OP-001 BF16 gradual underflow", fp_gemm_dot(
        [0x0001], [0x3F40], "bf16"), (0x0001, ok))
    compare("TEST-003 OP-001 FP16 negative halfway to zero", fp_gemm_dot(
        [0x8001], [0x3800], "fp16"), (0x8000, ok))
    compare("TEST-038 OP-002 saturated INT8 ADD", int8_elementwise("add", 127, rhs=127), 127)
    compare("TEST-038 OP-002 generated SwiGLU NaN", fp_elementwise(
        "swiglu", 0xFC00, "fp16", rhs=0x7C00), 0x7E00)
    compare("TEST-039 OP-003 fixed sum tree", reduce_result(
        [0x4E80, one_bf16, 0xCE80, one_bf16], "bf16", "sum", 32), (0, ok))
    compare("TEST-039 OP-003 negative zero writeback", reduce_result(
        [0x8000], "bf16", "max", 64), (0x8000, ok))
    for xlen in (32, 64):
        compare(f"TEST-039 OP-003 RV{xlen} signed INT8 result", reduce_result(
            [0xFE], "int8", "sum", xlen), ((1 << xlen) - 2, ok))
    compare("TEST-020 OP-004 tie at +Inf", argmax_result(
        "bf16", 64, logits=[0xFF80, 0x7F80, 0x7F80]), (1, ok))
    compare("TEST-020 OP-004 top-two +Inf tie", fp_top_two(
        [0xFF80, 0x7F80, 0x7F80], "bf16"), (1, 2, None, "positive_infinity_tie"))
    compare("TEST-020 OP-004 top-two signed-zero tie", fp_top_two(
        iter([0x8000, 0]), "fp16"), (0, 1, 0, "finite"))
    compare("TEST-020 OP-004 top-two one eligible token", fp_top_two(
        [0xFF80, 0x3F80], "bf16"), (1, None, None, "single"))
    compare("TEST-020 OP-004 top-two unusable scores", (
        fp_top_two([0xFF80], "bf16"), fp_top_two([0x3F80, 0x7FC0], "bf16")
    ), ((None, None, None, "no_valid"), (None, None, None, "nan")))
    compare("TEST-020 OP-004 FP32 top-two margin in score units", fp_top_two(
        project_fp32([0x3F80], [[0x3F80, 0x3FC0]], "bf16"), "fp32"),
        (1, 0, 0.5, "finite"))
    # OP-004 stores a matrix with input feature first and vocabulary channel second.
    weights_by_feature = [[minus_largest_bf16, 0x7F80], [largest_bf16, one_bf16]]
    compare("TEST-020 OP-004 FMA prevents a false infinity tie", argmax_result(
        "bf16", 64, activation=activation, weights=weights_by_feature), (1, ok))
    coefficient = Requant8(0x40000000, -1)
    accumulators = (509, 511)
    logits = [coefficient.requantize(accumulator) for accumulator in accumulators]
    compare("TEST-020 OP-004 materialized and pre-narrow INT8 margins", (
        exact_top_two(logits),
        exact_top_two(coefficient.score(accumulator) for accumulator in accumulators),
    ), ((0, 1, 0, "finite"), (1, 0, 0.5, "finite")))
    compare("TEST-020 OP-004 INT8 pre-narrow versus materialized logits", (
        fused_argmax_index((accumulator, coefficient) for accumulator in accumulators),
        logits,
        max(range(len(logits)), key=logits.__getitem__),
    ), (1, [127, 127], 0))
    for width in (32, 48, 64):
        magnitudes = (1 << (width - 1), (1 << (width - 1)) - 1, 65_536, 2, 1)
        scores = []
        for accumulator in (-magnitudes[0], *(-n for n in magnitudes[1:]), 0, *magnitudes[1:]):
            for multiplier, exponent in ((0x40000000, -31), (0x40000000, -1),
                                         (0x40000000, 0), (0x7fffffff, 31)):
                scale = Requant8(multiplier, exponent)
                product = abs(accumulator) * multiplier
                if product == 0:
                    key = (1, 0, 0)
                else:
                    leading = product.bit_length() - 1
                    adjusted = leading + exponent - 31
                    normalized = product << (width + 31 - leading)
                    if not -128 <= adjusted <= 127 or normalized.bit_length() != width + 32:
                        raise ValueError(f"TEST-020: normalized fields overflow at width {width}")
                    key = (0, -adjusted, -normalized) if accumulator < 0 else (2, adjusted, normalized)
                scores.append((scale.score(accumulator), key))
        for exact_a, key_a in scores:
            for exact_b, key_b in scores:
                if (exact_a > exact_b, exact_a == exact_b) != (key_a > key_b, key_a == key_b):
                    raise ValueError(f"TEST-020: normalized score order differs at width {width}")
        compare(f"TEST-020 OP-004 normalized compare at W={width}",
                max(range(len(scores)), key=lambda index: scores[index][1]),
                max(range(len(scores)), key=lambda index: scores[index][0]))
    for xlen in (32, 64):
        compare(f"TEST-020 OP-004 RV{xlen} invalid token sentinel", argmax_result(
            "bf16", xlen, logits=[0xFF80]), ((1 << xlen) - 1, "TC_ERR_ARGMAX_NO_VALID_LOGIT"))

    keys = [[0xC120], [0xC1A0], [0]]  # -10, -20, 0
    values = [[0], [0x4E80], [0]]    # 0, 2**30, 0
    for tile, expected in ((1, 0x400E), (2, 0x400E), (3, 0)):
        compare(f"TEST-040 OP-005 online cutoff at Tk={tile}", attention_row(
            [one_bf16], keys, values, "bf16", one_fp32, tile), ([expected], ok))
    compare("TEST-040 OP-005 ordered QK FMA avoids product overflow", attention_row(
        activation, [finite_weights], [[one_bf16]], "bf16", one_fp32, 1), ([one_bf16], ok))
    compare("TEST-040 OP-005 empty masked tile before first valid tile", attention_row(
        [one_bf16], [[0x7FC0], [0]], [[0x7F80], [one_bf16]], "bf16", one_fp32, 1,
        mask=b"\x00\x01"), ([one_bf16], ok))
    compare("TEST-040 OP-005 all masked skips invalid operands", attention_row(
        [0x7FC0], [[0x7F80]], [[0x7FC0]], "bf16", one_fp32, 1, mask=b"\x00"),
        (None, "TC_ERR_NO_VALID_ATTENTION_ROW"))
    compare("TEST-040 OP-005 valid V is classified at zero probability", attention_row(
        [one_bf16], [[0xC188], [0]], [[0x7F80], [one_bf16]], "bf16", one_fp32, 2),
        (None, "TC_ERR_NUMERIC_NONFINITE"))
    compare("TEST-041 OP-006 finite subtraction overflow", softmax_row(
        [0x7F7F, 0xFF7F], "bf16"), ([one_bf16, 0], ok))
    compare("TEST-041 OP-006 masked NaN and infinity", softmax_row(
        [one_bf16, 0x7FC0, 0x7F80], "bf16", bytes([7, 0, 0])), ([one_bf16, 0, 0], ok))
    compare("TEST-042 OP-007 correctly rounded variance", _row_statistics(
        [0xC1000000, 0xC1000000, 0xC0E00000])[1:], (0x3F2AAAAB, 0x3E638E39))
    compare("TEST-044 OP-008 positive 17-bit sparse sum", sparse_dot(
        [-128] * 4, b"\x04", b"\x80\x80", 1, 0), 32_768)

    zeros = [[[0]]]
    ones = [[[one_bf16]]]
    context, checkpoint, status = linear_attention_sample(zeros, zeros, ones, "bf16")
    compare("TEST-043 OP-009 RESET", (context, status), (ones, ok))
    compare("TEST-043 OP-009 TLAS header and payload",
            (checkpoint[:4], unpack_from("<QI", checkpoint, 24), checkpoint[64:]),
            (b"TLAS", (1, 8), pack("<II", one_fp32, one_fp32)))
    last, resumed, status = linear_attention_sample(zeros, zeros, ones, "bf16", checkpoint)
    full, final, full_status = linear_attention_sample([[[0], [0]]], [[[0], [0]]],
                                                       [[[one_bf16], [one_bf16]]], "bf16")
    compare("TEST-043 OP-009 CONTINUE", (context[0] + last[0], resumed, status, full_status),
            (full[0], final, ok, ok))
    # phi(-17) is zero, so CONTINUE uses the checkpoint's S/z without an update.
    cutoff_key = [[[0xC188]]]
    just_below_minimum = checkpoint[:64] + pack("<II", 0x007FFFFF, 0x007FFFFF)
    at_minimum = checkpoint[:64] + pack("<II", 0x00800000, 0x00800000)
    compare("TEST-043 OP-009 denominator below 2**-126", linear_attention_sample(
        zeros, cutoff_key, zeros, "bf16", just_below_minimum),
        (None, None, "TC_ERR_LINEAR_ZERO_DENOM"))
    boundary_output, boundary_checkpoint, boundary_status = linear_attention_sample(
        zeros, cutoff_key, zeros, "bf16", at_minimum)
    compare("TEST-043 OP-009 denominator exactly 2**-126",
            (boundary_output, boundary_status, unpack_from("<Q", boundary_checkpoint, 24),
             boundary_checkpoint[64:]), (ones, ok, (2,), at_minimum[64:]))
    max_count = checkpoint[:24] + pack("<Q", (1 << 64) - 1) + checkpoint[32:]
    compare("TEST-043 OP-009 checkpoint token count overflow", linear_attention_sample(
        zeros, zeros, ones, "bf16", max_count), (None, None, "TC_ERR_LINEAR_STATE"))
    return count


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cc", help="also check ABI examples using a native GCC-compatible C compiler")
    parser.add_argument("--verilator", help="also compile and run the ABI package with Verilator and g++")
    args = parser.parse_args()
    hds = read(HDS)
    print(f"PASS local navigation: {check_navigation()} targets")
    if not LOCAL_ARM.exists():
        print("SKIP local Arm conversion: licensed artifact not installed")
    print(f"PASS figure sources: {check_figures(hds)} embedded definitions")
    requirements, cases = check_test_traceability(hds)
    print(f"PASS test traceability: {requirements} requirements and {cases} test links")
    print(f"PASS waveform ordering: {check_waveform_ordering()} illustrative sequences")
    print(f"PASS CSR model: {check_csr()} register maps")
    schemas, values, fields = check_abi(hds)
    print(f"PASS ABI: {schemas} descriptor schemas, {fields} body offsets and {values} constants")
    check_build_capability()
    print("PASS build capability validation: mode, family dependencies and precision subsets")
    print(f"PASS numerical references: {check_numerical_references()} directed vectors")
    if args.cc:
        check_c_encoder(hds, args.cc)
        print("PASS native C ABI fixture: 10 schema headers/TREF spans, OP-003 bytes, error priority and AXI edge")
    if args.verilator:
        print(f"PASS SystemVerilog ABI package: {check_sv_package(hds, args.verilator)} constants and lookups")


if __name__ == "__main__":
    try:
        main()
    except (KeyError, OSError, ValueError, subprocess.SubprocessError) as error:
        raise SystemExit(f"FAIL: {error}") from None
