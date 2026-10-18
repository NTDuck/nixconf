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

      # 2026-10-18: Single unified `ashalliant` CLI using Typer framework.
      # Legacy separate ashalliants-{up,down,35b-up,35b-down} scripts removed.
      # Provides switch (-s), -h/--help, up, down, status, list, and shell autosuggestion.
      ashalliant =
        (pkgs.writers.writePython3Bin "ashalliant" {
          libraries = [pkgs.python3Packages.typer];
          flakeIgnore = ["E501"];
        } ''
          import subprocess
          from typing import Optional
          import typer

          SYSTEMCTL = "${pkgs.systemd}/bin/systemctl"

          MODELS = {
              "27b": {
                  "key": "27b",
                  "service": "ashalliants-df2.service",
                  "port": ${toString ashPort},
                  "label": "Qwen3.8-27B DFlash2",
                  "aliases": [
                      "27", "27b", "df2", "qwen27b", "qwen38",
                      "qwen38-27b", "qwen3.8", "qwen3.8-27b",
                      "27b-abliterated", "qwen38-abliterated",
                      "qwen3.8-27b-abliterated", "godmode",
                  ],
              },
              "35b": {
                  "service": "ashalliants-35b.service",
                  "port": ${toString ashPort35b},
                  "label": "Qwen3.6-35B-A3B MTP3",
                  "aliases": [
                      "35", "35b", "mtp", "qwen35b", "qwen36",
                      "qwen36-35b", "qwen3.6", "qwen3.6-35b", "qwen3.6-35b-a3b",
                      "35b-abliterated", "qwen36-abliterated",
                      "qwen3.6-35b-a3b-abliterated",
                  ],
              },
          }

          app = typer.Typer(
              name="ashalliant",
              help="Manage and switch Ashalliants Ninfer LLM daemons.",
              context_settings={"help_option_names": ["-h", "--help"]},
          )


          def complete_models(ctx: typer.Context, args: list[str], incomplete: str):
              norm = incomplete.strip().lower()
              for key, info in MODELS.items():
                  if key.startswith(norm):
                      yield (key, f"{info['label']} (port {info['port']})")
              if norm and not any(k.startswith(norm) for k in MODELS):
                  for key, info in MODELS.items():
                      for alias in info["aliases"]:
                          if alias.startswith(norm) and alias != key:
                              yield (alias, f"Alias for {key} ({info['label']})")


          def resolve_model(name: str):
              norm = name.strip().lower()
              for key, info in MODELS.items():
                  if norm == key or norm in info["aliases"]:
                      return info
              choices = ", ".join(MODELS.keys())
              typer.secho(
                  f"Error: Unknown model '{name}'. Available models: {choices}",
                  fg=typer.colors.RED,
                  err=True,
              )
              raise typer.Exit(code=1)


          def do_switch(model_name: str):
              target = resolve_model(model_name)
              for key, info in MODELS.items():
                  if key != target["key"]:
                      subprocess.run([SYSTEMCTL, "stop", info["service"]], check=False)
              res = subprocess.run([SYSTEMCTL, "start", target["service"]])
              if res.returncode == 0:
                  typer.secho(
                      f"✓ Switched to {target['label']} ({target['service']} on port {target['port']})",
                      fg=typer.colors.GREEN,
                      bold=True,
                  )
              else:
                  typer.secho(
                      f"✗ Failed to start {target['service']} (exit code {res.returncode})",
                      fg=typer.colors.RED,
                      err=True,
                  )
                  raise typer.Exit(code=res.returncode)


          @app.command(name="switch", help="Switch active daemon to target model.")
          def switch_cmd(
              model: str = typer.Argument(
                  ...,
                  help="Model name or alias (27b, 35b, qwen3.8-27b, qwen3.6-35b-a3b, etc.)",
                  autocompletion=complete_models,
              ),
          ):
              do_switch(model)


          @app.command(name="up", help="Start an ashalliants daemon (defaults to 27b).")
          def up_cmd(
              model: str = typer.Argument(
                  "27b",
                  help="Model name or alias: 27b or 35b",
                  autocompletion=complete_models,
              ),
          ):
              target = resolve_model(model)
              res = subprocess.run([SYSTEMCTL, "start", target["service"]])
              if res.returncode == 0:
                  typer.secho(
                      f"✓ Started {target['label']} ({target['service']})",
                      fg=typer.colors.GREEN,
                  )
              else:
                  typer.secho(
                      f"✗ Failed to start {target['service']} (exit code {res.returncode})",
                      fg=typer.colors.RED,
                      err=True,
                  )
                  raise typer.Exit(code=res.returncode)


          @app.command(name="down", help="Stop ashalliants daemon(s).")
          def down_cmd(
              model: Optional[str] = typer.Argument(
                  None,
                  help="Model name or alias (stops all if omitted)",
                  autocompletion=complete_models,
              ),
          ):
              if model:
                  target = resolve_model(model)
                  subprocess.run([SYSTEMCTL, "stop", target["service"]])
                  typer.secho(
                      f"✓ Stopped {target['label']} ({target['service']})",
                      fg=typer.colors.YELLOW,
                  )
              else:
                  for info in MODELS.values():
                      subprocess.run([SYSTEMCTL, "stop", info["service"]], check=False)
                  typer.secho("✓ Stopped all ashalliants daemons", fg=typer.colors.YELLOW)


          @app.command(name="status", help="Show active ashalliants daemon status.")
          def status_cmd():
              typer.echo("Ashalliants daemon status:")
              for key, info in MODELS.items():
                  res = subprocess.run(
                      [SYSTEMCTL, "is-active", "--quiet", info["service"]]
                  )
                  active = (res.returncode == 0)
                  state_str = (
                      typer.style("ACTIVE", fg=typer.colors.GREEN, bold=True)
                      if active
                      else typer.style("INACTIVE", fg=typer.colors.WHITE, dim=True)
                  )
                  typer.echo(
                      f"  [{state_str}] {key:<4} : {info['label']:<24} (port {info['port']}, {info['service']})"
                  )


          @app.command(name="list", help="List available models, ports, and aliases.")
          def list_cmd():
              typer.echo("Available Ashalliants models:")
              for key, info in MODELS.items():
                  res = subprocess.run(
                      [SYSTEMCTL, "is-active", "--quiet", info["service"]]
                  )
                  active = (res.returncode == 0)
                  state_str = (
                      typer.style("ACTIVE", fg=typer.colors.GREEN, bold=True)
                      if active
                      else typer.style("INACTIVE", fg=typer.colors.WHITE, dim=True)
                  )
                  aliases = ", ".join(info["aliases"])
                  typer.echo(
                      f"  • [{state_str}] {key} ({info['label']}) — port {info['port']}, service: {info['service']}"
                  )
                  typer.echo(f"    aliases: {aliases}")


          @app.callback(invoke_without_command=True)
          def main(
              ctx: typer.Context,
              switch_model: Optional[str] = typer.Option(
                  None,
                  "-s",
                  "--switch",
                  help="Switch active daemon to target model (shorthand for switch command).",
                  autocompletion=complete_models,
              ),
          ):
              if switch_model:
                  do_switch(switch_model)
                  raise typer.Exit()
              if ctx.invoked_subcommand is None:
                  typer.echo(ctx.get_help())
                  raise typer.Exit()


          if __name__ == "__main__":
              app(prog_name="ashalliant")
        '')
        .overrideAttrs (old: {
          buildCommand =
            old.buildCommand
            + ''
              mkdir -p $out/share/zsh/site-functions
              mkdir -p $out/share/bash-completion/completions
              mkdir -p $out/share/fish/vendor_completions.d
              echo "#compdef ashalliant" > $out/share/zsh/site-functions/_ashalliant
              _ASHALLIANT_COMPLETE=source_zsh $out/bin/ashalliant | ${pkgs.gnused}/bin/sed -n '/^_ashalliant_completion/,$p' >> $out/share/zsh/site-functions/_ashalliant
              _ASHALLIANT_COMPLETE=source_bash $out/bin/ashalliant > $out/share/bash-completion/completions/ashalliant
              _ASHALLIANT_COMPLETE=source_fish $out/bin/ashalliant > $out/share/fish/vendor_completions.d/ashalliant.fish
            '';
        });
    in {
      specialisation.homelab.configuration = {
        environment.systemPackages = [ashalliant];

        systemd.services.ashalliants-df2 = {
          description = "ashalliants ninfer-0.15.0 Qwen3.8-27B DFlash2";
          after = ["network-online.target"];
          wants = ["network-online.target"];

          # PRIMARY ENGINE (Qwen3.8-27B default on startup, autostarts on
          # the homelab spec). bonsai2 and ashalliants-35b declare reverse Conflicts.
          wantedBy = ["multi-user.target"];
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

        # On-demand Qwen3.6-35B-A3B daemon (port 8140, started via ashalliants-35b-up).
        # Mutually exclusive with ashalliants-df2 and bonsai2 via systemd Conflicts.
        systemd.services.ashalliants-35b = {
          description = "ashalliants ninfer-0.15.0 Qwen3.6-35B-A3B MTP3";
          after = ["network-online.target"];
          wants = ["network-online.target"];
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
