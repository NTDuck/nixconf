{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP-persist = {
    nixos = {inputs, ...}: {
      imports = [
        inputs.disko.nixosModules.disko
      ];

      fileSystems."/nix".neededForBoot = true;
      fileSystems."/persistent".neededForBoot = true; # sometimes needed too

      disko.devices.nodev = {
        "/" = {
          fsType = "tmpfs";
          mountOptions = [
            "size=25%"
            "mode=755"
          ];
        };
      };

      disko.devices.disk.main = {
        device = "/dev/nvme0n1"; # MAKE SURE TOO SELECT CORRECT DISK HERE
        type = "disk";

        content.type = "gpt";

        content.partitions.boot = {
          name = "boot";
          size = "1M";
          type = "EF02";
        };

        content.partitions.esp = {
          name = "ESP";
          size = "1G";
          type = "EF00";

          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };

        content.partitions.swap = {
          size = "16G";

          content = {
            type = "swap";
            resumeDevice = true;
          };
        };

        content.partitions.root = {
          name = "root";
          size = "100%";

          content = {
            type = "btrfs";
            extraArgs = ["-f"];

            subvolumes = {
              "/persistent" = {
                mountOptions = ["subvol=persistent" "noatime" "compress=zstd"];
                mountpoint = "/persistent";
              };

              "/nix" = {
                mountOptions = ["subvol=nix" "noatime" "compress=zstd"];
                mountpoint = "/nix";
              };
            };
          };
        };
      };
    };
  };
}
