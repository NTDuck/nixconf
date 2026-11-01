# HP ProBook 450 G3 hardware specification (2026-11-01):
# Scanned on physical host (Serial 5CD8132YC3, Intel Core i7-6500U Skylake GT2).
# Default mounts use labels so nixos-generate-config can override with UUIDs.
{den, ...}: {
  den.aspects.hp-probook-450-g3-5CD8132YC3 = {
    nixos = {
      config,
      lib,
      modulesPath,
      ...
    }: {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot.initrd.availableKernelModules = lib.mkDefault [
        "xhci_pci"
        "ahci"
        "usb_storage"
        "sd_mod"
        "rtsx_pci_sdmmc"
      ];
      boot.initrd.kernelModules = lib.mkDefault [];
      boot.kernelModules = lib.mkDefault ["kvm-intel"];
      boot.extraModulePackages = lib.mkDefault [];

      fileSystems."/" = lib.mkDefault {
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
      };

      fileSystems."/boot" = lib.mkDefault {
        device = "/dev/disk/by-label/boot";
        fsType = "vfat";
      };

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      hardware.enableRedistributableFirmware = lib.mkDefault true;
    };
  };
}
