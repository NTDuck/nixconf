{
  den,
  config,
  ...
}: {
  den.aspects."dell-latitude-E7270-H836QF2" = {
    includes = [
      config.den.aspects.ayin
      config.den.aspects.battery
      config.den.aspects.bluetooth
      config.den.aspects."cachyos-kernel"
    ];
    nixos = {
      config,
      lib,
      pkgs,
      ...
    }: {
      imports = [./private/hardware/default.nix];
    };
  };
}
