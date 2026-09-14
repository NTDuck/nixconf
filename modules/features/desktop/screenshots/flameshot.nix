{den, ...}: {
  den.aspects.desktop.screenshots.flameshot = {
    homeManager = {pkgs, ...}: {
      services.flameshot = {
        enable = true;
        package = pkgs.unstable.flameshot;
      };
    };
  };
}
