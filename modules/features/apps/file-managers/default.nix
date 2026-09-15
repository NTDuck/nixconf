{den, ...}: {
  den.aspects.apps.file-managers = {
    includes = [
      den.aspects.apps.file-managers.nemo
      den.aspects.apps.file-managers.yazi
    ];
  };
}
