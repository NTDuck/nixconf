{den, ...}: {
  # RisuAI: local-first AI roleplay frontend.
  # https://github.com/kwaroran/RisuAI
  # Ships as a Tauri AppImage; wrapped with appimageTools (same pattern as gaming/wlib).
  den.aspects.apps.gaming.roleplaying.risuai = {
    homeManager = {
      pkgs,
      lib,
      ...
    }: let
      # Pinned to the 2026.8.250 release so the store hash stays reproducible;
      # bump both strings together when updating.
      pname = "risuai";
      version = "2026.8.250";

      src = pkgs.fetchurl {
        url = "https://github.com/kwaroran/RisuAI/releases/download/v${version}/RisuAI_${version}_amd64.AppImage";
        hash = "sha256-cDEq6jMX1eTcNmbJ63ls+R5SVHavasKRMOBV0fGAaR4=";
      };

      appimageContents = pkgs.appimageTools.extractType2 {
        inherit pname version src;
      };

      risuai = pkgs.appimageTools.wrapAppImage {
        inherit pname version;
        src = appimageContents;

        # Tauri/WebKitGTK runtime libs the extracted AppImage expects on the host.
        extraPkgs = pkgs: [
          pkgs.glib
          pkgs.gsettings-desktop-schemas
          pkgs.gtk3
          pkgs.webkitgtk_4_1
          pkgs.libsoup_3
          pkgs.cairo
          pkgs.pango
          pkgs.gdk-pixbuf
          pkgs.libepoxy
          pkgs.libsecret
        ];

        extraInstallCommands = ''
          install -Dm444 "${appimageContents}/RisuAI.desktop" "$out/share/applications/risuai.desktop"
          install -Dm444 "${appimageContents}/usr/share/icons/hicolor/256x256@2/apps/RisuAI.png" \
            "$out/share/icons/hicolor/512x512/apps/risuai.png"
          # AppImage MimeType=x-scheme-handler/risuailocal — register so deep links open the app.
          substituteInPlace "$out/share/applications/risuai.desktop" \
            --replace-fail "Exec=RisuAI" "Exec=risuai"
        '';

        meta = {
          description = "Powerful frontend for character-based AI roleplay";
          homepage = "https://github.com/kwaroran/RisuAI";
          # Repo LICENSE is GPL-3.0 text without an "or later" grant.
          license = lib.licenses.gpl3Only;
          mainProgram = pname;
          platforms = ["x86_64-linux"];
          sourceProvenance = [lib.sourceTypes.binaryNativeCode];
        };
      };
    in {
      home.packages = [risuai];
    };
  };
}
