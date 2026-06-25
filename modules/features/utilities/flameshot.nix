{den, ...}: {
  den.aspects.utilities.flameshot = {
    homeManager = {pkgs, ...}: {
      services.flameshot = {
        enable = true;
        package = pkgs.unstable.flameshot;
      };
    };
  };
}
