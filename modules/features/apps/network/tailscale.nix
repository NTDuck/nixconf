# Tailscale provides a WireGuard mesh network so Moonlight clients can reach this
# host off-LAN (dell laptop ↔ legion), complementing the LAN-only Sunshine setup.
# The user brings the node up interactively (`sudo tailscale up`) — no auth key
# is provisioned in secrets.
{den, ...}: {
  den.aspects.apps.network.tailscale = {
    nixos = {
      services.tailscale = {
        enable = true;
        openFirewall = true;
        useRoutingFeatures = "both";
      };
    };
  };
}
