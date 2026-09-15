{den, ...}: {
  den.aspects.desktop.audio = {
    includes = [
      den.aspects.desktop.audio.pipewire
      den.aspects.desktop.audio.visualization
    ];
  };
}
