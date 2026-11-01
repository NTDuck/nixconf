{den, ...}: {
  den.aspects.hp-probook-450-g3-5CD8132YC3 = {
    nixos = {pkgs, ...}: {
      # Foxconn/Broadcom BCM43142A0 Bluetooth module [105b:e065] (2026-11-01):
      # Requires proprietary patchram firmware (brcm/BCM43142A0-105b-e065.hcd)
      # provided by broadcom-bt-firmware.
      # btusb.enable_autosuspend=0 prevents adapter autosuspend during streams.
      boot.kernelModules = ["btusb" "btbcm"];
      boot.kernelParams = ["btusb.enable_autosuspend=0"];
      hardware.firmware = [pkgs.broadcom-bt-firmware];
    };
  };
}
