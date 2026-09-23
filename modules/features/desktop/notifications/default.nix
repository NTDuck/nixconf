{den, ...}: {
  den.aspects.desktop.notifications = {
    includes = [
      den.aspects.desktop.notifications.dunst
      den.aspects.desktop.notifications.mako
    ];
  };
}
