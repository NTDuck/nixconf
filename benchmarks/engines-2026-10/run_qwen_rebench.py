#!/usr/bin/env python3
"""Runner for ashalliants Qwen3.8-27B re-benchmark and Qwen3.6-35B-A3B benchmark.
Starts each engine configuration once and runs all its assigned (ctx, conc) cells.
Results are appended to results/cells.jsonl.
"""
import json, sys, time
from pathlib import Path

ROOT = Path(__file__).resolve().parent
RESULTS = ROOT / "results"
RESULTS.mkdir(exist_ok=True)

import bench, engines

PLAN = [
    # --- Part 1: Qwen3.6-35B-A3B ---
    ("ashalliants-35b-mtp-c4", [
        (0, 4),
        (16384, 4),
        (32768, 4),
    ]),
    ("ashalliants-35b-mtp", [
        (0, 1),
        (0, 2),
        (0, 3),
        (16384, 1),
        (16384, 2),
        (16384, 3),
        (32768, 1),
        (32768, 2),
        (32768, 3),
        (65536, 1),
        (65536, 2),
        (65536, 3),
    ]),
    ("ashalliants-35b-mtp-128k", [
        (131072, 1),
        (131072, 2),
    ]),
    ("ashalliants-35b-mtp-256k", [
        (262144, 1),
    ]),

    # --- Part 2: Qwen3.8-27B Ashalliants Deep Context & Re-benchmark ---
    ("ashalliants-df2-32k", [
        (32768, 1),
        (32768, 2),
        (32768, 4),
        (32768, 6),
    ]),
    ("ashalliants-df2-65k", [
        (65536, 1),
        (65536, 2),
        (65536, 4),
    ]),
    ("ashalliants-df2-128k", [
        (131072, 1),
    ]),
    ("ashalliants-df2-256k", [
        (262144, 1),
    ]),
]


def done_keys():
    keys = set()
    p = RESULTS / "cells.jsonl"
    if p.exists():
        for line in p.read_text().splitlines():
            try:
                r = json.loads(line)
                # Only consider done if ok > 0
                if r.get("ok", 0) > 0:
                    keys.add((r["tag"], r["ctx"], r["conc"]))
            except Exception:
                pass
    return keys


def main():
    keys = done_keys()
    total_cells = sum(len(cells) for _, cells in PLAN)
    print(f"Total planned cells: {total_cells}")

    for tag, cells in PLAN:
        pending = [(ctx, c) for (ctx, c) in cells if (tag, ctx, c) not in keys]
        if not pending:
            print(f"All cells for {tag} already measured. Skipping engine start.")
            continue

        print(f"\n==========================================")
        print(f"Starting {tag} for {len(pending)} pending cells: {pending}")
        print(f"==========================================")
        cfg = engines.get(tag)

        try:
            engines.start(cfg)
        except Exception as e:
            print(f"FAILED to start {tag}: {e}", file=sys.stderr)
            with (RESULTS / "overflow.jsonl").open("a") as of:
                for ctx, conc in pending:
                    of.write(json.dumps({"tag": tag, "ctx": ctx, "conc": conc,
                                         "reason": f"Startup failed: {e}"}) + "\n")
            continue

        try:
            for ctx, conc in pending:
                print(f"\n--- Running {tag} ctx={ctx} conc={conc} ---", flush=True)
                try:
                    agg = bench.run_cell(cfg, ctx, conc, RESULTS, max_tokens=256, reps=1)
                    agent = agg["agents"][-1] if agg["agents"] else {}
                    tps = agent.get("mean_decode_tps", 0.0)
                    ok = agg.get("ok", 0)
                    wall = agent.get("wall", 0.0)
                    vram = agent.get("peak_vram_mib", 0)
                    print(f"RESULT: {tag} ctx={ctx} c={conc} => ok={ok}/{conc}, "
                          f"tps={tps:.1f}, wall={wall:.1f}s, vram={vram}MiB", flush=True)
                except Exception as cell_err:
                    print(f"ERROR in cell {tag} ctx={ctx} conc={conc}: {cell_err}", file=sys.stderr)
                    with (RESULTS / "overflow.jsonl").open("a") as of:
                        of.write(json.dumps({"tag": tag, "ctx": ctx, "conc": conc,
                                             "reason": str(cell_err)}) + "\n")
                time.sleep(1)
        finally:
            print(f"Stopping {tag}...")
            engines.stop(cfg)
            time.sleep(2)

    print("\nAll planned benchmark cells completed.")


if __name__ == "__main__":
    main()
