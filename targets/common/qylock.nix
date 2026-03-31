{ pkgs, ... }:

let
  qylock = pkgs.fetchFromGitHub {
    owner = "Darkkal44";
    repo = "qylock";
    rev = "29db82fc020f3881c6963951bae8979de27f0759";
    hash = "sha256-GSKeLJxWHkYSpRzVpqMBd/+IkPDoBgV0veHOMG/IQxE="; # pkgs.lib.fakeHash;
  };
in
{
  environment.systemPackages = [
    pkgs.quickshell
    pkgs.qt6.qtdeclarative
    pkgs.qt6.qtwayland

    (pkgs.writeShellScriptBin "qylock" ''
        # The qylock repository is a collection of themes.
        # Specify your preferred theme folder here (e.g., "paper", "nier-automata", "coffee")
        DESIRED_THEME="windows_7"

        # Search for the LockScreen.qml of the desired theme (case-insensitive)
        QML_PATH=$(find ${qylock} -iname "LockScreen.qml" -o -iname "lock.qml" -o -iname "lockscreen.qml" | grep -i "$DESIRED_THEME" | head -n 1)

        # Fallback to the first available theme if the desired one isn't found
        if [ -z "$QML_PATH" ]; then
        QML_PATH=$(find ${qylock} -iname "LockScreen.qml" -o -iname "lock.qml" -o -iname "lockscreen.qml" | head -n 1)
        fi

        if [ -z "$QML_PATH" ]; then
        echo "Error: Could not find any LockScreen.qml in ${qylock}"
        exit 1
        fi

        exec ${pkgs.quickshell}/bin/quickshell "$@" -p "$QML_PATH"
    '')
  ];
}
