# Inference engine benchmark — RTX 3090 (TB4 eGPU, SM86, 24 GB)

_Generated 2026-10-12 · harness: `benchmarks/engines-2026-10/` · metric: **per-agent decode tok/s** (chars/4.1 streaming proxy, engine-validated 2026-10-08) · greedy, 256 max tokens · GPU-resident weights/KV only (no CPU offload)._

## Summary

Sweep screened 18 engine configurations across two model families on one RTX 3090 (TB4 eGPU): screening (fresh + 16k, C1–C8) then a long ladder (32k–256k, C1/C4/C8) for survivors. Metric is per-agent decode tok/s: what one agent observes while N agents stream concurrently on the same engine. Cells that overflowed the 15 GiB host or deadlocked the engine are ledgered, not averaged in. Peak VRAM per cell is reported beside each table.


Per-engine sections below pair each engine's configuration with its result table: per-agent decode tok/s (rows = context, cols = C1–C8) and peak VRAM MiB per cell. `—` = not measured or overflow (see ledger).

### Throughput surfaces

Z = per-agent decode tok/s (up = faster), X = context, Y = parallelism k. One surface per engine; measured cells are dotted, gaps are unmeasured/overflowed.

![surf3d_bonsai2-27b](engines-2026-10/results/surf3d_bonsai2-27b.png)
![surf3d_qwen3.8-27b](engines-2026-10/results/surf3d_qwen3.8-27b.png)

## bonsai2-27b

### `ninfer-all-b2`

- **Artifact:** `Ternary-Bonsai-2-27B-ninfer-v3.ninfer` (ghcr.io/iamwavecut/ninfer-all, sm86)
- **Flags:** `--kv-dtype rk4v4 --spec dflash2 --draft-tokens 5 --no-prefix-reuse`, ctx/kv 262144

| context | C1 | C2 | C4 | C8 | peak VRAM (MiB) |
|---|---|---|---|---|---|
| fresh | 267.5 | 194.0 | 111.2 | 61.8 | 12116 |
| 16k | 204.7 | 100.3 | 63.9 | 40.1 | 12116 |
| 32k | 225.8 | — | 199.8 | 210.9 | 11950 |
| 64k | 197.9 | — | 42.7 | 24.6 | 15310 |

### `prism-ptq10`

- **Artifact:** `Ternary-Bonsai-2-27B-PTQ1_0.gguf` (prism llama.cpp)
- **Flags:** PTQ1_0, flash-attn, ctx 32768, np 4

| context | C1 | C2 | C4 | C8 | peak VRAM (MiB) |
|---|---|---|---|---|---|
| fresh | 61.7 | 36.5 | 20.1 | 20.2 | 8690 |
| 16k | 0.0 | — | — | — | 8678 |
| 32k | 0.0 | — | — | — | 8780 |
| 64k | 0.0 | — | — | — | 8780 |
| 128k | 0.0 | — | — | — | 8780 |
| 256k | 0.0 | — | — | — | 8780 |

### `q27-t3-mtp`

- **Artifact:** `bonsai2-27b-t3-mtp-slim.q27` (q27 v0.14.4)
- **Flags:** spec=mtp draft 3, slots 8

| context | C1 | C2 | C4 | C8 | peak VRAM (MiB) |
|---|---|---|---|---|---|
| fresh | 120.5 | 69.3 | 40.6 | 21.6 | 23028 |
| 16k | 86.7 | 47.6 | 25.9 | 13.6 | 23422 |
| 32k | 68.6 | — | 18.5 | 9.9 | 23310 |
| 64k | 54.6 | — | 12.6 | — | 23040 |
| 128k | 34.1 | — | — | — | 22902 |
| 256k | 20.8 | — | — | — | 24327 |

### `q27-t3-solo`

- **Artifact:** `bonsai2-27b-t3-mtp-slim.q27` (q27 v0.14.4)
- **Flags:** w8 stack 2.3 GiB, spec-off, ctx 262144, slots 1

| context | C1 | C2 | C4 | C8 | peak VRAM (MiB) |
|---|---|---|---|---|---|
| fresh | 118.5 | 119.5 | 115.4 | 115.7 | 22754 |
| 16k | 85.0 | 82.2 | 88.1 | 88.1 | 22727 |
| 32k | 70.6 | — | 71.8 | 71.0 | 22520 |
| 64k | 53.2 | — | 53.6 | — | 22520 |
| 128k | 33.5 | — | — | — | 22520 |
| 256k | 18.2 | — | — | — | 22520 |

## qwen3.8-27b

### `ashalliants-df2`

- **Artifact:** `qwen3_8_27b.ninfer` (ashalliants 0.15.0)
- **Flags:** spec=dflash2, ctx 262144, rk4v4 KV, host KV clamped 2048 MiB via shim, FALLBACK=off

| context | C1 | C2 | C4 | C8 | peak VRAM (MiB) |
|---|---|---|---|---|---|
| fresh | 154.5 | 160.3 | 162.0 | 158.3 | 21296 |
| 16k | 150.3 | 141.3 | 144.6 | 143.8 | 20702 |

### `ashalliants-016-df2` (2026-10-15 Evaluation)

- **Artifact:** `qwen3_8_27b.ninfer` (ashalliants 0.16.0 release binary, identical model artifact)
- **Flags:** spec=dflash2, rk4v4 KV, host context clamped 2048 MiB via shim, FALLBACK=off
- **Notes:** New context cache engine (#214) increases base per-lane runtime reservation on 24 GB card. C8x16k, C8x32k, C6x65k, and C4x128k OOM at startup (requires > 6.78 GiB available VRAM). Caps at C4x65k and C2x128k.

| context | C1 | C2 | C4 | C8 | peak VRAM (MiB) |
|---|---|---|---|---|---|
| fresh | 148.5 | — | 67.7 | OOM | 23023 |
| 16k | 165.4 | — | 67.3 | OOM | 22960 |
| 65k | — | — | 125.0 | OOM | 23198 |
| 128k | — | 119.4 | OOM | OOM | 23392 |

### `ashalliants-df2-128k`

- **Artifact:** —
- **Flags:** —

| context | C1 | C2 | C4 | C8 | peak VRAM (MiB) |
|---|---|---|---|---|---|
| 128k | — | 117.9 | 114.3 | — | 23434 |

### `ashalliants-df2-65k-c6`

- **Artifact:** —
- **Flags:** —

| context | C1 | C2 | C4 | C8 | peak VRAM (MiB) |
|---|---|---|---|---|---|

### `ashalliants-mtp`

- **Artifact:** `qwen3_8_27b.ninfer` (ashalliants 0.15.0)
- **Flags:** spec=mtp, ctx 262144, host KV shim 2048 MiB

| context | C1 | C2 | C4 | C8 | peak VRAM (MiB) |
|---|---|---|---|---|---|
| fresh | 117.5 | 113.5 | 109.3 | 105.1 | 22776 |
| 16k | 117.7 | 86.6 | 83.7 | 115.7 | 22786 |

### `ashalliants-mtp-128k`

- **Artifact:** —
- **Flags:** —

| context | C1 | C2 | C4 | C8 | peak VRAM (MiB) |
|---|---|---|---|---|---|
| 128k | — | 85.1 | 85.1 | — | 24094 |

### `ashalliants-mtp-65k-c6`

- **Artifact:** —
- **Flags:** —

| context | C1 | C2 | C4 | C8 | peak VRAM (MiB) |
|---|---|---|---|---|---|

### `ashalliants-mtp-65k-c8`

- **Artifact:** —
- **Flags:** —

| context | C1 | C2 | C4 | C8 | peak VRAM (MiB) |
|---|---|---|---|---|---|
| 64k | — | — | 98.8 | — | 23568 |

### `buun-qwen`

- **Artifact:** `Qwen3.8-27B-UD-IQ4_XS.gguf` (buun-llama-cpp b9637)
- **Flags:** TCQ KV `turbo2_tcq`, `-c 524288 -np 8` (per-slot 65536), flash-attn

| context | C1 | C2 | C4 | C8 | peak VRAM (MiB) |
|---|---|---|---|---|---|
| fresh | 43.1 | 35.9 | 25.2 | 15.2 | 19978 |
| 16k | 34.1 | 17.4 | 8.1 | 3.8 | 19986 |
| 32k | 28.7 | — | 4.8 | 2.1 | 19986 |
| 64k | 21.8 | — | 2.8 | 0.0 | 19984 |

### `davidau-fable`

- **Artifact:** `DavidAU-TurboFCFusion-Qwen3.8-27B-Q4_K_M.gguf` (prism llama.cpp CUDA)
- **Flags:** `-ngl 99 -fa on -c 262144 -np 8 -ctk q5_1 -ctv q4_0` (per-slot 32768)

| context | C1 | C2 | C4 | C8 | peak VRAM (MiB) |
|---|---|---|---|---|---|
| fresh | 29.6 | 4.3 | 1.6 | 0.7 | 23722 |
| 16k | 0.0 | — | — | — | 23720 |
| 32k | 0.0 | — | — | — | 23718 |
| 64k | 0.0 | — | — | — | 23710 |
| 128k | 0.0 | — | — | — | 23710 |
| 256k | 0.0 | — | — | — | 23710 |

### `fable5`

- **Artifact:** `Qwen3.8-27B-LoRA-IQ4_XS-MTP.gguf` (prism llama.cpp CUDA)
- **Flags:** `-ngl 99 -fa on -c 262144 -np 8 -ctk q5_1 -ctv q4_0` (per-slot 32768)

| context | C1 | C2 | C4 | C8 | peak VRAM (MiB) |
|---|---|---|---|---|---|
| fresh | 28.6 | 4.3 | 1.6 | 0.7 | 20934 |
| 16k | 0.0 | — | — | — | 20930 |
| 32k | 0.0 | — | — | — | 20930 |
| 64k | 0.0 | — | — | — | 20920 |
| 128k | 0.0 | — | — | — | 20920 |
| 256k | 0.0 | — | — | — | 20920 |

### `gguf-q4xs`

- **Artifact:** `Qwen3.8-27B-UD-IQ4_XS.gguf` (prism llama.cpp CUDA)
- **Flags:** q8_0 KV, `-c 262144 -np 8` (per-slot 32768), flash-attn

| context | C1 | C2 | C4 | C8 | peak VRAM (MiB) |
|---|---|---|---|---|---|
| fresh | 45.5 | 38.5 | 27.8 | 16.6 | 26410 |
| 16k | 41.4 | 23.9 | 12.1 | 5.8 | 26414 |
| 32k | 37.9 | — | 8.4 | 3.9 | 24360 |

### `humanlike`

- **Artifact:** `Humanlike-Qwen3.8-27B-IQ4_XS.gguf` (prism llama.cpp CUDA)
- **Flags:** `-ngl 99 -fa on -c 262144 -np 8 -ctk q5_1 -ctv q4_0` (per-slot 32768)

| context | C1 | C2 | C4 | C8 | peak VRAM (MiB) |
|---|---|---|---|---|---|
| fresh | 34.1 | 4.5 | 1.6 | 0.7 | 20944 |
| 16k | 0.0 | — | — | — | 20942 |
| 32k | 0.0 | — | — | — | 20940 |
| 64k | 0.0 | — | — | — | 20932 |
| 128k | 0.0 | — | — | — | 20932 |
| 256k | 0.0 | — | — | — | 20932 |

### `ninfer-061`

- **Artifact:** `/var/lib/ninfer/qwen3_8_27b.ninfer` (ninfer 0.6.1)
- **Flags:** ctx 65536, kv int8, spec=mtp draft 3

| context | C1 | C2 | C4 | C8 | peak VRAM (MiB) |
|---|---|---|---|---|---|
| fresh | 70.9 | 49.2 | 24.6 | 22.9 | 22630 |
| 16k | 67.5 | 30.8 | 31.2 | 30.1 | 22692 |
| 32k | 68.8 | — | 68.1 | 63.5 | 22734 |
| 64k | 66.2 | — | 66.3 | 61.2 | 22734 |
| 128k | 0.0 | — | — | — | 22732 |
| 256k | 0.0 | — | — | — | 22732 |

### `thinkingcap`

- **Artifact:** `ThinkingCap-Qwen3.8-27B-Q4_K_M.gguf` (prism llama.cpp CUDA)
- **Flags:** `-ngl 99 -fa on -c 262144 -np 8 -ctk q5_1 -ctv q4_0` (per-slot 32768)

| context | C1 | C2 | C4 | C8 | peak VRAM (MiB) |
|---|---|---|---|---|---|
| fresh | 31.1 | 4.4 | 1.6 | 0.7 | 22930 |
| 16k | 0.0 | — | — | — | 22938 |
| 32k | 0.0 | — | — | — | 22928 |
| 64k | 0.0 | — | — | — | 22904 |
| 128k | 0.0 | — | — | — | 22904 |
| 256k | 0.0 | — | — | — | 22904 |

## Lane comparability

`swift-uncensored` runs the **mtp lane** (spec=mtp), not the tuned dflash2 profile of `ashalliants-df2`: the converted artifact is the 1124-object flavor — full MTP draft weights but no dflash2 draft weights (0 of the baseline's 56 dflash2-bound weights, 1.11 GiB) — so the dflash2 profile is structurally impossible and the engine rejects it. The apples-to-apples comparison is therefore **swift-uncensored vs `ashalliants-mtp`** (same binary, spec, and profile; abliterated weights are the only variable). Do not rank swift-uncensored against `ashalliants-df2`.

The 2026-10-10/11 variant arms (`swift15`, `huihui-abl`, `obliterated`) ran on the same **mtp lane** with `NINFER_MODEL` overrides of the same 0.15.0 binary, all achieving 20/20 cells: they are directly comparable to `ashalliants-mtp`/`swift-uncensored` and to each other — not to `ashalliants-df2`. The four GGUF-only arms (`thinkingcap`, `davidau-fable`, `humanlike`, `fable5`) ran on prism llama.cpp CUDA with `q5_1/q4_0` KV cache (fitting the 24 GB card); with `-c 262144 -np 8`, each slot gets 32k context, measuring fresh C1–C8 cells while deep contexts exceed single-slot bounds. `coder390` carried publisher tokenizer drift (resolved via stock resources), but its dequantized BF16 DFlash2 draft (20.44 GiB artifact) plus the 0.15.0 DFlash2 runtime reservation (6.01 GiB) exceeds the 24 GiB card capacity by 1.05 GiB; dropping vision is rejected by the engine config.
## Overflowed cells (retried once 2026-10-09; permanent rejections kept)

_None outstanding._

## Per-model frontiers

### bonsai2-27b

| context | C1 | C2 | C4 | C8 |
|---|---|---|---|---|
| fresh | `ninfer-all-b2` 267.5 | `ninfer-all-b2` 194.0 | `q27-t3-solo` 115.4 | `q27-t3-solo` 115.7 |
| 16k | `ninfer-all-b2` 204.7 | `ninfer-all-b2` 100.3 | `q27-t3-solo` 88.1 | `q27-t3-solo` 88.1 |
| 32k | `ninfer-all-b2` 225.8 | — | `ninfer-all-b2` 199.8 | `ninfer-all-b2` 210.9 |
| 64k | `ninfer-all-b2` 197.9 | — | `q27-t3-solo` 53.6 | `ninfer-all-b2` 24.6 |
| 128k | `q27-t3-mtp` 34.1 | — | — | — |
| 256k | `q27-t3-mtp` 20.8 | — | — | — |

### qwen3.8-27b

| context | C1 | C2 | C4 | C8 |
|---|---|---|---|---|
| fresh | `ashalliants-df2` 154.5 | `ashalliants-df2` 160.3 | `ashalliants-df2` 162.0 | `ashalliants-df2` 158.3 |
| 16k | `ashalliants-df2` 150.3 | `ashalliants-df2` 141.3 | `ashalliants-df2` 144.6 | `ashalliants-df2` 143.8 |
| 32k | `ninfer-061` 68.8 | — | `ninfer-061` 68.1 | `ninfer-061` 63.5 |
| 64k | `ninfer-061` 66.2 | — | `ashalliants-mtp-65k-c8` 98.8 | `ninfer-061` 61.2 |
| 128k | — | `ashalliants-df2-128k` 117.9 | `ashalliants-df2-128k` 114.3 | — |

## Winner

- **bonsai2-27b**: peak `ninfer-all-b2` 267.5 tok/s per-agent; at high parallelism×deep ctx — C4 × 64k: `q27-t3-solo` 53.6 tok/s vs `ninfer-all-b2` 42.7.
- **qwen3.8-27b**: peak `ashalliants-df2` 162.0 tok/s per-agent; at high parallelism×deep ctx — C4 × 128k: `ashalliants-df2-128k` 114.3 tok/s vs `ashalliants-mtp-128k` 85.1.

qwen3.8-27b variants on the ashalliants engine (shared mtp lane) — per-agent decode tok/s (Z = tok/s up = faster, X = context, Y = parallelism k):

![winner surface](engines-2026-10/results/surf3d_winner.png)

## Reproduce

```bash
cd benchmarks/engines-2026-10
python3 run_sweep.py --stage screening            # fresh+16K, C1-C8
python3 run_sweep.py --stage long                 # survivors, 32K-256K
.venv/bin/python analyze.py                       # CSV + 3D surfaces
.venv/bin/python report.py                        # this file
```