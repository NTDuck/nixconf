{den, ...}: {
  den.aspects.gaming.wlib = {
    includes = [
      den.aspects.gaming.wine
    ];

    nixos = {
      pkgs,
      lib,
      ...
    }: let
      pname = "wlib";
      version = "0.3.4";

      src = pkgs.fetchurl {
        url = "https://github.com/kirin-3/wLib/releases/download/v${version}/wLib-v${version}-linux-x86_64.AppImage";
        hash = "sha256-TC66OKZkpgCGh/PtLntqze7zq2Gar4ypX6QC8pfvMz0=";
      };

      appimageContents = pkgs.appimageTools.extractType2 {
        inherit pname version src;
        postExtract = ''
          ${pkgs.patch}/bin/patch -p1 -d $out < ${./wlib-extension-permissions.patch}
        '';
      };

      wlib = pkgs.appimageTools.wrapAppImage {
        inherit pname version;
        src = appimageContents;

        extraPkgs = pkgs:
          with pkgs; [
            cabextract
            gtk3
            libglvnd
            libxcb
            libxcb-cursor
            libxcb-image
            libxcb-keysyms
            libxcb-render-util
            libxcb-wm
            libxkbcommon
            mesa-demos
            p7zip
            unzip
            wayland
            wineWow64Packages.stableFull
            winetricks
          ];

        extraInstallCommands = ''
          install -Dm444 "${appimageContents}/wlib.desktop" "$out/share/applications/wlib.desktop"
          install -Dm444 "${appimageContents}/wlib.svg" "$out/share/icons/hicolor/scalable/apps/wlib.svg"
          install -Dm444 "${appimageContents}/usr/bin/wlib.png" "$out/share/icons/hicolor/256x256/apps/wlib.png"
        '';

        meta = {
          # https://github.com/kirin-3/wLib
          description = "wLib is a native Linux desktop application for managing, launching, and updating your F95Zone game library.";
          homepage = "https://github.com/kirin-3/wLib";
          license = lib.licenses.gpl3Plus;
          mainProgram = pname;
          platforms = ["x86_64-linux"];
          sourceProvenance = [
            lib.sourceTypes.binaryNativeCode
          ];
        };
      };
    in {
      environment.systemPackages = [
        wlib
      ];
    };
  };
}
