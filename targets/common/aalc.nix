{pkgs, ...}: let
  version = "1.4.5";
  appId = "1973530"; # Limbus Company Steam AppID

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

      export WINEDLLOVERRIDES="winemenubuilder.exe=d"

      if [ ! -f "$APP_DIR/vcrun2022_installed" ]; then
        echo "Injecting vcrun2022 into Limbus Company Proton prefix..."
        # Removed steam-run. Protontricks handles its own Steam Runtime.
        ${pkgs.protontricks}/bin/protontricks -c "winetricks -q vcrun2022" ${appId}
        touch "$APP_DIR/vcrun2022_installed"
      fi

      echo "Running AALC inside Limbus Company's environment..."
      # Removed steam-run. Launch directly via protontricks natively.
      exec ${pkgs.protontricks}/bin/protontricks -c "wine \"$EXE_PATH\"" ${appId}
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
