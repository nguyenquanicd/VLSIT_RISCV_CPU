#!/usr/bin/env python3
"""Utilization arithmetic for the tensor coprocessor review (2026-11-17), companion of roofline.py.

Inputs from the HDS (CFG-64TOPS): 16 arrays of 32x32 INT8 PEs at 2 GHz, one 256-bit AXI port (64 GB/s).
Assumptions that are NOT in the HDS are marked (A) and can be changed on the command line of each function.
Run: python utilization.py
"""
import math

F_HZ = 2e9
ARRAYS = 16
ROWS = COLS = 32
BW = 64e9                       # bytes/s, one 256-bit AXI port at 2 GHz
PEAK_MAC = ARRAYS * ROWS * COLS * F_HZ    # MAC/s
PEAK_OPS = 2 * PEAK_MAC


def reuse_table():
    print("A. MAC utilization limited by memory: weights streamed once, reused by M rows (batch or tokens)")
    print(f"   peak = {PEAK_MAC / 1e12:.2f} TMAC/s, DRAM = {BW / 1e9:.0f} GB/s -> "
          f"{PEAK_MAC / BW:.0f} MAC per byte needed to fill every PE")
    print(f"{'M rows':>8} {'INT8 weights':>14} {'INT4 weights':>14}   comment")
    notes = {1: "batch-one decode", 4: "speculative verify of 4 drafts", 8: "small batch / GQA group",
             64: "short prefill chunk", 512: "prefill of 512 tokens"}
    for m in (1, 2, 4, 8, 16, 32, 64, 128, 256, 512):
        u8 = min(1.0, BW * m / PEAK_MAC)
        u4 = min(1.0, 2 * BW * m / PEAK_MAC)
        print(f"{m:8d} {u8:13.2%} {u4:13.2%}   {notes.get(m, '')}")


def session_average(params=1.24e9, prompt=512, gen=256, eff=0.7, tile_roof_tops=8.19):
    prefill_ops = 2 * params * prompt
    decode_ops = 2 * params * gen
    t_prefill = prefill_ops / (tile_roof_tops * 1e12)
    t_decode = gen * params / (BW * eff)
    util = (prefill_ops + decode_ops) / ((t_prefill + t_decode) * PEAK_OPS)
    print("\nB. Average MAC utilization over one chat session (1.24e9-parameter INT8 model)")
    print(f"   prompt {prompt} tokens, {gen} generated tokens, DRAM efficiency {eff:.0%}, prefill at the {tile_roof_tops} TOPS roofline")
    print(f"   prefill {t_prefill * 1e3:.0f} ms, decode {t_decode * 1e3:.0f} ms, total {(t_prefill + t_decode):.2f} s")
    print(f"   operations {(prefill_ops + decode_ops) / 1e12:.2f} T -> average utilization {util:.2%} of {PEAK_OPS / 1e12:.1f} TOPS")
    for label, t_pre in (("prefill at 58 TOPS (HDS 13 roof)", prefill_ops / 58e12),):
        u = (prefill_ops + decode_ops) / ((t_pre + t_decode) * PEAK_OPS)
        print(f"   {label}: average utilization {u:.2%}")
    duty = t_prefill / (t_prefill + t_decode)
    print(f"   prefill share of the session time: {duty:.1%}; during the other {1 - duty:.1%} (decode) the arrays run at "
          f"{BW * eff / PEAK_MAC:.2%} of peak MAC rate")


def shape_quantization(shapes, arrays=ARRAYS, r=ROWS, c=COLS):
    print("\nC. Shape quantization on 32x32 arrays (tile = one array, tiles dealt to 16 arrays)")
    print(f"{'M':>6} {'N':>6} {'K':>6} {'pad M/N':>9} {'tile balance':>13} {'combined':>9}")
    for m, n, k in shapes:
        mt, nt = math.ceil(m / r), math.ceil(n / c)
        pad = (m * n) / (mt * r * nt * c)
        tiles = mt * nt
        bal = tiles / (math.ceil(tiles / arrays) * arrays)
        print(f"{m:6d} {n:6d} {k:6d} {pad:8.1%} {bal:12.1%} {pad * bal:8.1%}")


def causal_waste():
    print("\nD. Causal attention with 128x128 score tiles (S is a multiple of tile size)")
    print("   Useful MAC share is shown separately from the fraction of blocks scheduled.")
    t = 128
    print(f"{'S':>6} {'useful/active-tile MAC':>24} {'scheduled/full tiles':>23} {'useful/full-square MAC':>24}")
    for s in (128, 256, 512, 1024, 2048, 4096):
        n = s // t
        # Active tiles are lower triangular. Useful causal (q,k) pairs include the diagonal.
        useful_in_active_tiles = (s + 1) / (s + t)
        scheduled_tiles = (n + 1) / (2 * n)
        useful_without_skipping = (s + 1) / (2 * s)
        print(f"{s:6d} {useful_in_active_tiles:23.1%} {scheduled_tiles:22.1%} {useful_without_skipping:23.1%}")


def dispatch_model():
    print("\nE. Host dispatch limit (A: 1 us of CPU work per tensor command: descriptor stores, 8 CBO.clean, issue, result)")
    t_host = 1e-6
    print(f"   commands shorter than {t_host * 1e6:.0f} us cannot keep the arrays busy at any queue depth:")
    print(f"   operations per command needed at peak for 1 us = {PEAK_OPS * t_host / 1e6:.0f} MOP "
          f"(a 256^3 GEMM is {2 * 256 ** 3 / 1e6:.0f} MOP, one 128^3 tile is {2 * 128 ** 3 / 1e6:.1f} MOP)")
    print(f"{'command time':>14} {'util, host prep inline':>24} {'util, prebuilt list (depth>=2)':>32}")
    for t_cmd in (64e-9, 1e-6, 4e-6, 10e-6, 100e-6, 1e-3):
        inline = t_cmd / (t_cmd + t_host)
        prebuilt = min(1.0, t_cmd / t_host)
        print(f"{t_cmd * 1e6:12.3f} us {inline:23.1%} {prebuilt:31.1%}")


def sparse_feed():
    print("\nF. 2:4 sparse paired lanes: activation feed per array")
    dense_a = ROWS          # bytes per cycle on the A edge (one INT8 per row)
    # Each PE consumes two nonzeros per cycle, i.e. four K positions per cycle -> K advances twice as fast.
    sparse_a = 2 * ROWS
    print(f"   A feed dense {dense_a} B/cycle/array, sparse {sparse_a} B/cycle/array; "
          f"16 arrays at 2 GHz: {ARRAYS * dense_a * F_HZ / 1e12:.3f} TB/s -> {ARRAYS * sparse_a * F_HZ / 1e12:.3f} TB/s for A alone")
    print("   If the injection network is not doubled, sparse mode is feed-limited to dense MAC rate (no speed-up).")


def littles_law():
    print("\nG. DMA reads in flight (Little's law) for 64 GB/s")
    for lat_ns in (100, 200, 400, 800):
        need = BW * lat_ns * 1e-9
        have = 16 * 64 * 32
        print(f"   latency {lat_ns:4d} ns -> {need / 1024:6.1f} KiB in flight needed, HDS candidate provides {have / 1024:.0f} KiB "
              f"({'ok' if have >= need else 'too small'})")


def main():
    reuse_table()
    session_average()
    shape_quantization([(1, 2048, 2048), (8, 2048, 2048), (32, 2048, 2048), (100, 2048, 8192),
                        (197, 768, 768), (197, 768, 3072), (512, 2048, 2048), (1024, 4096, 4096)])
    causal_waste()
    dispatch_model()
    sparse_feed()
    littles_law()


if __name__ == "__main__":
    main()
