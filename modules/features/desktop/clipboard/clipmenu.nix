# clipmenu — X11 clipboard history manager for the DELL spectrwm
# session, replacing cliphist (2026-09-22). cliphist is wl-clipboard-
# backed (Wayland only); clipmenu is the canonical X11 equivalent
# (dmenu-based, uses xsel/xclip under the hood).
#
# HM module:
# https://github.com/nix-community/home-manager/blob/release-26.05/modules/services/clipmenu.nix
#
# SCOPE: package + daemon only. The launcher invocation (clipmenu
# dmenu-style picker) is wired via the spectrwm aspect's `programs`
# if needed; for now the daemon alone is enough — users invoke
# `clipmenu` from a terminal or bind it later.
{den, ...}: {
  den.aspects.desktop.clipboard.clipmenu = {
    homeManager = {pkgs, ...}: {
      services.clipmenu = {
        enable = true;
        package = pkgs.clipmenu;
        # HM's clipmenu `launcher` option is a command string resolved
        # via PATH (not a package path). dmenu must be in PATH at
        # activation time — the desktop.launchers.dmenu aspect adds it.
        launcher = "dmenu -i -l 10 -p clipboard";
      };

      home.packages = [
        # clipmenu needs a clipboard backend; xsel is the lighter
        # option (xclip works too, but xsel is the upstream default).
        pkgs.xsel
      ];
    };
  };
}
