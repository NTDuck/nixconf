# moonlight-qt client; pairs with the sunshine host on the Legion over LAN
# (WiFi or ETH_VTIT 10.224.220.59).
{den, ...}: {
  den.aspects.apps.network.moonlight = {
    homeManager = {pkgs, ...}: {
      home.packages = [
        pkgs.moonlight-qt
      ];
    };
  };
}
