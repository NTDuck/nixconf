{
  den.aspects.\"speedtest-cli\" = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [pkgs.unstable.speedtest-cli];
    };
  };
}
