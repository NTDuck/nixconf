{den, ...}: {
  den.aspects.dell-latitude-E7270-H836QF2.provides.to-users = {user, ...}: {
    nixos = {
      boot.kernelModules = ["brcmfmac" "btusb"];
    };
  };
}
