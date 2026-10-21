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
    };
  };
}
