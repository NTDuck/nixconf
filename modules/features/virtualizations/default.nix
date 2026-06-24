{den, ...}: {
  den.aspects.virtualizations = {
    includes = [
      den.aspects.virtualbox
      den.aspects.waydroid
    ];
  };
}
