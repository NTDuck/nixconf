{
  den,
  inputs,
  lib,
  ...
}: {
  den.default.includes = [
    den.batteries.inputs'
    den.batteries.self'

    den.batteries.define-user
    den.batteries.hostname
    den.batteries.host-aspects
  ];

  # den.schema.host.includes = [
  #   (inputs.import-tree ./private)
  # ];

  # den.schema.host.classes = ["nixos"];
  den.schema.user.classes = lib.mkDefault ["homeManager"];

  den.default.homeManager = {
    config.home.stateVersion = "26.05";
  };

  den.default.nixos = {
    config.system.stateVersion = "26.05";
    config.home-manager.useGlobalPkgs = true;
    config.home-manager.useUserPackages = true;
  };
}
