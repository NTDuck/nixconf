# Falkon — KDE QtWebEngine browser for the DELL spectrwm (X11) session
# (2026-09-23). No HM module (verified: no falkon.nix in home-manager
# release-26.05 modules/programs — only NixOS has none either; it's a
# plain package), so home.packages like the other non-module apps.
# Default config (QtWebEngine handles X11 natively); user preferences
# land in ~/.config/falkon/profiles/ on first run.
{den, ...}: {
  den.aspects.apps.browsers.falkon = {
    homeManager = {
      pkgs,
      ...
    }: {
      home.packages = [
        pkgs.kdePackages.falkon
      ];
    };
  };
}
