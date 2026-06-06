{ inputs, pkgs, config, lib, ... }:
{
  flake.modules.nixos.bluetooth = {

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.blueman.enable = false;

  environment.systemPackages = [
    pkgs.bluetui
  ];

  };
}
