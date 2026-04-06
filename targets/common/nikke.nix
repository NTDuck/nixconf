{pkgs, ...}: let
  runnerUrl = "https://github.com/wine-cachyos/releases/releases/download/10.0-1/wine-cachyos-miniloader-fonts-10.0-1-x86_64.tar.xz";

  nikke-launcher = pkgs.writeShellScriptBin "nikke-launcher" ''
    APP_DIR="$HOME/.local/share/nikke"
    RUNNER_DIR="$APP_DIR/runner"
    export WINEPREFIX="$APP_DIR/wineprefix"
    export WINEDLLOVERRIDES="winemenubuilder.exe=d"

    mkdir -p "$APP_DIR"

    # 1. Fetch and extract the CachyOS Miniloader reproducibly
    if [ ! -d "$RUNNER_DIR" ]; then
      echo "Downloading and extracting wine-cachyos-miniloader..."
      mkdir -p "$RUNNER_DIR"
      ${pkgs.wget}/bin/wget -qO- ${runnerUrl} | ${pkgs.gnutar}/bin/tar -xJ -C "$RUNNER_DIR"
    fi

    # 2. Install Winetricks dependencies (arial)
    if [ ! -f "$APP_DIR/winetricks_done" ]; then
      echo "Installing Arial font dependency..."
      ${pkgs.winetricks}/bin/winetricks -q arial
      touch "$APP_DIR/winetricks_done"
    fi

    WINE_EXEC=$(find "$RUNNER_DIR" -name "wine" -type f -executable | head -n 1)

    # 3. Launch logic
    if [ -z "$1" ]; then
      LAUNCHER="$WINEPREFIX/drive_c/NIKKE/Launcher/nikke_launcher.exe"
      if [ -f "$LAUNCHER" ]; then
        echo "Launching NIKKE..."
        exec "$WINE_EXEC" "$LAUNCHER"
      else
        echo "NIKKE not found. To install, run: nikke-launcher /path/to/nikke_installer.exe"
        # Optional: Pop up a simple GUI warning if launched from Desktop without installer
        ${pkgs.libnotify}/bin/notify-send "NIKKE" "Run 'nikke-launcher /path/to/installer.exe' in terminal first."
      fi
    else
      echo "Running provided executable: $1"
      exec "$WINE_EXEC" "$1"
    fi
  '';

  desktopItem = pkgs.makeDesktopItem {
    name = "nikke";
    desktopName = "Goddess of Victory: NIKKE";
    exec = "nikke-launcher";
    terminal = false;
    categories = ["Game"];
  };
in {
  environment.systemPackages = [
    nikke-launcher
    desktopItem
  ];
}
