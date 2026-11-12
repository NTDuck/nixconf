#!/usr/bin/env bash
# Reproducible Coder390 -> NInfer v3 conversion (2026-11-11).
# Prereqs: converter venv at /home/ayin/models/q27-bench/ninfer-convert/.venv
# (python 3.11 + torch cu132 + numpy + safetensors + gguf), GPU free.
set -euo pipefail
CONV=/home/ayin/models/q27-bench/ninfer-convert
SRC=/home/ayin/models/q27-bench/downloads/coder390
OUT=$SRC/coder390_qwen3_8_27b.ninfer

cd "$CONV"
LD_LIBRARY_PATH=/run/opengl-driver/lib:${LD_LIBRARY_PATH:-} \
.venv/bin/python -m tools.convert \
  --model "$SRC/BF16" \
  --recipe qwen3_8_27b \
  --source imatrix="$SRC/coder390.imatrix.safetensors" \
  --source dflash2="$SRC/BF16/DFlash2-FP8" \
  --components text,vision,mtp,dflash2 \
  --proposal --name qwen3.8-27b-coder390 \
  --out "$OUT"
