{den, ...}: {
  den.aspects.desktop.clipboard.cliphist = {
    homeManager = {pkgs, ...}: {
      services.cliphist = {
        enable = true;
        package = pkgs.unstable.cliphist;

        # Default is stable pkgs.wl-clipboard; labwc pulls unstable
        # wl-clipboard and both variants ship a hidden .wl-copy-wrapped
        # subpath — two store paths, one subpath → buildEnv "conflicting
        # subpath" abort (DELL labwc build, 2026-09-18). One canonical
        # copy: everything consumes the unstable one.
        clipboardPackage = pkgs.unstable.wl-clipboard;

        allowImages = true;
      };
    };
  };
}
