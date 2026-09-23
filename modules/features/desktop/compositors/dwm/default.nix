# dwm: minimal dynamic tiling X11 WM for the DELL streaming client
# (2026-09-23 cutover). spectrwm froze the whole screen on two
# independent boots (gen 19 with parser-verified conf, gen 22 with a
# zero-exception Xvfb-validated conf — under Xvfb the WM survived both
# W-Return and W-d spawns, so the freeze is unreproducible offline),
# which hit the user's stated escape clause: "If this keeps happening,
# and there is no fix, switch to other tiling x11 e.g. dwm".
#
# Keybinds mirror the legion mango setup where dwm's action set allows:
# MODKEY = Mod4 (mango SUPER), W-Return terminal, W-d dmenu, W-b falkon,
# W-Ctrl-l i3lock, W-Shift-s scrot, W-q killclient, W-f fullscreen,
# W-j/k focus, W-Shift-h/l movestack (dwm-movestack), 1..9 view,
# Shift-1..9 send, XF86 media keys. Mango-only knobs (blur, animations,
# scroller layouts, gapp*) dropped — same rationale as the spectrwm
# port map.
#
# BUILD: nixpkgs' dwm takes a complete `conf` (config.def.h replacement)
# + `patches`. The repo-hosted config.def.h is the whole config (stylix
# kanagawa-dragon colors inlined); movestack-togglefullscreen.patch adds
# the two missing actions against pristine 6.6 (dwm.c hunks only — the
# config hunk is unnecessary because conf replaces the file wholesale).
#
# SESSION: dwm has no NixOS module and HM has no dwm module, so the
# session runs through HM's generic xsession.windowManager.command.
# The command is a wrapper (same pattern as the spectrwm aspect):
# export session env, start the session daemons that must outlive
# nothing (xss-lock/dunst/clipmenu start via hm-graphical-session.target
# from the xsession script), exec dwm. Wallpaper + screensaver-off run
# inside the wrapper BEFORE dwm so the boot never blanks.
{
  den,
  lib,
  ...
}: {
  den.aspects.desktop.compositors.dwm = {
    includes = [
      den.aspects.desktop.shells.zsh
      # Same session furniture the spectrwm aspect pulls in: clipboard
      # history (X11), Vietnamese input, notifications, launcher,
      # lock chain, portals.
      den.aspects.desktop.clipboard.clipmenu
      den.aspects.desktop.input.fcitx5
      den.aspects.desktop.launchers.dmenu
      den.aspects.desktop.notifications.dunst
      den.aspects.desktop.auth.i3lock
      (den.aspects.desktop.portals.xdg {internalOutput = "eDP-1";})
    ];

    nixos = {pkgs, ...}: {
      # dwm ships no NixOS module; the HM xsession command starts it.
      # dwm reads its colors/binds from the compiled config — nothing
      # needed on the NixOS side beyond the package, which the HM
      # xsession module puts in scope via the wrapper's PATH.
      environment.systemPackages = [
        (pkgs.dwm.override {
          conf = builtins.readFile ./config.def.h;
          patches = [./movestack-togglefullscreen.patch];
        })
      ];

      environment.sessionVariables = {
        XDG_CURRENT_DESKTOP = "dwm";
        XDG_SESSION_DESKTOP = "dwm";
        XDG_SESSION_TYPE = "x11";
      };
    };

    homeManager = {
      pkgs,
      config,
      lib,
      ...
    }: {
      xsession.enable = true;

      # Generic WM command (HM has no dwm module): wrapper execs dwm.
      # Same env exports as the spectrwm aspect's wrapper. toString:
      # HM's windowManager.command is a plain string; interpolating the
      # writeShellScriptBin derivation gives its out-path.
      xsession.windowManager.command =
        "${pkgs.writeShellScript "dwm-session" ''
          export XDG_CURRENT_DESKTOP=dwm
          export XDG_SESSION_DESKTOP=dwm
          export XDG_SESSION_TYPE=x11

          # "Never dim/sleep when idle" (2026-09-21): kill the X
          # screensaver timer (which screen-locker's ExecStartPre set to
          # 600s) and DPMS blanking BEFORE dwm maps the bar. Locking
          # stays manual (W-Ctrl-l) + suspend (--transfer-sleep-lock).
          ${pkgs.xorg.xset}/bin/xset s off -dpms &

          # Wallpaper: X11 has no compositor wallpaper — feh paints the
          # stylix image on the root window.
          ${pkgs.feh}/bin/feh --bg-fill ${config.stylix.image} &

          exec ${pkgs.dwm.override {
            conf = builtins.readFile ./config.def.h;
            patches = [./movestack-togglefullscreen.patch];
          }}/bin/dwm
        ''}";

      # Binaries referenced by dwm binds (dwm spawns via execvp on
      # PATH, unlike spectrwm's absolute-path programs[]).
      home.packages = with pkgs; [
        feh # root-window wallpaper (stylix image)
        scrot # W-Shift-s screenshots
        xorg.xset # screensaver/DPMS kill in the wrapper
      ];
    };
  };
}
