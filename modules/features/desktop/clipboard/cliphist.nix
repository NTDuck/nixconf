# cliphist — Wayland clipboard history manager. Used by Legion
# (mangowm/Wayland). DELL (spectrwm/X11) uses clipmenu instead.
#
# HM module:
# https://github.com/nix-community/home-manager/blob/release-26.05/modules/services/cliphist.nix
{den, ...}: {
  den.aspects.desktop.clipboard.cliphist = {
    homeManager = {pkgs, ...}: {
      services.cliphist = {
        enable = true;
        package = pkgs.unstable.cliphist;

        # Default is stable pkgs.wl-clipboard; labwc pulls unstable
        # wl-clipboard and both variants ship a hidden .wl-copy-wrapped
        # subpath — two store paths, one subpath → buildEnv "conflicting
        # subpath" abort. One canonical copy: everything consumes the
        # unstable one.
        clipboardPackage = pkgs.unstable.wl-clipboard;

        allowImages = true;
      };
    };
  };
}
