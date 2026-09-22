# moonlight-qt client; pairs with the sunshine host on the Legion over LAN
{den, ...}: {
  den.aspects.remote-desktop.moonlight = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.moonlight-qt
      ];
    };
  };
}
