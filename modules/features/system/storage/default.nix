{den, ...}: {
  den.aspects.system.storage = {
    includes = [
      den.aspects.system.storage.fstrim
      den.aspects.system.storage.udisks2
    ];
  };
}
