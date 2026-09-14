{
  den,
  inputs,
  ...
}: {
  den.aspects.system.nix.nur = {
    nixos = {
      nixpkgs.overlays = [
        inputs.nur.overlays.default
      ];
    };
  };
}
