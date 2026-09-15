{den, ...}: {
  den.aspects.system.swap = {
    includes = [
      den.aspects.system.swap.zram
    ];
  };
}
