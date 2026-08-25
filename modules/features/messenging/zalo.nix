{den, ...}: {
  den.aspects.messenging.zalo = {
    nixos = {
      pkgs,
      lib,
      ...
    }: let
      pname = "zalo";
      version = "1.1.3";

      src = pkgs.fetchurl {
        url = "https://github.com/realdtn2/zalo-linux-2026/releases/download/v${version}/Zalo-v${version}-x86_64.AppImage";
        hash = "sha256-7Dm22LYOZYcBX2BDZhWMnX9rj+GZ0LXIorCRdZmulrw=";
      };

      appimageContents = pkgs.appimageTools.extractType2 {
        inherit pname version src;
      };

      zalo = pkgs.appimageTools.wrapType2 {
        inherit pname version src;

        extraPkgs = pkgs:
          with pkgs; [
            libglvnd
            libxkbcommon
            openssl
            sqlite
            wayland
            xz
          ];

        extraInstallCommands = ''
          install -Dm444 "${appimageContents}/zalo.desktop" "$out/share/applications/zalo.desktop"
          install -Dm444 "${appimageContents}/zalo.png" "$out/share/icons/hicolor/512x512/apps/zalo.png"
          substituteInPlace "$out/share/applications/zalo.desktop" \
            --replace-fail "Exec=AppRun" "Exec=zalo"
        '';

        meta = {
          description = "Zalo messaging application for Linux (unofficial port)";
          homepage = "https://github.com/realdtn2/zalo-linux-2026";
          license = lib.licenses.unfree;
          mainProgram = pname;
          platforms = ["x86_64-linux"];
        };
      };
    in {
      environment.systemPackages = [
        zalo
      ];
    };
  };
}
