"""Sweep driver for the 3090 engine benchmark.

Stage 1 (screening): fresh + 16K context, conc 1,2,4,8 - one cell per
engine, per-agent decode tok/s as primary metric. Top survivors advance
to the long-context stage (32K..252K) and wider conc.

Resume-safe: cells already present in results/cells.jsonl are skipped.

Usage: python3 run_sweep.py [--stage screening] [--only tag,tag] [--reps N]
"""
import argparse, json, time
from pathlib import Path

import bench, engines

ROOT = Path(__file__).resolve().parent
RESULTS = ROOT / "results"
SCREEN_CONC = [1, 2, 4, 8]
SCREEN_CTX = [0, 16384]     # 0 = fresh (tiny prompt)
LONG_CTX = [32768, 65536, 131072, 262144]
BONSAI = ["q27-t3-mtp", "q27-t3-solo", "prism-ptq10", "ninfer-all-b2"]
# buun-ptq10 dropped 2026-10-09: buun-llama-cpp @ b9637 lacks PrismML
# weight types (PTQ1_0 = ggml type 143 unsupported) - bonsai2 GGUF will
# not load. buun line continues as the Qwen3.8 TCQ-KV arm instead.
# q27-q4s / ninfer-all-q38 dropped: no Qwen3.8 artifact staged for either
# engine (only bonsai2 t2/t3 .q27 and bonsai2 .ninfer exist; qwen38 lives in
# .ninfer form under ninfer-061/ashalliants only).
QWEN = ["ninfer-061", "ashalliants-df2", "ashalliants-mtp", "gguf-q4xs",
        "buun-qwen", "swift-uncensored",
        # 2026-10-10 variant campaign (user roster): every arm runs the
        # full screening + long ladder on its engine entry.
        "coder390", "swift15", "huihui-abl", "obliterated",
        "thinkingcap", "davidau-fable", "humanlike", "fable5"]
# 2026-10-09 scouting drops (scout-reports.log cand-scout#1-3): EXL3
# (serve_openai has no SSE streaming, 1.22 GiB verify-history per C8 slot,
# FIFO batch=1 serializes >=32k cells), HyperQwen vLLM 0.30 (per-agent C8
# 47-51 t/s vs ashalliants-df2 155.7, torch.compile RAM on 15 GiB host,
# KV pool caps ctx*conc at ~205k), sybil sglang (TP1 preset: 8k ctx cap,
# 43 t/s flat C1-C8).


def done_keys():
    """Cells already measured OR already marked overflow (never retried)."""
    keys = set()
    p = RESULTS / "cells.jsonl"
    if p.exists():
        for line in p.read_text().splitlines():
            try:
                r = json.loads(line)
                keys.add((r["tag"], r["ctx"], r["conc"]))
            except Exception:
                pass
    ov = RESULTS / "overflow.jsonl"
    if ov.exists():
        for line in ov.read_text().splitlines():
            if line.strip():
                o = json.loads(line)
                keys.add((o["tag"], o["ctx"], o["conc"]))
    return keys


def prefill_ram_guard(engine_tag, ctx, conc):
    """Skip cells whose concurrent long prefill would overflow the 15 GiB host.

    q27 stages 16K-prompt KV in host RAM (~5 GiB per concurrent 16K prompt
    observed: C1/C2 pass, C4 pushed user.slice to 91.6% pressure and oomd
    killed the sweep). Cells that would overflow are recorded as
    "overflow" and NOT retried (user rule 2026-10-08).
    Returns skip-reason or None.
    """
    if ctx == 0 or engine_tag not in ("q27-t3-mtp", "q27-t3-solo"):
        return None
    # Engine-measured staging bound (2026-10-08): q27 held 326K KV rows
    # (C2 x 163K real tokens) but oomd killed C4 x 163K (653K rows).
    if ctx * conc > 400_000:
        return (f"overflow: {engine_tag} ctx{ctx} x C{conc} = {ctx*conc} KV rows "
                "exceeds measured 400K host-RAM staging bound")
    return None


def run(engine_tags, ctxs, concs, max_tokens=256, reps=1):
    keys = done_keys()
    for tag in engine_tags:
        try:
            cfg = engines.get(tag)
        except SystemExit:
            print(f"SKIP {tag}: not registered"); continue
        for ctx in ctxs:
            for conc in concs:
                if (tag, ctx, conc) in keys:
                    print(f"skip done {tag} ctx={ctx} c={conc}")
                    continue
                skip = prefill_ram_guard(tag, ctx, conc)
                if skip:
                    print(f"OVERFLOW {tag} ctx={ctx} c={conc}: {skip}")
                    with RESULTS.joinpath("overflow.jsonl").open("a") as fh:
                        fh.write(json.dumps({"tag": tag, "ctx": ctx,
                                             "conc": conc, "reason": skip}) + "\n")
                    continue
                print(f"=== {tag} ctx={ctx} c={conc} ===", flush=True)
                try:
                    engines.start(cfg)
                except RuntimeError as e:
                    print(f"START-FAIL {tag}: {e}")
                    RESULTS.joinpath("start-failures.log").open("a").write(
                        f"{tag} ctx={ctx}: {e}\n")
                    break  # engine unusable; skip its remaining cells
                try:
                    # Cell wall budget: 4x the largest sane TTFT observed at
                    # this ctx+conc. q27 16K C4+ deadlocks in the KV scheduler
                    # (rid never starts, TTFT > 750s), so a cell that burns
                    # 20 min with no first token is recorded and abandoned
                    # rather than stalling the whole sweep.
                    cell_budget = 900 if ctx == 0 else 1200
                    bench.CELL_BUDGET_S = cell_budget
                    agg = bench.run_cell(cfg, ctx, conc, str(RESULTS),
                                         max_tokens=max_tokens, reps=reps)
                    print(json.dumps(agg["agents"][-1], ensure_ascii=False))
                    if agg["agents"][-1]["ok"] == 0:
                        print(f"DEADLOCK {tag} ctx={ctx} c={conc}; skipping "
                              "higher conc at this ctx")
                        break
                finally:
                    engines.stop(cfg)
                time.sleep(2)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--stage", choices=["screening", "long"], default="screening")
    ap.add_argument("--only", default="", help="comma-separated engine tags")
    ap.add_argument("--reps", type=int, default=1)
    ap.add_argument("--max-tokens", type=int, default=256)
    a = ap.parse_args()
    tags = [t for t in (a.only.split(",") if a.only else BONSAI + QWEN) if t]
    if a.stage == "screening":
        run(tags, SCREEN_CTX, SCREEN_CONC, a.max_tokens, a.reps)
    else:
        # Survivor list fixed from screening 2026-10-08 (see frontier.json):
        # Bonsai: ninfer-all-b2 (fastest everywhere, 65K window),
        #         q27-t3-solo (C2-C8 winner, 262K window via 163K-proven runs).
        # Qwen:   ashalliants-df2 (all-conc winner, 262K window).
        # Dropped: prism-ptq10 (2-6x slower everywhere), q27-t3-mtp (loses to
        #          solo at C2+), ashalliants-mtp (loses to df2 everywhere),
        #          ninfer-061 (3-7x slower).
        windows = {
            "ninfer-all-b2": [32768, 65536],          # --max-context 65536 cap
            "q27-t3-solo": [32768, 65536, 131072, 262144],
            "ashalliants-df2": [32768, 65536, 131072, 262144],
            # Same artifact family as ashalliants-df2 (uncensored
            # abliteration of Qwen3.8-27B): tuned profile window is
            # identical 262144 ctx, same ladder.
            "swift-uncensored": [32768, 65536, 131072, 262144],
            # Smoke-verified per-slot ceilings (2026-10-09): buun TCQ KV
            # 65536/slot (524288 total, 19.7 GiB); gguf q8 KV 32768/slot
            # (262144 total, ~22.3 GiB est).
            "buun-qwen": [32768, 65536],
            "gguf-q4xs": [32768],
        }
        for tag in tags:
            run([tag], windows.get(tag, LONG_CTX), [1, 4, 8],
                a.max_tokens, a.reps)


if __name__ == "__main__":
    main()
