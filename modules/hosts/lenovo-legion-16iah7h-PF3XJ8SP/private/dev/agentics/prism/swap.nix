# llamacpp-prism-up / llamacpp-prism-down — manual arbitration for the
# two 3090 daemons (see ../ninfer.nix, ../default.nix).
#
# WHY THIS EXISTS (2026-09-20, restored 2026-09-25): the 27B daemons
# want the 3090 and cannot be resident together (ashalliants 23.3 GiB
# peak; bonsai 256K ctx ≈ 23.1 GiB; card has 24.5 GiB). ashalliants is
# THE resident engine on the homelab spec (autostarts, conflicts
# bonsai2). bonsai2 is on-demand: any `systemctl start` of it natively
# stops ashalliants via the symmetric Conflicts declarations in the
# units — the scripts only add sugar (start the replacement after the
# stop settles). Boot-time arbitration is native: ashalliants'
# autostart beats bonsai2's on-demand nothing (bonsai2's WantedBy is
# empty, ../default.nix).
#
# SCRIPTS (2026-10-12 ollama removal — ashalliants is the sole local
# engine, ollama is gone):
#   llamacpp-prism-up   = bonsai2 takes over (stops ashalliants
#                         natively via Conflicts).
#   llamacpp-prism-down = back to ashalliants (stops bonsai2; the unit
#                         autorestarts only on failure — start it here).
#
# Idle offload: NATIVE on both sides — bonsai2 --sleep-idle-seconds
# 300; ashalliants is the evergreen resident (Restart=on-failure
# recovers it if a gaming session's CUDA OOM races it).
{
  ...
}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    # HOMELAB-ONLY (2026-09-21 user request, 3090 specialisation pattern):
    # the swap helpers drive units that live only inside
    # specialisation.homelab.
    #
    # 2026-10-12: ollama removed entirely (user request). The previous
    # `ashalliants-down` helper (which stopped ashalliants and started
    # ollama) is gone — there is no replacement engine to start. To
    # free the 3090 from ashalliants, just `systemctl stop
    # ashalliants-df2.service` directly.
    nixos = {
      pkgs,
      config,
      ...
    }: {
      specialisation.homelab.configuration = {
        environment.systemPackages = let
          sysd = "${config.systemd.package}/bin/systemctl";
        in [
          (pkgs.writeShellScriptBin "llamacpp-prism-up" ''
            set -eu
            ${sysd} start bonsai2.service
            echo "bonsai2 (prism llama-server) up on the 3090; ashalliants stopped natively"
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
