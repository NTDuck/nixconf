{den, ...}: {
  den.aspects.desktop.auth = {
    includes = [
      den.aspects.desktop.auth.gnome-keyring
      den.aspects.desktop.auth.lockscreen
      den.aspects.desktop.auth.polkit
    ];
  };
}
