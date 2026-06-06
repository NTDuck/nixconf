{ inputs, pkgs, config, lib, ... }:
{
  flake.modules.homeManager.mpv = {

  programs.mpv = {
    enable = true;
    package = pkgs.unstable.mpv;
  };

  };
}
