{den, ...}: {
  den.aspects.utilities.speedtest-cli = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [pkgs.unstable.speedtest-cli];
    };
  };
}
