# {
#   inputs,
#   system,
#   ...
# }: {
#   home.packages = [
#     inputs.cursor.packages.${system}.cursor
#   ];
# }
{pkgs, ...}: let
  cursor = pkgs.appimageTools.wrapType2 {
    pname = "cursor";
    version = "3.0.16";
    src = pkgs.fetchurl {
      url = "https://downloader.cursor.sh/linux/appImage/x64";
      # Here we insert the exact hash Nix told us it received:
      hash = "sha256-dN8tFSppIpO/P0Thst5uaNzlmfWZDh0Y81Lx1BuSYt0=";
    };
    extraInstallCommands = ''
      install -m 444 -D ${pkgs.appimageTools.extractType2 {
        name = "cursor";
        inherit src;
      }}/cursor.png $out/share/icons/hicolor/512x512/apps/cursor.png
      install -m 444 -D ${pkgs.appimageTools.extractType2 {
        name = "cursor";
        inherit src;
      }}/cursor.desktop $out/share/applications/cursor.desktop
      substituteInPlace $out/share/applications/cursor.desktop \
        --replace 'Exec=AppRun' 'Exec=cursor'
    '';
  };
in {
  home.packages = [
    cursor
  ];
}
