{den, ...}: {
  den.aspects.apps.network = {
    includes = [
      den.aspects.apps.network.speedtest-cli
      den.aspects.apps.network.tailscale
      den.aspects.apps.network.moonlight
    ];
  };
}
