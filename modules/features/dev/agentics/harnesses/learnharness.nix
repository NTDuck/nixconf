{den, ...}: {
  # LearnHarness (https://github.com/amosblomqvist/learnharness):
  # An agent harness for learning: adaptive teaching, practice, and a
  # persistent knowledge graph. Packaged from the official upstream AppImage,
  # wrapped with appimageTools.wrapType2 for non-FUSE NixOS execution.
  den.aspects.dev.agentics.harnesses.learnharness = {
    nixos = {
      pkgs,
      lib,
      ...
    }: let
      pname = "learnharness";
      version = "0.3.7";

      src = pkgs.fetchurl {
        url = "https://github.com/amosblomqvist/learnharness/releases/download/v${version}/LearnHarness-${version}-x86_64.AppImage";
        hash = "sha256-7zRlGDOxGOpcdEnM2UUFgBB66xg+bHGrFQdrQ7xFGOw=";
      };

      appimageContents = pkgs.appimageTools.extractType2 {
        inherit pname version src;
      };

      learnharness = pkgs.appimageTools.wrapType2 {
        inherit pname version src;

        extraPkgs = pkgs: [
          pkgs.libglvnd
          pkgs.libxkbcommon
          pkgs.wayland
        ];

        extraInstallCommands = ''
          install -Dm444 "${appimageContents}/learnharness.desktop" "$out/share/applications/learnharness.desktop"
          install -Dm444 "${appimageContents}/usr/share/icons/hicolor/512x512/apps/learnharness.png" "$out/share/icons/hicolor/512x512/apps/learnharness.png"
          substituteInPlace "$out/share/applications/learnharness.desktop" \
            --replace-fail "Exec=AppRun" "Exec=learnharness"
        '';

        meta = {
          description = "An agent harness for learning: adaptive teaching, practice, and a persistent knowledge graph";
          homepage = "https://github.com/amosblomqvist/learnharness";
          license = lib.licenses.agpl3Only;
          mainProgram = pname;
          platforms = ["x86_64-linux"];
          sourceProvenance = [lib.sourceTypes.binaryNativeCode];
        };
      };
    in {
      environment.systemPackages = [
        learnharness
      ];
    };
  };
}
