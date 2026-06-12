{ den, ... }:
{
  den.aspects."dell-latitude-E7270-H836QF2" = {
    includes = [
      den.aspects.userAyin
      den.aspects."battery"
      den.aspects."bluetooth"
      den.aspects."cachyos-kernel"
    ];
    nixos = { config, lib, pkgs, inputs, ... }: {
      imports = [ ./private/hardware/default.nix ];
      this.hostname = "dell-latitude-E7270-H836QF2";
    };
  };
}
