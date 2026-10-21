{den, ...}: {
  den.aspects.system.network.cloudflare-warp = {
    nixos = {pkgs, ...}: {
      services.cloudflare-warp = {
        enable = true;
        package = pkgs.unstable.cloudflare-warp;

        openFirewall = true;
      };

      # 2026-10-21: warp-svc's firewall helper shells out to iptables/nft
      # to install split-tunnel rules. The NixOS unit's explicit
      # Environment="PATH=..." omits both, so connect fails with
      # "Failed to start firewall: No such file or directory"
      # (journalctl -u cloudflare-warp.service). `systemd.services.X.path`
      # prepends to the unit's PATH.
      systemd.services.cloudflare-warp.path = [
        pkgs.iptables
        pkgs.nftables
      ];

      # 2026-10-21: Auto-connect WARP once the daemon is active.
      # Bypasses ISP-level DNS poisoning and SNI-based DPI (e.g. Steam in Vietnam).
      systemd.services.cloudflare-warp-autoconnect = {
        description = "Cloudflare WARP Auto-connect";
        after = ["cloudflare-warp.service"];
        wants = ["cloudflare-warp.service"];
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.unstable.cloudflare-warp}/bin/warp-cli --accept-tos connect";
          RemainAfterExit = true;
        };
      };
    };
  };
}
