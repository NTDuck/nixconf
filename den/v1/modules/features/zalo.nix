{ inputs, pkgs, config, lib, ... }:
{
  flake.modules.homeManager.zalo = {

  home.packages = [
    zalo
  ];

  };
}
