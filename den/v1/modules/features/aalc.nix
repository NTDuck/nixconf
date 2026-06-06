{ inputs, pkgs, config, lib, ... }:
{
  flake.modules.nixos.aalc = {

  environment.systemPackages = [
    aalc
    desktopItem
  ];

  };
}
