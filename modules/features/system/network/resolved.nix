{den, ...}: {
  den.aspects.system.network.resolved = {
    nixos = {
      services.resolved = {
        enable = true;

        # 2026-10-21: Opportunistic DoT upgrades public DNS queries (1.1.1.1, 8.8.8.8)
        # to TLS (port 853), preventing unencrypted UDP port 53 DNS poisoning while
        # preserving compatibility with local / Tailscale resolvers that lack TLS certificates.
        # Note: Do NOT set `Domains = ["~."]` globally in resolved.conf; doing so breaks
        # Cloudflare WARP's internal connectivity checks (`connectivity-check.warp-svc.`),
        # preventing warp-svc from completing its handshake. WARP dynamically configures
        # routing domain `~.` on its own `CloudflareWARP` interface once connected.
        settings.Resolve = {
          DNSOverTLS = "opportunistic";
        };
      };
    };
  };
}
