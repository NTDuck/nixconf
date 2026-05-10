# {pkgs, ...}: let
#   version = "1.4.10";
#   runnerUrl = "https://github.com/Kron4ek/Wine-Builds/releases/download/11.5/wine-11.5-staging-amd64.tar.xz";
#   aalc = pkgs.stdenv.mkDerivation {
#     pname = "ahab-assistant-limbus-company";
#     inherit version;
#     src = pkgs.fetchurl {
#       url = "https://github.com/KIYI671/AhabAssistantLimbusCompany/releases/download/V${version}/AALC_V${version}.7z";
#       hash = "sha256-N7bQIzunsdLZ+//jUARYrfpXANIjDnQNxn79b0t05jM=";
#     };
#     nativeBuildInputs = [pkgs.p7zip pkgs.makeWrapper];
#     sourceRoot = ".";
#     installPhase = ''
#             mkdir -p $out/opt/aalc
#             cp -r * $out/opt/aalc/
#             mkdir -p $out/bin
#             cat > $out/bin/aalc <<'EOF'
#       #!/bin/sh
#       APP_DIR="$HOME/.local/share/aalc"
#       RUNNER_DIR="$APP_DIR/runner"
#       export WINEPREFIX="$APP_DIR/wineprefix"
#       export WINEDLLOVERRIDES="winemenubuilder.exe=d"
#       mkdir -p "$APP_DIR"
#       if [ "$(cat "$APP_DIR/version" 2>/dev/null)" != "${version}" ]; then
#         echo "Deploying Ahab Assistant version ${version}..."
#         rm -rf "$APP_DIR/app"
#         mkdir -p "$APP_DIR/app"
#         cp -r ${placeholder "out"}/opt/aalc/* "$APP_DIR/app/"
#         chmod -R +w "$APP_DIR/app"
#         echo "${version}" > "$APP_DIR/version"
#       fi
#       EXE_PATH=$(find "$APP_DIR/app" -type f -iname "AALC.exe" | head -n 1)
#       if [ ! -d "$RUNNER_DIR" ]; then
#         echo "Downloading and extracting Kron4ek Wine..."
#         mkdir -p "$RUNNER_DIR"
#         ${pkgs.wget}/bin/wget -qO- ${runnerUrl} | ${pkgs.gnutar}/bin/tar -xJ --strip-components=1 -C "$RUNNER_DIR"
#       fi
#       # Explicitly assign our downloaded Wine to the WINE variable
#       export WINE=$(find "$RUNNER_DIR" -name "wine" -type f -executable | head -n 1)
#       if [ ! -f "$APP_DIR/vcrun2022_installed" ]; then
#         echo "Installing vcrun2022 via winetricks..."
#         # Wrap winetricks in steam-run to satisfy dynamic linking
#         ${pkgs.steam-run}/bin/steam-run ${pkgs.winetricks}/bin/winetricks -q vcrun2022
#         touch "$APP_DIR/vcrun2022_installed"
#       fi
#       cd "$(dirname "$EXE_PATH")"
#       # Run inside a Virtual Desktop to stop Sway from tiling hidden WPF overlay windows
#       exec ${pkgs.steam-run}/bin/steam-run "$WINE" explorer /desktop=AALC,1280x720 "$EXE_PATH"
#       EOF
#             chmod +x $out/bin/aalc
#     '';
#   };
#   desktopItem = pkgs.makeDesktopItem {
#     name = "aalc";
#     desktopName = "Ahab Assistant";
#     exec = "aalc";
#     terminal = false;
#     categories = ["Utility"];
#   };
# in {
#   environment.systemPackages = [
#     aalc
#     desktopItem
#   ];
# }
{pkgs, ...}: let
  version = "1.4.10";
  runnerUrl = "https://github.com/Kron4ek/Wine-Builds/releases/download/11.5/wine-11.5-staging-amd64.tar.xz";

  aalc = pkgs.stdenv.mkDerivation {
    pname = "ahab-assistant-limbus-company";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/KIYI671/AhabAssistantLimbusCompany/releases/download/V${version}/AALC_V${version}.7z";
      hash = "sha256-N7bQIzunsdLZ+//jUARYrfpXANIjDnQNxn79b0t05jM=";
    };

    nativeBuildInputs = [pkgs.p7zip pkgs.makeWrapper];
    sourceRoot = ".";

            installPhase = ''
            mkdir -p $out/opt/aalc
            cp -r * $out/opt/aalc/
            
            # FIX: Fix the typo in the source code itself so it uses the correct default path.
            # The typo "Program Files (x86\Steam" is in module/config/config_typing.py
            sed -i 's|Program Files (x86\\Steam|Program Files (x86)\\Steam|g' $out/opt/aalc/module/config/config_typing.py
            
            mkdir -p $out/bin

            cat > $out/bin/aalc <<'EOF'
      #!/bin/sh
      APP_DIR="$HOME/.local/share/aalc"
      RUNNER_DIR="$APP_DIR/runner"
      
      # THE CRITICAL FIX: To see the Limbus Company window, AALC MUST share the same Wine prefix as the game.
      # Limbus Company AppID: 1973530
      STEAM_PREFIX="$HOME/.local/share/Steam/steamapps/compatdata/1973530/pfx"
      
      if [ -d "$STEAM_PREFIX" ]; then
        export WINEPREFIX="$STEAM_PREFIX"
        echo "Using Steam Proton prefix: $WINEPREFIX"
      else
        export WINEPREFIX="$APP_DIR/wineprefix"
        echo "Warning: Steam prefix not found at $STEAM_PREFIX. Using standalone prefix."
      fi

      export WINEDLLOVERRIDES="winemenubuilder.exe=d"

      # THE FIX: Force XWayland. Native Wayland Wine completely breaks WPF mouse inputs.
      # And AALC MUST share the same X server as the game to 'see' its window.
      unset WAYLAND_DISPLAY
      export DISPLAY=:0

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

      # FIX: Create a fake Windows path to the game in our prefix so AALC's path check passes.
      # We create both the correct and the typoed path just in case.
      REAL_GAME_DIR="$HOME/.local/share/Steam/steamapps/common/Limbus Company"
      
      # 1. Correct path
      GAME_FAKE_PATH="$WINEPREFIX/drive_c/Program Files (x86)/Steam/steamapps/common/Limbus Company"
      mkdir -p "$(dirname "$GAME_FAKE_PATH")"
      if [ -d "$REAL_GAME_DIR" ] && [ ! -L "$GAME_FAKE_PATH" ]; then
        echo "Symlinking Limbus Company to AALC prefix..."
        ln -s "$REAL_GAME_DIR" "$GAME_FAKE_PATH"
      fi
      
      # 2. Typoed path (used in older AALC versions or if our sed failed)
      GAME_TYPO_PATH="$WINEPREFIX/drive_c/Program Files (x86\Steam/steamapps/common/Limbus Company"
      mkdir -p "$(dirname "$GAME_TYPO_PATH")"
      if [ -d "$REAL_GAME_DIR" ] && [ ! -L "$GAME_TYPO_PATH" ]; then
        ln -s "$REAL_GAME_DIR" "$GAME_TYPO_PATH"
      fi

      # FIX: Automatically update config.yaml
      CONFIG_FILE="$APP_DIR/app/config/config.yaml"
      if [ -f "$CONFIG_FILE" ]; then
        echo "Updating AALC configuration..."
        sed -i 's|game_path:.*|game_path: "C:\\\\Program Files (x86)\\\\Steam\\\\steamapps\\\\common\\\\Limbus Company\\\\LimbusCompany.exe"|' "$CONFIG_FILE"
      fi

      if [ ! -d "$RUNNER_DIR" ]; then
        echo "Downloading and extracting Kron4ek Wine..."
        mkdir -p "$RUNNER_DIR"
        ${pkgs.wget}/bin/wget -qO- ${runnerUrl} | ${pkgs.gnutar}/bin/tar -xJ --strip-components=1 -C "$RUNNER_DIR"
      fi

      # TRY TO USE PROTON'S WINE FIRST (for wineserver compatibility)
      PROTON_WINE=$(find "$HOME/.local/share/Steam/steamapps/common" -name "wine" -path "*/files/bin/wine" | head -n 1)
      if [ -x "$PROTON_WINE" ]; then
        echo "Found Proton Wine: $PROTON_WINE"
        export WINE="$PROTON_WINE"
      else
        export WINE=$(find "$RUNNER_DIR" -name "wine" -type f -executable | head -n 1)
      fi

      if [ ! -f "$APP_DIR/wpf_fixed" ]; then
        echo "Applying compatibility fixes to Wine..."
        ${pkgs.steam-run}/bin/steam-run ${pkgs.winetricks}/bin/winetricks -q vcrun2022
        # Disable WPF Hardware Acceleration
        ${pkgs.steam-run}/bin/steam-run "$WINE" reg add "HKCU\Software\Microsoft\Avalon.Graphics" /v DisableHWAcceleration /t REG_DWORD /d 1 /f
        touch "$APP_DIR/wpf_fixed"
      fi

      cd "$(dirname "$EXE_PATH")"

      echo "Launching AALC..."
      # NOTE: We use steam-run to ensure the Proton Wine has its needed libraries.
      exec ${pkgs.steam-run}/bin/steam-run "$WINE" "$EXE_PATH"
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
