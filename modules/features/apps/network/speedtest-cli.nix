{den, ...}: {
  den.aspects.apps.network.speedtest-cli = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.speedtest-cli
      ];
    };
  };
}
