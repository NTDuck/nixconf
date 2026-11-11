#!/usr/bin/env python3
"""Coder390 concurrency x context VRAM sweep (2026-11-11 user task).

BLOCKED 2026-11-11 (see results/sweep-coder390-2026-11-11.log): the
pinned artifact's 263 gguf_blocks_v1 K-quant tensors load on no ninfer
engine in the store; the system unit was removed from the config the
same day (ninfer/default.nix CODER390 REJECTED). Keep this ladder for
the rerun once upstream ships gguf-block support or an official
GGUF->v3 converter and a loadable artifact is re-pinned.

Question: what is the maximal {max concurrency} x {context} matrix for
qwen3.8-27b-coder390 (Q3 LynnStyle + Q8 MTP, 16.6 GiB weights) on the
RTX 3090? Fills the intentionally-empty SHAPES row in the ninfer CLI.

Ladder: C8 down (engine's hard --max-concurrency cap is 8). Weights sit
between bonsai2 (6.7 GiB, C8 holds at every ctx) and dense qwen3.8 (19
GiB, C8 OOMs above 16k) — the expected envelope is C8x16k..C8x65k, so
each context starts at C8 and steps down on OOM/refusal. ctx=0 cells
are the fresh/short-prompt screen (sweep_turbo 2026-11-07 convention).

Cells marked overflow on CUDA OOM / engine refusal — same done-key rule
as run_sweep, so a re-run resumes instead of re-burning 20-30 min cells.

Usage: python3 sweep_coder390.py [--cells tag:ctx:conc,...]
"""
import argparse, json, sys
from pathlib import Path

import bench, engines

RESULTS = Path(__file__).resolve().parent / "results"

# (tag, ctx, conc) — fresh screen first, then the deep cell per context.
# Each ctx ladder: C8 first; on OOM step down to C4/C2/C1.
CELLS = [
    ("ashalliants-coder390-16k",  0,      8),
    ("ashalliants-coder390-16k",  16384,  8),
    ("ashalliants-coder390-32k",  32768,  8),
    ("ashalliants-coder390-65k",  65536,  8),
    ("ashalliants-coder390-128k", 131072, 4),
    ("ashalliants-coder390-256k", 262144, 2),
]

OOM_MARKERS = ("out of memory", "cudaMalloc", "OOM", "kv cache",
               "cannot serve", "failed to allocate")


def done_keys():
    """Cells already measured OR marked overflow (run_sweep rule)."""
    keys = set()
    p = RESULTS / "cells.jsonl"
    if p.exists():
        for line in p.read_text().splitlines():
            try:
                r = json.loads(line)
                keys.add((r["tag"], r["ctx"], r["conc"]))
            except Exception:
                pass
    ov = RESULTS / "overflow.jsonl"
    if ov.exists():
        for line in ov.read_text().splitlines():
            if line.strip():
                o = json.loads(line)
                keys.add((o["tag"], o["ctx"], o["conc"]))
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

    keys = done_keys()
    log = (RESULTS / "sweep-coder390-2026-11-11.log").open("a")
    for tag, ctx, conc in cells:
        if (tag, ctx, conc) in keys:
            line = f"skip done {tag} ctx={ctx} c={conc}"
            print(line, flush=True); log.write(line + "\n"); log.flush()
            continue
        cfg = engines.get(tag)
        line = f"=== {tag} ctx={ctx} c={conc} ==="
        print(line, flush=True); log.write(line + "\n"); log.flush()
        try:
            engines.start(cfg)
        except RuntimeError as e:
            # Distinguish engine OOM/refusal (overflow) from other
            # startup failures — an OOM at startup means this conc is
            # above the KV ceiling for this ctx: record and continue.
            msg = str(e)
            if any(m.lower() in msg.lower() for m in OOM_MARKERS):
                line = f"OVERFLOW {tag} ctx={ctx} c={conc} (startup OOM/refusal)"
                print(line, flush=True); log.write(line + "\n"); log.flush()
                (RESULTS / "overflow.jsonl").open("a").write(
                    json.dumps({"tag": tag, "ctx": ctx, "conc": conc,
                                "reason": msg[-500:]}) + "\n")
            else:
                line = f"START-FAIL {tag}: {msg[-500:]}"
                print(line, flush=True); log.write(line + "\n"); log.flush()
                (RESULTS / "start-failures.log").open("a").write(
                    f"{tag} ctx={ctx} c={conc}: {msg}\n")
            continue
        try:
            bench.CELL_BUDGET_S = 1200
            agg = bench.run_cell(cfg, ctx, conc, str(RESULTS),
                                 max_tokens=args.max_tokens, reps=1)
            last = agg["agents"][-1]
            line = (f"RESULT {tag} ctx={ctx} c={conc} "
                    f"ok={last['ok']}/{conc} "
                    f"mean_decode={last['mean_decode_tps']} "
                    f"agg_decode={last['agg_decode_tps']} "
                    f"ttft={last['mean_ttft_s']} "
                    f"vram={last['peak_vram_mib']}")
            print(line, flush=True); log.write(line + "\n"); log.flush()
        finally:
            engines.stop(cfg)


if __name__ == "__main__":
    sys.exit(main())
