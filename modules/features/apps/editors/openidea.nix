{den, ...}: {
  # OpenIDEA (https://github.com/l0ng-ai/openidea) — open-source IDE
  # inspired by IntelliJ IDEA, rebuilt in Rust/Tauri: IDEA-style keymap,
  # tool windows, search-everywhere, debugger, Git, database and HTTP
  # clients. Ships as a Tauri AppImage; wrapped with appimageTools
  # (same pattern as tabularis/risuai — no FUSE at runtime, hash-pinned).
  den.aspects.apps.editors.openidea = {
    homeManager = {
      pkgs,
      lib,
      ...
    }: let
      # Pinned to the v0.1.34 release; bump version + hash together
      # (hash from `nix store prefetch-file` on the release asset).
      pname = "openidea";
      version = "0.1.34";

      src = pkgs.fetchurl {
        url = "https://github.com/l0ng-ai/openidea/releases/download/v${version}/OpenIDEA_${version}_amd64.AppImage";
        hash = "sha256-1vNflxcSB7av44zbUtU4C1rglhRwaIYi8iT+cwram5I=";
      };

      appimageContents = pkgs.appimageTools.extractType2 {
        inherit pname version src;
      };

      openidea = pkgs.appimageTools.wrapAppImage {
        inherit pname version;
        src = appimageContents;

        # Tauri/WebKitGTK runtime set (same base tabularis/risuai use);
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
          install -Dm444 "${appimageContents}/OpenIDEA.desktop" \
            "$out/share/applications/openidea.desktop"
          install -Dm444 "${appimageContents}/openidea.png" \
            "$out/share/icons/hicolor/512x512/apps/openidea.png"
          # Desktop entry Exec=openidea; the wrapper installs the binary
          # under that same name, so Exec resolves as-is.
        '';

        meta = {
          description = "Open-source IDE inspired by IntelliJ IDEA, rebuilt in Rust";
          homepage = "https://github.com/l0ng-ai/openidea";
          license = lib.licenses.asl20;
          mainProgram = pname;
          platforms = ["x86_64-linux"];
          sourceProvenance = [lib.sourceTypes.binaryNativeCode];
        };
      };
    in {
      home.packages = [openidea];
    };
  };
}
