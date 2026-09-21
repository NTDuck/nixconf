{den, ...}: {
  # Tabularis: lightweight local-first SQL workspace (Tauri + WebKitGTK;
  # Postgres/MySQL/SQLite built-in, plugin drivers for others). Not in
  # nixpkgs — official AppImage from TabularisDB/tabularis releases,
  # appimageTools-wrapped (no FUSE at runtime, hash-pinned). MimeType
  # carries x-scheme-handler/tabularis (deep links from the app UI).
  # https://github.com/TabularisDB/tabularis
  den.aspects.dev.toolchains.sql.tabularis = {
    homeManager = {
      pkgs,
      lib,
      ...
    }: let
      # Pinned to the 0.24.0 release; bump version + hash together
      # (hash from `nix store prefetch-file` on the release asset).
      pname = "tabularis";
      version = "0.24.0";

      src = pkgs.fetchurl {
        url = "https://github.com/TabularisDB/tabularis/releases/download/v${version}/tabularis_${version}_amd64.AppImage";
        hash = "sha256-ZBUGet7dlinRU6e+XGg8bTMwHaItFHFd7jsRauxgUnc=";
      };

      appimageContents = pkgs.appimageTools.extractType2 {
        inherit pname version src;
      };

      tabularis = pkgs.appimageTools.wrapAppImage {
        inherit pname version;
        src = appimageContents;

        # Tauri/WebKitGTK runtime set (same base risuai/unsloth-studio use);
        # webkitgtk's bundled junks dlopen more at runtime — smoke test
        # catches the rest.
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
          install -Dm444 "${appimageContents}/usr/share/applications/tabularis.desktop" \
            "$out/share/applications/tabularis.desktop"
          install -Dm444 "${appimageContents}/tabularis.png" \
            "$out/share/icons/hicolor/512x512/apps/tabularis.png"
          # Desktop entry Exec=tabularis %u + MimeType=x-scheme-handler/tabularis;
          # the wrapper installs the binary under that same name, so Exec
          # resolves as-is.
        '';

        meta = {
          description = "Lightweight local-first SQL workspace and database client";
          homepage = "https://github.com/TabularisDB/tabularis";
          license = lib.licenses.asl20;
          mainProgram = pname;
          platforms = ["x86_64-linux"];
          sourceProvenance = [lib.sourceTypes.binaryNativeCode];
        };
      };
    in {
      home.packages = [tabularis];
    };
  };
}
