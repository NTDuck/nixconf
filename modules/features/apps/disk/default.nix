{den, ...}: {
  den.aspects.apps.disk = {
    includes = [
      den.aspects.apps.disk.rufus
    ];
  };
}
