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

      mkxpzSrc = pkgs.fetchurl {
        url = "https://github.com/bakustarver/rpgmakermlinux-cicpoffs/releases/download/libraries/mkxp-z.x86_64.zip";
        hash = "sha256-F5G19gBqXfIIES5M7SH7Rzxcj9+Vxl/V2NOPyvvA+wQ=";
      };

      rpgmaker-data = pkgs.stdenv.mkDerivation {
        pname = "${pname}-data";
        inherit version src;

        sourceRoot = ".";

        nativeBuildInputs = [pkgs.unzip];

        postPatch = ''
          cd rpgmakerlinux-x86_64-v${version}
          substituteInPlace nwjs/packagefiles/nwjsstart-cicpoffs.sh \
            --replace-fail '$mainfd/nwjs/nwjs' '$mainfd/nwjs' \
            --replace-fail 'if echo "$1" | grep ".exe"; then' 'if false; then' \
            --replace-fail 'export nwjsfm="$mainfd/nwjs"' $'export nwjsfm="$mainfd/nwjs"\nexport PATH="$PATH:$nwjsfm/packagefiles"' \
            --replace-fail 'evbunpack "$gameexe"' '"$evbunpack" "$gameexe"' \
            --replace-fail 'if ! [ -d "$npath/$line-extracted" ]; then' 'if [ ! -d "$npath/$line-extracted" ] || [ -z "$(ls -A "$npath/$line-extracted" 2>/dev/null)" ]; then' \
            --replace-fail 'exenpath="$npath"' $'exenpath="$npath"\nbasegamef=$(basename "$npath")' \
            --replace-fail $'npath="$npath"\nfi' $'npath="$npath"\nfi\nnpath=$(realpath "$npath")' \
            --replace-fail 'mountpath="$npath/www"' $'mountpath="$npath/www"\nnotfound=""' \
            --replace-fail 'if echo "$allstrings" | grep -m 1 -q "\.enigma"; then' $'if echo "$allstrings" | grep -m 1 -q "\\.enigma"; then\nif [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then ret=0; else' \
            --replace-fail 'if [[ $ret -eq 1 ]]; then' $'fi\nif [[ $ret -eq 1 ]]; then' \
            --replace-fail 'checkandunmount() {' $'checkandunmount() {\n[ -L "$nwjstestpath/www" ] && rm -f "$nwjstestpath/www"' \
            --replace-fail 'if [ -n "$notfound" ]; then' 'if [ -n "$notfound" ] && [ "$found" != "true" ]; then' \
            --replace-fail 'startnw() {' $'startnw() {\nexport LD_LIBRARY_PATH="$nwjstestpath/lib:$nwjstestpath:$LD_LIBRARY_PATH"' \
            --replace-fail '"$mkxpzp/mkxp-z.$arch"' '(cd "$mkxpzp" && "$mkxpzp/mkxp-z.$arch")'
          cd ..
        '';

        installPhase = ''
          runHook preInstall
          mkdir -p $out/share/rpgmaker-linux/mkxp-z
          cp -r rpgmakerlinux-x86_64-v${version}/* $out/share/rpgmaker-linux/
          unzip -q ${mkxpzSrc} -d $out/share/rpgmaker-linux/mkxp-z
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
            gcc.cc.lib
            glib
            gnused
            gnutar
            gtk3
            libGL
            libbsd
            libdrm
            libffi
            libgbm
            libglvnd
            libnotify
            libpulseaudio
            libsndfile
            libx11
            libxcb
            libxcomposite
            libxcrypt-legacy
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
            libyaml
            mesa
            nspr
            nss
            p7zip
            pango
            procps
            udev
            unzip
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
          else
            cp -rf "$DATA_DIR/nwjs/packagefiles" "$MAIN_DIR/nwjs/"
            cp -f "$DATA_DIR/nwjs/cicpoffs" "$DATA_DIR/nwjs/dwnwjs.sh" "$MAIN_DIR/nwjs/" 2>/dev/null || true
          fi
          chmod -R u+w "$MAIN_DIR/nwjs"

          # Ensure mkxp-z directory and files exist in user directory
          if [[ ! -f "$MAIN_DIR/mkxp-z/mkxp-z.x86_64" ]]; then
            mkdir -p "$MAIN_DIR/mkxp-z"
            cp -rf "$DATA_DIR/mkxp-z"/* "$MAIN_DIR/mkxp-z/"
            chmod -R u+w "$MAIN_DIR/mkxp-z"
            sed -e "s@\"RGSS@\"$MAIN_DIR/mkxp-z/RGSS@g" -e "s@\"Kawariki-patches@\"$MAIN_DIR/mkxp-z/Kawariki-patches@g" -i "$MAIN_DIR/mkxp-z/mkxp.json"
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
