{den, ...}: {
  den.aspects.dell-latitude-E7270-H836QF2-bluetooth-driver = {
    nixos = {
      boot.kernelModules = ["brcmfmac" "btusb"];
    };
  };
}
