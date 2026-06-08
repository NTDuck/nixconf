{
  flake.modules.nixos.aalc = {
    pkgs,
    ...
  }: let
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

        find $out/opt/aalc -name "config_typing.py" -exec sed -i 's|Program Files (x86\\Steam|Program Files (x86)\\Steam|g' {} +

        mkdir -p $out/bin

        cat > $out/bin/aalc <<'INNER_EOF'
#!/bin/sh
APP_DIR="$HOME/.local/share/aalc"
RUNNER_DIR="$APP_DIR/runner"

STEAM_PREFIX="$HOME/.local/share/Steam/steamapps/compatdata/1973530/pfx"

GAME_PID=$(pgrep -f "LimbusCompany.exe" | grep -v "reaper" | grep -v "steam-launch" | head -n 1)
if [ -n "$GAME_PID" ]; then
  echo "Found Limbus Company process ($GAME_PID). Syncing environment..."

  DETECTED_PREFIX=$(grep -zP "^WINEPREFIX=" /proc/$GAME_PID/environ | tr -d '\0' | cut -d= -f2-)
  [ -n "$DETECTED_PREFIX" ] && export WINEPREFIX="$DETECTED_PREFIX" || export WINEPREFIX="$STEAM_PREFIX"

  GAME_DISPLAY=$(grep -zP "^DISPLAY=" /proc/$GAME_PID/environ | tr -d '\0' | cut -d= -f2-)
  [ -n "$GAME_DISPLAY" ] && export DISPLAY="$GAME_DISPLAY"

  GAME_XAUTH=$(grep -zP "^XAUTHORITY=" /proc/$GAME_PID/environ | tr -d '\0' | cut -d= -f2-)
  [ -n "$GAME_XAUTH" ] && export XAUTHORITY="$GAME_XAUTH"

  GAME_EXE=$(readlink -f /proc/$GAME_PID/exe)
  case "$(basename "$GAME_EXE")" in
    wine*|*preloader*)
      export WINE="$GAME_EXE"
      GAME_WINESERVER="$(dirname "$WINE")/wineserver"
      [ -x "$GAME_WINESERVER" ] && export WINESERVER="$GAME_WINESERVER"
      ;;
    *)
      echo "Process $GAME_PID is $(basename "$GAME_EXE"), not wine. Searching for Proton runner..."
      unset WINE
      ;;
  esac

  REAL_GAME_DIR=$(readlink -f /proc/$GAME_PID/cwd)
  REAL_GAME_DIR=$(echo "$REAL_GAME_DIR" | sed 's|/LimbusCompany_Data$||')

  export STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.local/share/Steam"
else
  export WINEPREFIX="$STEAM_PREFIX"
  REAL_GAME_DIR="$HOME/.local/share/Steam/steamapps/common/Limbus Company"
fi

if [ -z "$WINE" ]; then
  echo "Searching for Proton Wine runner..."
  PROTON_DIR=$(echo "$WINEPREFIX" | sed 's|/pfx||')
  WINE_SEARCH_PATH=$(find "$(dirname "$(dirname "$PROTON_DIR")")" -name "wine" -path "*/files/bin/wine" | head -n 1)
  [ -x "$WINE_SEARCH_PATH" ] && export WINE="$WINE_SEARCH_PATH" || export WINE=$(find "$HOME/.local/share/Steam/steamapps/common" -name "wine" -path "*/files/bin/wine" | head -n 1)
  [ -z "$WINE" ] && export WINE=$(find "$RUNNER_DIR" -name "wine" -type f -executable | head -n 1)
fi

echo "Final Environment:"
echo "  WINEPREFIX: $WINEPREFIX"
echo "  DISPLAY:    $DISPLAY"
echo "  XAUTHORITY: $XAUTHORITY"
echo "  WINE:       $WINE"
echo "  GAME_DIR:   $REAL_GAME_DIR"

export WINEDLLOVERRIDES="winemenubuilder.exe=d"
export WINE_FULLSCREEN_FSR=0
export PROTON_USE_SECCOMP=1

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

if [ -d "$REAL_GAME_DIR" ]; then
  echo "Creating symlinks to game directory..."
  GAME_FAKE_PATH="$WINEPREFIX/drive_c/Program Files (x86)/Steam/steamapps/common/Limbus Company"
  mkdir -p "$(dirname "$GAME_FAKE_PATH")"
  rm -rf "$GAME_FAKE_PATH"
  ln -sfn "$REAL_GAME_DIR" "$GAME_FAKE_PATH"

  GAME_TYPO_PATH="$WINEPREFIX/drive_c/Program Files (x86\Steam/steamapps/common/Limbus Company"
  mkdir -p "$(dirname "$GAME_TYPO_PATH")"
  rm -rf "$GAME_TYPO_PATH"
  ln -sfn "$REAL_GAME_DIR" "$GAME_TYPO_PATH"
fi

CONFIG_FILE="$APP_DIR/app/config/config.yaml"
if [ -f "$CONFIG_FILE" ]; then
  echo "Updating AALC configuration..."
  sed -i 's|game_path:.*|game_path: "C:\\\\Program Files (x86)\\\\Steam\\\\steamapps\\\\common\\\\Limbus Company\\\\LimbusCompany.exe"|' "$CONFIG_FILE"
  sed -i 's|game_process_name:.*|game_process_name: "LimbusCompany.exe"|' "$CONFIG_FILE"
fi

if [ ! -d "$RUNNER_DIR" ]; then
  echo "Downloading and extracting Kron4ek Wine..."
  mkdir -p "$RUNNER_DIR"
  ${pkgs.wget}/bin/wget -qO- ${runnerUrl} | ${pkgs.gnutar}/bin/tar -xJ --strip-components=1 -C "$RUNNER_DIR"
fi

if [ -z "$WINE" ]; then
  PROTON_WINE=$(find "$HOME/.local/share/Steam/steamapps/common" -name "wine" -path "*/files/bin/wine" | head -n 1)
  if [ -x "$PROTON_WINE" ]; then
    echo "Found Proton Wine: $PROTON_WINE"
    export WINE="$PROTON_WINE"
  else
    export WINE=$(find "$RUNNER_DIR" -name "wine" -type f -executable | head -n 1)
  fi
fi

if [ ! -f "$APP_DIR/wpf_fixed" ]; then
  echo "Applying compatibility fixes to Wine..."
  ${pkgs.steam-run}/bin/steam-run ${pkgs.winetricks}/bin/winetricks -q vcrun2022 wmp9
  ${pkgs.steam-run}/bin/steam-run "$WINE" reg add "HKCU\Software\Microsoft\Avalon.Graphics" /v DisableHWAcceleration /t REG_DWORD /d 1 /f
  touch "$APP_DIR/wpf_fixed"
fi

cd "$(dirname "$EXE_PATH")"

echo "Launching AALC..."
exec ${pkgs.steam-run}/bin/steam-run "$WINE" "$EXE_PATH"
INNER_EOF

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
  };
}
