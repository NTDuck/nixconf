{den, ...}: {
  den.aspects.browsers.chromium = {
    homeManager = {pkgs, ...}: {
      programs.chromium = {
        enable = true;
        package = pkgs.unstable.chromium;
      };
    };
  };
}
