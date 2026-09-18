{den, ...}: {
  den.aspects.desktop.notifications.mako = {
    homeManager = {pkgs, ...}: {
      services.mako = {
        enable = true;
        package = pkgs.unstable.mako;
      };
    };
  };
}
