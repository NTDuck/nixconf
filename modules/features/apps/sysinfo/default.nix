{den, ...}: {
  den.aspects.apps.sysinfo = {
    includes = [
      den.aspects.apps.sysinfo.fastfetch
    ];
  };
}
