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
      host.classes = ["nixos"];
      user.classes = lib.mkDefault ["nixos" "homeManager"];
    };
  };
}
