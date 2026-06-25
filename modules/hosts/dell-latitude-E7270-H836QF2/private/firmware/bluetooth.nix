{den, ...}: {
  den.aspects.dell-latitude-E7270-H836QF2.firmware.bluetooth = {
    nixos = {
      boot.kernelModules = ["brcmfmac" "btusb"];
    };
  };
}
