{den, ...}: {
  den.aspects.dell-latitude-E7270-H836QF2 = {
    nixos = {pkgs, ...}: {
      boot.kernelModules = ["btusb" "btbcm"];
      hardware.firmware = [pkgs.broadcom-bt-firmware];
    };
  };
}
