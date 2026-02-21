{
  nixConfig = {};

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # IGNORE THIS FOR NOW
    # broadcom-bt-firmware.url = "github:winterheart/broadcom-bt-firmware";
    # broadcom-bt-firmware.flake = false;
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    # broadcom-bt-firmware,
    ...
  }: {
    nixosConfigurations = {
      dell-latitude-E7270-H836QF2 = let
        system = "x86_64-linux";
        username = "admin";
      in
        nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = { inherit username; };

          modules = [
            ./targets/dell-latitude-E7270-H836QF2  # /default.nix
          ];
        };
    };
  };
}
