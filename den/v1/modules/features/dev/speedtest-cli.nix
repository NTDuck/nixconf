{ den, inputs, ... }: {
  den.aspects.speedtestCli = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [pkgs.unstable.speedtest-cli];
    };
  };
}
