# Tailscale provides a WireGuard mesh network so Moonlight clients can reach this
# host off-LAN (dell laptop ↔ legion), complementing the LAN-only Sunshine setup.
# The user brings the node up interactively (`sudo tailscale up`) — no auth key
# is provisioned in secrets.
{den, ...}: {
  den.aspects.system.network.tailscale = {
    nixos = {pkgs, ...}: {
      services.tailscale = {
        enable = true;
        openFirewall = true;
        useRoutingFeatures = "both";
      };

      # `sudo tailscale up` blocks with no output on a login-needed node:
      # tailscale tries xdg-open with the auth URL, but sudo strips BROWSER
      # and the TTY session has no desktop opener, so it hangs silently.
      # Keeping the user's BROWSER through sudo (set to the no-op `true` in
      # ayin's home) makes xdg-open exit 0 instantly and tailscale falls
      # through to printing the URL on the terminal (2026-09-17, DELL).
      security.sudo.extraConfig = ''
        Defaults env_keep += "BROWSER"
      '';
    };
  };
}
