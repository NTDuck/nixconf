{
  den,
  inputs,
  lib,
  ...
}: {
  den.hosts.x86_64-linux.dell-latitude-E7270-H836QF2 = {
    includes = [
      den.aspects.dell-latitude-E7270-H836QF2
    ];
    users.ayin = {
      includes = [
        den.aspects.dell-latitude-E7270-H836QF2
        den.batteries.primary-user
        (den.batteries.user-shell "zsh")
      ];
    };
  };

  den.aspects.hardware-dell-latitude-E7270 = {
    nixos = {
      config,
      lib,
      pkgs,
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

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
  };

  den.aspects.network-driver-dell-latitude-E7270 = {
    nixos = {
      config,
      lib,
      ...
    }: {
      nixpkgs.config.allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          "broadcom-sta"
        ];

      boot.kernelModules = ["wl"];
      boot.blacklistedKernelModules = ["b43" "bcma"];
      boot.extraModulePackages = [config.boot.kernelPackages.broadcom_sta];
    };
  };

  den.aspects.bluetooth-driver-dell-latitude-E7270 = {
    nixos = {
      boot.kernelModules = ["brcmfmac" "btusb"];
    };
  };

  den.aspects.dell-latitude-E7270-H836QF2 = {
    includes = [
      den.aspects.hardware-dell-latitude-E7270
      den.aspects.network-driver-dell-latitude-E7270
      den.aspects.bluetooth-driver-dell-latitude-E7270

      den.aspects.home-manager-integration
      den.aspects.agenix
      den.aspects.agent-browser
      den.aspects.alejandra
      den.aspects.antigravity-cli
      den.aspects.nixpkgs-overlays
      den.aspects.battery
      den.aspects.blob
      den.aspects.bluetooth
      den.aspects.bluetuith
      den.aspects.cachyos-kernel
      den.aspects.c-cpp
      den.aspects.cava
      den.aspects.claude-code
      den.aspects.cliphist
      den.aspects.cloudflare-warp
      den.aspects.codex
      den.aspects.docker
      den.aspects.fastfetch
      den.aspects.fcitx5
      den.aspects.firefox
      den.aspects.foot
      den.aspects.gc
      den.aspects.gh
      den.aspects.git
      den.aspects.glab
      den.aspects.greetd
      den.aspects.gtklock
      den.aspects.helix
      den.aspects.imv
      den.aspects.java-kotlin
      den.aspects.javascript-typescript
      den.aspects.kanshi
      den.aspects.lix
      den.aspects.lua
      den.aspects.mpv
      den.aspects.nh
      den.aspects.nix
      den.aspects.ollama
      den.aspects.openssh
      den.aspects.pear-desktop
      den.aspects.pipewire
      den.aspects.protobuf
      den.aspects.python
      den.aspects.qoder-cli
      den.aspects.rust
      den.aspects.speedtest-cli
      den.aspects.steam
      den.aspects.stylix
      den.aspects.sway
      den.aspects.taskwarrior
      den.aspects.tofi
      den.aspects.topiary
      den.aspects.vesktop
      den.aspects.waybar
      den.aspects.waydroid
      den.aspects.yazi
      den.aspects.zalo
      den.aspects.zathura
      den.aspects.zed-editor
      den.aspects.zsh
    ];
  };
}
