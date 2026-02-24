{
  nixConfig = {};

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    niri.url = "github:sodiboo/niri-flake";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    niri,
    ...
  }: {
    nixosConfigurations = {
      dell-latitude-E7270-H836QF2 = let
        system = "x86_64-linux";
        hostname = "dell-latitude-E7270-H836QF2";
        username = "ayin";

        specialArgs = { inherit system hostname username; };
      in
        nixpkgs.lib.nixosSystem {
          inherit specialArgs;

          modules = [
            ./targets/${hostname}  # default.nix

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
        };
    };
  };
}

# 528491