# DELL X11 session start (2026-09-22, root cause corrected 2026-09-24):
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
# is consulted. The default server is kept (the baked raw
# Xorg path); autorepeat flags are appended as server ARGS
# (not a different server binary), and startx still auto-adds
# `vt1 -keeptty` when serverargs lack a vt token — see the
# wrapper below.
#
# The paired greeter include lives in the host default.nix:
#   (den.aspects.desktop.greeters.tuigreet {
#     session = _config: "dell-latitude-E7270-H836QF2-x11-session";
#   })
{
  ...
}: {
  den.aspects.dell-latitude-E7270-H836QF2 = {
    nixos = {
      lib,
      pkgs,
      ...
    }: let
      # Merged Xorg module tree for the raw startx server (2026-09-28).
      # services.xserver.enable = false below keeps the DM payload
      # (xterm/xset/xprop/xsetroot/xlsclients/xinput, xlock.pam,
      # x11-ssh-askpass) out of systemPackages — but it ALSO stopped
      # the NixOS xserver module from materializing the merged
      # sw/lib/xorg/modules tree (xorgserver's modules + libinput +
      # evdev drivers). A config "ModulePath" REPLACES the server's
      # default search path, so once that directory vanished (first
      # boot of the 2026-09-28 generation) the raw Xorg could not
      # even load "modesetting" → "(EE) no screens found" → startx
      # died and the boot never got past tuigreet. Build the tree
      # explicitly and point ModulePath at the store path: complete
      # (modesetting + libinput + evdev), per-generation, and
      # independent of what happens to land in systemPackages.
      xorgModules = pkgs.symlinkJoin {
        name = "xorg-modules";
        paths = with pkgs; [
          xorg-server
          xf86-input-libinput
          xf86-input-evdev
        ];
      };
    in {
      # NO NixOS xserver module (2026-09-25; module-tree fallout fixed
      # 2026-09-28 via xorgModules above): this host never runs a
      # display-manager-managed server — the
      # dell-latitude-E7270-H836QF2-x11-session wrapper below execs
      # startx against the raw xorgserver. X init works
      # without the module: the wrapper's PATH prepends
      # ${pkgs.xorg.xinit} (xinit+xauth).
      services.xserver.enable = lib.mkForce false;
      environment.etc."X11/xorg.conf.d/00-modulepath.conf".text = ''
        Section "Files"
          ModulePath "${xorgModules}/lib/xorg/modules"
        EndSection
      '';
      # Driver-package catchall InputClass snippets (2026-09-28): the
      # xserver module used to ship these into /etc/X11/xorg.conf.d as
      # a side effect of enable=true; without them the 10/40 binding
      # sections ("evdev keyboard catchall", "libinput touchpad
      # catchall", ...) are gone and only the hand-written 50- option
      # section remains. They sort BEFORE 50-libinput-touchpad.conf so
      # its options still win (last-match-wins per option).
      environment.etc."X11/xorg.conf.d/10-evdev.conf".source = "${pkgs.xf86-input-evdev}/share/X11/xorg.conf.d/10-evdev.conf";
      environment.etc."X11/xorg.conf.d/40-libinput.conf".source = "${pkgs.xf86-input-libinput}/share/X11/xorg.conf.d/40-libinput.conf";
      # Touchpad defaults (2026-09-24, "sane defaults & like legion"):
      # tap-to-click + natural scrolling + disable-while-typing, ported
      # from the legion mango settings (trackpad_natural_scrolling=1,
      # trackpad_disable_while_typing=1). mango mouse_click_method=2
      # (clickfinger) has NO equivalent here: the E7270 GlidePoint has
      # real physical buttons, so libinput exposes exactly one click
      # method — verified live 2026-09-24 (no "Click Method" xinput
      # property at all); a ClickMethod option would be silently inert.
      #
      # WHY a hand-written InputClass instead of services.libinput.*:
      # this session starts the RAW xorgserver via startx (see
      # 00-modulepath.conf above), which reads ONLY /etc/X11/xorg.conf.d
      # snippets — services.libinput emits its option sections into the
      # main xserver.conf (inputClassSections → xserver.nix
      # configFile), which only a display-manager-launched server with
      # `-config` reads. Filename sorts AFTER 10-evdev.conf and
      # 40-libinput.conf so this section wins (InputClass sections are
      # last-match-wins per option).
      environment.etc."X11/xorg.conf.d/50-libinput-touchpad.conf".text = ''
        Section "InputClass"
          Identifier "Dell libinput touchpad defaults"
          MatchIsTouchpad "on"
          MatchDriver "libinput"
          Option "Tapping" "on"
          Option "NaturalScrolling" "on"
          Option "DisableWhileTyping" "on"
        EndSection
      '';
      environment.systemPackages = let
        x11Session = pkgs.writeShellScriptBin "dell-latitude-E7270-H836QF2-x11-session" ''
          # startx's server args: after `--` the first token is the
          # SERVER COMMAND, so `-- vt1` would exec a binary named
          # "vt1". Only FLAGS go after `--` (autorepeat below); the
          # server command stays startx's baked raw Xorg, and startx
          # auto-appends the current `vt<N> -keeptty` when serverargs
          # lack a vt token (logind session activation depends on it).
          #
          # PATH: greetd hands the session a minimal environment, but
          # startx invokes `xinit` and `xauth` BY NAME. Prepend the
          # xinit package bin (carries both) so the wrapper never
          # depends on the session's PATH — 2026-09-22 "xinit not
          # present" failure from exactly this.
          PATH="${pkgs.xorg.xinit}/bin:${pkgs.xorg.xauth}/bin:$PATH"
          export PATH
          # Key repeat (2026-09-24): legion mango parity
          # (repeat_delay=150 ms, repeat_rate=50 cps ⇒ 20 ms interval).
          # Server-level flags beat a session-side `xset r rate` (no
          # autostart race; applies before any client connects).
          # startx auto-appends `vt<N> -keeptty` when serverargs lack a
          # vt token (startx lines ~242-251), so logind/VT semantics
          # from the no-server-args path are preserved.
          exec ${pkgs.xorg.xinit}/bin/startx "$HOME"/.xsession -- -ardelay 150 -arinterval 20
        '';
      in [x11Session];

      networking.hosts = {
        # Tailscale peer mapping (2026-10-16): Dell runs tailscale with
        # --accept-dns=false, so MagicDNS bare hostnames do not resolve.
        # Map Legion's tailnet IP so ninfer and other services route over tailscale.
        "100.105.224.23" = [
          "lenovo-legion-16iah7h-pf3xj8sp"
          "lenovo-legion-16iah7h-pf3xj8sp.taild3be63.ts.net"
        ];
      };

      # ZRAM sizing (2026-10-21 user request): cap zram swap to 50% of RAM
      # on Dell instead of the shared 100% default, keeping memory footprint lower.
      zramSwap.memoryPercent = 50;
    };
  };
}
