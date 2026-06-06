{ inputs, pkgs, config, lib, ... }:
{
  flake.modules.homeManager.cliphist = {

  services.cliphist = {
    enable = true;
    package = pkgs.unstable.cliphist;

    allowImages = true;
  };

  };
}
