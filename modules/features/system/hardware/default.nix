{den, ...}: {
  den.aspects.system.hardware = {
    includes = [
      den.aspects.system.hardware.evtest
      den.aspects.system.hardware.openrgb
    ];
  };
}
