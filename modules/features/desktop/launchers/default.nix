{den, ...}: {
  den.aspects.desktop.launchers = {
    includes = [
      den.aspects.desktop.launchers.dmenu
      den.aspects.desktop.launchers.bemenu
    ];
  };
}
