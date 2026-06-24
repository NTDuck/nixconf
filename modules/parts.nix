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

  den.default.includes = [
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
}
