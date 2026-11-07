{den, ...}: {
  # GridCraft (https://github.com/storytold/gridcraft):
  # Open-source spreadsheet software in pure Rust.
  # Packaged from upstream AppImage via appimageTools.wrapType2 for non-FUSE NixOS execution.
  den.aspects.apps.office.gridcraft = {
    nixos = {
      pkgs,
      lib,
      ...
    }: let
      pname = "gridcraft";
      version = "0.17.0";

      src = pkgs.fetchurl {
        url = "https://github.com/storytold/gridcraft/releases/download/v${version}/gridcraft-${version}-linux-x86_64.AppImage";
        hash = "sha256-BFXIY1NYItlRoakf3ujdApNp4PL5P3rJnEkW73Cod2E=";
      };

      appimageContents = pkgs.appimageTools.extractType2 {
        inherit pname version src;
      };

      gridcraft = pkgs.appimageTools.wrapType2 {
        inherit pname version src;

        extraPkgs = pkgs: [
          pkgs.libglvnd
          pkgs.libxkbcommon
          pkgs.wayland
        ];

        extraInstallCommands = ''
          install -Dm444 "${appimageContents}/ai.storyteller.gridcraft.desktop" "$out/share/applications/ai.storyteller.gridcraft.desktop"
          install -Dm444 "${appimageContents}/usr/share/icons/hicolor/512x512/apps/ai.storyteller.gridcraft.png" \
            "$out/share/icons/hicolor/512x512/apps/ai.storyteller.gridcraft.png"
        '';

        meta = {
          description = "Open-source spreadsheet software in pure Rust";
          homepage = "https://github.com/storytold/gridcraft";
          license = with lib.licenses; [asl20 mit];
          mainProgram = pname;
          platforms = ["x86_64-linux"];
          sourceProvenance = [lib.sourceTypes.binaryNativeCode];
        };
      };
    in {
      environment.systemPackages = [
        gridcraft
      ];
    };
  };
}
