{den, ...}: {
  den.aspects.bluetooth-driver = {
    nixos = {
      boot.kernelModules = ["brcmfmac" "btusb"];
    };
  };
}
