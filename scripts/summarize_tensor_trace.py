"""Summarize tensor product and CV-X-IF timestamps in a common nanosecond domain."""

import argparse
import json
from collections import Counter
from decimal import Decimal
from fractions import Fraction
from pathlib import Path


def percentiles(samples):
    ordered = sorted(samples)
    summary = {"count": len(ordered)}
    for percentile in (50, 95, 99):
        rank = (percentile * len(ordered) + 99) // 100
        summary[f"p{percentile}"] = ordered[rank - 1] if rank else None
    return summary


def timestamp_ns(value):
    if type(value) is int and value >= 0:
        return value
    if isinstance(value, Decimal) and value.is_finite() and value >= 0:
        return Fraction(value)
    raise ValueError("timestamps must be finite nonnegative numbers in nanoseconds")


def timestamps(record, *keys):
    values = [timestamp_ns(record[key]) for key in keys]
    if values != sorted(values):
        raise ValueError(f"{keys} are out of order")
    return values


def rate(elements, duration_ns):
    return elements * 1e9 / duration_ns if duration_ns else None


def summarize_array_window(window):
    kind = window["kind"]
    if kind not in ("steady_service", "workload"):
        raise ValueError(f"invalid array window kind: {kind}")
    mode = window["mode"]
    slots_per_update = {"dense_int8": 1, "sparse_2of4_int8": 2}
    if mode not in slots_per_update:
        raise ValueError(f"invalid array window mode: {mode}")
    arrays = window["arrays"]
    rows = window["pe_rows"]
    cols = window["pe_cols"]
    cycles = window["core_cycles"]
    clock_hz = window["clock_hz"]
    if any(type(value) is not int or value <= 0
           for value in (arrays, rows, cols, cycles, clock_hz)):
        raise ValueError("array geometry, cycles and clock_hz must be positive integers")
    available = arrays * rows * cols * cycles
    assigned = window["assigned_pe_cycles"]
    updates = window["committed_pe_updates"]
    if (type(assigned) is not int or type(updates) is not int or
            not 0 <= updates <= assigned <= available):
        raise ValueError("expected committed updates <= assigned PE cycles <= available PE cycles")
    products = updates * slots_per_update[mode]
    return {
        "kind": kind,
        "mode": mode,
        "available_pe_cycles": available,
        "assigned_pe_cycles": assigned,
        "committed_pe_updates": updates,
        "assigned_utilization": assigned / available,
        "issue_efficiency": updates / assigned if assigned else None,
        "total_utilization": updates / available,
        "executed_product_slots": products,
        "committed_pe_updates_per_cycle": updates / cycles,
        "executed_product_slots_per_second": products * clock_hz / cycles,
    }


def summarize(trace):
    requests = []
    incomplete_requests = []
    request_outcomes = Counter()
    ttft, inter_token = [], []
    prompt_windows, decode_windows = [], []
    seen_requests = set()
    for request in trace.get("requests", []):
        ident = request["id"]
        if ident in seen_requests:
            raise ValueError(f"duplicate request id: {ident}")
        seen_requests.add(ident)
        outcome = request.get("outcome", "success")
        if outcome not in {"success", "error", "reset", "truncated"}:
            raise ValueError(f"invalid request outcome: {outcome}")
        request_outcomes[outcome] += 1
        accepted = timestamp_ns(request["request_ns"])
        prompt = request["prompt_tokens"]
        tokens = [timestamp_ns(value) for value in request.get("token_ns", [])]
        if type(prompt) is not int or prompt < 1:
            raise ValueError("prompt_tokens must be a positive integer")
        prefill = None
        if "prefill_done_ns" in request:
            _, prefill = timestamps(request, "request_ns", "prefill_done_ns")
        if tokens and (prefill is None or tokens[0] < prefill or tokens != sorted(tokens)):
            raise ValueError("token_ns must contain ordered delivery times after prefill")
        if outcome != "success":
            incomplete_requests.append({
                "id": ident,
                "outcome": outcome,
                "reason": request.get("reason"),
                "prompt_tokens": prompt,
                "delivered_tokens": len(tokens),
            })
            continue
        if not tokens:
            raise ValueError("successful request requires at least one delivered token")
        request_ttft = tokens[0] - accepted
        ttft.append(request_ttft)
        gaps = [right - left for left, right in zip(tokens, tokens[1:])]
        inter_token.extend(gaps)
        prompt_windows.append((accepted, prefill))
        if gaps:
            decode_windows.append((tokens[0], tokens[-1]))
        requests.append({
            "id": ident,
            "prompt_tokens": prompt,
            "generated_tokens": len(tokens),
            "prefill_tokens_per_second": rate(prompt, prefill - accepted),
            "ttft_ns": request_ttft,
            "inter_token_ns": gaps,
            "decode_tokens_per_second": rate(len(gaps), tokens[-1] - tokens[0]),
        })

    intervals = {
        "accept_to_commit_ns": [],
        "commit_to_result_valid_ns": [],
        "commit_to_dispatch_ns": [],
        "dispatch_to_result_valid_ns": [],
        "commit_to_descriptor_ar_ns": [],
        "commit_to_descriptor_ar_offer_ns": [],
        "descriptor_ar_offer_to_handshake_ns": [],
        "commit_to_descriptor_ready_ns": [],
        "dispatch_and_descriptor_ready_to_numeric_offer_ns": [],
        "descriptor_exposed_wait_ns": [],
        "descriptor_ready_before_dispatch_ns": [],
        "result_hold_ns": [],
        "accept_to_result_fire_ns": [],
        "csr_error_visible_to_clear_ns": [],
        "csr_core_clear_to_host_reconciled_ns": [],
        "csr_error_visible_to_id_reusable_ns": [],
        "csr_retire_to_id_reusable_ns": [],
    }
    by_outcome = {outcome: {name: [] for name in intervals}
                  for outcome in ("success", "error")}
    outcomes = Counter()
    seen_commands = set()
    pending_csr_clears = 0
    kill_delays = []
    for command in trace.get("commands", []):
        ident = command["id"]
        if ident in seen_commands:
            raise ValueError(f"duplicate command generation id: {ident}")
        seen_commands.add(ident)
        outcome = command["outcome"]
        if outcome not in {"success", "error", "killed", "reset"}:
            raise ValueError(f"invalid command outcome: {outcome}")
        csr_fields = {"error_visible_ns", "w1c_core_ns", "w1c_host_ns",
                      "id_reusable_ns"} & command.keys()
        if csr_fields and outcome != "error":
            raise ValueError("CSR recovery timestamps require a completed error command")
        if "w1c_core_ns" in csr_fields and "error_visible_ns" not in csr_fields:
            raise ValueError("W1C timestamp requires error_visible_ns")
        if "w1c_host_ns" in csr_fields and "w1c_core_ns" not in csr_fields:
            raise ValueError("host reconciliation timestamp requires w1c_core_ns")
        if "id_reusable_ns" in csr_fields and (
            "w1c_host_ns" not in csr_fields or "retire_ns" not in command
        ):
            raise ValueError("ID reuse timestamp requires w1c_host_ns and retire_ns")
        if "retire_ns" in command and outcome not in {"success", "error"}:
            raise ValueError("retirement timestamp requires a completed command")
        if "kill_ns" in command and outcome != "killed":
            raise ValueError("kill timestamp requires a killed command")
        if "commit_ns" in command:
            accepted, committed = timestamps(command, "accept_ns", "commit_ns")
            if accepted == committed:
                raise ValueError("tensor safe commit must follow the issue-acceptance edge")
        descriptor_events = [key for key in ("descriptor_ar_offer_ns", "descriptor_ar_ns",
                                               "descriptor_ready_ns") if key in command]
        if descriptor_events:
            if outcome == "killed" or "commit_ns" not in command:
                raise ValueError("descriptor activity requires a matching non-kill commit")
            sequence = ["commit_ns", *descriptor_events]
            if "result_valid_ns" in command:
                sequence.append("result_valid_ns")
            times = timestamps(command, *sequence)
            if times[0] == times[1]:
                raise ValueError("descriptor activity must follow the safe-commit edge")
            descriptor = dict(zip(sequence, times))
        if "first_numeric_dma_offer_ns" in command:
            if not {"descriptor_ready_ns", "dispatch_ns"} <= command.keys():
                raise ValueError("numeric DMA requires descriptor validation and dispatch")
            _, dispatch = timestamps(command, "commit_ns", "dispatch_ns")
            numeric = timestamp_ns(command["first_numeric_dma_offer_ns"])
            prerequisites = max(dispatch, descriptor["descriptor_ready_ns"])
            if numeric < prerequisites:
                raise ValueError("numeric DMA offered before descriptor validation or dispatch")
            if "result_valid_ns" in command:
                timestamps(command, "first_numeric_dma_offer_ns", "result_valid_ns")
        outcomes[outcome] += 1
        if outcome == "killed":
            accepted = timestamp_ns(command["accept_ns"])
            if {"commit_ns", "dispatch_ns", "result_valid_ns", "result_fire_ns"} & command.keys():
                raise ValueError("killed command cannot report commit, dispatch or result timestamps")
            if "kill_ns" in command:
                _, killed = timestamps(command, "accept_ns", "kill_ns")
                if killed == accepted:
                    raise ValueError("affected issue must be suppressed on the kill edge")
                kill_delays.append(killed - accepted)
            continue
        if outcome == "reset":
            if "result_fire_ns" in command:
                raise ValueError("reset-abandoned command cannot have a result handshake")
            keys = ["accept_ns"]
            if {"commit_ns", "dispatch_ns", "result_valid_ns"} & command.keys():
                keys.append("commit_ns")
            if "dispatch_ns" in command:
                keys.append("dispatch_ns")
            if "result_valid_ns" in command:
                keys.append("result_valid_ns")
            timestamps(command, *keys)
            continue
        accept, commit, valid, fire = timestamps(
            command, "accept_ns", "commit_ns", "result_valid_ns", "result_fire_ns"
        )
        if "retire_ns" in command:
            _, retired = timestamps(command, "result_fire_ns", "retire_ns")
        samples = {
            "accept_to_commit_ns": commit - accept,
            "commit_to_result_valid_ns": valid - commit,
            "result_hold_ns": fire - valid,
            "accept_to_result_fire_ns": fire - accept,
        }
        if "descriptor_ar_ns" in command:
            samples["commit_to_descriptor_ar_ns"] = descriptor["descriptor_ar_ns"] - commit
        if "descriptor_ar_offer_ns" in command:
            offer = descriptor["descriptor_ar_offer_ns"]
            samples["commit_to_descriptor_ar_offer_ns"] = offer - commit
            if "descriptor_ar_ns" in command:
                samples["descriptor_ar_offer_to_handshake_ns"] = descriptor["descriptor_ar_ns"] - offer
        if "first_numeric_dma_offer_ns" in command:
            samples["dispatch_and_descriptor_ready_to_numeric_offer_ns"] = numeric - prerequisites
        if "dispatch_ns" in command:
            _, dispatch, _ = timestamps(command, "commit_ns", "dispatch_ns", "result_valid_ns")
            samples["commit_to_dispatch_ns"] = dispatch - commit
            samples["dispatch_to_result_valid_ns"] = valid - dispatch
        if "descriptor_ready_ns" in command:
            _, ready, _ = timestamps(command, "commit_ns", "descriptor_ready_ns",
                                      "result_valid_ns")
            samples["commit_to_descriptor_ready_ns"] = ready - commit
            if "dispatch_ns" in command:
                samples["descriptor_exposed_wait_ns"] = max(0, ready - dispatch)
                samples["descriptor_ready_before_dispatch_ns"] = max(0, dispatch - ready)
        if "error_visible_ns" in csr_fields:
            _, visible, _ = timestamps(command, "commit_ns", "error_visible_ns", "result_valid_ns")
            if "w1c_core_ns" in csr_fields:
                _, cleared = timestamps(command, "error_visible_ns", "w1c_core_ns")
                samples["csr_error_visible_to_clear_ns"] = cleared - visible
            else:
                pending_csr_clears += 1
        if "w1c_host_ns" in csr_fields:
            cleared, reconciled = timestamps(command, "w1c_core_ns", "w1c_host_ns")
            samples["csr_core_clear_to_host_reconciled_ns"] = reconciled - cleared
        if "id_reusable_ns" in csr_fields:
            reusable = timestamp_ns(command["id_reusable_ns"])
            if reusable < max(retired, reconciled):
                raise ValueError("ID reuse precedes retirement or host clear reconciliation")
            samples["csr_error_visible_to_id_reusable_ns"] = reusable - visible
            samples["csr_retire_to_id_reusable_ns"] = reusable - retired
        for name, value in samples.items():
            intervals[name].append(value)
            by_outcome[outcome][name].append(value)

    handler_delays = []
    handler_outcomes = Counter()
    prefix_retirement_delays = []
    retirement_to_entry_delays = []
    handler_first_issue_delays = []
    for event in trace.get("handler_events", []):
        outcome = event.get("outcome", "entered")
        if outcome not in {"entered", "reset", "pending"}:
            raise ValueError(f"invalid handler event outcome: {outcome}")
        handler_outcomes[outcome] += 1
        if outcome != "entered":
            timestamp_ns(event["event_ns"])
            if {"handler_ns", "first_handler_issue_ns"} & event.keys():
                raise ValueError("handler entry/issue timestamp requires an entered event")
            continue
        selected, entered = timestamps(event, "event_ns", "handler_ns")
        handler_delays.append(entered - selected)
        if "last_authorized_retire_ns" in event:
            _, retired, _ = timestamps(event, "event_ns", "last_authorized_retire_ns", "handler_ns")
            prefix_retirement_delays.append(retired - selected)
            retirement_to_entry_delays.append(entered - retired)
        if "first_handler_issue_ns" in event:
            _, first_issue = timestamps(event, "handler_ns", "first_handler_issue_ns")
            handler_first_issue_delays.append(first_issue - entered)

    summary = {
        "profile": trace["profile"],
        "percentile_method": "nearest rank",
        "requests": requests,
        "request_outcomes": dict(request_outcomes),
        "incomplete_requests": incomplete_requests,
        "incomplete_delivered_tokens": sum(row["delivered_tokens"] for row in incomplete_requests),
        "prompt_tokens": sum(row["prompt_tokens"] for row in requests),
        "generated_tokens": sum(row["generated_tokens"] for row in requests),
        "ttft_ns": percentiles(ttft),
        "inter_token_ns": percentiles(inter_token),
        "command_outcomes": dict(outcomes),
        "accept_to_kill_ns": percentiles(kill_delays),
        "cvxif": {name: percentiles(values) for name, values in intervals.items()},
        "cvxif_by_outcome": {
            outcome: {name: percentiles(values) for name, values in metrics.items()}
            for outcome, metrics in by_outcome.items()
        },
        "csr_errors_visible_without_clear": pending_csr_clears,
        "handler_event_outcomes": dict(handler_outcomes),
        "event_to_handler_ns": percentiles(handler_delays),
        "event_to_authorized_prefix_retire_ns": percentiles(prefix_retirement_delays),
        "authorized_prefix_retire_to_handler_ns": percentiles(retirement_to_entry_delays),
        "handler_to_first_issue_ns": percentiles(handler_first_issue_delays),
    }
    if prompt_windows:
        prefill_begin = min(start for start, _ in prompt_windows)
        prefill_end = max(end for _, end in prompt_windows)
        cohort = {
            "request_count": len(requests),
            "prefill_begin_ns": prefill_begin,
            "prefill_end_ns": prefill_end,
            "prefill_tokens_per_second": rate(summary["prompt_tokens"], prefill_end - prefill_begin),
            "decode_request_count": len(decode_windows),
            "decode_tokens_after_first": len(inter_token),
            "decode_begin_ns": None,
            "decode_end_ns": None,
            "decode_tokens_per_second": None,
        }
        if decode_windows:
            decode_begin = min(start for start, _ in decode_windows)
            decode_end = max(end for _, end in decode_windows)
            cohort.update(
                decode_begin_ns=decode_begin,
                decode_end_ns=decode_end,
                decode_tokens_per_second=rate(len(inter_token), decode_end - decode_begin),
            )
        summary["request_cohort"] = cohort
    if "array_windows" in trace:
        summary["array_windows"] = [summarize_array_window(window)
                                    for window in trace["array_windows"]]
    return summary


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("trace", type=Path, help="JSON trace for one workload profile")
    args = parser.parse_args()
    try:
        trace = json.loads(args.trace.read_text(encoding="utf-8"), parse_float=Decimal)
        print(json.dumps(summarize(trace), indent=2, default=float, allow_nan=False))
    except (KeyError, OSError, TypeError, ValueError) as error:
        parser.exit(1, f"invalid trace: {error}\n")


if __name__ == "__main__":
    main()
