{...}: {
  flake.modules.nixos.dell-latitude-E7270-H836QF2-bluetooth = {
    boot.kernelModules = ["brcmfmac" "btusb"];
  };
}
