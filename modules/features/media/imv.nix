{den, ...}: {
  den.aspects.imv = {
    homeManager = {pkgs, ...}: {
      programs.imv = {
        enable = true;
        package = pkgs.unstable.imv;
      };
    };
  };
}
