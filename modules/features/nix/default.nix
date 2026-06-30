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
        allowInsecure = true;
        allowUnfree = true;

        allowInsecurePredicate = pkg:
          pkg
          |> lib.getName
          |> (name: builtins.elem name ["pnpm"]);
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
