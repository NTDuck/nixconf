{den, ...}: {
  den.aspects.lix = {
    nixos = {pkgs, ...}: {
      # https://lix.systems/add-to-config/
      nix.package = pkgs.lixPackageSets.stable.lix;

      nixpkgs.overlays = [
        (final: prev: {
          inherit
            (prev.lixPackageSets.stable)
            nixpkgs-review
            # DO_NOT_UNCOMMENT (infinite recursion)
            # nix-direnv
            nix-eval-jobs
            nix-fast-build
            colmena
            ;
        })
      ];

      # https://wiki.lix.systems/books/contributing/page/running-lix-main
      # imports = [
      #   inputs.lix-module.nixosModules.default
      # ];
    };
  };
}
