# HP ProBook 450 G3 hardware placeholder (2026-10-30):
# Hardware is not yet specified/scanned. Placeholders use lib.mkDefault
# so flake evaluation succeeds and nixos-generate-config can override them.
{den, ...}: {
  den.aspects.hp-probook-450-g3-xxxx = {
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
    };
  };
}
