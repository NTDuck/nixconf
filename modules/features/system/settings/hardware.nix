{den, ...}: {
  den.aspects.system-hardware = {
    nixos = { lib, pkgs, ... }: {
      hardware.firmware = [pkgs.linux-firmware];
      hardware.graphics.enable = true;
      hardware.enableRedistributableFirmware = lib.mkDefault true;
    };
  };
}
