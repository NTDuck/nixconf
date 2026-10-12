#!/usr/bin/env python3
"""High-context, high-parallelism sweep for ashalliants engines.

Tests the Pareto frontier at 128k+ context with C2/C4/C8 concurrency.
The current sweep caps context at 16k for C8 (VRAM constraint), but
128k+ context with C2/C4 should fit and may reveal new winners.

Memory math (24 GiB card, 17 GiB weights, rk4v4 KV ~12 KiB/tok):
  ctx=65536  C8:  65536*8*12KiB  = 6 GiB KV  -> 23 GiB total (fits)
  ctx=131072 C4:  131072*4*12KiB = 6 GiB KV  -> 23 GiB total (fits)
  ctx=131072 C2:  131072*2*12KiB = 3 GiB KV  -> 20 GiB total (fits)
  ctx=262144 C2:  262144*2*12KiB = 6 GiB KV  -> 23 GiB total (fits)
  ctx=262144 C4:  262144*4*12KiB = 12 GiB KV -> 29 GiB total (OOM)

Usage: python3 sweep_highctx.py [--tag ashalliants-df2-128k] [--conc 4]
"""
import argparse, json, time
from pathlib import Path

import bench, engines

ROOT = Path(__file__).resolve().parent
RESULTS = ROOT / "results"

# High-context cells to test (tag, ctx, conc)
# Each engine entry has a fixed context; we vary concurrency
CELLS = [
    # 128k context variants (NINFER_CONTEXT=131072, NINFER_CONCURRENCY=4)
    # Test at C2, C4 (C8 would OOM: 12 GiB KV + 17 GiB weights = 29 GiB)
    ("ashalliants-df2-128k", 131072, 2),
    ("ashalliants-df2-128k", 131072, 4),
    ("ashalliants-mtp-128k", 131072, 2),
    ("ashalliants-mtp-128k", 131072, 4),
    # 65k context variants (NINFER_CONTEXT=65536, NINFER_CONCURRENCY=8)
    # Test at C4, C8 (should fit: 6 GiB KV + 17 GiB weights = 23 GiB)
    ("ashalliants-df2-65k-c8", 65536, 4),
    ("ashalliants-df2-65k-c8", 65536, 8),
    ("ashalliants-mtp-65k-c8", 65536, 4),
    ("ashalliants-mtp-65k-c8", 65536, 8),
    # Reduced-KV variants for C8 at 65k (KV=49152 to fit VRAM)
    ("ashalliants-df2-65k-c8-reduced", 65536, 8),
    ("ashalliants-mtp-65k-c8-reduced", 65536, 8),
    # 49k context variants for C8 (both context and KV reduced to fit)
    ("ashalliants-df2-49k-c8", 49152, 8),
    ("ashalliants-mtp-49k-c8", 49152, 8),
    # C6 variants for 65k context (C8 OOMs)
    ("ashalliants-df2-65k-c6", 65536, 6),
    ("ashalliants-mtp-65k-c6", 65536, 6),
]


def done_keys():
    keys = set()
    p = RESULTS / "cells.jsonl"
    if p.exists():
        for line in p.read_text().splitlines():
            try:
                r = json.loads(line)
                keys.add((r["tag"], r["ctx"], r["conc"]))
            except Exception:
                pass
    return keys


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tag", default="", help="filter to specific tag")
    ap.add_argument("--ctx", type=int, default=0, help="filter to specific ctx")
    ap.add_argument("--conc", type=int, default=0, help="filter to specific conc")
    ap.add_argument("--max-tokens", type=int, default=256)
    a = ap.parse_args()

    keys = done_keys()
    for tag, ctx, conc in CELLS:
        if a.tag and tag != a.tag:
            continue
        if a.ctx and ctx != a.ctx:
            continue
        if a.conc and conc != a.conc:
            continue
        if (tag, ctx, conc) in keys:
            print(f"skip done {tag} ctx={ctx} c={conc}")
            continue

        print(f"=== {tag} ctx={ctx} c={conc} ===", flush=True)
        try:
            cfg = engines.get(tag)
        except SystemExit:
            print(f"SKIP {tag}: not registered")
            continue

        try:
            engines.start(cfg)
        except RuntimeError as e:
            print(f"START-FAIL {tag}: {e}")
            continue

        try:
            bench.CELL_BUDGET_S = 1200
            agg = bench.run_cell(cfg, ctx, conc, str(RESULTS),
                                 max_tokens=a.max_tokens, reps=1)
            print(json.dumps(agg["agents"][-1], ensure_ascii=False))
        except Exception as e:
            print(f"CELL-FAIL {tag} ctx={ctx} c={conc}: {e}")
        finally:
            engines.stop(cfg)
        time.sleep(2)


if __name__ == "__main__":
    main()
