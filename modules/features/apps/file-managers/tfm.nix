{
  den,
  lib,
  ...
}: let
  # tfm: mouse-first TUI file manager (clarkarch/tfm-tui). Upstream is a
  # Bun app; we install the official prebuilt release binary
  # (bun-compiled, mostly self-contained) rather than rebuilding from
  # source — a source build needs the bun-flake toolchain.
  version = "0.1.0-beta.0";
  # Published sidecar tfm-x86_64-linux.gz.sha256 (v0.1.0-beta.0).
  hash = "sha256-RuSDRLI6/6fm3IMysZyFeiAS3F3l6s2olct6nLVQ658=";
  tfm = pkgs: lib: # helper taking the module args it needs
    pkgs.stdenvNoCC.mkDerivation {
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
        license = lib.licenses.mit;
        platforms = ["x86_64-linux"];
        mainProgram = "tfm";
      };
    };
in {
  den.aspects.apps.file-managers.tfm = {
    # Config reads config.lib.stylix.colors directly (unguarded); the theme
    # aspect must be present wherever tfm is included.
    includes = [
      den.aspects.desktop.theming.stylix
    ];

    homeManager = {
      config,
      pkgs,
      ...
    }: let
      colors = config.lib.stylix.colors.withHashtag;
      # User accent override: gold, applied over the kanagawa-dragon base16
      # palette so tfm matches the desktop's accent color convention.
      accent = "#ffd700";
    in {
      home.packages = [
        (tfm pkgs lib)
        pkgs.librsvg # rsvg-convert — theme-tinted icons, SVG thumbnails
        pkgs.imagemagick # magick — raster image thumbnails
        pkgs.ffmpeg # video thumbnails & previews
        pkgs.glib # gio — starred-file metadata, gvfs network locations
        pkgs.xdg-utils # xdg-open — required for "open in default app"
        pkgs.udisks # udisksctl — mount/eject removable drives
        pkgs.unstable.wl-clipboard # wl-copy/wl-paste — one canonical copy with cliphist/labwc (stable copy collides on .wl-copy-wrapped, see cliphist.nix)
        pkgs.zip
        pkgs.unzip
        pkgs.p7zip
      ];

      xdg.configFile."tfm/config.toml".text = ''
        [ui]
        view-mode                 = "grid"
        transparent-bg            = false
        icons                     = "opaque"
        ui-style                  = "solid"
        preview-enabled           = false
        dual-pane                 = false
        tab-bar                   = false
        show-hidden               = false
        recursive-search          = false
        restore-session           = true

        [theme]
        bg             = "${colors.base00}"
        sidebarBg      = "${colors.base01}"
        sidebarFg      = "${colors.base05}"
        sidebarFgMuted = "${colors.base03}"
        accent         = "${accent}"
        accentBg       = "${colors.base02}"
        hoverBg        = "${colors.base01}"
        border         = "${colors.base02}"
        divider        = "${colors.base02}"
        white          = "${colors.base05}"
        syntaxString   = "${colors.base0B}"
        syntaxNumber   = "${colors.base09}"
        syntaxType     = "${colors.base0C}"
        syntaxFunction = "${accent}"
        syntaxOperator = "${colors.base0C}"
        syntaxProperty = "${colors.base0B}"
        ansi0          = "${colors.base00}"
        ansi1          = "${colors.base08}"
        ansi2          = "${colors.base0B}"
        ansi3          = "${colors.base0A}"
        ansi4          = "${colors.base0D}"
        ansi5          = "${colors.base0E}"
        ansi6          = "${colors.base0C}"
        ansi7          = "${colors.base05}"
        ansi8          = "${colors.base03}"
        ansi9          = "${colors.base08}"
        ansi10         = "${colors.base0B}"
        ansi11         = "${colors.base0A}"
        ansi12         = "${colors.base0D}"
        ansi13         = "${colors.base0E}"
        ansi14         = "${colors.base0C}"
        ansi15         = "${colors.base07}"
      '';
    };
  };
}
