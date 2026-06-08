{
  flake.modules.nixos.speedtest = {pkgs, ...}: {
    environment.systemPackages = [pkgs.unstable.speedtest-cli];
  };
}
