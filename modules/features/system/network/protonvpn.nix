# Proton VPN (official v4 GUI + CLI companion). No NixOS service module
# exists in the pinned nixpkgs; the GUI drives NetworkManager over D-Bus
# (python-proton-vpn-network-manager-wireguard), so NM must be on and the
# user in `networkmanager` (both already true on hosts including this).
# GNOME keyring (desktop.auth.gnome-keyring) provides the Secret Service
# the app needs for login-token storage. checkReversePath "loose" keeps
# WireGuard tunnel traffic alive under strict rp_filter (discourse.nixos.org
# /t/how-to-configure-and-use-proton-vpn-on-nixos/65837).
{den, ...}: {
  den.aspects.system.network.protonvpn = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.proton-vpn
        pkgs.proton-vpn-cli
      ];

      networking.firewall.checkReversePath = "loose";
    };
  };
}
