# ninfer 0.15.0 (RTX 3090 release binary) — Qwen3.8-27B
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
# 2026-11-11 VRAM SHAPE SWEEP (live nvidia-smi peaks, engine alone +
# ~150 MiB desktop, v0.15.0, no host-RAM KV): max concurrency per
# context — dflash2: 8x16k 21150 MiB, 7x32k 21144 (C8 OOMs: 6.41 GiB
# runtime vs 6.31 free), 6x65k 21462 (C7 OOMs), 4x128k 22000 (C5
# OOMs), 1x262k 23364 (C2 OOMs). turbo/mtp3: 8x16k 19562, 8x32k 19860,
# 8x65k 20454, 8x128k 21644, 5x262k 23526 (C6 OOMs). mtp3 draft state
# is ~1.6 GiB cheaper than dflash2's K=7, so turbo holds C8 to 128k.
# `ninfer list` shows these as the {C}x{ctx} column; `ninfer switch
# --context <ctx>` writes a per-unit EnvironmentFile override
# (/run/user/1000/ninfer/shape-<unit>.env) consumed by both units;
# `ninfer -i` opens the Bubble Tea TUI (ninfer-tools/ninfer-tui).
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
# 21.9 GiB. Both daemons declare symmetric Conflicts — starting any
# stops the other natively.
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
      # Bubble Tea TUI for `ninfer -i`. Source lives in ninfer-tools/ninfer-tui;
      # buildGoModule vendors deps via go.sum (proxy off-line build).
      ninferTui = pkgs.buildGoModule {
        pname = "ninfer-tui";
        version = "1.0.0";
        src = ./ninfer-tools/ninfer-tui;
        env.CGO_ENABLED = 0;
        vendorHash = null;
        meta.mainProgram = "ninfer-tui";
      };
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
      # header identity is pinned (see ninfer-tools/upgrade script) so
      # this build is deterministic and byte-identical to the locally
      # verified artifact (sha256 794fbbac...).
      ninferTurboModel =
        pkgs.runCommand "qwen38_turbo_sm86-v3.ninfer" {
          nativeBuildInputs = [pkgs.python3];
        } ''
          cp -r ${./ninfer-tools} ./ninfer-tools
          python3 ./ninfer-tools/upgrade_ninfer_v2_to_v3.py \
            ${ninferTurboModelV2} $out
        '';

      ninferRoot = pkgs.runCommand "ninfer-rtx3090-0.15.0" {} ''
        mkdir -p $out/models
        cp -r ${ninferRelease}/* $out/
        chmod -R u+w $out
        mv $out/ninfer-serve $out/ninfer-serve.real
        cp ${ninferServeHostkvShim} $out/ninfer-serve.hostkv-shim
        ln -s ninfer-serve.hostkv-shim $out/ninfer-serve
        chmod +x $out/ninfer-serve.hostkv-shim
        cp -r ${./ninfer-tools} $out/tools
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
      # 2026-10-18: Native shell CLI. Fast (<5ms), minimal UI,
      # canonical IDs only (no aliases), <nil> unloader, and full shell completions.
      # 2026-10-31: Renamed ashalliant CLI to ninfer (clean cutover).
      # 2026-11-06: Replaced qwen3.8-27b-abliterated with qwen3.8-27b-turbo.
      # 2026-11-07: Removed qwen3.6 models; enhanced switch with responsive progress bar and milestone logging.
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
            "qwen3.8-27b|ninfer-df2.service|${toString ninferPort}"
            "qwen3.8-27b-turbo|ninfer-df2-turbo.service|${toString ninferPort}"
          )

          # Measured max concurrency per context on the RTX 3090 (2026-11-11,
          # engine v0.15.0, engine alone + ~150 MiB desktop, no host-RAM KV):
          # each "C x ctx : peak-MiB" triple is a live nvidia-smi peak; the
          # next concurrency up at the same context OOM'd at startup
          # (dflash2 C8x32k wanted 6.41 GiB runtime vs 6.31 free). dflash2
          # costs ~1.6 GiB more than turbo at the same shape (K=7 draft
          # state), so its table is strictly worse except 16k.
          # Format: model|ctx:conc:peak,ctx:conc:peak,...
          SHAPES=(
            "qwen3.8-27b|16384:8:21150,32768:7:21144,65536:6:21462,131072:4:22000,262144:1:23364"
            "qwen3.8-27b-turbo|16384:8:19562,32768:8:19860,65536:8:20454,131072:8:21644,262144:5:23526"
          )
          # Unit default shape (what Environment= in the unit pins); a
          # --context equal to this clears the override file instead of
          # writing one.
          DEFAULT_CTX=65536
          DEFAULT_CONC=6

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
            out="{ "
            local first=1
            for pair in ''${specs//,/ }; do
              IFS=':' read -r ctxv c peak <<< "$pair"
              [ "$first" = 1 ] || out+=", "
              out+="''${c}x$ctxv"
              first=0
            done
            echo "$out }"
          }

          show_list() {
            local active_mid
            active_mid="$(get_active 2>/dev/null || true)"
            local any_active=0
            local shapes shapes_disp state
            for entry in "''${MODELS[@]}"; do
              IFS='|' read -r mid svc port <<< "$entry"
              state="inactive"
              if [ "$mid" = "$active_mid" ]; then
                state="active"
                any_active=1
              elif [ -z "$active_mid" ] && "''${SYSTEMCTL[@]}" is-active --quiet "$svc" 2>/dev/null; then
                state="active"
                any_active=1
              fi
              shapes="$(shapes_column "$mid")"
              printf "%-30s %-8s %-10s :%s\n" "$mid" "''${shapes:--}" "$state" "$port"
            done
            local nil_state="inactive"
            if [ "$any_active" -eq 0 ]; then
              nil_state="active"
            fi
            printf "%-30s %-8s %-10s -\n" "<nil>" "-" "$nil_state"
          }

          get_active() {
            # Consult persistent user runtime state file first so multi-variant targets
            # accurately report the user-selected variant rather than always defaulting to the first match.
            local state_file="''${XDG_RUNTIME_DIR:-/tmp}/ninfer/active-model"
            if [ -r "$state_file" ]; then
              local saved_mid
              saved_mid="$(cat "$state_file" 2>/dev/null || true)"
              if [ -n "$saved_mid" ]; then
                for entry in "''${MODELS[@]}"; do
                  IFS='|' read -r mid svc port <<< "$entry"
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

            for entry in "''${MODELS[@]}"; do
              IFS='|' read -r mid svc port <<< "$entry"
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
                *qwen3_8_27b*) echo "qwen3.8-27b"; return 0 ;;
              esac
            fi

            return 1
          }

          do_switch() {
            local target="''$1"
            local want_ctx="''${2:-}"
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
              for entry in "''${MODELS[@]}"; do
                IFS='|' read -r mid svc port <<< "''$entry"
                if "''${SYSTEMCTL[@]}" is-active --quiet "''$svc" 2>/dev/null; then
                  printf "Stopping %s (%s)... " "''$mid" "''$svc"
                  "''${SYSTEMCTL[@]}" stop "''$svc" 2>/dev/null || true
                  echo "done."
                  stopping=1
                fi
              done
              rm -f "''$state_file" 2>/dev/null || true
              rm -f "''$(shape_env_for ninfer-df2)" "''$(shape_env_for ninfer-df2-turbo)" 2>/dev/null || true
              echo "✔ Unloaded all models (switched to <nil>)"
              return 0
            fi

            local found_svc=""
            local canonical=""
            local target_port=""
            for entry in "''${MODELS[@]}"; do
              IFS='|' read -r mid svc port <<< "''$entry"
              if [ "''$mid" = "''$target" ]; then
                found_svc="''$svc"
                canonical="''$mid"
                target_port="''$port"
                break
              fi
            done

            if [ -z "''$found_svc" ]; then
              echo "error: unknown model ''$target" >&2
              echo "       available: qwen3.8-27b, qwen3.8-27b-turbo, <nil>" >&2
              exit 1
            fi

            local prev_active
            prev_active="''$(get_active 2>/dev/null || true)"
            mkdir -p "''$state_dir" "''$shape_dir" 2>/dev/null || true
            echo "''$canonical" > "''$state_file" 2>/dev/null || true

            # Shape selection: --context validated against the measured table.
            local target_shape="''${DEFAULT_CONC}x''${DEFAULT_CTX}"
            local shape_file
            shape_file="''$(shape_env_for ''${found_svc%.service})"
            if [ -n "''$want_ctx" ]; then
              local ctx_conc_val
              ctx_conc_val="''$(shape_for_ctx "''$canonical" "''$want_ctx" | cut -d' ' -f1)" || true
              if [ -z "''$ctx_conc_val" ]; then
                echo "error: context ''$want_ctx is not a measured shape for ''$canonical" >&2
                echo "       measured: ''$(shapes_column "''$canonical")" >&2
                return 1
              fi
              if [ "''$want_ctx" = "''$DEFAULT_CTX" ]; then
                rm -f "''$shape_file" 2>/dev/null || true
              else
                {
                  echo "NINFER_CONCURRENCY=''${ctx_conc_val}"
                  echo "NINFER_CONTEXT=''${want_ctx}"
                  echo "NINFER_KV_CAPACITY=''${want_ctx}"
                  echo "NINFER_HOST_STATE_SLOTS=''${ctx_conc_val}"
                } > "''$shape_file"
              fi
              target_shape="''${ctx_conc_val}x''$want_ctx"
            else
              # No --context: unit default shape; clear any stale override.
              rm -f "''$shape_file" 2>/dev/null || true
            fi

            # Fast path: already active and responding on HTTP. Only when NO
            # --context was given: the engine may currently run a non-default
            # shape (a prior `switch -c` left its EnvironmentFile), so a
            # context switch must always restart to apply the shape file.
            if [ -z "''$want_ctx" ]; then
              if "''${SYSTEMCTL[@]}" is-active --quiet "''$found_svc" 2>/dev/null; then
                if ${pkgs.curl}/bin/curl -s -m 0.5 "http://127.0.0.1:''$target_port/v1/models" >/dev/null 2>&1; then
                  echo "✔ Already active and responding on ''$canonical (:''$target_port)"
                  return 0
                fi
              fi
            fi

            # Stop any conflicting active services first
            for entry in "''${MODELS[@]}"; do
              IFS='|' read -r mid svc port <<< "$entry"
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
            switch|-s|--switch)
              if [ $# -lt 2 ]; then
                echo "error: model required" >&2
                exit 2
              fi
              sw_target="" sw_ctx=""
              shift
              while [ $# -gt 0 ]; do
                case "$1" in
                  --context|-c)
                    [ $# -ge 2 ] || { echo "error: --context needs a value" >&2; exit 2; }
                    sw_ctx="$2"; shift 2 ;;
                  --context=*)
                    sw_ctx="''${1#*=}"; shift ;;
                  *)
                    if [ -z "$sw_target" ]; then sw_target="$1"; else
                      echo "error: unexpected argument '$1'" >&2; exit 2
                    fi
                    shift ;;
                esac
              done
              [ -n "$sw_target" ] || { echo "error: model required" >&2; exit 2; }
              do_switch "$sw_target" "$sw_ctx"
              ;;
            -i|--interactive)
              exec ${ninferTui}/bin/ninfer-tui
              ;;
            -h|--help|help)
              echo "usage: ninfer [switch <model> [--context/-c <ctx>] | -s <model> [-c <ctx>] | -i | list | active]"
              echo "  -c <ctx>   context in tokens; measured shapes per model shown by 'ninfer list'"
              echo "  -i         interactive TUI (model + context picker)"
              ;;
            *)
              plain_ctx=""
              for entry in "''${MODELS[@]}"; do
                IFS='|' read -r mid svc port <<< "$entry"
                if [ "$mid" = "$cmd" ]; then
                  # Direct model invocation: ninfer <model> [-c ctx]
                  shift
                  while [ $# -gt 0 ]; do
                    case "$1" in
                      --context|-c) plain_ctx="$2"; shift 2 ;;
                      --context=*) plain_ctx="''${1#*=}"; shift ;;
                      *) echo "error: unexpected argument '$1'" >&2; exit 2 ;;
                    esac
                  done
                  do_switch "$cmd" "$plain_ctx"
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

                    # Shell completions supporting both subcommands (switch, list, status, active)
                    # and direct model invocation (e.g. `ninfer qwen3.8-27b`), fixing tab completion in zsh/bash/fish.
                    cat << 'ZSH' > $out/share/zsh/site-functions/_ninfer
          #compdef ninfer

          _ninfer() {
            local curcontext="$curcontext" state line
            typeset -A opt_args

            local -a commands models
            commands=(
              'switch:switch active model'
              'active:show active model'
              'current:show active model'
              'list:list models'
              'status:show status'
              '-i:interactive TUI'
              '--interactive:interactive TUI'
            )

            models=(
              'qwen3.8-27b:Qwen3.8-27B DFlash2 (8x16k 7x32k 6x65k 4x128k 1x262k :8092)'
              'qwen3.8-27b-turbo:Qwen3.8-27B Turbo Heretic (8x16k 8x32k 8x65k 8x128k 5x262k :8092)'
              '\<nil\>:Unload all ninfer models'
              'nil:Unload all ninfer models'
            )

            local -a contexts
            contexts=(
              '16384:16k context'
              '32768:32k context'
              '65536:64k context'
              '131072:128k context'
              '262144:262k context'
            )

            _arguments -C \
              '-s[switch active model]:model:->models' \
              '--switch[switch active model]:model:->models' \
              '-c[context tokens (per-model measured shapes)]:context:->ctxs' \
              '--context[context tokens (per-model measured shapes)]:context:->ctxs' \
              '(-i --interactive)'{-i,--interactive}'[interactive TUI]' \
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
              ctxs)
                _describe -t contexts 'context' contexts
                ;;
              args)
                case "''${words[2]}" in
                  switch|-s|--switch)
                    _describe -t models 'model' models
                    ;;
                esac
                ;;
              models)
                _describe -t models 'model' models
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

            local models="qwen3.8-27b qwen3.8-27b-turbo <nil> nil"
            local commands="switch list status active current -i --interactive"
            local contexts="16384 32768 65536 131072 262144"

            case "$prev" in
              switch|-s|--switch)
                COMPREPLY=( $(compgen -W "$models" -- "$cur") )
                return 0
                ;;
              -c|--context)
                COMPREPLY=( $(compgen -W "$contexts" -- "$cur") )
                return 0
                ;;
            esac

            if [ "$COMP_CWORD" -eq 1 ]; then
              COMPREPLY=( $(compgen -W "$commands -s --switch -c --context -h --help $models" -- "$cur") )
            elif [ "$COMP_CWORD" -eq 3 ]; then
              COMPREPLY=( $(compgen -W "-c --context" -- "$cur") )
            fi
          }

          complete -F _ninfer_completion ninfer
          BASH

                    cat << 'FISH' > $out/share/fish/vendor_completions.d/ninfer.fish
          complete -c ninfer -n "__fish_use_subcommand" -a switch -d "switch active model"
          complete -c ninfer -n "__fish_use_subcommand" -a list -d "list models"
          complete -c ninfer -n "__fish_use_subcommand" -a status -d "show status"
          complete -c ninfer -n "__fish_use_subcommand" -a active -d "show active model"
          complete -c ninfer -n "__fish_use_subcommand" -a current -d "show active model"
          complete -c ninfer -n "__fish_use_subcommand" -s i -l interactive -d "interactive TUI"
          complete -c ninfer -n "__fish_use_subcommand" -a "qwen3.8-27b qwen3.8-27b-turbo <nil> nil"
          complete -c ninfer -n "__fish_seen_subcommand_from switch; or __fish_contains_opt -s s switch" -a "qwen3.8-27b qwen3.8-27b-turbo <nil> nil"
          complete -c ninfer -s c -l context -d "context tokens (per-model measured shapes)" -a "16384 32768 65536 131072 262144"
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

        # Tailscale firewall: open single ninfer port (:8092).
        networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
          ninferPort
        ];
      }; # specialisation.homelab.configuration
    };
  };
}
