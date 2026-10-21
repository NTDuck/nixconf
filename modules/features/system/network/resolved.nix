{den, ...}: {
  den.aspects.system.network.resolved = {
    nixos = {
      services.resolved = {
        enable = true;

        # 2026-10-21: Opportunistic DoT upgrades public DNS queries (1.1.1.1, 8.8.8.8)
        # to TLS (port 853), preventing unencrypted UDP port 53 DNS poisoning while
        # preserving compatibility with local / Tailscale resolvers that lack TLS certificates.
        # Setting `Domains = ["~."]` routes un-scoped public queries to global DoT resolvers
        # rather than DHCP-assigned link DNS (e.g. 192.168.1.1) which poison Steam domains,
        # while preserving specific route-only domains like Tailscale's `~ts.net`.
        settings.Resolve = {
          DNSOverTLS = "opportunistic";
          Domains = ["~."];
        };
      };
    };
  };
}
