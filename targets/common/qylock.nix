{ pkgs, ... }:

let
  qylock-src = pkgs.fetchFromGitHub {
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
      exec ${pkgs.quickshell}/bin/quickshell "$@" ${qylock-src}/LockScreen.qml
    '')
  ];
}
