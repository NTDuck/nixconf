# ninfer (RTX 3090 release binaries) — Qwen3.8-27B on v0.15.0 +
# Ternary Bonsai 2 27B on v0.17.2 (two engine derivations; ternary
# support landed upstream in v0.16.1)
# DFlash2 server, added 2026-10-09 from the engines-2026-10 benchmark:
# the Qwen-arm winner on BOTH criteria — peak 162.7 tok/s per-agent
# (fresh C1) and high-parallelism x deep-ctx (C6x65k 769.4 agg tok/s,
# 128.2 per-lane) — vs resident ninfer-061 (Don-Chad v0.6.1, MTP3 int8:
# 68.8 peak, best agg 168.7 at C8x32k, 3-7x slower overall).
#
# 2026-10-12 UPDATE: switched from C8x16k (1073.1 agg tok/s, but capped
# at 16k context) to C6x65k (769.4 agg tok/s, full 65k context). The
# C8x65k config OOMs (7.98 GiB runtime > 6.78 GiB available on 24 GiB
# card with 17 GiB weights). C6x65k fits and provides 3.6x more
# throughput than the previous C4x65k winner (214.5 agg tok/s).
#
#
# 2026-10-15 EVALUATION: v0.16.0 was benchmarked against v0.15.0 on the 3090.
# The v0.16.0 context cache engine rewrite (#214) increases per-lane runtime
# reservation: C6x65k OOMs (8.57 GiB > 6.78 GiB available), C8x16k OOMs (8.22 GiB),
# and C4x128k OOMs (7.59 GiB). v0.16.0 caps out at C4x65k (500.0 agg tok/s).
# v0.15.0 C6x65k (769.4 agg tok/s) strictly dominates v0.16.0 on Pareto-optimal
# parallelism x context (+50% concurrency, +54% throughput). Production stays
# on v0.15.0 C6x65k; v0.16.0 is staged at ~/models/q27-bench/ashalliants/
# ninfer-rtx3090-linux-x64-0.16.0-rtx3090 with shim for future engine updates.
# 2026-11-07 MIGRATION TO NIX STORE: The engine distribution and pinned
# model artifacts are packaged as idiomatic Nix store derivations
# (fetchzip for release binaries, fetchurl for .ninfer weights, and
# runCommand wrapper). Units use ProtectHome=true and run strictly
# against store paths.
#
# DO NOT download .ninfer weights / engine tarballs into ~/models (or
# anywhere in $HOME) when adding or updating models here: the store
# derivations above ARE the canonical copies, hash-pinned from
# upstream SHA256SUMS/HF LFS. A stray copy on disk is invisible to
# this config (units run with ProtectHome=true) and only wastes ~10-14
# GiB per file; scratch downloads during probing were deleted
# 2026-11-11 (~/models/ninfer-new — contents hash-verified against the
# pins, then removed). To add a model: fetch it once to compute the
# hash, pin it in a fetchurl here, and delete the scratch copy.
#
# 2026-11-11 VRAM SHAPE SWEEP (live nvidia-smi peaks, engine alone +
# ~150 MiB desktop, v0.15.0, no host-RAM KV): max concurrency per
# context — dflash2: 8x16k 21150 MiB, 7x32k 21144 (C8 OOMs: 6.41 GiB
# runtime vs 6.31 free), 6x65k 21462 (C7 OOMs), 4x128k 22000 (C5
# OOMs), 1x262k 23364 (C2 OOMs). turbo/mtp3: 8x16k 19562, 8x32k 19860,
# 8x65k 20454, 8x128k 21644, 5x262k 23526 (C6 OOMs). mtp3 draft state
# is ~1.6 GiB cheaper than dflash2's K=7, so turbo holds C8 to 128k.
# `ninfer list` shows these as the {C}x{ctx} column; `ninfer switch
# --context <ctx>` writes a per-unit EnvironmentFile override
# (/run/user/1000/ninfer/shape-<unit>.env) consumed by all four units.
#
# WHY run.sh + the hostkv shim: the vendor launcher pins the tuned
# profile (--spec dflash2 --draft-tokens 7 --lm-head-draft --kv-dtype
# rk4v4 --gdn-state-fp16 --vision-residency overlay, context 262144,
# --prefill-chunk 4096) and steps down context on VRAM refusal. It also
# hardcodes --host-kv-mib 8192 (8 GiB pinned host RAM) which
# systemd-oomd-killed this 15 GiB host on 2026-10-08 (94.4% pressure);
# NINFER_SERVER points at ninfer-serve.hostkv-shim (verified 2026-10-08:
# "host KV pinned | 2.00 GiB") which clamps that one flag to 2048 MiB.
# MemoryHigh/Max below are the second belt: KV spill beyond the clamp
# throttles at 10G instead of reaching oomd.
#
# VRAM ARBITRATION (24.5 GiB card, single resource): ninfer is the
# Qwen3.8 winner (23.3 GiB peak with weights+KV, measured), bonsai2
# 14.2 GiB worst case (2026-11-11 measured sweep on engine v0.17.2,
# C8x262k). All three daemons declare symmetric Conflicts — starting
# any stops the others natively.
#
# PORT (2026-10-12): the den module system does NOT support top-level
# `options` (it wraps values in aspect objects, so `den.aspects.X.port`
# returns an aspect object, not the raw value). The port is exposed as a
# let-binding `ninferPort` here and referenced via `toString ninferPort` in
# the unit's Environment + firewall rules. Remote hosts (dell) duplicate
# the value with a sync comment — cross-host option references aren't
# reliable in the den module system.
{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    # HOMELAB-ONLY (3090 specialisation pattern, see ninfer.nix header):
    # the unit + wrapper exist only inside specialisation.homelab.
    nixos = {
      pkgs,
      lib,
      ...
    }: let
      # Idiomatic Nix store derivations for ninfer 0.15.0 and pinned model artifacts.
      ninferRelease = pkgs.fetchzip {
        url = "https://github.com/ashalliants/ninfer-3090/releases/download/v0.15.0-rtx3090/ninfer-rtx3090-linux-x64-0.15.0-rtx3090.tar.gz";
        hash = "sha256-f/u4NHbVDiigLrxKrEX8vZaYPM2GKNqoVbDkgp1Rsxk=";
      };

      ninferServeHostkvShim = pkgs.writeShellScript "ninfer-serve.hostkv-shim" ''
        set -euo pipefail
        REAL="$(dirname "$0")/ninfer-serve.real"
        out=()
        while (($#)); do
          if [[ "$1" == "--host-kv-mib" ]]; then
            out+=(--host-kv-mib 2048)
            shift 2
          else
            out+=("$1")
            shift
          fi
        done
        if [[ -n "''${NINFER_MODEL_ID:-}" ]]; then
          out+=(--model-id "$NINFER_MODEL_ID")
        fi
        exec "$REAL" "''${out[@]}"
      '';

      ninferQwen38Model = pkgs.fetchurl {
        url = "https://huggingface.co/WarlaxZ/Qwen3.8-27B-NInfer-3090/resolve/d47f2732d369acaec76dc44228f67c72b081df2f/qwen3_8_27b.ninfer";
        hash = "sha256-fyoAhqBx7pMsZhBuFVLRGKhc/sjd7xPGelTNZKuzlwY=";
        curlOptsList = ["--http1.1"];
      };

      # Upstream HF artifact is still NInfer v2 (nixinfer-serve 0.15.0
      # refuses it); converted to v3 in ninferTurboModel below.
      ninferTurboModelV2 = pkgs.fetchurl {
        url = "https://huggingface.co/amynporb/Qwen3.8-27B-TURBO-NInfer/resolve/main/qwen38_turbo_sm86.ninfer";
        hash = "sha256-/4LLBv22ph2Vd4+CmcdPO55HTgSHURoVO0LwepXlmuE=";
        curlOptsList = ["--http1.1"];
      };

      # v3 conversion of the upstream v2 artifact. The upgrade tool's
      # header identity is pinned (see tools/upgrade script) so
      # this build is deterministic and byte-identical to the locally
      # verified artifact (sha256 794fbbac...).
      ninferTurboModel =
        pkgs.runCommand "qwen38_turbo_sm86-v3.ninfer" {
          nativeBuildInputs = [pkgs.python3];
        } ''
          cp -r ${./tools} ./ninfer-tools
          python3 ./ninfer-tools/upgrade_ninfer_v2_to_v3.py \
            ${ninferTurboModelV2} $out
        '';

      # 2026-11-11 BONSAI ADDITION: v0.17.2 engine (2026-11-07 release,
      # SHA256SUMS-v0.17.2-linux: 4e70a9ff...) as a second derivation.
      # Why a second engine: v0.15.0 refuses the ternary tensor format
      # (weight/000258: unknown tensor format: t2_g128_fp16); ternary
      # Bonsai 2 27B support landed in v0.16.1 (#323). The two existing
      # Qwen units stay on v0.15.0 (2026-10-15 Pareto eval: C6x65k
      # 769.4 agg tok/s vs v0.16.0's C4x65k 500.0). v0.17.2 keeps the
      # flag list identical to v0.17.1 and is the release notes'
      # officially re-measured Bonsai 2 engine on a rented RTX 3090.
      ninferReleaseV0172 = pkgs.fetchzip {
        url = "https://github.com/ashalliants/ninfer-3090/releases/download/v0.17.2-rtx3090/ninfer-rtx3090-linux-x64-0.17.2-rtx3090.tar.gz";
        # fetchzip hashes the UNPACKED tree (release SHA256SUMS pins the
        # tar.gz itself: 4e70a9ff..., verified on download).
        hash = "sha256-ZohPlbp2EOTfuJxGmfVCg7QYQxzmpNFFg7QHkd/xyrk=";
      };

      # v0.17.2 adds a pinned host-RAM context budget defaulting to 8192
      # MiB (run.sh: NINFER_HOST_CONTEXT_MIB → --host-context-mib); 8 GiB
      # pinned RAM oomd-killed this 15 GiB host on 2026-10-08 via the
      # older --host-kv-mib 8192 default. The shim therefore clamps BOTH
      # flags: host KV spill → 2048 MiB, host context budget → 0 ("0
      # keeps everything on the card" — run.sh comment). NINFER_HOST_
      # CONTEXT_MIB=0 is also exported by the bonsai unit as a belt.
      ninferServeHostkvShimV0172 = pkgs.writeShellScript "ninfer-serve.hostkv-shim-0172" ''
        set -euo pipefail
        out=()
        while (($#)); do
          if [[ "$1" == "--host-kv-mib" ]]; then
            out+=(--host-kv-mib 2048)
            shift 2
          elif [[ "$1" == "--host-context-mib" ]]; then
            out+=(--host-context-mib 0)
            shift 2
          else
            out+=("$1")
            shift
          fi
        done
        if [[ -n "''${NINFER_MODEL_ID:-}" ]]; then
          out+=(--model-id "$NINFER_MODEL_ID")
        fi
        exec "$(dirname "$0")/ninfer-serve.real" "''${out[@]}"
      '';

      # Ternary Bonsai 2 27B: 2.125-bit quant of Qwen3.8-27B, 9.52 GB
      # (6.7 GiB weights). Manifest hash from the release README
      # (WarlaxZ/Ternary-Bonsai-2-27B-NInfer-3090, verified locally with
      # sha256sum before packaging).
      # 2026-11-11 CODER390 REJECTED: Qwen3.8-27B-Coder390-EfficientThink
      # (nerkyor's GGUF-NInfer Q3LynnStyle-Q8MTP, sha256
      # 815241ba...) FATALs on every store engine — its 263 K-quant
      # tensors use layout "gguf_blocks_v1", which no ninfer release
      # implements (0.17.2: "weight/000130: unknown tensor layout";
      # unit coder390.service never engine-ready; no converter ships).
      # Re-add only after upstream ships gguf-block support or an
      # official GGUF->v3 converter. Sweep ladder + findings:
      # benchmarks/engines-2026-10/results/sweep-coder390-2026-11-11.log
      ninferBonsai2Model = pkgs.fetchurl {
        url = "https://huggingface.co/WarlaxZ/Ternary-Bonsai-2-27B-NInfer-3090/resolve/main/bonsai2_27b.ninfer";
        hash = "sha256-l1Emd01+H5/6NrZUwKb8DbQsdzuk3V8RlqndxqRtRjQ=";
        curlOptsList = ["--http1.1"];
      };

      ninferRootV0172 = pkgs.runCommand "ninfer-rtx3090-0.17.2" {} ''
        mkdir -p $out/models
        cp -r ${ninferReleaseV0172}/* $out/
        chmod -R u+w $out
        mv $out/ninfer-serve $out/ninfer-serve.real
        cp ${ninferServeHostkvShimV0172} $out/ninfer-serve.hostkv-shim
        ln -s ninfer-serve.hostkv-shim $out/ninfer-serve
        chmod +x $out/ninfer-serve.hostkv-shim
        ln -s ${ninferBonsai2Model} $out/models/bonsai2_27b.ninfer
      '';

      ninferRoot = pkgs.runCommand "ninfer-rtx3090-0.15.0" {} ''
        mkdir -p $out/models
        cp -r ${ninferRelease}/* $out/
        chmod -R u+w $out
        mv $out/ninfer-serve $out/ninfer-serve.real
        cp ${ninferServeHostkvShim} $out/ninfer-serve.hostkv-shim
        ln -s ninfer-serve.hostkv-shim $out/ninfer-serve
        chmod +x $out/ninfer-serve.hostkv-shim
        cp -r ${./tools} $out/tools
        ln -s ${ninferQwen38Model} $out/models/qwen3_8_27b.ninfer
        ln -s ${ninferTurboModel} $out/models/qwen38_turbo_sm86.ninfer
        ln -s ${ninferTurboModel} $out/models/qwen3_8_27b_turbo.ninfer
      '';
      # The four non-bundled ldd deps of the 0.15.0 binary (skill:
      # ninfer-ash-hostkv-clamp). prism-llamacpp-libs covers
      # cublas/cudart, the driver package covers libcuda (via
      # /run/opengl-driver below), ffmpeg-full covers av*/swscale, curl
      # covers libcurl.so.4. Pin the exact store paths the benchmark
      # verified (engines.py LD_LIBRARY_PATH, 2026-10-08/09 sweeps).
      ninferLibs = [
        "/run/opengl-driver/lib"
        "/nix/store/pck9wssp6ca6dfxhpz15c8p67z4r59bg-prism-llamacpp-libs/lib"
        "/nix/store/3qixz64pvv7glvnhvqsib5fwb80rrfca-nvidia-x11-595.104.02/lib"
        "/nix/store/rcz6a5zlg8vqx689qsxh1r4m8v3pn3ic-ffmpeg-full-6.1.6-lib/lib"
        "/nix/store/cjxc4x3cnlzlcdrsi92k5i7pkn78ixnz-curl-8.21.0/lib"
      ];

      # Port the ninfer-serve listens on. Single source of truth for
      # this host; remote hosts (dell) duplicate the value with a sync
      # comment in their models.yml.
      ninferPort = 8092;
      # `ninfer --version` strings. CLI release line + the two engine
      # distributions packaged below (v0.15.0 Qwen arm, v0.17.2
      # bonsai2 arm) — bump all three together.
      ninferCliVersion = "1.1.0";
      engineVersionV0150 = "0.15.0-rtx3090";
      engineVersionV0172 = "0.17.2-rtx3090";
      # 2026-10-18: Native shell CLI. Fast (<5ms), minimal UI,
      # canonical IDs only (no aliases), <nil> unloader, and full shell completions.
      # 2026-10-31: Renamed ashalliant CLI to ninfer (clean cutover).
      # 2026-11-06: Replaced qwen3.8-27b-abliterated with qwen3.8-27b-turbo.
      # 2026-11-07: Removed qwen3.6 models; enhanced switch with responsive progress bar and milestone logging.
      # 2026-11-11: TUI removed; tabular list (ID/NAME/CONCURRENCYxCONTEXT,
      # alphabetical, <nil> last, bold ACTIVE row); positional
      # `switch <model-id> [C]x<ctx>` grammar; bonsai2 id -> bonsai2-27b
      # with only the 8x262144 champion shape; --version/-v.
      ninfer = pkgs.stdenv.mkDerivation {
        pname = "ninfer";
        version = "1.0.0";

        dontUnpack = true;

        installPhase = ''
                    runHook preInstall
                    mkdir -p $out/bin $out/share/zsh/site-functions $out/share/bash-completion/completions $out/share/fish/vendor_completions.d

                    cat << 'SCRIPT' > $out/bin/ninfer
          #!/usr/bin/env bash
          set -euo pipefail

          # Pass --no-ask-password to prevent hanging on polkit TTY prompts when non-interactive.
          SYSTEMCTL=( "${pkgs.systemd}/bin/systemctl" --no-ask-password )

          MODELS=(
            "bonsai2-27b|Ternary Bonsai 2 27B|bonsai2.service|${toString ninferPort}"
            "qwen3.8-27b|Qwen 3.8 27B DFlash2|ninfer-df2.service|${toString ninferPort}"
            "qwen3.8-27b-turbo|Qwen 3.8 27B Turbo (Heretic)|ninfer-df2-turbo.service|${toString ninferPort}"
          )

          # Measured max concurrency per context on the RTX 3090 (2026-11-11,
          # engine v0.15.0, engine alone + ~150 MiB desktop, no host-RAM KV):
          # each "C x ctx : peak-MiB" triple is a live nvidia-smi peak; the
          # next concurrency up at the same context OOM'd at startup
          # (dflash2 C8x32k wanted 6.41 GiB runtime vs 6.31 free). dflash2
          # costs ~1.6 GiB more than turbo at the same shape (K=7 draft
          # state), so its table is strictly worse except 16k.
          # Format: model|ctx:conc:peak,ctx:conc:peak,...
          # 2026-11-11 user request: each model pins ONE champion shape
          # (the full per-model tables live in the sweep logs); bonsai2
          # keeps only its max-context C8 cell.
          SHAPES=(
            "qwen3.8-27b|16384:8:21150,32768:7:21144,65536:6:21462,131072:4:22000,262144:1:23364"
            "qwen3.8-27b-turbo|16384:8:19562,32768:8:19860,65536:8:20454,131072:8:21644,262144:5:23526"
            # bonsai2 on engine v0.17.2 (2026-11-11 sweep, ternary 9.5 GB
            # weights): 6.7 GiB weights leave so much KV room that C8
            # (engine's hard --max-concurrency cap) holds at EVERY
            # context, including full 262k. Peak 14166 MiB = ~10 GiB
            # headroom below the 24.5 GiB card.
            "bonsai2-27b|262144:8:14166"
          )
          # Unit default shape (what Environment= in the unit pins); a
          # --context equal to this clears the override file instead of
          # writing one. Per-model: bonsai2's champion default is C8
          # (its tiny ternary weights hold C8 at every context, so its
          # single SHAPES cell 8x262144 also validates), while both
          # Qwen units run their Pareto winner C6x65k.
          DEFAULT_CTX=65536
          DEFAULT_CONC=6
          # Per-model unit default shape (2026-11-11): what a bare
          # `switch <model>` means. bonsai2-27b's user-pruned SHAPES
          # keeps only its 262k champion cell, so its default IS that
          # cell (the shape file is written on switch; the unit
          # Environment C8x65536 only applies if the unit starts with
          # no override). Used by do_switch and as the ACTIVE fallback
          # when neither /props nor the shape file yields values.
          default_shape_for() {
            case "$1" in
              bonsai2-27b) echo "8x262144" ;;
              *) echo "''${DEFAULT_CONC}x''${DEFAULT_CTX}" ;;
            esac
          }

          shapes_for() {
            for entry in "''${SHAPES[@]}"; do
              IFS='|' read -r mid specs <<< "$entry"
              if [ "$mid" = "$1" ]; then
                echo "$specs"
                return 0
              fi
            done
            return 1
          }

          # Validate ctx against the measured table; echo "conc ctx" on hit.
          shape_for_ctx() {
            local specs ctx c ctxv peak
            specs="$(shapes_for "$1")" || return 1
            for pair in ''${specs//,/ }; do
              IFS=':' read -r ctxv c peak <<< "$pair"
              if [ "$ctxv" = "$2" ]; then
                echo "$c $ctxv"
                return 0
              fi
            done
            return 1
          }

          shapes_column() {
            local specs pair ctxv c peak out=""
            specs="$(shapes_for "$1")" || { echo "-"; return 0; }
            local first=1
            for pair in ''${specs//,/ }; do
              IFS=':' read -r ctxv c peak <<< "$pair"
              [ "$first" = 1 ] || out+=","
              out+="''${c}x$ctxv"
              first=0
            done
            echo "$out"
          }

          # Output contract (2026-11-11 user request): header line, then
          # "ID<TAB>NAME<TAB>CONCURRENCYxCONTEXT" per model (alphabetical,
          # <nil> last), blank line, "ACTIVE:", then the active row in
          # bold. active_shape_line resolves the live shape from the
          # engine's /props, falling back to the unit's EnvironmentFile
          # override then its Environment= defaults.
          show_list() {
            local active_mid
            active_mid="$(get_active 2>/dev/null || true)"
            printf "ID\tNAME\tCONCURRENCYxCONTEXT\n"
            local entry mid name shapes
            for entry in "''${MODELS[@]}"; do
              IFS='|' read -r mid name svc port <<< "$entry"
              shapes="$(shapes_column "$mid")"
              printf "%s\t%s\t%s\n" "$mid" "$name" "''${shapes:--}"
            done
            printf "<nil>\tUnload all ninfer models\t-\n"
            echo
            echo "ACTIVE:"
            if [ -n "$active_mid" ]; then
              local active_shape
              active_shape="$(active_shape_line "$active_mid")"
              printf "\033[1m%s\t%s\t%s\033[0m\n" "$active_mid" "$(name_for "$active_mid")" "$active_shape"
            else
              printf "\033[1m<nil>\tUnload all ninfer models\t-\033[0m\n"
            fi
          }

          name_for() {
            local entry mid name svc port
            for entry in "''${MODELS[@]}"; do
              IFS='|' read -r mid name svc port <<< "$entry"
              if [ "$mid" = "$1" ]; then
                echo "$name"
                return 0
              fi
            done
            echo "$1"
          }

          # Current engine shape for the active model: prefer the live
          # engine via /props, fall back to the unit's EnvironmentFile
          # override, then to the unit Environment= defaults.
          active_shape_line() {
            local mid="''$1" conc ctx
            local props
            props="$(${pkgs.curl}/bin/curl -s -m 0.5 http://127.0.0.1:${toString ninferPort}/props 2>/dev/null || true)"
            if [ -n "$props" ]; then
              # Live engine: total_slots = concurrency, n_ctx = context
              # (verified against the 0.15.0 /props schema 2026-11-11).
              conc="$(${pkgs.jq}/bin/jq -r '.total_slots // empty' <<< "$props" 2>/dev/null || true)"
              ctx="$(${pkgs.jq}/bin/jq -r '.default_generation_settings.n_ctx // empty' <<< "$props" 2>/dev/null || true)"
            fi
            if [ -z "$conc" ] || [ -z "$ctx" ]; then
              local unit shape_file
              unit="$(service_for "$mid")"; unit="''${unit%.service}"
              shape_file="''${XDG_RUNTIME_DIR:-/run/user/1000}/ninfer/shape-''$unit.env"
              if [ -r "$shape_file" ]; then
                conc="$(${pkgs.gnused}/bin/sed -n 's/^NINFER_CONCURRENCY=//p' "$shape_file")"
                ctx="$(${pkgs.gnused}/bin/sed -n 's/^NINFER_CONTEXT=//p' "$shape_file")"
              fi
            fi
            # Last resort: the model's unit default shape — never "?x?".
            if [ -z "$conc" ] || [ -z "$ctx" ]; then
              local d="''$(default_shape_for "$mid")"
              conc="''${d%%x*}"; ctx="''${d#*x}"
            fi
            echo "''${conc}x''${ctx}"
          }

          service_for() {
            local entry mid name svc port
            for entry in "''${MODELS[@]}"; do
              IFS='|' read -r mid name svc port <<< "$entry"
              if [ "$mid" = "$1" ]; then
                echo "$svc"
                return 0
              fi
            done
            return 1
          }

          get_active() {
            # Consult persistent user runtime state file first so multi-variant targets
            # accurately report the user-selected variant rather than always defaulting to the first match.
            local state_file="''${XDG_RUNTIME_DIR:-/tmp}/ninfer/active-model"
            if [ -r "$state_file" ]; then
              local saved_mid
              saved_mid="$(cat "$state_file" 2>/dev/null || true)"
              if [ -n "$saved_mid" ]; then
                local entry mid name svc port
                for entry in "''${MODELS[@]}"; do
                  IFS='|' read -r mid name svc port <<< "$entry"
                  if [ "$mid" = "$saved_mid" ]; then
                    if "''${SYSTEMCTL[@]}" is-active --quiet "$svc" 2>/dev/null; then
                      echo "$saved_mid"
                      return 0
                    fi
                    break
                  fi
                done
              fi
            fi

            local entry mid name svc port
            for entry in "''${MODELS[@]}"; do
              IFS='|' read -r mid name svc port <<< "$entry"
              if "''${SYSTEMCTL[@]}" is-active --quiet "$svc" 2>/dev/null; then
                echo "$mid"
                return 0
              fi
            done

            # Fallback: probe ninfer directly on its port if started outside systemctl
            local mpath
            mpath="$( ${pkgs.curl}/bin/curl -s -m 0.5 http://127.0.0.1:${toString ninferPort}/props 2>/dev/null | ${pkgs.jq}/bin/jq -r '.model_path // empty' 2>/dev/null || true )"
            if [ -n "$mpath" ]; then
              case "$mpath" in
                *turbo*) echo "qwen3.8-27b-turbo"; return 0 ;;
                *bonsai2*) echo "bonsai2-27b"; return 0 ;;
                *qwen3_8_27b*) echo "qwen3.8-27b"; return 0 ;;
              esac
            fi

            return 1
          }

          do_switch() {
            local target="''$1"
            local want_shape="''${2:-}"
            local state_dir="''${XDG_RUNTIME_DIR:-/tmp}/ninfer"
            local state_file="''$state_dir/active-model"
            # Per-unit shape override file read by the system manager
            # (EnvironmentFile=-/run/user/1000/ninfer/shape-<unit>.env; optional
            # '-' so a missing file = unit Environment= defaults). Read by the
            # manager itself (root), so PrivateTmp/ProtectSystem are irrelevant;
            # /run/user/1000 (User=ayin, UID 1000, pinned below) avoids /tmp
            # tmpfiles age-cleanup and sits beside active-model. Cleared on
            # <nil> and on default-shape switches so a boot restart uses the
            # unit default shape.
            local shape_dir="''${XDG_RUNTIME_DIR:-/run/user/1000}/ninfer"
            shape_env_for() {
              echo "''$shape_dir/shape-''$1.env"
            }

            if [ "''$target" = "<nil>" ] || [ "''$target" = "nil" ]; then
              local stopping=0
              local entry mid name svc port
              for entry in "''${MODELS[@]}"; do
                IFS='|' read -r mid name svc port <<< "''$entry"
                if "''${SYSTEMCTL[@]}" is-active --quiet "''$svc" 2>/dev/null; then
                  printf "Stopping %s (%s)... " "''$mid" "''$svc"
                  "''${SYSTEMCTL[@]}" stop "''$svc" 2>/dev/null || true
                  echo "done."
                  stopping=1
                fi
              done
              rm -f "''$state_file" 2>/dev/null || true
              rm -f "''$(shape_env_for ninfer-df2)" "''$(shape_env_for ninfer-df2-turbo)" "''$(shape_env_for bonsai2)" 2>/dev/null || true
              echo "✔ Unloaded all models (switched to <nil>)"
              return 0
            fi

            local found_svc=""
            local canonical=""
            local target_port=""
            local entry mid name svc port
            for entry in "''${MODELS[@]}"; do
              IFS='|' read -r mid name svc port <<< "''$entry"
              if [ "''$mid" = "''$target" ]; then
                found_svc="''$svc"
                canonical="''$mid"
                target_port="''$port"
                break
              fi
            done

            if [ -z "''$found_svc" ]; then
              echo "error: unknown model ''$target" >&2
              echo "       available: bonsai2-27b, qwen3.8-27b, qwen3.8-27b-turbo, <nil>" >&2
              exit 1
            fi

            local prev_active
            prev_active="''$(get_active 2>/dev/null || true)"
            mkdir -p "''$state_dir" "''$shape_dir" 2>/dev/null || true
            echo "''$canonical" > "''$state_file" 2>/dev/null || true

            # Shape selection: "conc x ctx" validated against the measured
            # table (2026-11-11 grammar: `ninfer switch <model> <C>x<ctx>`;
            # bare <model> = the model's unit default shape).
            local target_shape
            target_shape="$(default_shape_for "$canonical")"
            local shape_file
            shape_file="''$(shape_env_for ''${found_svc%.service})"
            if [ -n "''$want_shape" ]; then
              local shape_conc shape_ctx ctx_conc_val
              shape_conc="''${want_shape%%x*}"
              shape_ctx="''${want_shape#*x}"
              if ! [[ "''$shape_conc" =~ ^[0-9]+$ ]] || ! [[ "''$shape_ctx" =~ ^[0-9]+$ ]]; then
                echo "error: shape ''$want_shape must look like <concurrency>x<context> (e.g. 8x262144)" >&2
                return 1
              fi
              ctx_conc_val="''$(shape_for_ctx "''$canonical" "''$shape_ctx" | cut -d' ' -f1)" || true
              if [ -z "''$ctx_conc_val" ] || [ "''$ctx_conc_val" != "''$shape_conc" ]; then
                echo "error: shape ''$want_shape is not a measured shape for ''$canonical" >&2
                echo "       measured: ''$(shapes_column "''$canonical")" >&2
                return 1
              fi
              # The override must carry the EXACT requested shape; write it
              # unless it equals the unit's Environment= shape (C6/C8 at
              # 65536) so a boot restart without the file stays honest.
              if [ "''$shape_ctx" = "''$DEFAULT_CTX" ] && [ "''$shape_conc" = "''$DEFAULT_CONC" ]; then
                rm -f "''$shape_file" 2>/dev/null || true
              elif [ "''$shape_conc" = "8" ] && [ "''$shape_ctx" = "''$DEFAULT_CTX" ]; then
                rm -f "''$shape_file" 2>/dev/null || true
              else
                {
                  echo "NINFER_CONCURRENCY=''${shape_conc}"
                  echo "NINFER_CONTEXT=''${shape_ctx}"
                  echo "NINFER_KV_CAPACITY=''${shape_ctx}"
                  echo "NINFER_HOST_STATE_SLOTS=''${shape_conc}"
                } > "''$shape_file"
              fi
              target_shape="''$want_shape"
            else
              # No shape given: the model's unit default shape. When that
              # default is NOT the unit Environment= shape (bonsai2-27b:
              # 8x262144 vs the unit's C8x65536), write the override so
              # the "Switching to ..." shape is what actually boots.
              if [ "''$target_shape" != "8x''$DEFAULT_CTX" ] && [ "''$target_shape" != "''$DEFAULT_CONC"x"''$DEFAULT_CTX" ]; then
                local d_conc="''${target_shape%%x*}" d_ctx="''${target_shape#*x}"
                {
                  echo "NINFER_CONCURRENCY=''${d_conc}"
                  echo "NINFER_CONTEXT=''${d_ctx}"
                  echo "NINFER_KV_CAPACITY=''${d_ctx}"
                  echo "NINFER_HOST_STATE_SLOTS=''${d_conc}"
                } > "''$shape_file"
              else
                rm -f "''$shape_file" 2>/dev/null || true
              fi
            fi

            # Fast path: already active and responding on HTTP. Only when NO
            # shape was given: the engine may currently run a non-default
            # shape (a prior `switch <model> <C>x<ctx>` left its
            # EnvironmentFile), so a shape switch must always restart to
            # apply the shape file.
            if [ -z "''$want_shape" ]; then
              if "''${SYSTEMCTL[@]}" is-active --quiet "''$found_svc" 2>/dev/null; then
                if ${pkgs.curl}/bin/curl -s -m 0.5 "http://127.0.0.1:''$target_port/v1/models" >/dev/null 2>&1; then
                  echo "✔ Already active and responding on ''$canonical (:''$target_port)"
                  return 0
                fi
              fi
            fi

            # Stop any conflicting active services first
            for entry in "''${MODELS[@]}"; do
              IFS='|' read -r mid name svc port <<< "$entry"
              if [ "$svc" != "$found_svc" ] && "''${SYSTEMCTL[@]}" is-active --quiet "$svc" 2>/dev/null; then
                printf "Stopping %s (%s)... " "$mid" "$svc"
                "''${SYSTEMCTL[@]}" stop --no-block "$svc" 2>/dev/null || true
                while "''${SYSTEMCTL[@]}" is-active --quiet "$svc" 2>/dev/null; do
                  sleep 0.1
                done
                echo "done."
              fi
            done

            echo "Switching to $canonical ($target_shape)..."

            local start_sec=$SECONDS
            local journal_cursor
            journal_cursor="$(${pkgs.systemd}/bin/journalctl -u "$found_svc" -n 0 --show-cursor 2>/dev/null | grep '^-- cursor:' | cut -d' ' -f2- || true)"

            if ! "''${SYSTEMCTL[@]}" start --no-block "$found_svc"; then
              rm -f "$state_file" 2>/dev/null || true
              echo "error: failed to start $found_svc" >&2
              exit 1
            fi

            local is_tty=0
            [ -t 1 ] && is_tty=1

            local spinner_chars=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
            local spin_idx=0
            local last_status=""
            local last_logged_line=""
            local substate=""

            while true; do
              local elapsed=$(( SECONDS - start_sec ))
              local spin="''${spinner_chars[$spin_idx]}"
              spin_idx=$(( (spin_idx + 1) % ''${#spinner_chars[@]} ))

              if "''${SYSTEMCTL[@]}" is-failed --quiet "$found_svc" 2>/dev/null; then
                [ "$is_tty" -eq 1 ] && printf "\r\033[K"
                echo "❌ $found_svc failed to start!" >&2
                ${pkgs.systemd}/bin/journalctl -u "$found_svc" -n 15 --no-pager >&2 || true
                rm -f "$state_file" 2>/dev/null || true
                exit 1
              fi

              # Check if HTTP endpoint is live
              if ${pkgs.curl}/bin/curl -s -m 0.5 "http://127.0.0.1:''''$target_port/v1/models" >/dev/null 2>&1; then
                [ "$is_tty" -eq 1 ] && printf "\r\033[K"
                echo "✔ Ready in ''${elapsed}s | listening on http://0.0.0.0:$target_port"
                echo "switched to $canonical"
                return 0
              fi

              local latest_line=""
              if [ -n "$journal_cursor" ]; then
                latest_line="$(${pkgs.systemd}/bin/journalctl -u "$found_svc" --after-cursor="$journal_cursor" -o cat --no-pager 2>/dev/null | tail -n 1 || true)"
              else
                latest_line="$(${pkgs.systemd}/bin/journalctl -u "$found_svc" -n 1 -o cat --no-pager 2>/dev/null || true)"
              fi

              local progress_desc=""
              if [[ "$latest_line" =~ loading[[:space:]]+weights[[:space:]]+([0-9.]+)% ]]; then
                local pct="''${BASH_REMATCH[1]}"
                local int_pct=''${pct%.*}
                int_pct=''${int_pct:-0}
                local bar_width=20
                local filled=$(( int_pct * bar_width / 100 ))
                local empty=$(( bar_width - filled ))
                local bar=""
                for ((b=0; b<filled; b++)); do bar+="█"; done
                for ((b=0; b<empty; b++)); do bar+="░"; done
                progress_desc="[$bar] $pct% ($latest_line)"
              elif [ -n "$latest_line" ] && [ "$latest_line" != "$last_logged_line" ]; then
                if [[ "$latest_line" =~ (weights\ ready|host\ state\ pinned|host\ KV\ pinned|CUDA\ graphs\ ready|engine\ ready|starting\ engine|API:) ]]; then
                  if [ "$is_tty" -eq 1 ]; then
                    printf "\r\033[K  → %s\n" "$latest_line"
                  else
                    echo "  → $latest_line"
                  fi
                  last_logged_line="$latest_line"
                else
                  progress_desc="$latest_line"
                fi
              fi

              if [ -z "$progress_desc" ]; then
                substate="$(${pkgs.systemd}/bin/systemctl show -p SubState --value "$found_svc" 2>/dev/null || echo "starting")"
                if [ "$substate" = "condition" ] || [ "$substate" = "start-pre" ]; then
                  progress_desc="[boot-gate] verifying GPU & model artifact..."
                else
                  progress_desc="initializing engine ($substate)..."
                fi
              fi

              if [ "$is_tty" -eq 1 ]; then
                printf "\r\033[K  %s %s (%ds)" "$spin" "$progress_desc" "$elapsed"
              elif [ "$progress_desc" != "$last_status" ] && [ "$(( elapsed % 3 ))" -eq 0 ]; then
                echo "  [ninfer] $progress_desc (''${elapsed}s)"
                last_status="$progress_desc"
              fi

              if [ "$elapsed" -gt 180 ]; then
                [ "$is_tty" -eq 1 ] && printf "\r\033[K"
                echo "error: timeout waiting for $found_svc to become ready (>180s)" >&2
                ${pkgs.systemd}/bin/journalctl -u "$found_svc" -n 20 --no-pager >&2 || true
                exit 1
              fi

              sleep 0.2
            done
          }



          cmd="''${1:-}"
          case "$cmd" in
            active|current)
              get_active
              ;;
            ""|list|status)
              show_list
              ;;
            switch)
              # Grammar (2026-11-11): switch <model-id> [C]x<ctx>. Model ids
              # and shapes are validated in do_switch; extra args rejected here.
              if [ $# -lt 2 ] || [ $# -gt 3 ]; then
                echo "usage: ninfer switch <model-id> [concurrencyxcontext]" >&2
                exit 2
              fi
              do_switch "$2" "''${3:-}"
              ;;
            -v|--version|version)
              echo "ninfer ${ninferCliVersion} (engine ${engineVersionV0150} / ${engineVersionV0172})"
              ;;
            -h|--help|help)
              echo "usage: ninfer [switch <model-id> [C]x<ctx> | list | active | -v]"
              echo "  switch <model-id> [C]x<ctx>"
              echo "                 switch active model; shape validated against the"
              echo "                 measured table shown by 'ninfer list' (omit for the"
              echo "                 unit default shape)"
              echo "  -v, --version show ninfer and engine versions"
              ;;
            *)
              for entry in "''${MODELS[@]}"; do
                IFS='|' read -r mid name svc port <<< "$entry"
                if [ "$mid" = "$cmd" ]; then
                  # Direct model invocation: ninfer <model-id> [C]x<ctx>
                  if [ $# -gt 2 ]; then
                    echo "error: unexpected argument '$3'" >&2
                    exit 2
                  fi
                  do_switch "$cmd" "''${2:-}"
                  exit 0
                fi
              done
              if [ "$cmd" = "<nil>" ] || [ "$cmd" = "nil" ]; then
                do_switch "<nil>" ""
                exit 0
              fi
              echo "unknown command '$cmd', run 'ninfer -h' for usage" >&2
              exit 1
              ;;
          esac
          SCRIPT
                    chmod +x $out/bin/ninfer

                    # Shell completions (2026-11-11 grammar): ids and
                    # shape tokens only — no descriptions (user request:
                    # noise-free autosuggestion).
                    cat << 'ZSH' > $out/share/zsh/site-functions/_ninfer
          #compdef ninfer

          _ninfer() {
            local curcontext="$curcontext" state line
            typeset -A opt_args

            local -a commands models shapes
            commands=(
              'switch:switch active model'
              'active:show active model'
              'current:show active model'
              'list:list models'
              'status:show status'
              'version:show version'
            )

            models=(
              'bonsai2-27b'
              'qwen3.8-27b'
              'qwen3.8-27b-turbo'
              '\<nil\>'
              'nil'
            )

            shapes=(
              '8x16384'
              '7x32768'
              '8x262144'
              '6x65536'
              '4x131072'
              '1x262144'
              '5x262144'
            )

            _arguments -C \
              '-v[show version]' \
              '--version[show version]' \
              '-h[show help]' \
              '--help[show help]' \
              '1:command or model:->cmd_or_model' \
              '*:args:->args' \
              && return 0

            case "$state" in
              cmd_or_model)
                _describe -t commands 'command' commands
                _describe -t models 'model' models
                ;;
              args)
                case "''${words[2]}" in
                  switch)
                    if [ "$CURRENT" -eq 3 ]; then
                      _describe -t models 'model' models
                    else
                      _describe -t shapes 'shape' shapes
                    fi
                    ;;
                esac
                ;;
            esac
          }

          _ninfer "$@"
          ZSH

                    cat << 'BASH' > $out/share/bash-completion/completions/ninfer
          _ninfer_completion() {
            local cur prev
            cur="''${COMP_WORDS[COMP_CWORD]}"
            prev="''${COMP_WORDS[COMP_CWORD-1]}"

            local models="bonsai2-27b qwen3.8-27b qwen3.8-27b-turbo <nil> nil"
            local commands="switch list status active current version"
            local shapes="8x16384 7x32768 6x65536 4x131072 1x262144 5x262144 8x262144"

            if [ "$COMP_CWORD" -eq 2 ] && [ "''${COMP_WORDS[1]}" = "switch" ]; then
              COMPREPLY=( $(compgen -W "$models" -- "$cur") )
              return 0
            elif [ "$COMP_CWORD" -eq 3 ] && [ "''${COMP_WORDS[1]}" = "switch" ]; then
              COMPREPLY=( $(compgen -W "$shapes" -- "$cur") )
              return 0
            fi

            if [ "$COMP_CWORD" -eq 1 ]; then
              COMPREPLY=( $(compgen -W "$commands -v --version -h --help $models" -- "$cur") )
            fi
          }

          complete -F _ninfer_completion ninfer
          BASH

                    cat << 'FISH' > $out/share/fish/vendor_completions.d/ninfer.fish
          complete -c ninfer -n "__fish_use_subcommand" -a switch -d "switch active model"
          complete -c ninfer -n "__fish_use_subcommand" -a list -d "show models"
          complete -c ninfer -n "__fish_use_subcommand" -a status -d "show models"
          complete -c ninfer -n "__fish_use_subcommand" -a active -d "show active model"
          complete -c ninfer -n "__fish_use_subcommand" -a current -d "show active model"
          complete -c ninfer -n "__fish_use_subcommand" -s v -l version -d "show version"
          complete -c ninfer -n "__fish_use_subcommand" -a "bonsai2-27b qwen3.8-27b qwen3.8-27b-turbo <nil> nil"
          complete -c ninfer -n "__fish_seen_subcommand_from switch" -a "bonsai2-27b qwen3.8-27b qwen3.8-27b-turbo <nil> nil"
          complete -c ninfer -n "__fish_seen_subcommand_from switch; and __fish_prev_arg_in switch; and test (count (commandline -opc)) -ge 3" -a "8x16384 7x32768 6x65536 4x131072 1x262144 5x262144 8x262144"
          FISH
                    runHook postInstall
        '';
      };
    in {
      specialisation.homelab.configuration = {
        environment.systemPackages = [ninfer];
        # Passwordless unit state management for ninfer switch CLI.
        # Without this, systemctl stop/start blocks on interactive polkit auth (25s hang).
        # Grants active local sessions or wheel users permission to manage ninfer-* and bonsai2 units.
        security.polkit.extraConfig = ''
          polkit.addRule(function(action, subject) {
            if (action.id === "org.freedesktop.systemd1.manage-units" &&
                (subject.isInGroup("wheel") || (subject.local && subject.active))) {
              var unit = action.lookup("unit");
              if (unit && (unit.indexOf("ninfer-") === 0 || unit === "bonsai2.service")) {
                return polkit.Result.YES;
              }
            }
          });
        '';

        # Qwen3.8-27B DFlash2 daemon (port 8092), on-demand since
        # 2026-11-09 (turbo is the boot default; switch with
        # `ninfer qwen3.8-27b`).
        systemd.services.ninfer-df2 = {
          description = "ninfer 0.15.0 Qwen3.8-27B DFlash2";
          after = ["network-online.target"];
          wants = ["network-online.target"];
          conflicts = [
            "bonsai2.service"
            "ninfer-df2-turbo.service"
          ];

          # run.sh resolves bash via `#!/usr/bin/env bash`. The NixOS
          # unit-level `path` option did NOT survive the den-module
          # merge (built unit xsfi7qpjdx921 carries only the default
          # PATH: coreutils/findutils/gnugrep/gnused/systemd, no bash;
          # journal 2026-10-10 09:45 status=127 "env: 'bash'"). Raw
          # systemd `Environment=` from serviceConfig provably renders
          # into the unit (LD_LIBRARY_PATH line) and, emitted after the
          # default PATH line, wins by systemd's last-set-wins rule.
          serviceConfig = {
            Type = "simple";
            User = "ayin"; # artifact tree is ayin-owned; run.sh probes $HOME trees
            WorkingDirectory = ninferRoot;
            # Boot gate: 60 s GPU wait (thunderbolt eGPU enumerates after
            # multi-user.target), then artifact hash verify. Exit 1 = clean
            # skip (undocked / unplugged GPU), no restart storm.
            ExecCondition = pkgs.writeShellScript "ninfer-boot-gate" ''
              i=0
              until [ -e /dev/nvidia-uvm ] && [ -e /dev/nvidia1 ]; do
                i=$((i+1)); [ $i -gt 60 ] && exit 1
                sleep 1
              done
              # Artifact gate (vendor download-model.sh pins, verified
              # 2026-10-09: sha256 7f2a0086..., 18982458624 bytes).
              echo "7f2a0086a071ee932c66106e1552d118a85cfec8ddef13c67a54cd64abb39706  ${ninferRoot}/models/qwen3_8_27b.ninfer" \
                | ${pkgs.coreutils}/bin/sha256sum -c -
            '';

            # Vendor run.sh: tuned profile (dflash2 K=7, 262144 ctx, rk4v4
            # KV, vision overlay). NINFER_FALLBACK=off keeps the context
            # honest (omp overclaim = trim-loop; a stepped-down context
            # would silently diverge from the declared provider window).
            # NINFER_HOST_STATE_SLOTS=6 + hostkv-shim (2 GiB) = the exact
            # benchmarked shape (2026-10-12: C6x65k = 769.4 agg tok/s,
            # 128.2 per-lane); NINFER_SPEC=dflash2 pins the winner lane.
            Environment = let
              ld = lib.concatStringsSep ":" (ninferLibs ++ ["/run/opengl-driver/lib"]);
            in [
              "PATH=${lib.makeBinPath [pkgs.bash pkgs.coreutils]}"
              "CUDA_VISIBLE_DEVICES=GPU-a4e36250-873d-62c5-912e-fde18d238a6c"
              "LD_LIBRARY_PATH=${ld}"
              "NINFER_SPEC=dflash2"
              # Listen on 0.0.0.0 so tailscale0 peers (Dell) can connect;
              # tailscale0-only firewall rule below keeps non-tailnet traffic blocked.
              "NINFER_HOST=0.0.0.0"
              "NINFER_PORT=${toString ninferPort}"
              "NINFER_FALLBACK=off"
              "NINFER_CONCURRENCY=6"
              "NINFER_CONTEXT=65536"
              "NINFER_KV_CAPACITY=65536"
              "NINFER_HOST_STATE_SLOTS=6"
              "NINFER_SERVER=${ninferRoot}/ninfer-serve.hostkv-shim"
              "NINFER_MODEL_ID=qwen3.8-27b"
            ];
            # Optional per-shape override written by `ninfer switch -c <ctx>`
            # (NINFER_CONCURRENCY/CONTEXT/KV_CAPACITY/HOST_STATE_SLOTS).
            # EnvironmentFile values override the Environment= defaults; the
            # '-' prefix makes a missing file (= default shape) a no-op.
            # Read by the system manager, so unit sandboxing is irrelevant.
            EnvironmentFile = "-/run/user/1000/ninfer/shape-ninfer-df2.env";
            ExecStart = "${ninferRoot}/run.sh qwen38-27b tuned";

            # Second belt after the 2 GiB hostkv clamp: throttle at 10G,
            # hard wall 12G (ninfer.nix oomd history: Psi spikes killed
            # engines 4x on 2026-10-03).
            MemoryHigh = "10G";
            MemoryMax = "12G";
            Restart = "on-failure";
            RestartSec = "10s";
            ProtectHome = true;
            # still pins the rest of the FS.
            ProtectSystem = "strict";
            NoNewPrivileges = true;
            PrivateTmp = true;
          };
        };

        # Qwen3.8-27B Turbo daemon (port 8092), starts by default at boot
        # on the homelab spec (2026-11-09 user request: turbo is the new
        # default model; DFlash2 moved to on-demand).
        systemd.services.ninfer-df2-turbo = {
          description = "ninfer 0.15.0 Qwen3.8-27B MTP3 Turbo (Heretic Uncensored)";
          after = ["network-online.target"];
          wants = ["network-online.target"];
          wantedBy = ["multi-user.target"];
          conflicts = [
            "bonsai2.service"
            "ninfer-df2.service"
          ];
          serviceConfig = {
            Type = "simple";
            User = "ayin";
            WorkingDirectory = ninferRoot;
            ExecCondition = pkgs.writeShellScript "ninfer-df2-turbo-boot-gate" ''
              i=0
              until [ -e /dev/nvidia-uvm ] && [ -e /dev/nvidia1 ]; do
                i=$((i+1)); [ $i -gt 60 ] && exit 1
                sleep 1
              done
              echo "794fbbac426e16eb027bb5e683de190346bbd7a38318172553c5e993f7a5a3ce  ${ninferRoot}/models/qwen38_turbo_sm86.ninfer" \
                | ${pkgs.coreutils}/bin/sha256sum -c -
            '';
            Environment = let
              ld = lib.concatStringsSep ":" (ninferLibs ++ ["/run/opengl-driver/lib"]);
            in [
              "PATH=${lib.makeBinPath [pkgs.bash pkgs.coreutils]}"
              "CUDA_VISIBLE_DEVICES=GPU-a4e36250-873d-62c5-912e-fde18d238a6c"
              "LD_LIBRARY_PATH=${ld}"
              "NINFER_SPEC=mtp"
              "NINFER_DRAFT_TOKENS=3"
              "NINFER_HOST=0.0.0.0"
              "NINFER_PORT=${toString ninferPort}"
              "NINFER_FALLBACK=off"
              "NINFER_MODEL_ID=qwen3.8-27b-turbo"
              "NINFER_CONCURRENCY=6"
              "NINFER_CONTEXT=65536"
              "NINFER_KV_CAPACITY=65536"
              "NINFER_HOST_STATE_SLOTS=6"
              "NINFER_SERVER=${ninferRoot}/ninfer-serve.hostkv-shim"
            ];
            # Same per-shape override contract as ninfer-df2 above.
            EnvironmentFile = "-/run/user/1000/ninfer/shape-ninfer-df2-turbo.env";
            ExecStart = pkgs.writeShellScript "ninfer-df2-turbo-start" ''
              export NINFER_MODEL="${ninferRoot}/models/qwen38_turbo_sm86.ninfer"
              exec ${ninferRoot}/run.sh qwen38-27b tuned
            '';
            MemoryHigh = "10G";
            MemoryMax = "12G";
            Restart = "on-failure";
            RestartSec = "10s";
            ProtectHome = true;
            ProtectSystem = "strict";
            NoNewPrivileges = true;
            PrivateTmp = true;
          };
        };

        # Ternary Bonsai 2 27B (port 8092), on-demand: engine v0.17.2 +
        # 9.5 GB ternary artifact, switched to with `ninfer bonsai2-27b`.
        # MTP spec (the shape swept 2026-11-11: C8 holds at every
        # context, 9704-14166 MiB peaks); user-pruned SHAPES keeps only
        # the 8x262144 champion cell, so the CLI default here is C8 at
        # DEFAULT_CTX with the unit Environment below pinning C8x65536.
        systemd.services.bonsai2 = {
          description = "ninfer 0.17.2 Ternary Bonsai 2 27B MTP";
          after = ["network-online.target"];
          wants = ["network-online.target"];
          conflicts = [
            "ninfer-df2.service"
            "ninfer-df2-turbo.service"
          ];
          serviceConfig = {
            Type = "simple";
            User = "ayin";
            WorkingDirectory = ninferRootV0172;
            # Same GPU wait gate as the Qwen units (thunderbolt eGPU
            # enumerates late), then artifact hash verify (manifest
            # 975126774d7e1f9ffa36b654c0a6fc0db42c773ba4dd5f1196a9ddc6a46d4634).
            ExecCondition = pkgs.writeShellScript "bonsai2-boot-gate" ''
              i=0
              until [ -e /dev/nvidia-uvm ] && [ -e /dev/nvidia1 ]; do
                i=$((i+1)); [ $i -gt 60 ] && exit 1
                sleep 1
              done
              echo "975126774d7e1f9ffa36b654c0a6fc0db42c773ba4dd5f1196a9ddc6a46d4634  ${ninferRootV0172}/models/bonsai2_27b.ninfer" \
                | ${pkgs.coreutils}/bin/sha256sum -c -
            '';
            Environment = let
              # v0.17.2 ldd adds libzstd.so.1 vs v0.15.0 (same prism/
              # driver/ffmpeg/curl pins; zstd from the same nixpkgs rev).
              ld = lib.concatStringsSep ":" (ninferLibs
                ++ [
                  "/run/opengl-driver/lib"
                  "/nix/store/2a69456iqj6rzzc2ys7l2yypsv1w6l5m-zstd-1.5.7/lib"
                ]);
            in [
              "PATH=${lib.makeBinPath [pkgs.bash pkgs.coreutils]}"
              "CUDA_VISIBLE_DEVICES=GPU-a4e36250-873d-62c5-912e-fde18d238a6c"
              "LD_LIBRARY_PATH=${ld}"
              "NINFER_SPEC=mtp"
              "NINFER_DRAFT_TOKENS=3"
              "NINFER_HOST=0.0.0.0"
              "NINFER_PORT=${toString ninferPort}"
              "NINFER_FALLBACK=off"
              "NINFER_CONCURRENCY=8"
              "NINFER_CONTEXT=65536"
              "NINFER_KV_CAPACITY=65536"
              "NINFER_HOST_STATE_SLOTS=8"
              "NINFER_SERVER=${ninferRootV0172}/ninfer-serve.hostkv-shim"
              # Belt over the shim's --host-context-mib 0 clamp: v0.17.2
              # defaults this to 8192 MiB pinned host RAM, the oomd
              # killer shape from 2026-10-08. 0 = everything on card.
              "NINFER_HOST_CONTEXT_MIB=0"
              "NINFER_MODEL_ID=bonsai2-27b"
            ];
            EnvironmentFile = "-/run/user/1000/ninfer/shape-bonsai2.env";
            ExecStart = pkgs.writeShellScript "bonsai2-start" ''
              # run.sh validates model keys against its bundled list
              # (qwen38-27b/qwen36-35b-a3b only) BEFORE honoring
              # NINFER_MODEL, so pass the qwen38-27b key and override
              # the artifact — the exact invocation the 2026-11-11
              # VRAM sweep verified for the ternary weights.
              export NINFER_MODEL="${ninferRootV0172}/models/bonsai2_27b.ninfer"
              exec ${ninferRootV0172}/run.sh qwen38-27b tuned
            '';
            # Measured worst case 14166 MiB device + engine RSS; the
            # 10G/12G host walls are the second belt after the shim.
            MemoryHigh = "10G";
            MemoryMax = "12G";
            Restart = "on-failure";
            RestartSec = "10s";
            ProtectHome = true;
            ProtectSystem = "strict";
            NoNewPrivileges = true;
            PrivateTmp = true;
          };
        };

        # Qwen3.8-27B-Coder390 unit REMOVED 2026-11-11: its artifact
        # (gguf_blocks_v1 K-quants) FATALs on engine 0.17.2 ("weight/
        # 000130: unknown tensor layout") — never engine-ready. Re-add
        # with a loadable artifact; see the CODER390 REJECTED comment
        # above and benchmarks/engines-2026-10/results/
        # sweep-coder390-2026-11-11.log for the full findings.

        # Tailscale firewall: open single ninfer port (:8092).
        networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
          ninferPort
        ];
      }; # specialisation.homelab.configuration
    };
  };
}
