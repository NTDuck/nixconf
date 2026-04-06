{pkgs, ...}: let
  version = "1.4.5";

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

      if [ -z "$EXE_PATH" ]; then
        echo "Error: No .exe file found in $APP_DIR/app"
        exit 1
      fi

      # Use an isolated standalone prefix instead of a Steam Proton prefix
      export WINEPREFIX="$APP_DIR/wineprefix"
      export WINEDLLOVERRIDES="winemenubuilder.exe=d" # Stop Wine from making clutter desktop shortcuts

      if [ ! -f "$APP_DIR/vcrun2022_installed" ]; then
        echo "Installing vcrun2022 via winetricks..."
        ${pkgs.winetricks}/bin/winetricks -q vcrun2022
        touch "$APP_DIR/vcrun2022_installed"
      fi

      cd "$(dirname "$EXE_PATH")"
      # Using Wayland native Wine
      exec ${pkgs.wineWowPackages.waylandFull}/bin/wine "$EXE_PATH"
      EOF

            chmod +x $out/bin/aalc
    '';
  };

  # Make it accessible via tofi launcher
  desktopItem = pkgs.makeDesktopItem {
    name = "aalc";
    desktopName = "AALC";
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
