{ inputs, pkgs, config, lib, ... }:
{
  flake.modules.homeManager.vesktop = {

  programs.vesktop = {
    enable = true;
    package = pkgs.unstable.vesktop;
  };

  };
}
