{den, ...}: {
  den.hosts.x86_64-linux.dell-latitude-E7270-H836QF2 = {
    users.ayin = {};
  };

  den.aspects.dell-latitude-E7270-H836QF2 = {
    includes = [
      den.aspects.apps.browsers.firefox
      den.aspects.apps.cli.p7zip
      den.aspects.apps.cli.ripgrep
      den.aspects.apps.cli.zoxide
      den.aspects.apps.file-managers.tfm
      den.aspects.apps.network.moonlight
      den.aspects.apps.network.tailscale
      den.aspects.apps.sysinfo.fastfetch
      den.aspects.apps.terminals.foot
      den.aspects.dev.gits.git
      den.aspects.system.bluetooth
      den.aspects.system.boot.systemd
      den.aspects.system.network.cloudflare-warp
      den.aspects.system.network.nftables
      den.aspects.system.network.resolved
      den.aspects.system.network.ssh
      den.aspects.system.nix
      den.aspects.system.nix.nh
      den.aspects.system.nix.nix-ld
      den.aspects.system.nix.nur
      den.aspects.system.power.power-profiles-daemon
      den.aspects.system.power.upower
      # den.aspects.system.secrets.agenix
      den.aspects.system.settings
      den.aspects.system.storage.udisks2
      den.aspects.system.swap.zram
      (den.aspects.desktop.compositors.dwl)
      den.aspects.desktop.auth.gnome-keyring
      den.aspects.desktop.auth.polkit
      den.aspects.desktop.shells.prompts.powerlevel10k
      den.aspects.desktop.shells.zsh
      den.aspects.desktop.theming.stylix
      (den.aspects.desktop.greeters.tuigreet {
        command = config: "${config.programs.dwl.package}/bin/dwl";
      })
    ];
  };
}
