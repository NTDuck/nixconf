{
  den,
  inputs,
  config,
  lib,
  ...
}: {
  # Hardware config for this specific host
  den.default.nixos = { config, ... }: lib.mkIf (config.networking.hostName == "dell-latitude-E7270-H836QF2") {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

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

    nixpkgs.hostPlatform = "x86_64-linux";
  };

  # Host registration
  den.hosts.x86_64-linux.dell-latitude-E7270-H836QF2 = {
    includes = [
      den.aspects.blob
    ];
    users.ayin = {
      includes = [
        den.batteries.primary-user
        (den.batteries.user-shell "zsh")
      ];
    };
  };

  den.aspects.network-driver = {
    nixos = {config, ...}: let
      broadcom_sta = config.boot.kernelPackages.broadcom_sta;
    in {
      boot.kernelModules = ["wl"];
      boot.blacklistedKernelModules = ["b43" "bcma"];
      boot.extraModulePackages = [broadcom_sta];
    };
  };
}
