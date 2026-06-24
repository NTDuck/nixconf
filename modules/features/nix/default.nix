{
  den,
  inputs,
  ...
}: {
  den.aspects.nix = {
    nixos = {pkgs, ...}: {
      nixpkgs.config.allowUnfree = true;
      nixpkgs.overlays = [
        (final: prev: {
          unstable = import inputs.nixpkgs-unstable {
            system = pkgs.stdenv.hostPlatform.system;
            config.allowUnfree = true;
          };
        })
      ];
    };
  };
}
