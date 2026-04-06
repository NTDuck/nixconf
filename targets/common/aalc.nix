{pkgs, ...}: let
  version = "1.4.5";
  runnerUrl = "https://github.com/wine-cachyos/releases/releases/download/10.0-1/wine-cachyos-miniloader-fonts-10.0-1-x86_64.tar.xz";

  aalc = pkgs.stdenv.mkDerivation {
    pname = "ahab-assistant-limbus-company";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/KIYI671/AhabAssistantLimbusCompany/releases/download/V${version}/AALC_V${version}.7z";
      hash = "sha256-9Wm2HeIHIm0DyLbeaSimeriy1g2BmGVsLBnrqI5kKp4=";
    };

    nativeBuildInputs = [pkgs.p7zip pkgs.makeWrapper];
    sourceRoot = ".";

    installPhase = ''
            mkdir -p $out/opt/aalc
            cp -r * $out/opt/aalc/
            mkdir -p $out/bin

            cat > $out/bin/aalc <<'EOF'
      #!/bin/sh
      APP_DIR="$HOME/.local/share/aalc"
      RUNNER_DIR="$APP_DIR/runner"
      export WINEPREFIX="$APP_DIR/wineprefix"
      export WINEDLLOVERRIDES="winemenubuilder.exe=d"

      mkdir -p "$APP_DIR"

      if [ "$(cat "$APP_DIR/version" 2>/dev/null)" != "${version}" ]; then
        echo "Deploying Ahab Assistant version ${version}..."
        rm -rf "$APP_DIR/app"
        mkdir -p "$APP_DIR/app"
        cp -r ${placeholder "out"}/opt/aalc/* "$APP_DIR/app/"
        chmod -R +w "$APP_DIR/app"
        echo "${version}" > "$APP_DIR/version"
      fi

      EXE_PATH=$(find "$APP_DIR/app" -type f -iname "AALC.exe" | head -n 1)

      # Fetch the highly optimized CachyOS Miniloader
      if [ ! -d "$RUNNER_DIR" ]; then
        echo "Downloading and extracting wine-cachyos-miniloader..."
        mkdir -p "$RUNNER_DIR"
        ${pkgs.wget}/bin/wget -qO- ${runnerUrl} | ${pkgs.gnutar}/bin/tar -xJ -C "$RUNNER_DIR"
      fi

      WINE_EXEC=$(find "$RUNNER_DIR" -name "wine" -type f -executable | head -n 1)

      if [ ! -f "$APP_DIR/vcrun2022_installed" ]; then
        echo "Installing vcrun2022 via winetricks..."
        # Winetricks will now run using the native host display perfectly
        ${pkgs.winetricks}/bin/winetricks -q vcrun2022
        touch "$APP_DIR/vcrun2022_installed"
      fi

      cd "$(dirname "$EXE_PATH")"
      exec "$WINE_EXEC" "$EXE_PATH"
      EOF

            chmod +x $out/bin/aalc
    '';
  };

  desktopItem = pkgs.makeDesktopItem {
    name = "aalc";
    desktopName = "Ahab Assistant";
    exec = "aalc";
    terminal = false;
    categories = ["Utility"];
  };
in {
  environment.systemPackages = [
    aalc
    desktopItem
  ];
}
