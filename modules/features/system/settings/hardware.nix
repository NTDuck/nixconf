{den, ...}: {
  den.aspects.system.settings.hardware = {
    nixos = {pkgs, ...}: {
      hardware.firmware = [pkgs.linux-firmware];

      hardware.graphics.enable = true;
      hardware.enableRedistributableFirmware = true;
    };
  };
}
