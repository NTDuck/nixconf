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
      # DELL browser (2026-09-24): firefox replaces falkon (parity with legion).
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
      # DELL terminal stack (2026-09-24): urxvt (rxvt-unicode, stylix
      # palette via xresources — replaced the patched st).
      den.aspects.apps.terminals.urxvt
      den.aspects.apps.editors.obsidian
      # JetBrains IDE (proprietary `idea`, not the dead idea-oss).
      den.aspects.apps.editors.intellij
      den.aspects.apps.editors.zed-editor
      # omp + ollama-over-tailscale (models.yml points at legion).
      den.aspects.dev.agentics.harnesses.codev
      den.aspects.dev.agentics.harnesses.oh-my-pi
      # CodeGraph CLI (repo indexer used by the coding agents).
      den.aspects.dev.agentics.codegraph
      den.aspects.dev.toolchains.sql.tabularis
      den.aspects.dev.toolchains.java-kotlin
      den.aspects.dev.toolchains.javascript-typescript
      den.aspects.dev.toolchains.nix
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
      # spectrwm (X11) — reinstated 2026-09-24 after one day on dwm.
      # The two freeze boots are diagnosed as spectrwm's libswmhack
      # spawn path (LD_PRELOAD injection into every program[] child),
      # fixed with spawn_flags = "nospawnws" in the spectrwm aspect.
      # The spectrwm aspect pulls in its own session furniture
      # (clipmenu, fcitx5, dmenu, dunst, i3lock/xss-lock, portals.xdg)
      # so the host doesn't list them individually.
      den.aspects.desktop.compositors.spectrwm
      # keyd (2026-09-24): legion-parity input remap (rightalt nav layer,
      # numlock LED sync timer). The spectrwm aspect relies on keyd-level
      # XKB handling for repeat rate/delay instead of WM settings.
      den.aspects.desktop.input.keyd
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
      # X11 session start (2026-09-22, root cause corrected 2026-09-24):
      # greetd+tuigreet does NOT start an X server — verified against
      # tuigreet 0.11.1 source (ipc.rs wrap_session_command: the `--cmd`
      # path runs the command directly; xsession_wrapper only applies to
      # registered xsessions entries). greetd's StartSession execs cmd[0]
      # as a SINGLE argv path, so the command must be one binary. This
      # wrapper (started as the logged-in user on tty1) runs startx, which:
      #   - starts Xorg on the session's VT (vt1, non-root via logind),
      #   - writes serverauth to ~/.serverauth.$$ and adds the cookie to
      #     ~/.Xauthority (xrandr/udev mirror script read it from there),
      #   - execs HM's ~/.xsession as the X client — which activates
      #     hm-graphical-session.target (xss-lock, dunst, clipmenu) and
      #     execs spectrwm.
      #
      # FREEZE ROOT CAUSE (2026-09-24): xinit's startx bakes the RAW
      # xorgserver as its default server (startx line 19: xserver =
      # "...xorg-server-<ver>/bin/X"), whose ModulePath contains ONLY
      # inputtest_drv — no libinput, no evdev. Xorg therefore started with
      # ZERO input drivers: wallpaper + bar painted (the WM was never the
      # problem) but every keystroke/mouse event was silently dropped —
      # the "freeze on W-Return/W-d". Proof: Xorg.0.log (spectrwm gen 24)
      # AND Xorg.0.log.old (dwm gen 23) show identical
      # `Failed to load module "libinput"` lines for every input device,
      # and the "file not found" flash at tuigreet login was Xorg's stderr
      # (Open ACPI failed /var/run/acpid.socket: No such file or directory
      # + the libinput EE lines) printed to vt1 before X took over. The
      # earlier libswmhack "spawn deadlock" theory (nospawnws, f21ed08) is
      # FALSIFIED: gen 24 already had nospawnws and froze identically.
      # Xvfb A/B tests passed because XTEST key injection bypasses input
      # drivers entirely. Fix: 00-modulepath.conf below injects the
      # NixOS-merged module tree (which HAS libinput+evdev) into the
      # config search path the raw server already reads — Xorg.0.log's
      # "Using config directory: /etc/X11/xorg.conf.d" proves that path
      # is consulted. Keep the default server (no explicit server arg):
      # startx's auto `vt1 -keeptty` and logind session activation both
      # depend on that code path.
      ({
        nixos = {pkgs, ...}: {
          environment.etc."X11/xorg.conf.d/00-modulepath.conf".text = ''
            Section "Files"
              ModulePath "/run/current-system/sw/lib/xorg/modules"
            EndSection
          '';
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
