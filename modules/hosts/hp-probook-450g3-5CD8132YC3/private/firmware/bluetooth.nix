{den, ...}: {
  den.aspects.hp-probook-450g3-5CD8132YC3.nixos = {
    boot.kernelModules = ["brcmfmac" "btusb"];
  };
}
