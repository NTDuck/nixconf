{ den, inputs, ... }: {
  den.aspects.zalo = {
    nixos = {pkgs, ...}: let
      pname = "zalo";
      version = "26.4.10";
    src = pkgs.fetchurl {
      url = "https://github.com/doandat943/zalo-for-linux/releases/download/${version}/Zalo-${version}+ZaDark-26.2-ffca4ab.AppImage";
      hash = "sha256-ldBkzc1H7Ku3+R8K1c0gygY6htSRtRuCuw/TeDHPQFI=";
    };
    zalo = pkgs.appimageTools.wrapType2 {
      inherit pname version src;
      extraPkgs = pkgs:
        with pkgs; [
          sqlite
        ];
    };
    zalo-desktop = pkgs.makeDesktopItem {
      name = "zalo";
      desktopName = "Zalo";
      exec = "zalo";
      categories = ["Network" "InstantMessaging"];
    };
  in {
    environment.systemPackages = [
      zalo
      zalo-desktop
    ];
  };
  };
}
