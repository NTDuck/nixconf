{ inputs, pkgs, config, lib, ... }:
{
  flake.modules.homeManager.termusic = {

  home.packages = [
    pkgs.unstable.termusic
  ];

  };
}
