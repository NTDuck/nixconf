{den, ...}: {
  den.aspects.utilities.screenshots.satty = {
    homeManager = {pkgs, ...}: {
      programs.satty = {
        enable = true;
        package = pkgs.unstable.satty;
      };
    };
  };
}
