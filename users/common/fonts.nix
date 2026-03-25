{ pkgs, ... }:

{
  fonts.fontconfig = {
    enable = true;

    defaultFonts = rec {
      monospace = [ "Intel One Mono" ];
      sansSerif = monospace;
    };
  };

  wayland.windowManager.sway.config.fonts = {
    names = [ "Intel One Mono" ];
    size = 11.0;
  };

  gtk = {
    enable = true;
    font = {
      name = "Intel One Mono";
      size = 11;
    };
  };

  home.packages = [
    pkgs.intel-one-mono
  ];
}