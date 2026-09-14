{
  den,
  inputs,
  ...
}: {
  den.aspects.nur = {
    nixos = {
      nixpkgs.overlays = [
        inputs.nur.overlays.default
      ];
    };
  };
}
