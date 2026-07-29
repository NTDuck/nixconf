{den, ...}: {
  den.aspects.utilities.screenshots.swappy = {
    homeManager = {pkgs, ...}: {
      programs.swappy = {
        enable = true;
        package = pkgs.unstable.swappy;
      };
    };
  };
}
