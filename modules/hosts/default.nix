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

  den.schema.user.classes = lib.mkDefault ["homeManager"];

  den.default.homeManager = {
    home.stateVersion = "26.05";
  };

  den.default.nixos = {
    system.stateVersion = "26.05";
  };
}
