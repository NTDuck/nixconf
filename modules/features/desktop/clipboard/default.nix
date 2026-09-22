{den, ...}: {
  den.aspects.desktop.clipboard = {
    includes = [
      den.aspects.desktop.clipboard.cliphist
      den.aspects.desktop.clipboard.clipmenu
    ];
  };
}
