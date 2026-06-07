{
  inputs,
  config,
  ...
}: {
  flake.modules.nixos.speedtest = {pkgs, ...}: {
    environment.systemPackages = [pkgs.speedtest-cli];
  };
}
