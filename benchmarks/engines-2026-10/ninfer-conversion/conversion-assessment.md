# Coder390 .ninfer conversion — final report (2026-11-12)

## Verdict
CONVERTED + SERVING. `qwen3.8-27b-coder390` boots on ninfer 0.17.2 RTX 3090,
answers /v1/chat/completions honestly (SMOKE-OK), and the C_max x ctx matrix is
measured and pinned in the module.

## Journey (three converter failures, three fixes)
1. v1: `pre_tokenizer.json pre_tokenizer.Segmented is not supported by the Qwen tokenizer`
   -> source repo ships a Segmented pre-tokenizer regex list the engine's
   tokenizer registry can't parse. Fixed by resource override:
   `--resource tokenizer.json=<base Qwen3.8-27B tokenizer.json>` (semantically
   identical: 248044 vocab, same merges modulo list/str JSON format, added_tokens
   equal; diffed in-session).
2. v2: boot FATAL `missing field added_tokens_decoder in tokenizer_config.json`
   -> engine 0.17.2 requires the modern tokenizer_config shape. Fixed by second
   resource override: `--resource tokenizer_config.json=<base tokenizer_config.json>`
   (eos/bos/pad/model_max_length verified identical before override).
3. v3: BOOT OK. Weights load 17.2 GiB @ 2.66 GiB/s; serving verified.

## Artifact
- Path: /home/ayin/models/q27-bench/downloads/coder390/coder390_qwen3_8_27b.ninfer
- sha256: 78d12c43cf8566f648e75b880a2200a6f26da76ecc7dac495a09373d19151502
- Size: 17.68 GiB; 1190 objects; 1184 tensors; 6 resources; formats
  bf16/fp32/int32/q4-q8 (240 q4_g64, 190 q5_g64, 2 q6_g64, 28 q8_g32)
- Components: text (Qwen3_5ForCausalLM arch, 64 layers, 248320 vocab, 262144
  max_pos), vision, mtp_proposal, dflash2 draft
- Provenance: /home/ayin/models/q27-bench/coder390/provenance.json (v3)

## C_max x ctx matrix (RTX 3090, dflash2, FALLBACK=off, engine 0.17.2)
| ctx | C_max | ready VRAM peak | first failing cell |
|---|---|---|---|
| 16384 | 6 | 20570 MiB | C7 (res 7.39 GiB) |
| 32768 | 5 | 20572 MiB | C6 (res 6.81 GiB, by 32 MiB) |
| 65536 | 4 | 20876 MiB | C5 (res 7.53 GiB) |
| 131072 | 3 | 21708 MiB | C4 (res 7.63 GiB); C2 fits too |
| 262144 | none | - | C1 (res 6.94 GiB, by 157 MiB) |

Runtime reservation model: ~6.6 GiB dflash2 floor + ~75 MiB per lane +
~21 MiB per kctx. 262k is out of reach for the dense artifact (weights leave
6.78 GiB; the floor + 262k KV pool needs 6.94+).

Champion default: C4x65536.

## Systemic finding: nix GC vs pinned engine libs
The 2026-10 pinned engine lib store paths were GC'd; EVERY fresh ninfer unit
start on this host would fail on libcublas.so.12 until a rebuild. Fixed by
re-pinning module `ninferLibs` to live store paths + indirect GC roots
(~/.local/share/nix-gcroots/ninfer-*). engines.py benchmark templates updated
(28+10 LD_LIBRARY_PATH pins + 1 podman -v mount).

## Wiring landed
- module: ninfer/default.nix — boot-gate hash v3, SHAPES row measured,
  unit default C4x65536, default_shape_for coder390 -> 4x65536
- omp provider: contextWindow 131072 (max bootable), default model untouched
- sweep log: benchmarks/engines-2026-10/results/sweep-coder390-2026-11-12.log
- flake evaluates clean after all edits (toplevel drv 3hag8i8j...)

## Post-sweep incident + resolution (2026-11-12 02:07)
- nixos-rebuild test BUILT the fixed generation (3rjqwlp76...) but the switch failed on polkit
  (non-interactive systemd-run). Run interactively:
  `sudo /nix/store/3rjqwlp76jwk818qficpvdixwm55fymy-nixos-system-lenovo-legion-16iah7h-PF3XJ8SP-26.05.20261108.ac588ef/bin/switch-to-configuration test`
- Turbo was crash-looping (42 restarts, status 127 = dead lib paths). Manually restored on port 8092
  with the corrected LD path + NINFER_SPEC=mtp (the unit pins mtp; run.sh 'tuned' defaults dflash2 —
  must override for the MTP3 int8 artifact). Serving verified: /v1/models honest 65k, completion OK,
  20140 MiB VRAM. Manual process is nohup'd; it dies at reboot — the unit takes over after the switch.
