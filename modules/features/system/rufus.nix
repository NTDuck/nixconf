{den, ...}: {
  den.aspects.rufus = {
    homeManager = {pkgs, ...}: {home.packages = [pkgs.unstable.impression];};
  };
}
