{den, ...}: {
  den.aspects.desktop.fs = {
    includes = [
      den.aspects.desktop.fs.gvfs
    ];
  };
}
