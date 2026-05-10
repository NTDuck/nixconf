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
      unset WAYLAND_DISPLAY

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
      # Limbus Company on Steam (Proton) is usually at ~/.local/share/Steam/steamapps/common/Limbus Company/
      # We symlink the real Linux path to the expected Windows path in the AALC Wine prefix.
      GAME_FAKE_PATH="$WINEPREFIX/drive_c/Program Files (x86)/Steam/steamapps/common/Limbus Company"
      mkdir -p "$(dirname "$GAME_FAKE_PATH")"
      REAL_GAME_DIR="$HOME/.local/share/Steam/steamapps/common/Limbus Company"
      if [ -d "$REAL_GAME_DIR" ] && [ ! -L "$GAME_FAKE_PATH" ]; then
        echo "Symlinking Limbus Company to AALC prefix..."
        ln -s "$REAL_GAME_DIR" "$GAME_FAKE_PATH"
      fi

      # FIX: Automatically update config.yaml to point to the correct paths and use background mode if needed.
      CONFIG_FILE="$APP_DIR/app/config/config.yaml"
      if [ -f "$CONFIG_FILE" ]; then
        # Ensure game_path and game_process_name match what AALC expects or our symlink
        # Note: AALC v1.4.10 uses a specific config structure.
        # We can use sed to update it if it already exists, or just let the user know.
        echo "Updating AALC configuration..."
        sed -i 's|game_path:.*|game_path: "C:\\\\Program Files (x86)\\\\Steam\\\\steamapps\\\\common\\\\Limbus Company\\\\LimbusCompany.exe"|' "$CONFIG_FILE"
      fi

      if [ ! -d "$RUNNER_DIR" ]; then
        echo "Downloading and extracting Kron4ek Wine..."
        mkdir -p "$RUNNER_DIR"
        ${pkgs.wget}/bin/wget -qO- ${runnerUrl} | ${pkgs.gnutar}/bin/tar -xJ --strip-components=1 -C "$RUNNER_DIR"
      fi

      export WINE=$(find "$RUNNER_DIR" -name "wine" -type f -executable | head -n 1)

      if [ ! -f "$APP_DIR/wpf_fixed" ]; then
        echo "Applying compatibility fixes to Wine..."

        ${pkgs.steam-run}/bin/steam-run ${pkgs.winetricks}/bin/winetricks -q vcrun2022

        # Disable WPF Hardware Acceleration to kill the invisible shadow boxes
        ${pkgs.steam-run}/bin/steam-run "$WINE" reg add "HKCU\Software\Microsoft\Avalon.Graphics" /v DisableHWAcceleration /t REG_DWORD /d 1 /f

        # Ensure Wine uses its own window management correctly inside gamescope
        ${pkgs.steam-run}/bin/steam-run "$WINE" reg add "HKCU\Software\Wine\X11 Driver" /v Decorated /t REG_SZ /d Y /f
        ${pkgs.steam-run}/bin/steam-run "$WINE" reg add "HKCU\Software\Wine\X11 Driver" /v Managed /t REG_SZ /d Y /f

        touch "$APP_DIR/wpf_fixed"
      fi

      cd "$(dirname "$EXE_PATH")"

      echo "Launching AALC via gamescope..."
      # Gamescope provides a stable X11 environment for Wine, fixing WPF clickability issues on Sway.
      # NOTE: For AALC to detect Limbus Company, they should ideally share the same X server (Xwayland/Gamescope).
      # If detection fails, try running the game inside this same gamescope instance.
      exec ${pkgs.steam-run}/bin/steam-run ${pkgs.gamescope}/bin/gamescope -W 1280 -H 720 -r 60 -- "$WINE" "$EXE_PATH"
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
