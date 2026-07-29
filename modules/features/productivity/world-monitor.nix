# TODO Slop, check this guy
{den, ...}: {
  den.aspects.productivity.world-monitor = {
    nixos = {
      pkgs,
      lib,
      ...
    }: let
      pname = "world-monitor";
      version = "2.5.23";

      asset =
        {
          x86_64-linux = {
            arch = "amd64";
            hash = "sha256-QEuPgOX1D0m08upP544NLCv5jXLnrHcCRT1TJIHKNY0=";
          };

          aarch64-linux = {
            arch = "aarch64";
            hash = "sha256-ZISYarD8Kwgd9pulfbeId7gmL3YUDVtxAPlcecw19lQ=";
          };
        }
          .${
          pkgs.stdenv.hostPlatform.system
        }
            or (throw "World Monitor does not support ${pkgs.stdenv.hostPlatform.system}");

      src = pkgs.fetchurl {
        url = "https://github.com/koala73/worldmonitor/releases/download/v${version}/World.Monitor_${version}_${asset.arch}.AppImage";
        inherit (asset) hash;
      };

      appimageContents = pkgs.appimageTools.extractType2 {
        inherit pname version src;
      };

      world-monitor = pkgs.appimageTools.wrapType2 {
        inherit pname version src;

        extraPkgs = pkgs: [
          pkgs.libglvnd
          pkgs.libxkbcommon
          pkgs.wayland
        ];

        extraInstallCommands = ''
          install -Dm444 \
            "${appimageContents}/usr/share/applications/World Monitor.desktop" \
            "$out/share/applications/world-monitor.desktop"

          install -Dm444 \
            "${appimageContents}/World Monitor.png" \
            "$out/share/icons/hicolor/256x256/apps/world-monitor.png"
        '';

        meta = {
          description = "Real-time global intelligence dashboard";
          homepage = "https://worldmonitor.app";
          changelog = "https://github.com/koala73/worldmonitor/releases/tag/v${version}";
          license = lib.licenses.agpl3Only;
          mainProgram = pname;
          platforms = [
            "x86_64-linux"
            "aarch64-linux"
          ];
          sourceProvenance = [
            lib.sourceTypes.binaryNativeCode
          ];
        };
      };
    in {
      environment.systemPackages = [
        world-monitor
      ];
    };
  };
}
