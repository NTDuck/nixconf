# ninfer-up / ninfer-down / llamacpp-prism-up / llamacpp-prism-down —
# manual arbitration for the three 3090 daemons (see ../ninfer.nix,
# ../prism/default.nix, ../ollama.nix).
#
# WHY THIS EXISTS (2026-09-20, restored 2026-09-25): all three 27B daemons
# want the 3090 and cannot be resident together (ninfer 19.6 GiB peak;
# bonsai 256K ctx ≈ 23.1 GiB; ollama 27B q4_K_M + KV ≈ 18 GiB; card has
# 24.5 GiB). ninfer is THE resident engine on the homelab spec (autostarts,
# conflicts both others). ollama + bonsai2 are on-demand: any
# `systemctl start` of one natively stops the others via the symmetric
# Conflicts declarations in the three units — the scripts only add
# sugar (start the replacement after the stop settles). Boot-time
# arbitration is native: ninfer's autostart beats ollama's on-demand
# nothing (ollama's WantedBy is empty, ../ollama.nix).
#
# SCRIPTS (2026-09-29 ninfer main-engine switch):
#   ninfer-up        = ninfer takes the 3090 (stops ollama + bonsai2) —
#                      usually redundant: the unit autostarts on the
#                      homelab spec.
#   ninfer-down      = ollama takes over (stops ninfer; ollama loads
#                      lazily on first request, ~10-20 s cold).
#   llamacpp-prism-up    = bonsai2 takes over (stops ninfer + ollama).
#   llamacpp-prism-down  = back to ninfer (stops bonsai2) — the resident
#                      default, not ollama as before the switch.
#
# Idle offload: NATIVE on all sides — ollama OLLAMA_KEEP_ALIVE=5m,
# bonsai2 --sleep-idle-seconds 300; ninfer is the evergreen resident
# (Restart=on-failure recovers it if a gaming session's CUDA OOM races
# it).
{
  den,
  ...
}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    # HOMELAB-ONLY (2026-09-21 user request, 3090 specialisation pattern):
    # the swap helpers drive units that live only inside
    # specialisation.homelab.
    nixos = {
      pkgs,
      config,
      ...
    }: {
      specialisation.homelab.configuration = {
        environment.systemPackages = let
          sysd = "${config.systemd.package}/bin/systemctl";
        in [
          (pkgs.writeShellScriptBin "ninfer-up" ''
            set -eu
            ${sysd} start ninfer-serve.service
            echo "ninfer up on the 3090 (ollama + bonsai2 stopped natively)"
          '')

          (pkgs.writeShellScriptBin "ninfer-down" ''
            set -eu
            ${sysd} stop ninfer-serve.service
            ${sysd} start ollama.service
            echo "ollama up on the 3090; ninfer stopped"
          '')

          (pkgs.writeShellScriptBin "llamacpp-prism-up" ''
            set -eu
            ${sysd} start bonsai2.service
            echo "bonsai2 (prism llama-server) up on the 3090; ninfer + ollama stopped natively"
          '')

          (pkgs.writeShellScriptBin "llamacpp-prism-down" ''
            set -eu
            ${sysd} stop bonsai2.service
            ${sysd} start ninfer-serve.service
            echo "ninfer up on the 3090; bonsai2 stopped"
          '')
        ];
      }; # specialisation.homelab.configuration
    };
  };
}
