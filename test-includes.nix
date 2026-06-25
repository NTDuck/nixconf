let
  flake = builtins.getFlake (toString ./.);
  dell = flake.nixosConfigurations.dell-latitude-E7270-H836QF2;
in
  dell.config.den.aspects.dell-latitude-E7270-H836QF2.includes
