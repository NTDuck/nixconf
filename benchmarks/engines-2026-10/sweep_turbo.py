#!/usr/bin/env python3
"""Turbo concurrency x context sweep (2026-11-07 user task).

Question: does qwen3.8-27b-turbo (qwen38_turbo_sm86.ninfer, mtp) support
more than the production 6x65k shape, and what is the maximal
concurrency x context matrix on the 3090?

Cells ladder C8@65k (production shape) upward in context at the
concurrency each KV budget allows (rk4v4 ~12 KiB/token; 17 GiB weights
leaves ~6.5 GiB compute+KV headroom on the 24 GiB card):
  65536x8, 65536x6, 98304x4, 131072x4, 196608x2, 262144x2, 262144x1.

Usage: python3 sweep_turbo.py [--cells tag,ctx,conc ...]
"""
import argparse, sys
from pathlib import Path

import bench, engines

RESULTS = Path(__file__).resolve().parent / "results"

# (tag, ctx, conc) — screen at fresh + short-prompt first, then the
# full 65k-prompt deep cell. Deep cells reuse run_sweep's done-keys.
CELLS = [
    ("ashalliants-turbo-65k",  0,      8),
    ("ashalliants-turbo-65k",  16384,  8),
    ("ashalliants-turbo-65k",  65536,  8),
    ("ashalliants-turbo-96k",  98304,  4),
    ("ashalliants-turbo-128k", 131072, 4),
    ("ashalliants-turbo-192k", 196608, 2),
    ("ashalliants-turbo-256k", 262144, 2),
    ("ashalliants-turbo-256k", 262144, 1),
]


def done_keys():
    """Cells already measured OR marked overflow (same rule as run_sweep)."""
    keys = set()
    p = RESULTS / "cells.jsonl"
    if p.exists():
        import json
        for line in p.read_text().splitlines():
            try:
                r = json.loads(line)
                keys.add((r["tag"], r["ctx"], r["conc"]))
            except Exception:
                pass
    ov = RESULTS / "overflow.jsonl"
    if ov.exists():
        import json
        for line in ov.read_text().splitlines():
            if line.strip():
                o = json.loads(line)
                keys.add((o["tag"], o["ctx"], o["conc"]))
    return keys


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--cells", default=None,
                    help="comma list tag,ctx,conc to run a subset")
    ap.add_argument("--max-tokens", type=int, default=256)
    args = ap.parse_args()

    cells = CELLS
    if args.cells:
        cells = []
        for spec in args.cells.split(","):
            tag, ctx, conc = spec.split(":")
            cells.append((tag, int(ctx), int(conc)))

    keys = done_keys()
    for tag, ctx, conc in cells:
        if (tag, ctx, conc) in keys:
            print(f"skip done {tag} ctx={ctx} c={conc}", flush=True)
            continue
        cfg = engines.get(tag)
        print(f"=== {tag} ctx={ctx} c={conc} ===", flush=True)
        try:
            engines.start(cfg)
        except RuntimeError as e:
            print(f"START-FAIL {tag}: {e}", flush=True)
            (RESULTS / "start-failures.log").open("a").write(
                f"{tag} ctx={ctx} c={conc}: {e}\n")
            continue
        try:
            bench.CELL_BUDGET_S = 1200
            agg = bench.run_cell(cfg, ctx, conc, str(RESULTS),
                                 max_tokens=args.max_tokens, reps=1)
            print(f"RESULT {tag} ctx={ctx} c={conc} "
                  f"ok={agg['agents'][-1]['ok']}/{conc} "
                  f"mean_decode={agg['agents'][-1]['mean_decode_tps']} "
                  f"agg_decode={agg['agents'][-1]['agg_decode_tps']} "
                  f"ttft={agg['agents'][-1]['mean_ttft_s']} "
                  f"vram={agg['agents'][-1]['peak_vram_mib']}", flush=True)
        finally:
            engines.stop(cfg)


if __name__ == "__main__":
    sys.exit(main())
