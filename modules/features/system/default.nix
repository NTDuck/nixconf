{den, ...}: {
  den.aspects.system = {
    includes = [
      den.aspects.system.bluetooth
      den.aspects.system.boot
      den.aspects.system.hardware
      den.aspects.system.kernel
      den.aspects.system.network
      den.aspects.system.nix
      den.aspects.system.secrets
      den.aspects.system.settings
      den.aspects.system.storage
      den.aspects.system.swap
      den.aspects.system.virtualization
    ];
  };
}
