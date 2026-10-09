#!/usr/bin/env python3
"""One-time retry of overflow-marked cells (user rule 2026-10-09).

Each cell in results/overflow.jsonl is retried at most once. Verdicts go
to results/retry-status.jsonl:
- "ok": measured; bench.run_cell appended the row to cells.jsonl itself.
- "error": start/run failure; ledger row stays visible in the report.
- "permanent": ctx*conc exceeds the measured 400K host-RAM staging bound;
  not a transient condition, never retried again.

Usage: python3 retry_overflow.py
"""
import json, sys
from pathlib import Path

import bench, engines

ROOT = Path(__file__).parent
RESULTS = ROOT / "results"
STAGING_BOUND = 400_000  # q27 host-RAM KV staging bound (2026-10-08)


def retry_state():
    p = RESULTS / "retry-status.jsonl"
    if not p.exists():
        return {}
    st = {}
    for line in p.read_text().splitlines():
        if line.strip():
            r = json.loads(line)
            st[tuple(r["key"])] = r["verdict"]
    return st


def main():
    ov = RESULTS / "overflow.jsonl"
    if not ov.exists():
        print("no overflow ledger")
        return 0
    done = retry_state()
    rows = [json.loads(l) for l in ov.read_text().splitlines() if l.strip()]
    for o in rows:
        key = (o["tag"], o["ctx"], o["conc"])
        if key in done:
            print(f"skip retried {key}")
            continue
        if o["ctx"] * o["conc"] > STAGING_BOUND:
            verdict, err = "permanent", "exceeds measured 400K staging bound"
        else:
            try:
                cfg = engines.get(o["tag"])
                engines.start(cfg)
                bench.CELL_BUDGET_S = 900 if o["ctx"] == 0 else 1200
                agg = bench.run_cell(cfg, o["ctx"], o["conc"], str(RESULTS))
                last = agg["agents"][-1]
                ok = last["ok"]
                verdict, err = ("ok" if ok else "deadlock"), None
                print(json.dumps(last, ensure_ascii=False))
            except Exception as e:
                verdict, err = "error", str(e)[:300]
            finally:
                try:
                    engines.stop(cfg)
                except Exception:
                    pass
        with (RESULTS / "retry-status.jsonl").open("a") as fh:
            fh.write(json.dumps({"key": list(key),
                                 "verdict": verdict, "err": err}) + "\n")
        print(f"{key} -> {verdict}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
