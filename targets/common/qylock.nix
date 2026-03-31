{ pkgs, ... }:

let
  qylock = pkgs.fetchFromGitHub {
    owner = "Darkkal44";
    repo = "qylock";
    rev = "29db82fc020f3881c6963951bae8979de27f0759";
    hash = "sha256-GSKeLJxWHkYSpRzVpqMBd/+IkPDoBgV0veHOMG/IQxE=";
  };
in
{
  environment.systemPackages = [
    pkgs.quickshell
    pkgs.qt6.qtdeclarative
    pkgs.qt6.qtwayland

    (pkgs.writeShellScriptBin "qylock" ''
      # Modern quickshell requires a writable config directory and a shell.qml file.
      CONFIG_DIR="$HOME/.config/quickshell/qylock"

      # Clear old configuration
      rm -rf "$CONFIG_DIR"
      mkdir -p "$CONFIG_DIR"

      # Dynamically find the directory containing the lockscreen QML file
      THEME_DIR=$(find ${qylock} -iname "LockScreen.qml" -o -iname "lock.qml" -o -iname "shell.qml" | head -n 1 | xargs dirname)

      if [ -z "$THEME_DIR" ]; then
        echo "Error: Could not find any QML lockscreen files in ${qylock}"
        exit 1
      fi

      # Copy the theme contents to our writable config directory
      cp -r "$THEME_DIR"/* "$CONFIG_DIR/"

      # Make the directory and its contents writable!
      chmod -R +w "$CONFIG_DIR"

      # Rename LockScreen.qml (or lock.qml) to shell.qml to satisfy Quickshell
      if [ -f "$CONFIG_DIR/LockScreen.qml" ]; then
        mv "$CONFIG_DIR/LockScreen.qml" "$CONFIG_DIR/shell.qml"
      elif [ -f "$CONFIG_DIR/lock.qml" ] && [ ! -f "$CONFIG_DIR/shell.qml" ]; then
        mv "$CONFIG_DIR/lock.qml" "$CONFIG_DIR/shell.qml"
      fi

      # Launch quickshell pointing to the writable config directory
      exec ${pkgs.quickshell}/bin/quickshell "$@" -p "$CONFIG_DIR"
    '')
  ];
}
