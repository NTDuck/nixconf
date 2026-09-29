# NInfer-3090 — MAIN 3090 inference engine (2026-09-29 user request).
# SM86 build of Don-Chad/ninfer-3090 (the maintained Ampere port of
# Neroued/ninfer, which is locked to sm_120a/RTX 5090). Serves the
# official Qwen3.8-27B groupwise artifact on one RTX 3090 with MTP3,
# ReplaySSM, CUDA Graphs, paged KV, and an OpenAI + Anthropic-compatible
# API (OpenAI adapter wired into omp).
#
# WHY A CUSTOM MODULE: upstream nixpkgs has no ninfer package and the
# fork publishes no Nix packaging. Built from source via the fork's own
# flake input (pinned to the validated v0.6.1-rtx3090 tag commit in
# flake.nix; gcc13Stdenv + CUDA 12.9, unfree allowed inside their flake
# eval). Consumed as `inputs.ninfer.packages.${system}.ninfer` — the
# fork's validated toolchain, not a re-derivation.
#
# WHY THE ARTIFACT IS NOT A fetchurl DERIVATION: the qwen3_8_27b.ninfer
# artifact is 17.0 GiB (HF LFS sha256
# eec39564993d6e9c7d5e383382a760f093465c9d163ec9a1bd6b80199514bf3e,
# HF commit 3526913004b1 — see ExecCondition for why this commit and
# not main).
# A fetchurl build doubles that transiently (download temp + store copy)
# on a disk that runs at 98% — measured ENOSPC twice on 2026-09-29. The
# fork's own Linux delivery is a resumable `curl -C -` into
# NINFER_MODEL_DIR, mirrored here: ExecStartPre resumes the download
# into /var/lib/ninfer (one-time ~6 min at ~58 MB/s), then hash-verifies
# against the pinned sha256 before the engine ever loads it. A corrupt
# artifact fails the boot gate instead of poisoning KV cache semantics.
#
# VRAM ARBITRATION (3090 is 24.5 GiB, single-resource):
#   ninfer 19.6 GiB peak (README C8 table) — resident engine, autostarts
#   on the homelab spec. ollama demoted to on-demand (WantedBy REMOVED
#   from ollama; conflicts declared here — see ../ollama.nix). bonsai2
#   stays on-demand via llamacpp-prism-up/-down (see ../prism/swap.nix),
#   updated to arbitrate ninfer as the resident daemon instead of
#   ollama.
{
  den,
  inputs,
  ...
}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    # HOMELAB-ONLY (2026-09-21 user request, 3090 specialisation pattern):
    # the whole ninfer stack lives inside specialisation.homelab — absent
    # from the default generation.
    nixos = {
      pkgs,
      lib,
      ...
    }: let
      ninfer = inputs.ninfer.packages.${pkgs.system}.ninfer;
    in {
      specialisation.homelab.configuration = {
        environment.systemPackages = [ninfer];

        systemd.services.ninfer-serve = {
          description = "NInfer-3090 Qwen3.8-27B server (main 3090 inference engine)";
          after = ["network-online.target"];
          wants = ["network-online.target"];

          # EXCLUSIVE ARBITRATION (symmetric Conflicts): starting ninfer
          # natively stops ollama + bonsai2; systemd enforces the reverse
          # when THEY start. ollama is demoted from autostart (see
          # ../ollama.nix WantedBy removal) — ninfer is THE resident
          # engine on the homelab spec.
          conflicts = ["ollama.service" "bonsai2.service"];
          wantedBy = ["multi-user.target"];

          environment = {
            # libcuda.so.1 comes from the driver package, outside the
            # store closure (nvidia aspect binds /run/opengl-driver);
            # store libs (libcudart, libcurl, ffmpeg) resolve via the
            # build's own RPATH.
            LD_LIBRARY_PATH = "/run/opengl-driver/lib";
            # Single-GPU pin: the 3090 only. Desktop runs on the 3060
            # (see ../prism/default.nix VRAM budget note). UUID matches
            # the ollama/prism pins (one card, three daemons).
            CUDA_VISIBLE_DEVICES = "GPU-a4e36250-873d-62c5-912e-fde18d238a6c";
          };

          serviceConfig = {
            Type = "simple";
            User = "root"; # /var/lib/ninfer is root-owned (download path)
            StateDirectory = "ninfer";

            # Boot gate (60 s GPU wait matches ollama's gate — thunderbolt
            # eGPU enumerates after multi-user.target), then artifact
            # ensure+verify. Exit 1 = clean skip (no restart storm):
            # ExecCondition non-zero skips the unit without counting as a
            # failure. Restart below covers genuine runtime crashes (CUDA
            # OOM racing a consumer), 10 s spacing to avoid a hot loop.
            ExecCondition = pkgs.writeShellScript "ninfer-boot-gate" ''
              i=0
              until [ -e /dev/nvidia-uvm ] && [ -e /dev/nvidia1 ]; do
                i=$((i+1)); [ $i -gt 60 ] && exit 1
                sleep 1
              done

              # Artifact ensure: resume-able download, idempotent. Size
              # check skips the (expensive) resume attempt when complete.
              # PINNED HF commit 3526913004b1 (2026-08-14): the LAST
              # dflash2-free artifact. 2026-09-29 measured: main-branch
              # v2/v3 artifacts embed dflash2/* objects that the pinned
              # v0.6.1 binder REJECTS at load ("artifact object was not
              # consumed by the selected target: dflash2/feature_projection"
              # — upstream master grew "bind optional dflash2 weights" +
              # "prune disabled startup weights"; the fork predates both).
              # Also pins container v2 (loader accepts v1/v2 only; main
              # is v3 since 2026-09-15). 17.0 GiB, sha256 eec39564…
              if [ ! -f /var/lib/ninfer/qwen3_8_27b.ninfer ] \
                || [ "$(${pkgs.coreutils}/bin/stat -c%s /var/lib/ninfer/qwen3_8_27b.ninfer)" != "18210531328" ]; then
                echo "ninfer: downloading Qwen3.8-27B artifact (one-time ~6 min)..."
                ${pkgs.curl}/bin/curl -L -C - --fail --retry 3 \
                  --output /var/lib/ninfer/qwen3_8_27b.ninfer \
                  https://huggingface.co/neroued/Qwen3.8-27B-NInfer/resolve/3526913004b1cf552cb57b88d6a5c6f5e4a89a70/qwen3_8_27b.ninfer
              fi

              # Hash gate: corrupt/interrupted artifact must never reach
              # the engine (weights+KV poison silently otherwise).
              echo "eec39564993d6e9c7d5e383382a760f093465c9d163ec9a1bd6b80199514bf3e  /var/lib/ninfer/qwen3_8_27b.ninfer" \
                | ${pkgs.coreutils}/bin/sha256sum -c -
            '';

            # 3090-validated profile (2026-09-29 measured, engine refuses
            # anything higher): --max-context 65536 is the KV-feasible
            # ceiling — at 131072 the fixed minimum Engine runtime
            # reservation (8.17 GiB) + 1 GiB headroom exceeds free VRAM
            # after 16.7 GiB weights ("only 7.5 GiB available after
            # weights"). 64K resolves to 81792 tokens KV (5.96 GiB,
            # 1.61 GiB free after startup). NO --lm-head-draft: it
            # materializes a second 5120x17408 draft head the 3090
            # budget cannot fit (measured: with it, free-after-weights
            # drops to 4.9 GiB and even 65536 fails). --kv-capacity auto
            # sizes KV to actual free VRAM. Host 0.0.0.0 (fork's Docker
            # delivery): DELL consumes ninfer over the tailnet; exposure
            # is firewall-gated to tailscale0 below, mirroring ollama's
            # host="0.0.0.0" + :11434 pattern.
            ExecStart = ''
              ${ninfer}/bin/ninfer-serve /var/lib/ninfer/qwen3_8_27b.ninfer \
                --host 0.0.0.0 --port 8081 \
                --max-context 65536 --kv-capacity auto \
                --max-concurrency 8 --max-pending-requests 32 \
                --prefill-chunk 1024 --kv-dtype int8 \
                --spec mtp --draft-tokens 3
            '';

            Restart = "on-failure";
            RestartSec = "10s";
            ProtectSystem = "strict";
            ReadWritePaths = ["/var/lib/ninfer"];
            NoNewPrivileges = true;
            ProtectHome = true;
          };
        };

        # DELL consumes ninfer over the tailnet (mirror of the ollama
        # :11434 firewall pattern in ../ollama.nix): open 8081 ONLY on
        # tailscale0, never the LAN.
        networking.firewall.interfaces.tailscale0.allowedTCPPorts = [8081];
      };
    };
  };
}
