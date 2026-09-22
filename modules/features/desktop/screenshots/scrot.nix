# scrot — minimal X11 screenshot tool for the DELL spectrwm session,
# replacing flameshot (2026-09-22). scrot is the canonical spectrwm
# pairing (spectrwm's example config uses scrot for screenshots).
#
# SCOPE: package only. The W-Shift-s KEYBIND lives in the spectrwm
# aspect (den's aspect-content merge is last-wins for function-valued
# class defs).
{den, ...}: {
  den.aspects.desktop.screenshots.scrot = {
    homeManager = {pkgs, ...}: {
      home.packages = [
        pkgs.scrot
      ];
    };
  };
}
