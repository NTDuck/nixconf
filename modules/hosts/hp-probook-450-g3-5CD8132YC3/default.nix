# HP ProBook 450 G3 headless worker host (2026-11-01):
# Renamed from placeholder xxxx to hardware serial 5CD8132YC3 (scanned via dmidecode).
# No GUI/WM, lid stays closed with battery connected, connects to legion over
# SSH & Tailscale mesh, terminal utilities only.
{
  den,
  ...
}: {
  den.hosts.x86_64-linux.hp-probook-450-g3-5CD8132YC3 = {
    users.ayin = {};
  };
  den.aspects.hp-probook-450-g3-5CD8132YC3 = {
    includes = [
      # Remote connectivity: SSH server + Tailscale mesh network
      # to connect seamlessly to legion and off-LAN nodes.
      den.aspects.system.network.ssh
      den.aspects.system.network.tailscale
      den.aspects.system.network.resolved

      # Terminal utilities
      den.aspects.apps.btop
      den.aspects.apps.fastfetch
      den.aspects.apps.jq
      den.aspects.apps.p7zip
      den.aspects.apps.pciutils
      den.aspects.apps.ripgrep
      den.aspects.apps.tmux
      den.aspects.apps.zoxide
      den.aspects.apps.editors.helix
      den.aspects.dev

      # Shell & prompt
      den.aspects.desktop.shells.zsh
      den.aspects.desktop.shells.prompts.starship

      # System base
      den.aspects.system.boot.systemd
      den.aspects.system.nix
      den.aspects.system.nix.lix
      den.aspects.system.settings
      den.aspects.system.storage.fstrim
      den.aspects.system.swap.zram
    ];
  };
}
