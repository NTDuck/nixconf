{
  den,
  config,
  ...
}: {
  den.aspects."lenovo-legion-pro-16-iah7h" = {
    includes = [
      config.den.aspects.ayin
      config.den.aspects.battery
      config.den.aspects.bluetooth
      config.den.aspects."cachyos-kernel"
      config.den.aspects."lenovo-legion"
    ];
    nixos = {
      config,
      lib,
      pkgs,
      ...
    }: {
      # imports = [./private/hardware/default.nix];
    };
  };
}
