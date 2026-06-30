{
  den,
  inputs,
  lib,
  ...
}: let
  version = "26.05";
in {
  imports = [
    inputs.den.flakeModules.default
    # inputs.flake-file.flakeModules.default
  ];

  den = {
    default = {
      includes = [
        den.batteries.inputs'
        den.batteries.self'

        den.batteries.define-user
        den.batteries.hostname
      ];

      nixos = {
        config = {
          system.stateVersion = version;

          # TODO Refactor
          # nixpkgs.config.allowInsecurePredicate = pkg:
          #   pkg
          #   |> lib.getName
          #   |> (name: builtins.elem name ["pnpm"]);
          nixpkgs.config.permittedInsecurePackages = [
            "pnpm-10.29.2"
          ];

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
          };
        };
      };

      homeManager.config.home.stateVersion = version;
    };

    schema = {
      host.includes = [
        # `homeManager` configurations are defined in host aspects
        # and need to be defined to users
        # DO NOT REMOVE
        den.batteries.host-aspects
      ];

      host.classes = ["nixos"];
      user.classes = lib.mkDefault ["nixos" "homeManager"];
    };
  };
}
