#!/usr/bin/env python3
"""Render results/ninfer-shape-sweep.json into results/ninfer-shape-sweep-summary.md."""
import json, sys
from pathlib import Path

d = json.loads(Path(sys.argv[1] if len(sys.argv) > 1 else
    "benchmarks/engines-2026-10/results/ninfer-shape-sweep.json").read_text())
CTXS = [16384, 32768, 65536, 131072, 262144]
lines = ["# ninfer max-concurrency x context sweep (2026-11-12)", "",
         "max C that starts without OOM/refusal; tps = per-agent decode tok/s at that C",
         "(median of 2 reps x C concurrent lanes); peak = engine VRAM MiB during probe.", "",
         "| model | " + " | ".join(f"{c//1000}k" for c in CTXS) + " |",
         "|---|" + "---|" * len(CTXS)]
for mid in sorted(d):
    cells = []
    for ctx in CTXS:
        c = d[mid].get(str(ctx))
        cells.append("-" if not c else f"C{c['conc']} {round(c['tps'])}tps {c['peak_mib']}MiB")
    lines.append(f"| {mid} | " + " | ".join(cells) + " |")
out = Path(sys.argv[2] if len(sys.argv) > 2 else
           "benchmarks/engines-2026-10/results/ninfer-shape-sweep-summary.md")
out.write_text("\n".join(lines) + "\n")
print("wrote", out)
