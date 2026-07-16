{
  den,
  inputs,
  ...
}: {
  den.aspects.nix = {
    nixos = {
      pkgs,
      lib,
      ...
    }: let
      config = {
        allowBroken = false;
        # This repository still has several unfree desktop/driver packages.
        # Keep the policy centralized until those exceptions move to aspects.
        allowUnfree = true;

        allowInsecurePredicate = pkg:
          builtins.elem (lib.getName pkg) [
            "pnpm"
            "broadcom-sta"
          ];
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
