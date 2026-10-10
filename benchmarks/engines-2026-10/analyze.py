#!/usr/bin/env python3
"""Aggregate results/cells.jsonl -> summary.csv + frontier.json + plots.

Plots (per model): 3D throughput surfaces — Z = per-agent decode tok/s
(what one agent observes while N stream), X = context bucket, Y =
parallelism as bare k. One surface per engine, one PNG per model
(surf3d_<model>.png). Primary metric is per-agent decode tok/s.
"""
import csv
import json
import sys
from collections import defaultdict
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import cm
from mpl_toolkits.mplot3d import Axes3D  # noqa: F401 — registers 3d projection

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
    if "qwen38-27b" in ml or "qwen3.8-27b" in ml:
        # All Qwen3.8-27B arms are the same weights family: alias-suffixed
        # variants (qwen38-27b-gguf / qwen38-27b-buun from --alias) merge
        # so per-model plots compare every engine on one canvas.
        return "qwen3.8-27b"
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

    # Per-model 3D surface: Z = per-agent decode tok/s, X = context,
    # Y = parallelism k. One wireframe surface per engine sharing one
    # canvas (user spec: throughput rising up, ctx across, k deep).
    # Cells measured at only one k leave a line, not a plane — still
    # plotted (wireframe degrades gracefully); zero-TPS/failed cells
    # are dropped, not clamped.
    for model, mrows in models.items():
        engine_order_m = []
        for r in sorted(mrows, key=lambda x: x["tag"]):
            if r["tag"] not in engine_order_m:
                engine_order_m.append(r["tag"])
        color = {t: PALETTE[i % len(PALETTE)]
                 for i, t in enumerate(engine_order_m)}
        fig = plt.figure(figsize=(11, 7.5))
        ax = fig.add_subplot(111, projection="3d")
        drew = False
        xtick_pos, xtick_lbl = [], []
        for tag in engine_order_m:
            # Bucket cells by (ctx, conc); mean over reps/lines for the
            # same key (last-wins dedup above already collapses exact
            # (tag,ctx,conc) rows, but screening+long ladders may both
            # contribute same-key rows with different reps).
            grid = defaultdict(dict)
            for r in mrows:
                if r["tag"] != tag or not r["agents"]:
                    continue
                a = r["agents"][-1]
                if a["ok"] <= 0 or a["mean_decode_tps"] <= 0:
                    continue
                grid[(r["ctx"], r["conc"])] = a["mean_decode_tps"]
            if not grid:
                continue
            ctxs = sorted({c for c, _ in grid})
            concs = sorted({c for _, c in grid})
            xi = list(range(len(ctxs)))
            yi = list(range(len(concs)))
            # Dense fill: missing (ctx,conc) combos stay gaps — only
            # measured corners carry Z; plot_surface needs a full grid,
            # so surface spans the measured hull with None-masked holes.
            Z = [[grid.get((ctxs[j], concs[i])) for j in range(len(ctxs))]
                 for i in range(len(concs))]
            import numpy as np
            Zm = np.ma.masked_invalid(np.array(
                [[np.nan if v is None else v for v in row] for row in Z]))
            if Zm.count() == 0:
                continue
            drew = True
            cmap = plt.get_cmap("viridis")
            norm = matplotlib.colors.Normalize(
                vmin=float(Zm.min()), vmax=float(Zm.max()))
            surf = ax.plot_surface(
                np.array(xi * len(concs)).reshape(len(concs), len(ctxs)),
                np.array([[yi[i]] * len(ctxs) for i in range(len(concs))],
                         dtype=float),
                Zm, color=color[tag], alpha=0.75, linewidth=1,
                edgecolor="k", cmap=None, shade=True)
            # Wireframe overlay on top of shaded surface for readability.
            try:
                ax.plot_wireframe(
                    np.array(xi * len(concs)).reshape(len(concs), len(ctxs)),
                    np.array([[yi[i]] * len(ctxs) for i in range(len(concs))],
                             dtype=float),
                    Zm, color=color[tag], alpha=0.55, linewidth=0.7,
                    rstride=1, cstride=1)
            except ValueError:
                pass  # masked grid too sparse for wireframe; surface suffices
            # Scatter the actual measured points so gaps read as gaps.
            for (ctxv, concv), tps in grid.items():
                ax.scatter(ctxs.index(ctxv), concs.index(concv), tps,
                           color=color[tag], s=14, depthshade=False)
            ax.plot([], [], [], color=color[tag], label=tag)
        if not drew:
            plt.close(fig)
            continue
        for i, ctx in enumerate(sorted({r["ctx"] for r in mrows})):
            lbl = next((l for b, l in CTX_BUCKETS if b == ctx), str(ctx))
            xtick_pos.append(i)
            xtick_lbl.append(lbl)
        ax.set_xticks(xtick_pos)
        ax.set_xticklabels(xtick_lbl, fontsize=8)
        ax.set_yticks(list(range(len(CONCS))))
        ax.set_yticklabels([f"k{c}" for c in CONCS], fontsize=8)
        ax.set_xlabel("context", fontsize=9, labelpad=8)
        ax.set_ylabel("parallelism (k)", fontsize=9, labelpad=8)
        ax.set_zlabel("per-agent decode tok/s", fontsize=9, labelpad=6)
        ax.set_title(f"{model} — 3D throughput surface (Z rises = faster)")
        ax.view_init(elev=22, azim=-60)
        ax.legend(fontsize=8, loc="upper left")
        fig.tight_layout()
        p = OUT / f"surf3d_{model}.png"
        fig.savefig(p, dpi=120)
        plt.close(fig)
        print(f"wrote {p.name}")

    # Variant-comparison surface closing the report (user spec
    # 2026-10-10): qwen3.8-27b variants on the ashalliants engine —
    # base vs uncensored (swift) — Z = per-agent decode tok/s,
    # X = context, Y = parallelism k. Only the shared mtp lane is
    # plottable: the tuned dflash2 lane has no uncensored counterpart
    # (the swift artifact carries no dflash2 draft weights), so mixing
    # lanes would compare spec acceleration, not weights. Extend
    # QWEN_VARIANTS as further variant arms (vision, ...) land.
    QWEN_VARIANTS = {"ashalliants-mtp": "base",
                     "swift-uncensored": "uncensored"}
    fig = plt.figure(figsize=(11, 7.5))
    ax = fig.add_subplot(111, projection="3d")
    qrows = models.get("qwen3.8-27b", [])
    all_ctxs = sorted({r["ctx"] for r in qrows} or {0})
    all_concs = sorted({r["conc"] for r in qrows} or {1})
    drew = False
    for i, (tag, vlabel) in enumerate(QWEN_VARIANTS.items()):
        grid = {}
        for r in qrows:
            if r["tag"] != tag or not r["agents"]:
                continue
            a = r["agents"][-1]
            if a["ok"] <= 0 or a["mean_decode_tps"] <= 0:
                continue
            grid[(r["ctx"], r["conc"])] = a["mean_decode_tps"]
        if not grid:
            continue
        Z = np.full((len(all_concs), len(all_ctxs)), np.nan)
        for (ctx, conc), tps in grid.items():
            Z[all_concs.index(conc), all_ctxs.index(ctx)] = tps
        Zm = np.ma.masked_invalid(Z)
        if Zm.count() == 0:
            continue
        Xg, Yg = np.meshgrid(range(len(all_ctxs)), range(len(all_concs)))
        col = PALETTE[i % len(PALETTE)]
        drew = True
        ax.plot_surface(Xg, Yg, Zm, color=col, alpha=0.8, linewidth=1,
                        edgecolor="k", shade=True)
        try:
            ax.plot_wireframe(Xg, Yg, Zm, color=col, alpha=0.5,
                              linewidth=0.7, rstride=1, cstride=1)
        except ValueError:
            pass
        for (ctx, conc), tps in grid.items():
            ax.scatter(all_ctxs.index(ctx), all_concs.index(conc), tps,
                       color=col, s=16, depthshade=False)
        ax.plot([], [], [], color=col, label=f"{vlabel} ({tag})")
    if drew:
        ax.set_xticks(range(len(all_ctxs)))
        ax.set_xticklabels(
            [next((l for b, l in CTX_BUCKETS if b == c), str(c))
             for c in all_ctxs], fontsize=8)
        ax.set_yticks(range(len(all_concs)))
        ax.set_yticklabels([f"k{c}" for c in all_concs], fontsize=8)
        ax.set_xlabel("context", fontsize=9, labelpad=8)
        ax.set_ylabel("parallelism (k)", fontsize=9, labelpad=8)
        ax.set_zlabel("per-agent decode tok/s", fontsize=9, labelpad=6)
        ax.set_title("qwen3.8-27b variants on ashalliants (mtp lane) — "
                     "per-agent decode tok/s (Z rises = faster)")
        ax.view_init(elev=22, azim=-60)
        ax.legend(fontsize=8, loc="upper left")
        fig.tight_layout()
        p = OUT / "surf3d_winner.png"
        fig.savefig(p, dpi=120)
        plt.close(fig)
        print("wrote surf3d_winner.png")
    else:
        plt.close(fig)
    return 0


if __name__ == "__main__":
    sys.exit(main())
