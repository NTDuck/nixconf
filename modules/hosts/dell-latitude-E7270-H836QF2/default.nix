{den, ...}: {
  den.hosts.x86_64-linux.dell-latitude-E7270-H836QF2 = {
    users.ayin = {};
  };

  den.aspects.dell-latitude-E7270-H836QF2 = {
    includes = [
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
      den.aspects.apps.terminals.st
      den.aspects.apps.editors.obsidian
      # JetBrains IDE (proprietary `idea`, not the dead idea-oss).
      den.aspects.apps.editors.intellij
      den.aspects.apps.editors.zed-editor
      # omp + ollama-over-tailscale (models.yml points at legion).
      den.aspects.dev.agentics.harnesses.codev
      den.aspects.dev.agentics.harnesses.oh-my-pi
      den.aspects.dev.toolchains.sql.tabularis
      den.aspects.dev.toolchains.java-kotlin
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
      # spectrwm (X11) replaces labwc (Wayland) — 2026-09-22. The
      # spectrwm aspect pulls in its own session furniture (clipmenu,
      # fcitx5, dmenu, lemonbar, dunst, portals.xdg) so the host
      # doesn't list them individually.
      (den.aspects.desktop.compositors.spectrwm)
      den.aspects.desktop.auth.gnome-keyring
      # slock + xss-lock (X11 idle chain) — replaces the retired
      # swaylock + swayidle chain. PAM service + xss-lock daemon live
      # here; the always-on aspect handles logind-side belt-and-
      # suspenders.
      den.aspects.desktop.auth.slock
      # Always-on session (xss-lock alive but logind idle/lid keys
      # ignored; sleep targets force-disabled). Replaces the retired
      # desktop.auth.lockscreen (swaylock + PAM + idle chain) per the
      # 2026-09-21 "never dim/sleep when idle" request.
      den.aspects.desktop.auth.always-on
      den.aspects.desktop.auth.polkit
      den.aspects.desktop.shells.prompts.powerlevel10k
      den.aspects.desktop.shells.zsh
      den.aspects.desktop.theming.stylix
      (den.aspects.desktop.greeters.tuigreet {
        # HM's xsession.windowManager.spectrwm adds spectrwm to
        # home.packages, so the binary is in the user's PATH after
        # activation. tuigreet runs the command as the logged-in user,
        # so PATH resolution works.
        command = _config: "spectrwm";
      })
    ];
  };
}
