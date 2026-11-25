# terabox (https://www.terabox.com): official TeraBox desktop client
# (Electron, 1 TB cloud storage). First-party Linux distribution is a
# .deb from TeraBox's own CDN (data.nephobox.com/issue/terabox/Linux/…,
# same host as the Windows .exe). Verified 2026-11-25 that no AppImage
# exists upstream — terabox.app's SPA lists Linux as "rpm deb" only and
# the CDN serves no AppImage asset — so this extracts the deb directly
# (autoPatchelfHook + makeWrapper) instead of the
# nixconf-appimage-packaging wrapType2 recipe. 1.7.0 is the newest
# version on the CDN (1.4.1/1.5.0 also live; 1.5.1–1.6.0 and 2.0.0 404).
{den, ...}: {
  den.aspects.apps.terabox = {
    nixos = {
      pkgs,
      lib,
      ...
    }: let
      pname = "terabox";
      version = "1.7.0";

      # Electron runtime deps plus the deb's declared Depends
      # (libgtkmm-2.4 → gtkmm2, TeraBoxHost tray helper) and
      # Recommends (libappindicator3 → libappindicator-gtk3).
      deps = [
        pkgs.alsa-lib
        pkgs.at-spi2-atk
        pkgs.atk
        pkgs.cairo
        pkgs.cups
        pkgs.dbus
        pkgs.expat
        pkgs.fontconfig
        pkgs.freetype
        pkgs.gdk-pixbuf
        pkgs.glib
        pkgs.gtk3
        pkgs.gtkmm2
        pkgs.libappindicator-gtk3
        pkgs.libdrm
        pkgs.libnotify
        pkgs.libuuid
        pkgs.libxkbcommon
        pkgs.mesa
        pkgs.nspr
        pkgs.nss
        pkgs.pango
        pkgs.systemd
        pkgs.wayland
        pkgs.xorg.libX11
        pkgs.xorg.libXcomposite
        pkgs.xorg.libXcursor
        pkgs.xorg.libXdamage
        pkgs.xorg.libXext
        pkgs.xorg.libXfixes
        pkgs.xorg.libXi
        pkgs.xorg.libXrandr
        pkgs.xorg.libXrender
        pkgs.xorg.libXScrnSaver
        pkgs.xorg.libXt
        pkgs.xorg.libXtst
        pkgs.xorg.libxcb
      ];

      # .node addons packed inside app.asar (ref-napi, uiohook-napi,
      # ffi-napi, …) dlopen their libs by bare name at first require —
      # invisible to autoPatchelfHook (not in any DT_NEEDED graph at
      # build time) and unresolvable via the main binary's RUNPATH (the
      # dlopen caller is the addon, whose RUNPATH only covers its own
      # NEEDED). Observed as hard crashes on 2026-11-25: libstdc++.so.6,
      # then libXtst.so.6. LD_LIBRARY_PATH is the only hook that covers
      # the whole class.
      libPath = pkgs.lib.makeLibraryPath (deps ++ [pkgs.stdenv.cc.cc.lib]);

      terabox = pkgs.stdenv.mkDerivation {
        inherit pname version;

        src = pkgs.fetchurl {
          url = "https://data.nephobox.com/issue/terabox/Linux/${version}/TeraBox_${version}_amd64.deb";
          hash = "sha256-u35NWeIICsRAzMsz7q/0rjZfUiTvTN/RiewJLDXChBY=";
        };

        nativeBuildInputs = [
          pkgs.autoPatchelfHook
          pkgs.dpkg
          pkgs.makeWrapper
        ];

        buildInputs = deps;

        # Electron binaries must not be stripped; patchelf hooks handle
        # interpreter/rpath fixing.
        dontStrip = true;
        dontPatchELF = true;

        unpackPhase = ''
          runHook preUnpack
          dpkg-deb -x $src unpacked
          runHook postUnpack
        '';

        installPhase = ''
          runHook preInstall
          mkdir -p $out/{bin,opt,share/applications,share/icons/hicolor/scalable/apps}
          cp -r unpacked/opt/TeraBox $out/opt/TeraBox
          cp unpacked/usr/share/applications/terabox.desktop $out/share/applications/
          cp unpacked/usr/share/icons/hicolor/scalable/apps/terabox.svg \
            $out/share/icons/hicolor/scalable/apps/
          # Upstream's own desktop entry ships --no-sandbox (no setuid
          # chrome-sandbox dance on NixOS).
          # libPath (see above) covers the .node addon dlopen class;
          # $out/opt/TeraBox on the path too: ffi-napi dlopens TeraBox's
          # in-house libs (libbrowserengine.so, libplayer.so, …) by bare
          # name from a .node addon whose RUNPATH can't see them.
          # cd: the same addons fs.openSync('libbrowserengine.so')
          # relative to process.cwd() before dlopening, so the app only
          # works when launched from its libdir (matches upstream's
          # /opt/TeraBox layout, where .deb users launch from an
          # absolute Exec= — cwd is inherited there; here it isn't).
          makeWrapper $out/opt/TeraBox/terabox $out/bin/terabox \
            --add-flags "--no-sandbox" \
            --prefix LD_LIBRARY_PATH : "${libPath}:$out/opt/TeraBox" \
            --run "cd $out/opt/TeraBox"
          substituteInPlace $out/share/applications/terabox.desktop \
            --replace-fail "/opt/TeraBox/terabox" "$out/bin/terabox"
          runHook postInstall
        '';

        meta = {
          description = "TeraBox desktop client - 1TB free cloud storage";
          homepage = "https://www.terabox.com";
          license = lib.licenses.unfree;
          mainProgram = pname;
          platforms = ["x86_64-linux"];
          sourceProvenance = [lib.sourceTypes.binaryNativeCode];
        };
      };
    in {
      environment.systemPackages = [
        terabox
      ];
    };
  };
}
