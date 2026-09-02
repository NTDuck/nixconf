{...}: {
  den.aspects.gaming.rpgmakermlinux-cicpoffs = {
    nixos = {
      pkgs,
      lib,
      ...
    }: let
      pname = "rpgmaker-linux";
      version = "1.1.9";

      src = pkgs.fetchurl {
        url = "https://github.com/bakustarver/rpgmakermlinux-cicpoffs/releases/download/v${version}/rpgmakerlinux-x86_64-v${version}.tar.gz";
        hash = "sha256-2SagfgwPcL6+hnHnsKyVKpSeywIuZpkuLM1k03LsrxI=";
      };

      rpgmaker-data = pkgs.stdenv.mkDerivation {
        pname = "${pname}-data";
        inherit version src;

        sourceRoot = ".";

        postPatch = ''
          substituteInPlace rpgmakerlinux-x86_64-v${version}/nwjs/packagefiles/nwjsstart-cicpoffs.sh \
            --replace-fail 'export nwjsfm="$mainfd/nwjs/nwjs"' 'export nwjsfm="$mainfd/nwjs"'
        '';

        installPhase = ''
          runHook preInstall
          mkdir -p $out/share/rpgmaker-linux
          cp -r rpgmakerlinux-x86_64-v${version}/* $out/share/rpgmaker-linux/
          runHook postInstall
        '';
      };

      rpgmaker-fhs = pkgs.buildFHSEnv {
        name = pname;

        targetPkgs = pkgs:
          with pkgs; [
            alsa-lib
            at-spi2-atk
            at-spi2-core
            binutils
            cairo
            coreutils
            cups
            dbus
            expat
            file
            findutils
            fuse3
            fuse
            gawk
            glib
            gnused
            gnutar
            gtk3
            libGL
            libdrm
            libglvnd
            libnotify
            libx11
            libxcb
            libxcomposite
            libxcursor
            libxdamage
            libxext
            libxfixes
            libxi
            libxkbcommon
            libxrandr
            libxrender
            libxscrnsaver
            libxtst
            mesa
            nspr
            nss
            p7zip
            pango
            procps
            udev
            util-linux
            wget
            which
            yad
            zlib
          ];

        runScript = pkgs.writeShellScript "rpgmaker-linux-entry" ''
          DATA_DIR="${rpgmaker-data}/share/rpgmaker-linux"
          CONFIG_FILE="$HOME/.config/defrpgmakerlinuxpath.txt"

          if [[ -r "$CONFIG_FILE" ]] && read -r line < "$CONFIG_FILE" && [[ -n "$line" ]]; then
            MAIN_DIR="''${line%/}"
          else
            MAIN_DIR="$HOME/desktopapps"
          fi

          # Ensure base nwjs directory and files exist in user directory
          if [[ ! -d "$MAIN_DIR/nwjs" ]]; then
            mkdir -p "$MAIN_DIR"
            cp -r "$DATA_DIR/nwjs" "$MAIN_DIR/"
            chmod -R u+w "$MAIN_DIR/nwjs"
          fi

          exec "$MAIN_DIR/nwjs/packagefiles/nwjsstart-cicpoffs.sh" "$@"
        '';

        extraInstallCommands = ''
          mkdir -p $out/share/applications $out/share/icons/hicolor/128x128/apps
          cp ${rpgmaker-data}/share/rpgmaker-linux/nwjs/packagefiles/nwjs128.png $out/share/icons/hicolor/128x128/apps/rpgmaker-linux.png

          cat > $out/share/applications/rpgmaker-linux.desktop << 'EOF'
          [Desktop Entry]
          Name=RPG Maker Launcher
          Comment=Run RPG Maker games natively on Linux
          Exec=rpgmaker-linux --chooselatestnwjs --gamepath %u
          Type=Application
          Categories=Game;
          StartupNotify=true
          MimeType=application/x-ms-dos-executable;application/x-wine-extension-msp;
          Icon=rpgmaker-linux
          Terminal=true
          NoDisplay=true
          EOF

          cat > $out/share/applications/rpgmaker-linux-options.desktop << 'EOF'
          [Desktop Entry]
          Name=RPG Maker Launcher Options
          Comment=Configuration for RPG Maker Linux Launcher
          Exec=rpgmaker-linux --gui
          Type=Application
          Categories=Game;
          StartupNotify=true
          MimeType=application/x-ms-dos-executable;application/x-wine-extension-msp;x-scheme-handler/rpgmakermp;
          Icon=rpgmaker-linux
          Terminal=true
          EOF
        '';

        meta = {
          description = "RPG Maker MV / MZ for Linux (cicpoffs mount)";
          homepage = "https://github.com/bakustarver/rpgmakermlinux-cicpoffs";
          license = lib.licenses.gpl3Plus;
          mainProgram = pname;
          platforms = ["x86_64-linux"];
        };
      };
    in {
      environment.systemPackages = [
        rpgmaker-fhs
      ];
    };
  };
}
