#!/usr/bin/env python3
"""Run one tool command while enforcing the approved host-memory floor."""
from __future__ import annotations

import ctypes
import json
import os
import shutil
import subprocess
import time
from pathlib import Path


class _MemoryStatusEx(ctypes.Structure):
    _fields_ = [
        ("dwLength", ctypes.c_ulong),
        ("dwMemoryLoad", ctypes.c_ulong),
        ("ullTotalPhys", ctypes.c_ulonglong),
        ("ullAvailPhys", ctypes.c_ulonglong),
        ("ullTotalPageFile", ctypes.c_ulonglong),
        ("ullAvailPageFile", ctypes.c_ulonglong),
        ("ullTotalVirtual", ctypes.c_ulonglong),
        ("ullAvailVirtual", ctypes.c_ulonglong),
        ("ullAvailExtendedVirtual", ctypes.c_ulonglong),
    ]


def _ram() -> dict[str, int]:
    if os.name != "nt":
        raise RuntimeError("resource guard requires Windows GlobalMemoryStatusEx")
    value = _MemoryStatusEx()
    value.dwLength = ctypes.sizeof(value)
    if not ctypes.windll.kernel32.GlobalMemoryStatusEx(ctypes.byref(value)):
        raise OSError("GlobalMemoryStatusEx failed")
    return {"available_bytes": int(value.ullAvailPhys), "total_bytes": int(value.ullTotalPhys),
            "load_percent": int(value.dwMemoryLoad)}


def _write_usage(path: Path, document: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temp = path.with_suffix(".tmp")
    temp.write_text(json.dumps(document, indent=2) + "\n", encoding="utf-8")
    temp.replace(path)


def run_logged(argv: list[str], cwd: Path, env: dict[str, str], log: Path,
               timeout: int) -> None:
    """Run one tool command with an early RAM-drop budget and hard host floors."""
    log.parent.mkdir(parents=True, exist_ok=True)
    run_root = Path(env.get("VLSIT_RUN_ROOT", str(log.parent))).resolve()
    usage_path = run_root / "resource_usage.json"
    floor = int(env.get("VLSIT_MIN_FREE_RAM_BYTES", str(1 << 30)))
    disk_floor = int(env.get("VLSIT_MIN_FREE_DISK_BYTES", str(2 << 30)))
    max_ram_drop = int(env.get("VLSIT_MAX_RAM_DROP_BYTES", str(1040 << 20)))
    guard_margin = int(env.get("VLSIT_RAM_GUARD_MARGIN_BYTES", str(128 << 20)))
    poll_interval = max(0.05, int(env.get("VLSIT_RAM_POLL_INTERVAL_MS", "100")) / 1000)
    if usage_path.is_file():
        usage = json.loads(usage_path.read_text(encoding="utf-8"))
    else:
        usage = {"schema_version": 2, "commands": [], "minimum_available_bytes": None,
                 "initial_available_bytes": None}
    before = _ram()
    if usage.get("initial_available_bytes") is None:
        usage["initial_available_bytes"] = before["available_bytes"]
    run_initial = int(usage["initial_available_bytes"])
    # The drop target is deliberately stricter than the previously approved
    # 1 GiB reserve. It limits peak run-induced RAM consumption independently
    # of the machine's current free-memory level.
    minimum_start = floor + guard_margin + max_ram_drop
    early_floor = max(floor + guard_margin, run_initial - max_ram_drop)
    disk_before = shutil.disk_usage(run_root).free
    samples = [{"elapsed_s": 0.0, **before, "disk_free_bytes": disk_before}]
    record = {"command": argv, "log": str(log), "start_ns": time.time_ns(),
              "start_available_bytes": before["available_bytes"],
              "run_initial_available_bytes": run_initial,
              "early_stop_available_bytes": early_floor,
              "minimum_start_available_bytes": minimum_start,
              "max_ram_drop_bytes": max_ram_drop,
              "ram_guard_margin_bytes": guard_margin, "ram_floor_bytes": floor,
              "disk_floor_bytes": disk_floor, "samples": samples,
              "status": "running"}
    usage["commands"].append(record)

    def write_status(status: str, reason: str | None = None) -> None:
        mins = [x.get("minimum_available_bytes") for x in usage["commands"]
                if x.get("minimum_available_bytes") is not None]
        disk_mins = [x.get("minimum_disk_free_bytes") for x in usage["commands"]
                     if x.get("minimum_disk_free_bytes") is not None]
        minimum = min([before["available_bytes"], *mins])
        usage.update({"status": status, "ram_floor_bytes": floor,
                      "early_stop_available_bytes": early_floor,
                      "minimum_start_available_bytes": minimum_start,
                      "max_ram_drop_bytes": max_ram_drop,
                      "ram_guard_margin_bytes": guard_margin,
                      "disk_floor_bytes": disk_floor,
                      "minimum_available_bytes": minimum,
                      "minimum_disk_free_bytes": min(disk_mins + [disk_before]),
                      "max_observed_available_ram_drop_bytes": max(0, run_initial - minimum)})
        if reason:
            usage["last_stop_reason"] = reason
        _write_usage(usage_path, usage)

    with log.open("wb") as stream:
        stop_reason = None
        if before["available_bytes"] < floor:
            stop_reason = f"preflight RAM below approved hard floor ({floor} bytes)"
        elif before["available_bytes"] < minimum_start:
            stop_reason = (f"preflight RAM below safe run-start requirement ({minimum_start} bytes; "
                           f"hard floor {floor} + guard margin {guard_margin} + max drop {max_ram_drop})")
        elif before["available_bytes"] < early_floor:
            stop_reason = (f"preflight RAM below run drop budget threshold ({early_floor} bytes; "
                           f"run start {run_initial} bytes, max drop {max_ram_drop} bytes)")
        elif disk_before < disk_floor:
            stop_reason = f"preflight free disk below approved floor ({disk_floor} bytes)"
        if stop_reason:
            record.update({"end_available_bytes": before["available_bytes"],
                           "minimum_available_bytes": before["available_bytes"],
                           "minimum_disk_free_bytes": disk_before, "duration_s": 0.0,
                           "stop_reason": stop_reason, "status": "stopped_before_start"})
            write_status("stopped_by_guard", stop_reason)
            raise RuntimeError(f"{stop_reason}; resource evidence={usage_path}; log={log}")
        process = subprocess.Popen(argv, cwd=cwd, env=env, stdout=stream,
                                   stderr=subprocess.STDOUT)
        start_ns = time.time_ns()
        start_mono = time.monotonic()
        deadline = time.monotonic() + timeout
        last_flush = time.monotonic()
        while process.poll() is None:
            time.sleep(poll_interval)
            now = time.monotonic()
            sample = {"elapsed_s": round(now - start_mono, 2), **_ram()}
            sample["disk_free_bytes"] = shutil.disk_usage(run_root).free
            samples.append(sample)
            if sample["available_bytes"] < floor:
                stop_reason = f"available RAM fell below approved hard floor ({floor} bytes)"
            elif sample["available_bytes"] < early_floor:
                stop_reason = (f"available RAM crossed run drop budget threshold ({early_floor} bytes; "
                               f"run start {run_initial} bytes, max drop {max_ram_drop} bytes)")
            elif sample["disk_free_bytes"] < disk_floor:
                stop_reason = f"free disk space fell below approved floor ({disk_floor} bytes)"
            elif now >= deadline:
                stop_reason = f"command timeout ({timeout}s)"
            if stop_reason:
                process.terminate()
                try:
                    process.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    process.kill()
                    process.wait()
                break
            if now - last_flush >= 10:
                mins = [x.get("minimum_available_bytes") for x in usage["commands"]
                        if x.get("minimum_available_bytes") is not None]
                minimum = min([run_initial, *mins,
                               min(sample["available_bytes"] for sample in samples)])
                record.update({"minimum_available_bytes": minimum, "samples": samples})
                usage.update({"status": "running", "minimum_available_bytes": minimum,
                              "max_observed_available_ram_drop_bytes": max(0, run_initial - minimum)})
                _write_usage(usage_path, usage)
                last_flush = now
        return_code = process.wait()
        final = _ram()
        samples.append({"elapsed_s": round(time.monotonic() - start_mono, 2), **final,
                        "disk_free_bytes": shutil.disk_usage(run_root).free})
        min_available = min(sample["available_bytes"] for sample in samples)
        record.update({
            "ram_floor_bytes": floor,
            "early_stop_available_bytes": early_floor,
            "minimum_start_available_bytes": minimum_start,
            "run_initial_available_bytes": run_initial,
            "max_ram_drop_bytes": max_ram_drop,
            "ram_guard_margin_bytes": guard_margin,
            "disk_floor_bytes": disk_floor,
            "minimum_disk_free_bytes": min(sample["disk_free_bytes"] for sample in samples),
            "minimum_available_bytes": min_available,
            "end_available_bytes": final["available_bytes"],
            "max_observed_available_ram_drop_bytes": max(0, run_initial - min_available),
            "duration_s": round((time.time_ns() - start_ns) / 1e9, 2),
            "stop_reason": stop_reason,
            "status": "timeout" if stop_reason and "timeout" in stop_reason else
                      "stopped_by_guard" if stop_reason else "completed",
            "samples": samples,
        })
        write_status(record["status"], stop_reason)
    if stop_reason:
        raise RuntimeError(f"{stop_reason}; resource evidence={usage_path}; log={log}")
    if return_code:
        tail = log.read_text(encoding="utf-8", errors="replace")[-12000:]
        raise RuntimeError(f"command failed ({return_code}): {' '.join(argv)}\n{tail}")
