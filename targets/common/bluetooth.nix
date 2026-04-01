{ pkgs, ... }:

{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.blueman.enable = false;

  environment.systemPackages = [
    pkgs.bluetui
  ];
}
