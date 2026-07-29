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
            # Vesktop 1.6.5 in the pinned unstable set validates against
            # Electron 40 at build time; keep this exception narrow.
            "electron"
            "idea-oss"
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
