{ inputs, pkgs, config, lib, ... }:
{
  flake.modules.nixos.steam = {

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  hardware.graphics.enable32Bit = true;

  };
}
