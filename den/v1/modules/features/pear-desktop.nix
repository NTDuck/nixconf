{ inputs, pkgs, config, lib, ... }:
{
  flake.modules.homeManager.pear-desktop = {

  home.packages = [
    pkgs.unstable.pear-desktop
  ];

  };
}
