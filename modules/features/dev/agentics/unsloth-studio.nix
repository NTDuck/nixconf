{den, ...}: {
  # Unsloth Studio: fine-tuning desktop app (Tauri + WebKitGTK), official
  # AppImage from unslothai/unsloth releases. Upstream marks the Linux
  # AppImage "experimental" (their latest.json prefers the .deb) — accepted,
  # per-host appimageTools wrapping avoids FUSE and pins the hash.
  # https://github.com/unslothai/unsloth
  den.aspects.dev.agentics.unsloth-studio = {
    homeManager = {
      pkgs,
      lib,
      ...
    }: let
      # Pinned to the 0.1.808-beta release; bump version + hash together.
      pname = "unsloth-studio";
      version = "0.1.808-beta";

      src = pkgs.fetchurl {
        url = "https://github.com/unslothai/unsloth/releases/download/v${version}/Unsloth-Desktop-Linux.AppImage";
        hash = "sha256-tyKcGUOj8qwcA4IfwTv+jDckIXA06tmzpAvOPwaiP4c=";
      };

      appimageContents = pkgs.appimageTools.extractType2 {
        inherit pname version src;
      };

      unsloth-studio = pkgs.appimageTools.wrapAppImage {
        inherit pname version;
        src = appimageContents;

        # Tauri/WebKitGTK runtime libs the extracted AppImage expects on the
        # host (same set risuai uses; gstreamer libs back the app's audio/video
        # surfaces via its bundled apprun-hook paths).
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
          # runtime deps the Tauri binary dlopens (missing-lib smoke test):
          pkgs.nghttp2
          pkgs.curl
          pkgs.openssl
        ];

        extraInstallCommands = ''
          install -Dm444 "${appimageContents}/usr/share/applications/Unsloth.desktop" \
            "$out/share/applications/unsloth-studio.desktop"
          install -Dm444 "${appimageContents}/unsloth-studio.png" \
            "$out/share/icons/hicolor/512x512/apps/unsloth-studio.png"
          # Desktop entry Exec=unsloth-studio %u + MimeType=x-scheme-handler/unsloth;
          # the wrapper installs the binary under that same name, so Exec
          # resolves as-is.
        '';

        meta = {
          description = "Fine-tune and run local LLMs (Unsloth desktop studio)";
          homepage = "https://github.com/unslothai/unsloth";
          license = lib.licenses.unfree;
          mainProgram = pname;
          platforms = ["x86_64-linux"];
          sourceProvenance = [lib.sourceTypes.binaryNativeCode];
        };
      };
    in {
      home.packages = [unsloth-studio];
    };
  };
}
