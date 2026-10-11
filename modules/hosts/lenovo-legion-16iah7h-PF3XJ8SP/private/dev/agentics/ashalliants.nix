# ashalliants ninfer 0.15.0 (RTX 3090 release binary) — Qwen3.8-27B
# DFlash2 server, added 2026-10-09 from the engines-2026-10 benchmark:
# the Qwen-arm winner on BOTH criteria — peak 162.7 tok/s per-agent
# (fresh C1) and high-parallelism x deep-ctx (C8x32k 1112.0, C8x65k
# 1073.1, C8x131k 820.3 agg tok/s) — vs resident ninfer-061 (Don-Chad
# v0.6.1, MTP3 int8: 68.8 peak, best agg 168.7 at C8x32k, 3-7x slower
# overall).
#
# WHY THE VENDOR TREE IS CONSUMED IN PLACE, NOT STORED: the release is a
# 20 GiB unpacked tree (17.7 GiB .ninfer artifact + binaries), and /home
# sits at 94%. A store copy would double that transiently (measured
# ENOSPC twice on 2026-09-29 for the 17 GiB ninfer artifact). The
# benchmark staged tree at ~/models/q27-bench/ashalliants/
# ninfer-rtx3090-linux-x64-0.15.0-rtx3090 is hash-verified below and
# referenced directly (ProtectHome=false for this unit only; artifact
# and /home are single-user ayin-owned).
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
# VRAM ARBITRATION (24.5 GiB card, single resource): ashalliants is the
# Qwen3.8 winner (23.3 GiB peak with weights+KV, measured), ninfer-061
# 19.6 GiB, bonsai2 21.9 GiB. All four daemons declare symmetric
# Conflicts — starting any stops the others natively.
{...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    # HOMELAB-ONLY (3090 specialisation pattern, see ninfer.nix header):
    # the unit + wrapper exist only inside specialisation.homelab.
    nixos = {
      pkgs,
      lib,
      ...
    }: let
      ashRoot = "/home/ayin/models/q27-bench/ashalliants/ninfer-rtx3090-linux-x64-0.15.0-rtx3090";

      # The four non-bundled ldd deps of the 0.15.0 binary (skill:
      # ninfer-ash-hostkv-clamp). prism-llamacpp-libs covers
      # cublas/cudart, the driver package covers libcuda (via
      # /run/opengl-driver below), ffmpeg-full covers av*/swscale, curl
      # covers libcurl.so.4. Pin the exact store paths the benchmark
      # verified (engines.py LD_LIBRARY_PATH, 2026-10-08/09 sweeps).
      ashLibs = [
        "/nix/store/pck9wssp6ca6dfxhpz15c8p67z4r59bg-prism-llamacpp-libs/lib"
        "/nix/store/3qixz64pvv7glvnhvqsib5fwb80rrfca-nvidia-x11-595.104.02/lib"
        "/nix/store/rcz6a5zlg8vqx689qsxh1r4m8v3pn3ic-ffmpeg-full-6.1.6-lib/lib"
        "/nix/store/cjxc4x3cnlzlcdrsi92k5i7pkn78ixnz-curl-8.21.0/lib"
      ];

      # On-demand starter (mirror of llamacpp-prism-up): stops the other
      # 3090 daemons natively (systemd Conflicts), then starts this unit.
      ashalliants-up = pkgs.writeShellScriptBin "ashalliants-up" ''
        exec ${pkgs.systemd}/bin/systemctl start ashalliants-df2.service
      '';
      ashalliants-down = pkgs.writeShellScriptBin "ashalliants-down" ''
        exec ${pkgs.systemd}/bin/systemctl stop ashalliants-df2.service
      '';
    in {
      specialisation.homelab.configuration = {
        environment.systemPackages = [ashalliants-up ashalliants-down];

        systemd.services.ashalliants-df2 = {
          description = "ashalliants ninfer-0.15.0 Qwen3.8-27B DFlash2";
          after = ["network-online.target"];
          wants = ["network-online.target"];

          # PRIMARY ENGINE (2026-10-10 user request: ninfer-061 removed
          # entirely, ../swap.nix + flake input; this unit autostarts on
          # the homelab spec). ollama is on-demand (../ollama.nix) and
          # declares the reverse Conflicts, so an ollama start still
          # stops this unit natively.
          wantedBy = ["multi-user.target"];

          conflicts = ["ollama.service" "bonsai2.service"];

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
            WorkingDirectory = ashRoot;
            # Boot gate: 60 s GPU wait (thunderbolt eGPU enumerates after
            # multi-user.target), then artifact hash verify. Exit 1 = clean
            # skip (undocked / unplugged GPU), no restart storm.
            ExecCondition = pkgs.writeShellScript "ashalliants-boot-gate" ''
              i=0
              until [ -e /dev/nvidia-uvm ] && [ -e /dev/nvidia1 ]; do
                i=$((i+1)); [ $i -gt 60 ] && exit 1
                sleep 1
              done
              # Artifact gate (vendor download-model.sh pins, verified
              # 2026-10-09: sha256 7f2a0086..., 18982458624 bytes).
              echo "7f2a0086a071ee932c66106e1552d118a85cfec8ddef13c67a54cd64abb39706  ${ashRoot}/models/qwen3_8_27b.ninfer" \
                | ${pkgs.coreutils}/bin/sha256sum -c -
            '';

            # Vendor run.sh: tuned profile (dflash2 K=7, 262144 ctx, rk4v4
            # KV, vision overlay). NINFER_FALLBACK=off keeps the context
            # honest (omp overclaim = trim-loop; a stepped-down context
            # would silently diverge from the declared provider window).
            # NINFER_HOST_STATE_SLOTS=8 + hostkv-shim (2 GiB) = the exact
            # benchmarked shape; NINFER_SPEC=dflash2 pins the winner lane.
            Environment = let
              ld = lib.concatStringsSep ":" (ashLibs ++ ["/run/opengl-driver/lib"]);
            in [
              "PATH=${lib.makeBinPath [pkgs.bash pkgs.coreutils]}"
              "CUDA_VISIBLE_DEVICES=GPU-a4e36250-873d-62c5-912e-fde18d238a6c"
              "LD_LIBRARY_PATH=${ld}"
              "NINFER_SPEC=dflash2"
              "NINFER_HOST=127.0.0.1"
              "NINFER_PORT=8092"
              "NINFER_FALLBACK=off"
              "NINFER_HOST_STATE_SLOTS=8"
              "NINFER_SERVER=${ashRoot}/ninfer-serve.hostkv-shim"
            ];
            ExecStart = "${ashRoot}/run.sh qwen38-27b tuned";

            # Second belt after the 2 GiB hostkv clamp: throttle at 10G,
            # hard wall 12G (ninfer.nix oomd history: Psi spikes killed
            # engines 4x on 2026-10-03).
            MemoryHigh = "10G";
            MemoryMax = "12G";
            Restart = "on-failure";
            RestartSec = "10s";
            # /home artifact tree: ProtectHome must stay OFF for this unit
            # (runs.sh + binary live under /home/ayin/models). ProtectSystem
            # still pins the rest of the FS.
            ProtectSystem = "strict";
            NoNewPrivileges = true;
            PrivateTmp = true;
          };
        };

        # DELL consumes ashalliants over the tailnet (2026-10-10: swapped
        # for the removed ninfer :8081 rule; mirror of the ollama :11434
        # pattern in ../ollama.nix): open 8092 ONLY on tailscale0.
        networking.firewall.interfaces.tailscale0.allowedTCPPorts = [8092];
      }; # specialisation.homelab.configuration
    };
  };
}
