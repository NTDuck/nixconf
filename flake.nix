{
  nixConfig = {
    extra-substituters = [
      "https://attic.xuyh0120.win/lantian" # `xddxdd`'s CachyOS Kernel binary cache, Hydra CI
      "https://cache.garnix.io" # `xddxdd`'s CachyOS Kernel binary cache, Garnix CI
    ];
    extra-trusted-public-keys = [
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" # `xddxdd`'s CachyOS Kernel binary cache, Hydra CI
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" # `xddxdd`'s CachyOS Kernel binary cache, Garnix CI
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:nix-community/stylix/release-25.11";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    # Kernel
    cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    # Secrets
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-unstable,
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
              self
              inputs
              system
              hostname
              username
              ;
          };

          modules = [
            (
              { ... }:
              {
                nixpkgs.config.allowUnfree = true;

                nixpkgs.overlays = [
                  (final: prev: {
                    unstable = import nixpkgs-unstable {
                      inherit system;
                      config.allowUnfree = true;
                    };
                  })
                ];
              }
            )

            "${self}/targets/${hostname}" # default.nix

            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";

              home-manager.extraSpecialArgs = {
                inherit
                  self
                  inputs
                  system
                  hostname
                  username
                  ;
              };
              home-manager.users.${username} = import "${self}/users/${username}"; # default.nix
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
