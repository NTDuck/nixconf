{ den, ... }:
{
  den.aspects.lenovoLegionPro16Iah7h = {
    includes = [
      den.aspects.userAyin
      den.aspects.battery
      den.aspects.bluetooth
      den.aspects.cachyosKernel
    ];
    nixos = { config, lib, pkgs, inputs, ... }: {
      imports = [ ./private/hardware/default.nix ];
      this.hostname = "lenovo-legion-pro-16-iah7h";
    };
  };
}
