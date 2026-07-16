{den, ...}: {
  den.aspects.hp-probook-450g3-5CD8132YC3.nixos = {
    config,
    lib,
    modulesPath,
    ...
  }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "sd_mod" "rtsx_pci_sdmmc"];
    boot.initrd.kernelModules = [];
    boot.kernelModules = ["kvm-intel"];
    boot.extraModulePackages = [];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/6a5f5f0e-d1d9-4ba3-b0ed-32b5289c408e";
      fsType = "btrfs";
      options = ["subvol=@"];
    };

    fileSystems."/home" = {
      device = "/dev/disk/by-uuid/6a5f5f0e-d1d9-4ba3-b0ed-32b5289c408e";
      fsType = "btrfs";
      options = ["subvol=@home"];
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/7563-564F";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };

    swapDevices = [
      {device = "/dev/disk/by-uuid/6561ae85-6ede-4b42-a200-a1fd04e26628";}
    ];

    services.udev.extraHwdb = ''
      # This host's internal keyboard has a faulty grave/backtick key that can
      # fire uncontrollably. The rule is host-local, so the broad AT keyboard
      # match is intentional and does not affect external hosts.
      evdev:atkbd:dmi:*
        KEYBOARD_KEY_29=reserved
    '';

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
