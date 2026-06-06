{ inputs, pkgs, config, lib, ... }:
{
  flake.modules.homeManager.gh = {

  programs.gh = {
    enable = true;
    package = pkgs.unstable.gh;

    gitCredentialHelper.enable = true;
  };

  };
}
