#!/usr/bin/env python3
"""Coder390 concurrency x context sweep (2026-11-11 user task).

Question: what is the {max concurrency} x {context} matrix for the
freshly converted qwen3.8-27b-coder390 (dense 19G weights + 5-layer
dflash2 draft, 0.17.2 engine)? Dense-family expectation: envelope
C8x16k..C6x65k (weights leave less KV headroom than bonsai2, more than
turbo at deep ctx because the 5L draft costs less than K=7).

Cells ladder from the production dense shape downward as the KV budget
allows (rk4v4 ~12 KiB/token). NINFER_FALLBACK=off keeps each cell honest:
OOM at startup = the cell does not exist for this artifact.

Usage: python3 sweep_coder390.py [--cells tag,ctx,conc ...]
"""
import argparse, sys
from pathlib import Path

import bench, engines

RESULTS = Path(__file__).resolve().parent / "results"
ART = "/home/ayin/models/q27-bench/downloads/coder390/coder390_qwen3_8_27b.ninfer"
ENGINE = "0.17.2"  # nix store hash resolved by engines.py ASH; local artifact overrides NINFER_MODEL

CELLS = [
    ("ashalliants-coder390-16k-c8",  16384,  8),
    ("ashalliants-coder390-32k-c8",  32768,  8),
    ("ashalliants-coder390-32k-c7",  32768,  7),
    ("ashalliants-coder390-65k-c8",  65536,  8),
    ("ashalliants-coder390-65k-c6",  65536,  6),
    ("ashalliants-coder390-65k-c4",  65536,  4),
    ("ashalliants-coder390-128k-c4", 131072, 4),
    ("ashalliants-coder390-128k-c2", 131072, 2),
    ("ashalliants-coder390-256k-c2", 262144, 2),
    ("ashalliants-coder390-256k-c1", 262144, 1),
]


def done_keys():
    keys = set()
    for name in ("cells.jsonl", "overflow.jsonl"):
        p = RESULTS / name
        if p.exists():
            import json
            for line in p.read_text().splitlines():
                try:
                    r = json.loads(line)
                    keys.add((r["tag"], r["ctx"], r["conc"]))
                except Exception:
                    pass
    return keys


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--cells", default=None,
                    help="comma list tag:ctx:conc to run a subset")
    ap.add_argument("--max-tokens", type=int, default=256)
    args = ap.parse_args()

    cells = CELLS
    if args.cells:
        cells = []
        for spec in args.cells.split(","):
            tag, ctx, conc = spec.split(":")
            cells.append((tag, int(ctx), int(conc)))

    for tag, ctx, conc in cells:
        if (tag, ctx, conc) in done_keys():
            print(f"skip done {tag} ctx={ctx} c={conc}", flush=True)
            continue
        cfg = dict(engines.get("ashalliants-df2-65k-c6"))
        cfg = dict(cfg)
        cfg["env"] = dict(cfg["env"])
        cfg["port"] = 8144
        cfg["env"]["NINFER_MODEL"] = ART
        cfg["env"]["NINFER_PORT"] = "8144"
        cfg["env"]["NINFER_CONCURRENCY"] = str(conc)
        cfg["env"]["NINFER_CONTEXT"] = str(ctx)
        cfg["env"]["NINFER_KV_CAPACITY"] = str(ctx)
        cfg["env"]["NINFER_HOST_STATE_SLOTS"] = str(conc)
        cfg["env"]["NINFER_SPEC"] = "dflash2"
        cfg["tag"] = tag
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
