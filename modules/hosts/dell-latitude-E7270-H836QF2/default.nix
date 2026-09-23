{
  den,
  inputs,
  lib,
  ...
}: {
  den.hosts.x86_64-linux.dell-latitude-E7270-H836QF2 = {
    users.ayin = {};
  };

  den.aspects.dell-latitude-E7270-H836QF2 = {
    includes = [
      # Dell-specific wallpaper (2026-09-22): the shared stylix aspect
      # defaults to 230826-2.png, which noctalia (legion) consumes as its
      # fallback too — override here instead of flipping the shared pin.
      # (Was the spectrwm feh autostart source; labwc's stylix usage
      # reads the same option.)
      # mkForce: the shared stylix aspect also defines image (mkDefault);
      # two plain definitions conflict at eval.
      ({
        nixos.stylix.image = lib.mkForce "${inputs.self}/assets/wallpapers/isle-of-the-dead.jpg";
      })
      den.aspects.apps.browsers.firefox
      den.aspects.apps.btop
      den.aspects.apps.p7zip
      den.aspects.apps.ripgrep
      den.aspects.apps.zoxide
      den.aspects.apps.file-managers.pcmanfm
      den.aspects.apps.file-managers.tfm
      den.aspects.remote-desktop.moonlight
      den.aspects.system.network.tailscale
      den.aspects.apps.fastfetch
      den.aspects.apps.terminals.foot
      den.aspects.apps.editors.obsidian
      # JetBrains IDE (proprietary `idea`, not the dead idea-oss).
      den.aspects.apps.editors.intellij
      den.aspects.apps.editors.zed-editor
      # omp + ollama-over-tailscale (models.yml points at legion).
      den.aspects.dev.agentics.harnesses.codev
      den.aspects.dev.agentics.harnesses.oh-my-pi
      den.aspects.dev.toolchains.sql.tabularis
      den.aspects.dev.toolchains.java-kotlin
      den.aspects.dev.toolchains.javascript-typescript
      den.aspects.dev.postman
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
      # REVERT (2026-09-23): spectrwm -> labwc. spectrwm froze the whole
      # screen on the gen-19 boot even with a fully-validated conf, so
      # DELL returns to the labwc (Wayland) session. The labwc aspect
      # pulls in its own session furniture (cliphist, fcitx5, bemenu,
      # yambar, mako, portals.xdg).
      (den.aspects.desktop.compositors.labwc)
      den.aspects.desktop.auth.gnome-keyring
      # Always-on session (swayidle alive but zero timeouts; logind lid/
      # suspend keys ignored; sleep targets force-disabled). Replaces
      # the retired desktop.auth.lockscreen per the 2026-09-21 "never
      # dim/sleep when idle" request.
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
