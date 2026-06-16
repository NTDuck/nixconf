{den, ...}: {
  den.aspects.bluetooth = {
    nixos = {
      boot.kernelModules = ["brcmfmac" "btusb"];
    };
  };
}
