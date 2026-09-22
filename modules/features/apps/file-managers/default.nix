{den, ...}: {
  den.aspects.apps.file-managers = {
    includes = [
      den.aspects.apps.file-managers.nemo
      den.aspects.apps.file-managers.pcmanfm
      den.aspects.apps.file-managers.tfm
    ];
  };
}
