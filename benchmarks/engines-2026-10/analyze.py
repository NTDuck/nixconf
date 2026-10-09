#!/usr/bin/env python3
"""Aggregate results/cells.jsonl -> summary.csv + frontier.json + plots.

Plots (per model): tok/s vs context bucket, one line per engine, one PNG
per concurrency C in {1,2,4,8} (perC_<model>_c<C>.png). Primary metric is
per-agent decode tok/s (what one agent observes while N stream).
"""
import csv
import json
import sys
from collections import defaultdict
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

ROOT = Path(__file__).parent
CELLS = ROOT / "results" / "cells.jsonl"
OUT = ROOT / "results"

CTX_BUCKETS = [(0, "fresh"), (16384, "16k"), (32768, "32k"), (65536, "64k"),
               (131072, "128k"), (262144, "256k")]
CONCS = [1, 2, 4, 8]

# Stable colors per engine tag across all plots.
PALETTE = ["#1f77b4", "#d62728", "#2ca02c", "#9467bd", "#ff7f0e",
           "#8c564b", "#e377c2", "#17becf", "#7f7f7f", "#bcbd22"]


def load_rows():
    rows = []
    if not CELLS.exists():
        return rows
    # Last-wins dedup (matches report.py): cells.jsonl is append-only, so
    # a re-measured cell (overflow retry) must shadow the original line.
    seen = {}
    for line in CELLS.read_text().splitlines():
        if not line.strip():
            continue
        try:
            r = json.loads(line)
        except json.JSONDecodeError:
            continue
        seen[(r["tag"], r["ctx"], r["conc"])] = r
    rows = list(seen.values())
    return rows


def model_label(m):
    """Normalize ugly model ids (nix store paths) to family labels."""
    ml = m.lower()
    if "bonsai" in ml or "ternary" in ml:
        return "bonsai2-27b"
    return m


def main():
    rows = load_rows()
    if not rows:
        print("no cells yet")
        return 1

    with (OUT / "summary.csv").open("w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        w.writeheader()
        w.writerows(rows)
    print(f"wrote {OUT/'summary.csv'} ({len(rows)} rows)")

    models = defaultdict(list)
    for r in rows:
        models[model_label(r["model"])].append(r)

    # Frontier per model: per (ctx, conc) the best per-agent tps engine(s).
    frontier = {}
    for model, mrows in models.items():
        cells = defaultdict(list)
        for r in mrows:
            cells[(r["ctx"], r["conc"])].append(r)
        frontier[model] = [
            {"ctx": ctx, "conc": conc,
             "tps": max(r["agents"][-1]["mean_decode_tps"] for r in rs
                        if r["agents"]),
             "winners": [r["tag"] for r in rs
                         if r["agents"]
                         and r["agents"][-1]["mean_decode_tps"] ==
                         max(x["agents"][-1]["mean_decode_tps"] for x in rs
                             if x["agents"])]}
            for (ctx, conc), rs in sorted(cells.items())]

    (OUT / "frontier.json").write_text(json.dumps(frontier, indent=1))
    print(f"wrote {OUT/'frontier.json'}")

    # Per-model, per-concurrency: tok/s vs context, one line per engine.
    engine_order = []
    for model, mrows in models.items():
        for r in sorted(mrows, key=lambda x: x["tag"]):
            if r["tag"] not in engine_order:
                engine_order.append(r["tag"])
    color = {t: PALETTE[i % len(PALETTE)] for i, t in enumerate(engine_order)}

    for model, mrows in models.items():
        for conc in CONCS:
            fig, ax = plt.subplots(figsize=(9, 5.5))
            drew = False
            for tag in engine_order:
                pts = sorted(((r["ctx"], r["agents"][-1]["mean_decode_tps"])
                              for r in mrows
                              if r["tag"] == tag and r["conc"] == conc
                              and r["agents"] and r["agents"][-1]["ok"] > 0),
                             key=lambda p: p[0])
                if not pts:
                    continue
                drew = True
                xs = [CTX_BUCKETS[[b for b, _ in CTX_BUCKETS].index(c)][1]
                      if c in [b for b, _ in CTX_BUCKETS] else str(c)
                      for c, _ in pts]
                ys = [t for _, t in pts]
                ax.plot(xs, ys, marker="o", color=color[tag], label=tag)
            if not drew:
                plt.close(fig)
                continue
            ax.set_xlabel("context (prompt tokens)")
            ax.set_ylabel("per-agent decode tok/s")
            ax.set_title(f"{model} — C{conc} (per-agent decode tok/s vs context)")
            ax.grid(alpha=0.3)
            ax.legend(fontsize=8)
            fig.tight_layout()
            p = OUT / f"perC_{model}_c{conc}.png"
            fig.savefig(p, dpi=110)
            plt.close(fig)
            print(f"wrote {p.name}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
