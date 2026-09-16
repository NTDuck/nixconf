{
  den.aspects.apps.file-managers.tfm = {
    homeManager = {
      pkgs,
      ...
    }: let
      # tfm: mouse-first TUI file manager (clarkarch/tfm-tui). Upstream is a
      # Bun app; we install the official prebuilt release binary
      # (bun-compiled, mostly self-contained) rather than rebuilding from
      # source — a source build needs the bun-flake toolchain.
      version = "0.1.0-beta.0";
      # Published sidecar tfm-x86_64-linux.gz.sha256 (v0.1.0-beta.0).
      hash = "sha256-RuSDRLI6/6fm3IMysZyFeiAS3F3l6s2olct6nLVQ658=";
      tfm = pkgs.stdenvNoCC.mkDerivation {
        pname = "tfm-tui";
        inherit version;
        src = pkgs.fetchurl {
          url = "https://github.com/clarkarch/tfm-tui/releases/download/v${version}/tfm-x86_64-linux.gz";
          inherit hash;
        };
        nativeBuildInputs = [pkgs.gzip];
        sourceRoot = ".";
        dontUnpack = true;
        dontConfigure = true;
        dontBuild = true;
        installPhase = ''
          runHook preInstall
          gzip -dc "$src" > tfm
          install -Dm755 tfm $out/bin/tfm
          ln -s tfm $out/bin/terminal-file-manager
          runHook postInstall
        '';
        # The binary embeds a Bun runtime; strip breaks it.
        dontStrip = true;
        meta = {
          description = "Modern, mouse-first terminal file manager";
          homepage = "https://github.com/clarkarch/tfm-tui";
          license = pkgs.lib.licenses.mit;
          platforms = ["x86_64-linux"];
          mainProgram = "tfm";
        };
      };
    in {
      home.packages = [
        tfm
        # Helpers the installer flags; each gates a tfm feature.
        pkgs.librsvg # rsvg-convert — theme-tinted icons, SVG thumbnails
        pkgs.imagemagick # magick — raster image thumbnails
        pkgs.ffmpeg # video thumbnails & previews
        pkgs.glib # gio — starred-file metadata, gvfs network locations
        pkgs.xdg-utils # xdg-open — required for "open in default app"
        pkgs.udisks # udisksctl — mount/eject removable drives
        pkgs.wl-clipboard # wl-copy/wl-paste — clipboard with GUI apps
        pkgs.zip
        pkgs.unzip
        pkgs.p7zip
      ];
    };
  };
}
