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
    if "qwen38-27b" in ml or "qwen3.8-27b" in ml:
        return "qwen3.8-27b"
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
        "Sweep screened " + str(len({r['tag'] for r in rows}))
        + " engine configurations across two model families on one RTX "
        "3090 (TB4 eGPU): screening (fresh + 16k, C1–C8) then a long "
        "ladder (32k–256k, C1/C4/C8) for survivors. Metric is per-agent "
        "decode tok/s: what one agent observes while N agents stream "
        "concurrently on the same engine. Cells that overflowed the 15 "
        "GiB host or deadlocked the engine are ledgered, not averaged "
        "in. Peak VRAM per cell is reported beside each table.",
        "",
    ]

    # Winner computation (user criterion: max throughput at high
    # parallelism at high context). High-C×deep-ctx line: at the highest
    # concurrency with ok data (C8), deepest context where >=2 engines
    # have ok cells; if only one engine ever produced ok C8 data, say so
    # at its deepest C8 cell. Peak line: max single-cell per-agent tok/s
    # anywhere. Rendered in the closing "## Winner" section.
    #
    # Lane-aware (2026-10-10): swift-uncensored runs the mtp lane — its
    # artifact has no dflash2 draft weights, so it is comparable only
    # to ashalliants-mtp, never to the ashalliants-df2 winner. Exclude
    # it from the cross-engine ranking and rank it inside its own lane.
    COMPARABLE_EXCLUDED = {"swift-uncensored"}
    winner = {}
    for model in by_model:
        grids = {tag: grid for (m, tag), grid in cells.items() if m == model}
        rank = {tag: grid for tag, grid in grids.items()
                if tag not in COMPARABLE_EXCLUDED}
        okc = [(tag, ctx, c, t)
               for tag, grid in rank.items()
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
        # Same-lane sibling for every excluded variant with data.
        LANE_CONTROL = {"swift-uncensored": "ashalliants-mtp"}
        for var in COMPARABLE_EXCLUDED:
            vgrid = grids.get(var)
            if not vgrid:
                continue
            vok = [(ctx, c, t) for (ctx, c), (t, v, ok) in vgrid.items()
                   if ok > 0 and t > 0]
            if not vok:
                continue
            vc8 = sorted(((ctx, c, t) for ctx, c, t in vok if c == 8),
                         key=lambda x: (-x[0], -x[2]))
            lane = ""
            if vc8:
                ctx, c, t = vc8[0]
                lbl = next(l for cc, l in CTX_BUCKETS if cc == ctx)
                ctl = next((t2 for (cx, cc), (t2, _, ok) in rank.get(
                    LANE_CONTROL[var], {}).items()
                    if cx == ctx and cc == c and ok > 0), None)
                if ctl:
                    delta = (t - ctl) / ctl * 100
                    lane = (f"{var} (mtp lane) C8 × {lbl}: {fmt(t)} tok/s, "
                            f"{delta:+.1f}% vs `{LANE_CONTROL[var]}` "
                            f"{fmt(ctl)}")
                else:
                    lane = f"{var} (mtp lane) C8 × {lbl}: {fmt(t)} tok/s"
            else:
                ctx, c, t = max(vok, key=lambda x: (x[0], x[2]))
                lbl = next(l for cc, l in CTX_BUCKETS if cc == ctx)
                lane = f"{var} (mtp lane) deepest C8 cell at {lbl}: {fmt(t)} tok/s"
            hi = (hi + "; " + lane) if hi else lane
        winner[model] = (pk_tag, pk_t, hi)

    winner_lines = []
    for model in by_model:
        if model not in winner:
            continue
        pk_tag, pk_t, hi = winner[model]
        line = f"- **{model}**: peak `{pk_tag}` {fmt(pk_t)} tok/s per-agent"
        if hi:
            line += f"; at high parallelism×deep ctx — {hi}"
        winner_lines.append(line + ".")
    lines += [
        "",
        "Per-engine sections below pair each engine's configuration with "
        "its result table: per-agent decode tok/s (rows = context, "
        "cols = C1–C8) and peak VRAM MiB per cell. `—` = not measured or "
        "overflow (see ledger).",
        "",
    ]

    # Per-model 3D surfaces in the summary (user spec: paragraph + plots).
    surf_pngs = sorted((ROOT / "results").glob("surf3d_*.png"))
    if surf_pngs:
        lines += ["### Throughput surfaces", "",
                  "Z = per-agent decode tok/s (up = faster), X = context, "
                  "Y = parallelism k. One surface per engine; measured "
                  "cells are dotted, gaps are unmeasured/overflowed.", ""]
        lines += [f"![{p.stem}](engines-2026-10/results/{p.name})"
                  for p in surf_pngs]
        lines.append("")

    ENGINE_CONFIG = {
        "q27-t3-solo": ("`bonsai2-27b-t3-mtp-slim.q27` (q27 v0.14.4)",
                        "w8 stack 2.3 GiB, spec-off, ctx 262144, slots 1"),
        "q27-t3-mtp": ("`bonsai2-27b-t3-mtp-slim.q27` (q27 v0.14.4)",
                       "spec=mtp draft 3, slots 8"),
        "ninfer-all-b2": ("`Ternary-Bonsai-2-27B-ninfer-v3.ninfer` "
                          "(ghcr.io/iamwavecut/ninfer-all, sm86)",
                          "`--kv-dtype rk4v4 --spec dflash2 --draft-tokens 5 "
                          "--no-prefix-reuse`, ctx/kv 262144"),
        "prism-ptq10": ("`Ternary-Bonsai-2-27B-PTQ1_0.gguf` (prism llama.cpp)",
                        "PTQ1_0, flash-attn, ctx 32768, np 4"),
        "ninfer-061": ("`/var/lib/ninfer/qwen3_8_27b.ninfer` (ninfer 0.6.1)",
                       "ctx 65536, kv int8, spec=mtp draft 3"),
        "ashalliants-df2": ("`qwen3_8_27b.ninfer` (ashalliants 0.15.0)",
                            "spec=dflash2, ctx 262144, rk4v4 KV, host KV "
                            "clamped 2048 MiB via shim, FALLBACK=off"),
        "ashalliants-mtp": ("`qwen3_8_27b.ninfer` (ashalliants 0.15.0)",
                            "spec=mtp, ctx 262144, host KV shim 2048 MiB"),
        "swift-uncensored": ("`swift_qwen3_8_27b_v3.ninfer` (Swift-Qwen3.8-27B-"
                             "Uncensored, d0xin abliteration; same 0.15.0 "
                             "binary as ashalliants-mtp)",
                             "spec=mtp, ctx 262144, NINFER_MODEL override, "
                             "host KV shim 2048 MiB, FALLBACK=off"),
        "buun-qwen": ("`Qwen3.8-27B-UD-IQ4_XS.gguf` (buun-llama-cpp b9637)",
                      "TCQ KV `turbo2_tcq`, `-c 524288 -np 8` "
                      "(per-slot 65536), flash-attn"),
        "gguf-q4xs": ("`Qwen3.8-27B-UD-IQ4_XS.gguf` (prism llama.cpp CUDA)",
                      "q8_0 KV, `-c 262144 -np 8` (per-slot 32768), "
                      "flash-attn"),
    }

    # Per-model -> per-engine sections: configuration + result table
    # live in the same block (user spec 2026-10-10).
    for model in by_model:
        model_tags = sorted(t for (m, t) in cells if m == model)
        lines += [f"## {model}", ""]
        for tag in model_tags:
            grid = cells[(model, tag)]
            artifact, flags = ENGINE_CONFIG.get(tag, ("—", "—"))
            lines += [f"### `{tag}`", "",
                      f"- **Artifact:** {artifact}",
                      f"- **Flags:** {flags}", "",
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

    # Lane comparability caveat (swift artifact lacks dflash2 weights).
    lines += ["## Lane comparability", ""]
    lines += [
        "`swift-uncensored` runs the **mtp lane** (spec=mtp), not the "
        "tuned dflash2 profile of `ashalliants-df2`: the converted "
        "artifact is the 1124-object flavor — full MTP draft weights "
        "but no dflash2 draft weights (0 of the baseline's 56 "
        "dflash2-bound weights, 1.11 GiB) — so the dflash2 profile is "
        "structurally impossible and the engine rejects it. The "
        "apples-to-apples comparison is therefore **swift-uncensored vs "
        "`ashalliants-mtp`** (same binary, spec, and profile; "
        "abliterated weights are the only variable). Do not rank "
        "swift-uncensored against `ashalliants-df2`.",
        "",
    ]

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

    # Winner section (user spec 2026-10-10: paragraph + per-model 3D
    # plots close the report).
    lines += ["## Winner", ""]
    if winner_lines:
        lines += winner_lines
    else:
        lines += ["_No model produced ok cells._"]
    if (ROOT / "results" / "surf3d_frontier.png").exists():
        lines += ["", "Throughput frontier — best measured per-agent decode "
                  "tok/s per model (Z = tok/s up = faster, X = context, "
                  "Y = parallelism k):", "",
                  "![winner frontier](engines-2026-10/results/"
                  "surf3d_frontier.png)"]
    lines += [
        "",
        "## Reproduce",
        "",
        "```bash",
        "cd benchmarks/engines-2026-10",
        "python3 run_sweep.py --stage screening            # fresh+16K, C1-C8",
        "python3 run_sweep.py --stage long                 # survivors, 32K-256K",
        ".venv/bin/python analyze.py                       # CSV + 3D surfaces",
        ".venv/bin/python report.py                        # this file",
        "```",
    ]

    OUT.write_text("\n".join(lines))
    print(f"wrote {OUT}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
