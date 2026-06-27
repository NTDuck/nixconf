{den, ...}: {
  den.aspects.multimedia.world-monitor = {
    nixos = {pkgs, ...}: let
      world-monitor = pkgs.appimageTools.wrapType2 {
        pname = "world-monitor";
        version = "2.5.23";

        src = pkgs.fetchurl {
          url = "https://worldmonitor.app/api/download?platform=linux-appimage";
          hash = "sha256-404b8f80e5f50f49b4f2ea4fe78e0d2c2bf98d72e7ac7702453d532481ca358d";
        };
      };
    in {
      environment.systemPackages = [
        world-monitor
      ];
    };
  };
}
