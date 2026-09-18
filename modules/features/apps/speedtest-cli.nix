{den, ...}: {
  den.aspects.apps.speedtest-cli = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.speedtest-cli
      ];
    };
  };
}
