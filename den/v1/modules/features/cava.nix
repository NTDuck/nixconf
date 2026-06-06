{ inputs, pkgs, config, lib, ... }:
{
  flake.modules.homeManager.cava = {

  home.packages = [
    pkgs.unstable.cava
  ];

  };
}
