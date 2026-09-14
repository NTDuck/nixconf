{den, ...}: {
  den.aspects.apps.multimedia.imv = {
    homeManager = {pkgs, ...}: {
      programs.imv = {
        enable = true;
        package = pkgs.unstable.imv;
      };
    };
  };
}
