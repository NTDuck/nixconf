{
  nixConfig = { };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:nix-community/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    # Kernel
    cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel";

    # TODO install https://kamadorueda.com/alejandra/
    # TODO use stable channels for nixosSystem & unstable channels for everything else
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      mkHost =
        {
          system,
          hostname,
          username,
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit
              inputs
              system
              hostname
              username
              ;
          };

          modules = [
            ./targets/${hostname} # default.nix

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";

              home-manager.extraSpecialArgs = { inherit inputs system hostname username; };
              home-manager.users.${username} = import ./users/${username}; # default.nix
            }
          ];
        };

    in
    {
      nixosConfigurations = rec {
        default = dell-latitude-E7270-H836QF2;

        dell-latitude-E7270-H836QF2 = mkHost {
          system = "x86_64-linux";
          hostname = "dell-latitude-E7270-H836QF2";
          username = "ayin";
        };
      };
    };
}

# 528491
