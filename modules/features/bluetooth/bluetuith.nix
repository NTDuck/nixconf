{den, ...}: {
  den.aspects.bluetuith = {
    home-manager = {pkgs, ...}: {
      programs.bluetuith = {
        enable = true;
        package = pkgs.unstable.bluetuith;
      };
    };
  };
}
