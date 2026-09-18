{den, ...}: {
  den.aspects.remote-desktop = {
    includes = [
      den.aspects.remote-desktop.moonlight
      den.aspects.remote-desktop.sunshine
    ];
  };
}
