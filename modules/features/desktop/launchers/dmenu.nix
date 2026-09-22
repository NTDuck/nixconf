# dmenu — the X11 application launcher for the DELL spectrwm session,
# replacing bemenu (2026-09-22). dmenu is the canonical spectrwm pairing
# (spectrwm's example config uses `dmenu_run` as the launcher).
#
# SCOPE: package only. The W-d KEYBIND lives in the spectrwm aspect
# (den's aspect-content merge is last-wins for function-valued class
# defs, so a second homeManager module here would REPLACE the spectrwm
# aspect's bindings instead of extending it).
{den, ...}: {
  den.aspects.desktop.launchers.dmenu = {
    homeManager = {
      pkgs,
      ...
    }: {
      home.packages = [
        pkgs.dmenu
      ];
    };
  };
}
