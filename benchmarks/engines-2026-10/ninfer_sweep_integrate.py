#!/usr/bin/env python3
"""Integrate ninfer-shape-sweep.json into the module's SHAPES + ninferShapeTable.

Reads results/ninfer-shape-sweep.json:
  {"model-id": {"16384": {"conc": 8, "tps": 155.4, "peak_mib": 21162} | null, ...}}

Rewrites, in modules/.../ninfer/default.nix:
  - SHAPES:      "mid|ctx:conc:peak:tps,..." for each MEASURED ctx (ctx ascending);
                 null cells dropped (engine can't run that ctx at any C).
  - ninferShapeTable: "mid|C1xNNk(tps),..." k = floor(ctx/1000), parens omitted
                 when tps == 0.

Preserves each row's leading comment block (matched by model-id literal).
Idempotent: re-running with the same JSON produces the same file.
"""
import json
import re
import sys
from pathlib import Path

MODULE = Path(sys.argv[1] if len(sys.argv) > 1 else
              "modules/hosts/lenovo-legion-16iah7h-PF3XJ8SP/private/dev/agentics/ninfer/default.nix")
RESULTS = Path(sys.argv[2] if len(sys.argv) > 2 else
               "benchmarks/engines-2026-10/results/ninfer-shape-sweep.json")

sweep = json.loads(RESULTS.read_text())
src = MODULE.read_text()

CTXS = [16384, 32768, 65536, 131072, 262144]

for mid, cells in sweep.items():
    # measured cells only, ctx ascending
    rows = []
    for ctx in CTXS:
        cell = cells.get(str(ctx))
        if not cell:
            continue
        rows.append((ctx, int(cell["conc"]), int(cell["peak_mib"]), int(round(cell["tps"]))))
    if not rows:
        continue

    shapes_row = mid + "|" + ",".join(f"{c}:{n}:{p}:{t}" for c, n, p, t in rows)
    def tok(c, ctx, t):
        k = ctx // 1000
        return f"{c}x{k}k" + (f"({t})" if t else "")
    table_row = mid + "|" + ",".join(tok(n, c, t) for c, n, p, t in rows)

    # Replace the SHAPES data line for this model. Distinguish the
    # three "mid|..." lines: SHAPES row = 2-space indented + starts
    # "<ctx>:<conc>:"; MODELS row = human name; ninferShapeTable row =
    # indented + starts "<C>x". Each replacement consumes the WHOLE
    # line (up to the closing quote) to avoid leaving stale tails.
    pat = re.compile(rf'\n(\s+)"{re.escape(mid)}\|\d+:')
    m = pat.search(src)
    n_sh = 0
    if m:
        start = m.start() + 1
        end = src.index('"\n', start) + 2
        src = src[:start] + f'{m.group(1)}"{shapes_row}"\n' + src[end:]
        n_sh = 1

    # Replace the ninferShapeTable token line (indented + starts "<C>x")
    pat_tb = re.compile(rf'\n(\s+)"{re.escape(mid)}\|\d+x[^"]*"')
    src, n_tb = pat_tb.subn(lambda m: '\n' + m.group(1) + f'"{table_row}"', src, count=1)

    print(f"{mid}: shapes={n_sh} table_ok={n_tb} rows={len(rows)}")

MODULE.write_text(src)
print("written", MODULE)
