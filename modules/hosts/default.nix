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
}
