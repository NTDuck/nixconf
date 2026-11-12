{den, ...}: {
  den.aspects.system.settings.networking = {
    includes = [
      den.aspects.system.network.resolved
    ];

    nixos = {lib, ...}: {
      networking = {
        networkmanager = {
          enable = true;
          # 2026-10-21: Use `lib.mkForce "none"` so NetworkManager does not forward
          # unencrypted DHCP DNS servers (192.168.1.1, which poison Steam domains
          # in Vietnam) to systemd-resolved. systemd-resolved manages DNS directly
          # via `services.resolved` with opportunistic DoT on 8.8.8.8 / 1.1.1.1,
          # while Tailscale and Cloudflare WARP register their link DNS directly over DBus.
          dns = lib.mkForce "none";
        };
        nameservers = ["8.8.8.8" "1.1.1.1"];
      };
      # 2026-11-12: `dns = "none"` stops NM writing resolv.conf, but NM STILL
      # programs per-link DHCP DNS into systemd-resolved over DBus (observed on
      # enp49s0: 192.168.1.1 with DefaultRoute=yes). warp-svc's dns_enforcer
      # snapshots those ISP servers and restores them on every connect cycle,
      # so Steam domains got ISP-poisoned (127.0.0.1 sinkhole) and warp's
      # connectivity check hit the same poisoned resolver ->
      # FailedConnectivityCheck(DNSLookupFailed) loop, Steam unable to connect.
      # Fix: ipv4/ipv6.ignore-auto-dns=yes on the ethernet profile (NM keyfile
      # "/etc/NetworkManager/system-connections/Wired connection 1.nmconnection",
      # applied live 2026-11-12 via nmcli and persisted there). NOT
      # networking.networkmanager.connectionConfig — that maps to NM's
      # [connection] section, which rejects per-ip-family keys.
    };
  };
}
