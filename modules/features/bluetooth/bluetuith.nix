{den, ...}: {
  den.aspects.bluetooth.bluetuith = {
    homeManager = {pkgs, ...}: {
      programs.bluetuith = {
        enable = true;
        package = pkgs.unstable.bluetuith;
      };
    };
  };
}
