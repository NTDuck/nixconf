#!/usr/bin/env python3
"""Streaming benchmark client - per-agent decode tok/s (primary), TTFT,
aggregate tok/s, peak VRAM. Engine-agnostic; server lifecycle lives in
engines.py, the sweep driver in run_sweep.py.

Metrics per agent-session:
  decode_tps  = completion_tokens / (t_last - t_first)   # pure decode
  ttft_s      = t_first - t_submit
  e2e_tps     = completion_tokens / wall
Aggregate tok/s = sum(per-agent decode_tps) for agents finishing in-window.
"""
import argparse, json, math, subprocess, sys, threading, time, urllib.request
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path


CELL_BUDGET_S = 1200  # per-cell wall budget; aborts stuck agents (see run_sweep)


def sse_chat(port, model, prompt, max_tokens, timeout=3600):
    """POST /v1/chat/completions stream=true; returns metrics dict."""
    body = json.dumps({
        "model": model,
        "messages": [{"role": "user", "content": prompt}],
        "max_tokens": max_tokens, "temperature": 0, "stream": True,
    }).encode()
    req = urllib.request.Request(
        f"http://127.0.0.1:{port}/v1/chat/completions", data=body,
        headers={"Content-Type": "application/json"})
    t_submit = time.perf_counter()
    ct = 0
    chars = 0
    n_deltas = 0
    t_first = t_last = None
    err = None
    try:
        resp = urllib.request.urlopen(req, timeout=timeout)
        for raw in resp:
            if time.perf_counter() - t_submit > CELL_BUDGET_S:
                err = f"cell budget {CELL_BUDGET_S}s exceeded; aborting stuck stream"
                break
            line = raw.decode("utf-8", "replace").strip()
            if not line.startswith("data:"):
                continue
            payload = line[5:].strip()
            if payload == "":
                break
            if payload == chr(91) + "DONE" + chr(93):
                break
            try:
                chunk = json.loads(payload)
            except json.JSONDecodeError:
                continue
            choices = chunk.get("choices") or []
            if not choices:
                # usage-only final chunk (stream_options) or keepalive
                continue
            delta = choices[0].get("delta", {})
            # Reasoning models (q27 --think) stream reasoning_content;
            # usage.completion_tokens counts those too, so count any.
            txt = (delta.get("content") or "") + (delta.get("reasoning_content") or "")
            if not txt:
                continue
            now = time.perf_counter()
            if t_first is None:
                t_first = now
            t_last = now
            chars += len(txt)
            n_deltas += 1
        resp.close()
    except Exception as e:
        err = f"{type(e).__name__}: {e}"[:300]
    if n_deltas and not err:
        # Deltas are NOT 1:1 tokens: ninfer 0.6.1 coalesces ~10.7 chars/delta
        # (spec-decode rounds), q27 ships ~4.3. Estimate tokens from chars at
        # the corpus ratio (57) blended with observed per-stream granularity;
        # cap at max_tokens. Per-char is engine-independent, unlike deltas.
        ct = max(1, round(chars / CHARS_PER_STREAM))
        if ct > max_tokens:
            ct = max_tokens
    wall = time.perf_counter() - t_submit
    rec = {"ok": err is None and ct > 0, "err": err, "ct": ct,
           "chars": chars, "n_deltas": n_deltas,
           "ttft_s": round(t_first - t_submit, 3) if t_first else None,
           "decode_s": round(t_last - t_first, 3) if (t_first and t_last) else None,
           "decode_tps": round(ct / (t_last - t_first), 2)
                         if (t_first and t_last and ct) else 0.0,
           "e2e_tps": round(ct / wall, 2) if ct else 0.0,
           "wall": round(wall, 2)}
    return rec


CORPUS_UNIT = ("The attention mechanism streams keys and values from HBM "
               "while the SM scheduler overlaps tensor-core math with memory "
               "latency. ")
# ~5.72 chars/token for this English filler (engine-measured 2026-10-08:
# q27 counted 163,383 tokens for a 934,060-char corpus body; the earlier
# 57 was a decimal error that made "16K" cells actually ~163K prompts).
CHARS_PER_TOK = 5.72
# Chat-prose tokens average ~4.1 chars (Qwen BPE); used to turn streamed
# characters into token counts engine-independently.
CHARS_PER_STREAM = 4.1


def corpus_prompt(ctx_tokens, lane):
    """Deterministic per-lane salted corpus at ~ctx_tokens prompt tokens.
    Salt every 16 units so lanes diverge from token 1 -> no prefix-cache
    reuse across lanes or runs (lesson from 2026-10-02 session)."""
    n_units = max(1, int(ctx_tokens * CHARS_PER_TOK * 0.98) // len(CORPUS_UNIT))
    parts = []
    for k in range(n_units):
        parts.append(f"LANESEED{lane} " + CORPUS_UNIT if k % 16 == 0 else CORPUS_UNIT)
    body = "".join(parts)[: int(ctx_tokens * CHARS_PER_TOK)]
    return (f"Session salt {lane}-{int(time.time())}. "
            + body
            + f"\n\nIgnore all text above. LANE MARKER {lane}: end your "
              f"answer with the token LANE{lane}END, then summarize the "
              f"memory-hierarchy text above in two sentences.")


def vram_used_mib():
    out = subprocess.run(
        ["nvidia-smi", "--query-compute-apps=pid,used_memory",
         "--format=csv,noheader"], capture_output=True, text=True).stdout
    tot = 0
    for line in out.strip().splitlines():
        if line.strip():
            try:
                tot += int(line.rsplit(",", 1)[1].strip().split()[0])
            except (IndexError, ValueError):
                pass
    return tot


def wait_healthy(port, proc, deadline_s=600):
    """Poll /v1/models until 200 or the process dies."""
    t0 = time.time()
    while time.time() - t0 < deadline_s:
        if proc.poll() is not None:
            return False, "server exited"
        try:
            r = urllib.request.urlopen(
                f"http://127.0.0.1:{port}/v1/models", timeout=5)
            if r.status == 200:
                r.read(); r.close()
                return True, "ok"
        except Exception:
            pass
        time.sleep(2)
    return False, "timeout"


def resolve_model_id(cfg):
    """Ask the server for its model id when the registry says 'auto'."""
    if cfg["model"] != "auto":
        return cfg["model"]
    r = urllib.request.urlopen(f"http://127.0.0.1:{cfg['port']}/v1/models",
                               timeout=10)
    mid = json.loads(r.read())["data"][0]["id"]
    r.close()
    return mid


def run_cell(engine_cfg, ctx_tokens, conc, out_dir, max_tokens=256, reps=1):
    """One (engine, ctx, concurrency) cell. Engine cfg supplies port/model.
    Returns aggregate record; per-agent lines go to out_dir sessions jsonl."""
    tag = engine_cfg["tag"]
    sdir = Path(out_dir) / "sessions" / tag / f"ctx{ctx_tokens}" / f"c{conc}"
    sdir.mkdir(parents=True, exist_ok=True)
    agg = {"tag": tag, "model": resolve_model_id(engine_cfg), "ctx": ctx_tokens,
           "conc": conc, "reps": reps, "agents": [], "ok": 0}
    for rep in range(reps):
        prompts = [corpus_prompt(ctx_tokens, i + rep * 1000) for i in range(conc)]
        peak = {"vram": 0}
        stop = threading.Event()

        def sampler():
            while not stop.is_set():
                peak["vram"] = max(peak["vram"], vram_used_mib())
                time.sleep(0.5)

        st = threading.Thread(target=sampler, daemon=True); st.start()
        t0 = time.perf_counter()
        mid = agg["model"]
        with ThreadPoolExecutor(max_workers=conc) as ex:
            futs = [ex.submit(sse_chat, engine_cfg["port"], mid,
                              p, max_tokens) for p in prompts]
            recs = [f.result() for f in futs]
        wall = time.perf_counter() - t0
        stop.set(); st.join(timeout=2)
        for i, r in enumerate(recs):
            r.update({"rep": rep, "lane": i})
            with (sdir / f"rep{rep}_lane{i}.json").open("w") as fh:
                json.dump(r, fh)
        oks = [r for r in recs if r["ok"]]
        agg["ok"] += len(oks)
        agg["agents"].append({
            "rep": rep, "ok": len(oks), "wall": round(wall, 2),
            "peak_vram_mib": peak["vram"],
            "mean_decode_tps": round(sum(r["decode_tps"] for r in oks) / len(oks), 2) if oks else 0.0,
            "agg_decode_tps": round(sum(r["decode_tps"] for r in oks), 2),
            "agg_e2e_tps": round(sum(r["ct"] for r in oks) / wall, 2) if oks else 0.0,
            "mean_ttft_s": round(sum(r["ttft_s"] for r in oks) / len(oks), 3) if oks else None,
            "errors": [r["err"] for r in recs if not r["ok"]][:3],
        })
    with (Path(out_dir) / "cells.jsonl").open("a") as fh:
        fh.write(json.dumps(agg) + "\n")
    return agg


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--engine", required=True, help="tag key from engines.json")
    ap.add_argument("--ctx", type=int, required=True)
    ap.add_argument("--conc", type=int, required=True)
    ap.add_argument("--out", default=str(Path(__file__).parent / "results"))
    ap.add_argument("--max-tokens", type=int, default=256)
    ap.add_argument("--reps", type=int, default=1)
    ap.add_argument("--serve", action="store_true",
                    help="also start/stop the server around the cell")
    a = ap.parse_args()
    import engines
    cfg = engines.get(a.engine)
    if a.serve:
        engines.start(cfg)
        try:
            ok, msg = wait_healthy(cfg["port"], cfg.get("proc"))
            if not ok:
                print(json.dumps({"fatal": f"server not healthy: {msg}"}))
                return 2
            agg = run_cell(cfg, a.ctx, a.conc, a.out, a.max_tokens, a.reps)
        finally:
            engines.stop(cfg)
    else:
        agg = run_cell(cfg, a.ctx, a.conc, a.out, a.max_tokens, a.reps)
    print(json.dumps(agg, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
