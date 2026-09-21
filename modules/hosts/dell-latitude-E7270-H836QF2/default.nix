{den, ...}: {
  den.hosts.x86_64-linux.dell-latitude-E7270-H836QF2 = {
    users.ayin = {};
  };

  den.aspects.dell-latitude-E7270-H836QF2 = {
    includes = [
      den.aspects.apps.browsers.firefox
      den.aspects.apps.p7zip
      den.aspects.apps.ripgrep
      den.aspects.apps.zoxide
      den.aspects.apps.file-managers.tfm
      den.aspects.remote-desktop.moonlight
      den.aspects.system.network.tailscale
      den.aspects.apps.fastfetch
      den.aspects.apps.terminals.foot
      den.aspects.apps.editors.obsidian
      # JetBrains IDE (proprietary `idea`, not the dead idea-oss).
      den.aspects.apps.editors.intellij
      # omp + ollama-over-tailscale (models.yml points at legion).
      den.aspects.dev.agentics.harnesses.oh-my-pi
      den.aspects.dev.gits.git
      den.aspects.dev.gits.gh
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
      (den.aspects.desktop.compositors.labwc)
      den.aspects.desktop.auth.gnome-keyring
      # Always-on session (swayidle alive but zero timeouts; logind lid/
      # suspend keys ignored; sleep targets force-disabled). Replaces
      # desktop.auth.lockscreen (swaylock + PAM + idle chain) per the
      # 2026-09-21 "never dim/sleep when idle" request — the two aspects
      # both write services.swayidle and would collide; list options
      # concatenate across aspects, so include order alone cannot disable
      # the lockscreen chain.
      den.aspects.desktop.auth.always-on
      den.aspects.desktop.auth.polkit
      den.aspects.desktop.shells.prompts.powerlevel10k
      den.aspects.desktop.shells.zsh
      den.aspects.desktop.theming.stylix
      (den.aspects.desktop.greeters.tuigreet {
        command = config: "${config.programs.labwc.package}/bin/labwc";
      })
    ];
  };
}
