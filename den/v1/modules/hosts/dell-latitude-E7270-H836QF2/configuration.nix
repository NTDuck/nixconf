{
  den,
  config,
  ...
}: {
  den.aspects."dell-latitude-E7270-H836QF2" = {
    includes = [
      config.den.aspects.userAyin
      config.den.aspects.battery
      config.den.aspects.bluetooth
      config.den.aspects.cachyosKernel
    ];
    nixos = {
      config,
      lib,
      pkgs,
      ...
    }: {
      imports = [./private/hardware/default.nix];
      this.hostname = "dell-latitude-E7270-H836QF2";
    };
  };
}
