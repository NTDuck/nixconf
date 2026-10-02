# q27 — MAIN 3090 inference engine (2026-10-03, replaces ninfer; user
# decision from the 2026-10-02 benchmark: q27 serves Ternary Bonsai 2 27B at
# 95-98 t/s short decode vs the ninfer+Qwen3.8 baseline's 62 t/s, and holds
# 3+ concurrent 64K lanes decode-concurrent where ninfer's 81792-token KV
# ceiling allowed exactly one 64K lane).
#
# WHAT THIS IS: signalnine/q27 (v0.14.1, commit 8be624e92362f5b1f4523fe4e0d38d11d170670b),
# a single-GPU narrow inference engine for Qwen3.6/3.8-27B-MTP and PrismML's
# Ternary Bonsai 2 27B. Serves the T3 slim pack (6.06 GiB weights, ternary
# 1.6 bpw, Hadamard-folded — bitwise the T2 pack's numerics on the 3090)
# plus the Qwen3.8 MTP head (blk.64, 6.49 GiB pack) on one RTX 3090.
# OpenAI (/v1/chat/completions, /v1/completions, /v1/responses) and
# Anthropic (/v1/messages) APIs on one port.
#
# WHY A CUSTOM MODULE: q27 publishes no Nix packaging and nixpkgs has no
# package. Built from a pinned fetchFromGitHub via the repo's own Makefile
# (build/q27-server-w8 target: the width-12 build OOMs at graph setup on
# 24 GB cards, README "On 24GB cards"). Toolchain: cudaPackages_12_8 nvcc
# (12.8 is the build floor — pf4.o links an sm_120a object unconditionally)
# + gcc13 (upstream targets gcc; 15.3 also compiled clean in the bench
# build, 13 pinned as the boring choice). CUDA runtime is NOT linked: the
# engine dlopens libcuda.so.1 from the driver (/run/opengl-driver) at
# runtime — ldd shows only glibc/libstdc++ (verified 2026-10-03).
#
# WHY THE ARTIFACT IS A fetchurl DERIVATION (contrast ../ninfer.nix): the
# q27 packs are 6.5 GiB, not 17 GiB — store copy + download temp fits the
# disk that ENOSPC'd on the 17 GiB ninfer artifact. fetchurl gives hash
# pinning at the flake level (no boot-time download gate, no sha256sum
# ExecCondition): corrupt artifact fails the BUILD, not the boot.
# Pinned to HF commit b50cbb33406732bebfe628f0d5205aaebc96a69c
# (signalnine/Bonsai-2-27B-q27 @ main, 2026-10-02); md5s cross-checked
# against the repo CHECKSUMS.md5 AND the locally downloaded copies used in
# the 2026-10-02 benchmark (f49b3e52… pack, bb95b3ca… tok — identical).
#
# VRAM BUDGET (3090 24.5 GiB, measured 2026-10-02, GPU-a4e36250…):
#   weights 6.49 GiB + engine stack 2.3 GiB (Q27_FIXED_STACK_GB=2.3) +
#   paged KV pool 9.53 GiB = 262144-token elastic window (8 slots share;
#   each may hold the whole pool) + 1.56 GiB free at ready. The MTP ladder
#   head ships inside the pack (blk.64) — no separate drafter, no
#   Q27_DFLASH2 reserve (DFlash2 serving is single-slot Q27_BATCH=0 only;
#   the MTP ladder keeps the fused multi-slot conductor, the measured
#   parallel path: 42 t/s aggregate decode at 2×64K lanes vs 1 lane for
#   ninfer).
#
# ARBITRATION (unchanged pattern): resident on the homelab spec, symmetric
# Conflicts with ollama + bonsai2 (prism llama-server). Desktop stays on
# the 3060 (GPU-a81782bc…); do-not-touch.
{den, ...}: let
  q27src = fetchTarball {
    url = "https://github.com/signalnine/q27/archive/8be624e92362f5b1f4523fe4e0d38d11d170670b.tar.gz";
    sha256 = "sha256-pJZALVRo0DlIxPyP2URA0x/k8akwxHlpKRovWu1O0HQ=";
  };
in {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    # HOMELAB-ONLY (2026-09-21 user request, 3090 specialisation pattern):
    # the whole q27 stack lives inside specialisation.homelab — absent from
    # the default generation.
    nixos = {
      pkgs,
      ...
    }: let
      cuda = pkgs.cudaPackages_12_8;

      q27 = pkgs.stdenv.mkDerivation {
        pname = "q27-server";
        version = "0.14.1";
        src = q27src;

        nativeBuildInputs = [cuda.cuda_nvcc pkgs.python3];
        buildInputs = [pkgs.stdenv.cc.cc.lib pkgs.glibc.static or pkgs.glibc];

        # The Makefile hardcodes /usr/local/cuda; point it at the nix store.
        # build/q27-server-w8 only (the 3090-class width-8 binary): skips
        # the test suites and the CLI, ~2 min single-TU link.
        buildPhase = ''
          runHook preBuild
          mkdir -p build
          # pf4.o needs the arch-specific sm_120a target (plain
          # compute_120 gencode REJECTS the mxf4nvf4 instruction —
          # README "fp4 NO-GO" note); runtime-gated to sm_120 only.
          $NVCC -O2 -std=c++17 -gencode arch=compute_120a,code=sm_120a -Xcompiler -Wall -c src/pf4.cu -o build/pf4.o
          $NVCC -O2 -std=c++17 -gencode arch=compute_86,code=sm_86 \
                -gencode arch=compute_89,code=sm_89 \
                -gencode arch=compute_120,code=sm_120 -Xcompiler -Wall \
                -DQ27_W_MAX=8 -Xcompiler -pthread \
                src/server.cu src/dflash2.cu src/blocks.cu src/prefill.cu src/kernels.cu \
                src/spec3.cu src/vgemm.cu src/device_model.cu src/loader.cpp src/tokenizer.cpp build/pf4.o \
                -o build/q27-server-w8
          runHook postBuild
        '';
        # Makefile expects nvcc at /usr/local/cuda; we bypass make entirely.
        dontUseCmakeConfigure = true;

        installPhase = ''
          mkdir -p $out/bin
          cp build/q27-server-w8 $out/bin/q27-server
        '';

        # CUDA kernel code lives in .nvFatBin sections; stripping breaks it.
        dontStrip = true;
      };

      # Packs pinned via HF lfs.oid (== content sha256; the prism
      # 06af754 hash-mismatch lesson). T3-MTP-slim: the 3090 pack —
      # T2 numerics bitwise, MTP ladder head included, 3.4 GiB less
      # than the T2 pack buys the 262K elastic window.
      pack = pkgs.fetchurl {
        url = "https://huggingface.co/signalnine/Bonsai-2-27B-q27/resolve/b50cbb33406732bebfe628f0d5205aaebc96a69c/bonsai2-27b-t3-mtp-slim.q27";
        sha256 = "sha256-Yo5ur0D+jXqTKyoC5FaMCRoWdxOiIIRFAtJFU4ssxlo=";
        # HF over H2 dies mid-stream on lossy routes (the prism module's
        # curl 92 CANCEL at 4.8 KB/s, 2026-10-01); HTTP/1.1 sustained.
        curlOptsList = ["--http1.1"];
      };
      tok = pkgs.fetchurl {
        url = "https://huggingface.co/signalnine/Bonsai-2-27B-q27/resolve/b50cbb33406732bebfe628f0d5205aaebc96a69c/qwen38-27b-mtp.tok";
        sha256 = "sha256-K2yBAmhvjzK+JveZbgUDKQ2llLQ3Q2kKJ2EXZaQpEkY=";
      };
    in {
      specialisation.homelab.configuration = {
        environment.systemPackages = [q27];

        systemd.services.q27-serve = {
          description = "q27 Ternary Bonsai 2 27B server (main 3090 inference engine)";
          after = ["network-online.target"];
          wants = ["network-online.target"];

          # EXCLUSIVE ARBITRATION (symmetric Conflicts, same pattern as
          # ../ninfer.nix): starting q27 natively stops ollama + bonsai2;
          # their units declare the reverse. q27 is THE resident engine.
          conflicts = ["ollama.service" "bonsai2.service"];
          wantedBy = ["multi-user.target"];

          serviceConfig = {
            # Boot gate (60 s GPU wait matches ollama/ninfer gates —
            # thunderbolt eGPU enumerates after multi-user.target). No
            # artifact ensure/verify: packs are store paths (fetchurl
            # hashes them at build time).
            ExecCondition = pkgs.writeShellScript "q27-boot-gate" ''
              i=0
              until [ -e /dev/nvidia-uvm ] && [ -e /dev/nvidia1 ]; do
                i=$((i+1)); [ $i -gt 60 ] && exit 1
                sleep 1
              done
            '';

            Type = "simple";
            # Packs + binary are store paths (world-readable); no state.
            DynamicUser = true;
            NoNewPrivileges = true;
            ProtectHome = true;
            PrivateTmp = true;
            ProtectSystem = "strict";
            ProtectKernelTunables = true;
            ProtectControlGroups = true;
            RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX"];
            # The engine relays the pack for the GPU on first boot
            # (~1-2 min one-time, cached afterward under PrivateTmp).
            TimeoutStartSec = "5min";

            # Measured 2026-10-02 (bench on this exact binary + pack):
            #   - Q27_FIXED_STACK_GB=2.3: the engine's measured non-KV
            #     footprint on the 3090; the paged-KV pool takes what
            #     remains. Without it the pool sizer overcommits and the
            #     boot dies at cudaMalloc (engine.cuh:1173).
            #   - Q27_BATCH unset (1): fused multi-slot conductor ON —
            #     the measured parallel path (concurrent 64K lanes).
            #     Q27_BATCH=0 is single-slot solo rounds (DFlash2 only).
            #   - --slots 8: 8 elastic slots share the 9.53 GiB pool; each
            #     may hold the full 262144 tokens. Fewer slots = fewer
            #     concurrent agents; more = same pool, no gain.
            #   - --ctx auto: elastic window, clamped to the pool.
            #   - Sampler = the README's measured Claude-Code recipe
            #     (greedy default scores 0.758 vs 0.847 with this).
            #   - --think-budget 0: CRITICAL for agentic serving — the
            #     default (half of max_tokens) force-closes reasoning
            #     blocks and truncates Claude-Code sessions to empty turns
            #     (5 of 6 trials at 0.000 score before this flag).
            #   - Host 0.0.0.0 (DELL consumes over the tailnet; exposure
            #     is firewall-gated to tailscale0 below, mirroring
            #     ollama:ninfer's pattern).
            ExecStart = ''
              ${q27}/bin/q27-server ${pack} ${tok} \
                --host 0.0.0.0 --port 8081 \
                --slots 8 \
                --think --temp 1.0 --top-p 0.95 --top-k 20 --min-p 0.05 --think-budget 0
            '';

            # Sustained-resident engine: recover from a gaming session's
            # CUDA OOM racing it (the ninfer pattern; a fresh boot
            # relayouts the pack in ~1-2 min).
            Restart = "on-failure";
            RestartSec = "10s";
          };

          environment = {
            # libcuda.so.1 resolves from the driver outside the store
            # (nvidia aspect binds /run/opengl-driver); the binary links
            # nothing CUDA (ldd-verified).
            LD_LIBRARY_PATH = "/run/opengl-driver/lib";
            # Single-GPU pin: the 3090 only (same UUID as ninfer/ollama/
            # bonsai2 pins — one card, arbitrating daemons).
            CUDA_VISIBLE_DEVICES = "GPU-a4e36250-873d-62c5-912e-fde18d238a6c";
          };

          # Measured 2026-10-02 (bench on this exact binary + pack):
          #   - Q27_FIXED_STACK_GB=2.3: the engine's measured non-KV
          #     footprint on the 3090; the paged-KV pool takes what
          #     remains. Without it the pool sizer overcommits and the
          #     boot dies at cudaMalloc (engine.cuh:1173).
          #   - Q27_BATCH unset (1): fused multi-slot conductor ON —
          #     the measured parallel path (concurrent 64K lanes).
          #     Q27_BATCH=0 is single-slot solo rounds (DFlash2 only).
          #   - --slots 8: 8 elastic slots share the 9.53 GiB pool; each
          #     may hold the full 262144 tokens. Fewer slots = fewer
          #     concurrent agents; more = same pool, no gain.
          #   - --ctx auto: elastic window, clamped to the pool.
          #   - Sampler = the README's measured Claude-Code recipe
          #     (greedy default scores 0.758 vs 0.847 with this).
          #   - --think-budget 0: CRITICAL for agentic serving — the
          #     default (half of max_tokens) force-closes reasoning
          #     blocks and truncates Claude-Code sessions to empty turns
          #     (5 of 6 trials at 0.000 score before this flag).
          #   - Host 0.0.0.0 (DELL consumes over the tailnet; exposure
          #     is firewall-gated to tailscale0 below, mirroring
          #     ollama:ninfer's pattern).
        };

        # DELL consumes q27 over the tailnet (mirror of the ollama :11434
        # / ninfer :8081 firewall pattern): open 8081 ONLY on tailscale0,
        # never the LAN.
        networking.firewall.interfaces.tailscale0.allowedTCPPorts = [8081];
      };
    };
  };
}
