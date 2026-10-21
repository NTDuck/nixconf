{den, ...}: {
  den.aspects.system.network.resolved = {
    nixos = {
      services.resolved = {
        enable = true;

        # 2026-10-21: Opportunistic DoT upgrades public DNS queries (1.1.1.1, 8.8.8.8)
        # to TLS (port 853), preventing unencrypted UDP port 53 DNS poisoning while
        # preserving compatibility with local / Tailscale resolvers that lack TLS certificates.
        settings.Resolve = {
          DNSOverTLS = "opportunistic";
        };
      };
    };
  };
}
