{den, ...}: {
  den.aspects.system-settings = {
    includes = [
      den.aspects.system-boot
      den.aspects.system-hardware
      den.aspects.system-locale
      den.aspects.system-network
      den.aspects.system-nix
      den.aspects.system-state-version
      den.aspects.system-users
    ];
  };
}
