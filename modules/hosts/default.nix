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
  ];

  den.schema.host.includes = [
    (inputs.import-tree ./private)
  ];

  den.schema.host.classes = ["nixos"];
  den.schema.user.classes = lib.mkDefault ["homeManager"];

  den.default.homeManager = {
    home.stateVersion = "26.05";
  };

  den.default.nixos = {
    system.stateVersion = "26.05";
  };
}
