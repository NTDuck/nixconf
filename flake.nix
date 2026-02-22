{
  nixConfig = {};

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    ...
  }: {
    nixosConfigurations = {
      dell-latitude-E7270-H836QF2 = let
        system = "x86_64-linux";
        hostname = "dell-latitude-E7270-H836QF2";
        username = "ayin";
      in
        nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = { inherit system hostname username; };

          modules = [
            ./targets/${hostname}  # default.nix

            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              
              home-manager.extraSpecialArgs = inputs // specialArgs;
              home-manager.users.${username} = import ./users/${username};  # default.nix
            }
          ];
        };
    };
  };
}
