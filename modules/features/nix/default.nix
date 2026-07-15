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
