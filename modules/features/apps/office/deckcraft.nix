{den, ...}: {
  # DeckCraft (https://github.com/storytold/deckcraft):
  # Open-source presentation software in pure Rust.
  # Packaged from upstream AppImage via appimageTools.wrapType2 for non-FUSE NixOS execution.
  den.aspects.apps.office.deckcraft = {
    nixos = {
      pkgs,
      lib,
      ...
    }: let
      pname = "deckcraft";
      version = "0.16.0";

      src = pkgs.fetchurl {
        url = "https://github.com/storytold/deckcraft/releases/download/v${version}/deckcraft-${version}-linux-x86_64.AppImage";
        hash = "sha256-EhHYtRc3fu0PwDfWTa7xt1t+4njgYgqw1+e+tuhhg/c=";
      };

      appimageContents = pkgs.appimageTools.extractType2 {
        inherit pname version src;
      };

      deckcraft = pkgs.appimageTools.wrapType2 {
        inherit pname version src;

        extraPkgs = pkgs: [
          pkgs.libglvnd
          pkgs.libxkbcommon
          pkgs.wayland
        ];

        extraInstallCommands = ''
          install -Dm444 "${appimageContents}/ai.storyteller.deckcraft.desktop" "$out/share/applications/ai.storyteller.deckcraft.desktop"
          install -Dm444 "${appimageContents}/usr/share/icons/hicolor/512x512/apps/ai.storyteller.deckcraft.png" \
            "$out/share/icons/hicolor/512x512/apps/ai.storyteller.deckcraft.png"
        '';

        meta = {
          description = "Open-source presentation software in pure Rust";
          homepage = "https://github.com/storytold/deckcraft";
          license = with lib.licenses; [asl20 mit];
          mainProgram = pname;
          platforms = ["x86_64-linux"];
          sourceProvenance = [lib.sourceTypes.binaryNativeCode];
        };
      };
    in {
      environment.systemPackages = [
        deckcraft
      ];
    };
  };
}
