#!/usr/bin/env python3
"""ninfer per-model max-concurrency x context sweep (2026-11-12).

For every deployed ninfer model unit and each candidate context, find the
MAXIMUM concurrency the engine starts without OOM/refusal, and measure the
per-agent decode tok/s at that concurrency (the value the CLI displays as
Cx{ctx}k(tps)).

Resource-safety contract (user directive, 2026-11-12):
- ONE engine start at a time; never parallel loads (15 GiB RAM box).
- Run under systemd-run (survives agent terminals); nice/ionice.
- Between shapes: stop the unit, sleep, only then start the next
  (VRAM must fully drain before the next weight load).

Method per (model, ctx):
  for C in 8..1:
    write /var/lib/ninfer/shape-<unit>.env (NINFER_CONCURRENCY/CONTEXT/
    KV_CAPACITY/HOST_STATE_SLOTS), systemctl restart <unit>
    wait healthy (curl /v1/models, 180s); on timeout -> OOM/refusal ->
    stop unit, next lower C.
    healthy -> bench probe: 1 warmup + measured reps at C lanes via
    bench.py sse_chat (per-agent decode tps = median of lane medians);
    record; stop unit; break.
Result: results/ninfer-shape-sweep.json + .log.
"""

import json
import os
import statistics
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).parent
sys.path.insert(0, str(ROOT))
import bench  # noqa: E402  (sse_chat, vram_used_mib, wait_healthy)

RESULTS = ROOT / "results"
RESULTS.mkdir(exist_ok=True)
OUT_JSON = RESULTS / "ninfer-shape-sweep.json"
LOG = RESULTS / "ninfer-shape-sweep.log"
SHAPE_DIR = Path("/var/lib/ninfer")
PORT = 8092

# model-id -> (unit, spec). spec only matters for reporting.
MODELS = [
    # 2026-11-13: huihui-abl + coder390 re-converted (GPU) + re-ingested; rows live.
    ("qwen3.8-27b-abliterated", "ninfer-df2-abliterated", "mtp"),
    ("qwen3.8-27b-coder390", "ninfer-df2-coder390", "dflash2"),
    ("qwen3.8-27b", "ninfer-df2", "dflash2"),
    ("qwen3.8-27b-turbo", "ninfer-df2-turbo", "mtp"),
    ("bonsai2-27b", "bonsai2", "mtp"),
    ("bonsai2-27b-abliterated", "bonsai2-abliterated", "mtp"),
]
CTXS = [16384, 32768, 65536, 131072, 262144]
CONCS = [8, 7, 6, 5, 4, 3, 2, 1]
REPS = 2  # measured reps per (ctx, C); median-of-lane-medians per rep
MODEL_ID = "test"  # set by healthy() from /v1/models
PROMPT_CACHE = {}  # ctx_tokens -> [C prompts]; corpus_prompt is CPU-heavy


def log(msg):
    line = f"[{time.strftime('%H:%M:%S')}] {msg}"
    print(line, flush=True)
    with open(LOG, "a") as f:
        f.write(line + "\n")


def sh(cmd, **kw):
    return subprocess.run(cmd, shell=isinstance(cmd, str),
                          capture_output=True, text=True, **kw)


def stop_unit(unit):
    sh(["systemctl", "--no-ask-password", "stop", unit])
    # let VRAM + RAM drain before ANY next start (user resource directive)
    for _ in range(60):
        r = sh(["systemctl", "is-active", "--quiet", unit])
        if r.returncode != 0:
            break
        time.sleep(1)
    time.sleep(5)


def write_shape(unit, conc, ctx):
    p = SHAPE_DIR / f"shape-{unit}.env"
    p.write_text(
        f"NINFER_CONCURRENCY={conc}\n"
        f"NINFER_CONTEXT={ctx}\n"
        f"NINFER_KV_CAPACITY={ctx}\n"
        f"NINFER_HOST_STATE_SLOTS={conc}\n"
    )
    return str(p)


def clear_shape(unit):
    p = SHAPE_DIR / f"shape-{unit}.env"
    p.unlink(missing_ok=True)


def start_unit(unit):
    sh(["systemctl", "--no-ask-password", "start", unit])


def healthy(deadline=240):
    # /v1/models returns 200 while weights are still loading (observed
    # 2026-11-12: "model_loading" body -> 503 on chat). Readiness =
    # a 1-token chat completion returning 200.
    global MODEL_ID
    end = time.time() + deadline
    while time.time() < end:
        r = sh(["curl", "-s", "-m", "5", f"http://127.0.0.1:{PORT}/v1/models"])
        if r.returncode != 0 or not r.stdout.strip():
            time.sleep(4)
            continue
        try:
            MODEL_ID = json.loads(r.stdout)["data"][0]["id"]
        except (KeyError, IndexError, ValueError):
            time.sleep(4)
            continue
        r2 = sh(["curl", "-s", "-m", "30", f"http://127.0.0.1:{PORT}/v1/chat/completions",
                 "-d", json.dumps({"model": MODEL_ID,
                                   "messages": [{"role": "user", "content": "hi"}],
                                   "max_tokens": 1})])
        if r2.returncode == 0 and '"choices"' in r2.stdout:
            return True
        time.sleep(4)
    return False


def measure_tps(conc, ctx_tokens):
    """One rep: launch `conc` concurrent SSE lanes; per-lane decode tps
    (bench.sse_chat contract); return per-agent tps (median of lane
    medians across reps) + aggregate."""
    # bench.sse_chat(port, model, prompt, max_tokens): prompt length
    # scaled to ctx via bench.corpus_prompt so KV pressure is real.
    # Model id: the engine serves its artifact id (e.g. "Qwen3.8-27B"),
    # discovered by healthy(); "test" gets 404 model_not_found.
    # Lanes run CONCURRENTLY (ThreadPoolExecutor): the metric is
    # per-agent decode tps under C-way load, and sequential lanes
    # would multiply wall time by C (a C8x262k rep would take ~20 min).
    from concurrent.futures import ThreadPoolExecutor
    prompts = PROMPT_CACHE.get(ctx_tokens)
    if not prompts:
        prompts = [bench.corpus_prompt(ctx_tokens, i) for i in range(conc)]
        PROMPT_CACHE[ctx_tokens] = prompts
    with ThreadPoolExecutor(max_workers=conc) as pool:
        lanes = list(pool.map(
            lambda p: bench.sse_chat(PORT, MODEL_ID, p, 256), prompts))
    per_agent = []
    for ln in lanes:
        if ln and ln.get("decode_tps"):
            per_agent.append(ln["decode_tps"])
    agg = sum(ln.get("decode_tps") or 0 for ln in lanes)
    return (statistics.median(per_agent) if per_agent else 0.0, agg)


def probe(conc, ctx):
    vals = []
    for _ in range(REPS):
        tps, agg = measure_tps(conc, ctx)
        vals.append(tps)
        time.sleep(2)
    return round(statistics.median(vals), 1)


def main():
    only = sys.argv[1:] or None
    results = {}
    if OUT_JSON.exists():
        results = json.loads(OUT_JSON.read_text())

    log("sweep: stopping any active engine before start")
    for _, unit, _ in MODELS:
        stop_unit(unit)

    try:
        for mid, unit, spec in MODELS:
            if only and mid not in only:
                continue
            results.setdefault(mid, {})
            for ctx in CTXS:
                if str(ctx) in results[mid] and only is None:
                    log(f"{mid} {ctx}: cached, skip")
                    continue
                found = None
                for c in CONCS:
                    clear_shape(unit)
                    write_shape(unit, c, ctx)
                    stop_unit(unit)  # ensure clean slate (VRAM drain)
                    start_unit(unit)
                    if not healthy():
                        log(f"{mid} {ctx}: C{c} FAILED to start (OOM/refusal)")
                        stop_unit(unit)
                        continue
                    time.sleep(2)
                    tps = probe(c, ctx)
                    if tps <= 0:
                        log(f"{mid} {ctx}: C{c} started but probe failed; treating as failure")
                        stop_unit(unit)
                        continue
                    peak = bench.vram_used_mib()
                    log(f"{mid} {ctx}: C{c} OK tps={tps} peak={peak}MiB")
                    found = {"conc": c, "tps": tps, "peak_mib": peak}
                    stop_unit(unit)
                    break
                if found:
                    results[mid][str(ctx)] = found
                else:
                    log(f"{mid} {ctx}: NO concurrency works; recording null")
                    results[mid][str(ctx)] = None
                OUT_JSON.write_text(json.dumps(results, indent=2))
    finally:
        # restore: clear every shape file, restart turbo (pre-sweep state)
        for _, unit, _ in MODELS:
            clear_shape(unit)
        log("sweep: restoring turbo (pre-sweep active model)")
        sh(["systemctl", "--no-ask-password", "start", "ninfer-df2-turbo"])
    log("sweep complete")


if __name__ == "__main__":
    main()
