{
  den,
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.den.flakeModules.default
    # inputs.flake-file.flakeModules.default
  ];

  den = let
    # den.denful.dev/guides/custom-classes/#example-alias-a-class-into-the-target-root
    homeManager-alias = {
      class,
      aspect-chain,
    }:
      den.batteries.forward {
        each = lib.singleton class;
        fromClass = _: "homeManager";
        intoClass = _: "homeManager";
        intoPath = _: [];
        fromAspect = _: lib.head aspect-chain;
        adaptArgs = {config, ...}: {osConfig = config;};
      };
  in {
    default = {
      includes = [
        den.batteries.inputs'
        den.batteries.self'

        den.batteries.define-user
        den.batteries.hostname

        homeManager-alias
      ];

      nixos = {
        config = {
          system.stateVersion = "26.05";

          homeManager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
          };
        };
      };

      homeManager = {
        config.home = {
          stateVersion = "26.05";
        };
      };
    };

    schema = {
      host = {
        includes = [
          den.batteries.host-aspects
        ];

        classes = ["nixos"];
      };

      user.classes = lib.mkDefault ["nixos" "homeManager"];
    };
  };
}
