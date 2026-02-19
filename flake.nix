{
  description = "NixOS configuration of ntduckk";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    broadcom-bt-firmware.url = "github:winterheart/broadcom-bt-firmware";
    broadcom-bt-firmware.flake = false;
  };

  outputs = { self, nixpkgs, broadcom-bt-firmware, ... }:
  let
    system = "x86_64-linux";
  in {
    nixosConfigurations.nixos =
      nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          # Your normal configuration.nix
          ./configuration.nix

          # Firmware + Bluetooth module
          ({ pkgs, ... }: {

            nixpkgs.config.allowUnfree = true;

            hardware.bluetooth.enable = true;
            hardware.bluetooth.powerOnBoot = true;

            hardware.firmware = [
              (pkgs.runCommand "bcm43142-firmware" {} ''
                mkdir -p $out/lib/firmware/brcm
                cp ${broadcom-bt-firmware}/brcm/BCM43142A0-105b-e065.hcd \
                   $out/lib/firmware/brcm/
              '')
            ];
          })
        ];
      };
  };
}
