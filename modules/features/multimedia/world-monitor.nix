{den, ...}: {
  den.aspects.multimedia.world-monitor = {
    nixos = {pkgs, ...}: let
      world-monitor = pkgs.appimageTools.wrapType2 {
        pname = "world-monitor";
        version = "2.5.23";

        src = pkgs.fetchurl {
          url = "https://worldmonitor.app/api/download?platform=linux-appimage";
          hash = "";
        };
      };
    in {
      environment.systemPackages = [
        world-monitor
      ];
    };
  };
}
