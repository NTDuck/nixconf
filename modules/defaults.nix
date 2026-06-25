{
  den,
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.den.flakeModules.default
    inputs.flake-file.flakeModules.default
  ];

  den = {
    default = {
      includes = [
        den.batteries.inputs'
        den.batteries.self'

        den.batteries.define-user
        den.batteries.hostname

        (
          {
            class,
            aspect-chain,
          }:
            den.batteries.forward {
              each = lib.singleton class;
              fromClass = _: "home-manager";
              intoClass = _: "homeManager";
              intoPath = _: []; # merge into root of homeManager
              fromAspect = _: lib.head aspect-chain;
              adaptArgs = {config, ...}: {osConfig = config;};
            }
        )
      ];

      nixos = {
        config = {
          system.stateVersion = "26.05";

          home-manager = {
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
