{den, ...}: {
  den.aspects.git-xet = {
    homeManager = {pkgs, ...}: {home.packages = [pkgs.unstable.git-xet];};
  };
}
