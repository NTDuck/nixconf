#!/usr/bin/env bash
# 2026-10-10 variant campaign driver (user roster): 8 qwen3.8-27B weight
# variants, sequential on the single 3090. Per variant: download ->
# (.ninfer) upgrade or (safetensors) convert -> screening -> long ladder
# -> artifact cleanup. Resume-safe: cells.jsonl last-wins via
# done_keys(); a variant with all 20 cells present is skipped. Disk
# guard: abort before any download that would leave <20G free.
#
# Long jobs rule: launched via setsid nohup, survives tool-call teardown.
set -uo pipefail
ROOT=/home/ayin/projs/nixconf/benchmarks/engines-2026-10
ASH=/home/ayin/models/q27-bench/ashalliants/ninfer-rtx3090-linux-x64-0.15.0-rtx3090
CONV=/home/ayin/models/q27-bench/ninfer-convert
DL=/home/ayin/models/q27-bench/downloads
MODELS=/home/ayin/models/q27-bench/models
mkdir -p "$DL" "$MODELS"

log() { echo "[$(date -u +%H:%M:%S)] $*"; }
# aria2 is not on the host PATH; pinned store path (curl fallback
# measured 3-8 MiB/s vs aria2 16-connection ~25 MiB/s on HF artifacts).
ARIA2=/nix/store/3m04gh06rfqj917212jarbk53gm45j9m-aria2-1.37.0-bin/bin/aria2c
have() { grep -q "\"tag\": \"$1\"" "$ROOT/results/cells.jsonl" 2>/dev/null; }

cells_for() { grep -c "\"tag\": \"$1\"" "$ROOT/results/cells.jsonl" 2>/dev/null || true; }

disk_free_g() { df -BG /home | tail -1 | awk '{print int($4)}'; }

sweep_one() {
  local tag=$1
  if [ "$(cells_for "$tag")" -ge 20 ]; then
    log "$tag: all 20 cells present, skipping"; return 0
  fi
  log "$tag: sweep starting ($(cells_for "$tag") cells present)"
  ( cd "$ROOT" \
    && .venv/bin/python run_sweep.py --stage screening --only "$tag" \
    && .venv/bin/python run_sweep.py --stage long --only "$tag" ) \
    || log "$tag: sweep returned nonzero (overflow/deadlock cells are ledgered)"
  log "$tag: sweep finished ($(cells_for "$tag") cells)"
}

fetch() { # fetch <url> <dest>
  local url=$1 dest=$2
  [ -f "$dest" ] && { log "  cached: $dest"; return 0; }
  local free; free=$(disk_free_g)
  if [ "$free" -lt 20 ]; then log "  DISK GUARD: ${free}G free, abort"; return 1; fi
  log "  downloading $(basename "$dest") (${free}G free)"
  mkdir -p "$(dirname "$dest")"
  if [ -x "$ARIA2" ]; then
    # aria2c -o takes a FILENAME (relative to --dir), not a path —
    # passing "models/coder390.ninfer" created engines-2026-10/home/...
    # and downloaded there (2026-10-10 10:44 probe). Use --dir=parent.
    ( cd "$(dirname "$dest")" && "$ARIA2" -q -x 16 -s 16 \
        -o "$(basename "$dest")" "$url" ) || return 1
  else
    curl -sL --fail -o "$dest" "$url" || return 1
  fi
}

upgrade_v3() { # upgrade_v3 <path>  (idempotent: v3 magic check)
  local f=$1
  [ -f "$f" ] || return 1
  if head -c 8 "$f" | od -An -tx1 | grep -q '4e 49 4e 46 45 52 00 03'; then
    log "  already v3: $(basename "$f")"; return 0
  fi
  log "  upgrading v2->v3: $(basename "$f")"
  python3 "$ASH/tools/upgrade_ninfer_v2_to_v3.py" "$f" "$f.v3" || return 1
  mv "$f.v3" "$f"
}

convert_bf16() { # convert_bf16 <hf_repo_dir> <out.ninfer> <name>
  local src=$1 out=$2
  [ -f "$out" ] && { log "  cached: $(basename "$out")"; return 0; }
  local free; free=$(disk_free_g)
  if [ "$free" -lt 25 ]; then log "  DISK GUARD: ${free}G free, abort"; return 1; fi
  log "  converting bf16 -> .ninfer (recipe qwen3_8_27b, text,vision,mtp,proposal)"
  # torch needs libcuda.so.1 (driver lib) from /run/opengl-driver/lib;
  # not on the default loader path on NixOS (see stage_coder390 note).
  local conv_env="LD_LIBRARY_PATH=/run/opengl-driver/lib:${LD_LIBRARY_PATH:-}"
  ( cd "$CONV" && env "$conv_env" .venv/bin/python -m tools.convert \
      --model "$src" \
      --recipe qwen3_8_27b \
      --components text,vision,mtp \
      --resource chat_template.jinja="$ASH/tools/chat_templates/qwen3_8.jinja" \
      --proposal --name qwen3.8-27b --out "$out" ) || return 1
  # The bf16 staging tree (~55G) exhausted 7.5G disk on the 2026-10-10
  # first run — discard once the artifact encodes it fully.
  rm -rf "$src.tmpdl" "${src%/}" 
  rmdir --ignore-fail-on-non-empty "$DL" 2>/dev/null || true
}

run_variant() { local tag=$1; sweep_one "$tag"; }

# ---------------- per-variant stages ----------------

stage_coder390() {
  # Publisher's .ninfer tiers are gguf_blocks_v1 — unsupported by the
  # 0.15.0 engine (startup FATAL, 2026-10-10). Convert BF16 + DFlash2-FP8
  # draft instead: dflash2 lane, comparable to ashalliants-df2.
  local dir="$DL/nerkyor_coder390"
  local out="$ASH/models/coder390_dflash2.ninfer"
  [ -f "$out" ] || {
    [ -f "$dir/BF16/model-00002-of-00002.safetensors" ] || {
      local free; free=$(disk_free_g)
      [ "$free" -lt 110 ] && { log "  DISK GUARD: ${free}G < 115 for bf16+draft, abort"; return 1; }
      log "  cloning BF16 (~52G) + DFlash2-FP8 draft (2.4G)"
      hf download nerkyor/Qwen3.8-27B-Coder390-EfficientThink-Opus5.5-GPT6Astra-Grok4.7-DSV4Pro-K3-SFT-RLOO-MTP-DFlash2 \
        --include "BF16/*" --local-dir "$dir" || return 1
    }
    # Draft ships 128x128 block-scale FP8; the converter only understands
    # per-row scales -> expand to plain BF16 first (dequant_dflash.py).
    # Initializer prefers the deq dir so re-runs after purging the FP8
    # original still resolve to the expanded draft, not the base model.
    local conv_src="$dir/BF16/DFlash2-FP8-deq"
    [ -d "$conv_src" ] || conv_src="$dir/BF16/DFlash2-FP8"
    if [ -f "$dir/BF16/DFlash2-FP8/model.safetensors" ]; then
      log "  expanding block-FP8 draft -> BF16"
      "$CONV/.venv/bin/python" "$ROOT/dequant_dflash.py" \
        "$dir/BF16/DFlash2-FP8" "$dir/BF16/DFlash2-FP8-deq" || return 1
      conv_src="$dir/BF16/DFlash2-FP8-deq"
    fi
    log "  converting bf16 + dflash2 -> .ninfer (recipe qwen3_8_27b)"
    # torch needs libcuda.so.1 (driver lib) which lives in
    # /run/opengl-driver/lib on NixOS and is NOT on the default loader
    # path; without it conversions die with "Found no NVIDIA driver".
    local conv_env="LD_LIBRARY_PATH=/run/opengl-driver/lib:${LD_LIBRARY_PATH:-}"
    ( cd "$CONV" && env "$conv_env" .venv/bin/python -m tools.convert \
        --model "$dir/BF16" \
        --recipe qwen3_8_27b \
        --source dflash2="$conv_src" \
        --components text,vision,mtp,dflash2 \
        --resource chat_template.jinja="$ASH/tools/chat_templates/qwen3_8.jinja" \
        --proposal --name qwen3.8-27b-coder390 --out "$out" ) || return 1
    # Discard the ~55G bf16 staging tree once encoded (disk-pressure
    # lesson from the 2026-10-10 first run).
    rm -rf "$dir"
  }
  run_variant coder390
}

stage_swift15() {
  local dir="$DL/ukisai_Swift-1.5-Qwen3.8-27b"
  local out="$ASH/models/swift15_qwen3_8_27b.ninfer"
  [ -f "$out" ] || {
    [ -d "$dir" ] && [ -n "$(ls -A "$dir" 2>/dev/null)" ] || {
      local free; free=$(disk_free_g)
      [ "$free" -lt 75 ] && { log "  DISK GUARD: ${free}G < 80 for bf16, abort"; return 1; }
      log "  cloning bf16 repo (~54G)"
      HF_HUB_ENABLE_HF_TRANSFER=0 hf download \
        ukisai/Swift-1.5-Qwen3.8-27b --local-dir "$dir" || return 1
    }
    convert_bf16 "$dir" "$out" || return 1
  }
  run_variant swift15
}

stage_huihui() {
  local dir="$DL/huihui_Huihui-Qwen3.8-27B-abliterated"
  local out="$ASH/models/huihui_abl_qwen3_8_27b.ninfer"
  [ -f "$out" ] || {
    [ -d "$dir" ] && [ -n "$(ls -A "$dir" 2>/dev/null)" ] || {
      local free; free=$(disk_free_g)
      [ "$free" -lt 75 ] && { log "  DISK GUARD: ${free}G < 80 for bf16, abort"; return 1; }
      log "  cloning bf16 repo (~54G)"
      HF_HUB_ENABLE_HF_TRANSFER=0 hf download \
        huihui-ai/Huihui-Qwen3.8-27B-abliterated --local-dir "$dir" || return 1
    }
    convert_bf16 "$dir" "$out" || return 1
  }
  run_variant huihui-abl
}

stage_obliterated() {
  local dir="$DL/OBLITERATUS_Qwen3.8-27B-OBLITERATED"
  local out="$ASH/models/obliterated_qwen3_8_27b.ninfer"
  [ -f "$out" ] || {
    [ -d "$dir" ] && [ -n "$(ls -A "$dir" 2>/dev/null)" ] || {
      local free; free=$(disk_free_g)
      [ "$free" -lt 75 ] && { log "  DISK GUARD: ${free}G < 80 for bf16, abort"; return 1; }
      log "  cloning bf16 repo (~54G)"
      HF_HUB_ENABLE_HF_TRANSFER=0 hf download \
        OBLITERATUS/Qwen3.8-27B-OBLITERATED --local-dir "$dir" || return 1
    }
    convert_bf16 "$dir" "$out" || return 1
  }
  run_variant obliterated
}

gguf_variant() { # gguf_variant <tag> <url> <destname>
  local tag=$1 url=$2 name=$3
  fetch "$url" "$MODELS/$name" || return 1
  run_variant "$tag"
}

stage_thinkingcap() {
  gguf_variant thinkingcap \
    "https://huggingface.co/bottlecapai/ThinkingCap-Qwen3.8-27B-GGUF/resolve/main/ThinkingCap-Qwen3.8-27B-Q4_K_M.gguf" \
    "ThinkingCap-Qwen3.8-27B-Q4_K_M.gguf"
}

stage_davidau() {
  gguf_variant davidau-fable \
    "https://huggingface.co/DavidAU/Qwen3.8-27B-TURBO-Fable-Cold-Fusion-735-882-Heretic-Uncensored-NEO-CODER-MAX-MTP-GGUF/resolve/main/Qwen3.8-27B-TurboFCFusion-735-882-Here-Uncen-NEO-CODER-MAX-MTP-Q4_K_M.gguf" \
    "Qwen3.8-27B-TurboFCFusion-735-882-Here-Uncen-NEO-CODER-MAX-MTP-Q4_K_M.gguf"
}

stage_humanlike() {
  gguf_variant humanlike \
    "https://huggingface.co/LessThanThreeAI/Qwen3.8-27B-Humanlike-Chat-GGUF/resolve/main/Qwen3.8-27B-Humanlike-Chat-IQ4_XS.gguf" \
    "Qwen3.8-27B-Humanlike-Chat-IQ4_XS.gguf"
}

stage_fable5() {
  gguf_variant fable5 \
    "https://huggingface.co/Verkiki/Qwen3.8-27b-Fable5-Distill-Abliterated-GGUF/resolve/main/Qwen3.8-27B-LoRA-IQ4_XS-MTP.gguf" \
    "Qwen3.8-27B-LoRA-IQ4_XS-MTP.gguf"
}

cleanup_artifacts() {
  # Free resident artifacts for variants whose sweep already completed.
  local f
  for f in "$ASH/models/coder390_dflash2.ninfer" \
           "$ASH/models/swift15_qwen3_8_27b.ninfer" \
           "$ASH/models/huihui_abl_qwen3_8_27b.ninfer" \
           "$ASH/models/obliterated_qwen3_8_27b.ninfer"; do
    local base; base=$(basename "$f" .ninfer)
    case "$base" in
      coder390*) local tag=coder390 ;;
      swift15*) local tag=swift15 ;;
      huihui*) local tag=huihui-abl ;;
      obliterated*) local tag=obliterated ;;
      *) continue ;;
    esac
    if [ "$(cells_for "$tag")" -ge 20 ] && [ -f "$f" ]; then
      log "cleanup: removing $f ($tag measured)"
      rm -f "$f"
    fi
  done
}

log "=== variant campaign start ==="
for st in stage_coder390 stage_swift15 stage_huihui stage_obliterated \
          stage_thinkingcap stage_davidau stage_humanlike stage_fable5; do
  log "--- $st ---"
  "$st" || log "$st: FAILED (continuing roster)"
  cleanup_artifacts
done
log "=== variant campaign complete ==="
# Restore the resident engine (sweep's clear_gpu kills it mid-campaign).
sudo -n systemctl restart ashalliants-df2 2>/dev/null \
  || echo "528491" | sudo -S systemctl restart ashalliants-df2 2>/dev/null \
  || log "NOTE: restart ashalliants-df2 manually"
