# ashalliants ninfer 0.15.0 (RTX 3090 release binary) — Qwen3.8-27B
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
# Qwen3.8 winner (23.3 GiB peak with weights+KV, measured), bonsai2
# 21.9 GiB. Both daemons declare symmetric Conflicts — starting any
# stops the other natively.
#
# PORT (2026-10-12): the den module system does NOT support top-level
# `options` (it wraps values in aspect objects, so `den.aspects.X.port`
# returns an aspect object, not the raw value). The port is exposed as a
# let-binding `ashPort` here and referenced via `toString ashPort` in
# the unit's Environment + firewall rules. Remote hosts (dell) duplicate
# the value with a sync comment — cross-host option references aren't
# reliable in the den module system.
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

      # Port the ninfer-serve listens on. Single source of truth for
      # this host; remote hosts (dell) duplicate the value with a sync
      # comment in their models.yml.
      ashPort = 8092;
      ashPort35b = 8140;

      # On-demand starter (mirror of llamacpp-prism-up): stops the other
      # 3090 daemons natively (systemd Conflicts), then starts this unit.
      ashalliants-up = pkgs.writeShellScriptBin "ashalliants-up" ''
        exec ${pkgs.systemd}/bin/systemctl start ashalliants-df2.service
      '';
      ashalliants-down = pkgs.writeShellScriptBin "ashalliants-down" ''
        exec ${pkgs.systemd}/bin/systemctl stop ashalliants-df2.service
      '';
      ashalliants-35b-up = pkgs.writeShellScriptBin "ashalliants-35b-up" ''
        exec ${pkgs.systemd}/bin/systemctl start ashalliants-35b.service
      '';
      ashalliants-35b-down = pkgs.writeShellScriptBin "ashalliants-35b-down" ''
        exec ${pkgs.systemd}/bin/systemctl stop ashalliants-35b.service
      '';
    in {
      specialisation.homelab.configuration = {
        environment.systemPackages = [ashalliants-up ashalliants-down ashalliants-35b-up ashalliants-35b-down];

        systemd.services.ashalliants-df2 = {
          description = "ashalliants ninfer-0.15.0 Qwen3.8-27B DFlash2";
          after = ["network-online.target"];
          wants = ["network-online.target"];

          # ON-DEMAND ENGINE (2026-10-16: ashalliants-35b is the primary autostart
          # engine; ashalliants-df2 is on-demand via ashalliants-up).
          # bonsai2 and ashalliants-35b declare reverse Conflicts.

          conflicts = ["bonsai2.service" "ashalliants-35b.service"];

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
            # NINFER_HOST_STATE_SLOTS=6 + hostkv-shim (2 GiB) = the exact
            # benchmarked shape (2026-10-12: C6x65k = 769.4 agg tok/s,
            # 128.2 per-lane); NINFER_SPEC=dflash2 pins the winner lane.
            Environment = let
              ld = lib.concatStringsSep ":" (ashLibs ++ ["/run/opengl-driver/lib"]);
            in [
              "PATH=${lib.makeBinPath [pkgs.bash pkgs.coreutils]}"
              "CUDA_VISIBLE_DEVICES=GPU-a4e36250-873d-62c5-912e-fde18d238a6c"
              "LD_LIBRARY_PATH=${ld}"
              "NINFER_SPEC=dflash2"
              # Listen on 0.0.0.0 so tailscale0 peers (Dell) can connect;
              # tailscale0-only firewall rule below keeps non-tailnet traffic blocked.
              "NINFER_HOST=0.0.0.0"
              "NINFER_PORT=${toString ashPort}"
              "NINFER_FALLBACK=off"
              "NINFER_CONCURRENCY=6"
              "NINFER_CONTEXT=65536"
              "NINFER_KV_CAPACITY=65536"
              "NINFER_HOST_STATE_SLOTS=6"
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

        # PRIMARY Qwen3.6-35B-A3B daemon (port 8140, 2026-10-16 benchmark winner:
        # 378.5 peak tok/s, 314+ tok/s at C3x65k). Mutually exclusive with
        # ashalliants-df2 and bonsai2 via systemd Conflicts.
        systemd.services.ashalliants-35b = {
          description = "ashalliants ninfer-0.15.0 Qwen3.6-35B-A3B MTP3";
          after = ["network-online.target"];
          wants = ["network-online.target"];
          wantedBy = ["multi-user.target"];
          conflicts = ["bonsai2.service" "ashalliants-df2.service"];
          serviceConfig = {
            Type = "simple";
            User = "ayin";
            WorkingDirectory = ashRoot;
            ExecCondition = pkgs.writeShellScript "ashalliants-35b-boot-gate" ''
              i=0
              until [ -e /dev/nvidia-uvm ] && [ -e /dev/nvidia1 ]; do
                i=$((i+1)); [ $i -gt 60 ] && exit 1
                sleep 1
              done
              echo "3e33297645dc33557751be1a3c407a74ed7c00f34909b5d4e8cfdce91b3dbe84  ${ashRoot}/models/qwen3_6_35b_a3b.ninfer" \
                | ${pkgs.coreutils}/bin/sha256sum -c -
            '';
            Environment = let
              ld = lib.concatStringsSep ":" (ashLibs ++ ["/run/opengl-driver/lib"]);
            in [
              "PATH=${lib.makeBinPath [pkgs.bash pkgs.coreutils]}"
              "CUDA_VISIBLE_DEVICES=GPU-a4e36250-873d-62c5-912e-fde18d238a6c"
              "LD_LIBRARY_PATH=${ld}"
              "NINFER_SPEC=mtp"
              "NINFER_HOST=0.0.0.0"
              "NINFER_PORT=${toString ashPort35b}"
              "NINFER_FALLBACK=off"
              "NINFER_CONCURRENCY=3"
              "NINFER_CONTEXT=65536"
              "NINFER_KV_CAPACITY=65536"
              "NINFER_HOST_STATE_SLOTS=3"
              "NINFER_SERVER=${ashRoot}/ninfer-serve.hostkv-shim"
            ];
            ExecStart = "${ashRoot}/run.sh qwen36-35b-a3b tuned";
            MemoryHigh = "10G";
            MemoryMax = "12G";
            Restart = "on-failure";
            RestartSec = "10s";
            ProtectSystem = "strict";
            NoNewPrivileges = true;
            PrivateTmp = true;
          };
        };

        # DELL consumes ashalliants over the tailnet (2026-10-10: swapped
        # for the removed ninfer :8081 rule): open the ashalliants port
        # ONLY on tailscale0.
        networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
          ashPort
          ashPort35b
        ];
      }; # specialisation.homelab.configuration
    };
  };
}
