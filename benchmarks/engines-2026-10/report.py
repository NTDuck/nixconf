#!/usr/bin/env python3
"""Generate benchmarks/INFERENCE-ENGINES.md from results/ artifacts.

Inputs: results/cells.jsonl, results/summary.csv (optional), results/*.png.
Output: ../INFERENCE-ENGINES.md (i.e. benchmarks/INFERENCE-ENGINES.md).
"""
import json
import sys
from collections import defaultdict
from datetime import date
from pathlib import Path

ROOT = Path(__file__).parent
OUT = ROOT.parent / "INFERENCE-ENGINES.md"


def load_rows():
    rows = []
    for line in (ROOT / "results" / "cells.jsonl").read_text().splitlines():
        if line.strip():
            rows.append(json.loads(line))
    return rows


def fmt(x, nd=1):
    return f"{x:.{nd}f}" if isinstance(x, (int, float)) else "—"


def main():
    rows = load_rows()
    if not rows:
        print("no results"); return 1

    by_model = defaultdict(list)
    for r in rows:
        by_model[r["model"]].append(r)

    lines = [
        "# Inference engine benchmark — RTX 3090 (TB4 eGPU, SM86, 24 GB)",
        "",
        f"_Generated {date.today().isoformat()} · harness: `benchmarks/engines-2026-10/` "
        "· metric: **per-agent decode tok/s** (chars/5.72 streaming proxy, "
        "engine-validated 2026-10-08) · greedy, thinking off, 256 max tokens · "
        "GPU-resident weights/KV only (no CPU offload)._",
        "",
        "## Method",
        "",
        "- Axes: context prefill (fresh, 16k, 32k, 64k, 131k, 262k) × concurrency (C1–C8).",
        "- Screening at fresh + 16K, C1/C2/C4/C8; survivors run the long-context ladder.",
        "- Per-agent tok/s = the tok/s ONE agent observes while N agents stream "
        "concurrently; aggregate tok/s shown for capacity context.",
        "- VRAM = 0.5 s sampled peak during generation.",
        "- Engine restart before each candidate; GPU must be empty (verified).",
        "",
        "## Verdict (per model, Pareto-optimal engine)",
        "",
        "**Ternary Bonsai-2 27B**",
        "",
        "- **C1 (single agent), any ctx ≤ 64k: `ninfer-all-b2`** — 267.5 t/s fresh, "
        "225.8 @32k, 197.9 @64k. ~2.3x the q27 runner-up at C1.",
        "- **C2–C8 (multi-agent): `q27-t3-solo`** — flat 115–119 t/s fresh up to C8, "
        "71 t/s @32k, 53 t/s @64k C1; but host-RAM staging caps it: ≥ C8@64k, "
        "≥ C4@128k, ≥ C4@256k overflow (see ledger). ninfer-all-b2 outruns it at "
        "C2 fresh (194 vs 119.5) — use ninfer-all-b2 up to 32k even multi-agent.",
        "- Cross-over: below ~32k contexts ninfer-all-b2 wins at every C; q27-t3-solo "
        "only takes the crown at 64k+ multi-agent where ninfer-all's decode "
        "collapses (42.7 C4 / 24.6 C8 @64k).",
        "- prism-ptq10 (llama.cpp GGUF) is dominated everywhere (20–62 t/s); drop it.",
        "",
        "**Qwen3.8 27B**",
        "",
        "- **`ashalliants-df2` (DFlash2 spec decode) wins every cell measured** — "
        "162.7 t/s fresh C1, holds 143–156 t/s per-agent through C8@16k and still "
        "89–92 t/s at 256k × C8. Only engine that ran the full 262k ladder.",
        "- ashalliants-mtp loses 30–45% at every point (its spec lane is slower than "
        "DFlash2 K=7); ninfer-061 collapses beyond C1 (22.9 t/s @C8) — drop both.",
        "- Host RAM: tuned profile pins 8 GiB host KV by default; the report config "
        "clamps it to 2 GiB (shim) — throughput numbers are with the clamp.",
        "",
        "### Caveats",
        "",
        "- ash 262k C4/C8 cells show ok=3/4 and 3/8: one agent per cell hit the "
        "262,144-token window (258k prompt + chat template + 256 output); the "
        "engine rejected just those requests. Aggregate throughput unaffected "
        "(mean is over served agents).",
        "- 16k 'C1: 86.7' for q27-t3-mtp vs solo 85.0: within noise (~2%), not a win.",
        "",
    ]

    # Pareto tables per model
    for model, mrows in by_model.items():
        fresh = [r for r in mrows if r["ctx"] == 0]
        engines = sorted({r["tag"] for r in fresh})
        lines += [f"## {model}", "", "### Screening (fresh context)", "",
                  "| engine | C1 | C2 | C4 | C8 | peak VRAM (MiB) |",
                  "|---|---|---|---|---|---|"]
        vram = {r["tag"]: r["agents"][-1]["peak_vram_mib"] for r in fresh}
        for eng in engines:
            cells = {r["conc"]: r["agents"][-1]["mean_decode_tps"]
                     for r in fresh if r["tag"] == eng}
            lines.append("| {} | {} | {} | {} | {} | {} |".format(
                eng,
                fmt(cells.get(1)), fmt(cells.get(2)),
                fmt(cells.get(4)), fmt(cells.get(8)),
                max((v for k, v in vram.items() if k == eng), default=0)))
        lines.append("")

        long = sorted({r["ctx"] for r in mrows if r["ctx"] not in (0,)})
        if long:
            lines += ["### Long context (per-agent decode tok/s)", ""]
            fkey = model + "@ctx"
            if fkey in (json.loads(fj.read_text()) if (fj := ROOT / "results" / "frontier.json").exists() else {}):
                per_ctx = json.loads((ROOT / "results" / "frontier.json").read_text())[fkey]
                for ctx in long:
                    key = str(ctx)
                    if key not in per_ctx:
                        continue
                    lines.append(f"**{ctx//1024}k**: " + "; ".join(
                        f"C{s['conc']}: {fmt(s['best_tps'])} t/s ← {'/'.join(s['winners'])}"
                        for s in per_ctx[key]) + "")
                    lines.append("")
            lines += ["### Long context, C1 per-agent decode tok/s", "",
                      "| engine | " + " | ".join(f"{c//1024}k" for c in long) + " |",
                      "|---" * (len(long) + 1) + "|"]
            for eng in engines:
                cells = {r["ctx"]: r["agents"][-1]["mean_decode_tps"]
                         for r in mrows if r["tag"] == eng and r["conc"] == 1}
                if cells:
                    lines.append(f"| {eng} | " +
                                 " | ".join(fmt(cells.get(c)) for c in long) + " |")
            lines.append("")

        pngs = sorted((ROOT / "results").glob(f"*{model.replace('.', '_').replace('/', '_')}*.png"))
        if pngs:
            lines += ["### Plots", ""]
            lines += [f"![{p.stem}]({p.relative_to(OUT.parent).as_posix()})"
                      for p in pngs]
            lines.append("")

    # Overflow ledger (user rule: overflow cells recorded, never retried)
    ov = ROOT / "results" / "overflow.jsonl"
    if ov.exists():
        lines += ["## Overflowed cells (not retried)", "",
                  "Concurrent long-context prefills that exceed host RAM "
                  "(15 GiB, ~6 GiB free). Marked overflow per policy.", "",
                  "| engine | ctx | conc | reason |", "|---|---|---|---|"]
        for line in ov.read_text().splitlines():
            if not line.strip():
                continue
            o = json.loads(line)
            lines.append(f"| {o['tag']} | {o['ctx']//1024}k | C{o['conc']} "
                         f"| {o['reason']} |")
        lines.append("")

    # Frontier summary
    fj = ROOT / "results" / "frontier.json"
    if fj.exists():
        frontier = json.loads(fj.read_text())
        lines += ["## Pareto frontier (fresh ctx, per-agent tok/s)", ""]
        for model, surv in frontier.items():
            if model.endswith("@ctx"):
                continue  # per-ctx winners already rendered inside model sections
            lines.append(f"**{model}**: " + "; ".join(
                f"C{s['conc']}: {fmt(s['best_tps'])} t/s ← {'/'.join(s['winners'])}"
                for s in surv) + "")
            lines.append("")

    lines += [
        "## Engine configurations",
        "",
        "| engine | artifact | key flags |",
        "|---|---|---|",
        "| q27-t3-solo | `bonsai2-27b-t3-mtp-slim.q27` (q27 v0.14.4) | w8, spec-off, ctx 262144 |",
        "| q27-t3-mtp | same | spec=mtp draft 3 |",
        "| ninfer-all-b2 | `Ternary-Bonsai-2-27B-ninfer-v3.ninfer` (ghcr.io/iamwavecut/ninfer-all, sm86) | `--kv-dtype rk4v4 --spec dflash2 --draft-tokens 5 --no-prefix-reuse` (host KV pin avoided), ctx/kv 262144 |",
        "| prism-ptq10 | `Ternary-Bonsai-2-27B-PTQ1_0.gguf` (prism llama.cpp) | PTQ1_0, flash-attn |",
        "| ninfer-061 | `/var/lib/ninfer/qwen3_8_27b.ninfer` (ninfer 0.6.1) | ctx 65536 |",
        "| ashalliants-df2 | `qwen3_8_27b.ninfer` (ashalliants 0.15.0) | spec=dflash2, ctx 262144, host KV clamped 8192→2048 MiB via `ninfer-serve.hostkv-shim` (oomd), full `LD_LIBRARY_PATH` from prism/nvidia-x11/ffmpeg/curl store paths |",
        "| ashalliants-mtp | same | spec=mtp |",
        "",
        "## Reproduce",
        "",
        "```bash",
        "cd benchmarks/engines-2026-10",
        "python3 run_sweep.py --stage screening            # fresh+16K, C1-C8",
        "python3 run_sweep.py --stage long --only ninfer-all-b2,q27-t3-solo,ashalliants-df2",
        ".venv/bin/python analyze.py                       # CSV + PNG + frontier.json",
        ".venv/bin/python report.py                        # this file",
        "```",
        "",
    ]

    OUT.write_text("\n".join(lines))
    print(f"wrote {OUT}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
