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

  den.schema.host.classes = ["nixos"];
  den.schema.user.classes = lib.mkDefault ["homeManager"];

  den.default.homeManager = {
    options.__args = lib.mkOption {
      type = lib.types.anything;
      default = {};
    };
    config.home.stateVersion = "26.05";
  };

  den.default.nixos = {
    options.__args = lib.mkOption {
      type = lib.types.anything;
      default = {};
    };
    config.system.stateVersion = "26.05";
  };
}
