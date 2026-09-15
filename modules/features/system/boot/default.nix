{den, ...}: {
  den.aspects.system.boot = {
    includes = [
      den.aspects.system.boot.systemd
    ];
  };
}
