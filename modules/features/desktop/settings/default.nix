{den, ...}: {
  den.aspects.desktop.settings = {
    includes = [
      den.aspects.desktop.settings.dconf
    ];
  };
}
