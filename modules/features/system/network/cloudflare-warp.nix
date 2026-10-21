{den, ...}: {
  den.aspects.system.network.cloudflare-warp = {
    nixos = {pkgs, ...}: {
      services.cloudflare-warp = {
        enable = true;
        package = pkgs.unstable.cloudflare-warp;

        openFirewall = true;
      };

      # 2026-10-21: warp-svc hardcodes `/usr/sbin/nft` in its Linux firewall
      # implementation (`firewall/src/linux/mod.rs`). On NixOS, `/usr/sbin/nft`
      # does not exist, causing `warp-svc` to fail with:
      #   "Failed to start firewall: Os { code: 2, kind: NotFound }"
      # Symlink `/usr/sbin/nft` via tmpfiles and preStart so the daemon can start
      # the firewall ruleset without error.
      systemd.tmpfiles.rules = [
        "L+ /usr/sbin/nft - - - - ${pkgs.nftables}/bin/nft"
        "L+ /usr/sbin/iptables - - - - ${pkgs.iptables}/bin/iptables"
      ];

      systemd.services.cloudflare-warp = {
        path = [
          pkgs.iptables
          pkgs.nftables
          pkgs.iproute2
        ];
        preStart = ''
          mkdir -p /usr/sbin
          ln -sf ${pkgs.nftables}/bin/nft /usr/sbin/nft
          ln -sf ${pkgs.iptables}/bin/iptables /usr/sbin/iptables
        '';
      };

      # 2026-10-21: Auto-connect WARP once the daemon is active.
      # Bypasses ISP-level DNS poisoning and SNI-based DPI (e.g. Steam in Vietnam).
      # Retries connection until the daemon's IPC socket is created.
      systemd.services.cloudflare-warp-autoconnect = {
        description = "Cloudflare WARP Auto-connect";
        after = ["cloudflare-warp.service"];
        wants = ["cloudflare-warp.service"];
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "warp-autoconnect" ''
            for i in $(seq 1 30); do
              if [ -S /run/cloudflare-warp/warp_service ] || [ -S /var/run/cloudflare-warp/warp_service ]; then
                if ${pkgs.unstable.cloudflare-warp}/bin/warp-cli --accept-tos connect; then
                  exit 0
                fi
              fi
              sleep 1
            done
            ${pkgs.unstable.cloudflare-warp}/bin/warp-cli --accept-tos connect
          '';
          RemainAfterExit = true;
        };
      };
    };
  };
}
