# flameshot — screenshot tool. Works on both X11 and Wayland.
# Used by Legion (mangowm/Wayland). DELL (spectrwm/X11) uses scrot
# instead (spectrwm's canonical pairing).
{den, ...}: {
  den.aspects.desktop.screenshots.flameshot = {
    homeManager = {pkgs, ...}: {
      services.flameshot = {
        enable = true;
        package = pkgs.unstable.flameshot;
      };
    };
  };
}
