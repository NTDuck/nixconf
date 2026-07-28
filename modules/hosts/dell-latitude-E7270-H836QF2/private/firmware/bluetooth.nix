{den, ...}: {
  den.aspects.dell-latitude-E7270-H836QF2 = {
    nixos = {
      boot.kernelModules = ["brcmfmac" "btusb"];
    };
  };
}
