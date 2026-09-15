{den, ...}: {
  den.aspects.apps.network = {
    includes = [
      den.aspects.apps.network.speedtest-cli
    ];
  };
}
