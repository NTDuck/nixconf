{ den, inputs, ... }: {
  den.aspects.\"nixpkgs-overlays\" = {
    nixos = { pkgs, ... }: {
      nixpkgs.config.allowUnfree = true;
      nixpkgs.overlays = [
        inputs.nur.overlays.default
        inputs.rust-overlay.overlays.default
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
