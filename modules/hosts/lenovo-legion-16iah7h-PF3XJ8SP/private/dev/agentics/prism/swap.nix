# ashalliants-down / llamacpp-prism-up / llamacpp-prism-down —
# manual arbitration for the three 3090 daemons (see ../ashalliants.nix,
# ../prism/default.nix, ../ollama.nix).
#
# WHY THIS EXISTS (2026-09-20, restored 2026-09-25): all 27B daemons
# want the 3090 and cannot be resident together (ashalliants 23.3 GiB
# peak; bonsai 256K ctx ≈ 23.1 GiB; ollama 27B q4_K_M + KV ≈ 18 GiB;
# card has 24.5 GiB). ashalliants is THE resident engine on the homelab
# spec (autostarts, conflicts both others). ollama + bonsai2 are
# on-demand: any `systemctl start` of one natively stops the others via
# the symmetric Conflicts declarations in the units — the scripts only
# add sugar (start the replacement after the stop settles). Boot-time
# arbitration is native: ashalliants' autostart beats ollama's on-demand
# nothing (ollama's WantedBy is empty, ../ollama.nix).
#
# SCRIPTS (2026-10-10 ninfer-061 removal — ashalliants main-engine swap):
#   ashalliants-down    = ollama takes over (stops ashalliants; ollama
#                         loads lazily on first request, ~10-20 s cold).
#   llamacpp-prism-up   = bonsai2 takes over (stops ashalliants + ollama
#                         natively via Conflicts).
#   llamacpp-prism-down = back to ashalliants (stops bonsai2; the unit
#                         autorestarts only on failure — start it here).
#
# Idle offload: NATIVE on all sides — ollama OLLAMA_KEEP_ALIVE=5m,
# bonsai2 --sleep-idle-seconds 300; ashalliants is the evergreen
# resident (Restart=on-failure recovers it if a gaming session's CUDA
# OOM races it).
{
  den,
  ...
}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    # HOMELAB-ONLY (2026-09-21 user request, 3090 specialisation pattern):
    # the swap helpers drive units that live only inside
    # specialisation.homelab.
    #
    # 2026-10-10: ninfer-061 (:8081) REMOVED as primary (ashalliants-df2
    # is the resident engine, ../ashalliants.nix). Up/down helpers now
    # arbitrate ollama vs ashalliants vs bonsai2 only.
    nixos = {
      pkgs,
      config,
      ...
    }: {
      specialisation.homelab.configuration = {
        environment.systemPackages = let
          sysd = "${config.systemd.package}/bin/systemctl";
        in [
          (pkgs.writeShellScriptBin "ashalliants-down" ''
            set -eu
            ${sysd} stop ashalliants-df2.service
            ${sysd} start ollama.service
            echo "ollama up on the 3090; ashalliants stopped"
          '')

          (pkgs.writeShellScriptBin "llamacpp-prism-up" ''
            set -eu
            ${sysd} start bonsai2.service
            echo "bonsai2 (prism llama-server) up on the 3090; ashalliants + ollama stopped natively"
          '')

          (pkgs.writeShellScriptBin "llamacpp-prism-down" ''
            set -eu
            ${sysd} stop bonsai2.service
            ${sysd} start ashalliants-df2.service
            echo "ashalliants back on the 3090; bonsai2 stopped"
          '')
        ];
      }; # specialisation.homelab.configuration
    };
  };
}
