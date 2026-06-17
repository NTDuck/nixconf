{den, ...}: {
  den.aspects.git-xet = {
    homeManager = {pkgs, ...}: {home.packages = [pkgs.git-xet];};
  };
}
