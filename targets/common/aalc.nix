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
            # We use find to locate the file as the directory structure in the 7z can vary.
            find $out/opt/aalc -name "config_typing.py" -exec sed -i 's|Program Files (x86\\Steam|Program Files (x86)\\Steam|g' {} +
            
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
        
        # FIX: Find the running wineserver of the game and use its socket.
        # This is essential for FindWindow to work across different Wine builds.
        # We also need to use the same DISPLAY as the game.
        GAME_PID=$(pgrep -f "LimbusCompany.exe" | head -n 1)
        if [ -n "$GAME_PID" ]; then
          echo "Found Limbus Company process ($GAME_PID). Syncing environment..."
          # Inherit the DISPLAY from the game process correctly
          # Using -P to ensure we match only the variable starting with DISPLAY
          GAME_DISPLAY=$(grep -zP "^DISPLAY=" /proc/$GAME_PID/environ | tr -d '\0' | cut -d= -f2-)
          if [ -n "$GAME_DISPLAY" ]; then
            export DISPLAY="$GAME_DISPLAY"
            echo "Using DISPLAY: $DISPLAY"
          fi
          # Attempt to join the same wineserver by using the same prefix.
          # To be safe, we also try to find the specific wineserver binary.
          GAME_WINESERVER=$(pgrep -u $(id -u) -f "wineserver" | head -n 1 | xargs -I{} readlink -f /proc/{}/exe)
          if [ -x "$GAME_WINESERVER" ]; then
             echo "Using Game's wineserver: $GAME_WINESERVER"
             export WINESERVER="$GAME_WINESERVER"
          fi
        fi
      else
        export WINEPREFIX="$APP_DIR/wineprefix"
        echo "Warning: Steam prefix not found at $STEAM_PREFIX."
      fi

      export WINEDLLOVERRIDES="winemenubuilder.exe=d"

      # THE FIX: Force XWayland. Native Wayland Wine completely breaks WPF mouse inputs.
      # And AALC MUST share the same X server as the game to 'see' its window.
      unset WAYLAND_DISPLAY
      [ -z "$DISPLAY" ] && export DISPLAY=:0

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

      # FIX: Create a fake Windows path to the game in our prefix.
      # AALC v1.4.10 has a literal typo in its default path: "Program Files (x86\Steam" (missing parenthesis).
      # We create both the correct and the typoed path to be safe.
      REAL_GAME_DIR="$HOME/.local/share/Steam/steamapps/common/Limbus Company"
      if [ -d "$REAL_GAME_DIR" ]; then
        # 1. Correct path
        GAME_FAKE_PATH="$WINEPREFIX/drive_c/Program Files (x86)/Steam/steamapps/common/Limbus Company"
        mkdir -p "$(dirname "$GAME_FAKE_PATH")"
        [ ! -L "$GAME_FAKE_PATH" ] && ln -s "$REAL_GAME_DIR" "$GAME_FAKE_PATH"
        
        # 2. Typoed path (matches AALC's log: "Program Files (x86\Steam")
        GAME_TYPO_PATH="$WINEPREFIX/drive_c/Program Files (x86\Steam/steamapps/common/Limbus Company"
        mkdir -p "$(dirname "$GAME_TYPO_PATH")"
        [ ! -L "$GAME_TYPO_PATH" ] && ln -s "$REAL_GAME_DIR" "$GAME_TYPO_PATH"
      fi

      # FIX: Automatically update config.yaml
      CONFIG_FILE="$APP_DIR/app/config/config.yaml"
      if [ -f "$CONFIG_FILE" ]; then
        echo "Updating AALC configuration..."
        sed -i 's|game_path:.*|game_path: "C:\\\\Program Files (x86)\\\\Steam\\\\steamapps\\\\common\\\\Limbus Company\\\\LimbusCompany.exe"|' "$CONFIG_FILE"
        # On Linux, the process name in psutil might not have the .exe extension
        sed -i 's|game_process_name:.*|game_process_name: "LimbusCompany"|' "$CONFIG_FILE"
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
        # wmp9 is often needed for WPF apps that play media or notifications
        ${pkgs.steam-run}/bin/steam-run ${pkgs.winetricks}/bin/winetricks -q vcrun2022 wmp9
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
