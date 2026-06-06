{ inputs, pkgs, config, lib, ... }:
{
  flake.modules.homeManager.imv = {

  programs.imv = {
    enable = true;
    package = pkgs.unstable.imv;
  };

  };
}
