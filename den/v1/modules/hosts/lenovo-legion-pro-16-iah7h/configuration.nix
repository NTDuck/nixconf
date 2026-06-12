{ den, config, ... }:
{
  den.aspects."lenovo-legion-pro-16-iah7h" = {
    includes = [
      config.den.aspects.userAyin
      config.den.aspects.battery
      config.den.aspects.bluetooth
      config.den.aspects.cachyosKernel
    ];
    nixos = { config, lib, pkgs, ... }: {
      imports = [ ./private/hardware/default.nix ];
      this.hostname = "lenovo-legion-pro-16-iah7h";
    };
  };
}
