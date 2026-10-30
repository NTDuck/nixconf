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
{den, ...}: {
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
        "/run/opengl-driver/lib"
        "/nix/store/pck9wssp6ca6dfxhpz15c8p67z4r59bg-prism-llamacpp-libs/lib"
        "/nix/store/3qixz64pvv7glvnhvqsib5fwb80rrfca-nvidia-x11-595.104.02/lib"
        "/nix/store/rcz6a5zlg8vqx689qsxh1r4m8v3pn3ic-ffmpeg-full-6.1.6-lib/lib"
        "/nix/store/cjxc4x3cnlzlcdrsi92k5i7pkn78ixnz-curl-8.21.0/lib"
      ];

      # Port the ninfer-serve listens on. Single source of truth for
      # this host; remote hosts (dell) duplicate the value with a sync
      # comment in their models.yml.
      ashPort = 8092;
      # 2026-10-18: Native shell ashalliant CLI. Fast (<5ms), minimal UI,
      # canonical IDs only (no aliases), <nil> unloader, and full shell completions.
      ashalliant = pkgs.stdenv.mkDerivation {
        pname = "ashalliant";
        version = "1.0.0";

        dontUnpack = true;

        installPhase = ''
          runHook preInstall
          mkdir -p $out/bin $out/share/zsh/site-functions $out/share/bash-completion/completions $out/share/fish/vendor_completions.d

          cat << 'SCRIPT' > $out/bin/ashalliant
#!/usr/bin/env bash
set -euo pipefail

# Pass --no-ask-password to prevent hanging on polkit TTY prompts when non-interactive.
SYSTEMCTL=( "${pkgs.systemd}/bin/systemctl" --no-ask-password )

MODELS=(
  "qwen3.8-27b|ashalliants-df2.service|${toString ashPort}|6x65k"
  "qwen3.8-27b-abliterated|ashalliants-df2-abliterated.service|${toString ashPort}|6x65k"
  "qwen3.6-35b-a3b|ashalliants-35b.service|${toString ashPort}|3x65k"
  "qwen3.6-35b-a3b-abliterated|ashalliants-35b-abliterated.service|${toString ashPort}|3x65k"
  "hemmingway-1-abliterated|ashalliants-hemmingway-1-heretic.service|${toString ashPort}|1x262k"
)

show_list() {
  local any_active=0
  for entry in "''${MODELS[@]}"; do
    IFS='|' read -r mid svc port shape <<< "$entry"
    local state="inactive"
    if "''${SYSTEMCTL[@]}" is-active --quiet "$svc" 2>/dev/null; then
      state="active"
      any_active=1
    fi
    printf "%-30s %-8s %-10s :%s\n" "$mid" "$shape" "$state" "$port"
  done
  local nil_state="inactive"
  if [ "$any_active" -eq 0 ]; then
    nil_state="active"
  fi
  printf "%-30s %-8s %-10s -\n" "<nil>" "-" "$nil_state"
}

do_switch() {
  local target="$1"
  if [ "$target" = "hemmingway-1-heretic" ]; then
    target="hemmingway-1-abliterated"
  fi
  if [ "$target" = "<nil>" ] || [ "$target" = "nil" ]; then
    for entry in "''${MODELS[@]}"; do
      IFS='|' read -r mid svc port shape <<< "$entry"
      if "''${SYSTEMCTL[@]}" is-active --quiet "$svc" 2>/dev/null; then
        "''${SYSTEMCTL[@]}" stop --no-block "$svc" 2>/dev/null || true
      fi
    done
    echo "switched to <nil>"
    return 0
  fi

  local found_svc=""
  local canonical=""
  for entry in "''${MODELS[@]}"; do
    IFS='|' read -r mid svc port shape <<< "$entry"
    if [ "$mid" = "$target" ]; then
      found_svc="$svc"
      canonical="$mid"
      break
    fi
  done

  if [ -z "$found_svc" ]; then
    echo "unknown model '$target', available: qwen3.8-27b, qwen3.8-27b-abliterated, qwen3.6-35b-a3b, qwen3.6-35b-a3b-abliterated, hemmingway-1-abliterated, <nil>" >&2
    exit 1
  fi

  if "''${SYSTEMCTL[@]}" is-active --quiet "$found_svc" 2>/dev/null; then
    echo "already on $canonical"
    return 0
  fi

  for entry in "''${MODELS[@]}"; do
    IFS='|' read -r mid svc port shape <<< "$entry"
    if [ "$svc" != "$found_svc" ] && "''${SYSTEMCTL[@]}" is-active --quiet "$svc" 2>/dev/null; then
      "''${SYSTEMCTL[@]}" stop --no-block "$svc" 2>/dev/null || true
    fi
  done

  if "''${SYSTEMCTL[@]}" start "$found_svc"; then
    echo "switched to $canonical"
  else
    echo "failed to start $found_svc" >&2
    exit 1
  fi
}

cmd="''${1:-}"
case "$cmd" in
  ""|list|status)
    show_list
    ;;
  switch|-s|--switch)
    if [ $# -lt 2 ]; then
      echo "error: model required" >&2
      exit 2
    fi
    do_switch "$2"
    ;;
  -h|--help|help)
    echo "usage: ashalliant [switch <model> | -s <model>]"
    ;;
  *)
    for entry in "''${MODELS[@]}"; do
      IFS='|' read -r mid svc port shape <<< "$entry"
      if [ "$mid" = "$cmd" ]; then
        do_switch "$cmd"
        exit 0
      fi
    done
    if [ "$cmd" = "<nil>" ] || [ "$cmd" = "nil" ]; then
      do_switch "<nil>"
      exit 0
    fi
    echo "unknown command '$cmd', run 'ashalliant -h' for usage" >&2
    exit 1
    ;;
esac
SCRIPT
          chmod +x $out/bin/ashalliant

          cat << 'ZSH' > $out/share/zsh/site-functions/_ashalliant
#compdef ashalliant

_ashalliant() {
  local -a models
  models=(
    'qwen3.8-27b:Qwen3.8-27B DFlash2 (6x65k :8092)'
    'qwen3.8-27b-abliterated:Qwen3.8-27B Abliterated (6x65k :8094)'
    'qwen3.6-35b-a3b:Qwen3.6-35B-A3B MTP3 (3x65k :8140)'
    'qwen3.6-35b-a3b-abliterated:Qwen3.6-35B-A3B Abliterated (3x65k :8142)'
    'hemmingway-1-abliterated:Hemmingway-1 Abliterated (1x262k :8092)'
    '\<nil\>:Unload all ashalliants models'
  )

  _arguments -C \
    '1:command:((switch\:"switch active model" list\:"list models" status\:"show status"))' \
    '2:model:->models' \
    '-s[switch active model]:model:->models' \
    '--switch[switch active model]:model:->models' \
    '-h[show help]' \
    '--help[show help]'

  case "$state" in
    models)
      _describe -t models 'model' models
      ;;
  esac
}

_ashalliant "$@"
ZSH

          cat << 'BASH' > $out/share/bash-completion/completions/ashalliant
_ashalliant_completion() {
  local cur prev
  cur="''${COMP_WORDS[COMP_CWORD]}"
  prev="''${COMP_WORDS[COMP_CWORD-1]}"

  local models="qwen3.8-27b qwen3.8-27b-abliterated qwen3.6-35b-a3b qwen3.6-35b-a3b-abliterated hemmingway-1-abliterated hemmingway-1-heretic <nil>"
  local commands="switch list status"

  case "$prev" in
    switch|-s|--switch)
      COMPREPLY=( $(compgen -W "$models" -- "$cur") )
      return 0
      ;;
  esac

  if [ "$COMP_CWORD" -eq 1 ]; then
    COMPREPLY=( $(compgen -W "$commands -s --switch -h --help $models" -- "$cur") )
  fi
}

complete -F _ashalliant_completion ashalliant
BASH

          cat << 'FISH' > $out/share/fish/vendor_completions.d/ashalliant.fish
complete -c ashalliant -n "__fish_use_subcommand" -a switch -d "switch active model"
complete -c ashalliant -n "__fish_use_subcommand" -a list -d "list models"
complete -c ashalliant -n "__fish_use_subcommand" -a status -d "show status"
complete -c ashalliant -n "__fish_seen_subcommand_from switch; or __fish_contains_opt -s s switch" -a "qwen3.8-27b qwen3.8-27b-abliterated qwen3.6-35b-a3b qwen3.6-35b-a3b-abliterated hemmingway-1-abliterated hemmingway-1-heretic <nil>"
FISH

          runHook postInstall
        '';
      };
    in {
      specialisation.homelab.configuration = {
        environment.systemPackages = [ashalliant];
        # Passwordless unit state management for ashalliant switch CLI.
        # Without this, systemctl stop/start blocks on interactive polkit auth (25s hang).
        # Grants active local sessions or wheel users permission to manage ashalliants-* and bonsai2 units.
        security.polkit.extraConfig = ''
          polkit.addRule(function(action, subject) {
            if (action.id === "org.freedesktop.systemd1.manage-units" &&
                (subject.isInGroup("wheel") || (subject.local && subject.active))) {
              var unit = action.lookup("unit");
              if (unit && (unit.indexOf("ashalliants-") === 0 || unit === "bonsai2.service")) {
                return polkit.Result.YES;
              }
            }
          });
        '';


        systemd.services.ashalliants-df2 = {
          description = "ashalliants ninfer-0.15.0 Qwen3.8-27B DFlash2";
          after = ["network-online.target"];
          wants = ["network-online.target"];

          # On-demand Qwen3.8-27B daemon (port 8092). Started via `ashalliant switch qwen3.8-27b`.
          conflicts = [
            "bonsai2.service"
            "ashalliants-df2-abliterated.service"
            "ashalliants-35b.service"
            "ashalliants-35b-abliterated.service"
            "ashalliants-hemmingway-1-heretic.service"
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

        # On-demand Qwen3.8-27B Abliterated daemon (port 8094).
        # PRIMARY ENGINE (Qwen3.8-27B Abliterated default on startup, autostarts on
        # the homelab spec).
        systemd.services.ashalliants-df2-abliterated = {
          description = "ashalliants ninfer-0.15.0 Qwen3.8-27B DFlash2 (Abliterated)";
          after = ["network-online.target"];
          wants = ["network-online.target"];
          wantedBy = ["multi-user.target"];
          conflicts = [
            "bonsai2.service"
            "ashalliants-df2.service"
            "ashalliants-35b.service"
            "ashalliants-35b-abliterated.service"
            "ashalliants-hemmingway-1-heretic.service"
          ];
          serviceConfig = {
            Type = "simple";
            User = "ayin";
            WorkingDirectory = ashRoot;
            ExecCondition = pkgs.writeShellScript "ashalliants-df2-abl-boot-gate" ''
              i=0
              until [ -e /dev/nvidia-uvm ] && [ -e /dev/nvidia1 ]; do
                i=$((i+1)); [ $i -gt 60 ] && exit 1
                sleep 1
              done
            '';
            Environment = let
              ld = lib.concatStringsSep ":" (ashLibs ++ ["/run/opengl-driver/lib"]);
            in [
              "PATH=${lib.makeBinPath [pkgs.bash pkgs.coreutils]}"
              "CUDA_VISIBLE_DEVICES=GPU-a4e36250-873d-62c5-912e-fde18d238a6c"
              "LD_LIBRARY_PATH=${ld}"
              "NINFER_SPEC=dflash2"
              "NINFER_HOST=0.0.0.0"
              "NINFER_PORT=${toString ashPort}"
              "NINFER_FALLBACK=off"
              "NINFER_CONCURRENCY=6"
              "NINFER_CONTEXT=65536"
              "NINFER_KV_CAPACITY=65536"
              "NINFER_HOST_STATE_SLOTS=6"
              "NINFER_SERVER=${ashRoot}/ninfer-serve.hostkv-shim"
            ];
            ExecStart = pkgs.writeShellScript "ashalliants-df2-abl-start" ''
              if [ -f "${ashRoot}/models/swift_1_5_qwen3_8_27b.ninfer" ]; then
                export NINFER_MODEL="${ashRoot}/models/swift_1_5_qwen3_8_27b.ninfer"
              elif [ -f "${ashRoot}/models/obliterated_qwen3_8_27b.ninfer" ]; then
                export NINFER_MODEL="${ashRoot}/models/obliterated_qwen3_8_27b.ninfer"
              fi
              exec ${ashRoot}/run.sh qwen38-27b tuned
            '';
            MemoryHigh = "10G";
            MemoryMax = "12G";
            Restart = "on-failure";
            RestartSec = "10s";
            ProtectSystem = "strict";
            NoNewPrivileges = true;
            PrivateTmp = true;
          };
        };

        # On-demand Qwen3.6-35B-A3B daemon (port 8140).
        systemd.services.ashalliants-35b = {
          description = "ashalliants ninfer-0.15.0 Qwen3.6-35B-A3B MTP3";
          after = ["network-online.target"];
          wants = ["network-online.target"];
          conflicts = [
            "bonsai2.service"
            "ashalliants-df2.service"
            "ashalliants-df2-abliterated.service"
            "ashalliants-35b-abliterated.service"
            "ashalliants-hemmingway-1-heretic.service"
          ];
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
              "NINFER_PORT=${toString ashPort}"
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

        # On-demand Qwen3.6-35B-A3B Abliterated daemon (port 8142).
        systemd.services.ashalliants-35b-abliterated = {
          description = "ashalliants ninfer-0.15.0 Qwen3.6-35B-A3B MTP3 (Abliterated)";
          after = ["network-online.target"];
          wants = ["network-online.target"];
          conflicts = [
            "bonsai2.service"
            "ashalliants-df2.service"
            "ashalliants-df2-abliterated.service"
            "ashalliants-35b.service"
            "ashalliants-hemmingway-1-heretic.service"
          ];
          serviceConfig = {
            Type = "simple";
            User = "ayin";
            WorkingDirectory = ashRoot;
            ExecCondition = pkgs.writeShellScript "ashalliants-35b-abl-boot-gate" ''
              i=0
              until [ -e /dev/nvidia-uvm ] && [ -e /dev/nvidia1 ]; do
                i=$((i+1)); [ $i -gt 60 ] && exit 1
                sleep 1
              done
            '';
            Environment = let
              ld = lib.concatStringsSep ":" (ashLibs ++ ["/run/opengl-driver/lib"]);
            in [
              "PATH=${lib.makeBinPath [pkgs.bash pkgs.coreutils]}"
              "CUDA_VISIBLE_DEVICES=GPU-a4e36250-873d-62c5-912e-fde18d238a6c"
              "LD_LIBRARY_PATH=${ld}"
              "NINFER_SPEC=mtp"
              "NINFER_HOST=0.0.0.0"
              "NINFER_PORT=${toString ashPort}"
              "NINFER_FALLBACK=off"
              "NINFER_CONCURRENCY=3"
              "NINFER_CONTEXT=65536"
              "NINFER_KV_CAPACITY=65536"
              "NINFER_HOST_STATE_SLOTS=3"
              "NINFER_SERVER=${ashRoot}/ninfer-serve.hostkv-shim"
            ];
            ExecStart = pkgs.writeShellScript "ashalliants-35b-abl-start" ''
              if [ -f "${ashRoot}/models/qwen3_6_35b_a3b_huihui_abliterated.ninfer" ]; then
                export NINFER_MODEL="${ashRoot}/models/qwen3_6_35b_a3b_huihui_abliterated.ninfer"
              fi
              exec ${ashRoot}/run.sh qwen36-35b-a3b tuned
            '';
            MemoryHigh = "10G";
            MemoryMax = "12G";
            Restart = "on-failure";
            RestartSec = "10s";
            ProtectSystem = "strict";
            NoNewPrivileges = true;
            PrivateTmp = true;
          };
        };

        # On-demand Hemmingway-1 (Abliterated) daemon (single-lane throughput optimized).
        systemd.services.ashalliants-hemmingway-1-heretic = {
          description = "ashalliants ninfer-0.15.0 Hemmingway-1 (Abliterated)";
          after = ["network-online.target"];
          wants = ["network-online.target"];
          conflicts = [
            "bonsai2.service"
            "ashalliants-df2.service"
            "ashalliants-df2-abliterated.service"
            "ashalliants-35b.service"
            "ashalliants-35b-abliterated.service"
          ];
          serviceConfig = {
            Type = "simple";
            User = "ayin";
            WorkingDirectory = ashRoot;
            ExecCondition = pkgs.writeShellScript "ashalliants-hemmingway-boot-gate" ''
              i=0
              until [ -e /dev/nvidia-uvm ] && [ -e /dev/nvidia1 ]; do
                i=$((i+1)); [ $i -gt 60 ] && exit 1
                sleep 1
              done
            '';
            Environment = let
              ld = lib.concatStringsSep ":" (ashLibs ++ ["/run/opengl-driver/lib"]);
            in [
              "PATH=${lib.makeBinPath [pkgs.bash pkgs.coreutils]}"
              "CUDA_VISIBLE_DEVICES=GPU-a4e36250-873d-62c5-912e-fde18d238a6c"
              "LD_LIBRARY_PATH=${ld}"
              "NINFER_SPEC=mtp"
              "NINFER_HOST=0.0.0.0"
              "NINFER_PORT=${toString ashPort}"
              "NINFER_FALLBACK=off"
              "NINFER_CONCURRENCY=1"
              "NINFER_CONTEXT=262144"
              "NINFER_KV_CAPACITY=262144"
              "NINFER_HOST_STATE_SLOTS=1"
              "NINFER_PREFILL_CHUNK=4096"
              "NINFER_SERVER=${ashRoot}/ninfer-serve.hostkv-shim"
            ];
            ExecStart = pkgs.writeShellScript "ashalliants-hemmingway-start" ''
              export NINFER_MODEL="${ashRoot}/models/hemmingway_1_heretic.ninfer"
              exec ${ashRoot}/run.sh hemmingway-1-heretic tuned
            '';
            MemoryHigh = "10G";
            MemoryMax = "12G";
            Restart = "on-failure";
            RestartSec = "10s";
            ProtectSystem = "strict";
            NoNewPrivileges = true;
            PrivateTmp = true;
          };
        };

        # Tailscale firewall: open single ashalliants port (:8092).
        networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
          ashPort
        ];
      }; # specialisation.homelab.configuration
    };
  };
}
