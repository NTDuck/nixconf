{den, ...}: {
  # WordCraft (https://github.com/storytold/wordcraft):
  # Clean-room open-source word processor reimplementation in pure Rust.
  # Packaged from upstream AppImage via appimageTools.wrapType2 for non-FUSE NixOS execution.
  den.aspects.apps.office.wordcraft = {
    nixos = {
      pkgs,
      lib,
      ...
    }: let
      pname = "wordcraft";
      version = "0.16.0";

      src = pkgs.fetchurl {
        url = "https://github.com/storytold/wordcraft/releases/download/v${version}/wordcraft-${version}-linux-x86_64.AppImage";
        hash = "sha256-mArB1pGPHB4MJA2Fk3TyKxnlJNOvM3La7xNExaCXrhc=";
      };

      appimageContents = pkgs.appimageTools.extractType2 {
        inherit pname version src;
      };

      wordcraft = pkgs.appimageTools.wrapType2 {
        inherit pname version src;

        extraPkgs = pkgs: [
          pkgs.libglvnd
          pkgs.libxkbcommon
          pkgs.wayland
        ];

        extraInstallCommands = ''
          install -Dm444 "${appimageContents}/ai.storyteller.wordcraft.desktop" "$out/share/applications/ai.storyteller.wordcraft.desktop"
          install -Dm444 "${appimageContents}/usr/share/icons/hicolor/512x512/apps/ai.storyteller.wordcraft.png" \
            "$out/share/icons/hicolor/512x512/apps/ai.storyteller.wordcraft.png"
        '';

        meta = {
          description = "Clean-room word processor reimplementation in pure Rust";
          homepage = "https://github.com/storytold/wordcraft";
          license = with lib.licenses; [asl20 mit];
          mainProgram = pname;
          platforms = ["x86_64-linux"];
          sourceProvenance = [lib.sourceTypes.binaryNativeCode];
        };
      };
    in {
      environment.systemPackages = [
        wordcraft
      ];
    };
  };
}
