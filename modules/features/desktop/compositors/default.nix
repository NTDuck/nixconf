{den, ...}: {
  den.aspects.desktop.compositors = {
    includes = [
      den.aspects.desktop.compositors.mangowm
      den.aspects.desktop.compositors.spectrwm
    ];
  };
}
