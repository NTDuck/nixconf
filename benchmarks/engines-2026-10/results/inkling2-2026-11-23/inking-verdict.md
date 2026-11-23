# Inkling-2-Mini on RTX 3090 — is 1x65k a true limitation?

**Verdict: NO.** The 1x65k shape in `ninfer list` is the upstream reference recipe's
memory-fit choice replicated in the unit, not a model or engine limit. Measured 2026-11-23
on ninfer-all 2026-11-22.5 (build 719119a, CUDA 13.4, sm86 profile), WaveCut UD-IQ4_XS v3
artifact, 2 waves per cell, greedy, ~90%-of-ctx long prompts.

## Headline answer
- **Model ceiling: 1,048,576 tokens** (config.json `model_max_length`; relative-bias
  attention, no YaRN needed). The vLLM recipe serves the full 1M on a GB200.
- **Engine ceiling: none documented** — `--max-context` is a plain per-request ceiling for
  this family; no inkling-specific cap in the ninfer-all help.
- **Measured 24 GB ceiling: C1x327680 boots and serves** (runtime 7.29 GiB, free 289 MiB at
  boot, peak 23,858 MiB during prefill). 65k → 320k = **5× the context** at C1.
- **1M context: physically impossible on this box** — ~20.7 KiB/token × 1M ≈ 20.7 GiB of KV
  alone vs ~8.7 GiB free after weights+desktop; host-KV offload can't bridge it either
  (unit MemoryMax=12G; upstream serves 1M only on 180 GB+ parts).
- **Decode cost is real**: t/s falls with filled context (93 → 69 → 51 → ~37 extrapolated
  at 320k). The context win trades per-request speed.

## Measured ladder (D=DSpark drafting active; none at C≥2)
| shape | boot `capacity` line | peak VRAM | ctx filled | decode t/s | prefill t/s | drafting |
|---|---|---|---|---|---|---|
| C1x65536 | KV 65,536, runtime 2.92 GiB, free 4.65 GiB | 19,404 MiB | 57,598 | 93.0 | 1885 | D 55% |
| C1x131072 | KV 131,072, runtime 4.20 GiB, free 3.37 GiB | 20,716 MiB | 115,222 | 69.1 | 1516 | D 52% |
| C1x262144 | KV 262,144, runtime 6.76 GiB, free 0.83 GiB | 23,340 MiB | 230,428 | 50.6 | 1105 | D 57% |
| C2x65536 | 2 seqs, pool 2540 MiB, runtime 3.74 GiB, free 4.23 | 19,820 MiB | 57,613/lane | **agg 109.6** (25.5+84.2) | 1872/879 | none |
| C2x131072 | 2 seqs, pool 4652 MiB, runtime 5.80 GiB, free 2.17 | 21,932 MiB | 115,237/lane | agg 93.8 (23.4+70.4) | 1519/735 | none |
| C1x327680 | KV 327,680, runtime 7.29 GiB, free 0.29 GiB | 23,858 MiB | (bench pending) | — | — | D |

## Mechanics discovered
1. **`--kv-capacity` is a shared pool**, not per-lane: C2x65k booted with my 131,072-token
   pool = "mxfp8 KV 2540 MiB" (20 KiB/token). Two 65k lanes fit because 131k pool ≥ demand.
   The CLI's `do_switch` writes `NINFER_KV_CAPACITY = NINFER_CONTEXT` — for C>1 that
   UNDER-provisions (2 lanes × 65k demand needs 131k pool). Shape-table rows for C≥2 must
   write conc×ctx as KV capacity or long-context lanes will be refused admission.
2. **KV dtype is mxfp8 by default** for Inkling 2 (boot log; engine help "mxfp8: Inkling 2
   (its default)") — 20.7 KiB/token measured, NOT 32 KiB/token F16 as the nixconf comment
   claims. That comment ("Quantized KV is NOT built for this family: F16 only") is wrong.
3. **DSpark drafts only at C1** ("up to 3 drafts a round for one decoding request"). C2+
   decode is undrafted. Two-lane 65k aggregate (109.6) still beats single-lane drafted
   (93.0), but the gain is modest, not the naive 2×: the second lane's prefill steals
   decode windows (lane imbalance 25 vs 84 t/s).
4. **Engine adapts**: at 320k it auto-switched prompt chunks 2048→512 to fit the pool.
5. Decode falloff ≈ −26% per context doubling (matches community 3090 datapoint
   90 t/s short → 64 t/s at 197k without DSpark).

## Recommendations
- Keep **1x65536 default** (fastest single-lane, DSpark on, matches upstream recipe).
- Add **1x131072, 1x262144, 1x327680** rows (long-context work; 5× depth, 93→~37 t/s).
- Add **2x65536** row (two-lane shape; aggregate 109.6 t/s vs 93 single-lane at same
  depth; KV pool must be 131,072 = conc×ctx, not ctx).
- Leave 1M/512k off the table: 512k needs ~10.4 GiB KV (boot fails with ~8.7 free);
  1M needs ~20.7 GiB — impossible on this card/box.
- nixconf artifact comment fixes: mxfp8 KV default (20.7 KiB/token measured), vision tower
  works (56 MiB + 580 MiB/image), DSpark C1-only (already correct), table + KV-capacity
  semantics per above.

## Edits to make in modules/.../agentics/ninfer/default.nix
1. Comment block ~:269-282: correct KV/vision claims; note measured 2026-11-23 ladder.
2. `ninferShapeTable`: `"inkling-2-mini|1x65k,2x65k,1x131k,1x262k,1x320k"` (pending cell).
3. `SHAPES`: `"inkling-2-mini|65536:1:19456:93,65536:2:19820:219,131072:1:20716:69,262144:1:23340:51,327680:1:23858:<tps>"`.
4. `default_shape_for`: keep `1x65536`.
5. NOTE: switch-validation writes KV_CAPACITY=ctx; for the 2x65536 row the env write must
   become KV_CAPACITY=conc×ctx (or 131072) — check do_switch write block before editing.
