{den, ...}: {
  den.aspects.utilities.screenshots.flameshot = {
    homeManager = {pkgs, ...}: {
      services.flameshot = {
        enable = true;
        package = pkgs.unstable.flameshot;
      };
    };
  };
}
