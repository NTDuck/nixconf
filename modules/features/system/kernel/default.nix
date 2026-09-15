{den, ...}: {
  den.aspects.system.kernel = {
    includes = [
      den.aspects.system.kernel.cachyos-kernel
    ];
  };
}
