{
  den,
  inputs,
  ...
}: {
  den.aspects.nix = {
    nixos = {pkgs, ...}: let
      config = {
        allowUnfree = true;
        allowBroken = false;
      };
    in {
      nixpkgs = {
        inherit config;

        overlays = [
          (final: prev: {
            unstable = import inputs.nixpkgs-unstable {
              system = pkgs.stdenv.hostPlatform.system;
              inherit config;
            };
          })
        ];
      };
    };
  };
}
