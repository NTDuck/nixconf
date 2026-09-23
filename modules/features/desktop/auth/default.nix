{den, ...}: {
  den.aspects.desktop.auth = {
    includes = [
      den.aspects.desktop.auth.gnome-keyring
      # slock retired for DELL (2026-09-23): i3lock + xss-lock replaced
      # it; slock stays defined for anything still referencing it.
      den.aspects.desktop.auth.i3lock
      den.aspects.desktop.auth.polkit
    ];
  };
}
