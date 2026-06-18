{
  den,
  lib,
  ...
}: {
  den.default.includes = [
    den.batteries.inputs'
    den.batteries.self'

    den.batteries.define-user
    den.batteries.hostname
  ];

  den.schema.host.includes = [
    den.batteries.host-aspects
  ];

  den.schema.host.classes = ["nixos"];
  den.schema.user.classes = lib.mkDefault ["nixos" "homeManager"];

  den.default.homeManager = {
    config.home.stateVersion = "26.05";
  };

  den.default.nixos = {
    config.system.stateVersion = "26.05";
    config.home-manager.useGlobalPkgs = true;
    config.home-manager.useUserPackages = true;
  };
}
