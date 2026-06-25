{den, ...}: {
  den.aspects.multimedia.imv = {
    homeManager = {pkgs, ...}: {
      programs.imv = {
        enable = true;
        package = pkgs.unstable.imv;
      };
    };
  };
}
