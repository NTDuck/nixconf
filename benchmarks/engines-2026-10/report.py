#!/usr/bin/env python3
"""Generate benchmarks/INFERENCE-ENGINES.md from results/ artifacts.

Layout: summary verdicts -> per-model "table views" (rows=context,
cols=C1..C8, per-agent decode tok/s + peak VRAM, one table per engine) ->
per-model plot links -> overflow ledger -> engine configurations ->
reproduce.

Inputs: results/cells.jsonl, results/overflow.jsonl, results/*.png.
"""
import json
import sys
from collections import defaultdict
from datetime import date
from pathlib import Path

ROOT = Path(__file__).parent
OUT = ROOT.parent / "INFERENCE-ENGINES.md"

CTX_BUCKETS = [(0, "fresh"), (16384, "16k"), (32768, "32k"), (65536, "64k"),
               (131072, "128k"), (262144, "256k")]
CONCS = [1, 2, 4, 8]


def load_rows():
    rows = []
    for line in (ROOT / "results" / "cells.jsonl").read_text().splitlines():
        if line.strip():
            rows.append(json.loads(line))
    return rows


def fmt(x, nd=1):
    return f"{x:.{nd}f}" if isinstance(x, (int, float)) else "—"


def model_label(m):
    ml = m.lower()
    if "bonsai" in ml or "ternary" in ml:
        return "bonsai2-27b"
    return m


def main():
    rows = load_rows()
    if not rows:
        print("no results")
        return 1

    by_model = defaultdict(list)
    for r in rows:
        by_model[model_label(r["model"])].append(r)

    # Aggregate: (model, tag) -> {(ctx, conc): (tps, vram, ok)}.
    cells = {}
    for model, mrows in by_model.items():
        for r in mrows:
            if not r["agents"]:
                continue
            a = r["agents"][-1]
            cells.setdefault((model, r["tag"]), {})[(r["ctx"], r["conc"])] = (
                a["mean_decode_tps"], a.get("peak_vram_mib"), a["ok"])

    lines = [
        "# Inference engine benchmark — RTX 3090 (TB4 eGPU, SM86, 24 GB)",
        "",
        "_Generated " + date.today().isoformat()
        + " · harness: `benchmarks/engines-2026-10/` · metric: "
        "**per-agent decode tok/s** (chars/4.1 streaming proxy, "
        "engine-validated 2026-10-08) · greedy, 256 max tokens · "
        "GPU-resident weights/KV only (no CPU offload)._",
        "",
        "## Summary",
        "",
    ]

    # Winner per model (user criterion: max throughput at high parallelism
    # at high context). High-C×deep-ctx line: at the highest concurrency
    # with ok data (C8), deepest context where >=2 engines have ok cells;
    # if only one engine ever produced ok C8 data, say so at its deepest
    # C8 cell. Peak line: max single-cell per-agent tok/s anywhere.
    winner = {}
    for model in by_model:
        grids = {tag: grid for (m, tag), grid in cells.items() if m == model}
        okc = [(tag, ctx, c, t)
               for tag, grid in grids.items()
               for (ctx, c), (t, v, ok) in grid.items() if ok > 0 and t > 0]
        if not okc:
            continue
        c8 = [(tag, ctx, t) for tag, ctx, c, t in okc if c == 8]
        hi = ""
        if c8:
            by_ctx = defaultdict(list)
            for tag, ctx, t in c8:
                by_ctx[ctx].append((tag, t))
            shared = sorted(ctx for ctx, ts in by_ctx.items() if len(ts) > 1)
            c8.sort(key=lambda x: x[1])  # by ctx
            if shared:
                ctx = shared[-1]
                ts = sorted(by_ctx[ctx], key=lambda x: -x[1])
                lbl = next(l for c, l in CTX_BUCKETS if c == ctx)
                hi = (f"C8 × {lbl}: `{ts[0][0]}` {fmt(ts[0][1])} tok/s vs "
                      f"`{ts[1][0]}` {fmt(ts[1][1])}")
            else:
                tag, ctx, t = c8[-1]
                lbl = next(l for c, l in CTX_BUCKETS if c == ctx)
                hi = f"C8 × {lbl}: only `{tag}` measured ({fmt(t)} tok/s)"
        pk_tag, _, _, pk_t = max(okc, key=lambda x: x[3])
        winner[model] = (pk_tag, pk_t, hi)

    for model in by_model:
        if model not in winner:
            continue
        pk_tag, pk_t, hi = winner[model]
        line = f"- **{model}**: peak `{pk_tag}` {fmt(pk_t)} tok/s per-agent"
        if hi:
            line += f"; at high parallelism×deep ctx — {hi}"
        lines.append(line + ".")
    lines += [
        "",
        "Tables below show per-agent decode tok/s (rows = context, "
        "cols = C1–C8) and peak VRAM MiB per cell. `—` = not measured or "
        "overflow (see ledger).",
        "",
    ]

    # Per-model, per-engine table views.
    for model in by_model:
        lines += [f"## {model}", "", "### Table views (per-agent decode tok/s)",
                  ""]
        for (m, tag), grid in sorted(cells.items()):
            if m != model:
                continue
            lines += [f"#### `{tag}`", "",
                      "| context | " + " | ".join(f"C{c}" for c in CONCS)
                      + " | peak VRAM (MiB) |", "|---|---|---|---|---|---|"]
            for ctx, lbl in CTX_BUCKETS:
                if not any((ctx, c) in grid for c in CONCS):
                    continue
                row = [lbl]
                for c in CONCS:
                    row.append(fmt(grid[(ctx, c)][0])
                               if (ctx, c) in grid else "—")
                vram = max((v for (cx, _), (t, v, ok) in grid.items()
                            if cx == ctx and v), default=None)
                row.append(fmt(vram, 0) if vram else "—")
                lines.append("| " + " | ".join(row) + " |")
            lines.append("")

        # Plot links: one PNG per C.
        pngs = sorted((ROOT / "results").glob(f"perC_{model}_c*.png"))
        if pngs:
            lines += ["### Plots", ""]
            lines += [f"![{p.stem}](engines-2026-10/results/{p.name})"
                      for p in pngs]
            lines.append("")

    # Overflow ledger.
    ov = ROOT / "results" / "overflow.jsonl"
    if ov.exists():
        lines += ["## Overflowed cells (retried once 2026-10-09; permanent "
                  "rejections kept)", ""]
        ovs = [json.loads(l) for l in ov.read_text().splitlines() if l.strip()]
        # Only ok-measured or permanent-rejected cells leave the ledger;
        # error/deadlock retries stay visible.
        try:
            verdicts = {tuple(json.loads(l)["key"]): json.loads(l)["verdict"]
                        for l in (ROOT / "results" / "retry-status.jsonl")
                        .read_text().splitlines() if l.strip()}
        except FileNotFoundError:
            verdicts = {}
        retried = {k for k, v in verdicts.items() if v in ("ok", "permanent")}
        kept = [o for o in ovs if (o["tag"], o["ctx"], o["conc"]) not in retried]
        if kept:
            lines += ["| engine | ctx | conc | reason |", "|---|---|---|---|"]
            lines += [f"| {o['tag']} | {o['ctx']} | C{o['conc']} | {o['reason']} |"
                      for o in kept]
        else:
            lines += ["_None outstanding._"]
        lines.append("")

    # Engine configurations.
    lines += [
        "## Engine configurations",
        "",
        "| engine | artifact | key flags |", "|---|---|---|",
        "| q27-t3-solo | `bonsai2-27b-t3-mtp-slim.q27` (q27 v0.14.4) | w8, spec-off, ctx 262144 |",
        "| q27-t3-mtp | same | spec=mtp draft 3 |",
        "| ninfer-all-b2 | `Ternary-Bonsai-2-27B-ninfer-v3.ninfer` (ghcr.io/iamwavecut/ninfer-all, sm86) | `--kv-dtype rk4v4 --spec dflash2 --draft-tokens 5 --no-prefix-reuse`, ctx/kv 262144 |",
        "| prism-ptq10 | `Ternary-Bonsai-2-27B-PTQ1_0.gguf` (prism llama.cpp) | PTQ1_0, flash-attn |",
        "| ninfer-061 | `/var/lib/ninfer/qwen3_8_27b.ninfer` (ninfer 0.6.1) | ctx 65536 |",
        "| ashalliants-df2 | `qwen3_8_27b.ninfer` (ashalliants 0.15.0) | spec=dflash2, ctx 262144, host KV clamped 2048 MiB via shim |",
        "| ashalliants-mtp | same | spec=mtp |",
        "",
        "## Reproduce",
        "",
        "```bash",
        "cd benchmarks/engines-2026-10",
        "python3 run_sweep.py --stage screening            # fresh+16K, C1-C8",
        "python3 run_sweep.py --stage long                 # survivors, 32K-256K",
        ".venv/bin/python analyze.py                       # CSV + plots",
        ".venv/bin/python report.py                        # this file",
        "```",
    ]

    OUT.write_text("\n".join(lines))
    print(f"wrote {OUT}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
