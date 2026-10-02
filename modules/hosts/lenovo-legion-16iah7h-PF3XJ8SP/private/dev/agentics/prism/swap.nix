# q27-up / q27-down / llamacpp-prism-up / llamacpp-prism-down —
# manual arbitration for the three 3090 daemons (see ../q27.nix,
# ../prism/default.nix, ../ollama.nix).
#
# WHY THIS EXISTS (2026-09-20, restored 2026-09-25): all three 27B daemons
# want the 3090 and cannot be resident together (q27 Bonsai-2 T3-MTP pack
# 6.49 GiB weights + 2.3 GiB stack + 9.53 GiB paged KV ≈ 18.3 GiB + arena
# ≈ 19.5 GiB; bonsai 256K ctx ≈ 23.1 GiB; ollama 27B q4_K_M + KV ≈ 18 GiB;
# card has 24.5 GiB). q27 is THE resident engine on the homelab spec
# (2026-10-03 switch from ninfer — the 2026-10-02 bench: 95-98 t/s short
# decode vs 62, 3+ concurrent 64K lanes vs 1; see ../q27.nix). ollama +
# bonsai2 are on-demand: any `systemctl start` of one natively stops the
# others via the symmetric Conflicts declarations in the four units — the
# scripts only add sugar (start the replacement after the stop settles).
# Boot-time arbitration is native: q27's autostart beats ollama's
# on-demand nothing (ollama's WantedBy is empty, ../ollama.nix).
#
# SCRIPTS (2026-10-03 q27 main-engine switch, was ninfer 2026-09-29):
#   q27-up           = q27 takes the 3090 (stops ollama + bonsai2) —
#                      usually redundant: the unit autostarts on the
#                      homelab spec.
#   q27-down         = ollama takes over (stops q27; ollama loads
#                      lazily on first request, ~10-20 s cold).
#   llamacpp-prism-up    = bonsai2 takes over (stops q27 + ollama).
#   llamacpp-prism-down  = back to q27 (stops bonsai2) — the resident
#                      default, not ollama as before the switch.
#
# Idle offload: NATIVE on the on-demand sides — ollama
# OLLAMA_KEEP_ALIVE=5m, bonsai2 --sleep-idle-seconds 300; q27 is the
# evergreen resident (Restart=on-failure recovers it if a gaming
# session's CUDA OOM races it).
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
          (pkgs.writeShellScriptBin "q27-up" ''
            set -eu
            ${sysd} start q27-serve.service
            echo "q27 up on the 3090 (ollama + bonsai2 stopped natively)"
          '')

          (pkgs.writeShellScriptBin "q27-down" ''
            set -eu
            ${sysd} stop q27-serve.service
            ${sysd} start ollama.service
            echo "ollama up on the 3090; q27 stopped"
          '')

          (pkgs.writeShellScriptBin "llamacpp-prism-up" ''
            set -eu
            ${sysd} start bonsai2.service
            echo "bonsai2 (prism llama-server) up on the 3090; q27 + ollama stopped natively"
          '')

          (pkgs.writeShellScriptBin "llamacpp-prism-down" ''
            set -eu
            ${sysd} stop bonsai2.service
            ${sysd} start q27-serve.service
            echo "q27 up on the 3090; bonsai2 stopped"
          '')
        ];
      }; # specialisation.homelab.configuration
    };
  };
}
