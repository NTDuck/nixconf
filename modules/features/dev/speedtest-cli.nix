{
  flake.modules.nixos.speedtest-cli = {pkgs, ...}: {
    environment.systemPackages = [pkgs.unstable.speedtest-cli];
  };
}
