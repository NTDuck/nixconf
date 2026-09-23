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
      # The dwm session wrapper's feh paints config.stylix.image.
      # mkForce: the shared stylix aspect also defines image (mkDefault);
      # two plain definitions conflict at eval.
      ({
        nixos.stylix.image = lib.mkForce "${inputs.self}/assets/wallpapers/isle-of-the-dead.jpg";
      })
      # DELL browser stack (2026-09-23): falkon (KDE QtWebEngine).
      den.aspects.apps.browsers.falkon
      den.aspects.apps.btop
      den.aspects.apps.p7zip
      den.aspects.apps.ripgrep
      den.aspects.apps.zoxide
      den.aspects.apps.file-managers.pcmanfm
      den.aspects.apps.file-managers.tfm
      den.aspects.remote-desktop.moonlight
      den.aspects.system.network.tailscale
      den.aspects.apps.fastfetch
      # DELL terminal stack (2026-09-23): st (suckless, X11 — patched
      # with the kanagawa-dragon palette in the st aspect).
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
      # dwm (X11) — 2026-09-23 cutover after spectrwm froze the whole
      # screen on two independent boots (gen 19 parser-verified, gen 22
      # zero-exception conf that survived the same binds under Xvfb).
      # Same stack around it: native bar (dwm's), feh, dmenu, dunst,
      # st, pcmanfm, i3lock+xss-lock. The dwm aspect pulls in its own
      # session furniture (clipmenu, fcitx5, dmenu, dunst,
      # i3lock/xss-lock, portals.xdg) so the host doesn't list them
      # individually.
      (den.aspects.desktop.compositors.dwm)
      den.aspects.desktop.auth.gnome-keyring
      # Always-on session (logind lid/suspend keys ignored; sleep
      # targets force-disabled). The idle/lock chain is handled by the
      # i3lock aspect (manual W-Ctrl-l + suspend lock; the X screensaver
      # timer and DPMS are disabled in the dwm session wrapper per the
      # 2026-09-21 "never dim/sleep when idle" request).
      den.aspects.desktop.auth.always-on
      den.aspects.desktop.auth.polkit
      den.aspects.desktop.shells.prompts.powerlevel10k
      den.aspects.desktop.shells.zsh
      den.aspects.desktop.theming.stylix
      # X11 session start (2026-09-22): greetd+tuigreet does NOT start an
      # X server — verified against tuigreet 0.11.1 source (ipc.rs
      # wrap_session_command: the `--cmd` path runs the command directly;
      # xsession_wrapper only applies to registered xsessions entries).
      # greetd's StartSession execs cmd[0] as a SINGLE argv path, so the
      # command must be one binary. This wrapper (started as the
      # logged-in user on tty1) runs startx, which:
      #   - starts Xorg on the session's VT (vt1, non-root via logind),
      #   - writes serverauth to ~/.serverauth.$$ and adds the cookie to
      #     ~/.Xauthority (xrandr/udev mirror script read it from there),
      #   - execs HM's ~/.xsession as the X client — which activates
      #     hm-graphical-session.target (xss-lock, dunst, clipmenu) and
      #     execs spectrwm.
      ({
        nixos = {pkgs, ...}: {
          environment.systemPackages = let
            x11Session = pkgs.writeShellScriptBin "dell-x11-session" ''
              # startx's server args: after `--` the first token is the
              # SERVER COMMAND, so `-- vt1` would exec a binary named
              # "vt1". No server args — startx uses its baked Xorg path
              # and auto-detects the current VT (the greetd session's
              # tty1), adding `vt1 -keeptty` itself.
              #
              # PATH: greetd hands the session a minimal environment, but
              # startx invokes `xinit` and `xauth` BY NAME. Prepend the
              # xinit package bin (carries both) so the wrapper never
              # depends on the session's PATH — 2026-09-22 "xinit not
              # present" failure from exactly this.
              PATH="${pkgs.xorg.xinit}/bin:${pkgs.xorg.xauth}/bin:$PATH"
              export PATH
              exec ${pkgs.xorg.xinit}/bin/startx "$HOME"/.xsession
            '';
          in [x11Session];
        };
      })
      (den.aspects.desktop.greeters.tuigreet {
        command = _config: "dell-x11-session";
      })
    ];
  };
}
