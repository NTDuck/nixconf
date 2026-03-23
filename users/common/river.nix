{ pkgs, ... }:

{
  wayland.windowManager.river = {
    enable = true;

    settings = {
      map.normal = {
        "Super Return" = "spawn footclient";
        "Super W" = "spawn firefox";
        "Super Q" = "close";
        "Super Shift E" = "exit";
      };
    };

    extraConfig = ''
      rivertile -view-padding 4 -outer-padding 4 &
      yambar &
      riverctl background-color 0x111111 &
      riverctl spawn "${pkgs.fcitx5}/bin/fcitx5 -d --replace"
    '';
  };
}