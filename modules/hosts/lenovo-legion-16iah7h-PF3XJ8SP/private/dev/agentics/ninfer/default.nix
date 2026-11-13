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
# on v0.15.0 C6x65k; the v0.16.0 stage under ~/models was DELETED 2026-11-12
# (home-dir model-artifact ban, see skill ninfer-model-quant-and-deploy §0)
# — v0.16.0 was Pareto-dominated and never promoted.
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
# 2026-11-13 RE-SWEEP (v0.17.2, same method, +tps): confirms the
# ladder (peaks within ±20 MiB; bonsai2 C8x262k 14168) and adds
# per-agent decode tps to every SHAPES row + the `ninfer list` table.
# Ternary-Bonsai-2-27B-Heretic-Abliterated measured directly this time (no sibling
# bound). `ninfer list` shows these as the {C}x{ctx}(tps) column;
# `ninfer switch
# --context <ctx>` writes a per-unit EnvironmentFile override
# (/var/lib/ninfer/shape-<unit>.env) consumed by all units; state
# persists across reboots (ninfer-restore.service re-starts the
# active model at boot).
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
      # 2026-11-11 CODER390: the ORIGINAL pin (nerkyor's GGUF-NInfer
      # Q3LynnStyle-Q8MTP, sha256 815241ba...) was rejected — its 263
      # K-quant tensors use layout "gguf_blocks_v1", which no ninfer
      # release implements (0.17.2: "weight/000130: unknown tensor
      # layout"). Same day, RE-CONVERTED from the official HF BF16
      # (see coder390Artifact + conversion-assessment.md); the new
      # artifact uses the dense recipe and loads natively. Failure
      # ladder + findings for the rejected artifact remain in
      # benchmarks/engines-2026-10/results/sweep-coder390-2026-11-11.log
      ninferBonsai2Model = pkgs.fetchurl {
        url = "https://huggingface.co/WarlaxZ/Ternary-Bonsai-2-27B-NInfer-3090/resolve/main/bonsai2_27b.ninfer";
        hash = "sha256-l1Emd01+H5/6NrZUwKb8DbQsdzuk3V8RlqndxqRtRjQ=";
        curlOptsList = ["--http1.1"];
      };

      # Ternary Bonsai 2 27B Heretic (abliterated): same 9.52 GB v3
      # container, recipe bonsai2_27b_ternary (provenance in the
      # manifest: converter ninfer-v3; Heretic LoRA baked into the
      # ternary codes from Ternary-Bonsai-2-27B-Uncensored-Heretic,
      # 34/851 matrices touched). Manifest audited 2026-11-11: zero
      # gguf_blocks_v1 tensors; format/layout set matches the
      # known-good bonsai2 artifact (t2_g128_fp16 etc., layouts
      # contiguous_le_v1/row_split_k128_v1) whose strings exist in the
      # 0.17.2 binary — 0.15.0 lacks t2_g128_fp16 and will refuse it.
      # Hash = HF LFS oid, agreeing with the repo's SHA256SUMS.
      # Serving: same shapes as Ternary-Bonsai-2-27B (kv rk4v4, NOT the
      # README's 5090-only rk4v4-e8); C8x262144 measured 14.2 GiB
      # peak for the sibling artifact.
      ninferBonsai2HereticModel = pkgs.fetchurl {
        url = "https://huggingface.co/emiltsoi/Ternary-Bonsai-2-27B-Uncensored-Heretic-NInfer/resolve/main/Ternary-Bonsai-2-27B-Heretic-ninfer.ninfer";
        hash = "sha256-mflPRL7UiJK3xeHE3INJ4NuLS0TSvYrXzUOM/Bgd4v0=";
        curlOptsList = ["--http1.1"];
      };

      # 2026-11-11 QWEN3.8-27B-ABLITERATED: locally converted from
      # huihui-ai/Huihui-Qwen3.8-27B-abliterated (bf16, 18 shards) with
      # the ashalliants/ninfer-3090 tools/convert recipe qwen3_8_27b
      # (components text,vision,mtp + proposal; imatrix from WarlaxZ's
      # published qwen3_8_27b.imatrix.safetensors). Same pipeline as the
      # 2026-10-10 campaign's huihui_abl artifact. No public .ninfer
      # exists for this repo, and the 16.76 GB file CANNOT be store-
      # ingested by `nix store add-file` (in-RAM hashing; OOM-killed on
      # this 15 GiB box, 2026-11-11 and 2026-11-12 — see skill
      # ninfer-model-quant-and-deploy §0). Cutover 2026-11-12: ingested
      # via STREAMING fetchurl file:// (curl, 88 MiB memory peak) as a
      # systemd transient unit; the unit pins the verified store path.
      # Artifact has NO dflash2 component -> NINFER_SPEC=mtp (turbo-unit
      # shape), not dflash2 (dense lane).
      huihuiAblArtifact = "/nix/store/bl01zwxxdscz232ihpbcqgsxn0rzsknh-huihui_abl_qwen3_8_27b.ninfer";

      # Qwen3.8-27B-Coder390-EfficientThink (2026-11-11 re-conversion):
      # nerkyor HF BF16 -> tools/convert recipe qwen3_8_27b, components
      # text,vision,mtp,dflash2, imatrix from the abliterated coder390
      # sibling (documented substitution — conversion-assessment.md,
      # archived at benchmarks/engines-2026-10/ninfer-conversion/).
      # Same streaming-store cutover as huihuiAblArtifact (18G file,
      # add-file OOMs this box; fetchurl file:// streams at ~88 MiB).
      coder390Artifact = "/nix/store/69d233pijmrzpyhzajqryc42cyfv3y2f-coder390_qwen3_8_27b.ninfer";

      ninferRootV0172 = pkgs.runCommand "ninfer-rtx3090-0.17.2" {} ''
        mkdir -p $out/models
        cp -r ${ninferReleaseV0172}/* $out/
        chmod -R u+w $out
        mv $out/ninfer-serve $out/ninfer-serve.real
        cp ${ninferServeHostkvShimV0172} $out/ninfer-serve.hostkv-shim
        ln -s ninfer-serve.hostkv-shim $out/ninfer-serve
        chmod +x $out/ninfer-serve.hostkv-shim
        ln -s ${ninferBonsai2Model} $out/models/bonsai2_27b.ninfer
        ln -s ${ninferBonsai2HereticModel} $out/models/bonsai2_27b_heretic.ninfer
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
        # huihui_abl artifact NOT in the store: 16.76 GB local file,
        # referenced by path (see huihuiAblArtifact above).
      '';
      # The non-bundled ldd deps of the engine binaries (skill:
      # ninfer-ash-hostkv-clamp). prism-llamacpp-libs covers
      # cublas/cudart, the driver package covers libcuda (via
      # /run/opengl-driver below), ffmpeg-full covers av*/swscale, curl
      # covers libcurl.so.4. Store paths re-pinned 2026-11-12 after a
      # nix GC orphaned the 2026-10 pins (fresh unit starts died on
      # libcublas.so.12); the new paths carry indirect GC roots in
      # ~/.local/share/nix-gcroots/ninfer-* so they survive GCs until
      # the next flake rebuild repins them. curl MUST be a build
      # linked against glibc <= the engine root's (2.42-103): 8.22.0
      # from the 2.44-era nixpkgs needs GLIBC_2.43 and kills the
      # engine at dlopen (glibc-2.42: version `GLIBC_2.43' not found;
      # unit crash-loop, broke the 2026-11-12 switch). 8.7.1 tops out
      # at GLIBC_2.34 — safe. The engine only needs libcurl.so.4.
      ninferLibs = [
        "/run/opengl-driver/lib"
        "/nix/store/md1vdf5hlk9y2yzdjq27ggq573g7q74z-prism-llamacpp-libs/lib"
        "/nix/store/sfn3qmgia0s6c3hylxk1ld01byydy7b4-nvidia-x11-595.112.07/lib"
        "/nix/store/jvqpbsb5cfh14ybq6znbqzhzdcv1g2nr-ffmpeg-full-6.1.1-lib/lib"
        "/nix/store/36kr91f8s509z2r8hqvpayw5bqyqgyzr-curl-8.7.1/lib"
      ];

      # Port the ninfer-serve listens on. Single source of truth for
      # this host; remote hosts (dell) duplicate the value with a sync
      # comment in their models.yml.
      ninferPort = 8092;
      # Per-model measured shape table (conc x ctx), 2026-11-11/12 sweeps
      # — SINGLE SOURCE OF TRUTH: rendered into the CLI's SHAPES array
      # AND $out/share/ninfer/shapes.conf, which the shell completions
      # read so `ninfer switch <model> <TAB>` offers only the shapes
      # valid for THAT model (no dual maintenance). Keep in sync with
      # do_switch's validation (shape_for_ctx) — both consume this list.
      # Format: "model-id|C1xCTX1k(tps),C2xCTX2k(tps),..." — ctx in
      # k-notation (k = floor(ctx/1000): 65536 -> 65k, 262144 -> 262k);
      # parens omitted when tps is 0. These tokens feed shell
      # completions; user input resolves k against this same table
      # (accepts raw and k forms).
      ninferShapeTable = [
        "Qwen3.8-27B|8x16k(155),7x32k(142),6x65k(128),4x131k(113),1x262k(97)"
        "Qwen3.8-27B-TURBO-Fable-Cold-Fusion-735-882-Heretic-Uncensored-NEO-CODER-MAX-MTP|8x16k(116),8x32k(107),8x65k(100),8x131k(93),5x262k(70)"
        "Ternary-Bonsai-2-27B|8x16k(218),8x32k(169),8x65k(138),8x131k(116),8x262k(77)"
        "Ternary-Bonsai-2-27B-Heretic-Abliterated|8x16k(195),8x32k(161),8x65k(136),8x131k(106),8x262k(78)"
        "Qwen3.8-27B-Huihui-Abliterated|8x16k,8x32k,8x65k,8x131k,5x262k"
        "Qwen3.8-27B-Coder390-EfficientThink-Opus5.5-GPT6Astra-Grok4.7-DSV4Pro-K3-SFT-RLOO-MTP-DFlash2|6x16k,5x32k,4x65k,3x131k"
      ];
      # `ninfer --version` strings. CLI release line + the two engine
      # distributions packaged below (v0.15.0 Qwen arm, v0.17.2
      # bonsai2 arm) — bump all three together.
      ninferCliVersion = "1.2.0";
      engineVersionV0150 = "0.15.0-rtx3090";
      engineVersionV0172 = "0.17.2-rtx3090";
      # 2026-10-18: Native shell CLI. Fast (<5ms), minimal UI,
      # canonical IDs only (no aliases), <nil> unloader, and full shell completions.
      # 2026-10-31: Renamed ashalliant CLI to ninfer (clean cutover).
      # 2026-11-06: Replaced Qwen3.8-27B-Huihui-Abliterated with Qwen3.8-27B-TURBO-Fable-Cold-Fusion-735-882-Heretic-Uncensored-NEO-CODER-MAX-MTP.
      # 2026-11-07: Removed qwen3.6 models; enhanced switch with responsive progress bar and milestone logging.
      # 2026-11-11: TUI removed; tabular list (ID/NAME/CONCURRENCYxCONTEXT,
      # alphabetical, <nil> last, bold ACTIVE row); positional
      # `switch <model-id> [C]x<ctx>` grammar; bonsai2 id -> Ternary-Bonsai-2-27B
      # with only the 8x262144 champion shape; --version/-v.
      # 2026-11-12: per-model shape completions — `switch <model> <TAB>`
      # offers only THAT model's measured shapes, read from the shipped
      # share/ninfer/shapes.conf (ninferShapeTable = single source of
      # truth); zsh/bash/fish; verified functionally (bash live, zsh
      # extraction, fish 4.9.3).
      ninfer = pkgs.stdenv.mkDerivation {
        pname = "ninfer";
        version = "1.0.0";

        dontUnpack = true;

        installPhase = ''
                    runHook preInstall
                    mkdir -p $out/bin $out/share/zsh/site-functions $out/share/bash-completion/completions $out/share/fish/vendor_completions.d $out/share/ninfer

                    # Per-model shape table for the shell completions (single
                    # source of truth: ninferShapeTable above). One line per
                    # model: "model-id|C1xCTX1,C2xCTX2,...". The CLI's SHAPES
                    # array below carries ctx:conc:peak for validation; this
                    # file carries only the CxCTX tokens completions offer.
                    # Rendered at column 0: heredoc preserves the Nix source
                    # indentation, which would corrupt every row after the
                    # first (completions grep '^model|').
                    cat << 'SHAPESCONF' > $out/share/ninfer/shapes.conf
${lib.concatStringsSep "\n" ninferShapeTable}
SHAPESCONF

                    cat << 'SCRIPT' > $out/bin/ninfer
#!/usr/bin/env bash
set -euo pipefail

# Pass --no-ask-password to prevent hanging on polkit TTY prompts when non-interactive.
SYSTEMCTL=( "${pkgs.systemd}/bin/systemctl" --no-ask-password )

MODELS=(
  "Ternary-Bonsai-2-27B|Ternary-Bonsai-2-27B|bonsai2.service|${toString ninferPort}"
  "Ternary-Bonsai-2-27B-Heretic-Abliterated|Ternary-Bonsai-2-27B-Heretic-Abliterated|bonsai2-abliterated.service|${toString ninferPort}"
  "Qwen3.8-27B|Qwen3.8-27B|ninfer-df2.service|${toString ninferPort}"
  "Qwen3.8-27B-Huihui-Abliterated|Qwen3.8-27B-Huihui-Abliterated|ninfer-df2-abliterated.service|${toString ninferPort}"
  "Qwen3.8-27B-Coder390-EfficientThink-Opus5.5-GPT6Astra-Grok4.7-DSV4Pro-K3-SFT-RLOO-MTP-DFlash2|Qwen3.8-27B-Coder390-EfficientThink-Opus5.5-GPT6Astra-Grok4.7-DSV4Pro-K3-SFT-RLOO-MTP-DFlash2|ninfer-df2-coder390.service|${toString ninferPort}"
  "Qwen3.8-27B-TURBO-Fable-Cold-Fusion-735-882-Heretic-Uncensored-NEO-CODER-MAX-MTP|Qwen3.8-27B-TURBO-Fable-Cold-Fusion-735-882-Heretic-Uncensored-NEO-CODER-MAX-MTP|ninfer-df2-turbo.service|${toString ninferPort}"
)

# Measured max concurrency per context on the RTX 3090 (2026-11-11,
# engine v0.15.0, engine alone + ~150 MiB desktop, no host-RAM KV):
# each "C x ctx : peak-MiB" triple is a live nvidia-smi peak; the
# next concurrency up at the same context OOM'd at startup
# (dflash2 C8x32k wanted 6.41 GiB runtime vs 6.31 free). dflash2
# costs ~1.6 GiB more than turbo at the same shape (K=7 draft
# state), so its table is strictly worse except 16k.
# Format: model|ctx:conc:peak[:tps],ctx:conc:peak[:tps],... — tps is
# per-agent decode tok/s (0/absent until the orchestrator injects it).
# 2026-11-11 user request: each model pins ONE champion shape
# (the full per-model tables live in the sweep logs); bonsai2
# keeps only its max-context C8 cell.
SHAPES=(
  # 2026-11-13 sweep (engine v0.17.2): tps = per-agent decode tok/s, median
  # of 2 reps at the pinned max-C shape for each ctx. C8 held at every ctx
  # for the bonsai2 pair (weights 9.5G -> big KV headroom).
  "Qwen3.8-27B|16384:8:21162:155,32768:7:21154:142,65536:6:21472:128,131072:4:22010:113,262144:1:23374:97"
  "Qwen3.8-27B-TURBO-Fable-Cold-Fusion-735-882-Heretic-Uncensored-NEO-CODER-MAX-MTP|16384:8:19572:116,32768:8:19870:107,65536:8:20464:100,131072:8:21654:93,262144:5:23536:70"
  # bonsai2 on engine v0.17.2 (2026-11-13 sweep): C8 held at EVERY
  # context, including full 262k. Peak 14168 MiB = ~10 GiB
  # headroom below the 24.5 GiB card. Measured ladder + tps.
  "Ternary-Bonsai-2-27B|16384:8:9706:218,32768:8:10004:169,65536:8:10598:138,131072:8:11788:116,262144:8:14168:77"
  # Ternary-Bonsai-2-27B-Heretic-Abliterated: 2026-11-13 sweep measured ladder — same
  # 9.52 GB ternary container as Ternary-Bonsai-2-27B, C8 held at every ctx
  # (peaks identical to the sibling; tps ~1-11% lower).
  "Ternary-Bonsai-2-27B-Heretic-Abliterated|16384:8:9706:195,32768:8:10004:161,65536:8:10598:136,131072:8:11788:106,262144:8:14168:78"
  # Qwen3.8-27B-Huihui-Abliterated: huihui bf16 -> tools/convert
  # recipe qwen3_8_27b, mtp-only artifact (no dflash2). The
  # 2026-10-10 campaign measured the SAME conversion recipe
  # (huihui_abl, artifact since cleaned): same engine spec as
  # the turbo unit (mtp, no dflash2 draft), so the turbo
  # table is the correct bound (dflash2's table costs ~1.6
  # GiB more per shape). Unverified on this artifact — first
  # load must confirm before trusting C8 at 65k+.
  "Qwen3.8-27B-Huihui-Abliterated|16384:8:19562,32768:8:19860,65536:8:20454,131072:8:21644:0,262144:5:23526:0"
  # Qwen3.8-27B-Coder390-EfficientThink-Opus5.5-GPT6Astra-Grok4.7-DSV4Pro-K3-SFT-RLOO-MTP-DFlash2: nerkyor HF BF16 -> tools/convert
  # recipe qwen3_8_27b (text,vision,mtp,dflash2; imatrix from
  # the abliterated coder390 sibling — conversion-assessment.
  # md). Dense-family weights (17.2 GiB quantized) + 5-layer
  # dflash2 draft. MEASURED 2026-11-12 smoke ladder on engine
  # v0.17.2, FALLBACK=off (VRAM peaks in MiB; each max-C cell
  # boot-verified, boundary cells die on reservation):
  # 16k C6 ok / C7 7.39G res ✗; 32k C5 ok / C6 6.81G ✗;
  # 65k C4 ok / C5 7.53G ✗; 128k C3 ok (C2 21532 ok) /
  # C4 7.63G ✗; 262k none (C1 6.94G ✗ by 157 MiB).
  "Qwen3.8-27B-Coder390-EfficientThink-Opus5.5-GPT6Astra-Grok4.7-DSV4Pro-K3-SFT-RLOO-MTP-DFlash2|16384:6:20570,32768:5:20572,65536:4:20876,131072:3:21708:0"
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
# `switch <model>` means. Ternary-Bonsai-2-27B's user-pruned SHAPES
# keeps only its 262k champion cell, so its default IS that
# cell (the shape file is written on switch; the unit
# Environment C8x65536 only applies if the unit starts with
# no override). Used by do_switch and as the ACTIVE fallback
# when neither /props nor the shape file yields values.
default_shape_for() {
  case "$1" in
    Ternary-Bonsai-2-27B|Ternary-Bonsai-2-27B-Heretic-Abliterated) echo "8x262144" ;;
    # coder390: measured champion C4x65k (dense 17.2 GiB
    # weights; C6x65k would OOM — see SHAPES row).
    Qwen3.8-27B-Coder390-EfficientThink-Opus5.5-GPT6Astra-Grok4.7-DSV4Pro-K3-SFT-RLOO-MTP-DFlash2) echo "4x65536" ;;
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

# Dominance pruning (2026-11-12, fixed 2026-11-13): drop a cell only
# when its conc is STRICTLY below the max conc already kept to its
# right at a LARGER-or-equal context (it can't win on either axis).
# The old `> running_max` collapsed flat measured ladders (bonsai2
# C8 at every ctx) to just the rightmost cell — equal-conc cells at
# different ctx are never dominated.
prune_dominated_shapes() {
  local specs pair ctxv c peak tps
  specs="$1"
  local pairs=() ctxs=() concs=()
  for pair in ''${specs//,/ }; do
    IFS=':' read -r ctxv c peak tps <<< "$pair"
    pairs+=("$pair"); ctxs+=("$ctxv"); concs+=("$c")
  done
  local n=''${#pairs[@]} i running_max=0 out="" keep
  for ((i = n - 1; i >= 0; i--)); do
    keep=0
    if (( ''${concs[$i]} >= running_max )); then
      keep=1; running_max=''${concs[$i]}
    fi
    if (( keep )); then
      [ -n "$out" ] && out=",''$out"
      out="''${pairs[$i]}''$out"
    fi
  done
  echo "$out"
}

# 2026-11-12 display rework: render "Cx{ctx}k" with k = floor(ctx/1000)
# (user's examples: 65536 -> 65k, 131072 -> 131k, 262144 -> 262k) and
# append "(tps)" when the measured tps field is present and nonzero.
shapes_column() {
  local specs pair ctxv c peak tps
  specs="$(shapes_for "$1")" || { echo "-"; return 0; }
  specs="$(prune_dominated_shapes "$specs")"
  local first=1 out=""
  for pair in ''${specs//,/ }; do
    IFS=':' read -r ctxv c peak tps <<< "$pair"
    tps="''${tps:-0}"
    [ "$first" = 1 ] || out+=","
    out+="''${c}x$((ctxv / 1000))k"
    [ "$tps" != 0 ] && out+="($tps)"
    first=0
  done
  echo "$out"
}

# Output contract (2026-11-11 user request; 2026-11-12
# alignment rework per docker-ps reference): header line,
# one row per model (alphabetical, <nil> last), blank line,
# "ACTIVE:", then the active row in bold. Columns are
# width-padded like `docker ps` (bash-only, no column(1)):
# two passes — collect rows, measure max width per column,
# then print left-aligned cells separated by two spaces.
show_list() {
  local active_mid
  active_mid="$(get_active 2>/dev/null || true)"
  local ids=() names=() shapes=()
  local entry mid name
  for entry in "''${MODELS[@]}"; do
    IFS='|' read -r mid name svc port <<< "$entry"
    ids+=("$mid"); names+=("$name"); shapes+=("$(shapes_column "$mid")")
  done
  ids+=("<nil>"); names+=("-"); shapes+=("-")
  local w_id=2 w_name=4 i
  for i in "''${!ids[@]}"; do
    [ ''${#ids[$i]} -gt $w_id ] && w_id=''${#ids[$i]}
    [ ''${#names[$i]} -gt $w_name ] && w_name=''${#names[$i]}
  done
  # left-align each cell to its column width + 2-space gutter;
  # the LAST column is unpadded (docker ps doesn't trail-pad)
  local fmt="%-''${w_id}s  %-''${w_name}s  %s\n"
  printf "$fmt" "ID" "NAME" "CONCURRENCYxCONTEXT"
  for i in "''${!ids[@]}"; do
    printf "$fmt" "''${ids[$i]}" "''${names[$i]}" "''${shapes[$i]}"
  done
  echo
  echo "ACTIVE:"
  if [ -n "$active_mid" ]; then
    local active_shape
    active_shape="$(active_shape_line "$active_mid")"
    printf "\033[1m%-''${w_id}s  %-''${w_name}s  %s\033[0m\n" \
      "$active_mid" "$(name_for "$active_mid")" "$active_shape"
  else
    printf "\033[1m%-''${w_id}s  %-''${w_name}s  %s\033[0m\n" \
      "<nil>" "-" "-"
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
    shape_file="/var/lib/ninfer/shape-''$unit.env"
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
  # Consult persistent user state file first so multi-variant targets
  # accurately report the user-selected variant rather than always defaulting to the first match.
  # /var/lib/ninfer (2026-11-12): survives reboots — active-model +
  # shape overrides persist across machine shutdowns; the boot
  # ninfer-restore.service re-starts the persisted model.
  local state_file="/var/lib/ninfer/active-model"
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
      *coder390*) echo "Qwen3.8-27B-Coder390-EfficientThink-Opus5.5-GPT6Astra-Grok4.7-DSV4Pro-K3-SFT-RLOO-MTP-DFlash2"; return 0 ;;
      *turbo*) echo "Qwen3.8-27B-TURBO-Fable-Cold-Fusion-735-882-Heretic-Uncensored-NEO-CODER-MAX-MTP"; return 0 ;;
      *huihui_abl*) echo "Qwen3.8-27B-Huihui-Abliterated"; return 0 ;;
      *bonsai2_27b_heretic*) echo "Ternary-Bonsai-2-27B-Heretic-Abliterated"; return 0 ;;
      *bonsai2*) echo "Ternary-Bonsai-2-27B"; return 0 ;;
      *qwen3_8_27b*) echo "Qwen3.8-27B"; return 0 ;;
    esac
  fi

  return 1
}

do_switch() {
  local target="''$1"
  local want_shape="''${2:-}"
  # PERSISTENT STATE (2026-11-12): /var/lib/ninfer survives
  # reboots (XDG_RUNTIME_DIR is tmpfs — the old location lost
  # both the active model and its shape override at every
  # shutdown). Owned by user ayin via systemd-tmpfiles; the CLI
  # (user ayin) writes, the root unit manager reads
  # EnvironmentFile=-/var/lib/ninfer/shape-<unit>.env, and the
  # boot ninfer-restore.service re-starts the persisted model.
  local state_dir="/var/lib/ninfer"
  local state_file="''$state_dir/active-model"
  # Cleared on <nil> and on default-shape switches so a boot
  # restart uses the unit default shape.
  local shape_dir="/var/lib/ninfer"
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
    rm -f "''$(shape_env_for ninfer-df2)" "''$(shape_env_for ninfer-df2-turbo)" "''$(shape_env_for ninfer-df2-abliterated)" "''$(shape_env_for ninfer-df2-coder390)" "''$(shape_env_for bonsai2)" "''$(shape_env_for bonsai2-abliterated)" 2>/dev/null || true
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
    echo "       available: Ternary-Bonsai-2-27B, Ternary-Bonsai-2-27B-Heretic-Abliterated, Qwen3.8-27B, Qwen3.8-27B-Huihui-Abliterated, Qwen3.8-27B-Coder390-EfficientThink-Opus5.5-GPT6Astra-Grok4.7-DSV4Pro-K3-SFT-RLOO-MTP-DFlash2, Qwen3.8-27B-TURBO-Fable-Cold-Fusion-735-882-Heretic-Uncensored-NEO-CODER-MAX-MTP, <nil>" >&2
    exit 1
  fi

  local prev_active
  prev_active="''$(get_active 2>/dev/null || true)"
  mkdir -p "''$state_dir" "''$shape_dir" 2>/dev/null || true

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
    # 2026-11-12 display rework: accept pasted display tokens too —
    # strip a trailing "(tps)" suffix, then resolve a "k"/"K" context
    # against the model's measured table: k = floor(ctx/1000) (user's
    # examples 65536 -> 65k, 262144 -> 262k), so "4x65k" matches the
    # 65536 row. A bare N*1000 never equals a real ctx, so match by
    # the same floor rule instead of multiplying back.
    shape_ctx="''${shape_ctx%%(*}"
    if [[ "''$shape_ctx" =~ ^([0-9]+)[kK]$ ]]; then
      shape_ctx="''$(shapes_for "''$canonical" | awk -F'[,:]' -v k="''${BASH_REMATCH[1]}" '
        { for (i = 1; i < NF; i += 2) if (int($i / 1000) == k) { print $i; exit } }')"
      if [ -z "''$shape_ctx" ]; then
        echo "error: shape ''$want_shape is not a measured shape for ''$canonical" >&2
        echo "       measured: ''$(shapes_column "''$canonical")" >&2
        return 1
      fi
    fi
    if ! [[ "''$shape_conc" =~ ^[0-9]+$ ]] || ! [[ "''$shape_ctx" =~ ^[0-9]+$ ]]; then
      echo "error: shape ''$want_shape must look like <concurrency>x<context> (e.g. 8x262144 or 8x262k)" >&2
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
    # default is NOT the unit Environment= shape (Ternary-Bonsai-2-27B:
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

  # Persist the active-model pointer ONLY after shape validation
  # passed (2026-11-12): an invalid-shape switch must not corrupt
  # the persisted pointer that ninfer-restore.service relies on
  # across reboots. (Was written before validation — an invalid
  # `switch <model> <bad-shape>` silently repointed the boot
  # restore at a model the user never switched to.)
  echo "''$canonical" > "''$state_file" 2>/dev/null || true

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
    if ${pkgs.curl}/bin/curl -s -m 0.5 "http://127.0.0.1:''$target_port/v1/models" >/dev/null 2>&1; then
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
              'Ternary-Bonsai-2-27B'
              'Ternary-Bonsai-2-27B-Heretic-Abliterated'
              'Qwen3.8-27B'
              'Qwen3.8-27B-Huihui-Abliterated'
              'Qwen3.8-27B-Coder390-EfficientThink-Opus5.5-GPT6Astra-Grok4.7-DSV4Pro-K3-SFT-RLOO-MTP-DFlash2'
              'Qwen3.8-27B-TURBO-Fable-Cold-Fusion-735-882-Heretic-Uncensored-NEO-CODER-MAX-MTP'
              '\<nil\>'
              'nil'
            )

            # Per-model shapes: read the model's row from shapes.conf
            # (same store file the CLI ships; ninferShapeTable in
            # default.nix is the single source of truth). `ninfer switch
            # <model> <TAB>` offers ONLY the measured CxCTX shapes for
            # THAT model. Fallback: flat union of every model's shapes
            # when the row is missing (never offer an empty list).
            local -a model_shapes all_shapes
            local shapes_conf="$(_ninfer_shapes_conf)"
            local mid row
            mid="''${words[3]}"
            row="$(grep -m1 "^''${mid}|" "$shapes_conf" 2>/dev/null | cut -d'|' -f2)"
            if [ -n "$row" ]; then
              model_shapes=("''${(@s/,/)row}")
            else
              all_shapes=($(cut -d'|' -f2 "$shapes_conf" 2>/dev/null | tr ',' ' '))
              model_shapes=("''${all_shapes[@]}")
            fi

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
                      _describe -t shapes 'shape' model_shapes
                    fi
                    ;;
                esac
                ;;
            esac
          }

          # Locate the shipped shapes.conf (store path) for completion.
          _ninfer_shapes_conf() {
            local p
            for p in "$(dirname "''${commands[ninfer]}")/../share/ninfer/shapes.conf" \
                     "@out@/share/ninfer/shapes.conf"; do
              [ -f "$p" ] && { echo "$p"; return 0; }
            done
            return 1
          }

          _ninfer "$@"
          ZSH
          substituteInPlace $out/share/zsh/site-functions/_ninfer \
            --replace-fail '@out@' "$out"

                    cat << 'BASH' > $out/share/bash-completion/completions/ninfer
          # Per-model shapes for `ninfer switch <model> <TAB>`: read the
          # model's row from the shipped shapes.conf (ninferShapeTable in
          # default.nix = single source of truth), fall back to the flat
          # union when the row is missing. @NINFER_SHAPES_CONF@ is
          # substituted to the store path at build time.
          _ninfer_completion() {
            local cur prev shapes_conf mid row
            cur="''${COMP_WORDS[COMP_CWORD]}"
            prev="''${COMP_WORDS[COMP_CWORD-1]}"
            shapes_conf="@NINFER_SHAPES_CONF@"

            local models="Ternary-Bonsai-2-27B Ternary-Bonsai-2-27B-Heretic-Abliterated Qwen3.8-27B Qwen3.8-27B-Huihui-Abliterated Qwen3.8-27B-TURBO-Fable-Cold-Fusion-735-882-Heretic-Uncensored-NEO-CODER-MAX-MTP <nil> nil"
            local commands="switch list status active current version"

            if [ "$COMP_CWORD" -eq 2 ] && [ "''${COMP_WORDS[1]}" = "switch" ]; then
              COMPREPLY=( $(compgen -W "$models" -- "$cur") )
              return 0
            elif [ "$COMP_CWORD" -eq 3 ] && [ "''${COMP_WORDS[1]}" = "switch" ]; then
              mid="''${COMP_WORDS[2]}"
              row="$(grep -m1 "^''${mid}|" "$shapes_conf" 2>/dev/null | cut -d'|' -f2 | tr ',' ' ')"
              [ -z "$row" ] && row="$(cut -d'|' -f2 "$shapes_conf" 2>/dev/null | tr ',' ' ')"
              COMPREPLY=( $(compgen -W "$row" -- "$cur") )
              return 0
            fi

            if [ "$COMP_CWORD" -eq 1 ]; then
              COMPREPLY=( $(compgen -W "$commands -v --version -h --help $models" -- "$cur") )
            fi
          }

          complete -F _ninfer_completion ninfer
          BASH
          substituteInPlace $out/share/bash-completion/completions/ninfer \
            --replace-fail '@NINFER_SHAPES_CONF@' "$out/share/ninfer/shapes.conf"

                    cat << 'FISH' > $out/share/fish/vendor_completions.d/ninfer.fish
          # Per-model shapes for `ninfer switch <model> <TAB>`: the
          # @NINFER_SHAPES_CONF@ placeholder is substituted to the store
          # shapes.conf at build time (ninferShapeTable in default.nix =
          # single source of truth). Fish evaluates the command
          # substitution at completion time, greps the typed model's row,
          # and offers ONLY that model's measured CxCTX shapes; the
          # fallback term covers unknown models with the flat union.
          complete -c ninfer -n "__fish_use_subcommand" -a switch -d "switch active model"
          complete -c ninfer -n "__fish_use_subcommand" -a list -d "show models"
          complete -c ninfer -n "__fish_use_subcommand" -a status -d "show models"
          complete -c ninfer -n "__fish_use_subcommand" -a active -d "show active model"
          complete -c ninfer -n "__fish_use_subcommand" -a current -d "show active model"
          complete -c ninfer -n "__fish_use_subcommand" -s v -l version -d "show version"
          complete -c ninfer -n "__fish_use_subcommand" -a "Ternary-Bonsai-2-27B Ternary-Bonsai-2-27B-Heretic-Abliterated Qwen3.8-27B Qwen3.8-27B-Huihui-Abliterated Qwen3.8-27B-TURBO-Fable-Cold-Fusion-735-882-Heretic-Uncensored-NEO-CODER-MAX-MTP <nil> nil"
          complete -c ninfer -n "__fish_seen_subcommand_from switch" -a "Ternary-Bonsai-2-27B Ternary-Bonsai-2-27B-Heretic-Abliterated Qwen3.8-27B Qwen3.8-27B-Huihui-Abliterated Qwen3.8-27B-TURBO-Fable-Cold-Fusion-735-882-Heretic-Uncensored-NEO-CODER-MAX-MTP <nil> nil"
          complete -c ninfer -n "__fish_seen_subcommand_from switch; and __fish_prev_arg_in switch; and test (count (commandline -opc)) -ge 3" \
            -a "(begin; set -l mid (commandline -opc)[3]; set -l row (grep -m1 '^'\$mid'|' @NINFER_SHAPES_CONF@ 2>/dev/null | cut -d'|' -f2); if test -n \"\$row\"; string split ',' \$row; else; grep -v '^#' @NINFER_SHAPES_CONF@ 2>/dev/null | cut -d'|' -f2 | string split ','; end; end)"
          FISH
          substituteInPlace $out/share/fish/vendor_completions.d/ninfer.fish \
            --replace-fail '@NINFER_SHAPES_CONF@' "$out/share/ninfer/shapes.conf"
                    runHook postInstall
        '';
      };
    in {
      specialisation.homelab.configuration = {
        environment.systemPackages = [ninfer];

        # PERSISTENT STATE (2026-11-12): /var/lib/ninfer holds the
        # user-selected active model and per-unit shape overrides so
        # they survive shutdowns (XDG_RUNTIME_DIR is tmpfs and lost
        # them every boot). CLI (user ayin) writes; the root unit
        # manager reads EnvironmentFile from here; the boot
        # ninfer-restore.service consumes active-model.
        systemd.tmpfiles.rules = [
          "d /var/lib/ninfer 0755 ayin root - -"
        ];

        # Boot restore: re-start whatever model was active at shutdown.
        # turbo stays WantedBy=multi-user.target as the fresh-install /
        # no-state default; starting the persisted unit relies on the
        # symmetric Conflicts= network to stop it. The engine units'
        # ExecCondition GPU gate keeps this clean on undocked boots
        # (60 s wait, then exit 1 = clean skip).
        systemd.services.ninfer-restore = {
          description = "Restore the ninfer model active at last shutdown";
          after = ["multi-user.target" "network-online.target"];
          wants = ["network-online.target"];
          wantedBy = ["multi-user.target"];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = pkgs.writeShellScript "ninfer-restore" ''
              state=/var/lib/ninfer/active-model
              [ -r "$state" ] || exit 0
              mid="$(cat "$state" 2>/dev/null || true)"
              case "$mid" in
                ""|"<nil>"|nil) echo "ninfer-restore: no persisted model"; exit 0 ;;
              esac
              case "$mid" in
                Ternary-Bonsai-2-27B) svc=bonsai2.service ;;
                Ternary-Bonsai-2-27B-Heretic-Abliterated) svc=bonsai2-abliterated.service ;;
                Qwen3.8-27B-Huihui-Abliterated) svc=ninfer-df2-abliterated.service ;;
                Qwen3.8-27B-Coder390-EfficientThink-Opus5.5-GPT6Astra-Grok4.7-DSV4Pro-K3-SFT-RLOO-MTP-DFlash2) svc=ninfer-df2-coder390.service ;;
                Qwen3.8-27B-TURBO-Fable-Cold-Fusion-735-882-Heretic-Uncensored-NEO-CODER-MAX-MTP) svc=ninfer-df2-turbo.service ;;
                Qwen3.8-27B) svc=ninfer-df2.service ;;
                *) echo "ninfer-restore: unknown persisted model '$mid'"; exit 0 ;;
              esac
              if systemctl is-active --quiet "$svc"; then
                echo "ninfer-restore: $svc already active"
                exit 0
              fi
              echo "ninfer-restore: re-starting $svc (persisted active model)"
              # Conflicts= on the engine units stops the boot-default
              # turbo (or any other active model) first; --no-block +
              # no wait: the engine unit's own start-up (weight load,
              # HTTP readiness) proceeds asynchronously.
              systemctl start --no-block "$svc"
            '';
          };
        };

        # Passwordless unit state management for ninfer switch CLI.
        # Without this, systemctl stop/start blocks on interactive polkit auth (25s hang).
        # Grants active local sessions or wheel users permission to manage ninfer-* and bonsai2 units.
        security.polkit.extraConfig = ''
          polkit.addRule(function(action, subject) {
            if (action.id === "org.freedesktop.systemd1.manage-units" &&
                (subject.isInGroup("wheel") || (subject.local && subject.active))) {
              var unit = action.lookup("unit");
              if (unit && (unit.indexOf("ninfer-") === 0 || unit === "bonsai2.service" || unit === "bonsai2-abliterated.service")) {
                return polkit.Result.YES;
              }
            }
          });
        '';

        # Qwen3.8-27B DFlash2 daemon (port 8092), on-demand since
        # 2026-11-09 (turbo is the boot default; switch with
        # `ninfer Qwen3.8-27B`).
        systemd.services.ninfer-df2 = {
          description = "ninfer 0.15.0 Qwen3.8-27B DFlash2";
          after = ["network-online.target"];
          wants = ["network-online.target"];
          conflicts = [
            "bonsai2.service"
            "bonsai2-abliterated.service"
            "ninfer-df2-turbo.service"
            "ninfer-df2-abliterated.service"
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
              "NINFER_MODEL_ID=Qwen3.8-27B"
            ];
            # Optional per-shape override written by `ninfer switch -c <ctx>`
            # (NINFER_CONCURRENCY/CONTEXT/KV_CAPACITY/HOST_STATE_SLOTS).
            # EnvironmentFile values override the Environment= defaults; the
            # '-' prefix makes a missing file (= default shape) a no-op.
            # Read by the system manager, so unit sandboxing is irrelevant.
            EnvironmentFile = "-/var/lib/ninfer/shape-ninfer-df2.env";
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
            "bonsai2-abliterated.service"
            "ninfer-df2.service"
            "ninfer-df2-abliterated.service"
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
              "NINFER_MODEL_ID=Qwen3.8-27B-TURBO-Fable-Cold-Fusion-735-882-Heretic-Uncensored-NEO-CODER-MAX-MTP"
              "NINFER_CONCURRENCY=6"
              "NINFER_CONTEXT=65536"
              "NINFER_KV_CAPACITY=65536"
              "NINFER_HOST_STATE_SLOTS=6"
              "NINFER_SERVER=${ninferRoot}/ninfer-serve.hostkv-shim"
            ];
            # Same per-shape override contract as ninfer-df2 above.
            EnvironmentFile = "-/var/lib/ninfer/shape-ninfer-df2-turbo.env";
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

        # Qwen3.8-27B Abliterated (Huihui) daemon (port 8092), on-demand
        # (2026-11-11 user request: reinstate the dense abliterated model).
        # Locally converted artifact (see huihuiAblArtifact): mtp-only
        # (no dflash2 component), so NINFER_SPEC=mtp — the turbo unit's
        # engine spec, NOT the dense unit's dflash2 lane. Same shape
        # contract (C6x65k default; the 2026-10-10 campaign's huihui_abl
        # measured 20 cells on the same recipe).
        systemd.services.ninfer-df2-abliterated = {
          description = "ninfer 0.15.0 Qwen3.8-27B MTP3 (Huihui Abliterated)";
          after = ["network-online.target"];
          wants = ["network-online.target"];
          conflicts = [
            "bonsai2.service"
            "bonsai2-abliterated.service"
            "ninfer-df2.service"
            "ninfer-df2-turbo.service"
          ];
          serviceConfig = {
            Type = "simple";
            User = "ayin";
            WorkingDirectory = ninferRoot;
            ExecCondition = pkgs.writeShellScript "ninfer-df2-abliterated-boot-gate" ''
              i=0
              until [ -e /dev/nvidia-uvm ] && [ -e /dev/nvidia1 ]; do
                i=$((i+1)); [ $i -gt 60 ] && exit 1
                sleep 1
              done
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
              "NINFER_MODEL_ID=Qwen3.8-27B-Huihui-Abliterated"
              "NINFER_CONCURRENCY=6"
              "NINFER_CONTEXT=65536"
              "NINFER_KV_CAPACITY=65536"
              "NINFER_HOST_STATE_SLOTS=6"
              "NINFER_SERVER=${ninferRoot}/ninfer-serve.hostkv-shim"
            ];
            # Same per-shape override contract as ninfer-df2 above.
            EnvironmentFile = "-/var/lib/ninfer/shape-ninfer-df2-abliterated.env";
            ExecStart = pkgs.writeShellScript "ninfer-df2-abliterated-start" ''
              export NINFER_MODEL="${huihuiAblArtifact}"
              exec ${ninferRoot}/run.sh qwen38-27b tuned
            '';
            MemoryHigh = "10G";
            MemoryMax = "12G";
            Restart = "on-failure";
            RestartSec = "10s";
            # NO ProtectHome: the artifact lives at ~/models (see
            # huihuiAblArtifact) and the engine + boot gate must read it.
            ProtectSystem = "strict";
            NoNewPrivileges = true;
            PrivateTmp = true;
          };
        };

        # Qwen3.8-27B Coder390 (EfficientThink) daemon (port 8092),
        # on-demand (2026-11-11 user request: retry the rejected model
        # with a proper conversion). Locally converted artifact (see
        # coder390Artifact): full DFlash2 bundle (text,vision,mtp,
        # dflash2 — mirrors the official qwen3_8_27b.ninfer shape), so
        # NINFER_SPEC=dflash2 — the dense unit's winner lane. Same
        # shape contract (C6x65k default); SHAPES row is UNMEASURED
        # until sweep_coder390.py runs.
        systemd.services.ninfer-df2-coder390 = {
          description = "ninfer 0.15.0 Qwen3.8-27B Coder390 (EfficientThink)";
          after = ["network-online.target"];
          wants = ["network-online.target"];
          conflicts = [
            "bonsai2.service"
            "bonsai2-abliterated.service"
            "ninfer-df2.service"
            "ninfer-df2-abliterated.service"
            "ninfer-df2-turbo.service"
          ];
          serviceConfig = {
            Type = "simple";
            User = "ayin";
            WorkingDirectory = ninferRoot;
            ExecCondition = pkgs.writeShellScript "ninfer-df2-coder390-boot-gate" ''
              i=0
              until [ -e /dev/nvidia-uvm ] && [ -e /dev/nvidia1 ]; do
                i=$((i+1)); [ $i -gt 60 ] && exit 1
                sleep 1
              done
            '';
            Environment = let
              ld = lib.concatStringsSep ":" (ninferLibs ++ ["/run/opengl-driver/lib"]);
            in [
              "PATH=${lib.makeBinPath [pkgs.bash pkgs.coreutils]}"
              "CUDA_VISIBLE_DEVICES=GPU-a4e36250-873d-62c5-912e-fde18d238a6c"
              "LD_LIBRARY_PATH=${ld}"
              "NINFER_SPEC=dflash2"
              "NINFER_HOST=0.0.0.0"
              "NINFER_PORT=${toString ninferPort}"
              "NINFER_FALLBACK=off"
              "NINFER_MODEL_ID=Qwen3.8-27B-Coder390-EfficientThink-Opus5.5-GPT6Astra-Grok4.7-DSV4Pro-K3-SFT-RLOO-MTP-DFlash2"
              # Measured sweep (2026-11-12 smoke ladder, FALLBACK=off):
              # 16k→C6 (20570 MiB), 32k→C5 (20572), 65k→C4 (20876),
              # 128k→C3 (21708; C2 also fits 21532), 262k→none (C1
              # dies by 157 MiB). Dense 17.2 GiB weights leave ~6.78
              # GiB runtime; the dflash2 floor is ~6.6 GiB + ~75 MiB/lane
              # + ~21 MiB/kctx. Champion default = C4x65k (deepest ctx
              # at the highest C that holds it).
              "NINFER_CONCURRENCY=4"
              "NINFER_CONTEXT=65536"
              "NINFER_KV_CAPACITY=65536"
              "NINFER_HOST_STATE_SLOTS=4"
              "NINFER_SERVER=${ninferRoot}/ninfer-serve.hostkv-shim"
            ];
            # Same per-shape override contract as ninfer-df2 above.
            EnvironmentFile = "-/var/lib/ninfer/shape-ninfer-df2-coder390.env";
            ExecStart = pkgs.writeShellScript "ninfer-df2-coder390-start" ''
              export NINFER_MODEL="${coder390Artifact}"
              exec ${ninferRoot}/run.sh qwen38-27b tuned
            '';
            MemoryHigh = "10G";
            MemoryMax = "12G";
            Restart = "on-failure";
            RestartSec = "10s";
            # NO ProtectHome: the artifact lives at ~/models (see
            # coder390Artifact) and the engine + boot gate must read it.
            ProtectSystem = "strict";
            NoNewPrivileges = true;
            PrivateTmp = true;
          };
        };

        # Ternary Bonsai 2 27B (port 8092), on-demand: engine v0.17.2 +
        # 9.5 GB ternary artifact, switched to with `ninfer Ternary-Bonsai-2-27B`.
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
            "ninfer-df2-abliterated.service"
            "bonsai2-abliterated.service"
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
              "NINFER_MODEL_ID=Ternary-Bonsai-2-27B"
            ];
            EnvironmentFile = "-/var/lib/ninfer/shape-bonsai2.env";
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

        # Ternary Bonsai 2 27B Heretic, CLI id Ternary-Bonsai-2-27B-Heretic-Abliterated
        # (port 8092), on-demand. Same 0.17.2 engine + shape contract
        # as bonsai2 (MTP3, C8x65536 default, 8x262144 champion); the
        # only delta is the artifact (Heretic LoRA baked into the
        # ternary codes, recipe bonsai2_27b_ternary — see the model
        # pin comment). MUST stay on 0.17.2: 0.15.0 lacks
        # t2_g128_fp16 and refuses the container.
        systemd.services.bonsai2-abliterated = {
          description = "ninfer 0.17.2 Ternary Bonsai 2 27B Heretic MTP";
          after = ["network-online.target"];
          wants = ["network-online.target"];
          conflicts = [
            "ninfer-df2.service"
            "ninfer-df2-turbo.service"
            "ninfer-df2-abliterated.service"
            "bonsai2.service"
          ];
          serviceConfig = {
            Type = "simple";
            User = "ayin";
            WorkingDirectory = ninferRootV0172;
            # Same GPU wait gate, then artifact hash verify (HF LFS oid
            # = repo SHA256SUMS line, audited 2026-11-11).
            ExecCondition = pkgs.writeShellScript "bonsai2-abliterated-boot-gate" ''
              i=0
              until [ -e /dev/nvidia-uvm ] && [ -e /dev/nvidia1 ]; do
                i=$((i+1)); [ $i -gt 60 ] && exit 1
                sleep 1
              done
              echo "99f94f44bed48892b7c5e1c4dc8349e0db8b4b44d2bd8ad7cd438cfc181de2fd  ${ninferRootV0172}/models/bonsai2_27b_heretic.ninfer" \
                | ${pkgs.coreutils}/bin/sha256sum -c -
            '';
            Environment = let
              # Identical ldd set to bonsai2 on v0.17.2.
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
              # Belt over the shim's --host-context-mib 0 clamp (see
              # bonsai2 unit).
              "NINFER_HOST_CONTEXT_MIB=0"
              "NINFER_MODEL_ID=Ternary-Bonsai-2-27B-Heretic-Abliterated"
            ];
            EnvironmentFile = "-/var/lib/ninfer/shape-bonsai2-abliterated.env";
            ExecStart = pkgs.writeShellScript "bonsai2-abliterated-start" ''
              # run.sh validates model keys (qwen38-27b/qwen36-35b-a3b
              # only) BEFORE honoring NINFER_MODEL — pass the
              # qwen38-27b key and override the artifact (same
              # invocation as the bonsai2 unit).
              export NINFER_MODEL="${ninferRootV0172}/models/bonsai2_27b_heretic.ninfer"
              exec ${ninferRootV0172}/run.sh qwen38-27b tuned
            '';
            # Sibling artifact measured 14166 MiB device peak at
            # C8x262144; identical walls as bonsai2.
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
