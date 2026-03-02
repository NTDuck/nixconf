{
  nixConfig = {};

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:nix-community/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel";

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.noctalia-qs.follows = "noctalia-qs";
    };

    noctalia-qs = {
      url = "github:noctalia-dev/noctalia-qs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri.url = "github:sodiboo/niri-flake";
  };

  outputs = inputs @ { self, nixpkgs, home-manager, stylix, nix-cachyos-kernel, niri, ... }:
  let mkHost = specialArgs @ { system, hostname, username }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = inputs // { inherit hostname username; };

      modules = [
        ./targets/${hostname}  # default.nix
        ./kernel  # default.nix

        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          
          home-manager.extraSpecialArgs = inputs // specialArgs;
          home-manager.users.${username} = import ./users/${username};  # default.nix
        }

        stylix.nixosModules.stylix
        ./stylix  # default.nix

        ./noctalia  # default.nix
      ];
    };

  in {
    nixosConfigurations = rec {
      dell-latitude-E7270-H836QF2 = mkHost {
        system = "x86_64-linux";
        hostname = "dell-latitude-E7270-H836QF2";
        username = "ayin";
      };

      default = dell-latitude-E7270-H836QF2;
    };
  };
}

# 528491
