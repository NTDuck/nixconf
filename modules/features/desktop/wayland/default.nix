{den, ...}: {
  den.aspects.desktop.wayland = {
    includes = [
      den.aspects.desktop.wayland.kanshi
      den.aspects.desktop.wayland.xwayland-satellite
    ];
  };
}
