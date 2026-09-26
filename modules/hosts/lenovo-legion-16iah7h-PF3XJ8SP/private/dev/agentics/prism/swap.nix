# llamacpp-prism-up / llamacpp-prism-down — lifecycle around the bonsai2
# prism llama-server (see ../prism/default.nix for the daemon).
#
# WHY THIS EXISTS (2026-09-20, restored 2026-09-25): both 27B daemons want
# the 3090 and cannot be resident together (bonsai 256K ctx ≈ 23.1 GiB;
# ollama 27B q4_K_M + KV ≈ 18 GiB; card has 24.5 GiB). Arbitration is
# manual and exclusive: `llamacpp-prism-up` = prism llama-server takes the
# 3090 (stops ollama); `llamacpp-prism-down` = back to ollama (stops
# bonsai2). mmap loads make switches fast (bonsai: ~6 s; ollama 27B:
# ~10-20 s).
#
# Idle offload is NATIVE now (2026-09-25): the fork's --sleep-idle-seconds
# 300 flag (see ../prism/default.nix) frees model+KV after 5 idle minutes
# — the old /metrics-polling watchdog idea was deleted before ever
# running: this build ships --metrics DISABLED by default (verified in
# llama-server --help), so there was no counter to poll.
{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    # HOMELAB-ONLY (2026-09-21 user request, 3090 specialisation pattern): the swap
    # helpers stop/start ollama + bonsai2 — both live only inside
    # specialisation.homelab.
    nixos = {
      pkgs,
      config,
      ...
    }: {
      specialisation.homelab.configuration = {
        environment.systemPackages = let
          llamacpp-prism-up = pkgs.writeShellScriptBin "llamacpp-prism-up" ''
            set -eu
            sysd=${config.systemd.package}/bin/systemctl
            $sysd stop ollama.service 2>/dev/null || true
            $sysd start bonsai2.service
            echo "bonsai2 (prism llama-server) up on the 3090; ollama stopped"
          '';

          llamacpp-prism-down = pkgs.writeShellScriptBin "llamacpp-prism-down" ''
            set -eu
            sysd=${config.systemd.package}/bin/systemctl
            $sysd stop bonsai2.service 2>/dev/null || true
            $sysd start ollama.service
            echo "ollama up on the 3090; bonsai2 stopped"
          '';
        in [
          llamacpp-prism-up
          llamacpp-prism-down
        ];
      }; # specialisation.homelab.configuration
    };
  };
}
