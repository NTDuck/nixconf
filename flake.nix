{
  nixConfig = {};

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:nix-community/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel";

    niri.url = "github:sodiboo/niri-flake";
  };

  outputs = inputs @ { self, nixpkgs, home-manager, stylix, nix-cachyos-kernel, niri, ... }:
  let mkHost = specialArgs @ { system, hostname, username }: {
    nixpkgs.lib.nixosSystem {
      inherit specialArgs;

      modules = [
        ./targets/${hostname}  # default.nix
        ./stylix  # default.nix
        ./kernel  # default.nix

        home-manager.nixosModules.default
        stylix.nixosModules.stylix

        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          
          home-manager.extraSpecialArgs = inputs // specialArgs;
          home-manager.users.${username} = import ./users/${username};  # default.nix
        }

        niri.nixosModules.niri {
          nixpkgs.overlays = [
            niri.overlays.niri
          ];
        }
      ];
    }
  };

  in {
    nixosConfigurations = {
      dell-latitude-E7270-H836QF2 = mkHost {
        system = "x86_64-linux";
        hostname = "dell-latitude-E7270-H836QF2";
        username = "ayin";
      };
    };
  };
}

# 528491
