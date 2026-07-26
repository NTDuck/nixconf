{
  den,
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.den.flakeModules.default
  ];

  den = {
    default = {
      includes = [
        den.batteries.inputs'
        den.batteries.self'

        den.batteries.define-user
        den.batteries.hostname
      ];

      nixos.config = {
        system.stateVersion = "26.05";

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "backup";
        };
      };

      homeManager.config.home.stateVersion = "26.05";
    };

    schema.user = {
      # `homeManager` configurations are defined in host aspects and need to be defined to users
      includes = [den.batteries.host-aspects];
      classes = lib.mkDefault ["homeManager"];
    };
  };
}
