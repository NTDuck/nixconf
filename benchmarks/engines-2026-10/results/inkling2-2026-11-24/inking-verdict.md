# Inkling-2-Mini engine re-pin verdict — 2026-11-24

Question (user): is "1x65k with acceptable tps" the model's limit, and can it be
pushed higher? Answer from this sweep + yesterday's ladder: the 65k ceiling is
**VRAM math on this 24 GB card, not the model** (upstream plan numbers go to
131k/262k/512k+; the shape ladder simply tops out where boot free VRAM runs
out), and the engine serving it was leaving large tps on the table.

## Engine A/B — ninfer-all 2026-11-22.5 (719119a) vs 2026-11-23.8 (982ad2a)

Same artifact (Inkling-2-Mini-UD-IQ4_XS v3), same card (RTX 3090, 24.5 GiB),
same harness (python driver, long 90%-ctx prompts, greedy, DSpark auto).
Numbers = engine-reported decode tok/s (aggregated lanes for C2).

| shape  | 11-22.5 | 11-23.8 | Δ |
|--------|---------|---------|---|
| C1x58k | 93.0    | 120.1   | +29% |
| C1x115k| 69.1    | 91.6    | +33% |
| C1x230k| 50.6    | 71.5    | +41% |
| C1x288k| 46.5    | 63.1    | +36% |
| C2x65k | 109.6   | 136.8   | +25% |
| C2x131k| 93.8    | 127.5   | +36% |

Prefill: 1885→2885 @65k, 1516→2340 @131k, 1105→1675 @262k (+50-55%).
Upstream notes the 11-23.8 kernel moves Inkling2 decode+verification
attention and prompt near/far fields to tensor cores (FP32 scores on
RTX 5090: 68.6→142.9 tok/s plain) — matches our +25-41% decode and +50%
prefill. Text identical in both engines (kernel only).

## Boot VRAM (new engine, unchanged vs old within noise)

| shape  | peak MiB | runtime KV MiB |
|--------|----------|----------------|
| C1x65k | 19364 | 2.90 GiB |
| C1x131k| 20676 | 4.18 GiB |
| C1x262k| 23300 | 6.75 GiB |
| C1x327k| 23854 | 7.29 GiB |
| C2x65k | 19808 | 3.73 GiB |
| C2x131k| 21920 | 5.79 GiB |

320k remains the max C1 shape (290 MiB boot headroom). 512k still projected
boot failure (~10.4 GiB KV alone). The new engine did not change VRAM math.

## Applied

- `modules/.../agentics/ninfer/default.nix`: single-volume fetchurl pin
  2026-11-23.8 (982ad2afa080), `engineVersionAll` bumped, SHAPES row and
  comments updated with the measured table above. fetchurl hash verified by
  nix; inner SHA256SUMS verified in the derivation build
  (`ninfer-serve 2026-11-23.8+982ad2a`).
- Raw data: this directory (`*.bench.jsonl`, `*.idle_vram`, engine logs,
  ladder.log). Prior-engine comparison: `inkling2-2026-11-23/`.
