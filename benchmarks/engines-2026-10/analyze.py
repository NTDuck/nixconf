#!/usr/bin/env python3
"""Aggregate results/cells.jsonl -> CSV + Pareto frontiers + plots (PNG).

X axis = per-agent decode tok/s (the optimization target), Y = parallelism.
Pareto frontier: a cell dominates another iff it has >= per-agent tps at the
same-or-higher concurrency, or higher per-agent tps at the same concurrency.
Frontier per model: the max concurrency at which the engine is not strictly
beaten on per-agent decode tps by another engine, per ctx bucket.
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


def load_rows():
    rows = []
    if not CELLS.exists():
        return rows
    seen = set()
    for line in CELLS.read_text().splitlines():
        if not line.strip():
            continue
        r = json.loads(line)
        key = (r["tag"], r["ctx"], r["conc"], r.get("reps", 1))
        if key in seen:
            continue
        seen.add(key)
        a = r["agents"][-1]
        rows.append({
            "tag": r["tag"], "model": r["model"], "ctx": r["ctx"],
            "conc": r["conc"], "per_agent_tps": a["mean_decode_tps"],
            "agg_tps": a["agg_decode_tps"], "e2e_tps": a["agg_e2e_tps"],
            "ttft_s": a["mean_ttft_s"] or 0.0,
            "vram_mib": a["peak_vram_mib"], "ok": a["ok"],
        })
    return rows


def main():
    rows = load_rows()
    if not rows:
        print("no cells yet"); return 1

    with (OUT / "summary.csv").open("w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        w.writeheader()
        w.writerows(rows)
    print(f"wrote {OUT/'summary.csv'} ({len(rows)} rows)")

    models = defaultdict(list)
    for r in rows:
        models[r["model"]].append(r)

    # Plot per model: fresh ctx
    for model, mrows in models.items():
        fig, ax = plt.subplots(figsize=(9, 6))
        engines = sorted({r["tag"] for r in mrows})
        for eng in engines:
            pts = sorted((r["conc"], r["per_agent_tps"])
                         for r in mrows if r["tag"] == eng and r["ctx"] == 0)
            if not pts:
                continue
            xs = [c for c, _ in pts]; ys = [t for _, t in pts]
            ax.plot(xs, ys, marker="o", label=eng)
        ax.set_xlabel("concurrency (agents)")
        ax.set_ylabel("per-agent decode tok/s")
        ax.set_title(f"{model}: per-agent decode tok/s vs concurrency (fresh ctx)")
        ax.grid(True, alpha=0.3); ax.legend()
        fig.savefig(OUT / f"pareto_{model.replace('.', '_').replace('/', '_')}_fresh.png",
                    dpi=140, bbox_inches="tight")
        plt.close(fig)
        print(f"wrote fresh plot for {model}")

        # long ctx: per-agent tps vs ctx at C1
        pts = defaultdict(dict)
        for r in mrows:
            if r["conc"] == 1:
                pts[r["tag"]][r["ctx"]] = r["per_agent_tps"]
        if any(len(v) > 1 for v in pts.values()):
            fig, ax = plt.subplots(figsize=(9, 6))
            for eng, series in sorted(pts.items()):
                if len(series) < 2:
                    continue
                xs = sorted(series); ys = [series[x] for x in xs]
                ax.plot(xs, ys, marker="s", label=eng)
            ax.set_xlabel("context tokens (prefill)")
            ax.set_ylabel("per-agent decode tok/s")
            ax.set_title(f"{model}: decode tps vs context (C1)")
            ax.set_xscale("log", base=2); ax.grid(True, alpha=0.3); ax.legend()
            fig.savefig(OUT / f"ctx_{model.replace('.', '_').replace('/', '_')}_c1.png",
                        dpi=140, bbox_inches="tight")
            plt.close(fig)
            print(f"wrote ctx plot for {model}")

            # per-agent tps vs ctx at C4 and C8 (concurrency collapse view)
            for conc in (4, 8):
                pts_c = defaultdict(dict)
                for r in mrows:
                    if r["conc"] == conc:
                        pts_c[r["tag"]][r["ctx"]] = r["per_agent_tps"]
                if any(len(v) > 1 for v in pts_c.values()):
                    fig, ax = plt.subplots(figsize=(9, 6))
                    for eng, series in sorted(pts_c.items()):
                        if len(series) < 2:
                            continue
                        xs = sorted(series); ys = [series[x] for x in xs]
                        ax.plot(xs, ys, marker="s", label=eng)
                    ax.set_xlabel("context tokens (prefill)")
                    ax.set_ylabel(f"per-agent decode tok/s (C{conc})")
                    ax.set_title(f"{model}: decode tps vs context (C{conc})")
                    ax.set_xscale("log", base=2); ax.grid(True, alpha=0.3); ax.legend()
                    fig.savefig(OUT / f"ctx_{model.replace('.', '_').replace('/', '_')}_c{conc}.png",
                                dpi=140, bbox_inches="tight")
                    plt.close(fig)
                    print(f"wrote ctx C{conc} plot for {model}")

    # Pareto frontier table per model (fresh ctx, printed + json)
    frontier = {}
    for model, mrows in models.items():
        fresh = [r for r in mrows if r["ctx"] == 0]
        if not fresh:
            continue
        best_c = {}
        for r in fresh:
            best_c[r["tag"]] = max(best_c.get(r["tag"], 0), r["conc"])
        by_conc = defaultdict(dict)
        for r in fresh:
            by_conc[r["conc"]][r["tag"]] = r["per_agent_tps"]
        surviving = []
        for conc in sorted(by_conc):
            best = max(by_conc[conc].values())
            winners = [e for e, t in by_conc[conc].items() if t == best]
            surviving.append({"conc": conc, "best_tps": best, "winners": winners})
        frontier[model] = surviving
        # per-ctx winners: which engine wins each concurrency at each ctx
        # bucket (0 = fresh). Used by the report's long-context tables.
        by_ctx = defaultdict(lambda: defaultdict(dict))
        for r in mrows:
            by_ctx[r["ctx"]][r["conc"]][r["tag"]] = r["per_agent_tps"]
        frontier[model + "@ctx"] = {
            ctx: [{"conc": conc,
                   "best_tps": best,
                   "winners": winners}
                  for conc, ts in sorted(cs.items())
                  for best in (max(ts.values()),)
                  for winners in ([e for e, t in ts.items() if t == best],)]
            for ctx, cs in sorted(by_ctx.items())
        }
    (OUT / "frontier.json").write_text(json.dumps(frontier, indent=1))
    print(json.dumps(frontier, indent=1))
    return 0


if __name__ == "__main__":
    sys.exit(main())
